From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH] [NET] cpmac: convert to new Fixed PHY infrastructure (was: Re: fixed phy support (warning related to FIXED_MII_100_FDX))
Date: Mon, 21 Jan 2008 23:49:53 +0300
Message-ID: <20080121204953.GA11384@localhost.localdomain>
References: <416B8C5D-109C-4C03-807D-7EBB0AA9C366@kernel.crashing.org>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: linuxppc-dev list <linuxppc-dev@ozlabs.org>,
	netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Eugene Konev <ejka@imfi.kspu.ru>
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:38389 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753227AbYAUUuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 15:50:03 -0500
Content-Disposition: inline
In-Reply-To: <416B8C5D-109C-4C03-807D-7EBB0AA9C366@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 21, 2008 at 01:19:41PM -0600, Kumar Gala wrote:
> Anton,
> 
> it looks like the "TI AR7 CPMAC Ethernet support" uses FIXED_PHY and  
> was selecting FIXED_MII_100_FDX which is gone.
> 
> Can you look into this.  I get the following warning now:
> 
> scripts/kconfig/conf -s arch/powerpc/Kconfig
> drivers/net/Kconfig:1713:warning: 'select' used by config symbol  
> 'CPMAC' refers to undefined symbol 'FIXED_MII_100_FDX'

Wow. I thought there were no Fixed PHY users. :-)

Jeff, as you've already Acked Fixed PHY rework to go through powerpc
tree, would you please Ack this patch in addition? I hope cpmac
maintainer will fix remaining issues as time goes by.

Thanks!

- - - -
From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH] [NET] cpmac: convert to new Fixed PHY infrastructure

This patch converts cpmac to the new Fixed PHY infrastructure, though it
doesn't fix all the problems with that driver. I didn't even bother to
test this patch to compile, because cpmac driver is broken in several ways:

1. This driver won't compile by itself because lack of its header describing
   platform data;
2. It assumes that fixed PHYs should be created by the ethernet driver.
   It is wrong assumption: fixed PHYs creation is platform code authority,
   driver must blindly accept bus_id and phy_id platform data variables
   instead.

Also, it seem that that driver doesn't have actual in-tree users, so
nothing to fix further.

The main purpose of that patch is to get rid of the following Kconfig
warning:

scripts/kconfig/conf -s arch/powerpc/Kconfig
drivers/net/Kconfig:1713:warning: 'select' used by config symbol
'CPMAC' refers to undefined symbol 'FIXED_MII_100_FDX'

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/Kconfig |    4 +--
 drivers/net/cpmac.c |   55 ++++++++++++++++----------------------------------
 2 files changed, 19 insertions(+), 40 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 114771a..5380ff9 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1707,10 +1707,8 @@ config SC92031
 
 config CPMAC
 	tristate "TI AR7 CPMAC Ethernet support (EXPERIMENTAL)"
-	depends on NET_ETHERNET && EXPERIMENTAL && AR7
+	depends on NET_ETHERNET && EXPERIMENTAL && AR7 && BROKEN
 	select PHYLIB
-	select FIXED_PHY
-	select FIXED_MII_100_FDX
 	help
 	  TI AR7 CPMAC Ethernet support
 
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index 6fd95a2..88eeb1d 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -848,15 +848,6 @@ static void cpmac_adjust_link(struct net_device *dev)
 	spin_unlock(&priv->lock);
 }
 
-static int cpmac_link_update(struct net_device *dev,
-			     struct fixed_phy_status *status)
-{
-	status->link = 1;
-	status->speed = 100;
-	status->duplex = 1;
-	return 0;
-}
-
 static int cpmac_open(struct net_device *dev)
 {
 	int i, size, res;
@@ -999,11 +990,11 @@ static int external_switch;
 static int __devinit cpmac_probe(struct platform_device *pdev)
 {
 	int rc, phy_id, i;
+	int mdio_bus_id = cpmac_mii.id;
 	struct resource *mem;
 	struct cpmac_priv *priv;
 	struct net_device *dev;
 	struct plat_cpmac_data *pdata;
-	struct fixed_info *fixed_phy;
 	DECLARE_MAC_BUF(mac);
 
 	pdata = pdev->dev.platform_data;
@@ -1017,9 +1008,23 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 	}
 
 	if (phy_id == PHY_MAX_ADDR) {
-		if (external_switch || dumb_switch)
+		if (external_switch || dumb_switch) {
+			struct fixed_phy_status status = {};
+
+			mdio_bus_id = 0;
+
+			/*
+			 * FIXME: this should be in the platform code!
+			 * Since there is not platform code at all (that is,
+			 * no mainline users of that driver), place it here
+			 * for now.
+			 */
 			phy_id = 0;
-		else {
+			status.link = 1;
+			status.duplex = 1;
+			status.speed = 100;
+			fixed_phy_add(PHY_POLL, phy_id, &status);
+		} else {
 			printk(KERN_ERR "cpmac: no PHY present\n");
 			return -ENODEV;
 		}
@@ -1063,32 +1068,8 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 	priv->msg_enable = netif_msg_init(debug_level, 0xff);
 	memcpy(dev->dev_addr, pdata->dev_addr, sizeof(dev->dev_addr));
 
-	if (phy_id == 31) {
-		snprintf(priv->phy_name, BUS_ID_SIZE, PHY_ID_FMT, cpmac_mii.id,
-			 phy_id);
-	} else {
-		/* Let's try to get a free fixed phy... */
-		for (i = 0; i < MAX_PHY_AMNT; i++) {
-			fixed_phy = fixed_mdio_get_phydev(i);
-			if (!fixed_phy)
-				continue;
-			if (!fixed_phy->phydev->attached_dev) {
-				strncpy(priv->phy_name,
-					fixed_phy->phydev->dev.bus_id,
-					BUS_ID_SIZE);
-				fixed_mdio_set_link_update(fixed_phy->phydev,
-							   &cpmac_link_update);
-				goto phy_found;
-			}
-		}
-		if (netif_msg_drv(priv))
-			printk(KERN_ERR "%s: Could not find fixed PHY\n",
-			       dev->name);
-		rc = -ENODEV;
-		goto fail;
-	}
+	snprintf(priv->phy_name, BUS_ID_SIZE, PHY_ID_FMT, mdio_bus_id, phy_id);
 
-phy_found:
 	priv->phy = phy_connect(dev, priv->phy_name, &cpmac_adjust_link, 0,
 				PHY_INTERFACE_MODE_MII);
 	if (IS_ERR(priv->phy)) {
-- 
1.5.2.2

