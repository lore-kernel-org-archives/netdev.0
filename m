From: Atul Gupta <atul.gupta@chelsio.com>
Subject: [PATCH net-next 2/3] cxgb4: Add PTP Hardware Clock (PHC) support
Date: Tue,  4 Jul 2017 16:46:21 +0530
Message-ID: <1499166982-4875-3-git-send-email-atul.gupta@chelsio.com>
References: <1499166982-4875-1-git-send-email-atul.gupta@chelsio.com>
Cc: richardcochran@gmail.com, ganeshgr@chelsio.com,
        Atul Gupta <atul.gupta@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:62834 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751910AbdGDLRi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2017 07:17:38 -0400
In-Reply-To: <1499166982-4875-1-git-send-email-atul.gupta@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add PTP IEEE-1588 support and make it accessible via PHC subsystem.
The functionality is enabled for T5/T6 adapters. Driver interfaces with
Firmware to program and adjust the clock offset.

Cc: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Atul Gupta <atul.gupta@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   6 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.c  | 281 ++++++++++++++++++++++++
 2 files changed, 287 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 584aa60..86f92e3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -5202,6 +5202,9 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		mutex_unlock(&uld_mutex);
 	}
 
+	if (!is_t4(adapter->params.chip))
+		cxgb4_ptp_init(adapter);
+
 	print_adapter_info(adapter);
 	setup_fw_sge_queues(adapter);
 	return 0;
@@ -5311,6 +5314,9 @@ static void remove_one(struct pci_dev *pdev)
 
 		debugfs_remove_recursive(adapter->debugfs_root);
 
+		if (!is_t4(adapter->params.chip))
+			cxgb4_ptp_stop(adapter);
+
 		/* If we allocated filters, free up state associated with any
 		 * valid filters ...
 		 */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.c
index 0efcbad..50517cf 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.c
@@ -192,3 +192,284 @@ int cxgb4_ptp_redirect_rx_packet(struct adapter *adapter, struct port_info *pi)
 			"PTP: %s error %d\n", __func__, -err);
 	return err;
 }
+
+/**
+ * @ptp: ptp clock structure
+ * @ppb: Desired frequency change in parts per billion
+ *
+ * Adjust the frequency of the PHC cycle counter by the indicated ppb from
+ * the base frequency.
+ */
+static int cxgb4_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
+{
+	struct adapter *adapter = (struct adapter *)container_of(ptp,
+				   struct adapter, ptp_clock_info);
+	struct fw_ptp_cmd c;
+	int err;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_portid = cpu_to_be32(FW_CMD_OP_V(FW_PTP_CMD) |
+				     FW_CMD_REQUEST_F |
+				     FW_CMD_WRITE_F |
+				     FW_PTP_CMD_PORTID_V(0));
+	c.retval_len16 = cpu_to_be32(FW_CMD_LEN16_V(sizeof(c) / 16));
+	c.u.ts.sc = FW_PTP_SC_ADJ_FREQ;
+	c.u.ts.sign = (ppb < 0) ? 1 : 0;
+	if (ppb < 0)
+		ppb = -ppb;
+	c.u.ts.ppb = cpu_to_be32(ppb);
+
+	err = t4_wr_mbox(adapter, adapter->mbox, &c, sizeof(c), NULL);
+	if (err < 0)
+		dev_err(adapter->pdev_dev,
+			"PTP: %s error %d\n", __func__, -err);
+
+	return err;
+}
+
+/**
+ * cxgb4_ptp_fineadjtime - Shift the time of the hardware clock
+ * @ptp: ptp clock structure
+ * @delta: Desired change in nanoseconds
+ *
+ * Adjust the timer by resetting the timecounter structure.
+ */
+static int  cxgb4_ptp_fineadjtime(struct adapter *adapter, s64 delta)
+{
+	struct fw_ptp_cmd c;
+	int err;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_portid = cpu_to_be32(FW_CMD_OP_V(FW_PTP_CMD) |
+			     FW_CMD_REQUEST_F |
+			     FW_CMD_WRITE_F |
+			     FW_PTP_CMD_PORTID_V(0));
+	c.retval_len16 = cpu_to_be32(FW_CMD_LEN16_V(sizeof(c) / 16));
+	c.u.ts.sc = FW_PTP_SC_ADJ_FTIME;
+	c.u.ts.tm = cpu_to_be64(delta);
+
+	err = t4_wr_mbox(adapter, adapter->mbox, &c, sizeof(c), NULL);
+	if (err < 0)
+		dev_err(adapter->pdev_dev,
+			"PTP: %s error %d\n", __func__, -err);
+	return err;
+}
+
+/**
+ * cxgb4_ptp_adjtime - Shift the time of the hardware clock
+ * @ptp: ptp clock structure
+ * @delta: Desired change in nanoseconds
+ *
+ * Adjust the timer by resetting the timecounter structure.
+ */
+static int cxgb4_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
+{
+	struct adapter *adapter =
+		(struct adapter *)container_of(ptp, struct adapter,
+					       ptp_clock_info);
+	struct fw_ptp_cmd c;
+	s64 sign = 1;
+	int err;
+
+	if (delta < 0)
+		sign = -1;
+
+	if (delta * sign > PTP_CLOCK_MAX_ADJTIME) {
+		memset(&c, 0, sizeof(c));
+		c.op_to_portid = cpu_to_be32(FW_CMD_OP_V(FW_PTP_CMD) |
+					     FW_CMD_REQUEST_F |
+					     FW_CMD_WRITE_F |
+					     FW_PTP_CMD_PORTID_V(0));
+		c.retval_len16 = cpu_to_be32(FW_CMD_LEN16_V(sizeof(c) / 16));
+		c.u.ts.sc = FW_PTP_SC_ADJ_TIME;
+		c.u.ts.sign = (delta < 0) ? 1 : 0;
+		if (delta < 0)
+			delta = -delta;
+		c.u.ts.tm = cpu_to_be64(delta);
+
+		err = t4_wr_mbox(adapter, adapter->mbox, &c, sizeof(c), NULL);
+		if (err < 0)
+			dev_err(adapter->pdev_dev,
+				"PTP: %s error %d\n", __func__, -err);
+	} else {
+		err = cxgb4_ptp_fineadjtime(adapter, delta);
+	}
+
+	return err;
+}
+
+/**
+ * cxgb4_ptp_gettime - Reads the current time from the hardware clock
+ * @ptp: ptp clock structure
+ * @ts: timespec structure to hold the current time value
+ *
+ * Read the timecounter and return the correct value in ns after converting
+ * it into a struct timespec.
+ */
+static int cxgb4_ptp_gettime(struct ptp_clock_info *ptp, struct timespec64 *ts)
+{
+	struct adapter *adapter = (struct adapter *)container_of(ptp,
+				   struct adapter, ptp_clock_info);
+	struct fw_ptp_cmd c;
+	u64 ns;
+	int err;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_portid = cpu_to_be32(FW_CMD_OP_V(FW_PTP_CMD) |
+				     FW_CMD_REQUEST_F |
+				     FW_CMD_READ_F |
+				     FW_PTP_CMD_PORTID_V(0));
+	c.retval_len16 = cpu_to_be32(FW_CMD_LEN16_V(sizeof(c) / 16));
+	c.u.ts.sc = FW_PTP_SC_GET_TIME;
+
+	err = t4_wr_mbox(adapter, adapter->mbox, &c, sizeof(c), &c);
+	if (err < 0) {
+		dev_err(adapter->pdev_dev,
+			"PTP: %s error %d\n", __func__, -err);
+		return err;
+	}
+
+	/* convert to timespec*/
+	ns = be64_to_cpu(c.u.ts.tm);
+	*ts = ns_to_timespec64(ns);
+
+	return err;
+}
+
+/**
+ *  cxgb4_ptp_settime - Set the current time on the hardware clock
+ *  @ptp: ptp clock structure
+ *  @ts: timespec containing the new time for the cycle counter
+ *
+ *  Reset value to new base value instead of the kernel
+ *  wall timer value.
+ */
+static int cxgb4_ptp_settime(struct ptp_clock_info *ptp,
+			     const struct timespec64 *ts)
+{
+	struct adapter *adapter = (struct adapter *)container_of(ptp,
+				   struct adapter, ptp_clock_info);
+	struct fw_ptp_cmd c;
+	u64 ns;
+	int err;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_portid = cpu_to_be32(FW_CMD_OP_V(FW_PTP_CMD) |
+				     FW_CMD_REQUEST_F |
+				     FW_CMD_WRITE_F |
+				     FW_PTP_CMD_PORTID_V(0));
+	c.retval_len16 = cpu_to_be32(FW_CMD_LEN16_V(sizeof(c) / 16));
+	c.u.ts.sc = FW_PTP_SC_SET_TIME;
+
+	ns = timespec64_to_ns(ts);
+	c.u.ts.tm = cpu_to_be64(ns);
+
+	err =  t4_wr_mbox(adapter, adapter->mbox, &c, sizeof(c), NULL);
+	if (err < 0)
+		dev_err(adapter->pdev_dev,
+			"PTP: %s error %d\n", __func__, -err);
+
+	return err;
+}
+
+static void cxgb4_init_ptp_timer(struct adapter *adapter)
+{
+	struct fw_ptp_cmd c;
+	int err;
+
+	memset(&c, 0, sizeof(c));
+		c.op_to_portid = cpu_to_be32(FW_CMD_OP_V(FW_PTP_CMD) |
+					     FW_CMD_REQUEST_F |
+					     FW_CMD_WRITE_F |
+					     FW_PTP_CMD_PORTID_V(0));
+	c.retval_len16 = cpu_to_be32(FW_CMD_LEN16_V(sizeof(c) / 16));
+	c.u.scmd.sc = FW_PTP_SC_INIT_TIMER;
+
+	err = t4_wr_mbox(adapter, adapter->mbox, &c, sizeof(c), NULL);
+	if (err < 0)
+		dev_err(adapter->pdev_dev,
+			"PTP: %s error %d\n", __func__, -err);
+}
+
+/**
+ * cxgb4_ptp_enable - enable or disable an ancillary feature
+ * @ptp: ptp clock structure
+ * @request: Desired resource to enable or disable
+ * @on: Caller passes one to enable or zero to disable
+ *
+ * Enable (or disable) ancillary features of the PHC subsystem.
+ * Currently, no ancillary features are supported.
+ */
+static int cxgb4_ptp_enable(struct ptp_clock_info __always_unused *ptp,
+			    struct ptp_clock_request __always_unused *request,
+			    int __always_unused on)
+{
+	return -ENOTSUPP;
+}
+
+static const struct ptp_clock_info cxgb4_ptp_clock_info = {
+	.owner          = THIS_MODULE,
+	.name           = "cxgb4_clock",
+	.max_adj        = MAX_PTP_FREQ_ADJ,
+	.n_alarm        = 0,
+	.n_ext_ts       = 0,
+	.n_per_out      = 0,
+	.pps            = 0,
+	.adjfreq        = cxgb4_ptp_adjfreq,
+	.adjtime        = cxgb4_ptp_adjtime,
+	.gettime64      = cxgb4_ptp_gettime,
+	.settime64      = cxgb4_ptp_settime,
+	.enable         = cxgb4_ptp_enable,
+};
+
+/**
+ * cxgb4_ptp_init - initialize PTP for devices which support it
+ * @adapter: board private structure
+ *
+ * This function performs the required steps for enabling PTP support.
+ */
+void cxgb4_ptp_init(struct adapter *adapter)
+{
+	struct timespec64 now;
+	 /* no need to create a clock device if we already have one */
+	if (!IS_ERR_OR_NULL(adapter->ptp_clock))
+		return;
+
+	adapter->ptp_tx_skb = NULL;
+	adapter->ptp_clock_info = cxgb4_ptp_clock_info;
+	spin_lock_init(&adapter->ptp_lock);
+
+	adapter->ptp_clock = ptp_clock_register(&adapter->ptp_clock_info,
+						&adapter->pdev->dev);
+	if (!adapter->ptp_clock) {
+		dev_err(adapter->pdev_dev,
+			"PTP %s Clock registration has failed\n", __func__);
+		return;
+	}
+
+	now = ktime_to_timespec64(ktime_get_real());
+	cxgb4_init_ptp_timer(adapter);
+	if (cxgb4_ptp_settime(&adapter->ptp_clock_info, &now) < 0) {
+		ptp_clock_unregister(adapter->ptp_clock);
+		adapter->ptp_clock = NULL;
+	}
+}
+
+/**
+ * cxgb4_ptp_remove - disable PTP device and stop the overflow check
+ * @adapter: board private structure
+ *
+ * Stop the PTP support.
+ */
+void cxgb4_ptp_stop(struct adapter *adapter)
+{
+	if (adapter->ptp_tx_skb) {
+		dev_kfree_skb_any(adapter->ptp_tx_skb);
+		adapter->ptp_tx_skb = NULL;
+	}
+
+	if (adapter->ptp_clock) {
+		ptp_clock_unregister(adapter->ptp_clock);
+		adapter->ptp_clock = NULL;
+	}
+}
-- 
1.8.3.1
