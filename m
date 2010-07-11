From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 3/8] tg3: Fix IPv6 TSO code in
 tg3_start_xmit_dma_bug()
Date: Sun, 11 Jul 2010 12:31:42 -0700
Message-ID: <1278876707-21390-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1308 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754613Ab0GKTb7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jul 2010 15:31:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tg3_start_xmit_dma_bug() function was missing code to process IPv6
TSO packets.  This patch adds the missing support.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |   20 ++++++++++++++------
 1 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 57dba79..efac448 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -5779,7 +5779,7 @@ static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *skb,
 
 	if ((mss = skb_shinfo(skb)->gso_size) != 0) {
 		struct iphdr *iph;
-		u32 tcp_opt_len, ip_tcp_len, hdr_len;
+		u32 tcp_opt_len, hdr_len;
 
 		if (skb_header_cloned(skb) &&
 		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
@@ -5787,10 +5787,21 @@ static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *skb,
 			goto out_unlock;
 		}
 
+		iph = ip_hdr(skb);
 		tcp_opt_len = tcp_optlen(skb);
-		ip_tcp_len = ip_hdrlen(skb) + sizeof(struct tcphdr);
 
-		hdr_len = ip_tcp_len + tcp_opt_len;
+		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6) {
+			hdr_len = skb_headlen(skb) - ETH_HLEN;
+		} else {
+			u32 ip_tcp_len;
+
+			ip_tcp_len = ip_hdrlen(skb) + sizeof(struct tcphdr);
+			hdr_len = ip_tcp_len + tcp_opt_len;
+
+			iph->check = 0;
+			iph->tot_len = htons(mss + hdr_len);
+		}
+
 		if (unlikely((ETH_HLEN + hdr_len) > 80) &&
 			     (tp->tg3_flags2 & TG3_FLG2_TSO_BUG))
 			return tg3_tso_bug(tp, skb);
@@ -5798,9 +5809,6 @@ static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *skb,
 		base_flags |= (TXD_FLAG_CPU_PRE_DMA |
 			       TXD_FLAG_CPU_POST_DMA);
 
-		iph = ip_hdr(skb);
-		iph->check = 0;
-		iph->tot_len = htons(mss + hdr_len);
 		if (tp->tg3_flags2 & TG3_FLG2_HW_TSO) {
 			tcp_hdr(skb)->check = 0;
 			base_flags &= ~TXD_FLAG_TCPUDP_CSUM;
-- 
1.6.4.4


