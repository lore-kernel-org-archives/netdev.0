From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] fib: add rtnl locking in ip_fib_net_exit
Date: Wed, 30 Mar 2011 14:28:02 +0200
Message-ID: <1301488082.3283.43.camel@edumazet-laptop>
References: <AANLkTimv61zJhCjj-pgOHW6UYG4XSPLkjb8Z_yEMaFWo@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Daniel J Blueman <daniel.blueman@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTimv61zJhCjj-pgOHW6UYG4XSPLkjb8Z_yEMaFWo@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 30 mars 2011 =C3=A0 18:05 +0800, Daniel J Blueman a =C3=A9c=
rit :
> The loop in fib_table_flush [1] calls trie_firstleaf() which
> RCU-dereferences a structure outside a RCU read critical section,
> generating a warning [2].
>=20

Hi Daniel

> Since trie_leaf_remove() uses rcu_assign_pointer(), which should be
> outside the RCU read critical section, is there any better solution
> than spitting up the loop, with the first half covered by a RCU read
> critical section lock?
>=20

rcu_assign_pointer() can be done anywhere. This is done by a writer
(holding RTNL), while RCU read is used by readers.

> Daniel
>=20
> --- [1]
>=20
> int fib_table_flush(struct fib_table *tb)
> {
> 	struct trie *t =3D (struct trie *) tb->tb_data;
> 	struct leaf *l, *ll =3D NULL;
> 	int found =3D 0;
>=20
> 	for (l =3D trie_firstleaf(t); l; l =3D trie_nextleaf(l)) {
> 		found +=3D trie_flush_leaf(l);
>=20
> 		if (ll && hlist_empty(&ll->list))
> 			trie_leaf_remove(t, ll);
> 		ll =3D l;
> 	}
>=20
> --- [2]
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
> [ INFO: suspicious rcu_dereference_check() usage. ]
> ---------------------------------------------------
> net/ipv4/fib_trie.c:1777 invoked rcu_dereference_check() without prot=
ection!
>=20
> other info that might help us debug this:
>=20
> rcu_scheduler_active =3D 1, debug_locks =3D 1
> 3 locks held by kworker/u:5/51:
>  #0:  (netns){.+.+.+}, at: [<ffffffff8107b639>] process_one_work+0x14=
9/0x470
>  #1:  (net_cleanup_work){+.+.+.}, at: [<ffffffff8107b639>]
> process_one_work+0x149/0x470
>  #2:  (net_mutex){+.+.+.}, at: [<ffffffff8157b4b0>] cleanup_net+0x80/=
0x1b0
>=20
> stack backtrace:
> Pid: 51, comm: kworker/u:5 Tainted: G        W   2.6.39-rc1-350cd #1
> Call Trace:
>  [<ffffffff81094cd4>] lockdep_rcu_dereference+0xa4/0xc0
>  [<ffffffff8160aa23>] trie_firstleaf+0x93/0xa0
>  [<ffffffff8156feb8>] ? __sk_free+0x148/0x1e0
>  [<ffffffff8160d890>] fib_table_flush+0x20/0x1a0
>  [<ffffffff81606da5>] ip_fib_net_exit+0x95/0xd0
>  [<ffffffff81606e10>] fib_net_exit+0x30/0x40
>  [<ffffffff8157ab8e>] ops_exit_list+0x2e/0x70
>  [<ffffffff8157b52b>] cleanup_net+0xfb/0x1b0
>  [<ffffffff8107b69a>] process_one_work+0x1aa/0x470
>  [<ffffffff8107b639>] ? process_one_work+0x149/0x470
>  [<ffffffff8157b430>] ? net_free+0x30/0x30
>  [<ffffffff8107bd97>] worker_thread+0x157/0x3c0
>  [<ffffffff816ea484>] ? preempt_schedule+0x44/0x60
>  [<ffffffff8107bc40>] ? rescuer_thread+0x2e0/0x2e0
>  [<ffffffff81080236>] kthread+0xb6/0xc0
>  [<ffffffff81095f1d>] ? trace_hardirqs_on_caller+0x14d/0x190
>  [<ffffffff816ef094>] kernel_thread_helper+0x4/0x10
>  [<ffffffff810553f8>] ? finish_task_switch+0x78/0x110
>  [<ffffffff816ed7c4>] ? retint_restore_args+0xe/0xe
>  [<ffffffff81080180>] ? __init_kthread_worker+0x70/0x70
>  [<ffffffff816ef090>] ? gs_change+0xb/0xb

So fib_table_flush() is called (from ip_fib_net_exit) without RTNL bein=
g
held.

Here is patch to fix this.

Thanks

[PATCH] fib: add rtnl locking in ip_fib_net_exit

Daniel J Blueman reported a lockdep splat in trie_firstleaf(), caused b=
y
RTNL being not locked before a call to fib_table_flush()

Reported-by: Daniel J Blueman <daniel.blueman@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/fib_frontend.c |    2 ++
 1 files changed, 2 insertions(+)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index f116ce8..4510883 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -1068,6 +1068,7 @@ static void ip_fib_net_exit(struct net *net)
 	fib4_rules_exit(net);
 #endif
=20
+	rtnl_lock();
 	for (i =3D 0; i < FIB_TABLE_HASHSZ; i++) {
 		struct fib_table *tb;
 		struct hlist_head *head;
@@ -1080,6 +1081,7 @@ static void ip_fib_net_exit(struct net *net)
 			fib_free_table(tb);
 		}
 	}
+	rtnl_unlock();
 	kfree(net->ipv4.fib_table_hash);
 }
=20
