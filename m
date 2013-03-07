From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 3/6] tg3: Refactor the 2nd type of cpu pause
Date: Wed, 6 Mar 2013 19:02:31 -0800
Message-ID: <1362625354-15095-4-git-send-email-nsujir@broadcom.com>
References: <1362625354-15095-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4286 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755773Ab3CGDDV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Mar 2013 22:03:21 -0500
In-Reply-To: <1362625354-15095-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For completeness and consistency, add common function
tg3_pause_cpu_and_set_pc(). This is only for existing fw and not used for the
57766.

Reviewed-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 53 +++++++++++++++++++------------------
 1 file changed, 27 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 35a99f7..4705169 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -3589,11 +3589,32 @@ out:
 }
 
 /* tp->lock is held. */
+static int tg3_pause_cpu_and_set_pc(struct tg3 *tp, u32 cpu_base, u32 pc)
+{
+	int i;
+	const int iters = 5;
+
+	tw32(cpu_base + CPU_STATE, 0xffffffff);
+	tw32_f(cpu_base + CPU_PC, pc);
+
+	for (i = 0; i < iters; i++) {
+		if (tr32(cpu_base + CPU_PC) == pc)
+			break;
+		tw32(cpu_base + CPU_STATE, 0xffffffff);
+		tw32(cpu_base + CPU_MODE,  CPU_MODE_HALT);
+		tw32_f(cpu_base + CPU_PC, pc);
+		udelay(1000);
+	}
+
+	return (i == iters) ? -EBUSY : 0;
+}
+
+/* tp->lock is held. */
 static int tg3_load_5701_a0_firmware_fix(struct tg3 *tp)
 {
 	struct fw_info info;
 	const __be32 *fw_data;
-	int err, i;
+	int err;
 
 	fw_data = (void *)tp->fw->data;
 
@@ -3620,18 +3641,8 @@ static int tg3_load_5701_a0_firmware_fix(struct tg3 *tp)
 		return err;
 
 	/* Now startup only the RX cpu. */
-	tw32(RX_CPU_BASE + CPU_STATE, 0xffffffff);
-	tw32_f(RX_CPU_BASE + CPU_PC, info.fw_base);
-
-	for (i = 0; i < 5; i++) {
-		if (tr32(RX_CPU_BASE + CPU_PC) == info.fw_base)
-			break;
-		tw32(RX_CPU_BASE + CPU_STATE, 0xffffffff);
-		tw32(RX_CPU_BASE + CPU_MODE,  CPU_MODE_HALT);
-		tw32_f(RX_CPU_BASE + CPU_PC, info.fw_base);
-		udelay(1000);
-	}
-	if (i >= 5) {
+	err = tg3_pause_cpu_and_set_pc(tp, RX_CPU_BASE, info.fw_base);
+	if (err) {
 		netdev_err(tp->dev, "%s fails to set RX CPU PC, is %08x "
 			   "should be %08x\n", __func__,
 			   tr32(RX_CPU_BASE + CPU_PC), info.fw_base);
@@ -3649,7 +3660,7 @@ static int tg3_load_tso_firmware(struct tg3 *tp)
 	struct fw_info info;
 	const __be32 *fw_data;
 	unsigned long cpu_base, cpu_scratch_base, cpu_scratch_size;
-	int err, i;
+	int err;
 
 	if (!tg3_flag(tp, FW_TSO))
 		return 0;
@@ -3683,18 +3694,8 @@ static int tg3_load_tso_firmware(struct tg3 *tp)
 		return err;
 
 	/* Now startup the cpu. */
-	tw32(cpu_base + CPU_STATE, 0xffffffff);
-	tw32_f(cpu_base + CPU_PC, info.fw_base);
-
-	for (i = 0; i < 5; i++) {
-		if (tr32(cpu_base + CPU_PC) == info.fw_base)
-			break;
-		tw32(cpu_base + CPU_STATE, 0xffffffff);
-		tw32(cpu_base + CPU_MODE,  CPU_MODE_HALT);
-		tw32_f(cpu_base + CPU_PC, info.fw_base);
-		udelay(1000);
-	}
-	if (i >= 5) {
+	err = tg3_pause_cpu_and_set_pc(tp, cpu_base, info.fw_base);
+	if (err) {
 		netdev_err(tp->dev,
 			   "%s fails to set CPU PC, is %08x should be %08x\n",
 			   __func__, tr32(cpu_base + CPU_PC), info.fw_base);
-- 
1.8.1.4
