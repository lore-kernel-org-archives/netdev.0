From: Witold Baryluk <baryluk@smp.if.uj.edu.pl>
Subject: Re: [Bug 42754] New: BUG: sleeping function called from invalid
 context at mm/memory.c:3924
Date: Thu, 16 Feb 2012 16:10:20 +0100
Message-ID: <20120216151019.GC19642@smp.if.uj.edu.pl>
References: <bug-42754-27@https.bugzilla.kernel.org/>
 <20120209191317.2fbad57b.akpm@linux-foundation.org>
 <20120210122657.GA9347@smp.if.uj.edu.pl>
 <20120212175004.GM3737@linux.vnet.ibm.com>
 <1329310952.2293.80.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	rostedt@goodmis.org, davej@redhat.com,
	David Miller <davem@davemloft.net>,
	Glauber Costa <glommer@parallels.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smp.if.uj.edu.pl ([149.156.82.206]:60620 "EHLO smp.if.uj.edu.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752389Ab2BPPK0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Feb 2012 10:10:26 -0500
Content-Disposition: inline
In-Reply-To: <1329310952.2293.80.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02-15 14:02, Peter Zijlstra wrote:
> On Sun, 2012-02-12 at 09:50 -0800, Paul E. McKenney wrote:
> > > I do not know why lockdep is disabled, because I configured kernel to
> > > keep telling my about lock dependency problems even after showing first
> > > one. AFAIK. 
> 
> That setting is only relevant to RCU, normal lockdep reports will always
> disable lockdep.

One more thing about a bug.

I was able to reproduce bug yestarday , and again today.

First one is again in NetworkManager process (just after loging in to
gnome, exactly like previously), and again NetworkManager process is
killed. And again restarting NM manually make it happy (and works
without further problems). So indeed it looks to be problem with
netlink, because netlink_recvmsg is common call here.

Second one is also in netlink, but process is this time ip, and message
is

[ 9136.204156] BUG: sleeping function called from invalid context at kernel/mutex.c:271

full stacks bellow.

Regards,
Witek

1)

[    0.000000] Linux version 3.3.0-rc3-t43-devel-smp-00188-g3ec1e88-dirty (baryluk@sredniczarny) (gcc version 4.6.2 (Debian 4.6.2-14) ) #22 SMP Sat Feb 11 23:16:44 CET 2012
..
[ 1078.282836] BUG: sleeping function called from invalid context at mm/memory.c:3924
[ 1078.282843] in_atomic(): 1, irqs_disabled(): 0, pid: 3953, name: NetworkManager
[ 1078.282847] INFO: lockdep is turned off.
[ 1078.282852] Pid: 3953, comm: NetworkManager Tainted: G        W  O 3.3.0-rc3-t43-devel-smp-00188-g3ec1e88-dirty #22
[ 1078.282856] Call Trace:
[ 1078.282868]  [<c107d554>] __might_sleep+0x124/0x1d0
[ 1078.282875]  [<c11400ee>] might_fault+0x2e/0xb0
[ 1078.282882]  [<c131d3ab>] copy_to_user+0x3b/0x60
[ 1078.282889]  [<c1568172>] put_cmsg+0x52/0xd0
[ 1078.282903]  [<c159a917>] netlink_recvmsg+0x287/0x340
[ 1078.282910]  [<c1557aa3>] sock_recvmsg+0xd3/0x110
[ 1078.282916]  [<c1140114>] ? might_fault+0x54/0xb0
[ 1078.282921]  [<c15663bc>] ? verify_iovec+0x4c/0xc0
[ 1078.282926]  [<c15579d0>] ? sock_sendmsg_nosec+0x100/0x100
[ 1078.282931]  [<c15588f4>] __sys_recvmsg+0x114/0x1e0
[ 1078.282938]  [<c1082752>] ? check_preempt_curr+0x72/0x90
[ 1078.282943]  [<c1082be2>] ? ttwu_queue+0x42/0xc0
[ 1078.282949]  [<c10b26f1>] ? __lock_acquired+0x2e1/0x330
[ 1078.282956]  [<c1177a65>] ? fget_light+0xc5/0x410
[ 1078.282961]  [<c1177a79>] ? fget_light+0xd9/0x410
[ 1078.282965]  [<c11779e5>] ? fget_light+0x45/0x410
[ 1078.282971]  [<c155a5b9>] sys_recvmsg+0x39/0x60
[ 1078.282976]  [<c155ab13>] sys_socketcall+0x2e3/0x330
[ 1078.282982]  [<c17adacd>] ? sysenter_exit+0xf/0x1a
[ 1078.282988]  [<c131cba8>] ? trace_hardirqs_on_thunk+0xc/0x10
[ 1078.282993]  [<c17ada98>] sysenter_do_call+0x12/0x38
[ 1078.282999]  [<c17a007b>] ? trace_packet+0x104/0x154
[ 1078.283003] BUG: scheduling while atomic: NetworkManager/3953/0x10000002
[ 1078.283006] INFO: lockdep is turned off.
[ 1078.283009] Modules linked in: pci_stub vboxpci(O) vboxnetadp(O) vboxnetflt(O) vboxdrv(O) pktcdvd ebtable_nat ebtables xt_CHECKSUM acpi_cpufreq mperf irtty_sir sir_dev irda crc_ccitt dummy ppdev lp bnep bluetooth lib80211_crypt_ccmp uinput nfsd pcmcia yenta_socket i2c_i801 ipw2200 pcmcia_rsrc pcmcia_core radeon libipw floppy video parport_pc parport ttm drm_kms_helper drm i2c_algo_bit cfbfillrect cfbcopyarea cfbimgblt intel_agp intel_gtt agpgart raid10 raid456 async_memcpy async_pq async_xor xor async_raid6_recov async_tx raid6_pq sr_mod cdrom [last unloaded: scsi_wait_scan]
[ 1078.283103] Pid: 3953, comm: NetworkManager Tainted: G        W  O 3.3.0-rc3-t43-devel-smp-00188-g3ec1e88-dirty #22
[ 1078.283106] Call Trace:
[ 1078.283112]  [<c178fb87>] __schedule_bug+0x7d/0x84
[ 1078.283118]  [<c17a3eea>] __schedule+0x6ca/0x780
[ 1078.283125]  [<c101995c>] ? show_trace_log_lvl+0x4c/0x60
[ 1078.283132]  [<c178da7f>] ? dump_stack+0x73/0x7a
[ 1078.283137]  [<c107d554>] ? __might_sleep+0x124/0x1d0
[ 1078.283142]  [<c1082a8b>] __cond_resched+0x1b/0x30
[ 1078.283146]  [<c17a4019>] _cond_resched+0x29/0x30
[ 1078.283151]  [<c11400f3>] might_fault+0x33/0xb0
[ 1078.283156]  [<c131d3ab>] copy_to_user+0x3b/0x60
[ 1078.283161]  [<c1568172>] put_cmsg+0x52/0xd0
[ 1078.283166]  [<c159a917>] netlink_recvmsg+0x287/0x340
[ 1078.283172]  [<c1557aa3>] sock_recvmsg+0xd3/0x110
[ 1078.283177]  [<c1140114>] ? might_fault+0x54/0xb0
[ 1078.283183]  [<c15663bc>] ? verify_iovec+0x4c/0xc0
[ 1078.283188]  [<c15579d0>] ? sock_sendmsg_nosec+0x100/0x100
[ 1078.283192]  [<c15588f4>] __sys_recvmsg+0x114/0x1e0
[ 1078.283198]  [<c1082752>] ? check_preempt_curr+0x72/0x90
[ 1078.283219]  [<c1082be2>] ? ttwu_queue+0x42/0xc0
[ 1078.283224]  [<c10b26f1>] ? __lock_acquired+0x2e1/0x330
[ 1078.283229]  [<c1177a65>] ? fget_light+0xc5/0x410
[ 1078.283234]  [<c1177a79>] ? fget_light+0xd9/0x410
[ 1078.283239]  [<c11779e5>] ? fget_light+0x45/0x410
[ 1078.283244]  [<c155a5b9>] sys_recvmsg+0x39/0x60
[ 1078.283249]  [<c155ab13>] sys_socketcall+0x2e3/0x330
[ 1078.283254]  [<c17adacd>] ? sysenter_exit+0xf/0x1a
[ 1078.283259]  [<c131cba8>] ? trace_hardirqs_on_thunk+0xc/0x10
[ 1078.283264]  [<c17ada98>] sysenter_do_call+0x12/0x38
[ 1078.283270]  [<c17a007b>] ? trace_packet+0x104/0x154
[ 1078.289513] BUG: scheduling while atomic: NetworkManager/3953/0x10000002
[ 1078.289519] INFO: lockdep is turned off.
[ 1078.289522] Modules linked in: pci_stub vboxpci(O) vboxnetadp(O) vboxnetflt(O) vboxdrv(O) pktcdvd ebtable_nat ebtables xt_CHECKSUM acpi_cpufreq mperf irtty_sir sir_dev irda crc_ccitt dummy ppdev lp bnep bluetooth lib80211_crypt_ccmp uinput nfsd pcmcia yenta_socket i2c_i801 ipw2200 pcmcia_rsrc pcmcia_core radeon libipw floppy video parport_pc parport ttm drm_kms_helper drm i2c_algo_bit cfbfillrect cfbcopyarea cfbimgblt intel_agp intel_gtt agpgart raid10 raid456 async_memcpy async_pq async_xor xor async_raid6_recov async_tx raid6_pq sr_mod cdrom [last unloaded: scsi_wait_scan]
[ 1078.289616] Pid: 3953, comm: NetworkManager Tainted: G        W  O 3.3.0-rc3-t43-devel-smp-00188-g3ec1e88-dirty #22
[ 1078.289620] Call Trace:
[ 1078.289631]  [<c178fb87>] __schedule_bug+0x7d/0x84
[ 1078.289637]  [<c17a3eea>] __schedule+0x6ca/0x780
[ 1078.289644]  [<c1083242>] ? try_to_wake_up+0x152/0x1d0
[ 1078.289651]  [<c10b26f1>] ? __lock_acquired+0x2e1/0x330
[ 1078.289658]  [<c10d0fb8>] ? audit_buffer_free+0x28/0x70
[ 1078.289663]  [<c107d465>] ? __might_sleep+0x35/0x1d0
[ 1078.289668]  [<c1082a8b>] __cond_resched+0x1b/0x30
[ 1078.289673]  [<c17a4019>] _cond_resched+0x29/0x30
[ 1078.289680]  [<c11631a3>] kmem_cache_alloc+0x43/0x2b0
[ 1078.289685]  [<c10b13ab>] ? trace_hardirqs_on+0xb/0x10
[ 1078.289692]  [<c10790ba>] ? prepare_creds+0x2a/0x100
[ 1078.289697]  [<c10790ba>] prepare_creds+0x2a/0x100
[ 1078.289704]  [<c117ebd5>] do_coredump+0x85/0x440
[ 1078.289709]  [<c1162e5d>] ? kmem_cache_free+0x12d/0x1e0
[ 1078.289715]  [<c105c602>] ? __sigqueue_free+0x32/0x40
[ 1078.289719]  [<c105c602>] ? __sigqueue_free+0x32/0x40
[ 1078.289724]  [<c105c602>] ? __sigqueue_free+0x32/0x40
[ 1078.289728]  [<c105c6c2>] ? collect_signal+0xb2/0x190
[ 1078.289734]  [<c10609d5>] ? get_signal_to_deliver+0x185/0x470
[ 1078.289739]  [<c17a5507>] ? _raw_spin_unlock_irq+0x27/0x40
[ 1078.289744]  [<c10b13ab>] ? trace_hardirqs_on+0xb/0x10
[ 1078.289751]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.289756]  [<c1060a0c>] get_signal_to_deliver+0x1bc/0x470
[ 1078.289760]  [<c17a5507>] ? _raw_spin_unlock_irq+0x27/0x40
[ 1078.289766]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.289773]  [<c10169df>] do_signal+0x3f/0xd0
[ 1078.289777]  [<c1060e43>] ? set_current_blocked+0x43/0x50
[ 1078.289782]  [<c17a5507>] ? _raw_spin_unlock_irq+0x27/0x40
[ 1078.289788]  [<c178ee99>] ? bad_area_nosemaphore+0x17/0x19
[ 1078.289793]  [<c17a96dc>] ? do_page_fault+0x3fc/0x4f0
[ 1078.289800]  [<c155ab13>] ? sys_socketcall+0x2e3/0x330
[ 1078.289805]  [<c17a5d56>] ? work_notifysig+0x11/0x2b
[ 1078.289810]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.289815]  [<c10b1298>] ? trace_hardirqs_on_caller+0x18/0x120
[ 1078.289820]  [<c1016ccd>] do_notify_resume+0x5d/0x80
[ 1078.289825]  [<c17a5d6a>] work_notifysig+0x25/0x2b
[ 1078.289830]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.293674] BUG: scheduling while atomic: NetworkManager/3953/0x10000002
[ 1078.293680] INFO: lockdep is turned off.
[ 1078.293682] Modules linked in: pci_stub vboxpci(O) vboxnetadp(O) vboxnetflt(O) vboxdrv(O) pktcdvd ebtable_nat ebtables xt_CHECKSUM acpi_cpufreq mperf irtty_sir sir_dev irda crc_ccitt dummy ppdev lp bnep bluetooth lib80211_crypt_ccmp uinput nfsd pcmcia yenta_socket i2c_i801 ipw2200 pcmcia_rsrc pcmcia_core radeon libipw floppy video parport_pc parport ttm drm_kms_helper drm i2c_algo_bit cfbfillrect cfbcopyarea cfbimgblt intel_agp intel_gtt agpgart raid10 raid456 async_memcpy async_pq async_xor xor async_raid6_recov async_tx raid6_pq sr_mod cdrom [last unloaded: scsi_wait_scan]
[ 1078.293851] Pid: 3953, comm: NetworkManager Tainted: G        W  O 3.3.0-rc3-t43-devel-smp-00188-g3ec1e88-dirty #22
[ 1078.293855] Call Trace:
[ 1078.293865]  [<c178fb87>] __schedule_bug+0x7d/0x84
[ 1078.293871]  [<c17a3eea>] __schedule+0x6ca/0x780
[ 1078.293879]  [<c1083242>] ? try_to_wake_up+0x152/0x1d0
[ 1078.293884]  [<c17a5585>] ? _raw_spin_unlock_irqrestore+0x65/0x70
[ 1078.293890]  [<c10adcef>] ? trace_hardirqs_off_caller+0x1f/0x130
[ 1078.293908]  [<c107d465>] ? __might_sleep+0x35/0x1d0
[ 1078.293913]  [<c17a5585>] ? _raw_spin_unlock_irqrestore+0x65/0x70
[ 1078.293918]  [<c1082a8b>] __cond_resched+0x1b/0x30
[ 1078.293923]  [<c17a4019>] _cond_resched+0x29/0x30
[ 1078.293927]  [<c17a404e>] wait_for_common+0x2e/0x120
[ 1078.293934]  [<c117d7b0>] ? coredump_wait+0x2d0/0x350
[ 1078.293939]  [<c17a4217>] wait_for_completion+0x17/0x20
[ 1078.293944]  [<c117d793>] coredump_wait+0x2b3/0x350
[ 1078.293950]  [<c10790ba>] ? prepare_creds+0x2a/0x100
[ 1078.293955]  [<c10790ba>] ? prepare_creds+0x2a/0x100
[ 1078.293960]  [<c117ec08>] do_coredump+0xb8/0x440
[ 1078.293967]  [<c1162e5d>] ? kmem_cache_free+0x12d/0x1e0
[ 1078.293973]  [<c105c602>] ? __sigqueue_free+0x32/0x40
[ 1078.293977]  [<c105c602>] ? __sigqueue_free+0x32/0x40
[ 1078.293983]  [<c10609d5>] ? get_signal_to_deliver+0x185/0x470
[ 1078.293989]  [<c10b13ab>] ? trace_hardirqs_on+0xb/0x10
[ 1078.293995]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.294000]  [<c1060a0c>] get_signal_to_deliver+0x1bc/0x470
[ 1078.294005]  [<c17a5507>] ? _raw_spin_unlock_irq+0x27/0x40
[ 1078.294010]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.294016]  [<c10169df>] do_signal+0x3f/0xd0
[ 1078.294021]  [<c1060e43>] ? set_current_blocked+0x43/0x50
[ 1078.294026]  [<c17a5507>] ? _raw_spin_unlock_irq+0x27/0x40
[ 1078.294031]  [<c178ee99>] ? bad_area_nosemaphore+0x17/0x19
[ 1078.294036]  [<c17a96dc>] ? do_page_fault+0x3fc/0x4f0
[ 1078.294043]  [<c155ab13>] ? sys_socketcall+0x2e3/0x330
[ 1078.294048]  [<c17a5d56>] ? work_notifysig+0x11/0x2b
[ 1078.294053]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.294058]  [<c10b1298>] ? trace_hardirqs_on_caller+0x18/0x120
[ 1078.294063]  [<c1016ccd>] do_notify_resume+0x5d/0x80
[ 1078.294068]  [<c17a5d6a>] work_notifysig+0x25/0x2b
[ 1078.294073]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.294105] BUG: scheduling while atomic: NetworkManager/3953/0x10000002
[ 1078.294108] INFO: lockdep is turned off.
[ 1078.294111] Modules linked in: pci_stub vboxpci(O) vboxnetadp(O) vboxnetflt(O) vboxdrv(O) pktcdvd ebtable_nat ebtables xt_CHECKSUM acpi_cpufreq mperf irtty_sir sir_dev irda crc_ccitt dummy ppdev lp bnep bluetooth lib80211_crypt_ccmp uinput nfsd pcmcia yenta_socket i2c_i801 ipw2200 pcmcia_rsrc pcmcia_core radeon libipw floppy video parport_pc parport ttm drm_kms_helper drm i2c_algo_bit cfbfillrect cfbcopyarea cfbimgblt intel_agp intel_gtt agpgart raid10 raid456 async_memcpy async_pq async_xor xor async_raid6_recov async_tx raid6_pq sr_mod cdrom [last unloaded: scsi_wait_scan]
[ 1078.294193] Pid: 3953, comm: NetworkManager Tainted: G        W  O 3.3.0-rc3-t43-devel-smp-00188-g3ec1e88-dirty #22
[ 1078.294196] Call Trace:
[ 1078.294201]  [<c178fb87>] __schedule_bug+0x7d/0x84
[ 1078.294206]  [<c17a3eea>] __schedule+0x6ca/0x780
[ 1078.294212]  [<c10e5e19>] ? __call_rcu+0xd9/0x3a0
[ 1078.294217]  [<c10b1298>] ? trace_hardirqs_on_caller+0x18/0x120
[ 1078.294222]  [<c10b13ab>] ? trace_hardirqs_on+0xb/0x10
[ 1078.294227]  [<c10b13ab>] ? trace_hardirqs_on+0xb/0x10
[ 1078.294233]  [<c10791c0>] ? release_tgcred.isra.10+0x30/0x30
[ 1078.294238]  [<c107d465>] ? __might_sleep+0x35/0x1d0
[ 1078.294242]  [<c1079274>] ? __put_cred+0x34/0x40
[ 1078.294247]  [<c1082a8b>] __cond_resched+0x1b/0x30
[ 1078.294252]  [<c17a4019>] _cond_resched+0x29/0x30
[ 1078.294256]  [<c17a3548>] down_read+0x28/0x8a
[ 1078.294261]  [<c1060cde>] exit_signals+0x1e/0x110
[ 1078.294268]  [<c104e342>] do_exit+0x92/0x450
[ 1078.294273]  [<c10609d5>] ? get_signal_to_deliver+0x185/0x470
[ 1078.294278]  [<c104e848>] do_group_exit+0x38/0xa0
[ 1078.294284]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.294288]  [<c1060a16>] get_signal_to_deliver+0x1c6/0x470
[ 1078.294293]  [<c17a5507>] ? _raw_spin_unlock_irq+0x27/0x40
[ 1078.294299]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.294304]  [<c10169df>] do_signal+0x3f/0xd0
[ 1078.294309]  [<c1060e43>] ? set_current_blocked+0x43/0x50
[ 1078.294314]  [<c17a5507>] ? _raw_spin_unlock_irq+0x27/0x40
[ 1078.294318]  [<c178ee99>] ? bad_area_nosemaphore+0x17/0x19
[ 1078.294323]  [<c17a96dc>] ? do_page_fault+0x3fc/0x4f0
[ 1078.294329]  [<c155ab13>] ? sys_socketcall+0x2e3/0x330
[ 1078.294334]  [<c17a5d56>] ? work_notifysig+0x11/0x2b
[ 1078.294339]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.294344]  [<c10b1298>] ? trace_hardirqs_on_caller+0x18/0x120
[ 1078.294349]  [<c1016ccd>] do_notify_resume+0x5d/0x80
[ 1078.294354]  [<c17a5d6a>] work_notifysig+0x25/0x2b
[ 1078.294359]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.298522] note: NetworkManager[3953] exited with preempt_count 1
[ 1078.299425] BUG: scheduling while atomic: NetworkManager/3953/0x10000002
[ 1078.299429] INFO: lockdep is turned off.
[ 1078.299432] Modules linked in: pci_stub vboxpci(O) vboxnetadp(O) vboxnetflt(O) vboxdrv(O) pktcdvd ebtable_nat ebtables xt_CHECKSUM acpi_cpufreq mperf irtty_sir sir_dev irda crc_ccitt dummy ppdev lp bnep bluetooth lib80211_crypt_ccmp uinput nfsd pcmcia yenta_socket i2c_i801 ipw2200 pcmcia_rsrc pcmcia_core radeon libipw floppy video parport_pc parport ttm drm_kms_helper drm i2c_algo_bit cfbfillrect cfbcopyarea cfbimgblt intel_agp intel_gtt agpgart raid10 raid456 async_memcpy async_pq async_xor xor async_raid6_recov async_tx raid6_pq sr_mod cdrom [last unloaded: scsi_wait_scan]
[ 1078.299525] Pid: 3953, comm: NetworkManager Tainted: G        W  O 3.3.0-rc3-t43-devel-smp-00188-g3ec1e88-dirty #22
[ 1078.299529] Call Trace:
[ 1078.299539]  [<c178fb87>] __schedule_bug+0x7d/0x84
[ 1078.299545]  [<c17a3eea>] __schedule+0x6ca/0x780
[ 1078.299551]  [<c156069d>] ? skb_dequeue+0x4d/0x70
[ 1078.299556]  [<c17a5556>] ? _raw_spin_unlock_irqrestore+0x36/0x70
[ 1078.299563]  [<c10b1298>] ? trace_hardirqs_on_caller+0x18/0x120
[ 1078.299569]  [<c10e5e19>] ? __call_rcu+0xd9/0x3a0
[ 1078.299574]  [<c10b1298>] ? trace_hardirqs_on_caller+0x18/0x120
[ 1078.299579]  [<c10b13ab>] ? trace_hardirqs_on+0xb/0x10
[ 1078.299584]  [<c107d465>] ? __might_sleep+0x35/0x1d0
[ 1078.299590]  [<c1082a8b>] __cond_resched+0x1b/0x30
[ 1078.299594]  [<c17a4019>] _cond_resched+0x29/0x30
[ 1078.299601]  [<c118d316>] dput+0x176/0x220
[ 1078.299606]  [<c11783ac>] __fput+0x12c/0x1d0
[ 1078.299611]  [<c117846d>] fput+0x1d/0x30
[ 1078.299616]  [<c1173834>] filp_close+0x54/0x80
[ 1078.299622]  [<c104c1f8>] close_files+0xf8/0x1f0
[ 1078.299627]  [<c104c128>] ? close_files+0x28/0x1f0
[ 1078.299633]  [<c104c304>] put_files_struct.part.12+0x14/0x180
[ 1078.299639]  [<c132d4ce>] ? do_raw_spin_unlock+0x4e/0x90
[ 1078.299644]  [<c104de8d>] put_files_struct+0x1d/0x30
[ 1078.299649]  [<c104df43>] exit_files+0x43/0x50
[ 1078.299654]  [<c104e3fd>] do_exit+0x14d/0x450
[ 1078.299659]  [<c104e848>] do_group_exit+0x38/0xa0
[ 1078.299666]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.299671]  [<c1060a16>] get_signal_to_deliver+0x1c6/0x470
[ 1078.299676]  [<c17a5507>] ? _raw_spin_unlock_irq+0x27/0x40
[ 1078.299682]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.299689]  [<c10169df>] do_signal+0x3f/0xd0
[ 1078.299694]  [<c1060e43>] ? set_current_blocked+0x43/0x50
[ 1078.299698]  [<c17a5507>] ? _raw_spin_unlock_irq+0x27/0x40
[ 1078.299704]  [<c178ee99>] ? bad_area_nosemaphore+0x17/0x19
[ 1078.299709]  [<c17a96dc>] ? do_page_fault+0x3fc/0x4f0
[ 1078.299715]  [<c155ab13>] ? sys_socketcall+0x2e3/0x330
[ 1078.299720]  [<c17a5d56>] ? work_notifysig+0x11/0x2b
[ 1078.299725]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.299730]  [<c10b1298>] ? trace_hardirqs_on_caller+0x18/0x120
[ 1078.299735]  [<c1016ccd>] do_notify_resume+0x5d/0x80
[ 1078.299740]  [<c17a5d6a>] work_notifysig+0x25/0x2b
[ 1078.299745]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.308465] BUG: scheduling while atomic: NetworkManager/3953/0x10000002
[ 1078.308471] INFO: lockdep is turned off.
[ 1078.308474] Modules linked in: pci_stub vboxpci(O) vboxnetadp(O) vboxnetflt(O) vboxdrv(O) pktcdvd ebtable_nat ebtables xt_CHECKSUM acpi_cpufreq mperf irtty_sir sir_dev irda crc_ccitt dummy ppdev lp bnep bluetooth lib80211_crypt_ccmp uinput nfsd pcmcia yenta_socket i2c_i801 ipw2200 pcmcia_rsrc pcmcia_core radeon libipw floppy video parport_pc parport ttm drm_kms_helper drm i2c_algo_bit cfbfillrect cfbcopyarea cfbimgblt intel_agp intel_gtt agpgart raid10 raid456 async_memcpy async_pq async_xor xor async_raid6_recov async_tx raid6_pq sr_mod cdrom [last unloaded: scsi_wait_scan]
[ 1078.308650] Pid: 3953, comm: NetworkManager Tainted: G        W  O 3.3.0-rc3-t43-devel-smp-00188-g3ec1e88-dirty #22
[ 1078.308655] Call Trace:
[ 1078.308666]  [<c178fb87>] __schedule_bug+0x7d/0x84
[ 1078.308672]  [<c17a3eea>] __schedule+0x6ca/0x780
[ 1078.308678]  [<c1088b87>] ? __enqueue_entity+0x77/0x80
[ 1078.308685]  [<c1081474>] ? resched_task+0x24/0x70
[ 1078.308690]  [<c108d2be>] ? check_preempt_wakeup+0x19e/0x230
[ 1078.308696]  [<c1082752>] ? check_preempt_curr+0x72/0x90
[ 1078.308701]  [<c1082be2>] ? ttwu_queue+0x42/0xc0
[ 1078.308705]  [<c107d465>] ? __might_sleep+0x35/0x1d0
[ 1078.308710]  [<c1082a8b>] __cond_resched+0x1b/0x30
[ 1078.308715]  [<c17a4019>] _cond_resched+0x29/0x30
[ 1078.308722]  [<c11631a3>] kmem_cache_alloc+0x43/0x2b0
[ 1078.308729]  [<c10ade0b>] ? trace_hardirqs_off+0xb/0x10
[ 1078.308734]  [<c17a5585>] ? _raw_spin_unlock_irqrestore+0x65/0x70
[ 1078.308740]  [<c11b7511>] ? fsnotify_create_event+0x31/0x170
[ 1078.308744]  [<c11b7511>] fsnotify_create_event+0x31/0x170
[ 1078.308749]  [<c107c5d4>] ? __wake_up+0x44/0x50
[ 1078.308754]  [<c17a5556>] ? _raw_spin_unlock_irqrestore+0x36/0x70
[ 1078.308760]  [<c11b9dc3>] inotify_ignored_and_remove_idr+0x43/0xc0
[ 1078.308765]  [<c11b902d>] inotify_freeing_mark+0xd/0x10
[ 1078.308770]  [<c11b7faa>] fsnotify_destroy_mark+0xda/0x140
[ 1078.308775]  [<c11b832b>] fsnotify_clear_marks_by_group_flags+0xbb/0xe0
[ 1078.308780]  [<c11b8362>] fsnotify_clear_marks_by_group+0x12/0x20
[ 1078.308785]  [<c11b9375>] inotify_release+0x25/0x60
[ 1078.308791]  [<c117832f>] __fput+0xaf/0x1d0
[ 1078.308795]  [<c117846d>] fput+0x1d/0x30
[ 1078.308800]  [<c1173834>] filp_close+0x54/0x80
[ 1078.308807]  [<c104c1f8>] close_files+0xf8/0x1f0
[ 1078.308812]  [<c104c128>] ? close_files+0x28/0x1f0
[ 1078.308817]  [<c104c304>] put_files_struct.part.12+0x14/0x180
[ 1078.308824]  [<c132d4ce>] ? do_raw_spin_unlock+0x4e/0x90
[ 1078.308829]  [<c104de8d>] put_files_struct+0x1d/0x30
[ 1078.308834]  [<c104df43>] exit_files+0x43/0x50
[ 1078.308839]  [<c104e3fd>] do_exit+0x14d/0x450
[ 1078.308844]  [<c104e848>] do_group_exit+0x38/0xa0
[ 1078.308851]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.308856]  [<c1060a16>] get_signal_to_deliver+0x1c6/0x470
[ 1078.308861]  [<c17a5507>] ? _raw_spin_unlock_irq+0x27/0x40
[ 1078.308867]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.308873]  [<c10169df>] do_signal+0x3f/0xd0
[ 1078.308878]  [<c1060e43>] ? set_current_blocked+0x43/0x50
[ 1078.308883]  [<c17a5507>] ? _raw_spin_unlock_irq+0x27/0x40
[ 1078.308888]  [<c178ee99>] ? bad_area_nosemaphore+0x17/0x19
[ 1078.308893]  [<c17a96dc>] ? do_page_fault+0x3fc/0x4f0
[ 1078.308901]  [<c155ab13>] ? sys_socketcall+0x2e3/0x330
[ 1078.308906]  [<c17a5d56>] ? work_notifysig+0x11/0x2b
[ 1078.308911]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.308916]  [<c10b1298>] ? trace_hardirqs_on_caller+0x18/0x120
[ 1078.308921]  [<c1016ccd>] do_notify_resume+0x5d/0x80
[ 1078.308926]  [<c17a5d6a>] work_notifysig+0x25/0x2b
[ 1078.308931]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.308954] BUG: scheduling while atomic: NetworkManager/3953/0x10000002
[ 1078.308957] INFO: lockdep is turned off.
[ 1078.308960] Modules linked in: pci_stub vboxpci(O) vboxnetadp(O) vboxnetflt(O) vboxdrv(O) pktcdvd ebtable_nat ebtables xt_CHECKSUM acpi_cpufreq mperf irtty_sir sir_dev irda crc_ccitt dummy ppdev lp bnep bluetooth lib80211_crypt_ccmp uinput nfsd pcmcia yenta_socket i2c_i801 ipw2200 pcmcia_rsrc pcmcia_core radeon libipw floppy video parport_pc parport ttm drm_kms_helper drm i2c_algo_bit cfbfillrect cfbcopyarea cfbimgblt intel_agp intel_gtt agpgart raid10 raid456 async_memcpy async_pq async_xor xor async_raid6_recov async_tx raid6_pq sr_mod cdrom [last unloaded: scsi_wait_scan]
[ 1078.309042] Pid: 3953, comm: NetworkManager Tainted: G        W  O 3.3.0-rc3-t43-devel-smp-00188-g3ec1e88-dirty #22
[ 1078.309046] Call Trace:
[ 1078.309051]  [<c178fb87>] __schedule_bug+0x7d/0x84
[ 1078.309055]  [<c17a3eea>] __schedule+0x6ca/0x780
[ 1078.309060]  [<c1088b87>] ? __enqueue_entity+0x77/0x80
[ 1078.309065]  [<c1081474>] ? resched_task+0x24/0x70
[ 1078.309070]  [<c108d2be>] ? check_preempt_wakeup+0x19e/0x230
[ 1078.309075]  [<c1082752>] ? check_preempt_curr+0x72/0x90
[ 1078.309080]  [<c1082be2>] ? ttwu_queue+0x42/0xc0
[ 1078.309085]  [<c107d465>] ? __might_sleep+0x35/0x1d0
[ 1078.309090]  [<c1082a8b>] __cond_resched+0x1b/0x30
[ 1078.309094]  [<c17a4019>] _cond_resched+0x29/0x30
[ 1078.309099]  [<c11631a3>] kmem_cache_alloc+0x43/0x2b0
[ 1078.309104]  [<c10ade0b>] ? trace_hardirqs_off+0xb/0x10
[ 1078.309109]  [<c17a5585>] ? _raw_spin_unlock_irqrestore+0x65/0x70
[ 1078.309114]  [<c11b7511>] ? fsnotify_create_event+0x31/0x170
[ 1078.309119]  [<c11b7511>] fsnotify_create_event+0x31/0x170
[ 1078.309123]  [<c107c5d4>] ? __wake_up+0x44/0x50
[ 1078.309128]  [<c17a5556>] ? _raw_spin_unlock_irqrestore+0x36/0x70
[ 1078.309134]  [<c11b9dc3>] inotify_ignored_and_remove_idr+0x43/0xc0
[ 1078.309139]  [<c11b902d>] inotify_freeing_mark+0xd/0x10
[ 1078.309143]  [<c11b7faa>] fsnotify_destroy_mark+0xda/0x140
[ 1078.309148]  [<c11b832b>] fsnotify_clear_marks_by_group_flags+0xbb/0xe0
[ 1078.309154]  [<c11b8362>] fsnotify_clear_marks_by_group+0x12/0x20
[ 1078.309158]  [<c11b9375>] inotify_release+0x25/0x60
[ 1078.309163]  [<c117832f>] __fput+0xaf/0x1d0
[ 1078.309168]  [<c117846d>] fput+0x1d/0x30
[ 1078.309172]  [<c1173834>] filp_close+0x54/0x80
[ 1078.309178]  [<c104c1f8>] close_files+0xf8/0x1f0
[ 1078.309183]  [<c104c128>] ? close_files+0x28/0x1f0
[ 1078.309188]  [<c104c304>] put_files_struct.part.12+0x14/0x180
[ 1078.309193]  [<c132d4ce>] ? do_raw_spin_unlock+0x4e/0x90
[ 1078.309198]  [<c104de8d>] put_files_struct+0x1d/0x30
[ 1078.309203]  [<c104df43>] exit_files+0x43/0x50
[ 1078.309208]  [<c104e3fd>] do_exit+0x14d/0x450
[ 1078.309213]  [<c104e848>] do_group_exit+0x38/0xa0
[ 1078.309219]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.309223]  [<c1060a16>] get_signal_to_deliver+0x1c6/0x470
[ 1078.309228]  [<c17a5507>] ? _raw_spin_unlock_irq+0x27/0x40
[ 1078.309234]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.309239]  [<c10169df>] do_signal+0x3f/0xd0
[ 1078.309244]  [<c1060e43>] ? set_current_blocked+0x43/0x50
[ 1078.309248]  [<c17a5507>] ? _raw_spin_unlock_irq+0x27/0x40
[ 1078.309253]  [<c178ee99>] ? bad_area_nosemaphore+0x17/0x19
[ 1078.309259]  [<c17a96dc>] ? do_page_fault+0x3fc/0x4f0
[ 1078.309264]  [<c155ab13>] ? sys_socketcall+0x2e3/0x330
[ 1078.309269]  [<c17a5d56>] ? work_notifysig+0x11/0x2b
[ 1078.309274]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.309279]  [<c10b1298>] ? trace_hardirqs_on_caller+0x18/0x120
[ 1078.309284]  [<c1016ccd>] do_notify_resume+0x5d/0x80
[ 1078.309289]  [<c17a5d6a>] work_notifysig+0x25/0x2b
[ 1078.309294]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.309309] BUG: scheduling while atomic: NetworkManager/3953/0x10000002
[ 1078.309312] INFO: lockdep is turned off.
[ 1078.309314] Modules linked in: pci_stub vboxpci(O) vboxnetadp(O) vboxnetflt(O) vboxdrv(O) pktcdvd ebtable_nat ebtables xt_CHECKSUM acpi_cpufreq mperf irtty_sir sir_dev irda crc_ccitt dummy ppdev lp bnep bluetooth lib80211_crypt_ccmp uinput nfsd pcmcia yenta_socket i2c_i801 ipw2200 pcmcia_rsrc pcmcia_core radeon libipw floppy video parport_pc parport ttm drm_kms_helper drm i2c_algo_bit cfbfillrect cfbcopyarea cfbimgblt intel_agp intel_gtt agpgart raid10 raid456 async_memcpy async_pq async_xor xor async_raid6_recov async_tx raid6_pq sr_mod cdrom [last unloaded: scsi_wait_scan]
[ 1078.309396] Pid: 3953, comm: NetworkManager Tainted: G        W  O 3.3.0-rc3-t43-devel-smp-00188-g3ec1e88-dirty #22
[ 1078.309400] Call Trace:
[ 1078.309405]  [<c178fb87>] __schedule_bug+0x7d/0x84
[ 1078.309409]  [<c17a3eea>] __schedule+0x6ca/0x780
[ 1078.309414]  [<c1088b87>] ? __enqueue_entity+0x77/0x80
[ 1078.309419]  [<c1081474>] ? resched_task+0x24/0x70
[ 1078.309424]  [<c108d2be>] ? check_preempt_wakeup+0x19e/0x230
[ 1078.309429]  [<c1082752>] ? check_preempt_curr+0x72/0x90
[ 1078.309434]  [<c1082be2>] ? ttwu_queue+0x42/0xc0
[ 1078.309439]  [<c107d465>] ? __might_sleep+0x35/0x1d0
[ 1078.309444]  [<c1082a8b>] __cond_resched+0x1b/0x30
[ 1078.309448]  [<c17a4019>] _cond_resched+0x29/0x30
[ 1078.309453]  [<c11631a3>] kmem_cache_alloc+0x43/0x2b0
[ 1078.309458]  [<c10ade0b>] ? trace_hardirqs_off+0xb/0x10
[ 1078.309463]  [<c17a5585>] ? _raw_spin_unlock_irqrestore+0x65/0x70
[ 1078.309468]  [<c11b7511>] ? fsnotify_create_event+0x31/0x170
[ 1078.309473]  [<c11b7511>] fsnotify_create_event+0x31/0x170
[ 1078.309477]  [<c107c5d4>] ? __wake_up+0x44/0x50
[ 1078.309482]  [<c17a5556>] ? _raw_spin_unlock_irqrestore+0x36/0x70
[ 1078.309488]  [<c11b9dc3>] inotify_ignored_and_remove_idr+0x43/0xc0
[ 1078.309493]  [<c11b902d>] inotify_freeing_mark+0xd/0x10
[ 1078.309497]  [<c11b7faa>] fsnotify_destroy_mark+0xda/0x140
[ 1078.309502]  [<c11b832b>] fsnotify_clear_marks_by_group_flags+0xbb/0xe0
[ 1078.309508]  [<c11b8362>] fsnotify_clear_marks_by_group+0x12/0x20
[ 1078.309512]  [<c11b9375>] inotify_release+0x25/0x60
[ 1078.309517]  [<c117832f>] __fput+0xaf/0x1d0
[ 1078.309522]  [<c117846d>] fput+0x1d/0x30
[ 1078.309526]  [<c1173834>] filp_close+0x54/0x80
[ 1078.309531]  [<c104c1f8>] close_files+0xf8/0x1f0
[ 1078.309536]  [<c104c128>] ? close_files+0x28/0x1f0
[ 1078.309542]  [<c104c304>] put_files_struct.part.12+0x14/0x180
[ 1078.309547]  [<c132d4ce>] ? do_raw_spin_unlock+0x4e/0x90
[ 1078.309552]  [<c104de8d>] put_files_struct+0x1d/0x30
[ 1078.309557]  [<c104df43>] exit_files+0x43/0x50
[ 1078.309562]  [<c104e3fd>] do_exit+0x14d/0x450
[ 1078.309567]  [<c104e848>] do_group_exit+0x38/0xa0
[ 1078.309573]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.309577]  [<c1060a16>] get_signal_to_deliver+0x1c6/0x470
[ 1078.309582]  [<c17a5507>] ? _raw_spin_unlock_irq+0x27/0x40
[ 1078.309588]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.309593]  [<c10169df>] do_signal+0x3f/0xd0
[ 1078.309598]  [<c1060e43>] ? set_current_blocked+0x43/0x50
[ 1078.309602]  [<c17a5507>] ? _raw_spin_unlock_irq+0x27/0x40
[ 1078.309607]  [<c178ee99>] ? bad_area_nosemaphore+0x17/0x19
[ 1078.309613]  [<c17a96dc>] ? do_page_fault+0x3fc/0x4f0
[ 1078.309618]  [<c155ab13>] ? sys_socketcall+0x2e3/0x330
[ 1078.309623]  [<c17a5d56>] ? work_notifysig+0x11/0x2b
[ 1078.309628]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.309633]  [<c10b1298>] ? trace_hardirqs_on_caller+0x18/0x120
[ 1078.309638]  [<c1016ccd>] do_notify_resume+0x5d/0x80
[ 1078.309643]  [<c17a5d6a>] work_notifysig+0x25/0x2b
[ 1078.309648]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.309663] BUG: scheduling while atomic: NetworkManager/3953/0x10000002
[ 1078.309666] INFO: lockdep is turned off.
[ 1078.309668] Modules linked in: pci_stub vboxpci(O) vboxnetadp(O) vboxnetflt(O) vboxdrv(O) pktcdvd ebtable_nat ebtables xt_CHECKSUM acpi_cpufreq mperf irtty_sir sir_dev irda crc_ccitt dummy ppdev lp bnep bluetooth lib80211_crypt_ccmp uinput nfsd pcmcia yenta_socket i2c_i801 ipw2200 pcmcia_rsrc pcmcia_core radeon libipw floppy video parport_pc parport ttm drm_kms_helper drm i2c_algo_bit cfbfillrect cfbcopyarea cfbimgblt intel_agp intel_gtt agpgart raid10 raid456 async_memcpy async_pq async_xor xor async_raid6_recov async_tx raid6_pq sr_mod cdrom [last unloaded: scsi_wait_scan]
[ 1078.309750] Pid: 3953, comm: NetworkManager Tainted: G        W  O 3.3.0-rc3-t43-devel-smp-00188-g3ec1e88-dirty #22
[ 1078.309753] Call Trace:
[ 1078.309758]  [<c178fb87>] __schedule_bug+0x7d/0x84
[ 1078.309763]  [<c17a3eea>] __schedule+0x6ca/0x780
[ 1078.309768]  [<c1088b87>] ? __enqueue_entity+0x77/0x80
[ 1078.309773]  [<c1081474>] ? resched_task+0x24/0x70
[ 1078.309778]  [<c108d2be>] ? check_preempt_wakeup+0x19e/0x230
[ 1078.309783]  [<c1082752>] ? check_preempt_curr+0x72/0x90
[ 1078.309788]  [<c1082be2>] ? ttwu_queue+0x42/0xc0
[ 1078.309862]  [<c107d465>] ? __might_sleep+0x35/0x1d0
[ 1078.309867]  [<c1082a8b>] __cond_resched+0x1b/0x30
[ 1078.309872]  [<c17a4019>] _cond_resched+0x29/0x30
[ 1078.309877]  [<c11631a3>] kmem_cache_alloc+0x43/0x2b0
[ 1078.309882]  [<c10ade0b>] ? trace_hardirqs_off+0xb/0x10
[ 1078.309887]  [<c17a5585>] ? _raw_spin_unlock_irqrestore+0x65/0x70
[ 1078.309892]  [<c11b7511>] ? fsnotify_create_event+0x31/0x170
[ 1078.309897]  [<c11b7511>] fsnotify_create_event+0x31/0x170
[ 1078.309901]  [<c107c5d4>] ? __wake_up+0x44/0x50
[ 1078.309906]  [<c17a5556>] ? _raw_spin_unlock_irqrestore+0x36/0x70
[ 1078.309912]  [<c11b9dc3>] inotify_ignored_and_remove_idr+0x43/0xc0
[ 1078.309917]  [<c11b902d>] inotify_freeing_mark+0xd/0x10
[ 1078.309921]  [<c11b7faa>] fsnotify_destroy_mark+0xda/0x140
[ 1078.309926]  [<c11b832b>] fsnotify_clear_marks_by_group_flags+0xbb/0xe0
[ 1078.309932]  [<c11b8362>] fsnotify_clear_marks_by_group+0x12/0x20
[ 1078.309936]  [<c11b9375>] inotify_release+0x25/0x60
[ 1078.309941]  [<c117832f>] __fput+0xaf/0x1d0
[ 1078.309946]  [<c117846d>] fput+0x1d/0x30
[ 1078.309950]  [<c1173834>] filp_close+0x54/0x80
[ 1078.309955]  [<c104c1f8>] close_files+0xf8/0x1f0
[ 1078.309960]  [<c104c128>] ? close_files+0x28/0x1f0
[ 1078.309966]  [<c104c304>] put_files_struct.part.12+0x14/0x180
[ 1078.309971]  [<c132d4ce>] ? do_raw_spin_unlock+0x4e/0x90
[ 1078.309976]  [<c104de8d>] put_files_struct+0x1d/0x30
[ 1078.309981]  [<c104df43>] exit_files+0x43/0x50
[ 1078.309986]  [<c104e3fd>] do_exit+0x14d/0x450
[ 1078.309991]  [<c104e848>] do_group_exit+0x38/0xa0
[ 1078.309997]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.310001]  [<c1060a16>] get_signal_to_deliver+0x1c6/0x470
[ 1078.310006]  [<c17a5507>] ? _raw_spin_unlock_irq+0x27/0x40
[ 1078.310012]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.310017]  [<c10169df>] do_signal+0x3f/0xd0
[ 1078.310022]  [<c1060e43>] ? set_current_blocked+0x43/0x50
[ 1078.310026]  [<c17a5507>] ? _raw_spin_unlock_irq+0x27/0x40
[ 1078.310031]  [<c178ee99>] ? bad_area_nosemaphore+0x17/0x19
[ 1078.310037]  [<c17a96dc>] ? do_page_fault+0x3fc/0x4f0
[ 1078.310042]  [<c155ab13>] ? sys_socketcall+0x2e3/0x330
[ 1078.310047]  [<c17a5d56>] ? work_notifysig+0x11/0x2b
[ 1078.310052]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.310057]  [<c10b1298>] ? trace_hardirqs_on_caller+0x18/0x120
[ 1078.310062]  [<c1016ccd>] do_notify_resume+0x5d/0x80
[ 1078.310067]  [<c17a5d6a>] work_notifysig+0x25/0x2b
[ 1078.310072]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.310088] BUG: scheduling while atomic: NetworkManager/3953/0x10000002
[ 1078.310091] INFO: lockdep is turned off.
[ 1078.310094] Modules linked in: pci_stub vboxpci(O) vboxnetadp(O) vboxnetflt(O) vboxdrv(O) pktcdvd ebtable_nat ebtables xt_CHECKSUM acpi_cpufreq mperf irtty_sir sir_dev irda crc_ccitt dummy ppdev lp bnep bluetooth lib80211_crypt_ccmp uinput nfsd pcmcia yenta_socket i2c_i801 ipw2200 pcmcia_rsrc pcmcia_core radeon libipw floppy video parport_pc parport ttm drm_kms_helper drm i2c_algo_bit cfbfillrect cfbcopyarea cfbimgblt intel_agp intel_gtt agpgart raid10 raid456 async_memcpy async_pq async_xor xor async_raid6_recov async_tx raid6_pq sr_mod cdrom [last unloaded: scsi_wait_scan]
[ 1078.310176] Pid: 3953, comm: NetworkManager Tainted: G        W  O 3.3.0-rc3-t43-devel-smp-00188-g3ec1e88-dirty #22
[ 1078.310179] Call Trace:
[ 1078.310184]  [<c178fb87>] __schedule_bug+0x7d/0x84
[ 1078.310189]  [<c17a3eea>] __schedule+0x6ca/0x780
[ 1078.310193]  [<c1088b87>] ? __enqueue_entity+0x77/0x80
[ 1078.310199]  [<c1081474>] ? resched_task+0x24/0x70
[ 1078.310203]  [<c108d2be>] ? check_preempt_wakeup+0x19e/0x230
[ 1078.310209]  [<c1082752>] ? check_preempt_curr+0x72/0x90
[ 1078.310213]  [<c1082be2>] ? ttwu_queue+0x42/0xc0
[ 1078.310218]  [<c107d465>] ? __might_sleep+0x35/0x1d0
[ 1078.310223]  [<c1082a8b>] __cond_resched+0x1b/0x30
[ 1078.310227]  [<c17a4019>] _cond_resched+0x29/0x30
[ 1078.310233]  [<c11631a3>] kmem_cache_alloc+0x43/0x2b0
[ 1078.310238]  [<c10ade0b>] ? trace_hardirqs_off+0xb/0x10
[ 1078.310242]  [<c17a5585>] ? _raw_spin_unlock_irqrestore+0x65/0x70
[ 1078.310247]  [<c11b7511>] ? fsnotify_create_event+0x31/0x170
[ 1078.310252]  [<c11b7511>] fsnotify_create_event+0x31/0x170
[ 1078.310257]  [<c107c5d4>] ? __wake_up+0x44/0x50
[ 1078.310262]  [<c17a5556>] ? _raw_spin_unlock_irqrestore+0x36/0x70
[ 1078.310267]  [<c11b9dc3>] inotify_ignored_and_remove_idr+0x43/0xc0
[ 1078.310272]  [<c11b902d>] inotify_freeing_mark+0xd/0x10
[ 1078.310277]  [<c11b7faa>] fsnotify_destroy_mark+0xda/0x140
[ 1078.310282]  [<c11b832b>] fsnotify_clear_marks_by_group_flags+0xbb/0xe0
[ 1078.310287]  [<c11b8362>] fsnotify_clear_marks_by_group+0x12/0x20
[ 1078.310292]  [<c11b9375>] inotify_release+0x25/0x60
[ 1078.310297]  [<c117832f>] __fput+0xaf/0x1d0
[ 1078.310301]  [<c117846d>] fput+0x1d/0x30
[ 1078.310306]  [<c1173834>] filp_close+0x54/0x80
[ 1078.310311]  [<c104c1f8>] close_files+0xf8/0x1f0
[ 1078.310316]  [<c104c128>] ? close_files+0x28/0x1f0
[ 1078.310321]  [<c104c304>] put_files_struct.part.12+0x14/0x180
[ 1078.310326]  [<c132d4ce>] ? do_raw_spin_unlock+0x4e/0x90
[ 1078.310331]  [<c104de8d>] put_files_struct+0x1d/0x30
[ 1078.310336]  [<c104df43>] exit_files+0x43/0x50
[ 1078.310341]  [<c104e3fd>] do_exit+0x14d/0x450
[ 1078.310347]  [<c104e848>] do_group_exit+0x38/0xa0
[ 1078.310352]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.310357]  [<c1060a16>] get_signal_to_deliver+0x1c6/0x470
[ 1078.310362]  [<c17a5507>] ? _raw_spin_unlock_irq+0x27/0x40
[ 1078.310367]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.310372]  [<c10169df>] do_signal+0x3f/0xd0
[ 1078.310377]  [<c1060e43>] ? set_current_blocked+0x43/0x50
[ 1078.310382]  [<c17a5507>] ? _raw_spin_unlock_irq+0x27/0x40
[ 1078.310387]  [<c178ee99>] ? bad_area_nosemaphore+0x17/0x19
[ 1078.310392]  [<c17a96dc>] ? do_page_fault+0x3fc/0x4f0
[ 1078.310398]  [<c155ab13>] ? sys_socketcall+0x2e3/0x330
[ 1078.310402]  [<c17a5d56>] ? work_notifysig+0x11/0x2b
[ 1078.310407]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.310413]  [<c10b1298>] ? trace_hardirqs_on_caller+0x18/0x120
[ 1078.310418]  [<c1016ccd>] do_notify_resume+0x5d/0x80
[ 1078.310422]  [<c17a5d6a>] work_notifysig+0x25/0x2b
[ 1078.310428]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.310494] BUG: scheduling while atomic: NetworkManager/3953/0x10000002
[ 1078.310497] INFO: lockdep is turned off.
[ 1078.310499] Modules linked in: pci_stub vboxpci(O) vboxnetadp(O) vboxnetflt(O) vboxdrv(O) pktcdvd ebtable_nat ebtables xt_CHECKSUM acpi_cpufreq mperf irtty_sir sir_dev irda crc_ccitt dummy ppdev lp bnep bluetooth lib80211_crypt_ccmp uinput nfsd pcmcia yenta_socket i2c_i801 ipw2200 pcmcia_rsrc pcmcia_core radeon libipw floppy video parport_pc parport ttm drm_kms_helper drm i2c_algo_bit cfbfillrect cfbcopyarea cfbimgblt intel_agp intel_gtt agpgart raid10 raid456 async_memcpy async_pq async_xor xor async_raid6_recov async_tx raid6_pq sr_mod cdrom [last unloaded: scsi_wait_scan]
[ 1078.310581] Pid: 3953, comm: NetworkManager Tainted: G        W  O 3.3.0-rc3-t43-devel-smp-00188-g3ec1e88-dirty #22
[ 1078.310585] Call Trace:
[ 1078.310590]  [<c178fb87>] __schedule_bug+0x7d/0x84
[ 1078.310595]  [<c17a3eea>] __schedule+0x6ca/0x780
[ 1078.310599]  [<c1088b87>] ? __enqueue_entity+0x77/0x80
[ 1078.310605]  [<c1081474>] ? resched_task+0x24/0x70
[ 1078.310609]  [<c108d2be>] ? check_preempt_wakeup+0x19e/0x230
[ 1078.310615]  [<c1082752>] ? check_preempt_curr+0x72/0x90
[ 1078.310619]  [<c1082be2>] ? ttwu_queue+0x42/0xc0
[ 1078.310624]  [<c107d465>] ? __might_sleep+0x35/0x1d0
[ 1078.310629]  [<c1082a8b>] __cond_resched+0x1b/0x30
[ 1078.310633]  [<c17a4019>] _cond_resched+0x29/0x30
[ 1078.310639]  [<c11631a3>] kmem_cache_alloc+0x43/0x2b0
[ 1078.310644]  [<c10ade0b>] ? trace_hardirqs_off+0xb/0x10
[ 1078.310648]  [<c17a5585>] ? _raw_spin_unlock_irqrestore+0x65/0x70
[ 1078.310653]  [<c11b7511>] ? fsnotify_create_event+0x31/0x170
[ 1078.310658]  [<c11b7511>] fsnotify_create_event+0x31/0x170
[ 1078.310663]  [<c107c5d4>] ? __wake_up+0x44/0x50
[ 1078.310668]  [<c17a5556>] ? _raw_spin_unlock_irqrestore+0x36/0x70
[ 1078.310673]  [<c11b9dc3>] inotify_ignored_and_remove_idr+0x43/0xc0
[ 1078.310678]  [<c11b902d>] inotify_freeing_mark+0xd/0x10
[ 1078.310683]  [<c11b7faa>] fsnotify_destroy_mark+0xda/0x140
[ 1078.310688]  [<c11b832b>] fsnotify_clear_marks_by_group_flags+0xbb/0xe0
[ 1078.310693]  [<c11b8362>] fsnotify_clear_marks_by_group+0x12/0x20
[ 1078.310698]  [<c11b9375>] inotify_release+0x25/0x60
[ 1078.310703]  [<c117832f>] __fput+0xaf/0x1d0
[ 1078.310708]  [<c117846d>] fput+0x1d/0x30
[ 1078.310712]  [<c1173834>] filp_close+0x54/0x80
[ 1078.310717]  [<c104c1f8>] close_files+0xf8/0x1f0
[ 1078.310722]  [<c104c128>] ? close_files+0x28/0x1f0
[ 1078.310727]  [<c104c304>] put_files_struct.part.12+0x14/0x180
[ 1078.310732]  [<c132d4ce>] ? do_raw_spin_unlock+0x4e/0x90
[ 1078.310738]  [<c104de8d>] put_files_struct+0x1d/0x30
[ 1078.310743]  [<c104df43>] exit_files+0x43/0x50
[ 1078.310747]  [<c104e3fd>] do_exit+0x14d/0x450
[ 1078.310753]  [<c104e848>] do_group_exit+0x38/0xa0
[ 1078.310758]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.310763]  [<c1060a16>] get_signal_to_deliver+0x1c6/0x470
[ 1078.310768]  [<c17a5507>] ? _raw_spin_unlock_irq+0x27/0x40
[ 1078.310774]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.310779]  [<c10169df>] do_signal+0x3f/0xd0
[ 1078.310783]  [<c1060e43>] ? set_current_blocked+0x43/0x50
[ 1078.310788]  [<c17a5507>] ? _raw_spin_unlock_irq+0x27/0x40
[ 1078.310793]  [<c178ee99>] ? bad_area_nosemaphore+0x17/0x19
[ 1078.310798]  [<c17a96dc>] ? do_page_fault+0x3fc/0x4f0
[ 1078.310804]  [<c155ab13>] ? sys_socketcall+0x2e3/0x330
[ 1078.310809]  [<c17a5d56>] ? work_notifysig+0x11/0x2b
[ 1078.310814]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190
[ 1078.310819]  [<c10b1298>] ? trace_hardirqs_on_caller+0x18/0x120
[ 1078.310824]  [<c1016ccd>] do_notify_resume+0x5d/0x80
[ 1078.310829]  [<c17a5d6a>] work_notifysig+0x25/0x2b
[ 1078.310834]  [<c17a92e0>] ? vmalloc_fault+0x190/0x190



2)

this is after suspend/resume cycle on laptop

[    0.000000] Linux version 3.3.0-rc3-t43-devel-smp-00272-g7ada1dd-dirty (baryluk@sredniczarny) (gcc version 4.6.2 (Debian 4.6.2-14) ) #25 SMP Wed Feb 15 16:57:40 CET 2012
...
suspend
...
resume
...
[ 9136.204156] BUG: sleeping function called from invalid context at kernel/mutex.c:271
[ 9136.204162] in_atomic(): 1, irqs_disabled(): 0, pid: 11404, name: ip
[ 9136.204166] INFO: lockdep is turned off.
[ 9136.204170] Pid: 11404, comm: ip Tainted: G        W    3.3.0-rc3-t43-devel-smp-00272-g7ada1dd-dirty #25
[ 9136.204174] Call Trace:
[ 9136.204182]  [<c107f2d4>] __might_sleep+0x124/0x1d0
[ 9136.204188]  [<c17b2cfa>] mutex_lock_nested+0x2a/0x310
[ 9136.204194]  [<c15a9f28>] ? netlink_dump+0x1b8/0x200
[ 9136.204200]  [<c15ab2b8>] ? netlink_dump_start+0xb8/0x150
[ 9136.204206]  [<c16689f0>] ? fib6_net_init+0x1f0/0x1f0
[ 9136.204211]  [<c1590ab4>] rtnl_lock+0x14/0x20
[ 9136.204216]  [<c1592a42>] rtnetlink_rcv_msg+0x2a2/0x330
[ 9136.204221]  [<c16689f0>] ? fib6_net_init+0x1f0/0x1f0
[ 9136.204226]  [<c1590ab4>] ? rtnl_lock+0x14/0x20
[ 9136.204231]  [<c16689f0>] ? fib6_net_init+0x1f0/0x1f0
[ 9136.204235]  [<c15927a0>] ? __rtnl_unlock+0x20/0x20
[ 9136.204240]  [<c15acdae>] netlink_rcv_skb+0x8e/0xb0
[ 9136.204245]  [<c1590ae0>] rtnetlink_rcv+0x20/0x30
[ 9136.204250]  [<c15ac55b>] netlink_unicast+0x17b/0x1c0
[ 9136.204255]  [<c15ac8cc>] netlink_sendmsg+0x32c/0x3d0
[ 9136.204262]  [<c1567d95>] sock_sendmsg+0xc5/0x100
[ 9136.204267]  [<c1089aad>] ? cpuacct_charge+0xdd/0x1f0
[ 9136.204273]  [<c1184f1d>] ? fget_light+0x18d/0x410
[ 9136.204278]  [<c156a257>] sys_sendto+0xb7/0xe0
[ 9136.204284]  [<c1082f17>] ? finish_task_switch+0x77/0x200
[ 9136.204289]  [<c17b5f07>] ? _raw_spin_unlock_irq+0x27/0x40
[ 9136.204295]  [<c10b3038>] ? trace_hardirqs_on_caller+0x18/0x120
[ 9136.204300]  [<c10b314b>] ? trace_hardirqs_on+0xb/0x10
[ 9136.204305]  [<c17b5f07>] ? _raw_spin_unlock_irq+0x27/0x40
[ 9136.204310]  [<c1082f17>] ? finish_task_switch+0x77/0x200
[ 9136.204322]  [<c114d3d4>] ? might_fault+0x54/0xb0
[ 9136.204328]  [<c156a2b7>] sys_send+0x37/0x40
[ 9136.204333]  [<c156ab8a>] sys_socketcall+0x1ba/0x330
[ 9136.204339]  [<c17be518>] sysenter_do_call+0x12/0x38
[ 9136.204343] BUG: scheduling while atomic: ip/11404/0x10000002
[ 9136.204346] INFO: lockdep is turned off.
[ 9136.204349] Modules linked in: pktcdvd ebtable_nat ebtables xt_CHECKSUM irtty_sir sir_dev irda crc_ccitt dummy ppdev lp bnep bluetooth lib80211_crypt_ccmp uinput nfsd pcmcia radeon ipw2200 i2c_i801 yenta_socket libipw pcmcia_rsrc pcmcia_core ttm parport_pc drm_kms_helper video floppy parport drm i2c_algo_bit cfbfillrect cfbcopyarea intel_agp cfbimgblt intel_gtt agpgart raid10 raid456 async_memcpy async_pq async_xor xor async_raid6_recov async_tx raid6_pq sr_mod cdrom [last unloaded: scsi_wait_scan]
[ 9136.204424] Pid: 11404, comm: ip Tainted: G        W    3.3.0-rc3-t43-devel-smp-00272-g7ada1dd-dirty #25
[ 9136.204427] Call Trace:
[ 9136.204432]  [<c17a0446>] __schedule_bug+0x7d/0x84
[ 9136.204437]  [<c17b48ea>] __schedule+0x6ca/0x780
[ 9136.204443]  [<c101998c>] ? show_trace_log_lvl+0x4c/0x60
[ 9136.204448]  [<c179e311>] ? dump_stack+0x73/0x7a
[ 9136.204454]  [<c107f2d4>] ? __might_sleep+0x124/0x1d0
[ 9136.204459]  [<c108480b>] __cond_resched+0x1b/0x30
[ 9136.204463]  [<c17b4a19>] _cond_resched+0x29/0x30
[ 9136.204468]  [<c17b2cff>] mutex_lock_nested+0x2f/0x310
[ 9136.204473]  [<c15a9f28>] ? netlink_dump+0x1b8/0x200
[ 9136.204478]  [<c15ab2b8>] ? netlink_dump_start+0xb8/0x150
[ 9136.204484]  [<c16689f0>] ? fib6_net_init+0x1f0/0x1f0
[ 9136.204488]  [<c1590ab4>] rtnl_lock+0x14/0x20
[ 9136.204493]  [<c1592a42>] rtnetlink_rcv_msg+0x2a2/0x330
[ 9136.204498]  [<c16689f0>] ? fib6_net_init+0x1f0/0x1f0
[ 9136.204503]  [<c1590ab4>] ? rtnl_lock+0x14/0x20
[ 9136.204508]  [<c16689f0>] ? fib6_net_init+0x1f0/0x1f0
[ 9136.204512]  [<c15927a0>] ? __rtnl_unlock+0x20/0x20
[ 9136.204517]  [<c15acdae>] netlink_rcv_skb+0x8e/0xb0
[ 9136.204522]  [<c1590ae0>] rtnetlink_rcv+0x20/0x30
[ 9136.204527]  [<c15ac55b>] netlink_unicast+0x17b/0x1c0
[ 9136.204532]  [<c15ac8cc>] netlink_sendmsg+0x32c/0x3d0
[ 9136.204538]  [<c1567d95>] sock_sendmsg+0xc5/0x100
[ 9136.204543]  [<c1089aad>] ? cpuacct_charge+0xdd/0x1f0
[ 9136.204548]  [<c1184f1d>] ? fget_light+0x18d/0x410
[ 9136.204554]  [<c156a257>] sys_sendto+0xb7/0xe0
[ 9136.204559]  [<c1082f17>] ? finish_task_switch+0x77/0x200
[ 9136.204564]  [<c17b5f07>] ? _raw_spin_unlock_irq+0x27/0x40
[ 9136.204569]  [<c10b3038>] ? trace_hardirqs_on_caller+0x18/0x120
[ 9136.204574]  [<c10b314b>] ? trace_hardirqs_on+0xb/0x10
[ 9136.204579]  [<c17b5f07>] ? _raw_spin_unlock_irq+0x27/0x40
[ 9136.204584]  [<c1082f17>] ? finish_task_switch+0x77/0x200
[ 9136.204590]  [<c114d3d4>] ? might_fault+0x54/0xb0
[ 9136.204595]  [<c156a2b7>] sys_send+0x37/0x40
[ 9136.204600]  [<c156ab8a>] sys_socketcall+0x1ba/0x330
[ 9136.204605]  [<c17be518>] sysenter_do_call+0x12/0x38
[ 9136.204684] ip[11404]: segfault at b7637a60 ip b7637a60 sp bf8cbe2c error 14
[ 9136.204700] note: ip[11404] exited with preempt_count 1


I'm going to didable IRDA initscripts, so I can check if this
is actually a problem.

It actually looks like this bug actually:

https://bugzilla.kernel.org/show_bug.cgi?id=42629
http://marc.info/?l=linux-kernel&m=132647921304184&w=2



-- 
Witold Baryluk
