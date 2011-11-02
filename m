From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fix NULL dereference in x25_recvmsg
Date: Wed, 02 Nov 2011 03:10:45 +0100
Message-ID: <1320199845.4728.23.camel@edumazet-laptop>
References: <20111102015315.GA6569@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Matthew Daley <mattjd@gmail.com>
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:62572 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753949Ab1KBCK4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 22:10:56 -0400
Received: by wyh15 with SMTP id 15so1017952wyh.19
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2011 19:10:55 -0700 (PDT)
In-Reply-To: <20111102015315.GA6569@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 01 novembre 2011 =C3=A0 21:53 -0400, Dave Jones a =C3=A9crit :
> commit cb101ed2 in 3.0 introduced a bug in x25_recvmsg()
> When passed bogus junk from userspace, x25->neighbour can be NULL,
> as shown in this oops..
>=20

Your patch seems fine but :

Are you sure this bug is not present on previous kernels ?

It seems we had prior to this commit :

skb_pull(skb, x25->neighbour->extended ?
	X25_EXT_MIN_LEN : X25_STD_MIN_LEN);



> Signed-off-by: Dave Jones <davej@redhat.com>
>=20
> diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
> index 5f03e4e..291b2e0 100644
> --- a/net/x25/af_x25.c
> +++ b/net/x25/af_x25.c
> @@ -1261,13 +1261,17 @@ static int x25_recvmsg(struct kiocb *iocb, st=
ruct socket *sock,
>  	struct x25_sock *x25 =3D x25_sk(sk);
>  	struct sockaddr_x25 *sx25 =3D (struct sockaddr_x25 *)msg->msg_name;
>  	size_t copied;
> -	int qbit, header_len =3D x25->neighbour->extended ?
> -		X25_EXT_MIN_LEN : X25_STD_MIN_LEN;
> -
> +	int qbit, header_len;
>  	struct sk_buff *skb;
>  	unsigned char *asmptr;
>  	int rc =3D -ENOTCONN;
> =20
> +	if (x25->neighbour =3D=3D NULL)
> +		return rc;
> +
> +	header_len =3D x25->neighbour->extended ?
> +		X25_EXT_MIN_LEN : X25_STD_MIN_LEN;
> +
>  	lock_sock(sk);
