From: Tino Reichardt <milky-kernel@mcmilk.de>
Subject: [PATCH 01/07] 8139too: Support for byte queue limits
Date: Mon, 14 Oct 2013 20:26:17 +0200
Message-ID: <1381775183-24866-2-git-send-email-milky-kernel@mcmilk.de>
References: <1381775183-24866-1-git-send-email-milky-kernel@mcmilk.de>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>, Jiri Pirko <jiri@resnulli.us>,
	Bill Pemberton <wfp5p@virginia.edu>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lotte.svc-box.de ([80.252.109.10]:35488 "EHLO lotte.svc-box.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757037Ab3JNSfx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Oct 2013 14:35:53 -0400
In-Reply-To: <1381775183-24866-1-git-send-email-milky-kernel@mcmilk.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes to 8139too to use byte queue limits.

This patch was not tested on real hardware currently, but compiles fine and
should work.


Signed-off-by: Tino Reichardt <milky-kernel@mcmilk.de>

---
 drivers/net/ethernet/realtek/8139too.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index 3ccedeb..992ac57 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -1409,6 +1409,7 @@ static void rtl8139_hw_start (struct net_device *dev)
 	}
 
 	netdev_dbg(dev, "init buffer addresses\n");
+	netdev_reset_queue(dev);
 
 	/* Lock Config[01234] and BMCR register writes */
 	RTL_W8 (Cfg9346, Cfg9346_Lock);
@@ -1638,6 +1639,7 @@ static inline void rtl8139_tx_clear (struct rtl8139_private *tp)
 {
 	tp->cur_tx = 0;
 	tp->dirty_tx = 0;
+	netdev_reset_queue(tp->dev);
 
 	/* XXX account for unsent Tx packets in tp->stats.tx_dropped */
 }
@@ -1733,6 +1735,7 @@ static netdev_tx_t rtl8139_start_xmit (struct sk_buff *skb,
 		   tp->tx_flag | max(len, (unsigned int)ETH_ZLEN));
 
 	tp->cur_tx++;
+	netdev_sent_queue(dev, len);
 
 	if ((tp->cur_tx - NUM_TX_DESC) == tp->dirty_tx)
 		netif_stop_queue (dev);
@@ -1750,6 +1753,7 @@ static void rtl8139_tx_interrupt (struct net_device *dev,
 				  void __iomem *ioaddr)
 {
 	unsigned long dirty_tx, tx_left;
+	unsigned bytes_compl = 0, pkts_compl = 0;
 
 	assert (dev != NULL);
 	assert (ioaddr != NULL);
@@ -1792,6 +1796,8 @@ static void rtl8139_tx_interrupt (struct net_device *dev,
 			u64_stats_update_begin(&tp->tx_stats.syncp);
 			tp->tx_stats.packets++;
 			tp->tx_stats.bytes += txstatus & 0x7ff;
+			pkts_compl++;
+			bytes_compl += txstatus & 0x7ff;
 			u64_stats_update_end(&tp->tx_stats.syncp);
 		}
 
@@ -1807,6 +1813,8 @@ static void rtl8139_tx_interrupt (struct net_device *dev,
 	}
 #endif /* RTL8139_NDEBUG */
 
+	netdev_completed_queue(dev, pkts_compl, bytes_compl);
+
 	/* only wake the queue if we did work, and the queue is stopped */
 	if (tp->dirty_tx != dirty_tx) {
 		tp->dirty_tx = dirty_tx;
-- 
1.8.4
