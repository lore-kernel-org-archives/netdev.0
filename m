From: Yury Polyanskiy <ypolyans@Princeton.EDU>
Subject: [IPSEC] xfrm_state locking problem in xfrm_input.c
Date: Mon, 11 May 2009 18:47:39 -0400
Message-ID: <20090511184739.6e497f29@penta.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/FUMSZhZtftNepJWcmdPo9Ok"; protocol="application/pgp-signature"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postoffice05.Princeton.EDU ([128.112.133.189]:61536 "EHLO
	Princeton.EDU" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757392AbZEKWts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2009 18:49:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/FUMSZhZtftNepJWcmdPo9Ok
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

xfrm_input() code uses spin_lock() where it must be using
spin_lock_bh() instead. The corresponding code in xfrm_output.c
correctly uses spin_lock_bh().=20

Note that if the locally generated packet is sent to a local ip,
dev_queue_xmit() calls loopback_xmit() and the xfrm_input() will be
called with softirqs enabled.

This might lead to a deadlock since x->lock is acquired in
xfrm_timer_handler().

Signed-off-by: Yury Polyanskiy <polyanskiy@gmail.com>
---
 net/xfrm/xfrm_input.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index b4a1317..4494918 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -161,7 +161,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32=
 spi, int encap_type)
=20
 		skb->sp->xvec[skb->sp->len++] =3D x;
=20
-		spin_lock(&x->lock);
+		spin_lock_bh(&x->lock);
 		if (unlikely(x->km.state !=3D XFRM_STATE_VALID)) {
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMINSTATEINVALID);
 			goto drop_unlock;
@@ -182,7 +182,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32=
 spi, int encap_type)
 			goto drop_unlock;
 		}
=20
-		spin_unlock(&x->lock);
+		spin_unlock_bh(&x->lock);
=20
 		XFRM_SKB_CB(skb)->seq.input =3D seq;
=20
@@ -192,7 +192,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32=
 spi, int encap_type)
 			return 0;
=20
 resume:
-		spin_lock(&x->lock);
+		spin_lock_bh(&x->lock);
 		if (nexthdr <=3D 0) {
 			if (nexthdr =3D=3D -EBADMSG) {
 				xfrm_audit_state_icvfail(x, skb,
@@ -212,7 +212,7 @@ resume:
 		x->curlft.bytes +=3D skb->len;
 		x->curlft.packets++;
=20
-		spin_unlock(&x->lock);
+		spin_unlock_bh(&x->lock);
=20
 		XFRM_MODE_SKB_CB(skb)->protocol =3D nexthdr;
=20
@@ -260,7 +260,7 @@ resume:
 	}
=20
 drop_unlock:
-	spin_unlock(&x->lock);
+	spin_unlock_bh(&x->lock);
 drop:
 	kfree_skb(skb);
 	return 0;
--=20
1.6.2.4




--Sig_/FUMSZhZtftNepJWcmdPo9Ok
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkoIqwsACgkQemuRe3zuqOQNPQCglPViWhG3djm0NJz/4iLTjFOx
d0EAmwWXobXuzkHZOBnhR7ug64TodT8f
=Cq0A
-----END PGP SIGNATURE-----

--Sig_/FUMSZhZtftNepJWcmdPo9Ok--
