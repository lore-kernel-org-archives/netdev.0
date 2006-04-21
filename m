From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 4/10] d80211: don't use pointer in ieee80211_tx_control
Date: Fri, 21 Apr 2006 22:53:24 +0200 (CEST)
Message-ID: <20060421205324.0F6A4482C0@silver.suse.cz>
References: <20060421225314.048983000.midnight@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:45953 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932442AbWDUUwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 16:52:55 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060421225314.048983000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A problem similar to the one with ieee80211_sub_if_data and skb->cb happens
to ieee80211_sub_if_data and ieee80211_tx_control. When originating
interface is removed while packet is sent to the driver, bad things will
happen. Use ifindex instead.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 include/net/d80211.h   |    3 ++-
 net/d80211/ieee80211.c |   12 +++++++-----
 2 files changed, 9 insertions(+), 6 deletions(-)

2f1956069a10abdc9a1d4f38ba413ae511428224
diff --git a/include/net/d80211.h b/include/net/d80211.h
index e44e21c..3943e30 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -185,7 +185,8 @@ struct ieee80211_tx_control {
 			     * struct ieee80211_rate). To be used to limit
 			     * packet dropping when probing higher rates, if hw
 			     * supports multiple retry rates. -1 = not used */
-	struct ieee80211_sub_if_data *sdata; /* internal */
+	int type;	/* internal */
+	int ifindex;	/* internal */
 };
 
 #define RX_FLAG_MMIC_ERROR       0x1
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index f768de5..425bd51 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -1242,7 +1242,7 @@ static int ieee80211_master_start_xmit(s
 	struct ieee80211_tx_control control;
 	struct ieee80211_tx_packet_data *pkt_data;
 	struct net_device *odev = NULL;
-	struct ieee80211_sub_if_data *sdata;
+	struct ieee80211_sub_if_data *sdata, *osdata;
 	int ret;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
@@ -1267,8 +1267,10 @@ #endif
 		dev_kfree_skb(skb);
 		return 0;
 	}
+	osdata = IEEE80211_DEV_TO_SUB_IF(odev);
 
-	control.sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	control.ifindex = odev->ifindex;
+	control.type = osdata->type;
 	control.req_tx_status = pkt_data->req_tx_status;
 	control.do_not_encrypt = pkt_data->do_not_encrypt;
 	control.pkt_type =
@@ -1277,7 +1279,7 @@ #endif
 	control.queue = pkt_data->queue;
 
 	ret = ieee80211_tx(odev, skb, &control,
-			   control.sdata->type == IEEE80211_IF_TYPE_MGMT);
+			   control.type == IEEE80211_IF_TYPE_MGMT);
 	dev_put(odev);
 
         return ret;
@@ -3694,8 +3696,8 @@ static void ieee80211_remove_tx_extra(st
 	struct ieee80211_tx_packet_data *pkt_data;
 
 	pkt_data = (struct ieee80211_tx_packet_data *)skb->cb;
-	pkt_data->ifindex = control->sdata->dev->ifindex;
-	pkt_data->mgmt_iface = (control->sdata->type == IEEE80211_IF_TYPE_MGMT);
+	pkt_data->ifindex = control->ifindex;
+	pkt_data->mgmt_iface = (control->type == IEEE80211_IF_TYPE_MGMT);
 	pkt_data->req_tx_status = control->req_tx_status;
 	pkt_data->do_not_encrypt = control->do_not_encrypt;
 	pkt_data->pkt_probe_resp = (control->pkt_type == PKT_PROBE_RESP);
-- 
1.3.0

