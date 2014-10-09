From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net-next v2 2/3] r8152: adjust usb_autopm_xxx
Date: Thu, 9 Oct 2014 18:00:25 +0800
Message-ID: <1394712342-15778-62-Taiwan-albertk@realtek.com>
References: <1394712342-15778-58-Taiwan-albertk@realtek.com>
 <1394712342-15778-60-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394712342-15778-60-Taiwan-albertk-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add usb_autopm_xxx for rtl8152_get_settings() ,and remove
usb_autopm_xxx from read_mii_word() and write_mii_word().

Signed-off-by: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/usb/r8152.c | 24 +++++++++++-------------
 1 file changed, 11 insertions(+), 13 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index c5afe8c..1d2fc8e 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -942,15 +942,8 @@ static int read_mii_word(struct net_device *netdev, int phy_id, int reg)
 	if (phy_id != R8152_PHY_ID)
 		return -EINVAL;
 
-	ret = usb_autopm_get_interface(tp->intf);
-	if (ret < 0)
-		goto out;
-
 	ret = r8152_mdio_read(tp, reg);
 
-	usb_autopm_put_interface(tp->intf);
-
-out:
 	return ret;
 }
 
@@ -965,12 +958,7 @@ void write_mii_word(struct net_device *netdev, int phy_id, int reg, int val)
 	if (phy_id != R8152_PHY_ID)
 		return;
 
-	if (usb_autopm_get_interface(tp->intf) < 0)
-		return;
-
 	r8152_mdio_write(tp, reg, val);
-
-	usb_autopm_put_interface(tp->intf);
 }
 
 static int
@@ -3290,11 +3278,21 @@ static
 int rtl8152_get_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
 {
 	struct r8152 *tp = netdev_priv(netdev);
+	int ret;
 
 	if (!tp->mii.mdio_read)
 		return -EOPNOTSUPP;
 
-	return mii_ethtool_gset(&tp->mii, cmd);
+	ret = usb_autopm_get_interface(tp->intf);
+	if (ret < 0)
+		goto out;
+
+	ret = mii_ethtool_gset(&tp->mii, cmd);
+
+	usb_autopm_put_interface(tp->intf);
+
+out:
+	return ret;
 }
 
 static int rtl8152_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-- 
1.9.3

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
