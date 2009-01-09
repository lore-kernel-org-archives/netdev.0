From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 38/45] hdlcdrv: convert to internal net_device_stats
Date: Fri, 09 Jan 2009 15:01:35 -0800
Message-ID: <20090109230139.553525868@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>, t.sailer@alumni.ethz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42273 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754733AbZAIXSJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:18:09 -0500
Content-Disposition: inline; filename=hdlcdrv-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/hamradio/hdlcdrv.c |   27 +++++++--------------------
 include/linux/hdlcdrv.h        |    1 -
 2 files changed, 7 insertions(+), 21 deletions(-)

--- a/drivers/net/hamradio/hdlcdrv.c	2009-01-09 10:16:50.000000000 -0800
+++ b/drivers/net/hamradio/hdlcdrv.c	2009-01-09 12:52:18.000000000 -0800
@@ -154,7 +154,7 @@ static void hdlc_rx_flag(struct net_devi
 	pkt_len = s->hdlcrx.len - 2 + 1; /* KISS kludge */
 	if (!(skb = dev_alloc_skb(pkt_len))) {
 		printk("%s: memory squeeze, dropping packet\n", dev->name);
-		s->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		return;
 	}
 	cp = skb_put(skb, pkt_len);
@@ -162,7 +162,7 @@ static void hdlc_rx_flag(struct net_devi
 	memcpy(cp, s->hdlcrx.buffer, pkt_len - 1);
 	skb->protocol = ax25_type_trans(skb, dev);
 	netif_rx(skb);
-	s->stats.rx_packets++;
+	dev->stats.rx_packets++;
 }
 
 void hdlcdrv_receiver(struct net_device *dev, struct hdlcdrv_state *s)
@@ -326,7 +326,7 @@ void hdlcdrv_transmitter(struct net_devi
 			s->hdlctx.len = pkt_len+2; /* the appended CRC */
 			s->hdlctx.tx_state = 2;
 			s->hdlctx.bitstream = 0;
-			s->stats.tx_packets++;
+			dev->stats.tx_packets++;
 			break;
 		case 2:
 			if (!s->hdlctx.len) {
@@ -427,19 +427,6 @@ static int hdlcdrv_set_mac_address(struc
 }
 
 /* --------------------------------------------------------------------- */
-
-static struct net_device_stats *hdlcdrv_get_stats(struct net_device *dev)
-{
-	struct hdlcdrv_state *sm = netdev_priv(dev);
-
-	/* 
-	 * Get the current statistics.  This may be called with the
-	 * card open or closed. 
-	 */
-	return &sm->stats;
-}
-
-/* --------------------------------------------------------------------- */
 /*
  * Open/initialize the board. This is called (in the current kernel)
  * sometime after booting when the 'ifconfig' program is run.
@@ -568,10 +555,10 @@ static int hdlcdrv_ioctl(struct net_devi
 		bi.data.cs.ptt = hdlcdrv_ptt(s);
 		bi.data.cs.dcd = s->hdlcrx.dcd;
 		bi.data.cs.ptt_keyed = s->ptt_keyed;
-		bi.data.cs.tx_packets = s->stats.tx_packets;
-		bi.data.cs.tx_errors = s->stats.tx_errors;
-		bi.data.cs.rx_packets = s->stats.rx_packets;
-		bi.data.cs.rx_errors = s->stats.rx_errors;
+		bi.data.cs.tx_packets = dev->stats.tx_packets;
+		bi.data.cs.tx_errors = dev->stats.tx_errors;
+		bi.data.cs.rx_packets = dev->stats.rx_packets;
+		bi.data.cs.rx_errors = dev->stats.rx_errors;
 		break;		
 
 	case HDLCDRVCTL_OLDGETSTAT:
--- a/include/linux/hdlcdrv.h	2009-01-09 10:16:50.000000000 -0800
+++ b/include/linux/hdlcdrv.h	2009-01-09 12:52:18.000000000 -0800
@@ -241,7 +241,6 @@ struct hdlcdrv_state {
 	struct hdlcdrv_bitbuffer bitbuf_hdlc;
 #endif /* HDLCDRV_DEBUG */
 
-	struct net_device_stats stats;
 	int ptt_keyed;
 
 	/* queued skb for transmission */


