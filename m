From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 3/10] d80211: fix Oops caused by packets sent directly to master device
Date: Fri, 21 Apr 2006 22:53:23 +0200 (CEST)
Message-ID: <20060421205323.07DD4482C1@silver.suse.cz>
References: <20060421225314.048983000.midnight@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:46209 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932443AbWDUUwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 16:52:55 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060421225314.048983000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sending packets to master interface directly causes dereferencing of pointer
containing random data. The same problem happens when originating virtual
interface is removed while a packet is queued.

We really shouldn't store pointer to ieee80211_sub_if_data in skb->cb. Store
ifindex there instead.

Also, there is no need for internal ieee80211_tx_packet_data structure to be
declared in d80211.h. As this patch touches this structure anyway, let's
move it to ieee80211_i.h.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 include/net/d80211.h       |   11 -----
 net/d80211/ieee80211.c     |   89 +++++++++++++++++++++++++++++++++++---------
 net/d80211/ieee80211_i.h   |   12 ++++++
 net/d80211/ieee80211_sta.c |    3 +
 net/d80211/wme.c           |    2 -
 5 files changed, 85 insertions(+), 32 deletions(-)

8d3a2dea3e4cefad23f3dad3e2eeeb5bdcff3dbb
diff --git a/include/net/d80211.h b/include/net/d80211.h
index 23bcbfa..e44e21c 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -188,17 +188,6 @@ struct ieee80211_tx_control {
 	struct ieee80211_sub_if_data *sdata; /* internal */
 };
 
-/* Stored in sk_buff->cb */
-struct ieee80211_tx_packet_data {
-        struct ieee80211_sub_if_data *sdata;
-	unsigned long jiffies;
-	unsigned int req_tx_status:1;
-	unsigned int do_not_encrypt:1;
-	unsigned int pkt_probe_resp:1;
-	unsigned int requeue:1;
-	unsigned int queue:4;
-};
-
 #define RX_FLAG_MMIC_ERROR       0x1
 #define RX_FLAG_DECRYPTED        0x2
 #define RX_FLAG_XR_DOUBLE_CHIRP  0x4
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index eb701ac..f768de5 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -1051,23 +1051,21 @@ ieee80211_tx_h_ps_buf(struct ieee80211_t
 }
 
 
-static void inline ieee80211_tx_prepare(struct ieee80211_txrx_data *tx,
-					struct sk_buff *skb,
-					struct net_device *dev,
-					struct ieee80211_tx_control *control)
+static void inline
+__ieee80211_tx_prepare(struct ieee80211_txrx_data *tx,
+		       struct sk_buff *skb,
+		       struct net_device *dev,
+		       struct ieee80211_tx_control *control)
 {
 	struct ieee80211_local *local = dev->priv;
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
-        struct ieee80211_tx_packet_data *pkt_data;
 	int hdrlen;
 
-        pkt_data = (struct ieee80211_tx_packet_data *)skb->cb;
-
 	memset(tx, 0, sizeof(*tx));
 	tx->skb = skb;
-	tx->dev = pkt_data->sdata->dev; /* use original interface */
+	tx->dev = dev; /* use original interface */
 	tx->local = local;
-        tx->sdata = pkt_data->sdata;
+	tx->sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	tx->sta = sta_info_get(local, hdr->addr1);
 	tx->fc = le16_to_cpu(hdr->frame_control);
         control->power_level = local->conf.power_level;
@@ -1095,6 +1093,37 @@ static void inline ieee80211_tx_prepare(
 
 }
 
+/* FIXME: This is not nice but currently there doesn't exist more elegant way */
+static int inline is_ieee80211_device(struct net_device *dev)
+{
+	return (dev->wireless_handlers ==
+		(struct iw_handler_def *) &ieee80211_iw_handler_def);
+}
+
+/* Device in tx->dev has a reference added; use dev_put(tx->dev) when
+ * finished with it. */
+static void inline ieee80211_tx_prepare(struct ieee80211_txrx_data *tx,
+					struct sk_buff *skb,
+					struct net_device *mdev,
+					struct ieee80211_tx_control *control)
+{
+	struct ieee80211_tx_packet_data *pkt_data;
+	struct net_device *dev;
+
+	pkt_data = (struct ieee80211_tx_packet_data *)skb->cb;
+	dev = dev_get_by_index(pkt_data->ifindex);
+	if (unlikely(dev && !is_ieee80211_device(dev))) {
+		dev_put(dev);
+		dev = NULL;
+	}
+	if (unlikely(!dev)) {
+		printk(KERN_WARNING "%s: NULL ifindex in pkt_data\n",
+		       mdev->name);
+		dev = mdev;
+		dev_hold(dev);
+	}
+	__ieee80211_tx_prepare(tx, skb, dev, control);
+}
 
 static int ieee80211_tx(struct net_device *dev, struct sk_buff *skb,
 			struct ieee80211_tx_control *control, int mgmt)
@@ -1111,7 +1140,7 @@ static int ieee80211_tx(struct net_devic
 		return 0;
 	}
 
-	ieee80211_tx_prepare(&tx, skb, dev, control);
+	__ieee80211_tx_prepare(&tx, skb, dev, control);
 	sta = tx.sta;
 	tx.u.tx.mgmt_interface = mgmt;
 
@@ -1136,8 +1165,8 @@ static int ieee80211_tx(struct net_devic
 		return 0;
 	}
 
-	ieee80211_dump_frame(dev->name, "TX to low-level driver", skb);
-	ret = local->hw->tx(dev, skb, control);
+	ieee80211_dump_frame(local->mdev->name, "TX to low-level driver", skb);
+	ret = local->hw->tx(local->mdev, skb, control);
 #ifdef IEEE80211_LEDS
 	if (!ret && local->tx_led_counter++ == 0) {
                 ieee80211_tx_led(1, dev);
@@ -1177,9 +1206,9 @@ #endif /* IEEE80211_LEDS */
 			dur = ieee80211_duration(&tx, 0, next_len);
 			hdr->duration_id = cpu_to_le16(dur);
 
-			ieee80211_dump_frame(dev->name,
+			ieee80211_dump_frame(local->mdev->name,
 					     "TX to low-level driver", skb);
-			ret = local->hw->tx(dev, tx.u.tx.extra_frag[i],
+			ret = local->hw->tx(local->mdev, tx.u.tx.extra_frag[i],
 					    control);
 			if (ret > 0)
 				goto drop;
@@ -1212,6 +1241,7 @@ static int ieee80211_master_start_xmit(s
 {
 	struct ieee80211_tx_control control;
 	struct ieee80211_tx_packet_data *pkt_data;
+	struct net_device *odev = NULL;
 	struct ieee80211_sub_if_data *sdata;
 	int ret;
 
@@ -1222,7 +1252,23 @@ static int ieee80211_master_start_xmit(s
 	 */
 	pkt_data = (struct ieee80211_tx_packet_data *)skb->cb;
 	memset(&control, 0, sizeof(struct ieee80211_tx_control));
-	control.sdata = pkt_data->sdata;
+
+	if (pkt_data->ifindex)
+		odev = dev_get_by_index(pkt_data->ifindex);
+	if (unlikely(odev && !is_ieee80211_device(odev))) {
+		dev_put(odev);
+		odev = NULL;
+	}
+	if (unlikely(!odev)) {
+#ifdef CONFIG_D80211_VERBOSE_DEBUG
+		printk(KERN_DEBUG "%s: Discarded packet with nonexistent "
+		       "originating device\n", dev->name);
+#endif
+		dev_kfree_skb(skb);
+		return 0;
+	}
+
+	control.sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	control.req_tx_status = pkt_data->req_tx_status;
 	control.do_not_encrypt = pkt_data->do_not_encrypt;
 	control.pkt_type =
@@ -1230,8 +1276,9 @@ static int ieee80211_master_start_xmit(s
 	control.requeue = pkt_data->requeue;
 	control.queue = pkt_data->queue;
 
-	ret = ieee80211_tx(dev, skb, &control,
+	ret = ieee80211_tx(odev, skb, &control,
 			   control.sdata->type == IEEE80211_IF_TYPE_MGMT);
+	dev_put(odev);
 
         return ret;
 }
@@ -1401,7 +1448,8 @@ #endif
 
 	pkt_data = (struct ieee80211_tx_packet_data *)skb->cb;
 	memset(pkt_data, 0, sizeof(struct ieee80211_tx_packet_data));
-	pkt_data->sdata = sdata;
+	pkt_data->ifindex = sdata->dev->ifindex;
+	pkt_data->mgmt_iface = (sdata->type == IEEE80211_IF_TYPE_MGMT);
 	pkt_data->do_not_encrypt = no_encrypt;
 
 	skb->dev = sdata->master;
@@ -1452,7 +1500,8 @@ ieee80211_mgmt_start_xmit(struct sk_buff
 
 	pkt_data = (struct ieee80211_tx_packet_data *) skb->cb;
 	memset(pkt_data, 0, sizeof(struct ieee80211_tx_packet_data));
-        pkt_data->sdata = sdata;
+        pkt_data->ifindex = sdata->dev->ifindex;
+	pkt_data->mgmt_iface = (sdata->type == IEEE80211_IF_TYPE_MGMT);
 
 	if (WLAN_FC_GET_TYPE(fc) == WLAN_FC_TYPE_MGMT &&
 	    WLAN_FC_GET_STYPE(fc) == WLAN_FC_STYPE_PROBE_RESP)
@@ -1680,6 +1729,7 @@ ieee80211_get_buffered_bc(struct net_dev
 		if (res == TXRX_DROP || res == TXRX_QUEUED)
 			break;
 	}
+	dev_put(tx.dev);
 
 	if (res == TXRX_DROP) {
 		I802_DEBUG_INC(local->tx_handlers_drop);
@@ -3644,7 +3694,8 @@ static void ieee80211_remove_tx_extra(st
 	struct ieee80211_tx_packet_data *pkt_data;
 
 	pkt_data = (struct ieee80211_tx_packet_data *)skb->cb;
-	pkt_data->sdata = control->sdata;
+	pkt_data->ifindex = control->sdata->dev->ifindex;
+	pkt_data->mgmt_iface = (control->sdata->type == IEEE80211_IF_TYPE_MGMT);
 	pkt_data->req_tx_status = control->req_tx_status;
 	pkt_data->do_not_encrypt = control->do_not_encrypt;
 	pkt_data->pkt_probe_resp = (control->pkt_type == PKT_PROBE_RESP);
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 400c675..b29a5e8 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -143,6 +143,18 @@ #ifdef CONFIG_HOSTAPD_WPA_TESTING
 #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 };
 
+/* Stored in sk_buff->cb */
+struct ieee80211_tx_packet_data {
+	int ifindex;
+	unsigned long jiffies;
+	unsigned int req_tx_status:1;
+	unsigned int do_not_encrypt:1;
+	unsigned int pkt_probe_resp:1;
+	unsigned int requeue:1;
+	unsigned int queue:4;
+	unsigned int mgmt_iface:1;
+};
+
 struct ieee80211_passive_scan {
         unsigned int in_scan:1; /* this must be cleared before calling
 				 * netif_oper(WAKEUP) */
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index d9c3d67..2720f1d 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -399,7 +399,8 @@ static void ieee80211_sta_tx(struct net_
 
 	pkt_data = (struct ieee80211_tx_packet_data *) skb->cb;
 	memset(pkt_data, 0, sizeof(struct ieee80211_tx_packet_data));
-	pkt_data->sdata = sdata;
+	pkt_data->ifindex = sdata->dev->ifindex;
+	pkt_data->mgmt_iface = (sdata->type == IEEE80211_IF_TYPE_MGMT);
 	pkt_data->do_not_encrypt = !encrypt;
 	if (probe_resp)
 		pkt_data->pkt_probe_resp = 1;
diff --git a/net/d80211/wme.c b/net/d80211/wme.c
index 51a197a..f20d3e0 100644
--- a/net/d80211/wme.c
+++ b/net/d80211/wme.c
@@ -190,7 +190,7 @@ static inline int classify80211(struct s
 		return IEEE80211_TX_QUEUE_DATA0;
 	}
 
-	if (unlikely(pkt_data->sdata->type == IEEE80211_IF_TYPE_MGMT)) {
+	if (unlikely(pkt_data->mgmt_iface)) {
 		/* Data frames from hostapd (mainly, EAPOL) use AC_VO
 		* and they will include QoS control fields if
 		* the target STA is using WME. */
-- 
1.3.0

