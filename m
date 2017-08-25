From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 2/2] r8169: Be drop monitor friendly
Date: Thu, 24 Aug 2017 18:34:44 -0700
Message-ID: <20170825013444.27326-3-f.fainelli@gmail.com>
References: <20170825013444.27326-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, nic_swsd@realtek.com, romieu@fr.zoreil.com,
        edumazet@gmail.com, alexander.h.duyck@intel.com,
        sgruszka@redhat.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:34819 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754435AbdHYBez (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 21:34:55 -0400
Received: by mail-qt0-f194.google.com with SMTP id u11so1024025qtu.2
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2017 18:34:54 -0700 (PDT)
In-Reply-To: <20170825013444.27326-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rtl_tx() is the TX reclamation process whereas rtl8169_tx_clear_range() does
the TX ring cleaning during shutdown, both of these functions should call
dev_consume_skb_any() to be drop monitor friendly.

Fixes: cac4b22f3d6a ("r8169: do not account fragments as packets")
Fixes: eb781397904e ("r8169: Do not use dev_kfree_skb in xmit path")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/realtek/r8169.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 8a1bbd2a6a20..e03fcf914690 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -6863,7 +6863,7 @@ static void rtl8169_tx_clear_range(struct rtl8169_private *tp, u32 start,
 			rtl8169_unmap_tx_skb(&tp->pci_dev->dev, tx_skb,
 					     tp->TxDescArray + entry);
 			if (skb) {
-				dev_kfree_skb_any(skb);
+				dev_consume_skb_any(skb);
 				tx_skb->skb = NULL;
 			}
 		}
@@ -7318,7 +7318,7 @@ static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
 			tp->tx_stats.packets++;
 			tp->tx_stats.bytes += tx_skb->skb->len;
 			u64_stats_update_end(&tp->tx_stats.syncp);
-			dev_kfree_skb_any(tx_skb->skb);
+			dev_consume_skb_any(tx_skb->skb);
 			tx_skb->skb = NULL;
 		}
 		dirty_tx++;
-- 
2.9.3
