From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [PATCH|RFC] IPv6 netfilter: a module for complete proxy ND
 support
Date: Fri, 16 Jan 2004 11:40:22 +0200 (EET)
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <Pine.LNX.4.58.0401151800170.29722@rhea.tcs.hut.fi>
References: <Pine.LNX.4.58.0401151705500.29722@rhea.tcs.hut.fi>
 <20040116.001317.73950271.yoshfuji@linux-ipv6.org>
 <Pine.LNX.4.58.0401151719160.29722@rhea.tcs.hut.fi>
 <20040116.005443.92504522.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@lists.netfilter.org, davem@redhat.com,
	netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: =?iso-8859-15?Q?YOSHIFUJI_Hideaki_=2F_=B5=C8=C6=A3=B1=D1=CC=C0?= <yoshfuji@linux-ipv6.org>,
	pekkas@netcore.fi
In-Reply-To: <20040116.005443.92504522.yoshfuji@linux-ipv6.org>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

On Fri, 16 Jan 2004, YOSHIFUJI Hideaki / [iso-2022-jp] =B5=C8=C6=A3=B1=D1=
=CC=C0 wrote:

> So, all usage of pneigh_XXX() is not for rfc2461 but for proxy arp.
> 1) We need to consider how to implement rfc2461-proxy.
> 2) We need to revisit all usages in net/ipv6.

No, no! The pneigh_XXX() *is* the way to do RFC2461 proxying :)
I think Thaler's extended "proxy ARP" for IPv6 needs some other framework.

I still haven't had the time to check how proxy ARP really works in IPv4,
so I might have misunderstood this line in arp.c (line 763):

"(arp_fwd_proxy(in_dev, rt) || pneigh_lookup(&arp_tbl, &tip, dev, 0)))) {"

I think the first check is for proxy ARP, and the second for a router
acting as proxy.

In a similar case for IPv6, we would first need to check for the Thaler
IPv6 "proxy ARP", then for the RFC2461 router as a proxy case.

> > In the current implementation the proxying router captures the multicas=
t
> > queries since it has joined the solicited-node multicast group, but it
> > doesn't capture the unicast queries.
>
> It is VERY strange to handle multicast / unicast in different way.
> I really hate such a hetero (or an inconsistent) implementation.

Well, we still need some way to have the router capture some packets (the
unicast NS messages) it would normally forward.

> > This is what I want to fix.
>
> I understand the issue, but the fix is unappropriate.

Ok. Having slept on the matter, here is a new attempt to fix the probem,
which I think is cleaner than the one I proposed earlier. The down side is
of course that all nodes, no matter if they are acting as proxies or not,
will have to do some extra comparisons each time they receive a packet.

Perhaps this is an acceptable trade off for the architectual cleanness.

Regards,
Ville

Ps. this patch is just a RFC, I haven't had a chance to test it yet!

=3D=3D=3D=3D=3D net/ipv6/ip6_input.c 1.14 vs edited =3D=3D=3D=3D=3D
--- 1.14/net/ipv6/ip6_input.c=09Mon Jun 16 18:11:36 2003
+++ edited/net/ipv6/ip6_input.c=09Fri Jan 16 11:13:06 2004
@@ -46,13 +46,41 @@
 #include <net/addrconf.h>
 #include <net/xfrm.h>

+static inline int ip6_proxy_rcv(struct sk_buff *skb)
+{
+=09struct ipv6hdr *hdr =3D skb->nh.ipv6h;

+=09if (ipv6_addr_type(&hdr->daddr)&IPV6_ADDR_UNICAST &&
+=09    pneigh_lookup(&nd_tbl, &hdr->daddr, skb->dev, 0)) {
+=09=09u8 nexthdr =3D hdr->nexthdr;
+=09=09int offset;
+=09=09struct icmp6hdr msg;
+
+=09=09if (ipv6_ext_hdr(nexthdr)) {
+=09=09=09offset =3D ipv6_skip_exthdr(skb, sizeof(*hdr), &nexthdr,
+=09=09=09=09=09=09  skb->len - sizeof(*hdr));
+=09=09=09if (offset < 0)
+=09=09=09=09return 0;
+=09=09} else
+=09=09=09offset =3D sizeof(struct ipv6hdr);
+
+=09=09/* capture unicast NUD probes on behalf of the proxied node */
+
+=09=09if (nexthdr =3D=3D IPPROTO_ICMPV6 &&
+=09=09    !skb_copy_bits(skb, offset, &msg, sizeof(msg)) &&
+=09=09    msg.icmp6_type =3D=3D NDISC_NEIGHBOUR_SOLICITATION) {
+=09=09=09ip6_input(skb);
+=09=09=09return 1;
+=09=09}
+=09}
+=09return 0;
+}

 static inline int ip6_rcv_finish( struct sk_buff *skb)
 {
-=09if (skb->dst =3D=3D NULL)
+=09if (skb->dst =3D=3D NULL && !ip6_proxy_rcv(skb)) {
 =09=09ip6_route_input(skb);
-
+=09}
 =09return dst_input(skb);
 }


--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
