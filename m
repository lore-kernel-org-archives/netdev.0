From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH 7/8] net: support tx_ring per UP in HW based QoS mechanism
Date: Tue, 13 Mar 2012 19:22:02 +0200
Message-ID: <1331659323-12904-8-git-send-email-amirv@mellanox.com>
References: <1331659323-12904-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Roland Dreier <roland@purestorage.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@mellanox.co.il>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:48592 "HELO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758615Ab2CMRWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 13:22:31 -0400
In-Reply-To: <1331659323-12904-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.co.il>

The Current HW based QoS mechanism which was introduced in commit 4f57c087de9
"net: implement mechanism for HW based QOS" is in orientation to ETS traffic
class. This patch introduces an approach which allow to use this mechanism also
with hardware who has queues per user priority (UP). After the change,
__skb_tx_hash() will direct a flow to a tx ring from a range of tx rings. This
range is defined by the caller function by the specific HW. If TC based queues,
the range is by TC number and for UP based queues, the range is by UP.

CC: John Fastabend <john.r.fastabend@intel.com>
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Eilon Greenstein <eilong@broadcom.com>
Signed-off-by: Amir Vadai <amirv@mellanox.co.il>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |   11 ++++++++++-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c      |    9 +++------
 include/linux/netdevice.h                       |   12 +++++++++++-
 include/linux/skbuff.h                          |    3 ++-
 net/core/dev.c                                  |   10 +---------
 5 files changed, 27 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index c11e50d..614d0b2 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1422,6 +1422,8 @@ void bnx2x_netif_stop(struct bnx2x *bp, int disable_hw)
 u16 bnx2x_select_queue(struct net_device *dev, struct sk_buff *skb)
 {
 	struct bnx2x *bp = netdev_priv(dev);
+	u16 qoffset = 0;
+	u16 qcount = BNX2X_NUM_ETH_QUEUES(bp);
 
 #ifdef BCM_CNIC
 	if (!NO_FCOE(bp)) {
@@ -1441,8 +1443,15 @@ u16 bnx2x_select_queue(struct net_device *dev, struct sk_buff *skb)
 			return bnx2x_fcoe_tx(bp, txq_index);
 	}
 #endif
+	if (dev->num_tc) {
+		u8 tc = netdev_get_prio_tc_map(dev, skb->priority);
+		qoffset = dev->tc_to_txq[tc].offset;
+		qcount = dev->tc_to_txq[tc].count;
+	}
+
 	/* select a non-FCoE queue */
-	return __skb_tx_hash(dev, skb, BNX2X_NUM_ETH_QUEUES(bp));
+	return __skb_tx_hash(dev, skb, BNX2X_NUM_ETH_QUEUES(bp), qoffset,
+			qcount);
 }
 
 void bnx2x_set_num_queues(struct bnx2x *bp)
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 7a49830..d0d96e3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -570,18 +570,15 @@ static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc, struct sk_buff *sk
 
 u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb)
 {
-	struct mlx4_en_priv *priv = netdev_priv(dev);
-	int up = -1;
+	int up = 0;
 
 	if (vlan_tx_tag_present(skb))
 		up = (vlan_tx_tag_get(skb) >> 13);
 	else if (dev->num_tc)
 		up = netdev_get_prio_tc_map(dev, skb->priority);
 
-	if (up >= 0)
-		return MLX4_EN_NUM_TX_RINGS + up;
-
-	return __skb_tx_hash(dev, skb, MLX4_EN_NUM_TX_RINGS);
+	return __skb_tx_hash(dev, skb, MLX4_EN_NUM_TX_RINGS,
+			MLX4_EN_NUM_TX_RINGS + up, 1);
 }
 
 static void mlx4_bf_copy(void __iomem *dst, unsigned long *src, unsigned bytecnt)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4535a4e..952dde3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2061,7 +2061,17 @@ static inline void netif_wake_subqueue(struct net_device *dev, u16 queue_index)
 static inline u16 skb_tx_hash(const struct net_device *dev,
 			      const struct sk_buff *skb)
 {
-	return __skb_tx_hash(dev, skb, dev->real_num_tx_queues);
+	u16 qoffset = 0;
+	u16 qcount = dev->real_num_tx_queues;
+
+	if (dev->num_tc) {
+		u8 tc = netdev_get_prio_tc_map(dev, skb->priority);
+		qoffset = dev->tc_to_txq[tc].offset;
+		qcount = dev->tc_to_txq[tc].count;
+	}
+
+	return __skb_tx_hash(dev, skb, dev->real_num_tx_queues, qoffset,
+			qcount);
 }
 
 /**
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 8dc8257..14fa201 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2455,7 +2455,8 @@ static inline bool skb_rx_queue_recorded(const struct sk_buff *skb)
 
 extern u16 __skb_tx_hash(const struct net_device *dev,
 			 const struct sk_buff *skb,
-			 unsigned int num_tx_queues);
+			 unsigned int num_tx_queues,
+			 u16 qoffset, u16 qcount);
 
 #ifdef CONFIG_XFRM
 static inline struct sec_path *skb_sec_path(struct sk_buff *skb)
diff --git a/net/core/dev.c b/net/core/dev.c
index 0090809..ecbf5c1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2290,11 +2290,9 @@ static u32 hashrnd __read_mostly;
  * to be used as a distribution range.
  */
 u16 __skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb,
-		  unsigned int num_tx_queues)
+		  unsigned int num_tx_queues, u16 qoffset, u16 qcount)
 {
 	u32 hash;
-	u16 qoffset = 0;
-	u16 qcount = num_tx_queues;
 
 	if (skb_rx_queue_recorded(skb)) {
 		hash = skb_get_rx_queue(skb);
@@ -2303,12 +2301,6 @@ u16 __skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb,
 		return hash;
 	}
 
-	if (dev->num_tc) {
-		u8 tc = netdev_get_prio_tc_map(dev, skb->priority);
-		qoffset = dev->tc_to_txq[tc].offset;
-		qcount = dev->tc_to_txq[tc].count;
-	}
-
 	if (skb->sk && skb->sk->sk_hash)
 		hash = skb->sk->sk_hash;
 	else
-- 
1.7.8.2
