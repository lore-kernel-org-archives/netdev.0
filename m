From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: DDoS attack causing bad effect on conntrack searches
Date: Mon, 31 May 2010 23:21:36 +0200
Message-ID: <1275340896.2478.26.camel@edumazet-laptop>
References: <1271941082.14501.189.camel@jdb-workstation>
	 <q2h412e6f7f1004220613m488c2ee4r6d24a8d1e65997d4@mail.gmail.com>
	 <4BD04C74.9020402@trash.net> <1271946961.7895.5665.camel@edumazet-laptop>
	 <1271948029.7895.5707.camel@edumazet-laptop>
	 <20100422155123.GA2524@linux.vnet.ibm.com>
	 <1271952128.7895.5851.camel@edumazet-laptop>
	 <Pine.LNX.4.64.1004222213290.10919@ask.diku.dk>
	 <1272056237.4599.7.camel@edumazet-laptop>
	 <Pine.LNX.4.64.1004241219280.32071@ask.diku.dk>
	 <1272139861.20714.525.camel@edumazet-laptop>
	 <1272292568.13192.43.camel@jdb-workstation>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <hawk@diku.dk>, paulmck@linux.vnet.ibm.com,
	Patrick McHardy <kaber@trash.net>,
	Changli Gao <xiaosuo@gmail.com>,
	Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: hawk@comx.dk
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1272292568.13192.43.camel@jdb-workstation>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 26 avril 2010 =C3=A0 16:36 +0200, Jesper Dangaard Brouer a =C3=
=A9crit :
> On Sat, 2010-04-24 at 22:11 +0200, Eric Dumazet wrote:
> > =20
> > > Monday or Tuesdag I'll do a test setup with some old HP380 G4 mac=
hines to=20
> > > see if I can reproduce the DDoS attack senario.  And see if I can=
 get=20
> > > it into to lookup loop.
> >=20
> > Theorically a loop is very unlikely, given a single retry is very
> > unlikly too.
> >=20
> > Unless a cpu gets in its cache a corrupted value of a 'next' pointe=
r.
> >=20
> ...
> >
> > With same hash bucket size (300.032) and max conntracks (800.000), =
and
> > after more than 10 hours of test, not a single lookup was restarted
> > because of a nulls with wrong value.
>=20
> So fare, I have to agree with you.  I have now tested on the same typ=
e
> of hardware (although running a 64-bit kernel, and off net-next-2.6),
> and the result is, the same as yours, I don't see a any restarts of t=
he
> loop.  The test systems differs a bit, as it has two physical CPU and=
 2M
> cache (and annoyingly the system insists on using HPET as clocksource=
).
>=20
> Guess, the only explanation would be bad/sub-optimal hash distributio=
n.
> With 40 kpps and 700.000 'searches' per second, the hash bucket list
> length "only" need to be 17.5 elements on average, where optimum is 3=
=2E
> With my pktgen DoS test, where I tried to reproduce the DoS attack, o=
nly
> see a screw of 6 elements on average.
>=20
>=20
> > I can setup a test on a 16 cpu machine, multiqueue card too.
>=20
> Don't think that is necessary.  My theory was it was possible on slow=
er
> single queue NIC, where one CPU is 100% busy in the conntrack search,
> and the other CPUs delete the entries (due to early drop and
> call_rcu()).  But guess that note the case, and RCU works perfectly ;=
-)
>=20
> > Hmm, I forgot to say I am using net-next-2.6, not your kernel versi=
on...
>=20
> I also did this test using net-next-2.6, perhaps I should try the
> version I use in production...
>=20
>=20


I had a look at current conntrack and found the 'unconfirmed' list was
maybe a candidate for a potential blackhole.

That is, if a reader happens to hit an entry that is moved from regular
hash table slot 'hash' to unconfirmed list, reader might scan whole
unconfirmed list to find out he is not anymore on the wanted hash chain=
=2E

Problem is this unconfirmed list might be very very long in case of
DDOS. It's really not designed to be scanned during a lookup.

So I guess we should stop early if we find an unconfirmed entry ?



diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilt=
er/nf_conntrack.h
index bde095f..0573641 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -298,8 +298,10 @@ extern int nf_conntrack_set_hashsize(const char *v=
al, struct kernel_param *kp);
 extern unsigned int nf_conntrack_htable_size;
 extern unsigned int nf_conntrack_max;
=20
-#define NF_CT_STAT_INC(net, count)	\
+#define NF_CT_STAT_INC(net, count)		\
 	__this_cpu_inc((net)->ct.stat->count)
+#define NF_CT_STAT_ADD(net, count, value)	\
+	__this_cpu_add((net)->ct.stat->count, value)
 #define NF_CT_STAT_INC_ATOMIC(net, count)		\
 do {							\
 	local_bh_disable();				\
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_connt=
rack_core.c
index eeeb8bc..e96d999 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -299,6 +299,7 @@ __nf_conntrack_find(struct net *net, u16 zone,
 	struct nf_conntrack_tuple_hash *h;
 	struct hlist_nulls_node *n;
 	unsigned int hash =3D hash_conntrack(net, zone, tuple);
+	unsigned int cnt =3D 0;
=20
 	/* Disable BHs the entire time since we normally need to disable them
 	 * at least once for the stats anyway.
@@ -309,10 +310,19 @@ begin:
 		if (nf_ct_tuple_equal(tuple, &h->tuple) &&
 		    nf_ct_zone(nf_ct_tuplehash_to_ctrack(h)) =3D=3D zone) {
 			NF_CT_STAT_INC(net, found);
+			NF_CT_STAT_ADD(net, searched, cnt);
 			local_bh_enable();
 			return h;
 		}
-		NF_CT_STAT_INC(net, searched);
+		/*
+		 * If we find an unconfirmed entry, restart the lookup to
+		 * avoid scanning whole unconfirmed list
+		 */
+		if (unlikely(++cnt > 8 &&
+			     !nf_ct_is_confirmed(nf_ct_tuplehash_to_ctrack(h)))) {
+			NF_CT_STAT_INC(net, search_restart);
+			goto begin;
+		}
 	}
 	/*
 	 * if the nulls value we got at the end of this lookup is
@@ -323,6 +333,7 @@ begin:
 		NF_CT_STAT_INC(net, search_restart);
 		goto begin;
 	}
+	NF_CT_STAT_ADD(net, searched, cnt);
 	local_bh_enable();
=20
 	return NULL;


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
