From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFC] r8169 : why SG / TX checksum are default disabled
Date: Fri, 20 Jul 2012 23:01:07 +0200
Message-ID: <20120720210107.GA28118@electric-eye.fr.zoreil.com>
References: <20120718.132840.1571938255177607234.davem@davemloft.net> <20120718214422.GA18207@electric-eye.fr.zoreil.com> <1342649136.2626.3757.camel@edumazet-glaptop> <20120718.152405.1083396282134539674.davem@davemloft.net> <EF06A7B3C1E6432BB660CDEF8E1D2A1B@realtek.com.tw> <20120720100846.GA17398@electric-eye.fr.zoreil.com> <A4FD513AF09D40849B8A75C371F1D431@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'David Miller'" <davem@davemloft.net>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57924 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752268Ab2GTVOH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 17:14:07 -0400
Content-Disposition: inline
In-Reply-To: <A4FD513AF09D40849B8A75C371F1D431@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hayeswang <hayeswang@realtek.com> :
[...]
> If the hw only fills in the checksum fields of IP header, UDP header, and TCP
> header, the patch would work. However, the hw would also fill in the total
> length field of IP header, so it causes problems.

Thanks, I missed this part. The patch below should be getting better now.

Btw, would there be any point in setting the TcpHeaderOffset field for
the post-8168c chipsets ?

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index be4e00f..2420af6 100644
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
@@ -5753,6 +5753,15 @@ static inline void rtl8169_tso_csum(struct rtl8169_private *tp,
 	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		const struct iphdr *ip = ip_hdr(skb);
 
+		if (unlikely(skb->len < ETH_ZLEN &&
+		    (tp->mac_version == RTL_GIGA_MAC_VER_34))) {
+			if (skb_padto(skb, ETH_ZLEN))
+				return false;
+			skb_checksum_help(skb);
+			skb_put(skb, ETH_ZLEN - skb->len);
+			return true;
+		}
+
 		if (ip->protocol == IPPROTO_TCP)
 			opts[offset] |= info->checksum.tcp;
 		else if (ip->protocol == IPPROTO_UDP)
@@ -5760,6 +5769,7 @@ static inline void rtl8169_tso_csum(struct rtl8169_private *tp,
 		else
 			WARN_ON_ONCE(1);
 	}
+	return true;
 }
 
 static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
@@ -5783,25 +5793,26 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 	if (unlikely(le32_to_cpu(txd->opts1) & DescOwn))
 		goto err_stop_0;
 
+	opts[1] = cpu_to_le32(rtl8169_tx_vlan_tag(tp, skb));
+	opts[0] = DescOwn;
+
+	if (!rtl8169_tso_csum(tp, skb, opts))
+		goto err_update_stats_0;
+
 	len = skb_headlen(skb);
 	mapping = dma_map_single(d, skb->data, len, DMA_TO_DEVICE);
 	if (unlikely(dma_mapping_error(d, mapping))) {
 		if (net_ratelimit())
 			netif_err(tp, drv, dev, "Failed to map TX DMA!\n");
-		goto err_dma_0;
+		goto err_free_skb_1;
 	}
 
 	tp->tx_skb[entry].len = len;
 	txd->addr = cpu_to_le64(mapping);
 
-	opts[1] = cpu_to_le32(rtl8169_tx_vlan_tag(tp, skb));
-	opts[0] = DescOwn;
-
-	rtl8169_tso_csum(tp, skb, opts);
-
 	frags = rtl8169_xmit_frags(tp, skb, opts);
 	if (frags < 0)
-		goto err_dma_1;
+		goto err_unmap_2;
 	else if (frags)
 		opts[0] |= FirstFrag;
 	else {
@@ -5849,10 +5860,11 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
 	return NETDEV_TX_OK;
 
-err_dma_1:
+err_unmap_2:
 	rtl8169_unmap_tx_skb(d, tp->tx_skb + entry, txd);
-err_dma_0:
+err_free_skb_1:
 	dev_kfree_skb(skb);
+err_update_stats_0:
 	dev->stats.tx_dropped++;
 	return NETDEV_TX_OK;
 
