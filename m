From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Thu, 28 Aug 2008 02:40:02 +0200
Message-ID: <48B5F3E2.2000909@cosmosbay.com>
References: <48B5DE9F.4010000@cosmosbay.com>	<20080827.161504.183610665.davem@davemloft.net>	<48B5E6A3.6@cosmosbay.com> <20080827.164535.150037784.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020606000005070400040702"
Cc: andi@firstfloor.org, davej@redhat.com, netdev@vger.kernel.org,
	j.w.r.degoede@hhs.nl
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp27.orange.fr ([80.12.242.95]:39009 "EHLO smtp27.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753289AbYH1AkM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 20:40:12 -0400
In-Reply-To: <20080827.164535.150037784.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020606000005070400040702
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Thu, 28 Aug 2008 01:43:31 +0200
>=20
>> David Miller a =E9crit :
>>> From: Eric Dumazet <dada1@cosmosbay.com>
>>> Date: Thu, 28 Aug 2008 01:09:19 +0200
>>>
>>>> Not really, I suspect commit (a7ab4b501f9b8a9dc4d5cee542db67b6ccd108=
8b [TCPv4]: Improve BH latency in /proc/net/tcp) is responsible for longe=
r delays.
>>>> Note that its rather old :
>>>  ...
>>>> We used to disable bh once, while reading the table. This sucked.
>>>>
>>>> In case machine is handling trafic, we now are preemptable by softir=
qs
>>>> while reading /proc/net/tcp. Thats a good thing.
>>> Yes, that would account for it, good spotting.
>>>
>>>> By the way, I find Andi patch usefull. Same thing could be done for =
/proc/net/rt_cache.
>>> Fair enough.  If you can cook up a quick rt_cache patch I'll toss it =
and
>>> Andi's patch into net-next so it can cook for a while.
>> Well, first patch I would like to submit is about letting netlink bein=
g able to be faster than /proc/net/tcp again :)
>=20
> Andi just posted a very similar patch :)

No problem :)

Here is the patch for /proc/net/rt_cache (legacy /proc and netlink interf=
ace)

Thank you

[PATCH] ip: speedup /proc/net/rt_cache handling

When scanning route cache hash table, we can avoid taking locks for empty=
 buckets.
Both /proc/net/rt_cache and NETLINK RTM_GETROUTE interface are taken into=
 account.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------020606000005070400040702
Content-Type: text/plain;
 name="route.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="route.patch"

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index cca921e..71598f6 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -282,6 +282,8 @@ static struct rtable *rt_cache_get_first(struct seq_file *seq)
 	struct rtable *r = NULL;
 
 	for (st->bucket = rt_hash_mask; st->bucket >= 0; --st->bucket) {
+		if (!rt_hash_table[st->bucket].chain)
+			continue;
 		rcu_read_lock_bh();
 		r = rcu_dereference(rt_hash_table[st->bucket].chain);
 		while (r) {
@@ -299,11 +301,14 @@ static struct rtable *__rt_cache_get_next(struct seq_file *seq,
 					  struct rtable *r)
 {
 	struct rt_cache_iter_state *st = seq->private;
+
 	r = r->u.dst.rt_next;
 	while (!r) {
 		rcu_read_unlock_bh();
-		if (--st->bucket < 0)
-			break;
+		do {
+			if (--st->bucket < 0)
+				return NULL;
+		} while (!rt_hash_table[st->bucket].chain);
 		rcu_read_lock_bh();
 		r = rt_hash_table[st->bucket].chain;
 	}
@@ -2840,7 +2845,9 @@ int ip_rt_dump(struct sk_buff *skb,  struct netlink_callback *cb)
 	if (s_h < 0)
 		s_h = 0;
 	s_idx = idx = cb->args[1];
-	for (h = s_h; h <= rt_hash_mask; h++) {
+	for (h = s_h; h <= rt_hash_mask; h++, s_idx = 0) {
+		if (!rt_hash_table[h].chain)
+			continue;
 		rcu_read_lock_bh();
 		for (rt = rcu_dereference(rt_hash_table[h].chain), idx = 0; rt;
 		     rt = rcu_dereference(rt->u.dst.rt_next), idx++) {
@@ -2859,7 +2866,6 @@ int ip_rt_dump(struct sk_buff *skb,  struct netlink_callback *cb)
 			dst_release(xchg(&skb->dst, NULL));
 		}
 		rcu_read_unlock_bh();
-		s_idx = 0;
 	}
 
 done:

--------------020606000005070400040702--


