From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Subject: [PATCH 1/11] [IEEE80211]: Check ieee80211softmac_auth_resp kmalloc result
Date: Tue, 21 Nov 2006 01:26:49 -0200
Message-ID: <20061121032648.GB7039@mandriva.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mandriva.com ([212.85.150.183]:3821 "EHLO mx1.mandriva.com")
	by vger.kernel.org with ESMTP id S1030681AbWKUD1J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 22:27:09 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

And use kmemdup and kzalloc where applicable

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/ieee80211/ieee80211_module.c              |    5 +----
 net/ieee80211/ieee80211_rx.c                  |    7 +++----
 net/ieee80211/softmac/ieee80211softmac_auth.c |   14 ++++++++++----
 3 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/net/ieee80211/ieee80211_module.c b/net/ieee80211/ieee80211_module.c
index 13b1e5f..0610ee7 100644
--- a/net/ieee80211/ieee80211_module.c
+++ b/net/ieee80211/ieee80211_module.c
@@ -67,7 +67,7 @@ static int ieee80211_networks_allocate(s
 		return 0;
 
 	ieee->networks =
-	    kmalloc(MAX_NETWORK_COUNT * sizeof(struct ieee80211_network),
+	    kzalloc(MAX_NETWORK_COUNT * sizeof(struct ieee80211_network),
 		    GFP_KERNEL);
 	if (!ieee->networks) {
 		printk(KERN_WARNING "%s: Out of memory allocating beacons\n",
@@ -75,9 +75,6 @@ static int ieee80211_networks_allocate(s
 		return -ENOMEM;
 	}
 
-	memset(ieee->networks, 0,
-	       MAX_NETWORK_COUNT * sizeof(struct ieee80211_network));
-
 	return 0;
 }
 
diff --git a/net/ieee80211/ieee80211_rx.c b/net/ieee80211/ieee80211_rx.c
index 2759312..f12c28a 100644
--- a/net/ieee80211/ieee80211_rx.c
+++ b/net/ieee80211/ieee80211_rx.c
@@ -1255,12 +1255,11 @@ #endif
 		case MFIE_TYPE_IBSS_DFS:
 			if (network->ibss_dfs)
 				break;
-			network->ibss_dfs =
-			    kmalloc(info_element->len, GFP_ATOMIC);
+			network->ibss_dfs = kmemdup(info_element->data,
+						    info_element->len,
+						    GFP_ATOMIC);
 			if (!network->ibss_dfs)
 				return 1;
-			memcpy(network->ibss_dfs, info_element->data,
-			       info_element->len);
 			network->flags |= NETWORK_HAS_IBSS_DFS;
 			break;
 
diff --git a/net/ieee80211/softmac/ieee80211softmac_auth.c b/net/ieee80211/softmac/ieee80211softmac_auth.c
index 4cef39e..bd4a54c 100644
--- a/net/ieee80211/softmac/ieee80211softmac_auth.c
+++ b/net/ieee80211/softmac/ieee80211softmac_auth.c
@@ -216,10 +216,16 @@ ieee80211softmac_auth_resp(struct net_de
 			net->challenge_len = *data++; 	
 			if (net->challenge_len > WLAN_AUTH_CHALLENGE_LEN)
 				net->challenge_len = WLAN_AUTH_CHALLENGE_LEN;
-			if (net->challenge != NULL)
-				kfree(net->challenge);
-			net->challenge = kmalloc(net->challenge_len, GFP_ATOMIC);
-			memcpy(net->challenge, data, net->challenge_len);
+			kfree(net->challenge);
+			net->challenge = kmemdup(data, net->challenge_len,
+						 GFP_ATOMIC);
+			if (net->challenge == NULL) {
+				printkl(KERN_NOTICE PFX "Shared Key "
+					"Authentication failed due to "
+					"memory shortage.\n");
+				spin_unlock_irqrestore(&mac->lock, flags);
+				break;
+			}
 			aq->state = IEEE80211SOFTMAC_AUTH_SHARED_RESPONSE; 
 
 			/* We reuse the work struct from the auth request here.
-- 
1.4.2.1.g3d5c

