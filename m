From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH stable 3.10-3.16] tcp: Fix crash in TCP Fast Open
Date: Wed, 15 Apr 2015 19:00:32 +0100
Message-ID: <1429120832.3211.91.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-q7mPDk7yAqV2SuNr+Uup"
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>, 782515@bugs.debian.org
To: stable <stable@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:48762 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754959AbbDOSAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 14:00:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-q7mPDk7yAqV2SuNr+Uup
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Commit 355a901e6cf1 ("tcp: make connect() mem charging friendly")
changed tcp_send_syn_data() to perform an open-coded copy of the 'syn'
skb rather than using skb_copy_expand().

The open-coded copy does not cover the skb_shared_info::gso_segs
field, so in the new skb it is left set to 0.  When this commit was
backported into stable branches between 3.10.y and 3.16.7-ckty
inclusive, it triggered the BUG() in tcp_transmit_skb().

Since Linux 3.18 the GSO segment count is kept in the
tcp_skb_cb::tcp_gso_segs field and tcp_send_syn_data() does copy the
tcp_skb_cb structure to the new skb, so mainline and newer stable
branches are not affected.

Set skb_shared_info::gso_segs to the correct value of 1.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 net/ipv4/tcp_output.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index d5457e4..1ea0a07 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2992,6 +2992,7 @@ static int tcp_send_syn_data(struct sock *sk, struct =
sk_buff *syn)
 		goto fallback;
 	syn_data->ip_summed =3D CHECKSUM_PARTIAL;
 	memcpy(syn_data->cb, syn->cb, sizeof(syn->cb));
+	skb_shinfo(syn_data)->gso_segs =3D 1;
 	if (unlikely(memcpy_fromiovecend(skb_put(syn_data, space),
 					 fo->data->msg_iov, 0, space))) {
 		kfree_skb(syn_data);

--=20
Ben Hutchings
Editing code like this is akin to sticking plasters on the bleeding stump
of a severed limb. - me, 29 June 1999

--=-q7mPDk7yAqV2SuNr+Uup
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVS6nRee/yOyVhhEJAQrmpBAAw6E5TtwLAmvnM9iAJE/oMUlj9CArXBwr
4l0uJNivyhbyU/vVraHk85XRrQTjmKTM5LTcbWCS3WaZsyAK8Ek3MHvV7azGh3lg
TptR0mOVEAzOfuJkDdoH3zwBgQoVTTrtBF6ejTmd2Hf5E2501rGPz3Gkb+DfyFB1
p7jSK0sG3DzyfnZtTaV47AnEXmu+Zn8b+NDUeUsmFrNX+YXmdtyltWFvopxxqrlO
t3wYCGvkMcv9cOw90SCmf2V7wqeDAsSwbI3KWPhVyWia8ldPUfhL7nnwTSYDZ2U5
8UabZK9cTUJ2GHaAPfGKiRmVfmx4E84GRBQDqZ5ycxlYQXIe+qzeowyIaKbk6g10
LwzvvG6IZK0koAFkgF9lQCXD/rij8ePmTCYyqMoIhEiPUid82F7DSWsaJ84Feo/p
jUk9QSYa3aBa4EIs8+7sk3gaOrGCdWsr9+h/sVBZP7RtsfB8pyYAqcLRohcKGtmw
Yitvf9XejACO6rQ0QFj997pV6ZgZL8kcv1e8dOY5TYWc6RKXAh2MeCDagx6AQnkG
ihynoyfT67cQZDL2oFEXP+3EgeH1ANFi5iuxOmOTpTpH7hcWeaseFzP9R17NqXD+
bTEfTwW8GCJIuo4IovjrLHZXnF7fclMSXyN/Cruvpfc0UHfzPgDibOT6nFOb/LOG
th6bsih2ZcA=
=7sfN
-----END PGP SIGNATURE-----

--=-q7mPDk7yAqV2SuNr+Uup--
