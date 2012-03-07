From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.3.0-rc6-next20120305 net/ipv4/tcp_ipv4.c:930 suspicious
 rcu_dereference_check() usage!
Date: Wed, 07 Mar 2012 06:45:43 -0800
Message-ID: <1331131543.2474.72.camel@edumazet-laptop>
References: <30475.1331126726@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <30475.1331126726@turing-police.cc.vt.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 07 mars 2012 =C3=A0 08:25 -0500, Valdis.Kletnieks@vt.edu a
=C3=A9crit :
> Seen in my dmesg.  Dell Latitude E6500.
>=20
> [  164.842511]
> [  164.842522] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> [  164.842528] [ INFO: suspicious RCU usage. ]
> [  164.842538] 3.3.0-rc6-next-20120305 #1 Tainted: G           O
> [  164.842544] -------------------------------
> [  164.842552] net/ipv4/tcp_ipv4.c:930 suspicious rcu_dereference_che=
ck() usage!
> [  164.842559]
> [  164.842560] other info that might help us debug this:
> [  164.842563]
> [  164.842570]
> [  164.842571] rcu_scheduler_active =3D 1, debug_locks =3D 1
> [  164.842579] 2 locks held by ksoftirqd/1/10:
> [  164.842586]  #0:  (&icsk->icsk_retransmit_timer){+.-...}, at: [<ff=
ffffff81039086>] run_timer_softirq+0x17f/0x3e7
> [  164.842620]  #1:  (slock-AF_INET){+.-...}, at: [<ffffffff814b75b3>=
] tcp_write_timer+0x1a/0x17b
> [  164.842649]
> [  164.842651] stack backtrace:
> [  164.842660] Pid: 10, comm: ksoftirqd/1 Tainted: G           O 3.3.=
0-rc6-next-20120305 #1
> [  164.842668] Call Trace:
> [  164.842685]  [<ffffffff8106e6a2>] lockdep_rcu_suspicious+0xec/0xf5
> [  164.842698]  [<ffffffff814b7f40>] tcp_md5_do_lookup+0x60/0xbe
> [  164.842710]  [<ffffffff814b7fc0>] tcp_v4_md5_lookup+0xe/0x10
> [  164.842725]  [<ffffffff814b2eb5>] tcp_established_options+0x32/0x1=
10
> [  164.842739]  [<ffffffff814b42d7>] tcp_current_mss+0x50/0x6f
> [  164.842753]  [<ffffffff814b5c50>] tcp_retransmit_skb+0xa9/0x510
> [  164.842766]  [<ffffffff814ab727>] ? tcp_set_ca_state+0x23/0x2f
> [  164.842779]  [<ffffffff814b73ee>] tcp_retransmit_timer+0x376/0x521
> [  164.842791]  [<ffffffff814b7638>] tcp_write_timer+0x9f/0x17b
> [  164.842804]  [<ffffffff8103915e>] run_timer_softirq+0x257/0x3e7
> [  164.842816]  [<ffffffff81039086>] ? run_timer_softirq+0x17f/0x3e7
> [  164.842828]  [<ffffffff814b7599>] ? tcp_retransmit_timer+0x521/0x5=
21
> [  164.842843]  [<ffffffff81032207>] __do_softirq+0x10a/0x25f
> [  164.842857]  [<ffffffff81032411>] run_ksoftirqd+0xb5/0x200
> [  164.842869]  [<ffffffff8103235c>] ? __do_softirq+0x25f/0x25f
> [  164.842884]  [<ffffffff810499bd>] kthread+0x86/0x8e
> [  164.842900]  [<ffffffff815e2434>] kernel_thread_helper+0x4/0x10
> [  164.842914]  [<ffffffff815db41d>] ? retint_restore_args+0xe/0xe
> [  164.842928]  [<ffffffff81049937>] ? flush_kthread_worker+0xcf/0xcf
> [  164.842941]  [<ffffffff815e2430>] ? gs_change+0xb/0xb
>=20

[PATCH net-next] tcp: md5: correct a RCU lockdep splat

commit a8afca0329 (tcp: md5: protects md5sig_info with RCU) added a
lockdep splat in tcp_md5_do_lookup() in case a timer fires a tcp
retransmit.

At this point, socket lock is owned by the sofirq handler, not the user=
,
so we should adjust a bit the lockdep condition, as we dont hold
rcu_read_lock().

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Reported-by: Valdis Kletnieks <valdis.kletnieks@vt.edu>
---
 net/ipv4/tcp_ipv4.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 94abee8..507924b 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -927,7 +927,8 @@ struct tcp_md5sig_key *tcp_md5_do_lookup(struct soc=
k *sk,
=20
 	/* caller either holds rcu_read_lock() or socket lock */
 	md5sig =3D rcu_dereference_check(tp->md5sig_info,
-				       sock_owned_by_user(sk));
+				       sock_owned_by_user(sk) ||
+				       lockdep_is_held(&sk->sk_lock.slock));
 	if (!md5sig)
 		return NULL;
 #if IS_ENABLED(CONFIG_IPV6)
