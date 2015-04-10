From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next 1/3] ipv4: reject too-big defragmented DF-skb when forwarding
Date: Sat, 11 Apr 2015 00:16:27 +0200
Message-ID: <1428704189-31247-2-git-send-email-fw@strlen.de>
References: <1428704189-31247-1-git-send-email-fw@strlen.de>
Cc: kaber@trash.net, Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:59131 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932277AbbDJWQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 18:16:48 -0400
In-Reply-To: <1428704189-31247-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Send icmp pmtu error if we find that the largest fragment of df-skb
exceeded the output path mtu.

The ip output path will still catch this later on but we can avoid the
forward/postrouting hook traversal by rejecting right away.

This is what ipv6 already does.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/ip_forward.c | 19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 939992c..494f62b 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -39,17 +39,22 @@
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
+	if (unlikely((ip_hdr(skb)->frag_off & htons(IP_DF)) == 0))
+		return false;
+
 	if (skb->len <= mtu)
 		return false;
 
+	/* original fragment had DF set */
+	if (unlikely(IPCB(skb)->frag_max_size) &&
+	    IPCB(skb)->frag_max_size > mtu)
+		return true;
+
+	if (skb->ignore_df)
+		return false;
+
 	if (skb_is_gso(skb) && skb_gso_network_seglen(skb) <= mtu)
 		return false;
 
@@ -111,7 +116,7 @@ int ip_forward(struct sk_buff *skb)
 
 	IPCB(skb)->flags |= IPSKB_FORWARDED;
 	mtu = ip_dst_mtu_maybe_forward(&rt->dst, true);
-	if (!ip_may_fragment(skb) && ip_exceeds_mtu(skb, mtu)) {
+	if (ip_exceeds_mtu(skb, mtu)) {
 		IP_INC_STATS(dev_net(rt->dst.dev), IPSTATS_MIB_FRAGFAILS);
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
 			  htonl(mtu));
-- 
2.0.5
