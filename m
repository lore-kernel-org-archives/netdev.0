From: Florian Westphal <fw@strlen.de>
Subject: [PATCH] net: ipv6: send pkttoobig immediately if orig frag size > mtu
Date: Mon,  5 May 2014 00:03:34 +0200
Message-ID: <1399241014-32471-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:34891 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753811AbaEDWIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2014 18:08:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If conntrack defragments incoming ipv6 frags it stores largest original
frag size in ip6cb and sets ->local_df.

We must thus first test the largest original frag size vs. mtu, and not
vice versa.

Without this patch PKTTOOBIG is still generated in ip6_fragment() later
in the stack, but

1) IPSTATS_MIB_INTOOBIGERRORS won't increment
2) packet did (needlessly) traverse netfilter postrouting hook.

Fixes: fe6cc55f3a9 ("net: ip, ipv6: handle gso skbs in forwarding path")
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv6/ip6_output.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 40e7581..31a38bd 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -344,12 +344,16 @@ static unsigned int ip6_dst_mtu_forward(const struct dst_entry *dst)
 
 static bool ip6_pkt_too_big(const struct sk_buff *skb, unsigned int mtu)
 {
-	if (skb->len <= mtu || skb->local_df)
+	if (skb->len <= mtu)
 		return false;
 
+	/* ipv6 conntrack defrag sets max_frag_size + local_df */
 	if (IP6CB(skb)->frag_max_size && IP6CB(skb)->frag_max_size > mtu)
 		return true;
 
+	if (skb->local_df)
+		return false;
+
 	if (skb_is_gso(skb) && skb_gso_network_seglen(skb) <= mtu)
 		return false;
 
-- 
1.8.1.5
