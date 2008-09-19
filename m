From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] pkt_sched: Fix TX state checking in qdisc_run()
Date: Fri, 19 Sep 2008 13:07:55 +0000
Message-ID: <20080919130755.GA13578@ff.dom.local>
References: <20080918063036.27934.91273.stgit@localhost.localdomain> <20080918194419.GA2982@ami.dom.local> <5f2db9d90809181811q74c3211fp9a099acb8e895fd4@mail.gmail.com> <20080919103225.GB9135@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:33915 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082AbYISNIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 09:08:09 -0400
Received: by fg-out-1718.google.com with SMTP id 19so560667fgg.17
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2008 06:08:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080919103225.GB9135@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


pkt_sched: Fix TX state checking in qdisc_run()

Current check wrongly uses the state of the first tx queue for all tx
queues. This patch brings back per dev __LINK_STATE_XOFF flag, which
is set when all tx queues are stopped. This check is needed in
qdisc_run() to avoid useless __netif_schedule() calls.

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
