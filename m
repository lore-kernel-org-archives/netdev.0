From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH RFC net-next] net: core: Pass XPS select queue decision to skb_tx_hash
Date: Wed, 30 Mar 2016 01:24:12 +0300
Message-ID: <1459290252-4121-1-git-send-email-saeedm@mellanox.com>
Cc: Eric Dumazet <edumazet@google.com>,
	Tom Herbert <tom@herbertland.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37950 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752020AbcC2WZV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Mar 2016 18:25:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently XPS select queue decision is final and overrides/ignores all other
select queue parameters such as QoS TC, RX recording.

This patch makes get_xps_queue value as a hint for skb_tx_hash, which will decide
whether to use this hint as is or to tweak it a little to provide the correct TXQ.

This will fix bugs in cases such that TC QoS offload (tc_to_txq mapping) and XPS mapping
are configured but select queue will only respect the XPS configuration which will skip
the TC QoS queue selection and thus will not satisfy the QoS configuration.

RFC because I want to discuss how we would like the final behavior of the
__netdev_pick_tx, with this patch it goes as follows:

netdev_pick_tx(skb):
        hint = get_xps_queue
        txq = skb_tx_hash(skb, hint)

skb_tx_hash(skb, hint):
        if (skb_rx_queue_recorded(skb))
                return skb_get_rx_queue(skb);

        queue_offset = 0;
        if (dev->num_tc)
                queue_offset = tc_queue_offset[tc];

        hash = hint < 0 ? skb_get_hash(skb) : hint;
        return hash + queue_offset;

i.e: instead of blindly return the XPS decision, we pass it to skb_tx_hash which can make the final
decision for us, select queue will now respect and combine XPS and TC QoS tc_to_txq mappings.

Also there is one additional behavioral change that recorded rx queues will
now override the XPS configuration.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c |    2 +-
 include/linux/netdevice.h                  |    6 +++---
 net/core/dev.c                             |   10 ++++++----
 3 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index c0d7b72..873cf49 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -693,7 +693,7 @@ u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb,
 	u8 up = 0;
 
 	if (dev->num_tc)
-		return skb_tx_hash(dev, skb);
+		return skb_tx_hash(dev, skb, -1);
 
 	if (skb_vlan_tag_present(skb))
 		up = skb_vlan_tag_get(skb) >> VLAN_PRIO_SHIFT;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index cb0d5d0..ad81ffe 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3130,16 +3130,16 @@ static inline int netif_set_xps_queue(struct net_device *dev,
 #endif
 
 u16 __skb_tx_hash(const struct net_device *dev, struct sk_buff *skb,
-		  unsigned int num_tx_queues);
+		  unsigned int num_tx_queues, int txq_hint);
 
 /*
  * Returns a Tx hash for the given packet when dev->real_num_tx_queues is used
  * as a distribution range limit for the returned value.
  */
 static inline u16 skb_tx_hash(const struct net_device *dev,
-			      struct sk_buff *skb)
+			      struct sk_buff *skb, int txq_hint)
 {
-	return __skb_tx_hash(dev, skb, dev->real_num_tx_queues);
+	return __skb_tx_hash(dev, skb, dev->real_num_tx_queues, txq_hint);
 }
 
 /**
diff --git a/net/core/dev.c b/net/core/dev.c
index b9bcbe7..ff640b7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2394,7 +2394,7 @@ EXPORT_SYMBOL(netif_device_attach);
  * to be used as a distribution range.
  */
 u16 __skb_tx_hash(const struct net_device *dev, struct sk_buff *skb,
-		  unsigned int num_tx_queues)
+		  unsigned int num_tx_queues, int txq_hint)
 {
 	u32 hash;
 	u16 qoffset = 0;
@@ -2411,9 +2411,12 @@ u16 __skb_tx_hash(const struct net_device *dev, struct sk_buff *skb,
 		u8 tc = netdev_get_prio_tc_map(dev, skb->priority);
 		qoffset = dev->tc_to_txq[tc].offset;
 		qcount = dev->tc_to_txq[tc].count;
+		if (txq_hint >= qcount) /* This can happen when xps is configured on TC TXQs */
+			txq_hint = -1; /* recalculate TXQ hash */
 	}
 
-	return (u16) reciprocal_scale(skb_get_hash(skb), qcount) + qoffset;
+	hash = txq_hint < 0 ? reciprocal_scale(skb_get_hash(skb), qcount) : txq_hint;
+	return (u16)(hash) + qoffset;
 }
 EXPORT_SYMBOL(__skb_tx_hash);
 
@@ -3201,8 +3204,7 @@ static u16 __netdev_pick_tx(struct net_device *dev, struct sk_buff *skb)
 	if (queue_index < 0 || skb->ooo_okay ||
 	    queue_index >= dev->real_num_tx_queues) {
 		int new_index = get_xps_queue(dev, skb);
-		if (new_index < 0)
-			new_index = skb_tx_hash(dev, skb);
+		new_index = skb_tx_hash(dev, skb, new_index);
 
 		if (queue_index != new_index && sk &&
 		    sk_fullsock(sk) &&
-- 
1.7.1
