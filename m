From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] GRO: fix merging a paged skb after non-paged skbs
Date: Mon, 24 Jan 2011 19:44:53 +0100
Message-ID: <1295894693.2755.58.camel@edumazet-laptop>
References: <20110124184752.1d0947dd@delilah>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Michal Schmidt <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:35726 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752945Ab1AXSo6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 13:44:58 -0500
Received: by wwa36 with SMTP id 36so4618400wwa.1
        for <netdev@vger.kernel.org>; Mon, 24 Jan 2011 10:44:57 -0800 (PST)
In-Reply-To: <20110124184752.1d0947dd@delilah>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 24 janvier 2011 =C3=A0 18:47 +0100, Michal Schmidt a =C3=A9cri=
t :
> Suppose that several linear skbs of the same flow were received by GR=
O. They
> were thus merged into one skb with a frag_list. Then a new skb of the=
 same flow
> arrives, but it is a paged skb with data starting in its frags[].
>=20
> Before adding the skb to the frag_list skb_gro_receive() will of cour=
se adjust
> the skb to throw away the headers. It correctly modifies the page_off=
set and
> size of the frag, but it leaves incorrect information in the skb:
>  ->data_len is not decreased at all.
>  ->len is decreased only by headlen, as if no change were done to the=
 frag.
> Later in a receiving process this causes skb_copy_datagram_iovec() to=
 return
> -EFAULT and this is seen in userspace as the result of the recv() sys=
call.
>=20
> In practice the bug can be reproduced with the sfc driver. By default=
 the
> driver uses an adaptive scheme when it switches between using
> napi_gro_receive() (with skbs) and napi_gro_frags() (with pages). The=
 bug is
> reproduced when under rx load with enough successful GRO merging the =
driver
> decides to switch from the former to the latter.
>=20
> Manual control is also possible, so reproducing this is easy with net=
cat:
>  - on machine1 (with sfc): nc -l 12345 > /dev/null
>  - on machine2: nc machine1 12345 < /dev/zero
>  - on machine1:
>    echo 1 > /sys/module/sfc/parameters/rx_alloc_method  # use skbs
>    echo 2 > /sys/module/sfc/parameters/rx_alloc_method  # use pages
>  - See that nc has quit suddenly.
>=20
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> ---
>  net/core/skbuff.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index d31bb36..c231f5b 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -2746,7 +2746,7 @@ merge:
>  	if (offset > headlen) {
>  		skbinfo->frags[0].page_offset +=3D offset - headlen;
>  		skbinfo->frags[0].size -=3D offset - headlen;
> -		offset =3D headlen;
> +		skb->data_len -=3D offset - headlen;
>  	}
> =20
>  	__skb_pull(skb, offset);

Hi Michal

Hmm, I dont really understand how __skb_pull(skb, offset) can be ok if
offset > headlen

skb->data might reach tail/end ?

Maybe I am too confused, this code is a bit complex :(

Thanks !

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d31bb36..7cd1bc8 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2744,8 +2744,12 @@ int skb_gro_receive(struct sk_buff **head, struc=
t sk_buff *skb)
=20
 merge:
 	if (offset > headlen) {
-		skbinfo->frags[0].page_offset +=3D offset - headlen;
-		skbinfo->frags[0].size -=3D offset - headlen;
+		unsigned int eat =3D offset - headlen;
+
+		skbinfo->frags[0].page_offset +=3D eat;
+		skbinfo->frags[0].size -=3D eat;
+		skb->data_len -=3D eat;
+		skb->len -=3D eat;
 		offset =3D headlen;
 	}
=20


