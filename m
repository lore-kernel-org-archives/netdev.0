From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 driver cause ssh failure
Date: Wed, 15 May 2013 00:54:22 +0200
Message-ID: <20130514225422.GA32242@electric-eye.fr.zoreil.com>
References: <CA+6wjbxdbTDXmO984sM1CHFT+PJJdvS=+YmwM2iu-10Ws4WouA@mail.gmail.com>
 <5190841E.9090503@canonical.com>
 <20130513063332.GA16374@electric-eye.fr.zoreil.com>
 <pan.2013.05.13.13.24.46.794122@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Holger Hoffstaette <holger.hoffstaette@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:60595 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758429Ab3ENWyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 May 2013 18:54:25 -0400
Content-Disposition: inline
In-Reply-To: <pan.2013.05.13.13.24.46.794122@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Holger Hoffstaette <holger.hoffstaette@googlemail.com> :
[...]
> Don't have a packet capture, but I also noticed that this commit caused
> failures; symptom for me was broken squid traffic to websites using CDNs
> (arstechnica, twitter) and/or DNS, probably related to mixed IPv4/v6
> traffic. See my followup to last week's 3.8.13-stable announcement, which
> was apparently not dramatic enough to warrant attention.

It was not Cced and it did not appear as a reply to the stable-submitted
r8169 patch.

> I later found out that this regression is related to tx offloading;
> enabling rx & gso offloading still works. Reverting the patch restores tx
> offloading as well.

Could you check if the patch below helps ?

It has not crashed yet but I still lack a test case to claim it makes
a difference.

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 79c520b..a05596c 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5856,7 +5856,15 @@ err_out:
 	return -EIO;
 }
 
-static inline void rtl8169_tso_csum(struct rtl8169_private *tp,
+static bool rtl_skb_pad(struct sk_buff *skb)
+{
+	if (skb_padto(skb, ETH_ZLEN))
+		return false;
+	skb_put(skb, ETH_ZLEN - skb->len);
+	return true;
+}
+
+static inline bool rtl8169_tso_csum(struct rtl8169_private *tp,
 				    struct sk_buff *skb, u32 *opts)
 {
 	const struct rtl_tx_desc_info *info = tx_desc_info + tp->txd_version;
@@ -5869,13 +5877,24 @@ static inline void rtl8169_tso_csum(struct rtl8169_private *tp,
 	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		const struct iphdr *ip = ip_hdr(skb);
 
+		if (unlikely(skb->len < ETH_ZLEN &&
+		    (tp->mac_version == RTL_GIGA_MAC_VER_34))) {
+			skb_checksum_help(skb);
+			return rtl_skb_pad(skb);
+		}
+
 		if (ip->protocol == IPPROTO_TCP)
 			opts[offset] |= info->checksum.tcp;
 		else if (ip->protocol == IPPROTO_UDP)
 			opts[offset] |= info->checksum.udp;
 		else
 			WARN_ON_ONCE(1);
+	} else {
+		if (unlikely(skb->len < ETH_ZLEN &&
+		    (tp->mac_version == RTL_GIGA_MAC_VER_34)))
+			return rtl_skb_pad(skb);
 	}
+	return true;
 }
 
 static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
@@ -5896,17 +5915,15 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 		goto err_stop_0;
 	}
 
-	/* 8168evl does not automatically pad to minimum length. */
-	if (unlikely(tp->mac_version == RTL_GIGA_MAC_VER_34 &&
-		     skb->len < ETH_ZLEN)) {
-		if (skb_padto(skb, ETH_ZLEN))
-			goto err_update_stats;
-		skb_put(skb, ETH_ZLEN - skb->len);
-	}
-
 	if (unlikely(le32_to_cpu(txd->opts1) & DescOwn))
 		goto err_stop_0;
 
+	opts[1] = cpu_to_le32(rtl8169_tx_vlan_tag(skb));
+	opts[0] = DescOwn;
+
+	if (!rtl8169_tso_csum(tp, skb, opts))
+		goto err_update_stats;
+
 	len = skb_headlen(skb);
 	mapping = dma_map_single(d, skb->data, len, DMA_TO_DEVICE);
 	if (unlikely(dma_mapping_error(d, mapping))) {
@@ -5918,11 +5935,6 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 	tp->tx_skb[entry].len = len;
 	txd->addr = cpu_to_le64(mapping);
 
-	opts[1] = cpu_to_le32(rtl8169_tx_vlan_tag(skb));
-	opts[0] = DescOwn;
-
-	rtl8169_tso_csum(tp, skb, opts);
-
 	frags = rtl8169_xmit_frags(tp, skb, opts);
 	if (frags < 0)
 		goto err_dma_1;
