From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 9/14] d80211: remove pkt_type/pkt_probe_resp
Date: Wed, 13 Dec 2006 17:41:44 +0100 (CET)
Message-ID: <20061213164144.AC9003AA7E7@silver.suse.cz>
References: <20061213174109.005697000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:57260 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965038AbWLMRIy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 12:08:54 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061213174109.005697000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Wu <flamingice@sourmilk.net>

Nobody uses pkt_type, and the information can be obtained from the
header. This removes it and the associated code that keeps tracks of it.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 include/net/d80211.h       |    1 -
 net/d80211/ieee80211.c     |    7 -------
 net/d80211/ieee80211_i.h   |    3 +--
 net/d80211/ieee80211_sta.c |   17 +++++++----------
 4 files changed, 8 insertions(+), 20 deletions(-)

67e20838fff9a011cb83a02ca21d39d73313a42f
diff --git a/include/net/d80211.h b/include/net/d80211.h
index 30980e1..f7f6318 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -135,7 +135,6 @@ struct ieee80211_low_level_stats {
 #define HW_KEY_IDX_INVALID -1
 
 struct ieee80211_tx_control {
-	enum { PKT_NORMAL = 0, PKT_PROBE_RESP } pkt_type;
 	int tx_rate; /* Transmit rate, given as the hw specific value for the
 		      * rate (from struct ieee80211_rate) */
 	int rts_cts_rate; /* Transmit rate for RTS/CTS frame, given as the hw
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 664e6d0..8d543f2 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -1393,8 +1393,6 @@ #endif
 		control.flags |= IEEE80211_TXCTL_REQ_TX_STATUS;
 	if (pkt_data->do_not_encrypt)
 		control.flags |= IEEE80211_TXCTL_DO_NOT_ENCRYPT;
-	control.pkt_type =
-		pkt_data->pkt_probe_resp ? PKT_PROBE_RESP : PKT_NORMAL;
 	if (pkt_data->requeue)
 		control.flags |= IEEE80211_TXCTL_REQUEUE;
 	control.queue = pkt_data->queue;
@@ -1626,10 +1624,6 @@ ieee80211_mgmt_start_xmit(struct sk_buff
         pkt_data->ifindex = sdata->dev->ifindex;
 	pkt_data->mgmt_iface = (sdata->type == IEEE80211_IF_TYPE_MGMT);
 
-	if ((fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_MGMT &&
-	    (fc & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_PROBE_RESP)
-		pkt_data->pkt_probe_resp = 1;
-
 	skb->priority = 20; /* use hardcoded priority for mgmt TX queue */
 	skb->dev = sdata->local->mdev;
 
@@ -4048,7 +4042,6 @@ static void ieee80211_remove_tx_extra(st
 	pkt_data->mgmt_iface = (control->type == IEEE80211_IF_TYPE_MGMT);
 	pkt_data->req_tx_status = !!(control->flags & IEEE80211_TXCTL_REQ_TX_STATUS);
 	pkt_data->do_not_encrypt = !!(control->flags & IEEE80211_TXCTL_DO_NOT_ENCRYPT);
-	pkt_data->pkt_probe_resp = (control->pkt_type == PKT_PROBE_RESP);
 	pkt_data->requeue = !!(control->flags & IEEE80211_TXCTL_REQUEUE);
 	pkt_data->queue = control->queue;
 
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 5615d6d..a7a4bc9 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -155,10 +155,9 @@ struct ieee80211_tx_packet_data {
 	unsigned long jiffies;
 	unsigned int req_tx_status:1;
 	unsigned int do_not_encrypt:1;
-	unsigned int pkt_probe_resp:1;
 	unsigned int requeue:1;
-	unsigned int queue:4;
 	unsigned int mgmt_iface:1;
+	unsigned int queue:4;
 };
 
 struct ieee80211_tx_stored_packet {
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 04bd5cd..7594022 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -384,7 +384,7 @@ static void ieee80211_set_associated(str
 
 
 static void ieee80211_sta_tx(struct net_device *dev, struct sk_buff *skb,
-			     int encrypt, int probe_resp)
+			     int encrypt)
 {
 	struct ieee80211_sub_if_data *sdata;
 	struct ieee80211_tx_packet_data *pkt_data;
@@ -398,8 +398,6 @@ static void ieee80211_sta_tx(struct net_
 	pkt_data->ifindex = sdata->dev->ifindex;
 	pkt_data->mgmt_iface = (sdata->type == IEEE80211_IF_TYPE_MGMT);
 	pkt_data->do_not_encrypt = !encrypt;
-	if (probe_resp)
-		pkt_data->pkt_probe_resp = 1;
 
 	dev_queue_xmit(skb);
 }
@@ -436,7 +434,7 @@ static void ieee80211_send_auth(struct n
 	if (extra)
 		memcpy(skb_put(skb, extra_len), extra, extra_len);
 
-	ieee80211_sta_tx(dev, skb, encrypt, 0);
+	ieee80211_sta_tx(dev, skb, encrypt);
 }
 
 
@@ -573,7 +571,7 @@ static void ieee80211_send_assoc(struct 
 	if (ifsta->assocreq_ies)
 		memcpy(ifsta->assocreq_ies, ies, ifsta->assocreq_ies_len);
 
-	ieee80211_sta_tx(dev, skb, 0, 0);
+	ieee80211_sta_tx(dev, skb, 0);
 }
 
 
@@ -600,7 +598,7 @@ static void ieee80211_send_deauth(struct
 	skb_put(skb, 2);
 	mgmt->u.deauth.reason_code = cpu_to_le16(reason);
 
-	ieee80211_sta_tx(dev, skb, 0, 0);
+	ieee80211_sta_tx(dev, skb, 0);
 }
 
 
@@ -627,7 +625,7 @@ static void ieee80211_send_disassoc(stru
 	skb_put(skb, 2);
 	mgmt->u.disassoc.reason_code = cpu_to_le16(reason);
 
-	ieee80211_sta_tx(dev, skb, 0, 0);
+	ieee80211_sta_tx(dev, skb, 0);
 }
 
 
@@ -803,7 +801,7 @@ static void ieee80211_send_probe_req(str
 			*pos = rate->rate / 5;
 	}
 
-	ieee80211_sta_tx(dev, skb, 0, 0);
+	ieee80211_sta_tx(dev, skb, 0);
 }
 
 
@@ -1693,7 +1691,7 @@ #ifdef CONFIG_D80211_IBSS_DEBUG
 	printk(KERN_DEBUG "%s: Sending ProbeResp to " MAC_FMT "\n",
 	       dev->name, MAC_ARG(resp->da));
 #endif /* CONFIG_D80211_IBSS_DEBUG */
-	ieee80211_sta_tx(dev, skb, 0, 1);
+	ieee80211_sta_tx(dev, skb, 0);
 }
 
 
@@ -2046,7 +2044,6 @@ static int ieee80211_sta_join_ibss(struc
 		}
 
 		memset(&control, 0, sizeof(control));
-		control.pkt_type = PKT_PROBE_RESP;
 		memset(&extra, 0, sizeof(extra));
 		extra.endidx = local->num_curr_rates;
 		rate = rate_control_get_rate(local, dev, skb, &extra);
-- 
1.3.0

