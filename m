From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.26] gianfar: Fix a locking bug in gianfar's sysfs code
Date: Fri,  2 May 2008 13:00:30 -0500
Message-ID: <1209751230-25462-1-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:46270 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756875AbYEBSAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 14:00:45 -0400
Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw01.freescale.net (8.12.11/az33egw01) with ESMTP id m42I0c4u008245
	for <netdev@vger.kernel.org>; Fri, 2 May 2008 11:00:38 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id m42I0UBg013212
	for <netdev@vger.kernel.org>; Fri, 2 May 2008 13:00:31 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During sparse cleanup, found a locking bug.  Some of the sysfs functions were
acquiring a lock, and then returning in the event of an error.  We rearrange
the code so that the lock is released in error conditions, too.

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/gianfar.c       |    5 +++--
 drivers/net/gianfar.h       |    3 +++
 drivers/net/gianfar_sysfs.c |   10 ++++++----
 3 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 587afe7..6f22f06 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -138,6 +138,7 @@ static int gfar_poll(struct napi_struct *napi, int budget);
 static void gfar_netpoll(struct net_device *dev);
 #endif
 int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit);
+static int gfar_clean_tx_ring(struct net_device *dev);
 static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb, int length);
 static void gfar_vlan_rx_register(struct net_device *netdev,
 		                struct vlan_group *grp);
@@ -1141,7 +1142,7 @@ static int gfar_close(struct net_device *dev)
 }
 
 /* Changes the mac address if the controller is not running. */
-int gfar_set_mac_address(struct net_device *dev)
+static int gfar_set_mac_address(struct net_device *dev)
 {
 	gfar_set_mac_for_addr(dev, 0, dev->dev_addr);
 
@@ -1260,7 +1261,7 @@ static void gfar_timeout(struct net_device *dev)
 }
 
 /* Interrupt Handler for Transmit complete */
-int gfar_clean_tx_ring(struct net_device *dev)
+static int gfar_clean_tx_ring(struct net_device *dev)
 {
 	struct txbd8 *bdp;
 	struct gfar_private *priv = netdev_priv(dev);
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index fd487be..27f37c8 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -782,5 +782,8 @@ extern void gfar_halt(struct net_device *dev);
 extern void gfar_phy_test(struct mii_bus *bus, struct phy_device *phydev,
 		int enable, u32 regnum, u32 read);
 void gfar_init_sysfs(struct net_device *dev);
+int gfar_local_mdio_write(struct gfar_mii __iomem *regs, int mii_id,
+			  int regnum, u16 value);
+int gfar_local_mdio_read(struct gfar_mii __iomem *regs, int mii_id, int regnum);
 
 #endif /* __GIANFAR_H */
diff --git a/drivers/net/gianfar_sysfs.c b/drivers/net/gianfar_sysfs.c
index 230878b..5116f68 100644
--- a/drivers/net/gianfar_sysfs.c
+++ b/drivers/net/gianfar_sysfs.c
@@ -103,10 +103,10 @@ static ssize_t gfar_set_rx_stash_size(struct device *dev,
 
 	spin_lock_irqsave(&priv->rxlock, flags);
 	if (length > priv->rx_buffer_size)
-		return count;
+		goto out;
 
 	if (length == priv->rx_stash_size)
-		return count;
+		goto out;
 
 	priv->rx_stash_size = length;
 
@@ -125,6 +125,7 @@ static ssize_t gfar_set_rx_stash_size(struct device *dev,
 
 	gfar_write(&priv->regs->attr, temp);
 
+out:
 	spin_unlock_irqrestore(&priv->rxlock, flags);
 
 	return count;
@@ -154,10 +155,10 @@ static ssize_t gfar_set_rx_stash_index(struct device *dev,
 
 	spin_lock_irqsave(&priv->rxlock, flags);
 	if (index > priv->rx_stash_size)
-		return count;
+		goto out;
 
 	if (index == priv->rx_stash_index)
-		return count;
+		goto out;
 
 	priv->rx_stash_index = index;
 
@@ -166,6 +167,7 @@ static ssize_t gfar_set_rx_stash_index(struct device *dev,
 	temp |= ATTRELI_EI(index);
 	gfar_write(&priv->regs->attreli, flags);
 
+out:
 	spin_unlock_irqrestore(&priv->rxlock, flags);
 
 	return count;
-- 
1.5.4.GIT

