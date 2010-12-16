From: David Lv <davidlv.linux@gmail.com>
Subject: [PATCH] via-velocity: fix the WOL bug on 1000M full duplex forced mode
Date: Thu, 16 Dec 2010 17:33:15 +0800
Message-ID: <AANLkTi=-MRrH1nCcbzqUMoP1sd=7opNGAz7KwmdoMmjA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:42746 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751441Ab0LPJdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 04:33:16 -0500
Received: by fxm18 with SMTP id 18so3046265fxm.2
        for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 01:33:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch isn't based on the first patch of the sleep speed 10M.
The VIA velocity card can't be waken up by WOL tool on 1000M full
duplex forced mode.
This patch fixes the bug.
Thanks!

Signed-off-by: David Lv <DavidLv@viatech.com.cn>
Acked-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/via-velocity.c |   37 +++++++++++++++++++++++--------------
 1 files changed, 23 insertions(+), 14 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index cab96ad..947af49 100755
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -2925,6 +2925,7 @@ static int velocity_set_wol(struct velocity_info *vptr)
       struct mac_regs __iomem *regs = vptr->mac_regs;
       static u8 buf[256];
       int i;
+       u8 GCR;

       static u32 mask_pattern[2][4] = {
               {0x00203000, 0x000003C0, 0x00000000, 0x0000000}, /* ARP */
@@ -2968,23 +2969,31 @@ static int velocity_set_wol(struct velocity_info *vptr)

       writew(0x0FFF, &regs->WOLSRClr);

-       if (vptr->mii_status & VELOCITY_AUTONEG_ENABLE) {
-               if (PHYID_GET_PHY_ID(vptr->phy_id) == PHYID_CICADA_CS8201)
-                       MII_REG_BITS_ON(AUXCR_MDPPS, MII_NCONFIG,
vptr->mac_regs);
-
-               MII_REG_BITS_OFF(ADVERTISE_1000FULL |
ADVERTISE_1000HALF, MII_CTRL1000, vptr->mac_regs);
-       }
+       if (SPD_DPX_1000_FULL != vptr->options.spd_dpx) {
+               if (SPD_DPX_AUTO == vptr->options.spd_dpx) {
+                       if (vptr->mii_status & VELOCITY_AUTONEG_ENABLE) {
+                               if (PHYID_GET_PHY_ID(vptr->phy_id) ==
+                                               PHYID_CICADA_CS8201)
+                                       MII_REG_BITS_ON(AUXCR_MDPPS,
+                                       MII_NCONFIG, vptr->mac_regs);
+
+                               MII_REG_BITS_OFF(ADVERTISE_1000FULL |
+                                       ADVERTISE_1000HALF, MII_CTRL1000,
+                                       vptr->mac_regs);
+                       }

-       if (vptr->mii_status & VELOCITY_SPEED_1000)
-               MII_REG_BITS_ON(BMCR_ANRESTART, MII_BMCR, vptr->mac_regs);
+                       if (vptr->mii_status & VELOCITY_SPEED_1000)
+                               MII_REG_BITS_ON(BMCR_ANRESTART, MII_BMCR,
+                                       vptr->mac_regs);
+               }

-       BYTE_REG_BITS_ON(CHIPGCR_FCMODE, &regs->CHIPGCR);
+               BYTE_REG_BITS_ON(CHIPGCR_FCMODE, &regs->CHIPGCR);

-       {
-               u8 GCR;
-               GCR = readb(&regs->CHIPGCR);
-               GCR = (GCR & ~CHIPGCR_FCGMII) | CHIPGCR_FCFDX;
-               writeb(GCR, &regs->CHIPGCR);
+               {
+                       GCR = readb(&regs->CHIPGCR);
+                       GCR = (GCR & ~CHIPGCR_FCGMII) | CHIPGCR_FCFDX;
+                       writeb(GCR, &regs->CHIPGCR);
+               }
       }

       BYTE_REG_BITS_OFF(ISR_PWEI, &regs->ISR);
--
1.7.0.4
