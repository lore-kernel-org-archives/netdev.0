From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 07/12] amd-xgbe: Provide support for receive
 side scaling
Date: Tue, 4 Nov 2014 16:07:02 -0600
Message-ID: <20141104220702.24738.50593.stgit@tlendack-t1.amdoffice.net>
References: <20141104220620.24738.10070.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0144.outbound.protection.outlook.com ([157.56.110.144]:28316
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751368AbaKDWWH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2014 17:22:07 -0500
In-Reply-To: <20141104220620.24738.10070.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch provides support for receive side scaling (RSS). RSS allows
for spreading incoming network packets across the Rx queues.  When used
in conjunction with the per DMA channel interrupt support, this allows
the receive processing to be spread across multiple processors.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-common.h |   34 ++++++
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c    |  148 +++++++++++++++++++++++++++
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c    |   16 +++
 drivers/net/ethernet/amd/xgbe/xgbe-main.c   |   16 +++
 drivers/net/ethernet/amd/xgbe/xgbe.h        |   21 ++++
 5 files changed, 233 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-common.h b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
index 39bcb11..2fe8fc7 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-common.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
@@ -308,6 +308,9 @@
 #define MAC_MACA0LR			0x0304
 #define MAC_MACA1HR			0x0308
 #define MAC_MACA1LR			0x030c
+#define MAC_RSSCR			0x0c80
+#define MAC_RSSAR			0x0c88
+#define MAC_RSSDR			0x0c8c
 #define MAC_TSCR			0x0d00
 #define MAC_SSIR			0x0d04
 #define MAC_STSR			0x0d08
@@ -449,6 +452,24 @@
 #define MAC_RFCR_UP_WIDTH		1
 #define MAC_RQC0R_RXQ0EN_INDEX		0
 #define MAC_RQC0R_RXQ0EN_WIDTH		2
+#define MAC_RSSAR_ADDRT_INDEX		2
+#define MAC_RSSAR_ADDRT_WIDTH		1
+#define MAC_RSSAR_CT_INDEX		1
+#define MAC_RSSAR_CT_WIDTH		1
+#define MAC_RSSAR_OB_INDEX		0
+#define MAC_RSSAR_OB_WIDTH		1
+#define MAC_RSSAR_RSSIA_INDEX		8
+#define MAC_RSSAR_RSSIA_WIDTH		8
+#define MAC_RSSCR_IP2TE_INDEX		1
+#define MAC_RSSCR_IP2TE_WIDTH		1
+#define MAC_RSSCR_RSSE_INDEX		0
+#define MAC_RSSCR_RSSE_WIDTH		1
+#define MAC_RSSCR_TCP4TE_INDEX		2
+#define MAC_RSSCR_TCP4TE_WIDTH		1
+#define MAC_RSSCR_UDP4TE_INDEX		3
+#define MAC_RSSCR_UDP4TE_WIDTH		1
+#define MAC_RSSDR_DMCH_INDEX		0
+#define MAC_RSSDR_DMCH_WIDTH		4
 #define MAC_SSIR_SNSINC_INDEX		8
 #define MAC_SSIR_SNSINC_WIDTH		8
 #define MAC_SSIR_SSINC_INDEX		16
@@ -848,6 +869,8 @@
 #define RX_PACKET_ATTRIBUTES_CONTEXT_WIDTH	1
 #define RX_PACKET_ATTRIBUTES_RX_TSTAMP_INDEX	5
 #define RX_PACKET_ATTRIBUTES_RX_TSTAMP_WIDTH	1
+#define RX_PACKET_ATTRIBUTES_RSS_HASH_INDEX	6
+#define RX_PACKET_ATTRIBUTES_RSS_HASH_WIDTH	1
 
 #define RX_NORMAL_DESC0_OVT_INDEX		0
 #define RX_NORMAL_DESC0_OVT_WIDTH		16
@@ -865,12 +888,23 @@
 #define RX_NORMAL_DESC3_FD_WIDTH		1
 #define RX_NORMAL_DESC3_INTE_INDEX		30
 #define RX_NORMAL_DESC3_INTE_WIDTH		1
+#define RX_NORMAL_DESC3_L34T_INDEX		20
+#define RX_NORMAL_DESC3_L34T_WIDTH		4
 #define RX_NORMAL_DESC3_LD_INDEX		28
 #define RX_NORMAL_DESC3_LD_WIDTH		1
 #define RX_NORMAL_DESC3_OWN_INDEX		31
 #define RX_NORMAL_DESC3_OWN_WIDTH		1
 #define RX_NORMAL_DESC3_PL_INDEX		0
 #define RX_NORMAL_DESC3_PL_WIDTH		14
+#define RX_NORMAL_DESC3_RSV_INDEX		26
+#define RX_NORMAL_DESC3_RSV_WIDTH		1
+
+#define RX_DESC3_L34T_IPV4_TCP			1
+#define RX_DESC3_L34T_IPV4_UDP			2
+#define RX_DESC3_L34T_IPV4_ICMP			3
+#define RX_DESC3_L34T_IPV6_TCP			9
+#define RX_DESC3_L34T_IPV6_UDP			10
+#define RX_DESC3_L34T_IPV6_ICMP			11
 
 #define RX_CONTEXT_DESC3_TSA_INDEX		4
 #define RX_CONTEXT_DESC3_TSA_WIDTH		1
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index ac3d319..551794c 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -351,6 +351,127 @@ static void xgbe_config_sph_mode(struct xgbe_prv_data *pdata)
 	XGMAC_IOWRITE_BITS(pdata, MAC_RCR, HDSMS, XGBE_SPH_HDSMS_SIZE);
 }
 
+static int xgbe_write_rss_reg(struct xgbe_prv_data *pdata, unsigned int type,
+			      unsigned int index, unsigned int val)
+{
+	unsigned int wait;
+	int ret = 0;
+
+	mutex_lock(&pdata->rss_mutex);
+
+	if (XGMAC_IOREAD_BITS(pdata, MAC_RSSAR, OB)) {
+		ret = -EBUSY;
+		goto unlock;
+	}
+
+	XGMAC_IOWRITE(pdata, MAC_RSSDR, val);
+
+	XGMAC_IOWRITE_BITS(pdata, MAC_RSSAR, RSSIA, index);
+	XGMAC_IOWRITE_BITS(pdata, MAC_RSSAR, ADDRT, type);
+	XGMAC_IOWRITE_BITS(pdata, MAC_RSSAR, CT, 0);
+	XGMAC_IOWRITE_BITS(pdata, MAC_RSSAR, OB, 1);
+
+	wait = 1000;
+	while (wait--) {
+		if (!XGMAC_IOREAD_BITS(pdata, MAC_RSSAR, OB))
+			goto unlock;
+
+		usleep_range(1000, 1500);
+	}
+
+	ret = -EBUSY;
+
+unlock:
+	mutex_unlock(&pdata->rss_mutex);
+
+	return ret;
+}
+
+static int xgbe_write_rss_hash_key(struct xgbe_prv_data *pdata)
+{
+	unsigned int key_regs = sizeof(pdata->rss_key) / sizeof(u32);
+	unsigned int *key = (unsigned int *)&pdata->rss_key;
+	int ret;
+
+	while (key_regs--) {
+		ret = xgbe_write_rss_reg(pdata, XGBE_RSS_HASH_KEY_TYPE,
+					 key_regs, *key++);
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+
+static int xgbe_write_rss_lookup_table(struct xgbe_prv_data *pdata)
+{
+	unsigned int i;
+	int ret;
+
+	for (i = 0; i < ARRAY_SIZE(pdata->rss_table); i++) {
+		ret = xgbe_write_rss_reg(pdata,
+					 XGBE_RSS_LOOKUP_TABLE_TYPE, i,
+					 pdata->rss_table[i]);
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+
+static int xgbe_enable_rss(struct xgbe_prv_data *pdata)
+{
+	int ret;
+
+	if (!pdata->hw_feat.rss)
+		return -EOPNOTSUPP;
+
+	/* Program the hash key */
+	ret = xgbe_write_rss_hash_key(pdata);
+	if (ret)
+		return ret;
+
+	/* Program the lookup table */
+	ret = xgbe_write_rss_lookup_table(pdata);
+	if (ret)
+		return ret;
+
+	/* Set the RSS options */
+	XGMAC_IOWRITE(pdata, MAC_RSSCR, pdata->rss_options);
+
+	/* Enable RSS */
+	XGMAC_IOWRITE_BITS(pdata, MAC_RSSCR, RSSE, 1);
+
+	return 0;
+}
+
+static int xgbe_disable_rss(struct xgbe_prv_data *pdata)
+{
+	if (!pdata->hw_feat.rss)
+		return -EOPNOTSUPP;
+
+	XGMAC_IOWRITE_BITS(pdata, MAC_RSSCR, RSSE, 0);
+
+	return 0;
+}
+
+static void xgbe_config_rss(struct xgbe_prv_data *pdata)
+{
+	int ret;
+
+	if (!pdata->hw_feat.rss)
+		return;
+
+	if (pdata->netdev->features & NETIF_F_RXHASH)
+		ret = xgbe_enable_rss(pdata);
+	else
+		ret = xgbe_disable_rss(pdata);
+
+	if (ret)
+		netdev_err(pdata->netdev,
+			   "error configuring RSS, RSS disabled\n");
+}
+
 static int xgbe_disable_tx_flow_control(struct xgbe_prv_data *pdata)
 {
 	unsigned int max_q_count, q_count;
@@ -1408,7 +1529,7 @@ static int xgbe_dev_read(struct xgbe_channel *channel)
 	struct xgbe_ring_desc *rdesc;
 	struct xgbe_packet_data *packet = &ring->packet_data;
 	struct net_device *netdev = channel->pdata->netdev;
-	unsigned int err, etlt;
+	unsigned int err, etlt, l34t;
 
 	DBGPR("-->xgbe_dev_read: cur = %d\n", ring->cur);
 
@@ -1447,6 +1568,26 @@ static int xgbe_dev_read(struct xgbe_channel *channel)
 		rdata->hdr_len = XGMAC_GET_BITS_LE(rdesc->desc2,
 						   RX_NORMAL_DESC2, HL);
 
+	/* Get the RSS hash */
+	if (XGMAC_GET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, RSV)) {
+		XGMAC_SET_BITS(packet->attributes, RX_PACKET_ATTRIBUTES,
+			       RSS_HASH, 1);
+
+		packet->rss_hash = le32_to_cpu(rdesc->desc1);
+
+		l34t = XGMAC_GET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, L34T);
+		switch (l34t) {
+		case RX_DESC3_L34T_IPV4_TCP:
+		case RX_DESC3_L34T_IPV4_UDP:
+		case RX_DESC3_L34T_IPV6_TCP:
+		case RX_DESC3_L34T_IPV6_UDP:
+			packet->rss_hash_type = PKT_HASH_TYPE_L4;
+
+		default:
+			packet->rss_hash_type = PKT_HASH_TYPE_L3;
+		}
+	}
+
 	/* Get the packet length */
 	rdata->len = XGMAC_GET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, PL);
 
@@ -2479,6 +2620,7 @@ static int xgbe_init(struct xgbe_prv_data *pdata)
 	xgbe_config_rx_buffer_size(pdata);
 	xgbe_config_tso_mode(pdata);
 	xgbe_config_sph_mode(pdata);
+	xgbe_config_rss(pdata);
 	desc_if->wrapper_tx_desc_init(pdata);
 	desc_if->wrapper_rx_desc_init(pdata);
 	xgbe_enable_dma_interrupts(pdata);
@@ -2614,5 +2756,9 @@ void xgbe_init_function_ptrs_dev(struct xgbe_hw_if *hw_if)
 	hw_if->config_dcb_tc = xgbe_config_dcb_tc;
 	hw_if->config_dcb_pfc = xgbe_config_dcb_pfc;
 
+	/* For Receive Side Scaling */
+	hw_if->enable_rss = xgbe_enable_rss;
+	hw_if->disable_rss = xgbe_disable_rss;
+
 	DBGPR("<--xgbe_init_function_ptrs\n");
 }
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index c3533e1..6c5a707 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1661,12 +1661,21 @@ static int xgbe_set_features(struct net_device *netdev,
 {
 	struct xgbe_prv_data *pdata = netdev_priv(netdev);
 	struct xgbe_hw_if *hw_if = &pdata->hw_if;
-	netdev_features_t rxcsum, rxvlan, rxvlan_filter;
+	netdev_features_t rxhash, rxcsum, rxvlan, rxvlan_filter;
+	int ret = 0;
 
+	rxhash = pdata->netdev_features & NETIF_F_RXHASH;
 	rxcsum = pdata->netdev_features & NETIF_F_RXCSUM;
 	rxvlan = pdata->netdev_features & NETIF_F_HW_VLAN_CTAG_RX;
 	rxvlan_filter = pdata->netdev_features & NETIF_F_HW_VLAN_CTAG_FILTER;
 
+	if ((features & NETIF_F_RXHASH) && !rxhash)
+		ret = hw_if->enable_rss(pdata);
+	else if (!(features & NETIF_F_RXHASH) && rxhash)
+		ret = hw_if->disable_rss(pdata);
+	if (ret)
+		return ret;
+
 	if ((features & NETIF_F_RXCSUM) && !rxcsum)
 		hw_if->enable_rx_csum(pdata);
 	else if (!(features & NETIF_F_RXCSUM) && rxcsum)
@@ -1960,6 +1969,11 @@ read_again:
 			hwtstamps->hwtstamp = ns_to_ktime(nsec);
 		}
 
+		if (XGMAC_GET_BITS(packet->attributes,
+				   RX_PACKET_ATTRIBUTES, RSS_HASH))
+			skb_set_hash(skb, packet->rss_hash,
+				     packet->rss_hash_type);
+
 		skb->dev = netdev;
 		skb->protocol = eth_type_trans(skb, netdev);
 		skb_record_rx_queue(skb, channel->queue_index);
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index cff9902..05fbdf9 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -170,6 +170,7 @@ static int xgbe_probe(struct platform_device *pdev)
 	struct device *dev = &pdev->dev;
 	struct resource *res;
 	const u8 *mac_addr;
+	unsigned int i;
 	int ret;
 
 	DBGPR("--> xgbe_probe\n");
@@ -190,6 +191,7 @@ static int xgbe_probe(struct platform_device *pdev)
 
 	spin_lock_init(&pdata->lock);
 	mutex_init(&pdata->xpcs_mutex);
+	mutex_init(&pdata->rss_mutex);
 	spin_lock_init(&pdata->tstamp_lock);
 
 	/* Set and validate the number of descriptors for a ring */
@@ -335,6 +337,17 @@ static int xgbe_probe(struct platform_device *pdev)
 		goto err_io;
 	}
 
+	/* Initialize RSS hash key and lookup table */
+	get_random_bytes(pdata->rss_key, sizeof(pdata->rss_key));
+
+	for (i = 0; i < XGBE_RSS_MAX_TABLE_SIZE; i++)
+		XGMAC_SET_BITS(pdata->rss_table[i], MAC_RSSDR, DMCH,
+			       i % pdata->rx_ring_count);
+
+	XGMAC_SET_BITS(pdata->rss_options, MAC_RSSCR, IP2TE, 1);
+	XGMAC_SET_BITS(pdata->rss_options, MAC_RSSCR, TCP4TE, 1);
+	XGMAC_SET_BITS(pdata->rss_options, MAC_RSSCR, UDP4TE, 1);
+
 	/* Prepare to regsiter with MDIO */
 	pdata->mii_bus_id = kasprintf(GFP_KERNEL, "%s", pdev->name);
 	if (!pdata->mii_bus_id) {
@@ -365,6 +378,9 @@ static int xgbe_probe(struct platform_device *pdev)
 			      NETIF_F_HW_VLAN_CTAG_TX |
 			      NETIF_F_HW_VLAN_CTAG_FILTER;
 
+	if (pdata->hw_feat.rss)
+		netdev->hw_features |= NETIF_F_RXHASH;
+
 	netdev->vlan_features |= NETIF_F_SG |
 				 NETIF_F_IP_CSUM |
 				 NETIF_F_IPV6_CSUM |
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index 55c935f..2ac4f17 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -215,6 +215,12 @@
 /* Maximum MAC address hash table size (256 bits = 8 bytes) */
 #define XGBE_MAC_HASH_TABLE_SIZE	8
 
+/* Receive Side Scaling */
+#define XGBE_RSS_HASH_KEY_SIZE		40
+#define XGBE_RSS_MAX_TABLE_SIZE		256
+#define XGBE_RSS_LOOKUP_TABLE_TYPE	0
+#define XGBE_RSS_HASH_KEY_TYPE		1
+
 struct xgbe_prv_data;
 
 struct xgbe_packet_data {
@@ -233,6 +239,9 @@ struct xgbe_packet_data {
 	unsigned short vlan_ctag;
 
 	u64 rx_tstamp;
+
+	u32 rss_hash;
+	enum pkt_hash_types rss_hash_type;
 };
 
 /* Common Rx and Tx descriptor mapping */
@@ -544,6 +553,10 @@ struct xgbe_hw_if {
 	/* For Data Center Bridging config */
 	void (*config_dcb_tc)(struct xgbe_prv_data *);
 	void (*config_dcb_pfc)(struct xgbe_prv_data *);
+
+	/* For Receive Side Scaling */
+	int (*enable_rss)(struct xgbe_prv_data *);
+	int (*disable_rss)(struct xgbe_prv_data *);
 };
 
 struct xgbe_desc_if {
@@ -616,6 +629,9 @@ struct xgbe_prv_data {
 	/* XPCS indirect addressing mutex */
 	struct mutex xpcs_mutex;
 
+	/* RSS addressing mutex */
+	struct mutex rss_mutex;
+
 	int dev_irq;
 	unsigned int per_channel_irq;
 
@@ -668,6 +684,11 @@ struct xgbe_prv_data {
 	unsigned int tx_pause;
 	unsigned int rx_pause;
 
+	/* Receive Side Scaling settings */
+	u8 rss_key[XGBE_RSS_HASH_KEY_SIZE];
+	u32 rss_table[XGBE_RSS_MAX_TABLE_SIZE];
+	u32 rss_options;
+
 	/* MDIO settings */
 	struct module *phy_module;
 	char *mii_bus_id;
