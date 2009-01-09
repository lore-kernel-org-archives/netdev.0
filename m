From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 22/45] ibmtr: convert to internal network_device_stats
Date: Fri, 09 Jan 2009 15:01:19 -0800
Message-ID: <20090109230138.344948381@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42209 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754239AbZAIXR6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:17:58 -0500
Content-Disposition: inline; filename=ibmtr-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/tokenring/ibmtr.c |   29 ++++++-----------------------
 include/linux/ibmtr.h         |    2 +-
 2 files changed, 7 insertions(+), 24 deletions(-)

--- a/drivers/net/tokenring/ibmtr.c	2009-01-09 13:53:36.000000000 -0800
+++ b/drivers/net/tokenring/ibmtr.c	2009-01-09 13:54:29.000000000 -0800
@@ -200,7 +200,6 @@ static void 	tr_rx(struct net_device *de
 static void	ibmtr_reset_timer(struct timer_list*tmr,struct net_device *dev);
 static void	tok_rerun(unsigned long dev_addr);
 static void	ibmtr_readlog(struct net_device *dev);
-static struct 	net_device_stats *tok_get_stats(struct net_device *dev);
 static int	ibmtr_change_mtu(struct net_device *dev, int mtu);
 static void	find_turbo_adapters(int *iolist);
 
@@ -825,7 +824,6 @@ static int __devinit trdev_init(struct n
 	dev->open = tok_open;
 	dev->stop = tok_close;
 	dev->hard_start_xmit = tok_send_packet;
-	dev->get_stats = tok_get_stats;
 	dev->set_multicast_list = tok_set_multicast_list;
 	dev->change_mtu = ibmtr_change_mtu;
 
@@ -1460,7 +1458,7 @@ static irqreturn_t tok_interrupt(int irq
 					"%02X\n",
 					(int)retcode, (int)readb(ti->ssb + 6));
 			else
-				ti->tr_stats.tx_packets++;
+				dev->stats.tx_packets++;
 			break;
 		case XMIT_XID_CMD:
 			DPRINTK("xmit xid ret_code: %02X\n",
@@ -1646,7 +1644,7 @@ static void tr_tx(struct net_device *dev
 		break;
 	}
 	writeb(RESP_IN_ASB, ti->mmio + ACA_OFFSET + ACA_SET + ISRA_ODD);
-	ti->tr_stats.tx_bytes += ti->current_skb->len;
+	dev->stats.tx_bytes += ti->current_skb->len;
 	dev_kfree_skb_irq(ti->current_skb);
 	ti->current_skb = NULL;
 	netif_wake_queue(dev);
@@ -1722,7 +1720,7 @@ static void tr_rx(struct net_device *dev
 	if (readb(llc + offsetof(struct trllc, llc)) != UI_CMD) {
 		SET_PAGE(ti->asb_page);
 		writeb(DATA_LOST, ti->asb + RETCODE_OFST);
-		ti->tr_stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		writeb(RESP_IN_ASB, ti->mmio + ACA_OFFSET + ACA_SET + ISRA_ODD);
 		return;
 	}
@@ -1757,7 +1755,7 @@ static void tr_rx(struct net_device *dev
 
 	if (!(skb = dev_alloc_skb(skb_size))) {
 		DPRINTK("out of memory. frame dropped.\n");
-		ti->tr_stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		SET_PAGE(ti->asb_page);
 		writeb(DATA_LOST, ti->asb + offsetof(struct asb_rec, ret_code));
 		writeb(RESP_IN_ASB, ti->mmio + ACA_OFFSET + ACA_SET + ISRA_ODD);
@@ -1813,8 +1811,8 @@ static void tr_rx(struct net_device *dev
 
 	writeb(RESP_IN_ASB, ti->mmio + ACA_OFFSET + ACA_SET + ISRA_ODD);
 
-	ti->tr_stats.rx_bytes += skb->len;
-	ti->tr_stats.rx_packets++;
+	dev->stats.rx_bytes += skb->len;
+	dev->stats.rx_packets++;
 
 	skb->protocol = tr_type_trans(skb, dev);
 	if (IPv4_p) {
@@ -1876,21 +1874,6 @@ static void ibmtr_readlog(struct net_dev
 
 /*****************************************************************************/
 
-/* tok_get_stats():  Basically a scaffold routine which will return
-   the address of the tr_statistics structure associated with
-   this device -- the tr.... structure is an ethnet look-alike
-   so at least for this iteration may suffice.   */
-
-static struct net_device_stats *tok_get_stats(struct net_device *dev)
-{
-
-	struct tok_info *toki;
-	toki = netdev_priv(dev);
-	return (struct net_device_stats *) &toki->tr_stats;
-}
-
-/*****************************************************************************/
-
 static int ibmtr_change_mtu(struct net_device *dev, int mtu)
 {
 	struct tok_info *ti = netdev_priv(dev);
--- a/include/linux/ibmtr.h	2009-01-09 13:53:36.000000000 -0800
+++ b/include/linux/ibmtr.h	2009-01-09 13:53:57.000000000 -0800
@@ -207,7 +207,7 @@ struct tok_info {
 	unsigned short exsap_station_id;
 	unsigned short global_int_enable;
 	struct sk_buff *current_skb;
-	struct net_device_stats tr_stats;
+
 	unsigned char auto_speedsave;
 	open_state			open_status, sap_status;
 	enum {MANUAL, AUTOMATIC}	open_mode;


