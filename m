From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH nf-next-2.6 2/2] conntrack: per_cpu untracking
Date: Tue, 08 Jun 2010 17:12:26 +0200
Message-ID: <1276009946.2486.216.camel@edumazet-laptop>
References: <1271941082.14501.189.camel@jdb-workstation>
	 <1271948029.7895.5707.camel@edumazet-laptop>
	 <20100422155123.GA2524@linux.vnet.ibm.com>
	 <1271952128.7895.5851.camel@edumazet-laptop>
	 <Pine.LNX.4.64.1004222213290.10919@ask.diku.dk>
	 <1272056237.4599.7.camel@edumazet-laptop>
	 <Pine.LNX.4.64.1004241219280.32071@ask.diku.dk>
	 <1272139861.20714.525.camel@edumazet-laptop>
	 <1272292568.13192.43.camel@jdb-workstation>
	 <1275340896.2478.26.camel@edumazet-laptop>
	 <AANLkTikw3uonDB4nPXg8FVFN_07F_wq0SA_ayyAHL6VM@mail.gmail.com>
	 <1275368732.2478.88.camel@edumazet-laptop> <4C04DE73.6050605@trash.net>
	 <1275388310.2738.2.camel@edumazet-laptop> <4C04E3E2.7020209@trash.net>
	 <1275409203.2738.227.camel@edumazet-laptop> <4C08E62A.9020607@trash.net>
	 <AANLkTilKEpFTg5bH8d9UE3a3DVJNAGYz10Jgkt6lXtJ0@mail.gmail.com>
	 <4C08F1A4.2050906@trash.net>  <1275654964.2482.150.camel@edumazet-laptop>
	 <1275668732.2482.201.camel@edumazet-laptop>
	 <1275682522.2490.6.camel@edumazet-laptop>  <4C0E53C4.7090308@trash.net>
	 <1276008733.2486.177.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1276008733.2486.177.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 08 juin 2010 =C3=A0 16:52 +0200, Eric Dumazet a =C3=A9crit :
> Le mardi 08 juin 2010 =C3=A0 16:29 +0200, Patrick McHardy a =C3=A9cri=
t :
> > On 04.06.2010 22:15, Eric Dumazet wrote:
> > > NOTRACK makes all cpus share a cache line on nf_conntrack_untrack=
ed
> > > twice per packet, slowing down performance.
> > >=20
> > > This patch converts it to a per_cpu variable.
> > >=20
> > > We assume same cpu is used for a given packet, entering and exiti=
ng the
> > > NOTRACK state.
> >=20
> > That doesn't seem to be a valid assumption, the conntrack entry is
> > attached to the skb and processing in the output path might get
> > preempted and rescheduled to a different CPU.
>=20
> Thats unfortunate.
>=20
> Ok, only choice then is to not change refcount on the untracked ct, a=
nd
> keep a shared (read only after setup time) untrack structure.
>=20
>=20

Oh well, re-reading my patch, I dont see why I said this in Changelog :=
)

We lazily select the untrack structure in one cpu, then keep the pointe=
r
to this untrack structure, attached to ct.

The (still atomic) increment / decrement of refcount is done on the
saved pointer, not on actual per_cpu structure.

So if a packet is rescheduled on a different CPU, second cpu will "only=
"
dirty cache line of other cpu, it probably almost never happens...

Thanks

[PATCH nf-next-2.6 2/2] conntrack: per_cpu untracking

NOTRACK makes all cpus share a cache line on nf_conntrack_untracked
twice per packet, slowing down performance.

This patch converts it to a per_cpu variable.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/netfilter/nf_conntrack.h |    5 +--
 net/netfilter/nf_conntrack_core.c    |   36 ++++++++++++++++++-------
 2 files changed, 28 insertions(+), 13 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilt=
er/nf_conntrack.h
index 3bc38c7..84a4b6f 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -261,11 +261,10 @@ extern s16 (*nf_ct_nat_offset)(const struct nf_co=
nn *ct,
 			       u32 seq);
=20
 /* Fake conntrack entry for untracked connections */
+DECLARE_PER_CPU(struct nf_conn, nf_conntrack_untracked);
 static inline struct nf_conn *nf_ct_untracked_get(void)
 {
-	extern struct nf_conn nf_conntrack_untracked;
-
-	return &nf_conntrack_untracked;
+	return &__raw_get_cpu_var(nf_conntrack_untracked);
 }
 extern void nf_ct_untracked_status_or(unsigned long bits);
=20
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_connt=
rack_core.c
index 6c1da21..9c66141 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -62,8 +62,8 @@ EXPORT_SYMBOL_GPL(nf_conntrack_htable_size);
 unsigned int nf_conntrack_max __read_mostly;
 EXPORT_SYMBOL_GPL(nf_conntrack_max);
=20
-struct nf_conn nf_conntrack_untracked;
-EXPORT_SYMBOL_GPL(nf_conntrack_untracked);
+DEFINE_PER_CPU(struct nf_conn, nf_conntrack_untracked);
+EXPORT_PER_CPU_SYMBOL(nf_conntrack_untracked);
=20
 static int nf_conntrack_hash_rnd_initted;
 static unsigned int nf_conntrack_hash_rnd;
@@ -1183,10 +1183,21 @@ static void nf_ct_release_dying_list(struct net=
 *net)
 	spin_unlock_bh(&nf_conntrack_lock);
 }
=20
+static int untrack_refs(void)
+{
+	int cnt =3D 0, cpu;
+
+	for_each_possible_cpu(cpu) {
+		struct nf_conn *ct =3D &per_cpu(nf_conntrack_untracked, cpu);
+
+		cnt +=3D atomic_read(&ct->ct_general.use) - 1;
+	}
+	return cnt;
+}
+
 static void nf_conntrack_cleanup_init_net(void)
 {
-	/* wait until all references to nf_conntrack_untracked are dropped */
-	while (atomic_read(&nf_conntrack_untracked.ct_general.use) > 1)
+	while (untrack_refs() > 0)
 		schedule();
=20
 	nf_conntrack_helper_fini();
@@ -1323,14 +1334,17 @@ module_param_call(hashsize, nf_conntrack_set_ha=
shsize, param_get_uint,
=20
 void nf_ct_untracked_status_or(unsigned long bits)
 {
-	nf_conntrack_untracked.status |=3D bits;
+	int cpu;
+
+	for_each_possible_cpu(cpu)
+		per_cpu(nf_conntrack_untracked, cpu).status |=3D bits;
 }
 EXPORT_SYMBOL_GPL(nf_ct_untracked_status_or);
=20
 static int nf_conntrack_init_init_net(void)
 {
 	int max_factor =3D 8;
-	int ret;
+	int ret, cpu;
=20
 	/* Idea from tcp.c: use 1/16384 of memory.  On i386: 32MB
 	 * machine has 512 buckets. >=3D 1GB machines have 16384 buckets. */
@@ -1369,10 +1383,12 @@ static int nf_conntrack_init_init_net(void)
 		goto err_extend;
 #endif
 	/* Set up fake conntrack: to never be deleted, not in any hashes */
-#ifdef CONFIG_NET_NS
-	nf_conntrack_untracked.ct_net =3D &init_net;
-#endif
-	atomic_set(&nf_conntrack_untracked.ct_general.use, 1);
+	for_each_possible_cpu(cpu) {
+		struct nf_conn *ct =3D &per_cpu(nf_conntrack_untracked, cpu);
+
+		write_pnet(&ct->ct_net, &init_net);
+		atomic_set(&ct->ct_general.use, 1);
+	}
 	/*  - and look it like as a confirmed connection */
 	nf_ct_untracked_status_or(IPS_CONFIRMED | IPS_UNTRACKED);
 	return 0;


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
