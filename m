From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [BUG] CPU lockup detected
Date: Wed, 17 Oct 2007 08:35:54 -0700
Message-ID: <20071017083554.5a4e1f16@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:54727 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934850AbXJQPgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 11:36:14 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Possible suspects TCP MD5 and/or netfilter conntrack.


Begin forwarded message:

Date: Wed, 17 Oct 2007 07:34:50 -0700 (PDT)
From: bugme-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 9173] New: BUG: soft lockup detected on CPU#0 - maybe related to TCP_MD5SIG


http://bugzilla.kernel.org/show_bug.cgi?id=9173

           Summary: BUG: soft lockup detected on CPU#0 - maybe related to
                    TCP_MD5SIG
           Product: Networking
           Version: 2.5
     KernelVersion: 2.6.20-9-server-lp2
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: tore@linpro.no
                CC: yoshfuji@linux-ipv6.org


Most recent kernel where this bug did not occur: 2.6.12 (with
TCP_MD5SIG-implementation from
http://hasso.linux.ee/doku.php/english:network:rfc2385)
Distribution: Ubuntu 6.06.1 LTS
Hardware Environment: Sun X4100 (x86_64, SMP)
Software Environment: Ubuntu 2.6.20-9-server-lp2 (-lp2 because it's recompiled
with TCP_MD5SIG enabled), 64-bits userspace
Problem Description:

The server is a border router running Quagga for BGP and OSPF, and usually
forwards 4-500Mbps worth of traffic between around 80 VLAN interfaces.  Four
network interfaces, bonded pairwise.  It has three BGP sessions with MD5
signatures enabled.

The server has an identical twin (for failover) which has also locked up like
this, although it happens much more frequently on the active one (no matter
which one is active, unfortunately).  We've got lots of these servers, but only
the border routers have had these lockups.

Once in a while (say, once every four to six weeks) it will flood the console
with BUG: soft lockup detected on CPU#0! and shortly after fail completely.This
time I had increased the default prink level one notch and got the back traces
too.  I'm not used to reading those, but the md5sig stuff seems to stand out...

I'll try to attach the trace somehow (got an error message about the bug being
to large when attempting to include it here).

Steps to reproduce:  It happens completely out of the blue, so I don't know
how.

Tore
---

Serial console started.  To stop, type ESC (
[616333.267002] BUG: soft lockup detected on CPU#0!
[616333.276201] 
[616333.276202] Call Trace:
[616333.284407]  <IRQ>  [<ffffffff802bbacb>] softlockup_tick+0xfb/0x120
[616333.297135]  [<ffffffff80298107>] update_process_times+0x57/0x90
[616333.309315]  [<ffffffff802798f4>] smp_local_timer_interrupt+0x34/0x60
[616333.322359]  [<ffffffff8027a1c9>] smp_apic_timer_interrupt+0x59/0x80
[616333.335230]  [<ffffffff80260ce6>] apic_timer_interrupt+0x66/0x70
[616333.347410]  [<ffffffff80266be7>] __lock_text_start+0x7/0x10
[616333.358896]  [<ffffffff803f3eff>] __tcp_get_md5sig_pool+0xf/0x50
[616333.371073]  [<ffffffff803fd899>] tcp_v4_do_calc_md5_hash+0x59/0x2e0
[616333.383954]  [<ffffffff881b4479>] :nf_conntrack:tcp_error+0x159/0x200
[616333.397006]  [<ffffffff881b16e9>] :nf_conntrack:__nf_conntrack_find+0x19/0x120
[616333.411647]  [<ffffffff80266c39>] _read_lock_bh+0x9/0x20
[616333.422441]  [<ffffffff882c2d15>] :ip_tables:ipt_do_table+0x305/0x370
[616333.435488]  [<ffffffff8023d4bb>] tcp_v4_do_rcv+0x10b/0x520
[616333.446805]  [<ffffffff881b5ab1>] :nf_conntrack:nf_ct_deliver_cached_events+0x61/0xb0
[616333.462656]  [<ffffffff881c51c8>] :nf_conntrack_ipv4:ipv4_confirm+0x48/0x60
[616333.476742]  [<ffffffff8023586c>] nf_iterate+0x5c/0xa0
[616333.487190]  [<ffffffff8022887e>] tcp_v4_rcv+0xa0e/0xa80
[616333.497985]  [<ffffffff80235f72>] ip_local_deliver+0x1b2/0x280
[616333.509817]  [<ffffffff802370b7>] ip_rcv+0x4d7/0x540
[616333.519918]  [<ffffffff80220d7a>] netif_receive_skb+0x2fa/0x330
[616333.531932]  [<ffffffff88152641>] :e1000:e1000_clean_rx_irq+0x451/0x520
[616333.545332]  [<ffffffff8815652f>] :e1000:e1000_clean+0x7f/0x250
[616333.557336]  [<ffffffff8028d936>] run_rebalance_domains+0xe6/0x3c0
[616333.569861]  [<ffffffff8020c29e>] net_rx_action+0xbe/0x1f0
[616333.581003]  [<ffffffff80211c53>] __do_softirq+0x63/0xd0
[616333.591796]  [<ffffffff8026123c>] call_softirq+0x1c/0x28
[616333.602587]  [<ffffffff8026f32c>] do_softirq+0x2c/0x90
[616333.613036]  [<ffffffff8026f516>] do_IRQ+0xc6/0xf0
[616333.622789]  [<ffffffff80260631>] ret_from_intr+0x0/0xa
[616333.633405]  <EOI>  [<ffffffff803f4037>] tcp_free_md5sig_pool+0x17/0x60
[616333.646813]  [<ffffffff803f4030>] tcp_free_md5sig_pool+0x10/0x60
[616333.658991]  [<ffffffff803fdab1>] tcp_v4_do_calc_md5_hash+0x271/0x2e0
[616333.672036]  [<ffffffff8021f290>] __pollwait+0x0/0x130
[616333.682484]  [<ffffffff8028d820>] default_wake_function+0x0/0x10
[616333.694662]  [<ffffffff802228fc>] tcp_transmit_skb+0x55c/0x790
[616333.706498]  [<ffffffff802348ad>] __tcp_push_pending_frames+0x80d/0x950
[616333.719887]  [<ffffffff80227190>] tcp_sendmsg+0x0/0xb00
[616333.730508]  [<ffffffff80227b39>] tcp_sendmsg+0x9a9/0xb00
[616333.741478]  [<ffffffff802492df>] sock_aio_write+0x13f/0x180
[616333.752970]  [<ffffffff80217ecf>] do_sync_write+0xcf/0x120
[616333.764111]  [<ffffffff802a2a40>] autoremove_wake_function+0x0/0x30
[616333.776809]  [<ffffffff80298fda>] lock_task_sighand+0x3a/0x80
[616333.788469]  [<ffffffff8029cb6e>] getrusage+0x23e/0x260
[616333.799090]  [<ffffffff80216668>] vfs_write+0xf8/0x1b0
[616333.809541]  [<ffffffff802171a3>] sys_write+0x53/0x90
[616333.819815]  [<ffffffff8026011e>] system_call+0x7e/0x83
[616333.830435] 
[616343.252556] BUG: soft lockup detected on CPU#0!
[616343.261784] 
[616343.261785] Call Trace:
[616343.270020]  <IRQ>  [<ffffffff802bbacb>] softlockup_tick+0xfb/0x120
[616343.282731]  [<ffffffff80298107>] update_process_times+0x57/0x90
[616343.294909]  [<ffffffff802798f4>] smp_local_timer_interrupt+0x34/0x60
[616343.307955]  [<ffffffff8027a1c9>] smp_apic_timer_interrupt+0x59/0x80
[616343.320825]  [<ffffffff80260ce6>] apic_timer_interrupt+0x66/0x70
[616343.333007]  [<ffffffff80266be7>] __lock_text_start+0x7/0x10
[616343.344497]  [<ffffffff803f3eff>] __tcp_get_md5sig_pool+0xf/0x50
[616343.356676]  [<ffffffff803fd899>] tcp_v4_do_calc_md5_hash+0x59/0x2e0
[616343.369554]  [<ffffffff881b4479>] :nf_conntrack:tcp_error+0x159/0x200
[616343.382603]  [<ffffffff881b16e9>] :nf_conntrack:__nf_conntrack_find+0x19/0x120
[616343.397238]  [<ffffffff80266c39>] _read_lock_bh+0x9/0x20
[616343.408031]  [<ffffffff882c2d15>] :ip_tables:ipt_do_table+0x305/0x370
[616343.421077]  [<ffffffff8023d4bb>] tcp_v4_do_rcv+0x10b/0x520
[616343.432394]  [<ffffffff881b5ab1>] :nf_conntrack:nf_ct_deliver_cached_events+0x61/0xb0
[616343.448245]  [<ffffffff881c51c8>] :nf_conntrack_ipv4:ipv4_confirm+0x48/0x60
[616343.462330]  [<ffffffff8023586c>] nf_iterate+0x5c/0xa0
[616343.472778]  [<ffffffff8022887e>] tcp_v4_rcv+0xa0e/0xa80
[616343.483573]  [<ffffffff80235f72>] ip_local_deliver+0x1b2/0x280
[616343.495405]  [<ffffffff802370b7>] ip_rcv+0x4d7/0x540
[616343.505505]  [<ffffffff80220d7a>] netif_receive_skb+0x2fa/0x330
[616343.517515]  [<ffffffff88152641>] :e1000:e1000_clean_rx_irq+0x451/0x520
[616343.530915]  [<ffffffff8815652f>] :e1000:e1000_clean+0x7f/0x250
[616343.542920]  [<ffffffff8028d936>] run_rebalance_domains+0xe6/0x3c0
[616343.555445]  [<ffffffff8020c29e>] net_rx_action+0xbe/0x1f0
[616343.566585]  [<ffffffff80211c53>] __do_softirq+0x63/0xd0
[616343.577378]  [<ffffffff8026123c>] call_softirq+0x1c/0x28
[616343.588169]  [<ffffffff8026f32c>] do_softirq+0x2c/0x90
[616343.598614]  [<ffffffff8026f516>] do_IRQ+0xc6/0xf0
[616343.608366]  [<ffffffff80260631>] ret_from_intr+0x0/0xa
[616343.618982]  <EOI>  [<ffffffff803f4037>] tcp_free_md5sig_pool+0x17/0x60
[616343.632390]  [<ffffffff803f4030>] tcp_free_md5sig_pool+0x10/0x60
[616343.644570]  [<ffffffff803fdab1>] tcp_v4_do_calc_md5_hash+0x271/0x2e0
[616343.657615]  [<ffffffff8021f290>] __pollwait+0x0/0x130
[616343.668063]  [<ffffffff8028d820>] default_wake_function+0x0/0x10
[616343.680242]  [<ffffffff802228fc>] tcp_transmit_skb+0x55c/0x790
[616343.692078]  [<ffffffff802348ad>] __tcp_push_pending_frames+0x80d/0x950
[616343.705467]  [<ffffffff80227190>] tcp_sendmsg+0x0/0xb00
[616343.716090]  [<ffffffff80227b39>] tcp_sendmsg+0x9a9/0xb00
[616343.727059]  [<ffffffff802492df>] sock_aio_write+0x13f/0x180
[616343.738551]  [<ffffffff80217ecf>] do_sync_write+0xcf/0x120
[616343.749692]  [<ffffffff802a2a40>] autoremove_wake_function+0x0/0x30
[616343.762393]  [<ffffffff80298fda>] lock_task_sighand+0x3a/0x80
[616343.774051]  [<ffffffff8029cb6e>] getrusage+0x23e/0x260
[616343.784673]  [<ffffffff80216668>] vfs_write+0xf8/0x1b0
[616343.795119]  [<ffffffff802171a3>] sys_write+0x53/0x90
[616343.805392]  [<ffffffff8026011e>] system_call+0x7e/0x83
[616343.816012] 
[616353.238112] BUG: soft lockup detected on CPU#0!
[616353.247343] 
[616353.247343] Call Trace:
[616353.255579]  <IRQ>  [<ffffffff802bbacb>] softlockup_tick+0xfb/0x120
[616353.268290]  [<ffffffff80298107>] update_process_times+0x57/0x90
[616353.280467]  [<ffffffff802798f4>] smp_local_timer_interrupt+0x34/0x60
[616353.293511]  [<ffffffff8027a1c9>] smp_apic_timer_interrupt+0x59/0x80
[616353.306387]  [<ffffffff80260ce6>] apic_timer_interrupt+0x66/0x70
[616353.318567]  [<ffffffff80266be7>] __lock_text_start+0x7/0x10
[616353.330053]  [<ffffffff803f3eff>] __tcp_get_md5sig_pool+0xf/0x50
[616353.342230]  [<ffffffff803fd899>] tcp_v4_do_calc_md5_hash+0x59/0x2e0
[616353.355108]  [<ffffffff881b4479>] :nf_conntrack:tcp_error+0x159/0x200
[616353.368157]  [<ffffffff881b16e9>] :nf_conntrack:__nf_conntrack_find+0x19/0x120
[616353.382792]  [<ffffffff80266c39>] _read_lock_bh+0x9/0x20
[616353.393585]  [<ffffffff882c2d15>] :ip_tables:ipt_do_table+0x305/0x370
[616353.406631]  [<ffffffff8023d4bb>] tcp_v4_do_rcv+0x10b/0x520
[616353.417948]  [<ffffffff881b5ab1>] :nf_conntrack:nf_ct_deliver_cached_events+0x61/0xb0
[616353.433798]  [<ffffffff881c51c8>] :nf_conntrack_ipv4:ipv4_confirm+0x48/0x60
[616353.447883]  [<ffffffff8023586c>] nf_iterate+0x5c/0xa0
[616353.458331]  [<ffffffff8022887e>] tcp_v4_rcv+0xa0e/0xa80
[616353.469127]  [<ffffffff80235f72>] ip_local_deliver+0x1b2/0x280
[616353.480958]  [<ffffffff802370b7>] ip_rcv+0x4d7/0x540
[616353.491058]  [<ffffffff80220d7a>] netif_receive_skb+0x2fa/0x330
[616353.503068]  [<ffffffff88152641>] :e1000:e1000_clean_rx_irq+0x451/0x520
[616353.516468]  [<ffffffff8815652f>] :e1000:e1000_clean+0x7f/0x250
[616353.528472]  [<ffffffff8028d936>] run_rebalance_domains+0xe6/0x3c0
[616353.540997]  [<ffffffff8020c29e>] net_rx_action+0xbe/0x1f0
[616353.552138]  [<ffffffff80211c53>] __do_softirq+0x63/0xd0
[616353.562931]  [<ffffffff8026123c>] call_softirq+0x1c/0x28
[616353.573724]  [<ffffffff8026f32c>] do_softirq+0x2c/0x90
[616353.584169]  [<ffffffff8026f516>] do_IRQ+0xc6/0xf0
[616353.593921]  [<ffffffff80260631>] ret_from_intr+0x0/0xa
[616353.604536]  <EOI>  [<ffffffff803f4037>] tcp_free_md5sig_pool+0x17/0x60
[616353.617944]  [<ffffffff803f4030>] tcp_free_md5sig_pool+0x10/0x60
[616353.630124]  [<ffffffff803fdab1>] tcp_v4_do_calc_md5_hash+0x271/0x2e0
[616353.643168]  [<ffffffff8021f290>] __pollwait+0x0/0x130
[616353.653616]  [<ffffffff8028d820>] default_wake_function+0x0/0x10
[616353.665797]  [<ffffffff802228fc>] tcp_transmit_skb+0x55c/0x790
[616353.677632]  [<ffffffff802348ad>] __tcp_push_pending_frames+0x80d/0x950
[616353.691021]  [<ffffffff80227190>] tcp_sendmsg+0x0/0xb00
[616353.701643]  [<ffffffff80227b39>] tcp_sendmsg+0x9a9/0xb00
[616353.712612]  [<ffffffff802492df>] sock_aio_write+0x13f/0x180
[616353.724104]  [<ffffffff80217ecf>] do_sync_write+0xcf/0x120
[616353.735248]  [<ffffffff802a2a40>] autoremove_wake_function+0x0/0x30
[616353.747948]  [<ffffffff80298fda>] lock_task_sighand+0x3a/0x80
[616353.759606]  [<ffffffff8029cb6e>] getrusage+0x23e/0x260
[616353.770226]  [<ffffffff80216668>] vfs_write+0xf8/0x1b0
[616353.780670]  [<ffffffff802171a3>] sys_write+0x53/0x90
[616353.790943]  [<ffffffff8026011e>] system_call+0x7e/0x83
[616353.801563] 
[616363.223667] BUG: soft lockup detected on CPU#0!
[616363.232899] 
[616363.232899] Call Trace:
[616363.241133]  <IRQ>  [<ffffffff802bbacb>] softlockup_tick+0xfb/0x120
[616363.253845]  [<ffffffff80298107>] update_process_times+0x57/0x90
[616363.266023]  [<ffffffff802798f4>] smp_local_timer_interrupt+0x34/0x60
[616363.279066]  [<ffffffff8027a1c9>] smp_apic_timer_interrupt+0x59/0x80
[616363.291937]  [<ffffffff80260ce6>] apic_timer_interrupt+0x66/0x70
[616363.304120]  [<ffffffff80266be5>] __lock_text_start+0x5/0x10
[616363.315606]  [<ffffffff803f3eff>] __tcp_get_md5sig_pool+0xf/0x50
[616363.327785]  [<ffffffff803fd899>] tcp_v4_do_calc_md5_hash+0x59/0x2e0
[616363.340662]  [<ffffffff881b4479>] :nf_conntrack:tcp_error+0x159/0x200
[616363.353711]  [<ffffffff881b16e9>] :nf_conntrack:__nf_conntrack_find+0x19/0x120
[616363.368346]  [<ffffffff80266c39>] _read_lock_bh+0x9/0x20
[616363.379137]  [<ffffffff882c2d15>] :ip_tables:ipt_do_table+0x305/0x370
[616363.392183]  [<ffffffff8023d4bb>] tcp_v4_do_rcv+0x10b/0x520
[616363.403501]  [<ffffffff881b5ab1>] :nf_conntrack:nf_ct_deliver_cached_events+0x61/0xb0
[616363.419350]  [<ffffffff881c51c8>] :nf_conntrack_ipv4:ipv4_confirm+0x48/0x60
[616363.433432]  [<ffffffff8023586c>] nf_iterate+0x5c/0xa0
[616363.443878]  [<ffffffff8022887e>] tcp_v4_rcv+0xa0e/0xa80
[616363.454672]  [<ffffffff80235f72>] ip_local_deliver+0x1b2/0x280
[616363.466504]  [<ffffffff802370b7>] ip_rcv+0x4d7/0x540
[616363.476605]  [<ffffffff80220d7a>] netif_receive_skb+0x2fa/0x330
[616363.488620]  [<ffffffff88152641>] :e1000:e1000_clean_rx_irq+0x451/0x520
[616363.503705]  [<ffffffff8815652f>] :e1000:e1000_clean+0x7f/0x250
[616363.515709]  [<ffffffff8028d936>] run_rebalance_domains+0xe6/0x3c0
[616363.528234]  [<ffffffff8020c29e>] net_rx_action+0xbe/0x1f0
[616363.539375]  [<ffffffff80211c53>] __do_softirq+0x63/0xd0
[616363.550168]  [<ffffffff8026123c>] call_softirq+0x1c/0x28
[616363.560962]  [<ffffffff8026f32c>] do_softirq+0x2c/0x90
[616363.571410]  [<ffffffff8026f516>] do_IRQ+0xc6/0xf0
[616363.581162]  [<ffffffff80260631>] ret_from_intr+0x0/0xa
[616363.591778]  <EOI>  [<ffffffff803f4037>] tcp_free_md5sig_pool+0x17/0x60
[616363.605186]  [<ffffffff803f4030>] tcp_free_md5sig_pool+0x10/0x60
[616363.617363]  [<ffffffff803fdab1>] tcp_v4_do_calc_md5_hash+0x271/0x2e0
[616363.630407]  [<ffffffff8021f290>] __pollwait+0x0/0x130
[616363.640855]  [<ffffffff8028d820>] default_wake_function+0x0/0x10
[616363.653035]  [<ffffffff802228fc>] tcp_transmit_skb+0x55c/0x790
[616363.664871]  [<ffffffff802348ad>] __tcp_push_pending_frames+0x80d/0x950
[616363.678260]  [<ffffffff80227190>] tcp_sendmsg+0x0/0xb00
[616363.688882]  [<ffffffff80227b39>] tcp_sendmsg+0x9a9/0xb00
[616363.699851]  [<ffffffff802492df>] sock_aio_write+0x13f/0x180
[616363.711342]  [<ffffffff80217ecf>] do_sync_write+0xcf/0x120
[616363.722483]  [<ffffffff802a2a40>] autoremove_wake_function+0x0/0x30
[616363.735181]  [<ffffffff80298fda>] lock_task_sighand+0x3a/0x80
[616363.746838]  [<ffffffff8029cb6e>] getrusage+0x23e/0x260
[616363.757461]  [<ffffffff80216668>] vfs_write+0xf8/0x1b0
[616363.767911]  [<ffffffff802171a3>] sys_write+0x53/0x90
[616363.778185]  [<ffffffff8026011e>] system_call+0x7e/0x83
[616363.788805] 
[616373.209223] BUG: soft lockup detected on CPU#0!
[616373.218454] 
[616373.218455] Call Trace:
[616373.226689]  <IRQ>  [<ffffffff802bbacb>] softlockup_tick+0xfb/0x120
[616373.239400]  [<ffffffff80298107>] update_process_times+0x57/0x90
[616373.251580]  [<ffffffff802798f4>] smp_local_timer_interrupt+0x34/0x60
[616373.264623]  [<ffffffff8027a1c9>] smp_apic_timer_interrupt+0x59/0x80
[616373.277493]  [<ffffffff80260ce6>] apic_timer_interrupt+0x66/0x70
[616373.289673]  [<ffffffff80266be7>] __lock_text_start+0x7/0x10
[616373.301158]  [<ffffffff803f3eff>] __tcp_get_md5sig_pool+0xf/0x50
[616373.313335]  [<ffffffff803fd899>] tcp_v4_do_calc_md5_hash+0x59/0x2e0
[616373.326212]  [<ffffffff881b4479>] :nf_conntrack:tcp_error+0x159/0x200
[616373.339261]  [<ffffffff881b16e9>] :nf_conntrack:__nf_conntrack_find+0x19/0x120
[616373.353899]  [<ffffffff80266c39>] _read_lock_bh+0x9/0x20
[616373.364696]  [<ffffffff882c2d15>] :ip_tables:ipt_do_table+0x305/0x370
[616373.377741]  [<ffffffff8023d4bb>] tcp_v4_do_rcv+0x10b/0x520
[616373.389057]  [<ffffffff881b5ab1>] :nf_conntrack:nf_ct_deliver_cached_events+0x61/0xb0
[616373.404907]  [<ffffffff881c51c8>] :nf_conntrack_ipv4:ipv4_confirm+0x48/0x60
[616373.418992]  [<ffffffff8023586c>] nf_iterate+0x5c/0xa0
[616373.429440]  [<ffffffff8022887e>] tcp_v4_rcv+0xa0e/0xa80
[616373.440235]  [<ffffffff80235f72>] ip_local_deliver+0x1b2/0x280
[616373.452068]  [<ffffffff802370b7>] ip_rcv+0x4d7/0x540
[616373.462168]  [<ffffffff80220d7a>] netif_receive_skb+0x2fa/0x330
[616373.474178]  [<ffffffff88152641>] :e1000:e1000_clean_rx_irq+0x451/0x520
[616373.487578]  [<ffffffff8815652f>] :e1000:e1000_clean+0x7f/0x250
[616373.499582]  [<ffffffff8028d936>] run_rebalance_domains+0xe6/0x3c0
[616373.512107]  [<ffffffff8020c29e>] net_rx_action+0xbe/0x1f0
[616373.523248]  [<ffffffff80211c53>] __do_softirq+0x63/0xd0
[616373.534039]  [<ffffffff8026123c>] call_softirq+0x1c/0x28
[616373.544830]  [<ffffffff8026f32c>] do_softirq+0x2c/0x90
[616373.555275]  [<ffffffff8026f516>] do_IRQ+0xc6/0xf0
[616373.565027]  [<ffffffff80260631>] ret_from_intr+0x0/0xa
[616373.575643]  <EOI>  [<ffffffff803f4037>] tcp_free_md5sig_pool+0x17/0x60
[616373.589051]  [<ffffffff803f4030>] tcp_free_md5sig_pool+0x10/0x60
[616373.601229]  [<ffffffff803fdab1>] tcp_v4_do_calc_md5_hash+0x271/0x2e0
[616373.614273]  [<ffffffff8021f290>] __pollwait+0x0/0x130
[616373.624720]  [<ffffffff8028d820>] default_wake_function+0x0/0x10
[616373.636901]  [<ffffffff802228fc>] tcp_transmit_skb+0x55c/0x790
[616373.648735]  [<ffffffff802348ad>] __tcp_push_pending_frames+0x80d/0x950
[616373.662124]  [<ffffffff80227190>] tcp_sendmsg+0x0/0xb00
[616373.672746]  [<ffffffff80227b39>] tcp_sendmsg+0x9a9/0xb00
[616373.683715]  [<ffffffff802492df>] sock_aio_write+0x13f/0x180
[616373.695206]  [<ffffffff80217ecf>] do_sync_write+0xcf/0x120
[616373.706346]  [<ffffffff802a2a40>] autoremove_wake_function+0x0/0x30
[616373.719043]  [<ffffffff80298fda>] lock_task_sighand+0x3a/0x80
[616373.730703]  [<ffffffff8029cb6e>] getrusage+0x23e/0x260
[616373.741325]  [<ffffffff80216668>] vfs_write+0xf8/0x1b0
[616373.751771]  [<ffffffff802171a3>] sys_write+0x53/0x90
[616373.762044]  [<ffffffff8026011e>] system_call+0x7e/0x83
[616373.772664] 
[616383.194779] BUG: soft lockup detected on CPU#0!
[616383.204008] 
[616383.204008] Call Trace:
[616383.212240]  <IRQ>  [<ffffffff802bbacb>] softlockup_tick+0xfb/0x120
[616383.224949]  [<ffffffff80298107>] update_process_times+0x57/0x90
[616383.237128]  [<ffffffff802798f4>] smp_local_timer_interrupt+0x34/0x60
[616383.250172]  [<ffffffff8027a1c9>] smp_apic_timer_interrupt+0x59/0x80
[616383.263043]  [<ffffffff80260ce6>] apic_timer_interrupt+0x66/0x70
[616383.275225]  [<ffffffff80266be5>] __lock_text_start+0x5/0x10
[616383.286712]  [<ffffffff803f3eff>] __tcp_get_md5sig_pool+0xf/0x50
[616383.298888]  [<ffffffff803fd899>] tcp_v4_do_calc_md5_hash+0x59/0x2e0
[616383.311764]  [<ffffffff881b4479>] :nf_conntrack:tcp_error+0x159/0x200
[616383.324813]  [<ffffffff881b16e9>] :nf_conntrack:__nf_conntrack_find+0x19/0x120
[616383.339450]  [<ffffffff80266c39>] _read_lock_bh+0x9/0x20
[616383.350244]  [<ffffffff882c2d15>] :ip_tables:ipt_do_table+0x305/0x370
[616383.363289]  [<ffffffff8023d4bb>] tcp_v4_do_rcv+0x10b/0x520
[616383.374606]  [<ffffffff881b5ab1>] :nf_conntrack:nf_ct_deliver_cached_events+0x61/0xb0
[616383.390457]  [<ffffffff881c51c8>] :nf_conntrack_ipv4:ipv4_confirm+0x48/0x60
[616383.404540]  [<ffffffff8023586c>] nf_iterate+0x5c/0xa0
[616383.414986]  [<ffffffff8022887e>] tcp_v4_rcv+0xa0e/0xa80
[616383.425782]  [<ffffffff80235f72>] ip_local_deliver+0x1b2/0x280
[616383.437613]  [<ffffffff802370b7>] ip_rcv+0x4d7/0x540
[616383.447713]  [<ffffffff80220d7a>] netif_receive_skb+0x2fa/0x330
[616383.459725]  [<ffffffff88152641>] :e1000:e1000_clean_rx_irq+0x451/0x520
[616383.473124]  [<ffffffff8815652f>] :e1000:e1000_clean+0x7f/0x250
[616383.485143]  [<ffffffff8028d936>] run_rebalance_domains+0xe6/0x3c0
[616383.497670]  [<ffffffff8020c29e>] net_rx_action+0xbe/0x1f0
[616383.508810]  [<ffffffff80211c53>] __do_softirq+0x63/0xd0
[616383.519603]  [<ffffffff8026123c>] call_softirq+0x1c/0x28
[616383.530396]  [<ffffffff8026f32c>] do_softirq+0x2c/0x90
[616383.540841]  [<ffffffff8026f516>] do_IRQ+0xc6/0xf0
[616383.550593]  [<ffffffff80260631>] ret_from_intr+0x0/0xa
[616383.561208]  <EOI>  [<ffffffff803f4037>] tcp_free_md5sig_pool+0x17/0x60
[616383.574616]  [<ffffffff803f4030>] tcp_free_md5sig_pool+0x10/0x60
[616383.586793]  [<ffffffff803fdab1>] tcp_v4_do_calc_md5_hash+0x271/0x2e0
[616383.599842]  [<ffffffff8021f290>] __pollwait+0x0/0x130
[616383.610290]  [<ffffffff8028d820>] default_wake_function+0x0/0x10
[616383.622468]  [<ffffffff802228fc>] tcp_transmit_skb+0x55c/0x790
[616383.634303]  [<ffffffff802348ad>] __tcp_push_pending_frames+0x80d/0x950
[616383.647696]  [<ffffffff80227190>] tcp_sendmsg+0x0/0xb00
[616383.658319]  [<ffffffff80227b39>] tcp_sendmsg+0x9a9/0xb00
[616383.669288]  [<ffffffff802492df>] sock_aio_write+0x13f/0x180
[616383.680780]  [<ffffffff80217ecf>] do_sync_write+0xcf/0x120
[616383.691922]  [<ffffffff802a2a40>] autoremove_wake_function+0x0/0x30
[616383.704621]  [<ffffffff80298fda>] lock_task_sighand+0x3a/0x80
[616383.716281]  [<ffffffff8029cb6e>] getrusage+0x23e/0x260
[616383.726903]  [<ffffffff80216668>] vfs_write+0xf8/0x1b0
[616383.737349]  [<ffffffff802171a3>] sys_write+0x53/0x90
[616383.747622]  [<ffffffff8026011e>] system_call+0x7e/0x83
[616383.758242] 
[616393.180335] BUG: soft lockup detected on CPU#0!
[616393.189563] 
[616393.189564] Call Trace:
[616393.197798]  <IRQ>  [<ffffffff802bbacb>] softlockup_tick+0xfb/0x120
[616393.210509]  [<ffffffff80298107>] update_process_times+0x57/0x90
[616393.222687]  [<ffffffff802798f4>] smp_local_timer_interrupt+0x34/0x60
[616393.235730]  [<ffffffff8027a1c9>] smp_apic_timer_interrupt+0x59/0x80
[616393.248603]  [<ffffffff80260ce6>] apic_timer_interrupt+0x66/0x70
[616393.260785]  [<ffffffff80266be7>] __lock_text_start+0x7/0x10
[616393.272272]  [<ffffffff803f3eff>] __tcp_get_md5sig_pool+0xf/0x50
[616393.284451]  [<ffffffff803fd899>] tcp_v4_do_calc_md5_hash+0x59/0x2e0
[616393.297328]  [<ffffffff881b4479>] :nf_conntrack:tcp_error+0x159/0x200
[616393.310381]  [<ffffffff881b16e9>] :nf_conntrack:__nf_conntrack_find+0x19/0x120
[616393.325019]  [<ffffffff80266c39>] _read_lock_bh+0x9/0x20
[616393.335812]  [<ffffffff882c2d15>] :ip_tables:ipt_do_table+0x305/0x370
[616393.348859]  [<ffffffff8023d4bb>] tcp_v4_do_rcv+0x10b/0x520
[616393.360176]  [<ffffffff881b5ab1>] :nf_conntrack:nf_ct_deliver_cached_events+0x61/0xb0
[616393.376025]  [<ffffffff881c51c8>] :nf_conntrack_ipv4:ipv4_confirm+0x48/0x60
[616393.390110]  [<ffffffff8023586c>] nf_iterate+0x5c/0xa0
[616393.400557]  [<ffffffff8022887e>] tcp_v4_rcv+0xa0e/0xa80
[616393.411349]  [<ffffffff80235f72>] ip_local_deliver+0x1b2/0x280
[616393.423182]  [<ffffffff802370b7>] ip_rcv+0x4d7/0x540
[616393.433282]  [<ffffffff80220d7a>] netif_receive_skb+0x2fa/0x330
[616393.445292]  [<ffffffff88152641>] :e1000:e1000_clean_rx_irq+0x451/0x520
[616393.458691]  [<ffffffff8815652f>] :e1000:e1000_clean+0x7f/0x250
[616393.470696]  [<ffffffff8028d936>] run_rebalance_domains+0xe6/0x3c0
[616393.483223]  [<ffffffff8020c29e>] net_rx_action+0xbe/0x1f0
[616393.494363]  [<ffffffff80211c53>] __do_softirq+0x63/0xd0
[616393.505156]  [<ffffffff8026123c>] call_softirq+0x1c/0x28
[616393.515949]  [<ffffffff8026f32c>] do_softirq+0x2c/0x90
[616393.526394]  [<ffffffff8026f516>] do_IRQ+0xc6/0xf0
[616393.536147]  [<ffffffff80260631>] ret_from_intr+0x0/0xa
[616393.546765]  <EOI>  [<ffffffff803f4037>] tcp_free_md5sig_pool+0x17/0x60
[616393.560174]  [<ffffffff803f4030>] tcp_free_md5sig_pool+0x10/0x60
[616393.572352]  [<ffffffff803fdab1>] tcp_v4_do_calc_md5_hash+0x271/0x2e0
[616393.585399]  [<ffffffff8021f290>] __pollwait+0x0/0x130
[616393.595848]  [<ffffffff8028d820>] default_wake_function+0x0/0x10
[616393.608038]  [<ffffffff802228fc>] tcp_transmit_skb+0x55c/0x790
[616393.619872]  [<ffffffff802348ad>] __tcp_push_pending_frames+0x80d/0x950
[616393.633261]  [<ffffffff80227190>] tcp_sendmsg+0x0/0xb00
[616393.643883]  [<ffffffff80227b39>] tcp_sendmsg+0x9a9/0xb00
[616393.654852]  [<ffffffff802492df>] sock_aio_write+0x13f/0x180
[616393.666344]  [<ffffffff80217ecf>] do_sync_write+0xcf/0x120
[616393.677484]  [<ffffffff802a2a40>] autoremove_wake_function+0x0/0x30
[616393.690183]  [<ffffffff80298fda>] lock_task_sighand+0x3a/0x80
[616393.701843]  [<ffffffff8029cb6e>] getrusage+0x23e/0x260
[616393.712466]  [<ffffffff80216668>] vfs_write+0xf8/0x1b0
[616393.722912]  [<ffffffff802171a3>] sys_write+0x53/0x90
[616393.734870]  [<ffffffff8026011e>] system_call+0x7e/0x83
[616393.745489] 
[616403.165890] BUG: soft lockup detected on CPU#0!
[616403.175119] 
[616403.175120] Call Trace:
[616403.183353]  <IRQ>  [<ffffffff802bbacb>] softlockup_tick+0xfb/0x120
[616403.196062]  [<ffffffff80298107>] update_process_times+0x57/0x90
[616403.208240]  [<ffffffff802798f4>] smp_local_timer_interrupt+0x34/0x60
[616403.221283]  [<ffffffff8027a1c9>] smp_apic_timer_interrupt+0x59/0x80
[616403.234156]  [<ffffffff80260ce6>] apic_timer_interrupt+0x66/0x70
[616403.246335]  [<ffffffff80266be5>] __lock_text_start+0x5/0x10
[616403.257821]  [<ffffffff803f3eff>] __tcp_get_md5sig_pool+0xf/0x50
[616403.270000]  [<ffffffff803fd899>] tcp_v4_do_calc_md5_hash+0x59/0x2e0
[616403.282877]  [<ffffffff881b4479>] :nf_conntrack:tcp_error+0x159/0x200
[616403.295926]  [<ffffffff881b16e9>] :nf_conntrack:__nf_conntrack_find+0x19/0x120
[616403.310561]  [<ffffffff80266c39>] _read_lock_bh+0x9/0x20
[616403.321353]  [<ffffffff882c2d15>] :ip_tables:ipt_do_table+0x305/0x370
[616403.334399]  [<ffffffff8023d4bb>] tcp_v4_do_rcv+0x10b/0x520
[616403.345716]  [<ffffffff881b5ab1>] :nf_conntrack:nf_ct_deliver_cached_events+0x61/0xb0
[616403.361564]  [<ffffffff881c51c8>] :nf_conntrack_ipv4:ipv4_confirm+0x48/0x60
[616403.375647]  [<ffffffff8023586c>] nf_iterate+0x5c/0xa0
[616403.386094]  [<ffffffff8022887e>] tcp_v4_rcv+0xa0e/0xa80
[616403.396892]  [<ffffffff80235f72>] ip_local_deliver+0x1b2/0x280
[616403.408726]  [<ffffffff802370b7>] ip_rcv+0x4d7/0x540
[616403.418830]  [<ffffffff80220d7a>] netif_receive_skb+0x2fa/0x330
[616403.430840]  [<ffffffff88152641>] :e1000:e1000_clean_rx_irq+0x451/0x520
[616403.444239]  [<ffffffff8815652f>] :e1000:e1000_clean+0x7f/0x250
[616403.456242]  [<ffffffff8028d936>] run_rebalance_domains+0xe6/0x3c0
[616403.468768]  [<ffffffff8020c29e>] net_rx_action+0xbe/0x1f0
[616403.479907]  [<ffffffff80211c53>] __do_softirq+0x63/0xd0
[616403.490700]  [<ffffffff8026123c>] call_softirq+0x1c/0x28
[616403.501493]  [<ffffffff8026f32c>] do_softirq+0x2c/0x90
[616403.511938]  [<ffffffff8026f516>] do_IRQ+0xc6/0xf0
[616403.521692]  [<ffffffff80260631>] ret_from_intr+0x0/0xa
[616403.532306]  <EOI>  [<ffffffff803f4037>] tcp_free_md5sig_pool+0x17/0x60
[616403.545715]  [<ffffffff803f4030>] tcp_free_md5sig_pool+0x10/0x60
[616403.557894]  [<ffffffff803fdab1>] tcp_v4_do_calc_md5_hash+0x271/0x2e0
[616403.570938]  [<ffffffff8021f290>] __pollwait+0x0/0x130
[616403.581390]  [<ffffffff8028d820>] default_wake_function+0x0/0x10
[616403.593568]  [<ffffffff802228fc>] tcp_transmit_skb+0x55c/0x790
[616403.605403]  [<ffffffff802348ad>] __tcp_push_pending_frames+0x80d/0x950
[616403.618792]  [<ffffffff80227190>] tcp_sendmsg+0x0/0xb00
[616403.629415]  [<ffffffff80227b39>] tcp_sendmsg+0x9a9/0xb00
[616403.640384]  [<ffffffff802492df>] sock_aio_write+0x13f/0x180
[616403.651875]  [<ffffffff80217ecf>] do_sync_write+0xcf/0x120
[616403.663014]  [<ffffffff802a2a40>] autoremove_wake_function+0x0/0x30
[616403.675713]  [<ffffffff80298fda>] lock_task_sighand+0x3a/0x80
[616403.687373]  [<ffffffff8029cb6e>] getrusage+0x23e/0x260
[616403.697994]  [<ffffffff80216668>] vfs_write+0xf8/0x1b0
[616403.708440]  [<ffffffff802171a3>] sys_write+0x53/0x90
[616403.718714]  [<ffffffff8026011e>] system_call+0x7e/0x83
[616403.729334] 
[616413.151446] BUG: soft lockup detected on CPU#0!
[616413.160677] 
[616413.160678] Call Trace:
[616413.168911]  <IRQ>  [<ffffffff802bbacb>] softlockup_tick+0xfb/0x120
[616413.181620]  [<ffffffff80298107>] update_process_times+0x57/0x90
[616413.193798]  [<ffffffff802798f4>] smp_local_timer_interrupt+0x34/0x60
[616413.206841]  [<ffffffff8027a1c9>] smp_apic_timer_interrupt+0x59/0x80
[616413.219712]  [<ffffffff80260ce6>] apic_timer_interrupt+0x66/0x70
[616413.231893]  [<ffffffff80266be5>] __lock_text_start+0x5/0x10
[616413.243378]  [<ffffffff803f3eff>] __tcp_get_md5sig_pool+0xf/0x50
[616413.255557]  [<ffffffff803fd899>] tcp_v4_do_calc_md5_hash+0x59/0x2e0
[616413.268433]  [<ffffffff881b4479>] :nf_conntrack:tcp_error+0x159/0x200
[616413.281482]  [<ffffffff881b16e9>] :nf_conntrack:__nf_conntrack_find+0x19/0x120
[616413.296118]  [<ffffffff80266c39>] _read_lock_bh+0x9/0x20
[616413.306911]  [<ffffffff882c2d15>] :ip_tables:ipt_do_table+0x305/0x370
[616413.319957]  [<ffffffff8023d4bb>] tcp_v4_do_rcv+0x10b/0x520
[616413.331274]  [<ffffffff881b5ab1>] :nf_conntrack:nf_ct_deliver_cached_events+0x61/0xb0
[616413.347124]  [<ffffffff881c51c8>] :nf_conntrack_ipv4:ipv4_confirm+0x48/0x60
[616413.361210]  [<ffffffff8023586c>] nf_iterate+0x5c/0xa0
[616413.371657]  [<ffffffff8022887e>] tcp_v4_rcv+0xa0e/0xa80
[616413.382449]  [<ffffffff80235f72>] ip_local_deliver+0x1b2/0x280
[616413.394282]  [<ffffffff802370b7>] ip_rcv+0x4d7/0x540
[616413.404382]  [<ffffffff80220d7a>] netif_receive_skb+0x2fa/0x330
[616413.416392]  [<ffffffff88152641>] :e1000:e1000_clean_rx_irq+0x451/0x520
[616413.429791]  [<ffffffff8815652f>] :e1000:e1000_clean+0x7f/0x250
[616413.441796]  [<ffffffff8028d936>] run_rebalance_domains+0xe6/0x3c0
[616413.454323]  [<ffffffff8020c29e>] net_rx_action+0xbe/0x1f0
[616413.465469]  [<ffffffff80211c53>] __do_softirq+0x63/0xd0
[616413.476262]  [<ffffffff8026123c>] call_softirq+0x1c/0x28
[616413.487056]  [<ffffffff8026f32c>] do_softirq+0x2c/0x90
[616413.497501]  [<ffffffff8026f516>] do_IRQ+0xc6/0xf0
[616413.507252]  [<ffffffff80260631>] ret_from_intr+0x0/0xa
[616413.517867]  <EOI>  [<ffffffff803f4037>] tcp_free_md5sig_pool+0x17/0x60
[616413.531279]  [<ffffffff803f4030>] tcp_free_md5sig_pool+0x10/0x60
[616413.543457]  [<ffffffff803fdab1>] tcp_v4_do_calc_md5_hash+0x271/0x2e0
[616413.556501]  [<ffffffff8021f290>] __pollwait+0x0/0x130
[616413.566950]  [<ffffffff8028d820>] default_wake_function+0x0/0x10
[616413.579135]  [<ffffffff802228fc>] tcp_transmit_skb+0x55c/0x790
[616413.590970]  [<ffffffff802348ad>] __tcp_push_pending_frames+0x80d/0x950
[616413.604358]  [<ffffffff80227190>] tcp_sendmsg+0x0/0xb00
[616413.614980]  [<ffffffff80227b39>] tcp_sendmsg+0x9a9/0xb00
[616413.625948]  [<ffffffff802492df>] sock_aio_write+0x13f/0x180
[616413.637441]  [<ffffffff80217ecf>] do_sync_write+0xcf/0x120
[616413.648581]  [<ffffffff802a2a40>] autoremove_wake_function+0x0/0x30
[616413.661278]  [<ffffffff80298fda>] lock_task_sighand+0x3a/0x80
[616413.672936]  [<ffffffff8029cb6e>] getrusage+0x23e/0x260
[616413.683557]  [<ffffffff80216668>] vfs_write+0xf8/0x1b0
[616413.694003]  [<ffffffff802171a3>] sys_write+0x53/0x90
[616413.704276]  [<ffffffff8026011e>] system_call+0x7e/0x83
[616413.714896] 
[616423.137002] BUG: soft lockup detected on CPU#0!
[616423.146231] 
[616423.146231] Call Trace:
[616423.154466]  <IRQ>  [<ffffffff802bbacb>] softlockup_tick+0xfb/0x120
[616423.167178]  [<ffffffff80298107>] update_process_times+0x57/0x90
[616423.179357]  [<ffffffff802798f4>] smp_local_timer_interrupt+0x34/0x60
[616423.192400]  [<ffffffff8027a1c9>] smp_apic_timer_interrupt+0x59/0x80
[616423.205270]  [<ffffffff80260ce6>] apic_timer_interrupt+0x66/0x70
[616423.217452]  [<ffffffff80266be5>] __lock_text_start+0x5/0x10
[616423.228937]  [<ffffffff803f3eff>] __tcp_get_md5sig_pool+0xf/0x50
[616423.241116]  [<ffffffff803fd899>] tcp_v4_do_calc_md5_hash+0x59/0x2e0
[616423.253993]  [<ffffffff881b4479>] :nf_conntrack:tcp_error+0x159/0x200
[616423.267044]  [<ffffffff881b16e9>] :nf_conntrack:__nf_conntrack_find+0x19/0x120
[616423.281684]  [<ffffffff80266c39>] _read_lock_bh+0x9/0x20
[616423.292477]  [<ffffffff882c2d15>] :ip_tables:ipt_do_table+0x305/0x370
[616423.305523]  [<ffffffff8023d4bb>] tcp_v4_do_rcv+0x10b/0x520
[616423.316840]  [<ffffffff881b5ab1>] :nf_conntrack:nf_ct_deliver_cached_events+0x61/0xb0
[616423.332689]  [<ffffffff881c51c8>] :nf_conntrack_ipv4:ipv4_confirm+0x48/0x60
[616423.346774]  [<ffffffff8023586c>] nf_iterate+0x5c/0xa0
[616423.357222]  [<ffffffff8022887e>] tcp_v4_rcv+0xa0e/0xa80
[616423.368016]  [<ffffffff80235f72>] ip_local_deliver+0x1b2/0x280
[616423.379850]  [<ffffffff802370b7>] ip_rcv+0x4d7/0x540
[616423.389950]  [<ffffffff80220d7a>] netif_receive_skb+0x2fa/0x330
[616423.401961]  [<ffffffff88152641>] :e1000:e1000_clean_rx_irq+0x451/0x520
[616423.415365]  [<ffffffff8815652f>] :e1000:e1000_clean+0x7f/0x250
[616423.427370]  [<ffffffff8028d936>] run_rebalance_domains+0xe6/0x3c0
[616423.439895]  [<ffffffff8020c29e>] net_rx_action+0xbe/0x1f0
[616423.451034]  [<ffffffff80211c53>] __do_softirq+0x63/0xd0
[616423.461825]  [<ffffffff8026123c>] call_softirq+0x1c/0x28
[616423.472616]  [<ffffffff8026f32c>] do_softirq+0x2c/0x90
[616423.483061]  [<ffffffff8026f516>] do_IRQ+0xc6/0xf0
[616423.492813]  [<ffffffff80260631>] ret_from_intr+0x0/0xa
[616423.503428]  <EOI>  [<ffffffff803f4037>] tcp_free_md5sig_pool+0x17/0x60
[616423.516836]  [<ffffffff803f4030>] tcp_free_md5sig_pool+0x10/0x60
[616423.529020]  [<ffffffff803fdab1>] tcp_v4_do_calc_md5_hash+0x271/0x2e0
[616423.542064]  [<ffffffff8021f290>] __pollwait+0x0/0x130
[616423.552513]  [<ffffffff8028d820>] default_wake_function+0x0/0x10
[616423.564693]  [<ffffffff802228fc>] tcp_transmit_skb+0x55c/0x790
[616423.576529]  [<ffffffff802348ad>] __tcp_push_pending_frames+0x80d/0x950
[616423.589918]  [<ffffffff80227190>] tcp_sendmsg+0x0/0xb00
[616423.600540]  [<ffffffff80227b39>] tcp_sendmsg+0x9a9/0xb00
[616423.611509]  [<ffffffff802492df>] sock_aio_write+0x13f/0x180
[616423.623001]  [<ffffffff80217ecf>] do_sync_write+0xcf/0x120
[616423.634141]  [<ffffffff802a2a40>] autoremove_wake_function+0x0/0x30
[616423.646840]  [<ffffffff80298fda>] lock_task_sighand+0x3a/0x80
[616423.658497]  [<ffffffff8029cb6e>] getrusage+0x23e/0x260
[616423.669119]  [<ffffffff80216668>] vfs_write+0xf8/0x1b0
[616423.679565]  [<ffffffff802171a3>] sys_write+0x53/0x90
[616423.689840]  [<ffffffff8026011e>] system_call+0x7e/0x83
[616423.700460] 
[616433.122558] BUG: soft lockup detected on CPU#0!
[616433.131787] 
[616433.131787] Call Trace:
[616433.140022]  <IRQ>  [<ffffffff802bbacb>] softlockup_tick+0xfb/0x120
[616433.152733]  [<ffffffff80298107>] update_process_times+0x57/0x90
[616433.164913]  [<ffffffff802798f4>] smp_local_timer_interrupt+0x34/0x60
[616433.177956]  [<ffffffff8027a1c9>] smp_apic_timer_interrupt+0x59/0x80
[616433.190829]  [<ffffffff80260ce6>] apic_timer_interrupt+0x66/0x70
[616433.203008]  [<ffffffff80266be7>] __lock_text_start+0x7/0x10
[616433.214494]  [<ffffffff803f3eff>] __tcp_get_md5sig_pool+0xf/0x50
[616433.226672]  [<ffffffff803fd899>] tcp_v4_do_calc_md5_hash+0x59/0x2e0
[616433.239554]  [<ffffffff881b4479>] :nf_conntrack:tcp_error+0x159/0x200
[616433.252605]  [<ffffffff881b16e9>] :nf_conntrack:__nf_conntrack_find+0x19/0x120
[616433.267241]  [<ffffffff80266c39>] _read_lock_bh+0x9/0x20
[616433.278035]  [<ffffffff882c2d15>] :ip_tables:ipt_do_table+0x305/0x370
[616433.291079]  [<ffffffff8023d4bb>] tcp_v4_do_rcv+0x10b/0x520
[616433.302400]  [<ffffffff881b5ab1>] :nf_conntrack:nf_ct_deliver_cached_events+0x61/0xb0
[616433.318251]  [<ffffffff881c51c8>] :nf_conntrack_ipv4:ipv4_confirm+0x48/0x60
[616433.332334]  [<ffffffff8023586c>] nf_iterate+0x5c/0xa0
[616433.342780]  [<ffffffff8022887e>] tcp_v4_rcv+0xa0e/0xa80
[616433.355262]  [<ffffffff80235f72>] ip_local_deliver+0x1b2/0x280
[616433.367095]  [<ffffffff802370b7>] ip_rcv+0x4d7/0x540
[616433.377199]  [<ffffffff80220d7a>] netif_receive_skb+0x2fa/0x330
[616433.389209]  [<ffffffff88152641>] :e1000:e1000_clean_rx_irq+0x451/0x520
[616433.402609]  [<ffffffff8815652f>] :e1000:e1000_clean+0x7f/0x250
[616433.414614]  [<ffffffff8028d936>] run_rebalance_domains+0xe6/0x3c0
[616433.427139]  [<ffffffff8020c29e>] net_rx_action+0xbe/0x1f0
[616433.438279]  [<ffffffff80211c53>] __do_softirq+0x63/0xd0
[616433.449073]  [<ffffffff8026123c>] call_softirq+0x1c/0x28
[616433.459866]  [<ffffffff8026f32c>] do_softirq+0x2c/0x90
[616433.470310]  [<ffffffff8026f516>] do_IRQ+0xc6/0xf0
[616433.480063]  [<ffffffff80260631>] ret_from_intr+0x0/0xa
[616433.490678]  <EOI>  [<ffffffff803f4037>] tcp_free_md5sig_pool+0x17/0x60
[616433.504085]  [<ffffffff803f4030>] tcp_free_md5sig_pool+0x10/0x60
[616433.516264]  [<ffffffff803fdab1>] tcp_v4_do_calc_md5_hash+0x271/0x2e0
[616433.529309]  [<ffffffff8021f290>] __pollwait+0x0/0x130
[616433.539761]  [<ffffffff8028d820>] default_wake_function+0x0/0x10
[616433.551939]  [<ffffffff802228fc>] tcp_transmit_skb+0x55c/0x790
[616433.563775]  [<ffffffff802348ad>] __tcp_push_pending_frames+0x80d/0x950
[616433.577164]  [<ffffffff80227190>] tcp_sendmsg+0x0/0xb00
[616433.587786]  [<ffffffff80227b39>] tcp_sendmsg+0x9a9/0xb00
[616433.598755]  [<ffffffff802492df>] sock_aio_write+0x13f/0x180
[616433.610247]  [<ffffffff80217ecf>] do_sync_write+0xcf/0x120
[616433.621390]  [<ffffffff802a2a40>] autoremove_wake_function+0x0/0x30
[616433.634089]  [<ffffffff80298fda>] lock_task_sighand+0x3a/0x80
[616433.645749]  [<ffffffff8029cb6e>] getrusage+0x23e/0x260
[616433.656369]  [<ffffffff80216668>] vfs_write+0xf8/0x1b0
[616433.666815]  [<ffffffff802171a3>] sys_write+0x53/0x90
[616433.677088]  [<ffffffff8026011e>] system_call+0x7e/0x83
[616433.687710] 
[616443.108113] BUG: soft lockup detected on CPU#0!
[616443.117342] 
[616443.117343] Call Trace:
[616443.125582]  <IRQ>  [<ffffffff802bbacb>] softlockup_tick+0xfb/0x120
[616443.138293]  [<ffffffff80298107>] update_process_times+0x57/0x90
[616443.150473]  [<ffffffff802798f4>] smp_local_timer_interrupt+0x34/0x60
[616443.163520]  [<ffffffff8027a1c9>] smp_apic_timer_interrupt+0x59/0x80
[616443.176391]  [<ffffffff80260ce6>] apic_timer_interrupt+0x66/0x70
[616443.188571]  [<ffffffff80266be5>] __lock_text_start+0x5/0x10
[616443.200057]  [<ffffffff803f3eff>] __tcp_get_md5sig_pool+0xf/0x50
[616443.212234]  [<ffffffff803fd899>] tcp_v4_do_calc_md5_hash+0x59/0x2e0
[616443.225110]  [<ffffffff881b4479>] :nf_conntrack:tcp_error+0x159/0x200
[616443.238159]  [<ffffffff881b16e9>] :nf_conntrack:__nf_conntrack_find+0x19/0x120
[616443.252795]  [<ffffffff80266c39>] _read_lock_bh+0x9/0x20
[616443.263588]  [<ffffffff882c2d15>] :ip_tables:ipt_do_table+0x305/0x370
[616443.276633]  [<ffffffff8023d4bb>] tcp_v4_do_rcv+0x10b/0x520
[616443.287947]  [<ffffffff881b5ab1>] :nf_conntrack:nf_ct_deliver_cached_events+0x61/0xb0
[616443.303798]  [<ffffffff881c51c8>] :nf_conntrack_ipv4:ipv4_confirm+0x48/0x60
[616443.317881]  [<ffffffff8023586c>] nf_iterate+0x5c/0xa0
[616443.328330]  [<ffffffff8022887e>] tcp_v4_rcv+0xa0e/0xa80
[616443.339124]  [<ffffffff80235f72>] ip_local_deliver+0x1b2/0x280
[616443.350957]  [<ffffffff802370b7>] ip_rcv+0x4d7/0x540
[616443.361057]  [<ffffffff80220d7a>] netif_receive_skb+0x2fa/0x330
[616443.373067]  [<ffffffff88152641>] :e1000:e1000_clean_rx_irq+0x451/0x520
[616443.386466]  [<ffffffff8815652f>] :e1000:e1000_clean+0x7f/0x250
[616443.398470]  [<ffffffff8028d936>] run_rebalance_domains+0xe6/0x3c0
[616443.410995]  [<ffffffff8020c29e>] net_rx_action+0xbe/0x1f0
[616443.422135]  [<ffffffff80211c53>] __do_softirq+0x63/0xd0
[616443.432928]  [<ffffffff8026123c>] call_softirq+0x1c/0x28
[616443.443721]  [<ffffffff8026f32c>] do_softirq+0x2c/0x90
[616443.454167]  [<ffffffff8026f516>] do_IRQ+0xc6/0xf0
[616443.463918]  [<ffffffff80260631>] ret_from_intr+0x0/0xa
[616443.474534]  <EOI>  [<ffffffff803f4037>] tcp_free_md5sig_pool+0x17/0x60
[616443.487942]  [<ffffffff803f4030>] tcp_free_md5sig_pool+0x10/0x60
[616443.500119]  [<ffffffff803fdab1>] tcp_v4_do_calc_md5_hash+0x271/0x2e0
[616443.513164]  [<ffffffff8021f290>] __pollwait+0x0/0x130
[616443.523613]  [<ffffffff8028d820>] default_wake_function+0x0/0x10
[616443.535792]  [<ffffffff802228fc>] tcp_transmit_skb+0x55c/0x790
[616443.547627]  [<ffffffff802348ad>] __tcp_push_pending_frames+0x80d/0x950
[616443.561016]  [<ffffffff80227190>] tcp_sendmsg+0x0/0xb00
[616443.571638]  [<ffffffff80227b39>] tcp_sendmsg+0x9a9/0xb00
[616443.582606]  [<ffffffff802492df>] sock_aio_write+0x13f/0x180
[616443.594099]  [<ffffffff80217ecf>] do_sync_write+0xcf/0x120
[616443.605239]  [<ffffffff802a2a40>] autoremove_wake_function+0x0/0x30
[616443.617938]  [<ffffffff80298fda>] lock_task_sighand+0x3a/0x80
[616443.629598]  [<ffffffff8029cb6e>] getrusage+0x23e/0x260
[616443.640226]  [<ffffffff80216668>] vfs_write+0xf8/0x1b0
[616443.650672]  [<ffffffff802171a3>] sys_write+0x53/0x90
[616443.660944]  [<ffffffff8026011e>] system_call+0x7e/0x83
[616443.671564] 
[616453.093669] BUG: soft lockup detected on CPU#0!
[616453.102898] 
[616453.102899] Call Trace:
[616453.111131]  <IRQ>  [<ffffffff802bbacb>] softlockup_tick+0xfb/0x120
[616453.123842]  [<ffffffff80298107>] update_process_times+0x57/0x90
[616453.136020]  [<ffffffff802798f4>] smp_local_timer_interrupt+0x34/0x60
[616453.149063]  [<ffffffff8027a1c9>] smp_apic_timer_interrupt+0x59/0x80
[616453.161936]  [<ffffffff80260ce6>] apic_timer_interrupt+0x66/0x70
[616453.174115]  [<ffffffff80266be7>] __lock_text_start+0x7/0x10
[616453.185600]  [<ffffffff803f3eff>] __tcp_get_md5sig_pool+0xf/0x50
[616453.197778]  [<ffffffff803fd899>] tcp_v4_do_calc_md5_hash+0x59/0x2e0
[616453.210655]  [<ffffffff881b4479>] :nf_conntrack:tcp_error+0x159/0x200
[616453.223704]  [<ffffffff881b16e9>] :nf_conntrack:__nf_conntrack_find+0x19/0x120
[616453.238340]  [<ffffffff80266c39>] _read_lock_bh+0x9/0x20
[616453.249134]  [<ffffffff882c2d15>] :ip_tables:ipt_do_table+0x305/0x370
[616453.262180]  [<ffffffff8023d4bb>] tcp_v4_do_rcv+0x10b/0x520
[616453.273497]  [<ffffffff881b5ab1>] :nf_conntrack:nf_ct_deliver_cached_events+0x61/0xb0
[616453.289345]  [<ffffffff881c51c8>] :nf_conntrack_ipv4:ipv4_confirm+0x48/0x60
[616453.303428]  [<ffffffff8023586c>] nf_iterate+0x5c/0xa0
[616453.313876]  [<ffffffff8022887e>] tcp_v4_rcv+0xa0e/0xa80
[616453.324671]  [<ffffffff80235f72>] ip_local_deliver+0x1b2/0x280
[616453.336504]  [<ffffffff802370b7>] ip_rcv+0x4d7/0x540
[616453.346605]  [<ffffffff80220d7a>] netif_receive_skb+0x2fa/0x330
[616453.358616]  [<ffffffff88152641>] :e1000:e1000_clean_rx_irq+0x451/0x520
[616453.372016]  [<ffffffff8815652f>] :e1000:e1000_clean+0x7f/0x250
[616453.384021]  [<ffffffff8028d936>] run_rebalance_domains+0xe6/0x3c0
[616453.396546]  [<ffffffff8020c29e>] net_rx_action+0xbe/0x1f0
[616453.407688]  [<ffffffff80211c53>] __do_softirq+0x63/0xd0
[616453.418481]  [<ffffffff8026123c>] call_softirq+0x1c/0x28
[616453.429272]  [<ffffffff8026f32c>] do_softirq+0x2c/0x90
[616453.439717]  [<ffffffff8026f516>] do_IRQ+0xc6/0xf0
[616453.449473]  [<ffffffff80260631>] ret_from_intr+0x0/0xa
[616453.460089]  <EOI>  [<ffffffff803f4037>] tcp_free_md5sig_pool+0x17/0x60
[616453.473497]  [<ffffffff803f4030>] tcp_free_md5sig_pool+0x10/0x60
[616453.485676]  [<ffffffff803fdab1>] tcp_v4_do_calc_md5_hash+0x271/0x2e0
[616453.498720]  [<ffffffff8021f290>] __pollwait+0x0/0x130
[616453.509169]  [<ffffffff8028d820>] default_wake_function+0x0/0x10
[616453.521349]  [<ffffffff802228fc>] tcp_transmit_skb+0x55c/0x790
[616453.533186]  [<ffffffff802348ad>] __tcp_push_pending_frames+0x80d/0x950
[616453.546575]  [<ffffffff80227190>] tcp_sendmsg+0x0/0xb00
[616453.557211]  [<ffffffff80227b39>] tcp_sendmsg+0x9a9/0xb00
[616453.568184]  [<ffffffff802492df>] sock_aio_write+0x13f/0x180
[616453.579675]  [<ffffffff80217ecf>] do_sync_write+0xcf/0x120
[616453.590815]  [<ffffffff802a2a40>] autoremove_wake_function+0x0/0x30
[616453.603513]  [<ffffffff80298fda>] lock_task_sighand+0x3a/0x80
[616453.615170]  [<ffffffff8029cb6e>] getrusage+0x23e/0x260
[616453.625792]  [<ffffffff80216668>] vfs_write+0xf8/0x1b0
[616453.636238]  [<ffffffff802171a3>] sys_write+0x53/0x90
[616453.646511]  [<ffffffff8026011e>] system_call+0x7e/0x83
[616453.657130] 
[616463.079225] BUG: soft lockup detected on CPU#0!
[616463.088454] 
[616463.088455] Call Trace:
[616463.096689]  <IRQ>  [<ffffffff802bbacb>] softlockup_tick+0xfb/0x120
[616463.109400]  [<ffffffff80298107>] update_process_times+0x57/0x90
[616463.121578]  [<ffffffff802798f4>] smp_local_timer_interrupt+0x34/0x60
[616463.134621]  [<ffffffff8027a1c9>] smp_apic_timer_interrupt+0x59/0x80
[616463.147493]  [<ffffffff80260ce6>] apic_timer_interrupt+0x66/0x70
[616463.159672]  [<ffffffff80266be5>] __lock_text_start+0x5/0x10
[616463.171157]  [<ffffffff803f3eff>] __tcp_get_md5sig_pool+0xf/0x50
[616463.183333]  [<ffffffff803fd899>] tcp_v4_do_calc_md5_hash+0x59/0x2e0
[616463.196210]  [<ffffffff881b4479>] :nf_conntrack:tcp_error+0x159/0x200
[616463.209259]  [<ffffffff881b16e9>] :nf_conntrack:__nf_conntrack_find+0x19/0x120
[616463.223898]  [<ffffffff80266c39>] _read_lock_bh+0x9/0x20
[616463.234691]  [<ffffffff882c2d15>] :ip_tables:ipt_do_table+0x305/0x370
[616463.247738]  [<ffffffff8023d4bb>] tcp_v4_do_rcv+0x10b/0x520
[616463.259054]  [<ffffffff881b5ab1>] :nf_conntrack:nf_ct_deliver_cached_events+0x61/0xb0
[616463.274904]  [<ffffffff881c51c8>] :nf_conntrack_ipv4:ipv4_confirm+0x48/0x60
[616463.288989]  [<ffffffff8023586c>] nf_iterate+0x5c/0xa0
[616463.299437]  [<ffffffff8022887e>] tcp_v4_rcv+0xa0e/0xa80
[616463.310231]  [<ffffffff80235f72>] ip_local_deliver+0x1b2/0x280
[616463.322064]  [<ffffffff802370b7>] ip_rcv+0x4d7/0x540
[616463.332164]  [<ffffffff80220d7a>] netif_receive_skb+0x2fa/0x330
[616463.344175]  [<ffffffff88152641>] :e1000:e1000_clean_rx_irq+0x451/0x520
[616463.357574]  [<ffffffff8815652f>] :e1000:e1000_clean+0x7f/0x250
[616463.369579]  [<ffffffff8028d936>] run_rebalance_domains+0xe6/0x3c0
[616463.382104]  [<ffffffff8020c29e>] net_rx_action+0xbe/0x1f0
[616463.393243]  [<ffffffff80211c53>] __do_softirq+0x63/0xd0
[616463.404037]  [<ffffffff8026123c>] call_softirq+0x1c/0x28
[616463.414829]  [<ffffffff8026f32c>] do_softirq+0x2c/0x90
[616463.425273]  [<ffffffff8026f516>] do_IRQ+0xc6/0xf0
[616463.435026]  [<ffffffff80260631>] ret_from_intr+0x0/0xa
[616463.445642]  <EOI>  [<ffffffff803f4037>] tcp_free_md5sig_pool+0x17/0x60
[616463.459050]  [<ffffffff803f4030>] tcp_free_md5sig_pool+0x10/0x60
[616463.471228]  [<ffffffff803fdab1>] tcp_v4_do_calc_md5_hash+0x271/0x2e0
[616463.484272]  [<ffffffff8021f290>] __pollwait+0x0/0x130
[616463.494719]  [<ffffffff8028d820>] default_wake_function+0x0/0x10
[616463.506900]  [<ffffffff802228fc>] tcp_transmit_skb+0x55c/0x790
[616463.518733]  [<ffffffff802348ad>] __tcp_push_pending_frames+0x80d/0x950
[616463.532123]  [<ffffffff80227190>] tcp_sendmsg+0x0/0xb00
[616463.542745]  [<ffffffff80227b39>] tcp_sendmsg+0x9a9/0xb00
[616463.553714]  [<ffffffff802492df>] sock_aio_write+0x13f/0x180
[616463.565205]  [<ffffffff80217ecf>] do_sync_write+0xcf/0x120
[616463.576346]  [<ffffffff802a2a40>] autoremove_wake_function+0x0/0x30
[616463.590729]  [<ffffffff80298fda>] lock_task_sighand+0x3a/0x80
[616463.602390]  [<ffffffff8029cb6e>] getrusage+0x23e/0x260
[616463.613011]  [<ffffffff80216668>] vfs_write+0xf8/0x1b0
[616463.623456]  [<ffffffff802171a3>] sys_write+0x53/0x90
[616463.633730]  [<ffffffff8026011e>] system_call+0x7e/0x83
[616463.644350] 
[616473.064781] BUG: soft lockup detected on CPU#0!
[616473.074010] 
[616473.074011] Call Trace:
[616473.082245]  <IRQ>  [<ffffffff802bbacb>] softlockup_tick+0xfb/0x120
[616473.094956]  [<ffffffff80298107>] update_process_times+0x57/0x90
[616473.107135]  [<ffffffff802798f4>] smp_local_timer_interrupt+0x34/0x60
[616473.120180]  [<ffffffff8027a1c9>] smp_apic_timer_interrupt+0x59/0x80
[616473.133050]  [<ffffffff80260ce6>] apic_timer_interrupt+0x66/0x70
[616473.145230]  [<ffffffff80266be7>] __lock_text_start+0x7/0x10
[616473.156715]  [<ffffffff803f3eff>] __tcp_get_md5sig_pool+0xf/0x50
[616473.168894]  [<ffffffff803fd899>] tcp_v4_do_calc_md5_hash+0x59/0x2e0
[616473.181770]  [<ffffffff881b4479>] :nf_conntrack:tcp_error+0x159/0x200
[616473.194821]  [<ffffffff881b16e9>] :nf_conntrack:__nf_conntrack_find+0x19/0x120
[616473.209457]  [<ffffffff80266c39>] _read_lock_bh+0x9/0x20
[616473.220250]  [<ffffffff882c2d15>] :ip_tables:ipt_do_table+0x305/0x370
[616473.233295]  [<ffffffff8023d4bb>] tcp_v4_do_rcv+0x10b/0x520
[616473.244612]  [<ffffffff881b5ab1>] :nf_conntrack:nf_ct_deliver_cached_events+0x61/0xb0
[616473.260465]  [<ffffffff881c51c8>] :nf_conntrack_ipv4:ipv4_confirm+0x48/0x60
[616473.274548]  [<ffffffff8023586c>] nf_iterate+0x5c/0xa0
[616473.284994]  [<ffffffff8022887e>] tcp_v4_rcv+0xa0e/0xa80
[616473.295789]  [<ffffffff80235f72>] ip_local_deliver+0x1b2/0x280
[616473.307621]  [<ffffffff802370b7>] ip_rcv+0x4d7/0x540
[616473.317723]  [<ffffffff80220d7a>] netif_receive_skb+0x2fa/0x330
[616473.329735]  [<ffffffff88152641>] :e1000:e1000_clean_rx_irq+0x451/0x520
[616473.343134]  [<ffffffff8815652f>] :e1000:e1000_clean+0x7f/0x250
[616473.355140]  [<ffffffff8028d936>] run_rebalance_domains+0xe6/0x3c0
[616473.367665]  [<ffffffff8020c29e>] net_rx_action+0xbe/0x1f0
[616473.378806]  [<ffffffff80211c53>] __do_softirq+0x63/0xd0
[616473.389599]  [<ffffffff8026123c>] call_softirq+0x1c/0x28
[616473.400392]  [<ffffffff8026f32c>] do_softirq+0x2c/0x90
[616473.410837]  [<ffffffff8026f516>] do_IRQ+0xc6/0xf0
[616473.420588]  [<ffffffff80260631>] ret_from_intr+0x0/0xa
[616473.431203]  <EOI>  [<ffffffff803f4037>] tcp_free_md5sig_pool+0x17/0x60
[616473.444611]  [<ffffffff803f4030>] tcp_free_md5sig_pool+0x10/0x60
[616473.456787]  [<ffffffff803fdab1>] tcp_v4_do_calc_md5_hash+0x271/0x2e0
[616473.469832]  [<ffffffff8021f290>] __pollwait+0x0/0x130
[616473.480280]  [<ffffffff8028d820>] default_wake_function+0x0/0x10
[616473.492457]  [<ffffffff802228fc>] tcp_transmit_skb+0x55c/0x790
[616473.504292]  [<ffffffff802348ad>] __tcp_push_pending_frames+0x80d/0x950
[616473.517680]  [<ffffffff80227190>] tcp_sendmsg+0x0/0xb00
[616473.528301]  [<ffffffff80227b39>] tcp_sendmsg+0x9a9/0xb00
[616473.539270]  [<ffffffff802492df>] sock_aio_write+0x13f/0x180
[616473.550764]  [<ffffffff80217ecf>] do_sync_write+0xcf/0x120
[616473.561904]  [<ffffffff802a2a40>] autoremove_wake_function+0x0/0x30
[616473.574603]  [<ffffffff80298fda>] lock_task_sighand+0x3a/0x80
[616473.586261]  [<ffffffff8029cb6e>] getrusage+0x23e/0x260
[616473.596884]  [<ffffffff80216668>] vfs_write+0xf8/0x1b0
[616473.607330]  [<ffffffff802171a3>] sys_write+0x53/0x90
[616473.617604]  [<ffffffff8026011e>] system_call+0x7e/0x83
[616473.628224] 
[616483.050336] BUG: soft lockup detected on CPU#0!
[616483.059565] 
[616483.059566] Call Trace:
[616483.067801]  <IRQ>  [<ffffffff802bbacb>] softlockup_tick+0xfb/0x120
[616483.080511]  [<ffffffff80298107>] update_process_times+0x57/0x90
[616483.092692]  [<ffffffff802798f4>] smp_local_timer_interrupt+0x34/0x60
[616483.105735]  [<ffffffff8027a1c9>] smp_apic_timer_interrupt+0x59/0x80
[616483.118612]  [<ffffffff80260ce6>] apic_timer_interrupt+0x66/0x70
[616483.130791]  [<ffffffff80266be7>] __lock_text_start+0x7/0x10
[616483.142278]  [<ffffffff803f3eff>] __tcp_get_md5sig_pool+0xf/0x50
[616483.154454]  [<ffffffff803fd899>] tcp_v4_do_calc_md5_hash+0x59/0x2e0
[616483.167332]  [<ffffffff881b4479>] :nf_conntrack:tcp_error+0x159/0x200
[616483.180381]  [<ffffffff881b16e9>] :nf_conntrack:__nf_conntrack_find+0x19/0x120
[616483.195016]  [<ffffffff80266c39>] _read_lock_bh+0x9/0x20
[616483.205807]  [<ffffffff882c2d15>] :ip_tables:ipt_do_table+0x305/0x370
[616483.218853]  [<ffffffff8023d4bb>] tcp_v4_do_rcv+0x10b/0x520
[616483.230170]  [<ffffffff881b5ab1>] :nf_conntrack:nf_ct_deliver_cached_events+0x61/0xb0
[616483.246020]  [<ffffffff881c51c8>] :nf_conntrack_ipv4:ipv4_confirm+0x48/0x60
[616483.260106]  [<ffffffff8023586c>] nf_iterate+0x5c/0xa0
[616483.270552]  [<ffffffff8022887e>] tcp_v4_rcv+0xa0e/0xa80
[616483.281347]  [<ffffffff80235f72>] ip_local_deliver+0x1b2/0x280
[616483.293178]  [<ffffffff802370b7>] ip_rcv+0x4d7/0x540
[616483.303279]  [<ffffffff80220d7a>] netif_receive_skb+0x2fa/0x330
[616483.315290]  [<ffffffff88152641>] :e1000:e1000_clean_rx_irq+0x451/0x520
[616483.328689]  [<ffffffff8815652f>] :e1000:e1000_clean+0x7f/0x250
[616483.340694]  [<ffffffff8028d936>] run_rebalance_domains+0xe6/0x3c0
[616483.353220]  [<ffffffff8020c29e>] net_rx_action+0xbe/0x1f0
[616483.364359]  [<ffffffff80211c53>] __do_softirq+0x63/0xd0
[616483.375153]  [<ffffffff8026123c>] call_softirq+0x1c/0x28
[616483.385944]  [<ffffffff8026f32c>] do_softirq+0x2c/0x90
[616483.396388]  [<ffffffff8026f516>] do_IRQ+0xc6/0xf0
[616483.406141]  [<ffffffff80260631>] ret_from_intr+0x0/0xa
[616483.416756]  <EOI>  [<ffffffff803f4037>] tcp_free_md5sig_pool+0x17/0x60
[616483.430165]  [<ffffffff803f4030>] tcp_free_md5sig_pool+0x10/0x60
[616483.442343]  [<ffffffff803fdab1>] tcp_v4_do_calc_md5_hash+0x271/0x2e0
[616483.455388]  [<ffffffff8021f290>] __pollwait+0x0/0x130
[616483.465837]  [<ffffffff8028d820>] default_wake_function+0x0/0x10
[616483.478017]  [<ffffffff802228fc>] tcp_transmit_skb+0x55c/0x790
[616483.489853]  [<ffffffff802348ad>] __tcp_push_pending_frames+0x80d/0x950
[616483.503242]  [<ffffffff80227190>] tcp_sendmsg+0x0/0xb00
[616483.513864]  [<ffffffff80227b39>] tcp_sendmsg+0x9a9/0xb00
[616483.524833]  [<ffffffff802492df>] sock_aio_write+0x13f/0x180
[616483.536324]  [<ffffffff80217ecf>] do_sync_write+0xcf/0x120
[616483.547469]  [<ffffffff802a2a40>] autoremove_wake_function+0x0/0x30
[616483.560168]  [<ffffffff80298fda>] lock_task_sighand+0x3a/0x80
[616483.571828]  [<ffffffff8029cb6e>] getrusage+0x23e/0x260
[616483.582450]  [<ffffffff80216668>] vfs_write+0xf8/0x1b0
[616483.592897]  [<ffffffff802171a3>] sys_write+0x53/0x90
[616483.603169]  [<ffffffff8026011e>] system_call+0x7e/0x83
[616483.613788] 
[616493.035892] BUG: soft lockup detected on CPU#0!
[616493.045121] 
[616493.045122] Call Trace:
[616493.053357]  <IRQ>  [<ffffffff802bbacb>] softlockup_tick+0xfb/0x120
[616493.066068]  [<ffffffff80298107>] update_process_times+0x57/0x90
[616493.078247]  [<ffffffff802798f4>] smp_local_timer_interrupt+0x34/0x60
[616493.091289]  [<ffffffff8027a1c9>] smp_apic_timer_interrupt+0x59/0x80
[616493.104160]  [<ffffffff80260ce6>] apic_timer_interrupt+0x66/0x70
[616493.116342]  [<ffffffff80266be7>] __lock_text_start+0x7/0x10
[616493.127827]  [<ffffffff803f3eff>] __tcp_get_md5sig_pool+0xf/0x50
[616493.140004]  [<ffffffff803fd899>] tcp_v4_do_calc_md5_hash+0x59/0x2e0
[616493.152882]  [<ffffffff881b4479>] :nf_conntrack:tcp_error+0x159/0x200
[616493.165931]  [<ffffffff881b16e9>] :nf_conntrack:__nf_conntrack_find+0x19/0x120
[616493.180568]  [<ffffffff80266c39>] _read_lock_bh+0x9/0x20
[616493.191361]  [<ffffffff882c2d15>] :ip_tables:ipt_do_table+0x305/0x370
[616493.204408]  [<ffffffff8023d4bb>] tcp_v4_do_rcv+0x10b/0x520
[616493.215726]  [<ffffffff881b5ab1>] :nf_conntrack:nf_ct_deliver_cached_events+0x61/0xb0
[616493.231575]  [<ffffffff881c51c8>] :nf_conntrack_ipv4:ipv4_confirm+0x48/0x60
[616493.245660]  [<ffffffff8023586c>] nf_iterate+0x5c/0xa0
[616493.256109]  [<ffffffff8022887e>] tcp_v4_rcv+0xa0e/0xa80
[616493.266903]  [<ffffffff80235f72>] ip_local_deliver+0x1b2/0x280
[616493.278736]  [<ffffffff802370b7>] ip_rcv+0x4d7/0x540
[616493.288837]  [<ffffffff80220d7a>] netif_receive_skb+0x2fa/0x330
[616493.300847]  [<ffffffff88152641>] :e1000:e1000_clean_rx_irq+0x451/0x520
[616493.314246]  [<ffffffff8815652f>] :e1000:e1000_clean+0x7f/0x250
[616493.326249]  [<ffffffff8028d936>] run_rebalance_domains+0xe6/0x3c0
[616493.338778]  [<ffffffff8020c29e>] net_rx_action+0xbe/0x1f0
[616493.349919]  [<ffffffff80211c53>] __do_softirq+0x63/0xd0
[616493.360717]  [<ffffffff8026123c>] call_softirq+0x1c/0x28
[616493.371509]  [<ffffffff8026f32c>] do_softirq+0x2c/0x90
[616493.381954]  [<ffffffff8026f516>] do_IRQ+0xc6/0xf0
[616493.391707]  [<ffffffff80260631>] ret_from_intr+0x0/0xa
[616493.402325]  <EOI>  [<ffffffff803f4037>] tcp_free_md5sig_pool+0x17/0x60
[616493.415730]  [<ffffffff803f4030>] tcp_free_md5sig_pool+0x10/0x60
[616493.427910]  [<ffffffff803fdab1>] tcp_v4_do_calc_md5_hash+0x271/0x2e0
[616493.440957]  [<ffffffff8021f290>] __pollwait+0x0/0x130
[616493.451404]  [<ffffffff8028d820>] default_wake_function+0x0/0x10
[616493.463582]  [<ffffffff802228fc>] tcp_transmit_skb+0x55c/0x790
[616493.475422]  [<ffffffff802348ad>] __tcp_push_pending_frames+0x80d/0x950
[616493.488811]  [<ffffffff80227190>] tcp_sendmsg+0x0/0xb00
[616493.499434]  [<ffffffff80227b39>] tcp_sendmsg+0x9a9/0xb00
[616493.510402]  [<ffffffff802492df>] sock_aio_write+0x13f/0x180
[616493.521894]  [<ffffffff80217ecf>] do_sync_write+0xcf/0x120
[616493.533034]  [<ffffffff802a2a40>] autoremove_wake_function+0x0/0x30
[616493.545733]  [<ffffffff80298fda>] lock_task_sighand+0x3a/0x80
[616493.557390]  [<ffffffff8029cb6e>] getrusage+0x23e/0x260
[616493.568012]  [<ffffffff80216668>] vfs_write+0xf8/0x1b0
[616493.578459]  [<ffffffff802171a3>] sys_write+0x53/0x90
[616493.588732]  [<ffffffff8026011e>] system_call+0x7e/0x83
[616493.599351] 
[616503.021448] BUG: soft lockup detected on CPU#0!
[616503.030677] 
[616503.030677] Call Trace:
[616503.038912]  <IRQ>  [<ffffffff802bbacb>] softlockup_tick+0xfb/0x120
[616503.051624]  [<ffffffff80298107>] update_process_times+0x57/0x90
[616503.063803]  [<ffffffff802798f4>] smp_local_timer_interrupt+0x34/0x60
[616503.076847]  [<ffffffff8027a1c9>] smp_apic_timer_interrupt+0x59/0x80
[616503.089719]  [<ffffffff80260ce6>] apic_timer_interrupt+0x66/0x70
[616503.101900]  [<ffffffff80266be5>] __lock_text_start+0x5/0x10
[616503.113385]  [<ffffffff803f3eff>] __tcp_get_md5sig_pool+0xf/0x50
[616503.125561]  [<ffffffff803fd899>] tcp_v4_do_calc_md5_hash+0x59/0x2e0
[616503.138439]  [<ffffffff881b4479>] :nf_conntrack:tcp_error+0x159/0x200
[616503.151488]  [<ffffffff881b16e9>] :nf_conntrack:__nf_conntrack_find+0x19/0x120
[616503.166123]  [<ffffffff80266c39>] _read_lock_bh+0x9/0x20
[616503.176917]  [<ffffffff882c2d15>] :ip_tables:ipt_do_table+0x305/0x370
[616503.189963]  [<ffffffff8023d4bb>] tcp_v4_do_rcv+0x10b/0x520
[616503.201280]  [<ffffffff881b5ab1>] :nf_conntrack:nf_ct_deliver_cached_events+0x61/0xb0
[616503.218817]  [<ffffffff881c51c8>] :nf_conntrack_ipv4:ipv4_confirm+0x48/0x60
[616503.232902]  [<ffffffff8023586c>] nf_iterate+0x5c/0xa0
[616503.243348]  [<ffffffff8022887e>] tcp_v4_rcv+0xa0e/0xa80
[616503.254142]  [<ffffffff80235f72>] ip_local_deliver+0x1b2/0x280
[616503.265974]  [<ffffffff802370b7>] ip_rcv+0x4d7/0x540
[616503.276074]  [<ffffffff80220d7a>] netif_receive_skb+0x2fa/0x330
[616503.288084]  [<ffffffff88152641>] :e1000:e1000_clean_rx_irq+0x451/0x520
[616503.301483]  [<ffffffff8815652f>] :e1000:e1000_clean+0x7f/0x250
[616503.313487]  [<ffffffff8028d936>] run_rebalance_domains+0xe6/0x3c0
[616503.326012]  [<ffffffff8020c29e>] net_rx_action+0xbe/0x1f0
[616503.337152]  [<ffffffff80211c53>] __do_softirq+0x63/0xd0
[616503.347945]  [<ffffffff8026123c>] call_softirq+0x1c/0x28
[616503.358737]  [<ffffffff8026f32c>] do_softirq+0x2c/0x90
[616503.369181]  [<ffffffff8026f516>] do_IRQ+0xc6/0xf0
[616503.378934]  [<ffffffff80260631>] ret_from_intr+0x0/0xa
[616503.389549]  <EOI>  [<ffffffff803f4037>] tcp_free_md5sig_pool+0x17/0x60
[616503.402958]  [<ffffffff803f4030>] tcp_free_md5sig_pool+0x10/0x60
[616503.415135]  [<ffffffff803fdab1>] tcp_v4_do_calc_md5_hash+0x271/0x2e0
[616503.428180]  [<ffffffff8021f290>] __pollwait+0x0/0x130
[616503.438627]  [<ffffffff8028d820>] default_wake_function+0x0/0x10
[616503.450808]  [<ffffffff802228fc>] tcp_transmit_skb+0x55c/0x790
[616503.462642]  [<ffffffff802348ad>] __tcp_push_pending_frames+0x80d/0x950
[616503.476030]  [<ffffffff80227190>] tcp_sendmsg+0x0/0xb00
[616503.486652]  [<ffffffff80227b39>] tcp_sendmsg+0x9a9/0xb00
[616503.497621]  [<ffffffff802492df>] sock_aio_write+0x13f/0x180
[616503.509117]  [<ffffffff80217ecf>] do_sync_write+0xcf/0x120
[616503.520259]  [<ffffffff802a2a40>] autoremove_wake_function+0x0/0x30
[616503.532959]  [<ffffffff80298fda>] lock_task_sighand+0x3a/0x80
[616503.544616]  [<ffffffff8029cb6e>] getrusage+0x23e/0x260
[616503.555237]  [<ffffffff80216668>] vfs_write+0xf8/0x1b0
[616503.565683]  [<ffffffff802171a3>] sys_write+0x53/0x90
[616503.575957]  [<ffffffff8026011e>] system_call+0x7e/0x83
[616503.586577] 
[616513.007004] BUG: soft lockup detected on CPU#0!
[616513.016235] 
[616513.016236] Call Trace:
[616513.024470]  <IRQ>  [<ffffffff802bbacb>] softlockup_tick+0xfb/0x120
[616513.037179]  [<ffffffff80298107>] update_process_times+0x57/0x90
[616513.049357]  [<ffffffff802798f4>] smp_local_timer_interrupt+0x34/0x60
[616513.062400]  [<ffffffff8027a1c9>] smp_apic_timer_interrupt+0x59/0x80
[616513.075274]  [<ffffffff80260ce6>] apic_timer_interrupt+0x66/0x70
[616513.087453]  [<ffffffff80266be7>] __lock_text_start+0x7/0x10
[616513.098941]  [<ffffffff803f3eff>] __tcp_get_md5sig_pool+0xf/0x50
[616513.111120]  [<ffffffff803fd899>] tcp_v4_do_calc_md5_hash+0x59/0x2e0
[616513.123995]  [<ffffffff881b4479>] :nf_conntrack:tcp_error+0x159/0x200
[616513.137044]  [<ffffffff881b16e9>] :nf_conntrack:__nf_conntrack_find+0x19/0x120
[616513.151679]  [<ffffffff80266c39>] _read_lock_bh+0x9/0x20
[616513.162473]  [<ffffffff882c2d15>] :ip_tables:ipt_do_table+0x305/0x370
[616513.175519]  [<ffffffff8023d4bb>] tcp_v4_do_rcv+0x10b/0x520
[616513.186836]  [<ffffffff881b5ab1>] :nf_conntrack:nf_ct_deliver_cached_events+0x61/0xb0
[616513.202688]  [<ffffffff881c51c8>] :nf_conntrack_ipv4:ipv4_confirm+0x48/0x60
[616513.216771]  [<ffffffff8023586c>] nf_iterate+0x5c/0xa0
[616513.227218]  [<ffffffff8022887e>] tcp_v4_rcv+0xa0e/0xa80
[616513.238012]  [<ffffffff80235f72>] ip_local_deliver+0x1b2/0x280
[616513.249845]  [<ffffffff802370b7>] ip_rcv+0x4d7/0x540
[616513.259945]  [<ffffffff80220d7a>] netif_receive_skb+0x2fa/0x330
[616513.271954]  [<ffffffff88152641>] :e1000:e1000_clean_rx_irq+0x451/0x520
[616513.285354]  [<ffffffff8815652f>] :e1000:e1000_clean+0x7f/0x250
[616513.297357]  [<ffffffff8028d936>] run_rebalance_domains+0xe6/0x3c0
[616513.309882]  [<ffffffff8020c29e>] net_rx_action+0xbe/0x1f0
[616513.321023]  [<ffffffff80211c53>] __do_softirq+0x63/0xd0
[616513.331817]  [<ffffffff8026123c>] call_softirq+0x1c/0x28
[616513.342608]  [<ffffffff8026f32c>] do_softirq+0x2c/0x90
[616513.353053]  [<ffffffff8026f516>] do_IRQ+0xc6/0xf0
[616513.362806]  [<ffffffff80260631>] ret_from_intr+0x0/0xa
[616513.373422]  <EOI>  [<ffffffff803f4037>] tcp_free_md5sig_pool+0x17/0x60
[616513.386829]  [<ffffffff803f4030>] tcp_free_md5sig_pool+0x10/0x60
[616513.399007]  [<ffffffff803fdab1>] tcp_v4_do_calc_md5_hash+0x271/0x2e0
[616513.412052]  [<ffffffff8021f290>] __pollwait+0x0/0x130
[616513.422501]  [<ffffffff8028d820>] default_wake_function+0x0/0x10
[616513.434681]  [<ffffffff802228fc>] tcp_transmit_skb+0x55c/0x790
[616513.446516]  [<ffffffff802348ad>] __tcp_push_pending_frames+0x80d/0x950
[616513.459905]  [<ffffffff80227190>] tcp_sendmsg+0x0/0xb00
[616513.470528]  [<ffffffff80227b39>] tcp_sendmsg+0x9a9/0xb00
[616513.481496]  [<ffffffff802492df>] sock_aio_write+0x13f/0x180
[616513.492989]  [<ffffffff80217ecf>] do_sync_write+0xcf/0x120
[616513.504129]  [<ffffffff802a2a40>] autoremove_wake_function+0x0/0x30
[616513.516831]  [<ffffffff80298fda>] lock_task_sighand+0x3a/0x80
[616513.528490]  [<ffffffff8029cb6e>] getrusage+0x23e/0x260
[616513.539111]  [<ffffffff80216668>] vfs_write+0xf8/0x1b0
[616513.549557]  [<ffffffff802171a3>] sys_write+0x53/0x90
[616513.559829]  [<ffffffff8026011e>] system_call+0x7e/0x83
[616513.570449] 
[616522.992560] BUG: soft lockup detected on CPU#0!
[616523.001791] 
[616523.001791] Call Trace:
[616523.010023]  <IRQ>  [<ffffffff802bbacb>] softlockup_tick+0xfb/0x120
[616523.022736]  [<ffffffff80298107>] update_process_times+0x57/0x90
[616523.034915]  [<ffffffff802798f4>] smp_local_timer_interrupt+0x34/0x60
[616523.047958]  [<ffffffff8027a1c9>] smp_apic_timer_interrupt+0x59/0x80
[616523.060828]  [<ffffffff80260ce6>] apic_timer_interrupt+0x66/0x70
[616523.073007]  [<ffffffff80266be5>] __lock_text_start+0x5/0x10
[616523.084492]  [<ffffffff803f3eff>] __tcp_get_md5sig_pool+0xf/0x50
[616523.096672]  [<ffffffff803fd899>] tcp_v4_do_calc_md5_hash+0x59/0x2e0
[616523.109549]  [<ffffffff881b4479>] :nf_conntrack:tcp_error+0x159/0x200
[616523.122605]  [<ffffffff881b16e9>] :nf_conntrack:__nf_conntrack_find+0x19/0x120
[616523.137242]  [<ffffffff80266c39>] _read_lock_bh+0x9/0x20
[616523.148035]  [<ffffffff882c2d15>] :ip_tables:ipt_do_table+0x305/0x370
[616523.161080]  [<ffffffff8023d4bb>] tcp_v4_do_rcv+0x10b/0x520
[616523.172397]  [<ffffffff881b5ab1>] :nf_conntrack:nf_ct_deliver_cached_events+0x61/0xb0
[616523.188247]  [<ffffffff881c51c8>] :nf_conntrack_ipv4:ipv4_confirm+0x48/0x60
[616523.202332]  [<ffffffff8023586c>] nf_iterate+0x5c/0xa0
[616523.212779]  [<ffffffff8022887e>] tcp_v4_rcv+0xa0e/0xa80
[616523.223573]  [<ffffffff80235f72>] ip_local_deliver+0x1b2/0x280
[616523.235406]  [<ffffffff802370b7>] ip_rcv+0x4d7/0x540
[616523.245507]  [<ffffffff80220d7a>] netif_receive_skb+0x2fa/0x330
[616523.257518]  [<ffffffff88152641>] :e1000:e1000_clean_rx_irq+0x451/0x520
[616523.270917]  [<ffffffff8815652f>] :e1000:e1000_clean+0x7f/0x250
[616523.282921]  [<ffffffff8028d936>] run_rebalance_domains+0xe6/0x3c0
[616523.295446]  [<ffffffff8020c29e>] net_rx_action+0xbe/0x1f0
[616523.306586]  [<ffffffff80211c53>] __do_softirq+0x63/0xd0
[616523.317379]  [<ffffffff8026123c>] call_softirq+0x1c/0x28
[616523.328172]  [<ffffffff8026f32c>] do_softirq+0x2c/0x90
[616523.338617]  [<ffffffff8026f516>] do_IRQ+0xc6/0xf0
[616523.348370]  [<ffffffff80260631>] ret_from_intr+0x0/0xa
[616523.358990]  <EOI>  [<ffffffff803f4037>] tcp_free_md5sig_pool+0x17/0x60
[616523.372398]  [<ffffffff803f4030>] tcp_free_md5sig_pool+0x10/0x60
[616523.384576]  [<ffffffff803fdab1>] tcp_v4_do_calc_md5_hash+0x271/0x2e0
[616523.397621]  [<ffffffff8021f290>] __pollwait+0x0/0x130
[616523.408069]  [<ffffffff8028d820>] default_wake_function+0x0/0x10
[616523.420247]  [<ffffffff802228fc>] tcp_transmit_skb+0x55c/0x790
[616523.432082]  [<ffffffff802348ad>] __tcp_push_pending_frames+0x80d/0x950
[616523.445472]  [<ffffffff80227190>] tcp_sendmsg+0x0/0xb00
[616523.456094]  [<ffffffff80227b39>] tcp_sendmsg+0x9a9/0xb00
[616523.467063]  [<ffffffff802492df>] sock_aio_write+0x13f/0x180
[616523.478554]  [<ffffffff80217ecf>] do_sync_write+0xcf/0x120
[616523.489694]  [<ffffffff802a2a40>] autoremove_wake_function+0x0/0x30
[616523.502393]  [<ffffffff80298fda>] lock_task_sighand+0x3a/0x80
[616523.514053]  [<ffffffff8029cb6e>] getrusage+0x23e/0x260
[616523.524674]  [<ffffffff80216668>] vfs_write+0xf8/0x1b0
[616523.535120]  [<ffffffff802171a3>] sys_write+0x53/0x90
[616523.545393]  [<ffffffff8026011e>] system_call+0x7e/0x83
[616523.556013] 
[616532.978115] BUG: soft lockup detected on CPU#0!
[616532.987344] 
[616532.987345] Call Trace:
[616532.995576]  <IRQ>  [<ffffffff802bbacb>] softlockup_tick+0xfb/0x120
[616533.008288]  [<ffffffff80298107>] update_process_times+0x57/0x90
[616533.020465]  [<ffffffff802798f4>] smp_local_timer_interrupt+0x34/0x60
[616533.033508]  [<ffffffff8027a1c9>] smp_apic_timer_interrupt+0x59/0x80
[616533.046378]  [<ffffffff80260ce6>] apic_timer_interrupt+0x66/0x70
[616533.058560]  [<ffffffff80266be7>] __lock_text_start+0x7/0x10
[616533.070045]  [<ffffffff803f3eff>] __tcp_get_md5sig_pool+0xf/0x50
[616533.082223]  [<ffffffff803fd899>] tcp_v4_do_calc_md5_hash+0x59/0x2e0
[616533.095099]  [<ffffffff881b4479>] :nf_conntrack:tcp_error+0x159/0x200
[616533.108149]  [<ffffffff881b16e9>] :nf_conntrack:__nf_conntrack_find+0x19/0x120
[616533.122786]  [<ffffffff80266c39>] _read_lock_bh+0x9/0x20
[616533.133576]  [<ffffffff882c2d15>] :ip_tables:ipt_do_table+0x305/0x370
[616533.146622]  [<ffffffff8023d4bb>] tcp_v4_do_rcv+0x10b/0x520
[616533.157939]  [<ffffffff881b5ab1>] :nf_conntrack:nf_ct_deliver_cached_events+0x61/0xb0
[616533.173788]  [<ffffffff881c51c8>] :nf_conntrack_ipv4:ipv4_confirm+0x48/0x60
[616533.187873]  [<ffffffff8023586c>] nf_iterate+0x5c/0xa0
[616533.198320]  [<ffffffff8022887e>] tcp_v4_rcv+0xa0e/0xa80
[616533.209117]  [<ffffffff80235f72>] ip_local_deliver+0x1b2/0x280
[616533.220949]  [<ffffffff802370b7>] ip_rcv+0x4d7/0x540
[616533.231053]  [<ffffffff80220d7a>] netif_receive_skb+0x2fa/0x330
[616533.243066]  [<ffffffff88152641>] :e1000:e1000_clean_rx_irq+0x451/0x520
[616533.256466]  [<ffffffff8815652f>] :e1000:e1000_clean+0x7f/0x250
[616533.268471]  [<ffffffff8028d936>] run_rebalance_domains+0xe6/0x3c0
[616533.280996]  [<ffffffff8020c29e>] net_rx_action+0xbe/0x1f0
[616533.292137]  [<ffffffff80211c53>] __do_softirq+0x63/0xd0
[616533.302930]  [<ffffffff8026123c>] call_softirq+0x1c/0x28
[616533.313723]  [<ffffffff8026f32c>] do_softirq+0x2c/0x90
[616533.324168]  [<ffffffff8026f516>] do_IRQ+0xc6/0xf0
[616533.333919]  [<ffffffff80260631>] ret_from_intr+0x0/0xa
[616533.344535]  <EOI>  [<ffffffff803f4037>] tcp_free_md5sig_pool+0x17/0x60
[616533.357942]  [<ffffffff803f4030>] tcp_free_md5sig_pool+0x10/0x60
[616533.370119]  [<ffffffff803fdab1>] tcp_v4_do_calc_md5_hash+0x271/0x2e0
[616533.383166]  [<ffffffff8021f290>] __pollwait+0x0/0x130
[616533.393614]  [<ffffffff8028d820>] default_wake_function+0x0/0x10
[616533.405792]  [<ffffffff802228fc>] tcp_transmit_skb+0x55c/0x790
[616533.417628]  [<ffffffff802348ad>] __tcp_push_pending_frames+0x80d/0x950
[616533.431017]  [<ffffffff80227190>] tcp_sendmsg+0x0/0xb00
[616533.443328]  [<ffffffff80227b39>] tcp_sendmsg+0x9a9/0xb00
[616533.454296]  [<ffffffff802492df>] sock_aio_write+0x13f/0x180
[616533.465787]  [<ffffffff80217ecf>] do_sync_write+0xcf/0x120
[616533.476928]  [<ffffffff802a2a40>] autoremove_wake_function+0x0/0x30
[616533.489625]  [<ffffffff80298fda>] lock_task_sighand+0x3a/0x80
[616533.501285]  [<ffffffff8029cb6e>] getrusage+0x23e/0x260
[616533.511906]  [<ffffffff80216668>] vfs_write+0xf8/0x1b0
[616533.522353]  [<ffffffff802171a3>] sys_write+0x53/0x90
[616533.532626]  [<ffffffff8026011e>] system_call+0x7e/0x83
[616533.543253] 
