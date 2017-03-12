From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: usb: r8152: use new api ethtool_{get|set}_link_ksettings
Date: Sun, 12 Mar 2017 22:41:58 +0100
Message-ID: <1489354918-6650-1-git-send-email-tremyfr@gmail.com>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, hayeswang@realtek.com, jarod@redhat.com,
        mario_limonciello@dell.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/usb/r8152.c |   21 ++++++++++++---------
 1 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 986243c..227e1fd 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -3800,7 +3800,8 @@ static void rtl8152_get_drvinfo(struct net_device *netdev,
 }
 
 static
-int rtl8152_get_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
+int rtl8152_get_link_ksettings(struct net_device *netdev,
+			       struct ethtool_link_ksettings *cmd)
 {
 	struct r8152 *tp = netdev_priv(netdev);
 	int ret;
@@ -3814,7 +3815,7 @@ int rtl8152_get_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
 
 	mutex_lock(&tp->control);
 
-	ret = mii_ethtool_gset(&tp->mii, cmd);
+	ret = mii_ethtool_get_link_ksettings(&tp->mii, cmd);
 
 	mutex_unlock(&tp->control);
 
@@ -3824,7 +3825,8 @@ int rtl8152_get_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
 	return ret;
 }
 
-static int rtl8152_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int rtl8152_set_link_ksettings(struct net_device *dev,
+				      const struct ethtool_link_ksettings *cmd)
 {
 	struct r8152 *tp = netdev_priv(dev);
 	int ret;
@@ -3835,11 +3837,12 @@ static int rtl8152_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 	mutex_lock(&tp->control);
 
-	ret = rtl8152_set_speed(tp, cmd->autoneg, cmd->speed, cmd->duplex);
+	ret = rtl8152_set_speed(tp, cmd->base.autoneg, cmd->base.speed,
+				cmd->base.duplex);
 	if (!ret) {
-		tp->autoneg = cmd->autoneg;
-		tp->speed = cmd->speed;
-		tp->duplex = cmd->duplex;
+		tp->autoneg = cmd->base.autoneg;
+		tp->speed = cmd->base.speed;
+		tp->duplex = cmd->base.duplex;
 	}
 
 	mutex_unlock(&tp->control);
@@ -4117,8 +4120,6 @@ static int rtl8152_set_coalesce(struct net_device *netdev,
 
 static const struct ethtool_ops ops = {
 	.get_drvinfo = rtl8152_get_drvinfo,
-	.get_settings = rtl8152_get_settings,
-	.set_settings = rtl8152_set_settings,
 	.get_link = ethtool_op_get_link,
 	.nway_reset = rtl8152_nway_reset,
 	.get_msglevel = rtl8152_get_msglevel,
@@ -4132,6 +4133,8 @@ static int rtl8152_set_coalesce(struct net_device *netdev,
 	.set_coalesce = rtl8152_set_coalesce,
 	.get_eee = rtl_ethtool_get_eee,
 	.set_eee = rtl_ethtool_set_eee,
+	.get_link_ksettings = rtl8152_get_link_ksettings,
+	.set_link_ksettings = rtl8152_set_link_ksettings,
 };
 
 static int rtl8152_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
-- 
1.7.4.4
