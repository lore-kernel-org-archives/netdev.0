From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [PATCH|RFC] IPv6 netfilter: a module for complete proxy ND
 support
Date: Tue, 27 Jan 2004 22:58:02 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0401272244360.28384@rhea.tcs.hut.fi>
References: <Pine.LNX.4.58.0401151705500.29722@rhea.tcs.hut.fi>
 <20040116.001317.73950271.yoshfuji@linux-ipv6.org>
 <Pine.LNX.4.58.0401151719160.29722@rhea.tcs.hut.fi>
 <20040116.005443.92504522.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-15
Content-Transfer-Encoding: quoted-printable
Cc: netfilter-devel@lists.netfilter.org, davem@redhat.com, netdev@oss.sgi.com,
        kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20040116.005443.92504522.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

netdev apparently ate my reply, but let me do a recap:

On Fri, 16 Jan 2004, YOSHIFUJI Hideaki / [iso-2022-jp] =B5=C8=C6=A3=B1=D1=
=CC=C0 wrote:

> So, all usage of pneigh_XXX() is not for rfc2461 but for proxy arp.
> 1) We need to consider how to implement rfc2461-proxy.
> 2) We need to revisit all usages in net/ipv6.

No, the pneigh_XXX() *is* the way to do RFC2461 proxying :)
I think Thaler's extended "proxy ARP" for IPv6 needs some other framework.

I still haven't had the time to check how proxy ARP really works in IPv4,
so I might have misunderstood this line in arp.c (line 763):

"(arp_fwd_proxy(in_dev, rt) || pneigh_lookup(&arp_tbl, &tip, dev, 0)))) {=
"

I think the first check is for proxy ARP, and the second for a router
acting as proxy.

In a similar case for IPv6, we would first need to check for the Thaler
IPv6 "proxy ARP", then for the RFC2461 router as a proxy case.

> > In the current implementation the proxying router captures the multic=
ast
> > queries since it has joined the solicited-node multicast group, but i=
t
> > doesn't capture the unicast queries.
>
> It is VERY strange to handle multicast / unicast in different way.
> I really hate such a hetero (or an inconsistent) implementation.

Well, we still need some way to have the router capture some packets (the
unicast NS messages) it would normally forward.>

> > This is what I want to fix.
>
> I understand the issue, but the fix is unappropriate.

How about this fix? I think it's cleaner than the one I proposed
earlier. The down side with it is that all nodes, no matter if they are
acting as proxies or not, will have to do some extra comparisons each tim=
e
they receive a packet.

Perhaps this is an acceptable trade off for the architectual cleannes

Regards,
Ville


# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or high=
er.
# This patch includes the following deltas:
#	           ChangeSet	1.1520  -> 1.1521
#	net/ipv6/ip6_input.c	1.14    -> 1.15
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/01/27	vnuorval@dsl-hkigw1o3c.dial.inet.fi	1.1521
# A proxy needs to capture and process Neighbor Solicitations on behalf o=
f the proxied node.
# Normal multicast NS messages are already handled by the existing neigbo=
r discovery code,
# but unicast NS messages used for Neighbor Unreachability Detection are =
not.
#
# To fix this, the proxy has to look through all packets sent to a proxie=
d address in order to
# filter out the NS messages for local processing.
# --------------------------------------------
#
diff -Nru a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
--- a/net/ipv6/ip6_input.c	Tue Jan 27 22:07:00 2004
+++ b/net/ipv6/ip6_input.c	Tue Jan 27 22:07:00 2004
@@ -46,13 +46,42 @@
 #include <net/addrconf.h>
 #include <net/xfrm.h>

+static inline int ip6_proxy_chk(struct sk_buff *skb)
+{
+	struct ipv6hdr *hdr =3D skb->nh.ipv6h;

+	if (ipv6_addr_type(&hdr->daddr)&IPV6_ADDR_UNICAST &&
+	    pneigh_lookup(&nd_tbl, &hdr->daddr, skb->dev, 0)) {
+		u8 nexthdr =3D hdr->nexthdr;
+		int offset;
+		struct icmp6hdr msg;
+
+		if (ipv6_ext_hdr(nexthdr)) {
+			offset =3D ipv6_skip_exthdr(skb, sizeof(*hdr), &nexthdr,
+						  skb->len - sizeof(*hdr));
+			if (offset < 0)
+				return 0;
+		} else
+			offset =3D sizeof(struct ipv6hdr);
+
+		/* capture unicast NUD probes on behalf of the proxied node */
+
+		if (nexthdr =3D=3D IPPROTO_ICMPV6 &&
+		    !skb_copy_bits(skb, offset, &msg, sizeof(msg)) &&
+		    msg.icmp6_type =3D=3D NDISC_NEIGHBOUR_SOLICITATION) {
+			return 1;
+		}
+	}
+	return 0;
+}

 static inline int ip6_rcv_finish( struct sk_buff *skb)
 {
-	if (skb->dst =3D=3D NULL)
+	if (skb->dst =3D=3D NULL) {
+		if (ip6_proxy_chk(skb))
+			return ip6_input(skb);
 		ip6_route_input(skb);
-
+	}
 	return dst_input(skb);
 }

--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
