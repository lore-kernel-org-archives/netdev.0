From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/7]: aoe: Use SKB interfaces for list management instead
 of home-grown stuff.
Date: Mon, 22 Sep 2008 19:12:37 -0700 (PDT)
Message-ID: <20080922.191237.75584132.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37177
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754108AbYIWCMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 22:12:50 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 290CEC8C181
	for <netdev@vger.kernel.org>; Mon, 22 Sep 2008 19:12:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


aoe: Use SKB interfaces for list management instead of home-grown stuff.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/block/aoe/aoe.h     |    9 ++---
 drivers/block/aoe/aoeblk.c  |    8 ++--
 drivers/block/aoe/aoechr.c  |    8 ++++-
 drivers/block/aoe/aoecmd.c  |   85 ++++++++++++++++---------------------------
 drivers/block/aoe/aoedev.c  |   12 +++---
 drivers/block/aoe/aoemain.c |    1 +
 drivers/block/aoe/aoenet.c  |    9 ++---
 7 files changed, 56 insertions(+), 76 deletions(-)

diff --git a/drivers/block/aoe/aoe.h b/drivers/block/aoe/aoe.h
index 5b4c6e6..93f3690 100644
--- a/drivers/block/aoe/aoe.h
+++ b/drivers/block/aoe/aoe.h
@@ -159,11 +159,8 @@ struct aoedev {
 	sector_t ssize;
 	struct timer_list timer;
 	spinlock_t lock;
-	struct sk_buff *sendq_hd; /* packets needing to be sent, list head */
-	struct sk_buff *sendq_tl;
-	struct sk_buff *skbpool_hd;
-	struct sk_buff *skbpool_tl;
-	int nskbpool;
+	struct sk_buff_head sendq;
+	struct sk_buff_head skbpool;
 	mempool_t *bufpool;	/* for deadlock-free Buf allocation */
 	struct list_head bufq;	/* queue of bios to work on */
 	struct buf *inprocess;	/* the one we're currently working on */
@@ -199,7 +196,7 @@ int aoedev_flush(const char __user *str, size_t size);
 
 int aoenet_init(void);
 void aoenet_exit(void);
-void aoenet_xmit(struct sk_buff *);
+void aoenet_xmit(struct sk_buff_head *);
 int is_aoe_netif(struct net_device *ifp);
 int set_aoe_iflist(const char __user *str, size_t size);
 
diff --git a/drivers/block/aoe/aoeblk.c b/drivers/block/aoe/aoeblk.c
index 0c39782..fd2cf54 100644
--- a/drivers/block/aoe/aoeblk.c
+++ b/drivers/block/aoe/aoeblk.c
@@ -158,9 +158,9 @@ aoeblk_release(struct inode *inode, struct file *filp)
 static int
 aoeblk_make_request(struct request_queue *q, struct bio *bio)
 {
+	struct sk_buff_head queue;
 	struct aoedev *d;
 	struct buf *buf;
-	struct sk_buff *sl;
 	ulong flags;
 
 	blk_queue_bounce(q, &bio);
@@ -213,11 +213,11 @@ aoeblk_make_request(struct request_queue *q, struct bio *bio)
 	list_add_tail(&buf->bufs, &d->bufq);
 
 	aoecmd_work(d);
-	sl = d->sendq_hd;
-	d->sendq_hd = d->sendq_tl = NULL;
+	__skb_queue_head_init(&queue);
+	skb_queue_splice_init(&d->sendq, &queue);
 
 	spin_unlock_irqrestore(&d->lock, flags);
-	aoenet_xmit(sl);
+	aoenet_xmit(&queue);
 
 	return 0;
 }
diff --git a/drivers/block/aoe/aoechr.c b/drivers/block/aoe/aoechr.c
index 181ebb8..1f56d2c 100644
--- a/drivers/block/aoe/aoechr.c
+++ b/drivers/block/aoe/aoechr.c
@@ -9,6 +9,7 @@
 #include <linux/completion.h>
 #include <linux/delay.h>
 #include <linux/smp_lock.h>
+#include <linux/skbuff.h>
 #include "aoe.h"
 
 enum {
@@ -103,7 +104,12 @@ loop:
 		spin_lock_irqsave(&d->lock, flags);
 		goto loop;
 	}
-	aoenet_xmit(skb);
+	if (skb) {
+		struct sk_buff_head queue;
+		__skb_queue_head_init(&queue);
+		__skb_queue_tail(&queue, skb);
+		aoenet_xmit(&queue);
+	}
 	aoecmd_cfg(major, minor);
 	return 0;
 }
diff --git a/drivers/block/aoe/aoecmd.c b/drivers/block/aoe/aoecmd.c
index 2f17462..e33da30 100644
--- a/drivers/block/aoe/aoecmd.c
+++ b/drivers/block/aoe/aoecmd.c
@@ -114,29 +114,22 @@ ifrotate(struct aoetgt *t)
 static void
 skb_pool_put(struct aoedev *d, struct sk_buff *skb)
 {
-	if (!d->skbpool_hd)
-		d->skbpool_hd = skb;
-	else
-		d->skbpool_tl->next = skb;
-	d->skbpool_tl = skb;
+	__skb_queue_tail(&d->skbpool, skb);
 }
 
 static struct sk_buff *
 skb_pool_get(struct aoedev *d)
 {
-	struct sk_buff *skb;
+	struct sk_buff *skb = skb_peek(&d->skbpool);
 
-	skb = d->skbpool_hd;
 	if (skb && atomic_read(&skb_shinfo(skb)->dataref) == 1) {
-		d->skbpool_hd = skb->next;
-		skb->next = NULL;
+		__skb_unlink(skb, &d->skbpool);
 		return skb;
 	}
-	if (d->nskbpool < NSKBPOOLMAX
-	&& (skb = new_skb(ETH_ZLEN))) {
-		d->nskbpool++;
+	if (skb_queue_len(&d->skbpool) < NSKBPOOLMAX &&
+	    (skb = new_skb(ETH_ZLEN)))
 		return skb;
-	}
+
 	return NULL;
 }
 
@@ -293,29 +286,22 @@ aoecmd_ata_rw(struct aoedev *d)
 
 	skb->dev = t->ifp->nd;
 	skb = skb_clone(skb, GFP_ATOMIC);
-	if (skb) {
-		if (d->sendq_hd)
-			d->sendq_tl->next = skb;
-		else
-			d->sendq_hd = skb;
-		d->sendq_tl = skb;
-	}
+	if (skb)
+		__skb_queue_tail(&d->sendq, skb);
 	return 1;
 }
 
 /* some callers cannot sleep, and they can call this function,
  * transmitting the packets later, when interrupts are on
  */
-static struct sk_buff *
-aoecmd_cfg_pkts(ushort aoemajor, unsigned char aoeminor, struct sk_buff **tail)
+static void
+aoecmd_cfg_pkts(ushort aoemajor, unsigned char aoeminor, struct sk_buff_head *queue)
 {
 	struct aoe_hdr *h;
 	struct aoe_cfghdr *ch;
-	struct sk_buff *skb, *sl, *sl_tail;
+	struct sk_buff *skb;
 	struct net_device *ifp;
 
-	sl = sl_tail = NULL;
-
 	read_lock(&dev_base_lock);
 	for_each_netdev(&init_net, ifp) {
 		dev_hold(ifp);
@@ -329,8 +315,7 @@ aoecmd_cfg_pkts(ushort aoemajor, unsigned char aoeminor, struct sk_buff **tail)
 		}
 		skb_put(skb, sizeof *h + sizeof *ch);
 		skb->dev = ifp;
-		if (sl_tail == NULL)
-			sl_tail = skb;
+		__skb_queue_tail(queue, skb);
 		h = (struct aoe_hdr *) skb_mac_header(skb);
 		memset(h, 0, sizeof *h + sizeof *ch);
 
@@ -342,16 +327,10 @@ aoecmd_cfg_pkts(ushort aoemajor, unsigned char aoeminor, struct sk_buff **tail)
 		h->minor = aoeminor;
 		h->cmd = AOECMD_CFG;
 
-		skb->next = sl;
-		sl = skb;
 cont:
 		dev_put(ifp);
 	}
 	read_unlock(&dev_base_lock);
-
-	if (tail != NULL)
-		*tail = sl_tail;
-	return sl;
 }
 
 static void
@@ -406,11 +385,7 @@ resend(struct aoedev *d, struct aoetgt *t, struct frame *f)
 	skb = skb_clone(skb, GFP_ATOMIC);
 	if (skb == NULL)
 		return;
-	if (d->sendq_hd)
-		d->sendq_tl->next = skb;
-	else
-		d->sendq_hd = skb;
-	d->sendq_tl = skb;
+	__skb_queue_tail(&d->sendq, skb);
 }
 
 static int
@@ -508,16 +483,15 @@ ata_scnt(unsigned char *packet) {
 static void
 rexmit_timer(ulong vp)
 {
+	struct sk_buff_head queue;
 	struct aoedev *d;
 	struct aoetgt *t, **tt, **te;
 	struct aoeif *ifp;
 	struct frame *f, *e;
-	struct sk_buff *sl;
 	register long timeout;
 	ulong flags, n;
 
 	d = (struct aoedev *) vp;
-	sl = NULL;
 
 	/* timeout is always ~150% of the moving average */
 	timeout = d->rttavg;
@@ -589,7 +563,7 @@ rexmit_timer(ulong vp)
 		}
 	}
 
-	if (d->sendq_hd) {
+	if (!skb_queue_empty(&d->sendq)) {
 		n = d->rttavg <<= 1;
 		if (n > MAXTIMER)
 			d->rttavg = MAXTIMER;
@@ -600,15 +574,15 @@ rexmit_timer(ulong vp)
 		aoecmd_work(d);
 	}
 
-	sl = d->sendq_hd;
-	d->sendq_hd = d->sendq_tl = NULL;
+	__skb_queue_head_init(&queue);
+	skb_queue_splice_init(&d->sendq, &queue);
 
 	d->timer.expires = jiffies + TIMERTICK;
 	add_timer(&d->timer);
 
 	spin_unlock_irqrestore(&d->lock, flags);
 
-	aoenet_xmit(sl);
+	aoenet_xmit(&queue);
 }
 
 /* enters with d->lock held */
@@ -767,12 +741,12 @@ diskstats(struct gendisk *disk, struct bio *bio, ulong duration, sector_t sector
 void
 aoecmd_ata_rsp(struct sk_buff *skb)
 {
+	struct sk_buff_head queue;
 	struct aoedev *d;
 	struct aoe_hdr *hin, *hout;
 	struct aoe_atahdr *ahin, *ahout;
 	struct frame *f;
 	struct buf *buf;
-	struct sk_buff *sl;
 	struct aoetgt *t;
 	struct aoeif *ifp;
 	register long n;
@@ -893,21 +867,21 @@ aoecmd_ata_rsp(struct sk_buff *skb)
 
 	aoecmd_work(d);
 xmit:
-	sl = d->sendq_hd;
-	d->sendq_hd = d->sendq_tl = NULL;
+	__skb_queue_head_init(&queue);
+	skb_queue_splice_init(&d->sendq, &queue);
 
 	spin_unlock_irqrestore(&d->lock, flags);
-	aoenet_xmit(sl);
+	aoenet_xmit(&queue);
 }
 
 void
 aoecmd_cfg(ushort aoemajor, unsigned char aoeminor)
 {
-	struct sk_buff *sl;
-
-	sl = aoecmd_cfg_pkts(aoemajor, aoeminor, NULL);
+	struct sk_buff_head queue;
 
-	aoenet_xmit(sl);
+	__skb_queue_head_init(&queue);
+	aoecmd_cfg_pkts(aoemajor, aoeminor, &queue);
+	aoenet_xmit(&queue);
 }
  
 struct sk_buff *
@@ -1076,7 +1050,12 @@ aoecmd_cfg_rsp(struct sk_buff *skb)
 
 	spin_unlock_irqrestore(&d->lock, flags);
 
-	aoenet_xmit(sl);
+	if (sl) {
+		struct sk_buff_head queue;
+		__skb_queue_head_init(&queue);
+		__skb_queue_tail(&queue, sl);
+		aoenet_xmit(&queue);
+	}
 }
 
 void
diff --git a/drivers/block/aoe/aoedev.c b/drivers/block/aoe/aoedev.c
index a1d813a..75a610a 100644
--- a/drivers/block/aoe/aoedev.c
+++ b/drivers/block/aoe/aoedev.c
@@ -188,14 +188,12 @@ skbfree(struct sk_buff *skb)
 static void
 skbpoolfree(struct aoedev *d)
 {
-	struct sk_buff *skb;
+	struct sk_buff *skb, *tmp;
 
-	while ((skb = d->skbpool_hd)) {
-		d->skbpool_hd = skb->next;
-		skb->next = NULL;
+	skb_queue_walk_safe(&d->skbpool, skb, tmp)
 		skbfree(skb);
-	}
-	d->skbpool_tl = NULL;
+
+	__skb_queue_head_init(&d->skbpool);
 }
 
 /* find it or malloc it */
@@ -217,6 +215,8 @@ aoedev_by_sysminor_m(ulong sysminor)
 		goto out;
 	INIT_WORK(&d->work, aoecmd_sleepwork);
 	spin_lock_init(&d->lock);
+	skb_queue_head_init(&d->sendq);
+	skb_queue_head_init(&d->skbpool);
 	init_timer(&d->timer);
 	d->timer.data = (ulong) d;
 	d->timer.function = dummy_timer;
diff --git a/drivers/block/aoe/aoemain.c b/drivers/block/aoe/aoemain.c
index 7b15a5e..7f83ad9 100644
--- a/drivers/block/aoe/aoemain.c
+++ b/drivers/block/aoe/aoemain.c
@@ -7,6 +7,7 @@
 #include <linux/hdreg.h>
 #include <linux/blkdev.h>
 #include <linux/module.h>
+#include <linux/skbuff.h>
 #include "aoe.h"
 
 MODULE_LICENSE("GPL");
diff --git a/drivers/block/aoe/aoenet.c b/drivers/block/aoe/aoenet.c
index 0c81ca7..8fb2603 100644
--- a/drivers/block/aoe/aoenet.c
+++ b/drivers/block/aoe/aoenet.c
@@ -95,15 +95,12 @@ mac_addr(char addr[6])
 }
 
 void
-aoenet_xmit(struct sk_buff *sl)
+aoenet_xmit(struct sk_buff_head *queue)
 {
-	struct sk_buff *skb;
+	struct sk_buff *skb, *tmp;
 
-	while ((skb = sl)) {
-		sl = sl->next;
-		skb->next = skb->prev = NULL;
+	skb_queue_walk_safe(queue, skb, tmp)
 		dev_queue_xmit(skb);
-	}
 }
 
 /* 
-- 
1.5.6.5

