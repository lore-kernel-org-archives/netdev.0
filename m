From: Patrick McHardy <kaber@trash.net>
Subject: Re: [bug] __nf_ct_refresh_acct(): WARNING: at lib/list_debug.c:30
 __list_add+0x7d/0xad()
Date: Thu, 18 Jun 2009 16:56:25 +0200
Message-ID: <4A3A5599.4080906@trash.net>
References: <20090615.050449.144947903.davem@davemloft.net> <20090616091538.GA4184@elte.hu> <20090616.034752.226811527.davem@davemloft.net> <20090616105304.GA3579@elte.hu> <20090616122415.GA16630@elte.hu> <20090617092152.GA17449@elte.hu> <4A38C2F3.3000009@gmail.com> <20090617110803.GA10175@elte.hu> <20090618052356.GA18722@elte.hu> <4A39D778.9020607@cosmosbay.com> <4A3A0D45.8090806@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080308000508060707010501"
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:32854 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755071AbZFRO4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 10:56:24 -0400
In-Reply-To: <4A3A0D45.8090806@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080308000508060707010501
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Eric Dumazet wrote:
>>> a test-box still triggered this crash overnight:
>>>
>>> [  252.433471] ------------[ cut here ]------------
>>> [  252.436031] WARNING: at lib/list_debug.c:30 __list_add+0x95/0xa0()
>>> ...
>>> With your patch (repeated below) applied. Is Patrick's alternative 
>>> patch supposed to fix something that yours does not?
>>
>> Hmm, not really, Patrick patch should fix same problem, but without 
>> extra locking
>> as mine.
>>
>> This new stack trace is somewhat different, as corruption is detected 
>> in the add_timer()
>> call in __nf_conntrack_confirm()
>>
>> So there is another problem. CCed Pablo Neira Ayuso who added some stuff
>> in netfilter and timeout logic recently.
> 
> That timeout logic shouldn't be relevant in this case, its only
> activated when netlink event delivery is used, a userspace process
> is actually listening and it has the socket marked for reliable
> delivery.
> 
> I think its still the same problem, the detection is just noticed
> at a different point.

I can't find anything wrong with the conntrack timer use itself.
Since its the timer base that is corrupted, its possible that
something else is using timers incorrectly and conntrack just
happens to hit the problem afterwards, but it seems rather
unlikely since the first backtrace originated in a network driver,
the second one in the socket layer.

But I've noticed a different problem, the lockless lookup might
incorrectly return an conntrack entry that is supposed to be
invisible. This can happen because we only check for equal tuples
and !atomic_inc_not_zero(refcnt), but the conntrack can be removed
from the lists and still have references to it. It should never
have an active timer at that point however, so all following
mod_timer_pending() calls *should* do nothing unless I'm missing
something.

Ingo, could you please try whether this patch (combined with the
last one) makes any difference? Enabling CONFIG_NETFILTER_DEBUG
could also help.



--------------080308000508060707010501
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 5f72b94..ce17a69 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -335,7 +335,8 @@ begin:
 	h = __nf_conntrack_find(net, tuple);
 	if (h) {
 		ct = nf_ct_tuplehash_to_ctrack(h);
-		if (unlikely(!atomic_inc_not_zero(&ct->ct_general.use)))
+		if (unlikely(nf_ct_is_dying(ct) ||
+			     !atomic_inc_not_zero(&ct->ct_general.use)))
 			h = NULL;
 		else {
 			if (unlikely(!nf_ct_tuple_equal(tuple, &h->tuple))) {
@@ -503,7 +504,8 @@ static noinline int early_drop(struct net *net, unsigned int hash)
 			cnt++;
 		}
 
-		if (ct && unlikely(!atomic_inc_not_zero(&ct->ct_general.use)))
+		if (ct && unlikely(nf_ct_is_dying(ct) ||
+				   !atomic_inc_not_zero(&ct->ct_general.use)))
 			ct = NULL;
 		if (ct || cnt >= NF_CT_EVICTION_RANGE)
 			break;

--------------080308000508060707010501--
