From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 4/6] tg3: Cleanup firmware parsing code
Date: Wed, 6 Mar 2013 19:02:32 -0800
Message-ID: <1362625354-15095-5-git-send-email-nsujir@broadcom.com>
References: <1362625354-15095-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3588 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752800Ab3CGDDQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Mar 2013 22:03:16 -0500
In-Reply-To: <1362625354-15095-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current firmware header parsing is complicated due to interpreting it as a
u32 array and accessing header members via array offsets. Add tg3_firmware_hdr
structure to access the firmware fields instead of hardcoding offsets. The same
header format will be used for individual firmware fragments in the 57766.

The fw_hdr and tg3 structures have all the information required for
loading the fw. Remove the redundant fw_info structure and pass fw_hdr
instead.

Reviewed-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 63 ++++++++++++++++---------------------
 drivers/net/ethernet/broadcom/tg3.h |  7 +++++
 2 files changed, 34 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 4705169..87bd0e3 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -3536,19 +3536,14 @@ static int tg3_halt_cpu(struct tg3 *tp, u32 cpu_base)
 	return 0;
 }
 
-struct fw_info {
-	unsigned int fw_base;
-	unsigned int fw_len;
-	const __be32 *fw_data;
-};
-
 /* tp->lock is held. */
 static int tg3_load_firmware_cpu(struct tg3 *tp, u32 cpu_base,
 				 u32 cpu_scratch_base, int cpu_scratch_size,
-				 struct fw_info *info)
+				 const struct tg3_firmware_hdr *fw_hdr)
 {
 	int err, lock_err, i;
 	void (*write_op)(struct tg3 *, u32, u32);
+	u32 *fw_data = (u32 *)(fw_hdr + 1);
 
 	if (cpu_base == TX_CPU_BASE && tg3_flag(tp, 5705_PLUS)) {
 		netdev_err(tp->dev,
@@ -3576,11 +3571,12 @@ static int tg3_load_firmware_cpu(struct tg3 *tp, u32 cpu_base,
 		write_op(tp, cpu_scratch_base + i, 0);
 	tw32(cpu_base + CPU_STATE, 0xffffffff);
 	tw32(cpu_base + CPU_MODE, tr32(cpu_base+CPU_MODE)|CPU_MODE_HALT);
-	for (i = 0; i < (info->fw_len / sizeof(u32)); i++)
-		write_op(tp, (cpu_scratch_base +
-			      (info->fw_base & 0xffff) +
-			      (i * sizeof(u32))),
-			      be32_to_cpu(info->fw_data[i]));
+	for (i = 0; i < (tp->fw->size - TG3_FW_HDR_LEN) / sizeof(u32); i++)
+		write_op(tp, cpu_scratch_base +
+			     (be32_to_cpu(fw_hdr->base_addr) & 0xffff) +
+			     (i * sizeof(u32)),
+			 be32_to_cpu(fw_data[i]));
+
 
 	err = 0;
 
@@ -3612,11 +3608,10 @@ static int tg3_pause_cpu_and_set_pc(struct tg3 *tp, u32 cpu_base, u32 pc)
 /* tp->lock is held. */
 static int tg3_load_5701_a0_firmware_fix(struct tg3 *tp)
 {
-	struct fw_info info;
-	const __be32 *fw_data;
+	const struct tg3_firmware_hdr *fw_hdr;
 	int err;
 
-	fw_data = (void *)tp->fw->data;
+	fw_hdr = (struct tg3_firmware_hdr *)tp->fw->data;
 
 	/* Firmware blob starts with version numbers, followed by
 	   start address and length. We are setting complete length.
@@ -3624,28 +3619,26 @@ static int tg3_load_5701_a0_firmware_fix(struct tg3 *tp)
 	   Remainder is the blob to be loaded contiguously
 	   from start address. */
 
-	info.fw_base = be32_to_cpu(fw_data[1]);
-	info.fw_len = tp->fw->size - 12;
-	info.fw_data = &fw_data[3];
-
 	err = tg3_load_firmware_cpu(tp, RX_CPU_BASE,
 				    RX_CPU_SCRATCH_BASE, RX_CPU_SCRATCH_SIZE,
-				    &info);
+				    fw_hdr);
 	if (err)
 		return err;
 
 	err = tg3_load_firmware_cpu(tp, TX_CPU_BASE,
 				    TX_CPU_SCRATCH_BASE, TX_CPU_SCRATCH_SIZE,
-				    &info);
+				    fw_hdr);
 	if (err)
 		return err;
 
 	/* Now startup only the RX cpu. */
-	err = tg3_pause_cpu_and_set_pc(tp, RX_CPU_BASE, info.fw_base);
+	err = tg3_pause_cpu_and_set_pc(tp, RX_CPU_BASE,
+				       be32_to_cpu(fw_hdr->base_addr));
 	if (err) {
 		netdev_err(tp->dev, "%s fails to set RX CPU PC, is %08x "
 			   "should be %08x\n", __func__,
-			   tr32(RX_CPU_BASE + CPU_PC), info.fw_base);
+			   tr32(RX_CPU_BASE + CPU_PC),
+				be32_to_cpu(fw_hdr->base_addr));
 		return -ENODEV;
 	}
 
@@ -3657,15 +3650,14 @@ static int tg3_load_5701_a0_firmware_fix(struct tg3 *tp)
 /* tp->lock is held. */
 static int tg3_load_tso_firmware(struct tg3 *tp)
 {
-	struct fw_info info;
-	const __be32 *fw_data;
+	const struct tg3_firmware_hdr *fw_hdr;
 	unsigned long cpu_base, cpu_scratch_base, cpu_scratch_size;
 	int err;
 
 	if (!tg3_flag(tp, FW_TSO))
 		return 0;
 
-	fw_data = (void *)tp->fw->data;
+	fw_hdr = (struct tg3_firmware_hdr *)tp->fw->data;
 
 	/* Firmware blob starts with version numbers, followed by
 	   start address and length. We are setting complete length.
@@ -3673,10 +3665,7 @@ static int tg3_load_tso_firmware(struct tg3 *tp)
 	   Remainder is the blob to be loaded contiguously
 	   from start address. */
 
-	info.fw_base = be32_to_cpu(fw_data[1]);
 	cpu_scratch_size = tp->fw_len;
-	info.fw_len = tp->fw->size - 12;
-	info.fw_data = &fw_data[3];
 
 	if (tg3_asic_rev(tp) == ASIC_REV_5705) {
 		cpu_base = RX_CPU_BASE;
@@ -3689,16 +3678,18 @@ static int tg3_load_tso_firmware(struct tg3 *tp)
 
 	err = tg3_load_firmware_cpu(tp, cpu_base,
 				    cpu_scratch_base, cpu_scratch_size,
-				    &info);
+				    fw_hdr);
 	if (err)
 		return err;
 
 	/* Now startup the cpu. */
-	err = tg3_pause_cpu_and_set_pc(tp, cpu_base, info.fw_base);
+	err = tg3_pause_cpu_and_set_pc(tp, cpu_base,
+				       be32_to_cpu(fw_hdr->base_addr));
 	if (err) {
 		netdev_err(tp->dev,
 			   "%s fails to set CPU PC, is %08x should be %08x\n",
-			   __func__, tr32(cpu_base + CPU_PC), info.fw_base);
+			   __func__, tr32(cpu_base + CPU_PC),
+			   be32_to_cpu(fw_hdr->base_addr));
 		return -ENODEV;
 	}
 
@@ -10598,7 +10589,7 @@ static int tg3_test_msi(struct tg3 *tp)
 
 static int tg3_request_firmware(struct tg3 *tp)
 {
-	const __be32 *fw_data;
+	const struct tg3_firmware_hdr *fw_hdr;
 
 	if (request_firmware(&tp->fw, tp->fw_needed, &tp->pdev->dev)) {
 		netdev_err(tp->dev, "Failed to load firmware \"%s\"\n",
@@ -10606,15 +10597,15 @@ static int tg3_request_firmware(struct tg3 *tp)
 		return -ENOENT;
 	}
 
-	fw_data = (void *)tp->fw->data;
+	fw_hdr = (struct tg3_firmware_hdr *)tp->fw->data;
 
 	/* Firmware blob starts with version numbers, followed by
 	 * start address and _full_ length including BSS sections
 	 * (which must be longer than the actual data, of course
 	 */
 
-	tp->fw_len = be32_to_cpu(fw_data[2]);	/* includes bss */
-	if (tp->fw_len < (tp->fw->size - 12)) {
+	tp->fw_len = be32_to_cpu(fw_hdr->len);	/* includes bss */
+	if (tp->fw_len < (tp->fw->size - TG3_FW_HDR_LEN)) {
 		netdev_err(tp->dev, "bogus length %d in \"%s\"\n",
 			   tp->fw_len, tp->fw_needed);
 		release_firmware(tp->fw);
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index eb41b6f..b5098f0 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -3065,6 +3065,13 @@ enum TG3_FLAGS {
 	TG3_FLAG_NUMBER_OF_FLAGS,	/* Last entry in enum TG3_FLAGS */
 };
 
+struct tg3_firmware_hdr {
+	__be32 version; /* unused for fragments */
+	__be32 base_addr;
+	__be32 len;
+};
+#define TG3_FW_HDR_LEN         (sizeof(struct tg3_firmware_hdr))
+
 struct tg3 {
 	/* begin "general, frequently-used members" cacheline section */
 
-- 
1.8.1.4
