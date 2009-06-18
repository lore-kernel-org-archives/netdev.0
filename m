From: Patrick McHardy <kaber@trash.net>
Subject: Re: [bug] __nf_ct_refresh_acct(): WARNING: at lib/list_debug.c:30
 __list_add+0x7d/0xad()
Date: Thu, 18 Jun 2009 11:47:49 +0200
Message-ID: <4A3A0D45.8090806@trash.net>
References: <20090615.050449.144947903.davem@davemloft.net> <20090616091538.GA4184@elte.hu> <20090616.034752.226811527.davem@davemloft.net> <20090616105304.GA3579@elte.hu> <20090616122415.GA16630@elte.hu> <20090617092152.GA17449@elte.hu> <4A38C2F3.3000009@gmail.com> <20090617110803.GA10175@elte.hu> <20090618052356.GA18722@elte.hu> <4A39D778.9020607@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57816 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752035AbZFRJru (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 05:47:50 -0400
In-Reply-To: <4A39D778.9020607@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Ingo Molnar a =E9crit :
>> * Ingo Molnar <mingo@elte.hu> wrote:
>>
>>>> IPS_CONFIRMED_BIT is set under nf_conntrack_lock (in=20
>>>> __nf_conntrack_confirm()), we probably want to add a=20
>>>> synchronisation under ct->lock as well, or=20
>>>> __nf_ct_refresh_acct() could set ct->timeout.expires to=20
>>>> extra_jiffies, while a different cpu could confirm the=20
>>>> conntrack.
>>>>
>>>> Following patch as RFC
>>> A quick test suggests that it seems to works here - thanks Eric!
>> a test-box still triggered this crash overnight:
>>
>> [  252.433471] ------------[ cut here ]------------
>> [  252.436031] WARNING: at lib/list_debug.c:30 __list_add+0x95/0xa0(=
)
>> [  252.436031] Hardware name: System Product Name
>> [  252.436031] list_add corruption. prev->next should be next (ffff8=
8003fa1d460), but was ffffffff82e560a0. (prev=3Dffff880003b458c0).
>> [  252.436031] Pid: 7348, comm: ssh Tainted: G        W  2.6.30-tip =
#54604
>> [  252.436031] Call Trace:
>> [  252.436031]  [<ffffffff8149eda5>] ? __list_add+0x95/0xa0
>> [  252.436031]  [<ffffffff8105c79b>] warn_slowpath_common+0x7b/0xd0
>> [  252.436031]  [<ffffffff8105c851>] warn_slowpath_fmt+0x41/0x50
>> [  252.436031]  [<ffffffff8149eda5>] __list_add+0x95/0xa0
>> [  252.436031]  [<ffffffff8106937e>] internal_add_timer+0x9e/0xf0
>> [  252.436031]  [<ffffffff8106a5ef>] mod_timer+0x10f/0x160
>> [  252.436031]  [<ffffffff8106a658>] add_timer+0x18/0x20
>> [  252.436031]  [<ffffffff81f6e42a>] __nf_conntrack_confirm+0x1da/0x=
3c0
>> [  252.436031]  [<ffffffff81fdb8dd>] ipv4_confirm+0xfd/0x160
>> [  252.436031]  [<ffffffff81f6a130>] nf_iterate+0x70/0xd0
>> [  252.436031]  [<ffffffff81f99180>] ? ip_finish_output+0x0/0x380
>> [  252.436031]  [<ffffffff81f6a4c4>] nf_hook_slow+0xe4/0x160
>> [  252.436031]  [<ffffffff81f99180>] ? ip_finish_output+0x0/0x380
>> [  252.436031]  [<ffffffff81f995f5>] ip_output+0xf5/0x110
>> [  252.436031]  [<ffffffff81f96b05>] ip_local_out+0x25/0x40
>> [  252.436031]  [<ffffffff81f97434>] ip_queue_xmit+0x224/0x420
>> [  252.436031]  [<ffffffff81111118>] ? __kmalloc_node_track_caller+0=
xd8/0x1f0
>> [  252.436031]  [<ffffffff8108df19>] ? trace_hardirqs_on_caller+0x29=
/0x1f0
>> [  252.436031]  [<ffffffff81fae0dd>] tcp_transmit_skb+0x50d/0x7e0
>> [  252.436031]  [<ffffffff81faf547>] tcp_connect+0x3c7/0x500
>> [  252.436031]  [<ffffffff81fb4693>] tcp_v4_connect+0x433/0x520
>> [  252.436031]  [<ffffffff81fc446f>] inet_stream_connect+0x22f/0x2d0
>> [  252.436031]  [<ffffffff81118719>] ? fget_light+0x19/0x110
>> [  252.436031]  [<ffffffff81f294b8>] sys_connect+0xb8/0xd0
>> [  252.436031]  [<ffffffff8100ccf9>] ? retint_swapgs+0x13/0x1b
>> [  252.436031]  [<ffffffff8108df19>] ? trace_hardirqs_on_caller+0x29=
/0x1f0
>> [  252.436031]  [<ffffffff8217a49f>] ? trace_hardirqs_on_thunk+0x3a/=
0x3f
>> [  252.436031]  [<ffffffff8100c252>] system_call_fastpath+0x16/0x1b
>> [  252.436031] ---[ end trace a7919e7f17c0a73d ]---
>>
>> With your patch (repeated below) applied. Is Patrick's alternative=20
>> patch supposed to fix something that yours does not?
>=20
> Hmm, not really, Patrick patch should fix same problem, but without e=
xtra locking
> as mine.
>=20
> This new stack trace is somewhat different, as corruption is detected=
 in the add_timer()
> call in __nf_conntrack_confirm()
>=20
> So there is another problem. CCed Pablo Neira Ayuso who added some st=
uff
> in netfilter and timeout logic recently.

That timeout logic shouldn't be relevant in this case, its only
activated when netlink event delivery is used, a userspace process
is actually listening and it has the socket marked for reliable
delivery.

I think its still the same problem, the detection is just noticed
at a different point.

