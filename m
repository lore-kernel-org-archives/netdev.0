From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 5/6] tg3: Enhance firmware download code to
 support fragmented firmware
Date: Wed, 6 Mar 2013 19:02:33 -0800
Message-ID: <1362625354-15095-6-git-send-email-nsujir@broadcom.com>
References: <1362625354-15095-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4284 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753882Ab3CGDDR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Mar 2013 22:03:17 -0500
In-Reply-To: <1362625354-15095-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This lays the ground work to download the 57766 fragmented firmware. We
loop until we've written data equal to tp->fw->size minus headers.

Reviewed-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 48 ++++++++++++++++++++++++++++++++-----
 1 file changed, 42 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 87bd0e3..54f604b 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -3536,6 +3536,33 @@ static int tg3_halt_cpu(struct tg3 *tp, u32 cpu_base)
 	return 0;
 }
 
+static int tg3_fw_data_len(struct tg3 *tp,
+			   const struct tg3_firmware_hdr *fw_hdr)
+{
+	int fw_len;
+
+	/* Non fragmented firmware have one firmware header followed by a
+	 * contiguous chunk of data to be written. The length field in that
+	 * header is not the length of data to be written but the complete
+	 * length of the bss. The data length is determined based on
+	 * tp->fw->size minus headers.
+	 *
+	 * Fragmented firmware have a main header followed by multiple
+	 * fragments. Each fragment is identical to non fragmented firmware
+	 * with a firmware header followed by a contiguous chunk of data. In
+	 * the main header, the length field is unused and set to 0xffffffff.
+	 * In each fragment header the length is the entire size of that
+	 * fragment i.e. fragment data + header length. Data length is
+	 * therefore length field in the header minus TG3_FW_HDR_LEN.
+	 */
+	if (tp->fw_len == 0xffffffff)
+		fw_len = be32_to_cpu(fw_hdr->len);
+	else
+		fw_len = tp->fw->size;
+
+	return (fw_len - TG3_FW_HDR_LEN) / sizeof(u32);
+}
+
 /* tp->lock is held. */
 static int tg3_load_firmware_cpu(struct tg3 *tp, u32 cpu_base,
 				 u32 cpu_scratch_base, int cpu_scratch_size,
@@ -3543,7 +3570,7 @@ static int tg3_load_firmware_cpu(struct tg3 *tp, u32 cpu_base,
 {
 	int err, lock_err, i;
 	void (*write_op)(struct tg3 *, u32, u32);
-	u32 *fw_data = (u32 *)(fw_hdr + 1);
+	int total_len = tp->fw->size;
 
 	if (cpu_base == TX_CPU_BASE && tg3_flag(tp, 5705_PLUS)) {
 		netdev_err(tp->dev,
@@ -3571,12 +3598,21 @@ static int tg3_load_firmware_cpu(struct tg3 *tp, u32 cpu_base,
 		write_op(tp, cpu_scratch_base + i, 0);
 	tw32(cpu_base + CPU_STATE, 0xffffffff);
 	tw32(cpu_base + CPU_MODE, tr32(cpu_base+CPU_MODE)|CPU_MODE_HALT);
-	for (i = 0; i < (tp->fw->size - TG3_FW_HDR_LEN) / sizeof(u32); i++)
-		write_op(tp, cpu_scratch_base +
-			     (be32_to_cpu(fw_hdr->base_addr) & 0xffff) +
-			     (i * sizeof(u32)),
-			 be32_to_cpu(fw_data[i]));
 
+	do {
+		u32 *fw_data = (u32 *)(fw_hdr + 1);
+		for (i = 0; i < tg3_fw_data_len(tp, fw_hdr); i++)
+			write_op(tp, cpu_scratch_base +
+				     (be32_to_cpu(fw_hdr->base_addr) & 0xffff) +
+				     (i * sizeof(u32)),
+				 be32_to_cpu(fw_data[i]));
+
+		total_len -= be32_to_cpu(fw_hdr->len);
+
+		/* Advance to next fragment */
+		fw_hdr = (struct tg3_firmware_hdr *)
+			 ((void *)fw_hdr + be32_to_cpu(fw_hdr->len));
+	} while (total_len > 0);
 
 	err = 0;
 
-- 
1.8.1.4
