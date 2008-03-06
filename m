From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: circular locking, mirred, 2.6.24.2
Date: Thu, 6 Mar 2008 21:25:51 +0100
Message-ID: <20080306202551.GB2876@ami.dom.local>
References: <20080224222035.M62480@visp.net.lb> <20080225095646.GA4321@ff.dom.local> <20080225104652.M2446@visp.net.lb> <20080225113930.GA4733@ff.dom.local> <20080305103935.M76165@visp.net.lb> <20080306134015.GA4571@ff.dom.local> <20080306135625.M25627@visp.net.lb> <1204813634.4440.59.camel@localhost> <20080306143910.M91001@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:37900 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932809AbYCFUUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 15:20:40 -0500
Received: by ug-out-1314.google.com with SMTP id z38so3980194ugc.16
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2008 12:20:39 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080306143910.M91001@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 06, 2008 at 05:50:59PM +0200, Denys Fedoryshchenko wrote:
> On Thu, 06 Mar 2008 09:27:14 -0500, jamal wrote
> > On Thu, 2008-06-03 at 15:57 +0200, Denys Fedoryshchenko wrote:
> > > I am able to reproduce this warning over this relatively simple shell 
> script
> > > on my Gentoo PC (2.6.25-rc3).
> > > http://www.nuclearcat.com/files/bug_feb.txt
> > >
> > 
> > That script looks pretty sane to me - nothing super-exciting. I suspect
> > you eventually want them all to look like ifb1 on the egress.
> > Do you see the same issue without the ifb1 speacial case?
> Well, i am able to reproduce in much more trivial script. Tested 2.6.25-rc4 
> also.
> 
> modprobe ifb
> ifconfig ifb0 up
> TC=/sbin/tc
> $TC qdisc del dev eth0 ingress 1>/dev/null 2>/dev/null
> $TC qdisc add dev eth0 ingress
> ${TC} filter add dev eth0 parent ffff: protocol ip prio 10 u32 \
>       match u32 0 0 flowid 1:1 \
>       action mirred egress redirect dev ifb0
> 

It's really strange: I can't reproduce this, and if it were so easy we
would get really a lot of similar reports. It looks like you have
something special. This lockdep report with this kind of problem
usually looks different too. The good side is it's easy to reproduce.
So, could you try the patch below? (It's only supposed to fix the lockdep
warning, not lockups).

> > 
> > > Probably it will help to debug issue for more experienced developers. 
> Note:
> > > it appears not immediately, second time i tested, it's appeared after 
> while,
> > > but in matter of seconds.
> > 
> > I wonder is there some latency from the moment you insmod ifb to the
> > moment the tc rules take effect? Will it still happen if you dont 
> > have modules? Also note, that lock dependency is a bit strange,
> >  Jarek correct me if i am wrong; it seems to say: a packet received 
> > on ingress of some e1000 (ethx) gets acted on by mirred which ends 
> > grabbing lock of an ifb device - this part should be fine and no 
> > need for the alarm. The alarm seems to be a result of a loopback 
> > device that is being registered in between the two activities.
> > i.e there are three devices affected with entirely different 
> > locks(ethx, ifbx, and loopback). Smells like lockdep is getting it wrong?

Yes, the details look wrong, but IMHO there are reasons to report
possible problems yet.

> No idea, i have strange lockup's on my systems where i have ifb, and that 
> make me worry. And i feel it is directly related with my love to use ifb 
> devices and way how i am using them.

Did you try to change the order of rules in this first script: ifb rules
before eth?

> > > Note - it can stop traffic on PC completely. It is also seems crashed my 
> > > desktop PC, i am not able to execute "tc qdisc del dev eth0 root".
> > > The system hang completely. I had few similar issues on my PPPoE servers 
> > > (with different scripts for shapers), that system hang, and even "reboot -
> f" 
> > > doesn't work sometimes.
> > 
> > This sounds like a different issue from above - when did this start 
> > to happen? Is it at the same time as above warnings showing up?
> 
> Yes, it is different issue seems, it is rare to lockup system , and i will 
> dig more, to understand how it is happening.

If you are willing for debugging I would be interested with results or
sending some patches.

Cheers,
Jarek P.

(testing patch take 2)

---

 drivers/net/ifb.c |   24 ++++++++++++++++++++++++
 1 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 15949d3..c553b62 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -227,6 +227,27 @@ static struct rtnl_link_ops ifb_link_ops __read_mostly = {
 module_param(numifbs, int, 0);
 MODULE_PARM_DESC(numifbs, "Number of ifb devices");
 
+#ifdef CONFIG_DEBUG_LOCK_ALLOC
+/*
+ * dev_ifb->queue_lock is usually taken after dev->ingress_lock,
+ * reversely to e.g. qdisc_lock_tree(). It should be safe until
+ * ifb doesn't take dev->queue_lock with dev_ifb->ingress_lock.
+ * But lockdep should know that ifb has different locks from dev.
+ */
+static struct lock_class_key ifb_queue_lock_key;
+static struct lock_class_key ifb_ingress_lock_key;
+
+static inline void ifb_set_lock_classes(struct net_device *dev_ifb)
+{
+	lockdep_set_class(&dev_ifb->queue_lock, &ifb_queue_lock_key);
+	lockdep_set_class(&dev_ifb->ingress_lock, &ifb_ingress_lock_key);
+}
+#else
+static inline void ifb_set_lock_classes(struct net_device *dev_ifb)
+{
+}
+#endif	/* CONFIG_DEBUG_LOCK_ALLOC */
+
 static int __init ifb_init_one(int index)
 {
 	struct net_device *dev_ifb;
@@ -246,6 +267,9 @@ static int __init ifb_init_one(int index)
 	err = register_netdevice(dev_ifb);
 	if (err < 0)
 		goto err;
+
+	ifb_set_lock_classes(dev_ifb);
+
 	return 0;
 
 err:
