From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net 1/1] r8169: fix vlan tag read ordering.
Date: Fri, 25 Jan 2013 00:30:06 +0100
Message-ID: <20130124233006.GA7511@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Hayes Wang <hayeswang@realtek.com>,
	Timo Teras <timo.teras@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:40437 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752277Ab3AXX7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 18:59:40 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Control of receive descriptor must not be returned to ethernet chipset
before vlan tag processing is done.

VLAN tag receive word is now reset both in normal and error path.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Spotted-by: Timo Teras <timo.teras@iki.fi>
Cc: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index c28bc31..1170232 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1826,8 +1826,6 @@ static void rtl8169_rx_vlan_tag(struct RxDesc *desc, struct sk_buff *skb)
 
 	if (opts2 & RxVlanTag)
 		__vlan_hwaccel_put_tag(skb, swab16(opts2 & 0xffff));
-
-	desc->opts2 = 0;
 }
 
 static int rtl8169_gset_tbi(struct net_device *dev, struct ethtool_cmd *cmd)
@@ -6064,8 +6062,6 @@ static int rtl_rx(struct net_device *dev, struct rtl8169_private *tp, u32 budget
 			    !(status & (RxRWT | RxFOVF)) &&
 			    (dev->features & NETIF_F_RXALL))
 				goto process_pkt;
-
-			rtl8169_mark_to_asic(desc, rx_buf_sz);
 		} else {
 			struct sk_buff *skb;
 			dma_addr_t addr;
@@ -6086,16 +6082,14 @@ process_pkt:
 			if (unlikely(rtl8169_fragmented_frame(status))) {
 				dev->stats.rx_dropped++;
 				dev->stats.rx_length_errors++;
-				rtl8169_mark_to_asic(desc, rx_buf_sz);
-				continue;
+				goto release_descriptor;
 			}
 
 			skb = rtl8169_try_rx_copy(tp->Rx_databuff[entry],
 						  tp, pkt_size, addr);
-			rtl8169_mark_to_asic(desc, rx_buf_sz);
 			if (!skb) {
 				dev->stats.rx_dropped++;
-				continue;
+				goto release_descriptor;
 			}
 
 			rtl8169_rx_csum(skb, status);
@@ -6111,6 +6105,10 @@ process_pkt:
 			tp->rx_stats.bytes += pkt_size;
 			u64_stats_update_end(&tp->rx_stats.syncp);
 		}
+release_descriptor:
+		desc->opts2 = 0;
+		wmb();
+		rtl8169_mark_to_asic(desc, rx_buf_sz);
 	}
 
 	count = cur_rx - tp->cur_rx;
-- 
1.7.11.7
