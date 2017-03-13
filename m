From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf] ipv6: avoid write to a possibly cloned skb
Date: Mon, 13 Mar 2017 16:24:28 +0100
Message-ID: <20170313152428.12514-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:33590 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751095AbdCMPYN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 11:24:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip6_fragment, in case skb has a fraglist, checks if the
skb is cloned.  If it is, it will move to the 'slow path' and allocates
new skbs for each fragment.

However, right before entering the slowpath loop, it updates the
nexthdr value of the last ipv6 extension header to NEXTHDR_FRAGMENT,
to account for the fragment header that will be inserted in the new
ipv6-fragment skbs.

In case original skb is cloned this munges nexthdr value of another
skb.  Avoid this by doing the nexthdr update for each of the new fragment
skbs separately.

This was observed with tcpdump on a bridge device where netfilter ipv6
reassembly is active:  tcpdump shows malformed fragment headers as
the l4 header (icmpv6, tcp, etc). is decoded as a fragment header.

Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Reported-by: Andreas Karis <akaris@redhat.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv6/ip6_output.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 528b3c1f3fde..2851a1558b89 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -768,13 +768,14 @@ int ip6_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 	 *	Fragment the datagram.
 	 */
 
-	*prevhdr = NEXTHDR_FRAGMENT;
 	troom = rt->dst.dev->needed_tailroom;
 
 	/*
 	 *	Keep copying data until we run out.
 	 */
 	while (left > 0)	{
+		u8 *fragnexthdr_offset;
+
 		len = left;
 		/* IF: it doesn't fit, use 'mtu' - the data space left */
 		if (len > mtu)
@@ -819,6 +820,10 @@ int ip6_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 		 */
 		skb_copy_from_linear_data(skb, skb_network_header(frag), hlen);
 
+		fragnexthdr_offset = skb_network_header(frag);
+		fragnexthdr_offset += prevhdr - skb_network_header(skb);
+		*fragnexthdr_offset = NEXTHDR_FRAGMENT;
+
 		/*
 		 *	Build fragment header.
 		 */
-- 
2.10.2
