From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [WIP] net+mlx4: auto doorbell
Date: Wed, 30 Nov 2016 23:30:15 +0100
Message-ID: <20161130233015.3de95356@redhat.com>
References: <20140903165943.372b897b@redhat.com>
        <20161116234022.2bad179b@redhat.com>
        <1479342849.8455.233.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161117091638.5fab8494@redhat.com>
        <1479388850.8455.240.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161117144248.23500001@redhat.com>
        <1479392258.8455.249.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161117155753.17b76f5a@redhat.com>
        <1479399679.8455.255.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161117193021.580589ae@redhat.com>
        <1479408683.8455.273.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161121170351.50a09ee1@redhat.com>
        <1479751857.8455.419.camel@edumazet-glaptop3.roam.corp.google.com>
        <1480402716.18162.124.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161130123810.581ba21f@redhat.com>
        <1480521386.18162.189.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161130201711.2f353a76@redhat.com>
        <1480534200.18162.203.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hpe.com>, netdev@vger.kernel.org,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Achiad Shochat <achiad@mellanox.com>, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46262 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757133AbcK3WaZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 17:30:25 -0500
In-Reply-To: <1480534200.18162.203.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Nov 2016 11:30:00 -0800
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Wed, 2016-11-30 at 20:17 +0100, Jesper Dangaard Brouer wrote:
> 
> > Don't take is as critique Eric.  I was hoping your patch would have
> > solved this issue of being sensitive to TX completion adjustments.  You
> > usually have good solutions for difficult issues. I basically rejected
> > Achiad's approach/patch because it was too sensitive to these kind of
> > adjustments.  
> 
> Well, this patch can hurt latencies, because a doorbell can be delayed,
> and softirqs can be delayed by many hundred of usec in some cases.
> 
> I would not enable this behavior by default.

What about another scheme, where dev_hard_start_xmit() can return an
indication that driver choose not to flush (based on TX queue depth),
and there by requesting stack to call flush at a later point.

Would that introduce less latency issues?


Patch muckup (not even compile tested):

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4ffcd874cc20..d7d15e4e6766 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -109,6 +109,7 @@ enum netdev_tx {
 	__NETDEV_TX_MIN	 = INT_MIN,	/* make sure enum is signed */
 	NETDEV_TX_OK	 = 0x00,	/* driver took care of packet */
 	NETDEV_TX_BUSY	 = 0x10,	/* driver tx path was busy*/
+	NETDEV_TX_FLUSHME= 0x04,	/* driver request doorbell/flush later */
 };
 typedef enum netdev_tx netdev_tx_t;
 
@@ -536,6 +537,8 @@ enum netdev_queue_state_t {
 	__QUEUE_STATE_DRV_XOFF,
 	__QUEUE_STATE_STACK_XOFF,
 	__QUEUE_STATE_FROZEN,
+	// __QUEUE_STATE_NEED_FLUSH
+	// is is better to store in txq state?
 };
 
 #define QUEUE_STATE_DRV_XOFF	(1 << __QUEUE_STATE_DRV_XOFF)
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index e6aa0a249672..7480e44c5a50 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -75,6 +75,7 @@ struct Qdisc {
 	void			*u32_node;
 
 	struct netdev_queue	*dev_queue;
+	struct netdev_queue	*flush_dev_queue; // store txq to flush here?
 
 	struct gnet_stats_rate_est64	rate_est;
 	struct gnet_stats_basic_cpu __percpu *cpu_bstats;
@@ -98,6 +99,20 @@ struct Qdisc {
 	spinlock_t		busylock ____cacheline_aligned_in_smp;
 };
 
+static inline void qdisc_request_txq_flush(struct Qdisc *qdisc,
+					   struct netdev_queue *txq)
+{
+	struct net_device dev;
+
+	if (qdisc->flush_dev_queue) {
+		if (likely(qdisc->flush_dev_queue == txq))
+			return;
+		/* Flush existing txq before reassignment */
+		dev_flush_xmit(qdisc_dev(q), txq);
+	}
+	qdisc->flush_dev_queue = txq;
+}
+
 static inline bool qdisc_is_running(const struct Qdisc *qdisc)
 {
 	return (raw_read_seqcount(&qdisc->running) & 1) ? true : false;
@@ -117,6 +132,19 @@ static inline bool qdisc_run_begin(struct Qdisc *qdisc)
 
 static inline void qdisc_run_end(struct Qdisc *qdisc)
 {
+	/* flush device txq here, if needed */
+	if (qdisc->flush_dev_queue) {
+		struct netdev_queue *txq = qdisc->flush_dev_queue;
+		struct net_device *dev = qdisc_dev(q);
+
+		qdisc->flush_dev_queue = NULL;
+		dev_flush_xmit(dev, txq);
+		/*
+		 * DISCUSS: it is too soon to flush here? What about
+		 * rescheduling a NAPI poll cycle for this device,
+		 * before calling flush.
+		 */
+	}
 	write_seqcount_end(&qdisc->running);
 }
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 048b46b7c92a..70339c267f33 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2880,6 +2880,15 @@ netdev_features_t netif_skb_features(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(netif_skb_features);
 
+static int dev_flush_xmit(struct net_device *dev,
+			  struct netdev_queue *txq)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	ops->ndo_flush_xmit(dev, txq);
+	// Oh oh, do we need to take HARD_TX_LOCK ??
+}
+
 static int xmit_one(struct sk_buff *skb, struct net_device *dev,
 		    struct netdev_queue *txq, bool more)
 {
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 6cfb6e9038c2..55c01b6f6311 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -190,6 +190,13 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 
 	if (dev_xmit_complete(ret)) {
 		/* Driver sent out skb successfully or skb was consumed */
+		if (ret == NETDEV_TX_FLUSHME) {
+			/* Driver choose no-TX-doorbell MMIO write.
+			 * This made taking qdisc root_lock less expensive.
+			 */
+			qdisc_request_txq_flush(q, txq);
+			// Flush happens later in qdisc_run_end()
+		}
 		ret = qdisc_qlen(q);
 	} else {
 		/* Driver returned NETDEV_TX_BUSY - requeue skb */


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
