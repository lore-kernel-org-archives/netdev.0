From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: skb_segment() questions
Date: Sun, 29 Mar 2009 10:07:01 +0800
Message-ID: <20090329020701.GA9983@gondor.apana.org.au>
References: <f0ed9b110903041912v6fba381fm4da792d49b1cbb91@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: James Huang <jamesclhuang@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:48977 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756831AbZC2CHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Mar 2009 22:07:14 -0400
Content-Disposition: inline
In-Reply-To: <f0ed9b110903041912v6fba381fm4da792d49b1cbb91@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 04, 2009 at 07:12:40PM -0800, James Huang wrote:
>
> (2) What is the purpose of the this check?
>=20
> `    if (pos >=3D offset + len)
>         continue;
>=20
>      If the payload in the head buffer of skb has at least mss bytes,=
 this
> check will succeed and no payload in skb=E2=80=99s head buffer will b=
e copy into
> nskb
> through a call to skb_copy_from_linear_data_offset(). Something seems=
 to be
> wrong here.

Indeed.  This breaks linear packets, which unfortunately older
versions of tun likes to construct.

gso: Fix support for linear packets

When GRO/frag_list support was added to GSO, I made an error
which broke the support for segmenting linear GSO packets (GSO
packets are normally non-linear in the payload).

These days most of these packets are constructed by the tun
driver, which prefers to allocate linear memory if possible.
This is fixed in the latest kernel, but for 2.6.29 and earlier
it is still the norm.

Therefore this bug causes failures with GSO when used with tun
in 2.6.29.

Reported-by: James Huang <jamesclhuang@gmail.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 6acbf9e..ce6356c 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2579,7 +2579,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, =
int features)
 					  skb_network_header_len(skb));
 		skb_copy_from_linear_data(skb, nskb->data, doffset);
=20
-		if (pos >=3D offset + len)
+		if (fskb !=3D skb_shinfo(skb)->frag_list)
 			continue;
=20
 		if (!sg) {

Thanks,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
