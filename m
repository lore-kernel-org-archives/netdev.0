From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 2/6] tg3: Refactor cpu pause/resume code
Date: Wed, 6 Mar 2013 19:02:30 -0800
Message-ID: <1362625354-15095-3-git-send-email-nsujir@broadcom.com>
References: <1362625354-15095-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2906 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752713Ab3CGDDP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Mar 2013 22:03:15 -0500
In-Reply-To: <1362625354-15095-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 57766 rxcpu needs to be paused/resumed when we download the firmware just
like we do for existing firmware. Refactor the pause/resume code to be
reusable.

This patch also renames the "offset" argument of tg3_halt_cpu to "cpu_base"
since that's what it really is.

Reviewed-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 83 ++++++++++++++++++++++++++-----------
 1 file changed, 58 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index f6ebcaa..35a99f7 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -3452,11 +3452,58 @@ static int tg3_nvram_write_block(struct tg3 *tp, u32 offset, u32 len, u8 *buf)
 #define TX_CPU_SCRATCH_SIZE	0x04000
 
 /* tp->lock is held. */
-static int tg3_halt_cpu(struct tg3 *tp, u32 offset)
+static int tg3_pause_cpu(struct tg3 *tp, u32 cpu_base)
 {
 	int i;
+	const int iters = 10000;
 
-	BUG_ON(offset == TX_CPU_BASE && tg3_flag(tp, 5705_PLUS));
+	for (i = 0; i < iters; i++) {
+		tw32(cpu_base + CPU_STATE, 0xffffffff);
+		tw32(cpu_base + CPU_MODE,  CPU_MODE_HALT);
+		if (tr32(cpu_base + CPU_MODE) & CPU_MODE_HALT)
+			break;
+	}
+
+	return (i == iters) ? -EBUSY : 0;
+}
+
+/* tp->lock is held. */
+static int tg3_rxcpu_pause(struct tg3 *tp)
+{
+	int rc = tg3_pause_cpu(tp, RX_CPU_BASE);
+
+	tw32(RX_CPU_BASE + CPU_STATE, 0xffffffff);
+	tw32_f(RX_CPU_BASE + CPU_MODE,  CPU_MODE_HALT);
+	udelay(10);
+
+	return rc;
+}
+
+/* tp->lock is held. */
+static int tg3_txcpu_pause(struct tg3 *tp)
+{
+	return tg3_pause_cpu(tp, TX_CPU_BASE);
+}
+
+/* tp->lock is held. */
+static void tg3_resume_cpu(struct tg3 *tp, u32 cpu_base)
+{
+	tw32(cpu_base + CPU_STATE, 0xffffffff);
+	tw32_f(cpu_base + CPU_MODE,  0x00000000);
+}
+
+/* tp->lock is held. */
+static void tg3_rxcpu_resume(struct tg3 *tp)
+{
+	tg3_resume_cpu(tp, RX_CPU_BASE);
+}
+
+/* tp->lock is held. */
+static int tg3_halt_cpu(struct tg3 *tp, u32 cpu_base)
+{
+	int rc;
+
+	BUG_ON(cpu_base == TX_CPU_BASE && tg3_flag(tp, 5705_PLUS));
 
 	if (tg3_asic_rev(tp) == ASIC_REV_5906) {
 		u32 val = tr32(GRC_VCPU_EXT_CTRL);
@@ -3464,17 +3511,8 @@ static int tg3_halt_cpu(struct tg3 *tp, u32 offset)
 		tw32(GRC_VCPU_EXT_CTRL, val | GRC_VCPU_EXT_CTRL_HALT_CPU);
 		return 0;
 	}
-	if (offset == RX_CPU_BASE) {
-		for (i = 0; i < 10000; i++) {
-			tw32(offset + CPU_STATE, 0xffffffff);
-			tw32(offset + CPU_MODE,  CPU_MODE_HALT);
-			if (tr32(offset + CPU_MODE) & CPU_MODE_HALT)
-				break;
-		}
-
-		tw32(offset + CPU_STATE, 0xffffffff);
-		tw32_f(offset + CPU_MODE,  CPU_MODE_HALT);
-		udelay(10);
+	if (cpu_base == RX_CPU_BASE) {
+		rc = tg3_rxcpu_pause(tp);
 	} else {
 		/*
 		 * There is only an Rx CPU for the 5750 derivative in the
@@ -3483,17 +3521,12 @@ static int tg3_halt_cpu(struct tg3 *tp, u32 offset)
 		if (tg3_flag(tp, IS_SSB_CORE))
 			return 0;
 
-		for (i = 0; i < 10000; i++) {
-			tw32(offset + CPU_STATE, 0xffffffff);
-			tw32(offset + CPU_MODE,  CPU_MODE_HALT);
-			if (tr32(offset + CPU_MODE) & CPU_MODE_HALT)
-				break;
-		}
+		rc = tg3_txcpu_pause(tp);
 	}
 
-	if (i >= 10000) {
+	if (rc) {
 		netdev_err(tp->dev, "%s timed out, %s CPU\n",
-			   __func__, offset == RX_CPU_BASE ? "RX" : "TX");
+			   __func__, cpu_base == RX_CPU_BASE ? "RX" : "TX");
 		return -ENODEV;
 	}
 
@@ -3604,8 +3637,8 @@ static int tg3_load_5701_a0_firmware_fix(struct tg3 *tp)
 			   tr32(RX_CPU_BASE + CPU_PC), info.fw_base);
 		return -ENODEV;
 	}
-	tw32(RX_CPU_BASE + CPU_STATE, 0xffffffff);
-	tw32_f(RX_CPU_BASE + CPU_MODE,  0x00000000);
+
+	tg3_rxcpu_resume(tp);
 
 	return 0;
 }
@@ -3667,8 +3700,8 @@ static int tg3_load_tso_firmware(struct tg3 *tp)
 			   __func__, tr32(cpu_base + CPU_PC), info.fw_base);
 		return -ENODEV;
 	}
-	tw32(cpu_base + CPU_STATE, 0xffffffff);
-	tw32_f(cpu_base + CPU_MODE,  0x00000000);
+
+	tg3_resume_cpu(tp, cpu_base);
 	return 0;
 }
 
-- 
1.8.1.4
