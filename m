From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v3 net-next-2.6] netfilter: x_tables: dont block BH while
 reading counters
Date: Thu, 16 Dec 2010 18:53:06 +0100
Message-ID: <1292521986.2883.472.camel@edumazet-laptop>
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
	 <1292518436.2883.393.camel@edumazet-laptop>
	 <20101216093149.71f082c7@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <hawk@comx.dk>,
	Patrick McHardy <kaber@trash.net>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Steven Rostedt <srostedt@redhat.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20101216093149.71f082c7@nehalam>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 16 d=C3=A9cembre 2010 =C3=A0 09:31 -0800, Stephen Hemminger a =
=C3=A9crit :
> On Thu, 16 Dec 2010 17:53:56 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> >  	spinlock_t lock;
> > +	seqcount_t seq;
>=20
> Since lock and seqcount_t are associated together, why isn't this a s=
eqlock instead?
>=20

Absolutely, I found this a bit later while preparing final patch.

Thanks !

[PATCH v3 net-next-2.6] netfilter: x_tables: dont block BH while readin=
g counters

Using "iptables -L" with a lot of rules might have a too big BH latency=
=2E
Jesper mentioned ~6 ms and worried of frame drops.

Switch to a per_cpu seqcount scheme, so that taking a snapshot of
counters doesnt need to block BH (for this cpu, but also other cpus).

Reported-by: Jesper Dangaard Brouer <hawk@comx.dk>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netfilter/x_tables.h |   10 +++---
 net/ipv4/netfilter/arp_tables.c    |   45 ++++++++-------------------
 net/ipv4/netfilter/ip_tables.c     |   45 ++++++++-------------------
 net/ipv6/netfilter/ip6_tables.c    |   45 ++++++++-------------------
 4 files changed, 47 insertions(+), 98 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilt=
er/x_tables.h
index 742bec0..6712e71 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -472,7 +472,7 @@ extern void xt_free_table_info(struct xt_table_info=
 *info);
  *  necessary for reading the counters.
  */
 struct xt_info_lock {
-	spinlock_t lock;
+	seqlock_t lock;
 	unsigned char readers;
 };
 DECLARE_PER_CPU(struct xt_info_lock, xt_info_locks);
@@ -497,7 +497,7 @@ static inline void xt_info_rdlock_bh(void)
 	local_bh_disable();
 	lock =3D &__get_cpu_var(xt_info_locks);
 	if (likely(!lock->readers++))
-		spin_lock(&lock->lock);
+		write_seqlock(&lock->lock);
 }
=20
 static inline void xt_info_rdunlock_bh(void)
@@ -505,7 +505,7 @@ static inline void xt_info_rdunlock_bh(void)
 	struct xt_info_lock *lock =3D &__get_cpu_var(xt_info_locks);
=20
 	if (likely(!--lock->readers))
-		spin_unlock(&lock->lock);
+		write_sequnlock(&lock->lock);
 	local_bh_enable();
 }
=20
@@ -516,12 +516,12 @@ static inline void xt_info_rdunlock_bh(void)
  */
 static inline void xt_info_wrlock(unsigned int cpu)
 {
-	spin_lock(&per_cpu(xt_info_locks, cpu).lock);
+	write_seqlock(&per_cpu(xt_info_locks, cpu).lock);
 }
=20
 static inline void xt_info_wrunlock(unsigned int cpu)
 {
-	spin_unlock(&per_cpu(xt_info_locks, cpu).lock);
+	write_sequnlock(&per_cpu(xt_info_locks, cpu).lock);
 }
=20
 /*
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_t=
ables.c
index 3fac340..e855fff 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -710,42 +710,25 @@ static void get_counters(const struct xt_table_in=
fo *t,
 	struct arpt_entry *iter;
 	unsigned int cpu;
 	unsigned int i;
-	unsigned int curcpu =3D get_cpu();
-
-	/* Instead of clearing (by a previous call to memset())
-	 * the counters and using adds, we set the counters
-	 * with data used by 'current' CPU
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
+		seqlock_t *lock =3D &per_cpu(xt_info_locks, cpu).lock;
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
+				start =3D read_seqbegin(lock);
+				bcnt =3D iter->counters.bcnt;
+				pcnt =3D iter->counters.pcnt;
+			} while (read_seqretry(lock, start));
+
+			ADD_COUNTER(counters[i], bcnt, pcnt);
 			++i;
 		}
-		xt_info_wrunlock(cpu);
-		local_bh_enable();
 	}
-	put_cpu();
 }
=20
 static struct xt_counters *alloc_counters(const struct xt_table *table=
)
@@ -759,7 +742,7 @@ static struct xt_counters *alloc_counters(const str=
uct xt_table *table)
 	 * about).
 	 */
 	countersize =3D sizeof(struct xt_counters) * private->number;
-	counters =3D vmalloc(countersize);
+	counters =3D vzalloc(countersize);
=20
 	if (counters =3D=3D NULL)
 		return ERR_PTR(-ENOMEM);
@@ -1007,7 +990,7 @@ static int __do_replace(struct net *net, const cha=
r *name,
 	struct arpt_entry *iter;
=20
 	ret =3D 0;
-	counters =3D vmalloc(num_counters * sizeof(struct xt_counters));
+	counters =3D vzalloc(num_counters * sizeof(struct xt_counters));
 	if (!counters) {
 		ret =3D -ENOMEM;
 		goto out;
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tab=
les.c
index a846d63..652efea 100644
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
+		seqlock_t *lock =3D &per_cpu(xt_info_locks, cpu).lock;
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
+				start =3D read_seqbegin(lock);
+				bcnt =3D iter->counters.bcnt;
+				pcnt =3D iter->counters.pcnt;
+			} while (read_seqretry(lock, start));
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
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_t=
ables.c
index 4555823..7d227c6 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -897,42 +897,25 @@ get_counters(const struct xt_table_info *t,
 	struct ip6t_entry *iter;
 	unsigned int cpu;
 	unsigned int i;
-	unsigned int curcpu =3D get_cpu();
-
-	/* Instead of clearing (by a previous call to memset())
-	 * the counters and using adds, we set the counters
-	 * with data used by 'current' CPU
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
+		seqlock_t *lock =3D &per_cpu(xt_info_locks, cpu).lock;
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
+				start =3D read_seqbegin(lock);
+				bcnt =3D iter->counters.bcnt;
+				pcnt =3D iter->counters.pcnt;
+			} while (read_seqretry(lock, start));
+
+			ADD_COUNTER(counters[i], bcnt, pcnt);
 			++i;
 		}
-		xt_info_wrunlock(cpu);
-		local_bh_enable();
 	}
-	put_cpu();
 }
=20
 static struct xt_counters *alloc_counters(const struct xt_table *table=
)
@@ -945,7 +928,7 @@ static struct xt_counters *alloc_counters(const str=
uct xt_table *table)
 	   (other than comefrom, which userspace doesn't care
 	   about). */
 	countersize =3D sizeof(struct xt_counters) * private->number;
-	counters =3D vmalloc(countersize);
+	counters =3D vzalloc(countersize);
=20
 	if (counters =3D=3D NULL)
 		return ERR_PTR(-ENOMEM);
@@ -1216,7 +1199,7 @@ __do_replace(struct net *net, const char *name, u=
nsigned int valid_hooks,
 	struct ip6t_entry *iter;
=20
 	ret =3D 0;
-	counters =3D vmalloc(num_counters * sizeof(struct xt_counters));
+	counters =3D vzalloc(num_counters * sizeof(struct xt_counters));
 	if (!counters) {
 		ret =3D -ENOMEM;
 		goto out;


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
