From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] Fix tcp splice length
Date: Tue, 27 Jan 2009 07:10:34 +0100
Message-ID: <497EA55A.2050905@cosmosbay.com>
References: <200901270512.n0R5CLXB019113@darkside.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Willy Tarreau <w@1wt.eu>
To: Dimitris Michailidis <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:49144 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753782AbZA0GLT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 01:11:19 -0500
In-Reply-To: <200901270512.n0R5CLXB019113@darkside.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CCed Willy Tarreau

Dimitris Michailidis a =E9crit :
> commit 6c242233648471868b44ea091d461f2db6a93f10
> Author: Dimitris Michailidis <dm@chelsio.com>
> Date:   Mon Jan 26 20:46:56 2009 -0800
>=20
>     Fix length tcp_splice_data_recv passes to skb_splice_bits.
>    =20
>     tcp_splice_data_recv has two lengths to consider: the len paramet=
er it
>     gets from tcp_read_sock, which specifies the amount of data in th=
e skb,
>     and rd_desc->count, which is the amount of data the splice caller=
 still
>     wants.  Currently it passes just the latter to skb_splice_bits, w=
hich then
>     splices min(rd_desc->count, skb->len - offset) bytes.
>    =20
>     Most of the time this is fine, except when the skb contains urgen=
t data.
>     In that case len goes only up to the urgent byte and is less than
>     skb->len - offset.  By ignoring len tcp_splice_data_recv may a) s=
plice
>     data tcp_read_sock told it not to, b) return to tcp_read_sock a v=
alue > len.
>    =20
>     Now, tcp_read_sock doesn't handle used > len and leaves the socke=
t in a
>     bad state (both sk_receive_queue and copied_seq are bad at that p=
oint)
>     resulting in duplicated data and corruption.
>    =20
>     Fix by passing min(rd_desc->count, len) to skb_splice_bits.
>    =20
>     Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
>=20
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 0cd71b8..76b148b 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -524,7 +524,8 @@ static int tcp_splice_data_recv(read_descriptor_t=
 *rd_desc, struct sk_buff *skb,
>  	struct tcp_splice_state *tss =3D rd_desc->arg.data;
>  	int ret;
> =20
> -	ret =3D skb_splice_bits(skb, offset, tss->pipe, rd_desc->count, tss=
->flags);
> +	ret =3D skb_splice_bits(skb, offset, tss->pipe, min(rd_desc->count,=
 len),
> +			      tss->flags);
>  	if (ret > 0)
>  		rd_desc->count -=3D ret;
>  	return ret;

Nice spot Dimitris !

Acked-by: Eric Dumazet <dada1@cosmosbay.com>

This fixes a bug present in previous linux versions (before commit=20
33966dd0e2f68f26943cd9ee93ec6abbc6547a8e tcp: splice as many packets
 as possible at once)
=20
It should be backported as well, changing tss->len by min(tss->len, len=
) ?



