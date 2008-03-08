From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: circular locking, mirred, 2.6.24.2
Date: Sat, 8 Mar 2008 11:43:22 +0100
Message-ID: <20080308104322.GA3301@ami.dom.local>
References: <1204811995.4440.30.camel@localhost> <20080306175629.GA2876@ami.dom.local> <1204836523.4457.103.camel@localhost> <20080306214000.GC2876@ami.dom.local> <1204846839.4431.23.camel@localhost> <20080307075113.GA3912@ff.dom.local> <1204898002.4431.99.camel@localhost> <20080308084628.GA2749@ami.dom.local> <20080308085854.GB2749@ami.dom.local> <20080308101540.M65133@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:41961 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752011AbYCHKiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2008 05:38:09 -0500
Received: by fg-out-1718.google.com with SMTP id e21so990595fga.17
        for <netdev@vger.kernel.org>; Sat, 08 Mar 2008 02:38:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080308101540.M65133@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 08, 2008 at 12:16:52PM +0200, Denys Fedoryshchenko wrote:
> Update. I am not able to reproduce on my PC, but still able to reproduce on 
> PPPoE server (but here i cannot take risk to use 2.6.25-rcX kernels). This is 
> PPPoE:
> 
> [2148614.154684]
> [2148614.154688] =======================================================
> [2148614.154805] [ INFO: possible circular locking dependency detected ]
> [2148614.154862] 2.6.24.3-build-0023 #9
> [2148614.154913] -------------------------------------------------------
> [2148614.154969] swapper/0 is trying to acquire lock:
> [2148614.155023]  (&ifb_queue_lock_key){-+..}, at: [<c0289d4d>] 
> dev_queue_xmit+0x177/0x302
> [2148614.155245]
> [2148614.155246] but task is already holding lock:
> [2148614.155346]  (&p->tcfc_lock){-+..}, at: [<f8a10066>] tcf_mirred+0x20/
> 0x180 [act_mirred]
> [2148614.155569]
> [2148614.155570] which lock already depends on the new lock.


...Hmm... the same day I sent to you "take 2" of my patch which was more
complete (lockdep_set_class for ingress_lock added). Could you try this?
It still could be not enough, and something similar is needed for
tcfc_lock in act_mirred, but I'd like to see a report after this patch
first.

As Jamal wrote this all is a false-positive with ifb, but I think it's
needed to please lockdep.

Thanks,
Jarek P.

PS: I resend this "take 2" here:
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
