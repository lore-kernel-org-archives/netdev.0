From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] Re: skb_segment() questions
Date: Wed, 1 Apr 2009 09:18:01 +0000
Message-ID: <20090401091801.GA5970@ff.dom.local>
References: <20090329020701.GA9983@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: James Huang <jamesclhuang@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.232]:61051 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751943AbZDAJSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 05:18:11 -0400
Received: by rv-out-0506.google.com with SMTP id f9so3526498rvb.1
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2009 02:18:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090329020701.GA9983@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29-03-2009 03:07, Herbert Xu wrote:
> On Wed, Mar 04, 2009 at 07:12:40PM -0800, James Huang wrote:
>> (2) What is the purpose of the this check?
>>
>> `    if (pos >=3D offset + len)
>>         continue;
>>
>>      If the payload in the head buffer of skb has at least mss bytes=
, this
>> check will succeed and no payload in skb=E2??s head buffer will be c=
opy into
>> nskb
>> through a call to skb_copy_from_linear_data_offset(). Something seem=
s to be
>> wrong here.
>=20
> Indeed.  This breaks linear packets, which unfortunately older
> versions of tun likes to construct.
>=20
> gso: Fix support for linear packets
>=20
> When GRO/frag_list support was added to GSO, I made an error
> which broke the support for segmenting linear GSO packets (GSO
> packets are normally non-linear in the payload).
>=20
> These days most of these packets are constructed by the tun
> driver, which prefers to allocate linear memory if possible.
> This is fixed in the latest kernel, but for 2.6.29 and earlier
> it is still the norm.
>=20
> Therefore this bug causes failures with GSO when used with tun
> in 2.6.29.
>=20
> Reported-by: James Huang <jamesclhuang@gmail.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>=20
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 6acbf9e..ce6356c 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -2579,7 +2579,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb=
, int features)
>  					  skb_network_header_len(skb));
>  		skb_copy_from_linear_data(skb, nskb->data, doffset);
> =20
> -		if (pos >=3D offset + len)
> +		if (fskb !=3D skb_shinfo(skb)->frag_list)
>  			continue;
> =20
>  		if (!sg) {
>=20

----------------------->
gso: Fix support for linear packets 2

The previous fix removed a check, which should be useful, only a bit
later, by skipping at least two similar checks and three useless
assignments in case a header is (still) copied.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/core/skbuff.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index ce6356c..2123a92 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2594,6 +2594,8 @@ struct sk_buff *skb_segment(struct sk_buff *skb, =
int features)
=20
 		skb_copy_from_linear_data_offset(skb, offset,
 						 skb_put(nskb, hsize), hsize);
+		if (pos >=3D offset + len)
+			continue;
=20
 		while (pos < offset + len && i < nfrags) {
 			*frag =3D skb_shinfo(skb)->frags[i];
