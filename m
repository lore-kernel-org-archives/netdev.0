From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 2/3] r8152: change rx early size when the mtu is changed
Date: Wed, 11 Feb 2015 14:46:58 +0800
Message-ID: <1394712342-15778-139-Taiwan-albertk@realtek.com>
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

The rx early size is calculated with the mtu, so it has to be
re-calculated when the mtu is changed.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index b043c7f..c5301ca 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -3724,6 +3724,7 @@ out:
 static int rtl8152_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct r8152 *tp = netdev_priv(dev);
+	int ret;
 
 	switch (tp->version) {
 	case RTL_VER_01:
@@ -3736,9 +3737,22 @@ static int rtl8152_change_mtu(struct net_device *dev, int new_mtu)
 	if (new_mtu < 68 || new_mtu > RTL8153_MAX_MTU)
 		return -EINVAL;
 
+	ret = usb_autopm_get_interface(tp->intf);
+	if (ret < 0)
+		return ret;
+
+	mutex_lock(&tp->control);
+
 	dev->mtu = new_mtu;
 
-	return 0;
+	if (netif_running(dev) && netif_carrier_ok(dev))
+		r8153_set_rx_early_size(tp);
+
+	mutex_unlock(&tp->control);
+
+	usb_autopm_put_interface(tp->intf);
+
+	return ret;
 }
 
 static const struct net_device_ops rtl8152_netdev_ops = {
-- 
2.1.0
