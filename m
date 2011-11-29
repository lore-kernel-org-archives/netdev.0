From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] sky2: add bql support
Date: Mon, 28 Nov 2011 20:19:07 -0800
Message-ID: <20111128201907.6d31d4c3@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59032 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751827Ab1K2ETK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Nov 2011 23:19:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just for testing, here is how to add BQL support to sky2

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/ethernet/marvell/sky2.c	2011-11-23 12:00:14.953964611 -0800
+++ b/drivers/net/ethernet/marvell/sky2.c	2011-11-23 12:17:40.269120465 -0800
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
 
+	netdev_sent_queue(dev, 1, skb->len);
 	sky2_put_idx(hw, txqaddr[sky2->port], sky2->tx_prod);
 
 	return NETDEV_TX_OK;
@@ -2022,6 +2024,8 @@ static void sky2_tx_complete(struct sky2
 			sky2->tx_stats.bytes += skb->len;
 			u64_stats_update_end(&sky2->tx_stats.syncp);
 
+			netdev_completed_queue(dev, 1, skb->len);
+
 			re->skb = NULL;
 			dev_kfree_skb_any(skb);
 
