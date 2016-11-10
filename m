From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 08/11] net: phy: expose phy_aneg_done API for
 use by drivers
Date: Thu, 10 Nov 2016 17:10:46 -0600
Message-ID: <20161110231046.20704.50400.stgit@tlendack-t1.amdoffice.net>
References: <20161110230916.20704.34081.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0059.outbound.protection.outlook.com ([104.47.41.59]:23280
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S964802AbcKJXKy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 18:10:54 -0500
In-Reply-To: <20161110230916.20704.34081.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make phy_aneg_done() available to drivers so that the result of the
auto-negotiation initiated by phy_start_aneg() can be determined.

Remove the local implementation of phy_aneg_done() from the Aeroflex
driver and use the phy library version.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/aeroflex/greth.c |    9 ---------
 drivers/net/phy/phy.c                 |    3 ++-
 include/linux/phy.h                   |    1 +
 3 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
index f8df824..93def92 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -1290,15 +1290,6 @@ static int greth_mdio_probe(struct net_device *dev)
 	return 0;
 }
 
-static inline int phy_aneg_done(struct phy_device *phydev)
-{
-	int retval;
-
-	retval = phy_read(phydev, MII_BMSR);
-
-	return (retval < 0) ? retval : (retval & BMSR_ANEGCOMPLETE);
-}
-
 static int greth_mdio_init(struct greth_private *greth)
 {
 	int ret;
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 2f94c60..e6dd222 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -143,13 +143,14 @@ static int phy_config_interrupt(struct phy_device *phydev, u32 interrupts)
  * Returns > 0 on success or < 0 on error. 0 means that auto-negotiation
  * is still pending.
  */
-static inline int phy_aneg_done(struct phy_device *phydev)
+int phy_aneg_done(struct phy_device *phydev)
 {
 	if (phydev->drv->aneg_done)
 		return phydev->drv->aneg_done(phydev);
 
 	return genphy_aneg_done(phydev);
 }
+EXPORT_SYMBOL(phy_aneg_done);
 
 /* A structure for mapping a particular speed and duplex
  * combination to a particular SUPPORTED and ADVERTISED value
diff --git a/include/linux/phy.h b/include/linux/phy.h
index e7e1fd3..9880d73 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -786,6 +786,7 @@ struct phy_device *phy_connect(struct net_device *dev, const char *bus_id,
 void phy_start(struct phy_device *phydev);
 void phy_stop(struct phy_device *phydev);
 int phy_start_aneg(struct phy_device *phydev);
+int phy_aneg_done(struct phy_device *phydev);
 
 int phy_stop_interrupts(struct phy_device *phydev);
 
