From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sctp: implement SIOCINQ ioctl() (take 2)
Date: Fri, 03 Sep 2010 08:55:28 +0200
Message-ID: <1283496928.3699.1581.camel@edumazet-laptop>
References: <1283476464-14341-1-git-send-email-flameeyes@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Diego Elio =?ISO-8859-1?Q?Petten=F2?= <flameeyes@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48975 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752873Ab0ICG4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 02:56:44 -0400
Received: by wyg36 with SMTP id 36so164wyg.19
        for <netdev@vger.kernel.org>; Thu, 02 Sep 2010 23:56:41 -0700 (PDT)
In-Reply-To: <1283476464-14341-1-git-send-email-flameeyes@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 03 septembre 2010 =C3=A0 03:14 +0200, Diego Elio Petten=C3=B2=
 a
=C3=A9crit :
> From: Diego Elio 'Flameeyes' Petten=C3=B2 <flameeyes@gmail.com>
>=20
> This simple patch copies the current approach for SIOCINQ ioctl() fro=
m DCCP
> into SCTP so that the userland code working with SCTP can use a simil=
ar
> interface across different protocols to know how much space to alloca=
te for
> a buffer.
> ---
>  net/sctp/socket.c |   35 ++++++++++++++++++++++++++++++++++-
>  1 files changed, 34 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index ca44917..54c01e4 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -3595,7 +3595,40 @@ out:
>  /* The SCTP ioctl handler. */
>  SCTP_STATIC int sctp_ioctl(struct sock *sk, int cmd, unsigned long a=
rg)
>  {
> -	return -ENOIOCTLCMD;
> +	int rc =3D -ENOTCONN;
> +
> +	sctp_lock_sock(sk);
> +
> +	/*
> +	 * SEQPACKET-style sockets in LISTENING state are valid, for
> +	 * SCTP, so only discard TCP-style sockets in LISTENING state.
> +	 */
> +	if (sctp_style(sk, TCP) && sctp_sstate(sk, LISTENING))
> +		goto out;
> +
> +	switch (cmd) {
> +	case SIOCINQ: {
> +		struct sk_buff *skb;
> +		unsigned long amount =3D 0;

why use an 'unsigned long', since user pointer is a 'int *' ?

> +
> +		skb =3D skb_peek(&sk->sk_receive_queue);
> +		if (skb !=3D NULL) {
> +			/*
> +			 * We will only return the amount of this packet since
> +			 * that is all that will be read.
> +			 */
> +			amount =3D skb->len;
> +		}
> +		rc =3D put_user(amount, (int __user *)arg);
> +	}
> +		break;
> +	default:
> +		rc =3D -ENOIOCTLCMD;
> +		break;
> +	}
> +out:
> +	sctp_release_sock(sk);
> +	return rc;
>  }
> =20
>  /* This is the function which gets called during socket creation to


