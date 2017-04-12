From: Jie Deng <Jie.Deng1@synopsys.com>
Subject: [PATCH v2 net-next] net: dwc-xlgmac: add the initial ethtool support
Date: Wed, 12 Apr 2017 13:10:06 +0800
Message-ID: <b52830f81e6a02782fd070e2509c5cf3557d5e07.1491970570.git.jiedeng@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Jie Deng <Jie.Deng1@synopsys.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay2.synopsys.com ([198.182.60.111]:60505 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751159AbdDLFM0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 01:12:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is necessary to provide ethtool support for displaying and
modifying parameters of dwc-xlgmac.

Signed-off-by: Jie Deng <jiedeng@synopsys.com>
---
v1->v2:
	- remove begin() method which is unnecessary

 drivers/net/ethernet/synopsys/Makefile             |   3 +-
 drivers/net/ethernet/synopsys/dwc-xlgmac-common.c  |   1 +
 drivers/net/ethernet/synopsys/dwc-xlgmac-ethtool.c | 275 +++++++++++++++++++++
 drivers/net/ethernet/synopsys/dwc-xlgmac-hw.c      |   4 +-
 drivers/net/ethernet/synopsys/dwc-xlgmac-net.c     |  22 +-
 drivers/net/ethernet/synopsys/dwc-xlgmac.h         |  11 +
 6 files changed, 312 insertions(+), 4 deletions(-)
 create mode 100644 drivers/net/ethernet/synopsys/dwc-xlgmac-ethtool.c

diff --git a/drivers/net/ethernet/synopsys/Makefile b/drivers/net/ethernet/synopsys/Makefile
index c06e2eb..0ad0191 100644
--- a/drivers/net/ethernet/synopsys/Makefile
+++ b/drivers/net/ethernet/synopsys/Makefile
@@ -4,6 +4,7 @@
 
 obj-$(CONFIG_DWC_XLGMAC) += dwc-xlgmac.o
 dwc-xlgmac-objs := dwc-xlgmac-net.o dwc-xlgmac-desc.o \
-		   dwc-xlgmac-hw.o dwc-xlgmac-common.o
+		   dwc-xlgmac-hw.o dwc-xlgmac-common.o \
+		   dwc-xlgmac-ethtool.o
 
 dwc-xlgmac-$(CONFIG_DWC_XLGMAC_PCI) += dwc-xlgmac-pci.o
diff --git a/drivers/net/ethernet/synopsys/dwc-xlgmac-common.c b/drivers/net/ethernet/synopsys/dwc-xlgmac-common.c
index 07def2b..d655a42 100644
--- a/drivers/net/ethernet/synopsys/dwc-xlgmac-common.c
+++ b/drivers/net/ethernet/synopsys/dwc-xlgmac-common.c
@@ -175,6 +175,7 @@ static int xlgmac_init(struct xlgmac_pdata *pdata)
 
 	/* Set device operations */
 	netdev->netdev_ops = xlgmac_get_netdev_ops();
+	netdev->ethtool_ops = xlgmac_get_ethtool_ops();
 
 	/* Set device features */
 	if (pdata->hw_feat.tso) {
diff --git a/drivers/net/ethernet/synopsys/dwc-xlgmac-ethtool.c b/drivers/net/ethernet/synopsys/dwc-xlgmac-ethtool.c
new file mode 100644
index 0000000..fde7221
--- /dev/null
+++ b/drivers/net/ethernet/synopsys/dwc-xlgmac-ethtool.c
@@ -0,0 +1,275 @@
+/* Synopsys DesignWare Core Enterprise Ethernet (XLGMAC) Driver
+ *
+ * Copyright (c) 2017 Synopsys, Inc. (www.synopsys.com)
+ *
+ * This program is dual-licensed; you may select either version 2 of
+ * the GNU General Public License ("GPL") or BSD license ("BSD").
+ *
+ * This Synopsys DWC XLGMAC software driver and associated documentation
+ * (hereinafter the "Software") is an unsupported proprietary work of
+ * Synopsys, Inc. unless otherwise expressly agreed to in writing between
+ * Synopsys and you. The Software IS NOT an item of Licensed Software or a
+ * Licensed Product under any End User Software License Agreement or
+ * Agreement for Licensed Products with Synopsys or any supplement thereto.
+ * Synopsys is a registered trademark of Synopsys, Inc. Other names included
+ * in the SOFTWARE may be the trademarks of their respective owners.
+ */
+
+#include <linux/ethtool.h>
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+
+#include "dwc-xlgmac.h"
+#include "dwc-xlgmac-reg.h"
+
+struct xlgmac_stats_desc {
+	char stat_string[ETH_GSTRING_LEN];
+	int stat_offset;
+};
+
+#define XLGMAC_STAT(str, var)					\
+	{							\
+		str,						\
+		offsetof(struct xlgmac_pdata, stats.var),	\
+	}
+
+static const struct xlgmac_stats_desc xlgmac_gstring_stats[] = {
+	/* MMC TX counters */
+	XLGMAC_STAT("tx_bytes", txoctetcount_gb),
+	XLGMAC_STAT("tx_bytes_good", txoctetcount_g),
+	XLGMAC_STAT("tx_packets", txframecount_gb),
+	XLGMAC_STAT("tx_packets_good", txframecount_g),
+	XLGMAC_STAT("tx_unicast_packets", txunicastframes_gb),
+	XLGMAC_STAT("tx_broadcast_packets", txbroadcastframes_gb),
+	XLGMAC_STAT("tx_broadcast_packets_good", txbroadcastframes_g),
+	XLGMAC_STAT("tx_multicast_packets", txmulticastframes_gb),
+	XLGMAC_STAT("tx_multicast_packets_good", txmulticastframes_g),
+	XLGMAC_STAT("tx_vlan_packets_good", txvlanframes_g),
+	XLGMAC_STAT("tx_64_byte_packets", tx64octets_gb),
+	XLGMAC_STAT("tx_65_to_127_byte_packets", tx65to127octets_gb),
+	XLGMAC_STAT("tx_128_to_255_byte_packets", tx128to255octets_gb),
+	XLGMAC_STAT("tx_256_to_511_byte_packets", tx256to511octets_gb),
+	XLGMAC_STAT("tx_512_to_1023_byte_packets", tx512to1023octets_gb),
+	XLGMAC_STAT("tx_1024_to_max_byte_packets", tx1024tomaxoctets_gb),
+	XLGMAC_STAT("tx_underflow_errors", txunderflowerror),
+	XLGMAC_STAT("tx_pause_frames", txpauseframes),
+
+	/* MMC RX counters */
+	XLGMAC_STAT("rx_bytes", rxoctetcount_gb),
+	XLGMAC_STAT("rx_bytes_good", rxoctetcount_g),
+	XLGMAC_STAT("rx_packets", rxframecount_gb),
+	XLGMAC_STAT("rx_unicast_packets_good", rxunicastframes_g),
+	XLGMAC_STAT("rx_broadcast_packets_good", rxbroadcastframes_g),
+	XLGMAC_STAT("rx_multicast_packets_good", rxmulticastframes_g),
+	XLGMAC_STAT("rx_vlan_packets", rxvlanframes_gb),
+	XLGMAC_STAT("rx_64_byte_packets", rx64octets_gb),
+	XLGMAC_STAT("rx_65_to_127_byte_packets", rx65to127octets_gb),
+	XLGMAC_STAT("rx_128_to_255_byte_packets", rx128to255octets_gb),
+	XLGMAC_STAT("rx_256_to_511_byte_packets", rx256to511octets_gb),
+	XLGMAC_STAT("rx_512_to_1023_byte_packets", rx512to1023octets_gb),
+	XLGMAC_STAT("rx_1024_to_max_byte_packets", rx1024tomaxoctets_gb),
+	XLGMAC_STAT("rx_undersize_packets_good", rxundersize_g),
+	XLGMAC_STAT("rx_oversize_packets_good", rxoversize_g),
+	XLGMAC_STAT("rx_crc_errors", rxcrcerror),
+	XLGMAC_STAT("rx_crc_errors_small_packets", rxrunterror),
+	XLGMAC_STAT("rx_crc_errors_giant_packets", rxjabbererror),
+	XLGMAC_STAT("rx_length_errors", rxlengtherror),
+	XLGMAC_STAT("rx_out_of_range_errors", rxoutofrangetype),
+	XLGMAC_STAT("rx_fifo_overflow_errors", rxfifooverflow),
+	XLGMAC_STAT("rx_watchdog_errors", rxwatchdogerror),
+	XLGMAC_STAT("rx_pause_frames", rxpauseframes),
+
+	/* Extra counters */
+	XLGMAC_STAT("tx_tso_packets", tx_tso_packets),
+	XLGMAC_STAT("rx_split_header_packets", rx_split_header_packets),
+	XLGMAC_STAT("tx_process_stopped", tx_process_stopped),
+	XLGMAC_STAT("rx_process_stopped", rx_process_stopped),
+	XLGMAC_STAT("tx_buffer_unavailable", tx_buffer_unavailable),
+	XLGMAC_STAT("rx_buffer_unavailable", rx_buffer_unavailable),
+	XLGMAC_STAT("fatal_bus_error", fatal_bus_error),
+	XLGMAC_STAT("tx_vlan_packets", tx_vlan_packets),
+	XLGMAC_STAT("rx_vlan_packets", rx_vlan_packets),
+	XLGMAC_STAT("napi_poll_isr", napi_poll_isr),
+	XLGMAC_STAT("napi_poll_txtimer", napi_poll_txtimer),
+};
+
+#define XLGMAC_STATS_COUNT	ARRAY_SIZE(xlgmac_gstring_stats)
+
+static void xlgmac_ethtool_get_drvinfo(struct net_device *netdev,
+				       struct ethtool_drvinfo *drvinfo)
+{
+	struct xlgmac_pdata *pdata = netdev_priv(netdev);
+	u32 ver = pdata->hw_feat.version;
+	u32 snpsver, devid, userver;
+
+	strlcpy(drvinfo->driver, pdata->drv_name, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, pdata->drv_ver, sizeof(drvinfo->version));
+	strlcpy(drvinfo->bus_info, dev_name(pdata->dev),
+		sizeof(drvinfo->bus_info));
+	/* S|SNPSVER: Synopsys-defined Version
+	 * D|DEVID: Indicates the Device family
+	 * U|USERVER: User-defined Version
+	 */
+	snpsver = XLGMAC_GET_REG_BITS(ver, MAC_VR_SNPSVER_POS,
+				      MAC_VR_SNPSVER_LEN);
+	devid = XLGMAC_GET_REG_BITS(ver, MAC_VR_DEVID_POS,
+				    MAC_VR_DEVID_LEN);
+	userver = XLGMAC_GET_REG_BITS(ver, MAC_VR_USERVER_POS,
+				      MAC_VR_USERVER_LEN);
+	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version),
+		 "S.D.U: %x.%x.%x", snpsver, devid, userver);
+}
+
+static u32 xlgmac_ethtool_get_msglevel(struct net_device *netdev)
+{
+	struct xlgmac_pdata *pdata = netdev_priv(netdev);
+
+	return pdata->msg_enable;
+}
+
+static void xlgmac_ethtool_set_msglevel(struct net_device *netdev,
+					u32 msglevel)
+{
+	struct xlgmac_pdata *pdata = netdev_priv(netdev);
+
+	pdata->msg_enable = msglevel;
+}
+
+static void xlgmac_ethtool_get_channels(struct net_device *netdev,
+					struct ethtool_channels *channel)
+{
+	struct xlgmac_pdata *pdata = netdev_priv(netdev);
+
+	channel->max_rx = XLGMAC_MAX_DMA_CHANNELS;
+	channel->max_tx = XLGMAC_MAX_DMA_CHANNELS;
+	channel->rx_count = pdata->rx_q_count;
+	channel->tx_count = pdata->tx_q_count;
+}
+
+static int xlgmac_ethtool_get_coalesce(struct net_device *netdev,
+				       struct ethtool_coalesce *ec)
+{
+	struct xlgmac_pdata *pdata = netdev_priv(netdev);
+
+	memset(ec, 0, sizeof(struct ethtool_coalesce));
+	ec->rx_coalesce_usecs = pdata->rx_usecs;
+	ec->rx_max_coalesced_frames = pdata->rx_frames;
+	ec->tx_max_coalesced_frames = pdata->tx_frames;
+
+	return 0;
+}
+
+static int xlgmac_ethtool_set_coalesce(struct net_device *netdev,
+				       struct ethtool_coalesce *ec)
+{
+	struct xlgmac_pdata *pdata = netdev_priv(netdev);
+	struct xlgmac_hw_ops *hw_ops = &pdata->hw_ops;
+	unsigned int rx_frames, rx_riwt, rx_usecs;
+	unsigned int tx_frames;
+
+	/* Check for not supported parameters */
+	if ((ec->rx_coalesce_usecs_irq) || (ec->rx_max_coalesced_frames_irq) ||
+	    (ec->tx_coalesce_usecs) || (ec->tx_coalesce_usecs_high) ||
+	    (ec->tx_max_coalesced_frames_irq) || (ec->tx_coalesce_usecs_irq) ||
+	    (ec->stats_block_coalesce_usecs) ||  (ec->pkt_rate_low) ||
+	    (ec->use_adaptive_rx_coalesce) || (ec->use_adaptive_tx_coalesce) ||
+	    (ec->rx_max_coalesced_frames_low) || (ec->rx_coalesce_usecs_low) ||
+	    (ec->tx_coalesce_usecs_low) || (ec->tx_max_coalesced_frames_low) ||
+	    (ec->pkt_rate_high) || (ec->rx_coalesce_usecs_high) ||
+	    (ec->rx_max_coalesced_frames_high) ||
+	    (ec->tx_max_coalesced_frames_high) ||
+	    (ec->rate_sample_interval))
+		return -EOPNOTSUPP;
+
+	rx_usecs = ec->rx_coalesce_usecs;
+	rx_riwt = hw_ops->usec_to_riwt(pdata, rx_usecs);
+	rx_frames = ec->rx_max_coalesced_frames;
+	tx_frames = ec->tx_max_coalesced_frames;
+
+	if ((rx_riwt > XLGMAC_MAX_DMA_RIWT) ||
+	    (rx_riwt < XLGMAC_MIN_DMA_RIWT) ||
+	    (rx_frames > pdata->rx_desc_count))
+		return -EINVAL;
+
+	if (tx_frames > pdata->tx_desc_count)
+		return -EINVAL;
+
+	pdata->rx_riwt = rx_riwt;
+	pdata->rx_usecs = rx_usecs;
+	pdata->rx_frames = rx_frames;
+	hw_ops->config_rx_coalesce(pdata);
+
+	pdata->tx_frames = tx_frames;
+	hw_ops->config_tx_coalesce(pdata);
+
+	return 0;
+}
+
+static void xlgmac_ethtool_get_strings(struct net_device *netdev,
+				       u32 stringset, u8 *data)
+{
+	int i;
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		for (i = 0; i < XLGMAC_STATS_COUNT; i++) {
+			memcpy(data, xlgmac_gstring_stats[i].stat_string,
+			       ETH_GSTRING_LEN);
+			data += ETH_GSTRING_LEN;
+		}
+		break;
+	default:
+		WARN_ON(1);
+		break;
+	}
+}
+
+static int xlgmac_ethtool_get_sset_count(struct net_device *netdev,
+					 int stringset)
+{
+	int ret;
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		ret = XLGMAC_STATS_COUNT;
+		break;
+
+	default:
+		ret = -EOPNOTSUPP;
+	}
+
+	return ret;
+}
+
+static void xlgmac_ethtool_get_ethtool_stats(struct net_device *netdev,
+					     struct ethtool_stats *stats,
+					     u64 *data)
+{
+	struct xlgmac_pdata *pdata = netdev_priv(netdev);
+	u8 *stat;
+	int i;
+
+	pdata->hw_ops.read_mmc_stats(pdata);
+	for (i = 0; i < XLGMAC_STATS_COUNT; i++) {
+		stat = (u8 *)pdata + xlgmac_gstring_stats[i].stat_offset;
+		*data++ = *(u64 *)stat;
+	}
+}
+
+static const struct ethtool_ops xlgmac_ethtool_ops = {
+	.get_drvinfo = xlgmac_ethtool_get_drvinfo,
+	.get_link = ethtool_op_get_link,
+	.get_msglevel = xlgmac_ethtool_get_msglevel,
+	.set_msglevel = xlgmac_ethtool_set_msglevel,
+	.get_channels = xlgmac_ethtool_get_channels,
+	.get_coalesce = xlgmac_ethtool_get_coalesce,
+	.set_coalesce = xlgmac_ethtool_set_coalesce,
+	.get_strings = xlgmac_ethtool_get_strings,
+	.get_sset_count = xlgmac_ethtool_get_sset_count,
+	.get_ethtool_stats = xlgmac_ethtool_get_ethtool_stats,
+};
+
+const struct ethtool_ops *xlgmac_get_ethtool_ops(void)
+{
+	return &xlgmac_ethtool_ops;
+}
diff --git a/drivers/net/ethernet/synopsys/dwc-xlgmac-hw.c b/drivers/net/ethernet/synopsys/dwc-xlgmac-hw.c
index 0dec1dc..458a784 100644
--- a/drivers/net/ethernet/synopsys/dwc-xlgmac-hw.c
+++ b/drivers/net/ethernet/synopsys/dwc-xlgmac-hw.c
@@ -835,12 +835,14 @@ static void xlgmac_dev_xmit(struct xlgmac_channel *channel)
 				desc_data->skb_dma_len);
 
 	/* VLAN tag insertion check */
-	if (vlan)
+	if (vlan) {
 		dma_desc->desc2 = XLGMAC_SET_REG_BITS_LE(
 					dma_desc->desc2,
 					TX_NORMAL_DESC2_VTIR_POS,
 					TX_NORMAL_DESC2_VTIR_LEN,
 					TX_NORMAL_DESC2_VLAN_INSERT);
+		pdata->stats.tx_vlan_packets++;
+	}
 
 	/* Timestamp enablement check */
 	if (XLGMAC_GET_REG_BITS(pkt_info->attributes,
diff --git a/drivers/net/ethernet/synopsys/dwc-xlgmac-net.c b/drivers/net/ethernet/synopsys/dwc-xlgmac-net.c
index 6acf86c..3b91257 100644
--- a/drivers/net/ethernet/synopsys/dwc-xlgmac-net.c
+++ b/drivers/net/ethernet/synopsys/dwc-xlgmac-net.c
@@ -290,19 +290,34 @@ static irqreturn_t xlgmac_isr(int irq, void *data)
 				/* Disable Tx and Rx interrupts */
 				xlgmac_disable_rx_tx_ints(pdata);
 
+				pdata->stats.napi_poll_isr++;
 				/* Turn on polling */
 				__napi_schedule_irqoff(&pdata->napi);
 			}
 		}
 
+		if (XLGMAC_GET_REG_BITS(dma_ch_isr, DMA_CH_SR_TPS_POS,
+					DMA_CH_SR_TPS_LEN))
+			pdata->stats.tx_process_stopped++;
+
+		if (XLGMAC_GET_REG_BITS(dma_ch_isr, DMA_CH_SR_RPS_POS,
+					DMA_CH_SR_RPS_LEN))
+			pdata->stats.rx_process_stopped++;
+
+		if (XLGMAC_GET_REG_BITS(dma_ch_isr, DMA_CH_SR_TBU_POS,
+					DMA_CH_SR_TBU_LEN))
+			pdata->stats.tx_buffer_unavailable++;
+
 		if (XLGMAC_GET_REG_BITS(dma_ch_isr, DMA_CH_SR_RBU_POS,
 					DMA_CH_SR_RBU_LEN))
 			pdata->stats.rx_buffer_unavailable++;
 
 		/* Restart the device on a Fatal Bus Error */
 		if (XLGMAC_GET_REG_BITS(dma_ch_isr, DMA_CH_SR_FBE_POS,
-					DMA_CH_SR_FBE_LEN))
+					DMA_CH_SR_FBE_LEN)) {
+			pdata->stats.fatal_bus_error++;
 			schedule_work(&pdata->restart_work);
+		}
 
 		/* Clear all interrupt signals */
 		writel(dma_ch_isr, XLGMAC_DMA_REG(channel, DMA_CH_SR));
@@ -357,6 +372,7 @@ static void xlgmac_tx_timer(unsigned long data)
 		else
 			xlgmac_disable_rx_tx_ints(pdata);
 
+		pdata->stats.napi_poll_txtimer++;
 		/* Turn on polling */
 		__napi_schedule(napi);
 	}
@@ -1225,9 +1241,11 @@ static int xlgmac_rx_poll(struct xlgmac_channel *channel, int budget)
 
 		if (XLGMAC_GET_REG_BITS(pkt_info->attributes,
 					RX_PACKET_ATTRIBUTES_VLAN_CTAG_POS,
-				    RX_PACKET_ATTRIBUTES_VLAN_CTAG_LEN))
+				    RX_PACKET_ATTRIBUTES_VLAN_CTAG_LEN)) {
 			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
 					       pkt_info->vlan_ctag);
+			pdata->stats.rx_vlan_packets++;
+		}
 
 		if (XLGMAC_GET_REG_BITS(pkt_info->attributes,
 					RX_PACKET_ATTRIBUTES_RSS_HASH_POS,
diff --git a/drivers/net/ethernet/synopsys/dwc-xlgmac.h b/drivers/net/ethernet/synopsys/dwc-xlgmac.h
index 676b2fb8..cab3e40 100644
--- a/drivers/net/ethernet/synopsys/dwc-xlgmac.h
+++ b/drivers/net/ethernet/synopsys/dwc-xlgmac.h
@@ -67,6 +67,8 @@
 #define XLGMAC_INIT_DMA_TX_FRAMES	25
 #define XLGMAC_INIT_DMA_RX_USECS	30
 #define XLGMAC_INIT_DMA_RX_FRAMES	25
+#define XLGMAC_MAX_DMA_RIWT		0xff
+#define XLGMAC_MIN_DMA_RIWT		0x01
 
 /* Flow control queue count */
 #define XLGMAC_MAX_FLOW_CONTROL_QUEUES	8
@@ -190,7 +192,15 @@ struct xlgmac_stats {
 	/* Extra counters */
 	u64 tx_tso_packets;
 	u64 rx_split_header_packets;
+	u64 tx_process_stopped;
+	u64 rx_process_stopped;
+	u64 tx_buffer_unavailable;
 	u64 rx_buffer_unavailable;
+	u64 fatal_bus_error;
+	u64 tx_vlan_packets;
+	u64 rx_vlan_packets;
+	u64 napi_poll_isr;
+	u64 napi_poll_txtimer;
 };
 
 struct xlgmac_ring_buf {
@@ -622,6 +632,7 @@ struct xlgmac_pdata {
 void xlgmac_init_desc_ops(struct xlgmac_desc_ops *desc_ops);
 void xlgmac_init_hw_ops(struct xlgmac_hw_ops *hw_ops);
 const struct net_device_ops *xlgmac_get_netdev_ops(void);
+const struct ethtool_ops *xlgmac_get_ethtool_ops(void);
 void xlgmac_dump_tx_desc(struct xlgmac_pdata *pdata,
 			 struct xlgmac_ring *ring,
 			 unsigned int idx,
-- 
1.9.1
