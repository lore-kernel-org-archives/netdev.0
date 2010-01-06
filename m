From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH 2/2] net: remove old tcp_optlen function
Date: Wed, 06 Jan 2010 16:37:31 -0500
Message-ID: <4B45029B.30300@gmail.com>
References: <4B44FE3C.6060809@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050405020004050703040709"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>
To: Linux Kernel Developers <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932694Ab0AFVho@vger.kernel.org>
In-Reply-To: <4B44FE3C.6060809@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050405020004050703040709
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

In the only two existing files using the old tcp_optlen() function,
clean up confusing and inconsistent mixing of both byte and word
offsets, and other coding style issues.  Document assumptions.

Quoth David Miller:
    This is transmit, and the packets can only come from the Linux
    TCP stack, not some external entity.

    You're being way too anal here, and adding these checks to
    drivers would be just a lot of rediculious bloat. [sic]

Therefore, there are *no* checks for bad TCP and IP header sizes, nor
any semantic changes.  The drivers should function exactly as existing.

Untested.  No response from testers in 10+ weeks.

Requires:
   net: tcp_header_len_th and tcp_option_len_th

Signed-off-by: William.Allen.Simpson@gmail.com
CC: Michael Chan <mchan@broadcom.com>
---
  drivers/net/bnx2.c  |   29 +++++++++++++-----------
  drivers/net/tg3.c   |   60 +++++++++++++++++++++++---------------------------
  include/linux/tcp.h |    5 ----
  3 files changed, 44 insertions(+), 50 deletions(-)


--------------050405020004050703040709
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="len_th+2v3.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="len_th+2v3.patch"

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 65df1de..45452c5 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6352,6 +6352,8 @@ bnx2_vlan_rx_register(struct net_device *dev, struct vlan_group *vlgrp)
 /* Called with netif_tx_lock.
  * bnx2_tx_int() runs without netif_tx_lock unless it needs to call
  * netif_wake_queue().
+ *
+ * No TCP or IP length checking, per David Miller (see commit log).
  */
 static netdev_tx_t
 bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
@@ -6396,19 +6398,19 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			(TX_BD_FLAGS_VLAN_TAG | (vlan_tx_tag_get(skb) << 16));
 	}
 #endif
-	if ((mss = skb_shinfo(skb)->gso_size)) {
-		u32 tcp_opt_len;
-		struct iphdr *iph;
+	mss = skb_shinfo(skb)->gso_size;
+	if (mss != 0) {
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
@@ -6421,14 +6423,15 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 				mss |= (tcp_off & 0xc) << TX_BD_TCP6_OFF2_SHL;
 			}
 		} else {
-			iph = ip_hdr(skb);
-			if (tcp_opt_len || (iph->ihl > 5)) {
-				vlan_tag_flags |= ((iph->ihl - 5) +
-						   (tcp_opt_len >> 2)) << 8;
-			}
+			struct iphdr *iph = ip_hdr(skb);
+			int ip_opt_words = iph->ihl - (sizeof(*iph) >> 2);
+			/* assumes positive ip_opt_words without checking */
+			int opt_words = ip_opt_words + tcp_opt_words;
+
+			if (opt_words > 0)
+				vlan_tag_flags |= opt_words << 8;
 		}
-	} else
-		mss = 0;
+	}
 
 	mapping = pci_map_single(bp->pdev, skb->data, len, PCI_DMA_TODEVICE);
 	if (pci_dma_mapping_error(bp->pdev, mapping)) {
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 3a74d21..0fd8182 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -5421,6 +5421,8 @@ static void tg3_set_txd(struct tg3_napi *tnapi, int entry,
 
 /* hard_start_xmit for devices that don't have any bugs and
  * support TG3_FLG2_HW_TSO_2 and TG3_FLG2_HW_TSO_3 only.
+ *
+ * No TCP or IP length checking, per David Miller (see commit log).
  */
 static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
 				  struct net_device *dev)
@@ -5456,9 +5458,9 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
 
 	entry = tnapi->tx_prod;
 	base_flags = 0;
-	mss = 0;
-	if ((mss = skb_shinfo(skb)->gso_size) != 0) {
-		int tcp_opt_len, ip_tcp_len;
+	mss = skb_shinfo(skb)->gso_size;
+	if (mss != 0) {
+		struct tcphdr *th;
 		u32 hdrlen;
 
 		if (skb_header_cloned(skb) &&
@@ -5466,18 +5468,16 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
 			dev_kfree_skb(skb);
 			goto out_unlock;
 		}
+		th = tcp_hdr(skb);
 
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
@@ -5491,7 +5491,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
 		base_flags |= (TXD_FLAG_CPU_PRE_DMA |
 			       TXD_FLAG_CPU_POST_DMA);
 
-		tcp_hdr(skb)->check = 0;
+		th->check = 0;
 
 	}
 	else if (skb->ip_summed == CHECKSUM_PARTIAL)
@@ -5624,6 +5624,8 @@ tg3_tso_bug_end:
 
 /* hard_start_xmit for devices that have the 4G bug and/or 40-bit bug and
  * support TG3_FLG2_HW_TSO_1 or firmware TSO only.
+ *
+ * No TCP or IP length checking, per David Miller (see commit log).
  */
 static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *skb,
 					  struct net_device *dev)
@@ -5663,20 +5665,21 @@ static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *skb,
 	if (skb->ip_summed == CHECKSUM_PARTIAL)
 		base_flags |= TXD_FLAG_TCPUDP_CSUM;
 
-	if ((mss = skb_shinfo(skb)->gso_size) != 0) {
+	mss = skb_shinfo(skb)->gso_size;
+	if (mss != 0) {
 		struct iphdr *iph;
-		u32 tcp_opt_len, ip_tcp_len, hdr_len;
+		struct tcphdr *th;
+		u32 hdr_len;
+		int opt_bytes;
 
 		if (skb_header_cloned(skb) &&
 		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
 			dev_kfree_skb(skb);
 			goto out_unlock;
 		}
+		th = tcp_hdr(skb);
+		hdr_len = ip_hdrlen(skb) + tcp_header_len_th(th);
 
-		tcp_opt_len = tcp_optlen(skb);
-		ip_tcp_len = ip_hdrlen(skb) + sizeof(struct tcphdr);
-
-		hdr_len = ip_tcp_len + tcp_opt_len;
 		if (unlikely((ETH_HLEN + hdr_len) > 80) &&
 			     (tp->tg3_flags2 & TG3_FLG2_TSO_BUG))
 			return (tg3_tso_bug(tp, skb));
@@ -5688,13 +5691,14 @@ static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *skb,
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
+		opt_bytes = hdr_len - sizeof(*iph) - sizeof(*th);
+		/* assumes positive opt_bytes without checking */
 
 		if (tp->tg3_flags2 & TG3_FLG2_HW_TSO_3) {
 			mss |= (hdr_len & 0xc) << 12;
@@ -5705,19 +5709,11 @@ static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *skb,
 			mss |= hdr_len << 9;
 		else if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_1) ||
 			 GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705) {
-			if (tcp_opt_len || iph->ihl > 5) {
-				int tsflags;
-
-				tsflags = (iph->ihl - 5) + (tcp_opt_len >> 2);
-				mss |= (tsflags << 11);
-			}
+			if (opt_bytes > 0)
+				mss |= opt_bytes << (11 - 2);
 		} else {
-			if (tcp_opt_len || iph->ihl > 5) {
-				int tsflags;
-
-				tsflags = (iph->ihl - 5) + (tcp_opt_len >> 2);
-				base_flags |= tsflags << 12;
-			}
+			if (opt_bytes > 0)
+				base_flags |= opt_bytes << (12 - 2);
 		}
 	}
 #if TG3_VLAN_TAG_USED
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index d0133cf..74728f7 100644
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
 /* Length of fixed header plus standard options. */
 static inline unsigned int tcp_header_len_th(const struct tcphdr *th)
 {
-- 
1.6.3.3


--------------050405020004050703040709--
