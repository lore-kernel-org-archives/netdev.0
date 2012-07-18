From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFC] r8169 : why SG / TX checksum are default disabled
Date: Wed, 18 Jul 2012 22:12:01 +0200
Message-ID: <20120718201201.GC14149@electric-eye.fr.zoreil.com>
References: <1342564781.2626.1264.camel@edumazet-glaptop> <20120717234037.GA26972@electric-eye.fr.zoreil.com> <AC35CD5731C3479B9BF5E53BF541A81F@realtek.com.tw> <20120718.092346.1263036873056516097.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hayeswang@realtek.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:52641 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751246Ab2GRUYu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 16:24:50 -0400
Content-Disposition: inline
In-Reply-To: <20120718.092346.1263036873056516097.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> :
> From: hayeswang <hayeswang@realtek.com>
> > Francois Romieu [mailto:romieu@fr.zoreil.com] 
> > [...]
> > 
> >> Hayes, should we not add into the kernel driver something similar to
> >> the rtl8168_start_xmit::skb_checksum_help stuff in Realtek's 
> >> 8168 driver ?
> >> There seems to be a bug for (skb->len < 60 && RTL_GIGA_MAC_VER_34.
> > 
> > For RTL8168E-VL (RTL_GIGA_MAC_VER_34), the hardware wouldn't send the packet
> > with the length less than 60 bytes. The hardware should pad this kind of packet
> > to 60 bytes, but it wouldn't. Therefore, the software has to pad the packet to
> > 60 bytes. However, the hw checksum would be incorrect for the modified packet,
> > so the software checksum is necessary.
> 
> I wonder how the hardware checksum can be incorrectly calculated if the padding
> is done with zeros?

A part of the apparent problem may stem from the fact that Realtek's 8168
driver claims a modified length but it does not really skb_padto... 

Hayes, would the patch below fix the original problem ?

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index be4e00f..a463697 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5740,7 +5740,7 @@ err_out:
 	return -EIO;
 }
 
-static inline void rtl8169_tso_csum(struct rtl8169_private *tp,
+static inline bool rtl8169_tso_csum(struct rtl8169_private *tp,
 				    struct sk_buff *skb, u32 *opts)
 {
 	const struct rtl_tx_desc_info *info = tx_desc_info + tp->txd_version;
@@ -5753,6 +5753,12 @@ static inline void rtl8169_tso_csum(struct rtl8169_private *tp,
 	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		const struct iphdr *ip = ip_hdr(skb);
 
+		if (unlikely(skb->len < 60 &&
+		    (tp->mac_version == RTL_GIGA_MAC_VER_34) &&
+		    skb_padto(skb, ETH_ZLEN))) {
+			return false;
+		}
+
 		if (ip->protocol == IPPROTO_TCP)
 			opts[offset] |= info->checksum.tcp;
 		else if (ip->protocol == IPPROTO_UDP)
@@ -5760,6 +5766,7 @@ static inline void rtl8169_tso_csum(struct rtl8169_private *tp,
 		else
 			WARN_ON_ONCE(1);
 	}
+	return true;
 }
 
 static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
@@ -5797,7 +5804,8 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 	opts[1] = cpu_to_le32(rtl8169_tx_vlan_tag(tp, skb));
 	opts[0] = DescOwn;
 
-	rtl8169_tso_csum(tp, skb, opts);
+	if (!rtl8169_tso_csum(tp, skb, opts))
+		goto err_update_stats;
 
 	frags = rtl8169_xmit_frags(tp, skb, opts);
 	if (frags < 0)
@@ -5853,6 +5861,7 @@ err_dma_1:
 	rtl8169_unmap_tx_skb(d, tp->tx_skb + entry, txd);
 err_dma_0:
 	dev_kfree_skb(skb);
+err_update_stats:
 	dev->stats.tx_dropped++;
 	return NETDEV_TX_OK;
 
