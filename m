From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net 1/3] ipv4: use ip_skb_dst_mtu to determine mtu in ip_fragment
Date: Wed, 26 Feb 2014 01:20:41 +0100
Message-ID: <1393374043-796-2-git-send-email-hannes@stressinduktion.org>
References: <1393374043-796-1-git-send-email-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:52921 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752847AbaBZAUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 19:20:49 -0500
Received: from stressinduktion.org (localhost.localdomain [127.0.0.1])
	by order.stressinduktion.org (Postfix) with ESMTP id EA9D91A0C27C
	for <netdev@vger.kernel.org>; Wed, 26 Feb 2014 01:20:48 +0100 (CET)
In-Reply-To: <1393374043-796-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip_skb_dst_mtu mostly falls back to ip_dst_mtu_maybe_forward if no socket
is attached to the skb (in case of forwarding) or determines the mtu like
we do in ip_finish_output, which actually checks if we should branch to
ip_fragment. Thus use the same function to determine the mtu here, too.

This is important for the introduction of IP_PMTUDISC_OMIT, where we
want the packets getting cut in pieces of the size of the outgoing
interface mtu. IPv6 already does this correctly.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv4/ip_output.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 73c6b63..7cf80d2 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -446,7 +446,6 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 	__be16 not_last_frag;
 	struct rtable *rt = skb_rtable(skb);
 	int err = 0;
-	bool forwarding = IPCB(skb)->flags & IPSKB_FORWARDED;
 
 	dev = rt->dst.dev;
 
@@ -456,7 +455,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 
 	iph = ip_hdr(skb);
 
-	mtu = ip_dst_mtu_maybe_forward(&rt->dst, forwarding);
+	mtu = ip_skb_dst_mtu(skb);
 	if (unlikely(((iph->frag_off & htons(IP_DF)) && !skb->local_df) ||
 		     (IPCB(skb)->frag_max_size &&
 		      IPCB(skb)->frag_max_size > mtu))) {
-- 
1.8.5.3
