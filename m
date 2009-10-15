From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [net-next-2.6 PATCH 3/4] TCPCT part 1: initial SYN exchange with
 SYNACK data
Date: Thu, 15 Oct 2009 01:34:31 -0400
Message-ID: <4AD6B467.2080701@gmail.com>
References: <4AD6B31B.3060402@gmail.com> <4AD6B3E8.2050904@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030609040806070000050904"
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.211.176]:37267 "EHLO
	mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752974AbZJOFfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 01:35:09 -0400
Received: by ywh6 with SMTP id 6so522789ywh.4
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2009 22:34:33 -0700 (PDT)
In-Reply-To: <4AD6B3E8.2050904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030609040806070000050904
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Redefine two TCP header functions to accept TCP header pointer.
When subtracting, return signed int to allow error checking.

In the only two existing files using the latter function, clean up
confusing and inconsistent mixing of both byte and word offsets.
However, remove proposed header length checking, and document the
assumptions instead.  In the immortal words of the reviewer:

   This is transmit, and the packets can only come from the Linux
   TCP stack, not some external entity.

   You're being way too anal here, and adding these checks to
   drivers would be just a lot of rediculious bloat. [sic]

These functions will also be used in subsequent patches that implement
additional features.
---
  drivers/net/bnx2.c  |   22 +++++++++++++---------
  drivers/net/tg3.c   |   32 +++++++++++++++++---------------
  include/linux/tcp.h |   10 ++++++++--
  3 files changed, 38 insertions(+), 26 deletions(-)


--------------030609040806070000050904
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="TCPCT+1-3.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="TCPCT+1-3.patch"

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 08cddb6..2cb342c 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6330,18 +6330,17 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
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
@@ -6354,10 +6353,15 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
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
index ba5d3fe..7e89e2a 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -5230,7 +5230,8 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
 		else {
 			struct iphdr *iph = ip_hdr(skb);
 
-			tcp_opt_len = tcp_optlen(skb);
+			tcp_opt_len = tcp_option_len_th(tcp_hdr(skb));
+			/* assumes positive tcp_opt_len without checking */
 			ip_tcp_len = ip_hdrlen(skb) + sizeof(struct tcphdr);
 
 			iph->check = 0;
@@ -5392,7 +5393,8 @@ static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *skb,
 	mss = 0;
 	if ((mss = skb_shinfo(skb)->gso_size) != 0) {
 		struct iphdr *iph;
-		int tcp_opt_len, ip_tcp_len, hdr_len;
+		int tcp_opt_len, ip_hdr_len, ip_opt_len, ip_tcp_len, hdr_len;
+		int opt_bytes;
 
 		if (skb_header_cloned(skb) &&
 		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
@@ -5400,10 +5402,12 @@ static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *skb,
 			goto out_unlock;
 		}
 
-		tcp_opt_len = tcp_optlen(skb);
-		ip_tcp_len = ip_hdrlen(skb) + sizeof(struct tcphdr);
-
+		tcp_opt_len = tcp_option_len_th(tcp_hdr(skb));
+		/* assumes positive tcp_opt_len without checking */
+		ip_hdr_len = ip_hdrlen(skb);
+		ip_tcp_len = ip_hdr_len + sizeof(struct tcphdr);
 		hdr_len = ip_tcp_len + tcp_opt_len;
+
 		if (unlikely((ETH_HLEN + hdr_len) > 80) &&
 			     (tp->tg3_flags2 & TG3_FLG2_TSO_BUG))
 			return (tg3_tso_bug(tp, skb));
@@ -5423,20 +5427,18 @@ static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *skb,
 								 IPPROTO_TCP,
 								 0);
 
+		ip_opt_len = ip_hdr_len - sizeof(struct iphdr);
+		/* assumes positive ip_opt_len without checking */
+		opt_bytes = ip_opt_len + tcp_opt_len;
+
 		if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO) ||
 		    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705)) {
-			if (tcp_opt_len || iph->ihl > 5) {
-				int tsflags;
-
-				tsflags = (iph->ihl - 5) + (tcp_opt_len >> 2);
-				mss |= (tsflags << 11);
+			if (opt_bytes > 0) {
+				mss |= (opt_bytes >> 2) << 11;
 			}
 		} else {
-			if (tcp_opt_len || iph->ihl > 5) {
-				int tsflags;
-
-				tsflags = (iph->ihl - 5) + (tcp_opt_len >> 2);
-				base_flags |= tsflags << 12;
+			if (opt_bytes > 0) {
+				base_flags |= (opt_bytes >> 2) << 12;
 			}
 		}
 	}
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 63ab660..d304ba5 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -217,9 +217,15 @@ static inline unsigned int tcp_hdrlen(const struct sk_buff *skb)
 	return tcp_hdr(skb)->doff * 4;
 }
 
-static inline unsigned int tcp_optlen(const struct sk_buff *skb)
+static inline unsigned int tcp_header_len_th(const struct tcphdr *th)
 {
-	return (tcp_hdr(skb)->doff - 5) * 4;
+	return th->doff * 4;
+}
+
+/* When doff is bad, this could be negative. */
+static inline int tcp_option_len_th(const struct tcphdr *th)
+{
+	return (int)tcp_header_len_th(th) - sizeof(*th);
 }
 
 /* This defines a selective acknowledgement block. */
-- 
1.6.0.4


--------------030609040806070000050904--
