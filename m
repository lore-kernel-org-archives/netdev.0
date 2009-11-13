From: Ed Cashin <ecashin@coraid.com>
Subject: Re: [PATCH 04/10] AOE: use rcu to find network device
Date: Fri, 13 Nov 2009 16:39:49 -0500
Message-ID: <11632bada28093377596d63180fe6c1c@coraid.com>
References: <20091110175446.280423729@vyatta.com>
	<20091110175647.409162953@vyatta.com>
	<8ffe0a1df67d13a45a413f40d00dd80a@coraid.com>
	<20091110150617.0e6920f0@nehalam>
	<a30adfc1658e1d5f2f35fee1bb89b364@coraid.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="upas-ickzaudveqwoumejpagvgbilwv"
To: ecashin@coraid.com, shemminger@vyatta.com, davem@davemloft.net,
	harvey.harrison@gmail.com, bzolnier@gmail.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from baron.coraid.com ([12.51.113.4]:55655 "EHLO coraid.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754294AbZKMVkP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 16:40:15 -0500
In-Reply-To: <a30adfc1658e1d5f2f35fee1bb89b364@coraid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--upas-ickzaudveqwoumejpagvgbilwv
Content-Disposition: inline
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit

I will be testing the patch below on Monday.  It is based on Stephen
Hemminger's starter patch (Thanks!).  It adds handling for the case
where all of the local network interfaces have become unusable.  In
that case, sent packets and retransmitted packets are effectively
dropped, and the driver's handling of ethernet's unreliability takes
care of things as usual.  If a local interface becomes usable in time
no I/O will fail.

After testing I'll make a proper changelog entry.  In brief this patch
allows the aoe driver to correctly take references on the net_device's
that it uses, handle their removal via a callback, and handle their
complete absence, too.

-- 
  Ed
--upas-ickzaudveqwoumejpagvgbilwv
Content-Disposition: inline
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit

diff --git a/drivers/block/aoe/aoe.h b/drivers/block/aoe/aoe.h
index db195ab..315d36b 100644
--- a/drivers/block/aoe/aoe.h
+++ b/drivers/block/aoe/aoe.h
@@ -186,6 +186,7 @@ void aoecmd_ata_rsp(struct sk_buff *);
 void aoecmd_cfg_rsp(struct sk_buff *);
 void aoecmd_sleepwork(struct work_struct *);
 void aoecmd_cleanslate(struct aoedev *);
+void aoecmd_flushnet(struct aoedev *, struct net_device *);
 struct sk_buff *aoecmd_ata_id(struct aoedev *);
 
 int aoedev_init(void);
@@ -194,6 +195,7 @@ struct aoedev *aoedev_by_aoeaddr(int maj, int min);
 struct aoedev *aoedev_by_sysminor_m(ulong sysminor);
 void aoedev_downdev(struct aoedev *d);
 int aoedev_flush(const char __user *str, size_t size);
+void aoedev_ejectnet(struct net_device *);
 
 int aoenet_init(void);
 void aoenet_exit(void);
diff --git a/drivers/block/aoe/aoecmd.c b/drivers/block/aoe/aoecmd.c
index 965ece2..060c8d6 100644
--- a/drivers/block/aoe/aoecmd.c
+++ b/drivers/block/aoe/aoecmd.c
@@ -93,16 +93,16 @@ put_lba(struct aoe_atahdr *ah, sector_t lba)
 	ah->lba5 = lba >>= 8;
 }
 
-static void
+static struct net_device *
 ifrotate(struct aoetgt *t)
 {
 	t->ifp++;
 	if (t->ifp >= &t->ifs[NAOEIFS] || t->ifp->nd == NULL)
 		t->ifp = t->ifs;
-	if (t->ifp->nd == NULL) {
-		printk(KERN_INFO "aoe: no interface to rotate to\n");
-		BUG();
-	}
+	if (t->ifp->nd == NULL && net_ratelimit())
+		printk(KERN_WARNING
+			"aoe: no local interface to send through\n");
+	return t->ifp->nd;
 }
 
 static void
@@ -336,7 +336,8 @@ resend(struct aoedev *d, struct aoetgt *t, struct frame *f)
 	char buf[128];
 	u32 n;
 
-	ifrotate(t);
+	if (!ifrotate(t))
+		return;		/* no usable local network interfaces */
 	n = newtag(t);
 	skb = f->skb;
 	h = (struct aoe_hdr *) skb_mac_header(skb);
@@ -413,6 +414,8 @@ addif(struct aoetgt *t, struct net_device *nd)
 	p = getif(t, NULL);
 	if (!p)
 		return NULL;
+
+	dev_hold(nd);
 	p->nd = nd;
 	p->maxbcnt = DEFAULTBCNT;
 	p->lost = 0;
@@ -424,12 +427,30 @@ static void
 ejectif(struct aoetgt *t, struct aoeif *ifp)
 {
 	struct aoeif *e;
+	struct net_device *nd;
 	ulong n;
 
 	e = t->ifs + NAOEIFS - 1;
+	nd = e->nd;
 	n = (e - ifp) * sizeof *ifp;
 	memmove(ifp, ifp+1, n);
 	e->nd = NULL;
+	dev_put(nd);
+}
+
+void
+aoecmd_flushnet(struct aoedev *d, struct net_device *nd)
+{
+	struct aoetgt **tt, **te;
+	tt = d->targets;
+	te = tt + NTARGETS;
+	for (; tt < te && *tt; tt++) {
+		struct aoetgt *t = *tt;
+		struct aoeif *ifp;
+
+		if ( (ifp = getif(t, nd)) )
+			ejectif(t, ifp);
+	}
 }
 
 static int
diff --git a/drivers/block/aoe/aoedev.c b/drivers/block/aoe/aoedev.c
index fa67027..6754db0 100644
--- a/drivers/block/aoe/aoedev.c
+++ b/drivers/block/aoe/aoedev.c
@@ -162,6 +162,21 @@ aoedev_flush(const char __user *str, size_t cnt)
 	return 0;
 }
 
+void
+aoedev_ejectnet(struct net_device *nd)
+{
+	struct aoedev *d;
+	unsigned long flags;
+
+	spin_lock_irqsave(&devlist_lock, flags);
+	for (d = devlist; d; d = d->next) {
+		spin_lock(&d->lock);
+		aoecmd_flushnet(d, nd);
+		spin_unlock(&d->lock);
+	}
+	spin_unlock_irqrestore(&d->lock, flags);
+}
+
 /* I'm not really sure that this is a realistic problem, but if the
 network driver goes gonzo let's just leak memory after complaining. */
 static void
diff --git a/drivers/block/aoe/aoemain.c b/drivers/block/aoe/aoemain.c
index 7f83ad9..5f6c072 100644
--- a/drivers/block/aoe/aoemain.c
+++ b/drivers/block/aoe/aoemain.c
@@ -8,6 +8,8 @@
 #include <linux/blkdev.h>
 #include <linux/module.h>
 #include <linux/skbuff.h>
+#include <linux/notifier.h>
+#include <linux/netdevice.h>
 #include "aoe.h"
 
 MODULE_LICENSE("GPL");
@@ -54,11 +56,29 @@ discover_timer(ulong vp)
 	}
 }
 
+/* Callback on change of state of network device. */
+static int
+aoe_device_event(struct notifier_block *unused,
+		unsigned long event, void *ptr)
+{
+	struct net_device *nd = ptr;
+
+	if (event == NETDEV_UNREGISTER)
+		aoedev_ejectnet(nd);
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block aoe_notifier = {
+	.notifier_call = aoe_device_event,
+};
+
 static void
 aoe_exit(void)
 {
 	discover_timer(TKILL);
 
+	unregister_netdevice_notifier(&aoe_notifier);
 	aoenet_exit();
 	unregister_blkdev(AOE_MAJOR, DEVICE_NAME);
 	aoechr_exit();
@@ -83,6 +103,9 @@ aoe_init(void)
 	ret = aoenet_init();
 	if (ret)
 		goto net_fail;
+	ret = register_netdevice_notifier(&aoe_notifier);
+	if (ret)
+		goto notifier_fail;
 	ret = register_blkdev(AOE_MAJOR, DEVICE_NAME);
 	if (ret < 0) {
 		printk(KERN_ERR "aoe: can't register major\n");
@@ -94,6 +117,8 @@ aoe_init(void)
 	return 0;
 
  blkreg_fail:
+	unregister_netdevice_notifier(&aoe_notifier);
+ notifier_fail:
 	aoenet_exit();
  net_fail:
 	aoeblk_exit();
diff --git a/drivers/block/aoe/aoenet.c b/drivers/block/aoe/aoenet.c
index ce0d62c..cc3872c 100644
--- a/drivers/block/aoe/aoenet.c
+++ b/drivers/block/aoe/aoenet.c
@@ -90,7 +90,10 @@ aoenet_xmit(struct sk_buff_head *queue)
 
 	skb_queue_walk_safe(queue, skb, tmp) {
 		__skb_unlink(skb, queue);
-		dev_queue_xmit(skb);
+		if (skb->dev)
+			dev_queue_xmit(skb);
+		else
+			dev_kfree_skb(skb);
 	}
 }
 
--upas-ickzaudveqwoumejpagvgbilwv--
