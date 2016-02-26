From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Subject: [PATCH 2/2] phy: micrel: Disable auto negotiation on startup
Date: Fri, 26 Feb 2016 19:18:23 +0100
Message-ID: <1456510703-31559-3-git-send-email-alexandre.belloni@free-electrons.com>
References: <1456510703-31559-1-git-send-email-alexandre.belloni@free-electrons.com>
Cc: "David S . Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456510703-31559-1-git-send-email-alexandre.belloni@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Disable auto negotiation on init to properly detect an already plugged
cable at boot.

At boot, when the phy is started, it is in the PHY_UP state.
However, if a cable is plugged at boot, because auto negociation is already
enabled at the time we get the first interrupt, the phy is already running.
But the state machine then switches from PHY_UP to PHY_AN and calls
phy_start_aneg(). phy_start_aneg() will not do anything because aneg is
already enabled on the phy. It will then wait for a interrupt before going
further. This interrupt will never happen unless the cable is unplugged and
then replugged.

It was working properly before 321beec5047a (net: phy: Use interrupts when
available in NOLINK state) because switching to NOLINK meant starting
polling the phy, even if IRQ were enabled.

Fixes: 321beec5047a (net: phy: Use interrupts when available in NOLINK state)
Signed-off-by: Alexandre Belloni <alexandre.belloni@free-electrons.com>
---
 drivers/net/phy/micrel.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index a5e265b2bbfb..dc85f7095e51 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -297,6 +297,17 @@ static int kszphy_config_init(struct phy_device *phydev)
 	if (priv->led_mode >= 0)
 		kszphy_setup_led(phydev, type->led_mode_reg, priv->led_mode);
 
+	if (phy_interrupt_is_valid(phydev)) {
+		int ctl = phy_read(phydev, MII_BMCR);
+
+		if (ctl < 0)
+			return ctl;
+
+		ret = phy_write(phydev, MII_BMCR, ctl & ~BMCR_ANENABLE);
+		if (ret < 0)
+			return ret;
+	}
+
 	return 0;
 }
 
-- 
2.7.0
