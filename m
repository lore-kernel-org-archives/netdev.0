From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 2/5] tg3: Dump registers when status block
 shows errors
Date: Wed, 13 Apr 2011 14:05:05 -0700
Message-ID: <1302728708-1797-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1664 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932837Ab1DMU4k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 16:56:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch monitors the error bit of the status word within the status
block.  If it is set, the driver will dump the driver state after
validating the error and then reset the chip.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   40 +++++++++++++++++++++++++++++++++++++++-
 drivers/net/tg3.h |    3 +++
 2 files changed, 42 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 7274435..b61b52f 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -5259,6 +5259,40 @@ tx_recovery:
 	return work_done;
 }
 
+static void tg3_process_error(struct tg3 *tp)
+{
+	u32 val;
+	bool real_error = false;
+
+	if (tp->tg3_flags & TG3_FLAG_ERROR_PROCESSED)
+		return;
+
+	/* Check Flow Attention register */
+	val = tr32(HOSTCC_FLOW_ATTN);
+	if (val & ~HOSTCC_FLOW_ATTN_MBUF_LWM) {
+		netdev_err(tp->dev, "FLOW Attention error.  Resetting chip.\n");
+		real_error = true;
+	}
+
+	if (tr32(MSGINT_STATUS) & ~MSGINT_STATUS_MSI_REQ) {
+		netdev_err(tp->dev, "MSI Status error.  Resetting chip.\n");
+		real_error = true;
+	}
+
+	if (tr32(RDMAC_STATUS) || tr32(WDMAC_STATUS)) {
+		netdev_err(tp->dev, "DMA Status error.  Resetting chip.\n");
+		real_error = true;
+	}
+
+	if (!real_error)
+		return;
+
+	tg3_dump_state(tp);
+
+	tp->tg3_flags |= TG3_FLAG_ERROR_PROCESSED;
+	schedule_work(&tp->reset_task);
+}
+
 static int tg3_poll(struct napi_struct *napi, int budget)
 {
 	struct tg3_napi *tnapi = container_of(napi, struct tg3_napi, napi);
@@ -5267,6 +5301,9 @@ static int tg3_poll(struct napi_struct *napi, int budget)
 	struct tg3_hw_status *sblk = tnapi->hw_status;
 
 	while (1) {
+		if (sblk->status & SD_STATUS_ERROR)
+			tg3_process_error(tp);
+
 		tg3_poll_link(tp);
 
 		work_done = tg3_poll_work(tnapi, work_done, budget);
@@ -7316,7 +7353,8 @@ static int tg3_chip_reset(struct tg3 *tp)
 
 	tg3_restore_pci_state(tp);
 
-	tp->tg3_flags &= ~TG3_FLAG_CHIP_RESETTING;
+	tp->tg3_flags &= ~(TG3_FLAG_CHIP_RESETTING |
+			   TG3_FLAG_ERROR_PROCESSED);
 
 	val = 0;
 	if (tp->tg3_flags2 & TG3_FLG2_5780_CLASS)
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 9912010..b3ccfcc 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1201,6 +1201,7 @@
 #define HOSTCC_STATS_BLK_NIC_ADDR	0x00003c40
 #define HOSTCC_STATUS_BLK_NIC_ADDR	0x00003c44
 #define HOSTCC_FLOW_ATTN		0x00003c48
+#define HOSTCC_FLOW_ATTN_MBUF_LWM	 0x00000040
 /* 0x3c4c --> 0x3c50 unused */
 #define HOSTCC_JUMBO_CON_IDX		0x00003c50
 #define HOSTCC_STD_CON_IDX		0x00003c54
@@ -1611,6 +1612,7 @@
 #define  MSGINT_MODE_ONE_SHOT_DISABLE	 0x00000020
 #define  MSGINT_MODE_MULTIVEC_EN	 0x00000080
 #define MSGINT_STATUS			0x00006004
+#define  MSGINT_STATUS_MSI_REQ		 0x00000001
 #define MSGINT_FIFO			0x00006008
 /* 0x600c --> 0x6400 unused */
 
@@ -2886,6 +2888,7 @@ struct tg3 {
 #define TG3_FLAG_TAGGED_STATUS		0x00000001
 #define TG3_FLAG_TXD_MBOX_HWBUG		0x00000002
 #define TG3_FLAG_USE_LINKCHG_REG	0x00000008
+#define TG3_FLAG_ERROR_PROCESSED	0x00000010
 #define TG3_FLAG_ENABLE_ASF		0x00000020
 #define TG3_FLAG_ASPM_WORKAROUND	0x00000040
 #define TG3_FLAG_POLL_SERDES		0x00000080
-- 
1.7.3.4


