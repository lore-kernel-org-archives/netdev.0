From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: rtl8168e-vl dropping tftp ack
Date: Thu, 18 Apr 2013 23:55:01 +0200
Message-ID: <20130418215501.GB8944@electric-eye.fr.zoreil.com>
References: <516EB23B.3080504@canonical.com>
 <20130417213251.GA13790@electric-eye.fr.zoreil.com>
 <516FC218.3060002@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Stefan Bader <stefan.bader@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:56616 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932207Ab3DRVzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 17:55:09 -0400
Content-Disposition: inline
In-Reply-To: <516FC218.3060002@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stefan Bader <stefan.bader@canonical.com> :
[...]
> This was taken with a 3.9-rc7 kernel running on the Xen host, listening on the
> tftp server. First run is with the kernel driver and the second pass with

Please try the patch below with current kernel and capture traffic on
both the tftp server and r8169 interfaces.

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 4ecbe64..c1cd9f6 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5747,7 +5747,7 @@ err_out:
 	return -EIO;
 }
 
-static inline void rtl8169_tso_csum(struct rtl8169_private *tp,
+static inline bool rtl8169_tso_csum(struct rtl8169_private *tp,
 				    struct sk_buff *skb, u32 *opts)
 {
 	const struct rtl_tx_desc_info *info = tx_desc_info + tp->txd_version;
@@ -5760,6 +5760,15 @@ static inline void rtl8169_tso_csum(struct rtl8169_private *tp,
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
@@ -5767,6 +5776,7 @@ static inline void rtl8169_tso_csum(struct rtl8169_private *tp,
 		else
 			WARN_ON_ONCE(1);
 	}
+	return true;
 }
 
 static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
@@ -5790,25 +5800,26 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 	if (unlikely(le32_to_cpu(txd->opts1) & DescOwn))
 		goto err_stop_0;
 
+	opts[1] = cpu_to_le32(rtl8169_tx_vlan_tag(skb));
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
 
-	opts[1] = cpu_to_le32(rtl8169_tx_vlan_tag(skb));
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
@@ -5854,10 +5865,11 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
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
 
