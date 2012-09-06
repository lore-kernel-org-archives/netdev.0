From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH 11/12] qlcnic: 83xx adpater ethtool
Date: Thu,  6 Sep 2012 02:22:08 -0400
Message-ID: <1346912529-17406-12-git-send-email-sony.chacko@qlogic.com>
References: <1346912529-17406-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:34391 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752030Ab2IFGjZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Sep 2012 02:39:25 -0400
In-Reply-To: <1346912529-17406-1-git-send-email-sony.chacko@qlogic.com>
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
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |  583 +++++++++++++-------
 1 files changed, 374 insertions(+), 209 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 4625253..b0d21ac 100644
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
@@ -78,7 +82,15 @@ static const char qlcnic_device_gstrings_stats[][ETH_GSTRING_LEN] = {
 	"tx numbytes",
 };
 
-static const char qlcnic_mac_stats_strings [][ETH_GSTRING_LEN] = {
+static const char qlcnic_83xx_tx_stats_strings[][ETH_GSTRING_LEN] = {
+	"ctx_tx_bytes",
+	"ctx_tx_pkts",
+	"ctx_tx_errors",
+	"ctx_tx_dropped_pkts",
+	"ctx_tx_num_buffers",
+};
+
+static const char qlcnic_83xx_mac_stats_strings[][ETH_GSTRING_LEN] = {
 	"mac_tx_frames",
 	"mac_tx_bytes",
 	"mac_tx_mcast_pkts",
@@ -110,21 +122,51 @@ static const char qlcnic_mac_stats_strings [][ETH_GSTRING_LEN] = {
 	"mac_rx_length_large",
 	"mac_rx_jabber",
 	"mac_rx_dropped",
-	"mac_rx_crc_error",
+	"mac_crc_error",
 	"mac_align_error",
 };
 
+static const char qlcnic_83xx_rx_stats_strings[][ETH_GSTRING_LEN] = {
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
+
+#define QLCNIC_STATS_LEN ARRAY_SIZE(qlcnic_gstrings_stats)
+#define QLC_83XX_STATS (ARRAY_SIZE(qlcnic_83xx_tx_stats_strings)	\
+			+ ARRAY_SIZE(qlcnic_83xx_mac_stats_strings)	\
+			+ ARRAY_SIZE(qlcnic_83xx_rx_stats_strings))
+
+#define QLCNIC_82XX_STATS (QLCNIC_STATS_LEN \
+			+ ARRAY_SIZE(qlcnic_83xx_mac_stats_strings))
+
+#define QLCNIC_DEVICE_STATS_LEN(adapter)	\
+	(QLCNIC_IS_83XX(adapter) ?	\
+	QLC_83XX_STATS :\
+	(ARRAY_SIZE(qlcnic_83xx_mac_stats_strings)	\
+	+ ARRAY_SIZE(qlcnic_device_gstrings_stats)))
+
 #define QLCNIC_STATS_LEN ARRAY_SIZE(qlcnic_gstrings_stats)
-#define QLCNIC_MAC_STATS_LEN ARRAY_SIZE(qlcnic_mac_stats_strings)
-#define QLCNIC_DEVICE_STATS_LEN	ARRAY_SIZE(qlcnic_device_gstrings_stats)
-#define QLCNIC_TOTAL_STATS_LEN QLCNIC_STATS_LEN + QLCNIC_MAC_STATS_LEN
 
 static const char qlcnic_gstrings_test[][ETH_GSTRING_LEN] = {
 	"Register_Test_on_offline",
 	"Link_Test_on_offline",
 	"Interrupt_Test_offline",
 	"Internal_Loopback_offline",
-	"External_Loopback_offline"
+	"EEPROM_Test_offline"
 };
 
 #define QLCNIC_TEST_LEN	ARRAY_SIZE(qlcnic_gstrings_test)
@@ -146,6 +188,12 @@ static const u32 diag_registers[] = {
 	QLCNIC_PEG_ALIVE_COUNTER,
 	QLCNIC_PEG_HALT_STATUS1,
 	QLCNIC_PEG_HALT_STATUS2,
+	-1
+};
+
+static const u32 ext_diag_registers[] = {
+	CRB_XG_STATE_P3P,
+	ISR_INT_STATE_REG,
 	QLCNIC_CRB_PEG_NET_0+0x3c,
 	QLCNIC_CRB_PEG_NET_1+0x3c,
 	QLCNIC_CRB_PEG_NET_2+0x3c,
@@ -154,12 +202,19 @@ static const u32 diag_registers[] = {
 };
 
 #define QLCNIC_MGMT_API_VERSION	2
-#define QLCNIC_DEV_INFO_SIZE	1
 #define QLCNIC_ETHTOOL_REGS_VER	2
+
 static int qlcnic_get_regs_len(struct net_device *dev)
 {
-	return sizeof(diag_registers) + QLCNIC_RING_REGS_LEN +
-				QLCNIC_DEV_INFO_SIZE + 1;
+	struct qlcnic_adapter *adapter = netdev_priv(dev);
+	u32 len;
+
+	if (QLCNIC_IS_83XX(adapter))
+		len = qlcnic_83xx_get_regs_len(adapter);
+	else
+		len = sizeof(ext_diag_registers) + sizeof(diag_registers);
+
+	return QLCNIC_RING_REGS_LEN + len + QLCNIC_DEV_INFO_SIZE + 1;
 }
 
 static int qlcnic_get_eeprom_len(struct net_device *dev)
@@ -170,13 +225,11 @@ static int qlcnic_get_eeprom_len(struct net_device *dev)
 static void
 qlcnic_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *drvinfo)
 {
-	int err;
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	u32 fw_major, fw_minor, fw_build;
-
-	fw_major = QLCRD32(adapter, QLCNIC_FW_VERSION_MAJOR, &err);
-	fw_minor = QLCRD32(adapter, QLCNIC_FW_VERSION_MINOR, &err);
-	fw_build = QLCRD32(adapter, QLCNIC_FW_VERSION_SUB, &err);
+	fw_major = QLCRD(adapter, QLCNIC_FW_VERSION_MAJOR);
+	fw_minor = QLCRD(adapter, QLCNIC_FW_VERSION_MINOR);
+	fw_build = QLCRD(adapter, QLCNIC_FW_VERSION_SUB);
 	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version),
 		"%d.%d.%d", fw_major, fw_minor, fw_build);
 
@@ -190,10 +243,10 @@ qlcnic_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *drvinfo)
 static int
 qlcnic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
-	int err;
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
-	int check_sfp_module = 0;
+	int err, check_sfp_module = 0;
+	u16 pcifn = ahw->pci_func;
 
 	/* read which mode */
 	if (ahw->port_type == QLCNIC_GBE) {
@@ -214,9 +267,12 @@ qlcnic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		ecmd->autoneg = ahw->link_autoneg;
 
 	} else if (ahw->port_type == QLCNIC_XGBE) {
-		u32 val;
-
-		val = QLCRD32(adapter, QLCNIC_PORT_MODE_ADDR, &err);
+		u32 val = 0;
+		if (QLCNIC_IS_83XX(adapter)) {
+			qlcnic_83xx_get_settings(adapter);
+		} else {
+			val = QLCRD32(adapter, QLCNIC_PORT_MODE_ADDR, &err);
+		}
 		if (val == QLCNIC_PORT_MODE_802_3_AP) {
 			ecmd->supported = SUPPORTED_1000baseT_Full;
 			ecmd->advertising = ADVERTISED_1000baseT_Full;
@@ -226,6 +282,10 @@ qlcnic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		}
 
 		if (netif_running(dev) && ahw->has_link_events) {
+			if (QLCNIC_IS_82XX(adapter))
+				ahw->link_speed =
+					QLCNIC_READ_LINK_SPEED(adapter,
+								pcifn, &err);
 			ethtool_cmd_speed_set(ecmd, ahw->link_speed);
 			ecmd->autoneg = ahw->link_autoneg;
 			ecmd->duplex = ahw->link_duplex;
@@ -295,6 +355,13 @@ skip:
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
@@ -323,15 +390,10 @@ skip:
 }
 
 static int
-qlcnic_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+qlcnic_set_port_config(struct qlcnic_adapter *adapter,
+	struct ethtool_cmd *ecmd)
 {
-	u32 config = 0;
-	u32 ret = 0;
-	struct qlcnic_adapter *adapter = netdev_priv(dev);
-
-	if (adapter->ahw->port_type != QLCNIC_GBE)
-		return -EOPNOTSUPP;
-
+	u32 ret = 0, config = 0;
 	/* read which mode */
 	if (ecmd->duplex)
 		config |= 0x1;
@@ -359,6 +421,25 @@ qlcnic_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		return -EOPNOTSUPP;
 	else if (ret)
 		return -EIO;
+	return ret;
+}
+
+static int
+qlcnic_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+{
+	u32 ret = 0;
+	struct qlcnic_adapter *adapter = netdev_priv(dev);
+
+	if (adapter->ahw->port_type != QLCNIC_GBE)
+		return -EOPNOTSUPP;
+
+	if (QLCNIC_IS_83XX(adapter))
+		ret = qlcnic_83xx_set_settings(adapter, ecmd);
+	else
+		ret = qlcnic_set_port_config(adapter, ecmd);
+
+	if (!ret)
+		return ret;
 
 	adapter->ahw->link_speed = ethtool_cmd_speed(ecmd);
 	adapter->ahw->link_duplex = ecmd->duplex;
@@ -371,26 +452,42 @@ qlcnic_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	return dev->netdev_ops->ndo_open(dev);
 }
 
+static int
+qlcnic_get_registers(struct qlcnic_adapter *adapter, u32 *regs_buff)
+{
+	int err, i, j = 0;
+
+	for (i = QLCNIC_DEV_INFO_SIZE + 1; diag_registers[j] != -1; j++, i++)
+		regs_buff[i] = QLCRD(adapter, diag_registers[j]);
+	j = 0;
+	while (ext_diag_registers[j] != -1)
+		regs_buff[i++] = QLCRD32(adapter, ext_diag_registers[j++],
+					 &err);
+	return i;
+}
+
 static void
 qlcnic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
 {
-	int err;
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 	struct qlcnic_host_sds_ring *sds_ring;
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	u32 *regs_buff = p;
-	int ring, i = 0, j = 0;
+	int ring, i = 0;
 
 	memset(p, 0, qlcnic_get_regs_len(dev));
+
 	regs->version = (QLCNIC_ETHTOOL_REGS_VER << 24) |
 		(ahw->revision_id << 16) | (adapter->pdev)->device;
 
 	regs_buff[0] = (0xcafe0000 | (QLCNIC_DEV_INFO_SIZE & 0xffff));
 	regs_buff[1] = QLCNIC_MGMT_API_VERSION;
 
-	for (i = QLCNIC_DEV_INFO_SIZE + 1; diag_registers[j] != -1; j++, i++)
-		regs_buff[i] = QLCRD32(adapter, diag_registers[j], &err);
+	if (QLCNIC_IS_82XX(adapter))
+		i = qlcnic_get_registers(adapter, regs_buff);
+	else
+		i = qlcnic_83xx_get_registers(adapter, regs_buff);
 
 	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state))
 		return;
@@ -419,6 +516,10 @@ static u32 qlcnic_test_link(struct net_device *dev)
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	u32 val;
 
+	if (QLCNIC_IS_83XX(adapter)) {
+		val = qlcnic_83xx_test_link(adapter);
+		return (val & 1) ? 0 : 1;
+	}
 	val = QLCRD32(adapter, CRB_XG_STATE_P3P, &err);
 	val = XG_LINK_STATE_P3P(adapter->ahw->pci_func, val);
 	return (val == XG_LINK_UP_P3P) ? 0 : 1;
@@ -430,8 +531,10 @@ qlcnic_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 {
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	int offset;
-	int ret;
+	int ret = -1;
 
+	if (QLCNIC_IS_83XX(adapter))
+		return 0;
 	if (eeprom->len == 0)
 		return -EINVAL;
 
@@ -439,7 +542,8 @@ qlcnic_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 			((adapter->pdev)->device << 16);
 	offset = eeprom->offset;
 
-	ret = qlcnic_rom_fast_read_words(adapter, offset, bytes,
+	if (QLCNIC_IS_82XX(adapter))
+		ret = qlcnic_rom_fast_read_words(adapter, offset, bytes,
 						eeprom->len);
 	if (ret < 0)
 		return ret;
@@ -509,25 +613,6 @@ qlcnic_set_ringparam(struct net_device *dev,
 	return qlcnic_reset_context(adapter);
 }
 
-static void qlcnic_get_channels(struct net_device *dev,
-		struct ethtool_channels *channel)
-{
-	struct qlcnic_adapter *adapter = netdev_priv(dev);
-
-	channel->max_rx = rounddown_pow_of_two(min_t(int,
-			adapter->ahw->max_rx_ques, num_online_cpus()));
-	channel->max_tx = adapter->ahw->max_tx_ques;
-
-	channel->rx_count = adapter->max_sds_rings;
-	channel->tx_count = adapter->ahw->max_tx_ques;
-}
-
-static int qlcnic_set_channels(struct net_device *dev,
-		struct ethtool_channels *channel)
-{
-	return 0;
-}
-
 static void
 qlcnic_get_pauseparam(struct net_device *netdev,
 			  struct ethtool_pauseparam *pause)
@@ -538,6 +623,10 @@ qlcnic_get_pauseparam(struct net_device *netdev,
 	int port = adapter->ahw->physical_port;
 	__u32 val;
 
+	if (QLCNIC_IS_83XX(adapter)) {
+		qlcnic_83xx_get_pauseparam(adapter, pause);
+		return;
+	}
 	if (ahw->port_type == QLCNIC_GBE) {
 		if ((port < 0) || (port > QLCNIC_NIU_MAX_GBE_PORTS))
 			return;
@@ -579,12 +668,14 @@ static int
 qlcnic_set_pauseparam(struct net_device *netdev,
 			  struct ethtool_pauseparam *pause)
 {
-	int err;
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
-	int port = adapter->ahw->physical_port;
+	int err, port = adapter->ahw->physical_port;
 	__u32 val;
 
+	if (QLCNIC_IS_83XX(adapter))
+		return qlcnic_83xx_set_pauseparam(adapter, pause);
+
 	/* read mode */
 	if (ahw->port_type == QLCNIC_GBE) {
 		if ((port < 0) || (port > QLCNIC_NIU_MAX_GBE_PORTS))
@@ -661,6 +752,9 @@ static int qlcnic_reg_test(struct net_device *dev)
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	u32 data_read;
 
+	if (QLCNIC_IS_83XX(adapter))
+		return qlcnic_83xx_reg_test(adapter);
+
 	data_read = QLCRD32(adapter, QLCNIC_PCIX_PH_REG(0), &err);
 	if ((data_read & 0xffff) != adapter->pdev->vendor)
 		return 1;
@@ -668,6 +762,16 @@ static int qlcnic_reg_test(struct net_device *dev)
 	return 0;
 }
 
+static int qlcnic_eeprom_test(struct net_device *dev)
+{
+	struct qlcnic_adapter *adapter = netdev_priv(dev);
+
+	if (QLCNIC_IS_82XX(adapter))
+		return 0;
+
+	return qlcnic_83xx_flash_test(adapter);
+}
+
 static int qlcnic_get_sset_count(struct net_device *dev, int sset)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
@@ -675,9 +779,11 @@ static int qlcnic_get_sset_count(struct net_device *dev, int sset)
 	case ETH_SS_TEST:
 		return QLCNIC_TEST_LEN;
 	case ETH_SS_STATS:
-		if (adapter->flags & QLCNIC_ESWITCH_ENABLED)
-			return QLCNIC_TOTAL_STATS_LEN + QLCNIC_DEVICE_STATS_LEN;
-		return QLCNIC_TOTAL_STATS_LEN;
+		if ((adapter->flags & QLCNIC_ESWITCH_ENABLED) ||
+			QLCNIC_IS_83XX(adapter))
+			return QLCNIC_STATS_LEN +
+				QLCNIC_DEVICE_STATS_LEN(adapter);
+		return QLCNIC_82XX_STATS;
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -700,8 +806,12 @@ static int qlcnic_irq_test(struct net_device *netdev)
 	adapter->ahw->diag_cnt = 0;
 	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_INTRPT_TEST);
 
-	cmd.req.arg[1] = cpu_to_le32(adapter->ahw->pci_func);
-	ret = qlcnic_issue_cmd(adapter, &cmd);
+	if (QLCNIC_IS_83XX(adapter)) {
+		ret = qlcnic_83xx_interrupt_test(adapter, &cmd);
+	} else {
+		cmd.req.arg[1] = cpu_to_le32(adapter->ahw->pci_func);
+		ret = qlcnic_issue_cmd(adapter, &cmd);
+	}
 
 	if (ret)
 		goto done;
@@ -746,15 +856,16 @@ static int qlcnic_do_lb_test(struct qlcnic_adapter *adapter, u8 mode)
 {
 	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 	struct qlcnic_host_sds_ring *sds_ring = &recv_ctx->sds_rings[0];
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	struct sk_buff *skb;
 	int i, loop, cnt = 0;
 
 	for (i = 0; i < QLCNIC_NUM_ILB_PKT; i++) {
-		skb = netdev_alloc_skb(adapter->netdev, QLCNIC_ILB_PKT_SIZE);
+		skb = dev_alloc_skb(QLCNIC_ILB_PKT_SIZE);
 		qlcnic_create_loopback_buff(skb->data, adapter->mac_addr);
 		skb_put(skb, QLCNIC_ILB_PKT_SIZE);
 
-		adapter->ahw->diag_cnt = 0;
+		ahw->diag_cnt = 0;
 		qlcnic_xmit_frame(skb, adapter->netdev);
 
 		loop = 0;
@@ -763,13 +874,14 @@ static int qlcnic_do_lb_test(struct qlcnic_adapter *adapter, u8 mode)
 			qlcnic_process_rcv_ring_diag(sds_ring);
 			if (loop++ > QLCNIC_ILB_MAX_RCV_LOOP)
 				break;
-		} while (!adapter->ahw->diag_cnt);
+		} while (!ahw->diag_cnt);
 
 		dev_kfree_skb_any(skb);
 
-		if (!adapter->ahw->diag_cnt)
-			QLCDB(adapter, DRV,
-			"LB Test: packet #%d was not received\n", i + 1);
+		if (!ahw->diag_cnt)
+			netif_warn(adapter->ahw, pktdata, adapter->netdev,
+				   "LB Test: packet #%d was not received\n",
+				   i + 1);
 		else
 			cnt++;
 	}
@@ -777,8 +889,7 @@ static int qlcnic_do_lb_test(struct qlcnic_adapter *adapter, u8 mode)
 		dev_warn(&adapter->pdev->dev, "LB Test failed\n");
 		if (mode != QLCNIC_ILB_MODE) {
 			dev_warn(&adapter->pdev->dev,
-				"WARNING: Please make sure external"
-				"loopback connector is plugged in\n");
+				 "Check loopback connector\n");
 		}
 		return -1;
 	}
@@ -789,21 +900,25 @@ static int qlcnic_loopback_test(struct net_device *netdev, u8 mode)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	int max_sds_rings = adapter->max_sds_rings;
-	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	struct qlcnic_host_sds_ring *sds_ring;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	int loop = 0;
 	int ret;
 
+	if (QLCNIC_IS_83XX(adapter))
+		goto skip_cap;
 	if (!(ahw->capabilities & QLCNIC_FW_CAPABILITY_MULTI_LOOPBACK)) {
-		netdev_info(netdev, "Firmware is not loopback test capable\n");
+		netdev_err(netdev,
+			   "Firmware is not loopback test capable\n");
 		return -EOPNOTSUPP;
 	}
-
-	QLCDB(adapter, DRV, "%s loopback test in progress\n",
-		   mode == QLCNIC_ILB_MODE ? "internal" : "external");
+skip_cap:
+	netif_info(adapter->ahw, drv, netdev,
+		"%s loopback test in progress\n",
+			mode == QLCNIC_ILB_MODE ? "internal" : "external");
 	if (ahw->op_mode == QLCNIC_NON_PRIV_FUNC) {
-		netdev_warn(netdev, "Loopback test not supported for non "
-				"privilege function\n");
+		dev_warn(&adapter->pdev->dev,
+			 "Loopback test invalid for non privileged function\n");
 		return 0;
 	}
 
@@ -815,18 +930,20 @@ static int qlcnic_loopback_test(struct net_device *netdev, u8 mode)
 		goto clear_it;
 
 	sds_ring = &adapter->recv_ctx->sds_rings[0];
-
 	ret = qlcnic_set_lb_mode(adapter, mode);
 	if (ret)
 		goto free_res;
 
+	if (QLCNIC_IS_83XX(adapter))
+		goto skip_fw_msg;
+
 	ahw->diag_cnt = 0;
 	do {
 		msleep(500);
 		qlcnic_process_rcv_ring_diag(sds_ring);
 		if (loop++ > QLCNIC_ILB_MAX_RCV_LOOP) {
-			netdev_info(netdev, "firmware didnt respond to loopback"
-				" configure request\n");
+			netdev_err(netdev,
+				   "No response for loopback request\n");
 			ret = -QLCNIC_FW_NOT_RESPOND;
 			goto free_res;
 		} else if (ahw->diag_cnt) {
@@ -834,7 +951,9 @@ static int qlcnic_loopback_test(struct net_device *netdev, u8 mode)
 			goto free_res;
 		}
 	} while (!QLCNIC_IS_LB_CONFIGURED(ahw->loopback_state));
-
+skip_fw_msg:
+	/* allowing firmware to settle before running traffic */
+	msleep(2000);
 	ret = qlcnic_do_lb_test(adapter, mode);
 
 	qlcnic_clear_lb_mode(adapter, mode);
@@ -870,20 +989,18 @@ qlcnic_diag_test(struct net_device *dev, struct ethtool_test *eth_test,
 		data[3] = qlcnic_loopback_test(dev, QLCNIC_ILB_MODE);
 		if (data[3])
 			eth_test->flags |= ETH_TEST_FL_FAILED;
-		if (eth_test->flags & ETH_TEST_FL_EXTERNAL_LB) {
-			data[4] = qlcnic_loopback_test(dev, QLCNIC_ELB_MODE);
-			if (data[4])
-				eth_test->flags |= ETH_TEST_FL_FAILED;
-			eth_test->flags |= ETH_TEST_FL_EXTERNAL_LB_DONE;
-		}
+
+		data[4] = qlcnic_eeprom_test(dev);
+		if (data[4])
+			eth_test->flags |= ETH_TEST_FL_FAILED;
 	}
 }
 
 static void
-qlcnic_get_strings(struct net_device *dev, u32 stringset, u8 * data)
+qlcnic_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
-	int index, i, j;
+	int index, i, num_stats;
 
 	switch (stringset) {
 	case ETH_SS_TEST:
@@ -896,14 +1013,34 @@ qlcnic_get_strings(struct net_device *dev, u32 stringset, u8 * data)
 			       qlcnic_gstrings_stats[index].stat_string,
 			       ETH_GSTRING_LEN);
 		}
-		for (j = 0; j < QLCNIC_MAC_STATS_LEN; index++, j++) {
-			memcpy(data + index * ETH_GSTRING_LEN,
-			       qlcnic_mac_stats_strings[j],
-			       ETH_GSTRING_LEN);
+		if (QLCNIC_IS_83XX(adapter)) {
+			num_stats = ARRAY_SIZE(qlcnic_83xx_tx_stats_strings);
+			for (i = 0; i < num_stats; i++, index++)
+				memcpy(data + index * ETH_GSTRING_LEN,
+				       qlcnic_83xx_tx_stats_strings[i],
+				       ETH_GSTRING_LEN);
+			num_stats = ARRAY_SIZE(qlcnic_83xx_mac_stats_strings);
+			for (i = 0; i < num_stats; i++, index++)
+				memcpy(data + index * ETH_GSTRING_LEN,
+				       qlcnic_83xx_mac_stats_strings[i],
+				       ETH_GSTRING_LEN);
+			num_stats = ARRAY_SIZE(qlcnic_83xx_rx_stats_strings);
+			for (i = 0; i < num_stats; i++, index++)
+				memcpy(data + index * ETH_GSTRING_LEN,
+				       qlcnic_83xx_rx_stats_strings[i],
+				       ETH_GSTRING_LEN);
+			return;
+		} else {
+			num_stats = ARRAY_SIZE(qlcnic_83xx_mac_stats_strings);
+			for (i = 0; i < num_stats; i++, index++)
+				memcpy(data + index * ETH_GSTRING_LEN,
+					qlcnic_83xx_mac_stats_strings[i],
+					ETH_GSTRING_LEN);
 		}
 		if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED))
 			return;
-		for (i = 0; i < QLCNIC_DEVICE_STATS_LEN; index++, i++) {
+		num_stats = ARRAY_SIZE(qlcnic_device_gstrings_stats);
+		for (i = 0; i < num_stats; index++, i++) {
 			memcpy(data + index * ETH_GSTRING_LEN,
 			       qlcnic_device_gstrings_stats[i],
 			       ETH_GSTRING_LEN);
@@ -912,88 +1049,83 @@ qlcnic_get_strings(struct net_device *dev, u32 stringset, u8 * data)
 }
 
 static void
-qlcnic_fill_stats(int *index, u64 *data, void *stats, int type)
+qlcnic_fill_stats(u64 *data, void *stats, int type)
 {
-	int ind = *index;
-
 	if (type == QLCNIC_MAC_STATS) {
 		struct qlcnic_mac_statistics *mac_stats =
 					(struct qlcnic_mac_statistics *)stats;
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_tx_frames);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_tx_bytes);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_tx_mcast_pkts);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_tx_bcast_pkts);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_tx_pause_cnt);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_tx_ctrl_pkt);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_tx_lt_64b_pkts);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_tx_lt_127b_pkts);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_tx_lt_255b_pkts);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_tx_lt_511b_pkts);
-		data[ind++] =
-			QLCNIC_FILL_STATS(mac_stats->mac_tx_lt_1023b_pkts);
-		data[ind++] =
-			QLCNIC_FILL_STATS(mac_stats->mac_tx_lt_1518b_pkts);
-		data[ind++] =
-			QLCNIC_FILL_STATS(mac_stats->mac_tx_gt_1518b_pkts);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_frames);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_bytes);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_mcast_pkts);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_bcast_pkts);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_pause_cnt);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_ctrl_pkt);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_lt_64b_pkts);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_lt_127b_pkts);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_lt_255b_pkts);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_lt_511b_pkts);
-		data[ind++] =
-			QLCNIC_FILL_STATS(mac_stats->mac_rx_lt_1023b_pkts);
-		data[ind++] =
-			QLCNIC_FILL_STATS(mac_stats->mac_rx_lt_1518b_pkts);
-		data[ind++] =
-			QLCNIC_FILL_STATS(mac_stats->mac_rx_gt_1518b_pkts);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_length_error);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_length_small);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_length_large);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_jabber);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_rx_dropped);
-		data[ind++] = QLCNIC_FILL_STATS(mac_stats->mac_align_error);
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
 	} else if (type == QLCNIC_ESW_STATS) {
 		struct __qlcnic_esw_statistics *esw_stats =
 				(struct __qlcnic_esw_statistics *)stats;
-		data[ind++] = QLCNIC_FILL_STATS(esw_stats->unicast_frames);
-		data[ind++] = QLCNIC_FILL_STATS(esw_stats->multicast_frames);
-		data[ind++] = QLCNIC_FILL_STATS(esw_stats->broadcast_frames);
-		data[ind++] = QLCNIC_FILL_STATS(esw_stats->dropped_frames);
-		data[ind++] = QLCNIC_FILL_STATS(esw_stats->errors);
-		data[ind++] = QLCNIC_FILL_STATS(esw_stats->local_frames);
-		data[ind++] = QLCNIC_FILL_STATS(esw_stats->numbytes);
+		*data++ = QLCNIC_FILL_STATS(esw_stats->unicast_frames);
+		*data++ = QLCNIC_FILL_STATS(esw_stats->multicast_frames);
+		*data++ = QLCNIC_FILL_STATS(esw_stats->broadcast_frames);
+		*data++ = QLCNIC_FILL_STATS(esw_stats->dropped_frames);
+		*data++ = QLCNIC_FILL_STATS(esw_stats->errors);
+		*data++ = QLCNIC_FILL_STATS(esw_stats->local_frames);
+		*data++ = QLCNIC_FILL_STATS(esw_stats->numbytes);
 	}
-
-	*index = ind;
 }
 
 static void
 qlcnic_get_ethtool_stats(struct net_device *dev,
-			     struct ethtool_stats *stats, u64 * data)
+			 struct ethtool_stats *stats, u64 *data)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	struct qlcnic_esw_statistics port_stats;
 	struct qlcnic_mac_statistics mac_stats;
-	int index, ret;
+	int index, ret, length;
 
-	for (index = 0; index < QLCNIC_STATS_LEN; index++) {
+	length = QLCNIC_STATS_LEN;
+	for (index = 0; index < length; index++) {
 		char *p =
 		    (char *)adapter +
 		    qlcnic_gstrings_stats[index].stat_offset;
-		data[index] =
-		    (qlcnic_gstrings_stats[index].sizeof_stat ==
-		     sizeof(u64)) ? *(u64 *)p:(*(u32 *)p);
+		*data++ = (qlcnic_gstrings_stats[index].sizeof_stat ==
+		     sizeof(u64)) ? (*(u64 *)p) : ((*(u32 *)p));
 	}
 
-	/* Retrieve MAC statistics from firmware */
-	memset(&mac_stats, 0, sizeof(struct qlcnic_mac_statistics));
-	qlcnic_get_mac_stats(adapter, &mac_stats);
-	qlcnic_fill_stats(&index, data, &mac_stats, QLCNIC_MAC_STATS);
+	if (QLCNIC_IS_83XX(adapter)) {
+		return qlcnic_83xx_get_stats(adapter, stats, data);
+	} else {
+		/* Retrieve MAC statistics from firmware */
+		memset(&mac_stats, 0, sizeof(struct qlcnic_mac_statistics));
+		qlcnic_get_mac_stats(adapter, &mac_stats);
+		qlcnic_fill_stats(data, &mac_stats, QLCNIC_MAC_STATS);
+	}
 
 	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED))
 		return;
@@ -1004,14 +1136,96 @@ qlcnic_get_ethtool_stats(struct net_device *dev,
 	if (ret)
 		return;
 
-	qlcnic_fill_stats(&index, data, &port_stats.rx, QLCNIC_ESW_STATS);
+	qlcnic_fill_stats(data, &port_stats.rx, QLCNIC_ESW_STATS);
 
 	ret = qlcnic_get_port_stats(adapter, adapter->ahw->pci_func,
 			QLCNIC_QUERY_TX_COUNTER, &port_stats.tx);
 	if (ret)
 		return;
 
-	qlcnic_fill_stats(&index, data, &port_stats.tx, QLCNIC_ESW_STATS);
+	qlcnic_fill_stats(data, &port_stats.tx, QLCNIC_ESW_STATS);
+}
+
+static void qlcnic_get_channels(struct net_device *dev,
+				struct ethtool_channels *channel)
+{
+	struct qlcnic_adapter *adapter = netdev_priv(dev);
+
+	channel->max_rx = rounddown_pow_of_two(min_t(int,
+					       adapter->ahw->max_rx_ques,
+					       num_online_cpus()));
+	channel->max_tx = adapter->ahw->max_tx_ques;
+
+	channel->rx_count = adapter->max_sds_rings;
+	channel->tx_count = adapter->ahw->max_tx_ques;
+}
+
+static int qlcnic_set_channels(struct net_device *dev,
+			       struct ethtool_channels *channel)
+{
+	struct qlcnic_adapter *adapter = netdev_priv(dev);
+	int err;
+
+	if (channel->other_count || channel->combined_count ||
+	    channel->tx_count != channel->max_tx)
+		return -EINVAL;
+
+	err = qlcnic_validate_max_rss(channel->max_rx, channel->rx_count);
+	if (err)
+		return err;
+
+	err = qlcnic_set_max_rss(adapter, channel->rx_count, 0);
+	netdev_info(dev, "allocated 0x%x sds rings\n",
+		    adapter->max_sds_rings);
+	return err;
+}
+
+static void
+qlcnic_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	int err;
+	struct qlcnic_adapter *adapter = netdev_priv(dev);
+	u32 wol_cfg;
+
+	if (QLCNIC_IS_83XX(adapter))
+		return;
+	wol->supported = 0;
+	wol->wolopts = 0;
+
+	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG_NV, &err);
+	if (wol_cfg & (1UL << adapter->portnum))
+		wol->supported |= WAKE_MAGIC;
+
+	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG, &err);
+	if (wol_cfg & (1UL << adapter->portnum))
+		wol->wolopts |= WAKE_MAGIC;
+}
+
+static int
+qlcnic_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	int err;
+	struct qlcnic_adapter *adapter = netdev_priv(dev);
+	u32 wol_cfg;
+
+	if (QLCNIC_IS_83XX(adapter))
+		return -EOPNOTSUPP;
+	if (wol->wolopts & ~WAKE_MAGIC)
+		return -EOPNOTSUPP;
+
+	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG_NV, &err);
+	if (!(wol_cfg & (1 << adapter->portnum)))
+		return -EOPNOTSUPP;
+
+	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG, &err);
+	if (wol->wolopts & WAKE_MAGIC)
+		wol_cfg |= 1UL << adapter->portnum;
+	else
+		wol_cfg &= ~(1UL << adapter->portnum);
+
+	QLCWR32(adapter, QLCNIC_WOL_CONFIG, wol_cfg);
+
+	return 0;
 }
 
 static int qlcnic_set_led(struct net_device *dev,
@@ -1021,6 +1235,8 @@ static int qlcnic_set_led(struct net_device *dev,
 	int max_sds_rings = adapter->max_sds_rings;
 	int err = -EIO, active = 1;
 
+	if (QLCNIC_IS_83XX(adapter))
+		return -EOPNOTSUPP;
 	if (adapter->ahw->op_mode == QLCNIC_NON_PRIV_FUNC) {
 		netdev_warn(dev, "LED test not supported for non "
 				"privilege function\n");
@@ -1081,50 +1297,6 @@ static int qlcnic_set_led(struct net_device *dev,
 	return err;
 }
 
-static void
-qlcnic_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
-{
-	int err;
-	struct qlcnic_adapter *adapter = netdev_priv(dev);
-	u32 wol_cfg;
-
-	wol->supported = 0;
-	wol->wolopts = 0;
-
-	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG_NV, &err);
-	if (wol_cfg & (1UL << adapter->portnum))
-		wol->supported |= WAKE_MAGIC;
-
-	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG, &err);
-	if (wol_cfg & (1UL << adapter->portnum))
-		wol->wolopts |= WAKE_MAGIC;
-}
-
-static int
-qlcnic_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
-{
-	int err;
-	struct qlcnic_adapter *adapter = netdev_priv(dev);
-	u32 wol_cfg;
-
-	if (wol->wolopts & ~WAKE_MAGIC)
-		return -EOPNOTSUPP;
-
-	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG_NV, &err);
-	if (!(wol_cfg & (1 << adapter->portnum)))
-		return -EOPNOTSUPP;
-
-	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG, &err);
-	if (wol->wolopts & WAKE_MAGIC)
-		wol_cfg |= 1UL << adapter->portnum;
-	else
-		wol_cfg &= ~(1UL << adapter->portnum);
-
-	QLCWR32(adapter, QLCNIC_WOL_CONFIG, wol_cfg);
-
-	return 0;
-}
-
 /*
  * Set the coalescing parameters. Currently only normal is supported.
  * If rx_coalesce_usecs == 0 or rx_max_coalesced_frames == 0 then set the
@@ -1299,7 +1471,7 @@ qlcnic_set_dump(struct net_device *netdev, struct ethtool_dump *val)
 			return 0;
 		}
 		netdev_info(netdev, "Forcing a FW dump\n");
-		qlcnic_dev_request_reset(adapter, 0);
+		qlcnic_dev_request_reset(adapter, val->flag);
 		break;
 	case QLCNIC_DISABLE_FW_DUMP:
 		if (fw_dump->enable && fw_dump->tmpl_hdr) {
@@ -1319,7 +1491,7 @@ qlcnic_set_dump(struct net_device *netdev, struct ethtool_dump *val)
 		return 0;
 	case QLCNIC_FORCE_FW_RESET:
 		netdev_info(netdev, "Forcing a FW reset\n");
-		qlcnic_dev_request_reset(adapter, 0);
+		qlcnic_dev_request_reset(adapter, val->flag);
 		adapter->flags &= ~QLCNIC_FW_RESET_OWNER;
 		return 0;
 	case QLCNIC_SET_QUIESCENT:
@@ -1333,8 +1505,8 @@ qlcnic_set_dump(struct net_device *netdev, struct ethtool_dump *val)
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
@@ -1342,7 +1514,7 @@ qlcnic_set_dump(struct net_device *netdev, struct ethtool_dump *val)
 				return 0;
 			}
 		}
-		netdev_info(netdev, "Invalid dump level: 0x%x\n", val->flag);
+		netdev_err(netdev, "Invalid dump level: 0x%x\n", val->flag);
 		return -EINVAL;
 	}
 	return 0;
@@ -1378,10 +1550,3 @@ const struct ethtool_ops qlcnic_ethtool_ops = {
 	.get_dump_data = qlcnic_get_dump_data,
 	.set_dump = qlcnic_set_dump,
 };
-
-const struct ethtool_ops qlcnic_ethtool_failed_ops = {
-	.get_settings = qlcnic_get_settings,
-	.get_drvinfo = qlcnic_get_drvinfo,
-	.set_msglevel = qlcnic_set_msglevel,
-	.get_msglevel = qlcnic_get_msglevel,
-};
-- 
1.7.1
