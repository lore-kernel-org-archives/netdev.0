From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH v9 2/2] TCPCT part 1i: remove old tcp_optlen()
 function
Date: Thu, 03 Dec 2009 18:54:41 -0500
Message-ID: <4B184FC1.8020805@gmail.com>
References: <4B184A20.4050005@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030109070901060500070808"
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f182.google.com ([209.85.211.182]:42096 "EHLO
	mail-yw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754643AbZLCXyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 18:54:37 -0500
Received: by ywh12 with SMTP id 12so2032598ywh.21
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2009 15:54:43 -0800 (PST)
In-Reply-To: <4B184A20.4050005@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030109070901060500070808
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

In the only two existing files using the old tcp_optlen() function,
clean up confusing and inconsistent mixing of both byte and word
offsets.  Document assumptions.  David Miller's review sayeth:

    This is transmit, and the packets can only come from the Linux
    TCP stack, not some external entity.

Untested.  No response from testers in 6+ weeks.

Signed-off-by: William.Allen.Simpson@gmail.com
CC: Michael Chan <mchan@broadcom.com>
---
  drivers/net/bnx2.c  |   22 +++++++++++++---------
  drivers/net/tg3.c   |   51 +++++++++++++++++++++++----------------------------
  include/linux/tcp.h |    5 -----
  3 files changed, 36 insertions(+), 42 deletions(-)

--------------030109070901060500070808
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="TCPCT+1i9.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="TCPCT+1i9.patch"

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 4cae2a8..5b9c41b 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6354,18 +6354,17 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 #endif
 	if ((mss = skb_shinfo(skb)->gso_size)) {
-		u32 tcp_opt_len;
-		struct iphdr *iph;
+		struct tcphdr *th = tcp_hdr(skb);
+		int tcp_opt_words = th->doff - (sizeof(*th) >> 2);
 
+		/* assumes positive tcp_opt_words without checking */
 		vlan_tag_flags |= TX_BD_FLAGS_SW_LSO;
 
-		tcp_opt_len = tcp_optlen(skb);
-
 		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6) {
 			u32 tcp_off = skb_transport_offset(skb) -
 				      sizeof(struct ipv6hdr) - ETH_HLEN;
 
-			vlan_tag_flags |= ((tcp_opt_len >> 2) << 8) |
+			vlan_tag_flags |= (tcp_opt_words << 8) |
 					  TX_BD_FLAGS_SW_FLAGS;
 			if (likely(tcp_off == 0))
 				vlan_tag_flags &= ~TX_BD_FLAGS_TCP6_OFF0_MSK;
@@ -6378,10 +6377,15 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 				mss |= (tcp_off & 0xc) << TX_BD_TCP6_OFF2_SHL;
 			}
 		} else {
-			iph = ip_hdr(skb);
-			if (tcp_opt_len || (iph->ihl > 5)) {
-				vlan_tag_flags |= ((iph->ihl - 5) +
-						   (tcp_opt_len >> 2)) << 8;
+			struct iphdr *iph = ip_hdr(skb);
+			int ip_opt_words = iph->ihl - (sizeof(*iph) >> 2);
+			int opt_words;
+
+			/* assumes positive ip_opt_words without checking */
+			opt_words = ip_opt_words + tcp_opt_words;
+
+			if (opt_words > 0) {
+				vlan_tag_flags |= opt_words << 8;
 			}
 		}
 	} else
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 302ea0b..f4c4173 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -5459,7 +5459,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
 	base_flags = 0;
 	mss = 0;
 	if ((mss = skb_shinfo(skb)->gso_size) != 0) {
-		int tcp_opt_len, ip_tcp_len;
+		struct tcphdr *th;
 		u32 hdrlen;
 
 		if (skb_header_cloned(skb) &&
@@ -5468,17 +5468,16 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
 			goto out_unlock;
 		}
 
+		th = tcp_hdr(skb);
+
 		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
 			hdrlen = skb_headlen(skb) - ETH_HLEN;
 		else {
 			struct iphdr *iph = ip_hdr(skb);
 
-			tcp_opt_len = tcp_optlen(skb);
-			ip_tcp_len = ip_hdrlen(skb) + sizeof(struct tcphdr);
-
+			hdrlen = ip_hdrlen(skb) + tcp_header_len_th(th);
+			iph->tot_len = htons(mss + hdrlen);
 			iph->check = 0;
-			iph->tot_len = htons(mss + ip_tcp_len + tcp_opt_len);
-			hdrlen = ip_tcp_len + tcp_opt_len;
 		}
 
 		if (tp->tg3_flags2 & TG3_FLG2_HW_TSO_3) {
@@ -5492,7 +5491,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
 		base_flags |= (TXD_FLAG_CPU_PRE_DMA |
 			       TXD_FLAG_CPU_POST_DMA);
 
-		tcp_hdr(skb)->check = 0;
+		th->check = 0;
 
 	}
 	else if (skb->ip_summed == CHECKSUM_PARTIAL)
@@ -5666,7 +5665,9 @@ static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *skb,
 
 	if ((mss = skb_shinfo(skb)->gso_size) != 0) {
 		struct iphdr *iph;
-		u32 tcp_opt_len, ip_tcp_len, hdr_len;
+		struct tcphdr *th;
+		u32 hdr_len;
+		int opt_bytes;
 
 		if (skb_header_cloned(skb) &&
 		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
@@ -5674,10 +5675,9 @@ static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *skb,
 			goto out_unlock;
 		}
 
-		tcp_opt_len = tcp_optlen(skb);
-		ip_tcp_len = ip_hdrlen(skb) + sizeof(struct tcphdr);
+		th = tcp_hdr(skb);
+		hdr_len = ip_hdrlen(skb) + tcp_header_len_th(th);
 
-		hdr_len = ip_tcp_len + tcp_opt_len;
 		if (unlikely((ETH_HLEN + hdr_len) > 80) &&
 			     (tp->tg3_flags2 & TG3_FLG2_TSO_BUG))
 			return (tg3_tso_bug(tp, skb));
@@ -5689,35 +5689,30 @@ static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *skb,
 		iph->check = 0;
 		iph->tot_len = htons(mss + hdr_len);
 		if (tp->tg3_flags2 & TG3_FLG2_HW_TSO) {
-			tcp_hdr(skb)->check = 0;
+			th->check = 0;
 			base_flags &= ~TXD_FLAG_TCPUDP_CSUM;
 		} else
-			tcp_hdr(skb)->check = ~csum_tcpudp_magic(iph->saddr,
-								 iph->daddr, 0,
-								 IPPROTO_TCP,
-								 0);
+			th->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr,
+						       0, IPPROTO_TCP, 0);
+
+		/* assumes positive without checking */
+		opt_bytes = hdr_len - sizeof(*iph) - sizeof(*th);
 
 		if (tp->tg3_flags2 & TG3_FLG2_HW_TSO_3) {
 			mss |= (hdr_len & 0xc) << 12;
 			if (hdr_len & 0x10)
 				base_flags |= 0x00000010;
 			base_flags |= (hdr_len & 0x3e0) << 5;
-		} else if (tp->tg3_flags2 & TG3_FLG2_HW_TSO_2)
+		} else if (tp->tg3_flags2 & TG3_FLG2_HW_TSO_2) {
 			mss |= hdr_len << 9;
-		else if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_1) ||
+		} else if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_1) ||
 			 GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705) {
-			if (tcp_opt_len || iph->ihl > 5) {
-				int tsflags;
-
-				tsflags = (iph->ihl - 5) + (tcp_opt_len >> 2);
-				mss |= (tsflags << 11);
+			if (opt_bytes > 0) {
+				mss |= opt_bytes << (11 - 2);
 			}
 		} else {
-			if (tcp_opt_len || iph->ihl > 5) {
-				int tsflags;
-
-				tsflags = (iph->ihl - 5) + (tcp_opt_len >> 2);
-				base_flags |= tsflags << 12;
+			if (opt_bytes > 0) {
+				base_flags |= opt_bytes << (12 - 2);
 			}
 		}
 	}
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 54ef984..67f7354 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -218,11 +218,6 @@ static inline unsigned int tcp_hdrlen(const struct sk_buff *skb)
 	return tcp_hdr(skb)->doff * 4;
 }
 
-static inline unsigned int tcp_optlen(const struct sk_buff *skb)
-{
-	return (tcp_hdr(skb)->doff - 5) * 4;
-}
-
 /* Fixed portion plus standard options. */
 static inline unsigned int tcp_header_len_th(const struct tcphdr *th)
 {
-- 
1.6.3.3


--------------030109070901060500070808--
