From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [PATCH|RFC] IPv6: have a proxy discard link-local traffic
Date: Tue, 27 Jan 2004 23:11:20 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0401272259160.28384@rhea.tcs.hut.fi>
References: <Pine.LNX.4.44.0401170906160.9907-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pekka Savola <pekkas@netcore.fi>, usagi-core@linux-ipv6.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, yoshfuji@linux-ipv6.org
In-Reply-To: <Pine.LNX.4.44.0401170906160.9907-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 17 Jan 2004, Pekka Savola wrote:

> > Since the Thaler proxy clearly needs some other forwarding function than
> > ip6_forward(), my proposed patch doesn't affect its behavior in any way.
>
> Ok, if your modification is in ip6_forward() (I didn't check), I guess
> it would OK, with a sufficient comment to bring up that a future
> implementation might treat link-local proxying differently.

Dave, since even Pekka is now convinced this patch doesn't break anything,
would you consider applying it? :)

Slightly (cleaned up version of) patch below.

Thanks,
Ville

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1521  -> 1.1522
#	net/ipv6/ip6_output.c	1.49    -> 1.50
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/01/27	vnuorval@dsl-hkigw1o3c.dial.inet.fi	1.1522
# The MIPv6 specification requires we send an ICMPv6 Destination Unreachable,
# Address Unreachable, message in response to traffic to a proxied link-local address
# --------------------------------------------
#
diff -Nru a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
--- a/net/ipv6/ip6_output.c	Tue Jan 27 22:05:56 2004
+++ b/net/ipv6/ip6_output.c	Tue Jan 27 22:05:56 2004
@@ -385,6 +385,15 @@
 	if (!xfrm6_route_forward(skb))
 		goto drop;

+	/* The proxying router can't forward traffic sent to a link-local
+	   address, so signal the sender and discard the packet. This
+	   behavior is required by the MIPv6 specification. */
+
+	if (ipv6_addr_type(&hdr->daddr) & IPV6_ADDR_LINKLOCAL &&
+	    skb->dev && pneigh_lookup(&nd_tbl, &hdr->daddr, skb->dev, 0)) {
+		dst_link_failure(skb);
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
