From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/4 05/13] wimax/i2400m: use JUMP cmd for last FW chunk indication
Date: Wed,  4 Nov 2009 13:40:00 -0800
Message-ID: <6f4fc90a36fbe87e3003b3f7c8090ecc89bd1353.1257370737.git.inaky@linux.intel.com>
References: <cover.1257370737.git.inaky@linux.intel.com>
Cc: Cindy H Kao <cindy.h.kao@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga12.intel.com ([143.182.124.36]:45111 "EHLO
	azsmga102.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932730AbZKDVmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:12 -0500
In-Reply-To: <cover.1257370737.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370737.git.inaky@linux.intel.com>
References: <cover.1257370737.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cindy H Kao <cindy.h.kao@intel.com>

Both secure and non-secure boot must set the JUMP command in the
bootmode header as the last FW chunk, so we change to use the JUMP
command to decide if the FW chunk download is completed.

Since we tend to use one single FW to support both secure and non-secure
boot for most of the time, I2400M_BRH_SIGNED_JUMP is actually found
even for non-secure boot. But in case the FW does come with
I2400M_BRH_JUMP, we check for both of them in i2400m_dnload_bcf().

Signed-off-by: Cindy H Kao <cindy.h.kao@intel.com>
Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/fw.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wimax/i2400m/fw.c b/drivers/net/wimax/i2400m/fw.c
index 3d67bcf..97ea784 100644
--- a/drivers/net/wimax/i2400m/fw.c
+++ b/drivers/net/wimax/i2400m/fw.c
@@ -720,14 +720,17 @@ ssize_t i2400m_dnload_bcf(struct i2400m *i2400m,
 			 "downloading section #%zu (@%zu %zu B) to 0x%08x\n",
 			 section, offset, sizeof(*bh) + data_size,
 			 le32_to_cpu(bh->target_addr));
-		if (i2400m_brh_get_opcode(bh) == I2400M_BRH_SIGNED_JUMP) {
-			/* Secure boot needs to stop here */
-			d_printf(5, dev,  "signed jump found @%zu\n", offset);
+		/*
+		 * We look for JUMP cmd from the bootmode header,
+		 * either I2400M_BRH_SIGNED_JUMP for secure boot
+		 * or I2400M_BRH_JUMP for unsecure boot, the last chunk
+		 * should be the bootmode header with JUMP cmd.
+		 */
+		if (i2400m_brh_get_opcode(bh) == I2400M_BRH_SIGNED_JUMP ||
+			i2400m_brh_get_opcode(bh) == I2400M_BRH_JUMP) {
+			d_printf(5, dev,  "jump found @%zu\n", offset);
 			break;
 		}
-		if (offset + section_size == bcf_len)
-			/* Non-secure boot stops here */
-			break;
 		if (offset + section_size > bcf_len) {
 			dev_err(dev, "fw %s: bad section #%zu, "
 				"end (@%zu) beyond EOF (@%zu)\n",
-- 
1.6.2.5

