From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH|RFC] IPv6: have a proxy discard link-local traffic
Date: Wed, 14 Jan 2004 12:50:34 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0401141108530.24125@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, usagi-core@linux-ipv6.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave & Co,

the patch below causes a router proxying a link-local address to discard
traffic sent to it, also sending an ICMPv6 Destination Unreachable, Code 3
message to the source. This behavior is required by the Mobile IPv6
specification (the only user of proxy ND I'm aware of).

This seems like reasonable behavior in any case, since the router won't be
able to forward the link-local traffic to the proxied node anyway.

Thanks,
Ville

===== net/ipv6/ip6_output.c 1.48 vs 1.50 =====
--- 1.48/net/ipv6/ip6_output.c	Thu Jan  1 22:25:30 2004
+++ 1.50/net/ipv6/ip6_output.c	Wed Jan 14 12:08:51 2004
@@ -385,6 +385,15 @@
 	if (!xfrm6_route_forward(skb))
 		goto drop;

+	/* The proxy can't forward traffic sent to a link-local address,
+	   so signal the sender and discard the packet */
+
+	if (ipv6_addr_type(&hdr->daddr) & IPV6_ADDR_LINKLOCAL &&
+	    skb->dev && pneigh_lookup(&nd_tbl, &hdr->daddr, skb->dev, 0)) {
+		icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_ADDR_UNREACH,
+			    0, skb->dev);
+		goto drop;
+	}
 	/* IPv6 specs say nothing about it, but it is clear that we cannot
 	   send redirects to source routed frames.
 	 */
--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
