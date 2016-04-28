From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 00/17] net: snmp: update SNMP methods
Date: Thu, 28 Apr 2016 05:00:54 -0700
Message-ID: <1461844854.5535.93.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461800683-25034-1-git-send-email-edumazet@google.com>
	 <5721E05B.1030603@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:35177 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752049AbcD1MA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 08:00:58 -0400
Received: by mail-qg0-f45.google.com with SMTP id f74so28657473qge.2
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 05:00:57 -0700 (PDT)
In-Reply-To: <5721E05B.1030603@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-04-28 at 12:05 +0200, Nicolas Dichtel wrote:
> Le 28/04/2016 01:44, Eric Dumazet a =C3=A9crit :
> > In the old days (before linux-3.0), SNMP counters were duplicated,
> > one set for user context, and anther one for BH context.
> >=20
> > After commit 8f0ea0fe3a03 ("snmp: reduce percpu needs by 50%")
> > we have a single copy, and what really matters is preemption being
> > enabled or disabled, since we use this_cpu_inc() or __this_cpu_inc(=
)
> > respectively.
> >=20
> > This patch series kills the obsolete STATS_USER() helpers,
> > and rename all XXX_BH() helpers to __XXX() ones, to more
> > closely match conventions used to update per cpu variables.
> >=20
> > This is probably going to hurt maintainers job for a while,
> > since cherry-picks will not be clean, but this had to be
> > cleaned at one point. I am so sorry guys.
> After this series, I have the following warning (the corresponding .c=
onfig is
> enclosed):
>=20
> [    5.328714] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> [    5.329644] [ INFO: inconsistent lock state ]
> [    5.330552] 4.6.0-rc5+ #396 Not tainted
> [    5.331372] ---------------------------------
> [    5.332213] inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
> [    5.332213] swapper/7/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
> [    5.332213]  (&syncp->seq#3){+.?...}, at: [<c13658b5>] ip_rcv+0x45=
/0x418
> [    5.332213] {SOFTIRQ-ON-W} state was registered at:
> [    5.332213]   [<c10833ce>] __lock_acquire+0x2d4/0xcf3
> [    5.332213]   [<c108424f>] lock_acquire+0x138/0x174
> [    5.332213]   [<c136871a>] u64_stats_update_begin+0x1a/0x1f
> [    5.332213]   [<c136a49d>] ip_output+0x4a/0x100
> [    5.332213]   [<c1368529>] dst_output+0x25/0x2b
> [    5.332213]   [<c1369e2a>] ip_local_out+0x21/0x26
> [    5.332213]   [<c136ac82>] ip_send_skb+0x12/0x7e
> [    5.332213]   [<c138b60c>] udp_send_skb+0x16f/0x1c3
> [    5.332213]   [<c138bce7>] udp_sendmsg+0x63a/0x805
> [    5.332213]   [<c1394ddf>] inet_sendmsg+0x2b/0x52
> [    5.332213]   [<c1321379>] sock_sendmsg_nosec+0xd/0x19
> [    5.332213]   [<c13213a3>] sock_sendmsg+0x1e/0x22
> [    5.332213]   [<c132205d>] ___sys_sendmsg+0x14c/0x1c5
> [    5.332213]   [<c1322521>] __sys_sendmsg+0x2d/0x49
> [    5.332213]   [<c1322c36>] SYSC_socketcall+0x30f/0x3a2
> [    5.332213]   [<c1322cf0>] SyS_socketcall+0xe/0x10
> [    5.332213]   [<c10032a8>] do_fast_syscall_32+0x9b/0xdb
> [    5.332213]   [<c1402aeb>] sysenter_past_esp+0x4c/0x7f
> [    5.332213] irq event stamp: 59546
> [    5.332213] hardirqs last  enabled at (59546): [<c10a3e17>]
> read_seqcount_begin.constprop.23+0x5b/0x74
> [    5.332213] hardirqs last disabled at (59545): [<c10a3dd3>]
> read_seqcount_begin.constprop.23+0x17/0x74
> [    5.332213] softirqs last  enabled at (59536): [<c1053922>]
> _local_bh_enable+0x39/0x3b
> [    5.332213] softirqs last disabled at (59537): [<c102130a>]
> do_softirq_own_stack+0x27/0x2d
> [    5.332213]
> [    5.332213] other info that might help us debug this:
> [    5.332213]  Possible unsafe locking scenario:
> [    5.332213]
> [    5.332213]        CPU0
> [    5.332213]        ----
> [    5.332213]   lock(&syncp->seq#3);
> [    5.332213]   <Interrupt>
> [    5.332213]     lock(&syncp->seq#3);
> [    5.332213]
> [    5.332213]  *** DEADLOCK ***
> [    5.332213]
> [    5.332213] 1 lock held by swapper/7/0:
> [    5.332213]  #0:  (rcu_read_lock){......}, at: [<c1331060>]
> rcu_lock_acquire+0x0/0x1c
> [    5.332213]
> [    5.332213] stack backtrace:
> [    5.332213] CPU: 7 PID: 0 Comm: swapper/7 Not tainted 4.6.0-rc5+ #=
396
> [    5.332213] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
> [    5.332213]  00000000 00200002 f25f5d34 c11fe7a9 f24b00c0 c1a7ab60=
 f25f5d60
> c10f2b61
> [    5.332213]  c15846f4 c1584587 c158454f c158456e c1584578 c15853d0=
 00000004
> f24b05c8
> [    5.332213]  00000000 f25f5d88 c108301c 00000004 00000006 00000000=
 c1082ad4
> f24b00c0
> [    5.332213] Call Trace:
> [    5.332213]  [<c11fe7a9>] dump_stack+0x72/0xa5
> [    5.332213]  [<c10f2b61>] print_usage_bug+0x181/0x18e
> [    5.332213]  [<c108301c>] mark_lock+0xf8/0x1d6
> [    5.332213]  [<c1082ad4>] ? check_usage_backwards+0x87/0x87
> [    5.332213]  [<c1083363>] __lock_acquire+0x269/0xcf3
> [    5.332213]  [<c10817ec>] ? __lock_is_held+0x24/0x3f
> [    5.332213]  [<c1082f42>] ? mark_lock+0x1e/0x1d6
> [    5.332213]  [<c108340f>] ? __lock_acquire+0x315/0xcf3
> [    5.332213]  [<c1082f42>] ? mark_lock+0x1e/0x1d6
> [    5.332213]  [<c108424f>] lock_acquire+0x138/0x174
> [    5.332213]  [<c13658b5>] ? ip_rcv+0x45/0x418
> [    5.332213]  [<c1364fb3>] u64_stats_update_begin+0x1a/0x1f
> [    5.332213]  [<c13658b5>] ? ip_rcv+0x45/0x418
> [    5.332213]  [<c13658b5>] ip_rcv+0x45/0x418
> [    5.332213]  [<c10817ec>] ? __lock_is_held+0x24/0x3f
> [    5.332213]  [<c1335d08>] __netif_receive_skb_core+0x534/0x5c8
> [    5.332213]  [<c1084266>] ? lock_acquire+0x14f/0x174
> [    5.332213]  [<c1331060>] ? dev_get_by_index_rcu+0x57/0x57
> [    5.332213]  [<c1213ffc>] ? debug_smp_processor_id+0x12/0x16
> [    5.332213]  [<c1335de4>] __netif_receive_skb+0x48/0x56
> [    5.332213]  [<c1335f77>] netif_receive_skb_internal+0x51/0x88
> [    5.332213]  [<c1336bd2>] napi_gro_receive+0x100/0x172
> [    5.332213]  [<f8339e56>] cp_rx_poll+0x214/0x2e2 [8139cp]
> [    5.332213]  [<c133669b>] net_rx_action+0xc5/0x1fe
> [    5.332213]  [<c1053cb9>] __do_softirq+0x189/0x391
> [    5.332213]  [<c1053b30>] ? perf_trace_irq_handler_entry+0xb8/0xb8
> [    5.332213]  [<c102130a>] do_softirq_own_stack+0x27/0x2d
> [    5.332213]  <IRQ>  [<c10540a8>] irq_exit+0x3c/0x88
> [    5.332213]  [<c1020beb>] do_IRQ+0xc9/0xdf
> [    5.332213]  [<c14032b8>] common_interrupt+0x38/0x40
> [    5.332213]  [<c102007b>] ? do_bounds+0x233/0x238
> [    5.332213]  [<c10800e0>] ? proc_sched_show_task+0x354/0x475
> [    5.332213]  [<c10423b8>] ? native_safe_halt+0x5/0x7
> [    5.332213]  [<c1026e1d>] default_idle+0x1e/0x30
> [    5.332213]  [<c10272e7>] arch_cpu_idle+0x9/0xb
> [    5.332213]  [<c107d365>] default_idle_call+0x1d/0x1f
> [    5.332213]  [<c107d4d4>] cpu_startup_entry+0x16d/0x285
> [    5.332213]  [<c1038ee3>] start_secondary+0x144/0x149
>=20

Hi Nicolas, thanks for testing.

Oh right, I shouldn't have changed the BH disabling of 64bit stats on
32bit arches, of course.

Can you double check this will fix the problem ? Thanks !

diff --git a/include/net/snmp.h b/include/net/snmp.h
index 6bdd255b2250..c9228ad7ee91 100644
--- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -166,9 +166,9 @@ struct linux_xfrm_mib {
=20
 #define SNMP_ADD_STATS64(mib, field, addend) 				\
 	do {								\
-		preempt_disable();					\
+		local_bh_disable();					\
 		__SNMP_ADD_STATS64(mib, field, addend);			\
-		preempt_enable();					\
+		local_bh_enable();				\
 	} while (0)
=20
 #define __SNMP_INC_STATS64(mib, field) SNMP_ADD_STATS64(mib, field, 1)
@@ -184,9 +184,9 @@ struct linux_xfrm_mib {
 	} while (0)
 #define SNMP_UPD_PO_STATS64(mib, basefield, addend)			\
 	do {								\
-		preempt_disable();					\
+		local_bh_disable();					\
 		__SNMP_UPD_PO_STATS64(mib, basefield, addend);		\
-		preempt_enable();					\
+		local_bh_enable();				\
 	} while (0)
 #else
 #define __SNMP_INC_STATS64(mib, field)		__SNMP_INC_STATS(mib, field)
