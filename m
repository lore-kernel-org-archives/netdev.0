From: Philippe Reynes <tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] net: usb: rtl8150: use new api ethtool_{get|set}_link_ksettings
Date: Sun, 12 Mar 2017 23:16:25 +0100
Message-ID: <1489356985-24117-1-git-send-email-tremyfr@gmail.com>
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Philippe Reynes <tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: petkan-nPnTwAqkgEqakBO8gow8eQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/usb/rtl8150.c |   35 ++++++++++++++++++++---------------
 1 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index c81c791..daaa88a 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -791,47 +791,52 @@ static void rtl8150_get_drvinfo(struct net_device *netdev, struct ethtool_drvinf
 	usb_make_path(dev->udev, info->bus_info, sizeof(info->bus_info));
 }
 
-static int rtl8150_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
+static int rtl8150_get_link_ksettings(struct net_device *netdev,
+				      struct ethtool_link_ksettings *ecmd)
 {
 	rtl8150_t *dev = netdev_priv(netdev);
 	short lpa, bmcr;
+	u32 supported;
 
-	ecmd->supported = (SUPPORTED_10baseT_Half |
+	supported = (SUPPORTED_10baseT_Half |
 			  SUPPORTED_10baseT_Full |
 			  SUPPORTED_100baseT_Half |
 			  SUPPORTED_100baseT_Full |
 			  SUPPORTED_Autoneg |
 			  SUPPORTED_TP | SUPPORTED_MII);
-	ecmd->port = PORT_TP;
-	ecmd->transceiver = XCVR_INTERNAL;
-	ecmd->phy_address = dev->phy;
+	ecmd->base.port = PORT_TP;
+	ecmd->base.phy_address = dev->phy;
 	get_registers(dev, BMCR, 2, &bmcr);
 	get_registers(dev, ANLP, 2, &lpa);
 	if (bmcr & BMCR_ANENABLE) {
 		u32 speed = ((lpa & (LPA_100HALF | LPA_100FULL)) ?
 			     SPEED_100 : SPEED_10);
-		ethtool_cmd_speed_set(ecmd, speed);
-		ecmd->autoneg = AUTONEG_ENABLE;
+		ecmd->base.speed = speed;
+		ecmd->base.autoneg = AUTONEG_ENABLE;
 		if (speed == SPEED_100)
-			ecmd->duplex = (lpa & LPA_100FULL) ?
+			ecmd->base.duplex = (lpa & LPA_100FULL) ?
 			    DUPLEX_FULL : DUPLEX_HALF;
 		else
-			ecmd->duplex = (lpa & LPA_10FULL) ?
+			ecmd->base.duplex = (lpa & LPA_10FULL) ?
 			    DUPLEX_FULL : DUPLEX_HALF;
 	} else {
-		ecmd->autoneg = AUTONEG_DISABLE;
-		ethtool_cmd_speed_set(ecmd, ((bmcr & BMCR_SPEED100) ?
-					     SPEED_100 : SPEED_10));
-		ecmd->duplex = (bmcr & BMCR_FULLDPLX) ?
+		ecmd->base.autoneg = AUTONEG_DISABLE;
+		ecmd->base.speed = ((bmcr & BMCR_SPEED100) ?
+					     SPEED_100 : SPEED_10);
+		ecmd->base.duplex = (bmcr & BMCR_FULLDPLX) ?
 		    DUPLEX_FULL : DUPLEX_HALF;
 	}
+
+	ethtool_convert_legacy_u32_to_link_mode(ecmd->link_modes.supported,
+						supported);
+
 	return 0;
 }
 
 static const struct ethtool_ops ops = {
 	.get_drvinfo = rtl8150_get_drvinfo,
-	.get_settings = rtl8150_get_settings,
-	.get_link = ethtool_op_get_link
+	.get_link = ethtool_op_get_link,
+	.get_link_ksettings = rtl8150_get_link_ksettings,
 };
 
 static int rtl8150_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
-- 
1.7.4.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
