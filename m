From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [bug] __nf_ct_refresh_acct(): WARNING: at lib/list_debug.c:30
 __list_add+0x7d/0xad()
Date: Wed, 17 Jun 2009 12:18:27 +0200
Message-ID: <4A38C2F3.3000009@gmail.com>
References: <20090615.050449.144947903.davem@davemloft.net> <20090616091538.GA4184@elte.hu> <20090616.034752.226811527.davem@davemloft.net> <20090616105304.GA3579@elte.hu> <20090616122415.GA16630@elte.hu> <20090617092152.GA17449@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35971 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756877AbZFQKSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 06:18:50 -0400
In-Reply-To: <20090617092152.GA17449@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar a =E9crit :
> here's another bug i triggered today - some sort of memory/list=20
> corruption going on in the timer code. Then i turned on debugobjects=20
> and got a pretty specific assert in the TCP code:
>=20
> [   48.320340] ------------[ cut here ]------------
> [   48.324031] WARNING: at lib/list_debug.c:30 __list_add+0x7d/0xad()
> [   48.324031] Hardware name: System Product Name
> [   48.324031] list_add corruption. prev->next should be next (ffffff=
ff81fe2280), but was ffff88003f901440. (prev=3Dffff880002a9bcf0).
> [   48.324031] Modules linked in:
> [   48.324031] Pid: 0, comm: swapper Tainted: G        W  2.6.30-tip =
#54394
> [   48.324031] Call Trace:
> [   48.324031]  <IRQ>  [<ffffffff812b3098>] ? __list_add+0x7d/0xad
> [   48.324031]  [<ffffffff810581a2>] warn_slowpath_common+0x8d/0xd0
> [   48.324031]  [<ffffffff81058272>] warn_slowpath_fmt+0x50/0x66
> [   48.324031]  [<ffffffff812b3098>] __list_add+0x7d/0xad
> [   48.324031]  [<ffffffff810650c3>] internal_add_timer+0xd1/0xe7
> [   48.324031]  [<ffffffff81065797>] __mod_timer+0x107/0x139
> [   48.324031]  [<ffffffff810658cb>] mod_timer_pending+0x28/0x3e
> [   48.324031]  [<ffffffff8163d5d3>] __nf_ct_refresh_acct+0x71/0xf9
> [   48.324031]  [<ffffffff81643d92>] tcp_packet+0x60c/0x6a2
> [   48.324031]  [<ffffffff8163da60>] ? nf_conntrack_find_get+0xb7/0xe=
f
> [   48.324031]  [<ffffffff8163d9a9>] ? nf_conntrack_find_get+0x0/0xef
> [   48.324031]  [<ffffffff8163f0fd>] nf_conntrack_in+0x3a3/0x534
> [   48.324031]  [<ffffffff81665a5c>] ? ip_rcv_finish+0x0/0x3bc
> [   48.324031]  [<ffffffff816a48b1>] ipv4_conntrack_in+0x34/0x4a
> [   48.324031]  [<ffffffff8163a79f>] nf_iterate+0x5d/0xb1
> [   48.324031]  [<ffffffff81012cd6>] ? ftrace_call+0x5/0x2b
> [   48.324031]  [<ffffffff81665a5c>] ? ip_rcv_finish+0x0/0x3bc
> [   48.324031]  [<ffffffff8163a897>] nf_hook_slow+0xa4/0x133
> [   48.324031]  [<ffffffff81665a5c>] ? ip_rcv_finish+0x0/0x3bc
> [   48.324031]  [<ffffffff816660c6>] ip_rcv+0x2ae/0x30d
> [   48.324031]  [<ffffffff816139f0>] ? netpoll_rx+0x14/0x9d
> [   48.324031]  [<ffffffff81613e2a>] netif_receive_skb+0x3b1/0x402
> [   48.324031]  [<ffffffff81613bf4>] ? netif_receive_skb+0x17b/0x402
> [   48.324031]  [<ffffffff81607661>] ? skb_pull+0xd/0x59
> [   48.324031]  [<ffffffff8162a0c5>] ? eth_type_trans+0x48/0x104
> [   48.324031]  [<ffffffff814cfc21>] nv_rx_process_optimized+0x15a/0x=
227
> [   48.324031]  [<ffffffff814d3326>] nv_napi_poll+0x2a9/0x2cd
> [   48.324031]  [<ffffffff81611aeb>] net_rx_action+0xd1/0x249
> [   48.324031]  [<ffffffff81611c02>] ? net_rx_action+0x1e8/0x249
> [   48.324031]  [<ffffffff8105f758>] __do_softirq+0xcb/0x1bb
> [   48.324031]  [<ffffffff8101420c>] call_softirq+0x1c/0x30
> [   48.324031]  [<ffffffff810164cb>] do_softirq+0x5f/0xd7
> [   48.324031]  [<ffffffff8105f0a4>] irq_exit+0x66/0xb9
> [   48.324031]  [<ffffffff817c1fc3>] do_IRQ+0xbb/0xe8
> [   48.324031]  [<ffffffff81def140>] ? early_idt_handler+0x0/0x71
> [   48.324031]  [<ffffffff810139d3>] ret_from_intr+0x0/0x16
> [   48.324031]  <EOI>  [<ffffffff8101c938>] ? default_idle+0x59/0x9d
> [   48.324031]  [<ffffffff81088399>] ? trace_hardirqs_on+0x20/0x36
> [   48.324031]  [<ffffffff810301a9>] ? native_safe_halt+0xb/0xd
> [   48.324031]  [<ffffffff810301a7>] ? native_safe_halt+0x9/0xd
> [   48.324031]  [<ffffffff8101c93d>] ? default_idle+0x5e/0x9d
> [   48.324031]  [<ffffffff810b9cbd>] ? stop_critical_timings+0x3d/0x5=
4
> [   48.324031]  [<ffffffff81011feb>] ? cpu_idle+0xbe/0x107
> [   48.324031]  [<ffffffff81def140>] ? early_idt_handler+0x0/0x71
> [   48.324031]  [<ffffffff8177f135>] ? rest_init+0x79/0x8f
> [   48.324031]  [<ffffffff81def140>] ? early_idt_handler+0x0/0x71
> [   48.324031]  [<ffffffff81deff5d>] ? start_kernel+0x2d8/0x2f3
> [   48.324031]  [<ffffffff81def140>] ? early_idt_handler+0x0/0x71
> [   48.324031]  [<ffffffff81def2a4>] ? x86_64_start_reservations+0x8f=
/0xaa
> [   48.324031]  [<ffffffff81def000>] ? __init_begin+0x0/0x140
> [   48.324031]  [<ffffffff81def3c3>] ? x86_64_start_kernel+0x104/0x12=
7
> [   48.324031] ---[ end trace 5a5d197966b56a31 ]---
> modprobe: FATAL: Could not load /lib/modules/2.6.30-tip/modules.dep: =
No such file or directory
>=20
> this too is a new pattern. Config and full bootlog attached.
>=20
> Unfortunately it's not clearly reproducible - needs some networking=20
> load to trigger, and sometimes the symptoms are just a straight hang=20
> (with no console messages) - so not very bisection friendly.
>=20
> 	Ingo
>=20

commit 65cb9fda32be613216f601a330b311c3bd7a8436 seems the origin...
(and/or 440f0d588555892601cfe511728a0fc0c8204063)

commit 65cb9fda32be613216f601a330b311c3bd7a8436
Author: Patrick McHardy <kaber@trash.net>
Date:   Sat Jun 13 12:21:49 2009 +0200

    netfilter: nf_conntrack: use mod_timer_pending() for conntrack refr=
esh

    Use mod_timer_pending() instead of atomic sequence of del_timer()/
    add_timer(). mod_timer_pending() does not rearm an inactive timer,
    so we don't need the conntrack lock anymore to make sure we don't
    accidentally rearm a timer of a conntrack which is in the process
    of being destroyed.

    With this change, we don't need to take the global lock anymore at =
all,
    counter updates can be performed under the per-conntrack lock.

    Signed-off-by: Patrick McHardy <kaber@trash.net>



IPS_CONFIRMED_BIT is set under nf_conntrack_lock (in __nf_conntrack_con=
firm()),
we probably want to add a synchronisation under ct->lock as well,
or __nf_ct_refresh_acct() could set ct->timeout.expires to extra_jiffie=
s,
while a different cpu could confirm the conntrack.

=46ollowing patch as RFC

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_connt=
rack_core.c
index 5f72b94..24034c4 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -408,6 +408,7 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	NF_CT_ASSERT(!nf_ct_is_confirmed(ct));
 	pr_debug("Confirming conntrack %p\n", ct);
=20
+	spin_lock_bh(&ct->lock);
 	spin_lock_bh(&nf_conntrack_lock);
=20
 	/* See if there's one in the list already, including reverse:
@@ -435,6 +436,7 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	set_bit(IPS_CONFIRMED_BIT, &ct->status);
 	NF_CT_STAT_INC(net, insert);
 	spin_unlock_bh(&nf_conntrack_lock);
+	spin_unlock_bh(&ct->lock);
 	help =3D nfct_help(ct);
 	if (help && help->helper)
 		nf_conntrack_event_cache(IPCT_HELPER, ct);
@@ -446,6 +448,7 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 out:
 	NF_CT_STAT_INC(net, insert_failed);
 	spin_unlock_bh(&nf_conntrack_lock);
+	spin_unlock_bh(&ct->lock);
 	return NF_DROP;
 }
 EXPORT_SYMBOL_GPL(__nf_conntrack_confirm);
@@ -848,6 +851,7 @@ void __nf_ct_refresh_acct(struct nf_conn *ct,
 	NF_CT_ASSERT(ct->timeout.data =3D=3D (unsigned long)ct);
 	NF_CT_ASSERT(skb);
=20
+	spin_lock_bh(&ct->lock);
 	/* Only update if this is not a fixed timeout */
 	if (test_bit(IPS_FIXED_TIMEOUT_BIT, &ct->status))
 		goto acct;
@@ -871,13 +875,12 @@ acct:
=20
 		acct =3D nf_conn_acct_find(ct);
 		if (acct) {
-			spin_lock_bh(&ct->lock);
 			acct[CTINFO2DIR(ctinfo)].packets++;
 			acct[CTINFO2DIR(ctinfo)].bytes +=3D
 				skb->len - skb_network_offset(skb);
-			spin_unlock_bh(&ct->lock);
 		}
 	}
+	spin_unlock_bh(&ct->lock);
 }
 EXPORT_SYMBOL_GPL(__nf_ct_refresh_acct);
=20
