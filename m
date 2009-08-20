From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 3/5] fakehard: add binding to wpan-phy
	device
Date: Thu, 20 Aug 2009 20:13:05 +0400
Message-ID: <1250784787-30590-4-git-send-email-dbaryshkov@gmail.com>
References: <1250784787-30590-1-git-send-email-dbaryshkov@gmail.com>
	<1250784787-30590-2-git-send-email-dbaryshkov@gmail.com>
	<1250784787-30590-3-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1250784787-30590-3-git-send-email-dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Make fakehard create and maintain wpan-phy node, thus representing
it's phy in the sysfs.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/ieee802154/fakehard.c |   52 ++++++++++++++++++++++++++++++++++++----
 1 files changed, 46 insertions(+), 6 deletions(-)

diff --git a/drivers/ieee802154/fakehard.c b/drivers/ieee802154/fakehard.c
index 262536f..22a93bc 100644
--- a/drivers/ieee802154/fakehard.c
+++ b/drivers/ieee802154/fakehard.c
@@ -30,6 +30,12 @@
 #include <net/ieee802154_netdev.h>
 #include <net/ieee802154.h>
 #include <net/nl802154.h>
+#include <net/wpan-phy.h>
+
+struct wpan_phy *net_to_phy(struct net_device *dev)
+{
+	return container_of(dev->dev.parent, struct wpan_phy, dev);
+}
 
 /**
  * fake_get_pan_id - Retrieve the PAN ID of the device.
@@ -115,6 +121,12 @@ static u8 fake_get_bsn(struct net_device *dev)
 static int fake_assoc_req(struct net_device *dev,
 		struct ieee802154_addr *addr, u8 channel, u8 cap)
 {
+	struct wpan_phy *phy = net_to_phy(dev);
+
+	mutex_lock(&phy->pib_lock);
+	phy->current_channel = channel;
+	mutex_unlock(&phy->pib_lock);
+
 	/* We simply emulate it here */
 	return ieee802154_nl_assoc_confirm(dev, fake_get_short_addr(dev),
 			IEEE802154_SUCCESS);
@@ -183,6 +195,12 @@ static int fake_start_req(struct net_device *dev, struct ieee802154_addr *addr,
 				u8 bcn_ord, u8 sf_ord, u8 pan_coord, u8 blx,
 				u8 coord_realign)
 {
+	struct wpan_phy *phy = net_to_phy(dev);
+
+	mutex_lock(&phy->pib_lock);
+	phy->current_channel = channel;
+	mutex_unlock(&phy->pib_lock);
+
 	/* We don't emulate beacons here at all, so START should fail */
 	ieee802154_nl_start_confirm(dev, IEEE802154_INVALID_PARAMETER);
 	return 0;
@@ -290,6 +308,14 @@ static const struct net_device_ops fake_ops = {
 	.ndo_set_mac_address	= ieee802154_fake_mac_addr,
 };
 
+static void ieee802154_fake_destruct(struct net_device *dev)
+{
+	struct wpan_phy *phy = net_to_phy(dev);
+
+	wpan_phy_unregister(phy);
+	free_netdev(dev);
+	wpan_phy_free(phy);
+}
 
 static void ieee802154_fake_setup(struct net_device *dev)
 {
@@ -302,22 +328,34 @@ static void ieee802154_fake_setup(struct net_device *dev)
 	dev->type		= ARPHRD_IEEE802154;
 	dev->flags		= IFF_NOARP | IFF_BROADCAST;
 	dev->watchdog_timeo	= 0;
+	dev->destructor		= ieee802154_fake_destruct;
 }
 
 
 static int __devinit ieee802154fake_probe(struct platform_device *pdev)
 {
-	struct net_device *dev =
-		alloc_netdev(0, "hardwpan%d", ieee802154_fake_setup);
+	struct net_device *dev;
+	struct wpan_phy *phy = wpan_phy_alloc(0);
 	int err;
 
-	if (!dev)
+	if (!phy)
+		return -ENOMEM;
+
+	dev = alloc_netdev(0, "hardwpan%d", ieee802154_fake_setup);
+	if (!dev) {
+		wpan_phy_free(phy);
 		return -ENOMEM;
+	}
+
+	phy->dev.platform_data = dev;
 
 	memcpy(dev->dev_addr, "\xba\xbe\xca\xfe\xde\xad\xbe\xef",
 			dev->addr_len);
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
+	phy->channels_supported = (1 << 27) - 1;
+	phy->transmit_power = 0xbf;
+
 	dev->netdev_ops = &fake_ops;
 	dev->ml_priv = &fake_mlme;
 
@@ -331,15 +369,18 @@ static int __devinit ieee802154fake_probe(struct platform_device *pdev)
 			goto out;
 	}
 
-	SET_NETDEV_DEV(dev, &pdev->dev);
+	SET_NETDEV_DEV(dev, &phy->dev);
 
 	platform_set_drvdata(pdev, dev);
 
+	err = wpan_phy_register(&pdev->dev, phy);
+	if (err)
+		goto out;
+
 	err = register_netdev(dev);
 	if (err < 0)
 		goto out;
 
-
 	dev_info(&pdev->dev, "Added ieee802154 HardMAC hardware\n");
 	return 0;
 
@@ -352,7 +393,6 @@ static int __devexit ieee802154fake_remove(struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
 	unregister_netdev(dev);
-	free_netdev(dev);
 	return 0;
 }
 
-- 
1.6.3.3


------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with 
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
