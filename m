From: Martin Pitt <martin.pitt-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] mac80211_hwsim: Register and bind to driver
Date: Mon, 8 Apr 2013 11:06:33 +0200
Message-ID: <20130408090633.GB2818@piware.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Properly register our mac80211_hwsim_driver, attach it to the platform bus.
Bind newly created hwsim devices to that driver, so that our wlan devices get
a proper "driver" sysfs attribute.

This makes mac80211_hwsim interfaces work with NetworkManager.

Signed-off-by: Martin Pitt <martin.pitt-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
---
 drivers/net/wireless/mac80211_hwsim.c |   17 ++++++++++++++++-
 1 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index 0064d38..50a8b52 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -25,6 +25,7 @@
 #include <linux/if_arp.h>
 #include <linux/rtnetlink.h>
 #include <linux/etherdevice.h>
+#include <linux/platform_device.h>
 #include <linux/debugfs.h>
 #include <linux/module.h>
 #include <linux/ktime.h>
@@ -1675,6 +1676,7 @@ static void mac80211_hwsim_free(void)
 		debugfs_remove(data->debugfs_ps);
 		debugfs_remove(data->debugfs);
 		ieee80211_unregister_hw(data->hw);
+		device_release_driver(data->dev);
 		device_unregister(data->dev);
 		ieee80211_free_hw(data->hw);
 	}
@@ -1683,7 +1685,9 @@ static void mac80211_hwsim_free(void)
 
 
 static struct device_driver mac80211_hwsim_driver = {
-	.name = "mac80211_hwsim"
+	.name = "mac80211_hwsim",
+	.bus = &platform_bus_type,
+	.owner = THIS_MODULE,
 };
 
 static const struct net_device_ops hwsim_netdev_ops = {
@@ -2179,6 +2183,8 @@ static int __init init_mac80211_hwsim(void)
 	if (IS_ERR(hwsim_class))
 		return PTR_ERR(hwsim_class);
 
+	driver_register(&mac80211_hwsim_driver);
+
 	memset(addr, 0, ETH_ALEN);
 	addr[0] = 0x02;
 
@@ -2205,6 +2211,14 @@ static int __init init_mac80211_hwsim(void)
 			goto failed_drvdata;
 		}
 		data->dev->driver = &mac80211_hwsim_driver;
+		err = device_bind_driver(data->dev);
+		if (err != 0) {
+			printk(KERN_DEBUG
+			       "mac80211_hwsim: device_bind_driver "
+			       "failed (%d)\n", err);
+			goto failed_hw;
+		}
+
 		skb_queue_head_init(&data->pending);
 
 		SET_IEEE80211_DEV(hw, data->dev);
@@ -2518,5 +2532,6 @@ static void __exit exit_mac80211_hwsim(void)
 
 	mac80211_hwsim_free();
 	unregister_netdev(hwsim_mon);
+	driver_unregister(&mac80211_hwsim_driver);
 }
 module_exit(exit_mac80211_hwsim);
-- 
1.7.2.5

-- 
Martin Pitt                        | http://www.piware.de
Ubuntu Developer (www.ubuntu.com)  | Debian Developer  (www.debian.org)
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
