From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 2/3] phylib: add missing _{check_gmii_support,link_ok,nway_restart}
Date: Wed,  3 Sep 2008 15:20:11 +0200
Message-ID: <1220448012-20347-3-git-send-email-buytenh@wantstofly.org>
References: <1220448012-20347-1-git-send-email-buytenh@wantstofly.org>
Cc: Andy Fleming <afleming@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:56365 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752077AbYICNUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 09:20:14 -0400
In-Reply-To: <1220448012-20347-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/net/mii.c provides a couple of routines which currently have
no phylib equivalents.  This patch provides those phylib equivalents.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/phy/phy.c |   63 +++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/phy.h   |    3 ++
 2 files changed, 66 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 45cc291..cb15517 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -349,6 +349,69 @@ int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd)
 EXPORT_SYMBOL(phy_ethtool_gset);
 
 /**
+ * phy_check_gmii_support - check if the PHY supports (R)GMII
+ * @phydev: the phy_device struct
+ */
+int phy_check_gmii_support(struct phy_device *phydev)
+{
+	int retval;
+
+	retval = phy_read(phydev, MII_BMSR);
+	if (retval < 0 || (retval & BMSR_ESTATEN) == 0)
+		return 0;
+
+	retval = phy_read(phydev, MII_ESTATUS);
+	if (retval < 0)
+		return 0;
+
+	return !!(retval & (ESTATUS_1000_TFULL | ESTATUS_1000_THALF));
+}
+EXPORT_SYMBOL(phy_check_gmii_support);
+
+/**
+ * phy_link_ok - is link status up/ok
+ * @phydev: the phy_device struct
+ *
+ * Returns 1 if the PHY reports link status up/ok, 0 otherwise.
+ */
+int phy_link_ok(struct phy_device *phydev)
+{
+	int retval;
+
+	/* first, a dummy read, needed to latch some MII phys */
+	phy_read(phydev, MII_BMSR);
+
+	retval = phy_read(phydev, MII_BMSR);
+	if (retval < 0 || (retval & BMSR_LSTATUS) == 0)
+		return 0;
+
+	return 1;
+}
+EXPORT_SYMBOL(phy_link_ok);
+
+/**
+ * phy_nway_restart - restart NWay (autonegotiation) for this interface
+ * @phydev: the phy_device struct
+ *
+ * Returns 0 on success, negative on error.
+ */
+int phy_nway_restart(struct phy_device *phydev)
+{
+	int bmcr;
+
+	/* if autoneg is off, it's an error */
+	bmcr = phy_read(phydev, MII_BMCR);
+	if (bmcr < 0 || (bmcr & BMCR_ANENABLE) == 0)
+		return -EINVAL;
+
+	if (phy_write(phydev, MII_BMCR, bmcr | BMCR_ANRESTART) < 0)
+		return -EINVAL;
+
+	return 0;
+}
+EXPORT_SYMBOL(phy_nway_restart);
+
+/**
  * phy_mii_ioctl - generic PHY MII ioctl interface
  * @phydev: the phy_device struct
  * @mii_data: MII ioctl data
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 5f170f5..e710bb1 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -436,6 +436,9 @@ void phy_start_machine(struct phy_device *phydev,
 void phy_stop_machine(struct phy_device *phydev);
 int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd *cmd);
 int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd);
+int phy_check_gmii_support(struct phy_device *phydev);
+int phy_link_ok(struct phy_device *phydev);
+int phy_nway_restart(struct phy_device *phydev);
 int phy_mii_ioctl(struct phy_device *phydev,
 		struct mii_ioctl_data *mii_data, int cmd);
 int phy_start_interrupts(struct phy_device *phydev);
-- 
1.5.6.4

