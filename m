From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: net/ipv4: KASAN: use-after-free in tcp_v4_rcv
Date: Sun, 15 May 2016 11:47:53 -0700
Message-ID: <1463338073.18194.35.camel@edumazet-glaptop3.roam.corp.google.com>
References: <57389D92.6050408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Baozeng Ding <sploving1@gmail.com>,
	Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57389D92.6050408@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-05-16 at 00:02 +0800, Baozeng Ding wrote:
> Hi all,
> I've got the following report use-after-free in tcp_v4_rcv while running 
> syzkaller.
> Unfortunately no reproducer.The kernel version is 4.6.0-rc2+.
> 
> ===========================================================
> BUG: KASAN: use-after-free in tcp_v4_rcv+0x2144/0x2c20 at addr 
> ffff8800380279c0
> Write of size 8 by task syz-executor/7055
> =============================================================================
> BUG skbuff_head_cache (Tainted: G    B D        ): kasan: bad access 
> detected
> -----------------------------------------------------------------------------
> 
> INFO: Freed in e1000_clean+0xa08/0x24a0 age=6364136532 cpu=2226773637 pid=-1
> [<     inline     >] napi_poll net/core/dev.c:5087
> [<      none      >] net_rx_action+0x751/0xd80 net/core/dev.c:5152
> [<      none      >] __do_softirq+0x22b/0x8da kernel/softirq.c:273
> [<     inline     >] invoke_softirq kernel/softirq.c:350
> [<      none      >] irq_exit+0x15d/0x190 kernel/softirq.c:391
> [<     inline     >] exiting_irq ./arch/x86/include/asm/apic.h:658
> [<      none      >] do_IRQ+0x86/0x1a0 arch/x86/kernel/irq.c:252
> [<      none      >] ret_from_intr+0x0/0x20 arch/x86/entry/entry_64.S:454
> [<      none      >] kfree_skbmem+0xe6/0x100 net/core/skbuff.c:622
> [<      none      >] __slab_free+0x1e8/0x300 mm/slub.c:2657
> [<     inline     >] slab_free mm/slub.c:2810
> [<      none      >] kmem_cache_free+0x298/0x320 mm/slub.c:2819
> [<      none      >] kfree_skbmem+0xe6/0x100 net/core/skbuff.c:622
> [<      none      >] __kfree_skb+0x1d/0x20 net/core/skbuff.c:684
> [<      none      >] kfree_skb+0x107/0x310 net/core/skbuff.c:704
> [<      none      >] packet_rcv_spkt+0xd8/0x4a0 net/packet/af_packet.c:1822
> [<     inline     >] deliver_skb net/core/dev.c:1814
> [<     inline     >] deliver_ptype_list_skb net/core/dev.c:1829
> [<      none      >] __netif_receive_skb_core+0x134a/0x3060 
> net/core/dev.c:4143
> [<      none      >] __netif_receive_skb+0x2a/0x160 net/core/dev.c:4198
> 

Above stack trace looks suspicious.

It looks like __netif_receive_skb() is called from a context with BH
enabled.

Some hard irq is happening, and invoke_softirq() enters __do_softirq()

Getting more depth in this stack trace would be nice ?


> 
> Call Trace:
>   [<     inline     >] __dump_stack lib/dump_stack.c:15
>   [<ffffffff829557d1>] dump_stack+0xb3/0x112 lib/dump_stack.c:51
>   [<ffffffff8170fabd>] print_trailer+0x10d/0x190 mm/slub.c:667
>   [<ffffffff817165af>] object_err+0x2f/0x40 mm/slub.c:674
>   [<     inline     >] print_address_description mm/kasan/report.c:179
>   [<ffffffff81718dd8>] kasan_report_error+0x218/0x530 mm/kasan/report.c:275
>   [<ffffffff84f3c5f4>] ? tcp_v4_rcv+0x1d14/0x2c20 net/ipv4/tcp_ipv4.c:1653
>   [<     inline     >] kasan_report mm/kasan/report.c:297
>   [<ffffffff8171932e>] __asan_report_store8_noabort+0x3e/0x40 
> mm/kasan/report.c:323
>   [<     inline     >] ? nf_reset include/linux/skbuff.h:3464
>   [<ffffffff84f3c501>] ? tcp_v4_rcv+0x1c21/0x2c20 net/ipv4/tcp_ipv4.c:1639
>   [<     inline     >] ? __sk_add_backlog include/net/sock.h:810
>   [<     inline     >] ? sk_add_backlog include/net/sock.h:843
>   [<ffffffff84f3ca24>] ? tcp_v4_rcv+0x2144/0x2c20 net/ipv4/tcp_ipv4.c:1659
>   [<     inline     >] __sk_add_backlog include/net/sock.h:810
>   [<     inline     >] sk_add_backlog include/net/sock.h:843
>   [<ffffffff84f3ca24>] tcp_v4_rcv+0x2144/0x2c20 net/ipv4/tcp_ipv4.c:1659
>   [<ffffffff84f5b6b1>] ? raw_local_deliver+0x7c1/0xae0 net/ipv4/raw.c:221
>   [<ffffffff84cee35a>] ? nf_iterate+0x1aa/0x230 net/netfilter/core.c:289
>   [<ffffffff84cee3e0>] ? nf_iterate+0x230/0x230 net/netfilter/core.c:268
>   [<ffffffff84e96fb0>] ip_local_deliver_finish+0x2b0/0xa50 
> net/ipv4/ip_input.c:216
>   [<     inline     >] ? __skb_pull include/linux/skbuff.h:1900
>   [<ffffffff84e96e2a>] ? ip_local_deliver_finish+0x12a/0xa50 
> net/ipv4/ip_input.c:194
>   [<     inline     >] NF_HOOK_THRESH include/linux/netfilter.h:219
>   [<     inline     >] NF_HOOK include/linux/netfilter.h:242
>   [<ffffffff84e97e43>] ip_local_deliver+0x1b3/0x350 net/ipv4/ip_input.c:257
>   [<ffffffff84e97c90>] ? ip_call_ra_chain+0x540/0x540 
> net/ipv4/ip_input.c:163
>   [<ffffffff84e96d00>] ? ip_rcv_finish+0x1ab0/0x1ab0 
> include/net/net_namespace.h:259
>   [<     inline     >] dst_input include/net/dst.h:510
>   [<ffffffff84e958c9>] ip_rcv_finish+0x679/0x1ab0 net/ipv4/ip_input.c:388
>   [<ffffffff84be8d1f>] ? sk_filter+0x7f/0xe50 net/core/filter.c:94
>   [<     inline     >] NF_HOOK_THRESH include/linux/netfilter.h:219
>   [<     inline     >] NF_HOOK include/linux/netfilter.h:242
>   [<ffffffff84e98943>] ip_rcv+0x963/0x10c0 net/ipv4/ip_input.c:478
>   [<ffffffff84e97fe0>] ? ip_local_deliver+0x350/0x350 
> net/ipv4/ip_input.c:250
>   [<ffffffff84b56c02>] ? skb_release_data+0x3d2/0x430 net/core/skbuff.c:599
>   [<ffffffff84e95250>] ? inet_del_offload+0x40/0x40 ??:?
>   [<ffffffff852211ed>] ? packet_rcv_spkt+0xdd/0x4a0 
> net/packet/af_packet.c:1822
>   [<ffffffff84e97fe0>] ? ip_local_deliver+0x350/0x350 
> net/ipv4/ip_input.c:250
>   [<ffffffff84b99b1d>] __netif_receive_skb_core+0x168d/0x3060 
> net/core/dev.c:4160
>   [<ffffffff84b98490>] ? netif_wake_subqueue+0x220/0x220 
> include/linux/compiler.h:222
>   [<     inline     >] ? ktime_get_real include/linux/timekeeping.h:179
>   [<     inline     >] ? __net_timestamp include/linux/skbuff.h:3099
>   [<ffffffff84b9ddf5>] ? netif_receive_skb_internal+0x125/0x390 
> net/core/dev.c:4207
>   [<     inline     >] ? __net_timestamp include/linux/skbuff.h:3099
>   [<ffffffff84b9de1a>] ? netif_receive_skb_internal+0x14a/0x390 
> net/core/dev.c:4207
>   [<ffffffff84b9b51a>] __netif_receive_skb+0x2a/0x160 net/core/dev.c:4198
>   [<ffffffff84b9de85>] netif_receive_skb_internal+0x1b5/0x390 
> net/core/dev.c:4226
>   [<     inline     >] ? __net_timestamp include/linux/skbuff.h:3099
>   [<ffffffff84b9de1a>] ? netif_receive_skb_internal+0x14a/0x390 
> net/core/dev.c:4207
>   [<ffffffff84b9dcd0>] ? dev_cpu_callback+0x690/0x690 net/core/dev.c:7755
>   [<ffffffff84ba1849>] ? dev_gro_receive+0x1d9/0x16f0 net/core/dev.c:4514
>   [<     inline     >] ? skb_is_gso include/linux/skbuff.h:3648
>   [<ffffffff84ba1cd5>] ? dev_gro_receive+0x665/0x16f0 net/core/dev.c:4426
>   [<ffffffff817187d2>] ? kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:482
>   [<     inline     >] ? trace_kmem_cache_alloc 
> include/trace/events/kmem.h:53
>   [<ffffffff81713149>] ? kmem_cache_alloc+0x1f9/0x2f0 mm/slub.c:2587
>   [<ffffffff84c46a40>] ? eth_type_trans+0x2a0/0x5b0 net/ethernet/eth.c:186
>   [<     inline     >] napi_skb_finish net/core/dev.c:4553
>   [<ffffffff84ba3882>] napi_gro_receive+0x2c2/0x480 net/core/dev.c:4585
>   [<     inline     >] e1000_receive_skb 
> drivers/net/ethernet/intel/e1000/e1000_main.c:4035
>   [<ffffffff83977bb0>] e1000_clean_rx_irq+0x440/0x1110 
> drivers/net/ethernet/intel/e1000/e1000_main.c:4491
>   [<ffffffff83977770>] ? e1000_enter_82542_rst+0x260/0x260 
> drivers/net/ethernet/intel/e1000/e1000_main.c:2148
>   [<ffffffff83974d08>] e1000_clean+0xa08/0x24a0 
> drivers/net/ethernet/intel/e1000/e1000_main.c:3836
>   [<ffffffff813c0d29>] ? check_preempt_wakeup+0x3c9/0xa70 
> kernel/sched/fair.c:5411
>   [<ffffffff83974300>] ? 
> e1000_unmap_and_free_tx_resource.isra.46+0x3e0/0x3e0 
> drivers/net/ethernet/intel/e1000/e1000_main.c:1972
>   [<ffffffff814011ad>] ? trace_hardirqs_off+0xd/0x10 
> kernel/locking/lockdep.c:2772
>   [<ffffffff81409300>] ? debug_check_no_locks_freed+0x290/0x290 
> kernel/locking/lockdep.c:4212
>   [<     inline     >] napi_poll net/core/dev.c:5087
>   [<ffffffff84ba02c1>] net_rx_action+0x751/0xd80 net/core/dev.c:5152
>   [<ffffffff82da9bbc>] ? add_interrupt_randomness+0x2bc/0x570 
> drivers/char/random.c:922
>   [<ffffffff84b9fb70>] ? sk_busy_loop+0x1130/0x1130 
> include/trace/events/napi.h:13
>   [<ffffffff814412a2>] ? handle_irq_event+0xb2/0x140 kernel/irq/handle.c:194
>   [<     inline     >] ? apic_eoi ./arch/x86/include/asm/apic.h:402
>   [<     inline     >] ? ack_APIC_irq ./arch/x86/include/asm/apic.h:446
>   [<ffffffff812120d5>] ? ioapic_ack_level+0x165/0x450 
> arch/x86/kernel/apic/io_apic.c:1814
>   [<     inline     >] ? invoke_softirq kernel/softirq.c:350
>   [<ffffffff8131690d>] ? irq_exit+0x15d/0x190 kernel/softirq.c:391
>   [<ffffffff85c8d91b>] __do_softirq+0x22b/0x8da kernel/softirq.c:273
>   [<     inline     >] invoke_softirq kernel/softirq.c:350
>   [<ffffffff8131690d>] irq_exit+0x15d/0x190 kernel/softirq.c:391
>   [<     inline     >] exiting_irq ./arch/x86/include/asm/apic.h:658
>   [<ffffffff85c8d0c6>] do_IRQ+0x86/0x1a0 arch/x86/kernel/irq.c:252
>   [<ffffffff85c8b50c>] common_interrupt+0x8c/0x8c 
> arch/x86/entry/entry_64.S:454
>   [<     inline     >] ? copy_pte_range mm/memory.c:945
>   [<     inline     >] ? copy_pmd_range mm/memory.c:1003
>   [<     inline     >] ? copy_pud_range mm/memory.c:1025
>   [<ffffffff816accd9>] ? copy_page_range+0xa69/0x19d0 mm/memory.c:1087
>   [<     inline     >] ? copy_pte_range mm/memory.c:945
>   [<     inline     >] ? copy_pmd_range mm/memory.c:1003
>   [<     inline     >] ? copy_pud_range mm/memory.c:1025
>   [<ffffffff816accba>] ? copy_page_range+0xa4a/0x19d0 mm/memory.c:1087
>   [<     inline     >] ? rb_insert_augmented 
> include/linux/rbtree_augmented.h:60
>   [<     inline     >] ? __anon_vma_interval_tree_insert 
> mm/interval_tree.c:72
>   [<ffffffff81694b83>] ? anon_vma_interval_tree_insert+0x233/0x2d0 
> mm/interval_tree.c:83
>   [<ffffffff816ac270>] ? vm_iomap_memory+0x130/0x130 mm/memory.c:1836
>   [<     inline     >] ? vma_rb_insert include/linux/rbtree_augmented.h:60
>   [<ffffffff816b7795>] ? __vma_link_rb+0x445/0x5d0 mm/mmap.c:531
>   [<     inline     >] dup_mmap kernel/fork.c:513
>   [<     inline     >] dup_mm kernel/fork.c:937
>   [<     inline     >] copy_mm kernel/fork.c:991
>   [<ffffffff812ffeed>] copy_process.part.37+0x468d/0x5a50 kernel/fork.c:1456
>   [<ffffffff812fb860>] ? __cleanup_sighand+0x50/0x50 kernel/fork.c:1105
>   [<     inline     >] copy_process kernel/fork.c:1282
>   [<ffffffff813015c9>] _do_fork+0x1a9/0xcd0 kernel/fork.c:1731
>   [<ffffffff81301420>] ? fork_idle+0x110/0x110 include/linux/list.h:601
>   [<ffffffff8183628e>] ? __fsnotify_parent+0x5e/0x2b0 
> fs/notify/fsnotify.c:98
>   [<     inline     >] ? inc_syscr include/linux/sched.h:3178
>   [<ffffffff81764623>] ? vfs_read+0x223/0x310 fs/read_write.c:499
>   [<     inline     >] SYSC_clone kernel/fork.c:1840
>   [<ffffffff813021c7>] SyS_clone+0x37/0x50 kernel/fork.c:1834
>   [<ffffffff85c8ad30>] ? ptregs_sys_rt_sigreturn+0x10/0x10 
> arch/x86/include/generated/asm/syscalls_64.h:16
>   [<ffffffff8100653d>] do_syscall_64+0x1ad/0x4b0 arch/x86/entry/common.c:350
>   [<ffffffff81302190>] ? sys_vfork+0x30/0x30 kernel/fork.c:1813
>   [<ffffffff85c8ac43>] entry_SYSCALL64_slow_path+0x25/0x25 
> arch/x86/entry/entry_64.S:248
> Memory state around the buggy address:
>   ffff880038027880: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>   ffff880038027900: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
> >ffff880038027980: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
>                                             ^
>   ffff880038027a00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>   ffff880038027a80: fb fb fb fb fc fc fc fc fc fc fc fc fc fc fc fc
> ==================================================================
> 
> 
> Best Regards,
> Baozeng Ding
