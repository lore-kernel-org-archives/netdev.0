From: David Miller <davem@davemloft.net>
Subject: [RFC]: Driver internal queue mapping
Date: Mon, 06 Aug 2007 00:16:40 -0700 (PDT)
Message-ID: <20070806.001640.74747569.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, hadi@cyberus.ca
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50374
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753926AbXHFHQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2007 03:16:40 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


In order to put some energy back into the "device selects
TX queue internally" discussion I've cooked up an example
patch below.

While tossing this together I noticed that the current code
paths seem to not check the queue status at the beginnig of
running the queue, f.e. via dev_queue_xmit(), it just blindly
invokes qdisc_run() which only checks the global queue stopped
status, not the mapped one.

This is cumbersome and isn't going to work very well when we
split up all the locking to be per-queue.

The problem is that qdisc_run() has not enough information.
Proper checks can't be made until we know what packet we are
going to process.

Anyways, here is a patch giving an example interface to let
the driver override skb->queue_mapping.  The drivers/net/sunvnet.c
driver would implement this as finding the port number for the
virtual channel that the packet should go over.

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4a616d7..c2be6f7 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -474,6 +474,8 @@ struct net_device
 						    struct net_device *dev);
 	/* These may be needed for future network-power-down code. */
 	unsigned long		trans_start;	/* Time (in jiffies) of last Tx	*/
+	void			(*tx_queue_select)(struct sk_buff *skb,
+						   struct net_device *dev);
 
 	int			watchdog_timeo; /* used by dev_watchdog() */
 	struct timer_list	watchdog_timer;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index c81649c..ff8742c 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -141,6 +141,9 @@ static inline int qdisc_restart(struct net_device *dev)
 	if (unlikely((skb = dev_dequeue_skb(dev, q)) == NULL))
 		return 0;
 
+	if (dev->tx_queue_select)
+		dev->tx_queue_select(skb, dev);
+
 	/*
 	 * When the driver has LLTX set, it does its own locking in
 	 * start_xmit. These checks are worth it because even uncongested

