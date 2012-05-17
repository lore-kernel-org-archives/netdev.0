From: Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>
Subject: [PATCH 12/12] Avoid dereferencing bd_disk during swap_entry_free for network storage
Date: Thu, 17 May 2012 15:51:25 +0100
Message-ID: <1337266285-8102-13-git-send-email-mgorman@suse.de>
References: <1337266285-8102-1-git-send-email-mgorman@suse.de>
Cc: Linux-MM <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>,
	Linux-Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux-NFS <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>,
	Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Mike Christie <michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>,
	Eric B Munson <emunson-CVBTeua0HjReoWH0uzbU5w@public.gmane.org>,
	Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1337266285-8102-1-git-send-email-mgorman-l3A5Bk7waGM@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Commit [b3a27d: swap: Add swap slot free callback to
block_device_operations] dereferences p->bdev->bd_disk but this is a
NULL dereference if using swap-over-NFS. This patch checks SWP_BLKDEV
on the swap_info_struct before dereferencing.

With reference to this callback, Christoph Hellwig stated "Please
just remove the callback entirely.  It has no user outside the staging
tree and was added clearly against the rules for that staging tree".
This would also be my preference but there was not an obvious way of
keeping zram in staging/ happy.

Signed-off-by: Xiaotian Feng <dfeng-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>
---
 mm/swapfile.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 80b3415..d85d842 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -547,7 +547,6 @@ static unsigned char swap_entry_free(struct swap_info_struct *p,
 
 	/* free if no reference */
 	if (!usage) {
-		struct gendisk *disk = p->bdev->bd_disk;
 		if (offset < p->lowest_bit)
 			p->lowest_bit = offset;
 		if (offset > p->highest_bit)
@@ -557,9 +556,11 @@ static unsigned char swap_entry_free(struct swap_info_struct *p,
 			swap_list.next = p->type;
 		nr_swap_pages++;
 		p->inuse_pages--;
-		if ((p->flags & SWP_BLKDEV) &&
-				disk->fops->swap_slot_free_notify)
-			disk->fops->swap_slot_free_notify(p->bdev, offset);
+		if (p->flags & SWP_BLKDEV) {
+			struct gendisk *disk = p->bdev->bd_disk;
+			if (disk->fops->swap_slot_free_notify)
+				disk->fops->swap_slot_free_notify(p->bdev, offset);
+		}
 	}
 
 	return usage;
-- 
1.7.9.2

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
