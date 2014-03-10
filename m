From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 4/5] qlcnic: Add VXLAN Rx offload support for 84xx
Date: Mon, 10 Mar 2014 12:49:01 -0400
Message-ID: <1394470142-13992-5-git-send-email-shahed.shaikh@qlogic.com>
References: <1394470142-13992-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:37107 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754469AbaCJRZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 13:25:12 -0400
In-Reply-To: <1394470142-13992-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

This patch adds Rx checksum offload support for VXLAN over 84xx
series adapters.

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |  8 +++++++
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    | 27 +++++++++++++++-------
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |  3 ++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  | 25 ++++++++++++++++++++
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |  2 ++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h     |  1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     | 13 +++++++++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  3 +++
 8 files changed, 73 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 5c48263..cf5a186 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -551,6 +551,7 @@ struct qlcnic_adapter_stats {
 	u64  lso_frames;
 	u64  encap_lso_frames;
 	u64  encap_tx_csummed;
+	u64  encap_rx_csummed;
 	u64  xmit_on;
 	u64  xmit_off;
 	u64  skb_alloc_failure;
@@ -912,6 +913,7 @@ struct qlcnic_mac_vlan_list {
 #define QLCNIC_FW_CAPABILITY_2_BEACON		BIT_7
 #define QLCNIC_FW_CAPABILITY_2_PER_PORT_ESWITCH_CFG	BIT_9
 
+#define QLCNIC_83XX_FW_CAPAB_ENCAP_RX_OFFLOAD	BIT_0
 #define QLCNIC_83XX_FW_CAPAB_ENCAP_TX_OFFLOAD	BIT_1
 #define QLCNIC_83XX_FW_CAPAB_ENCAP_CKO_OFFLOAD	BIT_4
 
@@ -1828,6 +1830,12 @@ static inline bool qlcnic_encap_tx_offload(struct qlcnic_adapter *adapter)
 	       QLCNIC_83XX_FW_CAPAB_ENCAP_TX_OFFLOAD;
 }
 
+static inline bool qlcnic_encap_rx_offload(struct qlcnic_adapter *adapter)
+{
+	return adapter->ahw->extra_capability[0] &
+	       QLCNIC_83XX_FW_CAPAB_ENCAP_RX_OFFLOAD;
+}
+
 static inline int qlcnic_start_firmware(struct qlcnic_adapter *adapter)
 {
 	return adapter->nic_ops->start_firmware(adapter);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 0f39778e..06a84a8 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -12,6 +12,7 @@
 #include <linux/ethtool.h>
 #include <linux/interrupt.h>
 #include <linux/aer.h>
+#include <net/vxlan.h>
 
 static void __qlcnic_83xx_process_aen(struct qlcnic_adapter *);
 static int qlcnic_83xx_clear_lb_mode(struct qlcnic_adapter *, u8);
@@ -77,7 +78,7 @@ static const struct qlcnic_mailbox_metadata qlcnic_83xx_mbx_tbl[] = {
 	{QLCNIC_CMD_GET_PORT_CONFIG, 2, 2},
 	{QLCNIC_CMD_GET_LINK_STATUS, 2, 4},
 	{QLCNIC_CMD_IDC_ACK, 5, 1},
-	{QLCNIC_CMD_INIT_NIC_FUNC, 2, 1},
+	{QLCNIC_CMD_INIT_NIC_FUNC, 3, 1},
 	{QLCNIC_CMD_STOP_NIC_FUNC, 2, 1},
 	{QLCNIC_CMD_SET_LED_CONFIG, 5, 1},
 	{QLCNIC_CMD_GET_LED_CONFIG, 1, 5},
@@ -87,6 +88,7 @@ static const struct qlcnic_mailbox_metadata qlcnic_83xx_mbx_tbl[] = {
 	{QLCNIC_CMD_BC_EVENT_SETUP, 2, 1},
 	{QLCNIC_CMD_DCB_QUERY_CAP, 1, 2},
 	{QLCNIC_CMD_DCB_QUERY_PARAM, 1, 50},
+	{QLCNIC_CMD_SET_INGRESS_ENCAP, 2, 1},
 };
 
 const u32 qlcnic_83xx_ext_reg_tbl[] = {
@@ -1567,25 +1569,34 @@ int  qlcnic_83xx_set_led(struct net_device *netdev,
 	return err;
 }
 
+#define QLC_83XX_ENCAP_TYPE_VXLAN	BIT_1
+#define QLC_83XX_MATCH_ENCAP_ID		BIT_2
+#define QLC_83XX_SET_VXLAN_UDP_DPORT	BIT_3
+#define QLC_83XX_VXLAN_UDP_DPORT	((VXLAN_DEFAULT_PORT & 0xffff) << 16)
+
 void qlcnic_83xx_initialize_nic(struct qlcnic_adapter *adapter, int enable)
 {
 	struct qlcnic_cmd_args cmd;
+	u32 op_type;
 	int status;
 
 	if (qlcnic_sriov_vf_check(adapter))
 		return;
 
-	if (enable)
-		status = qlcnic_alloc_mbx_args(&cmd, adapter,
-					       QLCNIC_CMD_INIT_NIC_FUNC);
-	else
-		status = qlcnic_alloc_mbx_args(&cmd, adapter,
-					       QLCNIC_CMD_STOP_NIC_FUNC);
+	op_type = enable ? QLCNIC_CMD_INIT_NIC_FUNC : QLCNIC_CMD_STOP_NIC_FUNC;
 
+	status = qlcnic_alloc_mbx_args(&cmd, adapter, op_type);
 	if (status)
 		return;
 
-	cmd.req.arg[1] = QLC_REGISTER_LB_IDC | QLC_INIT_FW_RESOURCES;
+	if (enable && qlcnic_encap_rx_offload(adapter)) {
+		cmd.req.arg[1] = QLC_83XX_MULTI_TENANCY_INFO;
+		cmd.req.arg[2] = QLC_83XX_ENCAP_TYPE_VXLAN |
+				 QLC_83XX_SET_VXLAN_UDP_DPORT |
+				 QLC_83XX_VXLAN_UDP_DPORT;
+	}
+
+	cmd.req.arg[1] |= QLC_REGISTER_LB_IDC | QLC_INIT_FW_RESOURCES;
 
 	if (adapter->dcb)
 		cmd.req.arg[1] |= QLC_REGISTER_DCB_AEN;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
index 81c1889..88d809c 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -528,8 +528,9 @@ enum qlc_83xx_ext_regs {
 };
 
 /* Initialize/Stop NIC command bit definitions */
-#define QLC_REGISTER_DCB_AEN		BIT_1
 #define QLC_REGISTER_LB_IDC		BIT_0
+#define QLC_REGISTER_DCB_AEN		BIT_1
+#define QLC_83XX_MULTI_TENANCY_INFO	BIT_29
 #define QLC_INIT_FW_RESOURCES		BIT_31
 
 /* 83xx funcitons */
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index 760e602..fea4157 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -2225,6 +2225,28 @@ static void qlcnic_83xx_init_rings(struct qlcnic_adapter *adapter)
 	qlcnic_set_sds_ring_count(adapter, rx_cnt);
 }
 
+#define QLCNIC_ENABLE_INGRESS_ENCAP_PARSING 1
+
+static void qlcnic_83xx_set_ingress_encap(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_cmd_args cmd;
+	int ret;
+
+	ret = qlcnic_alloc_mbx_args(&cmd, adapter,
+				    QLCNIC_CMD_SET_INGRESS_ENCAP);
+	if (ret)
+		return;
+
+	/* Enable encapsulation parsing */
+	cmd.req.arg[1] = QLCNIC_ENABLE_INGRESS_ENCAP_PARSING;
+	ret = qlcnic_issue_cmd(adapter, &cmd);
+	if (ret)
+		dev_err(&adapter->pdev->dev,
+			"Failed to enable encapulation parsing\n");
+
+	qlcnic_free_mbx_args(&cmd);
+}
+
 int qlcnic_83xx_init(struct qlcnic_adapter *adapter, int pci_using_dac)
 {
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
@@ -2283,6 +2305,9 @@ int qlcnic_83xx_init(struct qlcnic_adapter *adapter, int pci_using_dac)
 
 	qlcnic_83xx_initialize_nic(adapter, 1);
 
+	if (qlcnic_encap_rx_offload(adapter))
+		qlcnic_83xx_set_ingress_encap(adapter);
+
 	/* Configure default, SR-IOV or Virtual NIC mode of operation */
 	err = qlcnic_83xx_configure_opmode(adapter);
 	if (err)
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index dfc25f7..5bacf52 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -51,6 +51,8 @@ static const struct qlcnic_stats qlcnic_gstrings_stats[] = {
 	 QLC_OFF(stats.encap_lso_frames)},
 	{"encap_tx_csummed", QLC_SIZEOF(stats.encap_tx_csummed),
 	 QLC_OFF(stats.encap_tx_csummed)},
+	{"encap_rx_csummed", QLC_SIZEOF(stats.encap_rx_csummed),
+	 QLC_OFF(stats.encap_rx_csummed)},
 	{"skb_alloc_failure", QLC_SIZEOF(stats.skb_alloc_failure),
 	 QLC_OFF(stats.skb_alloc_failure)},
 	{"mac_filter_limit_overrun", QLC_SIZEOF(stats.mac_filter_limit_overrun),
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
index 576b301..cbe2399 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
@@ -98,6 +98,7 @@ enum qlcnic_regs {
 #define QLCNIC_CMD_GET_LINK_EVENT		0x48
 #define QLCNIC_CMD_CONFIGURE_MAC_RX_MODE	0x49
 #define QLCNIC_CMD_CONFIGURE_HW_LRO		0x4A
+#define QLCNIC_CMD_SET_INGRESS_ENCAP		0x4E
 #define QLCNIC_CMD_INIT_NIC_FUNC		0x60
 #define QLCNIC_CMD_STOP_NIC_FUNC		0x61
 #define QLCNIC_CMD_IDC_ACK			0x63
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index 7252af9..173b3d1 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -1703,6 +1703,13 @@ static inline int qlcnic_83xx_is_lb_pkt(u64 sts_data, int lro_pkt)
 		return (sts_data & QLC_83XX_NORMAL_LB_PKT) ? 1 : 0;
 }
 
+#define QLCNIC_ENCAP_LENGTH_MASK	0x7f
+
+static inline u8 qlcnic_encap_length(u64 sts_data)
+{
+	return sts_data & QLCNIC_ENCAP_LENGTH_MASK;
+}
+
 static struct qlcnic_rx_buffer *
 qlcnic_83xx_process_rcv(struct qlcnic_adapter *adapter,
 			struct qlcnic_host_sds_ring *sds_ring,
@@ -1753,6 +1760,12 @@ qlcnic_83xx_process_rcv(struct qlcnic_adapter *adapter,
 
 	skb->protocol = eth_type_trans(skb, netdev);
 
+	if (qlcnic_encap_length(sts_data[1]) &&
+	    skb->ip_summed == CHECKSUM_UNNECESSARY) {
+		skb->encapsulation = 1;
+		adapter->stats.encap_rx_csummed++;
+	}
+
 	if (vid != 0xffff)
 		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vid);
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 3564886..d8d03db 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2215,6 +2215,9 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter, struct net_device *netdev,
 					  NETIF_F_SG;
 	}
 
+	if (qlcnic_encap_rx_offload(adapter))
+		netdev->hw_enc_features |= NETIF_F_RXCSUM;
+
 	netdev->hw_features = netdev->features;
 	netdev->priv_flags |= IFF_UNICAST_FLT;
 	netdev->irq = adapter->msix_entries[0].vector;
-- 
1.8.3.1
