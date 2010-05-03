From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: mmotm 2010-04-28 - RCU whinges
Date: Mon, 03 May 2010 16:58:46 +0200
Message-ID: <1272898726.2226.47.camel@edumazet-laptop>
References: <201004290021.o3T0L04Y028017@imap1.linux-foundation.org>
	 <5702.1272822394@localhost> <1272865137.2173.179.camel@edumazet-laptop>
	 <5933.1272897014@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Valdis.Kletnieks@vt.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5933.1272897014@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 03 mai 2010 =C3=A0 10:30 -0400, Valdis.Kletnieks@vt.edu a =C3=A9=
crit :

> [    9.128899] Netfilter messages via NETLINK v0.30.
> [    9.128919] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
> [    9.129108] CONFIG_NF_CT_ACCT is deprecated and will be removed so=
on. Please use
> [    9.129110] nf_conntrack.acct=3D1 kernel parameter, acct=3D1 nf_co=
nntrack module option or
> [    9.129113] sysctl net.netfilter.nf_conntrack_acct=3D1 to enable i=
t.
> [    9.129135] ctnetlink v0.93: registering with nfnetlink.
> [    9.129452] ip_tables: (C) 2000-2006 Netfilter Core Team
> [    9.129506]=20
> [    9.129507] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
> [    9.129683] [ INFO: suspicious rcu_dereference_check() usage. ]
> [    9.129777] ---------------------------------------------------
> [    9.129872] net/netfilter/nf_log.c:55 invoked rcu_dereference_chec=
k() without protection!
> [    9.129969]=20
> [    9.129969] other info that might help us debug this:
> [    9.129970]=20
> [    9.130232]=20
> [    9.130232] rcu_scheduler_active =3D 1, debug_locks =3D 0
> [    9.130407] 1 lock held by swapper/1:
> [    9.130525]  #0:  (nf_log_mutex){+.+...}, at: [<ffffffff81481154>]=
 nf_log_register+0x57/0x10f
> [    9.130955]=20
> [    9.130956] stack backtrace:
> [    9.131162] Pid: 1, comm: swapper Tainted: G        W   2.6.34-rc5=
-mmotm0428 #2
> [    9.131259] Call Trace:
> [    9.131370]  [<ffffffff81064832>] lockdep_rcu_dereference+0xaa/0xb=
2
> [    9.131466]  [<ffffffff814811db>] nf_log_register+0xde/0x10f
> [    9.131579]  [<ffffffff81b5ca28>] ? log_tg_init+0x0/0x29
> [    9.131689]  [<ffffffff81b5ca4d>] log_tg_init+0x25/0x29
> [    9.131800]  [<ffffffff810001ef>] do_one_initcall+0x59/0x14e
> [    9.131912]  [<ffffffff81b2e68a>] kernel_init+0x144/0x1ce
> [    9.132033]  [<ffffffff81003414>] kernel_thread_helper+0x4/0x10
> [    9.132146]  [<ffffffff81598a40>] ? restore_args+0x0/0x30
> [    9.132257]  [<ffffffff81b2e546>] ? kernel_init+0x0/0x1ce
> [    9.132370]  [<ffffffff81003410>] ? kernel_thread_helper+0x0/0x10
> [    9.132513] TCP bic registered
>=20

Thanks for the report !

[PATCH] net: nf_log RCU fixes

nf_log_register() and nf_log_unregister() use a mutex to have exclusive
access to nf_logers[]. Use appropriate rcu_dereference_protected()
lockdep annotation.

Reported-by: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index 015725a..7df37fd 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -52,7 +52,8 @@ int nf_log_register(u_int8_t pf, struct nf_logger *lo=
gger)
 	} else {
 		/* register at end of list to honor first register win */
 		list_add_tail(&logger->list[pf], &nf_loggers_l[pf]);
-		llog =3D rcu_dereference(nf_loggers[pf]);
+		llog =3D rcu_dereference_protected(nf_loggers[pf],
+						 lockdep_is_held(&nf_log_mutex));
 		if (llog =3D=3D NULL)
 			rcu_assign_pointer(nf_loggers[pf], logger);
 	}
@@ -70,7 +71,8 @@ void nf_log_unregister(struct nf_logger *logger)
=20
 	mutex_lock(&nf_log_mutex);
 	for (i =3D 0; i < ARRAY_SIZE(nf_loggers); i++) {
-		c_logger =3D rcu_dereference(nf_loggers[i]);
+		c_logger =3D rcu_dereference_protected(nf_loggers[i],
+						     lockdep_is_held(&nf_log_mutex));
 		if (c_logger =3D=3D logger)
 			rcu_assign_pointer(nf_loggers[i], NULL);
 		list_del(&logger->list[i]);
