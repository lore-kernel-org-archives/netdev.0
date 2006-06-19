From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NET]: Prevent multiple qdisc runs
Date: Mon, 19 Jun 2006 22:15:19 +1000
Message-ID: <20060619121519.GA16031@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="AhhlLboLdkugWU4S"
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:13586 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932404AbWFSMPb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jun 2006 08:15:31 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--AhhlLboLdkugWU4S
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

I'm nearly done with the generic segmentation offload stuff (although
only TCPv4 is implemented for now), and I encountered this problem.

[NET]: Prevent multiple qdisc runs

Having two or more qdisc_run's contend against each other is bad because
it can induce packet reordering if the packets have to be requeued.  It
appears that this is an unintended consequence of relinquinshing the queue
lock while transmitting.  That in turn is needed for devices that spend a
lot of time in their transmit routine.

There are no advantages to be had as devices with queues are inherently
single-threaded (the loopback device is not but then it doesn't have a
queue).

Even if you were to add a queue to a parallel virtual device (e.g., bolt
a tbf filter in front of an ipip tunnel device), you would still want to
process the queue in sequence to ensure that the packets are ordered
correctly.

The solution here is to steal a bit from net_device to prevent this.

BTW, as qdisc_restart is no longer used by anyone as a module inside the
kernel (IIRC it used to with netif_wake_queue), I have not exported the
new __qdisc_run function.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--AhhlLboLdkugWU4S
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="qdisc-run.patch"

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e432b74..39919c8 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -233,6 +233,7 @@ enum netdev_state_t
 	__LINK_STATE_RX_SCHED,
 	__LINK_STATE_LINKWATCH_PENDING,
 	__LINK_STATE_DORMANT,
+	__LINK_STATE_QDISC_RUNNING,
 };
 
 
diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index b94d1ad..75b5b93 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -218,12 +218,13 @@ extern struct qdisc_rate_table *qdisc_ge
 		struct rtattr *tab);
 extern void qdisc_put_rtab(struct qdisc_rate_table *tab);
 
-extern int qdisc_restart(struct net_device *dev);
+extern void __qdisc_run(struct net_device *dev);
 
 static inline void qdisc_run(struct net_device *dev)
 {
-	while (!netif_queue_stopped(dev) && qdisc_restart(dev) < 0)
-		/* NOTHING */;
+	if (!netif_queue_stopped(dev) &&
+	    !test_and_set_bit(__LINK_STATE_QDISC_RUNNING, &dev->state))
+		__qdisc_run(dev);
 }
 
 extern int tc_classify(struct sk_buff *skb, struct tcf_proto *tp,
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index b1e4c5e..d7aca8e 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -90,7 +90,7 @@ void qdisc_unlock_tree(struct net_device
    NOTE: Called under dev->queue_lock with locally disabled BH.
 */
 
-int qdisc_restart(struct net_device *dev)
+static inline int qdisc_restart(struct net_device *dev)
 {
 	struct Qdisc *q = dev->qdisc;
 	struct sk_buff *skb;
@@ -179,6 +179,14 @@ requeue:
 	return q->q.qlen;
 }
 
+void __qdisc_run(struct net_device *dev)
+{
+	while (qdisc_restart(dev) < 0 && !netif_queue_stopped(dev))
+		/* NOTHING */;
+
+	clear_bit(__LINK_STATE_QDISC_RUNNING, &dev->state);
+}
+
 static void dev_watchdog(unsigned long arg)
 {
 	struct net_device *dev = (struct net_device *)arg;
@@ -620,6 +628,5 @@ EXPORT_SYMBOL(qdisc_create_dflt);
 EXPORT_SYMBOL(qdisc_alloc);
 EXPORT_SYMBOL(qdisc_destroy);
 EXPORT_SYMBOL(qdisc_reset);
-EXPORT_SYMBOL(qdisc_restart);
 EXPORT_SYMBOL(qdisc_lock_tree);
 EXPORT_SYMBOL(qdisc_unlock_tree);

--AhhlLboLdkugWU4S--
