From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] sky2: add bql support
Date: Tue, 29 Nov 2011 17:15:33 -0800
Message-ID: <20111129171533.146cec9f@nehalam.linuxnetplumber.net>
References: <20111128201907.6d31d4c3@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36092 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756530Ab1K3BPg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Nov 2011 20:15:36 -0500
In-Reply-To: <20111128201907.6d31d4c3@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for byte queue limits and aggregates statistics
update (suggestion from Eric).

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/ethernet/marvell/sky2.c	2011-11-28 19:37:50.739557687 -0800
+++ b/drivers/net/ethernet/marvell/sky2.c	2011-11-29 16:44:52.786657199 -0800
@@ -1110,6 +1110,7 @@ static void tx_init(struct sky2_port *sk
 	sky2->tx_prod = sky2->tx_cons = 0;
 	sky2->tx_tcpsum = 0;
 	sky2->tx_last_mss = 0;
+	netdev_reset_queue(sky2->netdev);
 
 	le = get_tx_le(sky2, &sky2->tx_prod);
 	le->addr = 0;
@@ -1971,6 +1972,7 @@ static netdev_tx_t sky2_xmit_frame(struc
 	if (tx_avail(sky2) <= MAX_SKB_TX_LE)
 		netif_stop_queue(dev);
 
+	netdev_sent_queue(dev, skb->len);
 	sky2_put_idx(hw, txqaddr[sky2->port], sky2->tx_prod);
 
 	return NETDEV_TX_OK;
@@ -2002,7 +2004,8 @@ mapping_error:
 static void sky2_tx_complete(struct sky2_port *sky2, u16 done)
 {
 	struct net_device *dev = sky2->netdev;
-	unsigned idx;
+	u16 idx;
+	unsigned int bytes_compl = 0, pkts_compl = 0;
 
 	BUG_ON(done >= sky2->tx_ring_size);
 
@@ -2017,10 +2020,8 @@ static void sky2_tx_complete(struct sky2
 			netif_printk(sky2, tx_done, KERN_DEBUG, dev,
 				     "tx done %u\n", idx);
 
-			u64_stats_update_begin(&sky2->tx_stats.syncp);
-			++sky2->tx_stats.packets;
-			sky2->tx_stats.bytes += skb->len;
-			u64_stats_update_end(&sky2->tx_stats.syncp);
+			pkts_compl++;
+			bytes_compl += skb->len;
 
 			re->skb = NULL;
 			dev_kfree_skb_any(skb);
@@ -2031,6 +2032,13 @@ static void sky2_tx_complete(struct sky2
 
 	sky2->tx_cons = idx;
 	smp_mb();
+
+	netdev_completed_queue(dev, pkts_compl, bytes_compl);
+
+	u64_stats_update_begin(&sky2->tx_stats.syncp);
+	sky2->tx_stats.packets += pkts_compl;
+	sky2->tx_stats.bytes += bytes_compl;
+	u64_stats_update_end(&sky2->tx_stats.syncp);
 }
 
 static void sky2_tx_reset(struct sky2_hw *hw, unsigned port)
