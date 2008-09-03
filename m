From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_state locking regression...
Date: Wed, 3 Sep 2008 15:50:41 +1000
Message-ID: <20080903055041.GA8547@gondor.apana.org.au>
References: <E1KakUR-0001xp-00@gondolin.me.apana.org.au> <48BE1B95.8000508@iki.fi> <20080903053935.GA8428@gondor.apana.org.au> <48BE245D.3060905@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36946 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752856AbYICFus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 01:50:48 -0400
Content-Disposition: inline
In-Reply-To: <48BE245D.3060905@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 03, 2008 at 08:45:01AM +0300, Timo Ter=E4s wrote:
>
> > ipsec: Move state dump list unlinking into GC
> >=20
> > This patch moves the unlinking of x->all (for dumping) into the
> > GC and changes the lock to xfrm_cfg_mutex.
>=20
> Shouldn't this also change the locking in all places where
> x->all is used?

You're right.  I'd forgotten about the larval states for some
reason, probably because I just added them to the list :)

So let's keep xfrm_state_lock and just move it.

ipsec: Move state dump list unlinking into GC

This patch moves the unlinking of x->all (for dumping) into the
GC so that we know for sure what locks we hold when we unlink the
entry.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 89551b6..0244325 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -380,6 +380,10 @@ static void xfrm_put_mode(struct xfrm_mode *mode)
=20
 static void xfrm_state_gc_destroy(struct xfrm_state *x)
 {
+	spin_lock_bh(&xfrm_state_lock);
+	list_del(&x->all);
+	spin_unlock_bh(&xfrm_state_lock);
+
 	del_timer_sync(&x->timer);
 	del_timer_sync(&x->rtimer);
 	kfree(x->aalg);
@@ -540,10 +544,6 @@ void __xfrm_state_destroy(struct xfrm_state *x)
 {
 	WARN_ON(x->km.state !=3D XFRM_STATE_DEAD);
=20
-	spin_lock_bh(&xfrm_state_lock);
-	list_del(&x->all);
-	spin_unlock_bh(&xfrm_state_lock);
-
 	spin_lock_bh(&xfrm_state_gc_lock);
 	hlist_add_head(&x->bydst, &xfrm_state_gc_list);
 	spin_unlock_bh(&xfrm_state_gc_lock);

Thanks,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
