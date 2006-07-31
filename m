From: Dave Jones <davej@redhat.com>
Subject: neigh_lookup lockdep bug.
Date: Mon, 31 Jul 2006 16:50:04 -0400
Message-ID: <20060731205004.GA31845@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: arjan@infradead.org, mingo@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:62930 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1030355AbWGaUuT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2006 16:50:19 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2.6.18rc2-gitSomething on my firewall box just triggered this..

		Dave

[515613.791771] =======================================================
[515613.841467] [ INFO: possible circular locking dependency detected ]
[515613.873284] -------------------------------------------------------
[515613.904945] swapper/0 is trying to acquire lock:
[515613.931489]  (&tbl->lock){-+-+}, at: [<c05b5d63>] neigh_lookup+0x50/0xaf
[515613.964369] 
[515613.964373] but task is already holding lock:
[515614.006550]  (&skb_queue_lock_key){-+..}, at: [<c05b741c>] neigh_proxy_process+0x20/0xc2
[515614.043225] 
[515614.043228] which lock already depends on the new lock.
[515614.043234] 
[515614.103456] 
[515614.103459] the existing dependency chain (in reverse order) is:
[515614.148752] 
[515614.148755] -> #2 (&skb_queue_lock_key){-+..}:
[515614.188880]        [<c043bf43>] lock_acquire+0x4b/0x6c
[515614.215554]        [<c06089a7>] _spin_lock_irqsave+0x22/0x32
[515614.243606]        [<c05ac2e3>] skb_dequeue+0x12/0x43
[515614.269657]        [<c05acffe>] skb_queue_purge+0x14/0x1b
[515614.296565]        [<c05b673e>] neigh_update+0x317/0x353
[515614.323004]        [<c05e8a0b>] arp_process+0x4aa/0x4e4
[515614.349004]        [<c05e8b19>] arp_rcv+0xd4/0xf1
[515614.373209]        [<c05b1210>] netif_receive_skb+0x204/0x271
[515614.400405]        [<c05b2b73>] process_backlog+0x99/0xfa
[515614.426351]        [<c05b2d56>] net_rx_action+0x9d/0x196
[515614.451856]        [<c04293d5>] __do_softirq+0x78/0xf2
[515614.476660]        [<c040662f>] do_softirq+0x5a/0xbe
[515614.500737] 
[515614.500741] -> #1 (&n->lock){-+-+}:
[515614.532763]        [<c043bf43>] lock_acquire+0x4b/0x6c
[515614.556814]        [<c06086d0>] _write_lock+0x19/0x28
[515614.580398]        [<c05b7a0e>] neigh_periodic_timer+0x98/0x13c
[515614.606447]        [<c042db48>] run_timer_softirq+0x108/0x167
[515614.631798]        [<c04293d5>] __do_softirq+0x78/0xf2
[515614.655122]        [<c040662f>] do_softirq+0x5a/0xbe
[515614.677721] 
[515614.677724] -> #0 (&tbl->lock){-+-+}:
[515614.707327]        [<c043bf43>] lock_acquire+0x4b/0x6c
[515614.729897]        [<c060878a>] _read_lock_bh+0x1e/0x2d
[515614.752546]        [<c05b5d63>] neigh_lookup+0x50/0xaf
[515614.774754]        [<c05b6e5e>] neigh_event_ns+0x2c/0x77
[515614.797271]        [<c05e88c7>] arp_process+0x366/0x4e4
[515614.819349]        [<c05e8b3e>] parp_redo+0x8/0xa
[515614.839660]        [<c05b7462>] neigh_proxy_process+0x66/0xc2
[515614.862931]        [<c042db48>] run_timer_softirq+0x108/0x167
[515614.886048]        [<c04293d5>] __do_softirq+0x78/0xf2
[515614.907136]        [<c040662f>] do_softirq+0x5a/0xbe
[515614.927553] 
[515614.927557] other info that might help us debug this:
[515614.927563] 
[515614.966774] 1 lock held by swapper/0:
[515614.982693]  #0:  (&skb_queue_lock_key){-+..}, at: [<c05b741c>] neigh_proxy_process+0x20/0xc2
[515615.013575] 
[515615.013578] stack backtrace:
[515615.037414]  [<c04051ea>] show_trace_log_lvl+0x54/0xfd
[515615.057910]  [<c04057a6>] show_trace+0xd/0x10
[515615.075934]  [<c04058bf>] dump_stack+0x19/0x1b
[515615.094167]  [<c043b030>] print_circular_bug_tail+0x59/0x64
[515615.116172]  [<c043b843>] __lock_acquire+0x808/0x997
[515615.136514]  [<c043bf43>] lock_acquire+0x4b/0x6c
[515615.155699]  [<c060878a>] _read_lock_bh+0x1e/0x2d
[515615.175098]  [<c05b5d63>] neigh_lookup+0x50/0xaf
[515615.197276]  [<c05b6e5e>] neigh_event_ns+0x2c/0x77
[515615.220267]  [<c05e88c7>] arp_process+0x366/0x4e4
[515615.243248]  [<c05e8b3e>] parp_redo+0x8/0xa
[515615.264645]  [<c05b7462>] neigh_proxy_process+0x66/0xc2
[515615.288899]  [<c042db48>] run_timer_softirq+0x108/0x167
[515615.309972]  [<c04293d5>] __do_softirq+0x78/0xf2
[515615.328940]  [<c040662f>] do_softirq+0x5a/0xbe
[515615.347150]  [<c042927e>] irq_exit+0x3d/0x3f
[515615.365067]  [<c0417cbb>] smp_apic_timer_interrupt+0x79/0x7e
[515615.387057]  [<c0404b0a>] apic_timer_interrupt+0x2a/0x30


-- 
http://www.codemonkey.org.uk
