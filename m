From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: [PATCH wireless-2.6 2/12] Host AP: Fix interface packet counters
Date: Sun, 7 Nov 2004 23:11:32 -0800
Message-ID: <20041108071132.GC1076@jm.kir.nu>
References: <20041108070156.GA1076@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20041108070156.GA1076@jm.kir.nu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fix wlan#/wifi# interface packet counters (both are supposed to see
data packets once; wlan# was counting TX twice and wifi# did not count
TX or RX at all for most cases).

Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>


diff -Nru a/drivers/net/wireless/hostap/hostap_80211_rx.c b/drivers/net/wireless/hostap/hostap_80211_rx.c
--- a/drivers/net/wireless/hostap/hostap_80211_rx.c	2004-11-07 22:37:59 -08:00
+++ b/drivers/net/wireless/hostap/hostap_80211_rx.c	2004-11-07 22:37:59 -08:00
@@ -689,6 +689,9 @@
 	void *sta = NULL;
 	int keyidx = 0;
 
+	iface->stats.rx_packets++;
+	iface->stats.rx_bytes += skb->len;
+
 	/* dev is the master radio device; change this to be the default
 	 * virtual interface (this may be changed to WDS device below) */
 	dev = local->ddev;
diff -Nru a/drivers/net/wireless/hostap/hostap_80211_tx.c b/drivers/net/wireless/hostap/hostap_80211_tx.c
--- a/drivers/net/wireless/hostap/hostap_80211_tx.c	2004-11-07 22:37:59 -08:00
+++ b/drivers/net/wireless/hostap/hostap_80211_tx.c	2004-11-07 22:37:59 -08:00
@@ -379,7 +379,7 @@
 		printk(KERN_DEBUG "%s: hostap_master_start_xmit: short skb "
 		       "(len=%d)\n", dev->name, skb->len);
 		ret = 0;
-		meta->iface->stats.tx_dropped++;
+		iface->stats.tx_dropped++;
 		goto fail;
 	}
 
@@ -405,13 +405,13 @@
 			hostap_dump_tx_80211(dev->name, skb);
 
 			ret = 0; /* drop packet */
-			meta->iface->stats.tx_dropped++;
+			iface->stats.tx_dropped++;
 			goto fail;
 		}
 		break;
 	case AP_TX_DROP:
 		ret = 0; /* drop packet */
-		meta->iface->stats.tx_dropped++;
+		iface->stats.tx_dropped++;
 		goto fail;
 	case AP_TX_RETRY:
 		goto fail;
@@ -488,11 +488,11 @@
 
 	if (local->func->tx == NULL || local->func->tx(skb, dev)) {
 		ret = 0;
-		meta->iface->stats.tx_dropped++;
+		iface->stats.tx_dropped++;
 	} else {
 		ret = 0;
-		meta->iface->stats.tx_packets++;
-		meta->iface->stats.tx_bytes += skb->len;
+		iface->stats.tx_packets++;
+		iface->stats.tx_bytes += skb->len;
 	}
 
  fail:


-- 
Jouni Malinen                                            PGP id EFC895FA
