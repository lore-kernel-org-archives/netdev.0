From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH] usbnet: pegasus: set wakeup enable in set_wol
Date: Sat, 19 Jan 2013 19:32:01 +0800
Message-ID: <1358595121-14373-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Petko Manolov <petkan-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch calls device_set_wakeup_enable() inside set_wol
callback, so that turning on WOL from user mode utility
can make the 'wakeup' of pegasus device to be enabled, then
remote wakeup may be enabled before putting into sleep.

Cc: Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Cc: Petko Manolov <petkan-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/net/usb/pegasus.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index a0b5807..44f46fd 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -1096,6 +1096,7 @@ pegasus_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	pegasus_t	*pegasus = netdev_priv(dev);
 	u8		reg78 = 0x04;
+	int		ret;
 
 	if (wol->wolopts & ~WOL_SUPPORTED)
 		return -EINVAL;
@@ -1110,7 +1111,12 @@ pegasus_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	else
 		pegasus->eth_regs[0] &= ~0x10;
 	pegasus->wolopts = wol->wolopts;
-	return set_register(pegasus, WakeupControl, reg78);
+
+	ret = set_register(pegasus, WakeupControl, reg78);
+	if (!ret)
+		ret = device_set_wakeup_enable(&pegasus->usb->dev,
+						wol->wolopts);
+	return ret;
 }
 
 static inline void pegasus_reset_wol(struct net_device *dev)
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
