From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/2] net: bcmgenet: add support for new GENET PHY revision scheme
Date: Tue,  2 Dec 2014 15:28:01 -0800
Message-ID: <1417562882-2511-2-git-send-email-f.fainelli@gmail.com>
References: <1417562882-2511-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:64258 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933263AbaLBX2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 18:28:14 -0500
Received: by mail-pd0-f170.google.com with SMTP id fp1so14205600pdb.29
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 15:28:13 -0800 (PST)
In-Reply-To: <1417562882-2511-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Starting with GPHY revision G0, the GENET register layout has changed to
use the same numbering scheme as the Starfighter 2 switch. This means
that GPHY major revision is in bits 15:12, minor in bits 11:8 and patch
level is in bits 7:4.

Introduce a small heuristic which checks for the old scheme first, tests
for the new scheme and finally attempts to catch reserved values and
aborts.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 24 +++++++++++++++++++++++-
 1 file changed, 23 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index f2fadb053d52..23e283174c4e 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2503,6 +2503,7 @@ static void bcmgenet_set_hw_params(struct bcmgenet_priv *priv)
 	struct bcmgenet_hw_params *params;
 	u32 reg;
 	u8 major;
+	u16 gphy_rev;
 
 	if (GENET_IS_V4(priv)) {
 		bcmgenet_dma_regs = bcmgenet_dma_regs_v3plus;
@@ -2551,8 +2552,29 @@ static void bcmgenet_set_hw_params(struct bcmgenet_priv *priv)
 	 * to pass this information to the PHY driver. The PHY driver expects
 	 * to find the PHY major revision in bits 15:8 while the GENET register
 	 * stores that information in bits 7:0, account for that.
+	 *
+	 * On newer chips, starting with PHY revision G0, a new scheme is
+	 * deployed similar to the Starfighter 2 switch with GPHY major
+	 * revision in bits 15:8 and patch level in bits 7:0. Major revision 0
+	 * is reserved as well as special value 0x01ff, we have a small
+	 * heuristic to check for the new GPHY revision and re-arrange things
+	 * so the GPHY driver is happy.
 	 */
-	priv->gphy_rev = (reg & 0xffff) << 8;
+	gphy_rev = (reg & 0xffff);
+
+	/* This the good old scheme, just GPHY major, no minor nor patch */
+	if ((gphy_rev & 0xf0) != 0)
+		priv->gphy_rev = gphy_rev << 8;
+
+	/* This is the new scheme, GPHY major rolls over with 0x10 = rev G0 */
+	else if ((gphy_rev & 0xff00) != 0)
+		priv->gphy_rev = gphy_rev;
+
+	/* This is reserved so should require special treatment */
+	else if (gphy_rev == 0 || gphy_rev == 0x01ff) {
+		pr_warn("Invalid GPHY revision detected: 0x%04x\n", gphy_rev);
+		return;
+	}
 
 #ifdef CONFIG_PHYS_ADDR_T_64BIT
 	if (!(params->flags & GENET_HAS_40BITS))
-- 
2.1.0
