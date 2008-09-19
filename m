From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH take2] pkt_sched: Fix TX state checking in qdisc_run()
Date: Fri, 19 Sep 2008 16:44:50 +0200
Message-ID: <20080919144450.GA2646@ami.dom.local>
References: <20080919103225.GB9135@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:8718 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927AbYISOor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 10:44:47 -0400
Received: by ey-out-2122.google.com with SMTP id 6so143977eyi.37
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2008 07:44:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080919103225.GB9135@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alas this time the changelog needs more details.

Sorry,
Jarek P.
-----------------> (take 2)

pkt_sched: Fix TX state checking in qdisc_run()

Current check wrongly uses the state of the first tx queue for all tx
queues in case of non-default qdiscs. This patch brings back per dev
__LINK_STATE_XOFF flag, which is set when all tx queues are stopped.
This check is needed in qdisc_run() to avoid useless __netif_schedule()
calls. The wrongness of this check was first noticed by Herbert Xu.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 include/linux/netdevice.h |    7 ++++++-
 include/net/pkt_sched.h   |    4 +---
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 488c56e..dc76e4b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -271,6 +271,7 @@ struct header_ops {
 
 enum netdev_state_t
 {
+	__LINK_STATE_XOFF,
 	__LINK_STATE_START,
 	__LINK_STATE_PRESENT,
 	__LINK_STATE_NOCARRIER,
@@ -1043,6 +1044,7 @@ static inline void netif_tx_wake_queue(struct netdev_queue *dev_queue)
 static inline void netif_wake_queue(struct net_device *dev)
 {
 	netif_tx_wake_queue(netdev_get_tx_queue(dev, 0));
+	clear_bit(__LINK_STATE_XOFF, &dev->state);
 }
 
 static inline void netif_tx_wake_all_queues(struct net_device *dev)
@@ -1053,6 +1055,7 @@ static inline void netif_tx_wake_all_queues(struct net_device *dev)
 		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
 		netif_tx_wake_queue(txq);
 	}
+	clear_bit(__LINK_STATE_XOFF, &dev->state);
 }
 
 static inline void netif_tx_stop_queue(struct netdev_queue *dev_queue)
@@ -1069,6 +1072,7 @@ static inline void netif_tx_stop_queue(struct netdev_queue *dev_queue)
  */
 static inline void netif_stop_queue(struct net_device *dev)
 {
+	set_bit(__LINK_STATE_XOFF, &dev->state);
 	netif_tx_stop_queue(netdev_get_tx_queue(dev, 0));
 }
 
@@ -1076,6 +1080,7 @@ static inline void netif_tx_stop_all_queues(struct net_device *dev)
 {
 	unsigned int i;
 
+	set_bit(__LINK_STATE_XOFF, &dev->state);
 	for (i = 0; i < dev->num_tx_queues; i++) {
 		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
 		netif_tx_stop_queue(txq);
@@ -1095,7 +1100,7 @@ static inline int netif_tx_queue_stopped(const struct netdev_queue *dev_queue)
  */
 static inline int netif_queue_stopped(const struct net_device *dev)
 {
-	return netif_tx_queue_stopped(netdev_get_tx_queue(dev, 0));
+	return test_bit(__LINK_STATE_XOFF, &dev->state);
 }
 
 static inline int netif_tx_queue_frozen(const struct netdev_queue *dev_queue)
diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index b786a5b..1718a60 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -90,9 +90,7 @@ extern void __qdisc_run(struct Qdisc *q);
 
 static inline void qdisc_run(struct Qdisc *q)
 {
-	struct netdev_queue *txq = q->dev_queue;
-
-	if (!netif_tx_queue_stopped(txq) &&
+	if (!netif_queue_stopped(qdisc_dev(q)) &&
 	    !test_and_set_bit(__QDISC_STATE_RUNNING, &q->state))
 		__qdisc_run(q);
 }
--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

