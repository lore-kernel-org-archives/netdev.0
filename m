From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/4] net: Use bool in netdevice.h helpers.
Date: Fri, 09 Mar 2012 14:36:30 -0800 (PST)
Message-ID: <20120309.143630.1818558345333025383.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51121 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758375Ab2CIWgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2012 17:36:31 -0500
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id q29MaUiH018632
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 9 Mar 2012 14:36:30 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Specifically use it in napi_disable_pending(), napi_schedule_prep(),
napi_reschedule(), netif_tx_queue_stopped(), netif_queue_stopped(),
netif_xmit_stopped(), netif_xmit_frozen_or_stopped(), netif_running(),
__netif_subqueue_stopped(), netif_subqueue_stopped(),
netif_is_multiquue(), netif_carrier_ok(), netif_dormant(),
netif_oper_up(), netif_device_present(), __netif_tx_trylock(),
net_gso_ok(), skb_gso_ok(), netif_needs_gso(), and
netif_is_bond_slave().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |   52 ++++++++++++++++++++++----------------------
 1 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a89933b..b195a34 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -417,7 +417,7 @@ typedef rx_handler_result_t rx_handler_func_t(struct sk_buff **pskb);
 
 extern void __napi_schedule(struct napi_struct *n);
 
-static inline int napi_disable_pending(struct napi_struct *n)
+static inline bool napi_disable_pending(struct napi_struct *n)
 {
 	return test_bit(NAPI_STATE_DISABLE, &n->state);
 }
@@ -431,7 +431,7 @@ static inline int napi_disable_pending(struct napi_struct *n)
  * insure only one NAPI poll instance runs.  We also make
  * sure there is no pending NAPI disable.
  */
-static inline int napi_schedule_prep(struct napi_struct *n)
+static inline bool napi_schedule_prep(struct napi_struct *n)
 {
 	return !napi_disable_pending(n) &&
 		!test_and_set_bit(NAPI_STATE_SCHED, &n->state);
@@ -451,13 +451,13 @@ static inline void napi_schedule(struct napi_struct *n)
 }
 
 /* Try to reschedule poll. Called by dev->poll() after napi_complete().  */
-static inline int napi_reschedule(struct napi_struct *napi)
+static inline bool napi_reschedule(struct napi_struct *napi)
 {
 	if (napi_schedule_prep(napi)) {
 		__napi_schedule(napi);
-		return 1;
+		return true;
 	}
-	return 0;
+	return false;
 }
 
 /**
@@ -1868,7 +1868,7 @@ static inline void netif_tx_stop_all_queues(struct net_device *dev)
 	}
 }
 
-static inline int netif_tx_queue_stopped(const struct netdev_queue *dev_queue)
+static inline bool netif_tx_queue_stopped(const struct netdev_queue *dev_queue)
 {
 	return test_bit(__QUEUE_STATE_DRV_XOFF, &dev_queue->state);
 }
@@ -1879,17 +1879,17 @@ static inline int netif_tx_queue_stopped(const struct netdev_queue *dev_queue)
  *
  *	Test if transmit queue on device is currently unable to send.
  */
-static inline int netif_queue_stopped(const struct net_device *dev)
+static inline bool netif_queue_stopped(const struct net_device *dev)
 {
 	return netif_tx_queue_stopped(netdev_get_tx_queue(dev, 0));
 }
 
-static inline int netif_xmit_stopped(const struct netdev_queue *dev_queue)
+static inline bool netif_xmit_stopped(const struct netdev_queue *dev_queue)
 {
 	return dev_queue->state & QUEUE_STATE_ANY_XOFF;
 }
 
-static inline int netif_xmit_frozen_or_stopped(const struct netdev_queue *dev_queue)
+static inline bool netif_xmit_frozen_or_stopped(const struct netdev_queue *dev_queue)
 {
 	return dev_queue->state & QUEUE_STATE_ANY_XOFF_OR_FROZEN;
 }
@@ -1954,7 +1954,7 @@ static inline void netdev_reset_queue(struct net_device *dev_queue)
  *
  *	Test if the device has been brought up.
  */
-static inline int netif_running(const struct net_device *dev)
+static inline bool netif_running(const struct net_device *dev)
 {
 	return test_bit(__LINK_STATE_START, &dev->state);
 }
@@ -2004,16 +2004,16 @@ static inline void netif_stop_subqueue(struct net_device *dev, u16 queue_index)
  *
  * Check individual transmit queue of a device with multiple transmit queues.
  */
-static inline int __netif_subqueue_stopped(const struct net_device *dev,
-					 u16 queue_index)
+static inline bool __netif_subqueue_stopped(const struct net_device *dev,
+					    u16 queue_index)
 {
 	struct netdev_queue *txq = netdev_get_tx_queue(dev, queue_index);
 
 	return netif_tx_queue_stopped(txq);
 }
 
-static inline int netif_subqueue_stopped(const struct net_device *dev,
-					 struct sk_buff *skb)
+static inline bool netif_subqueue_stopped(const struct net_device *dev,
+					  struct sk_buff *skb)
 {
 	return __netif_subqueue_stopped(dev, skb_get_queue_mapping(skb));
 }
@@ -2052,7 +2052,7 @@ static inline u16 skb_tx_hash(const struct net_device *dev,
  *
  * Check if device has multiple transmit queues
  */
-static inline int netif_is_multiqueue(const struct net_device *dev)
+static inline bool netif_is_multiqueue(const struct net_device *dev)
 {
 	return dev->num_tx_queues > 1;
 }
@@ -2188,7 +2188,7 @@ extern void linkwatch_forget_dev(struct net_device *dev);
  *
  * Check if carrier is present on device
  */
-static inline int netif_carrier_ok(const struct net_device *dev)
+static inline bool netif_carrier_ok(const struct net_device *dev)
 {
 	return !test_bit(__LINK_STATE_NOCARRIER, &dev->state);
 }
@@ -2240,7 +2240,7 @@ static inline void netif_dormant_off(struct net_device *dev)
  *
  * Check if carrier is present on device
  */
-static inline int netif_dormant(const struct net_device *dev)
+static inline bool netif_dormant(const struct net_device *dev)
 {
 	return test_bit(__LINK_STATE_DORMANT, &dev->state);
 }
@@ -2252,7 +2252,7 @@ static inline int netif_dormant(const struct net_device *dev)
  *
  * Check if carrier is operational
  */
-static inline int netif_oper_up(const struct net_device *dev)
+static inline bool netif_oper_up(const struct net_device *dev)
 {
 	return (dev->operstate == IF_OPER_UP ||
 		dev->operstate == IF_OPER_UNKNOWN /* backward compat */);
@@ -2264,7 +2264,7 @@ static inline int netif_oper_up(const struct net_device *dev)
  *
  * Check if device has not been removed from system.
  */
-static inline int netif_device_present(struct net_device *dev)
+static inline bool netif_device_present(struct net_device *dev)
 {
 	return test_bit(__LINK_STATE_PRESENT, &dev->state);
 }
@@ -2334,9 +2334,9 @@ static inline void __netif_tx_lock_bh(struct netdev_queue *txq)
 	txq->xmit_lock_owner = smp_processor_id();
 }
 
-static inline int __netif_tx_trylock(struct netdev_queue *txq)
+static inline bool __netif_tx_trylock(struct netdev_queue *txq)
 {
-	int ok = spin_trylock(&txq->_xmit_lock);
+	bool ok = spin_trylock(&txq->_xmit_lock);
 	if (likely(ok))
 		txq->xmit_lock_owner = smp_processor_id();
 	return ok;
@@ -2614,7 +2614,7 @@ void netif_stacked_transfer_operstate(const struct net_device *rootdev,
 
 netdev_features_t netif_skb_features(struct sk_buff *skb);
 
-static inline int net_gso_ok(netdev_features_t features, int gso_type)
+static inline bool net_gso_ok(netdev_features_t features, int gso_type)
 {
 	netdev_features_t feature = gso_type << NETIF_F_GSO_SHIFT;
 
@@ -2629,14 +2629,14 @@ static inline int net_gso_ok(netdev_features_t features, int gso_type)
 	return (features & feature) == feature;
 }
 
-static inline int skb_gso_ok(struct sk_buff *skb, netdev_features_t features)
+static inline bool skb_gso_ok(struct sk_buff *skb, netdev_features_t features)
 {
 	return net_gso_ok(features, skb_shinfo(skb)->gso_type) &&
 	       (!skb_has_frag_list(skb) || (features & NETIF_F_FRAGLIST));
 }
 
-static inline int netif_needs_gso(struct sk_buff *skb,
-	netdev_features_t features)
+static inline bool netif_needs_gso(struct sk_buff *skb,
+				   netdev_features_t features)
 {
 	return skb_is_gso(skb) && (!skb_gso_ok(skb, features) ||
 		unlikely(skb->ip_summed != CHECKSUM_PARTIAL));
@@ -2648,7 +2648,7 @@ static inline void netif_set_gso_max_size(struct net_device *dev,
 	dev->gso_max_size = size;
 }
 
-static inline int netif_is_bond_slave(struct net_device *dev)
+static inline bool netif_is_bond_slave(struct net_device *dev)
 {
 	return dev->flags & IFF_SLAVE && dev->priv_flags & IFF_BONDING;
 }
-- 
1.7.6.5
