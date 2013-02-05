From: Nicholas Thomas <nick@bytemark.co.uk>
Subject: [PATCH] NBD: Move from a global spinlock to one lock per NBD device
Date: Tue, 05 Feb 2013 16:14:27 +0000
Message-ID: <1360080867.18869.30.camel@eboracum.office.bytemark.co.uk>
References: <1359993343.18869.14.camel@eboracum.office.bytemark.co.uk>
	 <CAPshTCir48mTze-pEayg5TDxcH0Tyi4=NoH-FBhnM4rgrxekfQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hkchu@google.com, davem@davemloft.net,
	eric.dumazet@gmail.com
To: Paul.Clements@steeleye.com, jaxboe@fusionio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from bacon.sh.bytemark.co.uk ([212.110.161.169]:39104 "EHLO
	bacon.sh.bytemark.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754940Ab3BEQOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 11:14:34 -0500
In-Reply-To: <CAPshTCir48mTze-pEayg5TDxcH0Tyi4=NoH-FBhnM4rgrxekfQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is entirely based on a submission by Jerry Chu, incorporating
suggestions from Eric Dumazet. Modern, faster NICs make the original comment
on why a single lock is preferable incorrect; moving to one lock per NBD
device removes a performance bottleneck.

Original patch: http://permalink.gmane.org/gmane.linux.network/207233
    
Signed-off-by: Nick Thomas <nick@bytemark.co.uk>

diff --git a/drivers/block/nbd.c b/drivers/block/nbd.c
index 043ddcc..d285b64 100644
--- a/drivers/block/nbd.c
+++ b/drivers/block/nbd.c
@@ -57,20 +57,9 @@ static unsigned int debugflags;
 
 static unsigned int nbds_max = 16;
 static struct nbd_device *nbd_dev;
+static spinlock_t *nbd_locks __read_mostly;
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
@@ -781,6 +770,15 @@ static int __init nbd_init(void)
 	if (!nbd_dev)
 		return -ENOMEM;
 
+	nbd_locks = kcalloc(nbds_max, sizeof(*nbd_locks), GFP_KERNEL);
+	if (!nbd_locks) {
+		kfree(nbd_dev);
+		return -ENOMEM;
+	}
+
+	for (i = 0; i < nbds_max; i++)
+		spin_lock_init(&nbd_locks[i]);
+
 	part_shift = 0;
 	if (max_part > 0) {
 		part_shift = fls(max_part);
@@ -812,7 +810,7 @@ static int __init nbd_init(void)
 		 * every gendisk to have its very own request_queue struct.
 		 * These structs are big so we dynamically allocate them.
 		 */
-		disk->queue = blk_init_queue(do_nbd_request, &nbd_lock);
+		disk->queue = blk_init_queue(do_nbd_request, &nbd_locks[i]);
 		if (!disk->queue) {
 			put_disk(disk);
 			goto out;
@@ -863,6 +861,7 @@ out:
 		put_disk(nbd_dev[i].disk);
 	}
 	kfree(nbd_dev);
+	kfree(nbd_locks);
 	return err;
 }
 
@@ -880,6 +879,7 @@ static void __exit nbd_cleanup(void)
 	}
 	unregister_blkdev(NBD_MAJOR, "nbd");
 	kfree(nbd_dev);
+	kfree(nbd_locks);
 	printk(KERN_INFO "nbd: unregistered device at major %d\n", NBD_MAJOR);
 }
