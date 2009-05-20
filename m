From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: fix rtable leak in net/ipv4/route.c
Date: Wed, 20 May 2009 08:14:28 +0200
Message-ID: <4A139FC4.7030309@cosmosbay.com>
References: <20090519162048.GB28034@hmsreliant.think-freely.org>	<4A12FEDA.7040806@cosmosbay.com>	<20090519192450.GF28034@hmsreliant.think-freely.org> <20090519.150517.62361946.davem@davemloft.net> <4A138CFE.5070901@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nhorman@tuxdriver.com, jarkao2@gmail.com, lav@yar.ru,
	shemminger@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37102 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751680AbZETGOn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 02:14:43 -0400
In-Reply-To: <4A138CFE.5070901@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> David Miller a =E9crit :
>> From: Neil Horman <nhorman@tuxdriver.com>
>> Date: Tue, 19 May 2009 15:24:50 -0400
>>
>>>> Moving whole group in front would defeat the purpose of move, actu=
ally,
>>>> since rank in chain is used to decay the timeout in garbage collec=
tor.
>>>> (search for tmo >>=3D 1; )
>>>>
>>> Argh, so the list is implicitly ordered by expiration time.  That
>>> really defeats the entire purpose of doing grouping in the ilst at
>>> all.  If thats the case, then I agree, its probably better to to
>>> take the additional visitation hit in in check_expire above than to
>>> try and preserve ordering.
>> Yes, this seems best.
>>
>> I was worried that somehow the ordering also influences lookups,
>> because the TOS bits don't go into the hash so I worried that it wou=
ld
>> be important that explicit TOS values appear before wildcard ones.
>> But it doesn't appear that this is an issue, we don't have wildcard
>> TOSs in the rtable entries, they are always explicit.
>>
>> So I would like to see an explicit final patch from Eric so we can g=
et
>> this fixed now.
>>
>=20
> I would like to split patches because we have two bugs indeed, and
> I prefer to get attention for both problems, I dont remember Neil ack=
nowledged
> the length computation problem.
>=20
> First and small patch, candidate for net-2.6 and stable (for 2.6.29) =
:
>=20

Then here is the patch on top on previous one.

Thanks to all

[PATCH] net: fix rtable leak in net/ipv4/route.c

Alexander V. Lukyanov found a regression in 2.6.29 and made a complete
analysis found in http://bugzilla.kernel.org/show_bug.cgi?id=3D13339
Quoted here because its a perfect one :

begin_of_quotation=20
 2.6.29 patch has introduced flexible route cache rebuilding. Unfortuna=
tely the
 patch has at least one critical flaw, and another problem.

 rt_intern_hash calculates rthi pointer, which is later used for new en=
try
 insertion. The same loop calculates cand pointer which is used to clea=
n the
 list. If the pointers are the same, rtable leak occurs, as first the c=
and is
 removed then the new entry is appended to it.

 This leak leads to unregister_netdevice problem (usage count > 0).

 Another problem of the patch is that it tries to insert the entries in=
 certain
 order, to facilitate counting of entries distinct by all but QoS param=
eters.
 Unfortunately, referencing an existing rtable entry moves it to list b=
eginning,
 to speed up further lookups, so the carefully built order is destroyed=
=2E

 For the first problem the simplest patch it to set rthi=3D0 when rthi=3D=
=3Dcand, but
 it will also destroy the ordering.
end_of_quotation


Problematic commit is 1080d709fb9d8cd4392f93476ee46a9d6ea05a5b
(net: implement emergency route cache rebulds when gc_elasticity is exc=
eeded)

Trying to keep dst_entries ordered is too complex and breaks the fact t=
hat
order should depend on the frequency of use for garbage collection.

A possible fix is to make rt_intern_hash() simpler, and only makes
rt_check_expire() a litle bit smarter, being able to cope with an arbit=
rary
entries order. The added loop is running on cache hot data, while cpu
is prefetching next object, so should be unnoticied.

Reported-and-analyzed-by: Alexander V. Lukyanov <lav@yar.ru>
Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 net/ipv4/route.c |   55 +++++++++++++--------------------------------
 1 files changed, 17 insertions(+), 38 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 869cf1c..28205e5 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -784,7 +784,7 @@ static void rt_check_expire(void)
 {
 	static unsigned int rover;
 	unsigned int i =3D rover, goal;
-	struct rtable *rth, **rthp;
+	struct rtable *rth, *aux, **rthp;
 	unsigned long samples =3D 0;
 	unsigned long sum =3D 0, sum2 =3D 0;
 	u64 mult;
@@ -812,6 +812,7 @@ static void rt_check_expire(void)
 		length =3D 0;
 		spin_lock_bh(rt_hash_lock_addr(i));
 		while ((rth =3D *rthp) !=3D NULL) {
+			prefetch(rth->u.dst.rt_next);
 			if (rt_is_expired(rth)) {
 				*rthp =3D rth->u.dst.rt_next;
 				rt_free(rth);
@@ -820,33 +821,30 @@ static void rt_check_expire(void)
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
@@ -1069,7 +1067,6 @@ out:	return 0;
 static int rt_intern_hash(unsigned hash, struct rtable *rt, struct rta=
ble **rp)
 {
 	struct rtable	*rth, **rthp;
-	struct rtable	*rthi;
 	unsigned long	now;
 	struct rtable *cand, **candp;
 	u32 		min_score;
@@ -1089,7 +1086,6 @@ restart:
 	}
=20
 	rthp =3D &rt_hash_table[hash].chain;
-	rthi =3D NULL;
=20
 	spin_lock_bh(rt_hash_lock_addr(hash));
 	while ((rth =3D *rthp) !=3D NULL) {
@@ -1135,17 +1131,6 @@ restart:
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
@@ -1206,10 +1191,7 @@ restart:
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
@@ -1225,10 +1207,7 @@ restart:
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

