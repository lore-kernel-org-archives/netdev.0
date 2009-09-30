From: Oliver Hartkopp <oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH] net: fix NOHZ: local_softirq_pending 08
Date: Wed, 30 Sep 2009 20:18:25 +0200
Message-ID: <4AC3A0F1.3060306@hartkopp.net>
References: <200909111648.50902.mb@bu3sch.de>	 <87ocosqykb.fsf@purkki.valot.fi> <1254322466.3959.5.camel@johannes.local>	 <200909301710.31082.mb@bu3sch.de> <1254324077.3959.7.camel@johannes.local> <4AC39A90.6060602@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030607090101020402060209"
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, Kalle Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4AC39A90.6060602-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030607090101020402060209
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Socket buffers that are generated and received inside softirqs or from process
context must not use netif_rx() that's intended to be used from irq context only.

This patch introduces a new helper function netif_rx_ti(skb) that tests for
in_interrupt() before invoking netif_rx() or netif_rx_ni().

It fixes the ratelimited kernel warning

        NOHZ: local_softirq_pending 08

in the mac80211 and can subsystems.

Signed-off-by: Oliver Hartkopp <oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>

---




--------------030607090101020402060209
Content-Type: text/x-patch;
 name="net-NOHZ-local_softirq_pending-08.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="net-NOHZ-local_softirq_pending-08.patch"

diff --git a/drivers/net/can/vcan.c b/drivers/net/can/vcan.c
index 80ac563..899f3d3 100644
--- a/drivers/net/can/vcan.c
+++ b/drivers/net/can/vcan.c
@@ -80,7 +80,7 @@ static void vcan_rx(struct sk_buff *skb, struct net_device *dev)
 	skb->dev       = dev;
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-	netif_rx_ni(skb);
+	netif_rx_ti(skb);
 }
 
 static netdev_tx_t vcan_tx(struct sk_buff *skb, struct net_device *dev)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 94958c1..dc8dfb2 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1509,6 +1509,19 @@ extern int		netdev_budget;
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
+	else
+		return netif_rx_ni(skb);
+}
+
+/**
  *	dev_put - release reference to device
  *	@dev: network device
  *
diff --git a/net/can/af_can.c b/net/can/af_can.c
index 6068321..c21e7f4 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -199,8 +199,6 @@ static int can_create(struct net *net, struct socket *sock, int protocol)
  * @skb: pointer to socket buffer with CAN frame in data section
  * @loop: loopback for listeners on local CAN sockets (recommended default!)
  *
- * Due to the loopback this routine must not be called from hardirq context.
- *
  * Return:
  *  0 on success
  *  -ENETDOWN when the selected interface is down
@@ -280,7 +278,7 @@ int can_send(struct sk_buff *skb, int loop)
 	}
 
 	if (newskb)
-		netif_rx_ni(newskb);
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

--------------030607090101020402060209--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
