From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 3/3] netdev: Convert MDIO ioctl implementation to use
	struct mii_ioctl_data
Date: Thu, 03 Sep 2009 21:41:17 +0100
Message-ID: <1252010477.2781.20.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:35399 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932160AbZICUlQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 16:41:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A few drivers still access the arguments to MDIO ioctls as an array of
u16.  Convert them to use struct mii_ioctl_data.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
The PCMCIA drivers are compile-tested.  The emac driver is not since
it's for PPC only, but I'm fairly confident that it will work.

Ben.

 drivers/net/ibm_newemac/core.c  |   10 ++++++----
 drivers/net/pcmcia/3c574_cs.c   |   13 ++++++++-----
 drivers/net/pcmcia/axnet_cs.c   |    9 +++++----
 drivers/net/pcmcia/pcnet_cs.c   |    9 +++++----
 drivers/net/pcmcia/xirc2ps_cs.c |   13 ++++++++-----
 5 files changed, 32 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index 8a95234..1d7d7fe 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -2209,7 +2209,7 @@ static const struct ethtool_ops emac_ethtool_ops = {
 static int emac_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
 {
 	struct emac_instance *dev = netdev_priv(ndev);
-	uint16_t *data = (uint16_t *) & rq->ifr_ifru;
+	struct mii_ioctl_data *data = if_mii(rq);
 
 	DBG(dev, "ioctl %08x" NL, cmd);
 
@@ -2218,14 +2218,16 @@ static int emac_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
 
 	switch (cmd) {
 	case SIOCGMIIPHY:
-		data[0] = dev->phy.address;
+		data->phy_id = dev->phy.address;
 		/* Fall through */
 	case SIOCGMIIREG:
-		data[3] = emac_mdio_read(ndev, dev->phy.address, data[1]);
+		data->val_out = emac_mdio_read(ndev, dev->phy.address,
+					       data->reg_num);
 		return 0;
 
 	case SIOCSMIIREG:
-		emac_mdio_write(ndev, dev->phy.address, data[1], data[2]);
+		emac_mdio_write(ndev, dev->phy.address, data->reg_num,
+				data->val_in);
 		return 0;
 	default:
 		return -EOPNOTSUPP;
diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
index d836af1..ee8ad3e 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -85,6 +85,7 @@ earlier 3Com products.
 #include <linux/ioport.h>
 #include <linux/ethtool.h>
 #include <linux/bitops.h>
+#include <linux/mii.h>
 
 #include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
@@ -1096,16 +1097,16 @@ static int el3_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct el3_private *lp = netdev_priv(dev);
 	unsigned int ioaddr = dev->base_addr;
-	u16 *data = (u16 *)&rq->ifr_ifru;
+	struct mii_ioctl_data *data = if_mii(rq);
 	int phy = lp->phys & 0x1f;
 
 	DEBUG(2, "%s: In ioct(%-.6s, %#4.4x) %4.4x %4.4x %4.4x %4.4x.\n",
 		  dev->name, rq->ifr_ifrn.ifrn_name, cmd,
-		  data[0], data[1], data[2], data[3]);
+		  data->phy_id, data->reg_num, data->val_in, data->val_out);
 
 	switch(cmd) {
 	case SIOCGMIIPHY:		/* Get the address of the PHY in use. */
-		data[0] = phy;
+		data->phy_id = phy;
 	case SIOCGMIIREG:		/* Read the specified MII register. */
 		{
 			int saved_window;
@@ -1114,7 +1115,8 @@ static int el3_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 			spin_lock_irqsave(&lp->window_lock, flags);
 			saved_window = inw(ioaddr + EL3_CMD) >> 13;
 			EL3WINDOW(4);
-			data[3] = mdio_read(ioaddr, data[0] & 0x1f, data[1] & 0x1f);
+			data->val_out = mdio_read(ioaddr, data->phy_id & 0x1f,
+						  data->reg_num & 0x1f);
 			EL3WINDOW(saved_window);
 			spin_unlock_irqrestore(&lp->window_lock, flags);
 			return 0;
@@ -1127,7 +1129,8 @@ static int el3_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 			spin_lock_irqsave(&lp->window_lock, flags);
 			saved_window = inw(ioaddr + EL3_CMD) >> 13;
 			EL3WINDOW(4);
-			mdio_write(ioaddr, data[0] & 0x1f, data[1] & 0x1f, data[2]);
+			mdio_write(ioaddr, data->phy_id & 0x1f,
+				   data->reg_num & 0x1f, data->val_in);
 			EL3WINDOW(saved_window);
 			spin_unlock_irqrestore(&lp->window_lock, flags);
 			return 0;
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index 4f2fef6..3131a59 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -37,6 +37,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/crc32.h>
+#include <linux/mii.h>
 #include "../8390.h"
 
 #include <pcmcia/cs_types.h>
@@ -697,16 +698,16 @@ static const struct ethtool_ops netdev_ethtool_ops = {
 static int axnet_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
     axnet_dev_t *info = PRIV(dev);
-    u16 *data = (u16 *)&rq->ifr_ifru;
+    struct mii_ioctl_data *data = if_mii(rq);
     unsigned int mii_addr = dev->base_addr + AXNET_MII_EEP;
     switch (cmd) {
     case SIOCGMIIPHY:
-	data[0] = info->phy_id;
+	data->phy_id = info->phy_id;
     case SIOCGMIIREG:		/* Read MII PHY register. */
-	data[3] = mdio_read(mii_addr, data[0], data[1] & 0x1f);
+	data->val_out = mdio_read(mii_addr, data->phy_id, data->reg_num & 0x1f);
 	return 0;
     case SIOCSMIIREG:		/* Write MII PHY register. */
-	mdio_write(mii_addr, data[0], data[1] & 0x1f, data[2]);
+	mdio_write(mii_addr, data->phy_id, data->reg_num & 0x1f, data->val_in);
 	return 0;
     }
     return -EOPNOTSUPP;
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index 8996b45..90a94d2 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -40,6 +40,7 @@
 #include <linux/netdevice.h>
 #include <linux/log2.h>
 #include <linux/etherdevice.h>
+#include <linux/mii.h>
 #include "../8390.h"
 
 #include <pcmcia/cs_types.h>
@@ -1191,7 +1192,7 @@ static const struct ethtool_ops netdev_ethtool_ops = {
 static int ei_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
     pcnet_dev_t *info = PRIV(dev);
-    u16 *data = (u16 *)&rq->ifr_ifru;
+    struct mii_ioctl_data *data = if_mii(rq);
     unsigned int mii_addr = dev->base_addr + DLINK_GPIO;
 
     if (!(info->flags & (IS_DL10019|IS_DL10022)))
@@ -1199,12 +1200,12 @@ static int ei_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 
     switch (cmd) {
     case SIOCGMIIPHY:
-	data[0] = info->phy_id;
+	data->phy_id = info->phy_id;
     case SIOCGMIIREG:		/* Read MII PHY register. */
-	data[3] = mdio_read(mii_addr, data[0], data[1] & 0x1f);
+	data->val_out = mdio_read(mii_addr, data->phy_id, data->reg_num & 0x1f);
 	return 0;
     case SIOCSMIIREG:		/* Write MII PHY register. */
-	mdio_write(mii_addr, data[0], data[1] & 0x1f, data[2]);
+	mdio_write(mii_addr, data->phy_id, data->reg_num & 0x1f, data->val_in);
 	return 0;
     }
     return -EOPNOTSUPP;
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index 9709dd1..cf84231 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -80,6 +80,7 @@
 #include <linux/if_arp.h>
 #include <linux/ioport.h>
 #include <linux/bitops.h>
+#include <linux/mii.h>
 
 #include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
@@ -1558,24 +1559,26 @@ do_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
     local_info_t *local = netdev_priv(dev);
     unsigned int ioaddr = dev->base_addr;
-    u16 *data = (u16 *)&rq->ifr_ifru;
+    struct mii_ioctl_data *data = if_mii(rq);
 
     DEBUG(1, "%s: ioctl(%-.6s, %#04x) %04x %04x %04x %04x\n",
 	  dev->name, rq->ifr_ifrn.ifrn_name, cmd,
-	  data[0], data[1], data[2], data[3]);
+	  data->phy_id, data->reg_num, data->val_in, data->val_out);
 
     if (!local->mohawk)
 	return -EOPNOTSUPP;
 
     switch(cmd) {
       case SIOCGMIIPHY:		/* Get the address of the PHY in use. */
-	data[0] = 0;		/* we have only this address */
+	data->phy_id = 0;	/* we have only this address */
 	/* fall through */
       case SIOCGMIIREG:		/* Read the specified MII register. */
-	data[3] = mii_rd(ioaddr, data[0] & 0x1f, data[1] & 0x1f);
+	data->val_out = mii_rd(ioaddr, data->phy_id & 0x1f,
+			       data->reg_num & 0x1f);
 	break;
       case SIOCSMIIREG:		/* Write the specified MII register */
-	mii_wr(ioaddr, data[0] & 0x1f, data[1] & 0x1f, data[2], 16);
+	mii_wr(ioaddr, data->phy_id & 0x1f, data->reg_num & 0x1f, data->val_in,
+	       16);
 	break;
       default:
 	return -EOPNOTSUPP;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

