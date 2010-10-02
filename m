From: Nagendra Tomar <tomer_iisc@yahoo.com>
Subject: [PATCH 2.6.35.7] net: Fix the condition passed to sk_wait_event()
Date: Fri, 1 Oct 2010 19:55:42 -0700 (PDT)
Message-ID: <563428.39597.qm@web53703.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web53703.mail.re2.yahoo.com ([206.190.37.24]:41912 "HELO
	web53703.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753002Ab0JBDCW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Oct 2010 23:02:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



The condition (3rd arg) passed to sk_wait_event() in sk_stream_wait_mem=
ory() and=20
sk_stream_wait_connect() are incorrect.
The incorrect check in sk_stream_wait_memory() causes the following sof=
t lockup=20
in tcp_sendmsg() when the global tcp memory pool has exhausted. The che=
ck in=20
sk_stream_wait_connect() was found by code audit.
=A0=A0=20
>>> snip <<<
localhost kernel: BUG: soft lockup - CPU#3 stuck for 11s! [sshd:6429]
localhost kernel: CPU 3:
localhost kernel:=20
localhost kernel: Call Trace:
localhost kernel:=A0 [sk_stream_wait_memory+0x1b1/0x200]=20
sk_stream_wait_memory+0x1b1/0x200
localhost kernel:=A0 [<ffffffff802557c0>] autoremove_wake_function+0x0/=
0x40
localhost kernel:=A0 [ipv6:tcp_sendmsg+0x6e6/0xe90] tcp_sendmsg+0x6e6/0=
xce0
localhost kernel:=A0 [sock_aio_write+0x126/0x140] sock_aio_write+0x126/=
0x140
localhost kernel:=A0 [xfs:do_sync_write+0xf1/0x130] do_sync_write+0xf1/=
0x130
localhost kernel:=A0 [<ffffffff802557c0>] autoremove_wake_function+0x0/=
0x40
localhost kernel:=A0 [hrtimer_start+0xe3/0x170] hrtimer_start+0xe3/0x17=
0
localhost kernel:=A0 [vfs_write+0x185/0x190] vfs_write+0x185/0x190
localhost kernel:=A0 [sys_write+0x50/0x90] sys_write+0x50/0x90
localhost kernel:=A0 [system_call+0x7e/0x83] system_call+0x7e/0x83
>>> snip <<<

What is happening is, that the sk_wait_event() condition passed from
sk_stream_wait_memory() evaluates to true for the case of tcp global me=
mory
exhaustion. This is because both sk_stream_memory_free() and vm_wait ar=
e true
which causes sk_wait_event() to *not* call schedule_timeout().=20
Hence sk_stream_wait_memory() returns immediately to the caller w/o sle=
eping.
This causes the caller to again try allocation, which again fails and a=
gain
calls sk_stream_wait_memory(), and so on.

Signed-off-by: Nagendra Singh Tomar <tomer_iisc@yahoo.com>
---
--- linux-2.6.35.7/net/core/stream.c.orig=A02010-03-23 23:46:45.0000000=
00 +0530
+++ linux-2.6.35.7/net/core/stream.c=A02010-03-24 00:21:09.000000000 +0=
530
@@ -73,9 +73,8 @@ int sk_stream_wait_connect(struct sock *
=A0=A0=A0prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
=A0=A0=A0sk->sk_write_pending++;
=A0=A0=A0done =3D sk_wait_event(sk, timeo_p,
-=A0=A0=A0=A0=A0=A0=A0=A0 !sk->sk_err &&
-=A0=A0=A0=A0=A0=A0=A0=A0 !((1 << sk->sk_state) &
-=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 ~(TCPF_ESTABLISHED | TCPF_CLOSE_WAIT)))=
;
+=A0=A0=A0=A0=A0=A0=A0=A0 ((1 << sk->sk_state) &
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 (TCPF_ESTABLISHED | TCPF_CLOSE_WAIT)));
=A0=A0=A0finish_wait(sk_sleep(sk), &wait);
=A0=A0=A0sk->sk_write_pending--;
=A0=A0} while (!done);
@@ -144,10 +143,9 @@ int sk_stream_wait_memory(struct sock *s
=A0
=A0=A0=A0set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
=A0=A0=A0sk->sk_write_pending++;
-=A0=A0sk_wait_event(sk, &current_timeo, !sk->sk_err &&
-=A0=A0=A0=A0=A0=A0=A0 !(sk->sk_shutdown & SEND_SHUTDOWN) &&
-=A0=A0=A0=A0=A0=A0=A0 sk_stream_memory_free(sk) &&
-=A0=A0=A0=A0=A0=A0=A0 vm_wait);
+=A0=A0sk_wait_event(sk, &current_timeo, sk->sk_err ||
+=A0=A0=A0=A0=A0=A0=A0 (sk->sk_shutdown & SEND_SHUTDOWN) ||
+=A0=A0=A0=A0=A0=A0=A0 (sk_stream_memory_free(sk) && !vm_wait));
=A0=A0=A0sk->sk_write_pending--;
=A0
=A0=A0=A0if (vm_wait) {



     =20
