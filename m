From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [bug] __nf_ct_refresh_acct(): WARNING: at lib/list_debug.c:30
 __list_add+0x7d/0xad()
Date: Thu, 18 Jun 2009 17:46:11 +0200
Message-ID: <4A3A6143.3040607@gmail.com>
References: <20090615.050449.144947903.davem@davemloft.net> <20090616091538.GA4184@elte.hu> <20090616.034752.226811527.davem@davemloft.net> <20090616105304.GA3579@elte.hu> <20090616122415.GA16630@elte.hu> <20090617092152.GA17449@elte.hu> <4A38C2F3.3000009@gmail.com> <20090617110803.GA10175@elte.hu> <20090618052356.GA18722@elte.hu> <4A39D778.9020607@cosmosbay.com> <4A3A0D45.8090806@trash.net> <4A3A5599.4080906@trash.net>
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
Received: from gw1.cosmosbay.com ([212.99.114.194]:42475 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752638AbZFRPqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 11:46:35 -0400
In-Reply-To: <4A3A5599.4080906@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy a =E9crit :
> Patrick McHardy wrote:
>> Eric Dumazet wrote:
>>>> a test-box still triggered this crash overnight:
>>>>
>>>> [  252.433471] ------------[ cut here ]------------
>>>> [  252.436031] WARNING: at lib/list_debug.c:30 __list_add+0x95/0xa=
0()
>>>> ...
>>>> With your patch (repeated below) applied. Is Patrick's alternative
>>>> patch supposed to fix something that yours does not?
>>>
>>> Hmm, not really, Patrick patch should fix same problem, but without
>>> extra locking
>>> as mine.
>>>
>>> This new stack trace is somewhat different, as corruption is detect=
ed
>>> in the add_timer()
>>> call in __nf_conntrack_confirm()
>>>
>>> So there is another problem. CCed Pablo Neira Ayuso who added some =
stuff
>>> in netfilter and timeout logic recently.
>>
>> That timeout logic shouldn't be relevant in this case, its only
>> activated when netlink event delivery is used, a userspace process
>> is actually listening and it has the socket marked for reliable
>> delivery.
>>
>> I think its still the same problem, the detection is just noticed
>> at a different point.
>=20
> I can't find anything wrong with the conntrack timer use itself.
> Since its the timer base that is corrupted, its possible that
> something else is using timers incorrectly and conntrack just
> happens to hit the problem afterwards, but it seems rather
> unlikely since the first backtrace originated in a network driver,
> the second one in the socket layer.
>=20
> But I've noticed a different problem, the lockless lookup might
> incorrectly return an conntrack entry that is supposed to be
> invisible. This can happen because we only check for equal tuples
> and !atomic_inc_not_zero(refcnt), but the conntrack can be removed
> from the lists and still have references to it. It should never
> have an active timer at that point however, so all following
> mod_timer_pending() calls *should* do nothing unless I'm missing
> something.
>=20
> Ingo, could you please try whether this patch (combined with the
> last one) makes any difference? Enabling CONFIG_NETFILTER_DEBUG
> could also help.
>=20
>=20

Interesting !

In my own analysis, I found death_by_timeout() might be problematic,
with RCU and lockless lookups.

static void death_by_timeout(unsigned long ul_conntrack)
{
        struct nf_conn *ct =3D (void *)ul_conntrack;

        if (!test_bit(IPS_DYING_BIT, &ct->status) &&
            unlikely(nf_conntrack_event(IPCT_DESTROY, ct) < 0)) {
                /* destroy event was not delivered */
                nf_ct_delete_from_lists(ct);
<< HERE >>

                nf_ct_insert_dying_list(ct);
                return;
        }
        set_bit(IPS_DYING_BIT, &ct->status);
        nf_ct_delete_from_lists(ct);
        nf_ct_put(ct);
}


We delete ct from a list and insert it in a new list.

I believe a reader could "*catch*" ct while doing a lookup and miss the=
 end
of its chain. (nulls algo check the null value at the end of lookup and=
 can
decide to restart the lookup if the null value is not the expected one)

We need to change nf_conntrack_init_net() and use a different "null" va=
lue,
guaranteed not being used in regular lists

Patch follows :

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
