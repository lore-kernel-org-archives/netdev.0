From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 1/2] net: bcmgenet: add support for new GENET PHY revision scheme
Date: Wed,  3 Dec 2014 09:56:59 -0800
Message-ID: <1417629420-31146-2-git-send-email-f.fainelli@gmail.com>
References: <1417629420-31146-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:54814 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751045AbaLCR5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 12:57:13 -0500
Received: by mail-pa0-f52.google.com with SMTP id eu11so16077455pac.25
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 09:57:13 -0800 (PST)
In-Reply-To: <1417629420-31146-1-git-send-email-f.fainelli@gmail.com>
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
Changes in v2:

- remove unnecessary parenthesis
- add missing "is" in paragraph about the scheme

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 24 +++++++++++++++++++++++-
 1 file changed, 23 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index f2fadb053d52..410c22bc655a 100644
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
+	gphy_rev = reg & 0xffff;
+
+	/* This is the good old scheme, just GPHY major, no minor nor patch */
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
