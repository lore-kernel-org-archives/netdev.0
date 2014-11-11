From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 07/22] net: phy: micrel: refactor broadcast disable
Date: Tue, 11 Nov 2014 18:37:25 +0100
Message-ID: <1415727460-20417-8-git-send-email-johan@kernel.org>
References: <1415727460-20417-1-git-send-email-johan@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Johan Hovold <johan@kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415727460-20417-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Refactor and clean up broadcast disable.

Some Micrel PHYs have a broadcast-off bit in the Operation Mode Strap
Override register which can be used to disable PHY address 0 as the
broadcast address, so that it can be used as a unique (non-broadcast)
address on a shared bus.

Note that the KSZPHY_OMSO_RMII_OVERRIDE bit is set by default on
KSZ8021/8031.

Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/phy/micrel.c | 24 ++++++++++++++++++++++--
 1 file changed, 22 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index d962a2866bba..21abe5ade3df 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -184,6 +184,25 @@ static int kszphy_setup_led(struct phy_device *phydev,
 	return rc < 0 ? rc : 0;
 }
 
+/* Disable PHY address 0 as the broadcast address, so that it can be used as a
+ * unique (non-broadcast) address on a shared bus.
+ */
+static int kszphy_broadcast_disable(struct phy_device *phydev)
+{
+	int ret;
+
+	ret = phy_read(phydev, MII_KSZPHY_OMSO);
+	if (ret < 0)
+		goto out;
+
+	ret = phy_write(phydev, MII_KSZPHY_OMSO, ret | KSZPHY_OMSO_B_CAST_OFF);
+out:
+	if (ret)
+		dev_err(&phydev->dev, "failed to disable broadcast address\n");
+
+	return ret;
+}
+
 static int kszphy_config_init(struct phy_device *phydev)
 {
 	return 0;
@@ -197,7 +216,6 @@ static int kszphy_config_init_led8041(struct phy_device *phydev)
 
 static int ksz8021_config_init(struct phy_device *phydev)
 {
-	const u16 val = KSZPHY_OMSO_B_CAST_OFF | KSZPHY_OMSO_RMII_OVERRIDE;
 	int rc;
 
 	rc = kszphy_setup_led(phydev, 0x1f, 4);
@@ -207,7 +225,9 @@ static int ksz8021_config_init(struct phy_device *phydev)
 	rc = ksz_config_flags(phydev);
 	if (rc < 0)
 		return rc;
-	rc = phy_write(phydev, MII_KSZPHY_OMSO, val);
+
+	rc = kszphy_broadcast_disable(phydev);
+
 	return rc < 0 ? rc : 0;
 }
 
-- 
2.0.4
