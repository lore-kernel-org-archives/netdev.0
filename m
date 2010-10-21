From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH 5/8] r8169: do not account fragments as packets
Date: Thu, 21 Oct 2010 10:25:40 +0200
Message-ID: <1287649543-6569-6-git-send-email-sgruszka@redhat.com>
References: <1287649543-6569-1-git-send-email-sgruszka@redhat.com>
Cc: Denis Kirjanov <kirjanov@gmail.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4973 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753152Ab0JUIXb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 04:23:31 -0400
In-Reply-To: <1287649543-6569-1-git-send-email-sgruszka@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only increase tx_{packets,dropped} statistics when transmit or drop
full skb, not just fragment.

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
--
 drivers/net/r8169.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 0a797d0..ef304c5 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -4094,10 +4094,10 @@ static void rtl8169_tx_clear_range(struct rtl8169_private *tp, u32 start,
 			rtl8169_unmap_tx_skb(&tp->pci_dev->dev, tx_skb,
 					     tp->TxDescArray + entry);
 			if (skb) {
+				tp->dev->stats.tx_dropped++;
 				dev_kfree_skb(skb);
 				tx_skb->skb = NULL;
 			}
-			tp->dev->stats.tx_dropped++;
 		}
 	}
 }
@@ -4402,7 +4402,6 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
 	while (tx_left > 0) {
 		unsigned int entry = dirty_tx % NUM_TX_DESC;
 		struct ring_info *tx_skb = tp->tx_skb + entry;
-		u32 len = tx_skb->len;
 		u32 status;
 
 		rmb();
@@ -4410,12 +4409,11 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
 		if (status & DescOwn)
 			break;
 
-		dev->stats.tx_bytes += len;
-		dev->stats.tx_packets++;
-
 		rtl8169_unmap_tx_skb(&tp->pci_dev->dev, tx_skb,
 				     tp->TxDescArray + entry);
 		if (status & LastFrag) {
+			dev->stats.tx_packets++;
+			dev->stats.tx_bytes += tx_skb->skb->len;
 			dev_kfree_skb(tx_skb->skb);
 			tx_skb->skb = NULL;
 		}
-- 
1.6.5.2

