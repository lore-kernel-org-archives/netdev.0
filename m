From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] Fix guest memory leak and panic
Date: Tue, 18 Oct 2011 13:35:23 +0530
Message-ID: <20111018080523.16861.55402.sendpatchset@krkumar2.in.ibm.com>
Cc: Ian.Campbell@citrix.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, davem@davemloft.net,
	Krishna Kumar <krkumar2@in.ibm.com>
To: rusty@rustcorp.com.au, mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 86ee8130 ("virtionet: convert to SKB paged frag API")
introduced a bug in guest. During RX testing, guest runs out
of memory within seconds, causing oom-killer; which then
panics the system: "Kernel panic - not syncing: Out of memory
and no killable processes...". /proc/meminfo just before the
panic shows MemFree is a few MB's:

	MemFree:         1928544 kB	(starts here)
	...
	...
	MemFree:           27488 kB
	MemFree:           26248 kB
	MemFree:           24636 kB
	MemFree:           22632 kB
	MemFree:           19580 kB
	MemFree:           17928 kB
	MemFree:           15548 kB
		(Panic)

The extra reference to the fragment pages causes those pages to
not get freed in skb_release_data(). The following patch fixes
the bug. I have not checked if any other converted driver has
the same issue.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 drivers/net/virtio_net.c |   13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff -ruNp org/drivers/net/virtio_net.c new/drivers/net/virtio_net.c
--- org/drivers/net/virtio_net.c	2011-10-18 08:49:46.000000000 +0530
+++ new/drivers/net/virtio_net.c	2011-10-18 12:55:32.000000000 +0530
@@ -143,18 +143,15 @@ static void skb_xmit_done(struct virtque
 static void set_skb_frag(struct sk_buff *skb, struct page *page,
 			 unsigned int offset, unsigned int *len)
 {
+	int size = min((unsigned)PAGE_SIZE - offset, *len);
 	int i = skb_shinfo(skb)->nr_frags;
-	skb_frag_t *f;
 
-	f = &skb_shinfo(skb)->frags[i];
-	f->size = min((unsigned)PAGE_SIZE - offset, *len);
-	f->page_offset = offset;
-	__skb_frag_set_page(f, page);
+	__skb_fill_page_desc(skb, i, page, offset, size);
 
-	skb->data_len += f->size;
-	skb->len += f->size;
+	skb->data_len += size;
+	skb->len += size;
 	skb_shinfo(skb)->nr_frags++;
-	*len -= f->size;
+	*len -= size;
 }
 
 static struct sk_buff *page_to_skb(struct virtnet_info *vi,
