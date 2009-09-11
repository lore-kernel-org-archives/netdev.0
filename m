From: Michael Buesch <mb@bu3sch.de>
Subject: Re: mac80211: NOHZ: local_softirq_pending 08
Date: Fri, 11 Sep 2009 17:07:23 +0200
Message-ID: <200909111707.23971.mb@bu3sch.de>
References: <200909111648.50902.mb@bu3sch.de> <877hw534wd.fsf@litku.valot.fi>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>
To: Kalle Valo <kalle.valo@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bu3sch.de ([62.75.166.246]:39927 "EHLO vs166246.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752605AbZIKPIN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2009 11:08:13 -0400
In-Reply-To: <877hw534wd.fsf@litku.valot.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 11 September 2009 16:57:54 Kalle Valo wrote:
> Michael Buesch <mb@bu3sch.de> writes:
> 
> > Hi,
> 
> Hallo,
> 
> > mac80211 (or some other part of the networking stack) triggers this
> > warning in the NOHZ code: NOHZ: local_softirq_pending 08
> >
> > 08 seems to be NET_RX_SOFTIRQ.
> >
> > It happens, because my test driver b43 handles all RX and TX-status
> > callbacks in process context. I guess some part of the networking
> > stack expects RX to be in tasklet and/or softirq context.
> >
> > We also have a report of this warning in wl1251, so it's probably not
> > a b43 problem.
> 
> Yes, I see this with wl1251. It uses workqueues everywhere.
> 

This patch seems to fix it.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: wireless-testing/net/mac80211/cfg.c
===================================================================
--- wireless-testing.orig/net/mac80211/cfg.c	2009-08-09 18:47:11.000000000 +0200
+++ wireless-testing/net/mac80211/cfg.c	2009-09-11 16:59:12.000000000 +0200
@@ -606,7 +606,7 @@ static void ieee80211_send_layer2_update
 	skb->dev = sta->sdata->dev;
 	skb->protocol = eth_type_trans(skb, sta->sdata->dev);
 	memset(skb->cb, 0, sizeof(skb->cb));
-	netif_rx(skb);
+	ieee80211_netif_rx(skb);
 }
 
 static void sta_apply_parameters(struct ieee80211_local *local,
Index: wireless-testing/net/mac80211/ieee80211_i.h
===================================================================
--- wireless-testing.orig/net/mac80211/ieee80211_i.h	2009-08-23 00:06:41.000000000 +0200
+++ wireless-testing/net/mac80211/ieee80211_i.h	2009-09-11 17:02:05.000000000 +0200
@@ -1053,6 +1053,14 @@ void ieee80211_tx_pending(unsigned long 
 int ieee80211_monitor_start_xmit(struct sk_buff *skb, struct net_device *dev);
 int ieee80211_subif_start_xmit(struct sk_buff *skb, struct net_device *dev);
 
+/* rx handling */
+static inline int ieee80211_netif_rx(struct sk_buff *skb)
+{
+	if (in_interrupt())
+		return netif_rx(skb);
+	return netif_rx_ni(skb);
+}
+
 /* HT */
 void ieee80211_ht_cap_ie_to_sta_ht_cap(struct ieee80211_supported_band *sband,
 				       struct ieee80211_ht_cap *ht_cap_ie,
Index: wireless-testing/net/mac80211/main.c
===================================================================
--- wireless-testing.orig/net/mac80211/main.c	2009-08-23 00:06:41.000000000 +0200
+++ wireless-testing/net/mac80211/main.c	2009-09-11 16:59:35.000000000 +0200
@@ -591,7 +591,7 @@ void ieee80211_tx_status(struct ieee8021
 				skb2 = skb_clone(skb, GFP_ATOMIC);
 				if (skb2) {
 					skb2->dev = prev_dev;
-					netif_rx(skb2);
+					ieee80211_netif_rx(skb2);
 				}
 			}
 
@@ -600,7 +600,7 @@ void ieee80211_tx_status(struct ieee8021
 	}
 	if (prev_dev) {
 		skb->dev = prev_dev;
-		netif_rx(skb);
+		ieee80211_netif_rx(skb);
 		skb = NULL;
 	}
 	rcu_read_unlock();
Index: wireless-testing/net/mac80211/rx.c
===================================================================
--- wireless-testing.orig/net/mac80211/rx.c	2009-09-04 19:08:05.000000000 +0200
+++ wireless-testing/net/mac80211/rx.c	2009-09-11 17:00:08.000000000 +0200
@@ -309,7 +309,7 @@ ieee80211_rx_monitor(struct ieee80211_lo
 			skb2 = skb_clone(skb, GFP_ATOMIC);
 			if (skb2) {
 				skb2->dev = prev_dev;
-				netif_rx(skb2);
+				ieee80211_netif_rx(skb2);
 			}
 		}
 
@@ -320,7 +320,7 @@ ieee80211_rx_monitor(struct ieee80211_lo
 
 	if (prev_dev) {
 		skb->dev = prev_dev;
-		netif_rx(skb);
+		ieee80211_netif_rx(skb);
 	} else
 		dev_kfree_skb(skb);
 
@@ -1349,7 +1349,7 @@ ieee80211_deliver_skb(struct ieee80211_r
 			/* deliver to local stack */
 			skb->protocol = eth_type_trans(skb, dev);
 			memset(skb->cb, 0, sizeof(skb->cb));
-			netif_rx(skb);
+			ieee80211_netif_rx(skb);
 		}
 	}
 
@@ -1943,7 +1943,7 @@ static void ieee80211_rx_cooked_monitor(
 			skb2 = skb_clone(skb, GFP_ATOMIC);
 			if (skb2) {
 				skb2->dev = prev_dev;
-				netif_rx(skb2);
+				ieee80211_netif_rx(skb2);
 			}
 		}
 
@@ -1954,7 +1954,7 @@ static void ieee80211_rx_cooked_monitor(
 
 	if (prev_dev) {
 		skb->dev = prev_dev;
-		netif_rx(skb);
+		ieee80211_netif_rx(skb);
 		skb = NULL;
 	} else
 		goto out_free_skb;


-- 
Greetings, Michael.
