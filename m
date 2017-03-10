From: Doug Berger <opendmb@gmail.com>
Subject: [PATCH net 3/8] net: bcmgenet: reserved phy revisions must be checked first
Date: Thu,  9 Mar 2017 16:49:01 -0800
Message-ID: <20170310004906.10553-4-opendmb@gmail.com>
References: <20170310004906.10553-1-opendmb@gmail.com>
Cc: pgynther@google.com, jaedon.shin@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Doug Berger <doug.berger@broadcom.com>
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170310004906.10553-1-opendmb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Doug Berger <doug.berger@broadcom.com>

The reserved gphy_rev value of 0x01ff must be tested before the old
or new scheme for GPHY major versioning are tested, otherwise it will
be treated as 0xff00 according to the old scheme.

refs #SWLINUX-4311

Fixes: b04a2f5b9ff5 ("net: bcmgenet: add support for new GENET PHY revision scheme")
Signed-off-by: Doug Berger <doug.berger@broadcom.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 01a172d95328..99f8d9024633 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -3226,6 +3226,12 @@ static void bcmgenet_set_hw_params(struct bcmgenet_priv *priv)
 	 */
 	gphy_rev = reg & 0xffff;
 
+	/* This is reserved so should require special treatment */
+	if (gphy_rev == 0 || gphy_rev == 0x01ff) {
+		pr_warn("Invalid GPHY revision detected: 0x%04x\n", gphy_rev);
+		return;
+	}
+
 	/* This is the good old scheme, just GPHY major, no minor nor patch */
 	if ((gphy_rev & 0xf0) != 0)
 		priv->gphy_rev = gphy_rev << 8;
@@ -3234,12 +3240,6 @@ static void bcmgenet_set_hw_params(struct bcmgenet_priv *priv)
 	else if ((gphy_rev & 0xff00) != 0)
 		priv->gphy_rev = gphy_rev;
 
-	/* This is reserved so should require special treatment */
-	else if (gphy_rev == 0 || gphy_rev == 0x01ff) {
-		pr_warn("Invalid GPHY revision detected: 0x%04x\n", gphy_rev);
-		return;
-	}
-
 #ifdef CONFIG_PHYS_ADDR_T_64BIT
 	if (!(params->flags & GENET_HAS_40BITS))
 		pr_warn("GENET does not support 40-bits PA\n");
-- 
2.11.1
