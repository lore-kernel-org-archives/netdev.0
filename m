From: Tino Reichardt <milky-kernel@mcmilk.de>
Subject: [PATCH net-next v3 01/07] 8139too: Support for byte queue limits
Date: Sun, 20 Oct 2013 21:23:05 +0200
Message-ID: <1382296991-20289-2-git-send-email-milky-kernel@mcmilk.de>
References: <1382296991-20289-1-git-send-email-milky-kernel@mcmilk.de>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>, Jiri Pirko <jiri@resnulli.us>,
	Bill Pemberton <wfp5p@virginia.edu>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lotte.svc-box.de ([80.252.109.10]:49825 "EHLO lotte.svc-box.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751290Ab3JTTXR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Oct 2013 15:23:17 -0400
In-Reply-To: <1382296991-20289-1-git-send-email-milky-kernel@mcmilk.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes to 8139too driver to use byte queue limits.


Signed-off-by: Tino Reichardt <milky-kernel@mcmilk.de>

---
 drivers/net/ethernet/realtek/8139too.c | 28 +++++++++++++++++++++++-----
 1 file changed, 23 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index 3ccedeb..c17c12f 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -160,6 +160,8 @@ static int multicast_filter_limit = 32;
 /* bitmapped message enable number */
 static int debug = -1;
 
+static bool bql_disable;
+
 /*
  * Receive ring size
  * Warning: 64K ring has hardware issues and may lock up.
@@ -626,10 +628,12 @@ module_param(multicast_filter_limit, int, 0);
 module_param_array(media, int, NULL, 0);
 module_param_array(full_duplex, int, NULL, 0);
 module_param(debug, int, 0);
-MODULE_PARM_DESC (debug, "8139too bitmapped message enable number");
-MODULE_PARM_DESC (multicast_filter_limit, "8139too maximum number of filtered multicast addresses");
-MODULE_PARM_DESC (media, "8139too: Bits 4+9: force full duplex, bit 5: 100Mbps");
-MODULE_PARM_DESC (full_duplex, "8139too: Force full duplex for board(s) (1)");
+module_param(bql_disable, bool, 0);
+MODULE_PARM_DESC(debug, "8139too bitmapped message enable number");
+MODULE_PARM_DESC(multicast_filter_limit, "8139too maximum number of filtered multicast addresses");
+MODULE_PARM_DESC(media, "8139too: Bits 4+9: force full duplex, bit 5: 100Mbps");
+MODULE_PARM_DESC(full_duplex, "8139too: Force full duplex for board(s) (1)");
+MODULE_PARM_DESC(bql_disable, "8139too: Disable Byte Queue Limits functionality (default: false)");
 
 static int read_eeprom (void __iomem *ioaddr, int location, int addr_len);
 static int rtl8139_open (struct net_device *dev);
@@ -1409,6 +1413,8 @@ static void rtl8139_hw_start (struct net_device *dev)
 	}
 
 	netdev_dbg(dev, "init buffer addresses\n");
+	if (unlikely(bql_disable))
+		netdev_reset_queue(dev);
 
 	/* Lock Config[01234] and BMCR register writes */
 	RTL_W8 (Cfg9346, Cfg9346_Lock);
@@ -1639,6 +1645,9 @@ static inline void rtl8139_tx_clear (struct rtl8139_private *tp)
 	tp->cur_tx = 0;
 	tp->dirty_tx = 0;
 
+	if (unlikely(bql_disable))
+		netdev_reset_queue(tp->dev);
+
 	/* XXX account for unsent Tx packets in tp->stats.tx_dropped */
 }
 
@@ -1729,10 +1738,13 @@ static netdev_tx_t rtl8139_start_xmit (struct sk_buff *skb,
 	 * to make sure that the device sees the updated data.
 	 */
 	wmb();
+	len = max_t(unsigned int, len, (unsigned int)ETH_ZLEN);
 	RTL_W32_F (TxStatus0 + (entry * sizeof (u32)),
-		   tp->tx_flag | max(len, (unsigned int)ETH_ZLEN));
+		   tp->tx_flag | len);
 
 	tp->cur_tx++;
+	if (unlikely(bql_disable))
+		netdev_sent_queue(dev, len);
 
 	if ((tp->cur_tx - NUM_TX_DESC) == tp->dirty_tx)
 		netif_stop_queue (dev);
@@ -1750,6 +1762,7 @@ static void rtl8139_tx_interrupt (struct net_device *dev,
 				  void __iomem *ioaddr)
 {
 	unsigned long dirty_tx, tx_left;
+	unsigned bytes_compl = 0, pkts_compl = 0;
 
 	assert (dev != NULL);
 	assert (ioaddr != NULL);
@@ -1792,6 +1805,8 @@ static void rtl8139_tx_interrupt (struct net_device *dev,
 			u64_stats_update_begin(&tp->tx_stats.syncp);
 			tp->tx_stats.packets++;
 			tp->tx_stats.bytes += txstatus & 0x7ff;
+			pkts_compl++;
+			bytes_compl += txstatus & 0x7ff;
 			u64_stats_update_end(&tp->tx_stats.syncp);
 		}
 
@@ -1807,6 +1822,9 @@ static void rtl8139_tx_interrupt (struct net_device *dev,
 	}
 #endif /* RTL8139_NDEBUG */
 
+	if (unlikely(bql_disable))
+		netdev_completed_queue(dev, pkts_compl, bytes_compl);
+
 	/* only wake the queue if we did work, and the queue is stopped */
 	if (tp->dirty_tx != dirty_tx) {
 		tp->dirty_tx = dirty_tx;
-- 
1.8.4.1
