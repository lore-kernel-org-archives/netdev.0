From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH net-next 04/15] qlcnic: Refactoring - Moving hw specific data to hardware context
Date: Thu, 23 Aug 2012 21:07:08 -0400
Message-ID: <1345770439-30517-5-git-send-email-sony.chacko@qlogic.com>
References: <1345770439-30517-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:34289 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755021Ab2HXBYH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 21:24:07 -0400
In-Reply-To: <1345770439-30517-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>

Modify 82xx driver to support new adapter - Qlogic 83XX CNA
Group all the HW data in a seperate data structure

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |   62 ++++++-------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c    |   25 +++---
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   69 +++++++-------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h    |    3 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c   |   29 +++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     |   20 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   94 ++++++++++----------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c  |   22 +++---
 9 files changed, 164 insertions(+), 162 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 7f1a3e1..86e6a80 100644
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
 
+	u16 op_mode;
+	u16 switch_mode;
+	u16 max_tx_ques;
+	u16 max_rx_ques;
+	u16 max_mtu;
+	u16 msg_enable;
+
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
@@ -996,49 +1022,22 @@ struct qlcnic_adapter {
 
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
 
@@ -1062,7 +1061,6 @@ struct qlcnic_adapter {
 
 	struct delayed_work fw_work;
 
-
 	struct qlcnic_filter_hash fhash;
 
 	spinlock_t tx_clean_lock;
@@ -1658,7 +1656,7 @@ struct qlcnic_hardware_ops {
 };
 
 #define QLCDB(adapter, lvl, _fmt, _args...) do {	\
-	if (NETIF_MSG_##lvl & adapter->msg_enable)	\
+	if (NETIF_MSG_##lvl & adapter->ahw->msg_enable)	\
 		printk(KERN_INFO "%s: %s: " _fmt,	\
 			 dev_name(&adapter->pdev->dev),	\
 			__func__, ##_args);		\
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index c9be09b..c79bc9a 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -452,8 +452,7 @@ qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter)
 		temp = le32_to_cpu(prsp->cds_ring.host_producer_crb);
 		tx_ring->crb_cmd_producer = adapter->ahw->pci_base0 + temp;
 
-		adapter->tx_context_id =
-			le16_to_cpu(prsp->context_id);
+		tx_ring->ctx_id = le16_to_cpu(prsp->context_id);
 	} else {
 		dev_err(&adapter->pdev->dev,
 			"Failed to create tx ctx in firmware%d\n", err);
@@ -475,7 +474,7 @@ qlcnic_fw_cmd_destroy_tx_ctx(struct qlcnic_adapter *adapter)
 	struct qlcnic_cmd_args cmd;
 
 	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.arg1 = adapter->tx_context_id;
+	cmd.req.arg1 = adapter->tx_ring->ctx_id;
 	cmd.req.arg2 = QLCNIC_DESTROY_CTX_RESET;
 	cmd.req.arg3 = 0;
 	cmd.req.cmd = QLCNIC_CDRP_CMD_DESTROY_TX_CTX;
@@ -755,7 +754,7 @@ int qlcnic_set_nic_info(struct qlcnic_adapter *adapter, struct qlcnic_info *nic)
 	struct qlcnic_info *nic_info;
 	size_t nic_size = sizeof(struct qlcnic_info);
 
-	if (adapter->op_mode != QLCNIC_MGMT_FUNC)
+	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC)
 		return err;
 
 	nic_info_addr = dma_alloc_coherent(&adapter->pdev->dev, nic_size,
@@ -855,7 +854,7 @@ int qlcnic_config_port_mirroring(struct qlcnic_adapter *adapter, u8 id,
 	u32 arg1;
 	struct qlcnic_cmd_args cmd;
 
-	if (adapter->op_mode != QLCNIC_MGMT_FUNC ||
+	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC ||
 		!(adapter->eswitch[id].flags & QLCNIC_SWITCH_ENABLE))
 		return err;
 
@@ -895,8 +894,8 @@ int qlcnic_get_port_stats(struct qlcnic_adapter *adapter, const u8 func,
 	if (esw_stats == NULL)
 		return -ENOMEM;
 
-	if (adapter->op_mode != QLCNIC_MGMT_FUNC &&
-	    func != adapter->ahw->pci_func) {
+	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC &&
+		func != adapter->ahw->pci_func) {
 		dev_err(&adapter->pdev->dev,
 			"Not privilege to query stats for func=%d", func);
 		return -EIO;
@@ -1007,7 +1006,7 @@ int qlcnic_get_eswitch_stats(struct qlcnic_adapter *adapter, const u8 eswitch,
 
 	if (esw_stats == NULL)
 		return -ENOMEM;
-	if (adapter->op_mode != QLCNIC_MGMT_FUNC)
+	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC)
 		return -EIO;
 	if (adapter->npars == NULL)
 		return -EIO;
@@ -1058,7 +1057,7 @@ int qlcnic_clear_esw_stats(struct qlcnic_adapter *adapter, const u8 func_esw,
 	u32 arg1;
 	struct qlcnic_cmd_args cmd;
 
-	if (adapter->op_mode != QLCNIC_MGMT_FUNC)
+	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC)
 		return -EIO;
 
 	if (func_esw == QLCNIC_STATS_PORT) {
@@ -1131,7 +1130,7 @@ int qlcnic_config_switch_port(struct qlcnic_adapter *adapter,
 	struct qlcnic_cmd_args cmd;
 	u8 pci_func;
 
-	if (adapter->op_mode != QLCNIC_MGMT_FUNC)
+	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC)
 		return err;
 	pci_func = esw_cfg->pci_func;
 	arg1 = (adapter->npars[pci_func].phy_port & BIT_0);
@@ -1146,7 +1145,7 @@ int qlcnic_config_switch_port(struct qlcnic_adapter *adapter,
 	case QLCNIC_PORT_DEFAULTS:
 		arg1 |= (BIT_4 | BIT_6 | BIT_7);
 		arg2 |= (BIT_0 | BIT_1);
-		if (adapter->capabilities & QLCNIC_FW_CAPABILITY_TSO)
+		if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_TSO)
 			arg2 |= (BIT_2 | BIT_3);
 		if (!(esw_cfg->discard_tagged))
 			arg1 &= ~BIT_4;
@@ -1199,10 +1198,10 @@ qlcnic_get_eswitch_port_config(struct qlcnic_adapter *adapter,
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
index a114d9f..ec2ad45 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -209,9 +209,9 @@ qlcnic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
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
@@ -225,10 +225,10 @@ qlcnic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
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
 
@@ -239,7 +239,7 @@ qlcnic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		return -EIO;
 
 skip:
-	ecmd->phy_address = adapter->physical_port;
+	ecmd->phy_address = adapter->ahw->physical_port;
 	ecmd->transceiver = XCVR_EXTERNAL;
 
 	switch (ahw->board_type) {
@@ -255,7 +255,7 @@ skip:
 		ecmd->supported |= SUPPORTED_TP;
 		ecmd->advertising |= ADVERTISED_TP;
 		ecmd->port = PORT_TP;
-		ecmd->autoneg =  adapter->link_autoneg;
+		ecmd->autoneg =  ahw->link_autoneg;
 		break;
 	case QLCNIC_BRDTYPE_P3P_IMEZ:
 	case QLCNIC_BRDTYPE_P3P_XG_LOM:
@@ -271,7 +271,7 @@ skip:
 		ecmd->advertising |= ADVERTISED_TP;
 		ecmd->supported |= SUPPORTED_TP;
 		check_sfp_module = netif_running(dev) &&
-			adapter->has_link_events;
+			ahw->has_link_events;
 	case QLCNIC_BRDTYPE_P3P_10G_XFP:
 		ecmd->supported |= SUPPORTED_FIBRE;
 		ecmd->advertising |= ADVERTISED_FIBRE;
@@ -286,7 +286,7 @@ skip:
 				(ADVERTISED_FIBRE | ADVERTISED_TP);
 			ecmd->port = PORT_FIBRE;
 			check_sfp_module = netif_running(dev) &&
-				adapter->has_link_events;
+				ahw->has_link_events;
 		} else {
 			ecmd->autoneg = AUTONEG_ENABLE;
 			ecmd->supported |= (SUPPORTED_TP | SUPPORTED_Autoneg);
@@ -302,7 +302,7 @@ skip:
 	}
 
 	if (check_sfp_module) {
-		switch (adapter->module_type) {
+		switch (adapter->ahw->module_type) {
 		case LINKEVENT_MODULE_OPTICAL_UNKNOWN:
 		case LINKEVENT_MODULE_OPTICAL_SRLR:
 		case LINKEVENT_MODULE_OPTICAL_LRM:
@@ -360,9 +360,9 @@ qlcnic_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
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
@@ -513,11 +513,11 @@ static void qlcnic_get_channels(struct net_device *dev,
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
@@ -546,7 +546,7 @@ qlcnic_get_pauseparam(struct net_device *netdev,
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
-	int port = adapter->physical_port;
+	int port = adapter->ahw->physical_port;
 	__u32 val;
 
 	if (ahw->port_type == QLCNIC_GBE) {
@@ -592,7 +592,7 @@ qlcnic_set_pauseparam(struct net_device *netdev,
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
-	int port = adapter->physical_port;
+	int port = adapter->ahw->physical_port;
 	__u32 val;
 
 	/* read mode */
@@ -706,7 +706,7 @@ static int qlcnic_irq_test(struct net_device *netdev)
 	if (ret)
 		goto clear_it;
 
-	adapter->diag_cnt = 0;
+	adapter->ahw->diag_cnt = 0;
 	memset(&cmd, 0, sizeof(cmd));
 	cmd.req.cmd = QLCNIC_CDRP_CMD_INTRPT_TEST;
 	cmd.req.arg1 = adapter->ahw->pci_func;
@@ -718,7 +718,7 @@ static int qlcnic_irq_test(struct net_device *netdev)
 
 	msleep(10);
 
-	ret = !adapter->diag_cnt;
+	ret = !adapter->ahw->diag_cnt;
 
 done:
 	qlcnic_diag_free_res(netdev, max_sds_rings);
@@ -764,7 +764,7 @@ static int qlcnic_do_lb_test(struct qlcnic_adapter *adapter, u8 mode)
 		qlcnic_create_loopback_buff(skb->data, adapter->mac_addr);
 		skb_put(skb, QLCNIC_ILB_PKT_SIZE);
 
-		adapter->diag_cnt = 0;
+		adapter->ahw->diag_cnt = 0;
 		qlcnic_xmit_frame(skb, adapter->netdev);
 
 		loop = 0;
@@ -773,11 +773,11 @@ static int qlcnic_do_lb_test(struct qlcnic_adapter *adapter, u8 mode)
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
@@ -799,18 +799,19 @@ static int qlcnic_loopback_test(struct net_device *netdev, u8 mode)
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
@@ -829,7 +830,7 @@ static int qlcnic_loopback_test(struct net_device *netdev, u8 mode)
 	if (ret)
 		goto free_res;
 
-	adapter->diag_cnt = 0;
+	ahw->diag_cnt = 0;
 	do {
 		msleep(500);
 		qlcnic_process_rcv_ring_diag(sds_ring);
@@ -838,11 +839,11 @@ static int qlcnic_loopback_test(struct net_device *netdev, u8 mode)
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
 
@@ -1031,7 +1032,7 @@ static int qlcnic_set_led(struct net_device *dev,
 	int max_sds_rings = adapter->max_sds_rings;
 	int err = -EIO, active = 1;
 
-	if (adapter->op_mode == QLCNIC_NON_PRIV_FUNC) {
+	if (adapter->ahw->op_mode == QLCNIC_NON_PRIV_FUNC) {
 		netdev_warn(dev, "LED test not supported for non "
 				"privilege function\n");
 		return -EOPNOTSUPP;
@@ -1210,14 +1211,14 @@ static u32 qlcnic_get_msglevel(struct net_device *netdev)
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
index 0bee9f7..92cd3c3 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
@@ -715,6 +715,9 @@ enum {
 #define QLCNIC_HEARTBEAT_PERIOD_MSECS	200
 #define QLCNIC_HEARTBEAT_CHECK_RETRY_COUNT	45
 
+#define QLCNIC_MAX_MC_COUNT		38
+#define QLCNIC_WATCHDOG_TIMEOUTVALUE	5
+
 #define	ISR_MSI_INT_TRIGGER(FUNC) (QLCNIC_PCIX_PS_REG(PCIX_MSI_F(FUNC)))
 #define ISR_LEGACY_INT_TRIGGERED(VAL)	(((VAL) & 0x300) == 0x200)
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index 2f42d3e..7e943db 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -442,7 +442,7 @@ void qlcnic_set_multi(struct net_device *netdev)
 	}
 
 	if ((netdev->flags & IFF_ALLMULTI) ||
-	    (netdev_mc_count(netdev) > adapter->max_mc_count)) {
+	    (netdev_mc_count(netdev) > adapter->ahw->max_mc_count)) {
 		mode = VPORT_MISS_MODE_ACCEPT_MULTI;
 		goto send_fw_cmd;
 	}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
index 8abd7d9..5a1704e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
@@ -199,6 +199,7 @@ int qlcnic_alloc_sw_resources(struct qlcnic_adapter *adapter)
 
 	struct qlcnic_cmd_buffer *cmd_buf_arr;
 	struct net_device *netdev = adapter->netdev;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
 	size = sizeof(struct qlcnic_host_tx_ring);
 	tx_ring = kzalloc(size, GFP_KERNEL);
@@ -242,7 +243,7 @@ int qlcnic_alloc_sw_resources(struct qlcnic_adapter *adapter)
 			rds_ring->dma_size =
 				QLCNIC_P3P_RX_JUMBO_BUF_MAX_LEN;
 
-			if (adapter->capabilities & QLCNIC_FW_CAPABILITY_HW_LRO)
+			if (ahw->capabilities & QLCNIC_FW_CAPABILITY_HW_LRO)
 				rds_ring->dma_size += QLCNIC_LRO_BUFFER_EXTRA;
 
 			rds_ring->skb_size =
@@ -651,7 +652,7 @@ qlcnic_setup_idc_param(struct qlcnic_adapter *adapter) {
 			"Not an Ethernet NIC func=%u\n", val);
 		return -EIO;
 	}
-	adapter->physical_port = (val >> 2);
+	adapter->ahw->physical_port = (val >> 2);
 	if (qlcnic_rom_fast_read(adapter, QLCNIC_ROM_DEV_INIT_TIMEOUT, &timeo))
 		timeo = QLCNIC_INIT_TIMEOUT_SECS;
 
@@ -989,7 +990,7 @@ qlcnic_get_bootld_offs(struct qlcnic_adapter *adapter)
 {
 	u32 offs = QLCNIC_BOOTLD_START;
 
-	if (adapter->fw_type == QLCNIC_UNIFIED_ROMIMAGE)
+	if (adapter->ahw->fw_type == QLCNIC_UNIFIED_ROMIMAGE)
 		offs = cpu_to_le32((qlcnic_get_data_desc(adapter,
 					QLCNIC_UNI_DIR_SECT_BOOTLD,
 					QLCNIC_UNI_BOOTLD_IDX_OFF))->findex);
@@ -1002,7 +1003,7 @@ qlcnic_get_fw_offs(struct qlcnic_adapter *adapter)
 {
 	u32 offs = QLCNIC_IMAGE_START;
 
-	if (adapter->fw_type == QLCNIC_UNIFIED_ROMIMAGE)
+	if (adapter->ahw->fw_type == QLCNIC_UNIFIED_ROMIMAGE)
 		offs = cpu_to_le32((qlcnic_get_data_desc(adapter,
 					QLCNIC_UNI_DIR_SECT_FW,
 					QLCNIC_UNI_FIRMWARE_IDX_OFF))->findex);
@@ -1013,7 +1014,7 @@ qlcnic_get_fw_offs(struct qlcnic_adapter *adapter)
 static __le32
 qlcnic_get_fw_size(struct qlcnic_adapter *adapter)
 {
-	if (adapter->fw_type == QLCNIC_UNIFIED_ROMIMAGE)
+	if (adapter->ahw->fw_type == QLCNIC_UNIFIED_ROMIMAGE)
 		return cpu_to_le32((qlcnic_get_data_desc(adapter,
 					QLCNIC_UNI_DIR_SECT_FW,
 					QLCNIC_UNI_FIRMWARE_IDX_OFF))->size);
@@ -1031,7 +1032,7 @@ qlcnic_get_fw_version(struct qlcnic_adapter *adapter)
 	const u8 *ver_str;
 	int i, ret;
 
-	if (adapter->fw_type != QLCNIC_UNIFIED_ROMIMAGE)
+	if (adapter->ahw->fw_type != QLCNIC_UNIFIED_ROMIMAGE)
 		return cpu_to_le32(*(u32 *)&fw->data[QLCNIC_FW_VERSION_OFFSET]);
 
 	fw_data_desc = qlcnic_get_data_desc(adapter, QLCNIC_UNI_DIR_SECT_FW,
@@ -1059,7 +1060,7 @@ qlcnic_get_bios_version(struct qlcnic_adapter *adapter)
 	const struct firmware *fw = adapter->fw;
 	__le32 bios_ver, prd_off = adapter->file_prd_off;
 
-	if (adapter->fw_type != QLCNIC_UNIFIED_ROMIMAGE)
+	if (adapter->ahw->fw_type != QLCNIC_UNIFIED_ROMIMAGE)
 		return cpu_to_le32(
 			*(u32 *)&fw->data[QLCNIC_BIOS_VERSION_OFFSET]);
 
@@ -1129,7 +1130,7 @@ qlcnic_load_firmware(struct qlcnic_adapter *adapter)
 	struct pci_dev *pdev = adapter->pdev;
 
 	dev_info(&pdev->dev, "loading firmware from %s\n",
-			fw_name[adapter->fw_type]);
+			fw_name[adapter->ahw->fw_type]);
 
 	if (fw) {
 		__le64 data;
@@ -1221,7 +1222,7 @@ qlcnic_validate_firmware(struct qlcnic_adapter *adapter)
 	u32 ver, bios, min_size;
 	struct pci_dev *pdev = adapter->pdev;
 	const struct firmware *fw = adapter->fw;
-	u8 fw_type = adapter->fw_type;
+	u8 fw_type = adapter->ahw->fw_type;
 
 	if (fw_type == QLCNIC_UNIFIED_ROMIMAGE) {
 		if (qlcnic_validate_unified_romimage(adapter))
@@ -1266,7 +1267,7 @@ qlcnic_get_next_fwtype(struct qlcnic_adapter *adapter)
 {
 	u8 fw_type;
 
-	switch (adapter->fw_type) {
+	switch (adapter->ahw->fw_type) {
 	case QLCNIC_UNKNOWN_ROMIMAGE:
 		fw_type = QLCNIC_UNIFIED_ROMIMAGE;
 		break;
@@ -1277,7 +1278,7 @@ qlcnic_get_next_fwtype(struct qlcnic_adapter *adapter)
 		break;
 	}
 
-	adapter->fw_type = fw_type;
+	adapter->ahw->fw_type = fw_type;
 }
 
 
@@ -1287,16 +1288,16 @@ void qlcnic_request_firmware(struct qlcnic_adapter *adapter)
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
index 8f5ee9f..03b5e3e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -580,7 +580,7 @@ qlcnic_handle_linkevent(struct qlcnic_adapter *adapter,
 	u8 lb_status = 0;
 	struct net_device *netdev = adapter->netdev;
 
-	adapter->has_link_events = 1;
+	adapter->ahw->has_link_events = 1;
 
 	cable_OUI = msg->body[1] & 0xffffffff;
 	cable_len = (msg->body[1] >> 32) & 0xffff;
@@ -607,13 +607,13 @@ qlcnic_handle_linkevent(struct qlcnic_adapter *adapter,
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
@@ -651,17 +651,17 @@ qlcnic_handle_fw_message(int desc_cnt, int index,
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
@@ -1124,7 +1124,7 @@ void qlcnic_process_rcv_diag(struct qlcnic_adapter *adapter,
 		skb_pull(skb, pkt_offset);
 
 	if (!qlcnic_check_loopback_buff(skb->data, adapter->mac_addr))
-		adapter->diag_cnt++;
+		adapter->ahw->diag_cnt++;
 	else
 		dump_skb(skb, adapter);
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index b4edf75..0cf9991 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -329,7 +329,7 @@ static int qlcnic_enable_msix(struct qlcnic_adapter *adapter, u32 num_msix)
 	adapter->max_sds_rings = 1;
 	adapter->flags &= ~(QLCNIC_MSI_ENABLED | QLCNIC_MSIX_ENABLED);
 
-	if (adapter->msix_supported) {
+	if (adapter->ahw->msix_supported) {
  enable_msix:
 		for (i = 0; i < num_msix; i++)
 			adapter->msix_entries[i].entry = i;
@@ -370,7 +370,7 @@ static void qlcnic_enable_msi_legacy(struct qlcnic_adapter *adapter)
 
 	legacy_intrp = &legacy_intr[adapter->ahw->pci_func];
 
-	adapter->int_vec_bit = legacy_intrp->int_vec_bit;
+	adapter->ahw->int_vec_bit = legacy_intrp->int_vec_bit;
 	adapter->tgt_status_reg = qlcnic_get_ioaddr(adapter->ahw,
 			legacy_intrp->tgt_status_reg);
 	adapter->tgt_mask_reg = qlcnic_get_ioaddr(adapter->ahw,
@@ -388,7 +388,7 @@ qlcnic_setup_intr(struct qlcnic_adapter *adapter)
 {
 	int num_msix, err;
 
-	if (adapter->msix_supported)
+	if (adapter->ahw->msix_supported)
 		num_msix = rounddown_pow_of_two(min_t(int, num_online_cpus(),
 				QLCNIC_DEF_NUM_STS_DESC_RINGS));
 	else
@@ -537,7 +537,7 @@ qlcnic_check_vf(struct qlcnic_adapter *adapter)
 		priv_level = QLC_DEV_GET_DRV(op_mode, ahw->pci_func);
 
 	if (priv_level == QLCNIC_NON_PRIV_FUNC) {
-		adapter->op_mode = QLCNIC_NON_PRIV_FUNC;
+		ahw->op_mode = QLCNIC_NON_PRIV_FUNC;
 		dev_info(&adapter->pdev->dev,
 			"HAL Version: %d Non Privileged function\n",
 			ahw->fw_hal_version);
@@ -621,7 +621,7 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 
 	adapter->fw_version = QLCNIC_VERSION_CODE(fw_major, fw_minor, fw_build);
 
-	if (adapter->op_mode != QLCNIC_NON_PRIV_FUNC) {
+	if (ahw->op_mode != QLCNIC_NON_PRIV_FUNC) {
 		if (fw_dump->tmpl_hdr == NULL ||
 				adapter->fw_version > prev_fw_version) {
 			if (fw_dump->tmpl_hdr)
@@ -653,7 +653,7 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 		adapter->max_rxd = MAX_RCV_DESCRIPTORS_1G;
 	}
 
-	adapter->msix_supported = !!use_msi_x;
+	adapter->ahw->msix_supported = !!use_msi_x;
 
 	adapter->num_txd = MAX_CMD_DESCRIPTORS;
 
@@ -670,15 +670,15 @@ qlcnic_initialize_nic(struct qlcnic_adapter *adapter)
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
@@ -765,7 +765,7 @@ qlcnic_set_netdev_features(struct qlcnic_adapter *adapter,
 	vlan_features = (NETIF_F_SG | NETIF_F_IP_CSUM |
 			NETIF_F_IPV6_CSUM | NETIF_F_HW_VLAN_FILTER);
 
-	if (adapter->capabilities & QLCNIC_FW_CAPABILITY_TSO) {
+	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_TSO) {
 		features |= (NETIF_F_TSO | NETIF_F_TSO6);
 		vlan_features |= (NETIF_F_TSO | NETIF_F_TSO6);
 	}
@@ -812,7 +812,7 @@ qlcnic_check_eswitch_mode(struct qlcnic_adapter *adapter)
 
 	if (adapter->flags & QLCNIC_ESWITCH_ENABLED) {
 		if (priv_level == QLCNIC_MGMT_FUNC) {
-			adapter->op_mode = QLCNIC_MGMT_FUNC;
+			adapter->ahw->op_mode = QLCNIC_MGMT_FUNC;
 			err = qlcnic_init_pci_info(adapter);
 			if (err)
 				return err;
@@ -822,7 +822,7 @@ qlcnic_check_eswitch_mode(struct qlcnic_adapter *adapter)
 				"HAL Version: %d, Management function\n",
 				adapter->ahw->fw_hal_version);
 		} else if (priv_level == QLCNIC_PRIV_FUNC) {
-			adapter->op_mode = QLCNIC_PRIV_FUNC;
+			adapter->ahw->op_mode = QLCNIC_PRIV_FUNC;
 			dev_info(&adapter->pdev->dev,
 				"HAL Version: %d, Privileged function\n",
 				adapter->ahw->fw_hal_version);
@@ -852,7 +852,7 @@ qlcnic_set_default_offload_settings(struct qlcnic_adapter *adapter)
 		esw_cfg.offload_flags = BIT_0;
 		esw_cfg.mac_override = BIT_0;
 		esw_cfg.promisc_mode = BIT_0;
-		if (adapter->capabilities  & QLCNIC_FW_CAPABILITY_TSO)
+		if (adapter->ahw->capabilities  & QLCNIC_FW_CAPABILITY_TSO)
 			esw_cfg.offload_flags |= (BIT_1 | BIT_2);
 		if (qlcnic_config_switch_port(adapter, &esw_cfg))
 			return -EIO;
@@ -933,7 +933,7 @@ static int qlcnic_check_npar_opertional(struct qlcnic_adapter *adapter)
 	u8 npar_opt_timeo = QLCNIC_DEV_NPAR_OPER_TIMEO;
 	u32 npar_state;
 
-	if (adapter->op_mode == QLCNIC_MGMT_FUNC)
+	if (adapter->ahw->op_mode == QLCNIC_MGMT_FUNC)
 		return 0;
 
 	npar_state = QLCRD32(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
@@ -955,7 +955,7 @@ qlcnic_set_mgmt_operations(struct qlcnic_adapter *adapter)
 	int err;
 
 	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED) ||
-		    adapter->op_mode != QLCNIC_MGMT_FUNC)
+		    adapter->ahw->op_mode != QLCNIC_MGMT_FUNC)
 		return 0;
 
 	err = qlcnic_set_default_offload_settings(adapter);
@@ -989,7 +989,7 @@ qlcnic_start_firmware(struct qlcnic_adapter *adapter)
 		if (err)
 			goto err_out;
 
-		adapter->fw_type = QLCNIC_FLASH_ROMIMAGE;
+		adapter->ahw->fw_type = QLCNIC_FLASH_ROMIMAGE;
 	}
 
 	err = qlcnic_need_fw_reset(adapter);
@@ -1050,7 +1050,7 @@ qlcnic_request_irq(struct qlcnic_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 
-	if (adapter->diag_test == QLCNIC_INTERRUPT_TEST) {
+	if (adapter->ahw->diag_test == QLCNIC_INTERRUPT_TEST) {
 		handler = qlcnic_tmp_intr;
 		if (!QLCNIC_IS_MSI_FAMILY(adapter))
 			flags |= IRQF_SHARED;
@@ -1109,7 +1109,7 @@ __qlcnic_up(struct qlcnic_adapter *adapter, struct net_device *netdev)
 	if (qlcnic_set_eswitch_port_config(adapter))
 		return -EIO;
 
-	if (adapter->capabilities & QLCNIC_FW_CAPABILITY_MORE_CAPS) {
+	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_MORE_CAPS) {
 		capab2 = QLCRD32(adapter, CRB_FW_CAPABILITIES_2);
 		if (capab2 & QLCNIC_FW_CAPABILITY_2_LRO_MAX_TCP_SEG)
 			adapter->flags |= QLCNIC_FW_LRO_MSS_CAP;
@@ -1140,7 +1140,7 @@ __qlcnic_up(struct qlcnic_adapter *adapter, struct net_device *netdev)
 
 	qlcnic_linkevent_request(adapter, 1);
 
-	adapter->reset_context = 0;
+	adapter->ahw->reset_context = 0;
 	set_bit(__QLCNIC_DEV_UP, &adapter->state);
 	return 0;
 }
@@ -1273,7 +1273,7 @@ void qlcnic_diag_free_res(struct net_device *netdev, int max_sds_rings)
 	int ring;
 
 	clear_bit(__QLCNIC_DEV_UP, &adapter->state);
-	if (adapter->diag_test == QLCNIC_INTERRUPT_TEST) {
+	if (adapter->ahw->diag_test == QLCNIC_INTERRUPT_TEST) {
 		for (ring = 0; ring < adapter->max_sds_rings; ring++) {
 			sds_ring = &adapter->recv_ctx->sds_rings[ring];
 			QLCNIC_DISABLE_INTR(sds_ring->crb_intr_mask);
@@ -1284,7 +1284,7 @@ void qlcnic_diag_free_res(struct net_device *netdev, int max_sds_rings)
 
 	qlcnic_detach(adapter);
 
-	adapter->diag_test = 0;
+	adapter->ahw->diag_test = 0;
 	adapter->max_sds_rings = max_sds_rings;
 
 	if (qlcnic_attach(adapter))
@@ -1344,7 +1344,7 @@ int qlcnic_diag_alloc_res(struct net_device *netdev, int test)
 	qlcnic_detach(adapter);
 
 	adapter->max_sds_rings = 1;
-	adapter->diag_test = test;
+	adapter->ahw->diag_test = test;
 
 	ret = qlcnic_attach(adapter);
 	if (ret) {
@@ -1364,14 +1364,14 @@ int qlcnic_diag_alloc_res(struct net_device *netdev, int test)
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
@@ -1442,11 +1442,11 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter,
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
 
@@ -1455,16 +1455,16 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter,
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
@@ -1895,7 +1895,7 @@ static int qlcnic_check_temp(struct qlcnic_adapter *adapter)
 		       temp_val);
 		rv = 1;
 	} else if (temp_state == QLCNIC_TEMP_WARN) {
-		if (adapter->temp == QLCNIC_TEMP_NORMAL) {
+		if (adapter->ahw->temp == QLCNIC_TEMP_NORMAL) {
 			dev_err(&netdev->dev,
 			       "Device temperature %d degrees C "
 			       "exceeds operating range."
@@ -1903,13 +1903,13 @@ static int qlcnic_check_temp(struct qlcnic_adapter *adapter)
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
 
@@ -1925,7 +1925,7 @@ static void qlcnic_tx_timeout(struct net_device *netdev)
 	if (++adapter->tx_timeo_cnt >= QLCNIC_MAX_TX_TIMEOUTS)
 		adapter->need_fw_reset = 1;
 	else
-		adapter->reset_context = 1;
+		adapter->ahw->reset_context = 1;
 }
 
 static struct net_device_stats *qlcnic_get_stats(struct net_device *netdev)
@@ -1949,7 +1949,7 @@ static irqreturn_t qlcnic_clear_legacy_intr(struct qlcnic_adapter *adapter)
 
 	status = readl(adapter->isr_int_vec);
 
-	if (!(status & adapter->int_vec_bit))
+	if (!(status & adapter->ahw->int_vec_bit))
 		return IRQ_NONE;
 
 	/* check interrupt state machine, to be sure */
@@ -1981,7 +1981,7 @@ static irqreturn_t qlcnic_tmp_intr(int irq, void *data)
 		return IRQ_NONE;
 
 done:
-	adapter->diag_cnt++;
+	adapter->ahw->diag_cnt++;
 	QLCNIC_ENABLE_INTR(adapter, sds_ring->crb_intr_mask);
 	return IRQ_HANDLED;
 }
@@ -2264,7 +2264,7 @@ qlcnic_fwinit_work(struct work_struct *work)
 		return;
 	}
 
-	if (adapter->op_mode == QLCNIC_NON_PRIV_FUNC) {
+	if (adapter->ahw->op_mode == QLCNIC_NON_PRIV_FUNC) {
 		qlcnic_api_unlock(adapter);
 		goto wait_npar;
 	}
@@ -2380,9 +2380,9 @@ qlcnic_detach_work(struct work_struct *work)
 		goto err_ret;
 	}
 
-	if (adapter->temp == QLCNIC_TEMP_PANIC) {
+	if (adapter->ahw->temp == QLCNIC_TEMP_PANIC) {
 		dev_err(&adapter->pdev->dev, "Detaching the device: temp=%d\n",
-			adapter->temp);
+			adapter->ahw->temp);
 		goto err_ret;
 	}
 
@@ -2508,7 +2508,7 @@ qlcnic_attach_work(struct work_struct *work)
 	struct net_device *netdev = adapter->netdev;
 	u32 npar_state;
 
-	if (adapter->op_mode != QLCNIC_MGMT_FUNC) {
+	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC) {
 		npar_state = QLCRD32(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
 		if (adapter->fw_wait_cnt++ > QLCNIC_DEV_NPAR_OPER_TIMEO)
 			qlcnic_clr_all_drv_state(adapter, 0);
@@ -2565,7 +2565,7 @@ qlcnic_check_health(struct qlcnic_adapter *adapter)
 		if (adapter->need_fw_reset)
 			goto detach;
 
-		if (adapter->reset_context && auto_fw_reset) {
+		if (adapter->ahw->reset_context && auto_fw_reset) {
 			qlcnic_reset_hw_context(adapter);
 			adapter->netdev->trans_start = jiffies;
 		}
@@ -2678,7 +2678,7 @@ static int qlcnic_attach_func(struct pci_dev *pdev)
 	if (qlcnic_api_lock(adapter))
 		return -EINVAL;
 
-	if (adapter->op_mode != QLCNIC_NON_PRIV_FUNC && first_func) {
+	if (ahw->op_mode != QLCNIC_NON_PRIV_FUNC && first_func) {
 		adapter->need_fw_reset = 1;
 		set_bit(__QLCNIC_START_FW, &adapter->state);
 		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_INITIALIZING);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
index 4555016..a9f8836 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
@@ -9,7 +9,7 @@ qlcnic_store_bridged_mode(struct device *dev,
 	unsigned long new;
 	int ret = -EINVAL;
 
-	if (!(adapter->capabilities & QLCNIC_FW_CAPABILITY_BDG))
+	if (!(adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_BDG))
 		goto err_out;
 
 	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state))
@@ -32,7 +32,7 @@ qlcnic_show_bridged_mode(struct device *dev,
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 	int bridged_mode = 0;
 
-	if (adapter->capabilities & QLCNIC_FW_CAPABILITY_BDG)
+	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_BDG)
 		bridged_mode = !!(adapter->flags & QLCNIC_BRIDGE_ENABLED);
 
 	return sprintf(buf, "%d\n", bridged_mode);
@@ -407,7 +407,7 @@ validate_esw_config(struct qlcnic_adapter *adapter,
 		if (pci_func >= QLCNIC_MAX_PCI_FUNC)
 			return QL_STATUS_INVALID_PARAM;
 
-		if (adapter->op_mode == QLCNIC_MGMT_FUNC)
+		if (adapter->ahw->op_mode == QLCNIC_MGMT_FUNC)
 			if (adapter->npars[pci_func].type != QLCNIC_TYPE_NIC)
 				return QL_STATUS_INVALID_PARAM;
 
@@ -462,7 +462,7 @@ qlcnic_sysfs_write_esw_config(struct file *file, struct kobject *kobj,
 		return ret;
 
 	for (i = 0; i < count; i++) {
-		if (adapter->op_mode == QLCNIC_MGMT_FUNC)
+		if (adapter->ahw->op_mode == QLCNIC_MGMT_FUNC)
 			if (qlcnic_config_switch_port(adapter, &esw_cfg[i]))
 				return QL_STATUS_INVALID_PARAM;
 
@@ -488,7 +488,7 @@ qlcnic_sysfs_write_esw_config(struct file *file, struct kobject *kobj,
 		}
 	}
 
-	if (adapter->op_mode != QLCNIC_MGMT_FUNC)
+	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC)
 		goto out;
 
 	for (i = 0; i < count; i++) {
@@ -822,7 +822,7 @@ qlcnic_create_sysfs_entries(struct qlcnic_adapter *adapter)
 {
 	struct device *dev = &adapter->pdev->dev;
 
-	if (adapter->capabilities & QLCNIC_FW_CAPABILITY_BDG)
+	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_BDG)
 		if (device_create_file(dev, &dev_attr_bridged_mode))
 			dev_warn(dev,
 				"failed to create bridged_mode sysfs entry\n");
@@ -833,7 +833,7 @@ qlcnic_remove_sysfs_entries(struct qlcnic_adapter *adapter)
 {
 	struct device *dev = &adapter->pdev->dev;
 
-	if (adapter->capabilities & QLCNIC_FW_CAPABILITY_BDG)
+	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_BDG)
 		device_remove_file(dev, &dev_attr_bridged_mode);
 }
 
@@ -845,7 +845,7 @@ qlcnic_create_diag_entries(struct qlcnic_adapter *adapter)
 	if (device_create_bin_file(dev, &bin_attr_port_stats))
 		dev_info(dev, "failed to create port stats sysfs entry");
 
-	if (adapter->op_mode == QLCNIC_NON_PRIV_FUNC)
+	if (adapter->ahw->op_mode == QLCNIC_NON_PRIV_FUNC)
 		return;
 	if (device_create_file(dev, &dev_attr_diag_mode))
 		dev_info(dev, "failed to create diag_mode sysfs entry\n");
@@ -861,7 +861,7 @@ qlcnic_create_diag_entries(struct qlcnic_adapter *adapter)
 		return;
 	if (device_create_bin_file(dev, &bin_attr_esw_config))
 		dev_info(dev, "failed to create esw config sysfs entry");
-	if (adapter->op_mode != QLCNIC_MGMT_FUNC)
+	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC)
 		return;
 	if (device_create_bin_file(dev, &bin_attr_npar_config))
 		dev_info(dev, "failed to create npar config sysfs entry");
@@ -878,7 +878,7 @@ qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter)
 
 	device_remove_bin_file(dev, &bin_attr_port_stats);
 
-	if (adapter->op_mode == QLCNIC_NON_PRIV_FUNC)
+	if (adapter->ahw->op_mode == QLCNIC_NON_PRIV_FUNC)
 		return;
 	device_remove_file(dev, &dev_attr_diag_mode);
 	device_remove_file(dev, &dev_attr_beacon);
@@ -888,7 +888,7 @@ qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter)
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
