From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [bug] __nf_ct_refresh_acct(): WARNING: at lib/list_debug.c:30
 __list_add+0x7d/0xad()
Date: Thu, 18 Jun 2009 07:58:16 +0200
Message-ID: <4A39D778.9020607@cosmosbay.com>
References: <20090615.050449.144947903.davem@davemloft.net> <20090616091538.GA4184@elte.hu> <20090616.034752.226811527.davem@davemloft.net> <20090616105304.GA3579@elte.hu> <20090616122415.GA16630@elte.hu> <20090617092152.GA17449@elte.hu> <4A38C2F3.3000009@gmail.com> <20090617110803.GA10175@elte.hu> <20090618052356.GA18722@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47626 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751776AbZFRF7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 01:59:01 -0400
In-Reply-To: <20090618052356.GA18722@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar a =E9crit :
> * Ingo Molnar <mingo@elte.hu> wrote:
>=20
>>> IPS_CONFIRMED_BIT is set under nf_conntrack_lock (in=20
>>> __nf_conntrack_confirm()), we probably want to add a=20
>>> synchronisation under ct->lock as well, or=20
>>> __nf_ct_refresh_acct() could set ct->timeout.expires to=20
>>> extra_jiffies, while a different cpu could confirm the=20
>>> conntrack.
>>>
>>> Following patch as RFC
>> A quick test suggests that it seems to works here - thanks Eric!
>=20
> a test-box still triggered this crash overnight:
>=20
> [  252.433471] ------------[ cut here ]------------
> [  252.436031] WARNING: at lib/list_debug.c:30 __list_add+0x95/0xa0()
> [  252.436031] Hardware name: System Product Name
> [  252.436031] list_add corruption. prev->next should be next (ffff88=
003fa1d460), but was ffffffff82e560a0. (prev=3Dffff880003b458c0).
> [  252.436031] Pid: 7348, comm: ssh Tainted: G        W  2.6.30-tip #=
54604
> [  252.436031] Call Trace:
> [  252.436031]  [<ffffffff8149eda5>] ? __list_add+0x95/0xa0
> [  252.436031]  [<ffffffff8105c79b>] warn_slowpath_common+0x7b/0xd0
> [  252.436031]  [<ffffffff8105c851>] warn_slowpath_fmt+0x41/0x50
> [  252.436031]  [<ffffffff8149eda5>] __list_add+0x95/0xa0
> [  252.436031]  [<ffffffff8106937e>] internal_add_timer+0x9e/0xf0
> [  252.436031]  [<ffffffff8106a5ef>] mod_timer+0x10f/0x160
> [  252.436031]  [<ffffffff8106a658>] add_timer+0x18/0x20
> [  252.436031]  [<ffffffff81f6e42a>] __nf_conntrack_confirm+0x1da/0x3=
c0
> [  252.436031]  [<ffffffff81fdb8dd>] ipv4_confirm+0xfd/0x160
> [  252.436031]  [<ffffffff81f6a130>] nf_iterate+0x70/0xd0
> [  252.436031]  [<ffffffff81f99180>] ? ip_finish_output+0x0/0x380
> [  252.436031]  [<ffffffff81f6a4c4>] nf_hook_slow+0xe4/0x160
> [  252.436031]  [<ffffffff81f99180>] ? ip_finish_output+0x0/0x380
> [  252.436031]  [<ffffffff81f995f5>] ip_output+0xf5/0x110
> [  252.436031]  [<ffffffff81f96b05>] ip_local_out+0x25/0x40
> [  252.436031]  [<ffffffff81f97434>] ip_queue_xmit+0x224/0x420
> [  252.436031]  [<ffffffff81111118>] ? __kmalloc_node_track_caller+0x=
d8/0x1f0
> [  252.436031]  [<ffffffff8108df19>] ? trace_hardirqs_on_caller+0x29/=
0x1f0
> [  252.436031]  [<ffffffff81fae0dd>] tcp_transmit_skb+0x50d/0x7e0
> [  252.436031]  [<ffffffff81faf547>] tcp_connect+0x3c7/0x500
> [  252.436031]  [<ffffffff81fb4693>] tcp_v4_connect+0x433/0x520
> [  252.436031]  [<ffffffff81fc446f>] inet_stream_connect+0x22f/0x2d0
> [  252.436031]  [<ffffffff81118719>] ? fget_light+0x19/0x110
> [  252.436031]  [<ffffffff81f294b8>] sys_connect+0xb8/0xd0
> [  252.436031]  [<ffffffff8100ccf9>] ? retint_swapgs+0x13/0x1b
> [  252.436031]  [<ffffffff8108df19>] ? trace_hardirqs_on_caller+0x29/=
0x1f0
> [  252.436031]  [<ffffffff8217a49f>] ? trace_hardirqs_on_thunk+0x3a/0=
x3f
> [  252.436031]  [<ffffffff8100c252>] system_call_fastpath+0x16/0x1b
> [  252.436031] ---[ end trace a7919e7f17c0a73d ]---
>=20
> With your patch (repeated below) applied. Is Patrick's alternative=20
> patch supposed to fix something that yours does not?

Hmm, not really, Patrick patch should fix same problem, but without ext=
ra locking
as mine.

This new stack trace is somewhat different, as corruption is detected i=
n the add_timer()
call in __nf_conntrack_confirm()

So there is another problem. CCed Pablo Neira Ayuso who added some stuf=
f
in netfilter and timeout logic recently.

commit dd7669a92c6066b2b31bae7e04cd787092920883
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Sat Jun 13 12:30:52 2009 +0200

    netfilter: conntrack: optional reliable conntrack event delivery

    This patch improves ctnetlink event reliability if one broadcast
    listener has set the NETLINK_BROADCAST_ERROR socket option.

    The logic is the following: if an event delivery fails, we keep
    the undelivered events in the missed event cache. Once the next
    packet arrives, we add the new events (if any) to the missed
    events in the cache and we try a new delivery, and so on. Thus,
    if ctnetlink fails to deliver an event, we try to deliver them
    once we see a new packet. Therefore, we may lose state
    transitions but the userspace process gets in sync at some point.

    At worst case, if no events were delivered to userspace, we make
    sure that destroy events are successfully delivered. Basically,
    if ctnetlink fails to deliver the destroy event, we remove the
    conntrack entry from the hashes and we insert them in the dying
    list, which contains inactive entries. Then, the conntrack timer
    is added with an extra grace timeout of random32() % 15 seconds
    to trigger the event again (this grace timeout is tunable via
    /proc). The use of a limited random timeout value allows
    distributing the "destroy" resends, thus, avoiding accumulating
    lots "destroy" events at the same time. Event delivery may
    re-order but we can identify them by means of the tuple plus
    the conntrack ID.

    The maximum number of conntrack entries (active or inactive) is
    still handled by nf_conntrack_max. Thus, we may start dropping
    packets at some point if we accumulate a lot of inactive conntrack
    entries that did not successfully report the destroy event to
    userspace.

    During my stress tests consisting of setting a very small buffer
    of 2048 bytes for conntrackd and the NETLINK_BROADCAST_ERROR socket
    flag, and generating lots of very small connections, I noticed
    very few destroy entries on the fly waiting to be resend.

    A simple way to test this patch consist of creating a lot of
    entries, set a very small Netlink buffer in conntrackd (+ a patch
    which is not in the git tree to set the BROADCAST_ERROR flag)
    and invoke `conntrack -F'.

    For expectations, no changes are introduced in this patch.
    Currently, event delivery is only done for new expectations (no
    events from expectation expiration, removal and confirmation).
    In that case, they need a per-expectation event cache to implement
    the same idea that is exposed in this patch.

    This patch can be useful to provide reliable flow-accouting. We
    still have to add a new conntrack extension to store the creation
    and destroy time.

    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>


>=20
> 	Ingo
>=20
> ------------------>
> From 16b663c1ac11c31d05a0768eb9aeba743b4f49ed Mon Sep 17 00:00:00 200=
1
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 17 Jun 2009 12:18:27 +0200
> Subject: [PATCH] net: Fix: __nf_ct_refresh_acct(): WARNING: at lib/li=
st_debug.c:30 __list_add+0x7d/0xad()
> MIME-Version: 1.0
> Content-Type: text/plain; charset=3Dutf-8
> Content-Transfer-Encoding: 8bit
>=20
> Ingo Molnar a =E9crit :
>> here's another bug i triggered today - some sort of memory/list
>> corruption going on in the timer code. Then i turned on debugobjects
>> and got a pretty specific assert in the TCP code:
>>
>> [   48.320340] ------------[ cut here ]------------
>> [   48.324031] WARNING: at lib/list_debug.c:30 __list_add+0x7d/0xad(=
)
>> [   48.324031] Hardware name: System Product Name
>> [   48.324031] list_add corruption. prev->next should be next (fffff=
fff81fe2280), but was ffff88003f901440. (prev=3Dffff880002a9bcf0).
>> [   48.324031] Modules linked in:
>> [   48.324031] Pid: 0, comm: swapper Tainted: G        W  2.6.30-tip=
 #54394
>> [   48.324031] Call Trace:
>> [   48.324031]  <IRQ>  [<ffffffff812b3098>] ? __list_add+0x7d/0xad
>> [   48.324031]  [<ffffffff810581a2>] warn_slowpath_common+0x8d/0xd0
>> [   48.324031]  [<ffffffff81058272>] warn_slowpath_fmt+0x50/0x66
>> [   48.324031]  [<ffffffff812b3098>] __list_add+0x7d/0xad
>> [   48.324031]  [<ffffffff810650c3>] internal_add_timer+0xd1/0xe7
>> [   48.324031]  [<ffffffff81065797>] __mod_timer+0x107/0x139
>> [   48.324031]  [<ffffffff810658cb>] mod_timer_pending+0x28/0x3e
>> [   48.324031]  [<ffffffff8163d5d3>] __nf_ct_refresh_acct+0x71/0xf9
>> [   48.324031]  [<ffffffff81643d92>] tcp_packet+0x60c/0x6a2
>> [   48.324031]  [<ffffffff8163da60>] ? nf_conntrack_find_get+0xb7/0x=
ef
>> [   48.324031]  [<ffffffff8163d9a9>] ? nf_conntrack_find_get+0x0/0xe=
f
>> [   48.324031]  [<ffffffff8163f0fd>] nf_conntrack_in+0x3a3/0x534
>> [   48.324031]  [<ffffffff81665a5c>] ? ip_rcv_finish+0x0/0x3bc
>> [   48.324031]  [<ffffffff816a48b1>] ipv4_conntrack_in+0x34/0x4a
>> [   48.324031]  [<ffffffff8163a79f>] nf_iterate+0x5d/0xb1
>> [   48.324031]  [<ffffffff81012cd6>] ? ftrace_call+0x5/0x2b
>> [   48.324031]  [<ffffffff81665a5c>] ? ip_rcv_finish+0x0/0x3bc
>> [   48.324031]  [<ffffffff8163a897>] nf_hook_slow+0xa4/0x133
>> [   48.324031]  [<ffffffff81665a5c>] ? ip_rcv_finish+0x0/0x3bc
>> [   48.324031]  [<ffffffff816660c6>] ip_rcv+0x2ae/0x30d
>> [   48.324031]  [<ffffffff816139f0>] ? netpoll_rx+0x14/0x9d
>> [   48.324031]  [<ffffffff81613e2a>] netif_receive_skb+0x3b1/0x402
>> [   48.324031]  [<ffffffff81613bf4>] ? netif_receive_skb+0x17b/0x402
>> [   48.324031]  [<ffffffff81607661>] ? skb_pull+0xd/0x59
>> [   48.324031]  [<ffffffff8162a0c5>] ? eth_type_trans+0x48/0x104
>> [   48.324031]  [<ffffffff814cfc21>] nv_rx_process_optimized+0x15a/0=
x227
>> [   48.324031]  [<ffffffff814d3326>] nv_napi_poll+0x2a9/0x2cd
>> [   48.324031]  [<ffffffff81611aeb>] net_rx_action+0xd1/0x249
>> [   48.324031]  [<ffffffff81611c02>] ? net_rx_action+0x1e8/0x249
>> [   48.324031]  [<ffffffff8105f758>] __do_softirq+0xcb/0x1bb
>> [   48.324031]  [<ffffffff8101420c>] call_softirq+0x1c/0x30
>> [   48.324031]  [<ffffffff810164cb>] do_softirq+0x5f/0xd7
>> [   48.324031]  [<ffffffff8105f0a4>] irq_exit+0x66/0xb9
>> [   48.324031]  [<ffffffff817c1fc3>] do_IRQ+0xbb/0xe8
>> [   48.324031]  [<ffffffff81def140>] ? early_idt_handler+0x0/0x71
>> [   48.324031]  [<ffffffff810139d3>] ret_from_intr+0x0/0x16
>> [   48.324031]  <EOI>  [<ffffffff8101c938>] ? default_idle+0x59/0x9d
>> [   48.324031]  [<ffffffff81088399>] ? trace_hardirqs_on+0x20/0x36
>> [   48.324031]  [<ffffffff810301a9>] ? native_safe_halt+0xb/0xd
>> [   48.324031]  [<ffffffff810301a7>] ? native_safe_halt+0x9/0xd
>> [   48.324031]  [<ffffffff8101c93d>] ? default_idle+0x5e/0x9d
>> [   48.324031]  [<ffffffff810b9cbd>] ? stop_critical_timings+0x3d/0x=
54
>> [   48.324031]  [<ffffffff81011feb>] ? cpu_idle+0xbe/0x107
>> [   48.324031]  [<ffffffff81def140>] ? early_idt_handler+0x0/0x71
>> [   48.324031]  [<ffffffff8177f135>] ? rest_init+0x79/0x8f
>> [   48.324031]  [<ffffffff81def140>] ? early_idt_handler+0x0/0x71
>> [   48.324031]  [<ffffffff81deff5d>] ? start_kernel+0x2d8/0x2f3
>> [   48.324031]  [<ffffffff81def140>] ? early_idt_handler+0x0/0x71
>> [   48.324031]  [<ffffffff81def2a4>] ? x86_64_start_reservations+0x8=
f/0xaa
>> [   48.324031]  [<ffffffff81def000>] ? __init_begin+0x0/0x140
>> [   48.324031]  [<ffffffff81def3c3>] ? x86_64_start_kernel+0x104/0x1=
27
>> [   48.324031] ---[ end trace 5a5d197966b56a31 ]---
>> modprobe: FATAL: Could not load /lib/modules/2.6.30-tip/modules.dep:=
 No such file or directory
>>
>> this too is a new pattern. Config and full bootlog attached.
>>
>> Unfortunately it's not clearly reproducible - needs some networking
>> load to trigger, and sometimes the symptoms are just a straight hang
>> (with no console messages) - so not very bisection friendly.
>>
>> 	Ingo
>>
>=20
> commit 65cb9fda32be613216f601a330b311c3bd7a8436 seems the origin...
> (and/or 440f0d588555892601cfe511728a0fc0c8204063)
>=20
> commit 65cb9fda32be613216f601a330b311c3bd7a8436
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Sat Jun 13 12:21:49 2009 +0200
>=20
>     netfilter: nf_conntrack: use mod_timer_pending() for conntrack re=
fresh
>=20
>     Use mod_timer_pending() instead of atomic sequence of del_timer()=
/
>     add_timer(). mod_timer_pending() does not rearm an inactive timer=
,
>     so we don't need the conntrack lock anymore to make sure we don't
>     accidentally rearm a timer of a conntrack which is in the process
>     of being destroyed.
>=20
>     With this change, we don't need to take the global lock anymore a=
t all,
>     counter updates can be performed under the per-conntrack lock.
>=20
>     Signed-off-by: Patrick McHardy <kaber@trash.net>
> Cc: David Miller <davem@davemloft.net>
> Cc: torvalds@linux-foundation.org
> Cc: akpm@linux-foundation.org
> Cc: Patrick McHardy <kaber@trash.net>
> LKML-Reference: <4A38C2F3.3000009@gmail.com>
> Signed-off-by: Ingo Molnar <mingo@elte.hu>
> IPS_CONFIRMED_BIT is set under nf_conntrack_lock (in __nf_conntrack_c=
onfirm()),
> we probably want to add a synchronisation under ct->lock as well,
> or __nf_ct_refresh_acct() could set ct->timeout.expires to extra_jiff=
ies,
> while a different cpu could confirm the conntrack.
>=20
> Following patch as RFC
> ---
>  net/netfilter/nf_conntrack_core.c |    7 +++++--
>  1 files changed, 5 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_con=
ntrack_core.c
> index 5f72b94..24034c4 100644
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -408,6 +408,7 @@ __nf_conntrack_confirm(struct sk_buff *skb)
>  	NF_CT_ASSERT(!nf_ct_is_confirmed(ct));
>  	pr_debug("Confirming conntrack %p\n", ct);
> =20
> +	spin_lock_bh(&ct->lock);
>  	spin_lock_bh(&nf_conntrack_lock);
> =20
>  	/* See if there's one in the list already, including reverse:
> @@ -435,6 +436,7 @@ __nf_conntrack_confirm(struct sk_buff *skb)
>  	set_bit(IPS_CONFIRMED_BIT, &ct->status);
>  	NF_CT_STAT_INC(net, insert);
>  	spin_unlock_bh(&nf_conntrack_lock);
> +	spin_unlock_bh(&ct->lock);
>  	help =3D nfct_help(ct);
>  	if (help && help->helper)
>  		nf_conntrack_event_cache(IPCT_HELPER, ct);
> @@ -446,6 +448,7 @@ __nf_conntrack_confirm(struct sk_buff *skb)
>  out:
>  	NF_CT_STAT_INC(net, insert_failed);
>  	spin_unlock_bh(&nf_conntrack_lock);
> +	spin_unlock_bh(&ct->lock);
>  	return NF_DROP;
>  }
>  EXPORT_SYMBOL_GPL(__nf_conntrack_confirm);
> @@ -848,6 +851,7 @@ void __nf_ct_refresh_acct(struct nf_conn *ct,
>  	NF_CT_ASSERT(ct->timeout.data =3D=3D (unsigned long)ct);
>  	NF_CT_ASSERT(skb);
> =20
> +	spin_lock_bh(&ct->lock);
>  	/* Only update if this is not a fixed timeout */
>  	if (test_bit(IPS_FIXED_TIMEOUT_BIT, &ct->status))
>  		goto acct;
> @@ -871,13 +875,12 @@ acct:
> =20
>  		acct =3D nf_conn_acct_find(ct);
>  		if (acct) {
> -			spin_lock_bh(&ct->lock);
>  			acct[CTINFO2DIR(ctinfo)].packets++;
>  			acct[CTINFO2DIR(ctinfo)].bytes +=3D
>  				skb->len - skb_network_offset(skb);
> -			spin_unlock_bh(&ct->lock);
>  		}
>  	}
> +	spin_unlock_bh(&ct->lock);
>  }
>  EXPORT_SYMBOL_GPL(__nf_ct_refresh_acct);
> =20

