From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] tcp: tcp_prequeue() can use keyed wakeups
Date: Wed, 13 May 2009 05:28:26 +0200
Message-ID: <4A0A3E5A.6040702@cosmosbay.com>
References: <4A031596.4020904@cosmosbay.com>	 <4A031867.9060806@cosmosbay.com> <1242178490.11389.20.camel@merlyn>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: John Dykstra <john.dykstra1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw2.cosmosbay.com ([86.64.20.130]:38598 "EHLO gw2.cosmosbay.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753266AbZEMD2d convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 23:28:33 -0400
In-Reply-To: <1242178490.11389.20.camel@merlyn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Dykstra a =E9crit :
> On Thu, 2009-05-07 at 19:20 +0200, Eric Dumazet wrote:
>> We can avoid waking up tasks not interested in receive notifications=
,
>> using wake_up_interruptible_poll() instead of wake_up_interruptible(=
)
>=20
> Is there any reason why we shouldn't do the same thing on the write
> side?

No special reason, apart that this event is not so frequent.

(For tcp, sock_wfree() doesnt call ->sk_write_space())

I wonder if sk_stream_write_space() is actually called at all, I never =
got it in profiles :)

I see it is called from setsockopt(SO_SNFBUF),
and from tcp_new_space() only if SOCK_NOSPACE was set.

To see a benefit of this patch, we would need two threads, one blocked =
in a recv(),
one blocked in a send() on same socket (or a poll/epoll user with same =
bi-directional trafic)

Acked-by: Eric Dumazet <dada1@cosmosbay.com>

>=20
> Compile-tested only.
>=20
>   --  John
>=20
> ---
> [PATCH net-next-2.6] tcp: Don't wake up reading threads on write spac=
e=20
>=20
> When TCP frees up write buffer space, avoid waking up tasks that have
> done a poll() or select() on the same socket specifying read-side
> events.
>=20
> This is an extension of a read-side patch by Eric Dumazet.
>=20
> Signed-off-by: John Dykstra <john.dykstra1@gmail.com>
> ---
>  net/core/stream.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/core/stream.c b/net/core/stream.c
> index 8727cea..a37debf 100644
> --- a/net/core/stream.c
> +++ b/net/core/stream.c
> @@ -33,7 +33,8 @@ void sk_stream_write_space(struct sock *sk)
>  		clear_bit(SOCK_NOSPACE, &sock->flags);
> =20
>  		if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
> -			wake_up_interruptible(sk->sk_sleep);
> +			wake_up_interruptible_poll(sk->sk_sleep, POLLOUT |
> +						POLLWRNORM | POLLWRBAND);
>  		if (sock->fasync_list && !(sk->sk_shutdown & SEND_SHUTDOWN))
>  			sock_wake_async(sock, SOCK_WAKE_SPACE, POLL_OUT);
>  	}


