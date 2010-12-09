From: Meelis Roos <mroos-Y27EyoLml9s@public.gmane.org>
Subject: [PATCH] fix hostap registration order
Date: Fri, 10 Dec 2010 01:19:23 +0200 (EET)
Message-ID: <alpine.SOC.1.00.1012100020110.26229@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jouni Malinen <j@w1.fi>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In 2.6.37-rc4, hostap_pci init gives a WARNING with backtrace telling 
that netif_stop_queue is called before register_netdev. Fix it by moving 
this call after register_netdev. Removes the warning and seems to work, 
but why is the call to netif_stop_queue needed at all after 
register_netdev?

Signed-off-by: Meelis Roos <mroos-Y27EyoLml9s@public.gmane.org>

diff --git a/drivers/net/wireless/hostap/hostap_hw.c b/drivers/net/wireless/hostap/hostap_hw.c
index b7cb165..cc760c5 100644
--- a/drivers/net/wireless/hostap/hostap_hw.c
+++ b/drivers/net/wireless/hostap/hostap_hw.c
@@ -3253,6 +3253,8 @@ while (0)
 	}
 	printk(KERN_INFO "%s: Registered netdevice %s\n", dev_info, dev->name);
 
+	netif_stop_queue(dev);
+
 	hostap_init_data(local);
 	return dev;
 
diff --git a/drivers/net/wireless/hostap/hostap_main.c b/drivers/net/wireless/hostap/hostap_main.c
index 25a2722..0f1b202 100644
--- a/drivers/net/wireless/hostap/hostap_main.c
+++ b/drivers/net/wireless/hostap/hostap_main.c
@@ -100,6 +100,7 @@ struct net_device * hostap_add_interface(struct local_info *local,
 	printk(KERN_DEBUG "%s: registered netdevice %s\n",
 	       mdev->name, dev->name);
 
+	netif_stop_queue(dev);
 	return dev;
 }
 
@@ -891,7 +892,6 @@ void hostap_setup_dev(struct net_device *dev, local_info_t *local,
 
 	SET_ETHTOOL_OPS(dev, &prism2_ethtool_ops);
 
-	netif_stop_queue(dev);
 }
 
 static int hostap_enable_hostapd(local_info_t *local, int rtnl_locked)
-- 
Meelis Roos (mroos-Y27EyoLml9s@public.gmane.org)
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
