From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 4/6] cxgb4: Detect and display firmware reported errors
Date: Tue, 12 Aug 2014 11:09:11 +0530
Message-ID: <1407821953-8711-5-git-send-email-hariprasad@chelsio.com>
References: <1407821953-8711-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, anish@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:43200
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752423AbaHLFdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 01:33:42 -0400
In-Reply-To: <1407821953-8711-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on original work by Casey Leedom <leedom@chelsio.com>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c    |   38 ++++++++++++++++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h |    4 ++
 2 files changed, 41 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 0250a9d..41d0446 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -168,6 +168,34 @@ void t4_hw_pci_read_cfg4(struct adapter *adap, int reg, u32 *val)
 }
 
 /*
+ * t4_report_fw_error - report firmware error
+ * @adap: the adapter
+ *
+ * The adapter firmware can indicate error conditions to the host.
+ * If the firmware has indicated an error, print out the reason for
+ * the firmware error.
+ */
+static void t4_report_fw_error(struct adapter *adap)
+{
+	static const char *const reason[] = {
+		"Crash",                        /* PCIE_FW_EVAL_CRASH */
+		"During Device Preparation",    /* PCIE_FW_EVAL_PREP */
+		"During Device Configuration",  /* PCIE_FW_EVAL_CONF */
+		"During Device Initialization", /* PCIE_FW_EVAL_INIT */
+		"Unexpected Event",             /* PCIE_FW_EVAL_UNEXPECTEDEVENT */
+		"Insufficient Airflow",         /* PCIE_FW_EVAL_OVERHEAT */
+		"Device Shutdown",              /* PCIE_FW_EVAL_DEVICESHUTDOWN */
+		"Reserved",                     /* reserved */
+	};
+	u32 pcie_fw;
+
+	pcie_fw = t4_read_reg(adap, MA_PCIE_FW);
+	if (pcie_fw & FW_PCIE_FW_ERR)
+		dev_err(adap->pdev_dev, "Firmware reports adapter error: %s\n",
+			reason[FW_PCIE_FW_EVAL_GET(pcie_fw)]);
+}
+
+/*
  * Get the reply to a mailbox command and store it in @rpl in big-endian order.
  */
 static void get_mbox_rpl(struct adapter *adap, __be64 *rpl, int nflit,
@@ -300,6 +328,7 @@ int t4_wr_mbox_meat(struct adapter *adap, int mbox, const void *cmd, int size,
 	dump_mbox(adap, mbox, data_reg);
 	dev_err(adap->pdev_dev, "command %#x in mailbox %d timed out\n",
 		*(const u8 *)cmd, mbox);
+	t4_report_fw_error(adap);
 	return -ETIMEDOUT;
 }
 
@@ -1533,6 +1562,9 @@ static void cim_intr_handler(struct adapter *adapter)
 
 	int fat;
 
+	if (t4_read_reg(adapter, MA_PCIE_FW) & FW_PCIE_FW_ERR)
+		t4_report_fw_error(adapter);
+
 	fat = t4_handle_intr_status(adapter, CIM_HOST_INT_CAUSE,
 				    cim_intr_info) +
 	      t4_handle_intr_status(adapter, CIM_HOST_UPACC_INT_CAUSE,
@@ -2751,12 +2783,16 @@ retry:
 	/*
 	 * Issue the HELLO command to the firmware.  If it's not successful
 	 * but indicates that we got a "busy" or "timeout" condition, retry
-	 * the HELLO until we exhaust our retry limit.
+	 * the HELLO until we exhaust our retry limit.  If we do exceed our
+	 * retry limit, check to see if the firmware left us any error
+	 * information and report that if so.
 	 */
 	ret = t4_wr_mbox(adap, mbox, &c, sizeof(c), &c);
 	if (ret < 0) {
 		if ((ret == -EBUSY || ret == -ETIMEDOUT) && retries-- > 0)
 			goto retry;
+		if (t4_read_reg(adap, MA_PCIE_FW) & FW_PCIE_FW_ERR)
+			t4_report_fw_error(adap);
 		return ret;
 	}
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index ff709e3..c1c2e65 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -2217,6 +2217,10 @@ struct fw_debug_cmd {
 #define FW_PCIE_FW_MASTER(x)     ((x) << FW_PCIE_FW_MASTER_SHIFT)
 #define FW_PCIE_FW_MASTER_GET(x) (((x) >> FW_PCIE_FW_MASTER_SHIFT) & \
 				 FW_PCIE_FW_MASTER_MASK)
+#define FW_PCIE_FW_EVAL_MASK   0x7
+#define FW_PCIE_FW_EVAL_SHIFT  24
+#define FW_PCIE_FW_EVAL_GET(x) (((x) >> FW_PCIE_FW_EVAL_SHIFT) & \
+				 FW_PCIE_FW_EVAL_MASK)
 
 struct fw_hdr {
 	u8 ver;
-- 
1.7.1
