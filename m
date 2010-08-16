From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [LOCKDEP BUG][2.6.36-rc1] xt_info_wrlock?
Date: Mon, 16 Aug 2010 20:48:05 +0200
Message-ID: <1281984485.2487.24.camel@edumazet-laptop>
References: <1281978469.3268.55.camel@gandalf.stny.rr.com>
	 <1281979893.2524.54.camel@edumazet-laptop>
	 <1281981301.3268.110.camel@gandalf.stny.rr.com>
	 <1281982566.3268.137.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1281982566.3268.137.camel@gandalf.stny.rr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 16 ao=C3=BBt 2010 =C3=A0 14:16 -0400, Steven Rostedt a =C3=A9c=
rit :

> We need a better comment than that. Could that be changed to somethin=
g like:
>=20
> 	/*
> 	 * lockdep tests if we grab a lock and can be preempted by=20
> 	 * a softirq and that softirq grabs the same lock causing a
> 	 * deadlock.
> 	 * This is a special case because this is a per-cpu lock,
> 	 * and we are only grabbing the lock for other CPUs. A softirq
> 	 * will only takes its local CPU lock thus, if we are preempted
> 	 * by a softirq, then it will grab the current CPU lock which
> 	 * we do not take here.
> 	 *
> 	 * Simply disable lockdep here until it can handle this situation.
> 	 */
>=20

You mean duplicating this long comment in three files, or only once in
Changelog ?

My choice was to document the lockdep_off() use (very seldom used in
kernel) in the Changelog. Hopefully, people messing with this code know
about git ;)

I agree I didnt document how netfilter locks work in this Changelog.

And in original commit (24b36f019) I forgot to state that get_counters(=
)
is guarded by a mutex, so that no more than one cpu runs in
get_counters().

What about following ?

[PATCH] netfilter: {ip,ip6,arp}_tables: avoid lockdep false positive

After commit 24b36f019 (netfilter: {ip,ip6,arp}_tables: dont block
bottom half more than necessary), lockdep can raise a warning
because we attempt to lock a spinlock with BH enabled, while
the same lock is usually locked by another cpu in a softirq context.

In this use case, the lockdep splat is a false positive, because
the BH disabling only matters for one cpu and its associated.

1) We use one spinlock per cpu.

2) A softirq will only lock the lock associated to current cpu.

3) get_counters() disables sofirqs while fetching data of current cpu.
   (to avoid a deadlock if a softirq comes and try to lock same lock)

4) other locks are locked without blocking softirq
   (as a softirq will lock another lock)

5) get_counter() calls are serialized by a mutex.

   This to avoid a deadlock if two cpus were doing :

   CPU1          CPU2
lock lock#1      lock lock#2
copy data#1      copy data#2
unlock lock#1    unlock lock#2

lock#2           lock#1
softirq lock#1   softirq, attempt to lock lock#2
<deadlock>       <deadlock>

Use lockdep_off()/lockdep_on() around the problematic section to
avoid the splat.

Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
Diagnosed-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/arp_tables.c |    3 +++
 net/ipv4/netfilter/ip_tables.c  |    3 +++
 net/ipv6/netfilter/ip6_tables.c |    3 +++
 3 files changed, 9 insertions(+)


diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_t=
ables.c
index 6bccba3..b4f7ebf 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -729,8 +729,10 @@ static void get_counters(const struct xt_table_inf=
o *t,
 	local_bh_enable();
 	/* Processing counters from other cpus, we can let bottom half enable=
d,
 	 * (preemption is disabled)
+	 * We must turn off lockdep to avoid a false positive.
 	 */
=20
+	lockdep_off();
 	for_each_possible_cpu(cpu) {
 		if (cpu =3D=3D curcpu)
 			continue;
@@ -743,6 +745,7 @@ static void get_counters(const struct xt_table_info=
 *t,
 		}
 		xt_info_wrunlock(cpu);
 	}
+	lockdep_on();
 	put_cpu();
 }
=20
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tab=
les.c
index c439721..dc5b2fd 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -903,8 +903,10 @@ get_counters(const struct xt_table_info *t,
 	local_bh_enable();
 	/* Processing counters from other cpus, we can let bottom half enable=
d,
 	 * (preemption is disabled)
+	 * We must turn off lockdep to avoid a false positive.
 	 */
=20
+	lockdep_off();
 	for_each_possible_cpu(cpu) {
 		if (cpu =3D=3D curcpu)
 			continue;
@@ -917,6 +919,7 @@ get_counters(const struct xt_table_info *t,
 		}
 		xt_info_wrunlock(cpu);
 	}
+	lockdep_on();
 	put_cpu();
 }
=20
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_t=
ables.c
index 5359ef4..fb55443 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -916,8 +916,10 @@ get_counters(const struct xt_table_info *t,
 	local_bh_enable();
 	/* Processing counters from other cpus, we can let bottom half enable=
d,
 	 * (preemption is disabled)
+	 * We must turn off lockdep to avoid a false positive.
 	 */
=20
+	lockdep_off();
 	for_each_possible_cpu(cpu) {
 		if (cpu =3D=3D curcpu)
 			continue;
@@ -930,6 +932,7 @@ get_counters(const struct xt_table_info *t,
 		}
 		xt_info_wrunlock(cpu);
 	}
+	lockdep_on();
 	put_cpu();
 }
=20
