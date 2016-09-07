From: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Subject: [PATCH net-next 1/6] be2net: Support UE recovery in BEx/Skyhawk adapters
Date: Wed,  7 Sep 2016 19:57:49 +0530
Message-ID: <20160907142754.13284-2-sriharsha.basavapatna@broadcom.com>
References: <20160907142754.13284-1-sriharsha.basavapatna@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [192.19.245.250] ([192.19.245.250]:51437 "EHLO
        CMRELAYP1.ad.emulex.com" rhost-flags-FAIL-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S934334AbcIGOpw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 10:45:52 -0400
In-Reply-To: <20160907142754.13284-1-sriharsha.basavapatna@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch supports recovery from UEs caused due to Transient Parity
Errors (TPE), in BE2, BE3 and Skyhawk adapters. This change avoids
system reboot when such errors occur. The driver recovers from these
errors such that the adapter resumes full operational status as prior
to the UE.

Following is the list of changes in the driver to support this:

o The driver registers its UE recoverable capability with ARM FW at init
time. This also allows the driver to know if the feature is supported in
the FW.

o As the UE recovery requires precise time bound processing, the driver
creates its own error recovery work queue with a single worker thread (per
module, shared across functions).

o Each function runs an error detection task at an interval of 1 second as
required by the FW. The error detection logic already exists for BEx/SH,
but it now runs in the context of a separate worker thread.

o When an error is detected by the task, if it is recoverable, the PF0
driver instance initiates a soft reset, while other PF driver instances
wait for the reset to complete and the chip to become ready. Once
the chip is ready, all driver instances including PF0, resume to
reinitialize the respective functions.

o The PF0 driver checks for some recovery criteria, to determine if the
recovery can be initiated. If the criteria is not met, the PF0 driver does
not initiate a soft reset, it retains the existing behavior to stop
further processing and requires a reboot to get the chip to operational
state again.

o To allow each function to share the workq, while also making progress in
its recovery process, a per-function recovery state machine is used.
The per-function tasks avoid blocking operations like msleep() while in
this state machine (until reinit state) and instead reschedule for the
required delay.

o With these changes, the existing error recovery code for Lancer also
runs in the context of the new worker thread.

Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be.h         |  68 ++++++-
 drivers/net/ethernet/emulex/benet/be_cmds.c    |  53 ++++-
 drivers/net/ethernet/emulex/benet/be_cmds.h    |  41 +++-
 drivers/net/ethernet/emulex/benet/be_ethtool.c |  40 ++++
 drivers/net/ethernet/emulex/benet/be_hw.h      |   7 +-
 drivers/net/ethernet/emulex/benet/be_main.c    | 256 ++++++++++++++++++++++---
 6 files changed, 430 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 86780b5..eecf24e 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -399,13 +399,13 @@ enum vf_state {
 #define BE_FLAGS_PHY_MISCONFIGURED		BIT(10)
 #define BE_FLAGS_ERR_DETECTION_SCHEDULED	BIT(11)
 #define BE_FLAGS_OS2BMC				BIT(12)
+#define BE_FLAGS_TRY_RECOVERY			BIT(13)
 
 #define BE_UC_PMAC_COUNT			30
 #define BE_VF_UC_PMAC_COUNT			2
 
 #define MAX_ERR_RECOVERY_RETRY_COUNT		3
 #define ERR_DETECTION_DELAY			1000
-#define ERR_RECOVERY_RETRY_DELAY		30000
 
 /* Ethtool set_dump flags */
 #define LANCER_INITIATE_FW_DUMP			0x1
@@ -512,6 +512,66 @@ struct be_eth_addr {
 	unsigned char mac[ETH_ALEN];
 };
 
+#define BE_SEC	1000			/* in msec */
+#define BE_MIN	(60 * BE_SEC)		/* in msec */
+#define BE_HOUR	(60 * BE_MIN)		/* in msec */
+
+#define ERR_RECOVERY_MAX_RETRY_COUNT		3
+#define ERR_RECOVERY_DETECTION_DELAY		BE_SEC
+#define ERR_RECOVERY_RETRY_DELAY		(30 * BE_SEC)
+
+/* UE-detection-duration in BEx/Skyhawk:
+ * All PFs must wait for this duration after they detect UE before reading
+ * SLIPORT_SEMAPHORE register. At the end of this duration, the Firmware
+ * guarantees that the SLIPORT_SEMAPHORE register is updated to indicate
+ * if the UE is recoverable.
+ */
+#define ERR_RECOVERY_UE_DETECT_DURATION			BE_SEC
+
+/* Initial idle time (in msec) to elapse after driver load,
+ * before UE recovery is allowed.
+ */
+#define ERR_IDLE_HR			24
+#define ERR_RECOVERY_IDLE_TIME		(ERR_IDLE_HR * BE_HOUR)
+
+/* Time interval (in msec) after which UE recovery can be repeated */
+#define ERR_INTERVAL_HR			72
+#define ERR_RECOVERY_INTERVAL		(ERR_INTERVAL_HR * BE_HOUR)
+
+/* BEx/SH UE recovery state machine */
+enum {
+	ERR_RECOVERY_ST_NONE = 0,		/* No Recovery */
+	ERR_RECOVERY_ST_DETECT = 1,		/* UE detection duration */
+	ERR_RECOVERY_ST_RESET = 2,		/* Reset Phase (PF0 only) */
+	ERR_RECOVERY_ST_PRE_POLL = 3,		/* Pre-Poll Phase (all PFs) */
+	ERR_RECOVERY_ST_REINIT = 4		/* Re-initialize Phase */
+};
+
+struct be_error_recovery {
+	/* Lancer error recovery variables */
+	u8 recovery_retries;
+
+	/* BEx/Skyhawk error recovery variables */
+	u8 recovery_state;
+	u16 ue_to_reset_time;		/* Time after UE, to soft reset
+					 * the chip - PF0 only
+					 */
+	u16 ue_to_poll_time;		/* Time after UE, to Restart Polling
+					 * of SLIPORT_SEMAPHORE reg
+					 */
+	u16 last_err_code;
+	bool recovery_supported;
+	unsigned long probe_time;
+	unsigned long last_recovery_time;
+
+	/* Common to both Lancer & BEx/SH error recovery */
+	u32 resched_delay;
+	struct delayed_work err_detection_work;
+};
+
+/* Ethtool priv_flags */
+#define	BE_DISABLE_TPE_RECOVERY	0x1
+
 struct be_adapter {
 	struct pci_dev *pdev;
 	struct net_device *netdev;
@@ -560,7 +620,6 @@ struct be_adapter {
 	struct delayed_work work;
 	u16 work_counter;
 
-	struct delayed_work be_err_detection_work;
 	u8 recovery_retries;
 	u8 err_flags;
 	bool pcicfg_mapped;	/* pcicfg obtained via pci_iomap() */
@@ -634,6 +693,8 @@ struct be_adapter {
 	u32 fat_dump_len;
 	u16 serial_num[CNTL_SERIAL_NUM_WORDS];
 	u8 phy_state; /* state of sfp optics (functional, faulted, etc.,) */
+	u32 priv_flags; /* ethtool get/set_priv_flags() */
+	struct be_error_recovery error_recovery;
 };
 
 /* Used for defered FW config cmds. Add fields to this struct as reqd */
@@ -867,6 +928,9 @@ static inline bool is_ipv4_pkt(struct sk_buff *skb)
 	return skb->protocol == htons(ETH_P_IP) && ip_hdr(skb)->version == 4;
 }
 
+#define be_error_recovering(adapter)	\
+		(adapter->flags & BE_FLAGS_TRY_RECOVERY)
+
 #define BE_ERROR_EEH		1
 #define BE_ERROR_UE		BIT(1)
 #define BE_ERROR_FW		BIT(2)
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index fa11a5a..92794f3 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -705,7 +705,7 @@ static int be_mbox_notify_wait(struct be_adapter *adapter)
 	return 0;
 }
 
-static u16 be_POST_stage_get(struct be_adapter *adapter)
+u16 be_POST_stage_get(struct be_adapter *adapter)
 {
 	u32 sem;
 
@@ -4954,6 +4954,57 @@ int be_cmd_set_logical_link_config(struct be_adapter *adapter,
 							  1, domain);
 	return status;
 }
+
+int be_cmd_set_features(struct be_adapter *adapter)
+{
+	struct be_cmd_resp_set_features *resp;
+	struct be_cmd_req_set_features *req;
+	struct be_mcc_wrb *wrb;
+	int status;
+
+	if (mutex_lock_interruptible(&adapter->mcc_lock))
+		return -1;
+
+	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
+
+	req = embedded_payload(wrb);
+
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+			       OPCODE_COMMON_SET_FEATURES,
+			       sizeof(*req), wrb, NULL);
+
+	req->features = cpu_to_le32(BE_FEATURE_UE_RECOVERY);
+	req->parameter_len = cpu_to_le32(sizeof(struct be_req_ue_recovery));
+	req->parameter.req.uer = cpu_to_le32(BE_UE_RECOVERY_UER_MASK);
+
+	status = be_mcc_notify_wait(adapter);
+	if (status)
+		goto err;
+
+	resp = embedded_payload(wrb);
+
+	adapter->error_recovery.ue_to_poll_time =
+		le16_to_cpu(resp->parameter.resp.ue2rp);
+	adapter->error_recovery.ue_to_reset_time =
+		le16_to_cpu(resp->parameter.resp.ue2sr);
+	adapter->error_recovery.recovery_supported = true;
+err:
+	/* Checking "MCC_STATUS_INVALID_LENGTH" for SKH as FW
+	 * returns this error in older firmware versions
+	 */
+	if (base_status(status) == MCC_STATUS_ILLEGAL_REQUEST ||
+	    base_status(status) == MCC_STATUS_INVALID_LENGTH)
+		dev_info(&adapter->pdev->dev,
+			 "Adapter does not support HW error recovery\n");
+
+	mutex_unlock(&adapter->mcc_lock);
+	return status;
+}
+
 int be_roce_mcc_cmd(void *netdev_handle, void *wrb_payload,
 		    int wrb_payload_size, u16 *cmd_status, u16 *ext_status)
 {
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 0d6be22..686cbe0 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -58,7 +58,8 @@ enum mcc_base_status {
 	MCC_STATUS_INSUFFICIENT_BUFFER = 4,
 	MCC_STATUS_UNAUTHORIZED_REQUEST = 5,
 	MCC_STATUS_NOT_SUPPORTED = 66,
-	MCC_STATUS_FEATURE_NOT_SUPPORTED = 68
+	MCC_STATUS_FEATURE_NOT_SUPPORTED = 68,
+	MCC_STATUS_INVALID_LENGTH = 116
 };
 
 /* Additional status */
@@ -308,6 +309,7 @@ struct be_mcc_mailbox {
 #define OPCODE_COMMON_READ_OBJECT			171
 #define OPCODE_COMMON_WRITE_OBJECT			172
 #define OPCODE_COMMON_DELETE_OBJECT			174
+#define OPCODE_COMMON_SET_FEATURES			191
 #define OPCODE_COMMON_MANAGE_IFACE_FILTERS		193
 #define OPCODE_COMMON_GET_IFACE_LIST			194
 #define OPCODE_COMMON_ENABLE_DISABLE_VF			196
@@ -2315,6 +2317,41 @@ struct be_cmd_resp_get_iface_list {
 	struct be_if_desc if_desc;
 };
 
+/************** Set Features *******************/
+#define	BE_FEATURE_UE_RECOVERY		0x10
+#define	BE_UE_RECOVERY_UER_MASK		0x1
+
+struct be_req_ue_recovery {
+	u32	uer;
+	u32	rsvd;
+};
+
+struct be_cmd_req_set_features {
+	struct be_cmd_req_hdr hdr;
+	u32 features;
+	u32 parameter_len;
+	union {
+		struct be_req_ue_recovery req;
+		u32 rsvd[2];
+	} parameter;
+};
+
+struct be_resp_ue_recovery {
+	u32 uer;
+	u16 ue2rp;
+	u16 ue2sr;
+};
+
+struct be_cmd_resp_set_features {
+	struct be_cmd_resp_hdr hdr;
+	u32 features;
+	u32 parameter_len;
+	union {
+		struct be_resp_ue_recovery resp;
+		u32 rsvd[2];
+	} parameter;
+};
+
 /*************** Set logical link ********************/
 #define PLINK_ENABLE            BIT(0)
 #define PLINK_TRACK             BIT(8)
@@ -2343,6 +2380,7 @@ struct be_cmd_req_manage_iface_filters {
 	u32 cap_control_flags;
 } __packed;
 
+u16 be_POST_stage_get(struct be_adapter *adapter);
 int be_pci_fnum_get(struct be_adapter *adapter);
 int be_fw_wait_ready(struct be_adapter *adapter);
 int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
@@ -2470,3 +2508,4 @@ int be_cmd_manage_iface(struct be_adapter *adapter, u32 iface, u8 op);
 int be_cmd_set_sriov_config(struct be_adapter *adapter,
 			    struct be_resources res, u16 num_vfs,
 			    struct be_resources *vft_res);
+int be_cmd_set_features(struct be_adapter *adapter);
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 50e7be5..0a48a31 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -421,6 +421,10 @@ static void be_get_ethtool_stats(struct net_device *netdev,
 	}
 }
 
+static const char be_priv_flags[][ETH_GSTRING_LEN] = {
+	"disable-tpe-recovery"
+};
+
 static void be_get_stat_strings(struct net_device *netdev, uint32_t stringset,
 				uint8_t *data)
 {
@@ -454,6 +458,10 @@ static void be_get_stat_strings(struct net_device *netdev, uint32_t stringset,
 			data += ETH_GSTRING_LEN;
 		}
 		break;
+	case ETH_SS_PRIV_FLAGS:
+		for (i = 0; i < ARRAY_SIZE(be_priv_flags); i++)
+			strcpy(data + i * ETH_GSTRING_LEN, be_priv_flags[i]);
+		break;
 	}
 }
 
@@ -468,6 +476,8 @@ static int be_get_sset_count(struct net_device *netdev, int stringset)
 		return ETHTOOL_STATS_NUM +
 			adapter->num_rx_qs * ETHTOOL_RXSTATS_NUM +
 			adapter->num_tx_qs * ETHTOOL_TXSTATS_NUM;
+	case ETH_SS_PRIV_FLAGS:
+		return ARRAY_SIZE(be_priv_flags);
 	default:
 		return -EINVAL;
 	}
@@ -1360,6 +1370,34 @@ err:
 	return be_cmd_status(status);
 }
 
+static u32 be_get_priv_flags(struct net_device *netdev)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+
+	return adapter->priv_flags;
+}
+
+static int be_set_priv_flags(struct net_device *netdev, u32 flags)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+	bool tpe_old = !!(adapter->priv_flags & BE_DISABLE_TPE_RECOVERY);
+	bool tpe_new = !!(flags & BE_DISABLE_TPE_RECOVERY);
+
+	if (tpe_old != tpe_new) {
+		if (tpe_new) {
+			adapter->priv_flags |= BE_DISABLE_TPE_RECOVERY;
+			dev_info(&adapter->pdev->dev,
+				 "HW error recovery is disabled\n");
+		} else {
+			adapter->priv_flags &= ~BE_DISABLE_TPE_RECOVERY;
+			dev_info(&adapter->pdev->dev,
+				 "HW error recovery is enabled\n");
+		}
+	}
+
+	return 0;
+}
+
 const struct ethtool_ops be_ethtool_ops = {
 	.get_settings = be_get_settings,
 	.get_drvinfo = be_get_drvinfo,
@@ -1373,6 +1411,8 @@ const struct ethtool_ops be_ethtool_ops = {
 	.get_ringparam = be_get_ringparam,
 	.get_pauseparam = be_get_pauseparam,
 	.set_pauseparam = be_set_pauseparam,
+	.set_priv_flags = be_set_priv_flags,
+	.get_priv_flags = be_get_priv_flags,
 	.get_strings = be_get_stat_strings,
 	.set_phys_id = be_set_phys_id,
 	.set_dump = be_set_dump,
diff --git a/drivers/net/ethernet/emulex/benet/be_hw.h b/drivers/net/ethernet/emulex/benet/be_hw.h
index c684bb3..92942c8 100644
--- a/drivers/net/ethernet/emulex/benet/be_hw.h
+++ b/drivers/net/ethernet/emulex/benet/be_hw.h
@@ -32,18 +32,23 @@
 #define MPU_EP_CONTROL 		0
 
 /********** MPU semphore: used for SH & BE  *************/
+#define SLIPORT_SOFTRESET_OFFSET		0x5c	/* CSR BAR offset */
 #define SLIPORT_SEMAPHORE_OFFSET_BEx		0xac  /* CSR BAR offset */
 #define SLIPORT_SEMAPHORE_OFFSET_SH		0x94  /* PCI-CFG offset */
 #define POST_STAGE_MASK				0x0000FFFF
 #define POST_ERR_MASK				0x1
 #define POST_ERR_SHIFT				31
+#define POST_ERR_RECOVERY_CODE_MASK		0xFFF
+
+/* Soft Reset register masks */
+#define SLIPORT_SOFTRESET_SR_MASK		0x00000080	/* SR bit */
 
 /* MPU semphore POST stage values */
 #define POST_STAGE_AWAITING_HOST_RDY 	0x1 /* FW awaiting goahead from host */
 #define POST_STAGE_HOST_RDY 		0x2 /* Host has given go-ahed to FW */
 #define POST_STAGE_BE_RESET		0x3 /* Host wants to reset chip */
 #define POST_STAGE_ARMFW_RDY		0xc000	/* FW is done with POST */
-
+#define POST_STAGE_RECOVERABLE_ERR	0xE000	/* Recoverable err detected */
 
 /* Lancer SLIPORT registers */
 #define SLIPORT_STATUS_OFFSET		0x404
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index f7584d4..3be5d61 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -41,6 +41,11 @@ static ushort rx_frag_size = 2048;
 module_param(rx_frag_size, ushort, S_IRUGO);
 MODULE_PARM_DESC(rx_frag_size, "Size of a fragment that holds rcvd data.");
 
+/* Per-module error detection/recovery workq shared across all functions.
+ * Each function schedules its own work request on this shared workq.
+ */
+struct workqueue_struct *be_err_recovery_workq;
+
 static const struct pci_device_id be_dev_ids[] = {
 	{ PCI_DEVICE(BE_VENDOR_ID, BE_DEVICE_ID1) },
 	{ PCI_DEVICE(BE_VENDOR_ID, BE_DEVICE_ID2) },
@@ -3358,9 +3363,7 @@ void be_detect_error(struct be_adapter *adapter)
 		 */
 
 		if (ue_lo || ue_hi) {
-			dev_err(dev,
-				"Unrecoverable Error detected in the adapter");
-			dev_err(dev, "Please reboot server to recover");
+			dev_err(dev, "Error detected in the adapter");
 			if (skyhawk_chip(adapter))
 				be_set_error(adapter, BE_ERROR_UE);
 
@@ -3903,8 +3906,13 @@ static void be_cancel_worker(struct be_adapter *adapter)
 
 static void be_cancel_err_detection(struct be_adapter *adapter)
 {
+	struct be_error_recovery *err_rec = &adapter->error_recovery;
+
+	if (!be_err_recovery_workq)
+		return;
+
 	if (adapter->flags & BE_FLAGS_ERR_DETECTION_SCHEDULED) {
-		cancel_delayed_work_sync(&adapter->be_err_detection_work);
+		cancel_delayed_work_sync(&err_rec->err_detection_work);
 		adapter->flags &= ~BE_FLAGS_ERR_DETECTION_SCHEDULED;
 	}
 }
@@ -4503,10 +4511,25 @@ static void be_schedule_worker(struct be_adapter *adapter)
 	adapter->flags |= BE_FLAGS_WORKER_SCHEDULED;
 }
 
+static void be_destroy_err_recovery_workq(void)
+{
+	if (!be_err_recovery_workq)
+		return;
+
+	flush_workqueue(be_err_recovery_workq);
+	destroy_workqueue(be_err_recovery_workq);
+	be_err_recovery_workq = NULL;
+}
+
 static void be_schedule_err_detection(struct be_adapter *adapter, u32 delay)
 {
-	schedule_delayed_work(&adapter->be_err_detection_work,
-			      msecs_to_jiffies(delay));
+	struct be_error_recovery *err_rec = &adapter->error_recovery;
+
+	if (!be_err_recovery_workq)
+		return;
+
+	queue_delayed_work(be_err_recovery_workq, &err_rec->err_detection_work,
+			   msecs_to_jiffies(delay));
 	adapter->flags |= BE_FLAGS_ERR_DETECTION_SCHEDULED;
 }
 
@@ -4635,10 +4658,15 @@ static inline int fw_major_num(const char *fw_ver)
 	return fw_major;
 }
 
-/* If any VFs are already enabled don't FLR the PF */
+/* If it is error recovery, FLR the PF
+ * Else if any VFs are already enabled don't FLR the PF
+ */
 static bool be_reset_required(struct be_adapter *adapter)
 {
-	return pci_num_vf(adapter->pdev) ? false : true;
+	if (be_error_recovering(adapter))
+		return true;
+	else
+		return pci_num_vf(adapter->pdev) == 0;
 }
 
 /* Wait for the FW to be ready and perform the required initialization */
@@ -4650,6 +4678,9 @@ static int be_func_init(struct be_adapter *adapter)
 	if (status)
 		return status;
 
+	/* FW is now ready; clear errors to allow cmds/doorbell */
+	be_clear_error(adapter, BE_CLEAR_ALL);
+
 	if (be_reset_required(adapter)) {
 		status = be_cmd_reset_function(adapter);
 		if (status)
@@ -4657,9 +4688,6 @@ static int be_func_init(struct be_adapter *adapter)
 
 		/* Wait for interrupts to quiesce after an FLR */
 		msleep(100);
-
-		/* We can clear all errors when function reset succeeds */
-		be_clear_error(adapter, BE_CLEAR_ALL);
 	}
 
 	/* Tell FW we're ready to fire cmds */
@@ -4767,6 +4795,9 @@ static int be_setup(struct be_adapter *adapter)
 	if (!status && be_pause_supported(adapter))
 		adapter->phy.fc_autoneg = 1;
 
+	if (be_physfn(adapter) && !lancer_chip(adapter))
+		be_cmd_set_features(adapter);
+
 	be_schedule_worker(adapter);
 	adapter->flags |= BE_FLAGS_SETUP_DONE;
 	return 0;
@@ -5210,13 +5241,145 @@ static int be_resume(struct be_adapter *adapter)
 	return 0;
 }
 
+static void be_soft_reset(struct be_adapter *adapter)
+{
+	u32 val;
+
+	dev_info(&adapter->pdev->dev, "Initiating chip soft reset\n");
+	val = ioread32(adapter->pcicfg + SLIPORT_SOFTRESET_OFFSET);
+	val |= SLIPORT_SOFTRESET_SR_MASK;
+	iowrite32(val, adapter->pcicfg + SLIPORT_SOFTRESET_OFFSET);
+}
+
+static bool be_err_is_recoverable(struct be_adapter *adapter)
+{
+	struct be_error_recovery *err_rec = &adapter->error_recovery;
+	unsigned long initial_idle_time =
+		msecs_to_jiffies(ERR_RECOVERY_IDLE_TIME);
+	unsigned long recovery_interval =
+		msecs_to_jiffies(ERR_RECOVERY_INTERVAL);
+	u16 ue_err_code;
+	u32 val;
+
+	val = be_POST_stage_get(adapter);
+	if ((val & POST_STAGE_RECOVERABLE_ERR) != POST_STAGE_RECOVERABLE_ERR)
+		return false;
+	ue_err_code = val & POST_ERR_RECOVERY_CODE_MASK;
+	if (ue_err_code == 0)
+		return false;
+
+	dev_err(&adapter->pdev->dev, "Recoverable HW error code: 0x%x\n",
+		ue_err_code);
+
+	if (jiffies - err_rec->probe_time <= initial_idle_time) {
+		dev_err(&adapter->pdev->dev,
+			"Cannot recover within %lu sec from driver load\n",
+			jiffies_to_msecs(initial_idle_time) / MSEC_PER_SEC);
+		return false;
+	}
+
+	if (err_rec->last_recovery_time &&
+	    (jiffies - err_rec->last_recovery_time <= recovery_interval)) {
+		dev_err(&adapter->pdev->dev,
+			"Cannot recover within %lu sec from last recovery\n",
+			jiffies_to_msecs(recovery_interval) / MSEC_PER_SEC);
+		return false;
+	}
+
+	if (ue_err_code == err_rec->last_err_code) {
+		dev_err(&adapter->pdev->dev,
+			"Cannot recover from a consecutive TPE error\n");
+		return false;
+	}
+
+	err_rec->last_recovery_time = jiffies;
+	err_rec->last_err_code = ue_err_code;
+	return true;
+}
+
+static int be_tpe_recover(struct be_adapter *adapter)
+{
+	struct be_error_recovery *err_rec = &adapter->error_recovery;
+	int status = -EAGAIN;
+	u32 val;
+
+	switch (err_rec->recovery_state) {
+	case ERR_RECOVERY_ST_NONE:
+		err_rec->recovery_state = ERR_RECOVERY_ST_DETECT;
+		err_rec->resched_delay = ERR_RECOVERY_UE_DETECT_DURATION;
+		break;
+
+	case ERR_RECOVERY_ST_DETECT:
+		val = be_POST_stage_get(adapter);
+		if ((val & POST_STAGE_RECOVERABLE_ERR) !=
+		    POST_STAGE_RECOVERABLE_ERR) {
+			dev_err(&adapter->pdev->dev,
+				"Unrecoverable HW error detected: 0x%x\n", val);
+			status = -EINVAL;
+			err_rec->resched_delay = 0;
+			break;
+		}
+
+		dev_err(&adapter->pdev->dev, "Recoverable HW error detected\n");
+
+		/* Only PF0 initiates Chip Soft Reset. But PF0 must wait UE2SR
+		 * milliseconds before it checks for final error status in
+		 * SLIPORT_SEMAPHORE to determine if recovery criteria is met.
+		 * If it does, then PF0 initiates a Soft Reset.
+		 */
+		if (adapter->pf_num == 0) {
+			err_rec->recovery_state = ERR_RECOVERY_ST_RESET;
+			err_rec->resched_delay = err_rec->ue_to_reset_time -
+					ERR_RECOVERY_UE_DETECT_DURATION;
+			break;
+		}
+
+		err_rec->recovery_state = ERR_RECOVERY_ST_PRE_POLL;
+		err_rec->resched_delay = err_rec->ue_to_poll_time -
+					ERR_RECOVERY_UE_DETECT_DURATION;
+		break;
+
+	case ERR_RECOVERY_ST_RESET:
+		if (!be_err_is_recoverable(adapter)) {
+			dev_err(&adapter->pdev->dev,
+				"Failed to meet recovery criteria\n");
+			status = -EIO;
+			err_rec->resched_delay = 0;
+			break;
+		}
+		be_soft_reset(adapter);
+		err_rec->recovery_state = ERR_RECOVERY_ST_PRE_POLL;
+		err_rec->resched_delay = err_rec->ue_to_poll_time -
+					err_rec->ue_to_reset_time;
+		break;
+
+	case ERR_RECOVERY_ST_PRE_POLL:
+		err_rec->recovery_state = ERR_RECOVERY_ST_REINIT;
+		err_rec->resched_delay = 0;
+		status = 0;			/* done */
+		break;
+
+	default:
+		status = -EINVAL;
+		err_rec->resched_delay = 0;
+		break;
+	}
+
+	return status;
+}
+
 static int be_err_recover(struct be_adapter *adapter)
 {
 	int status;
 
-	/* Error recovery is supported only Lancer as of now */
-	if (!lancer_chip(adapter))
-		return -EIO;
+	if (!lancer_chip(adapter)) {
+		if (!adapter->error_recovery.recovery_supported ||
+		    adapter->priv_flags & BE_DISABLE_TPE_RECOVERY)
+			return -EIO;
+		status = be_tpe_recover(adapter);
+		if (status)
+			goto err;
+	}
 
 	/* Wait for adapter to reach quiescent state before
 	 * destroying queues
@@ -5225,59 +5388,74 @@ static int be_err_recover(struct be_adapter *adapter)
 	if (status)
 		goto err;
 
+	adapter->flags |= BE_FLAGS_TRY_RECOVERY;
+
 	be_cleanup(adapter);
 
 	status = be_resume(adapter);
 	if (status)
 		goto err;
 
-	return 0;
+	adapter->flags &= ~BE_FLAGS_TRY_RECOVERY;
+
 err:
 	return status;
 }
 
 static void be_err_detection_task(struct work_struct *work)
 {
+	struct be_error_recovery *err_rec =
+			container_of(work, struct be_error_recovery,
+				     err_detection_work.work);
 	struct be_adapter *adapter =
-				container_of(work, struct be_adapter,
-					     be_err_detection_work.work);
+			container_of(err_rec, struct be_adapter,
+				     error_recovery);
+	u32 resched_delay = ERR_RECOVERY_DETECTION_DELAY;
 	struct device *dev = &adapter->pdev->dev;
 	int recovery_status;
-	int delay = ERR_DETECTION_DELAY;
 
 	be_detect_error(adapter);
-
-	if (be_check_error(adapter, BE_ERROR_HW))
-		recovery_status = be_err_recover(adapter);
-	else
+	if (!be_check_error(adapter, BE_ERROR_HW))
 		goto reschedule_task;
 
+	recovery_status = be_err_recover(adapter);
 	if (!recovery_status) {
-		adapter->recovery_retries = 0;
+		err_rec->recovery_retries = 0;
+		err_rec->recovery_state = ERR_RECOVERY_ST_NONE;
 		dev_info(dev, "Adapter recovery successful\n");
 		goto reschedule_task;
-	} else if (be_virtfn(adapter)) {
+	} else if (!lancer_chip(adapter) && err_rec->resched_delay) {
+		/* BEx/SH recovery state machine */
+		if (adapter->pf_num == 0 &&
+		    err_rec->recovery_state > ERR_RECOVERY_ST_DETECT)
+			dev_err(&adapter->pdev->dev,
+				"Adapter recovery in progress\n");
+		resched_delay = err_rec->resched_delay;
+		goto reschedule_task;
+	} else if (lancer_chip(adapter) && be_virtfn(adapter)) {
 		/* For VFs, check if PF have allocated resources
 		 * every second.
 		 */
 		dev_err(dev, "Re-trying adapter recovery\n");
 		goto reschedule_task;
-	} else if (adapter->recovery_retries++ <
-		   MAX_ERR_RECOVERY_RETRY_COUNT) {
+	} else if (lancer_chip(adapter) && err_rec->recovery_retries++ <
+		   ERR_RECOVERY_MAX_RETRY_COUNT) {
 		/* In case of another error during recovery, it takes 30 sec
 		 * for adapter to come out of error. Retry error recovery after
 		 * this time interval.
 		 */
 		dev_err(&adapter->pdev->dev, "Re-trying adapter recovery\n");
-		delay = ERR_RECOVERY_RETRY_DELAY;
+		resched_delay = ERR_RECOVERY_RETRY_DELAY;
 		goto reschedule_task;
 	} else {
 		dev_err(dev, "Adapter recovery failed\n");
+		dev_err(dev, "Please reboot server to recover\n");
 	}
 
 	return;
+
 reschedule_task:
-	be_schedule_err_detection(adapter, delay);
+	be_schedule_err_detection(adapter, resched_delay);
 }
 
 static void be_log_sfp_info(struct be_adapter *adapter)
@@ -5490,7 +5668,10 @@ static int be_drv_init(struct be_adapter *adapter)
 	pci_save_state(adapter->pdev);
 
 	INIT_DELAYED_WORK(&adapter->work, be_worker);
-	INIT_DELAYED_WORK(&adapter->be_err_detection_work,
+
+	adapter->error_recovery.recovery_state = ERR_RECOVERY_ST_NONE;
+	adapter->error_recovery.resched_delay = 0;
+	INIT_DELAYED_WORK(&adapter->error_recovery.err_detection_work,
 			  be_err_detection_task);
 
 	adapter->rx_fc = true;
@@ -5681,6 +5862,7 @@ static int be_probe(struct pci_dev *pdev, const struct pci_device_id *pdev_id)
 	be_roce_dev_add(adapter);
 
 	be_schedule_err_detection(adapter, ERR_DETECTION_DELAY);
+	adapter->error_recovery.probe_time = jiffies;
 
 	/* On Die temperature not supported for VF. */
 	if (be_physfn(adapter) && IS_ENABLED(CONFIG_BE2NET_HWMON)) {
@@ -5926,6 +6108,8 @@ static struct pci_driver be_driver = {
 
 static int __init be_init_module(void)
 {
+	int status;
+
 	if (rx_frag_size != 8192 && rx_frag_size != 4096 &&
 	    rx_frag_size != 2048) {
 		printk(KERN_WARNING DRV_NAME
@@ -5945,7 +6129,17 @@ static int __init be_init_module(void)
 		return -1;
 	}
 
-	return pci_register_driver(&be_driver);
+	be_err_recovery_workq =
+		create_singlethread_workqueue("be_err_recover");
+	if (!be_err_recovery_workq)
+		pr_warn(DRV_NAME "Could not create error recovery workqueue\n");
+
+	status = pci_register_driver(&be_driver);
+	if (status) {
+		destroy_workqueue(be_wq);
+		be_destroy_err_recovery_workq();
+	}
+	return status;
 }
 module_init(be_init_module);
 
@@ -5953,6 +6147,8 @@ static void __exit be_exit_module(void)
 {
 	pci_unregister_driver(&be_driver);
 
+	be_destroy_err_recovery_workq();
+
 	if (be_wq)
 		destroy_workqueue(be_wq);
 }
-- 
2.10.0.rc2.20.g5b18e70
