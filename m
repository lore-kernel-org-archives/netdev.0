From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: DDoS attack causing bad effect on conntrack searches
Date: Thu, 22 Apr 2010 23:14:53 +0200
Message-ID: <1271970893.7895.6507.camel@edumazet-laptop>
References: <1271941082.14501.189.camel@jdb-workstation>
	 <q2h412e6f7f1004220613m488c2ee4r6d24a8d1e65997d4@mail.gmail.com>
	 <4BD04C74.9020402@trash.net> <1271946961.7895.5665.camel@edumazet-laptop>
	 <1271948029.7895.5707.camel@edumazet-laptop>
	 <20100422155123.GA2524@linux.vnet.ibm.com>
	 <1271952128.7895.5851.camel@edumazet-laptop>
	 <Pine.LNX.4.64.1004222213290.10919@ask.diku.dk>
	 <1271970199.7895.6482.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com, Patrick McHardy <kaber@trash.net>,
	Changli Gao <xiaosuo@gmail.com>, hawk@comx.dk,
	Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1271970199.7895.6482.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 22 avril 2010 =C3=A0 23:03 +0200, Eric Dumazet a =C3=A9crit :
> Le jeudi 22 avril 2010 =C3=A0 22:38 +0200, Jesper Dangaard Brouer a =C3=
=A9crit :
> > On Thu, 22 Apr 2010, Eric Dumazet wrote:
> >=20
> > > Le jeudi 22 avril 2010 =C3=A0 08:51 -0700, Paul E. McKenney a =C3=
=A9crit :
> > >> On Thu, Apr 22, 2010 at 04:53:49PM +0200, Eric Dumazet wrote:
> > >>> Le jeudi 22 avril 2010 =C3=A0 16:36 +0200, Eric Dumazet a =C3=A9=
crit :
> > >>>
> > >>> If we can do the 'retry' a 10 times, it means the attacker was =
really
> > >>> clever enough to inject new packets (new conntracks) at the rig=
ht
> > >>> moment, in the right hash chain, and this sounds so higly incre=
dible
> > >>> that I cannot believe it at all :)
> > >>
> > >> Or maybe the DoS attack is injecting so many new conntracks that=
 a large
> > >> fraction of the hash chains are being modified at any given time=
?
> > >>
> >=20
> > I think its plausable, there is a lot of modification going on.
> > Approx 40.000 deletes/sec and 40.000 inserts/sec.
> > The hash bucket size is 300032, and with 80000 modifications/sec, w=
e are=20
> > (potentially) changing 26.6% of the hash chains each second.
> >=20
>=20
> OK but a lookup last a fraction of a micro second, unless interrupted=
 by
> hard irq.
>=20
> Probability of a change during a lookup should be very very small.
>=20
> Note that the scenario for a restart is :
>=20
> The lookup go through the chain.
> While it is examining one object, this object is deleted.
> The object is re-allocated by another cpu and inserted to a new chain=
=2E
>=20
>=20
> What exact version of kernel are you running ?
>=20
> > As can be seen from the graphs:
> >   http://people.netfilter.org/hawk/DDoS/2010-04-12__001/list.html
> >=20
> > Notice that primarily CPU2 is doing the 40k deletes/sec, while CPU1=
 is=20
> > caught searching...
> >=20
> >=20
> > > maybe hash table has one slot :)
> >=20
> > Guess I have to reproduce the DoS attack in a testlab (I will first=
 have=20
> > time Tuesday).  So we can determine if its bad hashing or restart o=
f the=20
> > search loop.
> >=20

Or very long chains, if attacker managed to find a jhash flaw.

You could add a lookup_restart counter :


 include/linux/netfilter/nf_conntrack_common.h         |    1 +
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c |    7 ++++---
 net/netfilter/nf_conntrack_core.c                     |    4 +++-
 net/netfilter/nf_conntrack_standalone.c               |    7 ++++---
 4 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/include/linux/netfilter/nf_conntrack_common.h b/include/li=
nux/netfilter/nf_conntrack_common.h
index c608677..cf9a8df 100644
--- a/include/linux/netfilter/nf_conntrack_common.h
+++ b/include/linux/netfilter/nf_conntrack_common.h
@@ -113,6 +113,7 @@ struct ip_conntrack_stat {
 	unsigned int expect_new;
 	unsigned int expect_create;
 	unsigned int expect_delete;
+	unsigned int lookup_restart;
 };
=20
 /* call to create an explicit dependency on nf_conntrack. */
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c b/ne=
t/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
index 2fb7b76..95f2227 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
@@ -336,12 +336,12 @@ static int ct_cpu_seq_show(struct seq_file *seq, =
void *v)
 	const struct ip_conntrack_stat *st =3D v;
=20
 	if (v =3D=3D SEQ_START_TOKEN) {
-		seq_printf(seq, "entries  searched found new invalid ignore delete d=
elete_list insert insert_failed drop early_drop icmp_error  expect_new =
expect_create expect_delete\n");
+		seq_printf(seq, "entries  searched found new invalid ignore delete d=
elete_list insert insert_failed drop early_drop icmp_error  expect_new =
expect_create expect_delete lookup_restart\n");
 		return 0;
 	}
=20
 	seq_printf(seq, "%08x  %08x %08x %08x %08x %08x %08x %08x "
-			"%08x %08x %08x %08x %08x  %08x %08x %08x \n",
+			"%08x %08x %08x %08x %08x  %08x %08x %08x %08x\n",
 		   nr_conntracks,
 		   st->searched,
 		   st->found,
@@ -358,7 +358,8 @@ static int ct_cpu_seq_show(struct seq_file *seq, vo=
id *v)
=20
 		   st->expect_new,
 		   st->expect_create,
-		   st->expect_delete
+		   st->expect_delete,
+		   st->lookup_restart
 		);
 	return 0;
 }
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_connt=
rack_core.c
index 0c9bbe9..68e53f1 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -319,8 +319,10 @@ begin:
 	 * not the expected one, we must restart lookup.
 	 * We probably met an item that was moved to another chain.
 	 */
-	if (get_nulls_value(n) !=3D hash)
+	if (unlikely(get_nulls_value(n) !=3D hash)) {
+		NF_CT_STAT_INC(net, lookup_restart);
 		goto begin;
+	}
 	local_bh_enable();
=20
 	return NULL;
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf=
_conntrack_standalone.c
index faa8eb3..c8a286e 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -252,12 +252,12 @@ static int ct_cpu_seq_show(struct seq_file *seq, =
void *v)
 	const struct ip_conntrack_stat *st =3D v;
=20
 	if (v =3D=3D SEQ_START_TOKEN) {
-		seq_printf(seq, "entries  searched found new invalid ignore delete d=
elete_list insert insert_failed drop early_drop icmp_error  expect_new =
expect_create expect_delete\n");
+		seq_printf(seq, "entries  searched found new invalid ignore delete d=
elete_list insert insert_failed drop early_drop icmp_error  expect_new =
expect_create expect_delete lookup_restart\n");
 		return 0;
 	}
=20
 	seq_printf(seq, "%08x  %08x %08x %08x %08x %08x %08x %08x "
-			"%08x %08x %08x %08x %08x  %08x %08x %08x \n",
+			"%08x %08x %08x %08x %08x  %08x %08x %08x %08x\n",
 		   nr_conntracks,
 		   st->searched,
 		   st->found,
@@ -274,7 +274,8 @@ static int ct_cpu_seq_show(struct seq_file *seq, vo=
id *v)
=20
 		   st->expect_new,
 		   st->expect_create,
-		   st->expect_delete
+		   st->expect_delete,
+		   st->lookup_restart
 		);
 	return 0;
 }


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
