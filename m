From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] xmit_compl_seq: information to reclaim vmsplice
 buffers
Date: Fri, 24 Sep 2010 03:48:12 +0200
Message-ID: <1285292892.2380.16.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1009231426450.11579@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, sridharr@google.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:62037 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754757Ab0IXBsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 21:48:18 -0400
Received: by fxm3 with SMTP id 3so490641fxm.19
        for <netdev@vger.kernel.org>; Thu, 23 Sep 2010 18:48:17 -0700 (PDT)
In-Reply-To: <alpine.DEB.1.00.1009231426450.11579@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 23 septembre 2010 =C3=A0 14:35 -0700, Tom Herbert a =C3=A9crit=
 :

> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 3e8a4db..3d8d33f 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -1768,6 +1768,12 @@ skip_copy:
> =20
>  	TCP_CHECK_TIMER(sk);
>  	release_sock(sk);
> +
> +	/* Copy the first unacked seq into the receive msg control part. */
> +	if (sock_flag(sk, SOCK_XMIT_COMPL_SEQ))
> +		put_cmsg(msg, SOL_SOCKET, SCM_XMIT_COMPL_SEQ,
> +		    sizeof(tp->snd_una), &tp->snd_una);
> +
>  	return copied;
> =20
>  out:

Tom,

I took the time to suggest : copy tp->snd_una before release_sock().

Why do you try to avoid this copy and introduce a bug ?

Hint : put_cmsg() (and copy_to_user()) makes no guarantee the copy is
atomic.=20

It can be implemented by a 4 bytes copy, faut during this copy or being
interrupted, and application might get a garbled value, if tcp stack
modifies tp->snd_una during the copy.

If you want to optimize this (because release_sock() can process the
socket backlog, and update snd_una), please use :


	/* Copy the first unacked seq into the receive msg control part.
	 * As put_cmsg() might sleep, we must copy snd_una in a private var.
	 * Integer reads are atomic on all arches, so this copy can be
	 * performed while socket is unlocked.
	 */
	if (sock_flag(sk, SOCK_XMIT_COMPL_SEQ)) {
		u32 snd_una =3D tp->snd_una;

		put_cmsg(msg, SOL_SOCKET, SCM_XMIT_COMPL_SEQ,
			 sizeof(snd_una), &snd_una);
	}

Thanks !


