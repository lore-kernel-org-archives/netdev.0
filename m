From: Wenyou Yang <wenyou.yang@atmel.com>
Subject: [PATCH] net: phy: micrel: workaround to NAND_Tree# incorrectly strapp-in during the reset period.
Date: Mon, 8 Dec 2014 11:35:40 +0800
Message-ID: <1418009740-27384-1-git-send-email-wenyou.yang@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<nicolas.ferre@atmel.com>,
	<linux-arm-kernel-bounces@lists.infradead.org>,
	<wenyou.yang@atmel.com>
To: <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Appearance: On some boards, after power up, the Ethernet doesn't work.

Reason: On the SAMA5D4EK, the PIOE2 pin is connected to the NAND_Tree# of KSZ8081,
But it outputs LOW during the reset period, which cause the NAND_Tree# enabled.

Workaround: In the .config_init(), add code to disable NAND_Tree#
by operating Operation Mode Strap Override(i.e. Register 16h).

Signed-off-by: Wenyou Yang <wenyou.yang@atmel.com>
---
 drivers/net/phy/micrel.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 8c2a29a..11d72cb 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -31,6 +31,7 @@
 /* Operation Mode Strap Override */
 #define MII_KSZPHY_OMSO				0x16
 #define KSZPHY_OMSO_B_CAST_OFF			(1 << 9)
+#define KSZPHY_OMSO_NAND_TREE_OVERRIDE		(1 << 5)
 #define KSZPHY_OMSO_RMII_OVERRIDE		(1 << 1)
 #define KSZPHY_OMSO_MII_OVERRIDE		(1 << 0)
 
@@ -180,7 +181,12 @@ static int kszphy_setup_led(struct phy_device *phydev,
 
 static int kszphy_config_init(struct phy_device *phydev)
 {
-	return 0;
+	int rc;
+
+	phy_write(phydev, MII_KSZPHY_OMSO, phy_read(phydev, MII_KSZPHY_OMSO)
+			& (~KSZPHY_OMSO_NAND_TREE_OVERRIDE));
+	rc = ksz_config_flags(phydev);
+	return rc < 0 ? rc : 0;
 }
 
 static int kszphy_config_init_led8041(struct phy_device *phydev)
-- 
1.7.9.5
