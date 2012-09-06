From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH 03/12] qlcnic: Refactoring - Moving hw specific data to hardware context
Date: Thu,  6 Sep 2012 02:22:00 -0400
Message-ID: <1346912529-17406-4-git-send-email-sony.chacko@qlogic.com>
References: <1346912529-17406-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:9397 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1750999Ab2IFGjR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Sep 2012 02:39:17 -0400
In-Reply-To: <1346912529-17406-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>

Modify 82xx driver to support new adapter - Qlogic 83XX CNA
Group all the HW data in a seperate data structure

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |   86 +++-----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c    |   25 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   69 +++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h    |   25 ++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |  243 +++++++++++---------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h     |  182 ++++++++++++++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c   |   41 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     |   20 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  169 +++++++++-----
 9 files changed, 557 insertions(+), 303 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 00eb99c..e7bc324 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -35,9 +35,9 @@
 #include "qlcnic_hdr.h"
 
 #define _QLCNIC_LINUX_MAJOR 5
-#define _QLCNIC_LINUX_MINOR 0
+#define _QLCNIC_LINUX_MINOR 1
 #define _QLCNIC_LINUX_SUBVERSION 29
-#define QLCNIC_LINUX_VERSIONID  "5.0.29"
+#define QLCNIC_LINUX_VERSIONID  "5.1.29"
 #define QLCNIC_DRV_IDC_VER  0x01
 #define QLCNIC_DRIVER_VERSION  ((_QLCNIC_LINUX_MAJOR << 16) |\
 		 (_QLCNIC_LINUX_MINOR << 8) | (_QLCNIC_LINUX_SUBVERSION))
@@ -458,11 +458,36 @@ struct qlcnic_hardware_context {
 	u8 pci_func;
 	u8 linkup;
 	u8 loopback_state;
+	u8 beacon_state;
+	u8 has_link_events;
+	u8 fw_type;
+	u8 physical_port;
+	u8 reset_context;
+	u8 msix_supported;
+	u8 max_mac_filters;
+	u8 mc_enabled;
+	u8 max_mc_count;
+	u8 diag_test;
+	char diag_cnt;
+
 	u16 port_type;
 	u16 board_type;
 
-	u8 beacon_state;
+	u16 link_speed;
+	u16 link_duplex;
+	u16 link_autoneg;
+	u16 module_type;
+
+	u16 op_mode;
+	u16 switch_mode;
+	u16 max_tx_ques;
+	u16 max_rx_ques;
+	u16 max_mtu;
+	u16 msg_enable;
 
+	u32 capabilities;
+	u32 temp;
+	u32 int_vec_bit;
 	u32 fw_hal_version;
 	struct qlcnic_hardware_ops *hw_ops;
 	struct qlcnic_nic_intr_coalesce coal;
@@ -525,6 +550,7 @@ struct qlcnic_host_sds_ring {
 } ____cacheline_internodealigned_in_smp;
 
 struct qlcnic_host_tx_ring {
+	u16 ctx_id;
 	u32 producer;
 	u32 sw_consumer;
 	u32 num_desc;
@@ -997,49 +1023,22 @@ struct qlcnic_adapter {
 
 	u8 max_rds_rings;
 	u8 max_sds_rings;
-	u8 msix_supported;
 	u8 portnum;
-	u8 physical_port;
-	u8 reset_context;
 
-	u8 mc_enabled;
-	u8 max_mc_count;
 	u8 fw_wait_cnt;
 	u8 fw_fail_cnt;
 	u8 tx_timeo_cnt;
 	u8 need_fw_reset;
 
-	u8 has_link_events;
-	u8 fw_type;
-	u16 tx_context_id;
 	u16 is_up;
-
-	u16 link_speed;
-	u16 link_duplex;
-	u16 link_autoneg;
-	u16 module_type;
-
-	u16 op_mode;
-	u16 switch_mode;
-	u16 max_tx_ques;
-	u16 max_rx_ques;
-	u16 max_mtu;
 	u16 pvid;
 
-	u32 capabilities;
 	u32 irq;
-	u32 temp;
-
-	u32 int_vec_bit;
 	u32 heartbeat;
 
-	u8 max_mac_filters;
 	u8 dev_state;
-	u8 diag_test;
-	char diag_cnt;
 	u8 reset_ack_timeo;
 	u8 dev_init_timeo;
-	u16 msg_enable;
 
 	u8 mac_addr[ETH_ALEN];
 
@@ -1063,7 +1062,6 @@ struct qlcnic_adapter {
 
 	struct delayed_work fw_work;
 
-
 	struct qlcnic_filter_hash fhash;
 
 	spinlock_t tx_clean_lock;
@@ -1589,30 +1587,6 @@ struct qlcnic_brdinfo {
 	char short_name[QLCNIC_MAX_BOARD_NAME_LEN];
 };
 
-static const struct qlcnic_brdinfo qlcnic_boards[] = {
-	{0x1077, 0x8020, 0x1077, 0x203,
-		"8200 Series Single Port 10GbE Converged Network Adapter "
-		"(TCP/IP Networking)"},
-	{0x1077, 0x8020, 0x1077, 0x207,
-		"8200 Series Dual Port 10GbE Converged Network Adapter "
-		"(TCP/IP Networking)"},
-	{0x1077, 0x8020, 0x1077, 0x20b,
-		"3200 Series Dual Port 10Gb Intelligent Ethernet Adapter"},
-	{0x1077, 0x8020, 0x1077, 0x20c,
-		"3200 Series Quad Port 1Gb Intelligent Ethernet Adapter"},
-	{0x1077, 0x8020, 0x1077, 0x20f,
-		"3200 Series Single Port 10Gb Intelligent Ethernet Adapter"},
-	{0x1077, 0x8020, 0x103c, 0x3733,
-		"NC523SFP 10Gb 2-port Server Adapter"},
-	{0x1077, 0x8020, 0x103c, 0x3346,
-		"CN1000Q Dual Port Converged Network Adapter"},
-	{0x1077, 0x8020, 0x1077, 0x210,
-		"QME8242-k 10GbE Dual Port Mezzanine Card"},
-	{0x1077, 0x8020, 0x0, 0x0, "cLOM8214 1/10GbE Controller"},
-};
-
-#define NUM_SUPPORTED_BOARDS ARRAY_SIZE(qlcnic_boards)
-
 static inline u32 qlcnic_tx_avail(struct qlcnic_host_tx_ring *tx_ring)
 {
 	if (likely(tx_ring->producer < tx_ring->sw_consumer))
@@ -1677,7 +1651,7 @@ qlcnic_start_firmware(struct qlcnic_adapter *adapter)
 }
 
 #define QLCDB(adapter, lvl, _fmt, _args...) do {	\
-	if (NETIF_MSG_##lvl & adapter->msg_enable)	\
+	if (NETIF_MSG_##lvl & adapter->ahw->msg_enable) \
 		printk(KERN_INFO "%s: %s: " _fmt,	\
 			 dev_name(&adapter->pdev->dev),	\
 			__func__, ##_args);		\
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index 75b8995..4e57edb 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -453,8 +453,7 @@ qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter)
 		temp = le32_to_cpu(prsp->cds_ring.host_producer_crb);
 		tx_ring->crb_cmd_producer = adapter->ahw->pci_base0 + temp;
 
-		adapter->tx_context_id =
-			le16_to_cpu(prsp->context_id);
+		tx_ring->ctx_id = le16_to_cpu(prsp->context_id);
 	} else {
 		dev_err(&adapter->pdev->dev,
 			"Failed to create tx ctx in firmware%d\n", err);
@@ -476,7 +475,7 @@ qlcnic_fw_cmd_destroy_tx_ctx(struct qlcnic_adapter *adapter)
 	struct qlcnic_cmd_args cmd;
 
 	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.arg1 = adapter->tx_context_id;
+	cmd.req.arg1 = adapter->tx_ring->ctx_id;
 	cmd.req.arg2 = QLCNIC_DESTROY_CTX_RESET;
 	cmd.req.arg3 = 0;
 	cmd.req.cmd = QLCNIC_CDRP_CMD_DESTROY_TX_CTX;
@@ -756,7 +755,7 @@ int qlcnic_set_nic_info(struct qlcnic_adapter *adapter, struct qlcnic_info *nic)
 	struct qlcnic_info *nic_info;
 	size_t nic_size = sizeof(struct qlcnic_info);
 
-	if (adapter->op_mode != QLCNIC_MGMT_FUNC)
+	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC)
 		return err;
 
 	nic_info_addr = dma_alloc_coherent(&adapter->pdev->dev, nic_size,
@@ -856,7 +855,7 @@ int qlcnic_config_port_mirroring(struct qlcnic_adapter *adapter, u8 id,
 	u32 arg1;
 	struct qlcnic_cmd_args cmd;
 
-	if (adapter->op_mode != QLCNIC_MGMT_FUNC ||
+	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC ||
 		!(adapter->eswitch[id].flags & QLCNIC_SWITCH_ENABLE))
 		return err;
 
@@ -896,8 +895,8 @@ int qlcnic_get_port_stats(struct qlcnic_adapter *adapter, const u8 func,
 	if (esw_stats == NULL)
 		return -ENOMEM;
 
-	if (adapter->op_mode != QLCNIC_MGMT_FUNC &&
-	    func != adapter->ahw->pci_func) {
+	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC &&
+		func != adapter->ahw->pci_func) {
 		dev_err(&adapter->pdev->dev,
 			"Not privilege to query stats for func=%d", func);
 		return -EIO;
@@ -1008,7 +1007,7 @@ int qlcnic_get_eswitch_stats(struct qlcnic_adapter *adapter, const u8 eswitch,
 
 	if (esw_stats == NULL)
 		return -ENOMEM;
-	if (adapter->op_mode != QLCNIC_MGMT_FUNC)
+	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC)
 		return -EIO;
 	if (adapter->npars == NULL)
 		return -EIO;
@@ -1059,7 +1058,7 @@ int qlcnic_clear_esw_stats(struct qlcnic_adapter *adapter, const u8 func_esw,
 	u32 arg1;
 	struct qlcnic_cmd_args cmd;
 
-	if (adapter->op_mode != QLCNIC_MGMT_FUNC)
+	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC)
 		return -EIO;
 
 	if (func_esw == QLCNIC_STATS_PORT) {
@@ -1132,7 +1131,7 @@ int qlcnic_config_switch_port(struct qlcnic_adapter *adapter,
 	struct qlcnic_cmd_args cmd;
 	u8 pci_func;
 
-	if (adapter->op_mode != QLCNIC_MGMT_FUNC)
+	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC)
 		return err;
 	pci_func = esw_cfg->pci_func;
 	arg1 = (adapter->npars[pci_func].phy_port & BIT_0);
@@ -1147,7 +1146,7 @@ int qlcnic_config_switch_port(struct qlcnic_adapter *adapter,
 	case QLCNIC_PORT_DEFAULTS:
 		arg1 |= (BIT_4 | BIT_6 | BIT_7);
 		arg2 |= (BIT_0 | BIT_1);
-		if (adapter->capabilities & QLCNIC_FW_CAPABILITY_TSO)
+		if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_TSO)
 			arg2 |= (BIT_2 | BIT_3);
 		if (!(esw_cfg->discard_tagged))
 			arg1 &= ~BIT_4;
@@ -1200,10 +1199,10 @@ qlcnic_get_eswitch_port_config(struct qlcnic_adapter *adapter,
 {
 	u32 arg1, arg2;
 	u8 phy_port;
-	if (adapter->op_mode == QLCNIC_MGMT_FUNC)
+	if (adapter->ahw->op_mode == QLCNIC_MGMT_FUNC)
 		phy_port = adapter->npars[esw_cfg->pci_func].phy_port;
 	else
-		phy_port = adapter->physical_port;
+		phy_port = adapter->ahw->physical_port;
 	arg1 = phy_port;
 	arg1 |= (esw_cfg->pci_func << 8);
 	if (__qlcnic_get_eswitch_port_config(adapter, &arg1, &arg2))
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index c81fcf8..130408e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -210,9 +210,9 @@ qlcnic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 				     ADVERTISED_1000baseT_Half |
 				     ADVERTISED_1000baseT_Full);
 
-		ethtool_cmd_speed_set(ecmd, adapter->link_speed);
-		ecmd->duplex = adapter->link_duplex;
-		ecmd->autoneg = adapter->link_autoneg;
+		ethtool_cmd_speed_set(ecmd, ahw->link_speed);
+		ecmd->duplex = ahw->link_duplex;
+		ecmd->autoneg = ahw->link_autoneg;
 
 	} else if (ahw->port_type == QLCNIC_XGBE) {
 		u32 val;
@@ -226,10 +226,10 @@ qlcnic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 			ecmd->advertising = ADVERTISED_10000baseT_Full;
 		}
 
-		if (netif_running(dev) && adapter->has_link_events) {
-			ethtool_cmd_speed_set(ecmd, adapter->link_speed);
-			ecmd->autoneg = adapter->link_autoneg;
-			ecmd->duplex = adapter->link_duplex;
+		if (netif_running(dev) && ahw->has_link_events) {
+			ethtool_cmd_speed_set(ecmd, ahw->link_speed);
+			ecmd->autoneg = ahw->link_autoneg;
+			ecmd->duplex = ahw->link_duplex;
 			goto skip;
 		}
 
@@ -240,7 +240,7 @@ qlcnic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		return -EIO;
 
 skip:
-	ecmd->phy_address = adapter->physical_port;
+	ecmd->phy_address = adapter->ahw->physical_port;
 	ecmd->transceiver = XCVR_EXTERNAL;
 
 	switch (ahw->board_type) {
@@ -256,7 +256,7 @@ skip:
 		ecmd->supported |= SUPPORTED_TP;
 		ecmd->advertising |= ADVERTISED_TP;
 		ecmd->port = PORT_TP;
-		ecmd->autoneg =  adapter->link_autoneg;
+		ecmd->autoneg =  ahw->link_autoneg;
 		break;
 	case QLCNIC_BRDTYPE_P3P_IMEZ:
 	case QLCNIC_BRDTYPE_P3P_XG_LOM:
@@ -272,7 +272,7 @@ skip:
 		ecmd->advertising |= ADVERTISED_TP;
 		ecmd->supported |= SUPPORTED_TP;
 		check_sfp_module = netif_running(dev) &&
-			adapter->has_link_events;
+			ahw->has_link_events;
 	case QLCNIC_BRDTYPE_P3P_10G_XFP:
 		ecmd->supported |= SUPPORTED_FIBRE;
 		ecmd->advertising |= ADVERTISED_FIBRE;
@@ -287,7 +287,7 @@ skip:
 				(ADVERTISED_FIBRE | ADVERTISED_TP);
 			ecmd->port = PORT_FIBRE;
 			check_sfp_module = netif_running(dev) &&
-				adapter->has_link_events;
+				ahw->has_link_events;
 		} else {
 			ecmd->autoneg = AUTONEG_ENABLE;
 			ecmd->supported |= (SUPPORTED_TP | SUPPORTED_Autoneg);
@@ -303,7 +303,7 @@ skip:
 	}
 
 	if (check_sfp_module) {
-		switch (adapter->module_type) {
+		switch (adapter->ahw->module_type) {
 		case LINKEVENT_MODULE_OPTICAL_UNKNOWN:
 		case LINKEVENT_MODULE_OPTICAL_SRLR:
 		case LINKEVENT_MODULE_OPTICAL_LRM:
@@ -361,9 +361,9 @@ qlcnic_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	else if (ret)
 		return -EIO;
 
-	adapter->link_speed = ethtool_cmd_speed(ecmd);
-	adapter->link_duplex = ecmd->duplex;
-	adapter->link_autoneg = ecmd->autoneg;
+	adapter->ahw->link_speed = ethtool_cmd_speed(ecmd);
+	adapter->ahw->link_duplex = ecmd->duplex;
+	adapter->ahw->link_autoneg = ecmd->autoneg;
 
 	if (!netif_running(dev))
 		return 0;
@@ -514,11 +514,11 @@ static void qlcnic_get_channels(struct net_device *dev,
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 
 	channel->max_rx = rounddown_pow_of_two(min_t(int,
-			adapter->max_rx_ques, num_online_cpus()));
-	channel->max_tx = adapter->max_tx_ques;
+			adapter->ahw->max_rx_ques, num_online_cpus()));
+	channel->max_tx = adapter->ahw->max_tx_ques;
 
 	channel->rx_count = adapter->max_sds_rings;
-	channel->tx_count = adapter->max_tx_ques;
+	channel->tx_count = adapter->ahw->max_tx_ques;
 }
 
 static int qlcnic_set_channels(struct net_device *dev,
@@ -547,7 +547,7 @@ qlcnic_get_pauseparam(struct net_device *netdev,
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
-	int port = adapter->physical_port;
+	int port = adapter->ahw->physical_port;
 	__u32 val;
 
 	if (ahw->port_type == QLCNIC_GBE) {
@@ -593,7 +593,7 @@ qlcnic_set_pauseparam(struct net_device *netdev,
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
-	int port = adapter->physical_port;
+	int port = adapter->ahw->physical_port;
 	__u32 val;
 
 	/* read mode */
@@ -707,7 +707,7 @@ static int qlcnic_irq_test(struct net_device *netdev)
 	if (ret)
 		goto clear_it;
 
-	adapter->diag_cnt = 0;
+	adapter->ahw->diag_cnt = 0;
 	memset(&cmd, 0, sizeof(cmd));
 	cmd.req.cmd = QLCNIC_CDRP_CMD_INTRPT_TEST;
 	cmd.req.arg1 = adapter->ahw->pci_func;
@@ -719,7 +719,7 @@ static int qlcnic_irq_test(struct net_device *netdev)
 
 	msleep(10);
 
-	ret = !adapter->diag_cnt;
+	ret = !adapter->ahw->diag_cnt;
 
 done:
 	qlcnic_diag_free_res(netdev, max_sds_rings);
@@ -765,7 +765,7 @@ static int qlcnic_do_lb_test(struct qlcnic_adapter *adapter, u8 mode)
 		qlcnic_create_loopback_buff(skb->data, adapter->mac_addr);
 		skb_put(skb, QLCNIC_ILB_PKT_SIZE);
 
-		adapter->diag_cnt = 0;
+		adapter->ahw->diag_cnt = 0;
 		qlcnic_xmit_frame(skb, adapter->netdev);
 
 		loop = 0;
@@ -774,11 +774,11 @@ static int qlcnic_do_lb_test(struct qlcnic_adapter *adapter, u8 mode)
 			qlcnic_process_rcv_ring_diag(sds_ring);
 			if (loop++ > QLCNIC_ILB_MAX_RCV_LOOP)
 				break;
-		} while (!adapter->diag_cnt);
+		} while (!adapter->ahw->diag_cnt);
 
 		dev_kfree_skb_any(skb);
 
-		if (!adapter->diag_cnt)
+		if (!adapter->ahw->diag_cnt)
 			QLCDB(adapter, DRV,
 			"LB Test: packet #%d was not received\n", i + 1);
 		else
@@ -800,18 +800,19 @@ static int qlcnic_loopback_test(struct net_device *netdev, u8 mode)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	int max_sds_rings = adapter->max_sds_rings;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	struct qlcnic_host_sds_ring *sds_ring;
 	int loop = 0;
 	int ret;
 
-	if (!(adapter->capabilities & QLCNIC_FW_CAPABILITY_MULTI_LOOPBACK)) {
+	if (!(ahw->capabilities & QLCNIC_FW_CAPABILITY_MULTI_LOOPBACK)) {
 		netdev_info(netdev, "Firmware is not loopback test capable\n");
 		return -EOPNOTSUPP;
 	}
 
 	QLCDB(adapter, DRV, "%s loopback test in progress\n",
 		   mode == QLCNIC_ILB_MODE ? "internal" : "external");
-	if (adapter->op_mode == QLCNIC_NON_PRIV_FUNC) {
+	if (ahw->op_mode == QLCNIC_NON_PRIV_FUNC) {
 		netdev_warn(netdev, "Loopback test not supported for non "
 				"privilege function\n");
 		return 0;
@@ -830,7 +831,7 @@ static int qlcnic_loopback_test(struct net_device *netdev, u8 mode)
 	if (ret)
 		goto free_res;
 
-	adapter->diag_cnt = 0;
+	ahw->diag_cnt = 0;
 	do {
 		msleep(500);
 		qlcnic_process_rcv_ring_diag(sds_ring);
@@ -839,11 +840,11 @@ static int qlcnic_loopback_test(struct net_device *netdev, u8 mode)
 				" configure request\n");
 			ret = -QLCNIC_FW_NOT_RESPOND;
 			goto free_res;
-		} else if (adapter->diag_cnt) {
-			ret = adapter->diag_cnt;
+		} else if (ahw->diag_cnt) {
+			ret = ahw->diag_cnt;
 			goto free_res;
 		}
-	} while (!QLCNIC_IS_LB_CONFIGURED(adapter->ahw->loopback_state));
+	} while (!QLCNIC_IS_LB_CONFIGURED(ahw->loopback_state));
 
 	ret = qlcnic_do_lb_test(adapter, mode);
 
@@ -1032,7 +1033,7 @@ static int qlcnic_set_led(struct net_device *dev,
 	int max_sds_rings = adapter->max_sds_rings;
 	int err = -EIO, active = 1;
 
-	if (adapter->op_mode == QLCNIC_NON_PRIV_FUNC) {
+	if (adapter->ahw->op_mode == QLCNIC_NON_PRIV_FUNC) {
 		netdev_warn(dev, "LED test not supported for non "
 				"privilege function\n");
 		return -EOPNOTSUPP;
@@ -1211,14 +1212,14 @@ static u32 qlcnic_get_msglevel(struct net_device *netdev)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 
-	return adapter->msg_enable;
+	return adapter->ahw->msg_enable;
 }
 
 static void qlcnic_set_msglevel(struct net_device *netdev, u32 msglvl)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 
-	adapter->msg_enable = msglvl;
+	adapter->ahw->msg_enable = msglvl;
 }
 
 static int
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
index 0bee9f7..808b445 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
@@ -517,6 +517,28 @@ enum {
 #define MIU_TEST_AGT_ADDR_MASK		0xfffffff8
 #define MIU_TEST_AGT_UPPER_ADDR(off)	(0)
 
+#define QLCNIC_MS_CTRL     0x41000090
+#define QLCNIC_MS_ADDR_LO  0x41000094
+#define QLCNIC_MS_ADDR_HI  0x41000098
+
+#define QLCNIC_MS_WRTDATA_LO       0x410000A0
+#define QLCNIC_MS_WRTDATA_HI       0x410000A4
+#define QLCNIC_MS_WRTDATA_ULO      0x410000B0
+#define QLCNIC_MS_WRTDATA_UHI      0x410000B4
+
+#define QLCNIC_MS_RDDATA_LO        0x410000A8
+#define QLCNIC_MS_RDDATA_HI        0x410000AC
+#define QLCNIC_MS_RDDATA_ULO       0x410000B8
+#define QLCNIC_MS_RDDATA_UHI       0x410000BC
+
+static const u32 QLCNIC_MS_READ_DATA[] = {
+	0x410000A8, 0x410000AC, 0x410000B8, 0x410000BC};
+
+#define QLC_TA_WRITE_ENABLE (TA_CTL_ENABLE | TA_CTL_WRITE)
+#define QLC_TA_WRITE_START (TA_CTL_START | TA_CTL_ENABLE | TA_CTL_WRITE)
+#define QLC_TA_START_ENABLE (TA_CTL_START | TA_CTL_ENABLE)
+
+
 /* XG Link status */
 #define XG_LINK_UP	0x10
 #define XG_LINK_DOWN	0x20
@@ -715,6 +737,9 @@ enum {
 #define QLCNIC_HEARTBEAT_PERIOD_MSECS	200
 #define QLCNIC_HEARTBEAT_CHECK_RETRY_COUNT	45
 
+#define QLCNIC_MAX_MC_COUNT		38
+#define QLCNIC_WATCHDOG_TIMEOUTVALUE	5
+
 #define	ISR_MSI_INT_TRIGGER(FUNC) (QLCNIC_PCIX_PS_REG(PCIX_MSI_F(FUNC)))
 #define ISR_LEGACY_INT_TRIGGERED(VAL)	(((VAL) & 0x300) == 0x200)
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index ee4cd43..f31022a 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -279,6 +279,35 @@ static const u32 msi_tgt_status[8] = {
 
 #define QLCNIC_PCIE_SEM_TIMEOUT	10000
 
+static void
+qlcnic_read_dump_reg(u32 addr, void __iomem *bar0, u32 *data)
+{
+	u32 dest;
+	void __iomem *val;
+
+	dest = addr & 0xFFFF0000;
+	val = bar0 + QLCNIC_FW_DUMP_REG1;
+	writel(dest, val);
+	readl(val);
+	val = bar0 + QLCNIC_FW_DUMP_REG2 + LSW(addr);
+	*data = readl(val);
+}
+
+static void
+qlcnic_write_dump_reg(u32 addr, void __iomem *bar0, u32 data)
+{
+	u32 dest;
+	void __iomem *val;
+
+	dest = addr & 0xFFFF0000;
+	val = bar0 + QLCNIC_FW_DUMP_REG1;
+	writel(dest, val);
+	readl(val);
+	val = bar0 + QLCNIC_FW_DUMP_REG2 + LSW(addr);
+	writel(data, val);
+	readl(val);
+}
+
 int
 qlcnic_pcie_sem_lock(struct qlcnic_adapter *adapter, int sem, u32 id_reg)
 {
@@ -309,6 +338,23 @@ qlcnic_pcie_sem_unlock(struct qlcnic_adapter *adapter, int sem)
 	QLCRD32(adapter, QLCNIC_PCIE_REG(PCIE_SEM_UNLOCK(sem)));
 }
 
+u32 qlcnic_ind_rd(struct qlcnic_adapter *adapter, u32 addr)
+{
+	u32 data;
+
+	if (QLCNIC_IS_82XX(adapter))
+		qlcnic_read_dump_reg(addr, adapter->ahw->pci_base0, &data);
+	else
+		return -EIO;
+	return data;
+}
+
+void qlcnic_ind_wr(struct qlcnic_adapter *adapter, u32 addr, u32 data)
+{
+	if (QLCNIC_IS_82XX(adapter))
+		qlcnic_write_dump_reg(addr, adapter->ahw->pci_base0, data);
+}
+
 static int
 qlcnic_send_cmd_descs(struct qlcnic_adapter *adapter,
 		struct cmd_desc_type0 *cmd_desc_arr, int nr_desc)
@@ -443,7 +489,7 @@ void qlcnic_set_multi(struct net_device *netdev)
 	}
 
 	if ((netdev->flags & IFF_ALLMULTI) ||
-	    (netdev_mc_count(netdev) > adapter->max_mc_count)) {
+	    (netdev_mc_count(netdev) > adapter->ahw->max_mc_count)) {
 		mode = VPORT_MISS_MODE_ACCEPT_MULTI;
 		goto send_fw_cmd;
 	}
@@ -1004,36 +1050,19 @@ qlcnic_get_ioaddr(struct qlcnic_hardware_context *ahw, u32 offset)
 	return addr;
 }
 
-
-static int
-qlcnic_pci_set_window_2M(struct qlcnic_adapter *adapter,
-		u64 addr, u32 *start)
-{
-	u32 window;
-
-	window = OCM_WIN_P3P(addr);
-
-	writel(window, adapter->ahw->ocm_win_crb);
-	/* read back to flush */
-	readl(adapter->ahw->ocm_win_crb);
-
-	*start = QLCNIC_PCI_OCM0_2M + GET_MEM_OFFS_2M(addr);
-	return 0;
-}
-
 static int
-qlcnic_pci_mem_access_direct(struct qlcnic_adapter *adapter, u64 off,
-		u64 *data, int op)
+qlcnic_pci_mem_access_direct(struct qlcnic_adapter *adapter, u32 window,
+			     u64 off, u64 *data, int op)
 {
 	void __iomem *addr;
-	int ret;
 	u32 start;
 
 	mutex_lock(&adapter->ahw->mem_lock);
 
-	ret = qlcnic_pci_set_window_2M(adapter, off, &start);
-	if (ret != 0)
-		goto unlock;
+	writel(window, adapter->ahw->ocm_win_crb);
+	/* read back to flush */
+	readl(adapter->ahw->ocm_win_crb);
+	start = QLCNIC_PCI_OCM0_2M + off;
 
 	addr = adapter->ahw->pci_base0 + start;
 
@@ -1042,10 +1071,12 @@ qlcnic_pci_mem_access_direct(struct qlcnic_adapter *adapter, u64 off,
 	else		/* write */
 		writeq(*data, addr);
 
-unlock:
-	mutex_unlock(&adapter->ahw->mem_lock);
+	/* Set window to 0 */
+	writel(0, adapter->ahw->ocm_win_crb);
+	readl(adapter->ahw->ocm_win_crb);
 
-	return ret;
+	mutex_unlock(&adapter->ahw->mem_lock);
+	return 0;
 }
 
 void
@@ -1072,54 +1103,75 @@ qlcnic_pci_camqm_write_2M(struct qlcnic_adapter *adapter, u64 off, u64 data)
 
 #define MAX_CTL_CHECK   1000
 
+/* Set MS memory control data for different chip type*/
+static void
+qlcnic_set_ms_controls(struct qlcnic_adapter *adapter, u64 off,
+		       struct qlcnic_ms_reg_ctrl *ms)
+{
+	ms->control = QLCNIC_MS_CTRL;
+	ms->low = QLCNIC_MS_ADDR_LO;
+	ms->hi = QLCNIC_MS_ADDR_HI;
+	if (off & 0xf) {
+		ms->wd[0] = QLCNIC_MS_WRTDATA_LO;
+		ms->rd[0] = QLCNIC_MS_RDDATA_LO;
+		ms->wd[1] = QLCNIC_MS_WRTDATA_HI;
+		ms->rd[1] = QLCNIC_MS_RDDATA_HI;
+		ms->wd[2] = QLCNIC_MS_WRTDATA_ULO;
+		ms->wd[3] = QLCNIC_MS_WRTDATA_UHI;
+		ms->rd[2] = QLCNIC_MS_RDDATA_ULO;
+		ms->rd[3] = QLCNIC_MS_RDDATA_UHI;
+	} else {
+		ms->wd[0] = QLCNIC_MS_WRTDATA_ULO;
+		ms->rd[0] = QLCNIC_MS_RDDATA_ULO;
+		ms->wd[1] = QLCNIC_MS_WRTDATA_UHI;
+		ms->rd[1] = QLCNIC_MS_RDDATA_UHI;
+		ms->wd[2] = QLCNIC_MS_WRTDATA_LO;
+		ms->wd[3] = QLCNIC_MS_WRTDATA_HI;
+		ms->rd[2] = QLCNIC_MS_RDDATA_LO;
+		ms->rd[3] = QLCNIC_MS_RDDATA_HI;
+	}
+
+	ms->ocm_window = OCM_WIN_P3P(off);
+	ms->off = GET_MEM_OFFS_2M(off);
+}
+
 int
 qlcnic_pci_mem_write_2M(struct qlcnic_adapter *adapter,
-		u64 off, u64 data)
+			u64 off, u64 data)
 {
-	int i, j, ret;
+	int j, ret = 0;
 	u32 temp, off8;
-	void __iomem *mem_crb;
+	struct qlcnic_ms_reg_ctrl ms;
 
 	/* Only 64-bit aligned access */
 	if (off & 7)
 		return -EIO;
 
-	/* P3 onward, test agent base for MIU and SIU is same */
-	if (ADDR_IN_RANGE(off, QLCNIC_ADDR_QDR_NET,
-			  QLCNIC_ADDR_QDR_NET_MAX)) {
-		mem_crb = qlcnic_get_ioaddr(adapter->ahw,
-					    QLCNIC_CRB_QDR_NET +
-					    MIU_TEST_AGT_BASE);
-		goto correct;
-	}
+	memset(&ms, 0, sizeof(struct qlcnic_ms_reg_ctrl));
+	if (!((ADDR_IN_RANGE(off, QLCNIC_ADDR_QDR_NET,
+		QLCNIC_ADDR_QDR_NET_MAX)) ||
+			(ADDR_IN_RANGE(off, QLCNIC_ADDR_DDR_NET,
+				QLCNIC_ADDR_DDR_NET_MAX))))
+		return -EIO;
 
-	if (ADDR_IN_RANGE(off, QLCNIC_ADDR_DDR_NET, QLCNIC_ADDR_DDR_NET_MAX)) {
-		mem_crb = qlcnic_get_ioaddr(adapter->ahw,
-					    QLCNIC_CRB_DDR_NET +
-					    MIU_TEST_AGT_BASE);
-		goto correct;
-	}
+	qlcnic_set_ms_controls(adapter, off, &ms);
 
 	if (ADDR_IN_RANGE(off, QLCNIC_ADDR_OCM0, QLCNIC_ADDR_OCM0_MAX))
-		return qlcnic_pci_mem_access_direct(adapter, off, &data, 1);
-
-	return -EIO;
+		return qlcnic_pci_mem_access_direct(adapter, ms.ocm_window,
+						    ms.off, &data, 1);
 
-correct:
 	off8 = off & ~0xf;
 
 	mutex_lock(&adapter->ahw->mem_lock);
 
-	writel(off8, (mem_crb + MIU_TEST_AGT_ADDR_LO));
-	writel(0, (mem_crb + MIU_TEST_AGT_ADDR_HI));
+	qlcnic_ind_wr(adapter, ms.low, off8);
+	qlcnic_ind_wr(adapter, ms.hi, 0);
 
-	i = 0;
-	writel(TA_CTL_ENABLE, (mem_crb + TEST_AGT_CTRL));
-	writel((TA_CTL_START | TA_CTL_ENABLE),
-	       (mem_crb + TEST_AGT_CTRL));
+	qlcnic_ind_wr(adapter, ms.control, TA_CTL_ENABLE);
+	qlcnic_ind_wr(adapter, ms.control, QLC_TA_START_ENABLE);
 
 	for (j = 0; j < MAX_CTL_CHECK; j++) {
-		temp = readl(mem_crb + TEST_AGT_CTRL);
+		temp = qlcnic_ind_rd(adapter, ms.control);
 		if ((temp & TA_CTL_BUSY) == 0)
 			break;
 	}
@@ -1129,24 +1181,18 @@ correct:
 		goto done;
 	}
 
-	i = (off & 0xf) ? 0 : 2;
-	writel(readl(mem_crb + MIU_TEST_AGT_RDDATA(i)),
-	       mem_crb + MIU_TEST_AGT_WRDATA(i));
-	writel(readl(mem_crb + MIU_TEST_AGT_RDDATA(i+1)),
-	       mem_crb + MIU_TEST_AGT_WRDATA(i+1));
-	i = (off & 0xf) ? 2 : 0;
-
-	writel(data & 0xffffffff,
-	       mem_crb + MIU_TEST_AGT_WRDATA(i));
-	writel((data >> 32) & 0xffffffff,
-	       mem_crb + MIU_TEST_AGT_WRDATA(i+1));
+	/* This is the modify part of read-modify-write */
+	qlcnic_ind_wr(adapter, ms.wd[0], qlcnic_ind_rd(adapter, ms.rd[0]));
+	qlcnic_ind_wr(adapter, ms.wd[1], qlcnic_ind_rd(adapter, ms.rd[1]));
+	/* This is the write part of read-modify-write */
+	qlcnic_ind_wr(adapter, ms.wd[2], data & 0xffffffff);
+	qlcnic_ind_wr(adapter, ms.wd[3], (data >> 32) & 0xffffffff);
 
-	writel((TA_CTL_ENABLE | TA_CTL_WRITE), (mem_crb + TEST_AGT_CTRL));
-	writel((TA_CTL_START | TA_CTL_ENABLE | TA_CTL_WRITE),
-	       (mem_crb + TEST_AGT_CTRL));
+	qlcnic_ind_wr(adapter, ms.control, QLC_TA_WRITE_ENABLE);
+	qlcnic_ind_wr(adapter, ms.control, QLC_TA_WRITE_START);
 
 	for (j = 0; j < MAX_CTL_CHECK; j++) {
-		temp = readl(mem_crb + TEST_AGT_CTRL);
+		temp = qlcnic_ind_rd(adapter, ms.control);
 		if ((temp & TA_CTL_BUSY) == 0)
 			break;
 	}
@@ -1154,7 +1200,7 @@ correct:
 	if (j >= MAX_CTL_CHECK) {
 		if (printk_ratelimit())
 			dev_err(&adapter->pdev->dev,
-					"failed to write through agent\n");
+				"failed to write through agent\n");
 		ret = -EIO;
 	} else
 		ret = 0;
@@ -1166,53 +1212,41 @@ done:
 }
 
 int
-qlcnic_pci_mem_read_2M(struct qlcnic_adapter *adapter,
-		u64 off, u64 *data)
+qlcnic_pci_mem_read_2M(struct qlcnic_adapter *adapter, u64 off, u64 *data)
 {
 	int j, ret;
 	u32 temp, off8;
 	u64 val;
-	void __iomem *mem_crb;
+	struct qlcnic_ms_reg_ctrl ms;
 
 	/* Only 64-bit aligned access */
 	if (off & 7)
 		return -EIO;
+	if (!((ADDR_IN_RANGE(off, QLCNIC_ADDR_QDR_NET,
+		QLCNIC_ADDR_QDR_NET_MAX)) ||
+			(ADDR_IN_RANGE(off, QLCNIC_ADDR_DDR_NET,
+				QLCNIC_ADDR_DDR_NET_MAX))))
+		return -EIO ;
 
-	/* P3 onward, test agent base for MIU and SIU is same */
-	if (ADDR_IN_RANGE(off, QLCNIC_ADDR_QDR_NET,
-			  QLCNIC_ADDR_QDR_NET_MAX)) {
-		mem_crb = qlcnic_get_ioaddr(adapter->ahw,
-					    QLCNIC_CRB_QDR_NET +
-					    MIU_TEST_AGT_BASE);
-		goto correct;
-	}
-
-	if (ADDR_IN_RANGE(off, QLCNIC_ADDR_DDR_NET, QLCNIC_ADDR_DDR_NET_MAX)) {
-		mem_crb = qlcnic_get_ioaddr(adapter->ahw,
-					    QLCNIC_CRB_DDR_NET +
-					    MIU_TEST_AGT_BASE);
-		goto correct;
-	}
+	memset(&ms, 0, sizeof(struct qlcnic_ms_reg_ctrl));
+	qlcnic_set_ms_controls(adapter, off, &ms);
 
-	if (ADDR_IN_RANGE(off, QLCNIC_ADDR_OCM0, QLCNIC_ADDR_OCM0_MAX)) {
-		return qlcnic_pci_mem_access_direct(adapter,
-				off, data, 0);
-	}
+	if (ADDR_IN_RANGE(off, QLCNIC_ADDR_OCM0, QLCNIC_ADDR_OCM0_MAX))
+		return qlcnic_pci_mem_access_direct(adapter, ms.ocm_window,
+						    ms.off, data, 0);
 
-	return -EIO;
+	mutex_lock(&adapter->ahw->mem_lock);
 
-correct:
 	off8 = off & ~0xf;
 
-	mutex_lock(&adapter->ahw->mem_lock);
+	qlcnic_ind_wr(adapter, ms.low, off8);
+	qlcnic_ind_wr(adapter, ms.hi, 0);
 
-	writel(off8, (mem_crb + MIU_TEST_AGT_ADDR_LO));
-	writel(0, (mem_crb + MIU_TEST_AGT_ADDR_HI));
-	writel(TA_CTL_ENABLE, (mem_crb + TEST_AGT_CTRL));
-	writel((TA_CTL_START | TA_CTL_ENABLE), (mem_crb + TEST_AGT_CTRL));
+	qlcnic_ind_wr(adapter, ms.control, TA_CTL_ENABLE);
+	qlcnic_ind_wr(adapter, ms.control, QLC_TA_START_ENABLE);
 
 	for (j = 0; j < MAX_CTL_CHECK; j++) {
-		temp = readl(mem_crb + TEST_AGT_CTRL);
+		temp = qlcnic_ind_rd(adapter, ms.control);
 		if ((temp & TA_CTL_BUSY) == 0)
 			break;
 	}
@@ -1223,13 +1257,10 @@ correct:
 					"failed to read through agent\n");
 		ret = -EIO;
 	} else {
-		off8 = MIU_TEST_AGT_RDDATA_LO;
-		if (off & 0xf)
-			off8 = MIU_TEST_AGT_RDDATA_UPPER_LO;
 
-		temp = readl(mem_crb + off8 + 4);
+		temp = qlcnic_ind_rd(adapter, ms.rd[3]);
 		val = (u64)temp << 32;
-		val |= readl(mem_crb + off8);
+		val |= qlcnic_ind_rd(adapter, ms.rd[2]);
 		*data = val;
 		ret = 0;
 	}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
index 7dab9e2..8f16098 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
@@ -3,18 +3,168 @@
 
 #include "qlcnic.h"
 
+#define MASK(n) ((1ULL<<(n))-1)
+#define OCM_WIN_P3P(addr) (addr & 0xffc0000)
+#define OCM_WIN_83XX(addr)	(addr & 0xFFE0000)
+
+#define GET_MEM_OFFS_2M(addr) (addr & MASK(18))
+#define GET_83XX_OCM_OFFSET(addr)	(addr & MASK(17))
+
+#define CRB_BLK(off)	((off >> 20) & 0x3f)
+#define CRB_SUBBLK(off)	((off >> 16) & 0xf)
+#define CRB_WINDOW_2M	(0x130060)
+#define CRB_HI(off)	((crb_hub_agt[CRB_BLK(off)] << 20) | ((off) & 0xf0000))
+#define CRB_INDIRECT_2M	(0x1e0000UL)
+
+
+
 /* List of PCI device IDs */
-#define PCI_DEVICE_ID_QLOGIC_QLE824X  0x8020
-#define QLCNIC_P3P_BAR0_LENGTH		0x00200000UL
+#define PCI_DEVICE_ID_QLOGIC_QLE824X	0x8020
+#define PCI_DEVICE_ID_QLOGIC_QLE834X	0x8030
+#define QLCNIC_82XX_BAR0_LENGTH	0x00200000UL
+#define QLCNIC_83XX_BAR0_LENGTH	0x4000
+
+#define QLCNIC_IS_83XX(adapter)	\
+	(((adapter)->pdev->device == PCI_DEVICE_ID_QLOGIC_QLE834X) ? 1 : 0)
+
+#define QLCNIC_IS_82XX(adapter)	\
+	(((adapter)->pdev->device == PCI_DEVICE_ID_QLOGIC_QLE824X) ? 1 : 0)
+
+struct qlcnic_ms_reg_ctrl {
+	u32 ocm_window;
+	u32 control;
+	u32 hi;
+	u32 low;
+	u32 rd[4];
+	u32 wd[4];
+	u64 off;
+};
+
+/* Read from an address offset from BAR0, existing registers */
+#define QLCRD(a, addr)			\
+	readl(((a)->ahw->pci_base0) + ((a)->ahw->reg_tbl[addr]))
+/* Write to an address offset from BAR0, existing registers */
+#define QLCWR(a, addr, value)		\
+	writel(value, ((a)->ahw->pci_base0) + ((a)->ahw->reg_tbl[addr]))
+
+/* Read from a direct address offset from BAR0, additional registers */
+#define QLCRDX(ahw, addr)			\
+	readl(((ahw)->pci_base0) + ((ahw)->ext_reg_tbl[addr]))
+/* Write to a direct address offset from BAR0, additional registers */
+#define QLCWRX(ahw, addr, value)		\
+	writel(value, (((ahw)->pci_base0) + ((ahw)->ext_reg_tbl[addr])))
+
+#define QLCNIC_READ_LINK_SPEED(adapter, pcifn, err)\
+	QLCRD32(adapter, P3P_LINK_SPEED_REG(pcifn), err)
+
+/* Mailbox ownership */
+#define QLCNIC_GET_OWNER(val)	\
+	((val) & (BIT_0 | BIT_1))
+#define QLCNIC_SET_OWNER	1
+#define QLCNIC_CLR_OWNER	0
+#define QLCNIC_MBX_TIMEOUT	10000
+
+#define QLCNIC_CMD_CONFIGURE_IP_ADDR		0x1
+#define QLCNIC_CMD_CONFIG_INTRPT		0x2
+#define QLCNIC_CMD_CREATE_RX_CTX		0x7
+#define QLCNIC_CMD_DESTROY_RX_CTX		0x8
+#define QLCNIC_CMD_CREATE_TX_CTX		0x9
+#define QLCNIC_CMD_DESTROY_TX_CTX		0xa
+#define QLCNIC_CMD_CONFIGURE_LRO		0xC
+#define QLCNIC_CMD_CONFIGURE_MAC_LEARNING	0xD
+#define QLCNIC_CMD_GET_STATISTICS		0xF
+#define QLCNIC_CMD_INTRPT_TEST			0x11
+#define QLCNIC_CMD_SET_MTU			0x12
+#define QLCNIC_CMD_READ_PHY			0x13
+#define QLCNIC_CMD_WRITE_PHY			0x14
+#define QLCNIC_CMD_READ_HW_REG			0x15
+#define QLCNIC_CMD_GET_FLOW_CTL			0x16
+#define QLCNIC_CMD_SET_FLOW_CTL			0x17
+#define QLCNIC_CMD_READ_MAX_MTU			0x18
+#define QLCNIC_CMD_READ_MAX_LRO			0x19
+#define QLCNIC_CMD_MAC_ADDRESS			0x1f
+#define QLCNIC_CMD_GET_PCI_INFO			0x20
+#define QLCNIC_CMD_GET_NIC_INFO			0x21
+#define QLCNIC_CMD_SET_NIC_INFO			0x22
+#define QLCNIC_CMD_GET_ESWITCH_CAPABILITY	0x24
+#define QLCNIC_CMD_TOGGLE_ESWITCH		0x25
+#define QLCNIC_CMD_GET_ESWITCH_STATUS		0x26
+#define QLCNIC_CMD_SET_PORTMIRRORING		0x27
+#define QLCNIC_CMD_CONFIGURE_ESWITCH		0x28
+#define QLCNIC_CMD_GET_ESWITCH_PORT_CONFIG	0x29
+#define QLCNIC_CMD_GET_ESWITCH_STATS		0x2a
+#define QLCNIC_CMD_CONFIG_PORT			0x2e
+#define QLCNIC_CMD_TEMP_SIZE			0x2f
+#define QLCNIC_CMD_GET_TEMP_HDR			0x30
+#define QLCNIC_CMD_GET_MAC_STATS		0x37
+#define QLCNIC_CMD_CONFIGURE_RSS		0x41
+#define QLCNIC_CMD_CONFIG_INTR_COAL		0x43
+#define QLCNIC_CMD_CONFIGURE_LED		0x44
+#define QLCNIC_CMD_CONFIG_MAC_VLAN		0x45
+#define QLCNIC_CMD_GET_LINK_EVENT		0x48
+#define QLCNIC_CMD_CONFIGURE_MAC_RX_MODE	0x49
+#define QLCNIC_CMD_CONFIGURE_HW_LRO		0x4A
+#define QLCNIC_CMD_INIT_NIC_FUNC		0x60
+#define QLCNIC_CMD_STOP_NIC_FUNC		0x61
+#define QLCNIC_CMD_IDC_ACK			0x63
+#define QLCNIC_CMD_SET_PORT_CONFIG		0x66
+#define QLCNIC_CMD_GET_PORT_CONFIG		0x67
+#define QLCNIC_CMD_GET_LINK_STATUS		0x68
+#define QLCNIC_CMD_SET_LED_CONFIG		0x69
+#define QLCNIC_CMD_GET_LED_CONFIG		0x6A
+
+#define QLC_TCP_HDR_SIZE            20
+#define QLC_TCP_TS_OPTION_SIZE      12
+#define QLC_TCP_TS_HDR_SIZE         (QLC_TCP_HDR_SIZE + QLC_TCP_TS_OPTION_SIZE)
+
+#define QLCNIC_INTRPT_INTX	1
+#define QLCNIC_INTRPT_MSIX	3
+#define QLCNIC_INTRPT_ADD	1
+#define QLCNIC_INTRPT_DEL	2
+
+#define QLCNIC_GET_CURRENT_MAC	1
+#define QLCNIC_SET_STATION_MAC	2
+#define QLCNIC_GET_DEFAULT_MAC	3
+#define QLCNIC_GET_FAC_DEF_MAC	4
+#define QLCNIC_SET_FAC_DEF_MAC	5
+
+#define QLCNIC_MBX_LINK_EVENT		0x8001
+#define QLCNIC_MBX_COMP_EVENT		0x8100
+#define QLCNIC_MBX_REQUEST_EVENT	0x8101
+#define QLCNIC_MBX_TIME_EXTEND_EVENT	0x8102
+#define QLCNIC_MBX_SFP_INSERT_EVENT	0x8130
+#define QLCNIC_MBX_SFP_REMOVE_EVENT	0x8131
+
+struct qlcnic_mailbox_metadata {
+	u32 cmd;
+	u32 in_args;
+	u32 out_args;
+};
 
 #define QLCNIC_BAR_LENGTH(dev_id, bar)			\
 do {							\
-	if (dev_id == PCI_DEVICE_ID_QLOGIC_QLE824X)\
-		*bar = QLCNIC_P3P_BAR0_LENGTH;		\
-	else						\
+	switch (dev_id) {				\
+	case PCI_DEVICE_ID_QLOGIC_QLE824X:		\
+		*bar = QLCNIC_82XX_BAR0_LENGTH;		\
+		break;					\
+	case PCI_DEVICE_ID_QLOGIC_QLE834X:		\
+		*bar = QLCNIC_83XX_BAR0_LENGTH;	\
+		break;					\
+	default:					\
 		*bar = 0;				\
+	}						\
 } while (0)
 
+/* Make a handle with reference handle (0:14) and RDS ring
+ * number (15).
+ */
+#define QLCNIC_MAKE_REF_HANDLE(adapter, handle, ring_id)		\
+	((adapter->pdev->device == PCI_DEVICE_ID_QLOGIC_QLE834X) ?	\
+	((handle) | ((ring_id) << 15)) : handle)
+
+#define QLCNIC_FETCH_RING_ID(handle)			\
+	((handle) >> 63)
+
 #define QLCNIC_ENABLE_INTR(adapter, crb) {		\
 	writel(1, crb);					\
 	if (!QLCNIC_IS_MSI_FAMILY(adapter))		\
@@ -25,7 +175,29 @@ do {							\
 	writel(0, crb);					\
 }
 
+#define QLCNIC_MBX_RSP_OK	1
+#define QLCNIC_MBX_PORT_RSP_OK	0x1a
+
+#define QLCNIC_MBX_RSP(reg)\
+	LSW(reg)
+#define QLCNIC_MBX_NUM_REGS(reg)\
+	(MSW(reg) & 0x1FF)
+#define QLCNIC_MBX_STATUS(reg)	\
+	(((reg) >> 25) & 0x7F)
+
+/* Mailbox registers*/
+#define QLCNIC_MBX_HOST(ahw, i)	\
+	((ahw)->pci_base0 + ((i) * 4))
+#define QLCNIC_MBX_FW(ahw, i)	\
+	((ahw)->pci_base0 + 0x800 + ((i) * 4))
+
+#define QLCNIC_IS_TSO_CAPABLE(adapter)\
+	((adapter)->ahw->capabilities & QLCNIC_FW_CAPABILITY_TSO)
 
+#define QLCNIC_IS_VLAN_TX_CAPABLE(adapter) \
+	((QLCNIC_IS_82XX(adapter)) ?\
+	((adapter)->ahw->capabilities & QLCNIC_FW_CAPABILITY_FVLANTX) :\
+	1)
 
 void qlcnic_82xx_write_crb(struct qlcnic_adapter *, char *, loff_t, size_t);
 void qlcnic_82xx_read_crb(struct qlcnic_adapter *, char *, loff_t, size_t);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
index 9691df1..2012ce3 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
@@ -200,6 +200,7 @@ int qlcnic_alloc_sw_resources(struct qlcnic_adapter *adapter)
 
 	struct qlcnic_cmd_buffer *cmd_buf_arr;
 	struct net_device *netdev = adapter->netdev;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
 	size = sizeof(struct qlcnic_host_tx_ring);
 	tx_ring = kzalloc(size, GFP_KERNEL);
@@ -243,7 +244,7 @@ int qlcnic_alloc_sw_resources(struct qlcnic_adapter *adapter)
 			rds_ring->dma_size =
 				QLCNIC_P3P_RX_JUMBO_BUF_MAX_LEN;
 
-			if (adapter->capabilities & QLCNIC_FW_CAPABILITY_HW_LRO)
+			if (ahw->capabilities & QLCNIC_FW_CAPABILITY_HW_LRO)
 				rds_ring->dma_size += QLCNIC_LRO_BUFFER_EXTRA;
 
 			rds_ring->skb_size =
@@ -652,7 +653,7 @@ qlcnic_setup_idc_param(struct qlcnic_adapter *adapter) {
 			"Not an Ethernet NIC func=%u\n", val);
 		return -EIO;
 	}
-	adapter->physical_port = (val >> 2);
+	adapter->ahw->physical_port = (val >> 2);
 	if (qlcnic_rom_fast_read(adapter, QLCNIC_ROM_DEV_INIT_TIMEOUT, &timeo))
 		timeo = QLCNIC_INIT_TIMEOUT_SECS;
 
@@ -990,10 +991,10 @@ qlcnic_get_bootld_offs(struct qlcnic_adapter *adapter)
 {
 	u32 offs = QLCNIC_BOOTLD_START;
 
-	if (adapter->fw_type == QLCNIC_UNIFIED_ROMIMAGE)
+	if (adapter->ahw->fw_type == QLCNIC_UNIFIED_ROMIMAGE)
 		offs = cpu_to_le32((qlcnic_get_data_desc(adapter,
-					QLCNIC_UNI_DIR_SECT_BOOTLD,
-					QLCNIC_UNI_BOOTLD_IDX_OFF))->findex);
+				   QLCNIC_UNI_DIR_SECT_BOOTLD,
+				   QLCNIC_UNI_BOOTLD_IDX_OFF))->findex);
 
 	return (u8 *)&adapter->fw->data[offs];
 }
@@ -1003,10 +1004,10 @@ qlcnic_get_fw_offs(struct qlcnic_adapter *adapter)
 {
 	u32 offs = QLCNIC_IMAGE_START;
 
-	if (adapter->fw_type == QLCNIC_UNIFIED_ROMIMAGE)
+	if (adapter->ahw->fw_type == QLCNIC_UNIFIED_ROMIMAGE)
 		offs = cpu_to_le32((qlcnic_get_data_desc(adapter,
-					QLCNIC_UNI_DIR_SECT_FW,
-					QLCNIC_UNI_FIRMWARE_IDX_OFF))->findex);
+				   QLCNIC_UNI_DIR_SECT_FW,
+				   QLCNIC_UNI_FIRMWARE_IDX_OFF))->findex);
 
 	return (u8 *)&adapter->fw->data[offs];
 }
@@ -1014,10 +1015,10 @@ qlcnic_get_fw_offs(struct qlcnic_adapter *adapter)
 static __le32
 qlcnic_get_fw_size(struct qlcnic_adapter *adapter)
 {
-	if (adapter->fw_type == QLCNIC_UNIFIED_ROMIMAGE)
+	if (adapter->ahw->fw_type == QLCNIC_UNIFIED_ROMIMAGE)
 		return cpu_to_le32((qlcnic_get_data_desc(adapter,
-					QLCNIC_UNI_DIR_SECT_FW,
-					QLCNIC_UNI_FIRMWARE_IDX_OFF))->size);
+				   QLCNIC_UNI_DIR_SECT_FW,
+				   QLCNIC_UNI_FIRMWARE_IDX_OFF))->size);
 	else
 		return cpu_to_le32(
 			*(u32 *)&adapter->fw->data[QLCNIC_FW_SIZE_OFFSET]);
@@ -1032,7 +1033,7 @@ qlcnic_get_fw_version(struct qlcnic_adapter *adapter)
 	const u8 *ver_str;
 	int i, ret;
 
-	if (adapter->fw_type != QLCNIC_UNIFIED_ROMIMAGE)
+	if (adapter->ahw->fw_type != QLCNIC_UNIFIED_ROMIMAGE)
 		return cpu_to_le32(*(u32 *)&fw->data[QLCNIC_FW_VERSION_OFFSET]);
 
 	fw_data_desc = qlcnic_get_data_desc(adapter, QLCNIC_UNI_DIR_SECT_FW,
@@ -1060,7 +1061,7 @@ qlcnic_get_bios_version(struct qlcnic_adapter *adapter)
 	const struct firmware *fw = adapter->fw;
 	__le32 bios_ver, prd_off = adapter->file_prd_off;
 
-	if (adapter->fw_type != QLCNIC_UNIFIED_ROMIMAGE)
+	if (adapter->ahw->fw_type != QLCNIC_UNIFIED_ROMIMAGE)
 		return cpu_to_le32(
 			*(u32 *)&fw->data[QLCNIC_BIOS_VERSION_OFFSET]);
 
@@ -1130,7 +1131,7 @@ qlcnic_load_firmware(struct qlcnic_adapter *adapter)
 	struct pci_dev *pdev = adapter->pdev;
 
 	dev_info(&pdev->dev, "loading firmware from %s\n",
-			fw_name[adapter->fw_type]);
+			fw_name[adapter->ahw->fw_type]);
 
 	if (fw) {
 		__le64 data;
@@ -1222,7 +1223,7 @@ qlcnic_validate_firmware(struct qlcnic_adapter *adapter)
 	u32 ver, bios, min_size;
 	struct pci_dev *pdev = adapter->pdev;
 	const struct firmware *fw = adapter->fw;
-	u8 fw_type = adapter->fw_type;
+	u8 fw_type = adapter->ahw->fw_type;
 
 	if (fw_type == QLCNIC_UNIFIED_ROMIMAGE) {
 		if (qlcnic_validate_unified_romimage(adapter))
@@ -1267,7 +1268,7 @@ qlcnic_get_next_fwtype(struct qlcnic_adapter *adapter)
 {
 	u8 fw_type;
 
-	switch (adapter->fw_type) {
+	switch (adapter->ahw->fw_type) {
 	case QLCNIC_UNKNOWN_ROMIMAGE:
 		fw_type = QLCNIC_UNIFIED_ROMIMAGE;
 		break;
@@ -1278,7 +1279,7 @@ qlcnic_get_next_fwtype(struct qlcnic_adapter *adapter)
 		break;
 	}
 
-	adapter->fw_type = fw_type;
+	adapter->ahw->fw_type = fw_type;
 }
 
 
@@ -1288,16 +1289,16 @@ void qlcnic_request_firmware(struct qlcnic_adapter *adapter)
 	struct pci_dev *pdev = adapter->pdev;
 	int rc;
 
-	adapter->fw_type = QLCNIC_UNKNOWN_ROMIMAGE;
+	adapter->ahw->fw_type = QLCNIC_UNKNOWN_ROMIMAGE;
 
 next:
 	qlcnic_get_next_fwtype(adapter);
 
-	if (adapter->fw_type == QLCNIC_FLASH_ROMIMAGE) {
+	if (adapter->ahw->fw_type == QLCNIC_FLASH_ROMIMAGE) {
 		adapter->fw = NULL;
 	} else {
 		rc = request_firmware(&adapter->fw,
-				fw_name[adapter->fw_type], &pdev->dev);
+				fw_name[adapter->ahw->fw_type], &pdev->dev);
 		if (rc != 0)
 			goto next;
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index bcbb3af..6f39882 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -585,7 +585,7 @@ qlcnic_handle_linkevent(struct qlcnic_adapter *adapter,
 	u8 lb_status = 0;
 	struct net_device *netdev = adapter->netdev;
 
-	adapter->has_link_events = 1;
+	adapter->ahw->has_link_events = 1;
 
 	cable_OUI = msg->body[1] & 0xffffffff;
 	cable_len = (msg->body[1] >> 32) & 0xffff;
@@ -612,13 +612,13 @@ qlcnic_handle_linkevent(struct qlcnic_adapter *adapter,
 	qlcnic_advert_link_change(adapter, link_status);
 
 	if (duplex == LINKEVENT_FULL_DUPLEX)
-		adapter->link_duplex = DUPLEX_FULL;
+		adapter->ahw->link_duplex = DUPLEX_FULL;
 	else
-		adapter->link_duplex = DUPLEX_HALF;
+		adapter->ahw->link_duplex = DUPLEX_HALF;
 
-	adapter->module_type = module;
-	adapter->link_autoneg = autoneg;
-	adapter->link_speed = link_speed;
+	adapter->ahw->module_type = module;
+	adapter->ahw->link_autoneg = autoneg;
+	adapter->ahw->link_speed = link_speed;
 }
 
 static void
@@ -656,17 +656,17 @@ qlcnic_handle_fw_message(int desc_cnt, int index,
 			break;
 		case 1:
 			dev_info(dev, "loopback already in progress\n");
-			adapter->diag_cnt = -QLCNIC_TEST_IN_PROGRESS;
+			adapter->ahw->diag_cnt = -QLCNIC_TEST_IN_PROGRESS;
 			break;
 		case 2:
 			dev_info(dev, "loopback cable is not connected\n");
-			adapter->diag_cnt = -QLCNIC_LB_CABLE_NOT_CONN;
+			adapter->ahw->diag_cnt = -QLCNIC_LB_CABLE_NOT_CONN;
 			break;
 		default:
 			dev_info(dev,
 				 "configure loopback request failed, ret %x\n",
 				 ret);
-			adapter->diag_cnt = -QLCNIC_UNDEFINED_ERROR;
+			adapter->ahw->diag_cnt = -QLCNIC_UNDEFINED_ERROR;
 			break;
 		}
 		break;
@@ -1130,7 +1130,7 @@ void qlcnic_process_rcv_diag(struct qlcnic_adapter *adapter,
 		skb_pull(skb, pkt_offset);
 
 	if (!qlcnic_check_loopback_buff(skb->data, adapter->mac_addr))
-		adapter->diag_cnt++;
+		adapter->ahw->diag_cnt++;
 	else
 		dump_skb(skb, adapter);
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 712955a..1803d53 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -125,6 +125,56 @@ static const u32 msi_tgt_status[8] = {
 	ISR_INT_TARGET_STATUS_F6, ISR_INT_TARGET_STATUS_F7
 };
 
+static const u32 qlcnic_reg_tbl[] = {
+	0x1B20A8, /* PEG_HALT_STAT1 */
+	0x1B20AC, /* PEG_HALT_STAT2 */
+	0x1B20B0, /* FW_HEARTBEAT */
+	0x1B2100, /* LOCK ID */
+	0x1B2128, /* FW_CAPABILITIES */
+	0x1B2138, /* drv active */
+	0x1B2140, /* dev state */
+	0x1B2144, /* drv state */
+	0x1B2148, /* drv scratch */
+	0x1B214C, /* dev partition info */
+	0x1B2174, /* drv idc ver */
+	0x1B2150, /* fw version major */
+	0x1B2154, /* fw version minor */
+	0x1B2158, /* fw version sub */
+	0x1B019C, /* npar state */
+	0x1B21FC, /* FW_IMG_VALID */
+	0x1B2250, /* CMD_PEG_STATE */
+	0x1B233C, /* RCV_PEG_STATE */
+	0x1B23B4, /* ASIC TEMP */
+	0x1B216C, /* FW api */
+	0x1B2170, /* drv op mode */
+	0x13C010, /* flash lock */
+	0x13C014, /* flash unlock */
+};
+
+static const struct qlcnic_brdinfo qlcnic_boards[] = {
+	{0x1077, 0x8020, 0x1077, 0x203,
+		"8200 Series Single Port 10GbE Converged Network Adapter "
+		"(TCP/IP Networking)"},
+	{0x1077, 0x8020, 0x1077, 0x207,
+		"8200 Series Dual Port 10GbE Converged Network Adapter "
+		"(TCP/IP Networking)"},
+	{0x1077, 0x8020, 0x1077, 0x20b,
+		"3200 Series Dual Port 10Gb Intelligent Ethernet Adapter"},
+	{0x1077, 0x8020, 0x1077, 0x20c,
+		"3200 Series Quad Port 1Gb Intelligent Ethernet Adapter"},
+	{0x1077, 0x8020, 0x1077, 0x20f,
+		"3200 Series Single Port 10Gb Intelligent Ethernet Adapter"},
+	{0x1077, 0x8020, 0x103c, 0x3733,
+		"NC523SFP 10Gb 2-port Server Adapter"},
+	{0x1077, 0x8020, 0x103c, 0x3346,
+		"CN1000Q Dual Port Converged Network Adapter"},
+	{0x1077, 0x8020, 0x1077, 0x210,
+		"QME8242-k 10GbE Dual Port Mezzanine Card"},
+	{0x1077, 0x8020, 0x0, 0x0, "cLOM8214 1/10GbE Controller"},
+};
+
+#define NUM_SUPPORTED_BOARDS ARRAY_SIZE(qlcnic_boards)
+
 static const
 struct qlcnic_legacy_intr_set legacy_intr[] = QLCNIC_LEGACY_INTR_CONFIG;
 
@@ -402,7 +452,7 @@ static int qlcnic_enable_msix(struct qlcnic_adapter *adapter, u32 num_msix)
 	adapter->max_sds_rings = 1;
 	adapter->flags &= ~(QLCNIC_MSI_ENABLED | QLCNIC_MSIX_ENABLED);
 
-	if (adapter->msix_supported) {
+	if (adapter->ahw->msix_supported) {
  enable_msix:
 		for (i = 0; i < num_msix; i++)
 			adapter->msix_entries[i].entry = i;
@@ -443,7 +493,7 @@ static void qlcnic_enable_msi_legacy(struct qlcnic_adapter *adapter)
 
 	legacy_intrp = &legacy_intr[adapter->ahw->pci_func];
 
-	adapter->int_vec_bit = legacy_intrp->int_vec_bit;
+	adapter->ahw->int_vec_bit = legacy_intrp->int_vec_bit;
 	offset = legacy_intrp->tgt_status_reg;
 	adapter->tgt_status_reg = qlcnic_get_ioaddr(adapter->ahw, offset);
 	adapter->tgt_mask_reg = qlcnic_get_ioaddr(adapter->ahw,
@@ -461,7 +511,7 @@ qlcnic_setup_intr(struct qlcnic_adapter *adapter)
 {
 	int num_msix, err;
 
-	if (adapter->msix_supported)
+	if (adapter->ahw->msix_supported)
 		num_msix = rounddown_pow_of_two(min_t(int, num_online_cpus(),
 				QLCNIC_DEF_NUM_STS_DESC_RINGS));
 	else
@@ -610,7 +660,7 @@ qlcnic_check_vf(struct qlcnic_adapter *adapter)
 		priv_level = QLC_DEV_GET_DRV(op_mode, ahw->pci_func);
 
 	if (priv_level == QLCNIC_NON_PRIV_FUNC) {
-		adapter->op_mode = QLCNIC_NON_PRIV_FUNC;
+		ahw->op_mode = QLCNIC_NON_PRIV_FUNC;
 		dev_info(&adapter->pdev->dev,
 			 "HAL Version: %d Non Privileged function\n",
 			 ahw->fw_hal_version);
@@ -695,7 +745,7 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 
 	adapter->fw_version = QLCNIC_VERSION_CODE(fw_major, fw_minor, fw_build);
 
-	if (adapter->op_mode != QLCNIC_NON_PRIV_FUNC) {
+	if (ahw->op_mode != QLCNIC_NON_PRIV_FUNC) {
 		if (fw_dump->tmpl_hdr == NULL ||
 				adapter->fw_version > prev_fw_version) {
 			if (fw_dump->tmpl_hdr)
@@ -727,7 +777,7 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 		adapter->max_rxd = MAX_RCV_DESCRIPTORS_1G;
 	}
 
-	adapter->msix_supported = !!use_msi_x;
+	adapter->ahw->msix_supported = !!use_msi_x;
 
 	adapter->num_txd = MAX_CMD_DESCRIPTORS;
 
@@ -744,15 +794,15 @@ qlcnic_initialize_nic(struct qlcnic_adapter *adapter)
 	if (err)
 		return err;
 
-	adapter->physical_port = (u8)nic_info.phys_port;
-	adapter->switch_mode = nic_info.switch_mode;
-	adapter->max_tx_ques = nic_info.max_tx_ques;
-	adapter->max_rx_ques = nic_info.max_rx_ques;
-	adapter->capabilities = nic_info.capabilities;
-	adapter->max_mac_filters = nic_info.max_mac_filters;
-	adapter->max_mtu = nic_info.max_mtu;
+	adapter->ahw->physical_port = (u8)nic_info.phys_port;
+	adapter->ahw->switch_mode = nic_info.switch_mode;
+	adapter->ahw->max_tx_ques = nic_info.max_tx_ques;
+	adapter->ahw->max_rx_ques = nic_info.max_rx_ques;
+	adapter->ahw->capabilities = nic_info.capabilities;
+	adapter->ahw->max_mac_filters = nic_info.max_mac_filters;
+	adapter->ahw->max_mtu = nic_info.max_mtu;
 
-	if (adapter->capabilities & BIT_6)
+	if (adapter->ahw->capabilities & BIT_6)
 		adapter->flags |= QLCNIC_ESWITCH_ENABLED;
 	else
 		adapter->flags &= ~QLCNIC_ESWITCH_ENABLED;
@@ -823,7 +873,7 @@ qlcnic_set_netdev_features(struct qlcnic_adapter *adapter,
 	vlan_features = (NETIF_F_SG | NETIF_F_IP_CSUM |
 			NETIF_F_IPV6_CSUM | NETIF_F_HW_VLAN_FILTER);
 
-	if (adapter->capabilities & QLCNIC_FW_CAPABILITY_TSO) {
+	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_TSO) {
 		features |= (NETIF_F_TSO | NETIF_F_TSO6);
 		vlan_features |= (NETIF_F_TSO | NETIF_F_TSO6);
 	}
@@ -870,7 +920,7 @@ qlcnic_check_eswitch_mode(struct qlcnic_adapter *adapter)
 
 	if (adapter->flags & QLCNIC_ESWITCH_ENABLED) {
 		if (priv_level == QLCNIC_MGMT_FUNC) {
-			adapter->op_mode = QLCNIC_MGMT_FUNC;
+			adapter->ahw->op_mode = QLCNIC_MGMT_FUNC;
 			err = qlcnic_init_pci_info(adapter);
 			if (err)
 				return err;
@@ -880,7 +930,7 @@ qlcnic_check_eswitch_mode(struct qlcnic_adapter *adapter)
 				 "HAL Version: %d, Management function\n",
 				 adapter->ahw->fw_hal_version);
 		} else if (priv_level == QLCNIC_PRIV_FUNC) {
-			adapter->op_mode = QLCNIC_PRIV_FUNC;
+			adapter->ahw->op_mode = QLCNIC_PRIV_FUNC;
 			dev_info(&adapter->pdev->dev,
 				 "HAL Version: %d, Privileged function\n",
 				 adapter->ahw->fw_hal_version);
@@ -910,7 +960,7 @@ qlcnic_set_default_offload_settings(struct qlcnic_adapter *adapter)
 		esw_cfg.offload_flags = BIT_0;
 		esw_cfg.mac_override = BIT_0;
 		esw_cfg.promisc_mode = BIT_0;
-		if (adapter->capabilities  & QLCNIC_FW_CAPABILITY_TSO)
+		if (adapter->ahw->capabilities  & QLCNIC_FW_CAPABILITY_TSO)
 			esw_cfg.offload_flags |= (BIT_1 | BIT_2);
 		if (qlcnic_config_switch_port(adapter, &esw_cfg))
 			return -EIO;
@@ -991,7 +1041,7 @@ static int qlcnic_check_npar_opertional(struct qlcnic_adapter *adapter)
 	u8 npar_opt_timeo = QLCNIC_DEV_NPAR_OPER_TIMEO;
 	u32 npar_state;
 
-	if (adapter->op_mode == QLCNIC_MGMT_FUNC)
+	if (adapter->ahw->op_mode == QLCNIC_MGMT_FUNC)
 		return 0;
 
 	npar_state = QLCRD32(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
@@ -1013,7 +1063,7 @@ qlcnic_set_mgmt_operations(struct qlcnic_adapter *adapter)
 	int err;
 
 	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED) ||
-		    adapter->op_mode != QLCNIC_MGMT_FUNC)
+		    adapter->ahw->op_mode != QLCNIC_MGMT_FUNC)
 		return 0;
 
 	err = qlcnic_set_default_offload_settings(adapter);
@@ -1047,7 +1097,7 @@ qlcnic_82xx_start_firmware(struct qlcnic_adapter *adapter)
 		if (err)
 			goto err_out;
 
-		adapter->fw_type = QLCNIC_FLASH_ROMIMAGE;
+		adapter->ahw->fw_type = QLCNIC_FLASH_ROMIMAGE;
 	}
 
 	err = qlcnic_need_fw_reset(adapter);
@@ -1108,7 +1158,7 @@ qlcnic_request_irq(struct qlcnic_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 
-	if (adapter->diag_test == QLCNIC_INTERRUPT_TEST) {
+	if (adapter->ahw->diag_test == QLCNIC_INTERRUPT_TEST) {
 		handler = qlcnic_tmp_intr;
 		if (!QLCNIC_IS_MSI_FAMILY(adapter))
 			flags |= IRQF_SHARED;
@@ -1167,7 +1217,7 @@ __qlcnic_up(struct qlcnic_adapter *adapter, struct net_device *netdev)
 	if (qlcnic_set_eswitch_port_config(adapter))
 		return -EIO;
 
-	if (adapter->capabilities & QLCNIC_FW_CAPABILITY_MORE_CAPS) {
+	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_MORE_CAPS) {
 		capab2 = QLCRD32(adapter, CRB_FW_CAPABILITIES_2);
 		if (capab2 & QLCNIC_FW_CAPABILITY_2_LRO_MAX_TCP_SEG)
 			adapter->flags |= QLCNIC_FW_LRO_MSS_CAP;
@@ -1198,7 +1248,7 @@ __qlcnic_up(struct qlcnic_adapter *adapter, struct net_device *netdev)
 
 	qlcnic_linkevent_request(adapter, 1);
 
-	adapter->reset_context = 0;
+	adapter->ahw->reset_context = 0;
 	set_bit(__QLCNIC_DEV_UP, &adapter->state);
 	return 0;
 }
@@ -1331,7 +1381,7 @@ void qlcnic_diag_free_res(struct net_device *netdev, int max_sds_rings)
 	int ring;
 
 	clear_bit(__QLCNIC_DEV_UP, &adapter->state);
-	if (adapter->diag_test == QLCNIC_INTERRUPT_TEST) {
+	if (adapter->ahw->diag_test == QLCNIC_INTERRUPT_TEST) {
 		for (ring = 0; ring < adapter->max_sds_rings; ring++) {
 			sds_ring = &adapter->recv_ctx->sds_rings[ring];
 			QLCNIC_DISABLE_INTR(sds_ring->crb_intr_mask);
@@ -1342,7 +1392,7 @@ void qlcnic_diag_free_res(struct net_device *netdev, int max_sds_rings)
 
 	qlcnic_detach(adapter);
 
-	adapter->diag_test = 0;
+	adapter->ahw->diag_test = 0;
 	adapter->max_sds_rings = max_sds_rings;
 
 	if (qlcnic_attach(adapter))
@@ -1402,7 +1452,7 @@ int qlcnic_diag_alloc_res(struct net_device *netdev, int test)
 	qlcnic_detach(adapter);
 
 	adapter->max_sds_rings = 1;
-	adapter->diag_test = test;
+	adapter->ahw->diag_test = test;
 
 	ret = qlcnic_attach(adapter);
 	if (ret) {
@@ -1422,14 +1472,14 @@ int qlcnic_diag_alloc_res(struct net_device *netdev, int test)
 		qlcnic_post_rx_buffers(adapter, rds_ring);
 	}
 
-	if (adapter->diag_test == QLCNIC_INTERRUPT_TEST) {
+	if (adapter->ahw->diag_test == QLCNIC_INTERRUPT_TEST) {
 		for (ring = 0; ring < adapter->max_sds_rings; ring++) {
 			sds_ring = &adapter->recv_ctx->sds_rings[ring];
 			QLCNIC_ENABLE_INTR(adapter, sds_ring->crb_intr_mask);
 		}
 	}
 
-	if (adapter->diag_test == QLCNIC_LOOPBACK_TEST) {
+	if (adapter->ahw->diag_test == QLCNIC_LOOPBACK_TEST) {
 		adapter->ahw->loopback_state = 0;
 		qlcnic_linkevent_request(adapter, 1);
 	}
@@ -1500,11 +1550,11 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter,
 	int err;
 	struct pci_dev *pdev = adapter->pdev;
 
-	adapter->mc_enabled = 0;
-	adapter->max_mc_count = 38;
+	adapter->ahw->mc_enabled = 0;
+	adapter->ahw->max_mc_count = QLCNIC_MAX_MC_COUNT;
 
 	netdev->netdev_ops	   = &qlcnic_netdev_ops;
-	netdev->watchdog_timeo     = 5*HZ;
+	netdev->watchdog_timeo     = QLCNIC_WATCHDOG_TIMEOUTVALUE*HZ;
 
 	qlcnic_change_mtu(netdev, netdev->mtu);
 
@@ -1513,16 +1563,16 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter,
 	netdev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM |
 		NETIF_F_IPV6_CSUM | NETIF_F_RXCSUM;
 
-	if (adapter->capabilities & QLCNIC_FW_CAPABILITY_TSO)
+	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_TSO)
 		netdev->hw_features |= NETIF_F_TSO | NETIF_F_TSO6;
 	if (pci_using_dac)
 		netdev->hw_features |= NETIF_F_HIGHDMA;
 
 	netdev->vlan_features = netdev->hw_features;
 
-	if (adapter->capabilities & QLCNIC_FW_CAPABILITY_FVLANTX)
+	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_FVLANTX)
 		netdev->hw_features |= NETIF_F_HW_VLAN_TX;
-	if (adapter->capabilities & QLCNIC_FW_CAPABILITY_HW_LRO)
+	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_HW_LRO)
 		netdev->hw_features |= NETIF_F_LRO;
 
 	netdev->features |= netdev->hw_features |
@@ -1953,7 +2003,7 @@ static int qlcnic_check_temp(struct qlcnic_adapter *adapter)
 		       temp_val);
 		rv = 1;
 	} else if (temp_state == QLCNIC_TEMP_WARN) {
-		if (adapter->temp == QLCNIC_TEMP_NORMAL) {
+		if (adapter->ahw->temp == QLCNIC_TEMP_NORMAL) {
 			dev_err(&netdev->dev,
 			       "Device temperature %d degrees C "
 			       "exceeds operating range."
@@ -1961,13 +2011,13 @@ static int qlcnic_check_temp(struct qlcnic_adapter *adapter)
 			       temp_val);
 		}
 	} else {
-		if (adapter->temp == QLCNIC_TEMP_WARN) {
+		if (adapter->ahw->temp == QLCNIC_TEMP_WARN) {
 			dev_info(&netdev->dev,
 			       "Device temperature is now %d degrees C"
 			       " in normal range.\n", temp_val);
 		}
 	}
-	adapter->temp = temp_state;
+	adapter->ahw->temp = temp_state;
 	return rv;
 }
 
@@ -1983,7 +2033,7 @@ static void qlcnic_tx_timeout(struct net_device *netdev)
 	if (++adapter->tx_timeo_cnt >= QLCNIC_MAX_TX_TIMEOUTS)
 		adapter->need_fw_reset = 1;
 	else
-		adapter->reset_context = 1;
+		adapter->ahw->reset_context = 1;
 }
 
 static struct net_device_stats *qlcnic_get_stats(struct net_device *netdev)
@@ -2007,7 +2057,7 @@ static irqreturn_t qlcnic_clear_legacy_intr(struct qlcnic_adapter *adapter)
 
 	status = readl(adapter->isr_int_vec);
 
-	if (!(status & adapter->int_vec_bit))
+	if (!(status & adapter->ahw->int_vec_bit))
 		return IRQ_NONE;
 
 	/* check interrupt state machine, to be sure */
@@ -2039,7 +2089,7 @@ static irqreturn_t qlcnic_tmp_intr(int irq, void *data)
 		return IRQ_NONE;
 
 done:
-	adapter->diag_cnt++;
+	adapter->ahw->diag_cnt++;
 	QLCNIC_ENABLE_INTR(adapter, sds_ring->crb_intr_mask);
 	return IRQ_HANDLED;
 }
@@ -2322,7 +2372,7 @@ qlcnic_fwinit_work(struct work_struct *work)
 		return;
 	}
 
-	if (adapter->op_mode == QLCNIC_NON_PRIV_FUNC) {
+	if (adapter->ahw->op_mode == QLCNIC_NON_PRIV_FUNC) {
 		qlcnic_api_unlock(adapter);
 		goto wait_npar;
 	}
@@ -2438,9 +2488,9 @@ qlcnic_detach_work(struct work_struct *work)
 		goto err_ret;
 	}
 
-	if (adapter->temp == QLCNIC_TEMP_PANIC) {
+	if (adapter->ahw->temp == QLCNIC_TEMP_PANIC) {
 		dev_err(&adapter->pdev->dev, "Detaching the device: temp=%d\n",
-			adapter->temp);
+			adapter->ahw->temp);
 		goto err_ret;
 	}
 
@@ -2566,7 +2616,7 @@ qlcnic_attach_work(struct work_struct *work)
 	struct net_device *netdev = adapter->netdev;
 	u32 npar_state;
 
-	if (adapter->op_mode != QLCNIC_MGMT_FUNC) {
+	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC) {
 		npar_state = QLCRD32(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
 		if (adapter->fw_wait_cnt++ > QLCNIC_DEV_NPAR_OPER_TIMEO)
 			qlcnic_clr_all_drv_state(adapter, 0);
@@ -2623,7 +2673,7 @@ qlcnic_check_health(struct qlcnic_adapter *adapter)
 		if (adapter->need_fw_reset)
 			goto detach;
 
-		if (adapter->reset_context && auto_fw_reset) {
+		if (adapter->ahw->reset_context && auto_fw_reset) {
 			qlcnic_reset_hw_context(adapter);
 			adapter->netdev->trans_start = jiffies;
 		}
@@ -2718,6 +2768,7 @@ static int qlcnic_attach_func(struct pci_dev *pdev)
 {
 	int err, first_func;
 	struct qlcnic_adapter *adapter = pci_get_drvdata(pdev);
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	struct net_device *netdev = adapter->netdev;
 
 	pdev->error_state = pci_channel_io_normal;
@@ -2735,7 +2786,7 @@ static int qlcnic_attach_func(struct pci_dev *pdev)
 	if (qlcnic_api_lock(adapter))
 		return -EINVAL;
 
-	if (adapter->op_mode != QLCNIC_NON_PRIV_FUNC && first_func) {
+	if (ahw->op_mode != QLCNIC_NON_PRIV_FUNC && first_func) {
 		adapter->need_fw_reset = 1;
 		set_bit(__QLCNIC_START_FW, &adapter->state);
 		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_INITIALIZING);
@@ -2869,7 +2920,7 @@ qlcnic_store_bridged_mode(struct device *dev,
 	unsigned long new;
 	int ret = -EINVAL;
 
-	if (!(adapter->capabilities & QLCNIC_FW_CAPABILITY_BDG))
+	if (!(adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_BDG))
 		goto err_out;
 
 	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state))
@@ -2892,7 +2943,7 @@ qlcnic_show_bridged_mode(struct device *dev,
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 	int bridged_mode = 0;
 
-	if (adapter->capabilities & QLCNIC_FW_CAPABILITY_BDG)
+	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_BDG)
 		bridged_mode = !!(adapter->flags & QLCNIC_BRIDGE_ENABLED);
 
 	return sprintf(buf, "%d\n", bridged_mode);
@@ -3019,7 +3070,7 @@ qlcnic_store_beacon(struct device *dev,
 	u8 b_state, b_rate;
 	int err;
 
-	if (adapter->op_mode == QLCNIC_NON_PRIV_FUNC) {
+	if (adapter->ahw->op_mode == QLCNIC_NON_PRIV_FUNC) {
 		dev_warn(dev, "LED test not supported for non "
 				"privilege function\n");
 		return -EOPNOTSUPP;
@@ -3328,7 +3379,7 @@ validate_esw_config(struct qlcnic_adapter *adapter,
 		if (pci_func >= QLCNIC_MAX_PCI_FUNC)
 			return QL_STATUS_INVALID_PARAM;
 
-		if (adapter->op_mode == QLCNIC_MGMT_FUNC)
+		if (adapter->ahw->op_mode == QLCNIC_MGMT_FUNC)
 			if (adapter->npars[pci_func].type != QLCNIC_TYPE_NIC)
 				return QL_STATUS_INVALID_PARAM;
 
@@ -3383,7 +3434,7 @@ qlcnic_sysfs_write_esw_config(struct file *file, struct kobject *kobj,
 		return ret;
 
 	for (i = 0; i < count; i++) {
-		if (adapter->op_mode == QLCNIC_MGMT_FUNC)
+		if (adapter->ahw->op_mode == QLCNIC_MGMT_FUNC)
 			if (qlcnic_config_switch_port(adapter, &esw_cfg[i]))
 				return QL_STATUS_INVALID_PARAM;
 
@@ -3409,7 +3460,7 @@ qlcnic_sysfs_write_esw_config(struct file *file, struct kobject *kobj,
 		}
 	}
 
-	if (adapter->op_mode != QLCNIC_MGMT_FUNC)
+	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC)
 		goto out;
 
 	for (i = 0; i < count; i++) {
@@ -3743,7 +3794,7 @@ qlcnic_create_sysfs_entries(struct qlcnic_adapter *adapter)
 {
 	struct device *dev = &adapter->pdev->dev;
 
-	if (adapter->capabilities & QLCNIC_FW_CAPABILITY_BDG)
+	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_BDG)
 		if (device_create_file(dev, &dev_attr_bridged_mode))
 			dev_warn(dev,
 				"failed to create bridged_mode sysfs entry\n");
@@ -3754,7 +3805,7 @@ qlcnic_remove_sysfs_entries(struct qlcnic_adapter *adapter)
 {
 	struct device *dev = &adapter->pdev->dev;
 
-	if (adapter->capabilities & QLCNIC_FW_CAPABILITY_BDG)
+	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_BDG)
 		device_remove_file(dev, &dev_attr_bridged_mode);
 }
 
@@ -3767,7 +3818,7 @@ qlcnic_create_diag_entries(struct qlcnic_adapter *adapter)
 	if (device_create_bin_file(dev, &bin_attr_port_stats))
 		dev_info(dev, "failed to create port stats sysfs entry");
 
-	if (adapter->op_mode == QLCNIC_NON_PRIV_FUNC)
+	if (adapter->ahw->op_mode == QLCNIC_NON_PRIV_FUNC)
 		return;
 	if (device_create_file(dev, &dev_attr_diag_mode))
 		dev_info(dev, "failed to create diag_mode sysfs entry\n");
@@ -3788,7 +3839,7 @@ qlcnic_create_diag_entries(struct qlcnic_adapter *adapter)
 		return;
 	if (device_create_bin_file(dev, &bin_attr_esw_config))
 		dev_info(dev, "failed to create esw config sysfs entry");
-	if (adapter->op_mode != QLCNIC_MGMT_FUNC)
+	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC)
 		return;
 	if (device_create_bin_file(dev, &bin_attr_npar_config))
 		dev_info(dev, "failed to create npar config sysfs entry");
@@ -3806,7 +3857,7 @@ qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter)
 
 	device_remove_bin_file(dev, &bin_attr_port_stats);
 
-	if (adapter->op_mode == QLCNIC_NON_PRIV_FUNC)
+	if (adapter->ahw->op_mode == QLCNIC_NON_PRIV_FUNC)
 		return;
 	device_remove_file(dev, &dev_attr_diag_mode);
 	device_remove_bin_file(dev, &bin_attr_crb);
@@ -3818,7 +3869,7 @@ qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter)
 	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED))
 		return;
 	device_remove_bin_file(dev, &bin_attr_esw_config);
-	if (adapter->op_mode != QLCNIC_MGMT_FUNC)
+	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC)
 		return;
 	device_remove_bin_file(dev, &bin_attr_npar_config);
 	device_remove_bin_file(dev, &bin_attr_pm_config);
-- 
1.7.1
