From: Bart Trojanowski <bart@jukie.net>
Subject: Re: [BUG] 2.6.29-rc* QinQ vlan trunking regression
Date: Wed, 4 Mar 2009 23:59:25 -0500
Message-ID: <20090305045925.GG5959@jukie.net>
References: <49AE509B.3000305@trash.net> <20090304.025914.149394356.davem@davemloft.net> <49AE69DD.80802@trash.net> <20090304.195328.106253933.davem@davemloft.net> <20090305045442.GF5959@jukie.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, greearb@candelatech.com, shemminger@vyatta.com,
	dada1@cosmosbay.com, frank.blaschka@de.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tau.jukie.net ([216.239.93.128]:42146 "EHLO tau.jukie.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751438AbZCEE7c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Mar 2009 23:59:32 -0500
Content-Disposition: inline
In-Reply-To: <20090305045442.GF5959@jukie.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

* Bart Trojanowski <bart@jukie.net> [090304 23:54]:
> * David Miller <davem@davemloft.net> [090304 22:53]:
> > vlan: Fix vlan-in-vlan crashes.
> > 
> > As analyzed by Patrick McHardy, vlan needs to reset it's
> > netdev_ops pointer in it's ->init() function but this
> > leaves the compat method pointers stale.
> > 
> > Add a netdev_resync_ops() and call it from the vlan code.
> <snip>
> >  include/linux/netdevice.h |    1 +
> >  net/8021q/vlan_dev.c      |    1 +
> >  net/core/dev.c            |   54 +++++++++++++++++++++++++++-----------------
> >  3 files changed, 35 insertions(+), 21 deletions(-)
> 
> I tried this patch onto v2.6.29-rc7-3-g559595a, but I still get a crash.
> I assume that this worked for you, so I am not putting much faith in my
> results at this late hour.  I'll confirm tomorrow morning that it's not
> something else.

... if you're interested, here is the Oops.  And like I said, I'll
retest tomorrow.

-Bart

[  231.748126] 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
[  231.751563] All bugs added by David S. Miller <davem@redhat.com>
[  231.876164] PANIC: double fault, gdt at c364c000 [255 bytes]
[  231.876271] double fault, tss at c364fae0
[  231.876271] eip = f8163c65, esp = f3045000
[  231.876271] eax = f3d78800, ebx = f3d78800, ecx = f8163c62, edx = f3e4ce40
[  231.876271] esi = f3e4ce40, edi = c05228fc
[  232.156110] BUG: unable to handle kernel paging request at a0ad0eb4
[  232.159226] IP: [<c011fd49>] hrtick_start_fair+0x1f/0x17d
[  232.160050] *pde = 00000000 
[  232.160050] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[  232.160050] last sysfs file: /sys/class/net/lo/operstate
[  232.160050] Modules linked in: 8021q virtio_balloon virtio_pci thermal_sys
[  232.160050] 
[  232.160050] Pid: 0, comm: swapper Tainted: G S         (2.6.29-rc7-bisect-00004-g39fc204 #1) 
[  232.160050] EIP: 0060:[<c011fd49>] EFLAGS: 00010092 CPU: 0
[  232.160050] EIP is at hrtick_start_fair+0x1f/0x17d
[  232.160050] EAX: c0599d80 EBX: c364e200 ECX: c3651dd4 EDX: f8163c85
[  232.160050] ESI: f52f6198 EDI: f622b708 EBP: c0545ddc ESP: c0545dc4
[  232.160050]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[  232.160050] Process swapper (pid: 0, ti=c0544000 task=c04fd380 task.ti=c0544000)
[  232.160050] Stack:
[  232.160050]  c3651d80 5f684afd 00000002 c3651dd4 f52f6198 c3651d80 c0545df0 c011ff82
[  232.160050]  f4796708 c03d6ad8 00000000 c0545e14 c011da63 0d94c928 00000036 00000000
[  232.160050]  c3651d80 c3651d80 c3648d80 00000522 c0545e20 c011daaa f4796708 c0545e34
[  232.160050] Call Trace:
[  232.160050]  [<c011ff82>] ? dequeue_task_fair+0x51/0x56
[  232.160050]  [<c011da63>] ? dequeue_task+0xd5/0xe4
[  232.160050]  [<c011daaa>] ? deactivate_task+0x19/0x1f
[  232.160050]  [<c011e504>] ? pull_task+0x11/0x3d
[  232.160050]  [<c011e6fc>] ? load_balance_fair+0x134/0x1ce
[  232.160050]  [<c0124684>] ? rebalance_domains+0x219/0x421
[  232.160050]  [<c01248ba>] ? run_rebalance_domains+0x2e/0x9e
[  232.160050]  [<c012e0e7>] ? __do_softirq+0x8d/0x133
[  232.160050]  [<c012e1d5>] ? do_softirq+0x48/0x57
[  232.160050]  [<c012e2e6>] ? irq_exit+0x38/0x66
[  232.160050]  [<c011228b>] ? smp_apic_timer_interrupt+0x74/0x82
[  232.160050]  [<c0103cc0>] ? apic_timer_interrupt+0x28/0x30
[  232.160050]  [<c011824f>] ? native_safe_halt+0x5/0x7
[  232.160050]  [<c0108c92>] ? default_idle+0x30/0x58
[  232.160050]  [<c0102605>] ? cpu_idle+0x63/0x7e
[  232.160050]  [<c03bee3b>] ? rest_init+0x53/0x55
[  232.160050] Code: 3e ff ff ff 83 c4 14 5b 5e 5f 5d c3 55 89 e5 57 89 d7 56 53 83 ec 0c 89 45 e8 8b 9a 80 00 00 00 b8 80 9d 59 c0 8b 52 04 8b 52 10 <03> 04 95 a0 1c 54 c0 39 45 e8 74 14 6a 00 68 7a 03 00 00 68 e1 
[  232.160050] EIP: [<c011fd49>] hrtick_start_fair+0x1f/0x17d SS:ESP 0068:c0545dc4
[  232.160050] ---[ end trace b72565b053d710aa ]---
[  232.160050] Kernel panic - not syncing: Fatal exception in interrupt
[  232.160050] ------------[ cut here ]------------
[  232.160050] WARNING: at kernel/smp.c:329 smp_call_function_many+0x37/0x1cf()
[  232.160050] Hardware name: 
[  232.160050] Modules linked in: 8021q virtio_balloon virtio_pci thermal_sys
[  232.160050] Pid: 0, comm: swapper Tainted: G S    D    2.6.29-rc7-bisect-00004-g39fc204 #1
[  232.160050] Call Trace:
[  232.160050]  [<c0129779>] warn_slowpath+0x71/0xa8
[  232.160050]  [<c0288f14>] ? _raw_spin_unlock+0x74/0x78
[  232.160050]  [<c03ce3aa>] ? _spin_unlock+0x1d/0x20
[  232.160050]  [<c0288f6b>] ? _raw_spin_lock+0x53/0xfa
[  232.160050]  [<c03ccadd>] ? mutex_unlock+0x8/0xa
[  232.160050]  [<c014b26d>] smp_call_function_many+0x37/0x1cf
[  232.160050]  [<c0108ec2>] ? stop_this_cpu+0x0/0x47
[  232.160050]  [<c014b421>] smp_call_function+0x1c/0x23
[  232.160050]  [<c0110e91>] native_smp_send_stop+0x1b/0x45
[  232.160050]  [<c03cb99e>] panic+0x48/0xe4
[  232.160050]  [<c0105ff4>] oops_end+0x9a/0xa9
[  232.160050]  [<c0106187>] die+0x54/0x5a
[  232.160050]  [<c01195d3>] do_page_fault+0x5f8/0x69d
[  232.160050]  [<c0119fe8>] ? __change_page_attr_set_clr+0x2a7/0x791
[  232.160050]  [<c0119ca2>] ? lookup_address+0x68/0x88
[  232.160050]  [<c0119fe8>] ? __change_page_attr_set_clr+0x2a7/0x791
[  232.160050]  [<c011a5b0>] ? kernel_map_pages+0xde/0xfe
[  232.160050]  [<c0119ca2>] ? lookup_address+0x68/0x88
[  232.160050]  [<c0119ca2>] ? lookup_address+0x68/0x88
[  232.160050]  [<c0119ca2>] ? lookup_address+0x68/0x88
[  232.160050]  [<c0118fdb>] ? do_page_fault+0x0/0x69d
[  232.160050]  [<c03ce82a>] error_code+0x72/0x78
[  232.160050]  [<f8163c85>] ? vlan_dev_neigh_setup+0x23/0x2a [8021q]
[  232.160050]  [<c011fd49>] ? hrtick_start_fair+0x1f/0x17d
[  232.160050]  [<c011ff82>] dequeue_task_fair+0x51/0x56
[  232.160050]  [<c011da63>] dequeue_task+0xd5/0xe4
[  232.160050]  [<c011daaa>] deactivate_task+0x19/0x1f
[  232.160050]  [<c011e504>] pull_task+0x11/0x3d
[  232.160050]  [<c011e6fc>] load_balance_fair+0x134/0x1ce
[  232.160050]  [<c0124684>] rebalance_domains+0x219/0x421
[  232.160050]  [<c01248ba>] run_rebalance_domains+0x2e/0x9e
[  232.160050]  [<c012e0e7>] __do_softirq+0x8d/0x133
[  232.160050]  [<c012e1d5>] do_softirq+0x48/0x57
[  232.160050]  [<c012e2e6>] irq_exit+0x38/0x66
[  232.160050]  [<c011228b>] smp_apic_timer_interrupt+0x74/0x82
[  232.160050]  [<c0103cc0>] apic_timer_interrupt+0x28/0x30
[  232.160050]  [<c011824f>] ? native_safe_halt+0x5/0x7
[  232.160050]  [<c0108c92>] default_idle+0x30/0x58
[  232.160050]  [<c0102605>] cpu_idle+0x63/0x7e
[  232.160050]  [<c03bee3b>] rest_init+0x53/0x55
[  232.160050] ---[ end trace b72565b053d710ab ]---
[  232.160050] ------------[ cut here ]------------
[  232.160050] WARNING: at kernel/smp.c:226 smp_call_function_single+0x37/0xe8()
[  232.160050] Hardware name: 
[  232.160050] Modules linked in: 8021q virtio_balloon virtio_pci thermal_sys
[  232.160050] Pid: 0, comm: swapper Tainted: G S    D W  2.6.29-rc7-bisect-00004-g39fc204 #1
[  232.160050] Call Trace:
[  232.160050]  [<c0129779>] warn_slowpath+0x71/0xa8
[  232.160050]  [<c0288f14>] ? _raw_spin_unlock+0x74/0x78
[  232.160050]  [<c03ce300>] ? _read_unlock+0x15/0x20
[  232.160050]  [<c0288f6b>] ? _raw_spin_lock+0x53/0xfa
[  232.160050]  [<c014b185>] smp_call_function_single+0x37/0xe8
[  232.160050]  [<c0108ec2>] ? stop_this_cpu+0x0/0x47
[  232.160050]  [<c014b2ef>] smp_call_function_many+0xb9/0x1cf
[  232.160050]  [<c0108ec2>] ? stop_this_cpu+0x0/0x47
[  232.160050]  [<c014b421>] smp_call_function+0x1c/0x23
[  232.160050]  [<c0110e91>] native_smp_send_stop+0x1b/0x45
[  232.160050]  [<c03cb99e>] panic+0x48/0xe4
[  232.160050]  [<c0105ff4>] oops_end+0x9a/0xa9
[  232.160050]  [<c0106187>] die+0x54/0x5a
[  232.160050]  [<c01195d3>] do_page_fault+0x5f8/0x69d
[  232.160050]  [<c0119fe8>] ? __change_page_attr_set_clr+0x2a7/0x791
[  232.160050]  [<c0119ca2>] ? lookup_address+0x68/0x88
[  232.160050]  [<c0119fe8>] ? __change_page_attr_set_clr+0x2a7/0x791
[  232.160050]  [<c011a5b0>] ? kernel_map_pages+0xde/0xfe
[  232.160050]  [<c0119ca2>] ? lookup_address+0x68/0x88
[  232.160050]  [<c0119ca2>] ? lookup_address+0x68/0x88
[  232.160050]  [<c0119ca2>] ? lookup_address+0x68/0x88
[  232.160050]  [<c0118fdb>] ? do_page_fault+0x0/0x69d
[  232.160050]  [<c03ce82a>] error_code+0x72/0x78
[  232.160050]  [<f8163c85>] ? vlan_dev_neigh_setup+0x23/0x2a [8021q]
[  232.160050]  [<c011fd49>] ? hrtick_start_fair+0x1f/0x17d
[  232.160050]  [<c011ff82>] dequeue_task_fair+0x51/0x56
[  232.160050]  [<c011da63>] dequeue_task+0xd5/0xe4
[  232.160050]  [<c011daaa>] deactivate_task+0x19/0x1f
[  232.160050]  [<c011e504>] pull_task+0x11/0x3d
[  232.160050]  [<c011e6fc>] load_balance_fair+0x134/0x1ce
[  232.160050]  [<c0124684>] rebalance_domains+0x219/0x421
[  232.160050]  [<c01248ba>] run_rebalance_domains+0x2e/0x9e
[  232.160050]  [<c012e0e7>] __do_softirq+0x8d/0x133
[  232.160050]  [<c012e1d5>] do_softirq+0x48/0x57
[  232.160050]  [<c012e2e6>] irq_exit+0x38/0x66
[  232.160050]  [<c011228b>] smp_apic_timer_interrupt+0x74/0x82
[  232.160050]  [<c0103cc0>] apic_timer_interrupt+0x28/0x30
[  232.160050]  [<c011824f>] ? native_safe_halt+0x5/0x7
[  232.160050]  [<c0108c92>] default_idle+0x30/0x58
[  232.160050]  [<c0102605>] cpu_idle+0x63/0x7e
[  232.160050]  [<c03bee3b>] rest_init+0x53/0x55
[  232.160050] ---[ end trace b72565b053d710ac ]---
