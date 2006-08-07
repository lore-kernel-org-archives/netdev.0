From: Jouni Malinen <jkm@devicescape.com>
Subject: [PATCH wireless-dev 5/6] d80211: Fix ieee80211_remove_tx_extra() if key not configured
Date: Mon, 07 Aug 2006 16:16:13 -0700
Message-ID: <20060807231938.892291916@localhost>
References: <20060807231608.888744720@localhost>
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	jkm@devicescape.com, jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-17.dex002.intermedia.net ([64.78.21.83]:370 "EHLO
	dhost002-17.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S932338AbWHGX05 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 19:26:57 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline; filename=remove_tx_extra.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

QoS header processing mangled unencrypted WMM frames on software
retry. The QoS data needs to be removed even when encryption key is
not configured.

Signed-off-by: Jouni Malinen <jkm@devicescape.com>

Index: wireless-dev/net/d80211/ieee80211.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211.c
+++ wireless-dev/net/d80211/ieee80211.c
@@ -3977,11 +3977,11 @@ static void ieee80211_remove_tx_extra(st
 	pkt_data->requeue = control->requeue;
 	pkt_data->queue = control->queue;
 
-	if (key == NULL)
-		return;
-
 	hdrlen = ieee80211_get_hdrlen_from_skb(skb);
 
+	if (key == NULL)
+		goto no_key;
+
 	switch (key->alg) {
 	case ALG_WEP:
 		iv_len = WEP_IV_LEN;
@@ -3996,7 +3996,7 @@ static void ieee80211_remove_tx_extra(st
 		mic_len = CCMP_MIC_LEN;
 		break;
 	default:
-		return;
+		goto no_key;
 	}
 
 	if (skb->len >= mic_len && key->force_sw_encrypt)
@@ -4006,6 +4006,7 @@ static void ieee80211_remove_tx_extra(st
 		skb_pull(skb, iv_len);
 	}
 
+no_key:
 	{
 		struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
 		u16 fc = le16_to_cpu(hdr->frame_control);

--
-- 
Jouni Malinen                                            PGP id EFC895FA
