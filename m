From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Fw: [Bug 13339] New: rtable leak in ipv4/route.c
Date: Tue, 19 May 2009 17:32:29 +0200
Message-ID: <4A12D10D.3000504@cosmosbay.com>
References: <20090519123417.GA7376@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lav@yar.ru, Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44683 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752949AbZESPcm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 11:32:42 -0400
In-Reply-To: <20090519123417.GA7376@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski a =E9crit :
> On 19-05-2009 04:35, Stephen Hemminger wrote:
>> Begin forwarded message:
>>
>> Date: Mon, 18 May 2009 14:10:20 GMT
>> From: bugzilla-daemon@bugzilla.kernel.org
>> To: shemminger@linux-foundation.org
>> Subject: [Bug 13339] New: rtable leak in ipv4/route.c
>>
>>
>> http://bugzilla.kernel.org/show_bug.cgi?id=3D13339
> ...
>> 2.6.29 patch has introduced flexible route cache rebuilding. Unfortu=
nately the
>> patch has at least one critical flaw, and another problem.
>>
>> rt_intern_hash calculates rthi pointer, which is later used for new =
entry
>> insertion. The same loop calculates cand pointer which is used to cl=
ean the
>> list. If the pointers are the same, rtable leak occurs, as first the=
 cand is
>> removed then the new entry is appended to it.
>>
>> This leak leads to unregister_netdevice problem (usage count > 0).
>>
>> Another problem of the patch is that it tries to insert the entries =
in certain
>> order, to facilitate counting of entries distinct by all but QoS par=
ameters.
>> Unfortunately, referencing an existing rtable entry moves it to list=
 beginning,
>> to speed up further lookups, so the carefully built order is destroy=
ed.

We could change rt_check_expire() to be smarter and handle any order in=
 chains.

This would let rt_intern_hash() be simpler.

As its a more performance critical path, all would be good :)

>>
>> For the first problem the simplest patch it to set rthi=3D0 when rth=
i=3D=3Dcand, but
>> it will also destroy the ordering.
>=20
> I think fixing this bug fast is more important than this
> ordering or counting. Could you send your patch proposal?
>=20

Here is mine, only compiled, not tested yet.

All credits for Stephen for doing the analysis of course :)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index c4c60e9..fbe77ad 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -780,12 +780,37 @@ static void rt_do_flush(int process_context)
 #define FRACT_BITS 3
 #define ONE (1UL << FRACT_BITS)
=20
+static unsigned long compute_length(struct rtable *head)
+{
+	struct rtable *rth, *aux;
+	unsigned long length =3D 0;
+
+	for (rth =3D head; rth !=3D NULL; rth =3D rth->u.dst.rt_next) {
+		/*
+		 * We ignore items having same hash inputs
+		 * so that entries for different QOS
+		 * levels, and other non-hash input
+		 * attributes don't unfairly skew
+		 * the length computation
+		 */
+		for (aux =3D head; ;aux =3D aux->u.dst.rt_next) {
+			if (aux =3D=3D rth) {
+				length +=3D ONE;
+				break;
+			}
+			if (compare_hash_inputs(&aux->fl, &rth->fl))
+				break;
+		}
+	}
+	return length;
+}
+
 static void rt_check_expire(void)
 {
 	static unsigned int rover;
 	unsigned int i =3D rover, goal;
 	struct rtable *rth, **rthp;
-	unsigned long length =3D 0, samples =3D 0;
+	unsigned long length, samples =3D 0;
 	unsigned long sum =3D 0, sum2 =3D 0;
 	u64 mult;
=20
@@ -795,7 +820,6 @@ static void rt_check_expire(void)
 	goal =3D (unsigned int)mult;
 	if (goal > rt_hash_mask)
 		goal =3D rt_hash_mask + 1;
-	length =3D 0;
 	for (; goal > 0; goal--) {
 		unsigned long tmo =3D ip_rt_gc_timeout;
=20
@@ -821,29 +845,11 @@ static void rt_check_expire(void)
 				if (time_before_eq(jiffies, rth->u.dst.expires)) {
 					tmo >>=3D 1;
 					rthp =3D &rth->u.dst.rt_next;
-					/*
-					 * Only bump our length if the hash
-					 * inputs on entries n and n+1 are not
-					 * the same, we only count entries on
-					 * a chain with equal hash inputs once
-					 * so that entries for different QOS
-					 * levels, and other non-hash input
-					 * attributes don't unfairly skew
-					 * the length computation
-					 */
-					if ((*rthp =3D=3D NULL) ||
-					    !compare_hash_inputs(&(*rthp)->fl,
-								 &rth->fl))
-						length +=3D ONE;
 					continue;
 				}
 			} else if (!rt_may_expire(rth, tmo, ip_rt_gc_timeout)) {
 				tmo >>=3D 1;
 				rthp =3D &rth->u.dst.rt_next;
-				if ((*rthp =3D=3D NULL) ||
-				    !compare_hash_inputs(&(*rthp)->fl,
-							 &rth->fl))
-					length +=3D ONE;
 				continue;
 			}
=20
@@ -851,6 +857,7 @@ static void rt_check_expire(void)
 			*rthp =3D rth->u.dst.rt_next;
 			rt_free(rth);
 		}
+		length =3D compute_length(rt_hash_table[i].chain);
 		spin_unlock_bh(rt_hash_lock_addr(i));
 		sum +=3D length;
 		sum2 +=3D length*length;
@@ -1068,7 +1075,6 @@ out:	return 0;
 static int rt_intern_hash(unsigned hash, struct rtable *rt, struct rta=
ble **rp)
 {
 	struct rtable	*rth, **rthp;
-	struct rtable	*rthi;
 	unsigned long	now;
 	struct rtable *cand, **candp;
 	u32 		min_score;
@@ -1088,7 +1094,6 @@ restart:
 	}
=20
 	rthp =3D &rt_hash_table[hash].chain;
-	rthi =3D NULL;
=20
 	spin_lock_bh(rt_hash_lock_addr(hash));
 	while ((rth =3D *rthp) !=3D NULL) {
@@ -1134,17 +1139,6 @@ restart:
 		chain_length++;
=20
 		rthp =3D &rth->u.dst.rt_next;
-
-		/*
-		 * check to see if the next entry in the chain
-		 * contains the same hash input values as rt.  If it does
-		 * This is where we will insert into the list, instead of
-		 * at the head.  This groups entries that differ by aspects not
-		 * relvant to the hash function together, which we use to adjust
-		 * our chain length
-		 */
-		if (*rthp && compare_hash_inputs(&(*rthp)->fl, &rt->fl))
-			rthi =3D rth;
 	}
=20
 	if (cand) {
@@ -1205,10 +1199,7 @@ restart:
 		}
 	}
=20
-	if (rthi)
-		rt->u.dst.rt_next =3D rthi->u.dst.rt_next;
-	else
-		rt->u.dst.rt_next =3D rt_hash_table[hash].chain;
+	rt->u.dst.rt_next =3D rt_hash_table[hash].chain;
=20
 #if RT_CACHE_DEBUG >=3D 2
 	if (rt->u.dst.rt_next) {
@@ -1224,10 +1215,7 @@ restart:
 	 * previous writes to rt are comitted to memory
 	 * before making rt visible to other CPUS.
 	 */
-	if (rthi)
-		rcu_assign_pointer(rthi->u.dst.rt_next, rt);
-	else
-		rcu_assign_pointer(rt_hash_table[hash].chain, rt);
+	rcu_assign_pointer(rt_hash_table[hash].chain, rt);
=20
 	spin_unlock_bh(rt_hash_lock_addr(hash));
 	*rp =3D rt;

