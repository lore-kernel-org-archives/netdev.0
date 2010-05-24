From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH 2/2] qlcnic: NIC Partitioning - non privileged mode
Date: Mon, 24 May 2010 16:48:26 -0700
Message-ID: <alpine.OSX.2.00.1005241640400.27371@macintosh-2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Ameen Rahman <ameen.rahman@qlogic.com>,
	Amit Salecha <amit.salecha@qlogic.com>
To: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:22018 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758575Ab0EXXs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 19:48:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Added support for non privileged mode of npar functions.
Bumped up version number to 5.0.3.

Please apply.
thanks,
Anirban


Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |   13 +---
 drivers/net/qlcnic/qlcnic_hdr.h  |   14 +++--
 drivers/net/qlcnic/qlcnic_main.c |  124 +++++++++++++++++++++++++++++++++++---
 3 files changed, 128 insertions(+), 23 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 31a0b43..02db363 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -51,8 +51,8 @@
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 0
-#define _QLCNIC_LINUX_SUBVERSION 2
-#define QLCNIC_LINUX_VERSIONID  "5.0.2"
+#define _QLCNIC_LINUX_SUBVERSION 3
+#define QLCNIC_LINUX_VERSIONID  "5.0.3"
 #define QLCNIC_DRV_IDC_VER  0x01
 
 #define QLCNIC_VERSION_CODE(a, b, c)	(((a) << 24) + ((b) << 16) + (c))
@@ -891,6 +891,7 @@ struct qlcnic_mac_req {
 #define QLCNIC_LRO_ENABLED		0x08
 #define QLCNIC_BRIDGE_ENABLED       	0X10
 #define QLCNIC_DIAG_ENABLED		0x20
+#define QLCNIC_NPAR_ENABLED		0x40
 #define QLCNIC_IS_MSI_FAMILY(adapter) \
 	((adapter)->flags & (QLCNIC_MSI_ENABLED | QLCNIC_MSIX_ENABLED))
 
@@ -1159,13 +1160,6 @@ int qlcnic_check_loopback_buff(unsigned char *data);
 netdev_tx_t qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
 void qlcnic_process_rcv_ring_diag(struct qlcnic_host_sds_ring *sds_ring);
 
-/* Functions from qlcnic_vf.c */
-int qlcnicvf_config_bridged_mode(struct qlcnic_adapter *, u32);
-int qlcnicvf_config_led(struct qlcnic_adapter *, u32, u32);
-int qlcnicvf_set_ilb_mode(struct qlcnic_adapter *adapter);
-void qlcnicvf_clear_ilb_mode(struct qlcnic_adapter *adapter);
-void qlcnicvf_set_port_mode(struct qlcnic_adapter *adapter);
-
 /* Management functions */
 int qlcnic_set_mac_address(struct qlcnic_adapter *, u8*);
 int qlcnic_get_mac_address(struct qlcnic_adapter *, u8*);
@@ -1234,6 +1228,7 @@ struct qlcnic_nic_template {
 	int (*config_led) (struct qlcnic_adapter *, u32, u32);
 	int (*set_ilb_mode) (struct qlcnic_adapter *);
 	void (*clear_ilb_mode) (struct qlcnic_adapter *);
+	int (*start_firmware) (struct qlcnic_adapter *);
 };
 
 #define QLCDB(adapter, lvl, _fmt, _args...) do {	\
diff --git a/drivers/net/qlcnic/qlcnic_hdr.h b/drivers/net/qlcnic/qlcnic_hdr.h
index 1bcfb12..7b81cab 100644
--- a/drivers/net/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/qlcnic/qlcnic_hdr.h
@@ -701,10 +701,11 @@ enum {
 #define QLCNIC_CRB_DEV_REF_COUNT	(QLCNIC_CAM_RAM(0x138))
 #define QLCNIC_CRB_DEV_STATE		(QLCNIC_CAM_RAM(0x140))
 
-#define QLCNIC_CRB_DRV_STATE               (QLCNIC_CAM_RAM(0x144))
-#define QLCNIC_CRB_DRV_SCRATCH             (QLCNIC_CAM_RAM(0x148))
-#define QLCNIC_CRB_DEV_PARTITION_INFO      (QLCNIC_CAM_RAM(0x14c))
+#define QLCNIC_CRB_DRV_STATE		(QLCNIC_CAM_RAM(0x144))
+#define QLCNIC_CRB_DRV_SCRATCH		(QLCNIC_CAM_RAM(0x148))
+#define QLCNIC_CRB_DEV_PARTITION_INFO	(QLCNIC_CAM_RAM(0x14c))
 #define QLCNIC_CRB_DRV_IDC_VER		(QLCNIC_CAM_RAM(0x174))
+#define QLCNIC_CRB_DEV_NPAR_STATE	(QLCNIC_CAM_RAM(0x19c))
 #define QLCNIC_ROM_DEV_INIT_TIMEOUT	(0x3e885c)
 #define QLCNIC_ROM_DRV_RESET_TIMEOUT	(0x3e8860)
 
@@ -717,6 +718,9 @@ enum {
 #define QLCNIC_DEV_FAILED		0x6
 #define QLCNIC_DEV_QUISCENT		0x7
 
+#define QLCNIC_DEV_NPAR_NOT_RDY	0
+#define QLCNIC_DEV_NPAR_RDY		1
+
 #define QLC_DEV_CHECK_ACTIVE(VAL, FN)		((VAL) &= (1 << (FN * 4)))
 #define QLC_DEV_SET_REF_CNT(VAL, FN)		((VAL) |= (1 << (FN * 4)))
 #define QLC_DEV_CLR_REF_CNT(VAL, FN)		((VAL) &= ~(1 << (FN * 4)))
@@ -732,8 +736,8 @@ enum {
 #define QLCNIC_TYPE_ISCSI		3
 
 #define QLCNIC_RCODE_DRIVER_INFO		0x20000000
-#define QLCNIC_RCODE_DRIVER_CAN_RELOAD		0x40000000
-#define QLCNIC_RCODE_FATAL_ERROR		0x80000000
+#define QLCNIC_RCODE_DRIVER_CAN_RELOAD		BIT_30
+#define QLCNIC_RCODE_FATAL_ERROR		BIT_31
 #define QLCNIC_FWERROR_PEGNUM(code)		((code) & 0xff)
 #define QLCNIC_FWERROR_CODE(code)		((code >> 8) & 0xfffff)
 
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 3b4fdb3..9a1b60f 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -103,7 +103,14 @@ static irqreturn_t qlcnic_msix_intr(int irq, void *data);
 
 static struct net_device_stats *qlcnic_get_stats(struct net_device *netdev);
 static void qlcnic_config_indev_addr(struct net_device *dev, unsigned long);
-
+static int qlcnic_start_firmware(struct qlcnic_adapter *);
+
+static void qlcnic_dev_set_npar_ready(struct qlcnic_adapter *);
+static void qlcnicvf_clear_ilb_mode(struct qlcnic_adapter *);
+static int qlcnicvf_set_ilb_mode(struct qlcnic_adapter *);
+static int qlcnicvf_config_led(struct qlcnic_adapter *, u32, u32);
+static int qlcnicvf_config_bridged_mode(struct qlcnic_adapter *, u32);
+static int qlcnicvf_start_firmware(struct qlcnic_adapter *);
 /*  PCI Device ID Table  */
 #define ENTRY(device) \
 	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, (device)), \
@@ -375,7 +382,8 @@ static struct qlcnic_nic_template qlcnic_ops = {
 	.config_bridged_mode = qlcnic_config_bridged_mode,
 	.config_led = qlcnic_config_led,
 	.set_ilb_mode = qlcnic_set_ilb_mode,
-	.clear_ilb_mode = qlcnic_clear_ilb_mode
+	.clear_ilb_mode = qlcnic_clear_ilb_mode,
+	.start_firmware = qlcnic_start_firmware
 };
 
 static struct qlcnic_nic_template qlcnic_pf_ops = {
@@ -383,7 +391,17 @@ static struct qlcnic_nic_template qlcnic_pf_ops = {
 	.config_bridged_mode = qlcnic_config_bridged_mode,
 	.config_led = qlcnic_config_led,
 	.set_ilb_mode = qlcnic_set_ilb_mode,
-	.clear_ilb_mode = qlcnic_clear_ilb_mode
+	.clear_ilb_mode = qlcnic_clear_ilb_mode,
+	.start_firmware = qlcnic_start_firmware
+};
+
+static struct qlcnic_nic_template qlcnic_vf_ops = {
+	.get_mac_addr = qlcnic_get_mac_address,
+	.config_bridged_mode = qlcnicvf_config_bridged_mode,
+	.config_led = qlcnicvf_config_led,
+	.set_ilb_mode = qlcnicvf_set_ilb_mode,
+	.clear_ilb_mode = qlcnicvf_clear_ilb_mode,
+	.start_firmware = qlcnicvf_start_firmware
 };
 
 static void
@@ -467,7 +485,6 @@ qlcnic_cleanup_pci_map(struct qlcnic_adapter *adapter)
 		iounmap(adapter->ahw.pci_base0);
 }
 
-/* Use api lock to access this function */
 static int
 qlcnic_set_function_modes(struct qlcnic_adapter *adapter)
 {
@@ -567,6 +584,7 @@ qlcnic_get_driver_mode(struct qlcnic_adapter *adapter)
 		/* Set privilege level for other functions */
 		if (qlcnic_config_npars)
 			qlcnic_set_function_modes(adapter);
+		qlcnic_dev_set_npar_ready(adapter);
 		dev_info(&adapter->pdev->dev,
 			"HAL Version: %d, Management function\n",
 			adapter->fw_hal_version);
@@ -578,6 +596,13 @@ qlcnic_get_driver_mode(struct qlcnic_adapter *adapter)
 			adapter->fw_hal_version);
 		adapter->nic_ops = &qlcnic_pf_ops;
 		break;
+	case QLCNIC_NON_PRIV_FUNC:
+		adapter->op_mode = QLCNIC_NON_PRIV_FUNC;
+		dev_info(&adapter->pdev->dev,
+			"HAL Version: %d Non Privileged function\n",
+			adapter->fw_hal_version);
+		adapter->nic_ops = &qlcnic_vf_ops;
+		break;
 	default:
 		dev_info(&adapter->pdev->dev, "Unknown function mode: %d\n",
 			priv_level);
@@ -772,6 +797,8 @@ wait_init:
 	QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_READY);
 	qlcnic_idc_debug_info(adapter, 1);
 
+	qlcnic_dev_set_npar_ready(adapter);
+
 	qlcnic_check_options(adapter);
 
 	if (adapter->fw_hal_version != QLCNIC_FW_BASE &&
@@ -1244,7 +1271,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (qlcnic_setup_idc_param(adapter))
 		goto err_out_iounmap;
 
-	err = qlcnic_start_firmware(adapter);
+	err = adapter->nic_ops->start_firmware(adapter);
 	if (err) {
 		dev_err(&pdev->dev, "Loading fw failed.Please Reboot\n");
 		goto err_out_decr_ref;
@@ -1410,7 +1437,7 @@ qlcnic_resume(struct pci_dev *pdev)
 	pci_set_master(pdev);
 	pci_restore_state(pdev);
 
-	err = qlcnic_start_firmware(adapter);
+	err = adapter->nic_ops->start_firmware(adapter);
 	if (err) {
 		dev_err(&pdev->dev, "failed to start firmware\n");
 		return err;
@@ -2260,7 +2287,7 @@ qlcnic_fwinit_work(struct work_struct *work)
 {
 	struct qlcnic_adapter *adapter = container_of(work,
 			struct qlcnic_adapter, fw_work.work);
-	u32 dev_state = 0xf;
+	u32 dev_state = 0xf, npar_state;
 
 	if (qlcnic_api_lock(adapter))
 		goto err_ret;
@@ -2273,6 +2300,19 @@ qlcnic_fwinit_work(struct work_struct *work)
 		return;
 	}
 
+	if (adapter->op_mode == QLCNIC_NON_PRIV_FUNC) {
+		npar_state = QLCRD32(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
+		if (npar_state == QLCNIC_DEV_NPAR_RDY) {
+			qlcnic_api_unlock(adapter);
+			goto wait_npar;
+		} else {
+			qlcnic_schedule_work(adapter, qlcnic_fwinit_work,
+				FW_POLL_DELAY);
+			qlcnic_api_unlock(adapter);
+			return;
+		}
+	}
+
 	if (adapter->fw_wait_cnt++ > adapter->reset_ack_timeo) {
 		dev_err(&adapter->pdev->dev, "Reset:Failed to get ack %d sec\n",
 					adapter->reset_ack_timeo);
@@ -2305,7 +2345,7 @@ skip_ack_check:
 
 		qlcnic_api_unlock(adapter);
 
-		if (!qlcnic_start_firmware(adapter)) {
+		if (!adapter->nic_ops->start_firmware(adapter)) {
 			qlcnic_schedule_work(adapter, qlcnic_attach_work, 0);
 			return;
 		}
@@ -2314,6 +2354,7 @@ skip_ack_check:
 
 	qlcnic_api_unlock(adapter);
 
+wait_npar:
 	dev_state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
 	QLCDB(adapter, HW, "Func waiting: Device state=%u\n", dev_state);
 
@@ -2328,7 +2369,7 @@ skip_ack_check:
 		break;
 
 	default:
-		if (!qlcnic_start_firmware(adapter)) {
+		if (!adapter->nic_ops->start_firmware(adapter)) {
 			qlcnic_schedule_work(adapter, qlcnic_attach_work, 0);
 			return;
 		}
@@ -2402,6 +2443,30 @@ qlcnic_dev_request_reset(struct qlcnic_adapter *adapter)
 	qlcnic_api_unlock(adapter);
 }
 
+/* Transit to NPAR READY state from NPAR NOT READY state */
+static void
+qlcnic_dev_set_npar_ready(struct qlcnic_adapter *adapter)
+{
+	u32 state;
+
+	if (adapter->op_mode == QLCNIC_NON_PRIV_FUNC ||
+		adapter->fw_hal_version == QLCNIC_FW_BASE)
+		return;
+
+	if (qlcnic_api_lock(adapter))
+		return;
+
+	state = QLCRD32(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
+
+	if (state != QLCNIC_DEV_NPAR_RDY) {
+		QLCWR32(adapter, QLCNIC_CRB_DEV_NPAR_STATE,
+			QLCNIC_DEV_NPAR_RDY);
+		QLCDB(adapter, DRV, "NPAR READY state set\n");
+	}
+
+	qlcnic_api_unlock(adapter);
+}
+
 static void
 qlcnic_schedule_work(struct qlcnic_adapter *adapter,
 		work_func_t func, int delay)
@@ -2885,6 +2950,47 @@ done:
 	return NOTIFY_DONE;
 }
 
+static int
+qlcnicvf_start_firmware(struct qlcnic_adapter *adapter)
+{
+	int err;
+
+	err = qlcnic_can_start_firmware(adapter);
+	if (err)
+		return err;
+
+	qlcnic_check_options(adapter);
+
+	adapter->need_fw_reset = 0;
+
+	return err;
+}
+
+static int
+qlcnicvf_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable)
+{
+	return -EOPNOTSUPP;
+}
+
+static int
+qlcnicvf_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate)
+{
+	return -EOPNOTSUPP;
+}
+
+static int
+qlcnicvf_set_ilb_mode(struct qlcnic_adapter *adapter)
+{
+	return -EOPNOTSUPP;
+}
+
+static void
+qlcnicvf_clear_ilb_mode(struct qlcnic_adapter *adapter)
+{
+	return;
+}
+
+
 static struct notifier_block	qlcnic_netdev_cb = {
 	.notifier_call = qlcnic_netdev_event,
 };
-- 
1.6.0.2

