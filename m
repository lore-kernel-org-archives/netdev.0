From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] netfilter: ip_tables: dont block BH while
 reading counters
Date: Thu, 16 Dec 2010 17:07:05 +0100
Message-ID: <1292515625.2883.336.camel@edumazet-laptop>
References: <1292337974.9155.68.camel@firesoul.comx.local>
	 <1292340702.5934.5.camel@edumazet-laptop>
	 <1292342958.9155.91.camel@firesoul.comx.local>
	 <1292343855.5934.27.camel@edumazet-laptop>
	 <1292508266.31289.12.camel@firesoul.comx.local>
	 <1292508733.2883.152.camel@edumazet-laptop>
	 <1292509489.31289.20.camel@firesoul.comx.local>
	 <1292509775.2883.187.camel@edumazet-laptop>
	 <1292511761.2883.236.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnaldo Carvalho de Melo <acme@infradead.org>,
	Steven Rostedt <srostedt@redhat.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Jesper Dangaard Brouer <hawk@comx.dk>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1292511761.2883.236.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 16 d=C3=A9cembre 2010 =C3=A0 16:02 +0100, Eric Dumazet a =C3=A9=
crit :
> Le jeudi 16 d=C3=A9cembre 2010 =C3=A0 15:29 +0100, Eric Dumazet a =C3=
=A9crit :
> > Le jeudi 16 d=C3=A9cembre 2010 =C3=A0 15:24 +0100, Jesper Dangaard =
Brouer a
> > =C3=A9crit :
> >=20
> > > In my case I think this will not help. I'll kill the cache anyway=
s, as
> > > the ruleset is 19MB and my CPU cache is 8MB.
> > >=20
> > >=20
> >=20
> > Yep ;)
> >=20
> > By the way, you speak of a 'possible regression', but we always mas=
ked
> > BH while doing get_counters().
> >=20
> > Only very recent kernels are masking them for each unit (cpu) of wo=
rk.
> >=20
> > There was attempt to use a lockless read for each counter (using a
> > seqlock), but it was not completed. I guess we could do something t=
o
> > ressurect this idea.
> >=20
> >=20
>=20
> Something like following patch :

Here is a tested version : no need for a (buggy in previous patch)
memset() if we use vzalloc()

Note : We miss a this_cpu_write_seqcount_begin() interface.
I'll bug lkml to get it asap.

Thanks

[PATCH net-next-2.6] netfilter: ip_tables: dont block BH while reading =
counters

Using "iptables -L" with a lot of rules might have a too big BH latency=
=2E
Jesper mentioned ~6 ms and worried of frame drops.

Switch to a per_cpu seqcount scheme, so that taking a snapshot of
counters doesnt need to block BH (for this cpu, but also other cpus).
This slow down a bit each counter updates, using two extra increments.

Note : We miss a this_cpu_write_seqcount_begin() interface, so we are
forced to compute the address of our per_cpu seqcount to call
write_seqcount_begin(). Once available, overhead will be exactly two
"incl %gs:counters_seq" instructions on x86

Reported-by: Jesper Dangaard Brouer <hawk@comx.dk>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/netfilter/ip_tables.c |   52 ++++++++++++-------------------
 1 file changed, 21 insertions(+), 31 deletions(-)

diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tab=
les.c
index a846d63..ae18ead 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -293,6 +293,8 @@ struct ipt_entry *ipt_next_entry(const struct ipt_e=
ntry *entry)
 	return (void *)entry + entry->next_offset;
 }
=20
+static DEFINE_PER_CPU(seqcount_t, counters_seq);
+
 /* Returns one of the generic firewall policies, like NF_ACCEPT. */
 unsigned int
 ipt_do_table(struct sk_buff *skb,
@@ -311,6 +313,7 @@ ipt_do_table(struct sk_buff *skb,
 	unsigned int *stackptr, origptr, cpu;
 	const struct xt_table_info *private;
 	struct xt_action_param acpar;
+	seqcount_t *seq;
=20
 	/* Initialization */
 	ip =3D ip_hdr(skb);
@@ -364,7 +367,11 @@ ipt_do_table(struct sk_buff *skb,
 				goto no_match;
 		}
=20
+		seq =3D &__get_cpu_var(counters_seq);
+		/* could be faster if we had this_cpu_write_seqcount_begin() */
+		write_seqcount_begin(seq);
 		ADD_COUNTER(e->counters, skb->len, 1);
+		write_seqcount_end(seq);
=20
 		t =3D ipt_get_target(e);
 		IP_NF_ASSERT(t->u.kernel.target);
@@ -884,42 +891,25 @@ get_counters(const struct xt_table_info *t,
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
+		seqcount_t *seq =3D &per_cpu(counters_seq, cpu);
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
@@ -932,7 +922,7 @@ static struct xt_counters *alloc_counters(const str=
uct xt_table *table)
 	   (other than comefrom, which userspace doesn't care
 	   about). */
 	countersize =3D sizeof(struct xt_counters) * private->number;
-	counters =3D vmalloc(countersize);
+	counters =3D vzalloc(countersize);
=20
 	if (counters =3D=3D NULL)
 		return ERR_PTR(-ENOMEM);
@@ -1203,7 +1193,7 @@ __do_replace(struct net *net, const char *name, u=
nsigned int valid_hooks,
 	struct ipt_entry *iter;
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
