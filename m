From: "H.K. Jerry Chu" <hkchu@google.com>
Subject: [PATCH] Break up the single NBD lock into one per NBD device
Date: Mon, 26 Sep 2011 16:34:12 -0700
Message-ID: <1317080052-6052-1-git-send-email-hkchu@google.com>
Cc: netdev@vger.kernel.org, Jerry Chu <hkchu@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:32789 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752282Ab1IZXec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 19:34:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jerry Chu <hkchu@google.com>

This patch breaks up the single NBD lock into one per
disk. The single NBD lock has become a serious performance
bottleneck when multiple NBD disks are being used.

The original comment on why a single lock may be ok no
longer holds for today's much faster NICs.

Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
---
 drivers/block/nbd.c |   22 +++++++++-------------
 1 files changed, 9 insertions(+), 13 deletions(-)

diff --git a/drivers/block/nbd.c b/drivers/block/nbd.c
index f533f33..355e15c 100644
--- a/drivers/block/nbd.c
+++ b/drivers/block/nbd.c
@@ -58,20 +58,9 @@ static unsigned int debugflags;
 
 static unsigned int nbds_max = 16;
 static struct nbd_device *nbd_dev;
+static spinlock_t *nbd_locks;
 static int max_part;
 
-/*
- * Use just one lock (or at most 1 per NIC). Two arguments for this:
- * 1. Each NIC is essentially a synchronization point for all servers
- *    accessed through that NIC so there's no need to have more locks
- *    than NICs anyway.
- * 2. More locks lead to more "Dirty cache line bouncing" which will slow
- *    down each lock to the point where they're actually slower than just
- *    a single lock.
- * Thanks go to Jens Axboe and Al Viro for their LKML emails explaining this!
- */
-static DEFINE_SPINLOCK(nbd_lock);
-
 #ifndef NDEBUG
 static const char *ioctl_cmd_to_ascii(int cmd)
 {
@@ -753,6 +742,12 @@ static int __init nbd_init(void)
 	if (!nbd_dev)
 		return -ENOMEM;
 
+	nbd_locks = kcalloc(nbds_max, sizeof(*nbd_locks), GFP_KERNEL);
+	if (!nbd_locks) {
+		kfree(nbd_dev);
+		return -ENOMEM;
+	}
+
 	part_shift = 0;
 	if (max_part > 0) {
 		part_shift = fls(max_part);
@@ -784,7 +779,7 @@ static int __init nbd_init(void)
 		 * every gendisk to have its very own request_queue struct.
 		 * These structs are big so we dynamically allocate them.
 		 */
-		disk->queue = blk_init_queue(do_nbd_request, &nbd_lock);
+		disk->queue = blk_init_queue(do_nbd_request, &nbd_locks[i]);
 		if (!disk->queue) {
 			put_disk(disk);
 			goto out;
@@ -832,6 +827,7 @@ out:
 		put_disk(nbd_dev[i].disk);
 	}
 	kfree(nbd_dev);
+	kfree(nbd_locks);
 	return err;
 }
 
-- 
1.7.3.1
