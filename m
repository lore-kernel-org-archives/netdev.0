From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: usb: catc: use new api ethtool_{get|set}_link_ksettings
Date: Sun, 12 Mar 2017 22:08:26 +0100
Message-ID: <1489352906-13829-1-git-send-email-tremyfr@gmail.com>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, ben@decadent.org.uk, mugunthanvnm@ti.com,
        a@unstable.cc, fw@strlen.de, jarod@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/usb/catc.c |   31 ++++++++++++++++++-------------
 1 files changed, 18 insertions(+), 13 deletions(-)

diff --git a/drivers/net/usb/catc.c b/drivers/net/usb/catc.c
index 0acc9b64..fce92f0 100644
--- a/drivers/net/usb/catc.c
+++ b/drivers/net/usb/catc.c
@@ -688,29 +688,34 @@ static void catc_get_drvinfo(struct net_device *dev,
 	usb_make_path(catc->usbdev, info->bus_info, sizeof(info->bus_info));
 }
 
-static int catc_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int catc_get_link_ksettings(struct net_device *dev,
+				   struct ethtool_link_ksettings *cmd)
 {
 	struct catc *catc = netdev_priv(dev);
 	if (!catc->is_f5u011)
 		return -EOPNOTSUPP;
 
-	cmd->supported = SUPPORTED_10baseT_Half | SUPPORTED_TP;
-	cmd->advertising = ADVERTISED_10baseT_Half | ADVERTISED_TP;
-	ethtool_cmd_speed_set(cmd, SPEED_10);
-	cmd->duplex = DUPLEX_HALF;
-	cmd->port = PORT_TP; 
-	cmd->phy_address = 0;
-	cmd->transceiver = XCVR_INTERNAL;
-	cmd->autoneg = AUTONEG_DISABLE;
-	cmd->maxtxpkt = 1;
-	cmd->maxrxpkt = 1;
+	ethtool_link_ksettings_zero_link_mode(cmd, supported);
+	ethtool_link_ksettings_add_link_mode(cmd, supported, 10baseT_Half);
+	ethtool_link_ksettings_add_link_mode(cmd, supported, TP);
+
+	ethtool_link_ksettings_zero_link_mode(cmd, advertising);
+	ethtool_link_ksettings_add_link_mode(cmd, advertising, 10baseT_Half);
+	ethtool_link_ksettings_add_link_mode(cmd, advertising, TP);
+
+	cmd->base.speed = SPEED_10;
+	cmd->base.duplex = DUPLEX_HALF;
+	cmd->base.port = PORT_TP;
+	cmd->base.phy_address = 0;
+	cmd->base.autoneg = AUTONEG_DISABLE;
+
 	return 0;
 }
 
 static const struct ethtool_ops ops = {
 	.get_drvinfo = catc_get_drvinfo,
-	.get_settings = catc_get_settings,
-	.get_link = ethtool_op_get_link
+	.get_link = ethtool_op_get_link,
+	.get_link_ksettings = catc_get_link_ksettings,
 };
 
 /*
-- 
1.7.4.4
