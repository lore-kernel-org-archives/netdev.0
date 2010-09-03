From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH] sctp: implement SIOCINQ ioctl() (take 2)
Date: Fri, 03 Sep 2010 10:03:42 +0800
Message-ID: <4C80577E.7050005@cn.fujitsu.com>
References: <1283476464-14341-1-git-send-email-flameeyes@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: =?UTF-8?B?RGllZ28gRWxpbyBQZXR0ZW7Dsg==?= <flameeyes@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60965 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752348Ab0ICCFt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 22:05:49 -0400
In-Reply-To: <1283476464-14341-1-git-send-email-flameeyes@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46orward to linux-sctp maillist.


Diego Elio Petten=C3=B2 wrote, at 09/03/2010 09:14 AM:
> From: Diego Elio 'Flameeyes' Petten=C3=B2 <flameeyes@gmail.com>
>=20
> This simple patch copies the current approach for SIOCINQ ioctl() fro=
m DCCP
> into SCTP so that the userland code working with SCTP can use a simil=
ar
> interface across different protocols to know how much space to alloca=
te for
> a buffer.

lack of your singed-of-by.


--=20
Best Regards
-----
Shan Wei

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
