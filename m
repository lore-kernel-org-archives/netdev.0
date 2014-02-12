From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 05/10] net: phy: allow driver to implement their own aneg_done
Date: Tue, 11 Feb 2014 17:27:37 -0800
Message-ID: <1392168462-18888-6-git-send-email-f.fainelli@gmail.com>
References: <1392168462-18888-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:22446 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752392AbaBLB2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 20:28:19 -0500
In-Reply-To: <1392168462-18888-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some PHYs out there can be very quirky with respect to how they would
report the auto-negotiation is completed. Allow drivers to override the
generic aneg_done() implementation by providing their own.

Since not all drivers have been updated yet to use genphy_aneg_done() as
aneg_done() callback, we explicitely check that this callback is valid
before calling into it.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy.c        | 9 ++++++---
 drivers/net/phy/phy_device.c | 1 +
 include/linux/phy.h          | 3 +++
 3 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index db9c543..2fa4611 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -114,12 +114,15 @@ static int phy_config_interrupt(struct phy_device *phydev, u32 interrupts)
  * phy_aneg_done - return auto-negotiation status
  * @phydev: target phy_device struct
  *
- * Description: Reads the status register and returns 0 either if
- *   auto-negotiation is incomplete, or if there was an error.
- *   Returns BMSR_ANEGCOMPLETE if auto-negotiation is done.
+ * Description: Return the auto-negotiation status from this @phydev
+ * Returns > 0 on success or < 0 on error. 0 means that auto-negotiation
+ * is still pending.
  */
 static inline int phy_aneg_done(struct phy_device *phydev)
 {
+	if (phydev->drv->aneg_done)
+		return phydev->drv->aneg_done(phydev);
+
 	return genphy_aneg_done(phydev);
 }
 
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 4e7db72..7c18420 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -1267,6 +1267,7 @@ static struct phy_driver genphy_driver[] = {
 	.config_init	= genphy_config_init,
 	.features	= 0,
 	.config_aneg	= genphy_config_aneg,
+	.aneg_done	= genphy_aneg_done,
 	.read_status	= genphy_read_status,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
diff --git a/include/linux/phy.h b/include/linux/phy.h
index c572842..eede657 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -417,6 +417,9 @@ struct phy_driver {
 	 */
 	int (*config_aneg)(struct phy_device *phydev);
 
+	/* Determines the auto negotiation result */
+	int (*aneg_done)(struct phy_device *phydev);
+
 	/* Determines the negotiated speed and duplex */
 	int (*read_status)(struct phy_device *phydev);
 
-- 
1.8.3.2
