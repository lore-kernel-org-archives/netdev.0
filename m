From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH RFC] spinlock: split out debugging check from
 spin_lock_mutex
Date: Thu, 18 Apr 2013 15:29:12 -0400
Message-ID: <20130418192912.GB29130@hmsreliant.think-freely.org>
References: <5166F35B.1040200@acm.org>
 <20130411191409.GA9790@hmsreliant.think-freely.org>
 <5167A953.1020900@acm.org>
 <20130412113232.GA19966@hmsreliant.think-freely.org>
 <516813A0.1040300@acm.org>
 <20130412184542.GB19966@hmsreliant.think-freely.org>
 <51690AAB.1030102@acm.org>
 <20130415141610.GA3505@hmsreliant.think-freely.org>
 <CAO+b5-oBfH3M0dnrQSs-p1BF_5hKy2tsU-dD=EP9+S=iqPs5ew@mail.gmail.com>
 <20130416172454.GC9241@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bart Van Assche <bvanassche@acm.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ingo Molnar <mingo@redhat.com>
To: Bart Van Assche <bart.vanassche@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47660 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752796Ab3DRT3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 15:29:32 -0400
Content-Disposition: inline
In-Reply-To: <20130416172454.GC9241@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Well, I guess Ingo doesn't have time  to respond here.  Given that, I've been
looking at other ways of adressing this problem (as the more I think about it,
the more I think changing mutex semantics, even to be more accepting, is going
to be met with lots of friction).  I've come up with the below change, and it
works well for me (I've hammered it with ifup/downs while sending messages over
netconsole for 24 hours now without any incident).  I'm not sure I like all the
details yet (I modified the rx_flag field to be a gneral flags field that uses
test/set/clear_bit, which I don't think is necessecary, but it seems saner to
me).  the meat of the change though is that instead of a mutex, we use two flags
that, respectively, inhibit netpoll usage, and indicate when we're in a netpoll
service path.  Using these two flags, in conjunction with a wait_queue, we can
signal to executors in the netpoll path that we're inhibiting its use and expect
to any user in the path to complete and wake up any contexts in the inhibiting
path.  Seems to work well for me.  Let me know what you think, and I'll make any
desired changes and post an official patch.

Best
Neil


commit c277d54d471572b0ec7b27812d205fb303ad44f9
Author: Neil Horman <nhorman@tuxdriver.com>
Date:   Wed Apr 17 15:59:44 2013 -0400

    netpoll: convert mutex into a wait_event
    
    Bart Van Assche recently reported a warning to me:
    
    <IRQ>  [<ffffffff8103d79f>] warn_slowpath_common+0x7f/0xc0
     [<ffffffff8103d7fa>] warn_slowpath_null+0x1a/0x20
     [<ffffffff814761dd>] mutex_trylock+0x16d/0x180
     [<ffffffff813968c9>] netpoll_poll_dev+0x49/0xc30
     [<ffffffff8136a2d2>] ? __alloc_skb+0x82/0x2a0
     [<ffffffff81397715>] netpoll_send_skb_on_dev+0x265/0x410
     [<ffffffff81397c5a>] netpoll_send_udp+0x28a/0x3a0
     [<ffffffffa0541843>] ? write_msg+0x53/0x110 [netconsole]
     [<ffffffffa05418bf>] write_msg+0xcf/0x110 [netconsole]
     [<ffffffff8103eba1>] call_console_drivers.constprop.17+0xa1/0x1c0
     [<ffffffff8103fb76>] console_unlock+0x2d6/0x450
     [<ffffffff8104011e>] vprintk_emit+0x1ee/0x510
     [<ffffffff8146f9f6>] printk+0x4d/0x4f
     [<ffffffffa0004f1d>] scsi_print_command+0x7d/0xe0 [scsi_mod]
    
    This resulted from my commit ca99ca14c which introduced a mutex_trylock
    operation in a path that could execute in interrupt context.  When mutex
    debugging is enabled, the above warns the user when we are in fact exectuting in
    interrupt context.
    
    After some discussion, I'm not sure a mutex is the right choice here, as it
    seems unsafe to use (deadlock possibilities due to implementation details).
    Instead lets convert the mutex to a mechanism that makes use of a
    wait_queue_head and some flag bits.  The dev_close paths can now set a bit to
    suspend netpoll and then sleep waiting for the NETPOLL_POLLING flag to clear,
    which allows for flushing of any in-progress execution in the
    netpoll_poll_dev_path.
    
    Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
    Reported-by: Bart Van Assche <bvanassche@acm.org>
    CC: Bart Van Assche <bvanassche@acm.org>
    CC: David Miller <davem@davemloft.net>
    CC: netdev@vger.kernel.org

diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index 9d7d8c6..52e1d14 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -35,12 +35,19 @@ struct netpoll {
 	struct work_struct cleanup_work;
 };
 
+/* Flag defs for netpoll_info->flags */
+
+#define NETPOLL_RX_ENABLED	1
+#define NETPOLL_RX_DROP		2
+#define NETPOLL_SUSPENDED	3
+#define NETPOLL_POLLING		4
+
 struct netpoll_info {
 	atomic_t refcnt;
 
-	unsigned long rx_flags;
+	unsigned long flags;
 	spinlock_t rx_lock;
-	struct mutex dev_lock;
+	wait_queue_head_t dev_wait;
 	struct list_head rx_np; /* netpolls that registered an rx_hook */
 
 	struct sk_buff_head neigh_tx; /* list of neigh requests to reply to */
@@ -53,11 +60,11 @@ struct netpoll_info {
 };
 
 #ifdef CONFIG_NETPOLL
-extern int netpoll_rx_disable(struct net_device *dev);
-extern void netpoll_rx_enable(struct net_device *dev);
+extern int netpoll_suspend(struct net_device *dev);
+extern void netpoll_resume(struct net_device *dev);
 #else
-static inline int netpoll_rx_disable(struct net_device *dev) { return 0; }
-static inline void netpoll_rx_enable(struct net_device *dev) { return; }
+static inline int netpoll_suspend(struct net_device *dev) { return 0; }
+static inline void netpoll_resume(struct net_device *dev) { return; }
 #endif
 
 void netpoll_send_udp(struct netpoll *np, const char *msg, int len);
@@ -88,7 +95,8 @@ static inline bool netpoll_rx_on(struct sk_buff *skb)
 {
 	struct netpoll_info *npinfo = rcu_dereference_bh(skb->dev->npinfo);
 
-	return npinfo && (!list_empty(&npinfo->rx_np) || npinfo->rx_flags);
+	return npinfo && (!list_empty(&npinfo->rx_np) ||
+	       test_bit(NETPOLL_RX_ENABLED, &npinfo->flags));
 }
 
 static inline bool netpoll_rx(struct sk_buff *skb)
@@ -104,8 +112,9 @@ static inline bool netpoll_rx(struct sk_buff *skb)
 
 	npinfo = rcu_dereference_bh(skb->dev->npinfo);
 	spin_lock(&npinfo->rx_lock);
-	/* check rx_flags again with the lock held */
-	if (npinfo->rx_flags && __netpoll_rx(skb, npinfo))
+	/* check flags again with the lock held */
+	if (test_bit(NETPOLL_RX_ENABLED, &npinfo->flags) &&
+	    __netpoll_rx(skb, npinfo))
 		ret = true;
 	spin_unlock(&npinfo->rx_lock);
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 3655ff9..163dd3e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1200,7 +1200,7 @@ static int __dev_open(struct net_device *dev)
 	 * If we don't do this there is a chance ndo_poll_controller
 	 * or ndo_poll may be running while we open the device
 	 */
-	ret = netpoll_rx_disable(dev);
+	ret = netpoll_suspend(dev);
 	if (ret)
 		return ret;
 
@@ -1217,7 +1217,7 @@ static int __dev_open(struct net_device *dev)
 	if (!ret && ops->ndo_open)
 		ret = ops->ndo_open(dev);
 
-	netpoll_rx_enable(dev);
+	netpoll_resume(dev);
 
 	if (ret)
 		clear_bit(__LINK_STATE_START, &dev->state);
@@ -1311,7 +1311,7 @@ static int __dev_close(struct net_device *dev)
 	LIST_HEAD(single);
 
 	/* Temporarily disable netpoll until the interface is down */
-	retval = netpoll_rx_disable(dev);
+	retval = netpoll_suspend(dev);
 	if (retval)
 		return retval;
 
@@ -1319,7 +1319,7 @@ static int __dev_close(struct net_device *dev)
 	retval = __dev_close_many(&single);
 	list_del(&single);
 
-	netpoll_rx_enable(dev);
+	netpoll_resume(dev);
 	return retval;
 }
 
@@ -1360,7 +1360,7 @@ int dev_close(struct net_device *dev)
 		LIST_HEAD(single);
 
 		/* Block netpoll rx while the interface is going down */
-		ret = netpoll_rx_disable(dev);
+		ret = netpoll_suspend(dev);
 		if (ret)
 			return ret;
 
@@ -1368,7 +1368,7 @@ int dev_close(struct net_device *dev)
 		dev_close_many(&single);
 		list_del(&single);
 
-		netpoll_rx_enable(dev);
+		netpoll_resume(dev);
 	}
 	return ret;
 }
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index a3a17ae..a094227 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -50,8 +50,6 @@ static atomic_t trapped;
 DEFINE_STATIC_SRCU(netpoll_srcu);
 
 #define USEC_PER_POLL	50
-#define NETPOLL_RX_ENABLED  1
-#define NETPOLL_RX_DROP     2
 
 #define MAX_SKB_SIZE							\
 	(sizeof(struct ethhdr) +					\
@@ -155,7 +153,7 @@ static int poll_one_napi(struct netpoll_info *npinfo,
 	if (!test_bit(NAPI_STATE_SCHED, &napi->state))
 		return budget;
 
-	npinfo->rx_flags |= NETPOLL_RX_DROP;
+	set_bit(NETPOLL_RX_DROP, &npinfo->flags);
 	atomic_inc(&trapped);
 	set_bit(NAPI_STATE_NPSVC, &napi->state);
 
@@ -164,7 +162,7 @@ static int poll_one_napi(struct netpoll_info *npinfo,
 
 	clear_bit(NAPI_STATE_NPSVC, &napi->state);
 	atomic_dec(&trapped);
-	npinfo->rx_flags &= ~NETPOLL_RX_DROP;
+	clear_bit(NETPOLL_RX_DROP, &npinfo->flags);
 
 	return budget - work;
 }
@@ -206,27 +204,22 @@ static void netpoll_poll_dev(struct net_device *dev)
 	 * the dev_open/close paths use this to block netpoll activity
 	 * while changing device state
 	 */
-	if (!mutex_trylock(&ni->dev_lock))
-		return;
+	set_bit(NETPOLL_POLLING, &ni->flags);
+	if (test_bit(NETPOLL_SUSPENDED, &ni->flags))
+		goto out;
 
-	if (!netif_running(dev)) {
-		mutex_unlock(&ni->dev_lock);
-		return;
-	}
+	if (!netif_running(dev))
+		goto out;
 
 	ops = dev->netdev_ops;
-	if (!ops->ndo_poll_controller) {
-		mutex_unlock(&ni->dev_lock);
-		return;
-	}
+	if (!ops->ndo_poll_controller)
+		goto out;
 
 	/* Process pending work on NIC */
 	ops->ndo_poll_controller(dev);
 
 	poll_napi(dev);
 
-	mutex_unlock(&ni->dev_lock);
-
 	if (dev->flags & IFF_SLAVE) {
 		if (ni) {
 			struct net_device *bond_dev;
@@ -245,32 +238,37 @@ static void netpoll_poll_dev(struct net_device *dev)
 	service_neigh_queue(ni);
 
 	zap_completion_queue();
+out:
+	clear_bit(NETPOLL_POLLING, &ni->dev_wait.lock);
+	wake_up(&ni->dev_wait);
 }
 
-int netpoll_rx_disable(struct net_device *dev)
+int netpoll_suspend(struct net_device *dev)
 {
 	struct netpoll_info *ni;
 	int idx;
+
 	might_sleep();
 	idx = srcu_read_lock(&netpoll_srcu);
 	ni = srcu_dereference(dev->npinfo, &netpoll_srcu);
-	if (ni)
-		mutex_lock(&ni->dev_lock);
+	if (ni && !test_and_set_bit(NETPOLL_SUSPENDED, &ni->flags))
+		wait_event(ni->dev_wait, !test_bit(NETPOLL_POLLING,
+			   &ni->flags));
 	srcu_read_unlock(&netpoll_srcu, idx);
 	return 0;
 }
-EXPORT_SYMBOL(netpoll_rx_disable);
+EXPORT_SYMBOL(netpoll_suspend);
 
-void netpoll_rx_enable(struct net_device *dev)
+void netpoll_resume(struct net_device *dev)
 {
 	struct netpoll_info *ni;
 	rcu_read_lock();
 	ni = rcu_dereference(dev->npinfo);
 	if (ni)
-		mutex_unlock(&ni->dev_lock);
+		clear_bit(NETPOLL_SUSPENDED, &ni->flags);
 	rcu_read_unlock();
 }
-EXPORT_SYMBOL(netpoll_rx_enable);
+EXPORT_SYMBOL(netpoll_resume);
 
 static void refill_skbs(void)
 {
@@ -1042,11 +1040,11 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev, gfp_t gfp)
 			goto out;
 		}
 
-		npinfo->rx_flags = 0;
+		npinfo->flags = 0;
 		INIT_LIST_HEAD(&npinfo->rx_np);
 
 		spin_lock_init(&npinfo->rx_lock);
-		mutex_init(&npinfo->dev_lock);
+		init_waitqueue_head(&npinfo->dev_wait);
 		skb_queue_head_init(&npinfo->neigh_tx);
 		skb_queue_head_init(&npinfo->txq);
 		INIT_DELAYED_WORK(&npinfo->tx_work, queue_process);
@@ -1068,7 +1066,7 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev, gfp_t gfp)
 
 	if (np->rx_hook) {
 		spin_lock_irqsave(&npinfo->rx_lock, flags);
-		npinfo->rx_flags |= NETPOLL_RX_ENABLED;
+		set_bit(NETPOLL_RX_ENABLED, &npinfo->flags);
 		list_add_tail(&np->rx, &npinfo->rx_np);
 		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
 	}
@@ -1251,7 +1249,7 @@ void __netpoll_cleanup(struct netpoll *np)
 		spin_lock_irqsave(&npinfo->rx_lock, flags);
 		list_del(&np->rx);
 		if (list_empty(&npinfo->rx_np))
-			npinfo->rx_flags &= ~NETPOLL_RX_ENABLED;
+			clear_bit(NETPOLL_RX_ENABLED, &npinfo->flags);
 		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
 	}
 
