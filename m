From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 5/9] bnx2x: Take chip version from MFW
Date: Mon, 18 Feb 2013 10:16:34 +0200
Message-ID: <1361175398-12888-6-git-send-email-yuvalmin@broadcom.com>
References: <1361175398-12888-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4585 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757454Ab3BRJV3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2013 04:21:29 -0500
In-Reply-To: <1361175398-12888-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In latest boards, the CHIP_METAL register contains an incorrect
revision value, so the correct one needs to be obtained in a
different manner.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    8 ++++++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h  |    6 ++----
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index d3a33ef..f563fdc 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -10037,8 +10037,12 @@ static void bnx2x_get_common_hwinfo(struct bnx2x *bp)
 	id = ((val & 0xffff) << 16);
 	val = REG_RD(bp, MISC_REG_CHIP_REV);
 	id |= ((val & 0xf) << 12);
-	val = REG_RD(bp, MISC_REG_CHIP_METAL);
-	id |= ((val & 0xff) << 4);
+
+	/* Metal is read from PCI regs, but we can't access >=0x400 from
+	 * the configuration space (so we need to reg_rd)
+	 */
+	val = REG_RD(bp, PCICFG_OFFSET + PCI_ID_VAL3);
+	id |= (((val >> 24) & 0xf) << 4);
 	val = REG_RD(bp, MISC_REG_BOND_ID);
 	id |= (val & 0xf);
 	bp->common.chip_id = id;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index 791eb2d..d22bc40 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -1491,10 +1491,6 @@
 /* [R 4] This field indicates the type of the device. '0' - 2 Ports; '1' - 1
    Port. */
 #define MISC_REG_BOND_ID					 0xa400
-/* [R 8] These bits indicate the metal revision of the chip. This value
-   starts at 0x00 for each all-layer tape-out and increments by one for each
-   tape-out. */
-#define MISC_REG_CHIP_METAL					 0xa404
 /* [R 16] These bits indicate the part number for the chip. */
 #define MISC_REG_CHIP_NUM					 0xa408
 /* [R 4] These bits indicate the base revision of the chip. This value
@@ -6331,6 +6327,8 @@
 #define PCI_PM_DATA_B					0x414
 #define PCI_ID_VAL1					0x434
 #define PCI_ID_VAL2					0x438
+#define PCI_ID_VAL3					0x43c
+
 #define GRC_CONFIG_REG_PF_INIT_VF		0x624
 #define GRC_CR_PF_INIT_VF_PF_FIRST_VF_NUM_MASK	0xf
 /* First VF_NUM for PF is encoded in this register.
-- 
1.7.9.GIT
