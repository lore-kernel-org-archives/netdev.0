From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net] ipv6: xfrm: Handle errors reported by
 xfrm6_find_1stfragopt()
Date: Wed, 31 May 2017 13:15:41 +0100
Message-ID: <20170531121541.GA16923@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="dDRMvlgZJXvWKvBx"
Cc: netdev <netdev@vger.kernel.org>
To: Craig Gallek <kraig@google.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53988 "EHLO
        shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751025AbdEaMPu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 08:15:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--dDRMvlgZJXvWKvBx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

xfrm6_find_1stfragopt() may now return an error code and we must
not treat it as a length.

Fixes: 2423496af35d ("ipv6: Prevent overrun when parsing v6 header options")
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
Commits 2423496af35d "ipv6: Prevent overrun when parsing v6 header
options" and 7dd7eb9513bd "ipv6: Check ip6_find_1stfragopt() return
value properly." changed ip6_find_1stfragopt() to return negative
error codes and changed some of its callers to handle this.

However, there is also xfrm6_find_1stfragopt() which is a wrapper for
ip6_find_1stfragopt() and is called indirectly by xfrm6_ro_output()
and xfrm6_transport_output().  Neither of them check for errors.

This is totally untested.  I think xfrm_type::hdr_offset deserves a
comment about its semantics, but I don't understand it well enogugh to
write that.

Ben.

 net/ipv6/xfrm6_mode_ro.c        | 2 ++
 net/ipv6/xfrm6_mode_transport.c | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/net/ipv6/xfrm6_mode_ro.c b/net/ipv6/xfrm6_mode_ro.c
index 0e015906f9ca..07d36573f50b 100644
--- a/net/ipv6/xfrm6_mode_ro.c
+++ b/net/ipv6/xfrm6_mode_ro.c
@@ -47,6 +47,8 @@ static int xfrm6_ro_output(struct xfrm_state *x, struct s=
k_buff *skb)
 	iph =3D ipv6_hdr(skb);
=20
 	hdr_len =3D x->type->hdr_offset(x, skb, &prevhdr);
+	if (hdr_len < 0)
+		return hdr_len;
 	skb_set_mac_header(skb, (prevhdr - x->props.header_len) - skb->data);
 	skb_set_network_header(skb, -x->props.header_len);
 	skb->transport_header =3D skb->network_header + hdr_len;
diff --git a/net/ipv6/xfrm6_mode_transport.c b/net/ipv6/xfrm6_mode_transpor=
t.c
index 7a92c0f31912..9ad07a91708e 100644
--- a/net/ipv6/xfrm6_mode_transport.c
+++ b/net/ipv6/xfrm6_mode_transport.c
@@ -30,6 +30,8 @@ static int xfrm6_transport_output(struct xfrm_state *x, s=
truct sk_buff *skb)
 	skb_set_inner_transport_header(skb, skb_transport_offset(skb));
=20
 	hdr_len =3D x->type->hdr_offset(x, skb, &prevhdr);
+	if (hdr_len < 0)
+		return hdr_len;
 	skb_set_mac_header(skb, (prevhdr - x->props.header_len) - skb->data);
 	skb_set_network_header(skb, -x->props.header_len);
 	skb->transport_header =3D skb->network_header + hdr_len;

--dDRMvlgZJXvWKvBx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUBWS6z7ee/yOyVhhEJAQrNYg//cfAY2BjgHX9PwTNfxiDbse3MMMX1x0ae
0307YaQMA63th1gQLRhBSNbktAuIq5gzKg2f88Oxtm+L8FDDpqb7aNg+3G/GwoxG
j/jGfogkUu4me3UjbxJkR58fIm06957Gk/xk9RwfZW9BRDu153HpNePaw2jsy3Lf
mgKCahuutcEVlqe9/GZQZ2N8/QnkNMCz65GzRIGgluX+oeQG/c5B1bSDOtSi1rzX
3j1lONFMckDhXZ+Nij1vL9eQnJPYoTvqxyuBFOb0TCCPRxW50JEVj4JI2dEmW+Cw
IoeVbZuyh46zKg6Tvu6dOZq3dOR+udU/eror/cd+Kuyf6NxhsNk68oYpGNpEMPL2
KrIXfuWRg7LA3hLVDS3B1uKAfEm+9T+zNGW8s0CkttWEPzpikbrRhs9ZRKQZJSX1
kDr6K9KeVAu3shBlkgzWrdlMxWkgq+1F4rhezw2ElFRMv9afLwhTKjPNtiO1pyme
2zwpEcBN9i1iwpdUPopXIszZ1+5cDMFasmfNMyEjCrZ40u0vpyoLcy+rIZtB2MFz
HCpXp1bbq7EvwziuO070ExLqrQZbh+sUiQUIVqBRl6tTuoENIqYKnHyzIOcwoyRl
EuX/UySs7h8F6nmnQFccd7TSSgRuKk+rDVKF/2lvkCTDo+UA9OISMhmyTdUOV4gC
2lPdGFPGuPA=
=0VjV
-----END PGP SIGNATURE-----

--dDRMvlgZJXvWKvBx--
