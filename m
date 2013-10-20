From: Tino Reichardt <milky-kernel@mcmilk.de>
Subject: [PATCH net-next v2 02/07] r8169: Support for byte queue limits
Date: Sun, 20 Oct 2013 20:13:18 +0200
Message-ID: <1382292803-18875-3-git-send-email-milky-kernel@mcmilk.de>
References: <1382292803-18875-1-git-send-email-milky-kernel@mcmilk.de>
To: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Igor Maravic <igorm@etf.rs>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lotte.svc-box.de ([80.252.109.10]:45373 "EHLO lotte.svc-box.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750949Ab3JTSNc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Oct 2013 14:13:32 -0400
In-Reply-To: <1382292803-18875-1-git-send-email-milky-kernel@mcmilk.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes to r8169 driver to use byte queue limits.


Signed-off-by: Tino Reichardt <milky-kernel@mcmilk.de>

---
 drivers/net/ethernet/realtek/r8169.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 3397cee..8f12145 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -313,6 +313,7 @@ MODULE_DEVICE_TABLE(pci, rtl8169_pci_tbl);
 
 static int rx_buf_sz = 16383;
 static int use_dac;
+static bool bql_disable;
 static struct {
 	u32 msg_enable;
 } debug = { -1 };
@@ -818,6 +819,9 @@ MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@vger.kernel.org>");
 MODULE_DESCRIPTION("RealTek RTL-8169 Gigabit Ethernet driver");
 module_param(use_dac, int, 0);
 MODULE_PARM_DESC(use_dac, "Enable PCI DAC. Unsafe on 32 bit PCI slot.");
+module_param(bql_disable, bool, 0);
+MODULE_PARM_DESC(bql_disable,
+	"Disable Byte Queue Limits functionality (default: false)");
 module_param_named(debug, debug.msg_enable, int, 0);
 MODULE_PARM_DESC(debug, "Debug verbosity level (0=none, ..., 16=all)");
 MODULE_LICENSE("GPL");
@@ -5841,6 +5845,8 @@ static void rtl8169_tx_clear(struct rtl8169_private *tp)
 {
 	rtl8169_tx_clear_range(tp, tp->dirty_tx, NUM_TX_DESC);
 	tp->cur_tx = tp->dirty_tx = 0;
+	if (likely(bql_disable == false))
+		netdev_reset_queue(tp->dev);
 }
 
 static void rtl_reset_work(struct rtl8169_private *tp)
@@ -6017,6 +6023,8 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 	txd->opts2 = cpu_to_le32(opts[1]);
 
 	skb_tx_timestamp(skb);
+	if (likely(bql_disable == false))
+		netdev_sent_queue(dev, skb->len);
 
 	wmb();
 
@@ -6116,6 +6124,7 @@ static void rtl8169_pcierr_interrupt(struct net_device *dev)
 static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
 {
 	unsigned int dirty_tx, tx_left;
+	unsigned int pkts_compl = 0, bytes_compl = 0;
 
 	dirty_tx = tp->dirty_tx;
 	smp_rmb();
@@ -6138,6 +6147,9 @@ static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
 			tp->tx_stats.packets++;
 			tp->tx_stats.bytes += tx_skb->skb->len;
 			u64_stats_update_end(&tp->tx_stats.syncp);
+
+			bytes_compl += tx_skb->skb->len;
+			pkts_compl++;
 			dev_kfree_skb(tx_skb->skb);
 			tx_skb->skb = NULL;
 		}
@@ -6155,6 +6167,8 @@ static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
 		 * ring status.
 		 */
 		smp_mb();
+		if (likely(bql_disable == false))
+			netdev_completed_queue(dev, pkts_compl, bytes_compl);
 		if (netif_queue_stopped(dev) &&
 		    TX_FRAGS_READY_FOR(tp, MAX_SKB_FRAGS)) {
 			netif_wake_queue(dev);
-- 
1.8.4.1
