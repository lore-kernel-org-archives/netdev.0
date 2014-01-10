From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 5/8] qlcnic: Enable beaconing for 83xx/84xx Series adapter.
Date: Fri, 10 Jan 2014 11:48:56 -0500
Message-ID: <1389372539-13753-6-git-send-email-shahed.shaikh@qlogic.com>
References: <1389372539-13753-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:29138 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753031AbaAJRXU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 12:23:20 -0500
In-Reply-To: <1389372539-13753-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

o Refactored code to handle beaconing test for all adapters.
o Use GET_LED_CONFIG mailbox command for 83xx/84xx series adapter
  to detect current beaconing state of the adapter.

Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        | 10 ++++++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    | 29 ++++++++++++++++++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |  3 ++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     | 33 ++++++++++++++++------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h     |  1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c  | 17 +++--------
 7 files changed, 70 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 76740c2..94bbf48 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -970,6 +970,9 @@ struct qlcnic_ipaddr {
 #define QLCNIC_BEACON_EANBLE		0xC
 #define QLCNIC_BEACON_DISABLE		0xD
 
+#define QLCNIC_BEACON_ON		2
+#define QLCNIC_BEACON_OFF		0
+
 #define QLCNIC_MSIX_TBL_SPACE		8192
 #define QLCNIC_PCI_REG_MSIX_TBL 	0x44
 #define QLCNIC_MSIX_TBL_PGSIZE		4096
@@ -1641,7 +1644,6 @@ int qlcnic_set_default_offload_settings(struct qlcnic_adapter *);
 int qlcnic_reset_npar_config(struct qlcnic_adapter *);
 int qlcnic_set_eswitch_port_config(struct qlcnic_adapter *);
 void qlcnic_add_lb_filter(struct qlcnic_adapter *, struct sk_buff *, int, u16);
-int qlcnic_get_beacon_state(struct qlcnic_adapter *, u8 *);
 int qlcnic_83xx_configure_opmode(struct qlcnic_adapter *adapter);
 int qlcnic_read_mac_addr(struct qlcnic_adapter *);
 int qlcnic_setup_netdev(struct qlcnic_adapter *, struct net_device *, int);
@@ -1768,6 +1770,7 @@ struct qlcnic_hardware_ops {
 					       pci_channel_state_t);
 	pci_ers_result_t (*io_slot_reset) (struct pci_dev *);
 	void (*io_resume) (struct pci_dev *);
+	void (*get_beacon_state)(struct qlcnic_adapter *);
 };
 
 extern struct qlcnic_nic_template qlcnic_vf_ops;
@@ -1994,6 +1997,11 @@ static inline void qlcnic_set_mac_filter_count(struct qlcnic_adapter *adapter)
 		adapter->ahw->hw_ops->set_mac_filter_count(adapter);
 }
 
+static inline void qlcnic_get_beacon_state(struct qlcnic_adapter *adapter)
+{
+	adapter->ahw->hw_ops->get_beacon_state(adapter);
+}
+
 static inline void qlcnic_read_phys_port_id(struct qlcnic_adapter *adapter)
 {
 	if (adapter->ahw->hw_ops->read_phys_port_id)
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 03f70e8..a684d28 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -181,7 +181,7 @@ static struct qlcnic_hardware_ops qlcnic_83xx_hw_ops = {
 	.io_error_detected		= qlcnic_83xx_io_error_detected,
 	.io_slot_reset			= qlcnic_83xx_io_slot_reset,
 	.io_resume			= qlcnic_83xx_io_resume,
-
+	.get_beacon_state		= qlcnic_83xx_get_beacon_state,
 };
 
 static struct qlcnic_nic_template qlcnic_83xx_ops = {
@@ -1388,6 +1388,33 @@ out:
 	netif_device_attach(netdev);
 }
 
+void qlcnic_83xx_get_beacon_state(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+	struct qlcnic_cmd_args cmd;
+	u8 beacon_state;
+	int err = 0;
+
+	err = qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_GET_LED_CONFIG);
+	if (!err) {
+		err = qlcnic_issue_cmd(adapter, &cmd);
+		if (!err) {
+			beacon_state = cmd.rsp.arg[4];
+			if (beacon_state == QLCNIC_BEACON_DISABLE)
+				ahw->beacon_state = QLC_83XX_BEACON_OFF;
+			else if (beacon_state == QLC_83XX_ENABLE_BEACON)
+				ahw->beacon_state = QLC_83XX_BEACON_ON;
+		}
+	} else {
+		netdev_err(adapter->netdev, "Get beacon state failed, err=%d\n",
+			   err);
+	}
+
+	qlcnic_free_mbx_args(&cmd);
+
+	return;
+}
+
 int qlcnic_83xx_config_led(struct qlcnic_adapter *adapter, u32 state,
 			   u32 beacon)
 {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
index 34d2911..4643b15 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -381,6 +381,8 @@ enum qlcnic_83xx_states {
 
 /* LED configuration settings */
 #define QLC_83XX_ENABLE_BEACON		0xe
+#define QLC_83XX_BEACON_ON		1
+#define QLC_83XX_BEACON_OFF		0
 #define QLC_83XX_LED_RATE		0xff
 #define QLC_83XX_LED_ACT		(1 << 10)
 #define QLC_83XX_LED_MOD		(0 << 13)
@@ -559,6 +561,7 @@ void qlcnic_83xx_napi_del(struct qlcnic_adapter *);
 void qlcnic_83xx_napi_enable(struct qlcnic_adapter *);
 void qlcnic_83xx_napi_disable(struct qlcnic_adapter *);
 int qlcnic_83xx_config_led(struct qlcnic_adapter *, u32, u32);
+void qlcnic_83xx_get_beacon_state(struct qlcnic_adapter *);
 void qlcnic_ind_wr(struct qlcnic_adapter *, u32, u32);
 int qlcnic_ind_rd(struct qlcnic_adapter *, u32);
 int qlcnic_83xx_create_rx_ctx(struct qlcnic_adapter *);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index 18cc365..e96b76d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -1533,19 +1533,34 @@ int qlcnic_82xx_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate)
 	return rv;
 }
 
-int qlcnic_get_beacon_state(struct qlcnic_adapter *adapter, u8 *h_state)
+void qlcnic_82xx_get_beacon_state(struct qlcnic_adapter *adapter)
 {
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	struct qlcnic_cmd_args cmd;
-	int err;
+	u8 beacon_state;
+	int err = 0;
 
-	err = qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_GET_LED_STATUS);
-	if (!err) {
-		err = qlcnic_issue_cmd(adapter, &cmd);
-		if (!err)
-			*h_state = cmd.rsp.arg[1];
+	if (ahw->extra_capability[0] & QLCNIC_FW_CAPABILITY_2_BEACON) {
+		err = qlcnic_alloc_mbx_args(&cmd, adapter,
+					    QLCNIC_CMD_GET_LED_STATUS);
+		if (!err) {
+			err = qlcnic_issue_cmd(adapter, &cmd);
+			if (err) {
+				netdev_err(adapter->netdev,
+					   "Failed to get current beacon state, err=%d\n",
+					   err);
+			} else {
+				beacon_state = cmd.rsp.arg[1];
+				if (beacon_state == QLCNIC_BEACON_DISABLE)
+					ahw->beacon_state = QLCNIC_BEACON_OFF;
+				else if (beacon_state == QLCNIC_BEACON_EANBLE)
+					ahw->beacon_state = QLCNIC_BEACON_ON;
+			}
+		}
+		qlcnic_free_mbx_args(&cmd);
 	}
-	qlcnic_free_mbx_args(&cmd);
-	return err;
+
+	return;
 }
 
 void qlcnic_82xx_get_func_no(struct qlcnic_adapter *adapter)
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
index 13303e7..0e739ae 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
@@ -169,6 +169,7 @@ int qlcnic_82xx_config_hw_lro(struct qlcnic_adapter *adapter, int);
 int qlcnic_82xx_nic_set_promisc(struct qlcnic_adapter *adapter, u32);
 int qlcnic_82xx_napi_add(struct qlcnic_adapter *adapter,
 			 struct net_device *netdev);
+void qlcnic_82xx_get_beacon_state(struct qlcnic_adapter *);
 void qlcnic_82xx_change_filter(struct qlcnic_adapter *adapter,
 			       u64 *uaddr, u16 vlan_id);
 void qlcnic_82xx_config_intr_coalesce(struct qlcnic_adapter *adapter);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index eeec83a..a57dfe4 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -546,6 +546,7 @@ static struct qlcnic_hardware_ops qlcnic_hw_ops = {
 	.io_error_detected		= qlcnic_82xx_io_error_detected,
 	.io_slot_reset			= qlcnic_82xx_io_slot_reset,
 	.io_resume			= qlcnic_82xx_io_resume,
+	.get_beacon_state		= qlcnic_82xx_get_beacon_state,
 };
 
 static int qlcnic_check_multi_tx_capability(struct qlcnic_adapter *adapter)
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
index b529667..83a5d11 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
@@ -127,6 +127,8 @@ static int qlcnic_83xx_store_beacon(struct qlcnic_adapter *adapter,
 	if (kstrtoul(buf, 2, &h_beacon))
 		return -EINVAL;
 
+	qlcnic_get_beacon_state(adapter);
+
 	if (ahw->beacon_state == h_beacon)
 		return len;
 
@@ -158,7 +160,7 @@ static int qlcnic_82xx_store_beacon(struct qlcnic_adapter *adapter,
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	int err, drv_sds_rings = adapter->drv_sds_rings;
 	u16 beacon;
-	u8 h_beacon_state, b_state, b_rate;
+	u8 b_state, b_rate;
 
 	if (len != sizeof(u16))
 		return QL_STATUS_INVALID_PARAM;
@@ -168,18 +170,7 @@ static int qlcnic_82xx_store_beacon(struct qlcnic_adapter *adapter,
 	if (err)
 		return err;
 
-	if (ahw->extra_capability[0] & QLCNIC_FW_CAPABILITY_2_BEACON) {
-		err = qlcnic_get_beacon_state(adapter, &h_beacon_state);
-		if (err) {
-			netdev_err(adapter->netdev,
-				   "Failed to get current beacon state\n");
-		} else {
-			if (h_beacon_state == QLCNIC_BEACON_DISABLE)
-				ahw->beacon_state = 0;
-			else if (h_beacon_state == QLCNIC_BEACON_EANBLE)
-				ahw->beacon_state = 2;
-		}
-	}
+	qlcnic_get_beacon_state(adapter);
 
 	if (ahw->beacon_state == b_state)
 		return len;
-- 
1.8.3.1
