From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [netlink] WARNING: at mm/vmalloc.c:1487 __vunmap()
Date: Sat, 15 Jun 2013 06:01:19 +0800
Message-ID: <20130614220119.GA12954@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="n8g4imXOkfNTN/H1"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: fengguang.wu@intel.com, Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:41888 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751537Ab3FNWBa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jun 2013 18:01:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--n8g4imXOkfNTN/H1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Greetings,

I got the below dmesg and the first bad commit is

commit c05cdb1b864f548c0c3d8ae3b51264e6739a69b1
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Mon Jun 3 09:46:28 2013 +0000

    netlink: allow large data transfers from user-space
    
    I can hit ENOBUFS in the sendmsg() path with a large batch that is
    composed of many netlink messages. Here that limit is 8 MBytes of
    skbuff data area as kmalloc does not manage to get more than that.
    
    While discussing atomic rule-set for nftables with Patrick McHardy,
    we decided to put all rule-set updates that need to be applied
    atomically in one single batch to simplify the existing approach.
    However, as explained above, the existing netlink code limits us
    to a maximum of ~20000 rules that fit in one single batch without
    hitting ENOBUFS. iptables does not have such limitation as it is
    using vmalloc.
    
    This patch adds netlink_alloc_large_skb() which is only used in
    the netlink_sendmsg() path. It uses alloc_skb if the memory
    requested is <= one memory page, that should be the common case
    for most subsystems, else vmalloc for higher memory allocations.
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: David S. Miller <davem@davemloft.net>


[   65.085802] init: plymouth-upstart-bridge main process (345) terminated with status 1
[   65.138243] ------------[ cut here ]------------
[   65.140281] WARNING: at /c/kernel-tests/src/tip/mm/vmalloc.c:1487 __vunmap+0x10b/0x110()
[   65.143247] Trying to vfree() nonexistent vm area (ffffc90000810000)
[   65.145697] CPU: 0 PID: 145 Comm: trinity Not tainted 3.10.0-rc5-00652-ge8a36a6 #9
[   65.148822] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[   65.151073]  0000000000000009 ffff88000f3b7bc8 ffffffff81d3e5b3 ffff88000f3b7c08
[   65.154718]  ffffffff810cf7a6 ffff88000f3b7c28 ffffc90000810000 0000000000000000
[   65.158343]  0000000000000001 ffff88000dc36620 ffff8800091c87b0 ffff88000f3b7c68
[   65.161574] Call Trace:
[   65.162609]  [<ffffffff81d3e5b3>] dump_stack+0x19/0x1b
[   65.164349]  [<ffffffff810cf7a6>] warn_slowpath_common+0x66/0x90
[   65.166294]  [<ffffffff810cf841>] warn_slowpath_fmt+0x41/0x50
[   65.168286]  [<ffffffff81166f7b>] __vunmap+0x10b/0x110
[   65.170351]  [<ffffffff81166e2f>] vfree+0x2f/0x70
[   65.172272]  [<ffffffff81afd478>] netlink_skb_destructor+0xb8/0x100
[   65.174645]  [<ffffffff81aac8a1>] skb_release_head_state+0x51/0xb0
[   65.177009]  [<ffffffff81aadb61>] skb_release_all+0x11/0x30
[   65.179175]  [<ffffffff81aadb91>] __kfree_skb+0x11/0x90
[   65.181293]  [<ffffffff81aad9d9>] kfree_skb+0x19/0x40
[   65.183308]  [<ffffffff81ab00a8>] skb_queue_purge+0x18/0x30
[   65.185482]  [<ffffffff81afd858>] netlink_sock_destruct+0x38/0x110
[   65.187873]  [<ffffffff81aa8c3a>] __sk_free+0x1a/0x120
[   65.189911]  [<ffffffff81aa9989>] sk_free+0x19/0x20
[   65.191875]  [<ffffffff81afec77>] netlink_release+0x177/0x2d0
[   65.194086]  [<ffffffff81aa6208>] sock_release+0x18/0x70
[   65.196172]  [<ffffffff81aa645d>] sock_close+0xd/0x20
[   65.198190]  [<ffffffff8118ae55>] __fput+0xf5/0x240
[   65.200189]  [<ffffffff8118b069>] ____fput+0x9/0x10
[   65.202139]  [<ffffffff810eb955>] task_work_run+0x85/0xc0
[   65.204257]  [<ffffffff810d4942>] do_exit+0x232/0x920
[   65.206262]  [<ffffffff810d50ab>] do_group_exit+0x3b/0x90
[   65.208353]  [<ffffffff810d5112>] SyS_exit_group+0x12/0x20
[   65.210517]  [<ffffffff81d46827>] system_call_fastpath+0x16/0x1b
[   65.212811] ---[ end trace 9a70fd0f1776886b ]---

git bisect start e8a36a6ada2098e53e13e7c4f28f3d0857738df4 v3.9 --
git bisect good 20b4fb485227404329e41ad15588afad3df23050  # 23:13    230+  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs
git bisect good eac84105cddf8686440aaa9fbcb58093e37e4180  # 23:35    230+  Merge tag 'for_linus' of git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost
git bisect good 5c64e3a45d43c6e3fa87cbe02e10059171d10812  # 00:00    230+  Merge branch 'queue' of git://git.kernel.org/pub/scm/linux/kernel/git/nab/target-pending
git bisect good 8764d86100fe58e69877753faa44fc1d9276c624  # 00:50    230+  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/mszeredi/fuse
git bisect good c8cecfd1abfb415bbfc4157e711b50c5c6fab270  # 01:08    230+  Merge remote-tracking branch 'asoc/for-next' into devel-cairo-x86_64-201306111910
git bisect good 311503bb2119788ac88c406e0893351a2bb0705e  # 03:56    230+  tulip: remove redundant D0 power state set
git bisect  bad ed0483fa06e0efb86a82e382a00dbad02b62807c  # 04:09    102-  macvtap: fix a possible race between queue selection and changing queues
git bisect good 6f45eba1894a3ece88574079a931cc2e5beee1f3  # 04:44    270+  Merge branch 'for-davem' of git://gitorious.org/linux-can/linux-can-next
git bisect good ddcd91c6b8ec60a6bd5d3691d2cfaf4447215da1  # 05:26    270+  sh_eth: use EDSR_ENALL to set EDSR
git bisect good ca162a82f56921442f5db72a3a472010e5a62c4b  # 06:17    270+  fec: Only pass pdev in fec_ptp_init()
git bisect  bad c18a79abe31f555ec3b363b5b8c1d003230053b6  # 06:57    171-  sh_eth: get SH7619 support out of #ifdef
git bisect  bad c05cdb1b864f548c0c3d8ae3b51264e6739a69b1  # 07:11     39-  netlink: allow large data transfers from user-space
git bisect good 1b5acd292336da029535de010af568533df9b665  # 12:20    875+  bonding: disallow change of MAC if fail_over_mac enabled
git bisect good 1b5acd292336da029535de010af568533df9b665  # 03:42   2626+  bonding: disallow change of MAC if fail_over_mac enabled
git bisect  bad e8a36a6ada2098e53e13e7c4f28f3d0857738df4  # 03:43      0-  Merge remote-tracking branch 'x0148406/tmp' into devel-cairo-x86_64-201306111910
git bisect good 340c0f42c1ef970e7cdd6c5a7351f45792fac8e1  # 16:37   2625+  Revert "netlink: allow large data transfers from user-space"
git bisect good a2648ebb7ed69ef209d9c8a76fadeb3252d9a023  # 00:27   2625+  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/mason/linux-btrfs
git bisect good c04efed734409f5a44715b54a6ca1b54b0ccf215  # 03:56   2625+  Add linux-next specific files for 20130607

Thanks,
Fengguang

--n8g4imXOkfNTN/H1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-kvm-vp-26729-20130611194828-3.10.0-rc5-00652-ge8a36a6-9"

[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.10.0-rc5-00652-ge8a36a6 (kbuild@cairo) (gcc version 4.7.2 (Debian 4.7.2-4) ) #9 Tue Jun 11 19:43:12 CST 2013
[    0.000000] Command line: hung_task_panic=1 rcutree.rcu_cpu_stall_timeout=100 log_buf_len=8M ignore_loglevel debug sched_debug apic=debug dynamic_printk sysrq_always_enabled panic=10  prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal  root=/dev/ram0 rw link=/kernel-tests/run-queue/kvm/x86_64-randconfig-c03-0611/devel-cairo-x86_64-201306111910/.vmlinuz-e8a36a6ada2098e53e13e7c4f28f3d0857738df4-20130611194428-9-vp branch=linux-devel/devel-cairo-x86_64-201306111910  BOOT_IMAGE=/kernel/x86_64-randconfig-c03-0611/e8a36a6ada2098e53e13e7c4f28f3d0857738df4/vmlinuz-3.10.0-rc5-00652-ge8a36a6
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x0000000000093bff] usable
[    0.000000] BIOS-e820: [mem 0x0000000000093c00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000000fffdfff] usable
[    0.000000] BIOS-e820: [mem 0x000000000fffe000-0x000000000fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.4 present.
[    0.000000] DMI: Bochs Bochs, BIOS Bochs 01/01/2007
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn = 0xfffe max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 00E0000000 mask FFE0000000 uncachable
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x70406, new 0x7010600070106
[    0.000000] Base memory trampoline at [ffff88000008d000] 8d000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x0276c000, 0x0276cfff] PGTABLE
[    0.000000] BRK [0x0276d000, 0x0276dfff] PGTABLE
[    0.000000] BRK [0x0276e000, 0x0276efff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x0e600000-0x0e7fffff]
[    0.000000]  [mem 0x0e600000-0x0e7fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x0c000000-0x0e5fffff]
[    0.000000]  [mem 0x0c000000-0x0e5fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x0bffffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x0bffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x0e800000-0x0fffdfff]
[    0.000000]  [mem 0x0e800000-0x0fdfffff] page 2M
[    0.000000]  [mem 0x0fe00000-0x0fffdfff] page 4k
[    0.000000] BRK [0x0276f000, 0x0276ffff] PGTABLE
[    0.000000] log_buf_len: 8388608
[    0.000000] early log buf free: 127612(97%)
[    0.000000] RAMDISK: [mem 0x0e8d6000-0x0ffeffff]
[    0.000000] ACPI: RSDP 00000000000fd920 00014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 000000000fffe550 00038 (v01 BOCHS  BXPCRSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACP 000000000fffff80 00074 (v01 BOCHS  BXPCFACP 00000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 000000000fffe590 01121 (v01   BXPC   BXDSDT 00000001 INTL 20100528)
[    0.000000] ACPI: FACS 000000000fffff40 00040
[    0.000000] ACPI: SSDT 000000000ffffe40 000FF (v01 BOCHS  BXPCSSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: APIC 000000000ffffd50 00080 (v01 BOCHS  BXPCAPIC 00000001 BXPC 00000001)
[    0.000000] ACPI: HPET 000000000ffffd10 00038 (v01 BOCHS  BXPCHPET 00000001 BXPC 00000001)
[    0.000000] ACPI: SSDT 000000000ffff6c0 00644 (v01   BXPC BXSSDTPC 00000001 INTL 20100528)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fa000 (        fee00000)
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:fffd001, boot clock
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x00092fff]
[    0.000000]   node   0: [mem 0x00100000-0x0fffdfff]
[    0.000000] On node 0 totalpages: 65424
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3986 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 960 pages used for memmap
[    0.000000]   DMA32 zone: 61438 pages, LIFO batch:15
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fa000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 1 reached.  Processor 1/0x1 ignored.
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 17, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 2, APIC INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 2, APIC INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 2, APIC INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 2, APIC INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 2, APIC INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 2, APIC INT 01
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 2, APIC INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 2, APIC INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 2, APIC INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 2, APIC INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 2, APIC INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 2, APIC INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 2, APIC INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 2, APIC INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 2, APIC INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] mapped IOAPIC to ffffffffff5f9000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 2428ec0
[    0.000000] e820: [mem 0x10000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=1*32768
[    0.000000] pcpu-alloc: [0] 0 
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 64379
[    0.000000] Kernel command line: hung_task_panic=1 rcutree.rcu_cpu_stall_timeout=100 log_buf_len=8M ignore_loglevel debug sched_debug apic=debug dynamic_printk sysrq_always_enabled panic=10  prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal  root=/dev/ram0 rw link=/kernel-tests/run-queue/kvm/x86_64-randconfig-c03-0611/devel-cairo-x86_64-201306111910/.vmlinuz-e8a36a6ada2098e53e13e7c4f28f3d0857738df4-20130611194428-9-vp branch=linux-devel/devel-cairo-x86_64-201306111910  BOOT_IMAGE=/kernel/x86_64-randconfig-c03-0611/e8a36a6ada2098e53e13e7c4f28f3d0857738df4/vmlinuz-3.10.0-rc5-00652-ge8a36a6
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 1024 (order: 1, 8192 bytes)
[    0.000000] Dentry cache hash table entries: 32768 (order: 6, 262144 bytes)
[    0.000000] Inode-cache hash table entries: 16384 (order: 5, 131072 bytes)
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Memory: 201092k/262136k available (13606k kernel code, 440k absent, 60604k reserved, 8328k data, 1000k init)
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
[    0.000000] NR_IRQS:4352 nr_irqs:256 16
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] console [ttyS0] enabled
[    0.000000] allocated 1048576 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=memory' option if you don't want memory cgroups
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 2693.558 MHz processor
[    0.020000] Calibrating delay loop (skipped) preset value.. 5387.11 BogoMIPS (lpj=26935580)
[    0.021767] pid_max: default: 32768 minimum: 301
[    0.023707] Mount-cache hash table entries: 256
[    0.025824] Initializing cgroup subsys debug
[    0.027648] Initializing cgroup subsys memory
[    0.030025] Initializing cgroup subsys devices
[    0.031832] Initializing cgroup subsys freezer
[    0.033598] Initializing cgroup subsys net_cls
[    0.035498] mce: CPU supports 10 MCE banks
[    0.037261] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.037261] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.037261] tlb_flushall_shift: 6
[    0.040006] CPU: Intel Common KVM processor (fam: 0f, model: 06, stepping: 01)
[    0.059782] ACPI: Core revision 20130328
[    0.063991] ACPI: All ACPI Tables successfully acquired
[    0.066448] Performance Events: unsupported Netburst CPU model 6 no PMU driver, software events only.
[    0.071724] Getting VERSION: 50014
[    0.073207] Getting VERSION: 50014
[    0.074677] Getting ID: 0
[    0.075955] Getting ID: ff000000
[    0.077431] Getting LVT0: 8700
[    0.080013] Getting LVT1: 8400
[    0.081477] enabled ExtINT on CPU#0
[    0.084262] ENABLING IO-APIC IRQs
[    0.085795] init IO_APIC IRQs
[    0.087183]  apic 2 pin 0 not connected
[    0.090014] IOAPIC[0]: Set routing entry (2-1 -> 0x31 -> IRQ 1 Mode:0 Active:0 Dest:1)
[    0.093155] IOAPIC[0]: Set routing entry (2-2 -> 0x30 -> IRQ 0 Mode:0 Active:0 Dest:1)
[    0.096294] IOAPIC[0]: Set routing entry (2-3 -> 0x33 -> IRQ 3 Mode:0 Active:0 Dest:1)
[    0.100024] IOAPIC[0]: Set routing entry (2-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:1)
[    0.103133] IOAPIC[0]: Set routing entry (2-5 -> 0x35 -> IRQ 5 Mode:1 Active:0 Dest:1)
[    0.106214] IOAPIC[0]: Set routing entry (2-6 -> 0x36 -> IRQ 6 Mode:0 Active:0 Dest:1)
[    0.109302] IOAPIC[0]: Set routing entry (2-7 -> 0x37 -> IRQ 7 Mode:0 Active:0 Dest:1)
[    0.110024] IOAPIC[0]: Set routing entry (2-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:1)
[    0.113098] IOAPIC[0]: Set routing entry (2-9 -> 0x39 -> IRQ 9 Mode:1 Active:0 Dest:1)
[    0.116168] IOAPIC[0]: Set routing entry (2-10 -> 0x3a -> IRQ 10 Mode:1 Active:0 Dest:1)
[    0.120024] IOAPIC[0]: Set routing entry (2-11 -> 0x3b -> IRQ 11 Mode:1 Active:0 Dest:1)
[    0.123194] IOAPIC[0]: Set routing entry (2-12 -> 0x3c -> IRQ 12 Mode:0 Active:0 Dest:1)
[    0.126324] IOAPIC[0]: Set routing entry (2-13 -> 0x3d -> IRQ 13 Mode:0 Active:0 Dest:1)
[    0.130024] IOAPIC[0]: Set routing entry (2-14 -> 0x3e -> IRQ 14 Mode:0 Active:0 Dest:1)
[    0.133175] IOAPIC[0]: Set routing entry (2-15 -> 0x3f -> IRQ 15 Mode:0 Active:0 Dest:1)
[    0.136359]  apic 2 pin 16 not connected
[    0.137987]  apic 2 pin 17 not connected
[    0.140003]  apic 2 pin 18 not connected
[    0.141622]  apic 2 pin 19 not connected
[    0.143243]  apic 2 pin 20 not connected
[    0.144888]  apic 2 pin 21 not connected
[    0.146528]  apic 2 pin 22 not connected
[    0.148149]  apic 2 pin 23 not connected
[    0.150184] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.152738] Using local APIC timer interrupts.
[    0.152738] calibrating APIC timer ...
[    0.160000] ... lapic delta = 6286603
[    0.160000] ... PM-Timer delta = 360042
[    0.160000] ... PM-Timer result ok
[    0.160000] ..... delta 6286603
[    0.160000] ..... mult: 270007542
[    0.160000] ..... calibration result: 10058564
[    0.160000] ..... CPU clock speed is 2709.1877 MHz.
[    0.160000] ..... host bus clock speed is 1005.8564 MHz.
[    0.160337] devtmpfs: initialized
[    0.164249] xor: measuring software checksum speed
[    0.270012]    prefetch64-sse:  9829.600 MB/sec
[    0.370008]    generic_sse:  9829.600 MB/sec
[    0.372478] xor: using function: generic_sse (9829.600 MB/sec)
[    0.375909] regulator-dummy: no parameters
[    0.378648] NET: Registered protocol family 16
[    0.380731] ACPI: bus type PCI registered
[    0.383390] PCI: Using configuration type 1 for base access
[    0.398033] bio: create slab <bio-0> at 0
[    0.570012] raid6: sse2x1    4835 MB/s
[    0.740008] raid6: sse2x2    6402 MB/s
[    0.910010] raid6: sse2x4    7248 MB/s
[    0.912501] raid6: using algorithm sse2x4 (7248 MB/s)
[    0.915609] raid6: using intx1 recovery algorithm
[    0.918768] ACPI: Added _OSI(Module Device)
[    0.920007] ACPI: Added _OSI(Processor Device)
[    0.922872] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.925797] ACPI: Added _OSI(Processor Aggregator Device)
[    0.931063] ACPI: EC: Look up EC in DSDT
[    0.940499] ACPI: Interpreter enabled
[    0.942941] ACPI: (supports S0 S5)
[    0.945297] ACPI: Using IOAPIC for interrupt routing
[    0.948369] PCI: Ignoring host bridge windows from ACPI; if necessary, use "pci=use_crs" and report a bug
[    0.965727] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.970060] acpi PNP0A03:00: host bridge window [io  0x0000-0x0cf7] (ignored)
[    0.980007] acpi PNP0A03:00: host bridge window [io  0x0d00-0xffff] (ignored)
[    0.990007] acpi PNP0A03:00: host bridge window [mem 0x000a0000-0x000bffff] (ignored)
[    1.000007] acpi PNP0A03:00: host bridge window [mem 0xe0000000-0xfebfffff] (ignored)
[    1.010020] PCI: root bus 00: using default resources
[    1.020090] PCI host bridge to bus 0000:00
[    1.030009] pci_bus 0000:00: root bus resource [bus 00-ff]
[    1.035995] pci_bus 0000:00: root bus resource [io  0x0000-0xffff]
[    1.040008] pci_bus 0000:00: root bus resource [mem 0x00000000-0xffffffffff]
[    1.050084] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    1.058388] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    1.062040] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    1.074541] pci 0000:00:01.1: reg 20: [io  0xc1e0-0xc1ef]
[    1.082584] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    1.091826] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX4 ACPI
[    1.100028] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX4 SMB
[    1.109508] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    1.113006] pci 0000:00:02.0: reg 10: [mem 0xfc000000-0xfdffffff pref]
[    1.121563] pci 0000:00:02.0: reg 14: [mem 0xfebe0000-0xfebe0fff]
[    1.132455] pci 0000:00:02.0: reg 30: [mem 0xfebc0000-0xfebcffff pref]
[    1.137264] pci 0000:00:03.0: [1af4:1000] type 00 class 0x020000
[    1.141012] pci 0000:00:03.0: reg 10: [io  0xc1c0-0xc1df]
[    1.145443] pci 0000:00:03.0: reg 14: [mem 0xfebe1000-0xfebe1fff]
[    1.154285] pci 0000:00:03.0: reg 30: [mem 0xfebd0000-0xfebdffff pref]
[    1.158827] pci 0000:00:04.0: [8086:100e] type 00 class 0x020000
[    1.160917] pci 0000:00:04.0: reg 10: [mem 0xfeb80000-0xfeb9ffff]
[    1.165506] pci 0000:00:04.0: reg 14: [io  0xc000-0xc03f]
[    1.174238] pci 0000:00:04.0: reg 30: [mem 0xfeba0000-0xfebbffff pref]
[    1.180156] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    1.184785] pci 0000:00:05.0: reg 10: [io  0xc040-0xc07f]
[    1.188995] pci 0000:00:05.0: reg 14: [mem 0xfebe2000-0xfebe2fff]
[    1.194973] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    1.200998] pci 0000:00:06.0: reg 10: [io  0xc080-0xc0bf]
[    1.205290] pci 0000:00:06.0: reg 14: [mem 0xfebe3000-0xfebe3fff]
[    1.214921] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    1.219166] pci 0000:00:07.0: reg 10: [io  0xc0c0-0xc0ff]
[    1.220874] pci 0000:00:07.0: reg 14: [mem 0xfebe4000-0xfebe4fff]
[    1.231851] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    1.236461] pci 0000:00:08.0: reg 10: [io  0xc100-0xc13f]
[    1.240457] pci 0000:00:08.0: reg 14: [mem 0xfebe5000-0xfebe5fff]
[    1.248990] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    1.250971] pci 0000:00:09.0: reg 10: [io  0xc140-0xc17f]
[    1.255083] pci 0000:00:09.0: reg 14: [mem 0xfebe6000-0xfebe6fff]
[    1.264811] pci 0000:00:0a.0: [1af4:1001] type 00 class 0x010000
[    1.270463] pci 0000:00:0a.0: reg 10: [io  0xc180-0xc1bf]
[    1.274581] pci 0000:00:0a.0: reg 14: [mem 0xfebe7000-0xfebe7fff]
[    1.283064] pci 0000:00:0b.0: [8086:25ab] type 00 class 0x088000
[    1.287139] pci 0000:00:0b.0: reg 10: [mem 0xfebe8000-0xfebe800f]
[    1.293464] pci_bus 0000:00: on NUMA node 0
[    1.296197] acpi PNP0A03:00: Unable to request _OSC control (_OSC support mask: 0x08)
[    1.301298] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    1.306147] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    1.312489] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    1.317407] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    1.322562] ACPI: PCI Interrupt Link [LNKS] (IRQs 9) *0
[    1.327915] ACPI: Enabled 16 GPEs in block 00 to 0F
[    1.330014] acpi root: \_SB_.PCI0 notify handler is installed
[    1.332399] Found 1 acpi root devices
[    1.334959] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    1.338347] vgaarb: loaded
[    1.340002] vgaarb: bridge control possible 0000:00:02.0
[    1.342737] SCSI subsystem initialized
[    1.344404] ACPI: bus type ATA registered
[    1.346127] libata version 3.00 loaded.
[    1.347827] ACPI: bus type USB registered
[    1.349572] usbcore: registered new interface driver usbfs
[    1.350029] usbcore: registered new interface driver hub
[    1.352292] usbcore: registered new device driver usb
[    1.354427] Linux video capture interface: v2.00
[    1.356357] pps_core: LinuxPPS API ver. 1 registered
[    1.360002] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    1.367869] PTP clock support registered
[    1.369658] EDAC MC: Ver: 3.0.0
[    1.370746] PCI: Using ACPI for IRQ routing
[    1.373208] PCI: pci_cache_line_size set to 64 bytes
[    1.375610] e820: reserve RAM buffer [mem 0x00093c00-0x0009ffff]
[    1.377866] e820: reserve RAM buffer [mem 0x0fffe000-0x0fffffff]
[    1.380266] irda_init()
[    1.381505] NET: Registered protocol family 23
[    1.383912] cfg80211: Calling CRDA to update world regulatory domain
[    1.388066] nfc: nfc_init: NFC Core ver 0.1
[    1.390061] NET: Registered protocol family 39
[    1.393300] Switching to clocksource kvm-clock
[    1.396014] pnp: PnP ACPI init
[    1.398188] ACPI: bus type PNP registered
[    1.398188] IOAPIC[0]: Set routing entry (2-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:1)
[    1.398188] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    1.400658] IOAPIC[0]: Set routing entry (2-1 -> 0x31 -> IRQ 1 Mode:0 Active:0 Dest:1)
[    1.403826] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    1.406303] IOAPIC[0]: Set routing entry (2-12 -> 0x3c -> IRQ 12 Mode:0 Active:0 Dest:1)
[    1.409514] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    1.411997] IOAPIC[0]: Set routing entry (2-6 -> 0x36 -> IRQ 6 Mode:0 Active:0 Dest:1)
[    1.415986] pnp 00:03: [dma 2]
[    1.418212] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    1.421907] IOAPIC[0]: Set routing entry (2-7 -> 0x37 -> IRQ 7 Mode:0 Active:0 Dest:1)
[    1.426410] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    1.430009] IOAPIC[0]: Set routing entry (2-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:1)
[    1.434526] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.438885] pnp 00:06: Plug and Play ACPI device, IDs PNP0103 (active)
[    1.442158] pnp: PnP ACPI: found 7 devices
[    1.444213] ACPI: bus type PNP unregistered
[    1.453952] pci_bus 0000:00: resource 4 [io  0x0000-0xffff]
[    1.456937] pci_bus 0000:00: resource 5 [mem 0x00000000-0xffffffffff]
[    1.460363] NET: Registered protocol family 2
[    1.463160] TCP established hash table entries: 2048 (order: 3, 32768 bytes)
[    1.466115] TCP bind hash table entries: 2048 (order: 2, 16384 bytes)
[    1.469494] TCP: Hash tables configured (established 2048 bind 2048)
[    1.472902] TCP: reno registered
[    1.474921] UDP hash table entries: 256 (order: 1, 8192 bytes)
[    1.478301] UDP-Lite hash table entries: 256 (order: 1, 8192 bytes)
[    1.481624] NET: Registered protocol family 1
[    1.483400] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.485599] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.487790] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.490107] pci 0000:00:02.0: Boot video device
[    1.491975] PCI: CLS 0 bytes, default 64
[    1.493871] Unpacking initramfs...
[    2.290827] Freeing initrd memory: 23656k freed
[    2.301424] kvm: no hardware support
[    2.304081] camellia-x86_64: performance on this CPU would be suboptimal: disabling camellia-x86_64.
[    2.308983] blowfish-x86_64: performance on this CPU would be suboptimal: disabling blowfish-x86_64.
[    2.313935] twofish-x86_64-3way: performance on this CPU would be suboptimal: disabling twofish-x86_64-3way.
[    2.319347] sha1_ssse3: Neither AVX nor SSSE3 is available/usable.
[    2.322552] PCLMULQDQ-NI instructions are not detected.
[    2.325363] sha512_ssse3: Neither AVX nor SSSE3 is available/usable.
[    2.328620] AVX or AES-NI instructions are not detected.
[    2.331454] AVX instructions are not detected.
[    2.333929] AVX instructions are not detected.
[    2.336377] AVX instructions are not detected.
[    2.338841] AVX instructions are not detected.
[    2.341300] AVX2 instructions are not detected.
[    2.343815] AVX2 or AES-NI instructions are not detected.
[    2.346644] AVX2 instructions are not detected.
[    2.349155] AVX2 instructions are not detected.
[    2.351954] audit: initializing netlink socket (disabled)
[    2.354869] type=2000 audit(1370951241.350:1): initialized
[    2.358303] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    2.368929] VFS: Disk quotas dquot_6.5.2
[    2.371319] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    2.375129] DLM installed
[    2.377844] squashfs: version 4.0 (2009/01/31) Phillip Lougher
[    2.381929] NTFS driver 2.1.30 [Flags: R/O].
[    2.384809] EFS: 1.0a - http://aeschi.ch.eu.org/efs/
[    2.388846] jffs2: version 2.2. 
[    2.392817] QNX4 filesystem 0.2.3 registered.
[    2.395554] fuse init (API version 7.22)
[    2.398434] JFS: nTxBlock = 1755, nTxLock = 14046
[    2.402129] SGI XFS with ACLs, security attributes, large block/inode numbers, no debug enabled
[    2.417131] OCFS2 1.5.0
[    2.420973] ocfs2: Registered cluster interface user
[    2.423784] OCFS2 DLMFS 1.5.0
[    2.425768] OCFS2 User DLM kernel interface loaded
[    2.428641] OCFS2 Node Manager 1.5.0
[    2.431451] bio: create slab <bio-1> at 1
[    2.434423] Running btrfs free space cache tests
[    2.437078] Running extent only tests
[    2.439333] Running bitmap only tests
[    2.441756] Running bitmap and extent tests
[    2.444231] Free space cache tests finished
[    2.446725] Btrfs loaded
[    2.449290] GFS2 installed
[    2.451123] msgmni has been set to 438
[    2.454913] NET: Registered protocol family 38
[    2.457635] Key type asymmetric registered
[    2.460214] Asymmetric key parser 'x509' registered
[    2.463209] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 250)
[    2.467779] io scheduler noop registered (default)
[    2.470683] io scheduler deadline registered
[    2.473428] io scheduler cfq registered
[    2.475862] test_string_helpers: Running tests...
[    2.479426] no IO addresses supplied
[    2.481895] usbcore: registered new interface driver udlfb
[    2.498146] usbcore: registered new interface driver smscufx
[    2.501471] ipmi message handler version 39.2
[    2.504165] ipmi device interface
[    2.506446] IPMI System Interface driver.
[    2.509071] ipmi_si: Adding default-specified kcs state machine
[    2.512711] ipmi_si: Trying default-specified kcs state machine at i/o address 0xca2, slave address 0x0, irq 0
[    2.518491] ipmi_si: Interface detection failed
[    2.521319] ipmi_si: Adding default-specified smic state machine
[    2.524972] ipmi_si: Trying default-specified smic state machine at i/o address 0xca9, slave address 0x0, irq 0
[    2.530769] ipmi_si: Interface detection failed
[    2.533537] ipmi_si: Adding default-specified bt state machine
[    2.537132] ipmi_si: Trying default-specified bt state machine at i/o address 0xe4, slave address 0x0, irq 0
[    2.542895] ipmi_si: Interface detection failed
[    2.545727] ipmi_si: Unable to find any System Interface(s)
[    2.549008] Copyright (C) 2004 MontaVista Software - IPMI Powerdown via sys_reboot.
[    2.553925] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[    2.558560] ACPI: Power Button [PWRF]
[    2.561994] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    2.596078] 00:05: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    2.602265] lp: driver loaded but no devices found
[    2.605332] ppdev: user-space parallel port driver
[    2.608311] telclk_interrupt = 0xf non-mcpbl0010 hw.
[    2.611398] SyncLink PC Card driver $Revision: 4.34 $, tty major#247
[    2.615114] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 seconds, margin is 60 seconds).
[    2.620512] Hangcheck: Using getrawmonotonic().
[    2.623517] [drm] Initialized drm 1.1.0 20060810
[    2.627913] parport_pc 00:04: reported by Plug and Play ACPI
[    2.631673] parport0: PC-style at 0x378, irq 7 [PCSPP,TRISTATE]
[    2.710322] lp0: using parport0 (interrupt-driven).
[    2.713235] dummy-irq: no IRQ given.  Use irq=N
[    2.715410] Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolfo Giometti
[    2.720154] c2port c2port0: C2 port uc added
[    2.722879] c2port c2port0: uc flash has 30 blocks x 512 bytes (15360 bytes total)
[    2.727853] usbcore: registered new interface driver pn533
[    2.731162] Uniform Multi-Platform E-IDE driver
[    2.734992] ide_generic: please use "probe_mask=0x3f" module parameter for probing all legacy ISA IDE ports
[    2.742014] ide-gd driver 1.18
[    2.744662] Loading iSCSI transport class v2.0-870.
[    2.747983] rdac: device handler registered
[    2.750622] hp_sw: device handler registered
[    2.753301] emc: device handler registered
[    2.755877] alua: device handler registered
[    2.758845] iscsi: registered transport (tcp)
[    2.761587] ppa: Version 2.07 (for Linux 2.4.x)
[    2.767528] imm: Version 2.05 (for Linux 2.4.0)
[    2.771592] osst :I: Tape driver with OnStream support version 0.99.4
[    2.771592] osst :I: $Id: osst.c,v 1.73 2005/01/01 21:13:34 wriede Exp $
[    2.779357] SCSI Media Changer driver v0.25 
[    2.782364] SSFDC read-only Flash Translation layer
[    2.785405] mtdoops: mtd device (mtddev=name/number) must be supplied
[    2.789126] L440GX flash mapping: failed to find PIIX4 ISA bridge, cannot continue
[    2.793881] platform physmap-flash.0: failed to claim resource 0
[    2.797392] Failed to ioremap_nocache
[    2.800209] ftl_cs: FTL header not found.
[    2.806418] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[    2.815500] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[    2.827618] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[    2.833266] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[    2.838869] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[    2.844457] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[    2.850044] NAND device: Manufacturer ID: 0x98, Chip ID: 0x39 (Toshiba NAND 128MiB 1,8V 8-bit), 128MiB, page size: 512, OOB size: 16
[    2.857067] flash size: 128 MiB
[    2.859194] page size: 512 bytes
[    2.861368] OOB area size: 16 bytes
[    2.863671] sector size: 16 KiB
[    2.865831] pages number: 262144
[    2.868000] pages per sector: 32
[    2.870192] bus width: 8
[    2.872057] bits in sector size: 14
[    2.874321] bits in page size: 9
[    2.876517] bits in OOB size: 4
[    2.878628] flash size with OOB: 135168 KiB
[    2.881459] page address bytes: 4
[    2.883704] sector address bytes: 3
[    2.902168] options: 0x42
[    2.906303] Scanning device for bad blocks
[    2.927368] Creating 1 MTD partitions on "NAND 128MiB 1,8V 8-bit":
[    2.930993] 0x000000000000-0x000008000000 : "NAND simulator partition 0"
[    2.935502] ftl_cs: FTL header not found.
[    2.938528] usbcore: registered new interface driver alauda
[    2.942165] ipddp.c:v0.01 8/28/97 Bradford W. Johnson <johns393@maroon.tc.umn.edu>
[    2.947454] ipddp0: Appletalk-IP Decap. mode by Jay Schulist <jschlst@samba.org>
[    2.952403] slcan: serial line CAN interface driver
[    2.955618] slcan: 10 dynamic interface channels.
[    2.958599] CAN device driver interface
[    2.961127] usbcore: registered new interface driver ems_usb
[    2.964466] usbcore: registered new interface driver kvaser_usb
[    2.967955] sja1000 CAN netdevice driver
[    2.970487] sja1000_isa: insufficient parameters supplied
[    2.973766] AX.25: 6pack driver, Revision: 0.3.0
[    2.976595] YAM driver version 0.8 by F1OAT/F6FBB
[    2.980023] baycom_par: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[    2.980023] baycom_par: version 0.9
[    2.986186] hdlcdrv: (C) 1996-2000 Thomas Sailer HB9JNX/AE4WA
[    2.989561] hdlcdrv: version 0.8
[    2.991770] usbcore: registered new interface driver stir4200
[    2.995485] w83977af_init()
[    2.998106] w83977af_open()
[    3.000642] w83977af_probe()
[    3.002877] w83977af_probe(), Wrong chip version
[    3.005112] w83977af_probe()
[    3.008074] w83977af_probe(), Wrong chip version
[    3.010671] usbcore: registered new interface driver mcs7780
[    3.014870] usbcore: registered new interface driver kingsun-sir
[    3.018394] usbcore: registered new interface driver ksdazzle-sir
[    3.022382] usbcore: registered new interface driver cdc_acm
[    3.025740] cdc_acm: USB Abstract Control Model driver for USB modems and ISDN adapters
[    3.030788] usbcore: registered new interface driver usblp
[    3.034108] usbcore: registered new interface driver mdc800
[    3.037442] mdc800: v0.7.5 (30/10/2000):USB Driver for Mustek MDC800 Digital Camera
[    3.042349] usbcore: registered new interface driver usbserial
[    3.045874] usbcore: registered new interface driver aircable
[    3.049347] usbserial: USB Serial support registered for aircable
[    3.052973] usbcore: registered new interface driver belkin_sa
[    3.056454] usbserial: USB Serial support registered for Belkin / Peracom / GoHubs USB Serial Adapter
[    3.062291] usbcore: registered new interface driver ch341
[    3.065622] usbserial: USB Serial support registered for ch341-uart
[    3.069335] usbcore: registered new interface driver cp210x
[    3.072662] usbserial: USB Serial support registered for cp210x
[    3.076899] usbcore: registered new interface driver cyberjack
[    3.080425] usbserial: USB Serial support registered for Reiner SCT Cyberjack USB card reader
[    3.085719] usbcore: registered new interface driver cypress_m8
[    3.089264] usbserial: USB Serial support registered for DeLorme Earthmate USB
[    3.093896] usbserial: USB Serial support registered for HID->COM RS232 Adapter
[    3.098571] usbserial: USB Serial support registered for Nokia CA-42 V2 Adapter
[    3.103276] usbcore: registered new interface driver digi_acceleport
[    3.107018] usbserial: USB Serial support registered for Digi 2 port USB adapter
[    3.111693] usbserial: USB Serial support registered for Digi 4 port USB adapter
[    3.116489] usbcore: registered new interface driver empeg
[    3.119838] usbserial: USB Serial support registered for empeg
[    3.123392] usbcore: registered new interface driver f81232
[    3.126784] usbserial: USB Serial support registered for f81232
[    3.135779] usbcore: registered new interface driver ftdi_sio
[    3.139174] usbserial: USB Serial support registered for FTDI USB Serial Device
[    3.147197] usbcore: registered new interface driver garmin_gps
[    3.153966] usbserial: USB Serial support registered for Garmin GPS usb/tty
[    3.161281] usbcore: registered new interface driver hp4x
[    3.167806] usbserial: USB Serial support registered for hp4X
[    3.174297] usbcore: registered new interface driver ipaq
[    3.179705] usbserial: USB Serial support registered for PocketPC PDA
[    3.184765] usbcore: registered new interface driver ir_usb
[    3.187805] usbserial: USB Serial support registered for IR Dongle
[    3.191103] usbcore: registered new interface driver kl5kusb105
[    3.194309] usbserial: USB Serial support registered for KL5KUSB105D / PalmConnect
[    3.198861] usbcore: registered new interface driver kobil_sct
[    3.202339] usbserial: USB Serial support registered for KOBIL USB smart card terminal
[    3.207265] usbcore: registered new interface driver metro_usb
[    3.210580] usbserial: USB Serial support registered for Metrologic USB to Serial
[    3.214867] usbcore: registered new interface driver mos7720
[    3.217921] usbserial: USB Serial support registered for Moschip 2 port adapter
[    3.222160] usbcore: registered new interface driver moto_modem
[    3.225577] usbserial: USB Serial support registered for moto-modem
[    3.229182] usbcore: registered new interface driver navman
[    3.232515] usbserial: USB Serial support registered for navman
[    3.235978] usbcore: registered new interface driver opticon
[    3.239027] usbserial: USB Serial support registered for opticon
[    3.242236] usbcore: registered new interface driver qcserial
[    3.245293] usbserial: USB Serial support registered for Qualcomm USB modem
[    3.248948] usbcore: registered new interface driver quatech2
[    3.252423] usbserial: USB Serial support registered for Quatech 2nd gen USB to Serial Driver
[    3.257619] usbcore: registered new interface driver safe_serial
[    3.261170] usbserial: USB Serial support registered for safe_serial
[    3.267611] usbcore: registered new interface driver siemens_mpi
[    3.274494] usbserial: USB Serial support registered for siemens_mpi
[    3.280891] usbcore: registered new interface driver spcp8x5
[    3.287834] usbserial: USB Serial support registered for SPCP8x5
[    3.294727] usbcore: registered new interface driver symbolserial
[    3.301249] usbserial: USB Serial support registered for symbol
[    3.307968] usbcore: registered new interface driver ti_usb_3410_5052
[    3.314727] usbserial: USB Serial support registered for TI USB 3410 1 port adapter
[    3.323138] usbserial: USB Serial support registered for TI USB 5052 2 port adapter
[    3.332076] usbcore: registered new interface driver visor
[    3.339087] usbserial: USB Serial support registered for Handspring Visor / Palm OS
[    3.347403] usbserial: USB Serial support registered for Sony Clie 5.0
[    3.354844] usbserial: USB Serial support registered for Sony Clie 3.5
[    3.361509] usbcore: registered new interface driver wishbone_serial
[    3.368119] usbserial: USB Serial support registered for wishbone_serial
[    3.375306] usbcore: registered new interface driver zte_ev
[    3.378364] usbserial: USB Serial support registered for zte_ev
[    3.384413] tsc: Refined TSC clocksource calibration: 2693.508 MHz
[    3.391197] usbcore: registered new interface driver appledisplay
[    3.397609] usbcore: registered new interface driver cypress_cy7c63
[    3.403926] usbcore: registered new interface driver emi62 - firmware loader
[    3.409465] driver ftdi-elan
[    3.413302] usbcore: registered new interface driver ftdi-elan
[    3.420313] usbcore: registered new interface driver idmouse
[    3.426663] usbcore: registered new interface driver isight_firmware
[    3.433197] usbcore: registered new interface driver usblcd
[    3.439223] usbcore: registered new interface driver legousbtower
[    3.445630] usbcore: registered new interface driver usbtest
[    3.448659] usbcore: registered new interface driver uss720
[    3.454246] uss720: v0.6:USB Parport Cable driver for Cables using the Lucent Technologies USS720 Chip
[    3.465948] uss720: NOTE: this is a special purpose driver to allow nonstandard
[    3.473447] uss720: protocols (eg. bitbang) over USS720 usb to parallel cables
[    3.480518] uss720: If you just want to connect to a printer, use usblp instead
[    3.488061] usbcore: registered new interface driver usbsevseg
[    3.494033] usbcore: registered new interface driver sisusb
[    3.500701] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
[    3.507899] serio: i8042 KBD port at 0x60,0x64 irq 1
[    3.510596] serio: i8042 AUX port at 0x60,0x64 irq 12
[    3.513622] mousedev: PS/2 mouse device common for all mice
[    3.530125] mk712: device not present
[    3.532607] apanel: Fujitsu BIOS signature 'FJKEYINF' not found...
[    3.535842] usbcore: registered new interface driver ati_remote2
[    3.538999] usbcore: registered new interface driver ims_pcu
[    3.560287] usbcore: registered new interface driver powermate
[    3.574218] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input1
[    3.579924] rtc-test rtc-test.0: rtc core: registered test as rtc0
[    3.594684] rtc-test rtc-test.1: rtc core: registered test as rtc1
[    3.597947] i2c /dev entries driver
[    3.600162] usbcore: registered new interface driver i2c-diolan-u2c
[    3.611060] i2c-parport: adapter type unspecified
[    3.617863] usbcore: registered new interface driver i2c-tiny-usb
[    3.624785] pps_parport: parallel port PPS client
[    3.630913] parport0: cannot grant exclusive access for device pps_parport
[    3.636076] pps_parport: couldn't register with parport0
[    3.643494] applesmc: supported laptop not found!
[    3.647875] applesmc: driver init failed (ret=-19)!
[    3.656531] pc87360: PC8736x not detected, module not inserted
[    3.663926] intel_powerclamp: Intel powerclamp does not run on family 15 model 6
[    3.673688] acquirewdt: WDT driver for Acquire single board computer initialising
[    3.683674] acquirewdt: I/O address 0x0043 already in use
[    3.689909] acquirewdt: probe of acquirewdt failed with error -5
[    3.695688] advantechwdt: WDT driver for Advantech single board computer initialising
[    3.704799] advantechwdt: initialized. timeout=60 sec (nowayout=0)
[    3.711925] sc520_wdt: cannot register miscdev on minor=130 (err=-16)
[    3.718957] ib700wdt: WDT driver for IB700 single board computer initialising
[    3.726360] ib700wdt: START method I/O 443 is not available
[    3.732227] ib700wdt: probe of ib700wdt failed with error -5
[    3.738425] it87_wdt: no device
[    3.743058] pc87413_wdt: Version 1.1 at io 0x2E
[    3.748021] pc87413_wdt: cannot register miscdev on minor=130 (err=-16)
[    3.754194] sbc60xxwdt: I/O address 0x0443 already in use
[    3.759318] w83697ug_wdt: WDT driver for the Winbond(TM) W83697UG/UF Super I/O chip initialising
[    3.768026] w83697ug_wdt: No W83697UG/UF could be found
[    3.773297] w83877f_wdt: I/O address 0x0443 already in use
[    3.778654] w83977f_wdt: driver v1.00
[    3.783027] w83977f_wdt: cannot register miscdev on minor=130 (err=-16)
[    3.789070] machzwd: MachZ ZF-Logic Watchdog driver initializing
[    3.793231] machzwd: no ZF-Logic found
[    3.795290] md: raid0 personality registered for level 0
[    3.805847] md: raid1 personality registered for level 1
[    3.808391] md: raid10 personality registered for level 10
[    3.813227] md: raid6 personality registered for level 6
[    3.819165] md: raid5 personality registered for level 5
[    3.824788] md: raid4 personality registered for level 4
[    3.827615] md: multipath personality registered for level -4
[    3.830720] md: faulty personality registered for level -5
[    3.834013] cpuidle: using governor ladder
[    3.836477] sdhci: Secure Digital Host Controller Interface driver
[    3.839807] sdhci: Copyright(c) Pierre Ossman
[    3.842356] wbsd: Winbond W83L51xD SD/MMC card interface driver
[    3.845615] wbsd: Copyright(c) Pierre Ossman
[    3.848076] sdhci-pltfm: SDHCI platform and OF driver helper
[    3.851726] No iBFT detected.
[    3.854654] usbcore: registered new interface driver usbhid
[    3.857668] usbhid: USB HID core driver
[    3.860041] usbip_core: usbip_core_init:804: USB/IP Core v1.0.0
[    3.863307] vhci_hcd: vhci_hcd_probe:1000: name vhci_hcd id -1
[    3.866436] vhci_hcd vhci_hcd: USB/IP Virtual Host Controller
[    3.869682] vhci_hcd vhci_hcd: new USB bus registered, assigned bus number 1
[    3.873435] vhci_hcd: vhci_start:884: enter vhci_start
[    3.876530] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    3.880102] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    3.884270] usb usb1: Product: USB/IP Virtual Host Controller
[    3.887419] usb usb1: Manufacturer: Linux 3.10.0-rc5-00652-ge8a36a6 vhci_hcd
[    3.896115] usb usb1: SerialNumber: vhci_hcd
[    3.898489] hub 1-0:1.0: USB hub found
[    3.906072] vhci_hcd: vhci_hub_control:247: typeReq a006 wValue 2900 wIndex 0
[    3.911481] vhci_hcd: vhci_hub_control:305:  GetHubDescriptor
[    3.914270] vhci_hcd: vhci_hub_control:398: port -1
[    3.916722] vhci_hcd: vhci_hub_control:405:  bye
[    3.919069] hub 1-0:1.0: 8 ports detected
[    3.921239] vhci_hcd: vhci_hub_control:247: typeReq a000 wValue 0 wIndex 0
[    3.924425] vhci_hcd: vhci_hub_control:309:  GetHubStatus
[    3.927051] vhci_hcd: vhci_hub_control:398: port -1
[    3.929476] vhci_hcd: vhci_hub_control:405:  bye
[    3.931950] vhci_hcd: vhci_hub_control:247: typeReq 2303 wValue 8 wIndex 1
[    3.935145] vhci_hcd: vhci_hub_control:384:  SetPortFeature: default 8
[    3.938180] vhci_hcd: vhci_hub_control:398: port 0
[    3.940585] vhci_hcd: dump_port_status_diff:101: status prev -> new: 00000000 -> 00000100
[    3.944721] vhci_hcd: dump_port_status_diff:115:  +POWER
[    3.947342] vhci_hcd: dump_port_status_diff:119: 
[    3.949723] vhci_hcd: vhci_hub_control:405:  bye
[    3.952163] vhci_hcd: vhci_hub_control:247: typeReq 2303 wValue 8 wIndex 2
[    3.955294] vhci_hcd: vhci_hub_control:384:  SetPortFeature: default 8
[    3.958328] vhci_hcd: vhci_hub_control:398: port 1
[    3.960745] vhci_hcd: dump_port_status_diff:101: status prev -> new: 00000000 -> 00000100
[    3.964906] vhci_hcd: dump_port_status_diff:115:  +POWER
[    3.968372] vhci_hcd: dump_port_status_diff:119: 
[    3.970777] vhci_hcd: vhci_hub_control:405:  bye
[    3.973175] vhci_hcd: vhci_hub_control:247: typeReq 2303 wValue 8 wIndex 3
[    3.976327] vhci_hcd: vhci_hub_control:384:  SetPortFeature: default 8
[    3.979374] vhci_hcd: vhci_hub_control:398: port 2
[    3.981826] vhci_hcd: dump_port_status_diff:101: status prev -> new: 00000000 -> 00000100
[    3.989298] vhci_hcd: dump_port_status_diff:115:  +POWER
[    3.993137] vhci_hcd: dump_port_status_diff:119: 
[    3.998830] vhci_hcd: vhci_hub_control:405:  bye
[    4.005746] vhci_hcd: vhci_hub_control:247: typeReq 2303 wValue 8 wIndex 4
[    4.011067] vhci_hcd: vhci_hub_control:384:  SetPortFeature: default 8
[    4.014119] vhci_hcd: vhci_hub_control:398: port 3
[    4.019858] vhci_hcd: dump_port_status_diff:101: status prev -> new: 00000000 -> 00000100
[    4.028052] vhci_hcd: dump_port_status_diff:115:  +POWER
[    4.032752] vhci_hcd: dump_port_status_diff:119: 
[    4.035183] vhci_hcd: vhci_hub_control:405:  bye
[    4.045599] vhci_hcd: vhci_hub_control:247: typeReq 2303 wValue 8 wIndex 5
[    4.049434] vhci_hcd: vhci_hub_control:384:  SetPortFeature: default 8
[    4.053245] vhci_hcd: vhci_hub_control:398: port 4
[    4.056177] vhci_hcd: dump_port_status_diff:101: status prev -> new: 00000000 -> 00000100
[    4.061082] vhci_hcd: dump_port_status_diff:115:  +POWER
[    4.063972] vhci_hcd: dump_port_status_diff:119: 
[    4.066612] vhci_hcd: vhci_hub_control:405:  bye
[    4.069215] vhci_hcd: vhci_hub_control:247: typeReq 2303 wValue 8 wIndex 6
[    4.072837] vhci_hcd: vhci_hub_control:384:  SetPortFeature: default 8
[    4.076645] vhci_hcd: vhci_hub_control:398: port 5
[    4.079483] vhci_hcd: dump_port_status_diff:101: status prev -> new: 00000000 -> 00000100
[    4.084496] vhci_hcd: dump_port_status_diff:115:  +POWER
[    4.087531] vhci_hcd: dump_port_status_diff:119: 
[    4.090198] vhci_hcd: vhci_hub_control:405:  bye
[    4.092840] vhci_hcd: vhci_hub_control:247: typeReq 2303 wValue 8 wIndex 7
[    4.096375] vhci_hcd: vhci_hub_control:384:  SetPortFeature: default 8
[    4.099765] vhci_hcd: vhci_hub_control:398: port 6
[    4.102500] vhci_hcd: dump_port_status_diff:101: status prev -> new: 00000000 -> 00000100
[    4.107069] vhci_hcd: dump_port_status_diff:115:  +POWER
[    4.110236] vhci_hcd: dump_port_status_diff:119: 
[    4.113175] vhci_hcd: vhci_hub_control:405:  bye
[    4.116015] vhci_hcd: vhci_hub_control:247: typeReq 2303 wValue 8 wIndex 8
[    4.119844] vhci_hcd: vhci_hub_control:384:  SetPortFeature: default 8
[    4.126146] vhci_hcd: vhci_hub_control:398: port 7
[    4.128829] vhci_hcd: dump_port_status_diff:101: status prev -> new: 00000000 -> 00000100
[    4.137979] vhci_hcd: dump_port_status_diff:115:  +POWER
[    4.142297] vhci_hcd: dump_port_status_diff:119: 
[    4.147209] vhci_hcd: vhci_hub_control:405:  bye
[    4.152575] vhci_hcd: vhci_hcd_probe:1034: bye
[    4.157117] vhci_hcd: vhci_hcd_init:1156: USB/IP 'Virtual' Host Controller (VHCI) Driver v1.0.0
[    4.250114] vhci_hcd: vhci_hub_control:247: typeReq a300 wValue 0 wIndex 1
[    4.252638] vhci_hcd: vhci_hub_control:313:  GetPortStatus port 1
[    4.254909] vhci_hcd: vhci_hub_control:355:  GetPortStatus bye 100 0
[    4.257649] vhci_hcd: vhci_hub_control:398: port 0
[    4.260306] vhci_hcd: dump_port_status_diff:101: status prev -> new: 00000100 -> 00000100
[    4.272706] vhci_hcd: dump_port_status_diff:115:   POWER
[    4.275587] vhci_hcd: dump_port_status_diff:119: 
[    4.278185] vhci_hcd: vhci_hub_control:405:  bye
[    4.281604] vhci_hcd: vhci_hub_control:247: typeReq a300 wValue 0 wIndex 2
[    4.293546] vhci_hcd: vhci_hub_control:313:  GetPortStatus port 2
[    4.296741] vhci_hcd: vhci_hub_control:355:  GetPortStatus bye 100 0
[    4.300074] vhci_hcd: vhci_hub_control:398: port 1
[    4.312808] vhci_hcd: dump_port_status_diff:101: status prev -> new: 00000100 -> 00000100
[    4.317309] vhci_hcd: dump_port_status_diff:115:   POWER
[    4.320186] vhci_hcd: dump_port_status_diff:119: 
[    4.334957] vhci_hcd: vhci_hub_control:405:  bye
[    4.337539] vhci_hcd: vhci_hub_control:247: typeReq a300 wValue 0 wIndex 3
[    4.341313] vhci_hcd: vhci_hub_control:313:  GetPortStatus port 3
[    4.344692] vhci_hcd: vhci_hub_control:355:  GetPortStatus bye 100 0
[    4.348002] vhci_hcd: vhci_hub_control:398: port 2
[    4.350660] vhci_hcd: dump_port_status_diff:101: status prev -> new: 00000100 -> 00000100
[    4.355244] vhci_hcd: dump_port_status_diff:115:   POWER
[    4.358098] vhci_hcd: dump_port_status_diff:119: 
[    4.360713] vhci_hcd: vhci_hub_control:405:  bye
[    4.363340] vhci_hcd: vhci_hub_control:247: typeReq a300 wValue 0 wIndex 4
[    4.366838] vhci_hcd: vhci_hub_control:313:  GetPortStatus port 4
[    4.370009] vhci_hcd: vhci_hub_control:355:  GetPortStatus bye 100 0
[    4.373385] vhci_hcd: vhci_hub_control:398: port 3
[    4.376041] vhci_hcd: dump_port_status_diff:101: status prev -> new: 00000100 -> 00000100
[    4.380587] vhci_hcd: dump_port_status_diff:115:   POWER
[    4.383494] vhci_hcd: dump_port_status_diff:119: 
[    4.392150] vhci_hcd: vhci_hub_control:405:  bye
[    4.394719] vhci_hcd: vhci_hub_control:247: typeReq a300 wValue 0 wIndex 5
[    4.398231] vhci_hcd: vhci_hub_control:313:  GetPortStatus port 5
[    4.401497] vhci_hcd: vhci_hub_control:355:  GetPortStatus bye 100 0
[    4.404844] vhci_hcd: vhci_hub_control:398: port 4
[    4.407479] vhci_hcd: dump_port_status_diff:101: status prev -> new: 00000100 -> 00000100
[    4.412101] vhci_hcd: dump_port_status_diff:115:   POWER
[    4.414962] vhci_hcd: dump_port_status_diff:119: 
[    4.417607] vhci_hcd: vhci_hub_control:405:  bye
[    4.420193] vhci_hcd: vhci_hub_control:247: typeReq a300 wValue 0 wIndex 6
[    4.423793] vhci_hcd: vhci_hub_control:313:  GetPortStatus port 6
[    4.426967] vhci_hcd: vhci_hub_control:355:  GetPortStatus bye 100 0
[    4.430265] vhci_hcd: vhci_hub_control:398: port 5
[    4.432950] vhci_hcd: dump_port_status_diff:101: status prev -> new: 00000100 -> 00000100
[    4.437442] vhci_hcd: dump_port_status_diff:115:   POWER
[    4.440304] vhci_hcd: dump_port_status_diff:119: 
[    4.442967] vhci_hcd: vhci_hub_control:405:  bye
[    4.445548] vhci_hcd: vhci_hub_control:247: typeReq a300 wValue 0 wIndex 7
[    4.449056] vhci_hcd: vhci_hub_control:313:  GetPortStatus port 7
[    4.452291] vhci_hcd: vhci_hub_control:355:  GetPortStatus bye 100 0
[    4.455808] vhci_hcd: vhci_hub_control:398: port 6
[    4.458433] vhci_hcd: dump_port_status_diff:101: status prev -> new: 00000100 -> 00000100
[    4.463004] vhci_hcd: dump_port_status_diff:115:   POWER
[    4.465877] vhci_hcd: dump_port_status_diff:119: 
[    4.468454] vhci_hcd: vhci_hub_control:405:  bye
[    4.471073] vhci_hcd: vhci_hub_control:247: typeReq a300 wValue 0 wIndex 8
[    4.474597] vhci_hcd: vhci_hub_control:313:  GetPortStatus port 8
[    4.477769] vhci_hcd: vhci_hub_control:355:  GetPortStatus bye 100 0
[    4.481079] vhci_hcd: vhci_hub_control:398: port 7
[    4.483695] vhci_hcd: dump_port_status_diff:101: status prev -> new: 00000100 -> 00000100
[    4.488185] vhci_hcd: dump_port_status_diff:115:   POWER
[    4.491074] vhci_hcd: dump_port_status_diff:119: 
[    4.493652] vhci_hcd: vhci_hub_control:405:  bye
[    4.497034] panel: driver version 0.9.5 registered on parport0 (io=0x378).
[    4.500585] usbcore: registered new interface driver rts5139
[    4.503638] usbcore: registered new interface driver serqt_usb2
[    4.506757] usbserial: USB Serial support registered for Quatech USB to Serial Driver
[    4.511840] beceem: Beceem Communications Inc. WiMAX driver, 5.2.45
[    4.515099] Copyright 2010. Beceem Communications Inc
[    4.517878] usbcore: registered new interface driver usbbcm
[    4.521032] input: Speakup as /devices/virtual/input/input2
[    4.524144] initialized device: /dev/synth, node (MAJOR 10, MINOR 25)
[    4.527514] speakup 3.1.6: initialized
[    4.529728] synth name on entry is: (null)
[    4.532391] usbcore: registered new interface driver gdm_wimax
[    4.535499] usbcore: registered new interface driver cedusb
[    4.539368] pktgen: Packet Generator for packet performance testing. Version: 2.74
[    4.543836] GACT probability NOT on
[    4.545944] Failed to load ipt action
[    4.548287] netem: version 1.3
[    4.550309] u32 classifier
[    4.552163]     Performance counters on
[    4.554410]     Actions configured
[    4.556518] IPVS: Registered protocols (ESP)
[    4.559068] IPVS: Connection hash table configured (size=4096, memory=64Kbytes)
[    4.564209] IPVS: Each connection entry needs 288 bytes at least
[    4.567902] IPVS: Creating netns size=1128 id=0
[    4.571004] IPVS: ipvs loaded.
[    4.573154] IPVS: [wrr] scheduler registered.
[    4.575854] IPVS: [lc] scheduler registered.
[    4.578510] IPVS: [wlc] scheduler registered.
[    4.581264] IPVS: [lblcr] scheduler registered.
[    4.584042] IPVS: [dh] scheduler registered.
[    4.586686] IPVS: [sh] scheduler registered.
[    4.589337] IPVS: [sed] scheduler registered.
[    4.592209] gre: GRE over IPv4 demultiplexor driver
[    4.595195] ip_tables: (C) 2000-2006 Netfilter Core Team
[    4.598427] TCP: bic registered
[    4.600616] TCP: cubic registered
[    4.602935] TCP: highspeed registered
[    4.605433] TCP: hybla registered
[    4.607791] TCP: htcp registered
[    4.610193] TCP: vegas registered
[    4.612607] TCP: veno registered
[    4.614931] TCP: yeah registered
[    4.617213] TCP: illinois registered
[    4.620138] NET: Registered protocol family 10
[    4.624129] mip6: Mobile IPv6
[    4.626299] sit: IPv6 over IPv4 tunneling driver
[    4.629231] ip6_gre: GRE over IPv6 tunneling driver
[    4.632215] NET: Registered protocol family 15
[    4.634899] NET: Registered protocol family 4
[    4.637365] NET: Registered protocol family 5
[    4.641098] NET: Registered protocol family 11
[    4.643606] NET: Registered protocol family 3
[    4.646062] can: controller area network core (rev 20120528 abi 9)
[    4.649337] NET: Registered protocol family 29
[    4.651948] can: raw protocol (rev 20120528)
[    4.654329] can: netlink gateway (rev 20130117) max_hops=1
[    4.657565] IrCOMM protocol (Dag Brattli)
[    4.661041] NET: Registered protocol family 33
[    4.674660] Key type rxrpc registered
[    4.676811] Key type rxrpc_s registered
[    4.679190] RxRPC: Registered security type 2 'rxkad'
[    4.682014] l2tp_core: L2TP core driver, V2.0
[    4.684439] l2tp_ip: L2TP IP encapsulation support (L2TPv3)
[    4.687440] l2tp_netlink: L2TP netlink interface
[    4.689996] l2tp_eth: L2TP ethernet pseudowire support (L2TPv3)
[    4.693348] l2tp_debugfs: L2TP debugfs support
[    4.695801] l2tp_ip6: L2TP IP encapsulation support for IPv6 (L2TPv3)
[    4.699184] NET: Registered protocol family 35
[    4.701856] 8021q: 802.1Q VLAN Support v1.8
[    4.704549] DCCP: Activated CCID 2 (TCP-like)
[    4.707463] sctp: Hash tables configured (established 8192 bind 8192)
[    4.711091] sctp: sctp_init_sock(sk: ffff88000f2c4000)
[    4.714326] NET: Registered protocol family 21
[    4.716928] Registered RDS/tcp transport
[    4.719222] tipc: Activated (version 2.0.0)
[    4.721869] NET: Registered protocol family 30
[    4.724352] tipc: Started in single node mode
[    4.726796] 9pnet: Installing 9P2000 support
[    4.729233] NET: Registered protocol family 37
[    4.731968] NET: Registered protocol family 36
[    4.734475] Key type dns_resolver registered
[    4.736998] batman_adv: B.A.T.M.A.N. advanced 2013.3.0 (compatibility version 14) loaded
[    4.741484] openvswitch: Open vSwitch switching datapath
[    4.744823] 
[    4.744823] printing PIC contents
[    4.747905] ... PIC  IMR: ffff
[    4.749797] ... PIC  IRR: 1013
[    4.751830] ... PIC  ISR: 0000
[    4.753705] ... PIC ELCR: 0c00
[    4.755583] printing local APIC contents on CPU#0/0:
[    4.758263] ... APIC ID:      00000000 (0)
[    4.760568] ... APIC VERSION: 00050014
[    4.761737] ... APIC TASKPRI: 00000000 (00)
[    4.761737] ... APIC PROCPRI: 00000000
[    4.761737] ... APIC LDR: 01000000
[    4.761737] ... APIC DFR: ffffffff
[    4.761737] ... APIC SPIV: 000001ff
[    4.761737] ... APIC ISR field:
[    4.761737] 0000000000000000000000000000000000000000000000000000000000000000
[    4.761737] ... APIC TMR field:
[    4.761737] 0000000000000000000000000000000000000000000000000000000000000000
[    4.761737] ... APIC IRR field:
[    4.761737] 0000000000000000000000000000000000000000000000000000000000008000
[    4.761737] ... APIC ESR: 00000000
[    4.761737] ... APIC ICR: 00000831
[    4.761737] ... APIC ICR2: 01000000
[    4.761737] ... APIC LVTT: 000000ef
[    4.761737] ... APIC LVTPC: 00010000
[    4.761737] ... APIC LVT0: 00010700
[    4.761737] ... APIC LVT1: 00000400
[    4.761737] ... APIC LVTERR: 000000fe
[    4.761737] ... APIC TMICT: 0007ec92
[    4.761737] ... APIC TMCCT: 00000000
[    4.761737] ... APIC TDCR: 00000003
[    4.761737] 
[    4.819064] number of MP IRQ sources: 15.
[    4.821423] number of IO-APIC #2 registers: 24.
[    4.823934] testing the IO APIC.......................
[    4.826728] IO APIC #2......
[    4.828586] .... register #00: 00000000
[    4.830969] .......    : physical APIC id: 00
[    4.833383] .......    : Delivery Type: 0
[    4.835659] .......    : LTS          : 0
[    4.837945] .... register #01: 00170011
[    4.840173] .......     : max redirection entries: 17
[    4.842959] .......     : PRQ implemented: 0
[    4.845350] .......     : IO APIC version: 11
[    4.847769] .... register #02: 00000000
[    4.849980] .......     : arbitration: 00
[    4.852406] .... IRQ redirection table:
[    4.854638] 1    0    0   0   0    0    0    00
[    4.857140] 0    0    0   0   0    1    1    31
[    4.859641] 0    0    0   0   0    1    1    30
[    4.862260] 0    0    0   0   0    1    1    33
[    4.864739] 1    0    0   0   0    1    1    34
[    4.867237] 1    1    0   0   0    1    1    35
[    4.869721] 0    0    0   0   0    1    1    36
[    4.872376] 0    0    0   0   0    1    1    37
[    4.874883] 0    0    0   0   0    1    1    38
[    4.883356] 0    1    0   0   0    1    1    39
[    4.885879] 1    1    0   0   0    1    1    3A
[    4.888378] 1    1    0   0   0    1    1    3B
[    4.891017] 0    0    0   0   0    1    1    3C
[    4.893504] 0    0    0   0   0    1    1    3D
[    4.896006] 0    0    0   0   0    1    1    3E
[    4.898501] 0    0    0   0   0    1    1    3F
[    4.901054] 1    0    0   0   0    0    0    00
[    4.903549] 1    0    0   0   0    0    0    00
[    4.906052] 1    0    0   0   0    0    0    00
[    4.908558] 1    0    0   0   0    0    0    00
[    4.911194] 1    0    0   0   0    0    0    00
[    4.913694] 1    0    0   0   0    0    0    00
[    4.916215] 1    0    0   0   0    0    0    00
[    4.918707] 1    0    0   0   0    0    0    00
[    4.921263] IRQ to pin mappings:
[    4.923214] IRQ0 -> 0:2
[    4.925225] IRQ1 -> 0:1
[    4.927243] IRQ3 -> 0:3
[    4.929247] IRQ4 -> 0:4
[    4.931381] IRQ5 -> 0:5
[    4.933375] IRQ6 -> 0:6
[    4.935387] IRQ7 -> 0:7
[    4.937413] IRQ8 -> 0:8
[    4.939416] IRQ9 -> 0:9
[    4.941495] IRQ10 -> 0:10
[    4.943559] IRQ11 -> 0:11
[    4.945624] IRQ12 -> 0:12
[    4.947693] IRQ13 -> 0:13
[    4.949796] IRQ14 -> 0:14
[    4.952012] IRQ15 -> 0:15
[    4.954090] .................................... done.
[    4.957015] registered taskstats version 1
[    4.959445] Key type encrypted registered
[    4.962866] rtc-test rtc-test.0: setting system clock to 2013-06-11 11:47:23 UTC (1370951243)
[    4.968191] Freeing unused kernel memory: 1000k freed
[    4.971650] Write protecting the kernel read-only data: 20480k
[    4.976778] Freeing unused kernel memory: 724k freed
[    4.985021] Freeing unused kernel memory: 2032k freed
[    5.063934] init: Failed to create pty - disabling logging for job
[    5.067202] init: Temporary process spawn error: No such file or directory
[    5.089106] init: Failed to create pty - disabling logging for job
[    5.092607] init: Temporary process spawn error: No such file or directory
[    5.121363] init: Failed to create pty - disabling logging for job
[    5.156209] init: Temporary process spawn error: No such file or directory
[    5.183542] init: Failed to create pty - disabling logging for job
[    5.210201] init: Temporary process spawn error: No such file or directory
[    5.296280] init: Failed to create pty - disabling logging for job
[    5.302233] init: Temporary process spawn error: No such file or directory
[    5.335525] init: Failed to create pty - disabling logging for job
[    5.339412] init: Temporary process spawn error: No such file or directory
[    5.365196] init: Failed to create pty - disabling logging for job
[    5.369020] init: Temporary process spawn error: No such file or directory
[    5.383745] udevd[197]: starting version 175
[    5.391983] init: Failed to create pty - disabling logging for job
[    5.392026] init: Temporary process spawn error: No such file or directory
[    5.394781] init: Failed to create pty - disabling logging for job
[    5.394819] init: Temporary process spawn error: No such file or directory
[    5.398215] init: Failed to create pty - disabling logging for job
[    5.398259] init: Temporary process spawn error: No such file or directory
[    5.451245] init: Failed to create pty - disabling logging for job
[    5.451286] init: Temporary process spawn error: No such file or directory
[    5.452844] init: Failed to create pty - disabling logging for job
[    5.452885] init: Temporary process spawn error: No such file or directory
[    5.462669] init: plymouth-log main process (204) terminated with status 1
[    5.532549] init: Failed to create pty - disabling logging for job
[    5.536370] init: Temporary process spawn error: No such file or directory
[    5.546270] init: Failed to create pty - disabling logging for job
[    5.590386] init: Temporary process spawn error: No such file or directory
[    5.627392] init: udev main process (197) terminated with status 4
[    5.630667] init: udev main process ended, respawning
[    5.634242] init: udev-fallback-graphics main process (208) terminated with status 1
[    5.642216] init: Failed to create pty - disabling logging for job
[    5.645473] init: Temporary process spawn error: No such file or directory
[    5.664914] init: Failed to create pty - disabling logging for job
[    5.668158] init: Temporary process spawn error: No such file or directory
[    5.686811] udevd[215]: starting version 175
[    5.691929] init: plymouth-splash main process (213) terminated with status 1
[    5.710772] init: udev main process (215) terminated with status 4
[    5.714381] init: udev main process ended, respawning
[    5.717668] init: Failed to create pty - disabling logging for job
[    5.730175] init: Temporary process spawn error: No such file or directory
[    5.743143] udevd[220]: starting version 175
[    5.765227] sctp: sctp_addr_wq_mgmt add new entry for cmd:0 127.0.0.1 in wq ffffffff82510e40
[    5.770498] sctp: sctp_addr_wq_mgmt add new entry for cmd:0 0000:0000:0000:0000:0000:0000:0000:0001 in wq ffffffff82510e40
[    5.777484] init: udev main process (220) terminated with status 4
[    5.781308] init: udev main process ended, respawning
[    5.790408] udevd[226]: starting version 175
[    5.797724] init: udev main process (226) terminated with status 4
[    5.811433] init: udev main process ended, respawning
[    5.833264] udevd[233]: starting version 175
[    5.858460] init: udev main process (233) terminated with status 4
[    5.865247] init: udev main process ended, respawning
[    5.874495] init: networking main process (218) terminated with status 1
[    5.896927] udevd[246]: starting version 175
[    5.906603] init: udev main process (246) terminated with status 4
[    5.913400] init: udev main process ended, respawning
[    5.932818] udevd[251]: starting version 175
[    5.940024] init: udev main process (251) terminated with status 4
[    5.950012] init: udev main process ended, respawning
[    5.956702] udevd[256]: starting version 175
[    5.979502] init: Failed to create pty - disabling logging for job
[    5.989748] init: Temporary process spawn error: No such file or directory
[    6.017239] init: Failed to create pty - disabling logging for job
[    6.047993] init: Temporary process spawn error: No such file or directory
Kernel tests: Boot OK!
[    6.122843] init: Failed to create pty - disabling logging for job
[    6.122892] init: Temporary process spawn error: No such file or directory
[    6.124820] init: Failed to create pty - disabling logging for job
[    6.124866] init: Temporary process spawn error: No such file or directory
[    6.126818] init: Failed to create pty - disabling logging for job
[    6.126863] init: Temporary process spawn error: No such file or directory
[    6.128936] init: udev main process (256) terminated with status 4
[    6.128974] init: udev main process ended, respawning
[    6.131797] udevd[288]: starting version 175
[    6.212262] init: udev main process (288) terminated with status 4
[    6.215891] init: udev main process ended, respawning
[    6.252131] udevd[290]: starting version 175
[    6.259353] init: udev main process (290) terminated with status 4
[    6.272777] sctp: sctp_addrwq_timo_handler: the first ent in wq ffffffff82510e40 is 127.0.0.1 for cmd 0 at entry ffff88000ec6e330
[    6.279380] sctp: sctp_addrwq_timo_handler: the first ent in wq ffffffff82510e40 is 0000:0000:0000:0000:0000:0000:0000:0001 for cmd 0 at entry ffff88000ec6e6e8
[    6.351135] init: udev main process ended, respawning
[    6.356897] udevd[292]: starting version 175
[    6.374391] init: udev main process (292) terminated with status 4
[    6.377664] init: udev respawning too fast, stopped
[   18.181829] warning: process `trinity-child0' used the deprecated sysctl system call with 
[   65.038181] init: Failed to create pty - disabling logging for job
[   65.046428] init: Temporary process spawn error: No such file or directory
[   65.063468] init: rc main process (257) killed by TERM signal
[   65.066496] init: tty4 main process (263) killed by TERM signal
[   65.069629] init: tty5 main process (283) killed by TERM signal
[   65.072998] init: tty2 main process (284) killed by TERM signal
[   65.076081] init: tty3 main process (285) killed by TERM signal
[   65.079171] init: tty6 main process (286) killed by TERM signal
[   65.082368] init: hwclock-save main process (344) terminated with status 70
[   65.085802] init: plymouth-upstart-bridge main process (345) terminated with status 1
[   65.138243] ------------[ cut here ]------------
[   65.140281] WARNING: at /c/kernel-tests/src/tip/mm/vmalloc.c:1487 __vunmap+0x10b/0x110()
[   65.143247] Trying to vfree() nonexistent vm area (ffffc90000810000)
[   65.145697] CPU: 0 PID: 145 Comm: trinity Not tainted 3.10.0-rc5-00652-ge8a36a6 #9
[   65.148822] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[   65.151073]  0000000000000009 ffff88000f3b7bc8 ffffffff81d3e5b3 ffff88000f3b7c08
[   65.154718]  ffffffff810cf7a6 ffff88000f3b7c28 ffffc90000810000 0000000000000000
[   65.158343]  0000000000000001 ffff88000dc36620 ffff8800091c87b0 ffff88000f3b7c68
[   65.161574] Call Trace:
[   65.162609]  [<ffffffff81d3e5b3>] dump_stack+0x19/0x1b
[   65.164349]  [<ffffffff810cf7a6>] warn_slowpath_common+0x66/0x90
[   65.166294]  [<ffffffff810cf841>] warn_slowpath_fmt+0x41/0x50
[   65.168286]  [<ffffffff81166f7b>] __vunmap+0x10b/0x110
[   65.170351]  [<ffffffff81166e2f>] vfree+0x2f/0x70
[   65.172272]  [<ffffffff81afd478>] netlink_skb_destructor+0xb8/0x100
[   65.174645]  [<ffffffff81aac8a1>] skb_release_head_state+0x51/0xb0
[   65.177009]  [<ffffffff81aadb61>] skb_release_all+0x11/0x30
[   65.179175]  [<ffffffff81aadb91>] __kfree_skb+0x11/0x90
[   65.181293]  [<ffffffff81aad9d9>] kfree_skb+0x19/0x40
[   65.183308]  [<ffffffff81ab00a8>] skb_queue_purge+0x18/0x30
[   65.185482]  [<ffffffff81afd858>] netlink_sock_destruct+0x38/0x110
[   65.187873]  [<ffffffff81aa8c3a>] __sk_free+0x1a/0x120
[   65.189911]  [<ffffffff81aa9989>] sk_free+0x19/0x20
[   65.191875]  [<ffffffff81afec77>] netlink_release+0x177/0x2d0
[   65.194086]  [<ffffffff81aa6208>] sock_release+0x18/0x70
[   65.196172]  [<ffffffff81aa645d>] sock_close+0xd/0x20
[   65.198190]  [<ffffffff8118ae55>] __fput+0xf5/0x240
[   65.200189]  [<ffffffff8118b069>] ____fput+0x9/0x10
[   65.202139]  [<ffffffff810eb955>] task_work_run+0x85/0xc0
[   65.204257]  [<ffffffff810d4942>] do_exit+0x232/0x920
[   65.206262]  [<ffffffff810d50ab>] do_group_exit+0x3b/0x90
[   65.208353]  [<ffffffff810d5112>] SyS_exit_group+0x12/0x20
[   65.210517]  [<ffffffff81d46827>] system_call_fastpath+0x16/0x1b
[   65.212811] ---[ end trace 9a70fd0f1776886b ]---
[   65.328937] Unregister pv shared memory for cpu 0
[   65.355536] Restarting system.
[   65.356599] reboot: machine restart
Elapsed time: 80

--n8g4imXOkfNTN/H1
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="bisect-e8a36a6ada2098e53e13e7c4f28f3d0857738df4-x86_64-randconfig-c03-0611-__vunmap-123562.log"
Content-Transfer-Encoding: base64

YmlzZWN0OiBza2lwIDM0Mzc2YTUwZmIxZmEwOTViOWQwNjM2ZmE0MWVkMmU3MzEyNWYyMTQ6
IG5vdCBhIGdvb2QgbWVyZ2UgYmFzZQpnaXQgY2hlY2tvdXQgdjMuOQpQcmV2aW91cyBIRUFE
IHBvc2l0aW9uIHdhcyBlOGEzNmE2Li4uIE1lcmdlIHJlbW90ZS10cmFja2luZyBicmFuY2gg
J3gwMTQ4NDA2L3RtcCcgaW50byBkZXZlbC1jYWlyby14ODZfNjQtMjAxMzA2MTExOTEwCkhF
QUQgaXMgbm93IGF0IGMxYmU1YTUuLi4gTGludXggMy45CmxzIC1hIC9rZXJuZWwtdGVzdHMv
cnVuLXF1ZXVlL2t2bS94ODZfNjQtcmFuZGNvbmZpZy1jMDMtMDYxMS9saW51eC1kZXZlbDpk
ZXZlbC1jYWlyby14ODZfNjQtMjAxMzA2MTExOTEwOmMxYmU1YTViMWIzNTVkNDBlNmNmNzlj
Yzk3OWViNjZkYWZhMjRhZDE6YmlzZWN0LXVzYgoKMjAxMy0wNi0xMi0xODo1OTozOSBjMWJl
NWE1YjFiMzU1ZDQwZTZjZjc5Y2M5NzllYjY2ZGFmYTI0YWQxIGNvbXBpbGluZwoxNDIgcmVh
bCAgMTY1MyB1c2VyICAxMzAgc3lzICAxMjUyLjA0JSBjcHUgCXg4Nl82NC1yYW5kY29uZmln
LWMwMy0wNjExCgoyMDEzLTA2LTEyLTE5OjAyOjM4IGRldGVjdGluZyBib290IHN0YXRlIDMu
OS4wLi4JMgk2CTkJMTMJMTQJMTUJMTgJMjYJMjkJMzUJNDEJNDQJNDgJNDkJNTMJNjMJNjYJ
NzUJODAJODEJODgJOTguLgk5OQkxMDAJMTAxCTEwMwkxMTIJMTE2CTExOS4JMTIxCTEyNAkx
MjYuCTEyNy4JMTI4CTEyOQkxMzAuCTEzMgkxMzUJMTM3CTE0MQkxNDIJMTUzCTE1NAkxNTUJ
MTU2CTE1OAkxNjUJMTY4CTE3MAkxNzMJMTc1CTE4MwkxODUuCTE4NwkxODgJMTk1CTE5Ngkx
OTkJMjAzCTIwNAkyMDUJMjEwCTIxMQkyMTMJMjE3CTIxOQkyMjEJMjIyLgkyMjQJMjI3CTIy
OS4JMjMwIFNVQ0NFU1MKCmJpc2VjdDogZ29vZCBjb21taXQgdjMuOQpnaXQgYmlzZWN0IHN0
YXJ0IGU4YTM2YTZhZGEyMDk4ZTUzZTEzZTdjNGYyOGYzZDA4NTc3MzhkZjQgdjMuOSAtLQpC
aXNlY3Rpbmc6IDczODMgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3Vn
aGx5IDEzIHN0ZXBzKQpbMjBiNGZiNDg1MjI3NDA0MzI5ZTQxYWQxNTU4OGFmYWQzZGYyMzA1
MF0gTWVyZ2UgYnJhbmNoICdmb3ItbGludXMnIG9mIGdpdDovL2dpdC5rZXJuZWwub3JnL3B1
Yi9zY20vbGludXgva2VybmVsL2dpdC92aXJvL3ZmcwpnaXQgYmlzZWN0IHJ1biAvYy9rZXJu
ZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9jL3dmZy91c2Ivb2JqLWJp
c2VjdApydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUu
c2ggL2Mvd2ZnL3VzYi9vYmotYmlzZWN0CmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVuLXF1ZXVl
L2t2bS94ODZfNjQtcmFuZGNvbmZpZy1jMDMtMDYxMS9saW51eC1kZXZlbDpkZXZlbC1jYWly
by14ODZfNjQtMjAxMzA2MTExOTEwOjIwYjRmYjQ4NTIyNzQwNDMyOWU0MWFkMTU1ODhhZmFk
M2RmMjMwNTA6YmlzZWN0LXVzYgoKMjAxMy0wNi0xMi0xOTo0NDoxOSAyMGI0ZmI0ODUyMjc0
MDQzMjllNDFhZDE1NTg4YWZhZDNkZjIzMDUwIGNvbXBpbGluZwo0NjYgcmVhbCAgMTY3MSB1
c2VyICAxMzUgc3lzICAzODcuMzYlIGNwdSAJeDg2XzY0LXJhbmRjb25maWctYzAzLTA2MTEK
CjIwMTMtMDYtMTItMTk6NTI6MjAgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgMy45LjAtMDczOTEt
ZzIwYjRmYjQuLi4JNQk3CTgJOQkxMgkxMwkxNAkxNgkyNQkyOS4JMzEJMzIJMzYJMzguCTM5
CTQxCTQ2Lgk0Nwk1MQk1NAk1Ni4JNTkJNjMJNjYJNzAJNzIJNzMuCTc1CTgyCTgzCTg2CTg4
CTkwCTkzCTk1CTk4LgkxMDEJMTA1CTEwNwkxMDkJMTEyCTExNgkxMjEJMTIzCTEyOAkxMjkJ
MTM0CTEzNy4JMTQwCTE0NC4uCTE0NwkxNDkJMTUxLgkxNTMJMTU2CTE2MwkxNzAJMTcxLi4u
LgkxNzUJMTc2CTE3OAkxODIJMTg2CTE4OAkxODkuCTE5MgkxOTYJMjAyLgkyMDMJMjA2CTIx
MAkyMTMJMjE3CTIxOAkyMjMJMjI2CTIyOS4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4bWzE7MzVtYWRkX3RvX3J1bl9xdWV1ZSAxG1swbQouLi4JMjMwIFNVQ0NFU1MKCkJpc2Vj
dGluZzogMzcyMiByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkg
MTIgc3RlcHMpCltlYWM4NDEwNWNkZGY4Njg2NDQwYWFhOWZiY2I1ODA5M2UzN2U0MTgwXSBN
ZXJnZSB0YWcgJ2Zvcl9saW51cycgb2YgZ2l0Oi8vZ2l0Lmtlcm5lbC5vcmcvcHViL3NjbS9s
aW51eC9rZXJuZWwvZ2l0L21zdC92aG9zdApydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNl
Y3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2Mvd2ZnL3VzYi9vYmotYmlzZWN0CmxzIC1hIC9r
ZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2bS94ODZfNjQtcmFuZGNvbmZpZy1jMDMtMDYxMS9s
aW51eC1kZXZlbDpkZXZlbC1jYWlyby14ODZfNjQtMjAxMzA2MTExOTEwOmVhYzg0MTA1Y2Rk
Zjg2ODY0NDBhYWE5ZmJjYjU4MDkzZTM3ZTQxODA6YmlzZWN0LXVzYgoKMjAxMy0wNi0xMi0y
MzoxMzoyOSBlYWM4NDEwNWNkZGY4Njg2NDQwYWFhOWZiY2I1ODA5M2UzN2U0MTgwIGNvbXBp
bGluZwoyNTUgcmVhbCAgMTcwMyB1c2VyICAxNDkgc3lzICA3MjQuMzElIGNwdSAJeDg2XzY0
LXJhbmRjb25maWctYzAzLTA2MTEKCjIwMTMtMDYtMTItMjM6MTg6MTggZGV0ZWN0aW5nIGJv
b3Qgc3RhdGUgMy45LjAtMTEwNTItZ2VhYzg0MTAuLgkxCTMJMTAJMjAJMjcJMzAJNDEJNTEJ
NTQJNjYJNzMJOTUJOTcJMTA0CTExOAkxNDAJMTQxCTE0MgkxNDgJMTU2CTE2MAkxNjEJMTYy
CTE4NAkxODcuCTIwNAkyMjAuLgkyMjYJMjMwIFNVQ0NFU1MKCkJpc2VjdGluZzogMTg2MSBy
ZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgMTEgc3RlcHMpCls1
YzY0ZTNhNDVkNDNjNmUzZmE4N2NiZTAyZTEwMDU5MTcxZDEwODEyXSBNZXJnZSBicmFuY2gg
J3F1ZXVlJyBvZiBnaXQ6Ly9naXQua2VybmVsLm9yZy9wdWIvc2NtL2xpbnV4L2tlcm5lbC9n
aXQvbmFiL3RhcmdldC1wZW5kaW5nCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10
ZXN0LWJvb3QtZmFpbHVyZS5zaCAvYy93ZmcvdXNiL29iai1iaXNlY3QKbHMgLWEgL2tlcm5l
bC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1yYW5kY29uZmlnLWMwMy0wNjExL2xpbnV4
LWRldmVsOmRldmVsLWNhaXJvLXg4Nl82NC0yMDEzMDYxMTE5MTA6NWM2NGUzYTQ1ZDQzYzZl
M2ZhODdjYmUwMmUxMDA1OTE3MWQxMDgxMjpiaXNlY3QtdXNiCgoyMDEzLTA2LTEyLTIzOjM1
OjIyIDVjNjRlM2E0NWQ0M2M2ZTNmYTg3Y2JlMDJlMTAwNTkxNzFkMTA4MTIgY29tcGlsaW5n
CjE5NiByZWFsICAxNjg0IHVzZXIgIDEzNyBzeXMgIDkyOC42MyUgY3B1IAl4ODZfNjQtcmFu
ZGNvbmZpZy1jMDMtMDYxMQoKMjAxMy0wNi0xMi0yMzozODo1MCBkZXRlY3RpbmcgYm9vdCBz
dGF0ZSAzLjEwLjAtcmMxLTAwMTk4LWc1YzY0ZTNhNC4uLgkyCTMJNAk1CTEwCTEyLgkxNAky
MS4uCTMwCTQxCTQyCTQ5CTU3CTU5CTYwCTY3CTc1CTc2CTc4CTgyLi4JODUJOTEJMTEzCTEx
OQkxMjcJMTM2CTE2NAkxNjUJMTY2CTE3NAkyMDcJMjEwCTIxNQkyMjgJMjMwIFNVQ0NFU1MK
CkJpc2VjdGluZzogOTI5IHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91
Z2hseSAxMCBzdGVwcykKWzg3NjRkODYxMDBmZTU4ZTY5ODc3NzUzZmFhNDRmYzFkOTI3NmM2
MjRdIE1lcmdlIGJyYW5jaCAnZm9yLWxpbnVzJyBvZiBnaXQ6Ly9naXQua2VybmVsLm9yZy9w
dWIvc2NtL2xpbnV4L2tlcm5lbC9naXQvbXN6ZXJlZGkvZnVzZQpydW5uaW5nIC9jL2tlcm5l
bC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2Mvd2ZnL3VzYi9vYmotYmlz
ZWN0CmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2bS94ODZfNjQtcmFuZGNvbmZp
Zy1jMDMtMDYxMS9saW51eC1kZXZlbDpkZXZlbC1jYWlyby14ODZfNjQtMjAxMzA2MTExOTEw
Ojg3NjRkODYxMDBmZTU4ZTY5ODc3NzUzZmFhNDRmYzFkOTI3NmM2MjQ6YmlzZWN0LXVzYgoK
MjAxMy0wNi0xMy0wMDowMDoyMyA4NzY0ZDg2MTAwZmU1OGU2OTg3Nzc1M2ZhYTQ0ZmMxZDky
NzZjNjI0IGNvbXBpbGluZwoxOTAgcmVhbCAgMTcwNCB1c2VyICAxMzggc3lzICA5NjguNjUl
IGNwdSAJeDg2XzY0LXJhbmRjb25maWctYzAzLTA2MTEKCjIwMTMtMDYtMTMtMDA6MDM6NDkg
ZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgMy4xMC4wLXJjNC0wMDA0NC1nODc2NGQ4Ni4uCTEJNgkx
NQkxOQkyOQk0Ngk0OQk1NQk3NAk5NgkxMDAJMTEzCTEzMwkxMzcJMTM4CTE1NwkxNTkJMTYz
CTE3NAkxOTEJMTk1CTIwMgkyMTYJMjE3CTIyMgkyMjkuLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLgkyMzAgU1VDQ0VT
UwoKQmlzZWN0aW5nOiA0NjYgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChy
b3VnaGx5IDkgc3RlcHMpCltjOGNlY2ZkMWFiZmI0MTViYmZjNDE1N2U3MTFiNTBjNWM2ZmFi
MjcwXSBNZXJnZSByZW1vdGUtdHJhY2tpbmcgYnJhbmNoICdhc29jL2Zvci1uZXh0JyBpbnRv
IGRldmVsLWNhaXJvLXg4Nl82NC0yMDEzMDYxMTE5MTAKcnVubmluZyAvYy9rZXJuZWwtdGVz
dHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9jL3dmZy91c2Ivb2JqLWJpc2VjdAps
cyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0veDg2XzY0LXJhbmRjb25maWctYzAz
LTA2MTEvbGludXgtZGV2ZWw6ZGV2ZWwtY2Fpcm8teDg2XzY0LTIwMTMwNjExMTkxMDpjOGNl
Y2ZkMWFiZmI0MTViYmZjNDE1N2U3MTFiNTBjNWM2ZmFiMjcwOmJpc2VjdC11c2IKCjIwMTMt
MDYtMTMtMDA6NTA6NTQgYzhjZWNmZDFhYmZiNDE1YmJmYzQxNTdlNzExYjUwYzVjNmZhYjI3
MCBjb21waWxpbmcKMTk2IHJlYWwgIDE3MDEgdXNlciAgMTQyIHN5cyAgOTM4LjM3JSBjcHUg
CXg4Nl82NC1yYW5kY29uZmlnLWMwMy0wNjExCgoyMDEzLTA2LTEzLTAwOjU0OjIyIGRldGVj
dGluZyBib290IHN0YXRlIDMuMTAuMC1yYzUtMDAxODUtZ2M4Y2VjZmQuLi4JMTEuCTI0CTUx
CTgwCTk3CTEwMQkxMzIJMTQyCTE0NgkxNDgJMTU1CTE3MAkyMDEJMjA4CTIxMwkyMjYJMjI5
Li4uLi4uCTIzMCBTVUNDRVNTCgpCaXNlY3Rpbmc6IDIzMyByZXZpc2lvbnMgbGVmdCB0byB0
ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgOCBzdGVwcykKWzMxMTUwM2JiMjExOTc4OGFjODhj
NDA2ZTA4OTMzNTFhMmJiMDcwNWVdIHR1bGlwOiByZW1vdmUgcmVkdW5kYW50IEQwIHBvd2Vy
IHN0YXRlIHNldApydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZh
aWx1cmUuc2ggL2Mvd2ZnL3VzYi9vYmotYmlzZWN0CmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVu
LXF1ZXVlL2t2bS94ODZfNjQtcmFuZGNvbmZpZy1jMDMtMDYxMS9saW51eC1kZXZlbDpkZXZl
bC1jYWlyby14ODZfNjQtMjAxMzA2MTExOTEwOjMxMTUwM2JiMjExOTc4OGFjODhjNDA2ZTA4
OTMzNTFhMmJiMDcwNWU6YmlzZWN0LXVzYgoKMjAxMy0wNi0xMy0wMTowODoyNCAzMTE1MDNi
YjIxMTk3ODhhYzg4YzQwNmUwODkzMzUxYTJiYjA3MDVlIGNvbXBpbGluZwoxOTUgcmVhbCAg
MTczNSB1c2VyICAxNTUgc3lzICA5NjcuNjUlIGNwdSAJeDg2XzY0LXJhbmRjb25maWctYzAz
LTA2MTEKCjIwMTMtMDYtMTMtMDE6MTE6NTQgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgMy4xMC4w
LXJjMi0wMDU2MS1nMzExNTAzYi4uLi4uLgkxNgkxOAkyNwkzNQk3Mgk3OAk4MwkxMTAJMTMy
CTE2MwkxNjcJMTc3CTE5NwkyMjYuLgkyMjcJMjI4Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLhtbMTszNW1hZGRfdG9fcnVuX3F1ZXVlIDIbWzBtCi4uCTIyOQkyMzAgU1VDQ0VT
UwoKQmlzZWN0aW5nOiAxMTYgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChy
b3VnaGx5IDcgc3RlcHMpCltlZDA0ODNmYTA2ZTBlZmI4NmE4MmUzODJhMDBkYmFkMDJiNjI4
MDdjXSBtYWN2dGFwOiBmaXggYSBwb3NzaWJsZSByYWNlIGJldHdlZW4gcXVldWUgc2VsZWN0
aW9uIGFuZCBjaGFuZ2luZyBxdWV1ZXMKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0
LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9jL3dmZy91c2Ivb2JqLWJpc2VjdApscyAtYSAva2Vy
bmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0veDg2XzY0LXJhbmRjb25maWctYzAzLTA2MTEvbGlu
dXgtZGV2ZWw6ZGV2ZWwtY2Fpcm8teDg2XzY0LTIwMTMwNjExMTkxMDplZDA0ODNmYTA2ZTBl
ZmI4NmE4MmUzODJhMDBkYmFkMDJiNjI4MDdjOmJpc2VjdC11c2IKCjIwMTMtMDYtMTMtMDM6
NTY6MzEgZWQwNDgzZmEwNmUwZWZiODZhODJlMzgyYTAwZGJhZDAyYjYyODA3YyBjb21waWxp
bmcKMjA1IHJlYWwgIDE3MTIgdXNlciAgMTM4IHN5cyAgODk5LjU5JSBjcHUgCXg4Nl82NC1y
YW5kY29uZmlnLWMwMy0wNjExCgoyMDEzLTA2LTEzLTA0OjAwOjEwIGRldGVjdGluZyBib290
IHN0YXRlIDMuMTAuMC1yYzQtMDA1NjQtZ2VkMDQ4M2YuLgkyCTgJMTgJMjcJMjkJMzgJNDMJ
NTMJNTYJNjAJNzAJNzUJODguLgk5MgkxMDIgVEVTVCBGQUlMVVJFChtbMTszNW1JbmNyZWFz
aW5nIHJlcGVhdCBjb3VudCBmcm9tIDIzMCB0byAyNzAbWzBtCmRtZXNnLWt2bS1sa3AtbmV4
MDQtMTgxNDYtMjAxMzA2MTMwMzAxMzEtMy4xMC4wLXJjNC0wMDU2NC1nZWQwNDgzZi04CmRt
ZXNnLWt2bS1sa3AtbmV4MDQtMjAzNzEtMjAxMzA2MTMwMzAxMjktMy4xMC4wLXJjNC0wMDU2
NC1nZWQwNDgzZi04CgpCaXNlY3Rpbmc6IDU2IHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0
ZXIgdGhpcyAocm91Z2hseSA2IHN0ZXBzKQpbNmY0NWViYTE4OTRhM2VjZTg4NTc0MDc5YTkz
MWNjMmU1YmVlZTFmM10gTWVyZ2UgYnJhbmNoICdmb3ItZGF2ZW0nIG9mIGdpdDovL2dpdG9y
aW91cy5vcmcvbGludXgtY2FuL2xpbnV4LWNhbi1uZXh0CnJ1bm5pbmcgL2Mva2VybmVsLXRl
c3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvYy93ZmcvdXNiL29iai1iaXNlY3QK
bHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1yYW5kY29uZmlnLWMw
My0wNjExL2xpbnV4LWRldmVsOmRldmVsLWNhaXJvLXg4Nl82NC0yMDEzMDYxMTE5MTA6NmY0
NWViYTE4OTRhM2VjZTg4NTc0MDc5YTkzMWNjMmU1YmVlZTFmMzpiaXNlY3QtdXNiCgoyMDEz
LTA2LTEzLTA0OjA5OjQxIDZmNDVlYmExODk0YTNlY2U4ODU3NDA3OWE5MzFjYzJlNWJlZWUx
ZjMgY29tcGlsaW5nCjE5MSByZWFsICAxNzA2IHVzZXIgIDEzNyBzeXMgIDk2My4zMCUgY3B1
IAl4ODZfNjQtcmFuZGNvbmZpZy1jMDMtMDYxMQoKMjAxMy0wNi0xMy0wNDoxMzowMiBkZXRl
Y3RpbmcgYm9vdCBzdGF0ZSAzLjEwLjAtcmMyLTAwNjIxLWc2ZjQ1ZWJhLi4uCTE2CTIyCTI0
CTI1CTMxCTM1CTQxCTQ5CTUwCTUyCTUzLgk1OQk2OQk3Mgk3NAk3Nwk4MQk4OAk5NAk5Ngkx
MDEJMTA1CTExNQkxMTcJMTIwCTEyOAkxMzQJMTM3CTEzOQkxNDEJMTQ1CTE0OQkxNTEJMTUz
CTE1NAkxNTUJMTU4CTE1OQkxNjEJMTY1CTE2OQkxNzQJMTc3CTE4MQkxODYJMTg3CTIwMgky
MDUJMjA4CTIxMwkyMjQJMjM4CTI0NQkyNTIJMjU0CTI2MQkyNjYJMjcwIFNVQ0NFU1MKCkJp
c2VjdGluZzogMjggcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5
IDUgc3RlcHMpCltkZGNkOTFjNmI4ZWM2MGE2YmQ1ZDM2OTFkMmNmYWY0NDQ3MjE1ZGExXSBz
aF9ldGg6IHVzZSBFRFNSX0VOQUxMIHRvIHNldCBFRFNSCnJ1bm5pbmcgL2Mva2VybmVsLXRl
c3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvYy93ZmcvdXNiL29iai1iaXNlY3QK
bHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1yYW5kY29uZmlnLWMw
My0wNjExL2xpbnV4LWRldmVsOmRldmVsLWNhaXJvLXg4Nl82NC0yMDEzMDYxMTE5MTA6ZGRj
ZDkxYzZiOGVjNjBhNmJkNWQzNjkxZDJjZmFmNDQ0NzIxNWRhMTpiaXNlY3QtdXNiCgoyMDEz
LTA2LTEzLTA0OjQ0OjA0IGRkY2Q5MWM2YjhlYzYwYTZiZDVkMzY5MWQyY2ZhZjQ0NDcyMTVk
YTEgY29tcGlsaW5nCjE5NiByZWFsICAxNzE0IHVzZXIgIDE0MCBzeXMgIDk0My42MSUgY3B1
IAl4ODZfNjQtcmFuZGNvbmZpZy1jMDMtMDYxMQoKMjAxMy0wNi0xMy0wNDo0NzoyOCBkZXRl
Y3RpbmcgYm9vdCBzdGF0ZSAzLjEwLjAtcmM0LTAwNDcxLWdkZGNkOTFjLi4JMgkxMAkxNwkx
OQkyNAkyOQk0MAk0Nwk1MQk1NQk2OAk3OAk4OC4JOTAJMTA0CTExMAkxMTMJMTE2CTEyNS4J
MTMwCTEzOS4JMTQ0CTE0NwkxNjEJMTY3CTE3MQkxNzIJMTc1CTE3NwkxODEJMTg3CTE5MS4u
CTIwMgkyMDQJMjA3CTIwOAkyMDkJMjEzCTIxNAkyMjAuLgkyMjMJMjI5CTIzMAkyMzUJMjQz
CTI0NgkyNDkJMjYxLgkyNjUJMjY3CTI2OC4uLgkyNjkuLi4uLi4uLi4uLi4JMjcwIFNVQ0NF
U1MKCkJpc2VjdGluZzogMTQgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChy
b3VnaGx5IDQgc3RlcHMpCltjYTE2MmE4MmY1NjkyMTQ0MmY1ZGI3MmEzYTQ3MjAxMGU1YTYy
YzRiXSBmZWM6IE9ubHkgcGFzcyBwZGV2IGluIGZlY19wdHBfaW5pdCgpCnJ1bm5pbmcgL2Mv
a2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvYy93ZmcvdXNiL29i
ai1iaXNlY3QKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1yYW5k
Y29uZmlnLWMwMy0wNjExL2xpbnV4LWRldmVsOmRldmVsLWNhaXJvLXg4Nl82NC0yMDEzMDYx
MTE5MTA6Y2ExNjJhODJmNTY5MjE0NDJmNWRiNzJhM2E0NzIwMTBlNWE2MmM0YjpiaXNlY3Qt
dXNiCgoyMDEzLTA2LTEzLTA1OjI2OjM3IGNhMTYyYTgyZjU2OTIxNDQyZjVkYjcyYTNhNDcy
MDEwZTVhNjJjNGIgY29tcGlsaW5nCjE5MiByZWFsICAxNjkxIHVzZXIgIDE0NSBzeXMgIDk1
NS40MCUgY3B1IAl4ODZfNjQtcmFuZGNvbmZpZy1jMDMtMDYxMQoKMjAxMy0wNi0xMy0wNToz
MDowMiBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAzLjEwLjAtcmM0LTAwNTQ5LWdjYTE2MmE4Li4u
CTEJMi4JNAk1Lgk2CTEyCTE2CTE5CTIxCTIzCTMwCTM0CTM1CTQwCTQyCTQ0CTQ1CTUwCTUz
CTU4CTU5CTYxCTYyCTY5Li4JNzIJNzMJNzUJODAuCTgzCTg2CTg5CTk4CTEwNi4JMTA4Lgkx
MTEJMTE4CTEyMQkxMjcJMTM3CTE0MgkxNDMJMTQ0CTE0NwkxNTcJMTYwCTE2MQkxNjMJMTY1
CTE2NgkxNzUuLgkxNzYJMTc4CTE3OQkxODgJMTg5CTE5NQkyMDIJMjA2CTIwOAkyMTAJMjEz
CTIyNC4uCTIyNgkyMjcJMjI4CTIzMQkyMzIJMjM3CTI0NgkyNDcJMjQ4CTI1MAkyNTIJMjUz
CTI1NgkyNTguCTI2MQkyNjYJMjY4CTI3MCBTVUNDRVNTCgpCaXNlY3Rpbmc6IDcgcmV2aXNp
b25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDMgc3RlcHMpCltjMThhNzlh
YmUzMWY1NTVlYzNiMzYzYjViOGMxZDAwMzIzMDA1M2I2XSBzaF9ldGg6IGdldCBTSDc2MTkg
c3VwcG9ydCBvdXQgb2YgI2lmZGVmCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10
ZXN0LWJvb3QtZmFpbHVyZS5zaCAvYy93ZmcvdXNiL29iai1iaXNlY3QKbHMgLWEgL2tlcm5l
bC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1yYW5kY29uZmlnLWMwMy0wNjExL2xpbnV4
LWRldmVsOmRldmVsLWNhaXJvLXg4Nl82NC0yMDEzMDYxMTE5MTA6YzE4YTc5YWJlMzFmNTU1
ZWMzYjM2M2I1YjhjMWQwMDMyMzAwNTNiNjpiaXNlY3QtdXNiCgoyMDEzLTA2LTEzLTA2OjE3
OjM0IGMxOGE3OWFiZTMxZjU1NWVjM2IzNjNiNWI4YzFkMDAzMjMwMDUzYjYgY29tcGlsaW5n
CjE4NSByZWFsICAxNzAzIHVzZXIgIDEzOSBzeXMgIDk5NS4yOSUgY3B1IAl4ODZfNjQtcmFu
ZGNvbmZpZy1jMDMtMDYxMQoKMjAxMy0wNi0xMy0wNjoyMDo0OCBkZXRlY3RpbmcgYm9vdCBz
dGF0ZSAzLjEwLjAtcmM0LTAwNTU2LWdjMThhNzlhLi4uCTYuCTcJMTUuCTE3CTIxLgkyNAkz
MwkzOQk0Mwk0Ngk1MAk1Mgk1NC4JNTUJNTgJNjAJNjMuCTY0CTY3CTcxCTcyCTczCTc0CTc4
CTgwCTg0CTg5CTkyCTk1CTk3CTEwMAkxMDEJMTAzCTEwNC4JMTA1CTEwNgkxMDcJMTEwCTEx
MQkxMTIuCTExNgkxMTcJMTE5LgkxMjAJMTIxCTEyMwkxMjQJMTI1LgkxMjYJMTI5CTEzNQkx
MzgJMTQxCTE0NS4JMTUxCTE1MgkxNTcJMTY5CTE3MAkxNzEgVEVTVCBGQUlMVVJFChtbMTsz
NW1JbmNyZWFzaW5nIHJlcGVhdCBjb3VudCBmcm9tIDI3MCB0byA4NzUbWzBtCmRtZXNnLWt2
bS1sa3AtbmV4MDQtMjczNDUtMjAxMzA2MTMwNTQ4NTktMy4xMC4wLXJjNC0wMDU1Ni1nYzE4
YTc5YS0xMgoKQmlzZWN0aW5nOiAzIHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhp
cyAocm91Z2hseSAyIHN0ZXBzKQpbYzA1Y2RiMWI4NjRmNTQ4YzBjM2Q4YWUzYjUxMjY0ZTY3
MzlhNjliMV0gbmV0bGluazogYWxsb3cgbGFyZ2UgZGF0YSB0cmFuc2ZlcnMgZnJvbSB1c2Vy
LXNwYWNlCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVy
ZS5zaCAvYy93ZmcvdXNiL29iai1iaXNlY3QKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVl
dWUva3ZtL3g4Nl82NC1yYW5kY29uZmlnLWMwMy0wNjExL2xpbnV4LWRldmVsOmRldmVsLWNh
aXJvLXg4Nl82NC0yMDEzMDYxMTE5MTA6YzA1Y2RiMWI4NjRmNTQ4YzBjM2Q4YWUzYjUxMjY0
ZTY3MzlhNjliMTpiaXNlY3QtdXNiCgoyMDEzLTA2LTEzLTA2OjU3OjIwIGMwNWNkYjFiODY0
ZjU0OGMwYzNkOGFlM2I1MTI2NGU2NzM5YTY5YjEgY29tcGlsaW5nCjIwMyByZWFsICAxNjk2
IHVzZXIgIDEzOSBzeXMgIDkwNC4zMyUgY3B1IAl4ODZfNjQtcmFuZGNvbmZpZy1jMDMtMDYx
MQoKMjAxMy0wNi0xMy0wNzowMDo1NCBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAzLjEwLjAtcmM0
LTAwNTUyLWdjMDVjZGIxLi4uCTIJMwkxMAkxMS4JMTIJMTMJMTgJMjEJMjIJMjQJMjUuLgky
NgkyNwkyOQkzOSBURVNUIEZBSUxVUkUKZG1lc2cta3ZtLWxrcC1uZXgwNC00Mjc4OS0yMDEz
MDYxMzA2MDMwNy0zLjEwLjAtcmM0LTAwNTUyLWdjMDVjZGIxLTEzCgpCaXNlY3Rpbmc6IDAg
cmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDEgc3RlcCkKWzFi
NWFjZDI5MjMzNmRhMDI5NTM1ZGUwMTBhZjU2ODUzM2RmOWI2NjVdIGJvbmRpbmc6IGRpc2Fs
bG93IGNoYW5nZSBvZiBNQUMgaWYgZmFpbF9vdmVyX21hYyBlbmFibGVkCnJ1bm5pbmcgL2Mv
a2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvYy93ZmcvdXNiL29i
ai1iaXNlY3QKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1yYW5k
Y29uZmlnLWMwMy0wNjExL2xpbnV4LWRldmVsOmRldmVsLWNhaXJvLXg4Nl82NC0yMDEzMDYx
MTE5MTA6MWI1YWNkMjkyMzM2ZGEwMjk1MzVkZTAxMGFmNTY4NTMzZGY5YjY2NTpiaXNlY3Qt
dXNiCgoyMDEzLTA2LTEzLTA3OjExOjI2IDFiNWFjZDI5MjMzNmRhMDI5NTM1ZGUwMTBhZjU2
ODUzM2RmOWI2NjUgY29tcGlsaW5nCjE4OCByZWFsICAxNjg4IHVzZXIgIDE0MCBzeXMgIDk2
OS43NiUgY3B1IAl4ODZfNjQtcmFuZGNvbmZpZy1jMDMtMDYxMQoKMjAxMy0wNi0xMy0wNzox
NDo0NSBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAzLjEwLjAtcmM0LTAwNTUxLWcxYjVhY2QyLi4u
CTIJOQkxMAkxMgkxNQkyMS4uCTIyCTI1CTMwCTM0CTM4CTQzCTUyCTUzLi4JNjgJNzAJNzEu
Lgk3Mwk3NAk3Ni4uCTgwCTgxLgk4Mwk4NAk4Ngk5MAk5MQkxMDAJMTAyCTEwNAkxMDcJMTEy
CTExNwkxMjMJMTMyCTEzNC4JMTM2CTEzOQkxNDEuCTE0MgkxNDcJMTU3CTE1OAkxNjIJMTYz
CTE3MQkxNzMuLgkxNzUJMTc2CTE3OQkxODEuCTE4MgkxODcJMTkwLi4JMTkyCTE5MwkxOTYJ
MjAxCTIwNQkyMDkJMjIxLi4JMjI1CTIyOAkyMzAJMjM1CTIzOQkyNDEJMjQzCTI0OC4JMjQ5
CTI1MwkyNTYJMjU4LgkyNTkJMjYyLgkyNjQJMjY1CTI2Ny4JMjcwCTI3MgkyNzMJMjc3CTI3
OQkyODEJMjg2LgkyODgJMjkyCTI5NC4JMjk1CTMwOC4JMzA5CTMxNwkzMjEuCTMyMwkzMjYJ
MzI3CTMzNAkzMzcJMzQ2CTM0OAkzNDkJMzUzCTM1NQkzNTgJMzY3CTM3NQkzNzcJMzc5CTM5
MQkzOTYJNDAyCTQwOAk0MTEJNDE1Li4JNDE2CTQxOAk0MjQJNDI1CTQyNwk0MzYJNDM3CTQ0
MQk0NDIJNDQ2CTQ0OQk0NTEJNDU0Li4JNDU2CTQ1OAk0NjIJNDcxLgk0NzYJNDc4CTQ4Mgk0
OTYJNDk3CTQ5OAk0OTkJNTAzCTUwNC4JNTA2Lgk1MTkJNTIxCTUyMwk1MjUJNTM4CTU0NS4J
NTQ3Lgk1NDgJNTUzCTU1NC4JNTU2CTU1OQk1NjEJNTYzLi4JNTY1CTU3Mwk1NzcuCTU4Mwk1
ODguCTU5Mwk1OTcuCTU5OQk2MDIJNjExCTYxNS4JNjE4CTYyOQk2MzkJNjQyLgk2NDMJNjQ3
CTY1Ni4uCTY1Nwk2NjEuLgk2NjQuLgk2NjUJNjY2CTY2OQk2NzAJNjcxCTY3NQk2NzcJNjc4
CTY4Mwk2ODQuCTY4OC4uCTY5MAk2OTMJNjk0CTY5Ni4JNzAwCTcwNC4uCTcwNS4JNzA4Lgk3
MTAJNzEyCTcxNgk3MjAJNzI0CTcyOAk3MzMJNzM3CTc0Mgk3NDgJNzUzCTc1Nwk3NTkJNzYz
CTc3MS4JNzc1Lgk3ODAJNzg3CTc4OQk4MDAJODAyCTgwMwk4MDgJODEwCTgxMgk4MTMJODE3
CTgxOQk4MjMJODI4CTgzMwk4MzkJODUyCTg1OQk4NjAJODYxLgk4NjMuLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uG1sxOzM1bWFkZF90b19ydW5fcXVldWUgMTIbWzBtCi4uLi4u
Lgk4NjUuCTg2Ni4uLgk4NjkJODczCTg3NSBTVUNDRVNTCgpjMDVjZGIxYjg2NGY1NDhjMGMz
ZDhhZTNiNTEyNjRlNjczOWE2OWIxIGlzIHRoZSBmaXJzdCBiYWQgY29tbWl0CmNvbW1pdCBj
MDVjZGIxYjg2NGY1NDhjMGMzZDhhZTNiNTEyNjRlNjczOWE2OWIxCkF1dGhvcjogUGFibG8g
TmVpcmEgQXl1c28gPHBhYmxvQG5ldGZpbHRlci5vcmc+CkRhdGU6ICAgTW9uIEp1biAzIDA5
OjQ2OjI4IDIwMTMgKzAwMDAKCiAgICBuZXRsaW5rOiBhbGxvdyBsYXJnZSBkYXRhIHRyYW5z
ZmVycyBmcm9tIHVzZXItc3BhY2UKICAgIAogICAgSSBjYW4gaGl0IEVOT0JVRlMgaW4gdGhl
IHNlbmRtc2coKSBwYXRoIHdpdGggYSBsYXJnZSBiYXRjaCB0aGF0IGlzCiAgICBjb21wb3Nl
ZCBvZiBtYW55IG5ldGxpbmsgbWVzc2FnZXMuIEhlcmUgdGhhdCBsaW1pdCBpcyA4IE1CeXRl
cyBvZgogICAgc2tidWZmIGRhdGEgYXJlYSBhcyBrbWFsbG9jIGRvZXMgbm90IG1hbmFnZSB0
byBnZXQgbW9yZSB0aGFuIHRoYXQuCiAgICAKICAgIFdoaWxlIGRpc2N1c3NpbmcgYXRvbWlj
IHJ1bGUtc2V0IGZvciBuZnRhYmxlcyB3aXRoIFBhdHJpY2sgTWNIYXJkeSwKICAgIHdlIGRl
Y2lkZWQgdG8gcHV0IGFsbCBydWxlLXNldCB1cGRhdGVzIHRoYXQgbmVlZCB0byBiZSBhcHBs
aWVkCiAgICBhdG9taWNhbGx5IGluIG9uZSBzaW5nbGUgYmF0Y2ggdG8gc2ltcGxpZnkgdGhl
IGV4aXN0aW5nIGFwcHJvYWNoLgogICAgSG93ZXZlciwgYXMgZXhwbGFpbmVkIGFib3ZlLCB0
aGUgZXhpc3RpbmcgbmV0bGluayBjb2RlIGxpbWl0cyB1cwogICAgdG8gYSBtYXhpbXVtIG9m
IH4yMDAwMCBydWxlcyB0aGF0IGZpdCBpbiBvbmUgc2luZ2xlIGJhdGNoIHdpdGhvdXQKICAg
IGhpdHRpbmcgRU5PQlVGUy4gaXB0YWJsZXMgZG9lcyBub3QgaGF2ZSBzdWNoIGxpbWl0YXRp
b24gYXMgaXQgaXMKICAgIHVzaW5nIHZtYWxsb2MuCiAgICAKICAgIFRoaXMgcGF0Y2ggYWRk
cyBuZXRsaW5rX2FsbG9jX2xhcmdlX3NrYigpIHdoaWNoIGlzIG9ubHkgdXNlZCBpbgogICAg
dGhlIG5ldGxpbmtfc2VuZG1zZygpIHBhdGguIEl0IHVzZXMgYWxsb2Nfc2tiIGlmIHRoZSBt
ZW1vcnkKICAgIHJlcXVlc3RlZCBpcyA8PSBvbmUgbWVtb3J5IHBhZ2UsIHRoYXQgc2hvdWxk
IGJlIHRoZSBjb21tb24gY2FzZQogICAgZm9yIG1vc3Qgc3Vic3lzdGVtcywgZWxzZSB2bWFs
bG9jIGZvciBoaWdoZXIgbWVtb3J5IGFsbG9jYXRpb25zLgogICAgCiAgICBTaWduZWQtb2Zm
LWJ5OiBQYWJsbyBOZWlyYSBBeXVzbyA8cGFibG9AbmV0ZmlsdGVyLm9yZz4KICAgIFNpZ25l
ZC1vZmYtYnk6IERhdmlkIFMuIE1pbGxlciA8ZGF2ZW1AZGF2ZW1sb2Z0Lm5ldD4KCjowNDAw
MDAgMDQwMDAwIDEyOWQ1NzdlMDg2N2Q4YTRmNWQzYzM2ZjNlODAzN2U2NDkxZmQyZTIgYzY0
ZmRkY2ZkZDVkMDZlOGNlM2MzMTZlOTgxN2ZiZWVhMWVjYTUyZSBNCW5ldApiaXNlY3QgcnVu
IHN1Y2Nlc3MKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1yYW5k
Y29uZmlnLWMwMy0wNjExL2xpbnV4LWRldmVsOmRldmVsLWNhaXJvLXg4Nl82NC0yMDEzMDYx
MTE5MTA6MWI1YWNkMjkyMzM2ZGEwMjk1MzVkZTAxMGFmNTY4NTMzZGY5YjY2NTpiaXNlY3Qt
dXNiCgoyMDEzLTA2LTEzLTEyOjIwOjM4IDFiNWFjZDI5MjMzNmRhMDI5NTM1ZGUwMTBhZjU2
ODUzM2RmOWI2NjUgcmV1c2UgL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1jMDMtMDYxMS8x
YjVhY2QyOTIzMzZkYTAyOTUzNWRlMDEwYWY1Njg1MzNkZjliNjY1L3ZtbGludXotMy4xMC4w
LXJjNC0wMDU1MS1nMWI1YWNkMgoKMjAxMy0wNi0xMy0xMjoyMDo0MCBkZXRlY3RpbmcgYm9v
dCBzdGF0ZSAuLi4JMQk0CTYJOAkxMgkxNQkxNgkxNwkxOQkyNgkyNwkzMQk0Nwk0OQk1Ngk2
MQk3MQk3Ngk4MAk4NAk5NAk5OAkxMDMJMTA5CTExNAkxMjcJMTQ0CTE0NQkxNTIJMTY1CTE3
NgkxODQJMTg5CTE5MQkxOTIuCTE5MwkxOTQJMTk1Li4JMTk5CTIwMC4JMjAzLgkyMDUJMjA4
CTIxMC4JMjEyCTIxMwkyMjIJMjI3CTIyOS4JMjMwCTIzNAkyMzYJMjQxCTI0Mi4JMjQ2CTI1
MQkyNTIuCTI1NQkyNTgJMjYxCTI3NwkyODIJMjg4CTI5MgkyOTgJMzA4CTMxMQkzMTYJMzIw
CTMyMQkzMjMJMzI4CTMzMwkzMzYuCTMzOQkzNDAuCTM0MwkzNDQuCTM0NQkzNDYuCTM0Nwkz
NDguCTM1MAkzNTUuLgkzNTcJMzY1CTM2Ny4uCTM3MAkzNzIJMzc0LgkzNzYJMzgxCTM4NAkz
OTEuCTM5MgkzOTUJNDA0Li4JNDA1Lgk0MDcJNDEzLi4JNDE2CTQxOAk0MjQJNDI2CTQzMQk0
MzcJNDM5CTQ0Mgk0NDgJNDUwCTQ1NQk0NTYJNDU3CTQ1OQk0NjEJNDY0CTQ2OAk0NjkJNDc2
CTQ5Mwk1MDEJNTA0CTUxMQk1MTcJNTI0CTUzMgk1MzMJNTM0Li4JNTQyCTU1MQk1NTMJNTU4
CTU2MQk1NjQJNTY3CTU4MAk1ODQJNTg4Lgk2MDIJNjE0CTYxOQk2MjIJNjI0CTYzNwk2NTAJ
NjYxCTY2NAk2NjYJNjY5CTY3NAk2ODAJNjg1CTY5NAk3MTQJNzIwCTcyMgk3MzYJNzQxCTc2
MQk3NjQJNzY2CTc3MQk3NzUJNzkwCTgwMQk4MTQJODE4CTgyOAk4MjkJODQwCTg0Ngk4NTcJ
ODY5CTg4MQk4ODQJOTA3CTkyMAk5MjUJOTM3CTkzOAk5NDcJOTY3CTk4NgkxMDAyCTEwMDcJ
MTAyMwkxMDM4CTEwNDkJMTA1NQkxMDU4CTEwNTkJMTA2NAkxMDY3CTEwNjkJMTA3MAkxMDc2
CTEwNzgJMTA4MAkxMDg5CTEwOTgJMTA5OQkxMTA0CTExMDcJMTExMQkxMTEzCTExMjkJMTEz
NwkxMTM5CTExNDcJMTE0OQkxMTUwCTExNTkJMTE3MQkxMTc1CTExODEJMTE4MwkxMTg0CTEx
OTcJMTIwNgkxMjE2CTEyMjIJMTIyNQkxMjI4CTEyMzEJMTI0MgkxMjU1CTEyNjAJMTI2Mgkx
MjY1CTEyNjcJMTI3MAkxMjczCTEyODMJMTI4NAkxMjg2CTEyOTEJMTI5OAkxMzA2CTEzMTQJ
MTMxNQkxMzE2CTEzMTgJMTMyMQkxMzI1LgkxMzM1CTEzMzYJMTMzOQkxMzQ3CTEzNTIJMTM1
NAkxMzY3CTEzNjkJMTM3NAkxMzgxCTEzODYJMTM5MgkxMzk0CTEzOTcJMTQwMAkxNDA0CTE0
MDUuCTE0MDgJMTQxMAkxNDE1CTE0MTkuCTE0MjEJMTQyMgkxNDI0CTE0MjUJMTQzMQkxNDM1
CTE0MzcJMTQzOQkxNDQ2CTE0NDgJMTQ0OQkxNDUzLgkxNDU0CTE0NTgJMTQ2MgkxNDY2CTE0
NjkJMTQ3MAkxNDcxCTE0NzgJMTQ4MgkxNDg0CTE0ODYJMTQ4OAkxNDkwCTE0OTIJMTUwMAkx
NTAxCTE1MDkJMTUxMgkxNTIxCTE1MzAJMTUzMQkxNTM3LgkxNTQxCTE1NDguCTE1NDkJMTU1
MQkxNTUyCTE1NTMJMTU1NwkxNTYyCTE1NjUJMTU2Ni4JMTU2NwkxNTcxCTE1NzMJMTU3NS4J
MTU3NwkxNTc5CTE1ODAuLgkxNTgzCTE1ODUJMTU4Ni4JMTU4OAkxNTkzCTE1OTQJMTU5NQkx
NjA1CTE2MDgJMTYxMQkxNjE1CTE2MTkuCTE2MjAJMTYyMS4uLgkxNjIyCTE2MjMJMTYyNi4J
MTYyNy4uCTE2MzEuCTE2MzMuCTE2MzUuCTE2MzYuLgkxNjM4CTE2NDEuCTE2NDQJMTY0OQkx
NjUzCTE2NTUJMTY1NwkxNjU4CTE2NTkuCTE2NjAuCTE2NjIJMTY2MwkxNjY3CTE2NzAJMTY3
MQkxNjc0CTE2NzUJMTY4MAkxNjgyCTE2ODUJMTY4NgkxNjg5CTE2OTIJMTY5MwkxNjk2CTE2
OTgJMTcwMAkxNzAxCTE3MDMJMTcxMC4JMTcxNAkxNzE3CTE3MjIJMTcyNQkxNzMyCTE3MzkJ
MTc0NwkxNzUwCTE3NjIJMTc2NwkxNzc2CTE3ODEJMTc5MwkxODAyCTE4MTIJMTgyMwkxODI2
CTE4MzUJMTgzNwkxODQzCTE4NTUJMTg1OQkxODY1CTE4NzMJMTg3OQkxODgzCTE4OTEJMTg5
NgkxODk4CTE5MDQJMTkxNgkxOTIzCTE5MzIJMTkzNAkxOTQxCTE5NDgJMTk1MgkxOTU2CTE5
NTkJMTk2NgkxOTcyCTE5NzkJMTk4OS4JMTk5MAkyMDAwCTIwMDIJMjAxMgkyMDE0CTIwMTYJ
MjAxOQkyMDIxCTIwMjIJMjAyOAkyMDMyLi4JMjAzNgkyMDM4LgkyMDM5CTIwNDAJMjA0MS4J
MjA0MgkyMDQzCTIwNDQJMjA0OAkyMDQ5LgkyMDUxLgkyMDUyLgkyMDU0CTIwNTUuLi4JMjA1
NgkyMDU4CTIwNjAJMjA2MgkyMDY1CTIwNzUJMjA4MAkyMDgzCTIwODkJMjA5MQkyMDk0CTIx
MDIuCTIxMDYJMjEwOQkyMTE0CTIxMTcJMjEyOAkyMTM0CTIxMzgJMjEzOQkyMTQ1CTIxNDkJ
MjE1NwkyMTYxCTIxNjMJMjE2OQkyMTc4CTIxOTAJMjE5MQkyMTkyCTIyMDUJMjIwOQkyMjE2
CTIyMjYJMjIzMAkyMjM0CTIyMzkuCTIyNTYJMjI2MC4JMjI2NQkyMjcyCTIyNzgJMjI4NQky
Mjg5CTIyOTEJMjI5OQkyMzAwLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4JMjMwMS4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLgky
MzAyLgkyMzAzLi4uCTIzMDQJMjMwNS4JMjMwNi4uCTIzMDcJMjMwOS4JMjMxMC4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLgkyMzEx
Li4uCTIzMTIuLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uG1sxOzM1bWFkZF90b19y
dW5fcXVldWUgMzEzG1swbQouLi4JMjMxMwkyMzE0LgkyMzE1LgkyMzE2Li4uCTIzMTcuCTIz
MTgJMjMyMC4uLi4uLi4uCTIzMjIJMjMyNAkyMzI2LgkyMzI3LgkyMzI5LgkyMzMwCTIzMzEu
CTIzMzQJMjMzNgkyMzM4CTIzNDAJMjM0MgkyMzQ1CTIzNDkuLi4JMjM1MC4JMjM1Mi4JMjM1
NAkyMzU2Li4JMjM1OC4JMjM2Mi4JMjM2MwkyMzY0CTIzNjUJMjM2Ni4uCTIzNjcuLgkyMzY4
CTIzNjkJMjM3MAkyMzcxLi4uCTIzNzUuLgkyMzc3LgkyMzc4CTIzNzkJMjM4MAkyMzgxCTIz
ODIJMjM4MwkyMzg0Li4JMjM4Ni4uCTIzODcuCTIzODguCTIzODkuLi4uLi4uLi4uLi4uLi4u
CTIzOTAuLi4uLi4uLi4uLgkyMzkxCTIzOTIuLi4uLgkyMzkzLgkyMzk0Li4uLi4uLi4JMjM5
NS4JMjM5Ni4uLgkyMzk3CTIzOTkuLgkyNDAwCTI0MDEJMjQwMi4uLi4JMjQwNAkyNDA4CTI0
MTAJMjQxNAkyNDE4CTI0MjAuLi4uLi4JMjQzNQkyNDQwCTI0NDIuLi4uCTI0NDMuLi4uLgky
NDQ1Li4uCTI0NDYJMjQ0NwkyNDQ4Li4uLi4uCTI0NTEJMjQ1NAkyNDU1LgkyNDU2CTI0NTcu
LgkyNDYwCTI0NjMuLgkyNDY2CTI0NjcJMjQ3Mi4uCTI0NzcuCTI0ODAuCTI0ODIuCTI0ODQJ
MjQ4NQkyNDg3LgkyNDg4Li4uCTI0ODkJMjQ5MAkyNDkzLi4uCTI0OTQuLi4uLgkyNDk1Li4J
MjQ5OAkyNDk5Li4JMjUwMC4JMjUwMS4JMjUwMgkyNTAzLi4uLi4uLgkyNTA1Li4uLi4uLi4u
LgkyNTA3Li4JMjUwOAkyNTA5LgkyNTEwLi4uLgkyNTExLgkyNTEyLgkyNTEzCTI1MTQuCTI1
MTUuLi4uCTI1MTYuCTI1MTcuLi4uLgkyNTE4Li4uLgkyNTE5CTI1MjAuLgkyNTIxLgkyNTIy
Li4uCTI1MjMuCTI1MjQuCTI1MjUuLi4JMjUyNgkyNTI3Li4uLi4uLgkyNTI4LgkyNTI5Li4J
MjUzMC4uLi4uLi4uLi4uCTI1MzEJMjUzMi4uLgkyNTMzLi4uCTI1MzQuLi4uCTI1MzUuCTI1
MzYuCTI1MzcuLi4JMjUzOC4uLi4JMjUzOQkyNTQwLi4JMjU0MS4uLgkyNTQyLi4uLi4uLi4J
MjU0MwkyNTQ0CTI1NDUuLgkyNTQ2Li4uLi4uLi4uLi4uLi4uLi4JMjU0Ny4JMjU0OC4uLgky
NTQ5Li4JMjU1MAkyNTUxLi4uCTI1NTIuLi4uCTI1NTMuLi4uLi4uLgkyNTU1Li4uLi4uLi4J
MjU1Ni4uLi4uLi4uLi4uLi4uLi4uLi4uCTI1NTcJMjU1OC4uLgkyNTU5CTI1NjAuCTI1NjEu
LgkyNTYyLgkyNTYzCTI1NjQuLi4uLi4JMjU2NwkyNTY5Li4JMjU3MC4uCTI1NzEuLgkyNTcz
LgkyNTc0Li4uCTI1NzUuLi4uCTI1NzYJMjU3NwkyNTc4CTI1NzkuCTI1ODEuLgkyNTgyLi4J
MjU4My4uLi4uCTI1ODQuCTI1ODUJMjU4Ni4uLi4uLgkyNTg3CTI1ODguLi4uLi4uLi4uLi4u
CTI1ODkuLgkyNTkwLi4uLi4uLi4JMjU5MQkyNTkyLgkyNTkzCTI1OTQJMjU5NS4uCTI1OTYJ
MjU5Ny4JMjU5OAkyNTk5CTI2MDAJMjYwMS4JMjYwMgkyNjAzCTI2MDUJMjYwNi4JMjYwOQky
NjEwLgkyNjExCTI2MTIJMjYxNC4uCTI2MTUuCTI2MTYuCTI2MTgJMjYyMAkyNjIyLgkyNjI2
IFNVQ0NFU1MKCmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2bS94ODZfNjQtcmFu
ZGNvbmZpZy1jMDMtMDYxMS9saW51eC1kZXZlbDpkZXZlbC1jYWlyby14ODZfNjQtMjAxMzA2
MTExOTEwOmU4YTM2YTZhZGEyMDk4ZTUzZTEzZTdjNGYyOGYzZDA4NTc3MzhkZjQ6YmlzZWN0
LXVzYgogVEVTVCBGQUlMVVJFCi9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctYzAzLTA2MTEv
ZThhMzZhNmFkYTIwOThlNTNlMTNlN2M0ZjI4ZjNkMDg1NzczOGRmNC9kbWVzZy1rdm0tYmVu
cy03NzEyLTIwMTMwNjEyMTg1NzE4LTMuMTAuMC1yYzUtMDA2NTItZ2U4YTM2YTYtOQova2Vy
bmVsL3g4Nl82NC1yYW5kY29uZmlnLWMwMy0wNjExL2U4YTM2YTZhZGEyMDk4ZTUzZTEzZTdj
NGYyOGYzZDA4NTc3MzhkZjQvZG1lc2cta3ZtLXZwLTI2NzI5LTIwMTMwNjExMTk0ODI4LTMu
MTAuMC1yYzUtMDA2NTItZ2U4YTM2YTYtOQoKW2RldGFjaGVkIEhFQUQgMzQwYzBmNF0gUmV2
ZXJ0ICJuZXRsaW5rOiBhbGxvdyBsYXJnZSBkYXRhIHRyYW5zZmVycyBmcm9tIHVzZXItc3Bh
Y2UiCiAxIGZpbGUgY2hhbmdlZCwgMiBpbnNlcnRpb25zKCspLCAzNSBkZWxldGlvbnMoLSkK
bHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1yYW5kY29uZmlnLWMw
My0wNjExL2xpbnV4LWRldmVsOmRldmVsLWNhaXJvLXg4Nl82NC0yMDEzMDYxMTE5MTA6MzQw
YzBmNDJjMWVmOTcwZTdjZGQ2YzVhNzM1MWY0NTc5MmZhYzhlMTpiaXNlY3QtdXNiCgoyMDEz
LTA2LTE0LTAzOjQzOjAyIDM0MGMwZjQyYzFlZjk3MGU3Y2RkNmM1YTczNTFmNDU3OTJmYWM4
ZTEgY29tcGlsaW5nCgoyMDEzLTA2LTE0LTAzOjQ3OjQzIGRldGVjdGluZyBib290IHN0YXRl
IDMuMTAuMC1yYzUtMDA2NTMtZzM0MGMwZjQuLgkyLgk1CTgJMTAJMTEuLgkxMgkxNy4JMjAu
CTI3CTI5CTMxCTMyCTM1CTM4CTM5Lgk0Mgk0Ngk0Ny4JNDgJNTIuCTUzLgk1NQk1Ni4uLi4J
NTcuLi4JNTkuLi4JNjAuCTYyCTYzCTY0Li4JNjUJNjYJNjcuLgk2OAk3Mi4JNzMJNzQJNzgJ
ODAJODMJODUJODYJOTAJOTEJOTMuLgk5NC4JOTUJOTYJOTgJOTkJMTAwCTEwMi4JMTA2Li4u
LgkxMDguCTExMAkxMTEJMTE0CTExNQkxMTgJMTE5LgkxMjAJMTIyLgkxMjMJMTI1CTEyNwkx
MjkJMTMwLi4uCTEzMi4JMTMzCTEzNAkxMzUJMTQxCTE0MgkxNDcJMTQ4CTE1MQkxNTIJMTU0
CTE1NgkxNTkJMTY0Li4JMTY1CTE2NwkxNjguCTE3MC4uCTE3MgkxNzYuLi4JMTc4CTE4MS4J
MTgyLgkxODMuCTE4NAkxODUuLi4uCTE4NgkxOTAuLgkxOTEJMTkyLgkxOTMJMTk1LgkxOTYJ
MTk3CTIwMAkyMDEJMjAyLgkyMDQJMjA1CTIwNwkyMDgJMjEwCTIxMS4uLgkyMTIuCTIxMy4J
MjE3CTIxOS4JMjIyCTIyNgkyMjgJMjI5CTIzMAkyMzEuCTIzMi4JMjM0LgkyMzUuLgkyMzYJ
MjM3LgkyMzguLgkyMzkuLgkyNDAuLi4uLi4JMjQxLi4uCTI0MwkyNDUuLgkyNDYuLgkyNDcJ
MjQ4CTI1MAkyNTIuLgkyNTQJMjU1LgkyNTYuLgkyNTkuLgkyNjAuLi4uLi4uLgkyNjIuCTI2
NC4uCTI2NwkyNjgJMjY5CTI3MAkyNzEuCTI3My4uCTI3NC4uCTI3OAkyNzkJMjgxCTI4My4J
Mjg0CTI4NwkyODguCTI4OQkyOTAJMjkyCTI5My4uCTI5NAkyOTUJMjk2CTI5Ny4uLgkzMDAJ
MzAxLi4JMzA1CTMwNgkzMDcJMzA5Li4uCTMxMC4uLi4uLi4JMzExCTMxMi4JMzEzLgkzMTQJ
MzE1Li4uLgkzMTcJMzE4CTMxOQkzMjAJMzIxCTMyMi4uCTMyMy4JMzI2CTMyNy4uLi4uLgkz
MjkJMzMwCTMzMQkzMzQuCTMzOQkzNDEuLgkzNDIuCTM0My4uCTM0NgkzNDcJMzQ4LgkzNTAJ
MzUxCTM1Mi4JMzUzLi4uLgkzNTQuLgkzNTUuLgkzNTYuCTM1Ny4uLi4uCTM1OQkzNjEuLi4J
MzYzCTM2NC4JMzY2Li4JMzY4CTM2OS4JMzcwLgkzNzIuLi4uCTM3My4uLi4uCTM3NC4uLi4u
LgkzNzUuLi4uLgkzNzguCTM3OS4uLgkzODAuCTM4MS4uLgkzODIJMzgzCTM4NC4JMzg4Lgkz
OTIJMzk0Li4uCTM5NS4uLi4JMzk4LgkzOTkJNDAwCTQwMQk0MDcJNDA4Li4uCTQwOQk0MTIJ
NDEzCTQxNAk0MTUuCTQxNwk0MTguCTQyMC4JNDIxCTQyMwk0MjQuLi4JNDI1Li4uLi4uLi4u
CTQyNy4JNDI4Lgk0MjkJNDMxLi4JNDMyLgk0MzMuLi4uLi4uLi4JNDM1Li4uLi4JNDM3Li4J
NDM4Lgk0MzkuLgk0NDAuLgk0NDEJNDQyCTQ0NAk0NDUJNDQ2Lgk0NDgJNDUxCTQ1Ngk0NTgJ
NDU5Lgk0NjQJNDY2Lgk0NzAJNDczCTQ3NQk0NzcJNDc5CTQ4NAk0ODUJNDg4Lgk0ODkuCTQ5
MQk0OTYJNDk5CTUwMQk1MDQuCTUwNQk1MDcJNTA4CTUxMAk1MTIJNTE3CTUyMAk1MjUJNTI2
CTUyOQk1MzgJNTQ3CTU1Mgk1NTMJNTU2CTU1Nwk1NjAuCTU2Mwk1NjYJNTY4CTU3MAk1NzEJ
NTc1CTU3OAk1ODIJNTgzCTU4OAk1OTAJNTkzCTU5NQk1OTYJNTk5CTYwMS4JNjA0CTYwOAk2
MTEJNjE1CTYxOC4JNjIxCTYyNQk2MjcuCTYyOQk2MzYJNjM5CTY0OAk2NTYJNjU5CTY2Mgk2
NjMJNjY0CTY2NS4JNjY2Lgk2NzYJNjc4Lgk2ODEJNjg2CTY5Mgk2OTYJNjk3CTcwMAk3MDgu
CTcwOQk3MTkJNzI0CTcyOAk3MjkJNzMxCTczOAk3MzkJNzQ0CTc0NQk3NTIJNzU3CTc1OQk3
NjMJNzY2CTc2OAk3NjkuCTc3NAk3NzUJNzc4CTc3OQk3ODAJNzgxCTc4NQk3ODkuLgk3OTMJ
Nzk4CTgwNgk4MTIJODE0Lgk4MTkJODIyCTgyOAk4MjkuCTgzMwk4MzcJODQyCTg0NAk4NDgJ
ODUwCTg1MQk4NTMJODU4CTg2Mgk4NjcJODc0CTg3NS4JODc4CTg4MQk4ODMuCTg4Nwk4OTEJ
ODkyCTg5My4JODk1CTg5Ngk4OTkJOTAyCTkwNAk5MDcJOTA5CTkxMgk5MTkJOTI1CTkyOQk5
MzIJOTM1CTkzOQk5NDAJOTQyCTk0NAk5NDUJOTQ4CTk1NQk5NjkJOTczLgk5NzYJOTgwCTk4
Mgk5ODMJOTg2CTk4OAk5OTcJMTAwMS4uCTEwMTAJMTAxMQkxMDE0CTEwMTgJMTAyMAkxMDIy
CTEwMjUJMTAzMAkxMDM0CTEwMzcJMTA0MQkxMDQ1LgkxMDQ4CTEwNTAJMTA1MwkxMDY0CTEw
NzAJMTA3MQkxMDcyCTEwNzYJMTA3NwkxMDc5CTEwODAJMTA4OAkxMDk0CTEwOTUJMTEwMgkx
MTA2CTExMDkJMTExMwkxMTE0CTExMTUJMTExNwkxMTE5CTExMjAJMTEyMgkxMTMwCTExMzIJ
MTEzNgkxMTQxCTExNDMJMTE0NwkxMTQ5CTExNjAJMTE2NAkxMTY5CTExNzUJMTE4MQkxMTg4
CTExOTEJMTE5NAkxMTk4CTEyMDIuLgkxMjA1CTEyMDYuCTEyMDkJMTIxNC4JMTIxNgkxMjE4
CTEyMjEJMTIyNgkxMjI5CTEyMzIJMTIzMy4JMTIzNAkxMjM2CTEyMzkJMTI0MwkxMjQ4CTEy
NTEJMTI1NwkxMjU5CTEyNjYJMTI3NgkxMjgzCTEyOTMJMTI5NAkxMjk1CTEzMDMJMTMxNAkx
MzIyCTEzMzAJMTMzOQkxMzQ1CTEzNDgJMTM1NAkxMzY1CTEzNzAJMTM3NAkxMzc4CTEzODMJ
MTM4OQkxMzkzCTEzOTYJMTQwMAkxNDAyCTE0MDgJMTQxMwkxNDE2CTE0MTkJMTQyNQkxNDI3
CTE0MzIJMTQzOQkxNDQ2CTE0NTIJMTQ2MS4uCTE0NzQJMTQ3NgkxNDg0LgkxNDg2CTE0OTAJ
MTQ5Ny4JMTUwNAkxNTA5CTE1MTQJMTUxOAkxNTI0CTE1MjUJMTUyOAkxNTMwLgkxNTMxLgkx
NTM0CTE1MzUJMTUzNgkxNTM4LgkxNTM5CTE1NDAJMTU0NS4JMTU1MQkxNTUyCTE1NTkJMTU2
MS4JMTU2MwkxNTY2CTE1NzAJMTU3Mi4JMTU3MwkxNTgyCTE1OTAJMTU5My4JMTU5NAkxNTk5
CTE2MDQJMTYxMgkxNjE0CTE2MTYJMTYyMgkxNjIzLgkxNjI1CTE2MzAJMTYzMQkxNjMzCTE2
MzUJMTY0MQkxNjQ3CTE2NTgJMTY2MgkxNjYzCTE2NjQJMTY2NQkxNjY2CTE2NzAJMTY3Ngkx
NjgwCTE2ODMJMTY5Mi4JMTY5NAkxNzAxCTE3MDYJMTcxMgkxNzIyCTE3MjgJMTc0MQkxNzQz
CTE3NDgJMTc1OAkxNzY0CTE3NzAJMTc3NgkxNzc5CTE3OTEJMTc5MwkxNzk1CTE3OTgJMTgw
NQkxODA5CTE4MTQJMTgxNwkxODI0CTE4MjUJMTgyNy4JMTgzMy4JMTgzNQkxODM3CTE4MzgJ
MTg0OC4JMTg1MQkxODU1CTE4NTgJMTg1OQkxODY0CTE4NjYJMTg2OQkxODcyCTE4NzQJMTg4
MQkxODgzCTE4ODUJMTg4OAkxODk0CTE4OTcJMTg5OAkxOTAyCTE5MDMuCTE5MDYJMTkwOAkx
OTEwCTE5MTEJMTkxNAkxOTE2CTE5MjAJMTkyMy4JMTkyNAkxOTI4CTE5MzAJMTkzMQkxOTMz
CTE5MzYJMTkzOAkxOTQxLgkxOTQyCTE5NDMuCTE5NDUJMTk0Ny4uCTE5NDgJMTk1MS4uCTE5
NTIJMTk1MwkxOTU1CTE5NTYuCTE5NTcJMTk1OAkxOTYwLgkxOTYyCTE5NjQJMTk2NgkxOTY3
CTE5NjgJMTk2OQkxOTcwLgkxOTc2CTE5ODEJMTk4NQkxOTg2CTE5ODcJMTk5MS4JMTk5Mwkx
OTk1CTE5OTYuCTE5OTkJMjAwMi4JMjAwMwkyMDA4CTIwMTAuLgkyMDEzCTIwMTcJMjAxOAky
MDIwCTIwMjEJMjAyNAkyMDMwCTIwMzQJMjA0MQkyMDQ1CTIwNDguCTIwNTMJMjA1NwkyMDU5
CTIwNjMJMjA2NAkyMDY2CTIwNjgJMjA3NQkyMDc5CTIwODMJMjA4OQkyMDkzCTIwOTUJMjA5
OS4uCTIxMDcJMjExNQkyMTE2CTIxMjIJMjEyNi4JMjEyOQkyMTMyCTIxMzgJMjE0MAkyMTQy
CTIxNTEJMjE1MwkyMTYyCTIxNzAuCTIxNzIJMjE4MQkyMTgyCTIxODUJMjE5NQkyMjA0CTIy
MDUJMjIxNAkyMjIxCTIyMjQJMjIzNQkyMjM4CTIyNDAJMjI0MwkyMjQ1CTIyNDcJMjI1MAky
MjUyCTIyNTUJMjI2MgkyMjY3CTIyNzQJMjI4MQkyMjkxCTIyOTYJMjMwNwkyMzE0CTIzMjcJ
MjMzMQkyMzMzCTIzMzgJMjM0MwkyMzQ2CTIzNTAJMjM1MgkyMzU1Li4JMjM2MAkyMzYyCTIz
NjcJMjM3MAkyMzc0CTIzNzUJMjM3NwkyMzgxCTIzODUuCTIzOTIJMjQwMAkyNDA0CTI0MDYJ
MjQxMgkyNDE1CTI0MjIJMjQyOQkyNDMwCTI0MzYJMjQ0NgkyNDQ5CTI0NTEJMjQ1NwkyNDYy
CTI0ODQJMjQ4NgkyNDk0CTI1MDUJMjUxOAkyNTI3CTI1MzcJMjUzOQkyNTU1CTI1NjUJMjU4
MwkyNTkwCTI1OTcJMjYwOAkyNjIyLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
LgkyNjIzLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLhtbMTszNW1hZGRfdG9fcnVu
X3F1ZXVlIDIbWzBtCi4uLgkyNjI0Li4uLi4JMjYyNSBTVUNDRVNTCgoKPT09PT09PT09IHVw
c3RyZWFtID09PT09PT09PQpGZXRjaGluZyBsaW51cwpscyAtYSAva2VybmVsLXRlc3RzL3J1
bi1xdWV1ZS9rdm0veDg2XzY0LXJhbmRjb25maWctYzAzLTA2MTEvbGludXgtZGV2ZWw6ZGV2
ZWwtY2Fpcm8teDg2XzY0LTIwMTMwNjExMTkxMDphMjY0OGViYjdlZDY5ZWYyMDlkOWM4YTc2
ZmFkZWIzMjUyZDlhMDIzOmJpc2VjdC11c2IKCjIwMTMtMDYtMTQtMTY6Mzc6MzAgYTI2NDhl
YmI3ZWQ2OWVmMjA5ZDljOGE3NmZhZGViMzI1MmQ5YTAyMyBjb21waWxpbmcKCjIwMTMtMDYt
MTQtMTY6NDI6MjMgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgMy4xMC4wLXJjNS0wMDIxOS1nYTI2
NDhlYi4uLgkyLi4JNAk4CTkuLi4uCTEwCTExLgkxMwkxNS4JMTkuCTIxCTI0CTI3Li4JMzAJ
MzUuCTQwCTQyCTQ0CTQ3CTUwCTUzCTU1CTU4CTYwLgk2MQk2NAk2OQk3Mgk3My4JNzcJODQJ
ODUJODgJOTkJMTA1CTExMgkxMTQuCTExNQkxMTcJMTI2LgkxMzEJMTM0CTEzNgkxMzguCTE0
MAkxNDcJMTUwCTE1Mi4JMTUzCTE1Ny4uCTE1OQkxNjMuCTE2NQkxNjYJMTczCTE5MwkxOTYJ
MjAwCTIwNQkyMTAJMjE4CTIyMgkyMjMJMjI5CTIzNgkyMzguCTI0MAkyNDQJMjUwCTI2MQky
NjgJMjcwCTI3MgkyNzkJMjg0CTI4NQkyODYJMjk4CTMwMQkzMDkJMzE5CTMyNAkzMjgJMzM0
CTMzNQkzMzYJMzQ0CTM0OAkzNTAJMzUyCTM1NgkzNTcJMzYxCTM2MgkzNzAJMzczCTM3OAkz
ODAJMzgzCTM5NAkzOTUJMzk4CTQwMAk0MDYJNDE2Lgk0MjUJNDI4CTQ0MQk0NDUJNDU0CTQ2
NQk0NzEJNDc3CTQ3OQk0ODkJNDkwCTQ5OAk1MTcuCTUyMQk1MjgJNTM1CTU0Mwk1NDUJNTYy
CTU2NQk1NzIJNTgxCTU4OQk1OTcJNjA5CTYxNAk2MjUJNjM1CTYzOQk2NTUJNjU4CTY2Mwk2
NzAJNjc5CTY5MQk3MDUJNzEzCTcxOAk3MzgJNzU0CTc1NQk3NjEJNzY5CTc3Nwk3ODMJNzk1
CTgwMgk4MTAJODIwCTgyNAk4MzIJODM5CTg0NQk4NjAJODY5CTg3Ngk4ODMJOTA4CTkxMQk5
MjMJOTUxCTk2Mgk5NjYJOTY5CTk4NAk5ODgJMTAwMAkxMDE1CTEwMTgJMTAzNQkxMDU1CTEw
NTkJMTA2MwkxMDkwCTEwOTQJMTEwNAkxMTMzCTExNDAJMTE0OQkxMTg2CTEyMDIJMTIyMQkx
MjQ2CTEyNjYJMTI4NwkxMzIyCTEzNTEJMTM3MQkxMzkyCTE0MTAJMTQzNAkxNDU3CTE0NzQJ
MTUwMgkxNTIxCTE1NTAJMTU3OQkxNTk5CTE2MTkJMTY0NAkxNjY1CTE2ODAJMTY5NAkxNzA3
CTE3MjMJMTczNgkxNzQ1CTE3NTcJMTc2MQkxNzcxCTE3ODYJMTc5NwkxODExCTE4MTgJMTgy
MwkxODMyCTE4MzMuLi4uLi4uLi4uLi4uLi4uLi4uLgkxODM0Li4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLhtbMTszNW1hZGRfdG9fcnVuX3F1ZXVlIDc5MRtbMG0KLi4JMTgzNwkx
ODQ0CTE4NTgJMTg2MAkxODY4CTE4ODAJMTkwMwkxOTA1CTE5MTAJMTkyNQkxOTUxCTE5NjMJ
MTk2OAkxOTc4CTE5ODcJMjAwNgkyMDE5CTIwMjQJMjAzMQkyMDQ1CTIwNTYJMjA1OAkyMDYw
CTIwNzIJMjA3NwkyMDkwCTIxMDIJMjEwNgkyMTI2CTIxNDIJMjE0NwkyMTQ5CTIxNjgJMjE4
NAkyMTk5CTIyMTYJMjIyMgkyMjcwCTIzMDkJMjMyMQkyMzU2CTIzOTUJMjQ0NgkyNDg0CTI1
MzcJMjU3OQkyNjE3CTI2MjMuLi4uCTI2MjQuLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uG1sxOzM1bWFkZF90b19ydW5fcXVldWUgMRtbMG0KLi4JMjYyNSBTVUNDRVNTCgoKPT09
PT09PT09IGxpbnV4LW5leHQgPT09PT09PT09CkZldGNoaW5nIG5leHQKbHMgLWEgL2tlcm5l
bC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1yYW5kY29uZmlnLWMwMy0wNjExL2xpbnV4
LWRldmVsOmRldmVsLWNhaXJvLXg4Nl82NC0yMDEzMDYxMTE5MTA6YzA0ZWZlZDczNDQwOWY1
YTQ0NzE1YjU0YTZjYTFiNTRiMGNjZjIxNTpiaXNlY3QtdXNiCgoyMDEzLTA2LTE1LTAwOjI3
OjQ0IGMwNGVmZWQ3MzQ0MDlmNWE0NDcxNWI1NGE2Y2ExYjU0YjBjY2YyMTUgY29tcGlsaW5n
CgoyMDEzLTA2LTE1LTAwOjQwOjI4IGRldGVjdGluZyBib290IHN0YXRlIDMuMTAuMC1yYzQt
bmV4dC0yMDEzMDYwNy0wNTAwMS1nYzA0ZWZlZC4uCTQJOAk5CTExCTE3CTIwCTI5CTMyCTM3
CTQxCTU1CTk0CTExMAkxMjcJMTQ2CTE2NAkxOTIJMjAzCTIxOQkyMjMJMjI3CTI0MAkyNDgJ
MjkwCTMyNQkzMjgJMzM4CTM2NwkzOTgJNDA3CTQyNgk0MjkJNDcwCTUwMAk1MTIJNTIyCTUy
OQk1NTEJNTc4CTYyMAk2NTEJNjg2CTc0NAk3OTYJODIzCTg5MAk5NjEJMTAxOAkxMDcxCTEw
OTgJMTE3NwkxMjIyCTEyNzEJMTMxOAkxMzY4CTE0MTQJMTQ4MAkxNTQ0CTE1OTIJMTY0Mgkx
Njk5CTE3NTgJMTc5OQkxODU1CTE5MDAJMTk0MwkxOTk5CTIwNzAJMjExNAkyMTkxCTIyNTEJ
MjMyNQkyNDAxCTI0ODYJMjUzNwkyNjA1CTI2MTgJMjYyMC4JMjYyMS4uLi4JMjYyMi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4bWzE7MzVtYWRkX3RvX3J1bl9xdWV1ZSAzG1sw
bQouLgkyNjIzCTI2MjUgU1VDQ0VTUwoK

--n8g4imXOkfNTN/H1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=".config-bisect"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 3.10.0-rc5 Kernel Configuration
#
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_MMU=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_ARCH_HAS_CPU_AUTOPROBE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_CONSTRUCTORS=y
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
CONFIG_BROKEN_ON_SMP=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
# CONFIG_KERNEL_GZIP is not set
# CONFIG_KERNEL_BZIP2 is not set
CONFIG_KERNEL_LZMA=y
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_POSIX_MQUEUE=y
CONFIG_POSIX_MQUEUE_SYSCTL=y
# CONFIG_FHANDLE is not set
CONFIG_AUDIT=y
CONFIG_AUDITSYSCALL=y
CONFIG_AUDIT_WATCH=y
CONFIG_AUDIT_TREE=y
# CONFIG_AUDIT_LOGINUID_IMMUTABLE is not set
CONFIG_HAVE_GENERIC_HARDIRQS=y

#
# IRQ subsystem
#
CONFIG_GENERIC_HARDIRQS=y
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_IRQ_DOMAIN=y
# CONFIG_IRQ_DOMAIN_DEBUG is not set
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ_COMMON=y
# CONFIG_HZ_PERIODIC is not set
CONFIG_NO_HZ_IDLE=y
# CONFIG_NO_HZ is not set
CONFIG_HIGH_RES_TIMERS=y

#
# CPU/Task time and stats accounting
#
# CONFIG_TICK_CPU_ACCOUNTING is not set
# CONFIG_VIRT_CPU_ACCOUNTING_GEN is not set
CONFIG_IRQ_TIME_ACCOUNTING=y
# CONFIG_BSD_PROCESS_ACCT is not set
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
CONFIG_TASK_XACCT=y
# CONFIG_TASK_IO_ACCOUNTING is not set

#
# RCU Subsystem
#
CONFIG_TINY_RCU=y
# CONFIG_PREEMPT_RCU is not set
# CONFIG_RCU_STALL_COMMON is not set
# CONFIG_TREE_RCU_TRACE is not set
CONFIG_IKCONFIG=y
# CONFIG_IKCONFIG_PROC is not set
CONFIG_LOG_BUF_SHIFT=17
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANTS_PROT_NUMA_PROT_NONE=y
CONFIG_CGROUPS=y
CONFIG_CGROUP_DEBUG=y
CONFIG_CGROUP_FREEZER=y
CONFIG_CGROUP_DEVICE=y
# CONFIG_CPUSETS is not set
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_RESOURCE_COUNTERS=y
CONFIG_MEMCG=y
# CONFIG_MEMCG_SWAP is not set
# CONFIG_MEMCG_KMEM is not set
# CONFIG_CGROUP_HUGETLB is not set
# CONFIG_CGROUP_PERF is not set
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_CFS_BANDWIDTH=y
CONFIG_RT_GROUP_SCHED=y
# CONFIG_BLK_CGROUP is not set
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_NAMESPACES=y
# CONFIG_UTS_NS is not set
CONFIG_IPC_NS=y
CONFIG_PID_NS=y
# CONFIG_NET_NS is not set
CONFIG_SCHED_AUTOGROUP=y
CONFIG_MM_OWNER=y
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HOTPLUG=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
# CONFIG_EXPERT is not set
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_KALLSYMS=y
# CONFIG_KALLSYMS_ALL is not set
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_PCI_QUIRKS=y
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_SLUB_DEBUG=y
CONFIG_COMPAT_BRK=y
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_PROFILING is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_JUMP_LABEL is not set
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_MODULES_USE_ELF_RELA=y

#
# GCOV-based kernel profiling
#
CONFIG_GCOV_KERNEL=y
# CONFIG_GCOV_PROFILE_ALL is not set
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
# CONFIG_MODULES is not set
CONFIG_BLOCK=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
# CONFIG_BLK_DEV_INTEGRITY is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
CONFIG_ACORN_PARTITION=y
# CONFIG_ACORN_PARTITION_CUMANA is not set
# CONFIG_ACORN_PARTITION_EESOX is not set
CONFIG_ACORN_PARTITION_ICS=y
# CONFIG_ACORN_PARTITION_ADFS is not set
CONFIG_ACORN_PARTITION_POWERTEC=y
# CONFIG_ACORN_PARTITION_RISCIX is not set
# CONFIG_OSF_PARTITION is not set
# CONFIG_AMIGA_PARTITION is not set
CONFIG_ATARI_PARTITION=y
# CONFIG_MAC_PARTITION is not set
CONFIG_MSDOS_PARTITION=y
CONFIG_BSD_DISKLABEL=y
# CONFIG_MINIX_SUBPARTITION is not set
CONFIG_SOLARIS_X86_PARTITION=y
# CONFIG_UNIXWARE_DISKLABEL is not set
CONFIG_LDM_PARTITION=y
CONFIG_LDM_DEBUG=y
# CONFIG_SGI_PARTITION is not set
# CONFIG_ULTRIX_PARTITION is not set
# CONFIG_SUN_PARTITION is not set
# CONFIG_KARMA_PARTITION is not set
CONFIG_EFI_PARTITION=y
# CONFIG_SYSV68_PARTITION is not set

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
# CONFIG_DEFAULT_DEADLINE is not set
# CONFIG_DEFAULT_CFQ is not set
CONFIG_DEFAULT_NOOP=y
CONFIG_DEFAULT_IOSCHED="noop"
CONFIG_PREEMPT_NOTIFIERS=y
CONFIG_ASN1=y
CONFIG_INLINE_SPIN_UNLOCK_IRQ=y
CONFIG_INLINE_READ_UNLOCK=y
CONFIG_INLINE_READ_UNLOCK_IRQ=y
CONFIG_INLINE_WRITE_UNLOCK=y
CONFIG_INLINE_WRITE_UNLOCK_IRQ=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
# CONFIG_SMP is not set
# CONFIG_X86_MPPARSE is not set
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_INTEL_LPSS is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_XEN is not set
# CONFIG_XEN_PRIVILEGED_GUEST is not set
CONFIG_KVM_GUEST=y
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
CONFIG_MEMTEST=y
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_GENERIC_CPU=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_DMI=y
CONFIG_GART_IOMMU=y
# CONFIG_CALGARY_IOMMU is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_NR_CPUS=1
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
CONFIG_X86_MCE=y
# CONFIG_X86_MCE_INTEL is not set
# CONFIG_X86_MCE_AMD is not set
# CONFIG_X86_MCE_INJECT is not set
# CONFIG_I8K is not set
# CONFIG_MICROCODE is not set
CONFIG_X86_MSR=y
# CONFIG_X86_CPUID is not set
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_DIRECT_GBPAGES=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_MEMORY_PROBE=y
CONFIG_ARCH_PROC_KCORE_TEXT=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
# CONFIG_SPARSEMEM_VMEMMAP is not set
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
# CONFIG_MEMORY_HOTREMOVE is not set
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_MEMORY_FAILURE is not set
CONFIG_TRANSPARENT_HUGEPAGE=y
CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
# CONFIG_TRANSPARENT_HUGEPAGE_MADVISE is not set
CONFIG_CROSS_MEMORY_ATTACH=y
CONFIG_NEED_PER_CPU_KM=y
CONFIG_CLEANCACHE=y
# CONFIG_FRONTSWAP is not set
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
# CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
# CONFIG_MTRR_SANITIZER is not set
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
CONFIG_X86_SMAP=y
# CONFIG_EFI is not set
# CONFIG_SECCOMP is not set
# CONFIG_CC_STACKPROTECTOR is not set
CONFIG_HZ_100=y
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=100
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
CONFIG_CRASH_DUMP=y
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
CONFIG_PHYSICAL_ALIGN=0x1000000
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y

#
# Power management and ACPI options
#
# CONFIG_SUSPEND is not set
# CONFIG_HIBERNATION is not set
# CONFIG_PM_RUNTIME is not set
CONFIG_ACPI=y
# CONFIG_ACPI_PROCFS is not set
# CONFIG_ACPI_PROCFS_POWER is not set
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_PROC_EVENT=y
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_I2C=y
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_IPMI is not set
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
CONFIG_ACPI_BLACKLIST_YEAR=0
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
# CONFIG_ACPI_CONTAINER is not set
# CONFIG_ACPI_HOTPLUG_MEMORY is not set
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_APEI is not set
CONFIG_SFI=y

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_TABLE=y
CONFIG_CPU_FREQ_GOV_COMMON=y
CONFIG_CPU_FREQ_STAT=y
CONFIG_CPU_FREQ_STAT_DETAILS=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
# CONFIG_CPU_FREQ_GOV_POWERSAVE is not set
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_GOV_CONSERVATIVE is not set

#
# x86 CPU frequency scaling drivers
#
CONFIG_X86_INTEL_PSTATE=y
# CONFIG_X86_PCC_CPUFREQ is not set
# CONFIG_X86_ACPI_CPUFREQ is not set
# CONFIG_X86_SPEEDSTEP_CENTRINO is not set
# CONFIG_X86_P4_CLOCKMOD is not set

#
# shared options
#
# CONFIG_X86_SPEEDSTEP_LIB is not set
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_MULTIPLE_DRIVERS=y
CONFIG_CPU_IDLE_GOV_LADDER=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
# CONFIG_INTEL_IDLE is not set

#
# Memory power savings
#
CONFIG_I7300_IDLE_IOAT_CHANNEL=y
CONFIG_I7300_IDLE=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
# CONFIG_PCI_MMCONFIG is not set
CONFIG_PCI_DOMAINS=y
# CONFIG_PCIEPORTBUS is not set
CONFIG_ARCH_SUPPORTS_MSI=y
# CONFIG_PCI_MSI is not set
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
# CONFIG_PCI_STUB is not set
CONFIG_HT_IRQ=y
# CONFIG_PCI_IOV is not set
# CONFIG_PCI_PRI is not set
# CONFIG_PCI_PASID is not set
# CONFIG_PCI_IOAPIC is not set
CONFIG_PCI_LABEL=y
CONFIG_ISA_DMA_API=y
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
CONFIG_PCMCIA=y
# CONFIG_PCMCIA_LOAD_CIS is not set
CONFIG_CARDBUS=y

#
# PC-card bridges
#
# CONFIG_YENTA is not set
# CONFIG_PD6729 is not set
# CONFIG_I82092 is not set
# CONFIG_HOTPLUG_PCI is not set
# CONFIG_RAPIDIO is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=y
CONFIG_BINFMT_SCRIPT=y
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=y
CONFIG_COREDUMP=y
# CONFIG_IA32_EMULATION is not set
CONFIG_HAVE_TEXT_POKE_SMP=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_NET=y

#
# Networking options
#
# CONFIG_PACKET is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
# CONFIG_XFRM_USER is not set
# CONFIG_XFRM_SUB_POLICY is not set
# CONFIG_XFRM_MIGRATE is not set
# CONFIG_XFRM_STATISTICS is not set
CONFIG_XFRM_IPCOMP=y
CONFIG_NET_KEY=y
# CONFIG_NET_KEY_MIGRATE is not set
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
CONFIG_IP_ADVANCED_ROUTER=y
CONFIG_IP_FIB_TRIE_STATS=y
CONFIG_IP_MULTIPLE_TABLES=y
CONFIG_IP_ROUTE_MULTIPATH=y
CONFIG_IP_ROUTE_VERBOSE=y
CONFIG_IP_ROUTE_CLASSID=y
CONFIG_IP_PNP=y
# CONFIG_IP_PNP_DHCP is not set
# CONFIG_IP_PNP_BOOTP is not set
CONFIG_IP_PNP_RARP=y
# CONFIG_NET_IPIP is not set
CONFIG_NET_IPGRE_DEMUX=y
CONFIG_NET_IP_TUNNEL=y
# CONFIG_NET_IPGRE is not set
# CONFIG_IP_MROUTE is not set
# CONFIG_ARPD is not set
CONFIG_SYN_COOKIES=y
CONFIG_INET_AH=y
# CONFIG_INET_ESP is not set
CONFIG_INET_IPCOMP=y
CONFIG_INET_XFRM_TUNNEL=y
CONFIG_INET_TUNNEL=y
CONFIG_INET_XFRM_MODE_TRANSPORT=y
# CONFIG_INET_XFRM_MODE_TUNNEL is not set
CONFIG_INET_XFRM_MODE_BEET=y
CONFIG_INET_LRO=y
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
CONFIG_INET_UDP_DIAG=y
CONFIG_TCP_CONG_ADVANCED=y
CONFIG_TCP_CONG_BIC=y
CONFIG_TCP_CONG_CUBIC=y
# CONFIG_TCP_CONG_WESTWOOD is not set
CONFIG_TCP_CONG_HTCP=y
CONFIG_TCP_CONG_HSTCP=y
CONFIG_TCP_CONG_HYBLA=y
CONFIG_TCP_CONG_VEGAS=y
# CONFIG_TCP_CONG_SCALABLE is not set
# CONFIG_TCP_CONG_LP is not set
CONFIG_TCP_CONG_VENO=y
CONFIG_TCP_CONG_YEAH=y
CONFIG_TCP_CONG_ILLINOIS=y
CONFIG_DEFAULT_BIC=y
# CONFIG_DEFAULT_CUBIC is not set
# CONFIG_DEFAULT_HTCP is not set
# CONFIG_DEFAULT_HYBLA is not set
# CONFIG_DEFAULT_VEGAS is not set
# CONFIG_DEFAULT_VENO is not set
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG="bic"
# CONFIG_TCP_MD5SIG is not set
CONFIG_IPV6=y
CONFIG_IPV6_PRIVACY=y
# CONFIG_IPV6_ROUTER_PREF is not set
CONFIG_IPV6_OPTIMISTIC_DAD=y
CONFIG_INET6_AH=y
CONFIG_INET6_ESP=y
CONFIG_INET6_IPCOMP=y
CONFIG_IPV6_MIP6=y
CONFIG_INET6_XFRM_TUNNEL=y
CONFIG_INET6_TUNNEL=y
CONFIG_INET6_XFRM_MODE_TRANSPORT=y
# CONFIG_INET6_XFRM_MODE_TUNNEL is not set
CONFIG_INET6_XFRM_MODE_BEET=y
CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION=y
CONFIG_IPV6_SIT=y
# CONFIG_IPV6_SIT_6RD is not set
CONFIG_IPV6_NDISC_NODETYPE=y
CONFIG_IPV6_TUNNEL=y
CONFIG_IPV6_GRE=y
CONFIG_IPV6_MULTIPLE_TABLES=y
CONFIG_IPV6_SUBTREES=y
# CONFIG_IPV6_MROUTE is not set
# CONFIG_NETWORK_SECMARK is not set
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
CONFIG_NETFILTER=y
CONFIG_NETFILTER_DEBUG=y
# CONFIG_NETFILTER_ADVANCED is not set

#
# Core Netfilter Configuration
#
# CONFIG_NETFILTER_NETLINK_LOG is not set
# CONFIG_NF_CONNTRACK is not set
CONFIG_NETFILTER_XTABLES=y

#
# Xtables combined modules
#
CONFIG_NETFILTER_XT_MARK=y

#
# Xtables targets
#
CONFIG_NETFILTER_XT_TARGET_LOG=y
# CONFIG_NETFILTER_XT_TARGET_NFLOG is not set
CONFIG_NETFILTER_XT_TARGET_TCPMSS=y

#
# Xtables matches
#
# CONFIG_NETFILTER_XT_MATCH_POLICY is not set
CONFIG_IP_VS=y
# CONFIG_IP_VS_IPV6 is not set
CONFIG_IP_VS_DEBUG=y
CONFIG_IP_VS_TAB_BITS=12

#
# IPVS transport protocol load balancing support
#
# CONFIG_IP_VS_PROTO_TCP is not set
# CONFIG_IP_VS_PROTO_UDP is not set
CONFIG_IP_VS_PROTO_AH_ESP=y
CONFIG_IP_VS_PROTO_ESP=y
# CONFIG_IP_VS_PROTO_AH is not set
# CONFIG_IP_VS_PROTO_SCTP is not set

#
# IPVS scheduler
#
# CONFIG_IP_VS_RR is not set
CONFIG_IP_VS_WRR=y
CONFIG_IP_VS_LC=y
CONFIG_IP_VS_WLC=y
# CONFIG_IP_VS_LBLC is not set
CONFIG_IP_VS_LBLCR=y
CONFIG_IP_VS_DH=y
CONFIG_IP_VS_SH=y
CONFIG_IP_VS_SED=y
# CONFIG_IP_VS_NQ is not set

#
# IPVS SH scheduler
#
CONFIG_IP_VS_SH_TAB_BITS=8

#
# IPVS application helper
#

#
# IP: Netfilter Configuration
#
# CONFIG_NF_DEFRAG_IPV4 is not set
CONFIG_IP_NF_IPTABLES=y
CONFIG_IP_NF_FILTER=y
CONFIG_IP_NF_TARGET_REJECT=y
CONFIG_IP_NF_TARGET_ULOG=y
# CONFIG_IP_NF_MANGLE is not set
# CONFIG_IP_NF_RAW is not set

#
# IPv6: Netfilter Configuration
#
# CONFIG_NF_DEFRAG_IPV6 is not set
# CONFIG_IP6_NF_IPTABLES is not set
# CONFIG_BRIDGE_NF_EBTABLES is not set
CONFIG_IP_DCCP=y
CONFIG_INET_DCCP_DIAG=y

#
# DCCP CCIDs Configuration
#
# CONFIG_IP_DCCP_CCID2_DEBUG is not set
# CONFIG_IP_DCCP_CCID3 is not set

#
# DCCP Kernel Hacking
#
# CONFIG_IP_DCCP_DEBUG is not set
CONFIG_IP_SCTP=y
CONFIG_SCTP_DBG_MSG=y
CONFIG_SCTP_DBG_OBJCNT=y
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5 is not set
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1 is not set
CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE=y
CONFIG_SCTP_COOKIE_HMAC_MD5=y
CONFIG_SCTP_COOKIE_HMAC_SHA1=y
CONFIG_RDS=y
CONFIG_RDS_TCP=y
CONFIG_RDS_DEBUG=y
CONFIG_TIPC=y
CONFIG_TIPC_PORTS=8191
# CONFIG_ATM is not set
CONFIG_L2TP=y
CONFIG_L2TP_DEBUGFS=y
CONFIG_L2TP_V3=y
CONFIG_L2TP_IP=y
CONFIG_L2TP_ETH=y
CONFIG_STP=y
CONFIG_BRIDGE=y
# CONFIG_BRIDGE_IGMP_SNOOPING is not set
CONFIG_BRIDGE_VLAN_FILTERING=y
CONFIG_VLAN_8021Q=y
# CONFIG_VLAN_8021Q_GVRP is not set
# CONFIG_VLAN_8021Q_MVRP is not set
# CONFIG_DECNET is not set
CONFIG_LLC=y
# CONFIG_LLC2 is not set
CONFIG_IPX=y
CONFIG_IPX_INTERN=y
CONFIG_ATALK=y
CONFIG_DEV_APPLETALK=y
CONFIG_IPDDP=y
# CONFIG_IPDDP_ENCAP is not set
# CONFIG_X25 is not set
CONFIG_LAPB=y
CONFIG_PHONET=y
CONFIG_IEEE802154=y
CONFIG_IEEE802154_6LOWPAN=y
CONFIG_MAC802154=y
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
CONFIG_NET_SCH_CBQ=y
# CONFIG_NET_SCH_HTB is not set
CONFIG_NET_SCH_HFSC=y
CONFIG_NET_SCH_PRIO=y
# CONFIG_NET_SCH_MULTIQ is not set
CONFIG_NET_SCH_RED=y
CONFIG_NET_SCH_SFB=y
CONFIG_NET_SCH_SFQ=y
CONFIG_NET_SCH_TEQL=y
# CONFIG_NET_SCH_TBF is not set
CONFIG_NET_SCH_GRED=y
# CONFIG_NET_SCH_DSMARK is not set
CONFIG_NET_SCH_NETEM=y
CONFIG_NET_SCH_DRR=y
# CONFIG_NET_SCH_MQPRIO is not set
# CONFIG_NET_SCH_CHOKE is not set
CONFIG_NET_SCH_QFQ=y
CONFIG_NET_SCH_CODEL=y
CONFIG_NET_SCH_FQ_CODEL=y
CONFIG_NET_SCH_INGRESS=y
# CONFIG_NET_SCH_PLUG is not set

#
# Classification
#
CONFIG_NET_CLS=y
# CONFIG_NET_CLS_BASIC is not set
CONFIG_NET_CLS_TCINDEX=y
CONFIG_NET_CLS_ROUTE4=y
CONFIG_NET_CLS_FW=y
CONFIG_NET_CLS_U32=y
CONFIG_CLS_U32_PERF=y
# CONFIG_CLS_U32_MARK is not set
# CONFIG_NET_CLS_RSVP is not set
# CONFIG_NET_CLS_RSVP6 is not set
CONFIG_NET_CLS_FLOW=y
CONFIG_NET_CLS_CGROUP=y
# CONFIG_NET_EMATCH is not set
CONFIG_NET_CLS_ACT=y
CONFIG_NET_ACT_POLICE=y
CONFIG_NET_ACT_GACT=y
# CONFIG_GACT_PROB is not set
# CONFIG_NET_ACT_MIRRED is not set
CONFIG_NET_ACT_IPT=y
CONFIG_NET_ACT_NAT=y
CONFIG_NET_ACT_PEDIT=y
# CONFIG_NET_ACT_SIMP is not set
CONFIG_NET_ACT_SKBEDIT=y
# CONFIG_NET_ACT_CSUM is not set
# CONFIG_NET_CLS_IND is not set
CONFIG_NET_SCH_FIFO=y
# CONFIG_DCB is not set
CONFIG_DNS_RESOLVER=y
CONFIG_BATMAN_ADV=y
CONFIG_BATMAN_ADV_BLA=y
CONFIG_BATMAN_ADV_DAT=y
# CONFIG_BATMAN_ADV_NC is not set
# CONFIG_BATMAN_ADV_DEBUG is not set
CONFIG_OPENVSWITCH=y
CONFIG_VSOCKETS=y
CONFIG_NETLINK_MMAP=y
CONFIG_NETLINK_DIAG=y
# CONFIG_NET_MPLS_GSO is not set
# CONFIG_NETPRIO_CGROUP is not set
# CONFIG_NET_LL_RX_POLL is not set
CONFIG_BQL=y

#
# Network testing
#
CONFIG_NET_PKTGEN=y
CONFIG_HAMRADIO=y

#
# Packet Radio protocols
#
CONFIG_AX25=y
CONFIG_AX25_DAMA_SLAVE=y
# CONFIG_NETROM is not set
CONFIG_ROSE=y

#
# AX.25 network device drivers
#
# CONFIG_MKISS is not set
CONFIG_6PACK=y
# CONFIG_BPQETHER is not set
# CONFIG_BAYCOM_SER_FDX is not set
# CONFIG_BAYCOM_SER_HDX is not set
CONFIG_BAYCOM_PAR=y
CONFIG_YAM=y
CONFIG_CAN=y
CONFIG_CAN_RAW=y
# CONFIG_CAN_BCM is not set
CONFIG_CAN_GW=y

#
# CAN Device Drivers
#
# CONFIG_CAN_VCAN is not set
CONFIG_CAN_SLCAN=y
CONFIG_CAN_DEV=y
CONFIG_CAN_CALC_BITTIMING=y
# CONFIG_CAN_LEDS is not set
CONFIG_CAN_MCP251X=y
# CONFIG_PCH_CAN is not set
CONFIG_CAN_SJA1000=y
CONFIG_CAN_SJA1000_ISA=y
CONFIG_CAN_SJA1000_PLATFORM=y
CONFIG_CAN_EMS_PCMCIA=y
# CONFIG_CAN_EMS_PCI is not set
CONFIG_CAN_PEAK_PCMCIA=y
# CONFIG_CAN_PEAK_PCI is not set
# CONFIG_CAN_KVASER_PCI is not set
# CONFIG_CAN_PLX_PCI is not set
CONFIG_CAN_C_CAN=y
CONFIG_CAN_C_CAN_PLATFORM=y
# CONFIG_CAN_C_CAN_PCI is not set
# CONFIG_CAN_CC770 is not set

#
# CAN USB interfaces
#
CONFIG_CAN_EMS_USB=y
# CONFIG_CAN_ESD_USB2 is not set
CONFIG_CAN_KVASER_USB=y
# CONFIG_CAN_PEAK_USB is not set
# CONFIG_CAN_8DEV_USB is not set
CONFIG_CAN_SOFTING=y
CONFIG_CAN_SOFTING_CS=y
# CONFIG_CAN_DEBUG_DEVICES is not set
CONFIG_IRDA=y

#
# IrDA protocols
#
CONFIG_IRLAN=y
CONFIG_IRCOMM=y
# CONFIG_IRDA_ULTRA is not set

#
# IrDA options
#
CONFIG_IRDA_CACHE_LAST_LSAP=y
CONFIG_IRDA_FAST_RR=y
CONFIG_IRDA_DEBUG=y

#
# Infrared-port device drivers
#

#
# SIR device drivers
#
CONFIG_IRTTY_SIR=y

#
# Dongle support
#
# CONFIG_DONGLE is not set
CONFIG_KINGSUN_DONGLE=y
CONFIG_KSDAZZLE_DONGLE=y
# CONFIG_KS959_DONGLE is not set

#
# FIR device drivers
#
# CONFIG_USB_IRDA is not set
CONFIG_SIGMATEL_FIR=y
CONFIG_NSC_FIR=y
CONFIG_WINBOND_FIR=y
# CONFIG_SMC_IRCC_FIR is not set
CONFIG_ALI_FIR=y
# CONFIG_VLSI_FIR is not set
# CONFIG_VIA_FIR is not set
CONFIG_MCS_FIR=y
# CONFIG_BT is not set
CONFIG_AF_RXRPC=y
# CONFIG_AF_RXRPC_DEBUG is not set
CONFIG_RXKAD=y
CONFIG_FIB_RULES=y
CONFIG_WIRELESS=y
CONFIG_CFG80211=y
CONFIG_NL80211_TESTMODE=y
# CONFIG_CFG80211_DEVELOPER_WARNINGS is not set
CONFIG_CFG80211_REG_DEBUG=y
# CONFIG_CFG80211_DEFAULT_PS is not set
CONFIG_CFG80211_DEBUGFS=y
# CONFIG_CFG80211_INTERNAL_REGDB is not set
# CONFIG_CFG80211_WEXT is not set
# CONFIG_LIB80211 is not set
CONFIG_MAC80211=y
CONFIG_MAC80211_HAS_RC=y
CONFIG_MAC80211_RC_MINSTREL=y
CONFIG_MAC80211_RC_MINSTREL_HT=y
CONFIG_MAC80211_RC_DEFAULT_MINSTREL=y
CONFIG_MAC80211_RC_DEFAULT="minstrel_ht"
CONFIG_MAC80211_MESH=y
# CONFIG_MAC80211_LEDS is not set
CONFIG_MAC80211_DEBUGFS=y
CONFIG_MAC80211_MESSAGE_TRACING=y
CONFIG_MAC80211_DEBUG_MENU=y
# CONFIG_MAC80211_NOINLINE is not set
# CONFIG_MAC80211_VERBOSE_DEBUG is not set
# CONFIG_MAC80211_MLME_DEBUG is not set
# CONFIG_MAC80211_STA_DEBUG is not set
# CONFIG_MAC80211_HT_DEBUG is not set
# CONFIG_MAC80211_IBSS_DEBUG is not set
# CONFIG_MAC80211_PS_DEBUG is not set
# CONFIG_MAC80211_MPL_DEBUG is not set
# CONFIG_MAC80211_MPATH_DEBUG is not set
# CONFIG_MAC80211_MHWMP_DEBUG is not set
# CONFIG_MAC80211_MESH_SYNC_DEBUG is not set
# CONFIG_MAC80211_MESH_PS_DEBUG is not set
# CONFIG_MAC80211_TDLS_DEBUG is not set
# CONFIG_MAC80211_DEBUG_COUNTERS is not set
CONFIG_WIMAX=y
CONFIG_WIMAX_DEBUG_LEVEL=8
CONFIG_RFKILL=y
CONFIG_RFKILL_LEDS=y
CONFIG_RFKILL_INPUT=y
# CONFIG_RFKILL_REGULATOR is not set
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
# CONFIG_NET_9P_DEBUG is not set
CONFIG_CAIF=y
# CONFIG_CAIF_DEBUG is not set
CONFIG_CAIF_NETDEV=y
CONFIG_CAIF_USB=y
# CONFIG_CEPH_LIB is not set
CONFIG_NFC=y
# CONFIG_NFC_NCI is not set
# CONFIG_NFC_HCI is not set

#
# Near Field Communication (NFC) devices
#
CONFIG_NFC_PN533=y
CONFIG_HAVE_BPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
CONFIG_STANDALONE=y
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPI=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y

#
# Bus devices
#
# CONFIG_CONNECTOR is not set
CONFIG_MTD=y
# CONFIG_MTD_REDBOOT_PARTS is not set
CONFIG_MTD_CMDLINE_PARTS=y
CONFIG_MTD_AR7_PARTS=y

#
# User Modules And Translation Layers
#
CONFIG_MTD_BLKDEVS=y
# CONFIG_MTD_BLOCK is not set
CONFIG_MTD_BLOCK_RO=y
CONFIG_FTL=y
CONFIG_NFTL=y
# CONFIG_NFTL_RW is not set
CONFIG_INFTL=y
# CONFIG_RFD_FTL is not set
CONFIG_SSFDC=y
CONFIG_SM_FTL=y
CONFIG_MTD_OOPS=y
# CONFIG_MTD_SWAP is not set

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=y
CONFIG_MTD_JEDECPROBE=y
CONFIG_MTD_GEN_PROBE=y
# CONFIG_MTD_CFI_ADV_OPTIONS is not set
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
# CONFIG_MTD_MAP_BANK_WIDTH_8 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_32 is not set
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
# CONFIG_MTD_CFI_I4 is not set
# CONFIG_MTD_CFI_I8 is not set
# CONFIG_MTD_CFI_INTELEXT is not set
CONFIG_MTD_CFI_AMDSTD=y
CONFIG_MTD_CFI_STAA=y
CONFIG_MTD_CFI_UTIL=y
CONFIG_MTD_RAM=y
CONFIG_MTD_ROM=y
CONFIG_MTD_ABSENT=y

#
# Mapping drivers for chip access
#
CONFIG_MTD_COMPLEX_MAPPINGS=y
CONFIG_MTD_PHYSMAP=y
CONFIG_MTD_PHYSMAP_COMPAT=y
CONFIG_MTD_PHYSMAP_START=0x8000000
CONFIG_MTD_PHYSMAP_LEN=0
CONFIG_MTD_PHYSMAP_BANKWIDTH=2
# CONFIG_MTD_SC520CDP is not set
# CONFIG_MTD_NETSC520 is not set
CONFIG_MTD_TS5500=y
CONFIG_MTD_AMD76XROM=y
# CONFIG_MTD_ICHXROM is not set
# CONFIG_MTD_ESB2ROM is not set
# CONFIG_MTD_CK804XROM is not set
# CONFIG_MTD_SCB2_FLASH is not set
# CONFIG_MTD_NETtel is not set
CONFIG_MTD_L440GX=y
# CONFIG_MTD_PCI is not set
CONFIG_MTD_PCMCIA=y
# CONFIG_MTD_PCMCIA_ANONYMOUS is not set
CONFIG_MTD_GPIO_ADDR=y
# CONFIG_MTD_INTEL_VR_NOR is not set
# CONFIG_MTD_PLATRAM is not set
# CONFIG_MTD_LATCH_ADDR is not set

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
# CONFIG_MTD_DATAFLASH is not set
CONFIG_MTD_M25P80=y
# CONFIG_M25PXX_USE_FAST_READ is not set
# CONFIG_MTD_SST25L is not set
# CONFIG_MTD_SLRAM is not set
# CONFIG_MTD_PHRAM is not set
CONFIG_MTD_MTDRAM=y
CONFIG_MTDRAM_TOTAL_SIZE=4096
CONFIG_MTDRAM_ERASE_SIZE=128
CONFIG_MTDRAM_ABS_POS=0
CONFIG_MTD_BLOCK2MTD=y

#
# Disk-On-Chip Device Drivers
#
CONFIG_MTD_DOCG3=y
CONFIG_BCH_CONST_M=14
CONFIG_BCH_CONST_T=4
CONFIG_MTD_NAND_ECC=y
# CONFIG_MTD_NAND_ECC_SMC is not set
CONFIG_MTD_NAND=y
CONFIG_MTD_NAND_BCH=y
CONFIG_MTD_NAND_ECC_BCH=y
# CONFIG_MTD_SM_COMMON is not set
CONFIG_MTD_NAND_DENALI=y
# CONFIG_MTD_NAND_DENALI_PCI is not set
CONFIG_MTD_NAND_IDS=y
# CONFIG_MTD_NAND_RICOH is not set
# CONFIG_MTD_NAND_DISKONCHIP is not set
CONFIG_MTD_NAND_DOCG4=y
# CONFIG_MTD_NAND_CAFE is not set
CONFIG_MTD_NAND_NANDSIM=y
# CONFIG_MTD_NAND_PLATFORM is not set
CONFIG_MTD_ALAUDA=y
# CONFIG_MTD_ONENAND is not set

#
# LPDDR flash memory drivers
#
CONFIG_MTD_LPDDR=y
CONFIG_MTD_QINFO_PROBE=y
# CONFIG_MTD_UBI is not set
CONFIG_PARPORT=y
CONFIG_PARPORT_PC=y
# CONFIG_PARPORT_SERIAL is not set
# CONFIG_PARPORT_PC_FIFO is not set
CONFIG_PARPORT_PC_SUPERIO=y
# CONFIG_PARPORT_PC_PCMCIA is not set
# CONFIG_PARPORT_GSC is not set
CONFIG_PARPORT_AX88796=y
CONFIG_PARPORT_1284=y
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_FD is not set
# CONFIG_PARIDE is not set
# CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
# CONFIG_BLK_CPQ_DA is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
# CONFIG_BLK_DEV_LOOP is not set
# CONFIG_BLK_DEV_DRBD is not set
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_NVME is not set
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_RAM is not set
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
# CONFIG_VIRTIO_BLK is not set
# CONFIG_BLK_DEV_HD is not set
# CONFIG_BLK_DEV_RBD is not set
# CONFIG_BLK_DEV_RSXX is not set

#
# Misc devices
#
# CONFIG_SENSORS_LIS3LV02D is not set
CONFIG_AD525X_DPOT=y
CONFIG_AD525X_DPOT_I2C=y
CONFIG_AD525X_DPOT_SPI=y
CONFIG_DUMMY_IRQ=y
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_INTEL_MID_PTI is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
# CONFIG_ICS932S401 is not set
CONFIG_ATMEL_SSC=y
CONFIG_ENCLOSURE_SERVICES=y
# CONFIG_HP_ILO is not set
CONFIG_APDS9802ALS=y
CONFIG_ISL29003=y
CONFIG_ISL29020=y
CONFIG_SENSORS_TSL2550=y
CONFIG_SENSORS_BH1780=y
CONFIG_SENSORS_BH1770=y
CONFIG_SENSORS_APDS990X=y
# CONFIG_HMC6352 is not set
CONFIG_DS1682=y
CONFIG_TI_DAC7512=y
CONFIG_VMWARE_BALLOON=y
# CONFIG_BMP085_I2C is not set
# CONFIG_BMP085_SPI is not set
# CONFIG_PCH_PHUB is not set
CONFIG_USB_SWITCH_FSA9480=y
# CONFIG_LATTICE_ECP3_CONFIG is not set
CONFIG_SRAM=y
CONFIG_C2PORT=y
CONFIG_C2PORT_DURAMAR_2150=y

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
# CONFIG_EEPROM_AT25 is not set
# CONFIG_EEPROM_LEGACY is not set
# CONFIG_EEPROM_MAX6875 is not set
CONFIG_EEPROM_93CX6=y
CONFIG_EEPROM_93XX46=y
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
# CONFIG_SENSORS_LIS3_I2C is not set

#
# Altera FPGA firmware download module
#
# CONFIG_ALTERA_STAPL is not set
# CONFIG_INTEL_MEI is not set
# CONFIG_INTEL_MEI_ME is not set
# CONFIG_VMWARE_VMCI is not set
CONFIG_HAVE_IDE=y
CONFIG_IDE=y

#
# Please see Documentation/ide/ide.txt for help/info on IDE drives
#
CONFIG_IDE_XFER_MODE=y
CONFIG_IDE_TIMINGS=y
CONFIG_IDE_ATAPI=y
CONFIG_BLK_DEV_IDE_SATA=y
CONFIG_IDE_GD=y
# CONFIG_IDE_GD_ATA is not set
CONFIG_IDE_GD_ATAPI=y
# CONFIG_BLK_DEV_IDECS is not set
# CONFIG_BLK_DEV_DELKIN is not set
# CONFIG_BLK_DEV_IDECD is not set
# CONFIG_BLK_DEV_IDETAPE is not set
# CONFIG_BLK_DEV_IDEACPI is not set
# CONFIG_IDE_TASK_IOCTL is not set
CONFIG_IDE_PROC_FS=y

#
# IDE chipset support/bugfixes
#
CONFIG_IDE_GENERIC=y
# CONFIG_BLK_DEV_PLATFORM is not set
CONFIG_BLK_DEV_CMD640=y
CONFIG_BLK_DEV_CMD640_ENHANCED=y
# CONFIG_BLK_DEV_IDEPNP is not set

#
# PCI IDE chipsets support
#
# CONFIG_BLK_DEV_GENERIC is not set
# CONFIG_BLK_DEV_OPTI621 is not set
# CONFIG_BLK_DEV_RZ1000 is not set
# CONFIG_BLK_DEV_AEC62XX is not set
# CONFIG_BLK_DEV_ALI15X3 is not set
# CONFIG_BLK_DEV_AMD74XX is not set
# CONFIG_BLK_DEV_ATIIXP is not set
# CONFIG_BLK_DEV_CMD64X is not set
# CONFIG_BLK_DEV_TRIFLEX is not set
# CONFIG_BLK_DEV_CS5520 is not set
# CONFIG_BLK_DEV_CS5530 is not set
# CONFIG_BLK_DEV_HPT366 is not set
# CONFIG_BLK_DEV_JMICRON is not set
# CONFIG_BLK_DEV_SC1200 is not set
# CONFIG_BLK_DEV_PIIX is not set
# CONFIG_BLK_DEV_IT8172 is not set
# CONFIG_BLK_DEV_IT8213 is not set
# CONFIG_BLK_DEV_IT821X is not set
# CONFIG_BLK_DEV_NS87415 is not set
# CONFIG_BLK_DEV_PDC202XX_OLD is not set
# CONFIG_BLK_DEV_PDC202XX_NEW is not set
# CONFIG_BLK_DEV_SVWKS is not set
# CONFIG_BLK_DEV_SIIMAGE is not set
# CONFIG_BLK_DEV_SIS5513 is not set
# CONFIG_BLK_DEV_SLC90E66 is not set
# CONFIG_BLK_DEV_TRM290 is not set
# CONFIG_BLK_DEV_VIA82CXXX is not set
# CONFIG_BLK_DEV_TC86C001 is not set
# CONFIG_BLK_DEV_IDEDMA is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
# CONFIG_RAID_ATTRS is not set
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
CONFIG_SCSI_TGT=y
CONFIG_SCSI_NETLINK=y
# CONFIG_SCSI_PROC_FS is not set

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
# CONFIG_CHR_DEV_ST is not set
CONFIG_CHR_DEV_OSST=y
CONFIG_BLK_DEV_SR=y
# CONFIG_BLK_DEV_SR_VENDOR is not set
CONFIG_CHR_DEV_SG=y
CONFIG_CHR_DEV_SCH=y
CONFIG_SCSI_ENCLOSURE=y
CONFIG_SCSI_MULTI_LUN=y
CONFIG_SCSI_CONSTANTS=y
CONFIG_SCSI_LOGGING=y
CONFIG_SCSI_SCAN_ASYNC=y

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
CONFIG_SCSI_FC_ATTRS=y
CONFIG_SCSI_FC_TGT_ATTRS=y
CONFIG_SCSI_ISCSI_ATTRS=y
CONFIG_SCSI_SAS_ATTRS=y
CONFIG_SCSI_SAS_LIBSAS=y
CONFIG_SCSI_SAS_ATA=y
# CONFIG_SCSI_SAS_HOST_SMP is not set
CONFIG_SCSI_SRP_ATTRS=y
CONFIG_SCSI_SRP_TGT_ATTRS=y
CONFIG_SCSI_LOWLEVEL=y
CONFIG_ISCSI_TCP=y
CONFIG_ISCSI_BOOT_SYSFS=y
# CONFIG_SCSI_CXGB3_ISCSI is not set
# CONFIG_SCSI_CXGB4_ISCSI is not set
# CONFIG_SCSI_BNX2_ISCSI is not set
# CONFIG_SCSI_BNX2X_FCOE is not set
# CONFIG_BE2ISCSI is not set
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
# CONFIG_SCSI_HPSA is not set
# CONFIG_SCSI_3W_9XXX is not set
# CONFIG_SCSI_3W_SAS is not set
# CONFIG_SCSI_ACARD is not set
# CONFIG_SCSI_AACRAID is not set
# CONFIG_SCSI_AIC7XXX is not set
# CONFIG_SCSI_AIC7XXX_OLD is not set
# CONFIG_SCSI_AIC79XX is not set
# CONFIG_SCSI_AIC94XX is not set
# CONFIG_SCSI_MVSAS is not set
# CONFIG_SCSI_MVUMI is not set
# CONFIG_SCSI_DPT_I2O is not set
# CONFIG_SCSI_ADVANSYS is not set
# CONFIG_SCSI_ARCMSR is not set
# CONFIG_MEGARAID_NEWGEN is not set
# CONFIG_MEGARAID_LEGACY is not set
# CONFIG_MEGARAID_SAS is not set
# CONFIG_SCSI_MPT2SAS is not set
# CONFIG_SCSI_MPT3SAS is not set
CONFIG_SCSI_UFSHCD=y
# CONFIG_SCSI_UFSHCD_PCI is not set
CONFIG_SCSI_UFSHCD_PLATFORM=y
# CONFIG_SCSI_HPTIOP is not set
# CONFIG_SCSI_BUSLOGIC is not set
# CONFIG_VMWARE_PVSCSI is not set
CONFIG_LIBFC=y
CONFIG_LIBFCOE=y
# CONFIG_FCOE is not set
# CONFIG_FCOE_FNIC is not set
# CONFIG_SCSI_DMX3191D is not set
# CONFIG_SCSI_EATA is not set
# CONFIG_SCSI_FUTURE_DOMAIN is not set
# CONFIG_SCSI_GDTH is not set
# CONFIG_SCSI_ISCI is not set
# CONFIG_SCSI_IPS is not set
# CONFIG_SCSI_INITIO is not set
# CONFIG_SCSI_INIA100 is not set
CONFIG_SCSI_PPA=y
CONFIG_SCSI_IMM=y
CONFIG_SCSI_IZIP_EPP16=y
CONFIG_SCSI_IZIP_SLOW_CTR=y
# CONFIG_SCSI_STEX is not set
# CONFIG_SCSI_SYM53C8XX_2 is not set
# CONFIG_SCSI_IPR is not set
# CONFIG_SCSI_QLOGIC_1280 is not set
# CONFIG_SCSI_QLA_FC is not set
# CONFIG_SCSI_QLA_ISCSI is not set
# CONFIG_SCSI_LPFC is not set
# CONFIG_SCSI_DC395x is not set
# CONFIG_SCSI_DC390T is not set
# CONFIG_SCSI_DEBUG is not set
# CONFIG_SCSI_PMCRAID is not set
# CONFIG_SCSI_PM8001 is not set
# CONFIG_SCSI_SRP is not set
# CONFIG_SCSI_BFA_FC is not set
CONFIG_SCSI_VIRTIO=y
# CONFIG_SCSI_CHELSIO_FCOE is not set
# CONFIG_SCSI_LOWLEVEL_PCMCIA is not set
CONFIG_SCSI_DH=y
CONFIG_SCSI_DH_RDAC=y
CONFIG_SCSI_DH_HP_SW=y
CONFIG_SCSI_DH_EMC=y
CONFIG_SCSI_DH_ALUA=y
CONFIG_SCSI_OSD_INITIATOR=y
# CONFIG_SCSI_OSD_ULD is not set
CONFIG_SCSI_OSD_DPRINT_SENSE=1
CONFIG_SCSI_OSD_DEBUG=y
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_VERBOSE_ERROR=y
CONFIG_ATA_ACPI=y
# CONFIG_SATA_ZPODD is not set
# CONFIG_SATA_PMP is not set

#
# Controllers with non-SFF native interface
#
# CONFIG_SATA_AHCI is not set
CONFIG_SATA_AHCI_PLATFORM=y
# CONFIG_SATA_INIC162X is not set
# CONFIG_SATA_ACARD_AHCI is not set
# CONFIG_SATA_SIL24 is not set
# CONFIG_ATA_SFF is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
CONFIG_MD_AUTODETECT=y
# CONFIG_MD_LINEAR is not set
CONFIG_MD_RAID0=y
CONFIG_MD_RAID1=y
CONFIG_MD_RAID10=y
CONFIG_MD_RAID456=y
CONFIG_MD_MULTIPATH=y
CONFIG_MD_FAULTY=y
CONFIG_BCACHE=y
CONFIG_BCACHE_DEBUG=y
# CONFIG_BCACHE_EDEBUG is not set
# CONFIG_BCACHE_CLOSURES_DEBUG is not set
# CONFIG_BLK_DEV_DM is not set
# CONFIG_TARGET_CORE is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_I2O is not set
# CONFIG_MACINTOSH_DRIVERS is not set
# CONFIG_NETDEVICES is not set
CONFIG_VHOST_NET=y
CONFIG_VHOST_RING=y

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
# CONFIG_INPUT_SPARSEKMAP is not set
CONFIG_INPUT_MATRIXKMAP=y

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_INPUT_JOYDEV=y
# CONFIG_INPUT_EVDEV is not set
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5588 is not set
CONFIG_KEYBOARD_ADP5589=y
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
CONFIG_KEYBOARD_QT2160=y
CONFIG_KEYBOARD_LKKBD=y
CONFIG_KEYBOARD_GPIO=y
CONFIG_KEYBOARD_GPIO_POLLED=y
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_TCA8418 is not set
CONFIG_KEYBOARD_MATRIX=y
# CONFIG_KEYBOARD_LM8323 is not set
CONFIG_KEYBOARD_LM8333=y
# CONFIG_KEYBOARD_MAX7359 is not set
CONFIG_KEYBOARD_MCS=y
CONFIG_KEYBOARD_MPR121=y
CONFIG_KEYBOARD_NEWTON=y
CONFIG_KEYBOARD_OPENCORES=y
CONFIG_KEYBOARD_STOWAWAY=y
# CONFIG_KEYBOARD_SUNKBD is not set
CONFIG_KEYBOARD_TC3589X=y
CONFIG_KEYBOARD_XTKBD=y
# CONFIG_KEYBOARD_CROS_EC is not set
# CONFIG_INPUT_MOUSE is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_ADS7846=y
CONFIG_TOUCHSCREEN_AD7877=y
# CONFIG_TOUCHSCREEN_AD7879 is not set
# CONFIG_TOUCHSCREEN_ATMEL_MXT is not set
# CONFIG_TOUCHSCREEN_AUO_PIXCIR is not set
# CONFIG_TOUCHSCREEN_BU21013 is not set
# CONFIG_TOUCHSCREEN_CY8CTMG110 is not set
# CONFIG_TOUCHSCREEN_CYTTSP_CORE is not set
# CONFIG_TOUCHSCREEN_DA9052 is not set
# CONFIG_TOUCHSCREEN_DYNAPRO is not set
# CONFIG_TOUCHSCREEN_HAMPSHIRE is not set
# CONFIG_TOUCHSCREEN_EETI is not set
# CONFIG_TOUCHSCREEN_FUJITSU is not set
CONFIG_TOUCHSCREEN_ILI210X=y
CONFIG_TOUCHSCREEN_GUNZE=y
CONFIG_TOUCHSCREEN_ELO=y
CONFIG_TOUCHSCREEN_WACOM_W8001=y
CONFIG_TOUCHSCREEN_WACOM_I2C=y
# CONFIG_TOUCHSCREEN_MAX11801 is not set
CONFIG_TOUCHSCREEN_MCS5000=y
CONFIG_TOUCHSCREEN_MMS114=y
# CONFIG_TOUCHSCREEN_MTOUCH is not set
CONFIG_TOUCHSCREEN_INEXIO=y
CONFIG_TOUCHSCREEN_MK712=y
CONFIG_TOUCHSCREEN_PENMOUNT=y
CONFIG_TOUCHSCREEN_EDT_FT5X06=y
# CONFIG_TOUCHSCREEN_TOUCHRIGHT is not set
CONFIG_TOUCHSCREEN_TOUCHWIN=y
CONFIG_TOUCHSCREEN_PIXCIR=y
CONFIG_TOUCHSCREEN_WM831X=y
# CONFIG_TOUCHSCREEN_USB_COMPOSITE is not set
CONFIG_TOUCHSCREEN_MC13783=y
CONFIG_TOUCHSCREEN_TOUCHIT213=y
CONFIG_TOUCHSCREEN_TSC_SERIO=y
CONFIG_TOUCHSCREEN_TSC2005=y
CONFIG_TOUCHSCREEN_TSC2007=y
# CONFIG_TOUCHSCREEN_PCAP is not set
CONFIG_TOUCHSCREEN_ST1232=y
CONFIG_TOUCHSCREEN_TPS6507X=y
CONFIG_INPUT_MISC=y
CONFIG_INPUT_88PM80X_ONKEY=y
CONFIG_INPUT_AD714X=y
# CONFIG_INPUT_AD714X_I2C is not set
CONFIG_INPUT_AD714X_SPI=y
CONFIG_INPUT_BMA150=y
# CONFIG_INPUT_PCSPKR is not set
CONFIG_INPUT_MAX8925_ONKEY=y
CONFIG_INPUT_MC13783_PWRBUTTON=y
# CONFIG_INPUT_MMA8450 is not set
CONFIG_INPUT_MPU3050=y
CONFIG_INPUT_APANEL=y
CONFIG_INPUT_GP2A=y
# CONFIG_INPUT_GPIO_TILT_POLLED is not set
# CONFIG_INPUT_ATLAS_BTNS is not set
CONFIG_INPUT_ATI_REMOTE2=y
# CONFIG_INPUT_KEYSPAN_REMOTE is not set
# CONFIG_INPUT_KXTJ9 is not set
CONFIG_INPUT_POWERMATE=y
# CONFIG_INPUT_YEALINK is not set
# CONFIG_INPUT_CM109 is not set
CONFIG_INPUT_RETU_PWRBUTTON=y
CONFIG_INPUT_UINPUT=y
CONFIG_INPUT_PCF50633_PMU=y
CONFIG_INPUT_PCF8574=y
CONFIG_INPUT_GPIO_ROTARY_ENCODER=y
CONFIG_INPUT_DA9052_ONKEY=y
CONFIG_INPUT_DA9055_ONKEY=y
# CONFIG_INPUT_WM831X_ON is not set
CONFIG_INPUT_PCAP=y
CONFIG_INPUT_ADXL34X=y
# CONFIG_INPUT_ADXL34X_I2C is not set
CONFIG_INPUT_ADXL34X_SPI=y
CONFIG_INPUT_IMS_PCU=y
# CONFIG_INPUT_CMA3000 is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
# CONFIG_SERIO_SERPORT is not set
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PARKBD is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
# CONFIG_SERIO_ALTERA_PS2 is not set
CONFIG_SERIO_PS2MULT=y
CONFIG_SERIO_ARC_PS2=y
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_TTY=y
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_HW_CONSOLE=y
# CONFIG_VT_HW_CONSOLE_BINDING is not set
CONFIG_UNIX98_PTYS=y
CONFIG_DEVPTS_MULTIPLE_INSTANCES=y
# CONFIG_LEGACY_PTYS is not set
# CONFIG_SERIAL_NONSTANDARD is not set
# CONFIG_NOZOMI is not set
CONFIG_N_GSM=y
CONFIG_TRACE_ROUTER=y
CONFIG_TRACE_SINK=y
# CONFIG_DEVKMEM is not set

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_PCI=y
# CONFIG_SERIAL_8250_CS is not set
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
# CONFIG_SERIAL_8250_DW is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MAX3100 is not set
# CONFIG_SERIAL_MAX310X is not set
# CONFIG_SERIAL_MFD_HSU is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
# CONFIG_SERIAL_SCCNXP is not set
CONFIG_SERIAL_TIMBERDALE=y
CONFIG_SERIAL_ALTERA_JTAGUART=y
CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE=y
CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE_BYPASS=y
CONFIG_SERIAL_ALTERA_UART=y
CONFIG_SERIAL_ALTERA_UART_MAXPORTS=4
CONFIG_SERIAL_ALTERA_UART_BAUDRATE=115200
CONFIG_SERIAL_ALTERA_UART_CONSOLE=y
# CONFIG_SERIAL_IFX6X60 is not set
# CONFIG_SERIAL_PCH_UART is not set
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_RP2 is not set
CONFIG_PRINTER=y
# CONFIG_LP_CONSOLE is not set
CONFIG_PPDEV=y
# CONFIG_VIRTIO_CONSOLE is not set
CONFIG_IPMI_HANDLER=y
CONFIG_IPMI_PANIC_EVENT=y
# CONFIG_IPMI_PANIC_STRING is not set
CONFIG_IPMI_DEVICE_INTERFACE=y
CONFIG_IPMI_SI=y
# CONFIG_IPMI_WATCHDOG is not set
CONFIG_IPMI_POWEROFF=y
CONFIG_HW_RANDOM=y
# CONFIG_HW_RANDOM_TIMERIOMEM is not set
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=y
# CONFIG_HW_RANDOM_VIA is not set
# CONFIG_HW_RANDOM_VIRTIO is not set
CONFIG_HW_RANDOM_TPM=y
# CONFIG_NVRAM is not set
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set

#
# PCMCIA character devices
#
CONFIG_SYNCLINK_CS=y
CONFIG_CARDMAN_4000=y
# CONFIG_CARDMAN_4040 is not set
# CONFIG_MWAVE is not set
CONFIG_RAW_DRIVER=y
CONFIG_MAX_RAW_DEVS=256
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
CONFIG_TCG_TPM=y
# CONFIG_TCG_TIS is not set
CONFIG_TCG_TIS_I2C_INFINEON=y
CONFIG_TCG_NSC=y
CONFIG_TCG_ATMEL=y
# CONFIG_TCG_INFINEON is not set
CONFIG_TCG_ST33_I2C=y
CONFIG_TELCLOCK=y
CONFIG_DEVPORT=y
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
CONFIG_I2C_CHARDEV=y
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
# CONFIG_I2C_MUX_GPIO is not set
CONFIG_I2C_MUX_PCA9541=y
CONFIG_I2C_MUX_PCA954x=y
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=y
CONFIG_I2C_ALGOBIT=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_ISCH is not set
# CONFIG_I2C_ISMT is not set
# CONFIG_I2C_PIIX4 is not set
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_CBUS_GPIO=y
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_EG20T is not set
CONFIG_I2C_GPIO=y
# CONFIG_I2C_INTEL_MID is not set
CONFIG_I2C_OCORES=y
# CONFIG_I2C_PCA_PLATFORM is not set
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=y
CONFIG_I2C_XILINX=y

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_DIOLAN_U2C=y
CONFIG_I2C_PARPORT=y
# CONFIG_I2C_PARPORT_LIGHT is not set
# CONFIG_I2C_TAOS_EVM is not set
CONFIG_I2C_TINY_USB=y

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_SPI=y
# CONFIG_SPI_DEBUG is not set
CONFIG_SPI_MASTER=y

#
# SPI Master Controller Drivers
#
CONFIG_SPI_ALTERA=y
CONFIG_SPI_BITBANG=y
# CONFIG_SPI_BUTTERFLY is not set
CONFIG_SPI_GPIO=y
# CONFIG_SPI_LM70_LLP is not set
# CONFIG_SPI_OC_TINY is not set
# CONFIG_SPI_PXA2XX is not set
# CONFIG_SPI_PXA2XX_PCI is not set
CONFIG_SPI_SC18IS602=y
# CONFIG_SPI_TOPCLIFF_PCH is not set
CONFIG_SPI_XCOMM=y
CONFIG_SPI_XILINX=y
CONFIG_SPI_DESIGNWARE=y
# CONFIG_SPI_DW_PCI is not set

#
# SPI Protocol Masters
#
# CONFIG_SPI_SPIDEV is not set
CONFIG_SPI_TLE62X0=y

#
# Qualcomm MSM SSBI bus support
#
CONFIG_SSBI=y
# CONFIG_HSI is not set

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set
# CONFIG_NTP_PPS is not set

#
# PPS clients support
#
# CONFIG_PPS_CLIENT_KTIMER is not set
# CONFIG_PPS_CLIENT_LDISC is not set
CONFIG_PPS_CLIENT_PARPORT=y
# CONFIG_PPS_CLIENT_GPIO is not set

#
# PPS generators support
#

#
# PTP clock support
#
CONFIG_PTP_1588_CLOCK=y

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
CONFIG_PTP_1588_CLOCK_PCH=y
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
CONFIG_GPIO_DEVRES=y
CONFIG_GPIOLIB=y
CONFIG_GPIO_ACPI=y
# CONFIG_DEBUG_GPIO is not set
# CONFIG_GPIO_SYSFS is not set
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_DA9052=y
CONFIG_GPIO_DA9055=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers:
#
CONFIG_GPIO_GENERIC_PLATFORM=y
CONFIG_GPIO_IT8761E=y
# CONFIG_GPIO_TS5500 is not set
# CONFIG_GPIO_SCH is not set
# CONFIG_GPIO_ICH is not set
# CONFIG_GPIO_VX855 is not set
# CONFIG_GPIO_LYNXPOINT is not set

#
# I2C GPIO expanders:
#
# CONFIG_GPIO_ARIZONA is not set
CONFIG_GPIO_MAX7300=y
CONFIG_GPIO_MAX732X=y
CONFIG_GPIO_MAX732X_IRQ=y
CONFIG_GPIO_PCA953X=y
CONFIG_GPIO_PCA953X_IRQ=y
CONFIG_GPIO_PCF857X=y
# CONFIG_GPIO_SX150X is not set
CONFIG_GPIO_TC3589X=y
CONFIG_GPIO_TPS65912=y
CONFIG_GPIO_WM831X=y
CONFIG_GPIO_WM8350=y
# CONFIG_GPIO_WM8994 is not set
CONFIG_GPIO_ADP5588=y
CONFIG_GPIO_ADP5588_IRQ=y

#
# PCI GPIO expanders:
#
# CONFIG_GPIO_BT8XX is not set
# CONFIG_GPIO_AMD8111 is not set
# CONFIG_GPIO_LANGWELL is not set
# CONFIG_GPIO_PCH is not set
# CONFIG_GPIO_ML_IOH is not set
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders:
#
CONFIG_GPIO_MAX7301=y
CONFIG_GPIO_MCP23S08=y
# CONFIG_GPIO_MC33880 is not set
CONFIG_GPIO_74X164=y

#
# AC97 GPIO expanders:
#

#
# MODULbus GPIO expanders:
#
CONFIG_GPIO_TPS6586X=y

#
# USB GPIO expanders:
#
# CONFIG_W1 is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_GENERIC_ADC_BATTERY is not set
# CONFIG_MAX8925_POWER is not set
# CONFIG_WM831X_BACKUP is not set
# CONFIG_WM831X_POWER is not set
# CONFIG_WM8350_POWER is not set
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_DS2780 is not set
# CONFIG_BATTERY_DS2781 is not set
# CONFIG_BATTERY_DS2782 is not set
# CONFIG_BATTERY_SBS is not set
# CONFIG_BATTERY_BQ27x00 is not set
# CONFIG_BATTERY_DA9052 is not set
# CONFIG_BATTERY_MAX17040 is not set
# CONFIG_BATTERY_MAX17042 is not set
# CONFIG_CHARGER_PCF50633 is not set
# CONFIG_CHARGER_ISP1704 is not set
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_LP8727 is not set
# CONFIG_CHARGER_LP8788 is not set
# CONFIG_CHARGER_GPIO is not set
# CONFIG_CHARGER_MANAGER is not set
# CONFIG_CHARGER_BQ2415X is not set
# CONFIG_CHARGER_SMB347 is not set
# CONFIG_BATTERY_GOLDFISH is not set
# CONFIG_POWER_RESET is not set
# CONFIG_POWER_AVS is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
# CONFIG_SENSORS_ABITUGURU is not set
CONFIG_SENSORS_ABITUGURU3=y
CONFIG_SENSORS_AD7314=y
# CONFIG_SENSORS_AD7414 is not set
CONFIG_SENSORS_AD7418=y
# CONFIG_SENSORS_ADCXX is not set
# CONFIG_SENSORS_ADM1021 is not set
CONFIG_SENSORS_ADM1025=y
CONFIG_SENSORS_ADM1026=y
# CONFIG_SENSORS_ADM1029 is not set
CONFIG_SENSORS_ADM1031=y
CONFIG_SENSORS_ADM9240=y
CONFIG_SENSORS_ADT7X10=y
# CONFIG_SENSORS_ADT7310 is not set
CONFIG_SENSORS_ADT7410=y
CONFIG_SENSORS_ADT7411=y
CONFIG_SENSORS_ADT7462=y
CONFIG_SENSORS_ADT7470=y
CONFIG_SENSORS_ADT7475=y
# CONFIG_SENSORS_ASC7621 is not set
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_FAM15H_POWER is not set
CONFIG_SENSORS_ASB100=y
CONFIG_SENSORS_ATXP1=y
CONFIG_SENSORS_DS620=y
# CONFIG_SENSORS_DS1621 is not set
CONFIG_SENSORS_DA9052_ADC=y
CONFIG_SENSORS_DA9055=y
# CONFIG_SENSORS_I5K_AMB is not set
CONFIG_SENSORS_F71805F=y
# CONFIG_SENSORS_F71882FG is not set
CONFIG_SENSORS_F75375S=y
CONFIG_SENSORS_FSCHMD=y
# CONFIG_SENSORS_G760A is not set
CONFIG_SENSORS_GL518SM=y
# CONFIG_SENSORS_GL520SM is not set
# CONFIG_SENSORS_GPIO_FAN is not set
CONFIG_SENSORS_HIH6130=y
# CONFIG_SENSORS_CORETEMP is not set
# CONFIG_SENSORS_IBMAEM is not set
CONFIG_SENSORS_IBMPEX=y
CONFIG_SENSORS_IIO_HWMON=y
CONFIG_SENSORS_IT87=y
# CONFIG_SENSORS_JC42 is not set
CONFIG_SENSORS_LINEAGE=y
# CONFIG_SENSORS_LM63 is not set
CONFIG_SENSORS_LM70=y
CONFIG_SENSORS_LM73=y
CONFIG_SENSORS_LM75=y
# CONFIG_SENSORS_LM77 is not set
CONFIG_SENSORS_LM78=y
CONFIG_SENSORS_LM80=y
CONFIG_SENSORS_LM83=y
CONFIG_SENSORS_LM85=y
CONFIG_SENSORS_LM87=y
CONFIG_SENSORS_LM90=y
CONFIG_SENSORS_LM92=y
CONFIG_SENSORS_LM93=y
CONFIG_SENSORS_LTC4151=y
# CONFIG_SENSORS_LTC4215 is not set
CONFIG_SENSORS_LTC4245=y
# CONFIG_SENSORS_LTC4261 is not set
# CONFIG_SENSORS_LM95234 is not set
# CONFIG_SENSORS_LM95241 is not set
# CONFIG_SENSORS_LM95245 is not set
# CONFIG_SENSORS_MAX1111 is not set
# CONFIG_SENSORS_MAX16065 is not set
# CONFIG_SENSORS_MAX1619 is not set
CONFIG_SENSORS_MAX1668=y
CONFIG_SENSORS_MAX197=y
# CONFIG_SENSORS_MAX6639 is not set
# CONFIG_SENSORS_MAX6642 is not set
CONFIG_SENSORS_MAX6650=y
CONFIG_SENSORS_MAX6697=y
CONFIG_SENSORS_MCP3021=y
CONFIG_SENSORS_NCT6775=y
CONFIG_SENSORS_PC87360=y
CONFIG_SENSORS_PC87427=y
CONFIG_SENSORS_PCF8591=y
# CONFIG_PMBUS is not set
CONFIG_SENSORS_SHT15=y
# CONFIG_SENSORS_SHT21 is not set
# CONFIG_SENSORS_SIS5595 is not set
# CONFIG_SENSORS_SMM665 is not set
# CONFIG_SENSORS_DME1737 is not set
CONFIG_SENSORS_EMC1403=y
CONFIG_SENSORS_EMC2103=y
CONFIG_SENSORS_EMC6W201=y
CONFIG_SENSORS_SMSC47M1=y
CONFIG_SENSORS_SMSC47M192=y
# CONFIG_SENSORS_SMSC47B397 is not set
CONFIG_SENSORS_SCH56XX_COMMON=y
CONFIG_SENSORS_SCH5627=y
# CONFIG_SENSORS_SCH5636 is not set
CONFIG_SENSORS_ADS1015=y
CONFIG_SENSORS_ADS7828=y
# CONFIG_SENSORS_ADS7871 is not set
CONFIG_SENSORS_AMC6821=y
CONFIG_SENSORS_INA209=y
CONFIG_SENSORS_INA2XX=y
CONFIG_SENSORS_THMC50=y
CONFIG_SENSORS_TMP102=y
CONFIG_SENSORS_TMP401=y
CONFIG_SENSORS_TMP421=y
CONFIG_SENSORS_VIA_CPUTEMP=y
# CONFIG_SENSORS_VIA686A is not set
CONFIG_SENSORS_VT1211=y
# CONFIG_SENSORS_VT8231 is not set
CONFIG_SENSORS_W83781D=y
# CONFIG_SENSORS_W83791D is not set
# CONFIG_SENSORS_W83792D is not set
CONFIG_SENSORS_W83793=y
CONFIG_SENSORS_W83795=y
# CONFIG_SENSORS_W83795_FANCTRL is not set
CONFIG_SENSORS_W83L785TS=y
CONFIG_SENSORS_W83L786NG=y
# CONFIG_SENSORS_W83627HF is not set
CONFIG_SENSORS_W83627EHF=y
CONFIG_SENSORS_WM831X=y
CONFIG_SENSORS_WM8350=y
CONFIG_SENSORS_APPLESMC=y
# CONFIG_SENSORS_MC13783_ADC is not set

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
# CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE is not set
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE=y
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_GOV_STEP_WISE=y
CONFIG_THERMAL_GOV_USER_SPACE=y
# CONFIG_CPU_THERMAL is not set
# CONFIG_THERMAL_EMULATION is not set
CONFIG_INTEL_POWERCLAMP=y
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
# CONFIG_WATCHDOG_NOWAYOUT is not set

#
# Watchdog Device Drivers
#
# CONFIG_SOFT_WATCHDOG is not set
# CONFIG_DA9052_WATCHDOG is not set
# CONFIG_DA9055_WATCHDOG is not set
# CONFIG_WM831X_WATCHDOG is not set
CONFIG_WM8350_WATCHDOG=y
# CONFIG_RETU_WATCHDOG is not set
CONFIG_ACQUIRE_WDT=y
CONFIG_ADVANTECH_WDT=y
# CONFIG_ALIM1535_WDT is not set
# CONFIG_ALIM7101_WDT is not set
CONFIG_F71808E_WDT=y
# CONFIG_SP5100_TCO is not set
CONFIG_SC520_WDT=y
CONFIG_SBC_FITPC2_WATCHDOG=y
# CONFIG_EUROTECH_WDT is not set
CONFIG_IB700_WDT=y
CONFIG_IBMASR=y
# CONFIG_WAFER_WDT is not set
# CONFIG_I6300ESB_WDT is not set
# CONFIG_IE6XX_WDT is not set
# CONFIG_ITCO_WDT is not set
CONFIG_IT8712F_WDT=y
CONFIG_IT87_WDT=y
# CONFIG_HP_WATCHDOG is not set
# CONFIG_SC1200_WDT is not set
CONFIG_PC87413_WDT=y
# CONFIG_NV_TCO is not set
CONFIG_60XX_WDT=y
# CONFIG_SBC8360_WDT is not set
# CONFIG_CPU5_WDT is not set
# CONFIG_SMSC_SCH311X_WDT is not set
# CONFIG_SMSC37B787_WDT is not set
# CONFIG_VIA_WDT is not set
# CONFIG_W83627HF_WDT is not set
# CONFIG_W83697HF_WDT is not set
CONFIG_W83697UG_WDT=y
CONFIG_W83877F_WDT=y
CONFIG_W83977F_WDT=y
CONFIG_MACHZ_WDT=y
# CONFIG_SBC_EPX_C3_WATCHDOG is not set

#
# PCI-based Watchdog Cards
#
# CONFIG_PCIPCWATCHDOG is not set
# CONFIG_WDTPCI is not set

#
# USB-based Watchdog Cards
#
# CONFIG_USBPCWATCHDOG is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
# CONFIG_SSB is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
# CONFIG_BCMA is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_CS5535 is not set
CONFIG_MFD_AS3711=y
# CONFIG_PMIC_ADP5520 is not set
CONFIG_MFD_AAT2870_CORE=y
CONFIG_MFD_CROS_EC=y
# CONFIG_MFD_CROS_EC_I2C is not set
CONFIG_MFD_CROS_EC_SPI=y
# CONFIG_PMIC_DA903X is not set
CONFIG_PMIC_DA9052=y
# CONFIG_MFD_DA9052_SPI is not set
CONFIG_MFD_DA9052_I2C=y
CONFIG_MFD_DA9055=y
CONFIG_MFD_MC13783=y
CONFIG_MFD_MC13XXX=y
# CONFIG_MFD_MC13XXX_SPI is not set
CONFIG_MFD_MC13XXX_I2C=y
CONFIG_HTC_PASIC3=y
CONFIG_HTC_I2CPLD=y
# CONFIG_LPC_ICH is not set
# CONFIG_LPC_SCH is not set
# CONFIG_MFD_JANZ_CMODIO is not set
CONFIG_MFD_88PM800=y
# CONFIG_MFD_88PM805 is not set
# CONFIG_MFD_88PM860X is not set
# CONFIG_MFD_MAX77686 is not set
CONFIG_MFD_MAX77693=y
# CONFIG_MFD_MAX8907 is not set
CONFIG_MFD_MAX8925=y
CONFIG_MFD_MAX8997=y
# CONFIG_MFD_MAX8998 is not set
CONFIG_EZX_PCAP=y
# CONFIG_MFD_VIPERBOARD is not set
CONFIG_MFD_RETU=y
CONFIG_MFD_PCF50633=y
CONFIG_PCF50633_ADC=y
CONFIG_PCF50633_GPIO=y
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_RTSX_PCI is not set
# CONFIG_MFD_RC5T583 is not set
# CONFIG_MFD_SEC_CORE is not set
CONFIG_MFD_SI476X_CORE=y
CONFIG_MFD_SM501=y
CONFIG_MFD_SM501_GPIO=y
CONFIG_MFD_SMSC=y
# CONFIG_ABX500_CORE is not set
# CONFIG_MFD_STMPE is not set
# CONFIG_MFD_SYSCON is not set
# CONFIG_MFD_TI_AM335X_TSCADC is not set
CONFIG_MFD_LP8788=y
# CONFIG_MFD_PALMAS is not set
CONFIG_TPS6105X=y
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=y
# CONFIG_MFD_TPS65090 is not set
CONFIG_MFD_TPS65217=y
CONFIG_MFD_TPS6586X=y
# CONFIG_MFD_TPS65910 is not set
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_I2C=y
CONFIG_MFD_TPS65912_SPI=y
# CONFIG_MFD_TPS80031 is not set
# CONFIG_TWL4030_CORE is not set
# CONFIG_TWL6040_CORE is not set
CONFIG_MFD_WL1273_CORE=y
CONFIG_MFD_LM3533=y
# CONFIG_MFD_TIMBERDALE is not set
CONFIG_MFD_TC3589X=y
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_VX855 is not set
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=y
CONFIG_MFD_ARIZONA_SPI=y
# CONFIG_MFD_WM5102 is not set
# CONFIG_MFD_WM5110 is not set
CONFIG_MFD_WM8400=y
CONFIG_MFD_WM831X=y
CONFIG_MFD_WM831X_I2C=y
CONFIG_MFD_WM831X_SPI=y
CONFIG_MFD_WM8350=y
CONFIG_MFD_WM8350_I2C=y
CONFIG_MFD_WM8994=y
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
CONFIG_REGULATOR_DUMMY=y
CONFIG_REGULATOR_FIXED_VOLTAGE=y
CONFIG_REGULATOR_VIRTUAL_CONSUMER=y
CONFIG_REGULATOR_USERSPACE_CONSUMER=y
CONFIG_REGULATOR_GPIO=y
CONFIG_REGULATOR_AD5398=y
# CONFIG_REGULATOR_AAT2870 is not set
# CONFIG_REGULATOR_DA9052 is not set
# CONFIG_REGULATOR_DA9055 is not set
CONFIG_REGULATOR_FAN53555=y
CONFIG_REGULATOR_MC13XXX_CORE=y
CONFIG_REGULATOR_MC13783=y
# CONFIG_REGULATOR_MC13892 is not set
CONFIG_REGULATOR_ISL6271A=y
# CONFIG_REGULATOR_MAX1586 is not set
CONFIG_REGULATOR_MAX8649=y
CONFIG_REGULATOR_MAX8660=y
CONFIG_REGULATOR_MAX8925=y
CONFIG_REGULATOR_MAX8952=y
# CONFIG_REGULATOR_MAX8973 is not set
# CONFIG_REGULATOR_MAX8997 is not set
# CONFIG_REGULATOR_PCAP is not set
CONFIG_REGULATOR_LP3971=y
CONFIG_REGULATOR_LP3972=y
CONFIG_REGULATOR_LP872X=y
# CONFIG_REGULATOR_LP8755 is not set
CONFIG_REGULATOR_LP8788=y
CONFIG_REGULATOR_PCF50633=y
# CONFIG_REGULATOR_TPS51632 is not set
CONFIG_REGULATOR_TPS6105X=y
CONFIG_REGULATOR_TPS62360=y
CONFIG_REGULATOR_TPS65023=y
# CONFIG_REGULATOR_TPS6507X is not set
# CONFIG_REGULATOR_TPS65217 is not set
# CONFIG_REGULATOR_TPS6524X is not set
# CONFIG_REGULATOR_TPS6586X is not set
CONFIG_REGULATOR_TPS65912=y
# CONFIG_REGULATOR_WM831X is not set
CONFIG_REGULATOR_WM8350=y
CONFIG_REGULATOR_WM8400=y
CONFIG_REGULATOR_WM8994=y
CONFIG_REGULATOR_AS3711=y
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
# CONFIG_MEDIA_CAMERA_SUPPORT is not set
CONFIG_MEDIA_ANALOG_TV_SUPPORT=y
# CONFIG_MEDIA_DIGITAL_TV_SUPPORT is not set
CONFIG_MEDIA_RADIO_SUPPORT=y
# CONFIG_MEDIA_RC_SUPPORT is not set
CONFIG_VIDEO_DEV=y
CONFIG_VIDEO_V4L2=y
# CONFIG_VIDEO_ADV_DEBUG is not set
CONFIG_VIDEO_FIXED_MINOR_RANGES=y
CONFIG_VIDEO_V4L2_INT_DEVICE=y
# CONFIG_TTPCI_EEPROM is not set

#
# Media drivers
#
# CONFIG_MEDIA_USB_SUPPORT is not set
# CONFIG_MEDIA_PCI_SUPPORT is not set

#
# Supported MMC/SDIO adapters
#
# CONFIG_RADIO_ADAPTERS is not set
# CONFIG_CYPRESS_FIRMWARE is not set

#
# Media ancillary drivers (tuners, sensors, i2c, frontends)
#
CONFIG_MEDIA_SUBDRV_AUTOSELECT=y

#
# Audio decoders, processors and mixers
#

#
# RDS decoders
#

#
# Video decoders
#

#
# Video and audio decoders
#

#
# Video encoders
#

#
# Camera sensor devices
#

#
# Flash devices
#

#
# Video improvement chips
#

#
# Miscelaneous helper chips
#

#
# Sensors used on soc_camera driver
#
CONFIG_MEDIA_TUNER=y
CONFIG_MEDIA_TUNER_SIMPLE=y
CONFIG_MEDIA_TUNER_TDA8290=y
CONFIG_MEDIA_TUNER_TDA827X=y
CONFIG_MEDIA_TUNER_TDA18271=y
CONFIG_MEDIA_TUNER_TDA9887=y
CONFIG_MEDIA_TUNER_TEA5761=y
CONFIG_MEDIA_TUNER_TEA5767=y
CONFIG_MEDIA_TUNER_MT20XX=y
CONFIG_MEDIA_TUNER_XC2028=y
CONFIG_MEDIA_TUNER_XC5000=y
CONFIG_MEDIA_TUNER_XC4000=y
CONFIG_MEDIA_TUNER_MC44S803=y

#
# Tools to develop new frontends
#
# CONFIG_DVB_DUMMY_FE is not set

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
CONFIG_DRM=y
# CONFIG_DRM_TDFX is not set
# CONFIG_DRM_R128 is not set
# CONFIG_DRM_RADEON is not set
# CONFIG_DRM_NOUVEAU is not set
# CONFIG_DRM_MGA is not set
# CONFIG_DRM_VIA is not set
# CONFIG_DRM_SAVAGE is not set
# CONFIG_DRM_VMWGFX is not set
# CONFIG_DRM_GMA500 is not set
# CONFIG_DRM_UDL is not set
# CONFIG_DRM_AST is not set
# CONFIG_DRM_MGAG200 is not set
# CONFIG_DRM_CIRRUS_QEMU is not set
# CONFIG_DRM_QXL is not set
# CONFIG_VGASTATE is not set
# CONFIG_VIDEO_OUTPUT_CONTROL is not set
CONFIG_HDMI=y
CONFIG_FB=y
CONFIG_FIRMWARE_EDID=y
# CONFIG_FB_DDC is not set
# CONFIG_FB_BOOT_VESA_SUPPORT is not set
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
# CONFIG_FB_FOREIGN_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_HECUBA=y
# CONFIG_FB_SVGALIB is not set
# CONFIG_FB_MACMODES is not set
# CONFIG_FB_BACKLIGHT is not set
CONFIG_FB_MODE_HELPERS=y
# CONFIG_FB_TILEBLITTING is not set

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
# CONFIG_FB_ARC is not set
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_VESA is not set
CONFIG_FB_N411=y
# CONFIG_FB_HGA is not set
CONFIG_FB_S1D13XXX=y
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_I740 is not set
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_MATROX is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
# CONFIG_FB_SIS is not set
# CONFIG_FB_VIA is not set
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
# CONFIG_FB_PM3 is not set
# CONFIG_FB_CARMINE is not set
# CONFIG_FB_GEODE is not set
CONFIG_FB_TMIO=y
# CONFIG_FB_TMIO_ACCELL is not set
CONFIG_FB_SM501=y
CONFIG_FB_SMSCUFX=y
CONFIG_FB_UDL=y
# CONFIG_FB_GOLDFISH is not set
# CONFIG_FB_VIRTUAL is not set
CONFIG_FB_METRONOME=y
# CONFIG_FB_MB862XX is not set
CONFIG_FB_BROADSHEET=y
# CONFIG_FB_AUO_K190X is not set
# CONFIG_EXYNOS_VIDEO is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
# CONFIG_LCD_L4F00242T03 is not set
CONFIG_LCD_LMS283GF05=y
CONFIG_LCD_LTV350QV=y
# CONFIG_LCD_ILI922X is not set
CONFIG_LCD_ILI9320=y
# CONFIG_LCD_TDO24M is not set
CONFIG_LCD_VGG2432A4=y
CONFIG_LCD_PLATFORM=y
# CONFIG_LCD_S6E63M0 is not set
# CONFIG_LCD_LD9040 is not set
CONFIG_LCD_AMS369FG06=y
CONFIG_LCD_LMS501KF03=y
CONFIG_LCD_HX8357=y
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=y
CONFIG_BACKLIGHT_LM3533=y
CONFIG_BACKLIGHT_DA9052=y
# CONFIG_BACKLIGHT_MAX8925 is not set
# CONFIG_BACKLIGHT_APPLE is not set
# CONFIG_BACKLIGHT_SAHARA is not set
CONFIG_BACKLIGHT_WM831X=y
CONFIG_BACKLIGHT_ADP8860=y
# CONFIG_BACKLIGHT_ADP8870 is not set
CONFIG_BACKLIGHT_PCF50633=y
CONFIG_BACKLIGHT_AAT2870=y
# CONFIG_BACKLIGHT_LM3630 is not set
# CONFIG_BACKLIGHT_LM3639 is not set
CONFIG_BACKLIGHT_LP855X=y
CONFIG_BACKLIGHT_LP8788=y
CONFIG_BACKLIGHT_TPS65217=y
CONFIG_BACKLIGHT_AS3711=y

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
CONFIG_VGACON_SOFT_SCROLLBACK=y
CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=64
CONFIG_DUMMY_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=y
CONFIG_FRAMEBUFFER_CONSOLE_ROTATION=y
CONFIG_FONTS=y
CONFIG_FONT_8x8=y
CONFIG_FONT_8x16=y
CONFIG_FONT_6x11=y
# CONFIG_FONT_7x14 is not set
CONFIG_FONT_PEARL_8x8=y
CONFIG_FONT_ACORN_8x8=y
# CONFIG_FONT_MINI_4x6 is not set
CONFIG_FONT_SUN8x16=y
# CONFIG_FONT_SUN12x22 is not set
# CONFIG_FONT_10x18 is not set
CONFIG_LOGO=y
# CONFIG_LOGO_LINUX_MONO is not set
CONFIG_LOGO_LINUX_VGA16=y
CONFIG_LOGO_LINUX_CLUT224=y
CONFIG_SOUND=y
# CONFIG_SOUND_OSS_CORE is not set
# CONFIG_SND is not set
# CONFIG_SOUND_PRIME is not set

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
# CONFIG_HIDRAW is not set
CONFIG_UHID=y
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
CONFIG_HID_ACRUX=y
CONFIG_HID_ACRUX_FF=y
CONFIG_HID_APPLE=y
CONFIG_HID_APPLEIR=y
CONFIG_HID_AUREAL=y
CONFIG_HID_BELKIN=y
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
CONFIG_HID_CYPRESS=y
# CONFIG_HID_DRAGONRISE is not set
CONFIG_HID_EMS_FF=y
CONFIG_HID_ELECOM=y
CONFIG_HID_EZKEY=y
CONFIG_HID_HOLTEK=y
CONFIG_HOLTEK_FF=y
# CONFIG_HID_KEYTOUCH is not set
# CONFIG_HID_KYE is not set
# CONFIG_HID_UCLOGIC is not set
# CONFIG_HID_WALTOP is not set
CONFIG_HID_GYRATION=y
CONFIG_HID_ICADE=y
CONFIG_HID_TWINHAN=y
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LCPOWER=y
CONFIG_HID_LENOVO_TPKBD=y
CONFIG_HID_LOGITECH=y
CONFIG_HID_LOGITECH_DJ=y
CONFIG_LOGITECH_FF=y
CONFIG_LOGIRUMBLEPAD2_FF=y
CONFIG_LOGIG940_FF=y
CONFIG_LOGIWHEELS_FF=y
# CONFIG_HID_MAGICMOUSE is not set
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
CONFIG_HID_MULTITOUCH=y
CONFIG_HID_NTRIG=y
CONFIG_HID_ORTEK=y
CONFIG_HID_PANTHERLORD=y
CONFIG_PANTHERLORD_FF=y
CONFIG_HID_PETALYNX=y
CONFIG_HID_PICOLCD=y
CONFIG_HID_PICOLCD_FB=y
CONFIG_HID_PICOLCD_BACKLIGHT=y
CONFIG_HID_PICOLCD_LCD=y
CONFIG_HID_PICOLCD_LEDS=y
CONFIG_HID_PRIMAX=y
# CONFIG_HID_PS3REMOTE is not set
CONFIG_HID_ROCCAT=y
CONFIG_HID_SAITEK=y
# CONFIG_HID_SAMSUNG is not set
# CONFIG_HID_SONY is not set
# CONFIG_HID_SPEEDLINK is not set
CONFIG_HID_STEELSERIES=y
# CONFIG_HID_SUNPLUS is not set
CONFIG_HID_GREENASIA=y
CONFIG_GREENASIA_FF=y
CONFIG_HID_SMARTJOYPLUS=y
# CONFIG_SMARTJOYPLUS_FF is not set
CONFIG_HID_TIVO=y
CONFIG_HID_TOPSEED=y
# CONFIG_HID_THINGM is not set
# CONFIG_HID_THRUSTMASTER is not set
# CONFIG_HID_WACOM is not set
# CONFIG_HID_WIIMOTE is not set
# CONFIG_HID_ZEROPLUS is not set
CONFIG_HID_ZYDACRON=y
# CONFIG_HID_SENSOR_HUB is not set

#
# USB HID support
#
CONFIG_USB_HID=y
# CONFIG_HID_PID is not set
# CONFIG_USB_HIDDEV is not set

#
# I2C HID support
#
CONFIG_I2C_HID=y
CONFIG_USB_ARCH_HAS_OHCI=y
CONFIG_USB_ARCH_HAS_EHCI=y
CONFIG_USB_ARCH_HAS_XHCI=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
# CONFIG_USB_DEBUG is not set
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y

#
# Miscellaneous USB options
#
CONFIG_USB_DEFAULT_PERSIST=y
CONFIG_USB_DYNAMIC_MINORS=y
CONFIG_USB_MON=y
CONFIG_USB_WUSB_CBAF=y
CONFIG_USB_WUSB_CBAF_DEBUG=y

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
# CONFIG_USB_XHCI_HCD is not set
# CONFIG_USB_EHCI_HCD is not set
# CONFIG_USB_OXU210HP_HCD is not set
# CONFIG_USB_ISP116X_HCD is not set
# CONFIG_USB_ISP1760_HCD is not set
# CONFIG_USB_ISP1362_HCD is not set
# CONFIG_USB_OHCI_HCD is not set
# CONFIG_USB_UHCI_HCD is not set
# CONFIG_USB_U132_HCD is not set
CONFIG_USB_SL811_HCD=y
# CONFIG_USB_SL811_HCD_ISO is not set
CONFIG_USB_SL811_CS=y
# CONFIG_USB_R8A66597_HCD is not set
# CONFIG_USB_RENESAS_USBHS_HCD is not set
CONFIG_USB_MUSB_HDRC=y
CONFIG_USB_MUSB_TUSB6010=y
# CONFIG_USB_MUSB_DSPS is not set
# CONFIG_USB_MUSB_UX500 is not set
CONFIG_MUSB_PIO_ONLY=y
CONFIG_USB_RENESAS_USBHS=y

#
# USB Device Class drivers
#
CONFIG_USB_ACM=y
CONFIG_USB_PRINTER=y
# CONFIG_USB_WDM is not set
# CONFIG_USB_TMC is not set

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
# CONFIG_USB_STORAGE is not set

#
# USB Imaging devices
#
CONFIG_USB_MDC800=y
# CONFIG_USB_MICROTEK is not set
CONFIG_USB_DWC3=y
# CONFIG_USB_DWC3_HOST is not set
CONFIG_USB_DWC3_GADGET=y
# CONFIG_USB_DWC3_DUAL_ROLE is not set
CONFIG_USB_DWC3_DEBUG=y
CONFIG_USB_DWC3_VERBOSE=y
# CONFIG_USB_CHIPIDEA is not set

#
# USB port drivers
#
CONFIG_USB_USS720=y
CONFIG_USB_SERIAL=y
# CONFIG_USB_SERIAL_CONSOLE is not set
# CONFIG_USB_SERIAL_GENERIC is not set
CONFIG_USB_SERIAL_AIRCABLE=y
# CONFIG_USB_SERIAL_ARK3116 is not set
CONFIG_USB_SERIAL_BELKIN=y
CONFIG_USB_SERIAL_CH341=y
# CONFIG_USB_SERIAL_WHITEHEAT is not set
CONFIG_USB_SERIAL_DIGI_ACCELEPORT=y
CONFIG_USB_SERIAL_CP210X=y
CONFIG_USB_SERIAL_CYPRESS_M8=y
CONFIG_USB_SERIAL_EMPEG=y
CONFIG_USB_SERIAL_FTDI_SIO=y
# CONFIG_USB_SERIAL_FUNSOFT is not set
CONFIG_USB_SERIAL_VISOR=y
CONFIG_USB_SERIAL_IPAQ=y
CONFIG_USB_SERIAL_IR=y
# CONFIG_USB_SERIAL_EDGEPORT is not set
# CONFIG_USB_SERIAL_EDGEPORT_TI is not set
CONFIG_USB_SERIAL_F81232=y
CONFIG_USB_SERIAL_GARMIN=y
# CONFIG_USB_SERIAL_IPW is not set
# CONFIG_USB_SERIAL_IUU is not set
# CONFIG_USB_SERIAL_KEYSPAN_PDA is not set
# CONFIG_USB_SERIAL_KEYSPAN is not set
CONFIG_USB_SERIAL_KLSI=y
CONFIG_USB_SERIAL_KOBIL_SCT=y
# CONFIG_USB_SERIAL_MCT_U232 is not set
CONFIG_USB_SERIAL_METRO=y
CONFIG_USB_SERIAL_MOS7720=y
# CONFIG_USB_SERIAL_MOS7715_PARPORT is not set
# CONFIG_USB_SERIAL_MOS7840 is not set
CONFIG_USB_SERIAL_MOTOROLA=y
CONFIG_USB_SERIAL_NAVMAN=y
# CONFIG_USB_SERIAL_PL2303 is not set
# CONFIG_USB_SERIAL_OTI6858 is not set
# CONFIG_USB_SERIAL_QCAUX is not set
CONFIG_USB_SERIAL_QUALCOMM=y
CONFIG_USB_SERIAL_SPCP8X5=y
CONFIG_USB_SERIAL_HP4X=y
CONFIG_USB_SERIAL_SAFE=y
# CONFIG_USB_SERIAL_SAFE_PADDED is not set
CONFIG_USB_SERIAL_SIEMENS_MPI=y
# CONFIG_USB_SERIAL_SIERRAWIRELESS is not set
CONFIG_USB_SERIAL_SYMBOL=y
CONFIG_USB_SERIAL_TI=y
CONFIG_USB_SERIAL_CYBERJACK=y
# CONFIG_USB_SERIAL_XIRCOM is not set
CONFIG_USB_SERIAL_WWAN=y
# CONFIG_USB_SERIAL_OPTION is not set
# CONFIG_USB_SERIAL_OMNINET is not set
CONFIG_USB_SERIAL_OPTICON=y
# CONFIG_USB_SERIAL_VIVOPAY_SERIAL is not set
# CONFIG_USB_SERIAL_XSENS_MT is not set
# CONFIG_USB_SERIAL_ZIO is not set
CONFIG_USB_SERIAL_WISHBONE=y
CONFIG_USB_SERIAL_ZTE=y
# CONFIG_USB_SERIAL_SSU100 is not set
CONFIG_USB_SERIAL_QT2=y
# CONFIG_USB_SERIAL_DEBUG is not set

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=y
# CONFIG_USB_EMI26 is not set
# CONFIG_USB_ADUTUX is not set
CONFIG_USB_SEVSEG=y
# CONFIG_USB_RIO500 is not set
CONFIG_USB_LEGOTOWER=y
CONFIG_USB_LCD=y
# CONFIG_USB_LED is not set
CONFIG_USB_CYPRESS_CY7C63=y
# CONFIG_USB_CYTHERM is not set
CONFIG_USB_IDMOUSE=y
CONFIG_USB_FTDI_ELAN=y
CONFIG_USB_APPLEDISPLAY=y
CONFIG_USB_SISUSBVGA=y
CONFIG_USB_SISUSBVGA_CON=y
# CONFIG_USB_LD is not set
# CONFIG_USB_TRANCEVIBRATOR is not set
# CONFIG_USB_IOWARRIOR is not set
CONFIG_USB_TEST=y
CONFIG_USB_ISIGHTFW=y
# CONFIG_USB_YUREX is not set
# CONFIG_USB_EZUSB_FX2 is not set
# CONFIG_USB_HSIC_USB3503 is not set
CONFIG_USB_PHY=y
CONFIG_NOP_USB_XCEIV=y
CONFIG_OMAP_CONTROL_USB=y
CONFIG_OMAP_USB3=y
CONFIG_SAMSUNG_USBPHY=y
CONFIG_SAMSUNG_USB2PHY=y
# CONFIG_SAMSUNG_USB3PHY is not set
CONFIG_USB_GPIO_VBUS=y
CONFIG_USB_ISP1301=y
CONFIG_USB_RCAR_PHY=y
CONFIG_USB_GADGET=y
# CONFIG_USB_GADGET_DEBUG is not set
# CONFIG_USB_GADGET_DEBUG_FILES is not set
CONFIG_USB_GADGET_DEBUG_FS=y
CONFIG_USB_GADGET_VBUS_DRAW=2
CONFIG_USB_GADGET_STORAGE_NUM_BUFFERS=2

#
# USB Peripheral Controller
#
# CONFIG_USB_R8A66597 is not set
# CONFIG_USB_RENESAS_USBHS_UDC is not set
CONFIG_USB_PXA27X=y
# CONFIG_USB_MV_UDC is not set
CONFIG_USB_MV_U3D=y
# CONFIG_USB_GADGET_MUSB_HDRC is not set
# CONFIG_USB_M66592 is not set
# CONFIG_USB_AMD5536UDC is not set
CONFIG_USB_NET2272=y
# CONFIG_USB_NET2272_DMA is not set
# CONFIG_USB_NET2280 is not set
# CONFIG_USB_GOKU is not set
# CONFIG_USB_EG20T is not set
# CONFIG_USB_DUMMY_HCD is not set
CONFIG_USB_LIBCOMPOSITE=y
# CONFIG_USB_ZERO is not set
CONFIG_USB_ETH=y
# CONFIG_USB_ETH_RNDIS is not set
# CONFIG_USB_ETH_EEM is not set
# CONFIG_USB_G_NCM is not set
# CONFIG_USB_GADGETFS is not set
# CONFIG_USB_FUNCTIONFS is not set
# CONFIG_USB_MASS_STORAGE is not set
# CONFIG_USB_G_SERIAL is not set
# CONFIG_USB_G_PRINTER is not set
# CONFIG_USB_CDC_COMPOSITE is not set
# CONFIG_USB_G_NOKIA is not set
# CONFIG_USB_G_ACM_MS is not set
# CONFIG_USB_G_MULTI is not set
# CONFIG_USB_G_HID is not set
# CONFIG_USB_G_DBGP is not set
# CONFIG_USB_G_WEBCAM is not set
# CONFIG_UWB is not set
CONFIG_MMC=y
# CONFIG_MMC_DEBUG is not set
CONFIG_MMC_UNSAFE_RESUME=y
# CONFIG_MMC_CLKGATE is not set

#
# MMC/SD/SDIO Card Drivers
#
CONFIG_MMC_BLOCK=y
CONFIG_MMC_BLOCK_MINORS=8
# CONFIG_MMC_BLOCK_BOUNCE is not set
CONFIG_SDIO_UART=y
# CONFIG_MMC_TEST is not set

#
# MMC/SD/SDIO Host Controller Drivers
#
CONFIG_MMC_SDHCI=y
# CONFIG_MMC_SDHCI_PCI is not set
# CONFIG_MMC_SDHCI_ACPI is not set
CONFIG_MMC_SDHCI_PLTFM=y
CONFIG_MMC_WBSD=y
# CONFIG_MMC_TIFM_SD is not set
CONFIG_MMC_SPI=y
# CONFIG_MMC_SDRICOH_CS is not set
# CONFIG_MMC_CB710 is not set
# CONFIG_MMC_VIA_SDMMC is not set
# CONFIG_MMC_VUB300 is not set
# CONFIG_MMC_USHC is not set
CONFIG_MEMSTICK=y
# CONFIG_MEMSTICK_DEBUG is not set

#
# MemoryStick drivers
#
CONFIG_MEMSTICK_UNSAFE_RESUME=y
# CONFIG_MSPRO_BLOCK is not set

#
# MemoryStick Host Controller Drivers
#
# CONFIG_MEMSTICK_TIFM_MS is not set
# CONFIG_MEMSTICK_JMICRON_38X is not set
# CONFIG_MEMSTICK_R592 is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
CONFIG_LEDS_LM3530=y
CONFIG_LEDS_LM3533=y
# CONFIG_LEDS_LM3642 is not set
CONFIG_LEDS_PCA9532=y
CONFIG_LEDS_PCA9532_GPIO=y
CONFIG_LEDS_GPIO=y
# CONFIG_LEDS_LP3944 is not set
CONFIG_LEDS_LP55XX_COMMON=y
CONFIG_LEDS_LP5521=y
CONFIG_LEDS_LP5523=y
# CONFIG_LEDS_LP5562 is not set
CONFIG_LEDS_LP8788=y
CONFIG_LEDS_CLEVO_MAIL=y
CONFIG_LEDS_PCA955X=y
CONFIG_LEDS_PCA9633=y
CONFIG_LEDS_WM831X_STATUS=y
# CONFIG_LEDS_WM8350 is not set
CONFIG_LEDS_DA9052=y
# CONFIG_LEDS_DAC124S085 is not set
CONFIG_LEDS_REGULATOR=y
# CONFIG_LEDS_BD2802 is not set
# CONFIG_LEDS_INTEL_SS4200 is not set
CONFIG_LEDS_LT3593=y
CONFIG_LEDS_MC13783=y
CONFIG_LEDS_TCA6507=y
CONFIG_LEDS_MAX8997=y
# CONFIG_LEDS_LM355x is not set
# CONFIG_LEDS_OT200 is not set
CONFIG_LEDS_BLINKM=y

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
# CONFIG_LEDS_TRIGGER_TIMER is not set
CONFIG_LEDS_TRIGGER_ONESHOT=y
# CONFIG_LEDS_TRIGGER_HEARTBEAT is not set
# CONFIG_LEDS_TRIGGER_BACKLIGHT is not set
# CONFIG_LEDS_TRIGGER_CPU is not set
CONFIG_LEDS_TRIGGER_GPIO=y
# CONFIG_LEDS_TRIGGER_DEFAULT_ON is not set

#
# iptables trigger is under Netfilter config (LED target)
#
CONFIG_LEDS_TRIGGER_TRANSIENT=y
CONFIG_LEDS_TRIGGER_CAMERA=y
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
CONFIG_EDAC=y
CONFIG_EDAC_LEGACY_SYSFS=y
# CONFIG_EDAC_DEBUG is not set
CONFIG_EDAC_MM_EDAC=y
# CONFIG_EDAC_E752X is not set
# CONFIG_EDAC_I82975X is not set
# CONFIG_EDAC_I3000 is not set
# CONFIG_EDAC_I3200 is not set
# CONFIG_EDAC_X38 is not set
# CONFIG_EDAC_I5400 is not set
# CONFIG_EDAC_I5000 is not set
# CONFIG_EDAC_I5100 is not set
# CONFIG_EDAC_I7300 is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
# CONFIG_RTC_SYSTOHC is not set
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
CONFIG_RTC_DEBUG=y

#
# RTC interfaces
#
# CONFIG_RTC_INTF_SYSFS is not set
CONFIG_RTC_INTF_PROC=y
# CONFIG_RTC_INTF_DEV is not set
CONFIG_RTC_DRV_TEST=y

#
# I2C RTC drivers
#
CONFIG_RTC_DRV_88PM80X=y
# CONFIG_RTC_DRV_DS1307 is not set
CONFIG_RTC_DRV_DS1374=y
CONFIG_RTC_DRV_DS1672=y
CONFIG_RTC_DRV_DS3232=y
CONFIG_RTC_DRV_LP8788=y
# CONFIG_RTC_DRV_MAX6900 is not set
CONFIG_RTC_DRV_MAX8925=y
CONFIG_RTC_DRV_MAX8997=y
CONFIG_RTC_DRV_RS5C372=y
CONFIG_RTC_DRV_ISL1208=y
CONFIG_RTC_DRV_ISL12022=y
# CONFIG_RTC_DRV_X1205 is not set
CONFIG_RTC_DRV_PCF8523=y
# CONFIG_RTC_DRV_PCF8563 is not set
CONFIG_RTC_DRV_PCF8583=y
CONFIG_RTC_DRV_M41T80=y
CONFIG_RTC_DRV_M41T80_WDT=y
CONFIG_RTC_DRV_BQ32K=y
# CONFIG_RTC_DRV_TPS6586X is not set
CONFIG_RTC_DRV_S35390A=y
# CONFIG_RTC_DRV_FM3130 is not set
# CONFIG_RTC_DRV_RX8581 is not set
CONFIG_RTC_DRV_RX8025=y
# CONFIG_RTC_DRV_EM3027 is not set
CONFIG_RTC_DRV_RV3029C2=y

#
# SPI RTC drivers
#
# CONFIG_RTC_DRV_M41T93 is not set
# CONFIG_RTC_DRV_M41T94 is not set
# CONFIG_RTC_DRV_DS1305 is not set
# CONFIG_RTC_DRV_DS1390 is not set
CONFIG_RTC_DRV_MAX6902=y
# CONFIG_RTC_DRV_R9701 is not set
# CONFIG_RTC_DRV_RS5C348 is not set
CONFIG_RTC_DRV_DS3234=y
# CONFIG_RTC_DRV_PCF2123 is not set
CONFIG_RTC_DRV_RX4581=y

#
# Platform RTC drivers
#
# CONFIG_RTC_DRV_CMOS is not set
CONFIG_RTC_DRV_DS1286=y
CONFIG_RTC_DRV_DS1511=y
CONFIG_RTC_DRV_DS1553=y
# CONFIG_RTC_DRV_DS1742 is not set
# CONFIG_RTC_DRV_DA9052 is not set
CONFIG_RTC_DRV_DA9055=y
CONFIG_RTC_DRV_STK17TA8=y
# CONFIG_RTC_DRV_M48T86 is not set
# CONFIG_RTC_DRV_M48T35 is not set
CONFIG_RTC_DRV_M48T59=y
CONFIG_RTC_DRV_MSM6242=y
CONFIG_RTC_DRV_BQ4802=y
# CONFIG_RTC_DRV_RP5C01 is not set
CONFIG_RTC_DRV_V3020=y
CONFIG_RTC_DRV_DS2404=y
CONFIG_RTC_DRV_WM831X=y
CONFIG_RTC_DRV_WM8350=y
CONFIG_RTC_DRV_PCF50633=y

#
# on-CPU RTC drivers
#
CONFIG_RTC_DRV_PCAP=y
CONFIG_RTC_DRV_MC13XXX=y

#
# HID Sensor RTC drivers
#
# CONFIG_RTC_DRV_HID_SENSOR_TIME is not set
# CONFIG_DMADEVICES is not set
# CONFIG_AUXDISPLAY is not set
CONFIG_UIO=y
# CONFIG_UIO_CIF is not set
CONFIG_UIO_PDRV=y
# CONFIG_UIO_PDRV_GENIRQ is not set
CONFIG_UIO_DMEM_GENIRQ=y
# CONFIG_UIO_AEC is not set
# CONFIG_UIO_SERCOS3 is not set
# CONFIG_UIO_PCI_GENERIC is not set
# CONFIG_UIO_NETX is not set
# CONFIG_VIRT_DRIVERS is not set
CONFIG_VIRTIO=y

#
# Virtio drivers
#
# CONFIG_VIRTIO_PCI is not set
# CONFIG_VIRTIO_BALLOON is not set
# CONFIG_VIRTIO_MMIO is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
CONFIG_STAGING=y
# CONFIG_SLICOSS is not set
CONFIG_USBIP_CORE=y
CONFIG_USBIP_VHCI_HCD=y
# CONFIG_USBIP_HOST is not set
CONFIG_USBIP_DEBUG=y
CONFIG_ECHO=y
# CONFIG_ASUS_OLED is not set
CONFIG_PANEL=y
CONFIG_PANEL_PARPORT=0
CONFIG_PANEL_PROFILE=5
CONFIG_PANEL_CHANGE_MESSAGE=y
CONFIG_PANEL_BOOT_MESSAGE=""
CONFIG_RTS5139=y
# CONFIG_RTS5139_DEBUG is not set
# CONFIG_TRANZPORT is not set
CONFIG_USB_SERIAL_QUATECH2=y
# CONFIG_DX_SEP is not set

#
# IIO staging drivers
#

#
# Accelerometers
#
CONFIG_ADIS16201=y
CONFIG_ADIS16203=y
CONFIG_ADIS16204=y
# CONFIG_ADIS16209 is not set
CONFIG_ADIS16220=y
# CONFIG_ADIS16240 is not set
# CONFIG_LIS3L02DQ is not set
CONFIG_SCA3000=y

#
# Analog to digital converters
#
CONFIG_AD7291=y
CONFIG_AD7606=y
# CONFIG_AD7606_IFACE_PARALLEL is not set
CONFIG_AD7606_IFACE_SPI=y
CONFIG_AD799X=y
CONFIG_AD799X_RING_BUFFER=y
CONFIG_AD7780=y
# CONFIG_AD7816 is not set
CONFIG_AD7192=y
# CONFIG_AD7280 is not set

#
# Analog digital bi-direction converters
#
# CONFIG_ADT7316 is not set

#
# Capacitance to digital converters
#
CONFIG_AD7150=y
CONFIG_AD7152=y
# CONFIG_AD7746 is not set

#
# Direct Digital Synthesis
#
CONFIG_AD5930=y
CONFIG_AD9832=y
CONFIG_AD9834=y
# CONFIG_AD9850 is not set
# CONFIG_AD9852 is not set
CONFIG_AD9910=y
CONFIG_AD9951=y

#
# Digital gyroscope sensors
#
CONFIG_ADIS16060=y
CONFIG_ADIS16130=y
# CONFIG_ADIS16260 is not set

#
# Network Analyzer, Impedance Converters
#
# CONFIG_AD5933 is not set

#
# Light sensors
#
# CONFIG_SENSORS_ISL29018 is not set
CONFIG_SENSORS_ISL29028=y
# CONFIG_TSL2583 is not set
# CONFIG_TSL2x7x is not set

#
# Magnetometer sensors
#
# CONFIG_SENSORS_HMC5843 is not set

#
# Active energy metering IC
#
# CONFIG_ADE7753 is not set
# CONFIG_ADE7754 is not set
CONFIG_ADE7758=y
CONFIG_ADE7759=y
CONFIG_ADE7854=y
CONFIG_ADE7854_I2C=y
CONFIG_ADE7854_SPI=y

#
# Resolver to digital converters
#
# CONFIG_AD2S90 is not set
CONFIG_AD2S1200=y
CONFIG_AD2S1210=y

#
# Triggers - standalone
#
CONFIG_IIO_PERIODIC_RTC_TRIGGER=y
CONFIG_IIO_GPIO_TRIGGER=y
CONFIG_IIO_SYSFS_TRIGGER=y
CONFIG_IIO_DUMMY_EVGEN=y
# CONFIG_IIO_SIMPLE_DUMMY is not set
CONFIG_IIO_SIMPLE_DUMMY_EVENTS=y
# CONFIG_IIO_SIMPLE_DUMMY_BUFFER is not set
# CONFIG_ZSMALLOC is not set
# CONFIG_FB_SM7XX is not set
# CONFIG_CRYSTALHD is not set
# CONFIG_FB_XGI is not set
# CONFIG_ACPI_QUICKSTART is not set
CONFIG_BCM_WIMAX=y
# CONFIG_FT1000 is not set

#
# Speakup console speech
#
CONFIG_SPEAKUP=y
CONFIG_SPEAKUP_SYNTH_ACNTSA=y
CONFIG_SPEAKUP_SYNTH_ACNTPC=y
CONFIG_SPEAKUP_SYNTH_APOLLO=y
# CONFIG_SPEAKUP_SYNTH_AUDPTR is not set
CONFIG_SPEAKUP_SYNTH_BNS=y
# CONFIG_SPEAKUP_SYNTH_DECTLK is not set
CONFIG_SPEAKUP_SYNTH_DECEXT=y
CONFIG_SPEAKUP_SYNTH_DTLK=y
CONFIG_SPEAKUP_SYNTH_KEYPC=y
# CONFIG_SPEAKUP_SYNTH_LTLK is not set
CONFIG_SPEAKUP_SYNTH_SOFT=y
# CONFIG_SPEAKUP_SYNTH_SPKOUT is not set
CONFIG_SPEAKUP_SYNTH_TXPRT=y
# CONFIG_SPEAKUP_SYNTH_DUMMY is not set
# CONFIG_TOUCHSCREEN_CLEARPAD_TM1217 is not set
CONFIG_TOUCHSCREEN_SYNAPTICS_I2C_RMI4=y
# CONFIG_STAGING_MEDIA is not set

#
# Android
#
# CONFIG_ANDROID is not set
# CONFIG_USB_WPAN_HCD is not set
CONFIG_WIMAX_GDM72XX=y
CONFIG_WIMAX_GDM72XX_QOS=y
CONFIG_WIMAX_GDM72XX_K_MODE=y
# CONFIG_WIMAX_GDM72XX_WIMAX2 is not set
CONFIG_WIMAX_GDM72XX_USB=y
# CONFIG_WIMAX_GDM72XX_SDIO is not set
# CONFIG_NET_VENDOR_SILICOM is not set
CONFIG_CED1401=y
CONFIG_DGRP=y
CONFIG_USB_DWC2=y
CONFIG_USB_DWC2_DEBUG=y
CONFIG_USB_DWC2_VERBOSE=y
# CONFIG_USB_DWC2_TRACK_MISSED_SOFS is not set
# CONFIG_USB_DWC2_DEBUG_PERIODIC is not set
# CONFIG_X86_PLATFORM_DEVICES is not set

#
# Hardware Spinlock drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
# CONFIG_MAILBOX is not set
# CONFIG_IOMMU_SUPPORT is not set

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=y
CONFIG_STE_MODEM_RPROC=y

#
# Rpmsg drivers
#
# CONFIG_PM_DEVFREQ is not set
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
CONFIG_EXTCON_GPIO=y
CONFIG_EXTCON_ADC_JACK=y
CONFIG_EXTCON_MAX77693=y
# CONFIG_EXTCON_MAX8997 is not set
# CONFIG_MEMORY is not set
CONFIG_IIO=y
CONFIG_IIO_BUFFER=y
# CONFIG_IIO_BUFFER_CB is not set
CONFIG_IIO_KFIFO_BUF=y
CONFIG_IIO_TRIGGERED_BUFFER=y
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2

#
# Accelerometers
#
# CONFIG_KXSD9 is not set
CONFIG_IIO_ST_ACCEL_3AXIS=y
CONFIG_IIO_ST_ACCEL_I2C_3AXIS=y
CONFIG_IIO_ST_ACCEL_SPI_3AXIS=y

#
# Analog to digital converters
#
CONFIG_AD_SIGMA_DELTA=y
CONFIG_AD7266=y
CONFIG_AD7298=y
CONFIG_AD7923=y
# CONFIG_AD7791 is not set
CONFIG_AD7793=y
CONFIG_AD7476=y
# CONFIG_AD7887 is not set
CONFIG_LP8788_ADC=y
# CONFIG_MAX1363 is not set
CONFIG_TI_ADC081C=y

#
# Amplifiers
#
# CONFIG_AD8366 is not set

#
# Hid Sensor IIO Common
#
CONFIG_IIO_ST_SENSORS_I2C=y
CONFIG_IIO_ST_SENSORS_SPI=y
CONFIG_IIO_ST_SENSORS_CORE=y

#
# Digital to analog converters
#
CONFIG_AD5064=y
CONFIG_AD5360=y
CONFIG_AD5380=y
# CONFIG_AD5421 is not set
# CONFIG_AD5624R_SPI is not set
# CONFIG_AD5446 is not set
CONFIG_AD5449=y
CONFIG_AD5504=y
CONFIG_AD5755=y
CONFIG_AD5764=y
CONFIG_AD5791=y
CONFIG_AD5686=y
CONFIG_MAX517=y
CONFIG_MCP4725=y

#
# Frequency Synthesizers DDS/PLL
#

#
# Clock Generator/Distribution
#
CONFIG_AD9523=y

#
# Phase-Locked Loop (PLL) frequency synthesizers
#
CONFIG_ADF4350=y

#
# Digital gyroscope sensors
#
# CONFIG_ADIS16080 is not set
CONFIG_ADIS16136=y
CONFIG_ADXRS450=y
# CONFIG_IIO_ST_GYRO_3AXIS is not set
# CONFIG_ITG3200 is not set

#
# Inertial measurement units
#
CONFIG_ADIS16400=y
# CONFIG_ADIS16480 is not set
CONFIG_IIO_ADIS_LIB=y
CONFIG_IIO_ADIS_LIB_BUFFER=y
CONFIG_INV_MPU6050_IIO=y

#
# Light sensors
#
CONFIG_ADJD_S311=y
CONFIG_SENSORS_LM3533=y
CONFIG_SENSORS_TSL2563=y
# CONFIG_VCNL4000 is not set

#
# Magnetometer sensors
#
# CONFIG_AK8975 is not set
CONFIG_IIO_ST_MAGN_3AXIS=y
CONFIG_IIO_ST_MAGN_I2C_3AXIS=y
CONFIG_IIO_ST_MAGN_SPI_3AXIS=y
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set
# CONFIG_IPACK_BUS is not set
CONFIG_RESET_CONTROLLER=y

#
# Firmware Drivers
#
# CONFIG_EDD is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_DELL_RBU=y
# CONFIG_DCDBAS is not set
CONFIG_DMIID=y
CONFIG_DMI_SYSFS=y
CONFIG_ISCSI_IBFT_FIND=y
CONFIG_ISCSI_IBFT=y
# CONFIG_GOOGLE_FIRMWARE is not set

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
# CONFIG_EXT2_FS is not set
# CONFIG_EXT3_FS is not set
CONFIG_EXT4_FS=y
# CONFIG_EXT4_USE_FOR_EXT23 is not set
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
# CONFIG_EXT4_DEBUG is not set
CONFIG_JBD2=y
CONFIG_JBD2_DEBUG=y
CONFIG_FS_MBCACHE=y
# CONFIG_REISERFS_FS is not set
CONFIG_JFS_FS=y
CONFIG_JFS_POSIX_ACL=y
CONFIG_JFS_SECURITY=y
CONFIG_JFS_DEBUG=y
# CONFIG_JFS_STATISTICS is not set
CONFIG_XFS_FS=y
CONFIG_XFS_QUOTA=y
CONFIG_XFS_POSIX_ACL=y
# CONFIG_XFS_RT is not set
CONFIG_XFS_WARN=y
# CONFIG_XFS_DEBUG is not set
CONFIG_GFS2_FS=y
# CONFIG_GFS2_FS_LOCKING_DLM is not set
CONFIG_OCFS2_FS=y
# CONFIG_OCFS2_FS_O2CB is not set
CONFIG_OCFS2_FS_USERSPACE_CLUSTER=y
# CONFIG_OCFS2_FS_STATS is not set
# CONFIG_OCFS2_DEBUG_MASKLOG is not set
# CONFIG_OCFS2_DEBUG_FS is not set
CONFIG_BTRFS_FS=y
# CONFIG_BTRFS_FS_POSIX_ACL is not set
CONFIG_BTRFS_FS_CHECK_INTEGRITY=y
CONFIG_BTRFS_FS_RUN_SANITY_TESTS=y
CONFIG_BTRFS_DEBUG=y
# CONFIG_NILFS2_FS is not set
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
# CONFIG_INOTIFY_USER is not set
CONFIG_FANOTIFY=y
CONFIG_QUOTA=y
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
CONFIG_PRINT_QUOTA_WARNING=y
# CONFIG_QUOTA_DEBUG is not set
CONFIG_QUOTA_TREE=y
CONFIG_QFMT_V1=y
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
# CONFIG_AUTOFS4_FS is not set
CONFIG_FUSE_FS=y
CONFIG_CUSE=y

#
# Caches
#
# CONFIG_FSCACHE is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
CONFIG_JOLIET=y
CONFIG_ZISOFS=y
# CONFIG_UDF_FS is not set

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
# CONFIG_VFAT_FS is not set
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_NTFS_FS=y
# CONFIG_NTFS_DEBUG is not set
# CONFIG_NTFS_RW is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
# CONFIG_PROC_VMCORE is not set
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
# CONFIG_TMPFS_XATTR is not set
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
CONFIG_ADFS_FS=y
# CONFIG_ADFS_FS_RW is not set
# CONFIG_AFFS_FS is not set
# CONFIG_ECRYPT_FS is not set
CONFIG_HFS_FS=y
# CONFIG_HFSPLUS_FS is not set
# CONFIG_BEFS_FS is not set
CONFIG_BFS_FS=y
CONFIG_EFS_FS=y
CONFIG_JFFS2_FS=y
CONFIG_JFFS2_FS_DEBUG=0
# CONFIG_JFFS2_FS_WRITEBUFFER is not set
# CONFIG_JFFS2_SUMMARY is not set
CONFIG_JFFS2_FS_XATTR=y
# CONFIG_JFFS2_FS_POSIX_ACL is not set
# CONFIG_JFFS2_FS_SECURITY is not set
# CONFIG_JFFS2_COMPRESSION_OPTIONS is not set
CONFIG_JFFS2_ZLIB=y
# CONFIG_JFFS2_LZO is not set
CONFIG_JFFS2_RTIME=y
# CONFIG_JFFS2_RUBIN is not set
CONFIG_LOGFS=y
# CONFIG_CRAMFS is not set
CONFIG_SQUASHFS=y
CONFIG_SQUASHFS_XATTR=y
# CONFIG_SQUASHFS_ZLIB is not set
# CONFIG_SQUASHFS_LZO is not set
# CONFIG_SQUASHFS_XZ is not set
# CONFIG_SQUASHFS_4K_DEVBLK_SIZE is not set
CONFIG_SQUASHFS_EMBEDDED=y
CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3
CONFIG_VXFS_FS=y
CONFIG_MINIX_FS=y
CONFIG_OMFS_FS=y
CONFIG_HPFS_FS=y
CONFIG_QNX4FS_FS=y
# CONFIG_QNX6FS_FS is not set
# CONFIG_ROMFS_FS is not set
CONFIG_PSTORE=y
# CONFIG_PSTORE_CONSOLE is not set
CONFIG_PSTORE_RAM=y
CONFIG_SYSV_FS=y
CONFIG_UFS_FS=y
# CONFIG_UFS_FS_WRITE is not set
CONFIG_UFS_DEBUG=y
# CONFIG_F2FS_FS is not set
# CONFIG_NETWORK_FILESYSTEMS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_CODEPAGE_737=y
CONFIG_NLS_CODEPAGE_775=y
CONFIG_NLS_CODEPAGE_850=y
CONFIG_NLS_CODEPAGE_852=y
CONFIG_NLS_CODEPAGE_855=y
CONFIG_NLS_CODEPAGE_857=y
CONFIG_NLS_CODEPAGE_860=y
# CONFIG_NLS_CODEPAGE_861 is not set
CONFIG_NLS_CODEPAGE_862=y
# CONFIG_NLS_CODEPAGE_863 is not set
CONFIG_NLS_CODEPAGE_864=y
# CONFIG_NLS_CODEPAGE_865 is not set
# CONFIG_NLS_CODEPAGE_866 is not set
CONFIG_NLS_CODEPAGE_869=y
CONFIG_NLS_CODEPAGE_936=y
# CONFIG_NLS_CODEPAGE_950 is not set
CONFIG_NLS_CODEPAGE_932=y
# CONFIG_NLS_CODEPAGE_949 is not set
CONFIG_NLS_CODEPAGE_874=y
CONFIG_NLS_ISO8859_8=y
CONFIG_NLS_CODEPAGE_1250=y
CONFIG_NLS_CODEPAGE_1251=y
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=y
# CONFIG_NLS_ISO8859_2 is not set
CONFIG_NLS_ISO8859_3=y
CONFIG_NLS_ISO8859_4=y
CONFIG_NLS_ISO8859_5=y
CONFIG_NLS_ISO8859_6=y
CONFIG_NLS_ISO8859_7=y
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
CONFIG_NLS_ISO8859_14=y
# CONFIG_NLS_ISO8859_15 is not set
# CONFIG_NLS_KOI8_R is not set
CONFIG_NLS_KOI8_U=y
CONFIG_NLS_MAC_ROMAN=y
CONFIG_NLS_MAC_CELTIC=y
CONFIG_NLS_MAC_CENTEURO=y
CONFIG_NLS_MAC_CROATIAN=y
CONFIG_NLS_MAC_CYRILLIC=y
CONFIG_NLS_MAC_GAELIC=y
CONFIG_NLS_MAC_GREEK=y
CONFIG_NLS_MAC_ICELAND=y
CONFIG_NLS_MAC_INUIT=y
# CONFIG_NLS_MAC_ROMANIAN is not set
CONFIG_NLS_MAC_TURKISH=y
CONFIG_NLS_UTF8=y
CONFIG_DLM=y
CONFIG_DLM_DEBUG=y

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
CONFIG_PRINTK_TIME=y
CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
# CONFIG_ENABLE_WARN_DEPRECATED is not set
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=2048
CONFIG_MAGIC_SYSRQ=y
# CONFIG_STRIP_ASM_SYMS is not set
# CONFIG_READABLE_ASM is not set
# CONFIG_UNUSED_SYMBOLS is not set
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_DEBUG_KERNEL=y
# CONFIG_DEBUG_SHIRQ is not set
# CONFIG_LOCKUP_DETECTOR is not set
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
# CONFIG_DETECT_HUNG_TASK is not set
CONFIG_SCHED_DEBUG=y
# CONFIG_SCHEDSTATS is not set
# CONFIG_TIMER_STATS is not set
# CONFIG_DEBUG_OBJECTS is not set
CONFIG_SLUB_DEBUG_ON=y
# CONFIG_SLUB_STATS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_RT_MUTEX_TESTER is not set
# CONFIG_DEBUG_SPINLOCK is not set
# CONFIG_DEBUG_MUTEXES is not set
# CONFIG_DEBUG_LOCK_ALLOC is not set
# CONFIG_PROVE_LOCKING is not set
# CONFIG_LOCK_STAT is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
# CONFIG_DEBUG_STACK_USAGE is not set
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_INFO=y
# CONFIG_DEBUG_VM is not set
# CONFIG_DEBUG_VIRTUAL is not set
# CONFIG_DEBUG_WRITECOUNT is not set
CONFIG_DEBUG_MEMORY_INIT=y
# CONFIG_DEBUG_LIST is not set
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
# CONFIG_DEBUG_CREDENTIALS is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_BOOT_PRINTK_DELAY is not set

#
# RCU Debugging
#
CONFIG_SPARSE_RCU_POINTER=y
# CONFIG_RCU_TORTURE_TEST is not set
# CONFIG_RCU_TRACE is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
# CONFIG_LKDTM is not set
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
# CONFIG_FAULT_INJECTION is not set
# CONFIG_LATENCYTOP is not set
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
# CONFIG_DEBUG_PAGEALLOC is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
CONFIG_BUILD_DOCSRC=y
CONFIG_DYNAMIC_DEBUG=y
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_ATOMIC64_SELFTEST is not set
# CONFIG_ASYNC_RAID6_TEST is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_KMEMCHECK is not set
CONFIG_TEST_STRING_HELPERS=y
CONFIG_TEST_KSTRTOX=y
# CONFIG_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
# CONFIG_DEBUG_STACKOVERFLOW is not set
# CONFIG_X86_PTDUMP is not set
CONFIG_DEBUG_RODATA=y
CONFIG_DEBUG_RODATA_TEST=y
# CONFIG_DEBUG_TLBFLUSH is not set
# CONFIG_IOMMU_DEBUG is not set
# CONFIG_IOMMU_STRESS is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
CONFIG_IO_DELAY_0XED=y
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=1
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y
# CONFIG_DEBUG_NMI_SELFTEST is not set

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_TRUSTED_KEYS is not set
CONFIG_ENCRYPTED_KEYS=y
# CONFIG_KEYS_DEBUG_PROC_KEYS is not set
# CONFIG_SECURITY_DMESG_RESTRICT is not set
# CONFIG_SECURITY is not set
CONFIG_SECURITYFS=y
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_XOR_BLOCKS=y
CONFIG_ASYNC_CORE=y
CONFIG_ASYNC_MEMCPY=y
CONFIG_ASYNC_XOR=y
CONFIG_ASYNC_PQ=y
CONFIG_ASYNC_RAID6_RECOV=y
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_ABLK_HELPER_X86=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
# CONFIG_CRYPTO_CCM is not set
CONFIG_CRYPTO_GCM=y
CONFIG_CRYPTO_SEQIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
# CONFIG_CRYPTO_ECB is not set
CONFIG_CRYPTO_LRW=y
CONFIG_CRYPTO_PCBC=y
CONFIG_CRYPTO_XTS=y

#
# Hash modes
#
# CONFIG_CRYPTO_CMAC is not set
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=y
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
CONFIG_CRYPTO_CRC32=y
CONFIG_CRYPTO_CRC32_PCLMUL=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
# CONFIG_CRYPTO_RMD128 is not set
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=y
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=y
# CONFIG_CRYPTO_SHA256_SSSE3 is not set
CONFIG_CRYPTO_SHA512_SSSE3=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
# CONFIG_CRYPTO_TGR192 is not set
CONFIG_CRYPTO_WP512=y
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=y
CONFIG_CRYPTO_ANUBIS=y
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_BLOWFISH_X86_64=y
CONFIG_CRYPTO_BLOWFISH_AVX2_X86_64=y
# CONFIG_CRYPTO_CAMELLIA is not set
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64=y
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST5_AVX_X86_64=y
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_CAST6_AVX_X86_64=y
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_FCRYPT=y
CONFIG_CRYPTO_KHAZAD=y
CONFIG_CRYPTO_SALSA20=y
CONFIG_CRYPTO_SALSA20_X86_64=y
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX2_X86_64=y
CONFIG_CRYPTO_TEA=y
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=y
CONFIG_CRYPTO_TWOFISH_AVX2_X86_64=y

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
# CONFIG_CRYPTO_ZLIB is not set
CONFIG_CRYPTO_LZO=y

#
# Random Number Generation
#
# CONFIG_CRYPTO_ANSI_CPRNG is not set
CONFIG_CRYPTO_USER_API=y
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_USER_API_SKCIPHER=y
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_PADLOCK=y
# CONFIG_CRYPTO_DEV_PADLOCK_AES is not set
CONFIG_CRYPTO_DEV_PADLOCK_SHA=y
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
# CONFIG_PUBLIC_KEY_ALGO_RSA is not set
CONFIG_X509_CERTIFICATE_PARSER=y
CONFIG_HAVE_KVM=y
CONFIG_HAVE_KVM_IRQCHIP=y
CONFIG_HAVE_KVM_IRQ_ROUTING=y
CONFIG_HAVE_KVM_EVENTFD=y
CONFIG_KVM_APIC_ARCHITECTURE=y
CONFIG_KVM_MMIO=y
CONFIG_KVM_ASYNC_PF=y
CONFIG_HAVE_KVM_MSI=y
CONFIG_HAVE_KVM_CPU_RELAX_INTERCEPT=y
CONFIG_VIRTUALIZATION=y
CONFIG_KVM=y
CONFIG_KVM_INTEL=y
# CONFIG_KVM_AMD is not set
# CONFIG_BINARY_PRINTF is not set

#
# Library routines
#
CONFIG_RAID6_PQ=y
CONFIG_BITREVERSE=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
# CONFIG_CRC32_SLICEBY8 is not set
# CONFIG_CRC32_SLICEBY4 is not set
CONFIG_CRC32_SARWATE=y
# CONFIG_CRC32_BIT is not set
CONFIG_CRC7=y
CONFIG_LIBCRC32C=y
CONFIG_CRC8=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
# CONFIG_XZ_DEC_IA64 is not set
CONFIG_XZ_DEC_ARM=y
# CONFIG_XZ_DEC_ARMTHUMB is not set
# CONFIG_XZ_DEC_SPARC is not set
CONFIG_XZ_DEC_BCJ=y
# CONFIG_XZ_DEC_TEST is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=y
CONFIG_REED_SOLOMON_ENC8=y
CONFIG_REED_SOLOMON_DEC8=y
CONFIG_BCH=y
CONFIG_BCH_CONST_PARAMS=y
CONFIG_BTREE=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
CONFIG_AVERAGE=y
CONFIG_CLZ_TAB=y
CONFIG_CORDIC=y
CONFIG_DDR=y
CONFIG_MPILIB=y
CONFIG_OID_REGISTRY=y
# CONFIG_DRM_TTM is not set
# CONFIG_ISDN_DRV_LOOP is not set
# CONFIG_PCI_ATS is not set

--n8g4imXOkfNTN/H1--
