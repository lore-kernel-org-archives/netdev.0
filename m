From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 11/18] d80211:  clean up qdisc requeue
Date: Mon, 21 Aug 2006 09:41:18 +0200
Message-ID: <20060821075200.982958463@sipsolutions.net>
References: <20060821074107.648561364@sipsolutions.net>
Mime-Version: 1.0
Cc: Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:57024 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1030320AbWHUICO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 04:02:14 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=d80211-requeue-cleanup.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There was a comment saying:
/* TODO: clean up the cases where master_hard_start_xmit
 * returns non 0 - it shouldn't ever do that. Once done we
 * can remove this function */

I noticed that master_hard_start_xmit never returns nonzero
by following the paths it calls. This patch hence removes
the function and changes a few things to make the fact that
it always returns 0 more obvious.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/net/d80211/ieee80211.c	2006-08-20 14:56:22.708192788 +0200
+++ wireless-dev/net/d80211/ieee80211.c	2006-08-20 14:56:23.818192788 +0200
@@ -1211,8 +1211,8 @@ static int __ieee80211_tx(struct ieee802
 	return IEEE80211_TX_OK;
 }
 
-static int ieee80211_tx(struct net_device *dev, struct sk_buff *skb,
-			struct ieee80211_tx_control *control, int mgmt)
+static void ieee80211_tx(struct net_device *dev, struct sk_buff *skb,
+			 struct ieee80211_tx_control *control, int mgmt)
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct sta_info *sta;
@@ -1225,7 +1225,7 @@ static int ieee80211_tx(struct net_devic
 
 	if (unlikely(skb->len < 10)) {
 		dev_kfree_skb(skb);
-		return 0;
+		return;
 	}
 
 	__ieee80211_tx_prepare(&tx, skb, dev, control);
@@ -1245,12 +1245,18 @@ static int ieee80211_tx(struct net_devic
 
 	if (unlikely(res == TXRX_DROP)) {
 		I802_DEBUG_INC(local->tx_handlers_drop);
-		goto drop;
+		if (skb)
+			dev_kfree_skb(skb);
+		for (i = 0; i < tx.u.tx.num_extra_frag; i++)
+			if (tx.u.tx.extra_frag[i])
+				dev_kfree_skb(tx.u.tx.extra_frag[i]);
+		kfree(tx.u.tx.extra_frag);
+		return;
 	}
 
 	if (unlikely(res == TXRX_QUEUED)) {
 		I802_DEBUG_INC(local->tx_handlers_queued);
-		return 0;
+		return;
 	}
 
 	if (tx.u.tx.extra_frag) {
@@ -1306,16 +1312,6 @@ retry:
 		store->last_frag_rateidx = tx.u.tx.last_frag_rateidx;
 		store->last_frag_rate_ctrl_probe = tx.u.tx.probe_last_frag;
 	}
-	return 0;
-
- drop:
-	if (skb)
-		dev_kfree_skb(skb);
-	for (i = 0; i < tx.u.tx.num_extra_frag; i++)
-		if (tx.u.tx.extra_frag[i])
-			dev_kfree_skb(tx.u.tx.extra_frag[i]);
-        kfree(tx.u.tx.extra_frag);
-	return 0;
 }
 
 static void ieee80211_tx_pending(unsigned long data)
@@ -1380,7 +1376,6 @@ static int ieee80211_master_start_xmit(s
 	struct ieee80211_tx_packet_data *pkt_data;
 	struct net_device *odev = NULL;
 	struct ieee80211_sub_if_data *sdata, *osdata;
-	int ret;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
@@ -1415,11 +1410,11 @@ static int ieee80211_master_start_xmit(s
 	control.requeue = pkt_data->requeue;
 	control.queue = pkt_data->queue;
 
-	ret = ieee80211_tx(odev, skb, &control,
-			   control.type == IEEE80211_IF_TYPE_MGMT);
+	ieee80211_tx(odev, skb, &control,
+		     control.type == IEEE80211_IF_TYPE_MGMT);
 	dev_put(odev);
 
-        return ret;
+	return 0;
 }
 
 
--- wireless-dev.orig/net/d80211/wme.c	2006-08-20 14:56:22.718192788 +0200
+++ wireless-dev/net/d80211/wme.c	2006-08-20 14:56:23.818192788 +0200
@@ -286,30 +286,6 @@ static int wme_qdiscop_enqueue(struct sk
 	return err;
 }
 
-
-/* TODO: clean up the cases where master_hard_start_xmit
- * returns non 0 - it shouldn't ever do that. Once done we
- * can remove this function */
-static int wme_qdiscop_requeue(struct sk_buff *skb, struct Qdisc* qd)
-{
-	struct ieee80211_sched_data *q = qdisc_priv(qd);
-	struct ieee80211_tx_packet_data *pkt_data =
-		(struct ieee80211_tx_packet_data *) skb->cb;
-	struct Qdisc *qdisc;
-	int err;
-
-	/* we recorded which queue to use earlier! */
-	qdisc = q->queues[pkt_data->queue];
-
-	if ((err = qdisc->ops->requeue(skb, qdisc)) == 0) {
-		qd->q.qlen++;
-		return 0;
-	}
-	qd->qstats.drops++;
-	return err;
-}
-
-
 static struct sk_buff *wme_qdiscop_dequeue(struct Qdisc* qd)
 {
 	struct ieee80211_sched_data *q = qdisc_priv(qd);
@@ -643,7 +619,7 @@ static struct Qdisc_ops wme_qdisc_ops =
 
 	.enqueue = wme_qdiscop_enqueue,
 	.dequeue = wme_qdiscop_dequeue,
-	.requeue = wme_qdiscop_requeue,
+	.requeue = NULL, /* not needed since master_start_xmit never fails */
 	.drop = NULL, /* drop not needed since we are always the root qdisc */
 
 	.init = wme_qdiscop_init,

--
