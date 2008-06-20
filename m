From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH] tg3: Separate TSO setup logic.
Date: Thu, 19 Jun 2008 20:04:48 -0700
Message-ID: <1213931088-8013-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3818 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751598AbYFTDCz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jun 2008 23:02:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, this goes on top of the 3rd patch to manage TX backlog.

tg3: Separate TSO setup logic.

Different TG3 chips require slightly different ways of setting up the
TX descriptor and different initial values for some IP/TCP header
fields.  It is cleaner to have dedicated TSO setup methods for the
different chips and to call the proper one using a function pointer.
The missing logic for TG3_FLG2_HW_TSO_2 has also been added.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |  133 ++++++++++++++++++++++++++++++++++++-----------------
 drivers/net/tg3.h |    3 +
 2 files changed, 94 insertions(+), 42 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index db960f8..f1cdee7 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4767,6 +4767,93 @@ tg3_tso_bug_end:
 	return entry;
 }
 
+static int tg3_setup_fw_tso(struct tg3 *tp, struct sk_buff *skb, u32 *mss,
+			    u32 *base_flags)
+{
+	int tcp_opt_len, ip_tcp_len, hdr_len;
+	struct iphdr *iph;
+
+	tcp_opt_len = tcp_optlen(skb);
+	ip_tcp_len = ip_hdrlen(skb) + sizeof(struct tcphdr);
+
+	hdr_len = ip_tcp_len + tcp_opt_len;
+
+	if (unlikely((ETH_HLEN + hdr_len) > 80))
+		return -E2BIG;
+
+	*base_flags |= (TXD_FLAG_CPU_PRE_DMA | TXD_FLAG_CPU_POST_DMA);
+
+	iph = ip_hdr(skb);
+	iph->check = 0;
+	iph->tot_len = htons(*mss + hdr_len);
+
+	tcp_hdr(skb)->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr, 0,
+						 IPPROTO_TCP, 0);
+
+	if (tcp_opt_len || iph->ihl > 5) {
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705)
+			*mss |= ((iph->ihl - 5) + (tcp_opt_len >> 2)) << 11;
+		else
+			*base_flags |= ((iph->ihl - 5) + (tcp_opt_len >> 2)) <<
+				       12;
+	}
+
+	return 0;
+}
+
+static int tg3_setup_hw1_tso(struct tg3 *tp, struct sk_buff *skb, u32 *mss,
+			     u32 *base_flags)
+{
+	int tcp_opt_len, ip_tcp_len, hdr_len;
+	struct iphdr *iph;
+
+	tcp_opt_len = tcp_optlen(skb);
+	ip_tcp_len = ip_hdrlen(skb) + sizeof(struct tcphdr);
+
+	hdr_len = ip_tcp_len + tcp_opt_len;
+
+	if (unlikely((ETH_HLEN + hdr_len) > 80) &&
+		     (tp->tg3_flags2 & TG3_FLG2_TSO_BUG))
+		return -E2BIG;
+
+	*base_flags |= (TXD_FLAG_CPU_PRE_DMA | TXD_FLAG_CPU_POST_DMA);
+	*base_flags &= ~TXD_FLAG_TCPUDP_CSUM;
+
+	iph = ip_hdr(skb);
+	iph->check = 0;
+	iph->tot_len = htons(*mss + hdr_len);
+
+	tcp_hdr(skb)->check = 0;
+
+	if (tcp_opt_len || iph->ihl > 5)
+		*mss |= ((iph->ihl - 5) + (tcp_opt_len >> 2)) << 11;
+
+	return 0;
+}
+
+static int tg3_setup_hw2_tso(struct tg3 *tp, struct sk_buff *skb, u32 *mss,
+			     u32 *base_flags)
+{
+	if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
+		*mss |= (skb_headlen(skb) - ETH_HLEN) << 9;
+	else {
+		int tcp_opt_len, ip_tcp_len;
+		struct iphdr *iph = ip_hdr(skb);
+
+		tcp_opt_len = tcp_optlen(skb);
+		ip_tcp_len = ip_hdrlen(skb) + sizeof(struct tcphdr);
+
+		iph->check = 0;
+		iph->tot_len = htons(*mss + ip_tcp_len + tcp_opt_len);
+		*mss |= (ip_tcp_len + tcp_opt_len) << 9;
+	}
+	*base_flags |= (TXD_FLAG_CPU_PRE_DMA | TXD_FLAG_CPU_POST_DMA);
+	*base_flags &= ~TXD_FLAG_TCPUDP_CSUM;
+
+	tcp_hdr(skb)->check = 0;
+	return 0;
+}
+
 /* Transmit one SKB, return the final TX descriptor slot used.
  * No errors may be returned.  If something occurs which prevents
  * sending this packet, it will be dropped.
@@ -4784,55 +4871,14 @@ static u32 __tg3_xmit_one(struct tg3 *tp, struct net_device *dev,
 		base_flags |= TXD_FLAG_TCPUDP_CSUM;
 
 	if ((mss = skb_shinfo(skb)->gso_size) != 0) {
-		int tcp_opt_len, ip_tcp_len, hdr_len;
-		struct iphdr *iph;
-
 		if (skb_header_cloned(skb) &&
 		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
 			dev_kfree_skb(skb);
 			goto out;
 		}
 
-		tcp_opt_len = tcp_optlen(skb);
-		ip_tcp_len = ip_hdrlen(skb) + sizeof(struct tcphdr);
-
-		hdr_len = ip_tcp_len + tcp_opt_len;
-
-		if (unlikely((ETH_HLEN + hdr_len) > 80) &&
-			     (tp->tg3_flags2 & TG3_FLG2_TSO_BUG))
+		if (unlikely(tp->setup_tso(tp, skb, &mss, &base_flags)))
 			return tg3_tso_bug(tp, dev, skb, entry);
-
-		base_flags |= (TXD_FLAG_CPU_PRE_DMA |
-			       TXD_FLAG_CPU_POST_DMA);
-
-		iph = ip_hdr(skb);
-		iph->check = 0;
-		iph->tot_len = htons(mss + hdr_len);
-		if (tp->tg3_flags2 & TG3_FLG2_HW_TSO) {
-			tcp_hdr(skb)->check = 0;
-			base_flags &= ~TXD_FLAG_TCPUDP_CSUM;
-		} else
-			tcp_hdr(skb)->check = ~csum_tcpudp_magic(iph->saddr,
-								 iph->daddr, 0,
-								 IPPROTO_TCP,
-								 0);
-
-		if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO) ||
-		    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705)) {
-			if (tcp_opt_len || iph->ihl > 5) {
-				int tsflags;
-
-				tsflags = (iph->ihl - 5) + (tcp_opt_len >> 2);
-				mss |= (tsflags << 11);
-			}
-		} else {
-			if (tcp_opt_len || iph->ihl > 5) {
-				int tsflags;
-
-				tsflags = (iph->ihl - 5) + (tcp_opt_len >> 2);
-				base_flags |= tsflags << 12;
-			}
-		}
 	}
 #if TG3_VLAN_TAG_USED
 	if (tp->vlgrp != NULL && vlan_tx_tag_present(skb))
@@ -11969,6 +12015,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    (tp->tg3_flags2 & TG3_FLG2_5750_PLUS))
 		tp->tg3_flags2 |= TG3_FLG2_5705_PLUS;
 
+	tp->setup_tso = tg3_setup_fw_tso;
 	if (tp->tg3_flags2 & TG3_FLG2_5750_PLUS) {
 		tp->tg3_flags |= TG3_FLAG_SUPPORT_MSI;
 		if (GET_CHIP_REV(tp->pci_chip_rev_id) == CHIPREV_5750_AX ||
@@ -11986,8 +12033,10 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
 			tp->tg3_flags2 |= TG3_FLG2_HW_TSO_2;
 			tp->tg3_flags2 |= TG3_FLG2_1SHOT_MSI;
+			tp->setup_tso = tg3_setup_hw2_tso;
 		} else {
 			tp->tg3_flags2 |= TG3_FLG2_HW_TSO_1 | TG3_FLG2_TSO_BUG;
+			tp->setup_tso = tg3_setup_hw1_tso;
 			if (GET_ASIC_REV(tp->pci_chip_rev_id) ==
 				ASIC_REV_5750 &&
 	     		    tp->pci_chip_rev_id >= CHIPREV_ID_5750_C2)
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index d396c87..1792d47 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2388,6 +2388,9 @@ struct tg3 {
 	/* begin "tx thread" cacheline section */
 	void				(*write32_tx_mbox) (struct tg3 *, u32,
 							    u32);
+	int				(*setup_tso) (struct tg3 *,
+						      struct sk_buff *,
+						      u32 *, u32 *);
 	u32				tx_prod;
 	u32				tx_cons;
 	u32				tx_pending;
-- 
1.5.5.GIT


