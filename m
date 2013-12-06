From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 5/9] net: phy: consolidate PHY reset in phy_init_hw()
Date: Fri, 6 Dec 2013 13:01:34 -0800
Message-ID: <1386363698-8407-6-git-send-email-f.fainelli@gmail.com>
References: <1386363698-8407-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <sebastian.hesselbarth@gmail.com>,
	<sergei.shtylyov@cogentembedded.com>, <afleming@gmail.com>,
	<kyle@moffetthome.net>, Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:32631 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758733Ab3LFVDn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 16:03:43 -0500
In-Reply-To: <1386363698-8407-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are quite a lot of drivers touching a PHY device MII_BMCR
register to reset the PHY without taking care of:

1) ensuring that BMCR_RESET is cleared after a given timeout
2) the PHY state machine resuming to the proper state and re-applying
potentially changed settings such as auto-negotiation

Introduce phy_poll_reset() which will take care of polling the MII_BMCR
for the BMCR_RESET bit to be cleared after a given timeout or return a
timeout error code.

In order to make sure the PHY is in a correct state, phy_init_hw() first
issues a software reset through MII_BMCR and then applies any fixups.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/networking/phy.txt |  3 ++-
 drivers/net/phy/phy.c            |  5 ++--
 drivers/net/phy/phy_device.c     | 56 +++++++++++++++++++++++++++++++++++++++-
 3 files changed, 60 insertions(+), 4 deletions(-)

diff --git a/Documentation/networking/phy.txt b/Documentation/networking/phy.txt
index d5b1a39..ebf2707 100644
--- a/Documentation/networking/phy.txt
+++ b/Documentation/networking/phy.txt
@@ -255,7 +255,8 @@ Writing a PHY driver
 
    config_init: configures PHY into a sane state after a reset.
      For instance, a Davicom PHY requires descrambling disabled.
-   probe: Does any setup needed by the driver
+   probe: Allocate phy->priv, optionally refuse to bind.
+   PHY may not have been reset or had fixups run yet.
    suspend/resume: power management
    config_aneg: Changes the speed/duplex/negotiation settings
    read_status: Reads the current speed/duplex/negotiation settings
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 5d7101b..e3dd691 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -318,6 +318,7 @@ int phy_mii_ioctl(struct phy_device *phydev,
 {
 	struct mii_ioctl_data *mii_data = if_mii(ifr);
 	u16 val = mii_data->val_in;
+	int ret = 0;
 
 	switch (cmd) {
 	case SIOCGMIIPHY:
@@ -362,7 +363,7 @@ int phy_mii_ioctl(struct phy_device *phydev,
 
 		if (mii_data->reg_num == MII_BMCR &&
 		    val & BMCR_RESET)
-			phy_init_hw(phydev);
+			ret = phy_init_hw(phydev);
 		break;
 
 	case SIOCSHWTSTAMP:
@@ -374,7 +375,7 @@ int phy_mii_ioctl(struct phy_device *phydev,
 		return -EOPNOTSUPP;
 	}
 
-	return 0;
+	return ret;
 }
 EXPORT_SYMBOL(phy_mii_ioctl);
 
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 6db3659..5a619f0 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -364,7 +364,11 @@ int phy_device_register(struct phy_device *phydev)
 	phydev->bus->phy_map[phydev->addr] = phydev;
 
 	/* Run all of the fixups for this PHY */
-	phy_scan_fixups(phydev);
+	err = phy_init_hw(phydev);
+	if (err) {
+		pr_err("PHY %d failed to initialize\n", phydev->addr);
+		goto out;
+	}
 
 	err = device_add(&phydev->dev);
 	if (err) {
@@ -497,6 +501,47 @@ void phy_disconnect(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(phy_disconnect);
 
+/**
+ * phy_poll_reset - Safely wait until a PHY reset has properly completed
+ * @phydev: The PHY device to poll
+ *
+ * Description: According to IEEE 802.3, Section 2, Subsection 22.2.4.1.1, as
+ *   published in 2008, a PHY reset may take up to 0.5 seconds.  The MII BMCR
+ *   register must be polled until the BMCR_RESET bit clears.
+ *
+ *   Furthermore, any attempts to write to PHY registers may have no effect
+ *   or even generate MDIO bus errors until this is complete.
+ *
+ *   Some PHYs (such as the Marvell 88E1111) don't entirely conform to the
+ *   standard and do not fully reset after the BMCR_RESET bit is set, and may
+ *   even *REQUIRE* a soft-reset to properly restart autonegotiation.  In an
+ *   effort to support such broken PHYs, this function is separate from the
+ *   standard phy_init_hw() which will zero all the other bits in the BMCR
+ *   and reapply all driver-specific and board-specific fixups.
+ */
+static int phy_poll_reset(struct phy_device *phydev)
+{
+	/* Poll until the reset bit clears (50ms per retry == 0.6 sec) */
+	unsigned int retries = 12;
+	int ret;
+
+	do {
+		msleep(50);
+		ret = phy_read(phydev, MII_BMCR);
+		if (ret < 0)
+			return ret;
+	} while (ret & BMCR_RESET && --retries);
+	if (ret & BMCR_RESET)
+		return -ETIMEDOUT;
+
+	/*
+	 * Some chips (smsc911x) may still need up to another 1ms after the
+	 * BMCR_RESET bit is cleared before they are usable.
+	 */
+	msleep(1);
+	return 0;
+}
+
 int phy_init_hw(struct phy_device *phydev)
 {
 	int ret;
@@ -504,12 +549,21 @@ int phy_init_hw(struct phy_device *phydev)
 	if (!phydev->drv || !phydev->drv->config_init)
 		return 0;
 
+	ret = phy_write(phydev, MII_BMCR, BMCR_RESET);
+	if (ret < 0)
+		return ret;
+
+	ret = phy_poll_reset(phydev);
+	if (ret < 0)
+		return ret;
+
 	ret = phy_scan_fixups(phydev);
 	if (ret < 0)
 		return ret;
 
 	return phydev->drv->config_init(phydev);
 }
+EXPORT_SYMBOL(phy_init_hw);
 
 /**
  * phy_attach_direct - attach a network device to a given PHY device pointer
-- 
1.8.3.2
