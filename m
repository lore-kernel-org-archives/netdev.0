From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH][NET] ifb: set separate lockdep classes for queue locks
Date: Wed, 19 Mar 2008 07:34:41 +0000
Message-ID: <20080319073441.GA3918@ff.dom.local>
References: <20080307075113.GA3912@ff.dom.local> <1204898002.4431.99.camel@localhost> <20080308084628.GA2749@ami.dom.local> <20080308085854.GB2749@ami.dom.local> <20080308101540.M65133@visp.net.lb> <20080308104322.GA3301@ami.dom.local> <20080308105250.GB3301@ami.dom.local> <20080308110611.M62976@visp.net.lb> <20080308120244.GA3378@ami.dom.local> <20080319004547.M71837@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, jamal <hadi@cyberus.ca>,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.184]:37570 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934102AbYCSUf1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 16:35:27 -0400
Received: by fk-out-0910.google.com with SMTP id 19so720150fkr.5
        for <netdev@vger.kernel.org>; Wed, 19 Mar 2008 13:35:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080319004547.M71837@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 19, 2008 at 02:46:08AM +0200, Denys Fedoryshchenko wrote:
> No more warnings.
> Probably it must be applied to 2.6.25 before it is released?
> 
> On Sat, 8 Mar 2008 13:02:44 +0100, Jarek Poplawski wrote
> > On Sat, Mar 08, 2008 at 01:09:10PM +0200, Denys Fedoryshchenko wrote:
> > > Seems "try 2" helped. lockdep is not triggered anymore. I test on 3 
> different 
> > > servers for now.
> > > I will test more deeply and on more servers.

Thanks for testing Denys,
Jarek P.

--------------------->

Subject: [NET] ifb: set separate lockdep classes for queue locks

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

lockdep warns of locking order while using ifb with sch_ingress and
act_mirred: ingress_lock, tcfc_lock, queue_lock (usually queue_lock
is at the beginning). This patch is only to tell lockdep that ifb is
a different device (e.g. from eth) and has its own pair of queue
locks. (This warning is a false-positive in common scenario of using
ifb; yet there are possible situations, when this order could be
dangerous; lockdep should warn in such a case.)


Reported-and-tested-by: Denys Fedoryshchenko <denys@visp.net.lb>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
Cc: Jamal Hadi Salim <hadi@cyberus.ca>

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
--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

