From: David Miller <davem@davemloft.net>
Subject: Re: 1e918876 breaks r8169 (linux-3.18+)
Date: Sun, 22 Feb 2015 15:57:50 -0500 (EST)
Message-ID: <20150222.155750.495884608409425947.davem@davemloft.net>
References: <20150221190507.GA25687@louise.pinerecords.com>
	<1424548447.5565.48.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150222004151.GA4947@louise.pinerecords.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, fw@strlen.de, romieu@fr.zoreil.com,
	hayeswang@realtek.com, edumazet@google.com, therbert@google.com,
	pupilla@hotmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: szepe@pinerecords.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150222004151.GA4947@louise.pinerecords.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tomas Szepe <szepe@pinerecords.com>
Date: Sun, 22 Feb 2015 01:41:51 +0100

>> > Sure, just did.  Unfortunately, 3.19.0 + 0bec3b70 + this patch results
>> > in a driver that retains the problem.
>> 
>> OK, could you test following patch instead ?
> 
> Yup, but tough luck: 3.19.0 + 0bec3b70 + this patch -> problem present.

I'm reverting the two commits for now, as below.

We can put them back in if we can resolve the problems.

====================
[PATCH] r8169: Revert BQL and xmit_more support.

There are certain regressions which are pointing to
these two commits which we are having a hard time
resolving.  So revert them for now.

Specifically this reverts:

	commit 0bec3b700d106a8b0a34227b2976d1a582f1aab7
	Author: Florian Westphal <fw@strlen.de>
	Date:   Wed Jan 7 10:49:49 2015 +0100

	    r8169: add support for xmit_more

and

	commit 1e918876853aa85435e0f17fd8b4a92dcfff53d6
	Author: Florian Westphal <fw@strlen.de>
	Date:   Wed Oct 1 13:38:03 2014 +0200

	    r8169: add support for Byte Queue Limits

There were some attempts by Eric Dumazet to address some obvious
problems in the TX flow, to see if they would fix the problems,
but none of them seem to help for the regression reporters.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/realtek/r8169.c | 30 +++++++-----------------------
 1 file changed, 7 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index ad0020a..b156092 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5067,8 +5067,6 @@ static void rtl_hw_reset(struct rtl8169_private *tp)
 	RTL_W8(ChipCmd, CmdReset);
 
 	rtl_udelay_loop_wait_low(tp, &rtl_chipcmd_cond, 100, 100);
-
-	netdev_reset_queue(tp->dev);
 }
 
 static void rtl_request_uncached_firmware(struct rtl8169_private *tp)
@@ -7049,7 +7047,6 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 	u32 status, len;
 	u32 opts[2];
 	int frags;
-	bool stop_queue;
 
 	if (unlikely(!TX_FRAGS_READY_FOR(tp, skb_shinfo(skb)->nr_frags))) {
 		netif_err(tp, drv, dev, "BUG! Tx Ring full when queue awake!\n");
@@ -7090,8 +7087,6 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
 	txd->opts2 = cpu_to_le32(opts[1]);
 
-	netdev_sent_queue(dev, skb->len);
-
 	skb_tx_timestamp(skb);
 
 	/* Force memory writes to complete before releasing descriptor */
@@ -7106,16 +7101,11 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
 	tp->cur_tx += frags + 1;
 
-	stop_queue = !TX_FRAGS_READY_FOR(tp, MAX_SKB_FRAGS);
+	RTL_W8(TxPoll, NPQ);
 
-	if (!skb->xmit_more || stop_queue ||
-	    netif_xmit_stopped(netdev_get_tx_queue(dev, 0))) {
-		RTL_W8(TxPoll, NPQ);
-
-		mmiowb();
-	}
+	mmiowb();
 
-	if (stop_queue) {
+	if (!TX_FRAGS_READY_FOR(tp, MAX_SKB_FRAGS)) {
 		/* Avoid wrongly optimistic queue wake-up: rtl_tx thread must
 		 * not miss a ring update when it notices a stopped queue.
 		 */
@@ -7198,7 +7188,6 @@ static void rtl8169_pcierr_interrupt(struct net_device *dev)
 static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
 {
 	unsigned int dirty_tx, tx_left;
-	unsigned int bytes_compl = 0, pkts_compl = 0;
 
 	dirty_tx = tp->dirty_tx;
 	smp_rmb();
@@ -7222,8 +7211,10 @@ static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
 		rtl8169_unmap_tx_skb(&tp->pci_dev->dev, tx_skb,
 				     tp->TxDescArray + entry);
 		if (status & LastFrag) {
-			pkts_compl++;
-			bytes_compl += tx_skb->skb->len;
+			u64_stats_update_begin(&tp->tx_stats.syncp);
+			tp->tx_stats.packets++;
+			tp->tx_stats.bytes += tx_skb->skb->len;
+			u64_stats_update_end(&tp->tx_stats.syncp);
 			dev_kfree_skb_any(tx_skb->skb);
 			tx_skb->skb = NULL;
 		}
@@ -7232,13 +7223,6 @@ static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
 	}
 
 	if (tp->dirty_tx != dirty_tx) {
-		netdev_completed_queue(tp->dev, pkts_compl, bytes_compl);
-
-		u64_stats_update_begin(&tp->tx_stats.syncp);
-		tp->tx_stats.packets += pkts_compl;
-		tp->tx_stats.bytes += bytes_compl;
-		u64_stats_update_end(&tp->tx_stats.syncp);
-
 		tp->dirty_tx = dirty_tx;
 		/* Sync with rtl8169_start_xmit:
 		 * - publish dirty_tx ring index (write barrier)
-- 
2.1.0
