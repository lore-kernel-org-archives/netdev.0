From: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/4] Net: mac80211, remove bitfields from struct ieee80211_tx_packet_data
Date: Sun, 12 Aug 2007 15:08:56 +0200 (CEST)
Message-ID: <32694265142306417777@wsc.cz>
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: <jbenc-AlSwsSmVLrQ@public.gmane.org>
Cc: <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>
Cc: <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

All against mac80211 tree

--

mac80211, remove bitfields from struct ieee80211_tx_packet_data

Signed-off-by: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

---
commit 10e9252a35d42fb92e65dfaaef136d81dbb71c4f
tree f8579cff30dc8053b770b78582a30961b7320046
parent a050b807aede7f33339c6bee0bef1c07cd9c5fc4
author Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> Sun, 12 Aug 2007 11:14:36 +0200
committer Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> Sun, 12 Aug 2007 11:14:36 +0200

 net/mac80211/ieee80211.c     |   15 +++++++++++----
 net/mac80211/ieee80211_i.h   |   11 ++++++-----
 net/mac80211/ieee80211_sta.c |    6 ++++--
 net/mac80211/rx.c            |    4 ++--
 net/mac80211/tx.c            |   23 ++++++++++++-----------
 net/mac80211/wme.c           |    4 ++--
 6 files changed, 37 insertions(+), 26 deletions(-)

diff --git a/net/mac80211/ieee80211.c b/net/mac80211/ieee80211.c
index 9ff86ee..0952237 100644
--- a/net/mac80211/ieee80211.c
+++ b/net/mac80211/ieee80211.c
@@ -933,10 +933,17 @@ static void ieee80211_remove_tx_extra(struct ieee80211_local *local,
 
 	pkt_data = (struct ieee80211_tx_packet_data *)skb->cb;
 	pkt_data->ifindex = control->ifindex;
-	pkt_data->mgmt_iface = (control->type == IEEE80211_IF_TYPE_MGMT);
-	pkt_data->req_tx_status = !!(control->flags & IEEE80211_TXCTL_REQ_TX_STATUS);
-	pkt_data->do_not_encrypt = !!(control->flags & IEEE80211_TXCTL_DO_NOT_ENCRYPT);
-	pkt_data->requeue = !!(control->flags & IEEE80211_TXCTL_REQUEUE);
+	pkt_data->flags &= ~(IEEE80211_TXPD_REQ_TX_STATUS |
+		IEEE80211_TXPD_DO_NOT_ENCRYPT | IEEE80211_TXPD_REQUEUE |
+		IEEE80211_TXPD_MGMT_IFACE);
+	if (control->flags & IEEE80211_TXCTL_REQ_TX_STATUS)
+		pkt_data->flags |= IEEE80211_TXPD_REQ_TX_STATUS;
+	if (control->flags & IEEE80211_TXCTL_DO_NOT_ENCRYPT)
+		pkt_data->flags |= IEEE80211_TXPD_DO_NOT_ENCRYPT;
+	if (control->flags & IEEE80211_TXCTL_REQUEUE)
+		pkt_data->flags |= IEEE80211_TXPD_REQUEUE;
+	if (control->type == IEEE80211_IF_TYPE_MGMT)
+		pkt_data->flags |= IEEE80211_TXPD_MGMT_IFACE;
 	pkt_data->queue = control->queue;
 
 	hdrlen = ieee80211_get_hdrlen_from_skb(skb);
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 4599d55..265893a 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -170,11 +170,12 @@ struct ieee80211_txrx_data {
 struct ieee80211_tx_packet_data {
 	int ifindex;
 	unsigned long jiffies;
-	unsigned int req_tx_status:1;
-	unsigned int do_not_encrypt:1;
-	unsigned int requeue:1;
-	unsigned int mgmt_iface:1;
-	unsigned int queue:4;
+#define IEEE80211_TXPD_REQ_TX_STATUS	BIT(0)
+#define IEEE80211_TXPD_DO_NOT_ENCRYPT	BIT(1)
+#define IEEE80211_TXPD_REQUEUE		BIT(2)
+#define IEEE80211_TXPD_MGMT_IFACE	BIT(3)
+	unsigned int flags;
+	u8 queue;
 };
 
 struct ieee80211_tx_stored_packet {
diff --git a/net/mac80211/ieee80211_sta.c b/net/mac80211/ieee80211_sta.c
index b996332..75521ae 100644
--- a/net/mac80211/ieee80211_sta.c
+++ b/net/mac80211/ieee80211_sta.c
@@ -506,8 +506,10 @@ static void ieee80211_sta_tx(struct net_device *dev, struct sk_buff *skb,
 	pkt_data = (struct ieee80211_tx_packet_data *) skb->cb;
 	memset(pkt_data, 0, sizeof(struct ieee80211_tx_packet_data));
 	pkt_data->ifindex = sdata->dev->ifindex;
-	pkt_data->mgmt_iface = (sdata->type == IEEE80211_IF_TYPE_MGMT);
-	pkt_data->do_not_encrypt = !encrypt;
+	if (sdata->type == IEEE80211_IF_TYPE_MGMT)
+		pkt_data->flags |= IEEE80211_TXPD_MGMT_IFACE;
+	if (!encrypt)
+		pkt_data->flags |= IEEE80211_TXPD_DO_NOT_ENCRYPT;
 
 	dev_queue_xmit(skb);
 }
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 0a10720..948eb2f 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -415,7 +415,7 @@ static int ap_sta_ps_end(struct net_device *dev, struct sta_info *sta)
 	while ((skb = skb_dequeue(&sta->tx_filtered)) != NULL) {
 		pkt_data = (struct ieee80211_tx_packet_data *) skb->cb;
 		sent++;
-		pkt_data->requeue = 1;
+		pkt_data->flags |= IEEE80211_TXPD_REQUEUE;
 		dev_queue_xmit(skb);
 	}
 	while ((skb = skb_dequeue(&sta->ps_tx_buf)) != NULL) {
@@ -427,7 +427,7 @@ static int ap_sta_ps_end(struct net_device *dev, struct sta_info *sta)
 		       "since STA not sleeping anymore\n", dev->name,
 		       MAC_ARG(sta->addr), sta->aid);
 #endif /* CONFIG_MAC80211_VERBOSE_PS_DEBUG */
-		pkt_data->requeue = 1;
+		pkt_data->flags |= IEEE80211_TXPD_REQUEUE;
 		dev_queue_xmit(skb);
 	}
 
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index b57a592..3d05f8f 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1248,11 +1248,11 @@ int ieee80211_master_start_xmit(struct sk_buff *skb,
 
 	control.ifindex = odev->ifindex;
 	control.type = osdata->type;
-	if (pkt_data->req_tx_status)
+	if (pkt_data->flags & IEEE80211_TXPD_REQ_TX_STATUS)
 		control.flags |= IEEE80211_TXCTL_REQ_TX_STATUS;
-	if (pkt_data->do_not_encrypt)
+	if (pkt_data->flags & IEEE80211_TXPD_DO_NOT_ENCRYPT)
 		control.flags |= IEEE80211_TXCTL_DO_NOT_ENCRYPT;
-	if (pkt_data->requeue)
+	if (pkt_data->flags & IEEE80211_TXPD_REQUEUE)
 		control.flags |= IEEE80211_TXCTL_REQUEUE;
 	control.queue = pkt_data->queue;
 
@@ -1294,8 +1294,7 @@ int ieee80211_monitor_start_xmit(struct sk_buff *skb,
 	/* needed because we set skb device to master */
 	pkt_data->ifindex = dev->ifindex;
 
-	pkt_data->mgmt_iface = 0;
-	pkt_data->do_not_encrypt = 1;
+	pkt_data->flags |= IEEE80211_TXPD_DO_NOT_ENCRYPT;
 
 	/*
 	 * fix up the pointers accounting for the radiotap
@@ -1346,7 +1345,7 @@ int ieee80211_subif_start_xmit(struct sk_buff *skb,
 	struct ieee80211_hdr hdr;
 	const u8 *encaps_data;
 	int encaps_len, skip_header_bytes;
-	int nh_pos, h_pos, no_encrypt = 0;
+	int nh_pos, h_pos;
 	struct sta_info *sta;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
@@ -1492,8 +1491,8 @@ int ieee80211_subif_start_xmit(struct sk_buff *skb,
 	pkt_data = (struct ieee80211_tx_packet_data *)skb->cb;
 	memset(pkt_data, 0, sizeof(struct ieee80211_tx_packet_data));
 	pkt_data->ifindex = dev->ifindex;
-	pkt_data->mgmt_iface = (sdata->type == IEEE80211_IF_TYPE_MGMT);
-	pkt_data->do_not_encrypt = no_encrypt;
+	if (sdata->type == IEEE80211_IF_TYPE_MGMT)
+		pkt_data->flags |= IEEE80211_TXPD_MGMT_IFACE;
 
 	skb->dev = local->mdev;
 	sdata->stats.tx_packets++;
@@ -1551,7 +1550,8 @@ int ieee80211_mgmt_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	pkt_data = (struct ieee80211_tx_packet_data *) skb->cb;
 	memset(pkt_data, 0, sizeof(struct ieee80211_tx_packet_data));
 	pkt_data->ifindex = sdata->dev->ifindex;
-	pkt_data->mgmt_iface = (sdata->type == IEEE80211_IF_TYPE_MGMT);
+	if (sdata->type == IEEE80211_IF_TYPE_MGMT)
+		pkt_data->flags |= IEEE80211_TXPD_MGMT_IFACE;
 
 	skb->priority = 20; /* use hardcoded priority for mgmt TX queue */
 	skb->dev = sdata->local->mdev;
@@ -1561,12 +1561,13 @@ int ieee80211_mgmt_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * to request TX callback for hostapd. BIT(1) is checked.
 	 */
 	if ((fc & BIT(1)) == BIT(1)) {
-		pkt_data->req_tx_status = 1;
+		pkt_data->flags |= IEEE80211_TXPD_REQ_TX_STATUS;
 		fc &= ~BIT(1);
 		hdr->frame_control = cpu_to_le16(fc);
 	}
 
-	pkt_data->do_not_encrypt = !(fc & IEEE80211_FCTL_PROTECTED);
+	if (!(fc & IEEE80211_FCTL_PROTECTED))
+		pkt_data->flags |= IEEE80211_TXPD_DO_NOT_ENCRYPT;
 
 	sdata->stats.tx_packets++;
 	sdata->stats.tx_bytes += skb->len;
diff --git a/net/mac80211/wme.c b/net/mac80211/wme.c
index 99a792c..d3c81fe 100644
--- a/net/mac80211/wme.c
+++ b/net/mac80211/wme.c
@@ -110,7 +110,7 @@ static inline int classify80211(struct sk_buff *skb, struct Qdisc *qd)
 		return IEEE80211_TX_QUEUE_DATA0;
 	}
 
-	if (unlikely(pkt_data->mgmt_iface)) {
+	if (unlikely(pkt_data->flags & IEEE80211_TXPD_MGMT_IFACE)) {
 		/* Data frames from hostapd (mainly, EAPOL) use AC_VO
 		* and they will include QoS control fields if
 		* the target STA is using WME. */
@@ -179,7 +179,7 @@ static int wme_qdiscop_enqueue(struct sk_buff *skb, struct Qdisc* qd)
 	struct Qdisc *qdisc;
 	int err, queue;
 
-	if (pkt_data->requeue) {
+	if (pkt_data->flags & IEEE80211_TXPD_REQUEUE) {
 		skb_queue_tail(&q->requeued[pkt_data->queue], skb);
 		qd->q.qlen++;
 		return 0;
