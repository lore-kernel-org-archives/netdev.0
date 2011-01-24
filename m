From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] GRO: fix merging a paged skb after non-paged skbs
Date: Mon, 24 Jan 2011 23:22:25 +0100
Message-ID: <1295907745.2924.18.camel@edumazet-laptop>
References: <20110124184752.1d0947dd@delilah>
	 <1295894693.2755.58.camel@edumazet-laptop>
	 <20110124230848.577187e9@delilah>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Michal Schmidt <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:48128 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487Ab1AXWWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 17:22:30 -0500
Received: by wwa36 with SMTP id 36so4839841wwa.1
        for <netdev@vger.kernel.org>; Mon, 24 Jan 2011 14:22:29 -0800 (PST)
In-Reply-To: <20110124230848.577187e9@delilah>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 24 janvier 2011 =C3=A0 23:08 +0100, Michal Schmidt a =C3=A9cri=
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
> [v2: Modified by Eric Dumazet to avoid advancing skb->data past the e=
nd
>      and to use a temporary variable.]
>=20
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> ---
> Eric,
> I think skb->data is pretty much irrelevant at that point, because th=
e
> skb's headlen is going to become zero, but admittedly it seems cleane=
r
> this way.
> Thanks.
>=20
>  net/core/skbuff.c |    8 ++++++--
>  1 files changed, 6 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index d31bb36..7cd1bc8 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -2744,8 +2744,12 @@ int skb_gro_receive(struct sk_buff **head, str=
uct sk_buff *skb)
> =20
>  merge:
>  	if (offset > headlen) {
> -		skbinfo->frags[0].page_offset +=3D offset - headlen;
> -		skbinfo->frags[0].size -=3D offset - headlen;
> +		unsigned int eat =3D offset - headlen;
> +
> +		skbinfo->frags[0].page_offset +=3D eat;
> +		skbinfo->frags[0].size -=3D eat;
> +		skb->data_len -=3D eat;
> +		skb->len -=3D eat;
>  		offset =3D headlen;
>  	}
> =20

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks !


