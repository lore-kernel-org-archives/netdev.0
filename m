From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 3/3] r8152: support setting rx coalesce
Date: Wed, 11 Feb 2015 14:46:59 +0800
Message-ID: <1394712342-15778-140-Taiwan-albertk@realtek.com>
References: <1394712342-15778-137-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-137-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Support setting the rx coalesce. Then someone could change the rx
agg timeout value through ethtool.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 57 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 57 insertions(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index c5301ca..e4e7238 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -3660,6 +3660,61 @@ out:
 	return ret;
 }
 
+static int rtl8152_get_coalesce(struct net_device *netdev,
+				struct ethtool_coalesce *coalesce)
+{
+	struct r8152 *tp = netdev_priv(netdev);
+
+	switch (tp->version) {
+	case RTL_VER_01:
+	case RTL_VER_02:
+		return -EOPNOTSUPP;
+	default:
+		break;
+	}
+
+	coalesce->rx_coalesce_usecs = tp->coalesce;
+
+	return 0;
+}
+
+static int rtl8152_set_coalesce(struct net_device *netdev,
+				struct ethtool_coalesce *coalesce)
+{
+	struct r8152 *tp = netdev_priv(netdev);
+	int ret;
+
+	switch (tp->version) {
+	case RTL_VER_01:
+	case RTL_VER_02:
+		return -EOPNOTSUPP;
+	default:
+		break;
+	}
+
+	if (coalesce->rx_coalesce_usecs > COALESCE_SLOW)
+		return -EINVAL;
+
+	ret = usb_autopm_get_interface(tp->intf);
+	if (ret < 0)
+		return ret;
+
+	mutex_lock(&tp->control);
+
+	if (tp->coalesce != coalesce->rx_coalesce_usecs) {
+		tp->coalesce = coalesce->rx_coalesce_usecs;
+
+		if (netif_running(tp->netdev) && netif_carrier_ok(netdev))
+			r8153_set_rx_early_timeout(tp);
+	}
+
+	mutex_unlock(&tp->control);
+
+	usb_autopm_put_interface(tp->intf);
+
+	return ret;
+}
+
 static struct ethtool_ops ops = {
 	.get_drvinfo = rtl8152_get_drvinfo,
 	.get_settings = rtl8152_get_settings,
@@ -3673,6 +3728,8 @@ static struct ethtool_ops ops = {
 	.get_strings = rtl8152_get_strings,
 	.get_sset_count = rtl8152_get_sset_count,
 	.get_ethtool_stats = rtl8152_get_ethtool_stats,
+	.get_coalesce = rtl8152_get_coalesce,
+	.set_coalesce = rtl8152_set_coalesce,
 	.get_eee = rtl_ethtool_get_eee,
 	.set_eee = rtl_ethtool_set_eee,
 };
-- 
2.1.0
