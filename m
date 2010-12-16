From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next-2.6] netfilter: ip_tables: dont block BH while
 reading counters
Date: Thu, 16 Dec 2010 17:53:56 +0100
Message-ID: <1292518436.2883.393.camel@edumazet-laptop>
References: <1292337974.9155.68.camel@firesoul.comx.local>
	 <1292340702.5934.5.camel@edumazet-laptop>
	 <1292342958.9155.91.camel@firesoul.comx.local>
	 <1292343855.5934.27.camel@edumazet-laptop>
	 <1292508266.31289.12.camel@firesoul.comx.local>
	 <1292508733.2883.152.camel@edumazet-laptop>
	 <1292509489.31289.20.camel@firesoul.comx.local>
	 <1292509775.2883.187.camel@edumazet-laptop>
	 <1292511761.2883.236.camel@edumazet-laptop>
	 <1292515625.2883.336.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Steven Rostedt <srostedt@redhat.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f45.google.com ([209.85.214.45]:49249 "EHLO
	mail-bw0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754759Ab0LPQyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 11:54:04 -0500
In-Reply-To: <1292515625.2883.336.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 16 d=C3=A9cembre 2010 =C3=A0 17:07 +0100, Eric Dumazet a =C3=A9=
crit :

> Here is a tested version : no need for a (buggy in previous patch)
> memset() if we use vzalloc()
>=20
> Note : We miss a this_cpu_write_seqcount_begin() interface.
> I'll bug lkml to get it asap.

Well, we have a faster solution :

Add seqcount in "struct xt_info_lock"
so that we make the increment pair once per table, not once per rule,
and we already have the seq address, so no need for
this_cpu_write_seqcount_begin() interface.


[PATCH v2 net-next-2.6] netfilter: ip_tables: dont block BH while readi=
ng counters

Using "iptables -L" with a lot of rules might have a too big BH latency=
=2E
Jesper mentioned ~6 ms and worried of frame drops.

Switch to a per_cpu seqcount scheme, so that taking a snapshot of
counters doesnt need to block BH (for this cpu, but also other cpus).

Reported-by: Jesper Dangaard Brouer <hawk@comx.dk>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netfilter/x_tables.h |    9 ++++-
 net/ipv4/netfilter/ip_tables.c     |   45 ++++++++-------------------
 2 files changed, 21 insertions(+), 33 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilt=
er/x_tables.h
index 742bec0..7027762 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -473,6 +473,7 @@ extern void xt_free_table_info(struct xt_table_info=
 *info);
  */
 struct xt_info_lock {
 	spinlock_t lock;
+	seqcount_t seq;
 	unsigned char readers;
 };
 DECLARE_PER_CPU(struct xt_info_lock, xt_info_locks);
@@ -496,16 +497,20 @@ static inline void xt_info_rdlock_bh(void)
=20
 	local_bh_disable();
 	lock =3D &__get_cpu_var(xt_info_locks);
-	if (likely(!lock->readers++))
+	if (likely(!lock->readers++)) {
 		spin_lock(&lock->lock);
+		write_seqcount_begin(&lock->seq);
+	}
 }
=20
 static inline void xt_info_rdunlock_bh(void)
 {
 	struct xt_info_lock *lock =3D &__get_cpu_var(xt_info_locks);
=20
-	if (likely(!--lock->readers))
+	if (likely(!--lock->readers)) {
+		write_seqcount_end(&lock->seq);
 		spin_unlock(&lock->lock);
+	}
 	local_bh_enable();
 }
=20
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tab=
les.c
index a846d63..7fe3d7c 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -884,42 +884,25 @@ get_counters(const struct xt_table_info *t,
 	struct ipt_entry *iter;
 	unsigned int cpu;
 	unsigned int i;
-	unsigned int curcpu =3D get_cpu();
-
-	/* Instead of clearing (by a previous call to memset())
-	 * the counters and using adds, we set the counters
-	 * with data used by 'current' CPU.
-	 *
-	 * Bottom half has to be disabled to prevent deadlock
-	 * if new softirq were to run and call ipt_do_table
-	 */
-	local_bh_disable();
-	i =3D 0;
-	xt_entry_foreach(iter, t->entries[curcpu], t->size) {
-		SET_COUNTER(counters[i], iter->counters.bcnt,
-			    iter->counters.pcnt);
-		++i;
-	}
-	local_bh_enable();
-	/* Processing counters from other cpus, we can let bottom half enable=
d,
-	 * (preemption is disabled)
-	 */
=20
 	for_each_possible_cpu(cpu) {
-		if (cpu =3D=3D curcpu)
-			continue;
+		seqcount_t *seq =3D &per_cpu(xt_info_locks, cpu).seq;
+
 		i =3D 0;
-		local_bh_disable();
-		xt_info_wrlock(cpu);
 		xt_entry_foreach(iter, t->entries[cpu], t->size) {
-			ADD_COUNTER(counters[i], iter->counters.bcnt,
-				    iter->counters.pcnt);
+			u64 bcnt, pcnt;
+			unsigned int start;
+
+			do {
+				start =3D read_seqcount_begin(seq);
+				bcnt =3D iter->counters.bcnt;
+				pcnt =3D iter->counters.pcnt;
+			} while (read_seqcount_retry(seq, start));
+
+			ADD_COUNTER(counters[i], bcnt, pcnt);
 			++i; /* macro does multi eval of i */
 		}
-		xt_info_wrunlock(cpu);
-		local_bh_enable();
 	}
-	put_cpu();
 }
=20
 static struct xt_counters *alloc_counters(const struct xt_table *table=
)
@@ -932,7 +915,7 @@ static struct xt_counters *alloc_counters(const str=
uct xt_table *table)
 	   (other than comefrom, which userspace doesn't care
 	   about). */
 	countersize =3D sizeof(struct xt_counters) * private->number;
-	counters =3D vmalloc(countersize);
+	counters =3D vzalloc(countersize);
=20
 	if (counters =3D=3D NULL)
 		return ERR_PTR(-ENOMEM);
@@ -1203,7 +1186,7 @@ __do_replace(struct net *net, const char *name, u=
nsigned int valid_hooks,
 	struct ipt_entry *iter;
=20
 	ret =3D 0;
-	counters =3D vmalloc(num_counters * sizeof(struct xt_counters));
+	counters =3D vzalloc(num_counters * sizeof(struct xt_counters));
 	if (!counters) {
 		ret =3D -ENOMEM;
 		goto out;


