From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 04/10] AOE: use rcu to find network device
Date: Tue, 10 Nov 2009 15:53:16 -0800
Message-ID: <20091110155316.2c3d7b6e@nehalam>
References: <20091110175446.280423729@vyatta.com>
	<20091110175647.409162953@vyatta.com>
	<8ffe0a1df67d13a45a413f40d00dd80a@coraid.com>
	<20091110150617.0e6920f0@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: roel.kluin@gmail.com, harvey.harrison@gmail.com,
	bzolnier@gmail.com, netdev@vger.kernel.org
To: karaluh@karaluh.pl, Ed Cashin <ecashin@coraid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40231 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754373AbZKJXxc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2009 18:53:32 -0500
In-Reply-To: <20091110150617.0e6920f0@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Nov 2009 15:06:17 -0800
Stephen Hemminger <shemminger@vyatta.com> wrote:

> On Tue, 10 Nov 2009 15:01:49 -0500
> Ed Cashin <ecashin@coraid.com> wrote:
> 
> > On Tue Nov 10 13:07:37 EST 2009, shemminger@vyatta.com wrote:
> > > This gets rid of another use of read_lock(&dev_base_lock) by using
> > > RCU. Also, it only increments the reference count of the device actually
> > > used rather than holding and releasing every device
> > > 
> > > Compile tested only.
> > 
> > This function runs once a minute when the aoe driver is loaded,
> > if you'd like to test it a bit more.
> > 
> > It looks like there's no dev_put corresponding to the dev_hold
> > after the changes.
> > 
> 
> Hmm, looks like AOE actually is not ref counting the network device.
> So my patch is incorrect. 
> 
> As it stands (before my patch), it is UNSAFE. It can decide to queue
> packets to a device that is removed out from underneath it causing
> reference to freed memory.
> 
> Moving the rcu_read_lock up to aoecmd_cfg() would solve that but the
> whole driver appears to be unsafe about device refcounting and handling
> device removal properly.  
> 
> It needs to:
> 
> 1. Get a device ref count when it remembers a device: (ie addif)
> 2. Install a notifier that looks for device removal events
> 3. In notifier, remove interface, including flushing all pending
>    skb's for that device.
> 
> This obviously is beyond the scope of the RCU stuff.

Here is a patch to get you going, it does compile but it probably
won't work because the code doesn't handle the case of the last
device going away from a target. This is yet another pre-existing
bug, since if a timeout happens: ejectif() is called to remove a device,
resend() will BUG in ifrotate() if all devices are gone.


---
 drivers/block/aoe/aoe.h     |    2 ++
 drivers/block/aoe/aoecmd.c  |   19 +++++++++++++++++++
 drivers/block/aoe/aoedev.c  |   14 ++++++++++++++
 drivers/block/aoe/aoemain.c |   24 ++++++++++++++++++++++++
 4 files changed, 59 insertions(+)

--- a/drivers/block/aoe/aoecmd.c	2009-11-10 15:13:25.673859220 -0800
+++ b/drivers/block/aoe/aoecmd.c	2009-11-10 15:49:20.009047132 -0800
@@ -413,6 +413,8 @@ addif(struct aoetgt *t, struct net_devic
 	p = getif(t, NULL);
 	if (!p)
 		return NULL;
+
+	dev_hold(nd);
 	p->nd = nd;
 	p->maxbcnt = DEFAULTBCNT;
 	p->lost = 0;
@@ -424,12 +426,29 @@ static void
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
+void aoecmd_flushnet(struct aoedev *d, struct net_device *nd)
+{
+	struct aoetgt **tt, **te;
+	tt = d->targets;
+	te = tt + NTARGETS;
+	for (; tt < te && *tt; tt++) {
+		struct aoetgt *t = *tt;
+		struct aoeif *ifp;
+
+		while ( (ifp = getif(t, nd)) )
+			ejectif(t, ifp);
+	}
 }
 
 static int
--- a/drivers/block/aoe/aoemain.c	2009-11-10 15:13:25.696859195 -0800
+++ b/drivers/block/aoe/aoemain.c	2009-11-10 15:48:43.352047188 -0800
@@ -8,6 +8,8 @@
 #include <linux/blkdev.h>
 #include <linux/module.h>
 #include <linux/skbuff.h>
+#include <linux/notifier.h>
+#include <linux/netdevice.h>
 #include "aoe.h"
 
 MODULE_LICENSE("GPL");
@@ -54,11 +56,28 @@ discover_timer(ulong vp)
 	}
 }
 
+/* Callback on change of state of network device. */
+static int aoe_device_event(struct notifier_block *unused,
+			    unsigned long event, void *ptr)
+{
+	struct net_device *nd = ptr;
+
+	if (is_aoe_netif(nd) && event == NETDEV_UNREGISTER)
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
@@ -83,6 +102,9 @@ aoe_init(void)
 	ret = aoenet_init();
 	if (ret)
 		goto net_fail;
+	ret = register_netdevice_notifier(&aoe_notifier);
+	if (ret)
+		goto notifier_fail;
 	ret = register_blkdev(AOE_MAJOR, DEVICE_NAME);
 	if (ret < 0) {
 		printk(KERN_ERR "aoe: can't register major\n");
@@ -94,6 +116,8 @@ aoe_init(void)
 	return 0;
 
  blkreg_fail:
+	unregister_netdevice_notifier(&aoe_notifier);
+ notifier_fail:
 	aoenet_exit();
  net_fail:
 	aoeblk_exit();
--- a/drivers/block/aoe/aoe.h	2009-11-10 15:36:07.775921768 -0800
+++ b/drivers/block/aoe/aoe.h	2009-11-10 15:43:14.972984754 -0800
@@ -186,6 +186,7 @@ void aoecmd_ata_rsp(struct sk_buff *);
 void aoecmd_cfg_rsp(struct sk_buff *);
 void aoecmd_sleepwork(struct work_struct *);
 void aoecmd_cleanslate(struct aoedev *);
+void aoecmd_flushnet(struct aoedev *, struct net_device *);
 struct sk_buff *aoecmd_ata_id(struct aoedev *);
 
 int aoedev_init(void);
@@ -194,6 +195,7 @@ struct aoedev *aoedev_by_aoeaddr(int maj
 struct aoedev *aoedev_by_sysminor_m(ulong sysminor);
 void aoedev_downdev(struct aoedev *d);
 int aoedev_flush(const char __user *str, size_t size);
+void aoedev_ejectnet(struct net_device *);
 
 int aoenet_init(void);
 void aoenet_exit(void);
--- a/drivers/block/aoe/aoedev.c	2009-11-10 15:13:25.685859893 -0800
+++ b/drivers/block/aoe/aoedev.c	2009-11-10 15:46:19.430861404 -0800
@@ -162,6 +162,20 @@ aoedev_flush(const char __user *str, siz
 	return 0;
 }
 
+void aoedev_ejectnet(struct net_device *nd)
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
