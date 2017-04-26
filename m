From: Jakub Kicinski <kubakici@wp.pl>
Subject: GSO + changing TX queues == crash?
Date: Wed, 26 Apr 2017 11:35:55 -0700
Message-ID: <20170426113555.2c0055dc@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:34599 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936075AbdDZSg2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Apr 2017 14:36:28 -0400
Received: from unknown (HELO cakuba.netronome.com) (kubakici@wp.pl@[75.53.12.129])
          (envelope-sender <kubakici@wp.pl>)
          by smtp.wp.pl (WP-SMTPD) with ECDHE-RSA-AES256-GCM-SHA384 encrypted SMTP
          for <netdev@vger.kernel.org>; 26 Apr 2017 20:36:10 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

I'm seeing crashes with GSO on when changing the number of TX rings.  I
initially thought it was a nfp driver problem but I managed to
reproduce it with i40e now.

What I run on the nfp was iperf sending two dozen streams.  Then I run
this little script while 40Gbps is being sent:

bl() { 
	tc -s qdisc show dev p4p1 | \
		tail -$((MAX_TX*3)) | \
		grep backlog | \
		grep -v "backlog 0b"
}

while true
do 
	ethtool -L p4p1 tx 0

	a=$(bl | wc -l)
	echo down $a

	# there are 8 combined queues, we shouldn't see more backlog
	[ $a -gt 8 ] && break  
	
	sleep 2

	ethtool -L p4p1 tx 10

	echo up $(bl | wc -l)

	sleep 2
done

The idea is to catch when after reconfig more queues have backlog than
are configured.  Right after this script exits driver gets traffic on
queues which are down.  It usually reproduces within a minute, I run it
with tso on gso off and tso off gso off for 15 minutes and that didn't
crash.

i40e machine was running kernel 4.10, with the NFP driver I'm able to
reproduce on net-next all the way back to 3.16 (I haven't tried older).

FWIW the nfp driver is doing:

netif_carrier_off()
for enabled rings:
	disable_irq()
	napi_disable()
netif_tx_disable()

nfp's free_tx_bufs()

netif_set_real_num_tx_queues()

for enabled rings:
	napi_enable()
	enable_irq()
netif_tx_wake_all_queues()
nfp's read_link() # does netif_carrier_on()

I was entirely convinced that it's a driver problem, but the fact I
crashed the i40e made me worry :|

This is a crash from i40e, it takes a bit longer to kill it than the
nfp, maybe because it takes longer to reconfig:

[  461.822381] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
[  461.831229] IP: i40e_lan_xmit_frame+0xf1/0x1420 [i40e]
[  461.837045] PGD 0 
[  461.837046] 
[  461.841089] Oops: 0002 [#1] SMP
[  461.844665] Modules linked in: xfs nls_iso8859_1 ipmi_devintf ipt_MASQUERADE nf_nat_masquerade_ipv4 iptable_nat nf_nat_ipv4 nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xtc
[  461.924168]  fscache tg3 i40e ptp ahci pps_core libahci fjes
[  461.930595] CPU: 15 PID: 0 Comm: swapper/15 Not tainted 4.11.0-041100rc1-generic #201703051731
[  461.940340] Hardware name: Dell Inc. PowerEdge R730/072T6D, BIOS 2.3.4 11/08/2016
[  461.948823] task: ffffa087db2b0000 task.stack: ffffb9b903350000
[  461.955546] RIP: 0010:i40e_lan_xmit_frame+0xf1/0x1420 [i40e]
[  461.961965] RSP: 0018:ffffa087df1c3d80 EFLAGS: 00010293
[  461.967899] RAX: 0000000000000000 RBX: ffffa087c3077d00 RCX: 0000000000000000
[  461.975971] RDX: 0000000000000000 RSI: 0000000000000007 RDI: ffffa087b4e1d70c
[  461.984044] RBP: ffffa087df1c3e20 R08: ffffa087d440349c R09: 0000000000000000
[  461.992117] R10: ffffa087de821a08 R11: 0000000000000000 R12: ffffa087b7c60000
[  462.000188] R13: 0000000000000002 R14: 00000000000005ea R15: ffffa087d97b3000
[  462.008261] FS:  0000000000000000(0000) GS:ffffa087df1c0000(0000) knlGS:0000000000000000
[  462.017423] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  462.023941] CR2: 0000000000000008 CR3: 00000006efe09000 CR4: 00000000003406e0
[  462.032014] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  462.040083] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[  462.048154] Call Trace:
[  462.050969]  <IRQ>
[  462.053311]  ? update_load_avg+0x79/0x520
[  462.057876]  ? sched_clock_cpu+0x11/0xb0
[  462.062356]  dev_hard_start_xmit+0xa3/0x1f0
[  462.067127]  sch_direct_xmit+0xfc/0x1c0
[  462.071509]  __qdisc_run+0x122/0x270
[  462.075598]  net_tx_action+0xfd/0x1e0
[  462.079786]  __do_softirq+0x104/0x2af
[  462.083973]  irq_exit+0xb6/0xc0
[  462.087577]  smp_apic_timer_interrupt+0x3d/0x50
[  462.092732]  apic_timer_interrupt+0x89/0x90
[  462.097501] RIP: 0010:cpuidle_enter_state+0x122/0x2c0
[  462.103240] RSP: 0018:ffffb9b903353e58 EFLAGS: 00000246 ORIG_RAX: ffffffffffffff10
[  462.111818] RAX: 0000000000000000 RBX: 0000000000000004 RCX: 000000000000001f
[  462.119890] RDX: 0000006b86c1bdc1 RSI: ffffa087df1d8998 RDI: 0000000000000000
[  462.127962] RBP: ffffb9b903353e98 R08: 0000000000084c3f R09: 0000000000000018
[  462.136032] R10: 00000000000310a2 R11: 0000000000055e38 R12: ffffa087df1e5800
[  462.144094] R13: ffffffffb86ec998 R14: 0000000000000004 R15: ffffffffb86ec980
[  462.152165]  </IRQ>
[  462.154601]  ? cpuidle_enter_state+0x110/0x2c0
[  462.159662]  cpuidle_enter+0x17/0x20
[  462.163748]  call_cpuidle+0x23/0x40
[  462.167740]  do_idle+0x189/0x200
[  462.171438]  cpu_startup_entry+0x71/0x80
[  462.175908]  start_secondary+0x154/0x190
[  462.180384]  start_cpu+0x14/0x14
[  462.184080] Code: 8d 75 05 66 39 c8 0f 86 e4 04 00 00 01 d0 0f b7 d1 29 d0 83 e8 01 39 c6 0f 8f ed 05 00 00 49 8b 44 24 20 48 8d 14 89 4c 8d 1c d0 <49> 89 5b 08 8b 83 
[  462.205347] RIP: i40e_lan_xmit_frame+0xf1/0x1420 [i40e] RSP: ffffa087df1c3d80
[  462.213418] CR2: 0000000000000008
[  462.217226] ---[ end trace 0ee2eefbe09283a8 ]---
[  462.272123] Kernel panic - not syncing: Fatal exception in interrupt
[  462.279393] Kernel Offset: 0x36800000 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffffbfffffff)
[  462.345422] ---[ end Kernel panic - not syncing: Fatal exception in interrupt
