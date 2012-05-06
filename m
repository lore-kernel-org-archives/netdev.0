From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH net v3] bnx2x: bug fix when loading after SAN boot
Date: Sun, 6 May 2012 20:05:57 +0300
Message-ID: <1336323957.12363.23.camel@lb-tlvb-eilong.il.broadcom.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2577 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753990Ab2EFRGM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 May 2012 13:06:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

This is a bug fix for an "interface fails to load" issue.
The issue occurs when bnx2x driver loads after UNDI driver was previously
loaded over the chip. In such a scenario the UNDI driver is loaded and operates
in the pre-boot kernel, within its own specific host memory address range.
When the pre-boot stage is complete, the real kernel is loaded, in a new and
distinct host memory address range. The transition from pre-boot stage to boot
is asynchronous from UNDI point of view.

A race condition occurs when UNDI driver triggers a DMAE transaction to valid
host addresses in the pre-boot stage, when control is diverted to the real
kernel. This results in access to illegal addresses by our HW as the addresses
which were valid in the preboot stage are no longer considered valid.
Specifically, the 'was_error' bit in the pci glue of our device is set. This
causes all following pci transactions from chip to host to timeout (in
accordance to the pci spec).

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

---
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   23 +++++++++++++++++++++-
 1 files changed, 22 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index e077d25..795fc49 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -9122,13 +9122,34 @@ static int __devinit bnx2x_prev_unload_common(struct bnx2x *bp)
 	return bnx2x_prev_mcp_done(bp);
 }
 
+/* previous driver DMAE transaction may have occurred when pre-boot stage ended
+ * and boot began, or when kdump kernel was loaded. Either case would invalidate
+ * the addresses of the transaction, resulting in was-error bit set in the pci
+ * causing all hw-to-host pcie transactions to timeout. If this happened we want
+ * to clear the interrupt which detected this from the pglueb and the was done
+ * bit
+ */
+static void __devinit bnx2x_prev_interrupted_dmae(struct bnx2x *bp)
+{
+	u32 val = REG_RD(bp, PGLUE_B_REG_PGLUE_B_INT_STS);
+	if (val & PGLUE_B_PGLUE_B_INT_STS_REG_WAS_ERROR_ATTN) {
+		BNX2X_ERR("was error bit was found to be set in pglueb upon startup. Clearing");
+		REG_WR(bp, PGLUE_B_REG_WAS_ERROR_PF_7_0_CLR, 1 << BP_FUNC(bp));
+	}
+}
+
 static int __devinit bnx2x_prev_unload(struct bnx2x *bp)
 {
 	int time_counter = 10;
 	u32 rc, fw, hw_lock_reg, hw_lock_val;
 	BNX2X_DEV_INFO("Entering Previous Unload Flow\n");
 
-       /* Release previously held locks */
+	/* clear hw from errors which may have resulted from an interrupted
+	 * dmae transaction.
+	 */
+	bnx2x_prev_interrupted_dmae(bp);
+
+	/* Release previously held locks */
 	hw_lock_reg = (BP_FUNC(bp) <= 5) ?
 		      (MISC_REG_DRIVER_CONTROL_1 + BP_FUNC(bp) * 8) :
 		      (MISC_REG_DRIVER_CONTROL_7 + (BP_FUNC(bp) - 6) * 8);
