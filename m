From: Mark Brown <broonie@kernel.org>
Subject: linux-next: manual merge of the net-next tree with Linus' tree
Date: Mon, 30 Oct 2017 17:24:13 +0000
Message-ID: <20171030172413.nju5ew5lmt462f6p@sirena.co.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="cmqoriyudf3crchq"
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Yousuk Seung <ysseung@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from heliosphere.sirena.org.uk ([172.104.155.198]:46914 "EHLO
        heliosphere.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932434AbdJ3RYV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 13:24:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--cmqoriyudf3crchq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/ipv4/tcp_output.c

between commit:

  5889e2c0e441d8 ("tcp: call tcp_rate_skb_sent() when retransmit with unali=
gned skb->data")

=66rom Linus' tree and commit:

  e2080072ed2d98 ("tcp: new list for sent but unacked skbs for RACK recover=
y")

=66rom the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

diff --cc net/ipv4/tcp_output.c
index ae60dd3faed0,aab6e7145013..000000000000
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@@ -2840,13 -2905,14 +2907,16 @@@ int __tcp_retransmit_skb(struct sock *s
  		     skb_headroom(skb) >=3D 0xFFFF)) {
  		struct sk_buff *nskb;
 =20
- 		nskb =3D __pskb_copy(skb, MAX_TCP_HEADER, GFP_ATOMIC);
- 		err =3D nskb ? tcp_transmit_skb(sk, nskb, 0, GFP_ATOMIC) :
- 			     -ENOBUFS;
+ 		tcp_skb_tsorted_save(skb) {
+ 			nskb =3D __pskb_copy(skb, MAX_TCP_HEADER, GFP_ATOMIC);
+ 			err =3D nskb ? tcp_transmit_skb(sk, nskb, 0, GFP_ATOMIC) :
+ 				     -ENOBUFS;
+ 		} tcp_skb_tsorted_restore(skb);
+=20
 -		if (!err)
 +		if (!err) {
- 			skb->skb_mstamp =3D tp->tcp_mstamp;
+ 			tcp_update_skb_after_send(tp, skb);
 +			tcp_rate_skb_sent(sk, skb);
 +		}
  	} else {
  		err =3D tcp_transmit_skb(sk, skb, 1, GFP_ATOMIC);
  	}

--cmqoriyudf3crchq
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCgAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAln3YDwACgkQJNaLcl1U
h9AEMAf9FcNVZiRfBckApcoIxSaiJqLooDvLvC2zVqE6j5jBi+/H9U4MvtfyhDMz
8AzId8RgVMy6ccW2/x2mJEkaEQwv//JUtN6vGBlFjr8tukg37ZpiMmbKjlhIKJQB
zpmwM0uNnZDPFP8xliH9nNv3DdwDG1dRkJB45mZ0TyB6Ew/C2qOyNt8Md/SjJlXK
dVbYFbMvT8KIJa5IgIQC1b/utOKGtx7lwbjsAcMCyPaOlXLHNVeQ7O9tccNPBO1E
q8xq57RYEBaapqsVb0HogiFqL2WdTi7uMZqpHQNpATLes6ohjM7u5A5PpmraT499
z1+m0Rg839/RLtBGQD9OJ3ujZ4Km7g==
=+3W1
-----END PGP SIGNATURE-----

--cmqoriyudf3crchq--
