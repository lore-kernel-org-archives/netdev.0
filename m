From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: mac80211: NOHZ: local_softirq_pending 08
Date: Sat, 12 Sep 2009 18:41:12 +0200
Message-ID: <4AABCF28.6090505@hartkopp.net>
References: <200909111648.50902.mb@bu3sch.de> <200909111707.23971.mb@bu3sch.de> <4AAA75CB.6040803@hartkopp.net> <200909111813.35810.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060104030503040505060905"
Cc: Kalle Valo <kalle.valo@iki.fi>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:57001 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753943AbZILQl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Sep 2009 12:41:29 -0400
In-Reply-To: <200909111813.35810.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060104030503040505060905
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit

Michael Buesch wrote:

>> As there are several users in the kernel do exact this test and call the
>> appropriate netif_rx() function, i would suggest to create a static inline
>> function:
>>
>> static inline int netif_rx_ti(struct sk_buff *skb)
>> {
>> 	if (in_interrupt())
>> 		return netif_rx(skb);
>> 	return netif_rx_ni(skb);
>> }
>>
>> ('ti' for test in_interrupt())
>>
>> in include/linux/netdevice.h
>>
>> What do you think about that?
> 
> Yeah, I'm fine with that.
> 

Hi Michael,

i cooked a patch that introduces netif_rx_ti() and fixes up the problems in
mac80211 and the CAN subsystem.

Currently i'm pondering whether netif_rx_ti() is needed in all cases or if
there are code sections that'll never be executed from irq-context.

In theses cases netif_rx_ni() should be prefered to netif_rx_ti() to prevent
the obsolete check ...

Is there any of your changes that should better use netif_rx_ni() ?

Regards,
Oliver

--------------060104030503040505060905
Content-Type: text/x-patch;
 name="net-NOHZ-local_softirq_pending-08.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="net-NOHZ-local_softirq_pending-08.patch"

diff --git a/drivers/net/can/vcan.c b/drivers/net/can/vcan.c
index 6971f6c..899f3d3 100644
--- a/drivers/net/can/vcan.c
+++ b/drivers/net/can/vcan.c
@@ -80,7 +80,7 @@ static void vcan_rx(struct sk_buff *skb, struct net_device *dev)
 	skb->dev       = dev;
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-	netif_rx(skb);
+	netif_rx_ti(skb);
 }
 
 static netdev_tx_t vcan_tx(struct sk_buff *skb, struct net_device *dev)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a44118b..b34c05d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1503,6 +1503,18 @@ extern int		netdev_budget;
 extern void netdev_run_todo(void);
 
 /**
+ *	netif_rx_ti - test for irq context and post buffer to the network code
+ *	@skb: buffer to post
+ *
+ */
+static inline int netif_rx_ti(struct sk_buff *skb)
+{
+	if (in_interrupt())
+		return netif_rx(skb);
+	return netif_rx_ni(skb);
+}
+
+/**
  *	dev_put - release reference to device
  *	@dev: network device
  *
diff --git a/net/can/af_can.c b/net/can/af_can.c
index ef1c43a..c21e7f4 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -278,7 +278,7 @@ int can_send(struct sk_buff *skb, int loop)
 	}
 
 	if (newskb)
-		netif_rx(newskb);
+		netif_rx_ti(newskb);
 
 	/* update statistics */
 	can_stats.tx_frames++;
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 5608f6c..bbcb4cb 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -606,7 +606,7 @@ static void ieee80211_send_layer2_update(struct sta_info *sta)
 	skb->dev = sta->sdata->dev;
 	skb->protocol = eth_type_trans(skb, sta->sdata->dev);
 	memset(skb->cb, 0, sizeof(skb->cb));
-	netif_rx(skb);
+	netif_rx_ti(skb);
 }
 
 static void sta_apply_parameters(struct ieee80211_local *local,
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 797f539..1109f99 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -591,7 +591,7 @@ void ieee80211_tx_status(struct ieee80211_hw *hw, struct sk_buff *skb)
 				skb2 = skb_clone(skb, GFP_ATOMIC);
 				if (skb2) {
 					skb2->dev = prev_dev;
-					netif_rx(skb2);
+					netif_rx_ti(skb2);
 				}
 			}
 
@@ -600,7 +600,7 @@ void ieee80211_tx_status(struct ieee80211_hw *hw, struct sk_buff *skb)
 	}
 	if (prev_dev) {
 		skb->dev = prev_dev;
-		netif_rx(skb);
+		netif_rx_ti(skb);
 		skb = NULL;
 	}
 	rcu_read_unlock();
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index c01588f..5bb7c04 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -309,7 +309,7 @@ ieee80211_rx_monitor(struct ieee80211_local *local, struct sk_buff *origskb,
 			skb2 = skb_clone(skb, GFP_ATOMIC);
 			if (skb2) {
 				skb2->dev = prev_dev;
-				netif_rx(skb2);
+				netif_rx_ti(skb2);
 			}
 		}
 
@@ -320,7 +320,7 @@ ieee80211_rx_monitor(struct ieee80211_local *local, struct sk_buff *origskb,
 
 	if (prev_dev) {
 		skb->dev = prev_dev;
-		netif_rx(skb);
+		netif_rx_ti(skb);
 	} else
 		dev_kfree_skb(skb);
 
@@ -1349,7 +1349,7 @@ ieee80211_deliver_skb(struct ieee80211_rx_data *rx)
 			/* deliver to local stack */
 			skb->protocol = eth_type_trans(skb, dev);
 			memset(skb->cb, 0, sizeof(skb->cb));
-			netif_rx(skb);
+			netif_rx_ti(skb);
 		}
 	}
 
@@ -1943,7 +1943,7 @@ static void ieee80211_rx_cooked_monitor(struct ieee80211_rx_data *rx)
 			skb2 = skb_clone(skb, GFP_ATOMIC);
 			if (skb2) {
 				skb2->dev = prev_dev;
-				netif_rx(skb2);
+				netif_rx_ti(skb2);
 			}
 		}
 
@@ -1954,7 +1954,7 @@ static void ieee80211_rx_cooked_monitor(struct ieee80211_rx_data *rx)
 
 	if (prev_dev) {
 		skb->dev = prev_dev;
-		netif_rx(skb);
+		netif_rx_ti(skb);
 		skb = NULL;
 	} else
 		goto out_free_skb;

--------------060104030503040505060905--
