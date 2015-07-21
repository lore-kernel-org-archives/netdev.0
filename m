From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v5 1/4] net: dsa: bcm_sf2: Do not override speed settings
Date: Mon, 20 Jul 2015 17:49:55 -0700
Message-ID: <1437439798-12622-2-git-send-email-f.fainelli@gmail.com>
References: <1437439798-12622-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org, mxs@sbrk.org,
	arno@natisbad.org, stsp@users.sourceforge.net,
	devicetree@vger.kernel.org, thomas.petazzoni@free-electrons.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437439798-12622-1-git-send-email-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The SF2 driver currently overrides speed settings for its port
configured using a fixed PHY, this is both unnecessary and incorrect,
because we keep feedback to the hardware parameters that we read from
the PHY device, which in the case of a fixed PHY cannot possibly change
speed.

This is a required change to allow the fixed PHY code to allow
registering a PHY with a link configured as DOWN by default and avoid
some sort of circular dependency where we require the link_update
callback to run to program the hardware, and we then utilize the fixed
PHY parameters to program the hardware with the same settings.

Fixes: 246d7f773c13 ("net: dsa: add Broadcom SF2 switch driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 18 +-----------------
 1 file changed, 1 insertion(+), 17 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 972982f8bea7..3297604f8216 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -890,15 +890,11 @@ static void bcm_sf2_sw_fixed_link_update(struct dsa_switch *ds, int port,
 					 struct fixed_phy_status *status)
 {
 	struct bcm_sf2_priv *priv = ds_to_priv(ds);
-	u32 duplex, pause, speed;
+	u32 duplex, pause;
 	u32 reg;
 
 	duplex = core_readl(priv, CORE_DUPSTS);
 	pause = core_readl(priv, CORE_PAUSESTS);
-	speed = core_readl(priv, CORE_SPDSTS);
-
-	speed >>= (port * SPDSTS_SHIFT);
-	speed &= SPDSTS_MASK;
 
 	status->link = 0;
 
@@ -933,18 +929,6 @@ static void bcm_sf2_sw_fixed_link_update(struct dsa_switch *ds, int port,
 		reg &= ~LINK_STS;
 	core_writel(priv, reg, CORE_STS_OVERRIDE_GMIIP_PORT(port));
 
-	switch (speed) {
-	case SPDSTS_10:
-		status->speed = SPEED_10;
-		break;
-	case SPDSTS_100:
-		status->speed = SPEED_100;
-		break;
-	case SPDSTS_1000:
-		status->speed = SPEED_1000;
-		break;
-	}
-
 	if ((pause & (1 << port)) &&
 	    (pause & (1 << (port + PAUSESTS_TX_PAUSE_SHIFT)))) {
 		status->asym_pause = 1;
-- 
2.1.0
