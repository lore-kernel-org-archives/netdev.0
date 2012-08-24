From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH net-next 11/15] qlcnic: 83xx adpater ethtool
Date: Thu, 23 Aug 2012 21:07:15 -0400
Message-ID: <1345770439-30517-12-git-send-email-sony.chacko@qlogic.com>
References: <1345770439-30517-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:46652 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754893Ab2HXBYP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 21:24:15 -0400
In-Reply-To: <1345770439-30517-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

83xx ethtool interface routines

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |  341 +++++++++++++++++++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h    |    4 -
 2 files changed, 325 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index fa9e25e..1f21c39 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -23,6 +23,10 @@ struct qlcnic_stats {
 #define QLC_SIZEOF(m) FIELD_SIZEOF(struct qlcnic_adapter, m)
 #define QLC_OFF(m) offsetof(struct qlcnic_adapter, m)
 
+
+static const u32 qlcnic_fw_dump_level[] = {
+	0x3, 0x7, 0xf, 0x1f, 0x3f, 0x7f, 0xff};
+
 static const struct qlcnic_stats qlcnic_gstrings_stats[] = {
 	{"xmit_called",
 		QLC_SIZEOF(stats.xmitcalled), QLC_OFF(stats.xmitcalled)},
@@ -78,13 +82,84 @@ static const char qlcnic_device_gstrings_stats[][ETH_GSTRING_LEN] = {
 	"tx numbytes",
 };
 
+static const char qlc_83xx_tx_stats_strings[][ETH_GSTRING_LEN] = {
+	"ctx_tx_bytes",
+	"ctx_tx_pkts",
+	"ctx_tx_errors",
+	"ctx_tx_dropped_pkts",
+	"ctx_tx_num_buffers",
+};
+
+static const char qlc_83xx_mac_stats_strings[][ETH_GSTRING_LEN] = {
+	"mac_tx_frames",
+	"mac_tx_bytes",
+	"mac_tx_mcast_pkts",
+	"mac_tx_bcast_pkts",
+	"mac_tx_pause_cnt",
+	"mac_tx_ctrl_pkt",
+	"mac_tx_lt_64b_pkts",
+	"mac_tx_lt_127b_pkts",
+	"mac_tx_lt_255b_pkts",
+	"mac_tx_lt_511b_pkts",
+	"mac_tx_lt_1023b_pkts",
+	"mac_tx_lt_1518b_pkts",
+	"mac_tx_gt_1518b_pkts",
+	"mac_rx_frames",
+	"mac_rx_bytes",
+	"mac_rx_mcast_pkts",
+	"mac_rx_bcast_pkts",
+	"mac_rx_pause_cnt",
+	"mac_rx_ctrl_pkt",
+	"mac_rx_lt_64b_pkts",
+	"mac_rx_lt_127b_pkts",
+	"mac_rx_lt_255b_pkts",
+	"mac_rx_lt_511b_pkts",
+	"mac_rx_lt_1023b_pkts",
+	"mac_rx_lt_1518b_pkts",
+	"mac_rx_gt_1518b_pkts",
+	"mac_rx_length_error",
+	"mac_rx_length_small",
+	"mac_rx_length_large",
+	"mac_rx_jabber",
+	"mac_rx_dropped",
+	"mac_crc_error",
+	"mac_align_error",
+};
+
+static const char qlc_83xx_rx_stats_strings[][ETH_GSTRING_LEN] = {
+	"ctx_rx_bytes",
+	"ctx_rx_pkts",
+	"ctx_lro_pkt_cnt",
+	"ctx_ip_csum_error",
+	"ctx_rx_pkts_wo_ctx",
+	"ctx_rx_pkts_dropped_wo_sts",
+	"ctx_rx_osized_pkts",
+	"ctx_rx_pkts_dropped_wo_rds",
+	"ctx_rx_unexpected_mcast_pkts",
+	"ctx_invalid_mac_address",
+	"ctx_rx_rds_ring_prim_attemoted",
+	"ctx_rx_rds_ring_prim_success",
+	"ctx_num_lro_flows_added",
+	"ctx_num_lro_flows_removed",
+	"ctx_num_lro_flows_active",
+	"ctx_pkts_dropped_unknown",
+};
 
 #define QLCNIC_STATS_LEN ARRAY_SIZE(qlcnic_gstrings_stats)
-#define QLCNIC_82XX_STATS QLCNIC_STATS_LEN
-#define QLCNIC_DEVICE_STATS_LEN(adapter)	\
-	ARRAY_SIZE(qlcnic_device_gstrings_stats)
+#define QLCNIC_83XX_STATS (ARRAY_SIZE(qlc_83xx_tx_stats_strings)	\
+			+ ARRAY_SIZE(qlc_83xx_mac_stats_strings)	\
+			+ ARRAY_SIZE(qlc_83xx_rx_stats_strings))
 
+#define QLCNIC_82XX_STATS (QLCNIC_STATS_LEN \
+			+ ARRAY_SIZE(qlc_83xx_mac_stats_strings))
 
+#define QLCNIC_DEVICE_STATS_LEN(adapter)	\
+	(QLCNIC_IS_83XX(adapter) ?	\
+	QLCNIC_83XX_STATS :\
+	(ARRAY_SIZE(qlc_83xx_mac_stats_strings)	\
+	+ ARRAY_SIZE(qlcnic_device_gstrings_stats)))
+
+#define QLCNIC_STATS_LEN ARRAY_SIZE(qlcnic_gstrings_stats)
 
 static const char qlcnic_gstrings_test[][ETH_GSTRING_LEN] = {
 	"Register_Test_on_offline",
@@ -131,9 +206,13 @@ static const u32 ext_diag_registers[] = {
 
 static int qlcnic_get_regs_len(struct net_device *dev)
 {
+	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	u32 len;
 
-	len = sizeof(ext_diag_registers) + sizeof(diag_registers);
+	if (QLCNIC_IS_83XX(adapter))
+		len = qlcnic_83xx_get_regs_len(adapter);
+	else
+		len = sizeof(ext_diag_registers) + sizeof(diag_registers);
 
 	return QLCNIC_RING_REGS_LEN + len + QLCNIC_DEV_INFO_SIZE + 1;
 }
@@ -189,8 +268,11 @@ qlcnic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 
 	} else if (ahw->port_type == QLCNIC_XGBE) {
 		u32 val = 0;
-		val = QLCRD32(adapter, QLCNIC_PORT_MODE_ADDR, &err);
-
+		if (QLCNIC_IS_83XX(adapter)) {
+			qlcnic_83xx_get_settings(adapter);
+		} else {
+			val = QLCRD32(adapter, QLCNIC_PORT_MODE_ADDR, &err);
+		}
 		if (val == QLCNIC_PORT_MODE_802_3_AP) {
 			ecmd->supported = SUPPORTED_1000baseT_Full;
 			ecmd->advertising = ADVERTISED_1000baseT_Full;
@@ -273,6 +355,13 @@ skip:
 			ecmd->port = PORT_TP;
 		}
 		break;
+	case QLCNIC_BRDTYPE_83XX_10G:
+		ecmd->autoneg = AUTONEG_DISABLE;
+		ecmd->supported |= (SUPPORTED_FIBRE | SUPPORTED_TP);
+		ecmd->advertising |= (ADVERTISED_FIBRE | ADVERTISED_TP);
+		ecmd->port = PORT_FIBRE;
+		check_sfp_module = netif_running(dev) && ahw->has_link_events;
+		break;
 	default:
 		dev_err(&adapter->pdev->dev, "Unsupported board model %d\n",
 			ahw->board_type);
@@ -344,7 +433,10 @@ qlcnic_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	if (adapter->ahw->port_type != QLCNIC_GBE)
 		return -EOPNOTSUPP;
 
-	ret = qlcnic_set_port_config(adapter, ecmd);
+	if (QLCNIC_IS_83XX(adapter))
+		ret = qlcnic_83xx_set_settings(adapter, ecmd);
+	else
+		ret = qlcnic_set_port_config(adapter, ecmd);
 
 	if (!ret)
 		return ret;
@@ -394,6 +486,8 @@ qlcnic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
 
 	if (QLCNIC_IS_82XX(adapter))
 		i = qlcnic_get_registers(adapter, regs_buff);
+	else
+		i = qlcnic_83xx_get_registers(adapter, regs_buff);
 
 	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state))
 		return;
@@ -422,6 +516,10 @@ static u32 qlcnic_test_link(struct net_device *dev)
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	u32 val;
 
+	if (QLCNIC_IS_83XX(adapter)) {
+		val = qlcnic_83xx_test_link(adapter);
+		return (val & 1) ? 0 : 1;
+	}
 	val = QLCRD32(adapter, CRB_XG_STATE_P3P, &err);
 	val = XG_LINK_STATE_P3P(adapter->ahw->pci_func, val);
 	return (val == XG_LINK_UP_P3P) ? 0 : 1;
@@ -435,6 +533,8 @@ qlcnic_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 	int offset;
 	int ret = -1;
 
+	if (QLCNIC_IS_83XX(adapter))
+		return 0;
 	if (eeprom->len == 0)
 		return -EINVAL;
 
@@ -523,6 +623,10 @@ qlcnic_get_pauseparam(struct net_device *netdev,
 	int port = adapter->ahw->physical_port;
 	__u32 val;
 
+	if (QLCNIC_IS_83XX(adapter)) {
+		qlcnic_83xx_get_pauseparam(adapter, pause);
+		return;
+	}
 	if (ahw->port_type == QLCNIC_GBE) {
 		if ((port < 0) || (port > QLCNIC_NIU_MAX_GBE_PORTS))
 			return;
@@ -569,6 +673,8 @@ qlcnic_set_pauseparam(struct net_device *netdev,
 	int err, port = adapter->ahw->physical_port;
 	__u32 val;
 
+	if (QLCNIC_IS_83XX(adapter))
+		return qlcnic_83xx_set_pauseparam(adapter, pause);
 
 	/* read mode */
 	if (ahw->port_type == QLCNIC_GBE) {
@@ -646,6 +752,8 @@ static int qlcnic_reg_test(struct net_device *dev)
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	u32 data_read;
 
+	if (QLCNIC_IS_83XX(adapter))
+		return qlcnic_83xx_reg_test(adapter);
 
 	data_read = QLCRD32(adapter, QLCNIC_PCIX_PH_REG(0), &err);
 	if ((data_read & 0xffff) != adapter->pdev->vendor)
@@ -656,14 +764,26 @@ static int qlcnic_reg_test(struct net_device *dev)
 
 static int qlcnic_eeprom_test(struct net_device *dev)
 {
+	struct qlcnic_adapter *adapter = netdev_priv(dev);
+
+	if (QLCNIC_IS_82XX(adapter))
 		return 0;
+
+	return qlcnic_83xx_flash_test(adapter);
 }
 
 static int qlcnic_get_sset_count(struct net_device *dev, int sset)
 {
+	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	switch (sset) {
 	case ETH_SS_TEST:
 		return QLCNIC_TEST_LEN;
+	case ETH_SS_STATS:
+		if ((adapter->flags & QLCNIC_ESWITCH_ENABLED) ||
+			QLCNIC_IS_83XX(adapter))
+			return QLCNIC_STATS_LEN +
+				QLCNIC_DEVICE_STATS_LEN(adapter);
+		return QLCNIC_82XX_STATS;
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -671,7 +791,43 @@ static int qlcnic_get_sset_count(struct net_device *dev, int sset)
 
 static int qlcnic_irq_test(struct net_device *netdev)
 {
-	return 0;
+	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+	int max_sds_rings = adapter->max_sds_rings;
+	int ret;
+	struct qlcnic_cmd_args cmd;
+
+	if (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
+		return -EIO;
+
+	ret = qlcnic_diag_alloc_res(netdev, QLCNIC_INTERRUPT_TEST);
+	if (ret)
+		goto clear_it;
+
+	adapter->ahw->diag_cnt = 0;
+	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+						QLCNIC_CMD_INTRPT_TEST);
+
+	if (QLCNIC_IS_83XX(adapter)) {
+		ret = qlcnic_83xx_interrupt_test(adapter, &cmd);
+	} else {
+		cmd.req.arg[1] = cpu_to_le32(adapter->ahw->pci_func);
+		ret = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
+	}
+
+	if (ret)
+		goto done;
+
+	usleep_range(1000, 12000);
+	ret = !adapter->ahw->diag_cnt;
+
+done:
+	qlcnic_free_mbx_args(&cmd);
+	qlcnic_diag_free_res(netdev, max_sds_rings);
+
+clear_it:
+	adapter->max_sds_rings = max_sds_rings;
+	clear_bit(__QLCNIC_RESETTING, &adapter->state);
+	return ret;
 }
 
 #define QLCNIC_ILB_PKT_SIZE 64
@@ -724,7 +880,7 @@ static int qlcnic_do_lb_test(struct qlcnic_adapter *adapter, u8 mode)
 		dev_kfree_skb_any(skb);
 
 		if (!ahw->diag_cnt)
-			QLCDB(adapter, DRV,
+			netif_warn(adapter->ahw, pktdata, adapter->netdev,
 			"LB Test: packet #%d was not received\n", i + 1);
 		else
 			cnt++;
@@ -749,13 +905,17 @@ static int qlcnic_loopback_test(struct net_device *netdev, u8 mode)
 	int loop = 0;
 	int ret;
 
+	if (QLCNIC_IS_83XX(adapter))
+		goto skip_cap;
 	if (!(ahw->capabilities & QLCNIC_FW_CAPABILITY_MULTI_LOOPBACK)) {
-		dev_info(&adapter->pdev->dev,
+		netdev_err(netdev,
 				"Firmware is not loopback test capable\n");
 		return -EOPNOTSUPP;
 	}
-	QLCDB(adapter, DRV, "%s loopback test in progress\n",
-		mode == QLCNIC_ILB_MODE ? "internal" : "external");
+skip_cap:
+	netif_info(adapter->ahw, drv, netdev,
+		"%s loopback test in progress\n",
+			mode == QLCNIC_ILB_MODE ? "internal" : "external");
 	if (ahw->op_mode == QLCNIC_NON_PRIV_FUNC) {
 		dev_warn(&adapter->pdev->dev,
 			"Loopback test invalid for non privileged function\n");
@@ -774,12 +934,15 @@ static int qlcnic_loopback_test(struct net_device *netdev, u8 mode)
 	if (ret)
 		goto free_res;
 
+	if (QLCNIC_IS_83XX(adapter))
+		goto skip_fw_msg;
+
 	ahw->diag_cnt = 0;
 	do {
 		msleep(500);
 		ahw->hw_ops->process_lb_rcv_ring_diag(sds_ring);
 		if (loop++ > QLCNIC_ILB_MAX_RCV_LOOP) {
-			dev_info(&adapter->pdev->dev,
+			netdev_err(netdev,
 				"No response for loopback configure request\n");
 			ret = -QLCNIC_FW_NOT_RESPOND;
 			goto free_res;
@@ -788,6 +951,7 @@ static int qlcnic_loopback_test(struct net_device *netdev, u8 mode)
 			goto free_res;
 		}
 	} while (!QLCNIC_IS_LB_CONFIGURED(ahw->loopback_state));
+skip_fw_msg:
 	/* allowing firmware to settle before running traffic */
 	msleep(2000);
 	ret = qlcnic_do_lb_test(adapter, mode);
@@ -835,15 +999,153 @@ qlcnic_diag_test(struct net_device *dev, struct ethtool_test *eth_test,
 static void
 qlcnic_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 {
+	struct qlcnic_adapter *adapter = netdev_priv(dev);
+	int index, i, num_stats;
 
 	switch (stringset) {
 	case ETH_SS_TEST:
 		memcpy(data, *qlcnic_gstrings_test,
 		       QLCNIC_TEST_LEN * ETH_GSTRING_LEN);
 		break;
+	case ETH_SS_STATS:
+		for (index = 0; index < QLCNIC_STATS_LEN; index++) {
+			memcpy(data + index * ETH_GSTRING_LEN,
+			       qlcnic_gstrings_stats[index].stat_string,
+			       ETH_GSTRING_LEN);
+		}
+		if (QLCNIC_IS_83XX(adapter)) {
+			num_stats = ARRAY_SIZE(qlc_83xx_tx_stats_strings);
+			for (i = 0; i < num_stats; i++, index++)
+				memcpy(data + index * ETH_GSTRING_LEN,
+					qlc_83xx_tx_stats_strings[i],
+					ETH_GSTRING_LEN);
+			num_stats = ARRAY_SIZE(qlc_83xx_mac_stats_strings);
+			for (i = 0; i < num_stats; i++, index++)
+				memcpy(data + index * ETH_GSTRING_LEN,
+					qlc_83xx_mac_stats_strings[i],
+					ETH_GSTRING_LEN);
+			num_stats = ARRAY_SIZE(qlc_83xx_rx_stats_strings);
+			for (i = 0; i < num_stats; i++, index++)
+				memcpy(data + index * ETH_GSTRING_LEN,
+					qlc_83xx_rx_stats_strings[i],
+					ETH_GSTRING_LEN);
+			return;
+		} else {
+			num_stats = ARRAY_SIZE(qlc_83xx_mac_stats_strings);
+			for (i = 0; i < num_stats; i++, index++)
+				memcpy(data + index * ETH_GSTRING_LEN,
+					qlc_83xx_mac_stats_strings[i],
+					ETH_GSTRING_LEN);
+		}
+		if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED))
+			return;
+		num_stats = ARRAY_SIZE(qlcnic_device_gstrings_stats);
+		for (i = 0; i < num_stats; index++, i++) {
+			memcpy(data + index * ETH_GSTRING_LEN,
+			       qlcnic_device_gstrings_stats[i],
+			       ETH_GSTRING_LEN);
+		}
+	}
+}
+
+static void
+qlcnic_fill_stats(u64 *data, void *stats, int type)
+{
+	if (type == QLCNIC_MAC_STATS) {
+		struct qlcnic_mac_statistics *mac_stats =
+					(struct qlcnic_mac_statistics *)stats;
+		*data++ = QLCNIC_FILL_STATS(mac_stats->mac_tx_frames);
+		*data++ = QLCNIC_FILL_STATS(mac_stats->mac_tx_bytes);
+		*data++ = QLCNIC_FILL_STATS(mac_stats->mac_tx_mcast_pkts);
+		*data++ = QLCNIC_FILL_STATS(mac_stats->mac_tx_bcast_pkts);
+		*data++ = QLCNIC_FILL_STATS(mac_stats->mac_tx_pause_cnt);
+		*data++ = QLCNIC_FILL_STATS(mac_stats->mac_tx_ctrl_pkt);
+		*data++ = QLCNIC_FILL_STATS(mac_stats->mac_tx_lt_64b_pkts);
+		*data++ = QLCNIC_FILL_STATS(mac_stats->mac_tx_lt_127b_pkts);
+		*data++ = QLCNIC_FILL_STATS(mac_stats->mac_tx_lt_255b_pkts);
+		*data++ = QLCNIC_FILL_STATS(mac_stats->mac_tx_lt_511b_pkts);
+		*data++ = QLCNIC_FILL_STATS(mac_stats->mac_tx_lt_1023b_pkts);
+		*data++ = QLCNIC_FILL_STATS(mac_stats->mac_tx_lt_1518b_pkts);
+		*data++ = QLCNIC_FILL_STATS(mac_stats->mac_tx_gt_1518b_pkts);
+		*data++ = QLCNIC_FILL_STATS(mac_stats->mac_rx_frames);
+		*data++ = QLCNIC_FILL_STATS(mac_stats->mac_rx_bytes);
+		*data++ = QLCNIC_FILL_STATS(mac_stats->mac_rx_mcast_pkts);
+		*data++ = QLCNIC_FILL_STATS(mac_stats->mac_rx_bcast_pkts);
+		*data++ = QLCNIC_FILL_STATS(mac_stats->mac_rx_pause_cnt);
+		*data++ = QLCNIC_FILL_STATS(mac_stats->mac_rx_ctrl_pkt);
+		*data++ = QLCNIC_FILL_STATS(mac_stats->mac_rx_lt_64b_pkts);
+		*data++ = QLCNIC_FILL_STATS(mac_stats->mac_rx_lt_127b_pkts);
+		*data++ = QLCNIC_FILL_STATS(mac_stats->mac_rx_lt_255b_pkts);
+		*data++ = QLCNIC_FILL_STATS(mac_stats->mac_rx_lt_511b_pkts);
+		*data++ = QLCNIC_FILL_STATS(mac_stats->mac_rx_lt_1023b_pkts);
+		*data++ = QLCNIC_FILL_STATS(mac_stats->mac_rx_lt_1518b_pkts);
+		*data++ = QLCNIC_FILL_STATS(mac_stats->mac_rx_gt_1518b_pkts);
+		*data++ = QLCNIC_FILL_STATS(mac_stats->mac_rx_length_error);
+		*data++ = QLCNIC_FILL_STATS(mac_stats->mac_rx_length_small);
+		*data++ = QLCNIC_FILL_STATS(mac_stats->mac_rx_length_large);
+		*data++ = QLCNIC_FILL_STATS(mac_stats->mac_rx_jabber);
+		*data++ = QLCNIC_FILL_STATS(mac_stats->mac_rx_dropped);
+		*data++ = QLCNIC_FILL_STATS(mac_stats->mac_FCS_error);
+		*data++ = QLCNIC_FILL_STATS(mac_stats->mac_align_error);
+	} else if (type == QLCNIC_ESW_STATS) {
+		struct __qlcnic_esw_statistics *esw_stats =
+				(struct __qlcnic_esw_statistics *)stats;
+		*data++ = QLCNIC_FILL_STATS(esw_stats->unicast_frames);
+		*data++ = QLCNIC_FILL_STATS(esw_stats->multicast_frames);
+		*data++ = QLCNIC_FILL_STATS(esw_stats->broadcast_frames);
+		*data++ = QLCNIC_FILL_STATS(esw_stats->dropped_frames);
+		*data++ = QLCNIC_FILL_STATS(esw_stats->errors);
+		*data++ = QLCNIC_FILL_STATS(esw_stats->local_frames);
+		*data++ = QLCNIC_FILL_STATS(esw_stats->numbytes);
 	}
 }
 
+static void
+qlcnic_get_ethtool_stats(struct net_device *dev,
+			     struct ethtool_stats *stats, u64 *data)
+{
+	struct qlcnic_adapter *adapter = netdev_priv(dev);
+	struct qlcnic_esw_statistics port_stats;
+	struct qlcnic_mac_statistics mac_stats;
+	int index, ret, length;
+
+	length = QLCNIC_STATS_LEN;
+	for (index = 0; index < length; index++) {
+		char *p =
+		    (char *)adapter +
+		    qlcnic_gstrings_stats[index].stat_offset;
+		*data++ = (qlcnic_gstrings_stats[index].sizeof_stat ==
+		     sizeof(u64)) ? (*(u64 *)p) : ((*(u32 *)p));
+	}
+
+	if (QLCNIC_IS_83XX(adapter)) {
+		return qlcnic_83xx_get_stats(adapter, stats, data);
+	} else {
+		/* Retrieve MAC statistics from firmware */
+		memset(&mac_stats, 0, sizeof(struct qlcnic_mac_statistics));
+		qlcnic_get_mac_stats(adapter, &mac_stats);
+		qlcnic_fill_stats(data, &mac_stats, QLCNIC_MAC_STATS);
+	}
+
+	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED))
+		return;
+
+	memset(&port_stats, 0, sizeof(struct qlcnic_esw_statistics));
+	ret = qlcnic_get_port_stats(adapter, adapter->ahw->pci_func,
+			QLCNIC_QUERY_RX_COUNTER, &port_stats.rx);
+	if (ret)
+		return;
+
+	qlcnic_fill_stats(data, &port_stats.rx, QLCNIC_ESW_STATS);
+
+	ret = qlcnic_get_port_stats(adapter, adapter->ahw->pci_func,
+			QLCNIC_QUERY_TX_COUNTER, &port_stats.tx);
+	if (ret)
+		return;
+
+	qlcnic_fill_stats(data, &port_stats.tx, QLCNIC_ESW_STATS);
+}
+
 static void qlcnic_get_channels(struct net_device *dev,
 		struct ethtool_channels *channel)
 {
@@ -884,6 +1186,8 @@ qlcnic_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	u32 wol_cfg;
 
+	if (QLCNIC_IS_83XX(adapter))
+		return;
 	wol->supported = 0;
 	wol->wolopts = 0;
 
@@ -903,6 +1207,8 @@ qlcnic_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	u32 wol_cfg;
 
+	if (QLCNIC_IS_83XX(adapter))
+		return -EOPNOTSUPP;
 	if (wol->wolopts & ~WAKE_MAGIC)
 		return -EOPNOTSUPP;
 
@@ -928,6 +1234,8 @@ static int qlcnic_set_led(struct net_device *dev,
 	int max_sds_rings = adapter->max_sds_rings;
 	int err = -EIO, active = 1;
 
+	if (QLCNIC_IS_83XX(adapter))
+		return -EOPNOTSUPP;
 	if (adapter->ahw->op_mode == QLCNIC_NON_PRIV_FUNC) {
 		netdev_warn(dev, "LED test not supported for non "
 				"privilege function\n");
@@ -1196,8 +1504,8 @@ qlcnic_set_dump(struct net_device *netdev, struct ethtool_dump *val)
 			netdev_err(netdev, "FW dump not supported\n");
 			return -ENOTSUPP;
 		}
-		for (i = 0; i < ARRAY_SIZE(FW_DUMP_LEVELS); i++) {
-			if (val->flag == FW_DUMP_LEVELS[i]) {
+		for (i = 0; i < ARRAY_SIZE(qlcnic_fw_dump_level); i++) {
+			if (val->flag == qlcnic_fw_dump_level[i]) {
 				fw_dump->tmpl_hdr->drv_cap_mask =
 							val->flag;
 				netdev_info(netdev, "Driver mask changed to: 0x%x\n",
@@ -1205,7 +1513,7 @@ qlcnic_set_dump(struct net_device *netdev, struct ethtool_dump *val)
 				return 0;
 			}
 		}
-		netdev_info(netdev, "Invalid dump level: 0x%x\n", val->flag);
+		netdev_err(netdev, "Invalid dump level: 0x%x\n", val->flag);
 		return -EINVAL;
 	}
 	return 0;
@@ -1230,6 +1538,7 @@ const struct ethtool_ops qlcnic_ethtool_ops = {
 	.set_wol = qlcnic_set_wol,
 	.self_test = qlcnic_diag_test,
 	.get_strings = qlcnic_get_strings,
+	.get_ethtool_stats = qlcnic_get_ethtool_stats,
 	.get_sset_count = qlcnic_get_sset_count,
 	.get_coalesce = qlcnic_get_intr_coalesce,
 	.set_coalesce = qlcnic_set_intr_coalesce,
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
index 72615d1..8264722 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
@@ -727,10 +727,6 @@ struct qlcnic_legacy_intr_set {
 #define FLASH_ROM_WINDOW	0x42110030
 #define FLASH_ROM_DATA		0x42150000
 
-
-static const u32 FW_DUMP_LEVELS[] = {
-	0x3, 0x7, 0xf, 0x1f, 0x3f, 0x7f, 0xff };
-
 #define QLCNIC_FW_DUMP_REG1	0x00130060
 #define QLCNIC_FW_DUMP_REG2	0x001e0000
 #define QLCNIC_FLASH_SEM2_LK	0x0013C010
-- 
1.7.1
