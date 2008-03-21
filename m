From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH take2][NET] ifb: set separate lockdep classes for queue
	locks
Date: Fri, 21 Mar 2008 01:03:12 +0100
Message-ID: <20080321000312.GA7755@ami.dom.local>
References: <20080308120244.GA3378@ami.dom.local> <20080319004547.M71837@visp.net.lb> <20080319073441.GA3918@ff.dom.local> <20080320.153745.232982215.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, denys@visp.net.lb, hadi@cyberus.ca,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:63947 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759169AbYCTX4w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 19:56:52 -0400
Received: by fg-out-1718.google.com with SMTP id l27so1039306fgb.17
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2008 16:56:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080320.153745.232982215.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 20, 2008 at 03:37:45PM -0700, David Miller wrote:
...
> Jarek, the code in linux/lockdep.h provides dummy do-nothing
> versions of the lockdep_*() interfaces, so the spinlock
> debug ifdeffing you do here is unnecessary.
> 
> Simply include linux/lockdep.h and perform the actions
> unconditionally.
> 
> For example, this is how net/core/sock.c does things.
> 
> Also, please upgrade Jamal's "CC" to an "Acked-by" :-)

IMHO it wastes a bit of memory when lockdep is off and adds some
overhead when lockdep is "partialy" on and doesn't need this, but
it's really late...

Regards,
Jarek P.

--------------------->

Subject: [NET] ifb: set separate lockdep classes for queue locks

[   10.536424] =======================================================
[   10.536424] [ INFO: possible circular locking dependency detected ]
[   10.536424] 2.6.25-rc3-devel #3
[   10.536424] -------------------------------------------------------
[   10.536424] swapper/0 is trying to acquire lock:
[   10.536424]  (&dev->queue_lock){-+..}, at: [<c0299b4a>] 
dev_queue_xmit+0x175/0x2f3
[   10.536424]
[   10.536424] but task is already holding lock:
[   10.536424]  (&p->tcfc_lock){-+..}, at: [<f8a67154>] tcf_mirred+0x20/0x178 
[act_mirred]
[   10.536424]
[   10.536424] which lock already depends on the new lock.

lockdep warns of locking order while using ifb with sch_ingress and
act_mirred: ingress_lock, tcfc_lock, queue_lock (usually queue_lock
is at the beginning). This patch is only to tell lockdep that ifb is
a different device (e.g. from eth) and has its own pair of queue
locks. (This warning is a false-positive in common scenario of using
ifb; yet there are possible situations, when this order could be
dangerous; lockdep should warn in such a case.) (With suggestions by
David S. Miller)


Reported-and-tested-by: Denys Fedoryshchenko <denys@visp.net.lb>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>

---

 drivers/net/ifb.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 15949d3..af233b5 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -35,6 +35,7 @@
 #include <linux/moduleparam.h>
 #include <net/pkt_sched.h>
 #include <net/net_namespace.h>
+#include <linux/lockdep.h>
 
 #define TX_TIMEOUT  (2*HZ)
 
@@ -227,6 +228,16 @@ static struct rtnl_link_ops ifb_link_ops __read_mostly = {
 module_param(numifbs, int, 0);
 MODULE_PARM_DESC(numifbs, "Number of ifb devices");
 
+/*
+ * dev_ifb->queue_lock is usually taken after dev->ingress_lock,
+ * reversely to e.g. qdisc_lock_tree(). It should be safe until
+ * ifb doesn't take dev->queue_lock with dev_ifb->ingress_lock.
+ * But lockdep should know that ifb has different locks from dev.
+ */
+static struct lock_class_key ifb_queue_lock_key;
+static struct lock_class_key ifb_ingress_lock_key;
+
+
 static int __init ifb_init_one(int index)
 {
 	struct net_device *dev_ifb;
@@ -246,6 +257,10 @@ static int __init ifb_init_one(int index)
 	err = register_netdevice(dev_ifb);
 	if (err < 0)
 		goto err;
+
+	lockdep_set_class(&dev_ifb->queue_lock, &ifb_queue_lock_key);
+	lockdep_set_class(&dev_ifb->ingress_lock, &ifb_ingress_lock_key);
+
 	return 0;
 
 err:
