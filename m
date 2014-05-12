From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 2/3] tg3: Prevent page allocation failure during TSO workaround
Date: Sun, 11 May 2014 20:22:54 -0700
Message-ID: <1399864975-29070-3-git-send-email-mchan@broadcom.com>
References: <1399864975-29070-1-git-send-email-mchan@broadcom.com>
 <1399864975-29070-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <prashant@broadcom.com>,
	<ivecera@redhat.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:6585 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932496AbaELCCS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2014 22:02:18 -0400
In-Reply-To: <1399864975-29070-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If any TSO fragment hits hardware bug conditions (e.g. 4G boundary), the
driver will workaround by calling skb_copy() to copy to a linear SKB.  Users
have reported page allocation failures as the TSO packet can be up to 64K.
Copying such a large packet is also very inefficient.  We fix this by using
existing tg3_tso_bug() to transmit the packet using GSO.

Signed-off-by: Prashant Sreedharan <prashant@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   33 ++++++++++++++++++++++++++-------
 1 files changed, 26 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index bdfd08b..36b2b51 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -7882,6 +7882,10 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct tg3_napi *tnapi;
 	struct netdev_queue *txq;
 	unsigned int last;
+	struct iphdr *iph = NULL;
+	struct tcphdr *tcph = NULL;
+	__sum16 tcp_csum = 0, ip_csum = 0;
+	__be16 ip_tot_len = 0;
 
 	txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
 	tnapi = &tp->napi[skb_get_queue_mapping(skb)];
@@ -7913,7 +7917,6 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	mss = skb_shinfo(skb)->gso_size;
 	if (mss) {
-		struct iphdr *iph;
 		u32 tcp_opt_len, hdr_len;
 
 		if (skb_cow_head(skb, 0))
@@ -7929,6 +7932,8 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			    tg3_flag(tp, TSO_BUG))
 				return tg3_tso_bug(tp, skb);
 
+			ip_csum = iph->check;
+			ip_tot_len = iph->tot_len;
 			iph->check = 0;
 			iph->tot_len = htons(mss + hdr_len);
 		}
@@ -7936,16 +7941,18 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		base_flags |= (TXD_FLAG_CPU_PRE_DMA |
 			       TXD_FLAG_CPU_POST_DMA);
 
+		tcph = tcp_hdr(skb);
+		tcp_csum = tcph->check;
+
 		if (tg3_flag(tp, HW_TSO_1) ||
 		    tg3_flag(tp, HW_TSO_2) ||
 		    tg3_flag(tp, HW_TSO_3)) {
-			tcp_hdr(skb)->check = 0;
+			tcph->check = 0;
 			base_flags &= ~TXD_FLAG_TCPUDP_CSUM;
-		} else
-			tcp_hdr(skb)->check = ~csum_tcpudp_magic(iph->saddr,
-								 iph->daddr, 0,
-								 IPPROTO_TCP,
-								 0);
+		} else {
+			tcph->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr,
+							 0, IPPROTO_TCP, 0);
+		}
 
 		if (tg3_flag(tp, HW_TSO_3)) {
 			mss |= (hdr_len & 0xc) << 12;
@@ -8045,6 +8052,18 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (would_hit_hwbug) {
 		tg3_tx_skb_unmap(tnapi, tnapi->tx_prod, i);
 
+		if (mss) {
+			/* If it's a TSO packet, do GSO instead of
+			 * allocating and copying to a large linear SKB
+			 */
+			if (ip_tot_len) {
+				iph->check = ip_csum;
+				iph->tot_len = ip_tot_len;
+			}
+			tcph->check = tcp_csum;
+			return tg3_tso_bug(tp, skb);
+		}
+
 		/* If the workaround fails due to memory/mapping
 		 * failure, silently drop this packet.
 		 */
-- 
1.7.1
