From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] netfilter: conntrack: death_by_timeout() fix
Date: Fri, 19 Jun 2009 00:46:11 +0200
Message-ID: <4A3AC3B3.2030002@gmail.com>
References: <20090615.050449.144947903.davem@davemloft.net> <20090616091538.GA4184@elte.hu> <20090616.034752.226811527.davem@davemloft.net> <20090616105304.GA3579@elte.hu> <20090616122415.GA16630@elte.hu> <20090617092152.GA17449@elte.hu> <4A38C2F3.3000009@gmail.com> <20090617110803.GA10175@elte.hu> <20090618052356.GA18722@elte.hu> <4A39D778.9020607@cosmosbay.com> <4A3A0D45.8090806@trash.net> <4A3A5599.4080906@trash.net> <4A3A6143.3040607@gmail.com> <4A3A66CC.4090205@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53059 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758565AbZFRWrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 18:47:03 -0400
In-Reply-To: <4A3A66CC.4090205@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy a =E9crit :
> Eric Dumazet wrote:
>> In my own analysis, I found death_by_timeout() might be problematic,
>> with RCU and lockless lookups.
>>
>> static void death_by_timeout(unsigned long ul_conntrack)
>> {
>>         struct nf_conn *ct =3D (void *)ul_conntrack;
>>
>>         if (!test_bit(IPS_DYING_BIT, &ct->status) &&
>>             unlikely(nf_conntrack_event(IPCT_DESTROY, ct) < 0)) {
>>                 /* destroy event was not delivered */
>>                 nf_ct_delete_from_lists(ct);
>> << HERE >>
>>
>>                 nf_ct_insert_dying_list(ct);
>>                 return;
>>         }
>>         set_bit(IPS_DYING_BIT, &ct->status);
>>         nf_ct_delete_from_lists(ct);
>>         nf_ct_put(ct);
>> }
>>
>>
>> We delete ct from a list and insert it in a new list.
>>
>> I believe a reader could "*catch*" ct while doing a lookup and miss
>> the end
>> of its chain. (nulls algo check the null value at the end of lookup
>> and can
>> decide to restart the lookup if the null value is not the expected o=
ne)
>>
>> We need to change nf_conntrack_init_net() and use a different "null"
>> value,
>> guaranteed not being used in regular lists
>=20
> Good catch. This is a new bug, but it shouldn't matter in this case
> since nf_conntrack_event() can't fail unless you have a userspace
> listener that makes use of reliable delivery, which I think hasn't
> even been released yet.
>=20
>> Patch follows :
>=20
> Looks good. If you send me a Signed-off-by: I'll already apply it.

Sure, here it is.

Thank you

[PATCH] netfilter: conntrack: death_by_timeout() fix

death_by_timeout() might delete a conntrack from hash list
and insert it in dying list.

 nf_ct_delete_from_lists(ct);
 nf_ct_insert_dying_list(ct);

I believe a (lockless) reader could *catch* ct while doing a lookup=20
and miss the end of its chain.
(nulls lookup algo must check the null value at the end of lookup and
should restart if the null value is not the expected one.
cf Documentation/RCU/rculist_nulls.txt for details)

We need to change nf_conntrack_init_net() and use a different "null" va=
lue,
guaranteed not being used in regular lists. Choose very large values, s=
ince
hash table uses [0..size-1] null values.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>
Acked-by: Patrick McHardy <kaber@trash.net>
---

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_connt=
rack_core.c
index 5f72b94..5276a2d 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1267,13 +1267,19 @@ err_cache:
 	return ret;
 }
=20
+/*
+ * We need to use special "null" values, not used in hash table
+ */
+#define UNCONFIRMED_NULLS_VAL	((1<<30)+0)
+#define DYING_NULLS_VAL		((1<<30)+1)
+
 static int nf_conntrack_init_net(struct net *net)
 {
 	int ret;
=20
 	atomic_set(&net->ct.count, 0);
-	INIT_HLIST_NULLS_HEAD(&net->ct.unconfirmed, 0);
-	INIT_HLIST_NULLS_HEAD(&net->ct.dying, 0);
+	INIT_HLIST_NULLS_HEAD(&net->ct.unconfirmed, UNCONFIRMED_NULLS_VAL);
+	INIT_HLIST_NULLS_HEAD(&net->ct.dying, DYING_NULLS_VAL);
 	net->ct.stat =3D alloc_percpu(struct ip_conntrack_stat);
 	if (!net->ct.stat) {
 		ret =3D -ENOMEM;

