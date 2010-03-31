From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] xfrm: increment genid before bumping state genids
Date: Wed, 31 Mar 2010 19:19:49 +0800
Message-ID: <20100331111949.GD12845@gondor.apana.org.au>
References: <1270030626-16687-1-git-send-email-timo.teras@iki.fi> <1270030626-16687-3-git-send-email-timo.teras@iki.fi> <20100331105023.GA12845@gondor.apana.org.au> <4BB32A11.1030708@iki.fi> <4BB32B6F.7060403@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:43886 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757158Ab0CaLTx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 07:19:53 -0400
Content-Disposition: inline
In-Reply-To: <4BB32B6F.7060403@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 31, 2010 at 02:01:03PM +0300, Timo Ter=E4s wrote:
>
> If any other xfrm_state_insert place needs to invalidate old
> states it needs an additional bumping call. So the bumping function
> is the right place to increment the genid.

Right.  In fact, this thing doesn't need to be incremented on every
insert.  How about this patch?

xfrm: Remove xfrm_state_genid

The xfrm state genid only needs to be matched against the copy
saved in xfrm_dst.  So we don't need a global genid at all.  In
fact, we don't even need to initialise it.

Based on observation by Timo Ter=E4s.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 17d5b96..71f8f33 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -37,7 +37,6 @@
 static DEFINE_SPINLOCK(xfrm_state_lock);
=20
 static unsigned int xfrm_state_hashmax __read_mostly =3D 1 * 1024 * 10=
24;
-static unsigned int xfrm_state_genid;
=20
 static struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned int fa=
mily);
 static void xfrm_state_put_afinfo(struct xfrm_state_afinfo *afinfo);
@@ -923,8 +922,6 @@ static void __xfrm_state_insert(struct xfrm_state *=
x)
 	struct net *net =3D xs_net(x);
 	unsigned int h;
=20
-	x->genid =3D ++xfrm_state_genid;
-
 	list_add(&x->km.all, &net->xfrm.state_all);
=20
 	h =3D xfrm_dst_hash(net, &x->id.daddr, &x->props.saddr,
@@ -970,7 +967,7 @@ static void __xfrm_state_bump_genids(struct xfrm_st=
ate *xnew)
 		    (mark & x->mark.m) =3D=3D x->mark.v &&
 		    !xfrm_addr_cmp(&x->id.daddr, &xnew->id.daddr, family) &&
 		    !xfrm_addr_cmp(&x->props.saddr, &xnew->props.saddr, family))
-			x->genid =3D xfrm_state_genid;
+			x->genid++;
 	}
 }
=20
Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
