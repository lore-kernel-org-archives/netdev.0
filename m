From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 16/17] d80211: fix monitor interfaces
Date: Fri, 21 Apr 2006 22:11:47 +0200 (CEST)
Message-ID: <20060421201147.D4F76482CF@silver.suse.cz>
References: <20060421220951.205579000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:14983 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932426AbWDUULU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 16:11:20 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060421220951.205579000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch allows monitor interfaces to be set by SIOCSIWMODE and to receive
frames.

Also, "soft" and "hard" monitor modes are introduced.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 include/net/d80211.h         |   10 ++++++
 net/d80211/ieee80211.c       |   67 ++++++++++++++++++++++++++++++++++++++++--
 net/d80211/ieee80211_i.h     |    1 +
 net/d80211/ieee80211_iface.c |    7 ++++
 4 files changed, 81 insertions(+), 4 deletions(-)

738241025b5e0091237d8c9d809d9affbdfaee29
diff --git a/include/net/d80211.h b/include/net/d80211.h
index 7bc66b5..23bcbfa 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -330,6 +330,8 @@ enum ieee80211_if_types {
  * @if_id: internal interface ID. This number has no particular meaning to
  *	drivers and the only allowed usage is to pass it to
  *	ieee80211_beacon_get() and ieee80211_get_buffered_bc() functions.
+ *	This field is not valid for monitor interfaces
+ *	(interfaces of %IEEE80211_IF_TYPE_MNTR type).
  * @type: one of &enum ieee80211_if_types constants. Determines the type of
  *	added/removed interface.
  * @mac_addr: pointer to MAC address of the interface. This pointer is valid
@@ -476,6 +478,10 @@ struct ieee80211_hw {
 	 */
 	unsigned int device_strips_mic:1;
 
+	/* Device is capable of performing full monitor mode even during
+	 * normal operation. */
+	unsigned int monitor_during_oper:1;
+
 	/* 1 = low-level driver supports skb fraglist (NETIF_F_FRAGLIST), i.e.,
 	 * more than one skb per frame */
 	unsigned int fraglist;
@@ -511,7 +517,9 @@ struct ieee80211_hw {
 	 * more exactly, set UP). If the handler returns zero, the interface
 	 * is added. Driver should perform any initialization it needs prior
 	 * to returning zero. By returning non-zero, adding of the interface
-	 * is not permitted. The open() handler is called after
+	 * is not permitted. Unless monitor_during_oper is set, it is
+	 * guaranteed that monitor interfaces and normal interfaces are
+	 * mutually exclusive. The open() handler is called after
 	 * add_interface() if this is the first device added. At least one
 	 * of open() and add_interface() handler has to be non-NULL. If
 	 * add_interface() is NULL, one STA interface is permitted only. */
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index e2a42af..b199b9e 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -1891,7 +1891,9 @@ static struct net_device_stats *ieee8021
 
 static inline int identical_mac_addr_allowed(int type1, int type2)
 {
-	return ((type1 == IEEE80211_IF_TYPE_AP &&
+	return (type1 == IEEE80211_IF_TYPE_MNTR ||
+		type2 == IEEE80211_IF_TYPE_MNTR ||
+		(type1 == IEEE80211_IF_TYPE_AP &&
 		 type2 == IEEE80211_IF_TYPE_WDS) ||
 		(type1 == IEEE80211_IF_TYPE_WDS &&
 		 (type2 == IEEE80211_IF_TYPE_WDS ||
@@ -1925,6 +1927,36 @@ static int ieee80211_master_stop(struct 
 	return 0;
 }
 
+/* Check if running monitor interfaces should go to a "soft monitor" mode
+ * and switch them if necessary. */
+static inline void ieee80211_start_soft_monitor(struct ieee80211_local *local)
+{
+	struct ieee80211_if_init_conf conf;
+
+	if (local->open_count && local->open_count == local->monitors &&
+	    !local->hw->monitor_during_oper && local->hw->remove_interface) {
+		conf.if_id = -1;
+		conf.type = IEEE80211_IF_TYPE_MNTR;
+		conf.mac_addr = NULL;
+		local->hw->remove_interface(local->mdev, &conf);
+	}
+}
+
+/* Check if running monitor interfaces should go to a "hard monitor" mode
+ * and switch them if necessary. */
+static void ieee80211_start_hard_monitor(struct ieee80211_local *local)
+{
+	struct ieee80211_if_init_conf conf;
+
+	if (local->open_count && local->open_count == local->monitors &&
+	    !local->hw->monitor_during_oper && local->hw->add_interface) {
+		conf.if_id = -1;
+		conf.type = IEEE80211_IF_TYPE_MNTR;
+		conf.mac_addr = NULL;
+		local->hw->add_interface(local->mdev, &conf);
+	}
+}
+
 static int ieee80211_open(struct net_device *dev)
 {
 	struct ieee80211_sub_if_data *sdata, *nsdata;
@@ -1948,13 +1980,25 @@ static int ieee80211_open(struct net_dev
 	    memcmp(sdata->u.wds.remote_addr, "\0\0\0\0\0\0", ETH_ALEN) == 0)
 		return -ENOLINK;
 
+	if (sdata->type == IEEE80211_IF_TYPE_MNTR && local->open_count &&
+	    !local->hw->monitor_during_oper) {
+		/* run the interface in a "soft monitor" mode */
+		local->monitors++;
+		local->open_count++;
+		return 0;
+	}
+	ieee80211_start_soft_monitor(local);
+
 	if (local->hw->add_interface) {
 		conf.if_id = dev->ifindex;
 		conf.type = sdata->type;
 		conf.mac_addr = dev->dev_addr;
 		res = local->hw->add_interface(sdata->master, &conf);
-		if (res)
+		if (res) {
+			if (sdata->type == IEEE80211_IF_TYPE_MNTR)
+				ieee80211_start_hard_monitor(local);
 			return res;
+		}
 	} else {
 		if (sdata->type != IEEE80211_IF_TYPE_STA)
 			return -EOPNOTSUPP;
@@ -1980,6 +2024,9 @@ static int ieee80211_open(struct net_dev
 	}
         local->open_count++;
 
+	if (sdata->type == IEEE80211_IF_TYPE_MNTR)
+		local->monitors++;
+
 	netif_start_queue(dev);
 	return 0;
 }
@@ -1992,8 +2039,19 @@ static int ieee80211_stop(struct net_dev
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
+	if (sdata->type == IEEE80211_IF_TYPE_MNTR &&
+	    local->open_count > 1 && !local->hw->monitor_during_oper) {
+		/* remove "soft monitor" interface */
+		local->open_count--;
+		local->monitors--;
+		return 0;
+	}
+
         netif_stop_queue(dev);
 
+	if (sdata->type == IEEE80211_IF_TYPE_MNTR)
+		local->monitors--;
+
 	local->open_count--;
         if (local->open_count == 0) {
 		ieee80211_stop_scan(sdata->master);
@@ -2010,6 +2068,8 @@ static int ieee80211_stop(struct net_dev
 		local->hw->remove_interface(sdata->master, &conf);
 	}
 
+	ieee80211_start_hard_monitor(local);
+
 	return 0;
 }
 
@@ -2242,7 +2302,8 @@ ieee80211_rx_mgmt(struct net_device *dev
         size_t hlen;
         struct ieee80211_sub_if_data *sdata;
 
-        dev = local->apdev;
+	if (msg_type != ieee80211_msg_monitor)
+		dev = local->apdev;
         skb->dev = dev;
 
         sdata = IEEE80211_DEV_TO_SUB_IF(dev);
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 37d533d..2dbb132 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -305,6 +305,7 @@ struct ieee80211_local {
         struct net_device *wdev; /* wlan# - default Ethernet (data) devide */
 	struct net_device *apdev; /* wlan#ap - management frames (hostapd) */
 	int open_count;
+	int monitors;
 	struct ieee80211_conf conf;
 
 	int dev_index;
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index 2151bd9..dd809c2 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -8,6 +8,7 @@
  * published by the Free Software Foundation.
  */
 #include <linux/kernel.h>
+#include <linux/if_arp.h>
 #include <linux/netdevice.h>
 #include <linux/rtnetlink.h>
 #include <net/d80211.h>
@@ -124,6 +125,9 @@ void ieee80211_if_set_type(struct net_de
 		sdata->bss = &msdata->u.ap;
 		break;
 	}
+	case IEEE80211_IF_TYPE_MNTR:
+		dev->type = ARPHRD_IEEE80211_PRISM;
+		break;
 	default:
 		printk(KERN_WARNING "%s: %s: Unknown interface type 0x%x",
 		       dev->name, __FUNCTION__, type);
@@ -211,6 +215,9 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 		}
 
 		break;
+	case IEEE80211_IF_TYPE_MNTR:
+		dev->type = ARPHRD_ETHER;
+		break;
 	}
 
 	/* remove all STAs that are bound to this virtual interface */
-- 
1.3.0

