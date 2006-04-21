From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 14/17] d80211: set_multicast_list
Date: Fri, 21 Apr 2006 22:11:45 +0200 (CEST)
Message-ID: <20060421201145.BF3D1482CD@silver.suse.cz>
References: <20060421220951.205579000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:14471 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932420AbWDUULS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 16:11:18 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060421220951.205579000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add set_multicast_list callback. The version of set_multicast_list in
struct net_device cannot be used by a driver, because the driver is
interested in cumulative flags and cumulative multicast list from all
interfaces.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 include/net/d80211.h         |   24 ++++++++++++++
 net/d80211/ieee80211.c       |   71 ++++++++++++++++++++++++++++++++++++++++++
 net/d80211/ieee80211_i.h     |    8 +++++
 net/d80211/ieee80211_iface.c |    1 +
 4 files changed, 104 insertions(+), 0 deletions(-)

9ada6736d81619ac81ea1ce283f47c365fe3b24f
diff --git a/include/net/d80211.h b/include/net/d80211.h
index 6894745..7bc66b5 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -532,6 +532,13 @@ struct ieee80211_hw {
 	int (*config_interface)(struct net_device *dev, int if_id,
 				struct ieee80211_if_conf *conf);
 
+	/* ieee80211 drivers should use this and not the function in
+	 * net_device. dev->flags, dev->mc_count and dev->mc_list must not
+	 * be used; use passed parameters and ieee80211_get_mc_list_item()
+	 * instead. */
+	void (*set_multicast_list)(struct net_device *dev,
+				   unsigned short flags, int mc_count);
+
 	/* Set TIM bit handler. If the hardware/firmware takes care of beacon
 	 * generation, IEEE 802.11 code uses this function to tell the
 	 * low-level to set (or clear if set==0) TIM bit for the given aid. If
@@ -775,6 +782,23 @@ typedef enum {
 } Netif_Oper;
 int ieee80211_netif_oper(struct net_device *dev, Netif_Oper op);
 
+/**
+ * ieee80211_get_mc_list_item - iteration over items in multicast list
+ * @dev: pointer to &struct net_device as obtained from
+ *	ieee80211_alloc_hw().
+ * @prev: value returned by previous call to ieee80211_get_mc_list_item() or
+ *	NULL to start a new iteration.
+ * @ptr: pointer to buffer of void * type for internal usage of
+ *	ieee80211_get_mc_list_item().
+ *
+ * Iterates over items in multicast list of given device. To get the first
+ * item, pass NULL in @prev and in *@ptr. In subsequent calls, pass the
+ * value returned by previous call in @prev. Don't alter *@ptr during
+ * iteration. When there are no more items, NULL is returned.
+ */
+struct dev_mc_list *ieee80211_get_mc_list_item(struct net_device *dev,
+					       struct dev_mc_list *prev,
+					       void **ptr);
 
 /*
  * Function to get hardware configuration information
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index ea71b6c..fbca700 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -1812,6 +1812,75 @@ static int ieee80211_set_mac_address(str
 	return 0;
 }
 
+static void ieee80211_set_multicast_list(struct net_device *dev)
+{
+	struct ieee80211_local *local = dev->priv;
+        struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	unsigned short flags;
+
+	if (((dev->flags & IFF_ALLMULTI) != 0) ^ (sdata->allmulti != 0)) {
+		if (sdata->allmulti) {
+			sdata->allmulti = 0;
+			local->iff_allmultis--;
+		} else {
+			sdata->allmulti = 1;
+			local->iff_allmultis++;
+		}
+	}
+	if (((dev->flags & IFF_PROMISC) != 0) ^ (sdata->promisc != 0)) {
+		if (sdata->promisc) {
+			sdata->promisc = 0;
+			local->iff_promiscs--;
+		} else {
+			sdata->promisc = 1;
+			local->iff_promiscs++;
+		}
+	}
+	if (dev->mc_count != sdata->mc_count) {
+		local->mc_count = local->mc_count - sdata->mc_count +
+				  dev->mc_count;
+		sdata->mc_count = dev->mc_count;
+	}
+	if (local->hw->set_multicast_list) {
+		flags = sdata->master->flags;
+		if (local->iff_allmultis)
+			flags |= IFF_ALLMULTI;
+		if (local->iff_promiscs)
+			flags |= IFF_PROMISC;
+		local->hw->set_multicast_list(sdata->master, flags,
+					      local->mc_count);
+	}
+}
+
+struct dev_mc_list *ieee80211_get_mc_list_item(struct net_device *dev,
+					       struct dev_mc_list *prev,
+					       void **ptr)
+{
+	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_sub_if_data *sdata = *ptr;
+	struct dev_mc_list *mc;
+
+	if (!prev) {
+		WARN_ON(sdata);
+		sdata = NULL;
+	}
+	if (!prev || !prev->next) {
+		if (sdata)
+			sdata = list_entry(sdata->list.next,
+					   struct ieee80211_sub_if_data, list);
+		else
+			sdata = list_entry(local->sub_if_list.next,
+					   struct ieee80211_sub_if_data, list);
+		if (&sdata->list != &local->sub_if_list)
+			mc = sdata->dev->mc_list;
+		else
+			mc = NULL;
+	} else
+		mc = prev->next;
+
+	*ptr = sdata;
+	return mc;
+}
 
 static struct net_device_stats *ieee80211_get_stats(struct net_device *dev)
 {
@@ -3889,6 +3958,7 @@ void ieee80211_if_setup(struct net_devic
 		(struct iw_handler_def *) &ieee80211_iw_handler_def;
 	dev->do_ioctl = ieee80211_ioctl;
 	dev->set_mac_address = ieee80211_set_mac_address;
+	dev->set_multicast_list = ieee80211_set_multicast_list;
 	dev->change_mtu = ieee80211_change_mtu;
 	dev->tx_timeout = ieee80211_tx_timeout;
 	dev->get_stats = ieee80211_get_stats;
@@ -4449,6 +4519,7 @@ EXPORT_SYMBOL(ieee80211_rate_control_unr
 EXPORT_SYMBOL(sta_info_get);
 EXPORT_SYMBOL(sta_info_release);
 EXPORT_SYMBOL(ieee80211_radar_status);
+EXPORT_SYMBOL(ieee80211_get_mc_list_item);
 
 module_init(ieee80211_init);
 module_exit(ieee80211_exit);
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 5116a88..37d533d 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -264,6 +264,10 @@ struct ieee80211_sub_if_data {
         struct net_device *master;
         struct ieee80211_local *local;
 
+	int mc_count;
+	unsigned allmulti:1;
+	unsigned promisc:1;
+
         struct net_device_stats stats;
 	int drop_unencrypted;
 	int eapol; /* 0 = process EAPOL frames as normal data frames,
@@ -327,6 +331,10 @@ #define IEEE80211_IRQSAFE_QUEUE_LIMIT 12
 	struct sta_info *sta_hash[STA_HASH_SIZE];
 	struct timer_list sta_cleanup;
 
+	int mc_count;	/* total count of multicast entries in all interfaces */
+	int iff_allmultis, iff_promiscs;
+			/* number of interfaces with corresponding IFF_ flags */
+
 	/* Current rate table. This is a pointer to hw->modes structure. */
 	struct ieee80211_rate *curr_rates;
 	int num_curr_rates;
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index 917428e..2151bd9 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -62,6 +62,7 @@ int ieee80211_if_add(struct net_device *
 	ndev->irq = dev->irq;
 	ndev->mem_start = dev->mem_start;
 	ndev->mem_end = dev->mem_end;
+	ndev->flags = dev->flags & IFF_MULTICAST;
 	ieee80211_if_setup(ndev);
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(ndev);
-- 
1.3.0

