From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 5/8] net: ethernet: annapurna: add statistics helper
Date: Fri,  3 Feb 2017 19:12:13 +0100
Message-ID: <20170203181216.30214-6-antoine.tenart@free-electrons.com>
References: <20170203181216.30214-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        tsahee@annapurnalabs.com, rshitrit@annapurnalabs.com,
        saeed@annapurnalabs.com, barak@annapurnalabs.com,
        talz@annapurnalabs.com, thomas.petazzoni@free-electrons.com,
        arnd@arndb.de
To: netdev@vger.kernel.org, davem@davemloft.net,
        linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:36475 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750996AbdBCSPJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 13:15:09 -0500
In-Reply-To: <20170203181216.30214-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the ndo_get_stats64() helper in the Annapurna Labs Alpine Ethernet
driver.
---
 drivers/net/ethernet/annapurna/al_eth.c         |  36 ++++
 drivers/net/ethernet/annapurna/al_hw_eth.h      |   9 +
 drivers/net/ethernet/annapurna/al_hw_eth_main.c | 225 ++++++++++++++++++++++++
 3 files changed, 270 insertions(+)

diff --git a/drivers/net/ethernet/annapurna/al_eth.c b/drivers/net/ethernet/annapurna/al_eth.c
index 779a885de014..8dd84f66b5d1 100644
--- a/drivers/net/ethernet/annapurna/al_eth.c
+++ b/drivers/net/ethernet/annapurna/al_eth.c
@@ -2388,6 +2388,41 @@ static void al_eth_set_msglevel(struct net_device *netdev, u32 value)
 	adapter->msg_enable = value;
 }
 
+static void al_eth_get_stats64(struct net_device *netdev,
+			       struct rtnl_link_stats64 *stats)
+{
+	struct al_eth_adapter *adapter = netdev_priv(netdev);
+	struct al_eth_mac_stats *mac_stats = &adapter->mac_stats;
+
+	if (!adapter->up)
+		return NULL;
+
+	al_eth_mac_stats_get(&adapter->hw_adapter, mac_stats);
+
+	stats->rx_packets = mac_stats->aFramesReceivedOK; /* including pause frames */
+	stats->tx_packets = mac_stats->aFramesTransmittedOK; /* including pause frames */
+	stats->rx_bytes = mac_stats->aOctetsReceivedOK;
+	stats->tx_bytes = mac_stats->aOctetsTransmittedOK;
+	stats->rx_dropped = 0;
+	stats->multicast = mac_stats->ifInMulticastPkts;
+	stats->collisions = 0;
+
+	stats->rx_length_errors = (mac_stats->etherStatsUndersizePkts + /* good but short */
+				   mac_stats->etherStatsFragments + /* short and bad*/
+				   mac_stats->etherStatsJabbers + /* with crc errors */
+				   mac_stats->etherStatsOversizePkts);
+	stats->rx_crc_errors = mac_stats->aFrameCheckSequenceErrors;
+	stats->rx_frame_errors = mac_stats->aAlignmentErrors;
+	stats->rx_fifo_errors = mac_stats->etherStatsDropEvents;
+	stats->rx_missed_errors = 0;
+	stats->tx_window_errors = 0;
+
+	stats->rx_errors = mac_stats->ifInErrors;
+	stats->tx_errors = mac_stats->ifOutErrors;
+
+	return stats;
+}
+
 static void al_eth_get_drvinfo(struct net_device *dev,
 			       struct ethtool_drvinfo *info)
 {
@@ -2763,6 +2798,7 @@ static const struct net_device_ops al_eth_netdev_ops = {
 	.ndo_stop		= al_eth_close,
 	.ndo_start_xmit		= al_eth_start_xmit,
 	.ndo_select_queue	= al_eth_select_queue,
+	.ndo_get_stats64	= al_eth_get_stats64,
 	.ndo_do_ioctl		= al_eth_ioctl,
 	.ndo_tx_timeout		= al_eth_tx_timeout,
 	.ndo_change_mtu		= al_eth_change_mtu,
diff --git a/drivers/net/ethernet/annapurna/al_hw_eth.h b/drivers/net/ethernet/annapurna/al_hw_eth.h
index b2fc58793b3a..a44f3f200838 100644
--- a/drivers/net/ethernet/annapurna/al_hw_eth.h
+++ b/drivers/net/ethernet/annapurna/al_hw_eth.h
@@ -982,6 +982,15 @@ struct al_eth_mac_stats {
 };
 
 /*
+ * get mac statistics
+ * @param adapter pointer to the private structure.
+ * @param stats pointer to structure that will be filled with statistics.
+ *
+ * @return return 0 on success. otherwise on failure.
+ */
+int al_eth_mac_stats_get(struct al_hw_eth_adapter *adapter, struct al_eth_mac_stats *stats);
+
+/*
  * perform Function Level Reset RMN
  *
  * Addressing RMN: 714
diff --git a/drivers/net/ethernet/annapurna/al_hw_eth_main.c b/drivers/net/ethernet/annapurna/al_hw_eth_main.c
index abb9ffd09fbf..dac0c1e2a941 100644
--- a/drivers/net/ethernet/annapurna/al_hw_eth_main.c
+++ b/drivers/net/ethernet/annapurna/al_hw_eth_main.c
@@ -2639,6 +2639,231 @@ int al_eth_flow_control_config(struct al_hw_eth_adapter *adapter,
 	return 0;
 }
 
+/* get statistics */
+int al_eth_mac_stats_get(struct al_hw_eth_adapter *adapter, struct al_eth_mac_stats *stats)
+{
+	WARN_ON(!stats);
+
+	memset(stats, 0, sizeof(struct al_eth_mac_stats));
+
+	if (AL_ETH_IS_1G_MAC(adapter->mac_mode)) {
+		struct al_eth_mac_1g_stats __iomem *reg_stats =
+			&adapter->mac_regs_base->mac_1g.stats;
+
+		stats->ifInUcastPkts = readl(&reg_stats->ifInUcastPkts);
+		stats->ifInMulticastPkts = readl(&reg_stats->ifInMulticastPkts);
+		stats->ifInBroadcastPkts = readl(&reg_stats->ifInBroadcastPkts);
+		stats->etherStatsPkts = readl(&reg_stats->etherStatsPkts);
+		stats->ifOutUcastPkts = readl(&reg_stats->ifOutUcastPkts);
+		stats->ifOutMulticastPkts = readl(&reg_stats->ifOutMulticastPkts);
+		stats->ifOutBroadcastPkts = readl(&reg_stats->ifOutBroadcastPkts);
+		stats->ifInErrors = readl(&reg_stats->ifInErrors);
+		stats->ifOutErrors = readl(&reg_stats->ifOutErrors);
+		stats->aFramesReceivedOK = readl(&reg_stats->aFramesReceivedOK);
+		stats->aFramesTransmittedOK = readl(&reg_stats->aFramesTransmittedOK);
+		stats->aOctetsReceivedOK = readl(&reg_stats->aOctetsReceivedOK);
+		stats->aOctetsTransmittedOK = readl(&reg_stats->aOctetsTransmittedOK);
+		stats->etherStatsUndersizePkts = readl(&reg_stats->etherStatsUndersizePkts);
+		stats->etherStatsFragments = readl(&reg_stats->etherStatsFragments);
+		stats->etherStatsJabbers = readl(&reg_stats->etherStatsJabbers);
+		stats->etherStatsOversizePkts = readl(&reg_stats->etherStatsOversizePkts);
+		stats->aFrameCheckSequenceErrors =
+			readl(&reg_stats->aFrameCheckSequenceErrors);
+		stats->aAlignmentErrors = readl(&reg_stats->aAlignmentErrors);
+		stats->etherStatsDropEvents = readl(&reg_stats->etherStatsDropEvents);
+		stats->aPAUSEMACCtrlFramesTransmitted =
+			readl(&reg_stats->aPAUSEMACCtrlFramesTransmitted);
+		stats->aPAUSEMACCtrlFramesReceived =
+			readl(&reg_stats->aPAUSEMACCtrlFramesReceived);
+		stats->aFrameTooLongErrors = 0; /* N/A */
+		stats->aInRangeLengthErrors = 0; /* N/A */
+		stats->VLANTransmittedOK = 0; /* N/A */
+		stats->VLANReceivedOK = 0; /* N/A */
+		stats->etherStatsOctets = readl(&reg_stats->etherStatsOctets);
+		stats->etherStatsPkts64Octets = readl(&reg_stats->etherStatsPkts64Octets);
+		stats->etherStatsPkts65to127Octets =
+			readl(&reg_stats->etherStatsPkts65to127Octets);
+		stats->etherStatsPkts128to255Octets =
+			readl(&reg_stats->etherStatsPkts128to255Octets);
+		stats->etherStatsPkts256to511Octets =
+			readl(&reg_stats->etherStatsPkts256to511Octets);
+		stats->etherStatsPkts512to1023Octets =
+			readl(&reg_stats->etherStatsPkts512to1023Octets);
+		stats->etherStatsPkts1024to1518Octets =
+			readl(&reg_stats->etherStatsPkts1024to1518Octets);
+		stats->etherStatsPkts1519toX = readl(&reg_stats->etherStatsPkts1519toX);
+	} else if (AL_ETH_IS_10G_MAC(adapter->mac_mode) || AL_ETH_IS_25G_MAC(adapter->mac_mode)) {
+		if (adapter->rev_id < AL_ETH_REV_ID_3) {
+			struct al_eth_mac_10g_stats_v2 __iomem *reg_stats =
+				&adapter->mac_regs_base->mac_10g.stats.v2;
+			u64 octets;
+
+			stats->ifInUcastPkts = readl(&reg_stats->ifInUcastPkts);
+			stats->ifInMulticastPkts = readl(&reg_stats->ifInMulticastPkts);
+			stats->ifInBroadcastPkts = readl(&reg_stats->ifInBroadcastPkts);
+			stats->etherStatsPkts = readl(&reg_stats->etherStatsPkts);
+			stats->ifOutUcastPkts = readl(&reg_stats->ifOutUcastPkts);
+			stats->ifOutMulticastPkts = readl(&reg_stats->ifOutMulticastPkts);
+			stats->ifOutBroadcastPkts = readl(&reg_stats->ifOutBroadcastPkts);
+			stats->ifInErrors = readl(&reg_stats->ifInErrors);
+			stats->ifOutErrors = readl(&reg_stats->ifOutErrors);
+			stats->aFramesReceivedOK = readl(&reg_stats->aFramesReceivedOK);
+			stats->aFramesTransmittedOK = readl(&reg_stats->aFramesTransmittedOK);
+
+			/* aOctetsReceivedOK = ifInOctets - 18 * aFramesReceivedOK - 4 * VLANReceivedOK */
+			octets = readl(&reg_stats->ifInOctetsL);
+			octets |= (u64)(readl(&reg_stats->ifInOctetsH)) << 32;
+			octets -= 18 * stats->aFramesReceivedOK;
+			octets -= 4 * readl(&reg_stats->VLANReceivedOK);
+			stats->aOctetsReceivedOK = octets;
+
+			/* aOctetsTransmittedOK = ifOutOctets - 18 * aFramesTransmittedOK - 4 * VLANTransmittedOK */
+			octets = readl(&reg_stats->ifOutOctetsL);
+			octets |= (u64)(readl(&reg_stats->ifOutOctetsH)) << 32;
+			octets -= 18 * stats->aFramesTransmittedOK;
+			octets -= 4 * readl(&reg_stats->VLANTransmittedOK);
+			stats->aOctetsTransmittedOK = octets;
+
+			stats->etherStatsUndersizePkts = readl(&reg_stats->etherStatsUndersizePkts);
+			stats->etherStatsFragments = readl(&reg_stats->etherStatsFragments);
+			stats->etherStatsJabbers = readl(&reg_stats->etherStatsJabbers);
+			stats->etherStatsOversizePkts = readl(&reg_stats->etherStatsOversizePkts);
+			stats->aFrameCheckSequenceErrors = readl(&reg_stats->aFrameCheckSequenceErrors);
+			stats->aAlignmentErrors = readl(&reg_stats->aAlignmentErrors);
+			stats->etherStatsDropEvents = readl(&reg_stats->etherStatsDropEvents);
+			stats->aPAUSEMACCtrlFramesTransmitted = readl(&reg_stats->aPAUSEMACCtrlFramesTransmitted);
+			stats->aPAUSEMACCtrlFramesReceived = readl(&reg_stats->aPAUSEMACCtrlFramesReceived);
+			stats->aFrameTooLongErrors = readl(&reg_stats->aFrameTooLongErrors);
+			stats->aInRangeLengthErrors = readl(&reg_stats->aInRangeLengthErrors);
+			stats->VLANTransmittedOK = readl(&reg_stats->VLANTransmittedOK);
+			stats->VLANReceivedOK = readl(&reg_stats->VLANReceivedOK);
+			stats->etherStatsOctets = readl(&reg_stats->etherStatsOctets);
+			stats->etherStatsPkts64Octets = readl(&reg_stats->etherStatsPkts64Octets);
+			stats->etherStatsPkts65to127Octets = readl(&reg_stats->etherStatsPkts65to127Octets);
+			stats->etherStatsPkts128to255Octets = readl(&reg_stats->etherStatsPkts128to255Octets);
+			stats->etherStatsPkts256to511Octets = readl(&reg_stats->etherStatsPkts256to511Octets);
+			stats->etherStatsPkts512to1023Octets = readl(&reg_stats->etherStatsPkts512to1023Octets);
+			stats->etherStatsPkts1024to1518Octets = readl(&reg_stats->etherStatsPkts1024to1518Octets);
+			stats->etherStatsPkts1519toX = readl(&reg_stats->etherStatsPkts1519toX);
+		} else {
+			struct al_eth_mac_10g_stats_v3_rx __iomem *reg_rx_stats =
+				&adapter->mac_regs_base->mac_10g.stats.v3.rx;
+			struct al_eth_mac_10g_stats_v3_tx __iomem *reg_tx_stats =
+				&adapter->mac_regs_base->mac_10g.stats.v3.tx;
+			u64 octets;
+
+			stats->ifInUcastPkts = readl(&reg_rx_stats->ifInUcastPkts);
+			stats->ifInMulticastPkts = readl(&reg_rx_stats->ifInMulticastPkts);
+			stats->ifInBroadcastPkts = readl(&reg_rx_stats->ifInBroadcastPkts);
+			stats->etherStatsPkts = readl(&reg_rx_stats->etherStatsPkts);
+			stats->ifOutUcastPkts = readl(&reg_tx_stats->ifUcastPkts);
+			stats->ifOutMulticastPkts = readl(&reg_tx_stats->ifMulticastPkts);
+			stats->ifOutBroadcastPkts = readl(&reg_tx_stats->ifBroadcastPkts);
+			stats->ifInErrors = readl(&reg_rx_stats->ifInErrors);
+			stats->ifOutErrors = readl(&reg_tx_stats->ifOutErrors);
+			stats->aFramesReceivedOK = readl(&reg_rx_stats->FramesOK);
+			stats->aFramesTransmittedOK = readl(&reg_tx_stats->FramesOK);
+
+			/* aOctetsReceivedOK = ifInOctets - 18 * aFramesReceivedOK - 4 * VLANReceivedOK */
+			octets = readl(&reg_rx_stats->ifOctetsL);
+			octets |= (u64)(readl(&reg_rx_stats->ifOctetsH)) << 32;
+			octets -= 18 * stats->aFramesReceivedOK;
+			octets -= 4 * readl(&reg_rx_stats->VLANOK);
+			stats->aOctetsReceivedOK = octets;
+
+			/* aOctetsTransmittedOK = ifOutOctets - 18 * aFramesTransmittedOK - 4 * VLANTransmittedOK */
+			octets = readl(&reg_tx_stats->ifOctetsL);
+			octets |= (u64)(readl(&reg_tx_stats->ifOctetsH)) << 32;
+			octets -= 18 * stats->aFramesTransmittedOK;
+			octets -= 4 * readl(&reg_tx_stats->VLANOK);
+			stats->aOctetsTransmittedOK = octets;
+
+			stats->etherStatsUndersizePkts = readl(&reg_rx_stats->etherStatsUndersizePkts);
+			stats->etherStatsFragments = readl(&reg_rx_stats->etherStatsFragments);
+			stats->etherStatsJabbers = readl(&reg_rx_stats->etherStatsJabbers);
+			stats->etherStatsOversizePkts = readl(&reg_rx_stats->etherStatsOversizePkts);
+			stats->aFrameCheckSequenceErrors = readl(&reg_rx_stats->CRCErrors);
+			stats->aAlignmentErrors = readl(&reg_rx_stats->aAlignmentErrors);
+			stats->etherStatsDropEvents = readl(&reg_rx_stats->etherStatsDropEvents);
+			stats->aPAUSEMACCtrlFramesTransmitted = readl(&reg_tx_stats->aPAUSEMACCtrlFrames);
+			stats->aPAUSEMACCtrlFramesReceived = readl(&reg_rx_stats->aPAUSEMACCtrlFrames);
+			stats->aFrameTooLongErrors = readl(&reg_rx_stats->aFrameTooLong);
+			stats->aInRangeLengthErrors = readl(&reg_rx_stats->aInRangeLengthErrors);
+			stats->VLANTransmittedOK = readl(&reg_tx_stats->VLANOK);
+			stats->VLANReceivedOK = readl(&reg_rx_stats->VLANOK);
+			stats->etherStatsOctets = readl(&reg_rx_stats->etherStatsOctets);
+			stats->etherStatsPkts64Octets = readl(&reg_rx_stats->etherStatsPkts64Octets);
+			stats->etherStatsPkts65to127Octets = readl(&reg_rx_stats->etherStatsPkts65to127Octets);
+			stats->etherStatsPkts128to255Octets = readl(&reg_rx_stats->etherStatsPkts128to255Octets);
+			stats->etherStatsPkts256to511Octets = readl(&reg_rx_stats->etherStatsPkts256to511Octets);
+			stats->etherStatsPkts512to1023Octets = readl(&reg_rx_stats->etherStatsPkts512to1023Octets);
+			stats->etherStatsPkts1024to1518Octets = readl(&reg_rx_stats->etherStatsPkts1024to1518Octets);
+			stats->etherStatsPkts1519toX = readl(&reg_rx_stats->etherStatsPkts1519toMax);
+		}
+	} else {
+		struct al_eth_mac_10g_stats_v3_rx __iomem *reg_rx_stats =
+			&adapter->mac_regs_base->mac_10g.stats.v3.rx;
+		struct al_eth_mac_10g_stats_v3_tx __iomem *reg_tx_stats =
+			&adapter->mac_regs_base->mac_10g.stats.v3.tx;
+		u64 octets;
+
+		/* 40G MAC statistics registers are the same, only read indirectly */
+		#define _40g_mac_reg_read32(field)	al_eth_40g_mac_reg_read(adapter,	\
+			((u8 *)(field)) - ((u8 *)&adapter->mac_regs_base->mac_10g))
+
+		stats->ifInUcastPkts = _40g_mac_reg_read32(&reg_rx_stats->ifInUcastPkts);
+		stats->ifInMulticastPkts = _40g_mac_reg_read32(&reg_rx_stats->ifInMulticastPkts);
+		stats->ifInBroadcastPkts = _40g_mac_reg_read32(&reg_rx_stats->ifInBroadcastPkts);
+		stats->etherStatsPkts = _40g_mac_reg_read32(&reg_rx_stats->etherStatsPkts);
+		stats->ifOutUcastPkts = _40g_mac_reg_read32(&reg_tx_stats->ifUcastPkts);
+		stats->ifOutMulticastPkts = _40g_mac_reg_read32(&reg_tx_stats->ifMulticastPkts);
+		stats->ifOutBroadcastPkts = _40g_mac_reg_read32(&reg_tx_stats->ifBroadcastPkts);
+		stats->ifInErrors = _40g_mac_reg_read32(&reg_rx_stats->ifInErrors);
+		stats->ifOutErrors = _40g_mac_reg_read32(&reg_tx_stats->ifOutErrors);
+		stats->aFramesReceivedOK = _40g_mac_reg_read32(&reg_rx_stats->FramesOK);
+		stats->aFramesTransmittedOK = _40g_mac_reg_read32(&reg_tx_stats->FramesOK);
+
+		/* aOctetsReceivedOK = ifInOctets - 18 * aFramesReceivedOK - 4 * VLANReceivedOK */
+		octets = _40g_mac_reg_read32(&reg_rx_stats->ifOctetsL);
+		octets |= (u64)(_40g_mac_reg_read32(&reg_rx_stats->ifOctetsH)) << 32;
+		octets -= 18 * stats->aFramesReceivedOK;
+		octets -= 4 * _40g_mac_reg_read32(&reg_rx_stats->VLANOK);
+		stats->aOctetsReceivedOK = octets;
+
+		/* aOctetsTransmittedOK = ifOutOctets - 18 * aFramesTransmittedOK - 4 * VLANTransmittedOK */
+		octets = _40g_mac_reg_read32(&reg_tx_stats->ifOctetsL);
+		octets |= (u64)(_40g_mac_reg_read32(&reg_tx_stats->ifOctetsH)) << 32;
+		octets -= 18 * stats->aFramesTransmittedOK;
+		octets -= 4 * _40g_mac_reg_read32(&reg_tx_stats->VLANOK);
+		stats->aOctetsTransmittedOK = octets;
+
+		stats->etherStatsUndersizePkts = _40g_mac_reg_read32(&reg_rx_stats->etherStatsUndersizePkts);
+		stats->etherStatsFragments = _40g_mac_reg_read32(&reg_rx_stats->etherStatsFragments);
+		stats->etherStatsJabbers = _40g_mac_reg_read32(&reg_rx_stats->etherStatsJabbers);
+		stats->etherStatsOversizePkts = _40g_mac_reg_read32(&reg_rx_stats->etherStatsOversizePkts);
+		stats->aFrameCheckSequenceErrors = _40g_mac_reg_read32(&reg_rx_stats->CRCErrors);
+		stats->aAlignmentErrors = _40g_mac_reg_read32(&reg_rx_stats->aAlignmentErrors);
+		stats->etherStatsDropEvents = _40g_mac_reg_read32(&reg_rx_stats->etherStatsDropEvents);
+		stats->aPAUSEMACCtrlFramesTransmitted = _40g_mac_reg_read32(&reg_tx_stats->aPAUSEMACCtrlFrames);
+		stats->aPAUSEMACCtrlFramesReceived = _40g_mac_reg_read32(&reg_rx_stats->aPAUSEMACCtrlFrames);
+		stats->aFrameTooLongErrors = _40g_mac_reg_read32(&reg_rx_stats->aFrameTooLong);
+		stats->aInRangeLengthErrors = _40g_mac_reg_read32(&reg_rx_stats->aInRangeLengthErrors);
+		stats->VLANTransmittedOK = _40g_mac_reg_read32(&reg_tx_stats->VLANOK);
+		stats->VLANReceivedOK = _40g_mac_reg_read32(&reg_rx_stats->VLANOK);
+		stats->etherStatsOctets = _40g_mac_reg_read32(&reg_rx_stats->etherStatsOctets);
+		stats->etherStatsPkts64Octets = _40g_mac_reg_read32(&reg_rx_stats->etherStatsPkts64Octets);
+		stats->etherStatsPkts65to127Octets = _40g_mac_reg_read32(&reg_rx_stats->etherStatsPkts65to127Octets);
+		stats->etherStatsPkts128to255Octets = _40g_mac_reg_read32(&reg_rx_stats->etherStatsPkts128to255Octets);
+		stats->etherStatsPkts256to511Octets = _40g_mac_reg_read32(&reg_rx_stats->etherStatsPkts256to511Octets);
+		stats->etherStatsPkts512to1023Octets = _40g_mac_reg_read32(&reg_rx_stats->etherStatsPkts512to1023Octets);
+		stats->etherStatsPkts1024to1518Octets = _40g_mac_reg_read32(&reg_rx_stats->etherStatsPkts1024to1518Octets);
+		stats->etherStatsPkts1519toX = _40g_mac_reg_read32(&reg_rx_stats->etherStatsPkts1519toMax);
+	}
+
+/*	stats->etherStatsPkts = 1; */
+	return 0;
+}
+
 /* Traffic control */
 
 int al_eth_flr_rmn(int (*pci_read_config_u32)(void *handle, int where, u32 *val),
-- 
2.11.0
