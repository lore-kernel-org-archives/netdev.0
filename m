From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] netfilter: xtables: fix reentrancy
Date: Thu, 17 Mar 2011 11:35:40 +0100
Message-ID: <1300358140.3133.117.camel@edumazet-laptop>
References: <1300302005.3202.23.camel@edumazet-laptop>
	 <20110316.131648.15245216.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, hawk@diku.dk
To: David Miller <davem@davemloft.net>,
	Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110316.131648.15245216.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 16 mars 2011 =C3=A0 13:16 -0700, David Miller a =C3=A9crit =
:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 16 Mar 2011 20:00:05 +0100
>=20
> > We currently use a percpu spinlock to 'protect' rule bytes/packets
> > counters, after various attempts to use RCU instead.
> >=20
> > Lately we added a seqlock so that get_counters() can run without
> > blocking BH or 'writers'. But we really use the seqcount in it.
> >=20
> > Spinlock itself is only locked by the current cpu, so we can remove=
 it
> > completely.
> >=20
> > This cleanups api, using correct 'writer' vs 'reader' semantic.
> >=20
> > At replace time, the get_counters() call makes sure all cpus are do=
ne
> > using the old table.
> >=20
> > We could probably avoid blocking BH (we currently block them in xmi=
t
> > path), but thats a different topic ;)
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> FWIW, I think this is a great idea.

I knew you would be interested :)

While looking at it (and trying to only require preemption disabled
instead of BH disabled), I believe stackptr management is not safe.

I suggest following patch to make sure we restore *stackptr to origptr
before enabling BH (or preemption later)

Thanks

[PATCH] netfilter: xtables: fix reentrancy

commit f3c5c1bfd4308 (make ip_tables reentrant) introduced a race in
handling the stackptr restore, at the end of ipt_do_table()

We should do it before the call to xt_info_rdunlock_bh(), or we allow
cpu preemption and another cpu overwrites stackptr of original one.

A second fix is to change the underflow test to check the origptr value
instead of 0 to detect underflow, or else we allow a jump from differen=
t
hooks.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Jan Engelhardt <jengelh@medozas.de>
Cc: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/ip_tables.c  |    4 ++--
 net/ipv6/netfilter/ip6_tables.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tab=
les.c
index b09ed0d..ffcea0d 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -387,7 +387,7 @@ ipt_do_table(struct sk_buff *skb,
 					verdict =3D (unsigned)(-v) - 1;
 					break;
 				}
-				if (*stackptr =3D=3D 0) {
+				if (*stackptr <=3D origptr) {
 					e =3D get_entry(table_base,
 					    private->underflow[hook]);
 					pr_debug("Underflow (this is normal) "
@@ -427,10 +427,10 @@ ipt_do_table(struct sk_buff *skb,
 			/* Verdict */
 			break;
 	} while (!acpar.hotdrop);
-	xt_info_rdunlock_bh();
 	pr_debug("Exiting %s; resetting sp from %u to %u\n",
 		 __func__, *stackptr, origptr);
 	*stackptr =3D origptr;
+	xt_info_rdunlock_bh();
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
 #else
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_t=
ables.c
index c9598a9..0b2af9b 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -410,7 +410,7 @@ ip6t_do_table(struct sk_buff *skb,
 					verdict =3D (unsigned)(-v) - 1;
 					break;
 				}
-				if (*stackptr =3D=3D 0)
+				if (*stackptr <=3D origptr)
 					e =3D get_entry(table_base,
 					    private->underflow[hook]);
 				else
@@ -441,8 +441,8 @@ ip6t_do_table(struct sk_buff *skb,
 			break;
 	} while (!acpar.hotdrop);
=20
-	xt_info_rdunlock_bh();
 	*stackptr =3D origptr;
+	xt_info_rdunlock_bh();
=20
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
