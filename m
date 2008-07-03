From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 32/39]: mac80211: Reimplement WME using
	->select_queue().
Date: Thu, 03 Jul 2008 14:02:29 +0200
Message-ID: <1215086549.9975.4.camel@johannes.berg>
References: <20080703.000521.13130101.davem@davemloft.net>
	 (sfid-20080703_103230_813110_7C480890)  <1215080583.13270.38.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vinay-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, Matheos.Worku-UdXhSnd/wVw@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ron Rindjunsky <rindjon-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1215080583.13270.38.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2008-07-03 at 12:23 +0200, Johannes Berg wrote:
> Here's a little cleanup patch. My kernel is still compiling so I have=
n't
> tested it yet though.

This is a fixed version of the patch, but mac80211 still hangs and I
haven't been able to figure out why yet. iwlwifi scans fine, but since
that is hardware-assisted scanning we don't actually send packets, so i=
t
looks like it hangs as soon as the first packet is sent out...

johannes


=EF=BB=BFmac8021: Clean up after multiqueue rework

This cleans up mac80211 and removes a lot of now useless things. Also
removes netif_is_multiqueue().

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
---
 include/linux/netdevice.h  |   11 -----------
 include/net/mac80211.h     |    8 --------
 net/mac80211/Kconfig       |   10 ----------
 net/mac80211/Makefile      |    4 ++--
 net/mac80211/ieee80211_i.h |    9 ---------
 net/mac80211/main.c        |    9 ++-------
 net/mac80211/util.c        |   14 ++------------
 net/mac80211/wme.c         |   14 +-------------
 net/mac80211/wme.h         |   22 +---------------------
 9 files changed, 8 insertions(+), 93 deletions(-)

--- everything.orig/net/mac80211/ieee80211_i.h	2008-07-03 11:43:40.0000=
00000 +0200
+++ everything/net/mac80211/ieee80211_i.h	2008-07-03 11:50:28.000000000=
 +0200
@@ -757,15 +757,6 @@ struct ieee80211_local {
 #endif
 };
=20
-static inline int ieee80211_is_multiqueue(struct ieee80211_local *loca=
l)
-{
-#ifdef CONFIG_MAC80211_QOS
-	return netif_is_multiqueue(local->mdev);
-#else
-	return 0;
-#endif
-}
-
 /* this struct represents 802.11n's RA/TID combination */
 struct ieee80211_ra_tid {
 	u8 ra[ETH_ALEN];
--- everything.orig/net/mac80211/util.c	2008-07-03 11:43:53.000000000 +=
0200
+++ everything/net/mac80211/util.c	2008-07-03 11:51:02.000000000 +0200
@@ -363,12 +363,7 @@ void ieee80211_wake_queue(struct ieee802
 	if (test_bit(queue, local->queues_pending)) {
 		tasklet_schedule(&local->tx_pending_tasklet);
 	} else {
-		if (ieee80211_is_multiqueue(local)) {
-			netif_wake_subqueue(local->mdev, queue);
-		} else {
-			WARN_ON(queue !=3D 0);
-			netif_wake_queue(local->mdev);
-		}
+		netif_wake_subqueue(local->mdev, queue);
 	}
 }
 EXPORT_SYMBOL(ieee80211_wake_queue);
@@ -377,12 +372,7 @@ void ieee80211_stop_queue(struct ieee802
 {
 	struct ieee80211_local *local =3D hw_to_local(hw);
=20
-	if (ieee80211_is_multiqueue(local)) {
-		netif_stop_subqueue(local->mdev, queue);
-	} else {
-		WARN_ON(queue !=3D 0);
-		netif_stop_queue(local->mdev);
-	}
+	netif_stop_subqueue(local->mdev, queue);
 }
 EXPORT_SYMBOL(ieee80211_stop_queue);
=20
--- everything.orig/net/mac80211/wme.c	2008-07-03 11:43:19.000000000 +0=
200
+++ everything/net/mac80211/wme.c	2008-07-03 11:54:48.000000000 +0200
@@ -115,8 +115,7 @@ static u16 classify80211(struct sk_buff=20
 }
=20
=20
-static u16 ieee80211_select_queue(struct net_device *dev,
-				  struct sk_buff *skb)
+u16 ieee80211_select_queue(struct net_device *dev, struct sk_buff *skb=
)
 {
 	struct ieee80211_hdr *hdr =3D (struct ieee80211_hdr *) skb->data;
 	struct ieee80211_local *local =3D wdev_priv(dev->ieee80211_ptr);
@@ -157,17 +156,6 @@ static u16 ieee80211_select_queue(struct
 	return queue;
 }
=20
-void ieee80211_install_qdisc(struct net_device *dev)
-{
-	dev->select_queue =3D ieee80211_select_queue;
-}
-
-
-int ieee80211_qdisc_installed(struct net_device *dev)
-{
-	return dev->select_queue =3D=3D ieee80211_select_queue;
-}
-
 int ieee80211_ht_agg_queue_add(struct ieee80211_local *local,
 			struct sta_info *sta, u16 tid)
 {
--- everything.orig/net/mac80211/wme.h	2008-07-03 11:43:09.000000000 +0=
200
+++ everything/net/mac80211/wme.h	2008-07-03 12:02:29.000000000 +0200
@@ -31,30 +31,10 @@ static inline int WLAN_FC_IS_QOS_DATA(u1
 	return (fc & 0x8C) =3D=3D 0x88;
 }
=20
-#ifdef CONFIG_MAC80211_QOS
-void ieee80211_install_qdisc(struct net_device *dev);
-int ieee80211_qdisc_installed(struct net_device *dev);
 int ieee80211_ht_agg_queue_add(struct ieee80211_local *local,
 			       struct sta_info *sta, u16 tid);
 void ieee80211_ht_agg_queue_remove(struct ieee80211_local *local,
 				   struct sta_info *sta, u16 tid);
-#else
-static inline void ieee80211_install_qdisc(struct net_device *dev)
-{
-}
-static inline int ieee80211_qdisc_installed(struct net_device *dev)
-{
-	return 0;
-}
-static inline int ieee80211_ht_agg_queue_add(struct ieee80211_local *l=
ocal,
-					     struct sta_info *sta, u16 tid)
-{
-	return -EAGAIN;
-}
-static inline void ieee80211_ht_agg_queue_remove(struct ieee80211_loca=
l *local,
-						 struct sta_info *sta, u16 tid)
-{
-}
-#endif /* CONFIG_NET_SCHED */
+u16 ieee80211_select_queue(struct net_device *dev, struct sk_buff *skb=
);
=20
 #endif /* _WME_H */
--- everything.orig/include/linux/netdevice.h	2008-07-03 11:51:50.00000=
0000 +0200
+++ everything/include/linux/netdevice.h	2008-07-03 11:51:56.000000000 =
+0200
@@ -1175,17 +1175,6 @@ static inline void netif_wake_subqueue(s
 		__netif_schedule(txq);
 }
=20
-/**
- *	netif_is_multiqueue - test if device has multiple transmit queues
- *	@dev: network device
- *
- * Check if device has multiple transmit queues
- */
-static inline int netif_is_multiqueue(const struct net_device *dev)
-{
-	return (dev->num_tx_queues > 1);
-}
-
 /* Use this variant when it is known for sure that it
  * is executing from hardware interrupt context or with hardware inter=
rupts
  * disabled.
--- everything.orig/net/mac80211/Kconfig	2008-07-03 11:43:31.000000000 =
+0200
+++ everything/net/mac80211/Kconfig	2008-07-03 11:52:57.000000000 +0200
@@ -11,16 +11,6 @@ config MAC80211
 	  This option enables the hardware independent IEEE 802.11
 	  networking stack.
=20
-config MAC80211_QOS
-	def_bool y
-	depends on MAC80211
-	depends on NET_SCHED
-
-comment "QoS/HT support disabled"
-	depends on MAC80211 && !MAC80211_QOS
-comment "QoS/HT support needs CONFIG_NET_SCHED"
-	depends on MAC80211 && !NET_SCHED
-
 menu "Rate control algorithm selection"
 	depends on MAC80211 !=3D n
=20
--- everything.orig/net/mac80211/Makefile	2008-07-03 11:52:42.000000000=
 +0200
+++ everything/net/mac80211/Makefile	2008-07-03 11:52:51.000000000 +020=
0
@@ -26,10 +26,10 @@ mac80211-y :=3D \
 	tx.o \
 	key.o \
 	util.o \
-	event.o
+	event.o \
+	wme.o
=20
 mac80211-$(CONFIG_MAC80211_LEDS) +=3D led.o
-mac80211-$(CONFIG_MAC80211_QOS) +=3D wme.o
 mac80211-$(CONFIG_MAC80211_DEBUGFS) +=3D \
 	debugfs.o \
 	debugfs_sta.o \
--- everything.orig/net/mac80211/main.c	2008-07-03 11:52:13.000000000 +=
0200
+++ everything/net/mac80211/main.c	2008-07-03 11:56:51.000000000 +0200
@@ -114,7 +114,7 @@ static int ieee80211_master_open(struct=20
 	if (res)
 		return res;
=20
-	netif_start_queue(local->mdev);
+	netif_tx_start_all_queues(local->mdev);
=20
 	return 0;
 }
@@ -1667,17 +1667,12 @@ int ieee80211_register_hw(struct ieee802
 	 * We use the number of queues for feature tests (QoS, HT) internally
 	 * so restrict them appropriately.
 	 */
-#ifdef CONFIG_MAC80211_QOS
 	if (hw->queues > IEEE80211_MAX_QUEUES)
 		hw->queues =3D IEEE80211_MAX_QUEUES;
 	if (hw->ampdu_queues > IEEE80211_MAX_AMPDU_QUEUES)
 		hw->ampdu_queues =3D IEEE80211_MAX_AMPDU_QUEUES;
 	if (hw->queues < 4)
 		hw->ampdu_queues =3D 0;
-#else
-	hw->queues =3D 1;
-	hw->ampdu_queues =3D 0;
-#endif
=20
 	/* for now, mdev needs sub_if_data :/ */
 	mdev =3D alloc_netdev_mq(sizeof(struct ieee80211_sub_if_data),
@@ -1775,7 +1770,7 @@ int ieee80211_register_hw(struct ieee802
 		goto fail_wep;
 	}
=20
-	ieee80211_install_qdisc(local->mdev);
+	local->mdev->select_queue =3D ieee80211_select_queue;
=20
 	/* add one default STA interface */
 	result =3D ieee80211_if_add(local->mdev, "wlan%d", NULL,
--- everything.orig/include/net/mac80211.h	2008-07-03 13:39:28.00000000=
0 +0200
+++ everything/include/net/mac80211.h	2008-07-03 13:39:44.000000000 +02=
00
@@ -812,20 +812,12 @@ static inline void SET_IEEE80211_PERM_AD
=20
 static inline int ieee80211_num_regular_queues(struct ieee80211_hw *hw=
)
 {
-#ifdef CONFIG_MAC80211_QOS
 	return hw->queues;
-#else
-	return 1;
-#endif
 }
=20
 static inline int ieee80211_num_queues(struct ieee80211_hw *hw)
 {
-#ifdef CONFIG_MAC80211_QOS
 	return hw->queues + hw->ampdu_queues;
-#else
-	return 1;
-#endif
 }
=20
 static inline struct ieee80211_rate *


--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
