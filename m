From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ip6_tunnel: add optional fwmark inherit
Date: Mon, 19 Sep 2011 18:27:26 +0200
Message-ID: <1316449646.2539.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <C8A6796DE7C66C4ABCBC18106CB6C1CC106D903109@ESESSCMS0356.eemea.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Anders Franzen <Anders.Franzen@ericsson.com>
To: Hans =?ISO-8859-1?Q?Schillstr=F6m?=
	<hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47993 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756462Ab1ISQ1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 12:27:16 -0400
Received: by wwf22 with SMTP id 22so8228983wwf.1
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2011 09:27:15 -0700 (PDT)
In-Reply-To: <C8A6796DE7C66C4ABCBC18106CB6C1CC106D903109@ESESSCMS0356.eemea.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 19 septembre 2011 =C3=A0 10:47 +0200, Hans Schillstr=C3=B6m a =
=C3=A9crit :
> Hello Eric,
> For a year ago you send an untested patch to Anders Franzen=20
> I think the subject was "not possible to do policy routing for next h=
op on tunnels."
>=20
> The patch have been used since that and it works perfectly,
> I made some minor changes to reflect the flowi changes.
>=20
> Would it be possible for you to submit that patch, since (I guess) yo=
u are the author=20
> I can prepare it if you want.
> The included patch is for  linux-3.0.4

Here is an official patch submisssion, for net-next :

Its slightly different than linux-3.0 kernel because of recent changes
on ip6_tunnel.c file.

[PATCH net-next] ip6_tunnel: add optional fwmark inherit

Add IP6_TNL_F_USE_ORIG_FWMARK to ip6_tunnel, so that ip6_tnl_xmit2()
makes a route lookup taking into account skb->fwmark and doesnt cache
lookup result.

This permits more flexibility in policies and firewall setups.

To setup such a tunnel, "fwmark inherit" option should be added to "ip
-f inet6 tunnel" command.

Reported-by: Anders Franzen <Anders.Franzen@ericsson.com>
CC: Hans Schillstr=C3=B6m <hans.schillstrom@ericsson.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/ip6_tunnel.h |    2 ++
 net/ipv6/ip6_tunnel.c      |   23 +++++++++++++++++-------
 2 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/include/linux/ip6_tunnel.h b/include/linux/ip6_tunnel.h
index acb9ad6..bf22b03 100644
--- a/include/linux/ip6_tunnel.h
+++ b/include/linux/ip6_tunnel.h
@@ -16,6 +16,8 @@
 #define IP6_TNL_F_MIP6_DEV 0x8
 /* copy DSCP from the outer packet */
 #define IP6_TNL_F_RCV_DSCP_COPY 0x10
+/* copy fwmark from inner packet */
+#define IP6_TNL_F_USE_ORIG_FWMARK 0x20
=20
 struct ip6_tnl_parm {
 	char name[IFNAMSIZ];	/* name of tunnel device */
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 694d70a..bdc15c9 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -889,7 +889,7 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 	struct net_device_stats *stats =3D &t->dev->stats;
 	struct ipv6hdr *ipv6h =3D ipv6_hdr(skb);
 	struct ipv6_tel_txoption opt;
-	struct dst_entry *dst, *ndst =3D NULL;
+	struct dst_entry *dst =3D NULL, *ndst =3D NULL;
 	struct net_device *tdev;
 	int mtu;
 	unsigned int max_headroom =3D sizeof(struct ipv6hdr);
@@ -897,7 +897,8 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 	int err =3D -1;
 	int pkt_len;
=20
-	dst =3D ip6_tnl_dst_check(t);
+	if (!fl6->flowi6_mark)
+		dst =3D ip6_tnl_dst_check(t);
 	if (!dst) {
 		ndst =3D ip6_route_output(net, NULL, fl6);
=20
@@ -955,8 +956,12 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 		skb =3D new_skb;
 	}
 	skb_dst_drop(skb);
-	skb_dst_set_noref(skb, dst);
-
+	if (fl6->flowi6_mark) {
+		skb_dst_set(skb, dst);
+		ndst =3D NULL;
+	} else {
+		skb_dst_set_noref(skb, dst);
+	}
 	skb->transport_header =3D skb->network_header;
=20
 	proto =3D fl6->flowi6_proto;
@@ -1021,9 +1026,11 @@ ip4ip6_tnl_xmit(struct sk_buff *skb, struct net_=
device *dev)
=20
 	dsfield =3D ipv4_get_dsfield(iph);
=20
-	if ((t->parms.flags & IP6_TNL_F_USE_ORIG_TCLASS))
+	if (t->parms.flags & IP6_TNL_F_USE_ORIG_TCLASS)
 		fl6.flowlabel |=3D htonl((__u32)iph->tos << IPV6_TCLASS_SHIFT)
 					  & IPV6_TCLASS_MASK;
+	if (t->parms.flags & IP6_TNL_F_USE_ORIG_FWMARK)
+		fl6.flowi6_mark =3D skb->mark;
=20
 	err =3D ip6_tnl_xmit2(skb, dev, dsfield, &fl6, encap_limit, &mtu);
 	if (err !=3D 0) {
@@ -1070,10 +1077,12 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net=
_device *dev)
 	fl6.flowi6_proto =3D IPPROTO_IPV6;
=20
 	dsfield =3D ipv6_get_dsfield(ipv6h);
-	if ((t->parms.flags & IP6_TNL_F_USE_ORIG_TCLASS))
+	if (t->parms.flags & IP6_TNL_F_USE_ORIG_TCLASS)
 		fl6.flowlabel |=3D (*(__be32 *) ipv6h & IPV6_TCLASS_MASK);
-	if ((t->parms.flags & IP6_TNL_F_USE_ORIG_FLOWLABEL))
+	if (t->parms.flags & IP6_TNL_F_USE_ORIG_FLOWLABEL)
 		fl6.flowlabel |=3D (*(__be32 *) ipv6h & IPV6_FLOWLABEL_MASK);
+	if (t->parms.flags & IP6_TNL_F_USE_ORIG_FWMARK)
+		fl6.flowi6_mark =3D skb->mark;
=20
 	err =3D ip6_tnl_xmit2(skb, dev, dsfield, &fl6, encap_limit, &mtu);
 	if (err !=3D 0) {
