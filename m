From: Florian Westphal <fw@strlen.de>
Subject: [PATCH v3 -next] ip: reject too-big defragmented DF-skb when forwarding
Date: Fri, 22 May 2015 00:06:40 +0200
Message-ID: <1432246000-11104-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:36348 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756167AbbEUWGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 18:06:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Send icmp pmtu error if we find that the largest fragment of df-skb
exceeded the output path mtu.

The ip output path will still catch this later on but we can avoid the
forward/postrouting hook traversal by rejecting right away.

This is what ipv6 already does.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 No changes since v2; I moved the patch out of set defrag set
 since its independent.

 net/ipv4/ip_forward.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 3674484..2d3aa40 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -39,17 +39,21 @@
 #include <net/route.h>
 #include <net/xfrm.h>
 
-static bool ip_may_fragment(const struct sk_buff *skb)
-{
-	return unlikely((ip_hdr(skb)->frag_off & htons(IP_DF)) == 0) ||
-		skb->ignore_df;
-}
-
 static bool ip_exceeds_mtu(const struct sk_buff *skb, unsigned int mtu)
 {
 	if (skb->len <= mtu)
 		return false;
 
+	if (unlikely((ip_hdr(skb)->frag_off & htons(IP_DF)) == 0))
+		return false;
+
+	/* original fragment exceeds mtu and DF is set */
+	if (unlikely(IPCB(skb)->frag_max_size > mtu))
+		return true;
+
+	if (skb->ignore_df)
+		return false;
+
 	if (skb_is_gso(skb) && skb_gso_network_seglen(skb) <= mtu)
 		return false;
 
@@ -114,7 +118,7 @@ int ip_forward(struct sk_buff *skb)
 
 	IPCB(skb)->flags |= IPSKB_FORWARDED;
 	mtu = ip_dst_mtu_maybe_forward(&rt->dst, true);
-	if (!ip_may_fragment(skb) && ip_exceeds_mtu(skb, mtu)) {
+	if (ip_exceeds_mtu(skb, mtu)) {
 		IP_INC_STATS(dev_net(rt->dst.dev), IPSTATS_MIB_FRAGFAILS);
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
 			  htonl(mtu));
-- 
2.0.5
