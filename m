From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_state locking regression...
Date: Wed, 3 Sep 2008 15:23:30 +1000
Message-ID: <20080903052329.GA8134@gondor.apana.org.au>
References: <E1KakUR-0001xp-00@gondolin.me.apana.org.au> <48BE1B95.8000508@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37577 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751860AbYICFXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 01:23:36 -0400
Content-Disposition: inline
In-Reply-To: <48BE1B95.8000508@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 03, 2008 at 08:07:33AM +0300, Timo Ter=E4s wrote:
>=20
> But then caller of xfrm_state_walk() can be still holding a
> reference to the entry and dumping of the whole chain fails,
> because the entry is no longer part of the chain when dumping
> continues later.
>=20
> The walking coding skips entries which are dead so the
> entry is only kept temporarily to make a full traversal of
> the list.

Ah I see your point now.

Actually another thing we should do is to postpone the unlinking
into the GC process.  This doesn't really need to be immediate.

And here is a patch to fix a couple of changes in user-behaviour.

ipsec: Restore larval states and socket policies in dump

The commit commit 4c563f7669c10a12354b72b518c2287ffc6ebfb3 ("[XFRM]:
Speed up xfrm_policy and xfrm_state walking") inadvertently removed
larval states and socket policies from netlink dumps.  This patch
restores them.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 841b32a..5138845 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1077,6 +1077,7 @@ static void __xfrm_policy_link(struct xfrm_policy=
 *pol, int dir)
 	struct hlist_head *chain =3D policy_hash_bysel(&pol->selector,
 						     pol->family, dir);
=20
+	list_add_tail(&pol->bytype, &xfrm_policy_bytype[pol->type]);
 	hlist_add_head(&pol->bydst, chain);
 	hlist_add_head(&pol->byidx, xfrm_policy_byidx+idx_hash(pol->index));
 	xfrm_policy_count[dir]++;
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 4c6914e..89551b6 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -856,6 +856,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address=
_t *saddr,
=20
 		if (km_query(x, tmpl, pol) =3D=3D 0) {
 			x->km.state =3D XFRM_STATE_ACQ;
+			list_add_tail(&x->all, &xfrm_state_all);
 			hlist_add_head(&x->bydst, xfrm_state_bydst+h);
 			h =3D xfrm_src_hash(daddr, saddr, family);
 			hlist_add_head(&x->bysrc, xfrm_state_bysrc+h);
@@ -1051,6 +1052,7 @@ static struct xfrm_state *__find_acq_core(unsigne=
d short family, u8 mode, u32 re
 		xfrm_state_hold(x);
 		x->timer.expires =3D jiffies + sysctl_xfrm_acq_expires*HZ;
 		add_timer(&x->timer);
+		list_add_tail(&x->all, &xfrm_state_all);
 		hlist_add_head(&x->bydst, xfrm_state_bydst+h);
 		h =3D xfrm_src_hash(daddr, saddr, family);
 		hlist_add_head(&x->bysrc, xfrm_state_bysrc+h);

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
