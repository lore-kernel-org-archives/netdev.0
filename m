From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net] r8169: remove the obsolete and incorrect AMD workaround
Date: Wed, 23 Jan 2013 23:38:34 +0100
Message-ID: <20130123223834.GA5124@electric-eye.fr.zoreil.com>
References: <20130121234205.GA12449@electric-eye.fr.zoreil.com> <1358843435-24719-1-git-send-email-timo.teras@iki.fi> <20130123000541.GA9515@electric-eye.fr.zoreil.com> <20130123081408.2646fc4e@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:36219 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899Ab3AWXHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 18:07:50 -0500
Content-Disposition: inline
In-Reply-To: <20130123081408.2646fc4e@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Teras <timo.teras@iki.fi> :
[...]
> Actually, this sounds wrong. Why is rtl8169_rx_vlan_tag() which is
> fiddling opts2 invoked *after* rtl8169_mark_to_asic() ? This means it
> can overwrite the tag info if the queue is full.

Yes. It has been there for ages.

What about something like the patch below ?

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
