From: =?utf-8?B?Iklnb3IgTWFyYXZpxIci?= <igorm@etf.rs>
Subject: Re: [PATCH net-next] r8169: Support for byte queue limits
Date: Fri, 2 Dec 2011 17:31:38 +0100
Message-ID: <6b84ddc047f72f8a66cc587a1813fbe9.squirrel@kondor.etf.bg.ac.rs>
References: <igorm@etf.rs> <1322831399-23505-1-git-send-email-igorm@etf.rs>
    <1322836191.2762.3.camel@edumazet-laptop>
    <CAFdo_mVwRgB3OEBA7=nMcemr1x1WLkXC05UAnDW_n5gyYy9W=A@mail.gmail.com>
    <1322838687.2762.18.camel@edumazet-laptop>
Reply-To: igorm@etf.rs
Mime-Version: 1.0
Content-Type: text/plain;charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: igorm@etf.rs, netdev@vger.kernel.org, davem@davemloft.net,
	"Realtek linux nic maintainers" <nic_swsd@realtek.com>,
	"Francois Romieu" <romieu@fr.zoreil.com>,
	"Tom Herbert" <therbert@google.com>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.etf.rs ([147.91.14.170]:46482 "EHLO mx2.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757032Ab1LBQbm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 11:31:42 -0500
In-Reply-To: <1322838687.2762.18.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Quite frankly, any queued skb is eventually freed, so
> netdev_reset_queue() could be avoided.
>

If I didn't add netdev_reset_queue(), how dql would reset its parameters to 0?

I added spin_locks around netdev_completed_queue and netdev_sent_queue

[PATCH net-next] r8169: Support for byte queue limits

Changes to r8169 to use byte queue limits.

Signed-off-by: Igor Maravic <igorm@etf.rs>
---
 drivers/net/ethernet/realtek/r8169.c |   17 +++++++++++++++--
 1 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index e5a6d8e..e46d4e6 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3773,6 +3773,7 @@ static void rtl_init_rxcfg(struct rtl8169_private *tp)
 static void rtl8169_init_ring_indexes(struct rtl8169_private *tp)
 {
 	tp->dirty_tx = tp->dirty_rx = tp->cur_tx = tp->cur_rx = 0;
+	netdev_reset_queue(tp->dev);
 }

 static void rtl_hw_jumbo_enable(struct rtl8169_private *tp)
@@ -5422,6 +5423,7 @@ static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
 	unsigned int cur_frag, entry;
 	struct TxDesc * uninitialized_var(txd);
 	struct device *d = &tp->pci_dev->dev;
+	unsigned long flag;

 	entry = tp->cur_tx;
 	for (cur_frag = 0; cur_frag < info->nr_frags; cur_frag++) {
@@ -5458,6 +5460,9 @@ static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
 		tp->tx_skb[entry].skb = skb;
 		txd->opts1 |= cpu_to_le32(LastFrag);
 	}
+	spin_lock_irqsave(&tp->lock,flag);
+	netdev_sent_queue(tp->dev, skb->len);
+	spin_unlock_irqrestore(&tp->lock,flag);

 	return cur_frag;

@@ -5623,6 +5628,9 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
 				 void __iomem *ioaddr)
 {
 	unsigned int dirty_tx, tx_left;
+	unsigned int bytes_compl = 0;
+	int tx_compl = 0;
+	unsigned long flag;

 	dirty_tx = tp->dirty_tx;
 	smp_rmb();
@@ -5641,8 +5649,8 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
 		rtl8169_unmap_tx_skb(&tp->pci_dev->dev, tx_skb,
 				     tp->TxDescArray + entry);
 		if (status & LastFrag) {
-			dev->stats.tx_packets++;
-			dev->stats.tx_bytes += tx_skb->skb->len;
+			bytes_compl += tx_skb->skb->len;
+			tx_compl++;
 			dev_kfree_skb(tx_skb->skb);
 			tx_skb->skb = NULL;
 		}
@@ -5650,6 +5658,11 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
 		tx_left--;
 	}

+	dev->stats.tx_packets += tx_compl;
+	dev->stats.tx_bytes += bytes_compl;
+	spin_lock_irqsave(&tp->lock, flag);
+	netdev_completed_queue(dev, tx_compl, bytes_compl);
+	spin_unlock_irqrestore(&tp->lock, flag);
 	if (tp->dirty_tx != dirty_tx) {
 		tp->dirty_tx = dirty_tx;
 		smp_wmb();
-- 
1.7.5.4
