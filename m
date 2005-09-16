From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 4/5] orinoco: Add support for WE-16 and WE-17
Date: Fri, 16 Sep 2005 02:20:38 -0400
Message-ID: <1126851638.3056.11.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>,
	Orinoco Development List <orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Signed-off-by: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>

diff-tree 4f7da56f7d85502cc200a3264717f40f4bdb71e3 (from 73e242a82f9f4764e5381c1a5150909e17e01f94)
Author: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
Date:   Fri Sep 16 01:15:40 2005 -0400

    Add support for WE-16 and WE-17.
    
    Use simplified/unified iwspy support.  Add capability reporting via
    iwevent.  Move get_wireless_stats handler from netdev to iw_handler_def.

diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoco.c
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -133,11 +133,11 @@ MODULE_PARM_DESC(force_monitor, "Allow m
 /* Compile time configuration and compatibility stuff               */
 /********************************************************************/
 
 /* We do this this way to avoid ifdefs in the actual code */
 #ifdef WIRELESS_SPY
-#define SPY_NUMBER(priv)	(priv->spy_number)
+#define SPY_NUMBER(priv)	(priv->spy_data.spy_number)
 #else
 #define SPY_NUMBER(priv)	0
 #endif /* WIRELESS_SPY */
 
 /********************************************************************/
@@ -392,14 +392,14 @@ static struct iw_statistics *orinoco_get
 	if (priv->iw_mode == IW_MODE_ADHOC) {
 		memset(&wstats->qual, 0, sizeof(wstats->qual));
 		/* If a spy address is defined, we report stats of the
 		 * first spy address - Jean II */
 		if (SPY_NUMBER(priv)) {
-			wstats->qual.qual = priv->spy_stat[0].qual;
-			wstats->qual.level = priv->spy_stat[0].level;
-			wstats->qual.noise = priv->spy_stat[0].noise;
-			wstats->qual.updated = priv->spy_stat[0].updated;
+			wstats->qual.qual = priv->spy_data.spy_stat[0].qual;
+			wstats->qual.level = priv->spy_data.spy_stat[0].level;
+			wstats->qual.noise = priv->spy_data.spy_stat[0].noise;
+			wstats->qual.updated = priv->spy_data.spy_stat[0].updated;
 		}
 	} else {
 		struct {
 			u16 qual, signal, noise;
 		} __attribute__ ((packed)) cq;
@@ -714,22 +714,17 @@ static inline int is_ethersnap(void *_hd
 }
 
 static inline void orinoco_spy_gather(struct net_device *dev, u_char *mac,
 				      int level, int noise)
 {
-	struct orinoco_private *priv = netdev_priv(dev);
-	int i;
-
-	/* Gather wireless spy statistics: for each packet, compare the
-	 * source address with out list, and if match, get the stats... */
-	for (i = 0; i < priv->spy_number; i++)
-		if (!memcmp(mac, priv->spy_address[i], ETH_ALEN)) {
-			priv->spy_stat[i].level = level - 0x95;
-			priv->spy_stat[i].noise = noise - 0x95;
-			priv->spy_stat[i].qual = (level > noise) ? (level - noise) : 0;
-			priv->spy_stat[i].updated = 7;
-		}
+	struct iw_quality wstats;
+	wstats.level = level - 0x95;
+	wstats.noise = noise - 0x95;
+	wstats.qual = (level > noise) ? (level - noise) : 0;
+	wstats.updated = 7;
+	/* Update spy records */
+	wireless_spy_update(dev, mac, &wstats);
 }
 
 static void orinoco_stat_gather(struct net_device *dev,
 				struct sk_buff *skb,
 				struct hermes_rx_descriptor *desc)
@@ -2454,12 +2449,15 @@ struct net_device *alloc_orinocodev(int 
 	dev->hard_start_xmit = orinoco_xmit;
 	dev->tx_timeout = orinoco_tx_timeout;
 	dev->watchdog_timeo = HZ; /* 1 second timeout */
 	dev->get_stats = orinoco_get_stats;
 	dev->ethtool_ops = &orinoco_ethtool_ops;
-	dev->get_wireless_stats = orinoco_get_wireless_stats;
 	dev->wireless_handlers = (struct iw_handler_def *)&orinoco_handler_def;
+#ifdef WIRELESS_SPY
+	priv->wireless_data.spy_data = &priv->spy_data;
+	dev->wireless_data = &priv->wireless_data;
+#endif
 	dev->change_mtu = orinoco_change_mtu;
 	dev->set_multicast_list = orinoco_set_multicast_list;
 	/* we use the default eth_mac_addr for setting the MAC addr */
 
 	/* Set up default callbacks */
@@ -2827,11 +2825,11 @@ static int orinoco_ioctl_getiwrange(stru
 			range->encoding_size[1] = LARGE_KEY_SIZE;
 			range->num_encoding_sizes = 2;
 		}
 	}
 
-	if ((priv->iw_mode == IW_MODE_ADHOC) && (priv->spy_number == 0)){
+	if ((priv->iw_mode == IW_MODE_ADHOC) && (!SPY_NUMBER(priv))){
 		/* Quality stats meaningless in ad-hoc mode */
 	} else {
 		range->max_qual.qual = 0x8b - 0x2f;
 		range->max_qual.level = 0x2f - 0x95 - 1;
 		range->max_qual.noise = 0x2f - 0x95 - 1;
@@ -2874,10 +2872,18 @@ static int orinoco_ioctl_getiwrange(stru
 	range->min_retry = 0;
 	range->max_retry = 65535;	/* ??? */
 	range->min_r_time = 0;
 	range->max_r_time = 65535 * 1000;	/* ??? */
 
+	/* Event capability (kernel) */
+	IW_EVENT_CAPA_SET_KERNEL(range->event_capa);
+	/* Event capability (driver) */
+	IW_EVENT_CAPA_SET(range->event_capa, SIOCGIWTHRSPY);
+	IW_EVENT_CAPA_SET(range->event_capa, SIOCGIWAP);
+	IW_EVENT_CAPA_SET(range->event_capa, SIOCGIWSCAN);
+	IW_EVENT_CAPA_SET(range->event_capa, IWEVTXDROP);
+
 	TRACE_EXIT(dev->name);
 
 	return 0;
 }
 
@@ -3833,96 +3839,10 @@ static int orinoco_ioctl_getrid(struct n
  out:
 	orinoco_unlock(priv, &flags);
 	return err;
 }
 
-/* Spy is used for link quality/strength measurements in Ad-Hoc mode
- * Jean II */
-static int orinoco_ioctl_setspy(struct net_device *dev,
-				struct iw_request_info *info,
-				struct iw_point *srq,
-				char *extra)
-
-{
-	struct orinoco_private *priv = netdev_priv(dev);
-	struct sockaddr *address = (struct sockaddr *) extra;
-	int number = srq->length;
-	int i;
-	unsigned long flags;
-
-	/* Make sure nobody mess with the structure while we do */
-	if (orinoco_lock(priv, &flags) != 0)
-		return -EBUSY;
-
-	/* orinoco_lock() doesn't disable interrupts, so make sure the
-	 * interrupt rx path don't get confused while we copy */
-	priv->spy_number = 0;
-
-	if (number > 0) {
-		/* Extract the addresses */
-		for (i = 0; i < number; i++)
-			memcpy(priv->spy_address[i], address[i].sa_data,
-			       ETH_ALEN);
-		/* Reset stats */
-		memset(priv->spy_stat, 0,
-		       sizeof(struct iw_quality) * IW_MAX_SPY);
-		/* Set number of addresses */
-		priv->spy_number = number;
-	}
-
-	/* Now, let the others play */
-	orinoco_unlock(priv, &flags);
-
-	/* Do NOT call commit handler */
-	return 0;
-}
-
-static int orinoco_ioctl_getspy(struct net_device *dev,
-				struct iw_request_info *info,
-				struct iw_point *srq,
-				char *extra)
-{
-	struct orinoco_private *priv = netdev_priv(dev);
-	struct sockaddr *address = (struct sockaddr *) extra;
-	int number;
-	int i;
-	unsigned long flags;
-
-	if (orinoco_lock(priv, &flags) != 0)
-		return -EBUSY;
-
-	number = priv->spy_number;
-	/* Create address struct */
-	for (i = 0; i < number; i++) {
-		memcpy(address[i].sa_data, priv->spy_address[i], ETH_ALEN);
-		address[i].sa_family = AF_UNIX;
-	}
-	if (number > 0) {
-		/* Create address struct */
-		for (i = 0; i < number; i++) {
-			memcpy(address[i].sa_data, priv->spy_address[i],
-			       ETH_ALEN);
-			address[i].sa_family = AF_UNIX;
-		}
-		/* Copy stats */
-		/* In theory, we should disable irqs while copying the stats
-		 * because the rx path might update it in the middle...
-		 * Bah, who care ? - Jean II */
-		memcpy(extra  + (sizeof(struct sockaddr) * number),
-		       priv->spy_stat, sizeof(struct iw_quality) * number);
-	}
-	/* Reset updated flags. */
-	for (i = 0; i < number; i++)
-		priv->spy_stat[i].updated = 0;
-
-	orinoco_unlock(priv, &flags);
-
-	srq->length = number;
-
-	return 0;
-}
-
 /* Trigger a scan (look for other cells in the vicinity */
 static int orinoco_ioctl_setscan(struct net_device *dev,
 				 struct iw_request_info *info,
 				 struct iw_param *srq,
 				 char *extra)
@@ -4349,12 +4269,14 @@ static const iw_handler	orinoco_handler[
 	[SIOCSIWMODE  -SIOCIWFIRST] = (iw_handler) orinoco_ioctl_setmode,
 	[SIOCGIWMODE  -SIOCIWFIRST] = (iw_handler) orinoco_ioctl_getmode,
 	[SIOCSIWSENS  -SIOCIWFIRST] = (iw_handler) orinoco_ioctl_setsens,
 	[SIOCGIWSENS  -SIOCIWFIRST] = (iw_handler) orinoco_ioctl_getsens,
 	[SIOCGIWRANGE -SIOCIWFIRST] = (iw_handler) orinoco_ioctl_getiwrange,
-	[SIOCSIWSPY   -SIOCIWFIRST] = (iw_handler) orinoco_ioctl_setspy,
-	[SIOCGIWSPY   -SIOCIWFIRST] = (iw_handler) orinoco_ioctl_getspy,
+	[SIOCSIWSPY   -SIOCIWFIRST] = (iw_handler) iw_handler_set_spy,
+	[SIOCGIWSPY   -SIOCIWFIRST] = (iw_handler) iw_handler_get_spy,
+	[SIOCSIWTHRSPY-SIOCIWFIRST] = (iw_handler) iw_handler_set_thrspy,
+	[SIOCGIWTHRSPY-SIOCIWFIRST] = (iw_handler) iw_handler_get_thrspy,
 	[SIOCSIWAP    -SIOCIWFIRST] = (iw_handler) orinoco_ioctl_setwap,
 	[SIOCGIWAP    -SIOCIWFIRST] = (iw_handler) orinoco_ioctl_getwap,
 	[SIOCSIWSCAN  -SIOCIWFIRST] = (iw_handler) orinoco_ioctl_setscan,
 	[SIOCGIWSCAN  -SIOCIWFIRST] = (iw_handler) orinoco_ioctl_getscan,
 	[SIOCSIWESSID -SIOCIWFIRST] = (iw_handler) orinoco_ioctl_setessid,
@@ -4395,10 +4317,11 @@ static const struct iw_handler_def orino
 	.num_private = ARRAY_SIZE(orinoco_private_handler),
 	.num_private_args = ARRAY_SIZE(orinoco_privtab),
 	.standard = orinoco_handler,
 	.private = orinoco_private_handler,
 	.private_args = orinoco_privtab,
+	.get_wireless_stats = orinoco_get_wireless_stats,
 };
 
 static void orinoco_get_drvinfo(struct net_device *dev,
 				struct ethtool_drvinfo *info)
 {
diff --git a/drivers/net/wireless/orinoco.h b/drivers/net/wireless/orinoco.h
--- a/drivers/net/wireless/orinoco.h
+++ b/drivers/net/wireless/orinoco.h
@@ -11,10 +11,11 @@
 
 #include <linux/types.h>
 #include <linux/spinlock.h>
 #include <linux/netdevice.h>
 #include <linux/wireless.h>
+#include <net/iw_handler.h>
 #include <linux/version.h>
 
 #include "hermes.h"
 
 /* To enable debug messages */
@@ -110,13 +111,12 @@ struct orinoco_private {
 	u16 channel;
 	u16 ap_density, rts_thresh;
 	u16 pm_on, pm_mcast, pm_period, pm_timeout;
 	u16 preamble;
 #ifdef WIRELESS_SPY
-	int			spy_number;
-	u_char			spy_address[IW_MAX_SPY][ETH_ALEN];
-	struct iw_quality	spy_stat[IW_MAX_SPY];
+ 	struct iw_spy_data spy_data; /* iwspy support */
+	struct iw_public_data	wireless_data;
 #endif
 
 	/* Configuration dependent variables */
 	int port_type, createibss;
 	int promiscuous, mc_count;



-- 
Regards,
Pavel Roskin



-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
