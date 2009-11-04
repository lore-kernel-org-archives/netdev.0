From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: kernel WARNING/BUG with IOMMU + skb_dma_map/unmap + pktgen
Date: Tue, 03 Nov 2009 17:44:33 -0800
Message-ID: <4AF0DC81.10305@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>, dwmw2@infradead.org
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:4917 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751012AbZKDBo3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Nov 2009 20:44:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It looks like skb_dma_map/unmap plus trying to transmit multiple copies
of the same skb via pktgen doesn't work when a hardware IOMMU is enabled.

We first saw this on igb doing a loopback test partially due to the fact 
that I had copied the approach used by pktgen of just incrementing the 
user count and sending the same skb into the transmit path multiple 
times.  However we did some testing to verify that this is reproducible 
on other NICs using skb_dma_map/unmap and pktgen and generated the 
traces below on a tg3 w/ pktgen configured to clone_skb several times.

The issue seems to be due to the fact that skb_dma_map assumes that
dma_map_single/page should return the same value every time it is 
called, however in the case of having a hardware iommu enabled this is 
not so and as a result we end up leaking dma mappings and then attempt 
multiple unmaps on the last dma mapping we received.

I'm wondering if this is a valid issue since I am not sure how many 
different situations will result in a skb being cloned and sent either 
to the same device multiple times or to multiple devices.  Also I am 
looking for suggestions on how best to address this without negatively 
impacting TX performance.

Thanks,

Alex

DRHD: handling fault status reg 2
DMAR:[DMA Read] Request device [05:00.0] fault addr ffb9c000
DMAR:[fault reason 06] PTE Read access is not set
------------[ cut here ]------------
WARNING: at lib/dma-debug.c:798 check_unmap+0x158/0x5bf()
Hardware name: S5520HC
tg3 0000:05:00.0: DMA-API: device driver tries to free DMA memory it has
not allocated [device address=0x00000000ffb9c822] [size=1200 bytes]
Modules linked in: pktgen tg3 ipv6 autofs4 sunrpc cpufreq_ondemand
acpi_cpufreq freq_table video output sbs sbshc joydev shpchp iTCO_wdt
i2c_i801 i2c_core pcspkr iTCO_vendor_support usb_storage [last unloaded:
igb]
Pid: 8701, comm: kpktgend_0 Not tainted
2.6.32-rc3-net-next-igb-tag110309 #12
Call Trace:
   <IRQ>  [<ffffffff811c2500>] ? check_unmap+0x158/0x5bf
   [<ffffffff81046006>] warn_slowpath_common+0x77/0x8f
   [<ffffffff810460ce>] warn_slowpath_fmt+0x9f/0xa1
   [<ffffffff8137fca5>] ? _spin_lock_irqsave+0x44/0x50
   [<ffffffff811c182f>] ? get_hash_bucket+0x28/0x33
   [<ffffffff8106c648>] ? register_lock_class+0x20/0x29f
   [<ffffffff811c2500>] check_unmap+0x158/0x5bf
   [<ffffffff8106ccb9>] ? __lock_acquire+0x20d/0x3ce
   [<ffffffff8100e020>] ? do_IRQ+0x97/0xae
   [<ffffffff811c2b11>] debug_dma_unmap_page+0x80/0x92
   [<ffffffff811dcea8>] ? intel_unmap_page+0xf6/0x103
   [<ffffffff812e1dd9>] dma_unmap_single_attrs+0x5c/0x68
   [<ffffffff812e2043>] skb_dma_unmap+0x3f/0x78
   [<ffffffffa01a8890>] tg3_poll+0x172/0x77d [tg3]
   [<ffffffff812e2f84>] ? rcu_read_lock+0x0/0x3a
   [<ffffffff812e7ff1>] net_rx_action+0xbc/0x19f
   [<ffffffff8104bcf1>] __do_softirq+0xd5/0x19d
   [<ffffffff8100cc9c>] call_softirq+0x1c/0x34
   <EOI>  [<ffffffff8100e2d8>] do_softirq+0x33/0x6b
   [<ffffffff8104b541>] _local_bh_enable_ip+0x78/0xa7
   [<ffffffff8104b579>] local_bh_enable_ip+0x9/0xb
   [<ffffffff8137f9a2>] _spin_unlock_bh+0x39/0x3d
   [<ffffffffa004a2c3>] pktgen_xmit+0xf5f/0xfe3 [pktgen]
   [<ffffffffa01a65f7>] ? tg3_start_xmit_dma_bug+0x0/0x7cd [tg3]
   [<ffffffff8106ccb9>] ? __lock_acquire+0x20d/0x3ce
   [<ffffffffa004a3e5>] ? pktgen_thread_worker+0x9e/0x660 [pktgen]
   [<ffffffffa004a4ed>] pktgen_thread_worker+0x1a6/0x660 [pktgen]
   [<ffffffff8103236b>] ? need_resched+0x1e/0x28
   [<ffffffff8105e693>] ? autoremove_wake_function+0x0/0x38
   [<ffffffff8105e693>] ? autoremove_wake_function+0x0/0x38
   [<ffffffffa004a347>] ? pktgen_thread_worker+0x0/0x660 [pktgen]
   [<ffffffff8105e459>] kthread+0x69/0x71
   [<ffffffff8100cb9a>] child_rip+0xa/0x20
   [<ffffffff8105e3f0>] ? kthread+0x0/0x71
   [<ffffffff8100cb90>] ? child_rip+0x0/0x20
---[ end trace 39dadbc5c44cf3fd ]---
------------[ cut here ]------------
WARNING: at drivers/pci/intel-iommu.c:2719 intel_unmap_page+0x8e/0x103()
Hardware name: S5520HC
Driver unmaps unmatched page at PFN ffb9c822
Modules linked in: pktgen tg3 ipv6 autofs4 sunrpc cpufreq_ondemand
acpi_cpufreq freq_table video output sbs sbshc joydev shpchp iTCO_wdt
i2c_i801 i2c_core pcspkr iTCO_vendor_support usb_storage [last unloaded:
igb]
Pid: 8701, comm: kpktgend_0 Tainted: G        W
2.6.32-rc3-net-next-igb-tag110309 #12
Call Trace:
   <IRQ>  [<ffffffff811dce40>] ? intel_unmap_page+0x8e/0x103
   [<ffffffff81046006>] warn_slowpath_common+0x77/0x8f
   [<ffffffff810460ce>] warn_slowpath_fmt+0x9f/0xa1
   [<ffffffff811dac28>] ? find_iova+0x18/0x66
   [<ffffffff8137fa55>] ? _spin_unlock_irqrestore+0x57/0x5c
   [<ffffffff811dac6b>] ? find_iova+0x5b/0x66
   [<ffffffff811dce40>] intel_unmap_page+0x8e/0x103
   [<ffffffff812e1dc3>] dma_unmap_single_attrs+0x46/0x68
   [<ffffffff812e2043>] skb_dma_unmap+0x3f/0x78
   [<ffffffffa01a8890>] tg3_poll+0x172/0x77d [tg3]
   [<ffffffff812e2f84>] ? rcu_read_lock+0x0/0x3a
   [<ffffffff812e7ff1>] net_rx_action+0xbc/0x19f
   [<ffffffff8104bcf1>] __do_softirq+0xd5/0x19d
   [<ffffffff8100cc9c>] call_softirq+0x1c/0x34
   <EOI>  [<ffffffff8100e2d8>] do_softirq+0x33/0x6b
   [<ffffffff8104b541>] _local_bh_enable_ip+0x78/0xa7
   [<ffffffff8104b579>] local_bh_enable_ip+0x9/0xb
   [<ffffffff8137f9a2>] _spin_unlock_bh+0x39/0x3d
   [<ffffffffa004a2c3>] pktgen_xmit+0xf5f/0xfe3 [pktgen]
   [<ffffffffa01a65f7>] ? tg3_start_xmit_dma_bug+0x0/0x7cd [tg3]
   [<ffffffff8106ccb9>] ? __lock_acquire+0x20d/0x3ce
   [<ffffffffa004a3e5>] ? pktgen_thread_worker+0x9e/0x660 [pktgen]
   [<ffffffffa004a4ed>] pktgen_thread_worker+0x1a6/0x660 [pktgen]
   [<ffffffff8103236b>] ? need_resched+0x1e/0x28
   [<ffffffff8105e693>] ? autoremove_wake_function+0x0/0x38
   [<ffffffff8105e693>] ? autoremove_wake_function+0x0/0x38
   [<ffffffffa004a347>] ? pktgen_thread_worker+0x0/0x660 [pktgen]
   [<ffffffff8105e459>] kthread+0x69/0x71
   [<ffffffff8100cb9a>] child_rip+0xa/0x20
   [<ffffffff8105e3f0>] ? kthread+0x0/0x71
   [<ffffffff8100cb90>] ? child_rip+0x0/0x20
---[ end trace 39dadbc5c44cf3fe ]---
------------[ cut here ]------------
kernel BUG at drivers/pci/iova.c:155!
invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
last sysfs file:
/sys/devices/pci0000:00/0000:00:1e.0/0000:0a:00.0/local_cpus
CPU 0
Modules linked in: pktgen tg3 ipv6 autofs4 sunrpc cpufreq_ondemand
acpi_cpufreq freq_table video output sbs sbshc joydev shpchp iTCO_wdt
i2c_i801 i2c_core pcspkr iTCO_vendor_support usb_storage [last unloaded:
igb]
Pid: 8701, comm: kpktgend_0 Tainted: G        W
2.6.32-rc3-net-next-igb-tag110309 #12 S5520HC
RIP: 0010:[<ffffffff811db065>]  [<ffffffff811db065>] alloc_iova+0x174/0x1d7
RSP: 0018:ffff88036570fac0  EFLAGS: 00010046
RAX: 00000000000ffb9b RBX: ffff8801e78d4180 RCX: 0000000000000000
RDX: ffff8801e73ba710 RSI: ffff8801e73ba700 RDI: 0000000000000001
RBP: ffff88036570fb20 R08: 0000000000000000 R09: ffff880100000000
R10: ffffffff811daf48 R11: 0000fffffffff000 R12: 00000000000ffb9b
R13: 0000000000000001 R14: ffff8801e5cad520 R15: ffff8801e73ba700
FS:  0000000000000000(0000) GS:ffff880028200000(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 00007fef515530a0 CR3: 0000000001001000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process kpktgend_0 (pid: 8701, threadinfo ffff88036570e000, task
ffff8803661d3fc0)
Stack:
   ffffffff81e5a328 ffffffff81e5a310 00000000000fffff 0000000000000286
<0> 01ff8801e88de890 ffffffff81e5a310 ffff8801e78d4180 ffff8801e88de890
<0> 0000fffffffff000 ffff8801e5cad500 0000000000000001 ffff8801e88de890
Call Trace:
   [<ffffffff811dd992>] intel_alloc_iova+0x68/0xb4
   [<ffffffff811ddc3a>] __intel_map_single+0x7d/0x152
   [<ffffffff811ddd0f>] ? intel_map_page+0x0/0x3e
   [<ffffffff811ddd4b>] intel_map_page+0x3c/0x3e
   [<ffffffff812e1e77>] skb_dma_map+0x92/0x21f
   [<ffffffff81039012>] ? finish_task_switch+0x7c/0x9e
   [<ffffffffa01a6976>] tg3_start_xmit_dma_bug+0x37f/0x7cd [tg3]
   [<ffffffffa004a1ef>] ? pktgen_xmit+0xe8b/0xfe3 [pktgen]
   [<ffffffffa004a230>] pktgen_xmit+0xecc/0xfe3 [pktgen]
   [<ffffffffa01a65f7>] ? tg3_start_xmit_dma_bug+0x0/0x7cd [tg3]
   [<ffffffff8106ccb9>] ? __lock_acquire+0x20d/0x3ce
   [<ffffffffa004a3e5>] ? pktgen_thread_worker+0x9e/0x660 [pktgen]
   [<ffffffffa004a4ed>] pktgen_thread_worker+0x1a6/0x660 [pktgen]
   [<ffffffff8103236b>] ? need_resched+0x1e/0x28
   [<ffffffff8105e693>] ? autoremove_wake_function+0x0/0x38
   [<ffffffff8105e693>] ? autoremove_wake_function+0x0/0x38
   [<ffffffffa004a347>] ? pktgen_thread_worker+0x0/0x660 [pktgen]
   [<ffffffff8105e459>] kthread+0x69/0x71
   [<ffffffff8100cb9a>] child_rip+0xa/0x20
   [<ffffffff8105e3f0>] ? kthread+0x0/0x71
   [<ffffffff8100cb90>] ? child_rip+0x0/0x20
Code: 05 ff 49 89 47 18 48 83 7d d0 00 75 04 49 8d 56 30 31 c0 eb 1d 48
8b 46 20 48 8d 56 10 49 39 47 20 72 0c 76 06 48 8d 56 08 eb 04 <0f> 0b
eb fe 48 89 f0 48 8b 32 48 85 f6 75 db 48 89 c6 4c 89 ff
RIP  [<ffffffff811db065>] alloc_iova+0x174/0x1d7
   RSP <ffff88036570fac0>
---[ end trace 39dadbc5c44cf3ff ]---
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 8701, comm: kpktgend_0 Tainted: G      D W
2.6.32-rc3-net-next-igb-tag110309 #12
Call Trace:
   [<ffffffff810461c4>] panic+0xe5/0x195
   [<ffffffff8137fa4c>] ? _spin_unlock_irqrestore+0x4e/0x5c
   [<ffffffff81046860>] ? release_console_sem+0x19e/0x1ab
   [<ffffffff81046a8b>] ? console_unblank+0x65/0x69
   [<ffffffff81045e36>] ? print_oops_end_marker+0x1e/0x20
   [<ffffffff81380d8f>] oops_end+0xaa/0xba
   [<ffffffff8100f41d>] die+0x55/0x5e
   [<ffffffff813806b2>] do_trap+0x110/0x11f
   [<ffffffff8100d4bb>] do_invalid_op+0x91/0x9a
   [<ffffffff811db065>] ? alloc_iova+0x174/0x1d7
   [<ffffffff8137faa4>] ? _spin_unlock+0x4a/0x57
   [<ffffffff8106ccb9>] ? __lock_acquire+0x20d/0x3ce
   [<ffffffff8100c935>] invalid_op+0x15/0x20
   [<ffffffff811daf48>] ? alloc_iova+0x57/0x1d7
   [<ffffffff811db065>] ? alloc_iova+0x174/0x1d7
   [<ffffffff811dd992>] intel_alloc_iova+0x68/0xb4
   [<ffffffff811ddc3a>] __intel_map_single+0x7d/0x152
   [<ffffffff811ddd0f>] ? intel_map_page+0x0/0x3e
   [<ffffffff811ddd4b>] intel_map_page+0x3c/0x3e
   [<ffffffff812e1e77>] skb_dma_map+0x92/0x21f
   [<ffffffff81039012>] ? finish_task_switch+0x7c/0x9e
   [<ffffffffa01a6976>] tg3_start_xmit_dma_bug+0x37f/0x7cd [tg3]
   [<ffffffffa004a1ef>] ? pktgen_xmit+0xe8b/0xfe3 [pktgen]
   [<ffffffffa004a230>] pktgen_xmit+0xecc/0xfe3 [pktgen]
   [<ffffffffa01a65f7>] ? tg3_start_xmit_dma_bug+0x0/0x7cd [tg3]
   [<ffffffff8106ccb9>] ? __lock_acquire+0x20d/0x3ce
   [<ffffffffa004a3e5>] ? pktgen_thread_worker+0x9e/0x660 [pktgen]
   [<ffffffffa004a4ed>] pktgen_thread_worker+0x1a6/0x660 [pktgen]
   [<ffffffff8103236b>] ? need_resched+0x1e/0x28
   [<ffffffff8105e693>] ? autoremove_wake_function+0x0/0x38
   [<ffffffff8105e693>] ? autoremove_wake_function+0x0/0x38
   [<ffffffffa004a347>] ? pktgen_thread_worker+0x0/0x660 [pktgen]
   [<ffffffff8105e459>] kthread+0x69/0x71
   [<ffffffff8100cb9a>] child_rip+0xa/0x20
   [<ffffffff8105e3f0>] ? kthread+0x0/0x71
   [<ffffffff8100cb90>] ? child_rip+0x0/0x20
------------[ cut here ]------------
WARNING: at arch/x86/kernel/smp.c:117 native_smp_send_reschedule+0x25/0x43()
Hardware name: S5520HC
Modules linked in: pktgen tg3 ipv6 autofs4 sunrpc cpufreq_ondemand
acpi_cpufreq freq_table video output sbs sbshc joydev shpchp iTCO_wdt
i2c_i801 i2c_core pcspkr iTCO_vendor_support usb_storage [last unloaded:
igb]
Pid: 8701, comm: kpktgend_0 Tainted: G      D W
2.6.32-rc3-net-next-igb-tag110309 #12
Call Trace:
   <IRQ>  [<ffffffff81034a05>] ? __enqueue_entity+0x74/0x76
   [<ffffffff8101eefc>] ? native_smp_send_reschedule+0x25/0x43
   [<ffffffff81046006>] warn_slowpath_common+0x77/0x8f
   [<ffffffff8104602d>] warn_slowpath_null+0xf/0x11
   [<ffffffff8101eefc>] native_smp_send_reschedule+0x25/0x43
   [<ffffffff8102ff5d>] smp_send_reschedule+0xa/0xc
   [<ffffffff810324ea>] resched_task+0x67/0x6c
   [<ffffffff81032585>] check_preempt_curr_idle+0x10/0x12
   [<ffffffff81030056>] check_preempt_curr+0x12/0x14
   [<ffffffff8103dfbf>] try_to_wake_up+0x249/0x2b2
   [<ffffffff8103e035>] default_wake_function+0xd/0xf
   [<ffffffff8105e6a4>] autoremove_wake_function+0x11/0x38
   [<ffffffff81030bad>] __wake_up_common+0x41/0x74
   [<ffffffff810341d8>] __wake_up+0x38/0x4f
   [<ffffffff810468c0>] printk_tick+0x53/0x58
   [<ffffffff81051f13>] update_process_times+0x3e/0x54
   [<ffffffff8106b278>] tick_sched_timer+0x70/0x99
   [<ffffffff8106b208>] ? tick_sched_timer+0x0/0x99
   [<ffffffff81061101>] __run_hrtimer+0xba/0x121
   [<ffffffff8106125e>] hrtimer_interrupt+0xf6/0x152
   [<ffffffff81096d71>] ? rcu_irq_enter+0x15/0x63
   [<ffffffff81020124>] smp_apic_timer_interrupt+0x73/0x87
   [<ffffffff8100c673>] apic_timer_interrupt+0x13/0x20
   <EOI>  [<ffffffff81382434>] ? __atomic_notifier_call_chain+0x0/0xb2
   [<ffffffff81382434>] ? __atomic_notifier_call_chain+0x0/0xb2
   [<ffffffff81046252>] ? panic+0x173/0x195
   [<ffffffff810461e6>] ? panic+0x107/0x195
   [<ffffffff8137fa4c>] ? _spin_unlock_irqrestore+0x4e/0x5c
   [<ffffffff81046860>] ? release_console_sem+0x19e/0x1ab
   [<ffffffff81046a8b>] ? console_unblank+0x65/0x69
   [<ffffffff81045e36>] ? print_oops_end_marker+0x1e/0x20
   [<ffffffff81380d8f>] ? oops_end+0xaa/0xba
   [<ffffffff8100f41d>] ? die+0x55/0x5e
   [<ffffffff813806b2>] ? do_trap+0x110/0x11f
   [<ffffffff8100d4bb>] ? do_invalid_op+0x91/0x9a
   [<ffffffff811db065>] ? alloc_iova+0x174/0x1d7
   [<ffffffff8137faa4>] ? _spin_unlock+0x4a/0x57
   [<ffffffff8106ccb9>] ? __lock_acquire+0x20d/0x3ce
   [<ffffffff8100c935>] ? invalid_op+0x15/0x20
   [<ffffffff811daf48>] ? alloc_iova+0x57/0x1d7
   [<ffffffff811db065>] ? alloc_iova+0x174/0x1d7
   [<ffffffff811dd992>] ? intel_alloc_iova+0x68/0xb4
   [<ffffffff811ddc3a>] ? __intel_map_single+0x7d/0x152
   [<ffffffff811ddd0f>] ? intel_map_page+0x0/0x3e
   [<ffffffff811ddd4b>] ? intel_map_page+0x3c/0x3e
   [<ffffffff812e1e77>] ? skb_dma_map+0x92/0x21f
   [<ffffffff81039012>] ? finish_task_switch+0x7c/0x9e
   [<ffffffffa01a6976>] ? tg3_start_xmit_dma_bug+0x37f/0x7cd [tg3]
   [<ffffffffa004a1ef>] ? pktgen_xmit+0xe8b/0xfe3 [pktgen]
   [<ffffffffa004a230>] ? pktgen_xmit+0xecc/0xfe3 [pktgen]
   [<ffffffffa01a65f7>] ? tg3_start_xmit_dma_bug+0x0/0x7cd [tg3]
   [<ffffffff8106ccb9>] ? __lock_acquire+0x20d/0x3ce
   [<ffffffffa004a3e5>] ? pktgen_thread_worker+0x9e/0x660 [pktgen]
   [<ffffffffa004a4ed>] ? pktgen_thread_worker+0x1a6/0x660 [pktgen]
   [<ffffffff8103236b>] ? need_resched+0x1e/0x28
   [<ffffffff8105e693>] ? autoremove_wake_function+0x0/0x38
   [<ffffffff8105e693>] ? autoremove_wake_function+0x0/0x38
   [<ffffffffa004a347>] ? pktgen_thread_worker+0x0/0x660 [pktgen]
   [<ffffffff8105e459>] ? kthread+0x69/0x71
   [<ffffffff8100cb9a>] ? child_rip+0xa/0x20
   [<ffffffff8105e3f0>] ? kthread+0x0/0x71
   [<ffffffff8100cb90>] ? child_rip+0x0/0x20
---[ end trace 39dadbc5c44cf400 ]---

