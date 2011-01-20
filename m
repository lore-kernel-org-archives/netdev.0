From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] via-velocity: fix the WOL bug on 1000M full duplex forced mode.
Date: Thu, 20 Jan 2011 15:59:33 +0100
Message-ID: <20110120145933.GC7291@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, David Lv <DavidLv@viatech.com.cn>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:35504 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755831Ab1ATPAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 10:00:41 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The VIA velocity card can't be waken up by WOL tool on 1000M full
duplex forced mode. This patch fixes the bug.

Signed-off-by: David Lv <DavidLv@viatech.com.cn>
Acked-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/via-velocity.c |    9 +++++++++
 drivers/net/via-velocity.h |    8 ++++----
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 09cac70..0d6fec6 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -2923,6 +2923,7 @@ static u16 wol_calc_crc(int size, u8 *pattern, u8 *mask_pattern)
 static int velocity_set_wol(struct velocity_info *vptr)
 {
 	struct mac_regs __iomem *regs = vptr->mac_regs;
+	enum speed_opt spd_dpx = vptr->options.spd_dpx;
 	static u8 buf[256];
 	int i;
 
@@ -2968,6 +2969,12 @@ static int velocity_set_wol(struct velocity_info *vptr)
 
 	writew(0x0FFF, &regs->WOLSRClr);
 
+	if (spd_dpx == SPD_DPX_1000_FULL)
+		goto mac_done;
+
+	if (spd_dpx != SPD_DPX_AUTO)
+		goto advertise_done;
+
 	if (vptr->mii_status & VELOCITY_AUTONEG_ENABLE) {
 		if (PHYID_GET_PHY_ID(vptr->phy_id) == PHYID_CICADA_CS8201)
 			MII_REG_BITS_ON(AUXCR_MDPPS, MII_NCONFIG, vptr->mac_regs);
@@ -2978,6 +2985,7 @@ static int velocity_set_wol(struct velocity_info *vptr)
 	if (vptr->mii_status & VELOCITY_SPEED_1000)
 		MII_REG_BITS_ON(BMCR_ANRESTART, MII_BMCR, vptr->mac_regs);
 
+advertise_done:
 	BYTE_REG_BITS_ON(CHIPGCR_FCMODE, &regs->CHIPGCR);
 
 	{
@@ -2987,6 +2995,7 @@ static int velocity_set_wol(struct velocity_info *vptr)
 		writeb(GCR, &regs->CHIPGCR);
 	}
 
+mac_done:
 	BYTE_REG_BITS_OFF(ISR_PWEI, &regs->ISR);
 	/* Turn on SWPTAG just before entering power mode */
 	BYTE_REG_BITS_ON(STICKHW_SWPTAG, &regs->STICKHW);
diff --git a/drivers/net/via-velocity.h b/drivers/net/via-velocity.h
index aa2e69b..d722753 100644
--- a/drivers/net/via-velocity.h
+++ b/drivers/net/via-velocity.h
@@ -361,7 +361,7 @@ enum  velocity_owner {
 #define MAC_REG_CHIPGSR     0x9C
 #define MAC_REG_TESTCFG     0x9D
 #define MAC_REG_DEBUG       0x9E
-#define MAC_REG_CHIPGCR     0x9F
+#define MAC_REG_CHIPGCR     0x9F	/* Chip Operation and Diagnostic Control */
 #define MAC_REG_WOLCR0_SET  0xA0
 #define MAC_REG_WOLCR1_SET  0xA1
 #define MAC_REG_PWCFG_SET   0xA2
@@ -848,10 +848,10 @@ enum  velocity_owner {
  *	Bits in CHIPGCR register
  */
 
-#define CHIPGCR_FCGMII      0x80	/* enable GMII mode */
-#define CHIPGCR_FCFDX       0x40
+#define CHIPGCR_FCGMII      0x80	/* force GMII (else MII only) */
+#define CHIPGCR_FCFDX       0x40	/* force full duplex */
 #define CHIPGCR_FCRESV      0x20
-#define CHIPGCR_FCMODE      0x10
+#define CHIPGCR_FCMODE      0x10	/* enable MAC forced mode */
 #define CHIPGCR_LPSOPT      0x08
 #define CHIPGCR_TM1US       0x04
 #define CHIPGCR_TM0US       0x02
-- 
1.7.3.4

