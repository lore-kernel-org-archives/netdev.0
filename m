From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 2/5] d80211: per-queue TX flow control
Date: Fri, 23 Jun 2006 15:01:19 +0200 (CEST)
Message-ID: <20060623130119.AFAD4483AC@silver.suse.cz>
References: <20060623150047.368594000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:11399 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S964801AbWFWM75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 08:59:57 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060623150047.368594000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, before a packet is passed to the driver, the driver is asked
about status of its TX queues (i.e. how many packets are queued in each
queue and how large are queues).

This is different from the way generic networking works in Linux and it
doesn't allow easy implementation of resubmitting fragments to the driver
when the queue gets filled up during transmitting.

This patch changes the stack not to ask driver about queue status but
require driver to do TX flow control.

Please note that this breaks drivers.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 include/net/d80211.h     |   30 ++++++++++++++++++++++++++++++
 net/d80211/ieee80211.c   |   27 +++++++++++++++++++++++++++
 net/d80211/ieee80211_i.h |    6 ++++++
 net/d80211/wme.c         |    6 +-----
 4 files changed, 64 insertions(+), 5 deletions(-)

39ee8c857aff2f97fb8c27cee2ee9001833f5a2b
diff --git a/include/net/d80211.h b/include/net/d80211.h
index 4bdbdbe..141f776 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -781,6 +781,7 @@ int ieee80211_get_hdrlen(u16 fc);
  * netdevices for each hardware device. The low-level driver does not "see"
  * these interfaces, so it should use this function to perform netif
  * operations on all interface. */
+/* This function is deprecated. */
 typedef enum {
 	NETIF_ATTACH, NETIF_DETACH, NETIF_START, NETIF_STOP, NETIF_WAKE,
 	NETIF_IS_STOPPED, NETIF_UPDATE_TX_START
@@ -788,6 +789,35 @@ typedef enum {
 int ieee80211_netif_oper(struct net_device *dev, Netif_Oper op);
 
 /**
+ * ieee80211_wake_queue - wake specific queue
+ * @dev: pointer to &struct net_device as obtained from
+ *	ieee80211_alloc_hw().
+ * @queue: queue number (counted from zero).
+ *
+ * Drivers should use this function instead of netif_wake_queue.
+ */
+void ieee80211_wake_queue(struct net_device *dev, int queue);
+
+/**
+ * ieee80211_stop_queue - stop specific queue
+ * @dev: pointer to &struct net_device as obtained from
+ *	ieee80211_alloc_hw().
+ * @queue: queue number (counted from zero).
+ *
+ * Drivers should use this function instead of netif_stop_queue.
+ */
+void ieee80211_stop_queue(struct net_device *dev, int queue);
+
+/**
+ * ieee80211_start_queues - start all queues
+ * @dev: pointer to &struct net_device as obtained from
+ *	ieee80211_alloc_hw().
+ *
+ * Drivers should use this function instead of netif_start_queue.
+ */
+void ieee80211_start_queues(struct net_device *dev);
+
+/**
  * ieee80211_get_mc_list_item - iteration over items in multicast list
  * @dev: pointer to &struct net_device as obtained from
  *	ieee80211_alloc_hw().
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 944b89f..65f32a8 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -4421,6 +4421,30 @@ #endif
         return 0;
 }
 
+void ieee80211_wake_queue(struct net_device *dev, int queue)
+{
+	struct ieee80211_local *local = dev->ieee80211_ptr;
+
+	if (test_and_clear_bit(IEEE80211_LINK_STATE_XOFF,
+			       &local->state[queue]))
+		__netif_schedule(dev);
+}
+
+void ieee80211_stop_queue(struct net_device *dev, int queue)
+{
+	struct ieee80211_local *local = dev->ieee80211_ptr;
+
+	set_bit(IEEE80211_LINK_STATE_XOFF, &local->state[queue]);
+}
+
+void ieee80211_start_queues(struct net_device *dev)
+{
+	struct ieee80211_local *local = dev->ieee80211_ptr;
+	int i;
+
+	for (i = 0; i < local->hw->queues; i++)
+		clear_bit(IEEE80211_LINK_STATE_XOFF, &local->state[i]);
+}
 
 void * ieee80211_dev_hw_data(struct net_device *dev)
 {
@@ -4548,6 +4572,9 @@ EXPORT_SYMBOL(ieee80211_tx_status);
 EXPORT_SYMBOL(ieee80211_beacon_get);
 EXPORT_SYMBOL(ieee80211_get_buffered_bc);
 EXPORT_SYMBOL(ieee80211_netif_oper);
+EXPORT_SYMBOL(ieee80211_wake_queue);
+EXPORT_SYMBOL(ieee80211_stop_queue);
+EXPORT_SYMBOL(ieee80211_start_queues);
 EXPORT_SYMBOL(ieee80211_dev_hw_data);
 EXPORT_SYMBOL(ieee80211_dev_stats);
 EXPORT_SYMBOL(ieee80211_get_hw_conf);
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index c1d7422..722860c 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -353,6 +353,8 @@ #define IEEE80211_IRQSAFE_QUEUE_LIMIT 12
 	struct sta_info *sta_hash[STA_HASH_SIZE];
 	struct timer_list sta_cleanup;
 
+	unsigned long state[NUM_TX_DATA_QUEUES];
+
 	int mc_count;	/* total count of multicast entries in all interfaces */
 	int iff_allmultis, iff_promiscs;
 			/* number of interfaces with corresponding IFF_ flags */
@@ -514,6 +516,10 @@ #endif /* CONFIG_D80211_DEBUG_COUNTERS *
 	int user_space_mlme;
 };
 
+enum ieee80211_link_state_t {
+	IEEE80211_LINK_STATE_XOFF = 0,
+};
+
 struct sta_attribute {
 	struct attribute attr;
 	ssize_t (*show)(const struct sta_info *, char *buf);
diff --git a/net/d80211/wme.c b/net/d80211/wme.c
index 138f892..87437cc 100644
--- a/net/d80211/wme.c
+++ b/net/d80211/wme.c
@@ -316,18 +316,14 @@ static struct sk_buff *wme_qdiscop_deque
 	struct net_device *dev = qd->dev;
 	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_hw *hw = local->hw;
-	struct ieee80211_tx_queue_stats stats;
 	struct sk_buff *skb;
 	struct Qdisc *qdisc;
 	int queue;
 
-	/* find which hardware queues have space in them */
-	hw->get_tx_stats(dev, &stats);
-
 	/* check all the h/w queues in numeric/priority order */
 	for (queue = 0; queue < hw->queues; queue++) {
 		/* see if there is room in this hardware queue */
-		if (stats.data[queue].len >= stats.data[queue].limit)
+		if (test_bit(IEEE80211_LINK_STATE_XOFF, &local->state[queue]))
 			continue;
 
 		/* there is space - try and get a frame */
-- 
1.3.0

