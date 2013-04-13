From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 1/9] qlcnic: Implement GET_LED_STATUS command for 82xx adapter.
Date: Sat, 13 Apr 2013 13:28:26 -0400
Message-ID: <1365874114-6759-2-git-send-email-shahed.shaikh@qlogic.com>
References: <1365874114-6759-1-git-send-email-shahed.shaikh@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:46300 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751045Ab3DMRwS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Apr 2013 13:52:18 -0400
In-Reply-To: <1365874114-6759-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

o GET_LED_STATUS command will be used by driver to get
  current beacon state from 82xx adapter.

Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h       |    5 ++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c   |    1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c    |   23 +++++++++++++++++++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h    |    1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c |    9 ++++++++
 5 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index ef55718..602d3e4 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -807,6 +807,7 @@ struct qlcnic_mac_list_s {
 #define QLCNIC_FW_CAPABILITY_2_LRO_MAX_TCP_SEG	BIT_2
 #define QLCNIC_FW_CAP2_HW_LRO_IPV6		BIT_3
 #define QLCNIC_FW_CAPABILITY_2_OCBB		BIT_5
+#define QLCNIC_FW_CAPABILITY_2_BEACON		BIT_7
 
 /* module types */
 #define LINKEVENT_MODULE_NOT_PRESENT			1
@@ -901,6 +902,9 @@ struct qlcnic_ipaddr {
 #define QLCNIC_IS_MSI_FAMILY(adapter) \
 	((adapter)->flags & (QLCNIC_MSI_ENABLED | QLCNIC_MSIX_ENABLED))
 
+#define QLCNIC_BEACON_EANBLE		0xC
+#define QLCNIC_BEACON_DISABLE		0xD
+
 #define QLCNIC_DEF_NUM_STS_DESC_RINGS	4
 #define QLCNIC_MSIX_TBL_SPACE		8192
 #define QLCNIC_PCI_REG_MSIX_TBL 	0x44
@@ -1526,6 +1530,7 @@ int qlcnic_reset_npar_config(struct qlcnic_adapter *);
 int qlcnic_set_eswitch_port_config(struct qlcnic_adapter *);
 void qlcnic_add_lb_filter(struct qlcnic_adapter *, struct sk_buff *, int,
 			  __le16);
+int qlcnic_get_beacon_state(struct qlcnic_adapter *, u8 *);
 int qlcnic_83xx_configure_opmode(struct qlcnic_adapter *adapter);
 int qlcnic_read_mac_addr(struct qlcnic_adapter *);
 int qlcnic_setup_netdev(struct qlcnic_adapter *, struct net_device *, int);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index 43562c2..d63b5f7 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -37,6 +37,7 @@ static const struct qlcnic_mailbox_metadata qlcnic_mbx_tbl[] = {
 	{QLCNIC_CMD_TEMP_SIZE, 4, 4},
 	{QLCNIC_CMD_GET_TEMP_HDR, 4, 1},
 	{QLCNIC_CMD_SET_DRV_VER, 4, 1},
+	{QLCNIC_CMD_GET_LED_STATUS, 4, 2},
 };
 
 static inline u32 qlcnic_get_cmd_signature(struct qlcnic_hardware_context *ahw)
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index 253b3ac..3784bef 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -1462,6 +1462,29 @@ int qlcnic_82xx_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate)
 	return rv;
 }
 
+int qlcnic_get_beacon_state(struct qlcnic_adapter *adapter, u8 *h_state)
+{
+	int err = 0;
+	struct qlcnic_cmd_args cmd;
+
+	if (adapter->ahw->capabilities2 & QLCNIC_FW_CAPABILITY_2_BEACON) {
+		err = qlcnic_alloc_mbx_args(&cmd, adapter,
+					    QLCNIC_CMD_GET_LED_STATUS);
+		if (err)
+			goto error;
+
+		err = qlcnic_issue_cmd(adapter, &cmd);
+		if (err)
+			err = -EIO;
+		else
+			*h_state = cmd.rsp.arg[1];
+
+		qlcnic_free_mbx_args(&cmd);
+	}
+error:
+	return err;
+}
+
 void qlcnic_82xx_get_func_no(struct qlcnic_adapter *adapter)
 {
 	void __iomem *msix_base_addr;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
index e862a77..7e8f99e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
@@ -84,6 +84,7 @@ enum qlcnic_regs {
 #define QLCNIC_CMD_TEMP_SIZE			0x2f
 #define QLCNIC_CMD_GET_TEMP_HDR			0x30
 #define QLCNIC_CMD_BC_EVENT_SETUP		0x31
+#define QLCNIC_CMD_GET_LED_STATUS		0x3C
 #define	QLCNIC_CMD_CONFIG_VPORT			0x32
 #define QLCNIC_CMD_GET_MAC_STATS		0x37
 #define QLCNIC_CMD_SET_DRV_VER			0x38
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
index c77675d..a17671d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
@@ -124,6 +124,7 @@ static ssize_t qlcnic_store_beacon(struct device *dev,
 	u16 beacon;
 	u8 b_state, b_rate;
 	unsigned long h_beacon;
+	u8 h_beacon_state;
 
 	if (adapter->ahw->op_mode == QLCNIC_NON_PRIV_FUNC) {
 		dev_warn(dev,
@@ -174,6 +175,14 @@ beacon_err:
 	if (err)
 		return err;
 
+	err = qlcnic_get_beacon_state(adapter, &h_beacon_state);
+	if (err != -EIO) {
+		if (h_beacon_state == QLCNIC_BEACON_DISABLE)
+			adapter->ahw->beacon_state = 0;
+		else
+			adapter->ahw->beacon_state = 2;
+	}
+
 	if (adapter->ahw->beacon_state == b_state)
 		return len;
 
-- 
1.5.6
