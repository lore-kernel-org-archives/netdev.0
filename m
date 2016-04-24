From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 6/6] net: remove NETDEV_TX_LOCKED support
Date: Sun, 24 Apr 2016 21:38:14 +0200
Message-ID: <1461526694-11367-7-git-send-email-fw@strlen.de>
References: <1461526694-11367-1-git-send-email-fw@strlen.de>
Cc: linux-kernel@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461526694-11367-1-git-send-email-fw@strlen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No more users in the tree, remove NETDEV_TX_LOCKED support.
Adds another hole in softnet_stats struct, but better than keeping
the unused collision counter around.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 Documentation/networking/netdev-features.txt | 10 ++++-----
 Documentation/networking/netdevices.txt      |  9 +++-----
 include/linux/netdevice.h                    |  3 ---
 net/core/net-procfs.c                        |  3 ++-
 net/core/pktgen.c                            |  1 -
 net/sched/sch_generic.c                      | 32 ----------------------------
 6 files changed, 9 insertions(+), 49 deletions(-)

diff --git a/Documentation/networking/netdev-features.txt b/Documentation/networking/netdev-features.txt
index f310ede..7413eb0 100644
--- a/Documentation/networking/netdev-features.txt
+++ b/Documentation/networking/netdev-features.txt
@@ -131,13 +131,11 @@ stack. Driver should not change behaviour based on them.
 
  * LLTX driver (deprecated for hardware drivers)
 
-NETIF_F_LLTX should be set in drivers that implement their own locking in
-transmit path or don't need locking at all (e.g. software tunnels).
-In ndo_start_xmit, it is recommended to use a try_lock and return
-NETDEV_TX_LOCKED when the spin lock fails.  The locking should also properly
-protect against other callbacks (the rules you need to find out).
+NETIF_F_LLTX is meant to be used by drivers that don't need locking at all,
+e.g. software tunnels.
 
-Don't use it for new drivers.
+This is also used in a few legacy drivers that implement their
+own locking, don't use it for new (hardware) drivers.
 
  * netns-local device
 
diff --git a/Documentation/networking/netdevices.txt b/Documentation/networking/netdevices.txt
index 0b1cf6b..7fec206 100644
--- a/Documentation/networking/netdevices.txt
+++ b/Documentation/networking/netdevices.txt
@@ -69,10 +69,9 @@ ndo_start_xmit:
 
 	When the driver sets NETIF_F_LLTX in dev->features this will be
 	called without holding netif_tx_lock. In this case the driver
-	has to lock by itself when needed. It is recommended to use a try lock
-	for this and return NETDEV_TX_LOCKED when the spin lock fails.
-	The locking there should also properly protect against 
-	set_rx_mode. Note that the use of NETIF_F_LLTX is deprecated.
+	has to lock by itself when needed.
+	The locking there should also properly protect against
+	set_rx_mode. WARNING: use of NETIF_F_LLTX is deprecated.
 	Don't use it for new drivers.
 
 	Context: Process with BHs disabled or BH (timer),
@@ -83,8 +82,6 @@ ndo_start_xmit:
 	o NETDEV_TX_BUSY Cannot transmit packet, try later 
 	  Usually a bug, means queue start/stop flow control is broken in
 	  the driver. Note: the driver must NOT put the skb in its DMA ring.
-	o NETDEV_TX_LOCKED Locking failed, please retry quickly.
-	  Only valid when NETIF_F_LLTX is set.
 
 ndo_tx_timeout:
 	Synchronization: netif_tx_lock spinlock; all TX queues frozen.
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1f6d5db..18d8394 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -106,7 +106,6 @@ enum netdev_tx {
 	__NETDEV_TX_MIN	 = INT_MIN,	/* make sure enum is signed */
 	NETDEV_TX_OK	 = 0x00,	/* driver took care of packet */
 	NETDEV_TX_BUSY	 = 0x10,	/* driver tx path was busy*/
-	NETDEV_TX_LOCKED = 0x20,	/* driver tx lock was already taken */
 };
 typedef enum netdev_tx netdev_tx_t;
 
@@ -831,7 +830,6 @@ struct tc_to_netdev {
  *	the queue before that can happen; it's for obsolete devices and weird
  *	corner cases, but the stack really does a non-trivial amount
  *	of useless work if you return NETDEV_TX_BUSY.
- *        (can also return NETDEV_TX_LOCKED iff NETIF_F_LLTX)
  *	Required; cannot be NULL.
  *
  * netdev_features_t (*ndo_fix_features)(struct net_device *dev,
@@ -2737,7 +2735,6 @@ struct softnet_data {
 	/* stats */
 	unsigned int		processed;
 	unsigned int		time_squeeze;
-	unsigned int		cpu_collision;
 	unsigned int		received_rps;
 #ifdef CONFIG_RPS
 	struct softnet_data	*rps_ipi_list;
diff --git a/net/core/net-procfs.c b/net/core/net-procfs.c
index 2bf8329..14d0934 100644
--- a/net/core/net-procfs.c
+++ b/net/core/net-procfs.c
@@ -162,7 +162,8 @@ static int softnet_seq_show(struct seq_file *seq, void *v)
 		   "%08x %08x %08x %08x %08x %08x %08x %08x %08x %08x %08x\n",
 		   sd->processed, sd->dropped, sd->time_squeeze, 0,
 		   0, 0, 0, 0, /* was fastroute */
-		   sd->cpu_collision, sd->received_rps, flow_limit_count);
+		   0,	/* was cpu_collision */
+		   sd->received_rps, flow_limit_count);
 	return 0;
 }
 
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 20999aa..8604ae2 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3472,7 +3472,6 @@ xmit_more:
 				     pkt_dev->odevname, ret);
 		pkt_dev->errors++;
 		/* fallthru */
-	case NETDEV_TX_LOCKED:
 	case NETDEV_TX_BUSY:
 		/* Retry it next time */
 		atomic_dec(&(pkt_dev->skb->users));
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 80742ed..9c77562 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -108,35 +108,6 @@ static struct sk_buff *dequeue_skb(struct Qdisc *q, bool *validate,
 	return skb;
 }
 
-static inline int handle_dev_cpu_collision(struct sk_buff *skb,
-					   struct netdev_queue *dev_queue,
-					   struct Qdisc *q)
-{
-	int ret;
-
-	if (unlikely(dev_queue->xmit_lock_owner == smp_processor_id())) {
-		/*
-		 * Same CPU holding the lock. It may be a transient
-		 * configuration error, when hard_start_xmit() recurses. We
-		 * detect it by checking xmit owner and drop the packet when
-		 * deadloop is detected. Return OK to try the next skb.
-		 */
-		kfree_skb_list(skb);
-		net_warn_ratelimited("Dead loop on netdevice %s, fix it urgently!\n",
-				     dev_queue->dev->name);
-		ret = qdisc_qlen(q);
-	} else {
-		/*
-		 * Another cpu is holding lock, requeue & delay xmits for
-		 * some time.
-		 */
-		__this_cpu_inc(softnet_data.cpu_collision);
-		ret = dev_requeue_skb(skb, q);
-	}
-
-	return ret;
-}
-
 /*
  * Transmit possibly several skbs, and handle the return status as
  * required. Holding the __QDISC___STATE_RUNNING bit guarantees that
@@ -174,9 +145,6 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 	if (dev_xmit_complete(ret)) {
 		/* Driver sent out skb successfully or skb was consumed */
 		ret = qdisc_qlen(q);
-	} else if (ret == NETDEV_TX_LOCKED) {
-		/* Driver try lock failed */
-		ret = handle_dev_cpu_collision(skb, txq, q);
 	} else {
 		/* Driver returned NETDEV_TX_BUSY - requeue skb */
 		if (unlikely(ret != NETDEV_TX_BUSY))
-- 
2.7.3
