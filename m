From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [held lock freed] Re: [GIT] Networking
Date: Mon, 21 Mar 2011 14:32:26 +0100
Message-ID: <1300714346.2884.284.camel@edumazet-laptop>
References: <20110320.195156.226769634.davem@davemloft.net>
	 <20110321125320.GA23490@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Thomas Gleixner <tglx@linutronix.de>,
	Arnd Bergmann <arnd@arndb.de>
To: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110321125320.GA23490@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 21 mars 2011 =C3=A0 13:53 +0100, Ingo Molnar a =C3=A9crit :
> Dave,
>=20
> lockdep caught this held-lock-freed incident in the networking code:
>=20
> [   21.121321] EXT3-fs (sda5): using internal journal
> [   21.127218] EXT3-fs (sda5): mounted filesystem with ordered data m=
ode
> [   22.034265] rc.sysinit used greatest stack depth: 5796 bytes left
> [   22.511213] IPv4 FIB: Using LC-trie version 0.409
> [   22.646483]=20
> [   22.646484] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D
> [   22.648398] [ BUG: held lock freed! ]
> [   22.648398] -------------------------
> [   22.648398] ifconfig/329 is freeing memory f5d01680-f5d018ff, with=
 a lock still held there!
> [   22.648398]  (sk_lock-AF_IPX){......}, at: [<c1c345b1>] ipx_releas=
e+0x21/0xf0
> [   22.648398] 1 lock held by ifconfig/329:
> [   22.648398]  #0:  (sk_lock-AF_IPX){......}, at: [<c1c345b1>] ipx_r=
elease+0x21/0xf0
> [   22.648398]=20
> [   22.648398] stack backtrace:
> [   22.648398] Pid: 329, comm: ifconfig Not tainted 2.6.38-tip+ #1093=
81
> [   22.648398] Call Trace:
> [   22.648398]  [<c1d3dd48>] ? printk+0x2d/0x2f
> [   22.648398]  [<c1067aab>] debug_check_no_locks_freed+0x10b/0x130
> [   22.648398]  [<c10eae01>] kmem_cache_free+0x61/0x120
> [   22.648398]  [<c1b1135c>] ? __sk_free+0xbc/0x150
> [   22.648398]  [<c1b1135c>] __sk_free+0xbc/0x150
> [   22.648398]  [<c1b17964>] ? skb_dequeue+0x44/0x60
> [   22.648398]  [<c1b11ee5>] sk_free+0x25/0x30
> [   22.648398]  [<c1c34647>] ipx_release+0xb7/0xf0
> [   22.648398]  [<c1b0e386>] sock_release+0x16/0x60
> [   22.648398]  [<c1b0e3e5>] sock_close+0x15/0x30
> [   22.648398]  [<c1b0e3d0>] ? sock_close+0x0/0x30
> [   22.648398]  [<c10f33cc>] fput+0xcc/0x260
> [   22.648398]  [<c10f112a>] filp_close+0x4a/0x80
> [   22.648398]  [<c103a7c6>] put_files_struct+0x146/0x170
> [   22.648398]  [<c103a6b0>] ? put_files_struct+0x30/0x170
> [   22.648398]  [<c103a87c>] exit_files+0x3c/0x50
> [   22.648398]  [<c103abac>] do_exit+0x10c/0x770
> [   22.648398]  [<c10f1d50>] ? vfs_write+0xf0/0x160
> [   22.648398]  [<c10f1b80>] ? do_sync_write+0x0/0xe0
> [   22.648398]  [<c103b284>] do_group_exit+0x34/0x90
> [   22.648398]  [<c103b2f8>] sys_exit_group+0x18/0x20
> [   22.648398]  [<c1d52597>] sysenter_do_call+0x12/0x32
>=20
> Not sure whether it's VFS or networking related - my guess it's the l=
atter.
> The bug was introduced between 016aa2ed1cc9 and a44f99c7efdb.
>=20
> The box has booted up fine after the lockdep report. Config attached.

Hi Ingo, thanks for this report.

Here is a probable fix.

[PATCH] ipx: fix ipx_release()

Commit b0d0d915d1d1a0 (remove the BKL) added a regression, because
sock_put() can free memory while we are going to use it later.

=46ix is to delay sock_put() _after_ release_sock().

Reported-by: Ingo Molnar <mingo@elte.hu>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Arnd Bergmann <arnd@arndb.de>
---
 net/ipx/af_ipx.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index 2731b51..9680226 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -148,7 +148,6 @@ static void ipx_destroy_socket(struct sock *sk)
 	ipx_remove_socket(sk);
 	skb_queue_purge(&sk->sk_receive_queue);
 	sk_refcnt_debug_dec(sk);
-	sock_put(sk);
 }
=20
 /*
@@ -1404,6 +1403,7 @@ static int ipx_release(struct socket *sock)
 	sk_refcnt_debug_release(sk);
 	ipx_destroy_socket(sk);
 	release_sock(sk);
+	sock_put(sk);
 out:
 	return 0;
 }
