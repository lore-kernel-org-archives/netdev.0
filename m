From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Fix race in tcp_poll
Date: Mon, 20 Sep 2010 23:54:06 +0200
Message-ID: <1285019646.2323.267.camel@edumazet-laptop>
References: <20100920185719.GA13355@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Tom Marshall <tdm.code@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33842 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932123Ab0ITVyl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 17:54:41 -0400
Received: by wyf22 with SMTP id 22so4807378wyf.19
        for <netdev@vger.kernel.org>; Mon, 20 Sep 2010 14:54:40 -0700 (PDT)
In-Reply-To: <20100920185719.GA13355@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 20 septembre 2010 =C3=A0 12:18 -0700, Tom Marshall a =C3=A9cri=
t :
> If a RST comes in immediately after checking sk->sk_err, tcp_poll wil=
l
> return POLLIN but not POLLOUT.  Fix this by checking sk->sk_err at th=
e end
> of tcp_poll.  Additionally, ensure the correct order of operations on=
 SMP
> machines with memory barriers.
>=20
> Signed-off-by: Tom Marshall <tdm.code@gmail.com>
>=20
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 3fb1428..95d75d4 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -386,8 +386,6 @@ unsigned int tcp_poll(struct file *file, struct s=
ocket *sock, poll_table *wait)
>  	 */
> =20
>  	mask =3D 0;
> -	if (sk->sk_err)
> -		mask =3D POLLERR;
> =20
>  	/*
>  	 * POLLHUP is certainly not done right. But poll() doesn't
> @@ -457,6 +455,11 @@ unsigned int tcp_poll(struct file *file, struct =
socket *sock, poll_table *wait)
>  		if (tp->urg_data & TCP_URG_VALID)
>  			mask |=3D POLLPRI;
>  	}
> +	/* This barrier is coupled with smp_wmb() in tcp_reset() */
> +	smp_rmb();
> +	if (sk->sk_err)
> +		mask |=3D POLLERR;
> +
>  	return mask;
>  }
>  EXPORT_SYMBOL(tcp_poll);
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index e663b78..149e79a 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -4048,6 +4048,8 @@ static void tcp_reset(struct sock *sk)
>  	default:
>  		sk->sk_err =3D ECONNRESET;
>  	}
> +	/* This barrier is coupled with smp_rmb() in tcp_poll() */
> +	smp_wmb();
> =20
>  	if (!sock_flag(sk, SOCK_DEAD))
>  		sk->sk_error_report(sk);
>=20

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Maybe this is the last time we can avoid taking socket lock in
tcp_poll() ;)



