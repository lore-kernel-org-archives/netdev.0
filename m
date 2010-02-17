From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] xt_hashlimit: fix locking
Date: Wed, 17 Feb 2010 17:43:47 +0100
Message-ID: <1266425027.3075.66.camel@edumazet-laptop>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
	 <20100216145550.2796.32.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100216145550.2796.32.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 16 f=C3=A9vrier 2010 =C3=A0 15:55 +0100, Patrick McHardy a =C3=
=A9crit :
> commit 2eff25c18c3d332d3c4dd98f2ac9b7114e9771b0
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Wed Feb 3 13:24:54 2010 +0100
>=20
>     netfilter: xt_hashlimit: fix race condition and simplify locking
>    =20
>     As noticed by Shin Hong <hongshin@gmail.com>, there is a race bet=
ween
>     htable_find_get() and htable_put():
>    =20
>     htable_put():				htable_find_get():
>    =20
>     					spin_lock_bh(&hashlimit_lock);
>     					<search entry>
>     atomic_dec_and_test(&hinfo->use)
>     					atomic_inc(&hinfo->use)
>     					spin_unlock_bh(&hashlimit_lock)
>     					return hinfo;
>     spin_lock_bh(&hashlimit_lock);
>     hlist_del(&hinfo->node);
>     spin_unlock_bh(&hashlimit_lock);
>     htable_destroy(hinfo);
>    =20
>     The entire locking concept is overly complicated, tables are only
>     created/referenced and released in process context, so a single
>     mutex works just fine. Remove the hashinfo_spinlock and atomic
>     reference count and use the mutex to protect table lookups/creati=
on
>     and reference count changes.
>    =20
>     Signed-off-by: Patrick McHardy <kaber@trash.net>
>=20

Patrick, David

I believe this patch has a problem, since latest net-next-2.6 triggers =
:

[  240.682047] INFO: task iptables:4512 blocked for more than 120
seconds.
[  240.682125] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[  240.682198] iptables      D f7a69c48     0  4512   4436 0x00000000
[  240.682201]  f7a69c5c 00000086 00000002 f7a69c48 c3603304 00000000
c0379b0d 0000000e
[  240.682540]  00000138 f8c06504 fffbef49 d15abc2a 00000007 c0785000
c0788304 00000000
[  240.682861]  f81af0c0 c078d080 d157e120 00000007 f81aee40 c037a608
00000202 f9e38478
[  240.683191] Call Trace:
[  240.683247]  [<c0379b0d>] ? get_from_free_list+0x3d/0x50
[  240.683303]  [<c037a608>] ? ida_pre_get+0x18/0xe0
[  240.683359]  [<c05503ed>] __mutex_lock_slowpath+0xed/0x230
[  240.683426]  [<c0550540>] mutex_lock+0x10/0x20
[  240.683488]  [<c04dee7e>] hashlimit_mt_check+0x29e/0x380
[  240.683544]  [<c04de02c>] xt_check_match+0x9c/0x1b0
[  240.683599]  [<c05509a7>] ? __mutex_lock_interruptible_slowpath
+0x1a7/0x260
[  240.683657]  [<c05509a7>] ? __mutex_lock_interruptible_slowpath
+0x1a7/0x260
[  240.683716]  [<c05502fd>] ? mutex_unlock+0xd/0x10
[  240.683770]  [<c04ddb1f>] ? xt_find_match+0xdf/0x150
[  240.683831]  [<c0521994>] translate_table+0x384/0x760
[  240.683886]  [<c04dde02>] ? xt_alloc_table_info+0x52/0xc0
[  240.683942]  [<c0522bef>] do_ipt_set_ctl+0x16f/0x440
[  240.683998]  [<c04da2cb>] nf_sockopt+0x15b/0x1a0
[  240.684062]  [<c0551ca0>] ? _raw_spin_lock_bh+0x10/0x30
[  240.684118]  [<c04da369>] nf_setsockopt+0x29/0x30
[  240.684177]  [<c04eb96e>] ip_setsockopt+0x8e/0xa0
[  240.684233]  [<c02bd6ec>] ? page_add_new_anon_rmap+0x7c/0x90
[  240.684289]  [<c0504df4>] raw_setsockopt+0x44/0x80
[  240.684345]  [<c04aaf87>] sock_common_setsockopt+0x27/0x30
[  240.684411]  [<c04a9569>] sys_setsockopt+0x59/0xb0
[  240.684472]  [<c04aa90a>] sys_socketcall+0x12a/0x280
[  240.684528]  [<c0202c50>] sysenter_do_call+0x12/0x26


htable_create() is called with hashlimit_mutex already hold

Maybe original race could be solved using atomic_inc_not_zero() instead
of atomic_inc() ?

Or following quick & dirty patch just cures the problem.

Thanks

[PATCH net-next-2.6] xt_hashlimit: fix locking

Commit 2eff25c18c3d332d3c4dd98f2ac9b7114e9771b0
(netfilter: xt_hashlimit: fix race condition and simplify locking)
added a mutex deadlock :
htable_create() is called with hashlimit_mutex already locked

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.=
c
index e47fb80..d952806 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -262,9 +262,7 @@ static int htable_create_v0(struct net *net, struct=
 xt_hashlimit_info *minfo, u_
 	hinfo->timer.expires =3D jiffies + msecs_to_jiffies(hinfo->cfg.gc_int=
erval);
 	add_timer(&hinfo->timer);
=20
-	mutex_lock(&hashlimit_mutex);
 	hlist_add_head(&hinfo->node, &hashlimit_net->htables);
-	mutex_unlock(&hashlimit_mutex);
=20
 	return 0;
 }
@@ -327,9 +325,7 @@ static int htable_create(struct net *net, struct xt=
_hashlimit_mtinfo1 *minfo,
 	hinfo->timer.expires =3D jiffies + msecs_to_jiffies(hinfo->cfg.gc_int=
erval);
 	add_timer(&hinfo->timer);
=20
-	mutex_lock(&hashlimit_mutex);
 	hlist_add_head(&hinfo->node, &hashlimit_net->htables);
-	mutex_unlock(&hashlimit_mutex);
=20
 	return 0;
 }


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
