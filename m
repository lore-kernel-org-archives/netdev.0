From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Fw: [Bug 13339] New: rtable leak in ipv4/route.c
Date: Tue, 19 May 2009 20:47:54 +0200
Message-ID: <4A12FEDA.7040806@cosmosbay.com>
References: <20090519123417.GA7376@ff.dom.local> <4A12D10D.3000504@cosmosbay.com> <20090519162048.GB28034@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>, lav@yar.ru,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45566 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752558AbZESSsL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 14:48:11 -0400
In-Reply-To: <20090519162048.GB28034@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman a =E9crit :
> On Tue, May 19, 2009 at 05:32:29PM +0200, Eric Dumazet wrote:
>> Jarek Poplawski a =E9crit :
>>> On 19-05-2009 04:35, Stephen Hemminger wrote:
>>>> Begin forwarded message:
>>>>
>>>> Date: Mon, 18 May 2009 14:10:20 GMT
>>>> From: bugzilla-daemon@bugzilla.kernel.org
>>>> To: shemminger@linux-foundation.org
>>>> Subject: [Bug 13339] New: rtable leak in ipv4/route.c
>>>>
>>>>
>>>> http://bugzilla.kernel.org/show_bug.cgi?id=3D13339
>>> ...
>>>> 2.6.29 patch has introduced flexible route cache rebuilding. Unfor=
tunately the
>>>> patch has at least one critical flaw, and another problem.
>>>>
>>>> rt_intern_hash calculates rthi pointer, which is later used for ne=
w entry
>>>> insertion. The same loop calculates cand pointer which is used to =
clean the
>>>> list. If the pointers are the same, rtable leak occurs, as first t=
he cand is
>>>> removed then the new entry is appended to it.
>>>>
>>>> This leak leads to unregister_netdevice problem (usage count > 0).
>>>>
>>>> Another problem of the patch is that it tries to insert the entrie=
s in certain
>>>> order, to facilitate counting of entries distinct by all but QoS p=
arameters.
>>>> Unfortunately, referencing an existing rtable entry moves it to li=
st beginning,
>>>> to speed up further lookups, so the carefully built order is destr=
oyed.
>> We could change rt_check_expire() to be smarter and handle any order=
 in chains.
>>
>> This would let rt_intern_hash() be simpler.
>>
>> As its a more performance critical path, all would be good :)
>>
>>>> For the first problem the simplest patch it to set rthi=3D0 when r=
thi=3D=3Dcand, but
>>>> it will also destroy the ordering.
>>> I think fixing this bug fast is more important than this
>>> ordering or counting. Could you send your patch proposal?
>>>
>=20
> I was thinking something along these lines (also completely untested)=
=2E  The
> extra check in rt_intern hash prevents us from identifying a 'group l=
eader' that
> is about to be deleted, and sets rthi to point at the group leader ra=
ther than
> the last entry in the group as it previously did, which we then mark =
with the
> new flag in the dst_entry (updating it on rt_free of course).  This l=
ets us
> identify the boundaries of a group, so when we do a move to front her=
uistic, we
> can move the entire group rather than just the single entry.    I pre=
fer this to
> Erics approach since, even though rt_check_expire isn't in a performa=
nce
> critical path, the addition of the extra list search when the list is=
 unordered
> makes rt_check_expire run in O(n^2) rather than O(n), which I think w=
ill have a
> significant impact on high traffic systems.  Since the ordered list c=
reation was
> done at almost zero performance cost in rt_intern_hash, I'd like to k=
eep it if
> at all possible.
>=20
> There is of course a shortcomming in my patch in that it doesn't actu=
ally do
> anything currently with DST_GRPLDR other than set/clear it appropriat=
ely, I've
> yet to identify where the route cache move to front heruistic is impl=
emented.
> If someone could show me where that is, I'd be happy to finish this p=
atch.
>=20

O(n^2) ? Not exactly ...

N * (Y + x)  instead of N * (Y),  where x <=3D Y/100, and we can make x=
 being 0
in fact with proper prefetching.

Real cost is bringing into CPU cache the information needed, by two
orders of magnitude. (one cache line miss : more than 200 cycles,
and we need at least two cache lines per rtable.)

Adding 'group' notion to dst entries is overengineering an already
too complex ipv4/route.c file, that is almost unreadable these days,
since even you can not spot the point where we move the entry at chain
front.

Hint : search for /* Put it first */ in rt_intern_hash()

Moving whole group in front would defeat the purpose of move, actually,
since rank in chain is used to decay the timeout in garbage collector.
(search for tmo >>=3D 1; )


Here is is a revised patch, doing the length computation inside
the loop, while cpu is prefeching next entry into its cache.

BTW, we actually have another bug, since length is set to 0 at the wron=
g place
(before the for (; goal > 0; goal--) loop)

We must of course reset length to 0 for each chain.

All credits for Alexander V. Lukyanov for doing the analysis of course =
:)


 net/ipv4/route.c |   57 ++++++++++++++-------------------------------
 1 files changed, 18 insertions(+), 39 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index c4c60e9..769f72e 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -784,7 +784,7 @@ static void rt_check_expire(void)
 {
 	static unsigned int rover;
 	unsigned int i =3D rover, goal;
-	struct rtable *rth, **rthp;
+	struct rtable *rth, *aux, **rthp;
 	unsigned long length =3D 0, samples =3D 0;
 	unsigned long sum =3D 0, sum2 =3D 0;
 	u64 mult;
@@ -795,7 +795,6 @@ static void rt_check_expire(void)
 	goal =3D (unsigned int)mult;
 	if (goal > rt_hash_mask)
 		goal =3D rt_hash_mask + 1;
-	length =3D 0;
 	for (; goal > 0; goal--) {
 		unsigned long tmo =3D ip_rt_gc_timeout;
=20
@@ -809,8 +808,10 @@ static void rt_check_expire(void)
=20
 		if (*rthp =3D=3D NULL)
 			continue;
+		length =3D 0;
 		spin_lock_bh(rt_hash_lock_addr(i));
 		while ((rth =3D *rthp) !=3D NULL) {
+			prefetch(rth->u.dst.rt_next);
 			if (rt_is_expired(rth)) {
 				*rthp =3D rth->u.dst.rt_next;
 				rt_free(rth);
@@ -819,33 +820,30 @@ static void rt_check_expire(void)
 			if (rth->u.dst.expires) {
 				/* Entry is expired even if it is in use */
 				if (time_before_eq(jiffies, rth->u.dst.expires)) {
+nofree:
 					tmo >>=3D 1;
 					rthp =3D &rth->u.dst.rt_next;
 					/*
-					 * Only bump our length if the hash
-					 * inputs on entries n and n+1 are not
-					 * the same, we only count entries on
+					 * We only count entries on
 					 * a chain with equal hash inputs once
 					 * so that entries for different QOS
 					 * levels, and other non-hash input
 					 * attributes don't unfairly skew
 					 * the length computation
 					 */
-					if ((*rthp =3D=3D NULL) ||
-					    !compare_hash_inputs(&(*rthp)->fl,
-								 &rth->fl))
-						length +=3D ONE;
+					for (aux =3D rt_hash_table[i].chain;;) {
+						if (aux =3D=3D rth) {
+							length +=3D ONE;
+							break;
+						}
+						if (compare_hash_inputs(&aux->fl, &rth->fl))
+							break;
+						aux =3D aux->u.dst.rt_next;
+					}
 					continue;
 				}
-			} else if (!rt_may_expire(rth, tmo, ip_rt_gc_timeout)) {
-				tmo >>=3D 1;
-				rthp =3D &rth->u.dst.rt_next;
-				if ((*rthp =3D=3D NULL) ||
-				    !compare_hash_inputs(&(*rthp)->fl,
-							 &rth->fl))
-					length +=3D ONE;
-				continue;
-			}
+			} else if (!rt_may_expire(rth, tmo, ip_rt_gc_timeout))
+				goto nofree;
=20
 			/* Cleanup aged off entries. */
 			*rthp =3D rth->u.dst.rt_next;
@@ -1068,7 +1066,6 @@ out:	return 0;
 static int rt_intern_hash(unsigned hash, struct rtable *rt, struct rta=
ble **rp)
 {
 	struct rtable	*rth, **rthp;
-	struct rtable	*rthi;
 	unsigned long	now;
 	struct rtable *cand, **candp;
 	u32 		min_score;
@@ -1088,7 +1085,6 @@ restart:
 	}
=20
 	rthp =3D &rt_hash_table[hash].chain;
-	rthi =3D NULL;
=20
 	spin_lock_bh(rt_hash_lock_addr(hash));
 	while ((rth =3D *rthp) !=3D NULL) {
@@ -1134,17 +1130,6 @@ restart:
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
@@ -1205,10 +1190,7 @@ restart:
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
@@ -1224,10 +1206,7 @@ restart:
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

