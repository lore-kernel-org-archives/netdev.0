From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
Subject: Re: [CHECKER] 32 Memory Leaks on Error Paths
Date: Tue, 16 Sep 2003 11:07:48 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030916090748.GE27703@wohnheim.fh-wedel.de>
References: <200309160435.h8G4ZkQM009953@elaine4.Stanford.EDU>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org, mc@cs.stanford.edu, davem@redhat.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Yu Chen <dychen@stanford.edu>
Content-Disposition: inline
In-Reply-To: <200309160435.h8G4ZkQM009953@elaine4.Stanford.EDU>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 15 September 2003 21:35:46 -0700, David Yu Chen wrote:
>=20
> [FILE:  2.6.0-test5/net/ipv4/igmp.c]
> [FUNC:  igmpv3_newpack]
> [LINES: 274-284]
> [VAR:   skb]
>  269:	struct sk_buff *skb;
>  270:	struct rtable *rt;
>  271:	struct iphdr *pip;
>  272:	struct igmpv3_report *pig;
>  273:
> START -->
>  274:	skb =3D alloc_skb(size + dev->hard_header_len + 15, GFP_ATOMIC);
>  275:	if (skb =3D=3D NULL)
>  276:		return 0;
>  277:
>  278:	{
>  279:		struct flowi fl =3D { .oif =3D dev->ifindex,
>  280:				    .nl_u =3D { .ip4_u =3D {
>  281:				    .daddr =3D IGMPV3_ALL_MCR } },
>  282:				    .proto =3D IPPROTO_IGMP };
>  283:		if (ip_route_output_key(&rt, &fl))
> END -->
>  284:			return 0;
>  285:	}
>  286:	if (rt->rt_src =3D=3D 0) {
>  287:		ip_rt_put(rt);
>  288:		return 0;
>  289:	}

Looks valid.  And since skb isn't really needed until after these
returns, moving four lines down a bit fixes the problem.

Davem, is this correct?

J=F6rn

--=20
Data dominates. If you've chosen the right data structures and organized
things well, the algorithms will almost always be self-evident. Data
structures, not algorithms, are central to programming.
-- Rob Pike

--- linux-2.6.0-test3/net/ipv4/igmp.c~igmp_memleak	2003-07-15 23:09:02.00=
0000000 +0200
+++ linux-2.6.0-test3/net/ipv4/igmp.c	2003-09-16 10:29:47.000000000 +0200
@@ -70,6 +70,8 @@
  *		Alexey Kuznetsov:	Accordance to igmp-v2-06 draft.
  *		David L Stevens:	IGMPv3 support, with help from
  *					Vinay Kulkarni
+ *		J=F6rn Engel:		Fix memleak in igmpv3_newpack, reported
+ *					by David Yu Chen (stanford checker)
  */
=20
=20
@@ -271,10 +273,6 @@
 	struct iphdr *pip;
 	struct igmpv3_report *pig;
=20
-	skb =3D alloc_skb(size + dev->hard_header_len + 15, GFP_ATOMIC);
-	if (skb =3D=3D NULL)
-		return 0;
-
 	{
 		struct flowi fl =3D { .oif =3D dev->ifindex,
 				    .nl_u =3D { .ip4_u =3D {
@@ -288,6 +286,10 @@
 		return 0;
 	}
=20
+	skb =3D alloc_skb(size + dev->hard_header_len + 15, GFP_ATOMIC);
+	if (skb =3D=3D NULL)
+		return 0;
+
 	skb->dst =3D &rt->u.dst;
 	skb->dev =3D dev;
=20
