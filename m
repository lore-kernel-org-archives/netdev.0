From: David Miller <davem@davemloft.net>
Subject: Re: Occasional oops with IPSec and IPv6.
Date: Fri, 18 Nov 2011 15:10:54 -0500 (EST)
Message-ID: <20111118.151054.669492198256098000.davem@davemloft.net>
References: <4EC6A38E.6060404@iki.fi>
	<20111118192639.GA10531@elliptictech.com>
	<4EC6BAD7.3010200@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nbowler@elliptictech.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39455 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754734Ab1KRULG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 15:11:06 -0500
In-Reply-To: <4EC6BAD7.3010200@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Fri, 18 Nov 2011 22:06:47 +0200

> I'm not too familiar with the relevant IPv6 code, but it seems to be
> mostly modelled after the IPv4 side. Looking at the back trace offset
> inside ipv6_fragment, I'd say it was taking the "fast path" for
> constructing the fragments. So first guess is that the headroom check
> for allowing fast path to happen is not right.
>=20
> Since the code seems to be treating separately hlen and struct frag_h=
dr,
> I'm wondering if the following patch would be in place?
>=20
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index 1c9bf8b..c35d9fc 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -675,7 +675,7 @@ int ip6_fragment(struct sk_buff *skb, int
> (*output)(struct sk_buff *))
>  			/* Correct geometry. */
>  			if (frag->len > mtu ||
>  			    ((frag->len & 7) && frag->next) ||
> -			    skb_headroom(frag) < hlen)
> +			    skb_headroom(frag) < hlen + sizeof(struct frag_hdr))
>  				goto slow_path_clean;
>=20
>  			/* Partially cloned skb? */
>=20
>=20
> Alternatively, we could just run the "slow path" unconditionally with
> the test load to see if it fixes the issue. At least that'd be pretty
> good test if it's a problem in the ipv6 fragmentation code or somethi=
ng
> else.

This reminds me of the following change from Steffen Klassert in net-ne=
xt:

commit 299b0767642a65f0c5446ab6d35e6df0daf43d33
Author: Steffen Klassert <steffen.klassert@secunet.com>
Date:   Tue Oct 11 01:43:33 2011 +0000

    ipv6: Fix IPsec slowpath fragmentation problem
   =20
    ip6_append_data() builds packets based on the mtu from dst_mtu(rt->=
dst.path).
    On IPsec the effective mtu is lower because we need to add the prot=
ocol
    headers and trailers later when we do the IPsec transformations. So=
 after
    the IPsec transformations the packet might be too big, which leads =
to a
    slowpath fragmentation then. This patch fixes this by building the =
packets
    based on the lower IPsec mtu from dst_mtu(&rt->dst) and adapts the =
exthdr
    handling to this.
   =20
    Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 835c04b..1e20b64 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1193,6 +1193,7 @@ int ip6_append_data(struct sock *sk, int getfrag(=
void *from, char *to,
 	struct sk_buff *skb;
 	unsigned int maxfraglen, fragheaderlen;
 	int exthdrlen;
+	int dst_exthdrlen;
 	int hh_len;
 	int mtu;
 	int copy;
@@ -1248,7 +1249,7 @@ int ip6_append_data(struct sock *sk, int getfrag(=
void *from, char *to,
 		np->cork.hop_limit =3D hlimit;
 		np->cork.tclass =3D tclass;
 		mtu =3D np->pmtudisc =3D=3D IPV6_PMTUDISC_PROBE ?
-		      rt->dst.dev->mtu : dst_mtu(rt->dst.path);
+		      rt->dst.dev->mtu : dst_mtu(&rt->dst);
 		if (np->frag_size < mtu) {
 			if (np->frag_size)
 				mtu =3D np->frag_size;
@@ -1259,16 +1260,17 @@ int ip6_append_data(struct sock *sk, int getfra=
g(void *from, char *to,
 		cork->length =3D 0;
 		sk->sk_sndmsg_page =3D NULL;
 		sk->sk_sndmsg_off =3D 0;
-		exthdrlen =3D rt->dst.header_len + (opt ? opt->opt_flen : 0) -
-			    rt->rt6i_nfheader_len;
+		exthdrlen =3D (opt ? opt->opt_flen : 0) - rt->rt6i_nfheader_len;
 		length +=3D exthdrlen;
 		transhdrlen +=3D exthdrlen;
+		dst_exthdrlen =3D rt->dst.header_len;
 	} else {
 		rt =3D (struct rt6_info *)cork->dst;
 		fl6 =3D &inet->cork.fl.u.ip6;
 		opt =3D np->cork.opt;
 		transhdrlen =3D 0;
 		exthdrlen =3D 0;
+		dst_exthdrlen =3D 0;
 		mtu =3D cork->fragsize;
 	}
=20
@@ -1368,6 +1370,8 @@ alloc_new_skb:
 			else
 				alloclen =3D datalen + fragheaderlen;
=20
+			alloclen +=3D dst_exthdrlen;
+
 			/*
 			 * The last fragment gets additional space at tail.
 			 * Note: we overallocate on fragments with MSG_MODE
@@ -1419,9 +1423,9 @@ alloc_new_skb:
 			/*
 			 *	Find where to start putting bytes
 			 */
-			data =3D skb_put(skb, fraglen);
-			skb_set_network_header(skb, exthdrlen);
-			data +=3D fragheaderlen;
+			data =3D skb_put(skb, fraglen + dst_exthdrlen);
+			skb_set_network_header(skb, exthdrlen + dst_exthdrlen);
+			data +=3D fragheaderlen + dst_exthdrlen;
 			skb->transport_header =3D (skb->network_header +
 						 fragheaderlen);
 			if (fraggap) {
@@ -1434,6 +1438,7 @@ alloc_new_skb:
 				pskb_trim_unique(skb_prev, maxfraglen);
 			}
 			copy =3D datalen - transhdrlen - fraggap;
+
 			if (copy < 0) {
 				err =3D -EINVAL;
 				kfree_skb(skb);
@@ -1448,6 +1453,7 @@ alloc_new_skb:
 			length -=3D datalen - fraggap;
 			transhdrlen =3D 0;
 			exthdrlen =3D 0;
+			dst_exthdrlen =3D 0;
 			csummode =3D CHECKSUM_NONE;
=20
 			/*
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 3486f62..6f7824e 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -542,8 +542,7 @@ static int rawv6_push_pending_frames(struct sock *s=
k, struct flowi6 *fl6,
 		goto out;
=20
 	offset =3D rp->offset;
-	total_len =3D inet_sk(sk)->cork.base.length - (skb_network_header(skb=
) -
-						     skb->data);
+	total_len =3D inet_sk(sk)->cork.base.length;
 	if (offset >=3D total_len - 1) {
 		err =3D -EINVAL;
 		ip6_flush_pending_frames(sk);
