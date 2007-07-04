From: Olaf Kirch <okir@lst.de>
Subject: Races in net_rx_action vs netpoll?
Date: Wed, 4 Jul 2007 14:16:32 +0200
Message-ID: <200707041416.33732.okir@lst.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:45207 "EHLO mail.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756776AbXGDMQo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jul 2007 08:16:44 -0400
Received: from [192.168.5.7] (p54A7FD92.dip.t-dialin.net [84.167.253.146])
	(authenticated bits=0)
	by mail.lst.de (8.12.3/8.12.3/Debian-7.1) with ESMTP id l64CGfNK015018
	(version=TLSv1/SSLv3 cipher=EXP1024-RC4-SHA bits=56 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 4 Jul 2007 14:16:42 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

as a caveat, let me say that the whole thing discussed below started
as an investigation of an oops on RHEL4. You may or may not be
interested in 2.6.9 kernels (depending on your employer :-) but
looking at mainline it seems to be the issue is still present.

It appears there is a race condition between net_rx_action and
poll_napi. In the particular scenario I've been debugging, the
machine BUGs in netif_rx_complete because the device is no longer
on the poll list.

Here's a snippet from net_rx_action:

        while (!list_empty(&queue->poll_list)) {
                struct net_device *dev;

                if (budget <= 0 || jiffies - start_time > 1)
                        goto softnet_break;

                local_irq_enable();

                dev = list_entry(queue->poll_list.next,
                                 struct net_device, poll_list);
                have = netpoll_poll_lock(dev);

And here's poll_napi:

        if (test_bit(__LINK_STATE_RX_SCHED, &np->dev->state) &&
            npinfo->poll_owner != smp_processor_id() &&
            spin_trylock(&npinfo->poll_lock)) {
                [...]
                np->dev->poll(np->dev, &budget);

Here's the race:

 CPU0	interrupt arrives, puts interface on local poll_list
	net_rx_action runs, finds the list is not empty.

 CPU1	Something causes a kernel printk, which is sent via
	netconsole. Via netpoll_send_skb we arrive in
	poll_napi. RX_SCHED is set, poll_owner is -1,
	and we're able to grab the poll_lock.

 CPU0	Calls netpoll_poll_lock and spins on the poll_lock

 CPU1	Calls dev->poll, which does its work and calls
	netif_rx_complete, returns, and releases the spinlock.

 CPU0	resumes, calls dev->poll(), which calls netif_rx_action
	again, and BUGs as the device is no longer on the poll_list.

Does this make sense so far?

Of course, the race can happen the other way round as well -
poll_napi tests for the RX_SCHED bit before taking the spin_lock, so
net_rx_action running on a different CPU may call netif_rx_complete
and release the spinlock inbetween poll_napi's test_bit() and
spin_trylock(). Not very likely to happen, but possible.

This is just one failure mode. A worse case would be if
net_rx_action finds the poll_list is non-empty, but before it
executes dev = list_entry(queue->poll_list.next, ...), poll_napi
runs on another CPU and removes the device from the list. In the
worst case, dev would now point into softnet_data.

I think the only real fix for this is to restrict who is allowed
to remove the interface from the poll_list. Only net_rx_action
should be allowed to do so. A possible patch is given below
(beware, it's untested so far)

Olaf
-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax
-----------------
From: Olaf Kirch <olaf.kirch@oracle.com>

Keep netpoll/poll_napi from messing with the poll_list.
Only net_rx_action is allowed to manipulate the list.

This patch is a draft only.

Signed-off-by: Olaf Kirch <olaf.kirch@oracle.com>
---
 include/linux/netdevice.h |   32 +++++++++++++++++++++++++-------
 net/core/dev.c            |   13 ++++++++++++-
 2 files changed, 37 insertions(+), 8 deletions(-)

Index: iscsi-2.6/include/linux/netdevice.h
===================================================================
--- iscsi-2.6.orig/include/linux/netdevice.h
+++ iscsi-2.6/include/linux/netdevice.h
@@ -248,6 +248,7 @@ enum netdev_state_t
 	__LINK_STATE_LINKWATCH_PENDING,
 	__LINK_STATE_DORMANT,
 	__LINK_STATE_QDISC_RUNNING,
+	__LINK_STATE_RX_COMPLETE,
 };
 
 
@@ -868,6 +869,12 @@ static inline u32 netif_msg_init(int deb
 /* Test if receive needs to be scheduled */
 static inline int __netif_rx_schedule_prep(struct net_device *dev)
 {
+	/* The driver may have decided that there's no more work
+	 * to be done - but now another interrupt arrives, and
+	 * we changed our mind. */
+	smp_mb__before_clear_bit();
+	clear_bit(__LINK_STATE_RX_COMPLETE, &dev->state);
+
 	return !test_and_set_bit(__LINK_STATE_RX_SCHED, &dev->state);
 }
 
@@ -910,21 +917,35 @@ static inline int netif_rx_reschedule(st
 	return 0;
 }
 
-/* Remove interface from poll list: it must be in the poll list
- * on current cpu. This primitive is called by dev->poll(), when
+/* Tell net_rx_action that we think there's no more work to be
+ * done. */
+static inline void netif_rx_complete(struct net_device *dev)
+{
+	set_bit(__LINK_STATE_RX_COMPLETE, &dev->state);
+}
+
+/* Remove interface from poll list if RX_COMPLETE is set.
+ * The device it must be in the poll list on current cpu.
+ * This primitive is called by net_rx_action when
  * it completes the work. The device cannot be out of poll list at this
  * moment, it is BUG().
  */
-static inline void netif_rx_complete(struct net_device *dev)
+static inline int netif_rx_continue(struct net_device *dev)
 {
 	unsigned long flags;
 
 	local_irq_save(flags);
+	if (!test_bit(__LINK_STATE_RX_COMPLETE, &dev->state)) {
+		local_irq_restore(flags);
+		return 1;
+	}
+
 	BUG_ON(!test_bit(__LINK_STATE_RX_SCHED, &dev->state));
 	list_del(&dev->poll_list);
 	smp_mb__before_clear_bit();
 	clear_bit(__LINK_STATE_RX_SCHED, &dev->state);
 	local_irq_restore(flags);
+	return 0;
 }
 
 static inline void netif_poll_disable(struct net_device *dev)
@@ -945,10 +966,7 @@ static inline void netif_poll_enable(str
  */
 static inline void __netif_rx_complete(struct net_device *dev)
 {
-	BUG_ON(!test_bit(__LINK_STATE_RX_SCHED, &dev->state));
-	list_del(&dev->poll_list);
-	smp_mb__before_clear_bit();
-	clear_bit(__LINK_STATE_RX_SCHED, &dev->state);
+	set_bit(__LINK_STATE_RX_COMPLETE, &dev->state);
 }
 
 static inline void netif_tx_lock(struct net_device *dev)
Index: iscsi-2.6/net/core/dev.c
===================================================================
--- iscsi-2.6.orig/net/core/dev.c
+++ iscsi-2.6/net/core/dev.c
@@ -1994,7 +1994,16 @@ static void net_rx_action(struct softirq
 				 struct net_device, poll_list);
 		have = netpoll_poll_lock(dev);
 
-		if (dev->quota <= 0 || dev->poll(dev, &budget)) {
+		/* We keep polling iff
+		 *  -	the device is over quota, OR
+		 *  -	the driver's poll() routine says there's more work
+		 *	(in which case it should set RX_COMPLETE, too), OR
+		 *  -	the RX_COMPLETE flag was cleared in the meantime
+		 *	(eg by an incoming interrupt).
+		 */
+		if (dev->quota <= 0 || dev->poll(dev, &budget) ||
+		    netif_rx_continue(dev)) {
+			clear_bit(__LINK_STATE_RX_COMPLETE, &dev->state);
 			netpoll_poll_unlock(have);
 			local_irq_disable();
 			list_move_tail(&dev->poll_list, &queue->poll_list);
@@ -2003,6 +2012,8 @@ static void net_rx_action(struct softirq
 			else
 				dev->quota = dev->weight;
 		} else {
+			/* If we get here, netif_rx_continue removed the
+			 * device from the poll_list. */
 			netpoll_poll_unlock(have);
 			dev_put(dev);
 			local_irq_disable();
