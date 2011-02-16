From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2] bnx2x: Support for managing RX indirection table
Date: Wed, 16 Feb 2011 12:27:02 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1102161210190.31937@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, eilong@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:4162 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753861Ab1BPU1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Feb 2011 15:27:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support fetching and retrieving RX indirection table via ethtool.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/bnx2x/bnx2x.h         |    2 +
 drivers/net/bnx2x/bnx2x_ethtool.c |   56 +++++++++++++++++++++++++++++++++++++
 drivers/net/bnx2x/bnx2x_main.c    |   22 +++++++++++---
 3 files changed, 75 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index 236d79a..c0dd30d 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -1076,6 +1076,7 @@ struct bnx2x {
 	int			num_queues;
 	int			disable_tpa;
 	int			int_mode;
+	u32			*rx_indir_table;
 
 	struct tstorm_eth_mac_filter_config	mac_filters;
 #define BNX2X_ACCEPT_NONE		0x0000
@@ -1799,5 +1800,6 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 BNX2X_EXTERN int load_count[2][3]; /* per path: 0-common, 1-port0, 2-port1 */
 
 extern void bnx2x_set_ethtool_ops(struct net_device *netdev);
+void bnx2x_push_indir_table(struct bnx2x *bp);
 
 #endif /* bnx2x.h */
diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
index 816fef6..8d19d12 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -2134,6 +2134,59 @@ static int bnx2x_phys_id(struct net_device *dev, u32 data)
 	return 0;
 }
 
+static int bnx2x_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *info,
+			   void *rules __always_unused)
+{
+	struct bnx2x *bp = netdev_priv(dev);
+
+	switch (info->cmd) {
+	case ETHTOOL_GRXRINGS:
+		info->data = BNX2X_NUM_ETH_QUEUES(bp);
+		return 0;
+
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static int bnx2x_get_rxfh_indir(struct net_device *dev,
+				struct ethtool_rxfh_indir *indir)
+{
+	struct bnx2x *bp = netdev_priv(dev);
+	size_t copy_size =
+		min_t(size_t, indir->size, TSTORM_INDIRECTION_TABLE_SIZE);
+
+	if (bp->multi_mode == ETH_RSS_MODE_DISABLED)
+		return -EOPNOTSUPP;
+
+	indir->size = TSTORM_INDIRECTION_TABLE_SIZE;
+	memcpy(indir->ring_index, bp->rx_indir_table,
+	       copy_size * sizeof(bp->rx_indir_table[0]));
+	return 0;
+}
+
+static int bnx2x_set_rxfh_indir(struct net_device *dev,
+				const struct ethtool_rxfh_indir *indir)
+{
+	struct bnx2x *bp = netdev_priv(dev);
+	size_t i;
+
+	if (bp->multi_mode == ETH_RSS_MODE_DISABLED)
+		return -EOPNOTSUPP;
+
+	/* Validate size and indices */
+	if (indir->size != TSTORM_INDIRECTION_TABLE_SIZE)
+		return -EINVAL;
+	for (i = 0; i < TSTORM_INDIRECTION_TABLE_SIZE; i++)
+		if (indir->ring_index[i] >= BNX2X_NUM_ETH_QUEUES(bp))
+			return -EINVAL;
+
+	memcpy(bp->rx_indir_table, indir->ring_index,
+	       indir->size * sizeof(bp->rx_indir_table[0]));
+	bnx2x_push_indir_table(bp);
+	return 0;
+}
+
 static const struct ethtool_ops bnx2x_ethtool_ops = {
 	.get_settings		= bnx2x_get_settings,
 	.set_settings		= bnx2x_set_settings,
@@ -2170,6 +2223,9 @@ static const struct ethtool_ops bnx2x_ethtool_ops = {
 	.get_strings		= bnx2x_get_strings,
 	.phys_id		= bnx2x_phys_id,
 	.get_ethtool_stats	= bnx2x_get_ethtool_stats,
+	.get_rxnfc		= bnx2x_get_rxnfc,
+	.get_rxfh_indir		= bnx2x_get_rxfh_indir,
+	.set_rxfh_indir		= bnx2x_set_rxfh_indir,
 };
 
 void bnx2x_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index c238c4d..6c7745e 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -4254,7 +4254,7 @@ static void bnx2x_init_eq_ring(struct bnx2x *bp)
 		min_t(int, MAX_SP_DESC_CNT - MAX_SPQ_PENDING, NUM_EQ_DESC) - 1);
 }
 
-static void bnx2x_init_ind_table(struct bnx2x *bp)
+void bnx2x_push_indir_table(struct bnx2x *bp)
 {
 	int func = BP_FUNC(bp);
 	int i;
@@ -4262,13 +4262,20 @@ static void bnx2x_init_ind_table(struct bnx2x *bp)
 	if (bp->multi_mode == ETH_RSS_MODE_DISABLED)
 		return;
 
-	DP(NETIF_MSG_IFUP,
-	   "Initializing indirection table  multi_mode %d\n", bp->multi_mode);
 	for (i = 0; i < TSTORM_INDIRECTION_TABLE_SIZE; i++)
 		REG_WR8(bp, BAR_TSTRORM_INTMEM +
 			TSTORM_INDIRECTION_TABLE_OFFSET(func) + i,
-			bp->fp->cl_id + (i % (bp->num_queues -
-				NONE_ETH_CONTEXT_USE)));
+			bp->fp->cl_id + bp->rx_indir_table[i]);
+}
+
+static void bnx2x_init_ind_table(struct bnx2x *bp)
+{
+	int i;
+
+	for (i = 0; i < TSTORM_INDIRECTION_TABLE_SIZE; i++)
+		bp->rx_indir_table[i] = i % BNX2X_NUM_ETH_QUEUES(bp);
+
+	bnx2x_push_indir_table(bp);
 }
 
 void bnx2x_set_storm_rx_mode(struct bnx2x *bp)
@@ -6016,6 +6023,8 @@ void bnx2x_free_mem(struct bnx2x *bp)
 	BNX2X_PCI_FREE(bp->eq_ring, bp->eq_mapping,
 		       BCM_PAGE_SIZE * NUM_EQ_PAGES);
 
+	BNX2X_FREE(bp->rx_indir_table);
+
 #undef BNX2X_PCI_FREE
 #undef BNX2X_KFREE
 }
@@ -6146,6 +6155,9 @@ int bnx2x_alloc_mem(struct bnx2x *bp)
 	/* EQ */
 	BNX2X_PCI_ALLOC(bp->eq_ring, &bp->eq_mapping,
 			BCM_PAGE_SIZE * NUM_EQ_PAGES);
+
+	BNX2X_ALLOC(bp->rx_indir_table, sizeof(bp->rx_indir_table[0]) *
+		    TSTORM_INDIRECTION_TABLE_SIZE);
 	return 0;
 
 alloc_mem_err:
-- 
1.7.3.1

