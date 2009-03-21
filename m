From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 72/77] ipw2x00: convert infrastructure for use by net_device_ops
Date: Fri, 20 Mar 2009 22:36:39 -0700
Message-ID: <20090321053718.065171867@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, jkosina-AlSwsSmVLrQ@public.gmane.org,
	dstreba-AlSwsSmVLrQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=ipw-netdev.patch
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Expose routines so drivers can hook. Only set ptrs in netdev
if using old compat code.

Signed-off-by: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>

---
 drivers/net/wireless/ipw2x00/ieee80211.h     |    1 +
 drivers/net/wireless/ipw2x00/libipw_module.c |    5 ++++-
 drivers/net/wireless/ipw2x00/libipw_tx.c     |    1 +
 3 files changed, 6 insertions(+), 1 deletion(-)

--- a/drivers/net/wireless/ipw2x00/libipw_module.c	2009-03-20 21:39:32.901088992 -0700
+++ b/drivers/net/wireless/ipw2x00/libipw_module.c	2009-03-20 21:39:34.508964994 -0700
@@ -131,13 +131,14 @@ static void ieee80211_networks_initializ
 			      &ieee->network_free_list);
 }
 
-static int ieee80211_change_mtu(struct net_device *dev, int new_mtu)
+int ieee80211_change_mtu(struct net_device *dev, int new_mtu)
 {
 	if ((new_mtu < 68) || (new_mtu > IEEE80211_DATA_LEN))
 		return -EINVAL;
 	dev->mtu = new_mtu;
 	return 0;
 }
+EXPORT_SYMBOL(ieee80211_change_mtu);
 
 struct net_device *alloc_ieee80211(int sizeof_priv)
 {
@@ -153,8 +154,10 @@ struct net_device *alloc_ieee80211(int s
 		goto failed;
 	}
 	ieee = netdev_priv(dev);
+#ifdef CONFIG_COMPAT_NET_DEV_OPS
 	dev->hard_start_xmit = ieee80211_xmit;
 	dev->change_mtu = ieee80211_change_mtu;
+#endif
 
 	ieee->dev = dev;
 
--- a/drivers/net/wireless/ipw2x00/ieee80211.h	2009-03-20 21:39:32.900089558 -0700
+++ b/drivers/net/wireless/ipw2x00/ieee80211.h	2009-03-20 21:39:34.509964918 -0700
@@ -1016,6 +1016,7 @@ static inline int ieee80211_is_cck_rate(
 /* ieee80211.c */
 extern void free_ieee80211(struct net_device *dev);
 extern struct net_device *alloc_ieee80211(int sizeof_priv);
+extern int ieee80211_change_mtu(struct net_device *dev, int new_mtu);
 
 extern void ieee80211_networks_age(struct ieee80211_device *ieee,
 				   unsigned long age_secs);
--- a/drivers/net/wireless/ipw2x00/libipw_tx.c	2009-03-20 21:39:59.063966304 -0700
+++ b/drivers/net/wireless/ipw2x00/libipw_tx.c	2009-03-20 21:40:37.667839502 -0700
@@ -541,5 +541,6 @@ int ieee80211_xmit(struct sk_buff *skb, 
 	dev->stats.tx_errors++;
 	return 1;
 }
+EXPORT_SYMBOL(ieee80211_xmit);
 
 EXPORT_SYMBOL(ieee80211_txb_free);

-- 

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
