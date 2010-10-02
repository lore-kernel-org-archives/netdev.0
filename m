From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2.6.35.7] net: Fix the condition passed to
 sk_wait_event()
Date: Sat, 02 Oct 2010 10:27:31 +0200
Message-ID: <1286008051.2582.846.camel@edumazet-laptop>
References: <667106.4951.qm@web53706.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
To: Nagendra Tomar <tomer_iisc@yahoo.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <667106.4951.qm@web53706.mail.re2.yahoo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le samedi 02 octobre 2010 =C3=A0 01:22 -0700, Nagendra Tomar a =C3=A9cr=
it :
> Resending ...
>=20
>=20
> The condition (3rd arg) passed to sk_wait_event() in sk_stream_wait_m=
emory() and sk_stream_wait_connect() are incorrect.
> The incorrect check in sk_stream_wait_memory() causes the following s=
oft lockup in tcp_sendmsg() when the global tcp memory pool has exhaust=
ed. The check in sk_stream_wait_connect() was found by code audit.
>   =20
>=20
> >>> snip <<<
>=20
> localhost kernel: BUG: soft lockup - CPU#3 stuck for 11s! [sshd:6429]
> localhost kernel: CPU 3:
> localhost kernel: RIP: 0010:[sk_stream_wait_memory+0xcd/0x200]  [sk_s=
tream_wait_memory+0xcd/0x200] sk_stream_wait_memory+0xcd/0x200
> localhost kernel: Call Trace:
> localhost kernel:  [sk_stream_wait_memory+0x1b1/0x200] sk_stream_wait=
_memory+0x1b1/0x200
> localhost kernel:  [<ffffffff802557c0>] autoremove_wake_function+0x0/=
0x40
> localhost kernel:  [ipv6:tcp_sendmsg+0x6e6/0xe90] tcp_sendmsg+0x6e6/0=
xce0
> localhost kernel:  [sock_aio_write+0x126/0x140] sock_aio_write+0x126/=
0x140
> localhost kernel:  [xfs:do_sync_write+0xf1/0x130] do_sync_write+0xf1/=
0x130
> localhost kernel:  [<ffffffff802557c0>] autoremove_wake_function+0x0/=
0x40
> localhost kernel:  [hrtimer_start+0xe3/0x170] hrtimer_start+0xe3/0x17=
0
> localhost kernel:  [vfs_write+0x185/0x190] vfs_write+0x185/0x190
> localhost kernel:  [sys_write+0x50/0x90] sys_write+0x50/0x90
> localhost kernel:  [system_call+0x7e/0x83] system_call+0x7e/0x83
>=20
> >>> snip <<<
>=20
> What is happening is, that the sk_wait_event() condition passed from
> sk_stream_wait_memory() evaluates to true for the case of tcp global =
memory
> exhaustion. This is because both sk_stream_memory_free() and vm_wait =
are true which causes sk_wait_event() to *not* call schedule_timeout().=
=20
> Hence sk_stream_wait_memory() returns immediately to the caller w/o s=
leeping.
> This causes the caller to again try allocation, which again fails and=
 again
> calls sk_stream_wait_memory(), and so on.
>=20
>=20

Hi Nagendra


> Signed-off-by: Nagendra Singh Tomar <tomer_iisc@yahoo.com>
> ---
> --- linux-2.6.35.7/net/core/stream.c.orig	2010-03-23 23:46:45.0000000=
00 +0530
> +++ linux-2.6.35.7/net/core/stream.c	2010-03-24 00:21:09.000000000 +0=
530
> @@ -73,9 +73,8 @@ int sk_stream_wait_connect(struct sock *
>  		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
>  		sk->sk_write_pending++;
>  		done =3D sk_wait_event(sk, timeo_p,
> -				     !sk->sk_err &&
> -				     !((1 << sk->sk_state) &
> -				       ~(TCPF_ESTABLISHED | TCPF_CLOSE_WAIT)));
> +				     ((1 << sk->sk_state) &
> +				       (TCPF_ESTABLISHED | TCPF_CLOSE_WAIT)));

Just wondering why you remove the test on sk->err ?

We want to break the loop If sk->sk_err is set, or state is ESTABLISHED
or CLOSE_WAIT.

>  		finish_wait(sk_sleep(sk), &wait);
>  		sk->sk_write_pending--;
>  	} while (!done);
> @@ -144,10 +143,9 @@ int sk_stream_wait_memory(struct sock *s
> =20
>  		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
>  		sk->sk_write_pending++;
> -		sk_wait_event(sk, &current_timeo, !sk->sk_err &&
> -						  !(sk->sk_shutdown & SEND_SHUTDOWN) &&
> -						  sk_stream_memory_free(sk) &&
> -						  vm_wait);
> +		sk_wait_event(sk, &current_timeo, sk->sk_err ||
> +						  (sk->sk_shutdown & SEND_SHUTDOWN) ||
> +						  (sk_stream_memory_free(sk) && !vm_wait));
>  		sk->sk_write_pending--;
> =20
>  		if (vm_wait) {
>=20
>=20
>=20

Thanks !
