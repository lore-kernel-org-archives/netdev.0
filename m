From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [virtio-net] BUG: sleeping function called from invalid context at
	kernel/mutex.c:616
Date: Sun, 20 Oct 2013 10:34:18 +0800
Message-ID: <20131020023418.GA6737@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="3MwIy2ne0vdjdPXF"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


--3MwIy2ne0vdjdPXF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Greetings,

I got the below dmesg and the first bad commit is

commit 3ab098df35f8b98b6553edc2e40234af512ba877
Author: Jason Wang <jasowang@redhat.com>
Date:   Tue Oct 15 11:18:58 2013 +0800

    virtio-net: don't respond to cpu hotplug notifier if we're not ready
    
    We're trying to re-configure the affinity unconditionally in cpu hotplug
    callback. This may lead the issue during resuming from s3/s4 since
    
    - virt queues haven't been allocated at that time.
    - it's unnecessary since thaw method will re-configure the affinity.
    
    Fix this issue by checking the config_enable and do nothing is we're not ready.
    
    The bug were introduced by commit 8de4b2f3ae90c8fc0f17eeaab87d5a951b66ee17
    (virtio-net: reset virtqueue affinity when doing cpu hotplug).
    
    Cc: Rusty Russell <rusty@rustcorp.com.au>
    Cc: Michael S. Tsirkin <mst@redhat.com>
    Cc: Wanlong Gao <gaowanlong@cn.fujitsu.com>
    Acked-by: Michael S. Tsirkin <mst@redhat.com>
    Reviewed-by: Wanlong Gao <gaowanlong@cn.fujitsu.com>
    Signed-off-by: Jason Wang <jasowang@redhat.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

[  622.944441] CPU0 attaching NULL sched-domain.
[  622.944446] CPU1 attaching NULL sched-domain.
[  622.944485] CPU0 attaching NULL sched-domain.
[  622.950795] BUG: sleeping function called from invalid context at kernel/mutex.c:616
[  622.950796] in_atomic(): 1, irqs_disabled(): 1, pid: 10, name: migration/1
[  622.950796] no locks held by migration/1/10.
[  622.950798] CPU: 1 PID: 10 Comm: migration/1 Not tainted 3.12.0-rc5-wl-01249-gb91e82d #317
[  622.950799] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[  622.950802]  0000000000000000 ffff88001d42dba0 ffffffff81a32f22 ffff88001bfb9c70
[  622.950803]  ffff88001d42dbb0 ffffffff810edb02 ffff88001d42dc38 ffffffff81a396ed
[  622.950805]  0000000000000046 ffff88001d42dbe8 ffffffff810e861d 0000000000000000
[  622.950805] Call Trace:
[  622.950810]  [<ffffffff81a32f22>] dump_stack+0x54/0x74
[  622.950815]  [<ffffffff810edb02>] __might_sleep+0x112/0x114
[  622.950817]  [<ffffffff81a396ed>] mutex_lock_nested+0x3c/0x3c6
[  622.950818]  [<ffffffff810e861d>] ? up+0x39/0x3e
[  622.950821]  [<ffffffff8153ea7c>] ? acpi_os_signal_semaphore+0x21/0x2d
[  622.950824]  [<ffffffff81565ed1>] ? acpi_ut_release_mutex+0x5e/0x62
[  622.950828]  [<ffffffff816d04ec>] virtnet_cpu_callback+0x33/0x87
[  622.950830]  [<ffffffff81a42576>] notifier_call_chain+0x3c/0x5e
[  622.950832]  [<ffffffff810e86a8>] __raw_notifier_call_chain+0xe/0x10
[  622.950835]  [<ffffffff810c5556>] __cpu_notify+0x20/0x37
[  622.950836]  [<ffffffff810c5580>] cpu_notify+0x13/0x15
[  622.950838]  [<ffffffff81a237cd>] take_cpu_down+0x27/0x3a
[  622.950841]  [<ffffffff81136289>] stop_machine_cpu_stop+0x93/0xf1
[  622.950842]  [<ffffffff81136167>] cpu_stopper_thread+0xa0/0x12f
[  622.950844]  [<ffffffff811361f6>] ? cpu_stopper_thread+0x12f/0x12f
[  622.950847]  [<ffffffff81119710>] ? lock_release_holdtime.part.7+0xa3/0xa8
[  622.950848]  [<ffffffff81135e4b>] ? cpu_stop_should_run+0x3f/0x47
[  622.950850]  [<ffffffff810ea9b0>] smpboot_thread_fn+0x1c5/0x1e3
[  622.950852]  [<ffffffff810ea7eb>] ? lg_global_unlock+0x67/0x67
[  622.950854]  [<ffffffff810e36b7>] kthread+0xd8/0xe0
[  622.950857]  [<ffffffff81a3bfad>] ? wait_for_common+0x12f/0x164
[  622.950859]  [<ffffffff810e35df>] ? kthread_create_on_node+0x124/0x124
[  622.950861]  [<ffffffff81a45ffc>] ret_from_fork+0x7c/0xb0
[  622.950862]  [<ffffffff810e35df>] ? kthread_create_on_node+0x124/0x124
[  622.950876] smpboot: CPU 1 is now offline
[  623.194556] SMP alternatives: lockdep: fixing up alternatives
[  623.194559] smpboot: Booting Node 0 Processor 1 APIC 0x1

git bisect start b91e82dc6ad55f2d39b92e731c6bb95cc44a923c 61e6cfa80de5760bbe406f4e815b7739205754d2 --
git bisect good a1b13b9ad3759dca24c6b721ee026c540a4e6564  # 21:47     20+      2  rt2x00: rt2800pci: use module_pci_driver macro
git bisect good fd1b6d51e114be121460a07e9ccb2005928d0c88  # 22:38     20+      0  Merge branch 'pm-cpufreq-next' into linux-next
git bisect good 11ec23f2c0874676a3321d304d2a03e2c46dc680  # 23:13     20+      4  Merge 'shawnguo/for-next' into devel-inn-x86_64-201310190634
git bisect good e358784297992b012e8071764d996191dd2b1a54  # 00:19     20+      1  can: flexcan: fix mx28 detection by rearanging OF match table
git bisect  bad 2b13d06c9584b4eb773f1e80bbaedab9a1c344e1  # 00:35      0-      6  wanxl: fix info leak in ioctl
git bisect good 725907827a7f46dfb5df6e4f3d8f9bcbc9903877  # 01:29     20+      2  Merge branch 'sctp_csum'
git bisect  bad ce97fef4235378108ed3bd96e1b3eab8fd0a1fbd  # 01:54      0-     17  net: qmi_wwan: Olivetti Olicard 200 support
git bisect good dbbd2ad89bb1f86b94b23bb2e56d4935717f9b94  # 02:44     20+      1  net/ethernet: cpsw: Bugfix interrupts before enabling napi
git bisect good 39bb93f88c5db54cbe1df0b0aa957b3a8f2227ed  # 03:11     20+      3  yam: remove a no-op in yam_ioctl()
git bisect  bad 35ed159bfd96a7547ec277ed8b550c7cbd9841b6  # 03:22      0-      1  virtio-net: refill only when device is up during setting queues
git bisect  bad 3ab098df35f8b98b6553edc2e40234af512ba877  # 03:39      0-      9  virtio-net: don't respond to cpu hotplug notifier if we're not ready
git bisect good 39bb93f88c5db54cbe1df0b0aa957b3a8f2227ed  # 04:52     60+      7  yam: remove a no-op in yam_ioctl()
git bisect  bad b91e82dc6ad55f2d39b92e731c6bb95cc44a923c  # 04:53      0-     18  Merge 'lunn/v3.12-rc5-rafael-next-dove-cpufreq' into devel-inn-x86_64-201310190634
git bisect good bc823919e42bc7a31ee06fa040194db6f455c2e3  # 06:04     60+      8  Revert "virtio-net: don't respond to cpu hotplug notifier if we're not ready"
git bisect good 31d141e3a666269a3b6fcccddb0351caf7454240  # 07:11     60+     12  Linux 3.12-rc6
git bisect good a0cf1abc25ac197dd97b857c0f6341066a8cb1cf  # 08:10     60+     10  Add linux-next specific files for 20130927

Thanks,
Fengguang

--3MwIy2ne0vdjdPXF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-nfsroot-waimea-6:20131019151041:x86_64-lkp-CONFIG_SCSI_DEBUG:3.12.0-rc5-wl-01249-gb91e82d:317"
Content-Transfer-Encoding: quoted-printable

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.12.0-rc5-wl-01249-gb91e82d (kbuild@inn) (gcc=
 version 4.8.1 (Debian 4.8.1-8) ) #317 SMP Sat Oct 19 06:59:11 CST 2013
[    0.000000] Command line: hung_task_panic=3D1 rcutree.rcu_cpu_stall_time=
out=3D100 log_buf_len=3D8M ignore_loglevel debug sched_debug apic=3Ddebug d=
ynamic_printk sysrq_always_enabled panic=3D10 load_ramdisk=3D2 prompt_ramdi=
sk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal ip=3D::::nfsroot-=
waimea-6::dhcp nfsroot=3D192.168.1.1:/nfsroot/wfg,tcp,v3,nocto,actimeo=3D60=
0,nolock,rsize=3D524288,wsize=3D524288 rw link=3D/kernel-tests/run-queue/kv=
m/x86_64-lkp-CONFIG_SCSI_DEBUG/devel-inn-x86_64-201310190634/.vmlinuz-b91e8=
2dc6ad55f2d39b92e731c6bb95cc44a923c-20131019065945-3-waimea branch=3Dlinux-=
devel/devel-inn-x86_64-201310190634 BOOT_IMAGE=3D/kernel/x86_64-lkp-CONFIG_=
SCSI_DEBUG/b91e82dc6ad55f2d39b92e731c6bb95cc44a923c/vmlinuz-3.12.0-rc5-wl-0=
1249-gb91e82d
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000001fffdfff] usable
[    0.000000] BIOS-e820: [mem 0x000000001fffe000-0x000000001fffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.4 present.
[    0.000000] DMI: Bochs Bochs, BIOS Bochs 01/01/2011
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn =3D 0x1fffe max_arch_pfn =3D 0x400000000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0080000000 mask FF80000000 uncachable
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x70406, new 0x7010600070106
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000fdab0-0x000fdabf] mapped at =
[ffff8800000fdab0]
[    0.000000]   mpc: fdac0-fdbec
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x02fd7000, 0x02fd7fff] PGTABLE
[    0.000000] BRK [0x02fd8000, 0x02fd8fff] PGTABLE
[    0.000000] BRK [0x02fd9000, 0x02fd9fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x1fc00000-0x1fdfffff]
[    0.000000]  [mem 0x1fc00000-0x1fdfffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x1c000000-0x1fbfffff]
[    0.000000]  [mem 0x1c000000-0x1fbfffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x1bffffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x1bffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x1fe00000-0x1fffdfff]
[    0.000000]  [mem 0x1fe00000-0x1fffdfff] page 4k
[    0.000000] BRK [0x02fda000, 0x02fdafff] PGTABLE
[    0.000000] log_buf_len: 8388608
[    0.000000] early log buf free: 1044612(99%)
[    0.000000] ACPI: RSDP 00000000000fd920 00014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 000000001fffe450 00034 (v01 BOCHS  BXPCRSDT 00000=
001 BXPC 00000001)
[    0.000000] ACPI: FACP 000000001fffff80 00074 (v01 BOCHS  BXPCFACP 00000=
001 BXPC 00000001)
[    0.000000] ACPI: DSDT 000000001fffe490 011A9 (v01   BXPC   BXDSDT 00000=
001 INTL 20100528)
[    0.000000] ACPI: FACS 000000001fffff40 00040
[    0.000000] ACPI: SSDT 000000001ffff7a0 00796 (v01 BOCHS  BXPCSSDT 00000=
001 BXPC 00000001)
[    0.000000] ACPI: APIC 000000001ffff680 00080 (v01 BOCHS  BXPCAPIC 00000=
001 BXPC 00000001)
[    0.000000] ACPI: HPET 000000001ffff640 00038 (v01 BOCHS  BXPCHPET 00000=
001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5f7000 (        fee00000)
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000001fffdfff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x1fffdfff]
[    0.000000]   NODE_DATA [mem 0x1f7f9000-0x1f7fdfff]
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:1f7f5001, boot clock
[    0.000000]  [ffffea0000000000-ffffea00007fffff] PMD -> [ffff88001e60000=
0-ffff88001edfffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x1fffdfff]
[    0.000000] On node 0 totalpages: 130972
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 1984 pages used for memmap
[    0.000000]   DMA32 zone: 126974 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5f7000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-=
23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 0, APIC =
INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 0, APIC =
INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 0, APIC =
INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 0, APIC =
INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 0, APIC =
INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 0, APIC =
INT 01
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 0, APIC =
INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 0, APIC =
INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 0, APIC =
INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 0, APIC =
INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 0, APIC =
INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 0, APIC =
INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 0, APIC =
INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 0, APIC =
INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 0, APIC =
INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffffffff5f6000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000effff]
[    0.000000] PM: Registered nosave memory: [mem 0x000f0000-0x000fffff]
[    0.000000] e820: [mem 0x20000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:256 nr_cpumask_bits:256 nr_cpu_ids:2 n=
r_node_ids:1
[    0.000000] PERCPU: Embedded 476 pages/cpu @ffff88001e200000 s1920640 r8=
192 d20864 u2097152
[    0.000000] pcpu-alloc: s1920640 r8192 d20864 u2097152 alloc=3D1*2097152
[    0.000000] pcpu-alloc: [0] 0 [0] 1=20
[    0.000000] kvm-clock: cpu 0, msr 0:1f7f5001, primary cpu clock
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 1e20d200
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Tota=
l pages: 128903
[    0.000000] Policy zone: DMA32
[    0.000000] Kernel command line: hung_task_panic=3D1 rcutree.rcu_cpu_sta=
ll_timeout=3D100 log_buf_len=3D8M ignore_loglevel debug sched_debug apic=3D=
debug dynamic_printk sysrq_always_enabled panic=3D10 load_ramdisk=3D2 promp=
t_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal ip=3D::::n=
fsroot-waimea-6::dhcp nfsroot=3D192.168.1.1:/nfsroot/wfg,tcp,v3,nocto,actim=
eo=3D600,nolock,rsize=3D524288,wsize=3D524288 rw link=3D/kernel-tests/run-q=
ueue/kvm/x86_64-lkp-CONFIG_SCSI_DEBUG/devel-inn-x86_64-201310190634/.vmlinu=
z-b91e82dc6ad55f2d39b92e731c6bb95cc44a923c-20131019065945-3-waimea branch=
=3Dlinux-devel/devel-inn-x86_64-201310190634 BOOT_IMAGE=3D/kernel/x86_64-lk=
p-CONFIG_SCSI_DEBUG/b91e82dc6ad55f2d39b92e731c6bb95cc44a923c/vmlinuz-3.12.0=
-rc5-wl-01249-gb91e82d
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 2048 (order: 2, 16384 bytes)
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Memory: 470200K/523888K available (10541K kernel code, 1380K=
 rwdata, 5340K rodata, 3192K init, 9544K bss, 53688K reserved)
[    0.000000] SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D2, N=
odes=3D1
[    0.000000] Hierarchical RCU implementation.
[    0.000000]=20
[    0.000000] NR_IRQS:16640 nr_irqs:512 16
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc.,=
 Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000000] ... CHAINHASH_SIZE:          16384
[    0.000000]  memory used by lock dependency info: 6335 kB
[    0.000000]  per task-struct memory footprint: 2688 bytes
[    0.000000] allocated 2097152 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=3Dmemory' option if you don't wan=
t memory cgroups
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 3300.168 MHz processor
[    0.008000] Calibrating delay loop (skipped) preset value.. 6600.33 Bogo=
MIPS (lpj=3D13200672)
[    0.008006] pid_max: default: 32768 minimum: 301
[    0.009058] Dentry cache hash table entries: 65536 (order: 7, 524288 byt=
es)
[    0.010446] Inode-cache hash table entries: 32768 (order: 6, 262144 byte=
s)
[    0.011746] Mount-cache hash table entries: 256
[    0.012335] Initializing cgroup subsys memory
[    0.013300] Initializing cgroup subsys blkio
[    0.014238] Initializing cgroup subsys perf_event
[    0.016007] Initializing cgroup subsys hugetlb
[    0.017034] mce: CPU supports 10 MCE banks
[    0.017992] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.017992] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.017992] tlb_flushall_shift: 6
[    0.020091] Freeing SMP alternatives memory: 40K (ffffffff82679000 - fff=
fffff82683000)
[    0.026089] ACPI: Core revision 20130823
[    0.028270] ACPI: All ACPI Tables successfully acquired
[    0.029547] ftrace: allocating 39517 entries in 155 pages
[    0.040413] Getting VERSION: 50014
[    0.041394] Getting VERSION: 50014
[    0.042376] Getting ID: 0
[    0.044011] Getting ID: ff000000
[    0.044986] Getting LVT0: 8700
[    0.045936] Getting LVT1: 8400
[    0.046889] enabled ExtINT on CPU#0
[    0.048699] ENABLING IO-APIC IRQs
[    0.049828] init IO_APIC IRQs
[    0.050672]  apic 0 pin 0 not connected
[    0.052018] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.053959] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.056044] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.058004] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.060018] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.061977] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.064017] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.065988] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.068017] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.069813] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.071607] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.072017] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.073799] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.076017] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.077800] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.080022]  apic 0 pin 16 not connected
[    0.080926]  apic 0 pin 17 not connected
[    0.081844]  apic 0 pin 18 not connected
[    0.082778]  apic 0 pin 19 not connected
[    0.084003]  apic 0 pin 20 not connected
[    0.084932]  apic 0 pin 21 not connected
[    0.085872]  apic 0 pin 22 not connected
[    0.086796]  apic 0 pin 23 not connected
[    0.088140] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.089908] smpboot: CPU0: Intel Common KVM processor (fam: 0f, model: 0=
6, stepping: 01)
[    0.093052] Using local APIC timer interrupts.
[    0.093052] calibrating APIC timer ...
[    0.100000] ... lapic delta =3D 6249829
[    0.100000] ... PM-Timer delta =3D 358062
[    0.100000] ... PM-Timer result ok
[    0.100000] ..... delta 6249829
[    0.100000] ..... mult: 268428111
[    0.100000] ..... calibration result: 3999890
[    0.100000] ..... CPU clock speed is 3301.0523 MHz.
[    0.100000] ..... host bus clock speed is 999.3890 MHz.
[    0.100072] Performance Events: unsupported Netburst CPU model 6 no PMU =
driver, software events only.
[    0.104070] SMP alternatives: lockdep: fixing up alternatives
[    0.105456] smpboot: Booting Node   0, Processors  #   1 OK
[    0.008000] kvm-clock: cpu 1, msr 0:1f7f5041, secondary cpu clock
[    0.008000] masked ExtINT on CPU#1
[    0.120000] TSC synchronization [CPU#0 -> CPU#1]:
[    0.120000] Measured 2110 cycles TSC warp between CPUs, turning off TSC =
clock.
[    0.120000] tsc: Marking TSC unstable due to check_tsc_sync_source failed
[    0.124081] Brought up 2 CPUs
[    0.124051] KVM setup async PF for cpu 1
[    0.124051] kvm-stealtime: cpu 1, msr 1e40d200
[    0.128004] smpboot: Total of 2 processors activated (13200.67 BogoMIPS)
[    0.132280] CPU0 attaching sched-domain:
[    0.133169]  domain 0: span 0-1 level CPU
[    0.134283]   groups: 0 1
[    0.135351] CPU1 attaching sched-domain:
[    0.136017]  domain 0: span 0-1 level CPU
[    0.137064]   groups: 1 0
[    0.138183] devtmpfs: initialized
[    0.141814] xor: measuring software checksum speed
[    0.184003]    prefetch64-sse: 15292.000 MB/sec
[    0.224003]    generic_sse: 14298.000 MB/sec
[    0.224987] xor: using function: prefetch64-sse (15292.000 MB/sec)
[    0.226242] atomic64 test passed for x86-64 platform with CX8 and with S=
SE
[    0.227649] NET: Registered protocol family 16
[    0.228369] cpuidle: using governor ladder
[    0.228962] cpuidle: using governor menu
[    0.232259] ACPI: bus type PCI registered
[    0.233143] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.234393] PCI: Using configuration type 1 for base access
[    0.272151] bio: create slab <bio-0> at 0
[    0.340005] raid6: sse2x1    8720 MB/s
[    0.408006] raid6: sse2x2   11118 MB/s
[    0.476006] raid6: sse2x4   12701 MB/s
[    0.476904] raid6: using algorithm sse2x4 (12701 MB/s)
[    0.478001] raid6: using intx1 recovery algorithm
[    0.479081] ACPI: Added _OSI(Module Device)
[    0.480003] ACPI: Added _OSI(Processor Device)
[    0.481034] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.482069] ACPI: Added _OSI(Processor Aggregator Device)
[    0.488282] ACPI: Interpreter enabled
[    0.489176] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S1_] (20130823/hwxface-573)
[    0.491348] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S2_] (20130823/hwxface-573)
[    0.492733] ACPI: (supports S0 S3 S4 S5)
[    0.493671] ACPI: Using IOAPIC for interrupt routing
[    0.494785] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.496802] ACPI: No dock devices found.
[    0.508402] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.509499] acpi PNP0A03:00: ACPI _OSC support notification failed, disa=
bling PCIe ASPM
[    0.512016] acpi PNP0A03:00: Unable to request _OSC control (_OSC suppor=
t mask: 0x08)
[    0.514009] acpi PNP0A03:00: fail to add MMCONFIG information, can't acc=
ess extended PCI configuration space under this bridge.
[    0.516283] acpiphp: Slot [3] registered
[    0.517008] acpiphp: Slot [4] registered
[    0.520081] acpiphp: Slot [5] registered
[    0.521037] acpiphp: Slot [6] registered
[    0.521037] acpiphp: Slot [7] registered
[    0.521037] acpiphp: Slot [8] registered
[    0.524071] acpiphp: Slot [9] registered
[    0.525047] acpiphp: Slot [10] registered
[    0.525062] acpiphp: Slot [11] registered
[    0.525062] acpiphp: Slot [12] registered
[    0.532086] acpiphp: Slot [13] registered
[    0.533072] acpiphp: Slot [14] registered
[    0.536087] acpiphp: Slot [15] registered
[    0.537141] acpiphp: Slot [16] registered
[    0.537141] acpiphp: Slot [17] registered
[    0.537141] acpiphp: Slot [18] registered
[    0.540122] acpiphp: Slot [19] registered
[    0.541179] acpiphp: Slot [20] registered
[    0.541204] acpiphp: Slot [21] registered
[    0.544074] acpiphp: Slot [22] registered
[    0.545180] acpiphp: Slot [23] registered
[    0.545208] acpiphp: Slot [24] registered
[    0.548020] acpiphp: Slot [25] registered
[    0.549185] acpiphp: Slot [26] registered
[    0.549211] acpiphp: Slot [27] registered
[    0.549211] acpiphp: Slot [28] registered
[    0.552070] acpiphp: Slot [29] registered
[    0.553076] acpiphp: Slot [30] registered
[    0.553076] acpiphp: Slot [31] registered
[    0.553076] PCI host bridge to bus 0000:00
[    0.556015] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.557158] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.558450] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.560004] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    0.561313] pci_bus 0000:00: root bus resource [mem 0x80000000-0xfebffff=
f]
[    0.562936] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.564564] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.566026] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.570472] pci 0000:00:01.1: reg 0x20: [io  0xc1e0-0xc1ef]
[    0.573218] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.573768] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX=
4 ACPI
[    0.576014] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX=
4 SMB
[    0.577730] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.581088] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    0.584014] pci 0000:00:02.0: reg 0x14: [mem 0xfebe4000-0xfebe4fff]
[    0.589993] pci 0000:00:02.0: reg 0x30: [mem 0xfebc0000-0xfebcffff pref]
[    0.592041] pci 0000:00:03.0: [1af4:1000] type 00 class 0x020000
[    0.594196] pci 0000:00:03.0: reg 0x10: [io  0xc1c0-0xc1df]
[    0.596005] pci 0000:00:03.0: reg 0x14: [mem 0xfebe5000-0xfebe5fff]
[    0.601724] pci 0000:00:03.0: reg 0x30: [mem 0xfebd0000-0xfebdffff pref]
[    0.603536] pci 0000:00:04.0: [8086:100e] type 00 class 0x020000
[    0.604911] pci 0000:00:04.0: reg 0x10: [mem 0xfeb80000-0xfeb9ffff]
[    0.608004] pci 0000:00:04.0: reg 0x14: [io  0xc000-0xc03f]
[    0.613315] pci 0000:00:04.0: reg 0x30: [mem 0xfeba0000-0xfebbffff pref]
[    0.614893] pci 0000:00:05.0: [8086:2668] type 00 class 0x040300
[    0.616518] pci 0000:00:05.0: reg 0x10: [mem 0xfebe0000-0xfebe3fff]
[    0.621415] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    0.622246] pci 0000:00:06.0: reg 0x10: [io  0xc040-0xc07f]
[    0.624859] pci 0000:00:06.0: reg 0x14: [mem 0xfebe6000-0xfebe6fff]
[    0.632066] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    0.634239] pci 0000:00:07.0: reg 0x10: [io  0xc080-0xc0bf]
[    0.636005] pci 0000:00:07.0: reg 0x14: [mem 0xfebe7000-0xfebe7fff]
[    0.642194] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    0.644469] pci 0000:00:08.0: reg 0x10: [io  0xc0c0-0xc0ff]
[    0.646543] pci 0000:00:08.0: reg 0x14: [mem 0xfebe8000-0xfebe8fff]
[    0.652861] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    0.654264] pci 0000:00:09.0: reg 0x10: [io  0xc100-0xc13f]
[    0.656891] pci 0000:00:09.0: reg 0x14: [mem 0xfebe9000-0xfebe9fff]
[    0.663076] pci 0000:00:0a.0: [1af4:1001] type 00 class 0x010000
[    0.664955] pci 0000:00:0a.0: reg 0x10: [io  0xc140-0xc17f]
[    0.667022] pci 0000:00:0a.0: reg 0x14: [mem 0xfebea000-0xfebeafff]
[    0.673803] pci 0000:00:0b.0: [1af4:1001] type 00 class 0x010000
[    0.676005] pci 0000:00:0b.0: reg 0x10: [io  0xc180-0xc1bf]
[    0.678082] pci 0000:00:0b.0: reg 0x14: [mem 0xfebeb000-0xfebebfff]
[    0.684490] pci 0000:00:0c.0: [8086:25ab] type 00 class 0x088000
[    0.685813] pci 0000:00:0c.0: reg 0x10: [mem 0xfebec000-0xfebec00f]
[    0.690624] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.693147] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.694933] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.697112] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.698892] ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
[    0.700803] ACPI: Enabled 16 GPEs in block 00 to 0F
[    0.701567] ACPI: \_SB_.PCI0: notify handler is installed
[    0.702851] Found 1 acpi root devices
[    0.704172] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    0.705812] vgaarb: loaded
[    0.706593] vgaarb: bridge control possible 0000:00:02.0
[    0.708107] SCSI subsystem initialized
[    0.709004] libata version 3.00 loaded.
[    0.709044] ACPI: bus type USB registered
[    0.712118] usbcore: registered new interface driver usbfs
[    0.713422] usbcore: registered new interface driver hub
[    0.716095] usbcore: registered new device driver usb
[    0.717374] pps_core: LinuxPPS API ver. 1 registered
[    0.717374] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    0.720057] PTP clock support registered
[    0.721191] EDAC MC: Ver: 3.0.0
[    0.724374] PCI: Using ACPI for IRQ routing
[    0.725139] PCI: pci_cache_line_size set to 64 bytes
[    0.726643] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.728005] e820: reserve RAM buffer [mem 0x1fffe000-0x1fffffff]
[    0.729556] HPET: 3 timers in total, 0 timers will be used for per-cpu t=
imer
[    0.732032] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.733743] hpet0: 3 comparators, 64-bit 100.000000 MHz counter
[    0.740071] Switched to clocksource kvm-clock
[    0.774158] pnp: PnP ACPI init
[    0.775052] ACPI: bus type PNP registered
[    0.776116] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:3)
[    0.778147] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.779506] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:3)
[    0.781548] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.782929] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:3)
[    0.784932] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.786255] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:3)
[    0.788127] pnp 00:03: [dma 2]
[    0.789153] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.790526] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:3)
[    0.792555] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    0.793952] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:3)
[    0.795943] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.797659] pnp 00:06: Plug and Play ACPI device, IDs PNP0103 (active)
[    0.799154] pnp: PnP ACPI: found 7 devices
[    0.800167] ACPI: bus type PNP unregistered
[    0.817018] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    0.818251] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    0.819428] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    0.820800] pci_bus 0000:00: resource 7 [mem 0x80000000-0xfebfffff]
[    0.822173] NET: Registered protocol family 2
[    0.823402] TCP established hash table entries: 4096 (order: 4, 65536 by=
tes)
[    0.824950] TCP bind hash table entries: 4096 (order: 6, 327680 bytes)
[    0.826394] TCP: Hash tables configured (established 4096 bind 4096)
[    0.827769] TCP: reno registered
[    0.828675] UDP hash table entries: 256 (order: 3, 49152 bytes)
[    0.829948] UDP-Lite hash table entries: 256 (order: 3, 49152 bytes)
[    0.831394] NET: Registered protocol family 1
[    0.832640] RPC: Registered named UNIX socket transport module.
[    0.834113] RPC: Registered udp transport module.
[    0.835351] RPC: Registered tcp transport module.
[    0.836653] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    0.838169] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.839669] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.841086] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.842376] pci 0000:00:02.0: Boot video device
[    0.843572] PCI: CLS 0 bytes, default 64
[    0.852796] DMA-API: preallocated 65536 debug entries
[    0.853944] DMA-API: debugging enabled by kernel config
[    0.855444] kvm: no hardware support
[    0.856572] Machine check injector initialized
[    0.857843] Scanning for low memory corruption every 60 seconds
[    0.859353] camellia-x86_64: performance on this CPU would be suboptimal=
: disabling camellia-x86_64.
[    0.861428] blowfish-x86_64: performance on this CPU would be suboptimal=
: disabling blowfish-x86_64.
[    0.863633] twofish-x86_64-3way: performance on this CPU would be subopt=
imal: disabling twofish-x86_64-3way.
[    0.867095] sha1_ssse3: Neither AVX nor SSSE3 is available/usable.
[    0.868399] PCLMULQDQ-NI instructions are not detected.
[    0.869556] AVX or AES-NI instructions are not detected.
[    0.870694] AVX instructions are not detected.
[    0.871730] AVX instructions are not detected.
[    0.872837] AVX instructions are not detected.
[    0.873869] AVX instructions are not detected.
[    0.902146] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    0.911916] VFS: Disk quotas dquot_6.5.2
[    0.913023] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    0.917373] NFS: Registering the id_resolver key type
[    0.918444] Key type id_resolver registered
[    0.919350] Key type id_legacy registered
[    0.920323] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[    0.922382] ROMFS MTD (C) 2007 Red Hat, Inc.
[    0.923594] fuse init (API version 7.22)
[    0.924931] SGI XFS with ACLs, security attributes, realtime, large bloc=
k/inode numbers, debug enabled
[    0.930459] bio: create slab <bio-1> at 1
[    0.932183] Btrfs loaded
[    0.932932] msgmni has been set to 918
[    0.938582] NET: Registered protocol family 38
[    0.939568] Key type asymmetric registered
[    0.940527] Asymmetric key parser 'x509' registered
[    0.941632] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 250)
[    0.948159] io scheduler noop registered
[    0.949057] io scheduler deadline registered
[    0.950003] io scheduler cfq registered (default)
[    0.951524] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    0.953009] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    0.954528] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    0.956218] ACPI: Power Button [PWRF]
[    0.958016] GHES: HEST is not enabled!
[    0.958949] ERST DBG: ERST support is disabled.
[    0.960720] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
[    0.961840] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:3)
[    0.964088] virtio-pci 0000:00:03.0: setting latency timer to 64
[    0.966095] ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 10
[    0.967221] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:3)
[    0.969562] virtio-pci 0000:00:06.0: setting latency timer to 64
[    0.972597] virtio-pci 0000:00:07.0: setting latency timer to 64
[    0.975170] ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 11
[    0.977123] virtio-pci 0000:00:08.0: setting latency timer to 64
[    0.979782] ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 10
[    0.981802] virtio-pci 0000:00:09.0: setting latency timer to 64
[    0.985488] virtio-pci 0000:00:0a.0: setting latency timer to 64
[    0.989434] virtio-pci 0000:00:0b.0: setting latency timer to 64
[    0.992240] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    1.016748] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[    1.020631] Non-volatile memory driver v1.3
[    1.027763] brd: module loaded
[    1.031829] loop: module loaded
[    1.032838] virtio-pci 0000:00:06.0: irq 40 for MSI/MSI-X
[    1.033940] virtio-pci 0000:00:06.0: irq 41 for MSI/MSI-X
[    1.035779]  vda: unknown partition table
[    1.038378] virtio-pci 0000:00:07.0: irq 42 for MSI/MSI-X
[    1.039554] virtio-pci 0000:00:07.0: irq 43 for MSI/MSI-X
[    1.041497]  vdb: unknown partition table
[    1.043972] virtio-pci 0000:00:08.0: irq 44 for MSI/MSI-X
[    1.045223] virtio-pci 0000:00:08.0: irq 45 for MSI/MSI-X
[    1.047117]  vdc: unknown partition table
[    1.049491] virtio-pci 0000:00:09.0: irq 46 for MSI/MSI-X
[    1.050597] virtio-pci 0000:00:09.0: irq 47 for MSI/MSI-X
[    1.052325]  vdd: unknown partition table
[    1.054941] virtio-pci 0000:00:0a.0: irq 48 for MSI/MSI-X
[    1.056113] virtio-pci 0000:00:0a.0: irq 49 for MSI/MSI-X
[    1.057921]  vde: unknown partition table
[    1.060323] virtio-pci 0000:00:0b.0: irq 50 for MSI/MSI-X
[    1.061435] virtio-pci 0000:00:0b.0: irq 51 for MSI/MSI-X
[    1.063232]  vdf: unknown partition table
[    1.065639] lkdtm: No crash points registered, enable through debugfs
[    1.067595] Loading iSCSI transport class v2.0-870.
[    1.070457] Adaptec aacraid driver 1.2-0[30200]-ms
[    1.071741] aic94xx: Adaptec aic94xx SAS/SATA driver version 1.0.3 loaded
[    1.073333] qla2xxx [0000:00:00.0]-0005: : QLogic Fibre Channel HBA Driv=
er: 8.06.00.08-k.
[    1.075265] megaraid cmm: 2.20.2.7 (Release Date: Sun Jul 16 00:01:03 ES=
T 2006)
[    1.077089] megaraid: 2.20.5.1 (Release Date: Thu Nov 16 15:32:35 EST 20=
06)
[    1.078473] megasas: 06.700.06.00-rc1 Sat. Aug. 31 17:00:00 PDT 2013
[    1.079899] GDT-HA: Storage RAID Controller Driver. Version: 3.05
[    1.081202] RocketRAID 3xxx/4xxx Controller driver v1.8
[    1.082991] ata_piix 0000:00:01.1: version 2.13
[    1.085526] ata_piix 0000:00:01.1: setting latency timer to 64
[    1.088191] scsi0 : ata_piix
[    1.089389] scsi1 : ata_piix
[    1.090575] ata1: PATA max MWDMA2 cmd 0x1f0 ctl 0x3f6 bmdma 0xc1e0 irq 14
[    1.092058] ata2: PATA max MWDMA2 cmd 0x170 ctl 0x376 bmdma 0xc1e8 irq 15
[    1.094494] virtio-pci 0000:00:03.0: irq 52 for MSI/MSI-X
[    1.095787] virtio-pci 0000:00:03.0: irq 53 for MSI/MSI-X
[    1.097124] virtio-pci 0000:00:03.0: irq 54 for MSI/MSI-X
[    1.099863] pcnet32: pcnet32.c:v1.35 21.Apr.2008 tsbogend@alpha.franken.=
de
[    1.101645] Atheros(R) L2 Ethernet Driver - version 2.2.3
[    1.102894] Copyright (c) 2007 Atheros Corporation.
[    1.104593] dmfe: Davicom DM9xxx net driver, version 1.36.4 (2002-01-17)
[    1.106134] v1.01-e (2.4 port) Sep-11-2006  Donald Becker <becker@scyld.=
com>
[    1.106134]   http://www.scyld.com/network/drivers.html
[    1.109176] uli526x: ULi M5261/M5263 net driver, version 0.9.3 (2005-7-2=
9)
[    1.110836] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
[    1.112202] e100: Copyright(c) 1999-2006 Intel Corporation
[    1.113574] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-=
NAPI
[    1.115019] e1000: Copyright (c) 1999-2006 Intel Corporation.
[    1.118195] e1000 0000:00:04.0: setting latency timer to 64
[    1.248715] ata2.01: NODEV after polling detection
[    1.250395] ata2.00: ATAPI: QEMU DVD-ROM, 1.6.0, max UDMA/100
[    1.252407] ata2.00: configured for MWDMA2
[    1.254218] scsi 1:0:0:0: CD-ROM            QEMU     QEMU DVD-ROM     1.=
6. PQ: 0 ANSI: 5
[    1.257751] sr0: scsi3-mmc drive: 4x/4x cd/rw xa/form2 tray
[    1.259245] cdrom: Uniform CD-ROM driver Revision: 3.20
[    1.261074] sr 1:0:0:0: Attached scsi CD-ROM sr0
[    1.262904] sr 1:0:0:0: Attached scsi generic sg0 type 5
[    1.462384] e1000 0000:00:04.0 eth1: (PCI:33MHz:32-bit) 52:54:00:12:34:57
[    1.463925] e1000 0000:00:04.0 eth1: Intel(R) PRO/1000 Network Connection
[    1.465645] e1000e: Intel(R) PRO/1000 Network Driver - 2.3.2-k
[    1.466937] e1000e: Copyright(c) 1999 - 2013 Intel Corporation.
[    1.468487] igb: Intel(R) Gigabit Ethernet Network Driver - version 5.0.=
5-k
[    1.470009] igb: Copyright (c) 2007-2013 Intel Corporation.
[    1.471498] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - vers=
ion 3.15.1-k
[    1.473679] ixgbe: Copyright (c) 1999-2013 Intel Corporation.
[    1.475246] ixgb: Intel(R) PRO/10GbE Network Driver - version 1.0.135-k2=
-NAPI
[    1.476835] ixgb: Copyright (c) 1999-2008 Intel Corporation.
[    1.478502] sky2: driver version 1.30
[    1.481034] usbcore: registered new interface driver catc
[    1.482497] usbcore: registered new interface driver kaweth
[    1.483714] pegasus: v0.9.3 (2013/04/25), Pegasus/Pegasus II USB Etherne=
t driver
[    1.485698] usbcore: registered new interface driver pegasus
[    1.487091] usbcore: registered new interface driver rtl8150
[    1.488409] usbcore: registered new interface driver asix
[    1.489640] usbcore: registered new interface driver ax88179_178a
[    1.491057] usbcore: registered new interface driver cdc_ether
[    1.492436] usbcore: registered new interface driver r815x
[    1.493737] usbcore: registered new interface driver cdc_eem
[    1.495118] usbcore: registered new interface driver dm9601
[    1.496504] usbcore: registered new interface driver smsc75xx
[    1.497880] usbcore: registered new interface driver smsc95xx
[    1.499212] usbcore: registered new interface driver gl620a
[    1.500597] usbcore: registered new interface driver net1080
[    1.501949] usbcore: registered new interface driver plusb
[    1.503245] usbcore: registered new interface driver rndis_host
[    1.504654] usbcore: registered new interface driver cdc_subset
[    1.506018] usbcore: registered new interface driver zaurus
[    1.507288] usbcore: registered new interface driver MOSCHIP usb-etherne=
t driver
[    1.509176] usbcore: registered new interface driver int51x1
[    1.510855] usbcore: registered new interface driver ipheth
[    1.512328] usbcore: registered new interface driver sierra_net
[    1.513872] usbcore: registered new interface driver cdc_ncm
[    1.515274] Fusion MPT base driver 3.04.20
[    1.516415] Copyright (c) 1999-2008 LSI Corporation
[    1.517655] Fusion MPT SPI Host driver 3.04.20
[    1.519063] Fusion MPT FC Host driver 3.04.20
[    1.520404] Fusion MPT SAS Host driver 3.04.20
[    1.521774] Fusion MPT misc device (ioctl) driver 3.04.20
[    1.523305] mptctl: Registered with Fusion MPT base driver
[    1.524631] mptctl: /dev/mptctl @ (major,minor=3D10,220)
[    1.526366] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    1.527880] ehci-pci: EHCI PCI platform driver
[    1.529213] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    1.530634] ohci-pci: OHCI PCI platform driver
[    1.532023] uhci_hcd: USB Universal Host Controller Interface driver
[    1.533804] usbcore: registered new interface driver usb-storage
[    1.535305] usbcore: registered new interface driver ums-alauda
[    1.536655] usbcore: registered new interface driver ums-datafab
[    1.538145] usbcore: registered new interface driver ums-freecom
[    1.539498] usbcore: registered new interface driver ums-isd200
[    1.540902] usbcore: registered new interface driver ums-jumpshot
[    1.542321] usbcore: registered new interface driver ums-sddr09
[    1.543688] usbcore: registered new interface driver ums-sddr55
[    1.545034] usbcore: registered new interface driver ums-usbat
[    1.546293] usbcore: registered new interface driver usbtest
[    1.547633] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x6=
0,0x64 irq 1,12
[    1.550277] serio: i8042 KBD port at 0x60,0x64 irq 1
[    1.551336] serio: i8042 AUX port at 0x60,0x64 irq 12
[    1.552798] mousedev: PS/2 mouse device common for all mice
[    1.554842] rtc_cmos 00:00: RTC can wake from S4
[    1.556352] rtc_cmos 00:00: rtc core: registered rtc_cmos as rtc0
[    1.557641] rtc_cmos 00:00: alarms up to one day, 114 bytes nvram, hpet =
irqs
[    1.559210] i6300esb: Intel 6300ESB WatchDog Timer Driver v0.05
[    1.560604] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input1
[    1.562680] i6300esb: initialized (0xffffc90000178000). heartbeat=3D30 s=
ec (nowayout=3D0)
[    1.564790] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.10
[    1.566164] iTCO_vendor_support: vendor-support=3D0
[    1.567231] watchdog: Software Watchdog: cannot register miscdev on mino=
r=3D130 (err=3D-16).
[    1.568988] watchdog: Software Watchdog: a legacy watchdog module is pro=
bably present.
[    1.570980] softdog: Software Watchdog Timer: 0.08 initialized. soft_nob=
oot=3D0 soft_margin=3D60 sec soft_panic=3D0 (nowayout=3D0)
[    1.573162] md: linear personality registered for level -1
[    1.574314] md: raid0 personality registered for level 0
[    1.575381] md: raid1 personality registered for level 1
[    1.576487] md: raid10 personality registered for level 10
[    1.577786] md: raid6 personality registered for level 6
[    1.578870] md: raid5 personality registered for level 5
[    1.579928] md: raid4 personality registered for level 4
[    1.585767] md: multipath personality registered for level -4
[    1.586924] md: faulty personality registered for level -5
[    1.589761] device-mapper: ioctl: 4.26.0-ioctl (2013-08-15) initialised:=
 dm-devel@redhat.com
[    1.592531] device-mapper: multipath: version 1.5.1 loaded
[    1.593689] device-mapper: multipath round-robin: version 1.0.0 loaded
[    1.595111] device-mapper: cache-policy-mq: version 1.0.0 loaded
[    1.596341] device-mapper: cache cleaner: version 1.0.0 loaded
[    1.597931] dcdbas dcdbas: Dell Systems Management Base Driver (version =
5.6.0-3.2)
[    1.602418] usbcore: registered new interface driver usbhid
[    1.603564] usbhid: USB HID core driver
[    1.604631] oprofile: using NMI interrupt.
[    1.605608] TCP: bic registered
[    1.606388] Initializing XFRM netlink socket
[    1.607869] NET: Registered protocol family 10
[    1.609184] sit: IPv6 over IPv4 tunneling driver
[    1.610594] NET: Registered protocol family 17
[    1.611587] 8021q: 802.1Q VLAN Support v1.8
[    1.612935] sctp: Hash tables configured (established 1638 bind 1638)
[    1.614366] Key type dns_resolver registered
[    1.616218]=20
[    1.616218] printing PIC contents
[    1.617513] ... PIC  IMR: ffff
[    1.618283] ... PIC  IRR: 9113
[    1.619059] ... PIC  ISR: 0000
[    1.619830] ... PIC ELCR: 0c00
[    1.620639] printing local APIC contents on CPU#0/0:
[    1.621654] ... APIC ID:      00000000 (0)
[    1.622558] ... APIC VERSION: 00050014
[    1.623412] ... APIC TASKPRI: 00000000 (00)
[    1.624357] ... APIC PROCPRI: 00000000
[    1.624629] ... APIC LDR: 01000000
[    1.624629] ... APIC DFR: ffffffff
[    1.624629] ... APIC SPIV: 000001ff
[    1.624629] ... APIC ISR field:
[    1.624629] 000000000000000000000000000000000000000000000000000000000000=
0000
[    1.624629] ... APIC TMR field:
[    1.624629] 000000000200000000000000000000000000000000000000000000000000=
0000
[    1.624629] ... APIC IRR field:
[    1.624629] 000000000000000000000000000000000000000000000000000000000000=
8000
[    1.624629] ... APIC ESR: 00000000
[    1.624629] ... APIC ICR: 000008fd
[    1.624629] ... APIC ICR2: 02000000
[    1.624629] ... APIC LVTT: 000000ef
[    1.624629] ... APIC LVTPC: 00010000
[    1.624629] ... APIC LVT0: 00010700
[    1.624629] ... APIC LVT1: 00000400
[    1.624629] ... APIC LVTERR: 000000fe
[    1.624629] ... APIC TMICT: 00033653
[    1.624629] ... APIC TMCCT: 00000000
[    1.624629] ... APIC TDCR: 00000003
[    1.624629]=20
[    1.646158] number of MP IRQ sources: 15.
[    1.647063] number of IO-APIC #0 registers: 24.
[    1.648060] testing the IO APIC.......................
[    1.649110] IO APIC #0......
[    1.649877] .... register #00: 00000000
[    1.650734] .......    : physical APIC id: 00
[    1.651664] .......    : Delivery Type: 0
[    1.652599] .......    : LTS          : 0
[    1.653481] .... register #01: 00170011
[    1.654342] .......     : max redirection entries: 17
[    1.655369] .......     : PRQ implemented: 0
[    1.656352] .......     : IO APIC version: 11
[    1.657303] .... register #02: 00000000
[    1.658190] .......     : arbitration: 00
[    1.659096] .... IRQ redirection table:
[    1.659993] 1    0    0   0   0    0    0    00
[    1.661037] 0    0    0   0   0    1    1    31
[    1.662099] 0    0    0   0   0    1    1    30
[    1.663136] 0    0    0   0   0    1    1    33
[    1.664221] 1    0    0   0   0    1    1    34
[    1.665295] 1    1    0   0   0    1    1    35
[    1.666348] 0    0    0   0   0    1    1    36
[    1.667404] 0    0    0   0   0    1    1    37
[    1.668475] 0    0    0   0   0    1    1    38
[    1.669497] 0    1    0   0   0    1    1    39
[    1.670522] 1    1    0   0   0    1    1    3A
[    1.671540] 1    1    0   0   0    1    1    3B
[    1.672608] 0    0    0   0   0    1    1    3C
[    1.673645] 0    0    0   0   0    1    1    3D
[    1.674669] 0    0    0   0   0    1    1    3E
[    1.675691] 0    0    0   0   0    1    1    3F
[    1.676747] 1    0    0   0   0    0    0    00
[    1.677774] 1    0    0   0   0    0    0    00
[    1.678802] 1    0    0   0   0    0    0    00
[    1.679859] 1    0    0   0   0    0    0    00
[    1.680949] 1    0    0   0   0    0    0    00
[    1.681985] 1    0    0   0   0    0    0    00
[    1.683035] 1    0    0   0   0    0    0    00
[    1.684106] 1    0    0   0   0    0    0    00
[    1.685142] IRQ to pin mappings:
[    1.685993] IRQ0 -> 0:2
[    1.686922] IRQ1 -> 0:1
[    1.687848] IRQ3 -> 0:3
[    1.688830] IRQ4 -> 0:4
[    1.689734] IRQ5 -> 0:5
[    1.690680] IRQ6 -> 0:6
[    1.691602] IRQ7 -> 0:7
[    1.692564] IRQ8 -> 0:8
[    1.693528] IRQ9 -> 0:9
[    1.694495] IRQ10 -> 0:10
[    1.695473] IRQ11 -> 0:11
[    1.696498] IRQ12 -> 0:12
[    1.697461] IRQ13 -> 0:13
[    1.698433] IRQ14 -> 0:14
[    1.699397] IRQ15 -> 0:15
[    1.700443] .................................... done.
[    1.702011] PM: Hibernation image not present or could not be loaded.
[    1.703350] registered taskstats version 1
[    1.705110] rtc_cmos 00:00: setting system clock to 2013-10-19 07:00:14 =
UTC (1382166014)
[    1.706960] BIOS EDD facility v0.16 2004-Jun-25, 6 devices found
[    1.709380] 8021q: adding VLAN 0 to HW filter on device eth0
[    1.715307] IPv6: ADDRCONF(NETDEV_UP): eth1: link is not ready
[    1.716629] 8021q: adding VLAN 0 to HW filter on device eth1
[    1.732052] Sending DHCP requests ., OK
[    1.756050] IP-Config: Got DHCP answer from 10.0.2.2, my address is 10.0=
=2E2.15
[    1.809492] IP-Config: Complete:
[    1.810392]      device=3Deth0, hwaddr=3D52:54:00:12:34:56, ipaddr=3D10.=
0.2.15, mask=3D255.255.255.0, gw=3D10.0.2.2
[    1.812510]      host=3Dnfsroot-waimea-6, domain=3D, nis-domain=3D(none)
[    1.813778]      bootserver=3D10.0.2.2, rootserver=3D192.168.1.1, rootpa=
th=3D
[    1.814685]      nameserver0=3D10.0.2.3
[    2.194159] input: ImExPS/2 Generic Explorer Mouse as /devices/platform/=
i8042/serio1/input/input2
[    2.197033] md: Skipping autodetection of RAID arrays. (raid=3Dautodetec=
t will force)
[    2.216859] VFS: Mounted root (nfs filesystem) on device 0:13.
[    2.219291] Freeing unused kernel memory: 3192K (ffffffff8235b000 - ffff=
ffff82679000)
[    2.221015] Write protecting the kernel read-only data: 18432k
[    2.225854] Freeing unused kernel memory: 1736K (ffff880001a4e000 - ffff=
880001c00000)
[    2.228987] Freeing unused kernel memory: 804K (ffff880002137000 - ffff8=
80002200000)
[  380.864697] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recov=
ery directory
[  380.868529] NFSD: starting 90-second grace period (net ffffffff82309fc0)
Kernel tests: Boot OK!
[  622.895176] Unregister pv shared memory for cpu 1
[  622.944441] CPU0 attaching NULL sched-domain.
[  622.944446] CPU1 attaching NULL sched-domain.
[  622.944485] CPU0 attaching NULL sched-domain.
[  622.950795] BUG: sleeping function called from invalid context at kernel=
/mutex.c:616
[  622.950796] in_atomic(): 1, irqs_disabled(): 1, pid: 10, name: migration=
/1
[  622.950796] no locks held by migration/1/10.
[  622.950798] CPU: 1 PID: 10 Comm: migration/1 Not tainted 3.12.0-rc5-wl-0=
1249-gb91e82d #317
[  622.950799] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[  622.950802]  0000000000000000 ffff88001d42dba0 ffffffff81a32f22 ffff8800=
1bfb9c70
[  622.950803]  ffff88001d42dbb0 ffffffff810edb02 ffff88001d42dc38 ffffffff=
81a396ed
[  622.950805]  0000000000000046 ffff88001d42dbe8 ffffffff810e861d 00000000=
00000000
[  622.950805] Call Trace:
[  622.950810]  [<ffffffff81a32f22>] dump_stack+0x54/0x74
[  622.950815]  [<ffffffff810edb02>] __might_sleep+0x112/0x114
[  622.950817]  [<ffffffff81a396ed>] mutex_lock_nested+0x3c/0x3c6
[  622.950818]  [<ffffffff810e861d>] ? up+0x39/0x3e
[  622.950821]  [<ffffffff8153ea7c>] ? acpi_os_signal_semaphore+0x21/0x2d
[  622.950824]  [<ffffffff81565ed1>] ? acpi_ut_release_mutex+0x5e/0x62
[  622.950828]  [<ffffffff816d04ec>] virtnet_cpu_callback+0x33/0x87
[  622.950830]  [<ffffffff81a42576>] notifier_call_chain+0x3c/0x5e
[  622.950832]  [<ffffffff810e86a8>] __raw_notifier_call_chain+0xe/0x10
[  622.950835]  [<ffffffff810c5556>] __cpu_notify+0x20/0x37
[  622.950836]  [<ffffffff810c5580>] cpu_notify+0x13/0x15
[  622.950838]  [<ffffffff81a237cd>] take_cpu_down+0x27/0x3a
[  622.950841]  [<ffffffff81136289>] stop_machine_cpu_stop+0x93/0xf1
[  622.950842]  [<ffffffff81136167>] cpu_stopper_thread+0xa0/0x12f
[  622.950844]  [<ffffffff811361f6>] ? cpu_stopper_thread+0x12f/0x12f
[  622.950847]  [<ffffffff81119710>] ? lock_release_holdtime.part.7+0xa3/0x=
a8
[  622.950848]  [<ffffffff81135e4b>] ? cpu_stop_should_run+0x3f/0x47
[  622.950850]  [<ffffffff810ea9b0>] smpboot_thread_fn+0x1c5/0x1e3
[  622.950852]  [<ffffffff810ea7eb>] ? lg_global_unlock+0x67/0x67
[  622.950854]  [<ffffffff810e36b7>] kthread+0xd8/0xe0
[  622.950857]  [<ffffffff81a3bfad>] ? wait_for_common+0x12f/0x164
[  622.950859]  [<ffffffff810e35df>] ? kthread_create_on_node+0x124/0x124
[  622.950861]  [<ffffffff81a45ffc>] ret_from_fork+0x7c/0xb0
[  622.950862]  [<ffffffff810e35df>] ? kthread_create_on_node+0x124/0x124
[  622.950876] smpboot: CPU 1 is now offline
[  623.194556] SMP alternatives: lockdep: fixing up alternatives
[  623.194559] smpboot: Booting Node 0 Processor 1 APIC 0x1
[  622.952013] kvm-clock: cpu 1, msr 0:1f7f5041, secondary cpu clock
[  622.952013] masked ExtINT on CPU#1
[  623.217880] CPU0 attaching NULL sched-domain.
[  623.217913] CPU0 attaching sched-domain:
[  623.217915]  domain 0: span 0-1 level CPU
[  623.217917]   groups: 0 1
[  623.217919] CPU1 attaching sched-domain:
[  623.217920]  domain 0: span 0-1 level CPU
[  623.217921]   groups: 1 0
[  623.218021] KVM setup async PF for cpu 1
[  623.218025] kvm-stealtime: cpu 1, msr 1e40d200
Trinity v1.0  Dave Jones <davej@redhat.com> 2012
[3143] Marking 64-bit syscall 274 (get_robust_list) as AVOID
[3143] Marking 32-bit syscall 312 (get_robust_list) as AVOID
[  627.841130] Unregister pv shared memory for cpu 1

Elapsed time: 625
qemu-system-x86_64 -cpu kvm64 -enable-kvm -kernel /kernel/x86_64-lkp-CONFIG=
_SCSI_DEBUG/b91e82dc6ad55f2d39b92e731c6bb95cc44a923c/vmlinuz-3.12.0-rc5-wl-=
01249-gb91e82d -append 'hung_task_panic=3D1 rcutree.rcu_cpu_stall_timeout=
=3D100 log_buf_len=3D8M ignore_loglevel debug sched_debug apic=3Ddebug dyna=
mic_printk sysrq_always_enabled panic=3D10 load_ramdisk=3D2 prompt_ramdisk=
=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal ip=3D::::nfsroot-wa=
imea-6::dhcp nfsroot=3D192.168.1.1:/nfsroot/wfg,tcp,v3,nocto,actimeo=3D600,=
nolock,rsize=3D524288,wsize=3D524288 rw link=3D/kernel-tests/run-queue/kvm/=
x86_64-lkp-CONFIG_SCSI_DEBUG/devel-inn-x86_64-201310190634/.vmlinuz-b91e82d=
c6ad55f2d39b92e731c6bb95cc44a923c-20131019065945-3-waimea branch=3Dlinux-de=
vel/devel-inn-x86_64-201310190634 BOOT_IMAGE=3D/kernel/x86_64-lkp-CONFIG_SC=
SI_DEBUG/b91e82dc6ad55f2d39b92e731c6bb95cc44a923c/vmlinuz-3.12.0-rc5-wl-012=
49-gb91e82d'  -m 512M -smp 2 -net nic,vlan=3D0,macaddr=3D00:00:00:00:00:00,=
model=3Dvirtio -net user,vlan=3D0,hostfwd=3Dtcp::18248-:22 -net nic,vlan=3D=
1,model=3De1000 -net user,vlan=3D1 -boot order=3Dnc -no-reboot -watchdog i6=
300esb -soundhw hda -drive file=3D/fs/LABEL=3DKVM/disk0-nfsroot-waimea-6,me=
dia=3Ddisk,if=3Dvirtio -drive file=3D/fs/LABEL=3DKVM/disk1-nfsroot-waimea-6=
,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/LABEL=3DKVM/disk2-nfsroot-waime=
a-6,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/LABEL=3DKVM/disk3-nfsroot-wa=
imea-6,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/LABEL=3DKVM/disk4-nfsroot=
-waimea-6,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/LABEL=3DKVM/disk5-nfsr=
oot-waimea-6,media=3Ddisk,if=3Dvirtio -pidfile /dev/shm/kboot/pid-nfsroot-w=
aimea-6 -serial file:/dev/shm/kboot/serial-nfsroot-waimea-6 -daemonize -dis=
play none -monitor null=20

--3MwIy2ne0vdjdPXF
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="bisect-b91e82dc6ad55f2d39b92e731c6bb95cc44a923c-x86_64-lkp-CONFIG_SCSI_DEBUG-BUG:-sleeping-function-called-from-invalid-context-at-kernel-mutex-c-126797.log"
Content-Transfer-Encoding: base64

Z2l0IGNoZWNrb3V0IDYxZTZjZmE4MGRlNTc2MGJiZTQwNmY0ZTgxNWI3NzM5MjA1NzU0ZDIK
UHJldmlvdXMgSEVBRCBwb3NpdGlvbiB3YXMgYjkxZTgyZC4uLiBNZXJnZSAnbHVubi92My4x
Mi1yYzUtcmFmYWVsLW5leHQtZG92ZS1jcHVmcmVxJyBpbnRvIGRldmVsLWlubi14ODZfNjQt
MjAxMzEwMTkwNjM0CkhFQUQgaXMgbm93IGF0IDYxZTZjZmEuLi4gTGludXggMy4xMi1yYzUK
bHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1sa3AtQ09ORklHX1ND
U0lfREVCVUcvbGludXgtZGV2ZWw6ZGV2ZWwtaW5uLXg4Nl82NC0yMDEzMTAxOTA2MzQ6NjFl
NmNmYTgwZGU1NzYwYmJlNDA2ZjRlODE1Yjc3MzkyMDU3NTRkMjpiaXNlY3QtbmV0CiBTVUND
RVNTCgpiaXNlY3Q6IGdvb2QgY29tbWl0IDYxZTZjZmE4MGRlNTc2MGJiZTQwNmY0ZTgxNWI3
NzM5MjA1NzU0ZDIKZ2l0IGJpc2VjdCBzdGFydCBiOTFlODJkYzZhZDU1ZjJkMzliOTJlNzMx
YzZiYjk1Y2M0NGE5MjNjIDYxZTZjZmE4MGRlNTc2MGJiZTQwNmY0ZTgxNWI3NzM5MjA1NzU0
ZDIgLS0KUHJldmlvdXMgSEVBRCBwb3NpdGlvbiB3YXMgNjFlNmNmYS4uLiBMaW51eCAzLjEy
LXJjNQpTd2l0Y2hlZCB0byBicmFuY2ggJ21hc3RlcicKWW91ciBicmFuY2ggaXMgYmVoaW5k
ICdvcmlnaW4vbWFzdGVyJyBieSA0MTIxMyBjb21taXRzLCBhbmQgY2FuIGJlIGZhc3QtZm9y
d2FyZGVkLgogICh1c2UgImdpdCBwdWxsIiB0byB1cGRhdGUgeW91ciBsb2NhbCBicmFuY2gp
CkJpc2VjdGluZzogNjI5IHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91
Z2hseSA5IHN0ZXBzKQpbYTFiMTNiOWFkMzc1OWRjYTI0YzZiNzIxZWUwMjZjNTQwYTRlNjU2
NF0gcnQyeDAwOiBydDI4MDBwY2k6IHVzZSBtb2R1bGVfcGNpX2RyaXZlciBtYWNybwpnaXQg
YmlzZWN0IHJ1biAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNo
IC9ob21lL3dmZy9uZXQvb2JqLWJpc2VjdApydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNl
Y3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2hvbWUvd2ZnL25ldC9vYmotYmlzZWN0CmxzIC1h
IC9rZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2bS94ODZfNjQtbGtwLUNPTkZJR19TQ1NJX0RF
QlVHL2xpbnV4LWRldmVsOmRldmVsLWlubi14ODZfNjQtMjAxMzEwMTkwNjM0OmExYjEzYjlh
ZDM3NTlkY2EyNGM2YjcyMWVlMDI2YzU0MGE0ZTY1NjQ6YmlzZWN0LW5ldAoKMjAxMy0xMC0x
OS0yMDo1MjoxNiBhMWIxM2I5YWQzNzU5ZGNhMjRjNmI3MjFlZTAyNmM1NDBhNGU2NTY0IGNv
bXBpbGluZwozMjAgcmVhbCAgMTcyMiB1c2VyICAxNjIgc3lzICA1ODcuNjIlIGNwdSAJeDg2
XzY0LWxrcC1DT05GSUdfU0NTSV9ERUJVRwoKMjAxMy0xMC0xOS0yMDo1ODowMCBkZXRlY3Rp
bmcgYm9vdCBzdGF0ZSAzLjEyLjAtcmMxLTAwODQ3LWdhMWIxM2I5Li4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uCTEuLi4JMgkzLi4uCTUJMTIuLgkxNC4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLgkxNQkxNwkxOC4JMTkuLi4uLi4JMjAgU1VDQ0VT
UwoKQmlzZWN0aW5nOiAzMTMgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChy
b3VnaGx5IDggc3RlcHMpCltmZDFiNmQ1MWUxMTRiZTEyMTQ2MGEwN2U5Y2NiMjAwNTkyOGQw
Yzg4XSBNZXJnZSBicmFuY2ggJ3BtLWNwdWZyZXEtbmV4dCcgaW50byBsaW51eC1uZXh0CnJ1
bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvaG9t
ZS93ZmcvbmV0L29iai1iaXNlY3QKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3Zt
L3g4Nl82NC1sa3AtQ09ORklHX1NDU0lfREVCVUcvbGludXgtZGV2ZWw6ZGV2ZWwtaW5uLXg4
Nl82NC0yMDEzMTAxOTA2MzQ6ZmQxYjZkNTFlMTE0YmUxMjE0NjBhMDdlOWNjYjIwMDU5Mjhk
MGM4ODpiaXNlY3QtbmV0CgoyMDEzLTEwLTE5LTIxOjQ3OjAyIGZkMWI2ZDUxZTExNGJlMTIx
NDYwYTA3ZTljY2IyMDA1OTI4ZDBjODggY29tcGlsaW5nCjI1NSByZWFsICAxNzMxIHVzZXIg
IDE0NiBzeXMgIDczNS40NiUgY3B1IAl4ODZfNjQtbGtwLUNPTkZJR19TQ1NJX0RFQlVHCgoy
MDEzLTEwLTE5LTIxOjUxOjMxIGRldGVjdGluZyBib290IHN0YXRlIDMuMTIuMC1yYzUtMDAz
MTYtZ2ZkMWI2ZDUuLi4uLi4JMS4uLi4uLi4uLi4uLgkyLgkzLi4uLi4uLi4uLi4uLgk1CTcu
CTgJMTMuLi4uLi4uLi4uLi4uLi4uLi4uCTE0Li4JMTUJMTYuLi4uLi4uLi4uLi4uLi4uLi4u
Li4uCTE3Li4JMTguCTE5CTIwIFNVQ0NFU1MKCkJpc2VjdGluZzogMTU1IHJldmlzaW9ucyBs
ZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSA3IHN0ZXBzKQpbMTFlYzIzZjJjMDg3
NDY3NmEzMzIxZDMwNGQyYTAzZTJjNDZkYzY4MF0gTWVyZ2UgJ3NoYXduZ3VvL2Zvci1uZXh0
JyBpbnRvIGRldmVsLWlubi14ODZfNjQtMjAxMzEwMTkwNjM0CnJ1bm5pbmcgL2Mva2VybmVs
LXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvaG9tZS93ZmcvbmV0L29iai1i
aXNlY3QKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1sa3AtQ09O
RklHX1NDU0lfREVCVUcvbGludXgtZGV2ZWw6ZGV2ZWwtaW5uLXg4Nl82NC0yMDEzMTAxOTA2
MzQ6MTFlYzIzZjJjMDg3NDY3NmEzMzIxZDMwNGQyYTAzZTJjNDZkYzY4MDpiaXNlY3QtbmV0
CgoyMDEzLTEwLTE5LTIyOjM4OjAzIDExZWMyM2YyYzA4NzQ2NzZhMzMyMWQzMDRkMmEwM2Uy
YzQ2ZGM2ODAgY29tcGlsaW5nCjI0NyByZWFsICAxNzE2IHVzZXIgIDE0NiBzeXMgIDc1MS45
NyUgY3B1IAl4ODZfNjQtbGtwLUNPTkZJR19TQ1NJX0RFQlVHCgoyMDEzLTEwLTE5LTIyOjQy
OjI3IGRldGVjdGluZyBib290IHN0YXRlIDMuMTIuMC1yYzUtd2wtMDA3NzctZzExZWMyM2Yu
Li4uLi4JMS4uLi4uLi4uLi4uLi4JMi4uLi4uLi4uLi4uLi4uCTMJNQk2CTgJMTAuCTEzCTE3
LgkxOS4uLi4uLi4uLi4uLi4uLi4uCTIwIFNVQ0NFU1MKCkJpc2VjdGluZzogNzcgcmV2aXNp
b25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDYgc3RlcHMpCltlMzU4Nzg0
Mjk3OTkyYjAxMmU4MDcxNzY0ZDk5NjE5MWRkMmIxYTU0XSBjYW46IGZsZXhjYW46IGZpeCBt
eDI4IGRldGVjdGlvbiBieSByZWFyYW5naW5nIE9GIG1hdGNoIHRhYmxlCnJ1bm5pbmcgL2Mv
a2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvaG9tZS93ZmcvbmV0
L29iai1iaXNlY3QKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1s
a3AtQ09ORklHX1NDU0lfREVCVUcvbGludXgtZGV2ZWw6ZGV2ZWwtaW5uLXg4Nl82NC0yMDEz
MTAxOTA2MzQ6ZTM1ODc4NDI5Nzk5MmIwMTJlODA3MTc2NGQ5OTYxOTFkZDJiMWE1NDpiaXNl
Y3QtbmV0CgoyMDEzLTEwLTE5LTIzOjEzOjU5IGUzNTg3ODQyOTc5OTJiMDEyZTgwNzE3NjRk
OTk2MTkxZGQyYjFhNTQgY29tcGlsaW5nCjI1MiByZWFsICAxNzMwIHVzZXIgIDE0NSBzeXMg
IDc0NC42OSUgY3B1IAl4ODZfNjQtbGtwLUNPTkZJR19TQ1NJX0RFQlVHCgoyMDEzLTEwLTE5
LTIzOjE4OjI2IGRldGVjdGluZyBib290IHN0YXRlIDMuMTIuMC1yYzMtMDAyODItZ2UzNTg3
ODQuLi4uLi4uLi4uLi4uLi4uLi4uLi4JMS4uLi4uLi4uCTIuLi4uLgkzCTUJNgkxMAkxMS4u
LgkxNy4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uCTE4
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4JMjAgU1VDQ0VTUwoKQmlzZWN0aW5nOiAz
OCByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgNSBzdGVwcykK
WzJiMTNkMDZjOTU4NGI0ZWI3NzNmMWU4MGJiYWVkYWI5YTFjMzQ0ZTFdIHdhbnhsOiBmaXgg
aW5mbyBsZWFrIGluIGlvY3RsCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0
LWJvb3QtZmFpbHVyZS5zaCAvaG9tZS93ZmcvbmV0L29iai1iaXNlY3QKbHMgLWEgL2tlcm5l
bC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1sa3AtQ09ORklHX1NDU0lfREVCVUcvbGlu
dXgtZGV2ZWw6ZGV2ZWwtaW5uLXg4Nl82NC0yMDEzMTAxOTA2MzQ6MmIxM2QwNmM5NTg0YjRl
Yjc3M2YxZTgwYmJhZWRhYjlhMWMzNDRlMTpiaXNlY3QtbmV0CgoyMDEzLTEwLTIwLTAwOjE5
OjU4IDJiMTNkMDZjOTU4NGI0ZWI3NzNmMWU4MGJiYWVkYWI5YTFjMzQ0ZTEgY29tcGlsaW5n
Cjc5IHJlYWwgIDQ0NCB1c2VyICA0MyBzeXMgIDYxNy44MyUgY3B1IAl4ODZfNjQtbGtwLUNP
TkZJR19TQ1NJX0RFQlVHCgoyMDEzLTEwLTIwLTAwOjIxOjMyIGRldGVjdGluZyBib290IHN0
YXRlIDMuMTIuMC1yYzMtMDAzMzQtZzJiMTNkMDYuLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4gVEVTVCBGQUlMVVJFClsgIDYzMS4yNDQ0NDJdIENQVTAgYXR0YWNoaW5nIE5VTEwgc2No
ZWQtZG9tYWluLgpbICA2MzEuMjQ0NDQ4XSBDUFUxIGF0dGFjaGluZyBOVUxMIHNjaGVkLWRv
bWFpbi4KWyAgNjMxLjI0NDUwNF0gQ1BVMCBhdHRhY2hpbmcgTlVMTCBzY2hlZC1kb21haW4u
ClsgIDYzMS4yNTIyNjNdIEJVRzogc2xlZXBpbmcgZnVuY3Rpb24gY2FsbGVkIGZyb20gaW52
YWxpZCBjb250ZXh0IGF0IGtlcm5lbC9tdXRleC5jOjYxNgpbICA2MzEuMjUyMjYzXSBpbl9h
dG9taWMoKTogMSwgaXJxc19kaXNhYmxlZCgpOiAxLCBwaWQ6IDEwLCBuYW1lOiBtaWdyYXRp
b24vMQpbICA2MzEuMjUyMjYzXSBubyBsb2NrcyBoZWxkIGJ5IG1pZ3JhdGlvbi8xLzEwLgpb
ICA2MzEuMjUyMjYzXSBDUFU6IDEgUElEOiAxMCBDb21tOiBtaWdyYXRpb24vMSBOb3QgdGFp
bnRlZCAzLjEyLjAtcmMzLTAwMzM0LWcyYjEzZDA2ICM0NjUKWyAgNjMxLjI1MjI2M10gSGFy
ZHdhcmUgbmFtZTogQm9jaHMgQm9jaHMsIEJJT1MgQm9jaHMgMDEvMDEvMjAxMQpbICA2MzEu
MjUyMjYzXSAgMDAwMDAwMDAwMDAwMDAwMCBmZmZmODgwMDFkNDJkYmEwIGZmZmZmZmZmODFh
MmZlODUgZmZmZjg4MDAxYmY0MmM3MApbICA2MzEuMjUyMjYzXSAgZmZmZjg4MDAxZDQyZGJi
MCBmZmZmZmZmZjgxMGVkYjAyIGZmZmY4ODAwMWQ0MmRjMzggZmZmZmZmZmY4MWEzNjY0ZApb
ICA2MzEuMjUyMjYzXSAgMDAwMDAwMDAwMDAwMDA0NiBmZmZmODgwMDFkNDJkYmU4IGZmZmZm
ZmZmODEwZTg2MWQgMDAwMDAwMDAwMDAwMDAwMApbICA2MzEuMjUyMjYzXSBDYWxsIFRyYWNl
OgpbICA2MzEuMjUyMjYzXSAgWzxmZmZmZmZmZjgxYTJmZTg1Pl0gZHVtcF9zdGFjaysweDU0
LzB4NzQKWyAgNjMxLjI1MjI2M10gIFs8ZmZmZmZmZmY4MTBlZGIwMj5dIF9fbWlnaHRfc2xl
ZXArMHgxMTIvMHgxMTQKWyAgNjMxLjI1MjI2M10gIFs8ZmZmZmZmZmY4MWEzNjY0ZD5dIG11
dGV4X2xvY2tfbmVzdGVkKzB4M2MvMHgzYzYKWyAgNjMxLjI1MjI2M10gIFs8ZmZmZmZmZmY4
MTBlODYxZD5dID8gdXArMHgzOS8weDNlClsgIDYzMS4yNTIyNjNdICBbPGZmZmZmZmZmODE1
M2VkZDk+XSA/IGFjcGlfb3Nfc2lnbmFsX3NlbWFwaG9yZSsweDIxLzB4MmQKWyAgNjMxLjI1
MjI2M10gIFs8ZmZmZmZmZmY4MTU2NjMxYT5dID8gYWNwaV91dF9yZWxlYXNlX211dGV4KzB4
NWUvMHg2MgpbICA2MzEuMjUyMjYzXSAgWzxmZmZmZmZmZjgxNmNjYTExPl0gdmlydG5ldF9j
cHVfY2FsbGJhY2srMHgzMy8weDg3ClsgIDYzMS4yNTIyNjNdICBbPGZmZmZmZmZmODFhM2Y0
ZjY+XSBub3RpZmllcl9jYWxsX2NoYWluKzB4M2MvMHg1ZQpbICA2MzEuMjUyMjYzXSAgWzxm
ZmZmZmZmZjgxMGU4NmE4Pl0gX19yYXdfbm90aWZpZXJfY2FsbF9jaGFpbisweGUvMHgxMApb
ICA2MzEuMjUyMjYzXSAgWzxmZmZmZmZmZjgxMGM1NTU2Pl0gX19jcHVfbm90aWZ5KzB4MjAv
MHgzNwpbICA2MzEuMjUyMjYzXSAgWzxmZmZmZmZmZjgxMGM1NTgwPl0gY3B1X25vdGlmeSsw
eDEzLzB4MTUKWyAgNjMxLjI1MjI2M10gIFs8ZmZmZmZmZmY4MWEyMDZlOT5dIHRha2VfY3B1
X2Rvd24rMHgyNy8weDNhClsgIDYzMS4yNTIyNjNdICBbPGZmZmZmZmZmODExMzYyNmQ+XSBz
dG9wX21hY2hpbmVfY3B1X3N0b3ArMHg5My8weGYxClsgIDYzMS4yNTIyNjNdICBbPGZmZmZm
ZmZmODExMzYxNGI+XSBjcHVfc3RvcHBlcl90aHJlYWQrMHhhMC8weDEyZgpbICA2MzEuMjUy
MjYzXSAgWzxmZmZmZmZmZjgxMTM2MWRhPl0gPyBjcHVfc3RvcHBlcl90aHJlYWQrMHgxMmYv
MHgxMmYKWyAgNjMxLjI1MjI2M10gIFs8ZmZmZmZmZmY4MTExOTZlYj5dID8gbG9ja19yZWxl
YXNlX2hvbGR0aW1lLnBhcnQuNysweGEzLzB4YTgKWyAgNjMxLjI1MjI2M10gIFs8ZmZmZmZm
ZmY4MTEzNWUyZj5dID8gY3B1X3N0b3Bfc2hvdWxkX3J1bisweDNmLzB4NDcKWyAgNjMxLjI1
MjI2M10gIFs8ZmZmZmZmZmY4MTBlYTliMD5dIHNtcGJvb3RfdGhyZWFkX2ZuKzB4MWM1LzB4
MWUzClsgIDYzMS4yNTIyNjNdICBbPGZmZmZmZmZmODEwZWE3ZWI+XSA/IGxnX2dsb2JhbF91
bmxvY2srMHg2Ny8weDY3ClsgIDYzMS4yNTIyNjNdICBbPGZmZmZmZmZmODEwZTM2Yjc+XSBr
dGhyZWFkKzB4ZDgvMHhlMApbICA2MzEuMjUyMjYzXSAgWzxmZmZmZmZmZjgxYTM4ZjBkPl0g
PyB3YWl0X2Zvcl9jb21tb24rMHgxMmYvMHgxNjQKWyAgNjMxLjI1MjI2M10gIFs8ZmZmZmZm
ZmY4MTBlMzVkZj5dID8ga3RocmVhZF9jcmVhdGVfb25fbm9kZSsweDEyNC8weDEyNApbICA2
MzEuMjUyMjYzXSAgWzxmZmZmZmZmZjgxYTQyZjdjPl0gcmV0X2Zyb21fZm9yaysweDdjLzB4
YjAKWyAgNjMxLjI1MjI2M10gIFs8ZmZmZmZmZmY4MTBlMzVkZj5dID8ga3RocmVhZF9jcmVh
dGVfb25fbm9kZSsweDEyNC8weDEyNApbICA2MzEuMjU0NDU0XSBzbXBib290OiBDUFUgMSBp
cyBub3cgb2ZmbGluZQpbICA2MzEuNDYyMTA4XSBTTVAgYWx0ZXJuYXRpdmVzOiBsb2NrZGVw
OiBmaXhpbmcgdXAgYWx0ZXJuYXRpdmVzClsgIDYzMS40NjIxMTNdIHNtcGJvb3Q6IEJvb3Rp
bmcgTm9kZSAwIFByb2Nlc3NvciAxIEFQSUMgMHgxCi9rZXJuZWwveDg2XzY0LWxrcC1DT05G
SUdfU0NTSV9ERUJVRy8yYjEzZDA2Yzk1ODRiNGViNzczZjFlODBiYmFlZGFiOWExYzM0NGUx
L2RtZXNnLW5mc3Jvb3QtY2Fpcm8tMTY6MjAxMzEwMjAwMDMyMjQ6eDg2XzY0LWxrcC1DT05G
SUdfU0NTSV9ERUJVRzozLjEyLjAtcmMzLTAwMzM0LWcyYjEzZDA2OjQ2NQova2VybmVsL3g4
Nl82NC1sa3AtQ09ORklHX1NDU0lfREVCVUcvMmIxM2QwNmM5NTg0YjRlYjc3M2YxZTgwYmJh
ZWRhYjlhMWMzNDRlMS9kbWVzZy1uZnNyb290LXdhaW1lYS0yOjIwMTMxMDIwMDgyNzMyOng4
Nl82NC1sa3AtQ09ORklHX1NDU0lfREVCVUc6My4xMi4wLXJjMy0wMDMzNC1nMmIxM2QwNjo0
NjUKL2tlcm5lbC94ODZfNjQtbGtwLUNPTkZJR19TQ1NJX0RFQlVHLzJiMTNkMDZjOTU4NGI0
ZWI3NzNmMWU4MGJiYWVkYWI5YTFjMzQ0ZTEvZG1lc2ctcXVhbnRhbC1jYWlyby0xOToyMDEz
MTAyMDAwMzIxOTp4ODZfNjQtbGtwLUNPTkZJR19TQ1NJX0RFQlVHOjMuMTIuMC1yYzMtMDAz
MzQtZzJiMTNkMDY6NDY1Ci9rZXJuZWwveDg2XzY0LWxrcC1DT05GSUdfU0NTSV9ERUJVRy8y
YjEzZDA2Yzk1ODRiNGViNzczZjFlODBiYmFlZGFiOWExYzM0NGUxL2RtZXNnLXF1YW50YWwt
Y2Fpcm8tMjc6MjAxMzEwMjAwMDMyMTE6eDg2XzY0LWxrcC1DT05GSUdfU0NTSV9ERUJVRzoz
LjEyLjAtcmMzLTAwMzM0LWcyYjEzZDA2OjQ2NQova2VybmVsL3g4Nl82NC1sa3AtQ09ORklH
X1NDU0lfREVCVUcvMmIxM2QwNmM5NTg0YjRlYjc3M2YxZTgwYmJhZWRhYjlhMWMzNDRlMS9k
bWVzZy1xdWFudGFsLWNhaXJvLTk6MjAxMzEwMjAwMDMyMDc6eDg2XzY0LWxrcC1DT05GSUdf
U0NTSV9ERUJVRzozLjEyLjAtcmMzLTAwMzM0LWcyYjEzZDA2OjQ2NQova2VybmVsL3g4Nl82
NC1sa3AtQ09ORklHX1NDU0lfREVCVUcvMmIxM2QwNmM5NTg0YjRlYjc3M2YxZTgwYmJhZWRh
YjlhMWMzNDRlMS9kbWVzZy15b2N0by1sa3Atc3QwMS0yOjIwMTMxMDIwMDAyMzA3Ong4Nl82
NC1sa3AtQ09ORklHX1NDU0lfREVCVUc6My4xMi4wLXJjMy0wMDMzNC1nMmIxM2QwNjo0NjUK
MDo2OjYgYWxsX2dvb2Q6YmFkOmFsbF9iYWQgYm9vdHMKG1sxOzM1bVJFUEVBVCBDT1VOVDog
MjAgICMgL2NjL3dmZy9uZXQtYmlzZWN0Ly5yZXBlYXQbWzBtCgpCaXNlY3Rpbmc6IDE5IHJl
dmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSA0IHN0ZXBzKQpbNzI1
OTA3ODI3YTdmNDZkZmI1ZGY2ZTRmM2Q4ZjliY2JjOTkwMzg3N10gTWVyZ2UgYnJhbmNoICdz
Y3RwX2NzdW0nCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFp
bHVyZS5zaCAvaG9tZS93ZmcvbmV0L29iai1iaXNlY3QKbHMgLWEgL2tlcm5lbC10ZXN0cy9y
dW4tcXVldWUva3ZtL3g4Nl82NC1sa3AtQ09ORklHX1NDU0lfREVCVUcvbGludXgtZGV2ZWw6
ZGV2ZWwtaW5uLXg4Nl82NC0yMDEzMTAxOTA2MzQ6NzI1OTA3ODI3YTdmNDZkZmI1ZGY2ZTRm
M2Q4ZjliY2JjOTkwMzg3NzpiaXNlY3QtbmV0CgoyMDEzLTEwLTIwLTAwOjM1OjA3IDcyNTkw
NzgyN2E3ZjQ2ZGZiNWRmNmU0ZjNkOGY5YmNiYzk5MDM4NzcgY29tcGlsaW5nCjI4IHJlYWwg
IDU0IHVzZXIgIDEwIHN5cyAgMjI1LjEwJSBjcHUgCXg4Nl82NC1sa3AtQ09ORklHX1NDU0lf
REVCVUcKCjIwMTMtMTAtMjAtMDA6Mzc6MjYgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgMy4xMi4w
LXJjMy0wMDMwMS1nNzI1OTA3OC4uLi4uLi4JMS4uLi4uLi4uLi4uLgkyLi4uLi4uLi4uCTMu
Li4uLi4uLi4uCTkuLi4uLi4uLi4uLi4uLi4uLi4JMTQJMTUuLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLgkxNi4uLi4uCTE3LgkxOS4JMjAgU1VDQ0VTUwoKQmlzZWN0aW5nOiAx
MCByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgMyBzdGVwcykK
W2NlOTdmZWY0MjM1Mzc4MTA4ZWQzYmQ5NmUxYjNlYWI4ZmQwYTFmYmRdIG5ldDogcW1pX3d3
YW46IE9saXZldHRpIE9saWNhcmQgMjAwIHN1cHBvcnQKcnVubmluZyAvYy9rZXJuZWwtdGVz
dHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9ob21lL3dmZy9uZXQvb2JqLWJpc2Vj
dApscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0veDg2XzY0LWxrcC1DT05GSUdf
U0NTSV9ERUJVRy9saW51eC1kZXZlbDpkZXZlbC1pbm4teDg2XzY0LTIwMTMxMDE5MDYzNDpj
ZTk3ZmVmNDIzNTM3ODEwOGVkM2JkOTZlMWIzZWFiOGZkMGExZmJkOmJpc2VjdC1uZXQKCjIw
MTMtMTAtMjAtMDE6Mjk6NTkgY2U5N2ZlZjQyMzUzNzgxMDhlZDNiZDk2ZTFiM2VhYjhmZDBh
MWZiZCBjb21waWxpbmcKMzIgcmVhbCAgNTAgdXNlciAgMTAgc3lzICAxOTAuNjklIGNwdSAJ
eDg2XzY0LWxrcC1DT05GSUdfU0NTSV9ERUJVRwoKMjAxMy0xMC0yMC0wMTozMDo0NCBkZXRl
Y3RpbmcgYm9vdCBzdGF0ZSAzLjEyLjAtcmMzLTAwMzEwLWdjZTk3ZmVmLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uIFRFU1QgRkFJTFVSRQpbICA3
NzQuMDc2MzQ2XSBDUFUwIGF0dGFjaGluZyBOVUxMIHNjaGVkLWRvbWFpbi4KWyAgNzc0LjA3
NjM1M10gQ1BVMSBhdHRhY2hpbmcgTlVMTCBzY2hlZC1kb21haW4uClsgIDc3NC4wNzY0MTFd
IENQVTAgYXR0YWNoaW5nIE5VTEwgc2NoZWQtZG9tYWluLgpbICA3NzQuMDc5NTk1XSBCVUc6
IHNsZWVwaW5nIGZ1bmN0aW9uIGNhbGxlZCBmcm9tIGludmFsaWQgY29udGV4dCBhdCBrZXJu
ZWwvbXV0ZXguYzo2MTYKWyAgNzc0LjA3OTU5OF0gaW5fYXRvbWljKCk6IDEsIGlycXNfZGlz
YWJsZWQoKTogMSwgcGlkOiAxMCwgbmFtZTogbWlncmF0aW9uLzEKWyAgNzc0LjA3OTU5OV0g
bm8gbG9ja3MgaGVsZCBieSBtaWdyYXRpb24vMS8xMC4KWyAgNzc0LjA3OTYwNF0gQ1BVOiAx
IFBJRDogMTAgQ29tbTogbWlncmF0aW9uLzEgTm90IHRhaW50ZWQgMy4xMi4wLXJjMy0wMDMx
MC1nY2U5N2ZlZiAjNDY3ClsgIDc3NC4wNzk2MDVdIEhhcmR3YXJlIG5hbWU6IEJvY2hzIEJv
Y2hzLCBCSU9TIEJvY2hzIDAxLzAxLzIwMTEKWyAgNzc0LjA3OTYwOV0gIDAwMDAwMDAwMDAw
MDAwMDAgZmZmZjg4MDAxZDQyZGJhMCBmZmZmZmZmZjgxYTJmZTE1IGZmZmY4ODAwMWQ3ZWNj
NzAKWyAgNzc0LjA3OTYxMl0gIGZmZmY4ODAwMWQ0MmRiYjAgZmZmZmZmZmY4MTBlZGIwMiBm
ZmZmODgwMDFkNDJkYzM4IGZmZmZmZmZmODFhMzY1ZGQKWyAgNzc0LjA3OTYxNV0gIDAwMDAw
MDAwMDAwMDAwNDYgZmZmZjg4MDAxZDQyZGJlOCBmZmZmZmZmZjgxMGU4NjFkIDAwMDAwMDAw
MDAwMDAwMDAKWyAgNzc0LjA3OTYxNl0gQ2FsbCBUcmFjZToKWyAgNzc0LjA3OTYzNl0gIFs8
ZmZmZmZmZmY4MWEyZmUxNT5dIGR1bXBfc3RhY2srMHg1NC8weDc0ClsgIDc3NC4wNzk2NDRd
ICBbPGZmZmZmZmZmODEwZWRiMDI+XSBfX21pZ2h0X3NsZWVwKzB4MTEyLzB4MTE0ClsgIDc3
NC4wNzk2NDldICBbPGZmZmZmZmZmODFhMzY1ZGQ+XSBtdXRleF9sb2NrX25lc3RlZCsweDNj
LzB4M2M2ClsgIDc3NC4wNzk2NTNdICBbPGZmZmZmZmZmODEwZTg2MWQ+XSA/IHVwKzB4Mzkv
MHgzZQpbICA3NzQuMDc5NjU5XSAgWzxmZmZmZmZmZjgxNTNlZGQ5Pl0gPyBhY3BpX29zX3Np
Z25hbF9zZW1hcGhvcmUrMHgyMS8weDJkClsgIDc3NC4wNzk2NjVdICBbPGZmZmZmZmZmODE1
NjYzMWE+XSA/IGFjcGlfdXRfcmVsZWFzZV9tdXRleCsweDVlLzB4NjIKWyAgNzc0LjA3OTY3
NV0gIFs8ZmZmZmZmZmY4MTZjY2ExMT5dIHZpcnRuZXRfY3B1X2NhbGxiYWNrKzB4MzMvMHg4
NwpbICA3NzQuMDc5NjgwXSAgWzxmZmZmZmZmZjgxYTNmNDc2Pl0gbm90aWZpZXJfY2FsbF9j
aGFpbisweDNjLzB4NWUKWyAgNzc0LjA3OTY4M10gIFs8ZmZmZmZmZmY4MTBlODZhOD5dIF9f
cmF3X25vdGlmaWVyX2NhbGxfY2hhaW4rMHhlLzB4MTAKWyAgNzc0LjA3OTY4OV0gIFs8ZmZm
ZmZmZmY4MTBjNTU1Nj5dIF9fY3B1X25vdGlmeSsweDIwLzB4MzcKWyAgNzc0LjA3OTY5MV0g
IFs8ZmZmZmZmZmY4MTBjNTU4MD5dIGNwdV9ub3RpZnkrMHgxMy8weDE1ClsgIDc3NC4wNzk2
OTddICBbPGZmZmZmZmZmODFhMjA2Nzk+XSB0YWtlX2NwdV9kb3duKzB4MjcvMHgzYQpbICA3
NzQuMDc5NzAyXSAgWzxmZmZmZmZmZjgxMTM2MjZkPl0gc3RvcF9tYWNoaW5lX2NwdV9zdG9w
KzB4OTMvMHhmMQpbICA3NzQuMDc5NzA1XSAgWzxmZmZmZmZmZjgxMTM2MTRiPl0gY3B1X3N0
b3BwZXJfdGhyZWFkKzB4YTAvMHgxMmYKWyAgNzc0LjA3OTcwN10gIFs8ZmZmZmZmZmY4MTEz
NjFkYT5dID8gY3B1X3N0b3BwZXJfdGhyZWFkKzB4MTJmLzB4MTJmClsgIDc3NC4wNzk3MTRd
ICBbPGZmZmZmZmZmODExMTk2ZWI+XSA/IGxvY2tfcmVsZWFzZV9ob2xkdGltZS5wYXJ0Ljcr
MHhhMy8weGE4ClsgIDc3NC4wNzk3MTZdICBbPGZmZmZmZmZmODExMzVlMmY+XSA/IGNwdV9z
dG9wX3Nob3VsZF9ydW4rMHgzZi8weDQ3ClsgIDc3NC4wNzk3MjBdICBbPGZmZmZmZmZmODEw
ZWE5YjA+XSBzbXBib290X3RocmVhZF9mbisweDFjNS8weDFlMwpbICA3NzQuMDc5NzI0XSAg
WzxmZmZmZmZmZjgxMGVhN2ViPl0gPyBsZ19nbG9iYWxfdW5sb2NrKzB4NjcvMHg2NwpbICA3
NzQuMDc5NzI4XSAgWzxmZmZmZmZmZjgxMGUzNmI3Pl0ga3RocmVhZCsweGQ4LzB4ZTAKWyAg
Nzc0LjA3OTczMl0gIFs8ZmZmZmZmZmY4MWEzOGU5ZD5dID8gd2FpdF9mb3JfY29tbW9uKzB4
MTJmLzB4MTY0ClsgIDc3NC4wNzk3MzZdICBbPGZmZmZmZmZmODEwZTM1ZGY+XSA/IGt0aHJl
YWRfY3JlYXRlX29uX25vZGUrMHgxMjQvMHgxMjQKWyAgNzc0LjA3OTc0MF0gIFs8ZmZmZmZm
ZmY4MWE0MmVmYz5dIHJldF9mcm9tX2ZvcmsrMHg3Yy8weGIwClsgIDc3NC4wNzk3NDNdICBb
PGZmZmZmZmZmODEwZTM1ZGY+XSA/IGt0aHJlYWRfY3JlYXRlX29uX25vZGUrMHgxMjQvMHgx
MjQKWyAgNzc0LjA3OTc2Nl0gc21wYm9vdDogQ1BVIDEgaXMgbm93IG9mZmxpbmUKWyAgNzc0
LjI4MzYzMl0gU01QIGFsdGVybmF0aXZlczogbG9ja2RlcDogZml4aW5nIHVwIGFsdGVybmF0
aXZlcwpbICA3NzQuMjgzNjM3XSBzbXBib290OiBCb290aW5nIE5vZGUgMCBQcm9jZXNzb3Ig
MSBBUElDIDB4MQova2VybmVsL3g4Nl82NC1sa3AtQ09ORklHX1NDU0lfREVCVUcvY2U5N2Zl
ZjQyMzUzNzgxMDhlZDNiZDk2ZTFiM2VhYjhmZDBhMWZiZC9kbWVzZy1uZnNyb290LWF0aGVu
cy0yNToyMDEzMTAyMDAxNDM1Mzp4ODZfNjQtbGtwLUNPTkZJR19TQ1NJX0RFQlVHOjMuMTIu
MC1yYzMtMDAzMTAtZ2NlOTdmZWY6NDY3Ci9rZXJuZWwveDg2XzY0LWxrcC1DT05GSUdfU0NT
SV9ERUJVRy9jZTk3ZmVmNDIzNTM3ODEwOGVkM2JkOTZlMWIzZWFiOGZkMGExZmJkL2RtZXNn
LW5mc3Jvb3QtYXRoZW5zLTg6MjAxMzEwMjAwMTQ1NDI6eDg2XzY0LWxrcC1DT05GSUdfU0NT
SV9ERUJVRzozLjEyLjAtcmMzLTAwMzEwLWdjZTk3ZmVmOjQ2Nwova2VybmVsL3g4Nl82NC1s
a3AtQ09ORklHX1NDU0lfREVCVUcvY2U5N2ZlZjQyMzUzNzgxMDhlZDNiZDk2ZTFiM2VhYjhm
ZDBhMWZiZC9kbWVzZy1uZnNyb290LWF0aGVucy05OjIwMTMxMDIwMDE0NzM1Ong4Nl82NC1s
a3AtQ09ORklHX1NDU0lfREVCVUc6My4xMi4wLXJjMy0wMDMxMC1nY2U5N2ZlZjo0NjcKL2tl
cm5lbC94ODZfNjQtbGtwLUNPTkZJR19TQ1NJX0RFQlVHL2NlOTdmZWY0MjM1Mzc4MTA4ZWQz
YmQ5NmUxYjNlYWI4ZmQwYTFmYmQvZG1lc2ctbmZzcm9vdC1jYWlyby03OjIwMTMxMDIwMDE0
NDQzOng4Nl82NC1sa3AtQ09ORklHX1NDU0lfREVCVUc6My4xMi4wLXJjMy0wMDMxMC1nY2U5
N2ZlZjo0NjcKL2tlcm5lbC94ODZfNjQtbGtwLUNPTkZJR19TQ1NJX0RFQlVHL2NlOTdmZWY0
MjM1Mzc4MTA4ZWQzYmQ5NmUxYjNlYWI4ZmQwYTFmYmQvZG1lc2ctbmZzcm9vdC1yb2FtLTE3
OjIwMTMxMDIwMDE0MjI5Ong4Nl82NC1sa3AtQ09ORklHX1NDU0lfREVCVUc6My4xMi4wLXJj
My0wMDMxMC1nY2U5N2ZlZjo0NjcKL2tlcm5lbC94ODZfNjQtbGtwLUNPTkZJR19TQ1NJX0RF
QlVHL2NlOTdmZWY0MjM1Mzc4MTA4ZWQzYmQ5NmUxYjNlYWI4ZmQwYTFmYmQvZG1lc2ctbmZz
cm9vdC1zbmItMjE6MjAxMzEwMjAwMTQ2MjY6eDg2XzY0LWxrcC1DT05GSUdfU0NTSV9ERUJV
RzozLjEyLjAtcmMzLTAwMzEwLWdjZTk3ZmVmOjQ2Nwova2VybmVsL3g4Nl82NC1sa3AtQ09O
RklHX1NDU0lfREVCVUcvY2U5N2ZlZjQyMzUzNzgxMDhlZDNiZDk2ZTFiM2VhYjhmZDBhMWZi
ZC9kbWVzZy1uZnNyb290LXNuYi0zOjIwMTMxMDIwMDE0NjQ5Ong4Nl82NC1sa3AtQ09ORklH
X1NDU0lfREVCVUc6My4xMi4wLXJjMy0wMDMxMC1nY2U5N2ZlZjo0NjcKL2tlcm5lbC94ODZf
NjQtbGtwLUNPTkZJR19TQ1NJX0RFQlVHL2NlOTdmZWY0MjM1Mzc4MTA4ZWQzYmQ5NmUxYjNl
YWI4ZmQwYTFmYmQvZG1lc2ctcXVhbnRhbC1hdGhlbnMtMzI6MjAxMzEwMjAwMTQ1MDg6eDg2
XzY0LWxrcC1DT05GSUdfU0NTSV9ERUJVRzozLjEyLjAtcmMzLTAwMzEwLWdjZTk3ZmVmOjQ2
Nwova2VybmVsL3g4Nl82NC1sa3AtQ09ORklHX1NDU0lfREVCVUcvY2U5N2ZlZjQyMzUzNzgx
MDhlZDNiZDk2ZTFiM2VhYjhmZDBhMWZiZC9kbWVzZy1xdWFudGFsLWF0aGVucy0zOToyMDEz
MTAyMDAxNDcwNzp4ODZfNjQtbGtwLUNPTkZJR19TQ1NJX0RFQlVHOjMuMTIuMC1yYzMtMDAz
MTAtZ2NlOTdmZWY6NDY3Ci9rZXJuZWwveDg2XzY0LWxrcC1DT05GSUdfU0NTSV9ERUJVRy9j
ZTk3ZmVmNDIzNTM3ODEwOGVkM2JkOTZlMWIzZWFiOGZkMGExZmJkL2RtZXNnLXF1YW50YWwt
Y2Fpcm8tMjI6MjAxMzEwMjAwMTQ0Mzc6eDg2XzY0LWxrcC1DT05GSUdfU0NTSV9ERUJVRzoz
LjEyLjAtcmMzLTAwMzEwLWdjZTk3ZmVmOjQ2Nwova2VybmVsL3g4Nl82NC1sa3AtQ09ORklH
X1NDU0lfREVCVUcvY2U5N2ZlZjQyMzUzNzgxMDhlZDNiZDk2ZTFiM2VhYjhmZDBhMWZiZC9k
bWVzZy1xdWFudGFsLWlubi0xOToyMDEzMTAyMDAxNDEyODp4ODZfNjQtbGtwLUNPTkZJR19T
Q1NJX0RFQlVHOjMuMTIuMC1yYzMtMDAzMTAtZ2NlOTdmZWY6NDY3Ci9rZXJuZWwveDg2XzY0
LWxrcC1DT05GSUdfU0NTSV9ERUJVRy9jZTk3ZmVmNDIzNTM3ODEwOGVkM2JkOTZlMWIzZWFi
OGZkMGExZmJkL2RtZXNnLXF1YW50YWwtbGtwLXN0MDEtMTA6MjAxMzEwMjAwMTQ3MDI6eDg2
XzY0LWxrcC1DT05GSUdfU0NTSV9ERUJVRzozLjEyLjAtcmMzLTAwMzEwLWdjZTk3ZmVmOjQ2
Nwova2VybmVsL3g4Nl82NC1sa3AtQ09ORklHX1NDU0lfREVCVUcvY2U5N2ZlZjQyMzUzNzgx
MDhlZDNiZDk2ZTFiM2VhYjhmZDBhMWZiZC9kbWVzZy1xdWFudGFsLWxrcC10dDAyLTIzOjIw
MTMxMDE5MTYyODA2Ong4Nl82NC1sa3AtQ09ORklHX1NDU0lfREVCVUc6My4xMi4wLXJjMy0w
MDMxMC1nY2U5N2ZlZjo0NjcKL2tlcm5lbC94ODZfNjQtbGtwLUNPTkZJR19TQ1NJX0RFQlVH
L2NlOTdmZWY0MjM1Mzc4MTA4ZWQzYmQ5NmUxYjNlYWI4ZmQwYTFmYmQvZG1lc2ctcXVhbnRh
bC14aWFuLTc6MjAxMzEwMjAwMTQ4MzE6eDg2XzY0LWxrcC1DT05GSUdfU0NTSV9ERUJVRzoz
LjEyLjAtcmMzLTAwMzEwLWdjZTk3ZmVmOjQ2Nwova2VybmVsL3g4Nl82NC1sa3AtQ09ORklH
X1NDU0lfREVCVUcvY2U5N2ZlZjQyMzUzNzgxMDhlZDNiZDk2ZTFiM2VhYjhmZDBhMWZiZC9k
bWVzZy15b2N0by1pbm4tMTE6MjAxMzEwMjAwMTQyMDg6eDg2XzY0LWxrcC1DT05GSUdfU0NT
SV9ERUJVRzozLjEyLjAtcmMzLTAwMzEwLWdjZTk3ZmVmOjQ2Nwova2VybmVsL3g4Nl82NC1s
a3AtQ09ORklHX1NDU0lfREVCVUcvY2U5N2ZlZjQyMzUzNzgxMDhlZDNiZDk2ZTFiM2VhYjhm
ZDBhMWZiZC9kbWVzZy15b2N0by1zbmItMToyMDEzMTAyMDAxNDc1Nzp4ODZfNjQtbGtwLUNP
TkZJR19TQ1NJX0RFQlVHOjMuMTIuMC1yYzMtMDAzMTAtZ2NlOTdmZWY6NDY3Ci9rZXJuZWwv
eDg2XzY0LWxrcC1DT05GSUdfU0NTSV9ERUJVRy9jZTk3ZmVmNDIzNTM3ODEwOGVkM2JkOTZl
MWIzZWFiOGZkMGExZmJkL2RtZXNnLXlvY3RvLXN0b2FrbGV5LTE6MjAxMzEwMjAwMTQ0NDM6
eDg2XzY0LWxrcC1DT05GSUdfU0NTSV9ERUJVRzozLjEyLjAtcmMzLTAwMzEwLWdjZTk3ZmVm
OjQ2NwowOjE3OjE3IGFsbF9nb29kOmJhZDphbGxfYmFkIGJvb3RzChtbMTszNW1SRVBFQVQg
Q09VTlQ6IDIwICAjIC9jYy93ZmcvbmV0LWJpc2VjdC8ucmVwZWF0G1swbQoKQmlzZWN0aW5n
OiA0IHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSAyIHN0ZXBz
KQpbZGJiZDJhZDg5YmIxZjg2Yjk0YjIzYmIyZTU2ZDQ5MzU3MTdmOWI5NF0gbmV0L2V0aGVy
bmV0OiBjcHN3OiBCdWdmaXggaW50ZXJydXB0cyBiZWZvcmUgZW5hYmxpbmcgbmFwaQpydW5u
aW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2hvbWUv
d2ZnL25ldC9vYmotYmlzZWN0CmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2bS94
ODZfNjQtbGtwLUNPTkZJR19TQ1NJX0RFQlVHL2xpbnV4LWRldmVsOmRldmVsLWlubi14ODZf
NjQtMjAxMzEwMTkwNjM0OmRiYmQyYWQ4OWJiMWY4NmI5NGIyM2JiMmU1NmQ0OTM1NzE3Zjli
OTQ6YmlzZWN0LW5ldAoKMjAxMy0xMC0yMC0wMTo1NDo1MCBkYmJkMmFkODliYjFmODZiOTRi
MjNiYjJlNTZkNDkzNTcxN2Y5Yjk0IGNvbXBpbGluZwoxMzQgcmVhbCAgNDYgdXNlciAgOSBz
eXMgIDQxLjUwJSBjcHUgCXg4Nl82NC1sa3AtQ09ORklHX1NDU0lfREVCVUcKCjIwMTMtMTAt
MjAtMDE6NTc6NTEgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgMy4xMi4wLXJjMy0wMDMwNS1nZGJi
ZDJhZC4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uCTEzLi4uCTE2Li4uLi4uLi4uCTE3Li4uLi4uLi4uLi4uLi4uLi4uLi4uLgkyMCBT
VUNDRVNTCgpCaXNlY3Rpbmc6IDIgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlz
IChyb3VnaGx5IDEgc3RlcCkKWzM5YmI5M2Y4OGM1ZGI1NGNiZTFkZjBiMGFhOTU3YjNhOGYy
MjI3ZWRdIHlhbTogcmVtb3ZlIGEgbm8tb3AgaW4geWFtX2lvY3RsKCkKcnVubmluZyAvYy9r
ZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9ob21lL3dmZy9uZXQv
b2JqLWJpc2VjdApscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0veDg2XzY0LWxr
cC1DT05GSUdfU0NTSV9ERUJVRy9saW51eC1kZXZlbDpkZXZlbC1pbm4teDg2XzY0LTIwMTMx
MDE5MDYzNDozOWJiOTNmODhjNWRiNTRjYmUxZGYwYjBhYTk1N2IzYThmMjIyN2VkOmJpc2Vj
dC1uZXQKCjIwMTMtMTAtMjAtMDI6NDQ6NTYgMzliYjkzZjg4YzVkYjU0Y2JlMWRmMGIwYWE5
NTdiM2E4ZjIyMjdlZCBjb21waWxpbmcKMTgzIHJlYWwgIDQ0IHVzZXIgIDkgc3lzICAyOS40
OSUgY3B1IAl4ODZfNjQtbGtwLUNPTkZJR19TQ1NJX0RFQlVHCgoyMDEzLTEwLTIwLTAyOjQ4
OjUwIGRldGVjdGluZyBib290IHN0YXRlIDMuMTIuMC1yYzMtMDAzMDctZzM5YmI5M2YuLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4JMjAgU1VDQ0VTUwoK
QmlzZWN0aW5nOiAwIHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hs
eSAxIHN0ZXApClszNWVkMTU5YmZkOTZhNzU0N2VjMjc3ZWQ4YjU1MGM3Y2JkOTg0MWI2XSB2
aXJ0aW8tbmV0OiByZWZpbGwgb25seSB3aGVuIGRldmljZSBpcyB1cCBkdXJpbmcgc2V0dGlu
ZyBxdWV1ZXMKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWls
dXJlLnNoIC9ob21lL3dmZy9uZXQvb2JqLWJpc2VjdApscyAtYSAva2VybmVsLXRlc3RzL3J1
bi1xdWV1ZS9rdm0veDg2XzY0LWxrcC1DT05GSUdfU0NTSV9ERUJVRy9saW51eC1kZXZlbDpk
ZXZlbC1pbm4teDg2XzY0LTIwMTMxMDE5MDYzNDozNWVkMTU5YmZkOTZhNzU0N2VjMjc3ZWQ4
YjU1MGM3Y2JkOTg0MWI2OmJpc2VjdC1uZXQKCjIwMTMtMTAtMjAtMDM6MTE6NTMgMzVlZDE1
OWJmZDk2YTc1NDdlYzI3N2VkOGI1NTBjN2NiZDk4NDFiNiBjb21waWxpbmcKMzEgcmVhbCAg
NDcgdXNlciAgMTAgc3lzICAxODQuODUlIGNwdSAJeDg2XzY0LWxrcC1DT05GSUdfU0NTSV9E
RUJVRwoKMjAxMy0xMC0yMC0wMzoxMjozNiBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAzLjEyLjAt
cmMzLTAwMzA5LWczNWVkMTU5Li4uLi4uLi4uLi4uLi4uLi4uLi4gVEVTVCBGQUlMVVJFClsg
IDQ4MC4xNDQxMjldIENQVTAgYXR0YWNoaW5nIE5VTEwgc2NoZWQtZG9tYWluLgpbICA0ODAu
MTQ0MTMzXSBDUFUxIGF0dGFjaGluZyBOVUxMIHNjaGVkLWRvbWFpbi4KWyAgNDgwLjE0NDE2
MF0gQ1BVMCBhdHRhY2hpbmcgTlVMTCBzY2hlZC1kb21haW4uClsgIDQ4MC4xNTA4OThdIEJV
Rzogc2xlZXBpbmcgZnVuY3Rpb24gY2FsbGVkIGZyb20gaW52YWxpZCBjb250ZXh0IGF0IGtl
cm5lbC9tdXRleC5jOjYxNgpbICA0ODAuMTUwODk5XSBpbl9hdG9taWMoKTogMSwgaXJxc19k
aXNhYmxlZCgpOiAxLCBwaWQ6IDEwLCBuYW1lOiBtaWdyYXRpb24vMQpbICA0ODAuMTUwODk5
XSBubyBsb2NrcyBoZWxkIGJ5IG1pZ3JhdGlvbi8xLzEwLgpbICA0ODAuMTUwOTAxXSBDUFU6
IDEgUElEOiAxMCBDb21tOiBtaWdyYXRpb24vMSBOb3QgdGFpbnRlZCAzLjEyLjAtcmMzLTAw
MzA5LWczNWVkMTU5ICM0NzAKWyAgNDgwLjE1MDkwMl0gSGFyZHdhcmUgbmFtZTogQm9jaHMg
Qm9jaHMsIEJJT1MgQm9jaHMgMDEvMDEvMjAxMQpbICA0ODAuMTUwOTA0XSAgMDAwMDAwMDAw
MDAwMDAwMCBmZmZmODgwMDBlMmQzYmEwIGZmZmZmZmZmODFhMmZlMTUgZmZmZjg4MDAwYzFm
YmM3MApbICA0ODAuMTUwOTA1XSAgZmZmZjg4MDAwZTJkM2JiMCBmZmZmZmZmZjgxMGVkYjAy
IGZmZmY4ODAwMGUyZDNjMzggZmZmZmZmZmY4MWEzNjVkZApbICA0ODAuMTUwOTA2XSAgMDAw
MDAwMDAwMDAwMDA0NiBmZmZmODgwMDBlMmQzYmU4IGZmZmZmZmZmODEwZTg2MWQgMDAwMDAw
MDAwMDAwMDAwMApbICA0ODAuMTUwOTA2XSBDYWxsIFRyYWNlOgpbICA0ODAuMTUwOTEyXSAg
WzxmZmZmZmZmZjgxYTJmZTE1Pl0gZHVtcF9zdGFjaysweDU0LzB4NzQKWyAgNDgwLjE1MDkx
Nl0gIFs8ZmZmZmZmZmY4MTBlZGIwMj5dIF9fbWlnaHRfc2xlZXArMHgxMTIvMHgxMTQKWyAg
NDgwLjE1MDkxN10gIFs8ZmZmZmZmZmY4MWEzNjVkZD5dIG11dGV4X2xvY2tfbmVzdGVkKzB4
M2MvMHgzYzYKWyAgNDgwLjE1MDkxOV0gIFs8ZmZmZmZmZmY4MTBlODYxZD5dID8gdXArMHgz
OS8weDNlClsgIDQ4MC4xNTA5MjFdICBbPGZmZmZmZmZmODE1M2VkZDk+XSA/IGFjcGlfb3Nf
c2lnbmFsX3NlbWFwaG9yZSsweDIxLzB4MmQKWyAgNDgwLjE1MDkyNF0gIFs8ZmZmZmZmZmY4
MTU2NjMxYT5dID8gYWNwaV91dF9yZWxlYXNlX211dGV4KzB4NWUvMHg2MgpbICA0ODAuMTUw
OTI3XSAgWzxmZmZmZmZmZjgxNmNjYTExPl0gdmlydG5ldF9jcHVfY2FsbGJhY2srMHgzMy8w
eDg3ClsgIDQ4MC4xNTA5MjldICBbPGZmZmZmZmZmODFhM2Y0NzY+XSBub3RpZmllcl9jYWxs
X2NoYWluKzB4M2MvMHg1ZQpbICA0ODAuMTUwOTMwXSAgWzxmZmZmZmZmZjgxMGU4NmE4Pl0g
X19yYXdfbm90aWZpZXJfY2FsbF9jaGFpbisweGUvMHgxMApbICA0ODAuMTUwOTMyXSAgWzxm
ZmZmZmZmZjgxMGM1NTU2Pl0gX19jcHVfbm90aWZ5KzB4MjAvMHgzNwpbICA0ODAuMTUwOTMz
XSAgWzxmZmZmZmZmZjgxMGM1NTgwPl0gY3B1X25vdGlmeSsweDEzLzB4MTUKWyAgNDgwLjE1
MDkzNl0gIFs8ZmZmZmZmZmY4MWEyMDY3OT5dIHRha2VfY3B1X2Rvd24rMHgyNy8weDNhClsg
IDQ4MC4xNTA5MzhdICBbPGZmZmZmZmZmODExMzYyNmQ+XSBzdG9wX21hY2hpbmVfY3B1X3N0
b3ArMHg5My8weGYxClsgIDQ4MC4xNTA5MzldICBbPGZmZmZmZmZmODExMzYxNGI+XSBjcHVf
c3RvcHBlcl90aHJlYWQrMHhhMC8weDEyZgpbICA0ODAuMTUwOTQwXSAgWzxmZmZmZmZmZjgx
MTM2MWRhPl0gPyBjcHVfc3RvcHBlcl90aHJlYWQrMHgxMmYvMHgxMmYKWyAgNDgwLjE1MDk0
M10gIFs8ZmZmZmZmZmY4MTExOTZlYj5dID8gbG9ja19yZWxlYXNlX2hvbGR0aW1lLnBhcnQu
NysweGEzLzB4YTgKWyAgNDgwLjE1MDk0NF0gIFs8ZmZmZmZmZmY4MTEzNWUyZj5dID8gY3B1
X3N0b3Bfc2hvdWxkX3J1bisweDNmLzB4NDcKWyAgNDgwLjE1MDk0Nl0gIFs8ZmZmZmZmZmY4
MTBlYTliMD5dIHNtcGJvb3RfdGhyZWFkX2ZuKzB4MWM1LzB4MWUzClsgIDQ4MC4xNTA5NDdd
ICBbPGZmZmZmZmZmODEwZWE3ZWI+XSA/IGxnX2dsb2JhbF91bmxvY2srMHg2Ny8weDY3Clsg
IDQ4MC4xNTA5NDldICBbPGZmZmZmZmZmODEwZTM2Yjc+XSBrdGhyZWFkKzB4ZDgvMHhlMApb
ICA0ODAuMTUwOTUxXSAgWzxmZmZmZmZmZjgxYTM4ZTlkPl0gPyB3YWl0X2Zvcl9jb21tb24r
MHgxMmYvMHgxNjQKWyAgNDgwLjE1MDk1Ml0gIFs8ZmZmZmZmZmY4MTBlMzVkZj5dID8ga3Ro
cmVhZF9jcmVhdGVfb25fbm9kZSsweDEyNC8weDEyNApbICA0ODAuMTUwOTU0XSAgWzxmZmZm
ZmZmZjgxYTQyZWZjPl0gcmV0X2Zyb21fZm9yaysweDdjLzB4YjAKWyAgNDgwLjE1MDk1NV0g
IFs8ZmZmZmZmZmY4MTBlMzVkZj5dID8ga3RocmVhZF9jcmVhdGVfb25fbm9kZSsweDEyNC8w
eDEyNApbICA0ODAuMTUwOTY5XSBzbXBib290OiBDUFUgMSBpcyBub3cgb2ZmbGluZQpbICA0
ODAuMzUwNTQ3XSBTTVAgYWx0ZXJuYXRpdmVzOiBsb2NrZGVwOiBmaXhpbmcgdXAgYWx0ZXJu
YXRpdmVzClsgIDQ4MC4zNTA1NTBdIHNtcGJvb3Q6IEJvb3RpbmcgTm9kZSAwIFByb2Nlc3Nv
ciAxIEFQSUMgMHgxCi9rZXJuZWwveDg2XzY0LWxrcC1DT05GSUdfU0NTSV9ERUJVRy8zNWVk
MTU5YmZkOTZhNzU0N2VjMjc3ZWQ4YjU1MGM3Y2JkOTg0MWI2L2RtZXNnLXF1YW50YWwtd2Fp
bWVhLTc6MjAxMzEwMjAxMTE5NTg6eDg2XzY0LWxrcC1DT05GSUdfU0NTSV9ERUJVRzozLjEy
LjAtcmMzLTAwMzA5LWczNWVkMTU5OjQ3MAowOjE6MSBhbGxfZ29vZDpiYWQ6YWxsX2JhZCBi
b290cwobWzE7MzVtUkVQRUFUIENPVU5UOiAyMCAgIyAvY2Mvd2ZnL25ldC1iaXNlY3QvLnJl
cGVhdBtbMG0KCkJpc2VjdGluZzogMCByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRo
aXMgKHJvdWdobHkgMCBzdGVwcykKWzNhYjA5OGRmMzVmOGI5OGI2NTUzZWRjMmU0MDIzNGFm
NTEyYmE4NzddIHZpcnRpby1uZXQ6IGRvbid0IHJlc3BvbmQgdG8gY3B1IGhvdHBsdWcgbm90
aWZpZXIgaWYgd2UncmUgbm90IHJlYWR5CnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2Vj
dC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvaG9tZS93ZmcvbmV0L29iai1iaXNlY3QKbHMgLWEg
L2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1sa3AtQ09ORklHX1NDU0lfREVC
VUcvbGludXgtZGV2ZWw6ZGV2ZWwtaW5uLXg4Nl82NC0yMDEzMTAxOTA2MzQ6M2FiMDk4ZGYz
NWY4Yjk4YjY1NTNlZGMyZTQwMjM0YWY1MTJiYTg3NzpiaXNlY3QtbmV0CgoyMDEzLTEwLTIw
LTAzOjIyOjM5IDNhYjA5OGRmMzVmOGI5OGI2NTUzZWRjMmU0MDIzNGFmNTEyYmE4NzcgY29t
cGlsaW5nCjMwIHJlYWwgIDQ2IHVzZXIgIDEwIHN5cyAgMTkwLjc5JSBjcHUgCXg4Nl82NC1s
a3AtQ09ORklHX1NDU0lfREVCVUcKCjIwMTMtMTAtMjAtMDM6MjM6MjMgZGV0ZWN0aW5nIGJv
b3Qgc3RhdGUgMy4xMi4wLXJjMy0wMDMwOC1nM2FiMDk4ZC4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uIFRFU1QgRkFJTFVSRQpbICA3ODcuOTY4NTAwXSBDUFUwIGF0dGFjaGlu
ZyBOVUxMIHNjaGVkLWRvbWFpbi4KWyAgNzg3Ljk2ODUwNl0gQ1BVMSBhdHRhY2hpbmcgTlVM
TCBzY2hlZC1kb21haW4uClsgIDc4Ny45Njg1NDldIENQVTAgYXR0YWNoaW5nIE5VTEwgc2No
ZWQtZG9tYWluLgpbICA3ODcuOTc1MDU0XSBCVUc6IHNsZWVwaW5nIGZ1bmN0aW9uIGNhbGxl
ZCBmcm9tIGludmFsaWQgY29udGV4dCBhdCBrZXJuZWwvbXV0ZXguYzo2MTYKWyAgNzg3Ljk3
NTA1Nl0gaW5fYXRvbWljKCk6IDEsIGlycXNfZGlzYWJsZWQoKTogMSwgcGlkOiAxMCwgbmFt
ZTogbWlncmF0aW9uLzEKWyAgNzg3Ljk3NTA1N10gbm8gbG9ja3MgaGVsZCBieSBtaWdyYXRp
b24vMS8xMC4KWyAgNzg3Ljk3NTA1OV0gQ1BVOiAxIFBJRDogMTAgQ29tbTogbWlncmF0aW9u
LzEgTm90IHRhaW50ZWQgMy4xMi4wLXJjMy0wMDMwOC1nM2FiMDk4ZCAjNDcxClsgIDc4Ny45
NzUwNTldIEhhcmR3YXJlIG5hbWU6IEJvY2hzIEJvY2hzLCBCSU9TIEJvY2hzIDAxLzAxLzIw
MTEKWyAgNzg3Ljk3NTA2Ml0gIDAwMDAwMDAwMDAwMDAwMDAgZmZmZjg4MDAxZDQyZGJhMCBm
ZmZmZmZmZjgxYTJmZTA1IGZmZmY4ODAwMWJlZTFjNzAKWyAgNzg3Ljk3NTA2M10gIGZmZmY4
ODAwMWQ0MmRiYjAgZmZmZmZmZmY4MTBlZGIwMiBmZmZmODgwMDFkNDJkYzM4IGZmZmZmZmZm
ODFhMzY1Y2QKWyAgNzg3Ljk3NTA2NV0gIDAwMDAwMDAwMDAwMDAwNDYgZmZmZjg4MDAxZDQy
ZGJlOCBmZmZmZmZmZjgxMGU4NjFkIDAwMDAwMDAwMDAwMDAwMDAKWyAgNzg3Ljk3NTA2NV0g
Q2FsbCBUcmFjZToKWyAgNzg3Ljk3NTA3M10gIFs8ZmZmZmZmZmY4MWEyZmUwNT5dIGR1bXBf
c3RhY2srMHg1NC8weDc0ClsgIDc4Ny45NzUwNzhdICBbPGZmZmZmZmZmODEwZWRiMDI+XSBf
X21pZ2h0X3NsZWVwKzB4MTEyLzB4MTE0ClsgIDc4Ny45NzUwODJdICBbPGZmZmZmZmZmODFh
MzY1Y2Q+XSBtdXRleF9sb2NrX25lc3RlZCsweDNjLzB4M2M2ClsgIDc4Ny45NzUwODRdICBb
PGZmZmZmZmZmODEwZTg2MWQ+XSA/IHVwKzB4MzkvMHgzZQpbICA3ODcuOTc1MDg4XSAgWzxm
ZmZmZmZmZjgxNTNlZGQ5Pl0gPyBhY3BpX29zX3NpZ25hbF9zZW1hcGhvcmUrMHgyMS8weDJk
ClsgIDc4Ny45NzUwOTJdICBbPGZmZmZmZmZmODE1NjYzMWE+XSA/IGFjcGlfdXRfcmVsZWFz
ZV9tdXRleCsweDVlLzB4NjIKWyAgNzg3Ljk3NTA5Nl0gIFs8ZmZmZmZmZmY4MTZjY2ExMT5d
IHZpcnRuZXRfY3B1X2NhbGxiYWNrKzB4MzMvMHg4NwpbICA3ODcuOTc1MDk5XSAgWzxmZmZm
ZmZmZjgxYTNmNDc2Pl0gbm90aWZpZXJfY2FsbF9jaGFpbisweDNjLzB4NWUKWyAgNzg3Ljk3
NTEwMV0gIFs8ZmZmZmZmZmY4MTBlODZhOD5dIF9fcmF3X25vdGlmaWVyX2NhbGxfY2hhaW4r
MHhlLzB4MTAKWyAgNzg3Ljk3NTEwNF0gIFs8ZmZmZmZmZmY4MTBjNTU1Nj5dIF9fY3B1X25v
dGlmeSsweDIwLzB4MzcKWyAgNzg3Ljk3NTEwNl0gIFs8ZmZmZmZmZmY4MTBjNTU4MD5dIGNw
dV9ub3RpZnkrMHgxMy8weDE1ClsgIDc4Ny45NzUxMDldICBbPGZmZmZmZmZmODFhMjA2Njk+
XSB0YWtlX2NwdV9kb3duKzB4MjcvMHgzYQpbICA3ODcuOTc1MTEyXSAgWzxmZmZmZmZmZjgx
MTM2MjZkPl0gc3RvcF9tYWNoaW5lX2NwdV9zdG9wKzB4OTMvMHhmMQpbICA3ODcuOTc1MTE0
XSAgWzxmZmZmZmZmZjgxMTM2MTRiPl0gY3B1X3N0b3BwZXJfdGhyZWFkKzB4YTAvMHgxMmYK
WyAgNzg3Ljk3NTExNV0gIFs8ZmZmZmZmZmY4MTEzNjFkYT5dID8gY3B1X3N0b3BwZXJfdGhy
ZWFkKzB4MTJmLzB4MTJmClsgIDc4Ny45NzUxMTldICBbPGZmZmZmZmZmODExMTk2ZWI+XSA/
IGxvY2tfcmVsZWFzZV9ob2xkdGltZS5wYXJ0LjcrMHhhMy8weGE4ClsgIDc4Ny45NzUxMjFd
ICBbPGZmZmZmZmZmODExMzVlMmY+XSA/IGNwdV9zdG9wX3Nob3VsZF9ydW4rMHgzZi8weDQ3
ClsgIDc4Ny45NzUxMjNdICBbPGZmZmZmZmZmODEwZWE5YjA+XSBzbXBib290X3RocmVhZF9m
bisweDFjNS8weDFlMwpbICA3ODcuOTc1MTI1XSAgWzxmZmZmZmZmZjgxMGVhN2ViPl0gPyBs
Z19nbG9iYWxfdW5sb2NrKzB4NjcvMHg2NwpbICA3ODcuOTc1MTI4XSAgWzxmZmZmZmZmZjgx
MGUzNmI3Pl0ga3RocmVhZCsweGQ4LzB4ZTAKWyAgNzg3Ljk3NTEzMV0gIFs8ZmZmZmZmZmY4
MWEzOGU4ZD5dID8gd2FpdF9mb3JfY29tbW9uKzB4MTJmLzB4MTY0ClsgIDc4Ny45NzUxMzNd
ICBbPGZmZmZmZmZmODEwZTM1ZGY+XSA/IGt0aHJlYWRfY3JlYXRlX29uX25vZGUrMHgxMjQv
MHgxMjQKWyAgNzg3Ljk3NTEzNV0gIFs8ZmZmZmZmZmY4MWE0MmVmYz5dIHJldF9mcm9tX2Zv
cmsrMHg3Yy8weGIwClsgIDc4Ny45NzUxMzddICBbPGZmZmZmZmZmODEwZTM1ZGY+XSA/IGt0
aHJlYWRfY3JlYXRlX29uX25vZGUrMHgxMjQvMHgxMjQKWyAgNzg3Ljk3NTE1NF0gc21wYm9v
dDogQ1BVIDEgaXMgbm93IG9mZmxpbmUKWyAgNzg4LjE0ODA4Ml0gU01QIGFsdGVybmF0aXZl
czogbG9ja2RlcDogZml4aW5nIHVwIGFsdGVybmF0aXZlcwpbICA3ODguMTQ4MDg1XSBzbXBi
b290OiBCb290aW5nIE5vZGUgMCBQcm9jZXNzb3IgMSBBUElDIDB4MQova2VybmVsL3g4Nl82
NC1sa3AtQ09ORklHX1NDU0lfREVCVUcvM2FiMDk4ZGYzNWY4Yjk4YjY1NTNlZGMyZTQwMjM0
YWY1MTJiYTg3Ny9kbWVzZy1uZnNyb290LWlubi0yMjoyMDEzMTAyMDAzMzYzOTp4ODZfNjQt
bGtwLUNPTkZJR19TQ1NJX0RFQlVHOjMuMTIuMC1yYzMtMDAzMDgtZzNhYjA5OGQ6NDcxCi9r
ZXJuZWwveDg2XzY0LWxrcC1DT05GSUdfU0NTSV9ERUJVRy8zYWIwOThkZjM1ZjhiOThiNjU1
M2VkYzJlNDAyMzRhZjUxMmJhODc3L2RtZXNnLW5mc3Jvb3Qtcm9hbS0xMDoyMDEzMTAyMDAz
Mzg0Mjp4ODZfNjQtbGtwLUNPTkZJR19TQ1NJX0RFQlVHOjMuMTIuMC1yYzMtMDAzMDgtZzNh
YjA5OGQ6NDcxCi9rZXJuZWwveDg2XzY0LWxrcC1DT05GSUdfU0NTSV9ERUJVRy8zYWIwOThk
ZjM1ZjhiOThiNjU1M2VkYzJlNDAyMzRhZjUxMmJhODc3L2RtZXNnLW5mc3Jvb3Qtcm9hbS0x
NzoyMDEzMTAyMDAzMzgzNzp4ODZfNjQtbGtwLUNPTkZJR19TQ1NJX0RFQlVHOjMuMTIuMC1y
YzMtMDAzMDgtZzNhYjA5OGQ6NDcxCi9rZXJuZWwveDg2XzY0LWxrcC1DT05GSUdfU0NTSV9E
RUJVRy8zYWIwOThkZjM1ZjhiOThiNjU1M2VkYzJlNDAyMzRhZjUxMmJhODc3L2RtZXNnLXF1
YW50YWwtaW5uLTk6MjAxMzEwMjAwMzM2MDg6eDg2XzY0LWxrcC1DT05GSUdfU0NTSV9ERUJV
RzozLjEyLjAtcmMzLTAwMzA4LWczYWIwOThkOjQ3MQova2VybmVsL3g4Nl82NC1sa3AtQ09O
RklHX1NDU0lfREVCVUcvM2FiMDk4ZGYzNWY4Yjk4YjY1NTNlZGMyZTQwMjM0YWY1MTJiYTg3
Ny9kbWVzZy15b2N0by1jYWlyby0zOToyMDEzMTAyMDAzMzYxNTp4ODZfNjQtbGtwLUNPTkZJ
R19TQ1NJX0RFQlVHOjMuMTIuMC1yYzMtMDAzMDgtZzNhYjA5OGQ6NDcxCi9rZXJuZWwveDg2
XzY0LWxrcC1DT05GSUdfU0NTSV9ERUJVRy8zYWIwOThkZjM1ZjhiOThiNjU1M2VkYzJlNDAy
MzRhZjUxMmJhODc3L2RtZXNnLXlvY3RvLWNhaXJvLTQwOjIwMTMxMDIwMDMzNjQwOng4Nl82
NC1sa3AtQ09ORklHX1NDU0lfREVCVUc6My4xMi4wLXJjMy0wMDMwOC1nM2FiMDk4ZDo0NzEK
L2tlcm5lbC94ODZfNjQtbGtwLUNPTkZJR19TQ1NJX0RFQlVHLzNhYjA5OGRmMzVmOGI5OGI2
NTUzZWRjMmU0MDIzNGFmNTEyYmE4NzcvZG1lc2cteW9jdG8taW5uLTI5OjIwMTMxMDIwMDMz
NjA1Ong4Nl82NC1sa3AtQ09ORklHX1NDU0lfREVCVUc6My4xMi4wLXJjMy0wMDMwOC1nM2Fi
MDk4ZDo0NzEKL2tlcm5lbC94ODZfNjQtbGtwLUNPTkZJR19TQ1NJX0RFQlVHLzNhYjA5OGRm
MzVmOGI5OGI2NTUzZWRjMmU0MDIzNGFmNTEyYmE4NzcvZG1lc2cteW9jdG8taW5uLTg6MjAx
MzEwMjAwMzM2MjA6eDg2XzY0LWxrcC1DT05GSUdfU0NTSV9ERUJVRzozLjEyLjAtcmMzLTAw
MzA4LWczYWIwOThkOjQ3MQova2VybmVsL3g4Nl82NC1sa3AtQ09ORklHX1NDU0lfREVCVUcv
M2FiMDk4ZGYzNWY4Yjk4YjY1NTNlZGMyZTQwMjM0YWY1MTJiYTg3Ny9kbWVzZy15b2N0by1y
b2FtLTIwOjIwMTMxMDIwMDMzNjUwOng4Nl82NC1sa3AtQ09ORklHX1NDU0lfREVCVUc6My4x
Mi4wLXJjMy0wMDMwOC1nM2FiMDk4ZDo0NzEKL2tlcm5lbC94ODZfNjQtbGtwLUNPTkZJR19T
Q1NJX0RFQlVHLzNhYjA5OGRmMzVmOGI5OGI2NTUzZWRjMmU0MDIzNGFmNTEyYmE4NzcvZG1l
c2cteW9jdG8tc25iLTE1OjIwMTMxMDIwMDMzNjM5Ong4Nl82NC1sa3AtQ09ORklHX1NDU0lf
REVCVUc6My4xMi4wLXJjMy0wMDMwOC1nM2FiMDk4ZDo0NzEKMDoxMDo5IGFsbF9nb29kOmJh
ZDphbGxfYmFkIGJvb3RzCgozYWIwOThkZjM1ZjhiOThiNjU1M2VkYzJlNDAyMzRhZjUxMmJh
ODc3IGlzIHRoZSBmaXJzdCBiYWQgY29tbWl0CmNvbW1pdCAzYWIwOThkZjM1ZjhiOThiNjU1
M2VkYzJlNDAyMzRhZjUxMmJhODc3CkF1dGhvcjogSmFzb24gV2FuZyA8amFzb3dhbmdAcmVk
aGF0LmNvbT4KRGF0ZTogICBUdWUgT2N0IDE1IDExOjE4OjU4IDIwMTMgKzA4MDAKCiAgICB2
aXJ0aW8tbmV0OiBkb24ndCByZXNwb25kIHRvIGNwdSBob3RwbHVnIG5vdGlmaWVyIGlmIHdl
J3JlIG5vdCByZWFkeQogICAgCiAgICBXZSdyZSB0cnlpbmcgdG8gcmUtY29uZmlndXJlIHRo
ZSBhZmZpbml0eSB1bmNvbmRpdGlvbmFsbHkgaW4gY3B1IGhvdHBsdWcKICAgIGNhbGxiYWNr
LiBUaGlzIG1heSBsZWFkIHRoZSBpc3N1ZSBkdXJpbmcgcmVzdW1pbmcgZnJvbSBzMy9zNCBz
aW5jZQogICAgCiAgICAtIHZpcnQgcXVldWVzIGhhdmVuJ3QgYmVlbiBhbGxvY2F0ZWQgYXQg
dGhhdCB0aW1lLgogICAgLSBpdCdzIHVubmVjZXNzYXJ5IHNpbmNlIHRoYXcgbWV0aG9kIHdp
bGwgcmUtY29uZmlndXJlIHRoZSBhZmZpbml0eS4KICAgIAogICAgRml4IHRoaXMgaXNzdWUg
YnkgY2hlY2tpbmcgdGhlIGNvbmZpZ19lbmFibGUgYW5kIGRvIG5vdGhpbmcgaXMgd2UncmUg
bm90IHJlYWR5LgogICAgCiAgICBUaGUgYnVnIHdlcmUgaW50cm9kdWNlZCBieSBjb21taXQg
OGRlNGIyZjNhZTkwYzhmYzBmMTdlZWFhYjg3ZDVhOTUxYjY2ZWUxNwogICAgKHZpcnRpby1u
ZXQ6IHJlc2V0IHZpcnRxdWV1ZSBhZmZpbml0eSB3aGVuIGRvaW5nIGNwdSBob3RwbHVnKS4K
ICAgIAogICAgQ2M6IFJ1c3R5IFJ1c3NlbGwgPHJ1c3R5QHJ1c3Rjb3JwLmNvbS5hdT4KICAg
IENjOiBNaWNoYWVsIFMuIFRzaXJraW4gPG1zdEByZWRoYXQuY29tPgogICAgQ2M6IFdhbmxv
bmcgR2FvIDxnYW93YW5sb25nQGNuLmZ1aml0c3UuY29tPgogICAgQWNrZWQtYnk6IE1pY2hh
ZWwgUy4gVHNpcmtpbiA8bXN0QHJlZGhhdC5jb20+CiAgICBSZXZpZXdlZC1ieTogV2FubG9u
ZyBHYW8gPGdhb3dhbmxvbmdAY24uZnVqaXRzdS5jb20+CiAgICBTaWduZWQtb2ZmLWJ5OiBK
YXNvbiBXYW5nIDxqYXNvd2FuZ0ByZWRoYXQuY29tPgogICAgU2lnbmVkLW9mZi1ieTogRGF2
aWQgUy4gTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0PgoKOjA0MDAwMCAwNDAwMDAgODEw
ZDNiMTg3NGE4ODM4Y2YzNjcxYTdjZmQ1MzFjMGU5OWNjMGZkZiAyMDEyOWQwN2E3OGE3ZWQy
Y2NkNjcwZWFkNDJiYTQxZTU4ZGU4ZmQ3IE0JZHJpdmVycwpiaXNlY3QgcnVuIHN1Y2Nlc3MK
bHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1sa3AtQ09ORklHX1ND
U0lfREVCVUcvbGludXgtZGV2ZWw6ZGV2ZWwtaW5uLXg4Nl82NC0yMDEzMTAxOTA2MzQ6Mzli
YjkzZjg4YzVkYjU0Y2JlMWRmMGIwYWE5NTdiM2E4ZjIyMjdlZDpiaXNlY3QtbmV0CgoyMDEz
LTEwLTIwLTAzOjM5OjI4IDM5YmI5M2Y4OGM1ZGI1NGNiZTFkZjBiMGFhOTU3YjNhOGYyMjI3
ZWQgcmV1c2UgL2tlcm5lbC94ODZfNjQtbGtwLUNPTkZJR19TQ1NJX0RFQlVHLzM5YmI5M2Y4
OGM1ZGI1NGNiZTFkZjBiMGFhOTU3YjNhOGYyMjI3ZWQvdm1saW51ei0zLjEyLjAtcmMzLTAw
MzA3LWczOWJiOTNmCgoyMDEzLTEwLTIwLTAzOjM5OjI4IGRldGVjdGluZyBib290IHN0YXRl
IC4uLi4uLgkxLgkyLi4uLi4uLi4uLgkzLgk0Li4uLi4uLi4uCTUuLi4JNgk3CTExCTE1CTIw
CTIxCTIzCTI3CTMxCTM1CTQxCTQyCTQzCTQ4CTQ5Li4uLi4uLgk1MC4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLgk1Mgk1My4uCTU1Lgk1Ni4uLgk1
Ny4uLi4uLi4uLi4uLi4uLgk1OC4uLi4uCTU5Li4uLi4uLgk2MCBTVUNDRVNTCgpscyAtYSAv
a2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0veDg2XzY0LWxrcC1DT05GSUdfU0NTSV9ERUJV
Ry9saW51eC1kZXZlbDpkZXZlbC1pbm4teDg2XzY0LTIwMTMxMDE5MDYzNDpiOTFlODJkYzZh
ZDU1ZjJkMzliOTJlNzMxYzZiYjk1Y2M0NGE5MjNjOmJpc2VjdC1uZXQKIFRFU1QgRkFJTFVS
RQpbICA2NTEuMzY1MTAyXSBDUFUwIGF0dGFjaGluZyBOVUxMIHNjaGVkLWRvbWFpbi4KWyAg
NjUxLjM2NTExMV0gQ1BVMSBhdHRhY2hpbmcgTlVMTCBzY2hlZC1kb21haW4uClsgIDY1MS4z
NjUxNjddIENQVTAgYXR0YWNoaW5nIE5VTEwgc2NoZWQtZG9tYWluLgpbICA2NTEuMzc1MTA4
XSBCVUc6IHNsZWVwaW5nIGZ1bmN0aW9uIGNhbGxlZCBmcm9tIGludmFsaWQgY29udGV4dCBh
dCBrZXJuZWwvbXV0ZXguYzo2MTYKWyAgNjUxLjM3NTExMF0gaW5fYXRvbWljKCk6IDEsIGly
cXNfZGlzYWJsZWQoKTogMSwgcGlkOiAxMCwgbmFtZTogbWlncmF0aW9uLzEKWyAgNjUxLjM3
NTExMl0gbm8gbG9ja3MgaGVsZCBieSBtaWdyYXRpb24vMS8xMC4KWyAgNjUxLjM3NTExNV0g
Q1BVOiAxIFBJRDogMTAgQ29tbTogbWlncmF0aW9uLzEgTm90IHRhaW50ZWQgMy4xMi4wLXJj
NS13bC0wMTI0OS1nYjkxZTgyZCAjMzE3ClsgIDY1MS4zNzUxMTZdIEhhcmR3YXJlIG5hbWU6
IEJvY2hzIEJvY2hzLCBCSU9TIEJvY2hzIDAxLzAxLzIwMTEKWyAgNjUxLjM3NTEyMF0gIDAw
MDAwMDAwMDAwMDAwMDAgZmZmZjg4MDAxZDQyZGJhMCBmZmZmZmZmZjgxYTMyZjIyIGZmZmY4
ODAwMWJlNTBjNzAKWyAgNjUxLjM3NTEyM10gIGZmZmY4ODAwMWQ0MmRiYjAgZmZmZmZmZmY4
MTBlZGIwMiBmZmZmODgwMDFkNDJkYzM4IGZmZmZmZmZmODFhMzk2ZWQKWyAgNjUxLjM3NTEy
Nl0gIDAwMDAwMDAwMDAwMDAwNDYgZmZmZjg4MDAxZDQyZGJlOCBmZmZmZmZmZjgxMGU4NjFk
IDAwMDAwMDAwMDAwMDAwMDAKWyAgNjUxLjM3NTEyNl0gQ2FsbCBUcmFjZToKWyAgNjUxLjM3
NTEzNV0gIFs8ZmZmZmZmZmY4MWEzMmYyMj5dIGR1bXBfc3RhY2srMHg1NC8weDc0ClsgIDY1
MS4zNzUxNDBdICBbPGZmZmZmZmZmODEwZWRiMDI+XSBfX21pZ2h0X3NsZWVwKzB4MTEyLzB4
MTE0ClsgIDY1MS4zNzUxNDRdICBbPGZmZmZmZmZmODFhMzk2ZWQ+XSBtdXRleF9sb2NrX25l
c3RlZCsweDNjLzB4M2M2ClsgIDY1MS4zNzUxNDddICBbPGZmZmZmZmZmODEwZTg2MWQ+XSA/
IHVwKzB4MzkvMHgzZQpbICA2NTEuMzc1MTUyXSAgWzxmZmZmZmZmZjgxNTNlYTdjPl0gPyBh
Y3BpX29zX3NpZ25hbF9zZW1hcGhvcmUrMHgyMS8weDJkClsgIDY1MS4zNzUxNTZdICBbPGZm
ZmZmZmZmODE1NjVlZDE+XSA/IGFjcGlfdXRfcmVsZWFzZV9tdXRleCsweDVlLzB4NjIKWyAg
NjUxLjM3NTE2MV0gIFs8ZmZmZmZmZmY4MTZkMDRlYz5dIHZpcnRuZXRfY3B1X2NhbGxiYWNr
KzB4MzMvMHg4NwpbICA2NTEuMzc1MTY1XSAgWzxmZmZmZmZmZjgxYTQyNTc2Pl0gbm90aWZp
ZXJfY2FsbF9jaGFpbisweDNjLzB4NWUKWyAgNjUxLjM3NTE2OF0gIFs8ZmZmZmZmZmY4MTBl
ODZhOD5dIF9fcmF3X25vdGlmaWVyX2NhbGxfY2hhaW4rMHhlLzB4MTAKWyAgNjUxLjM3NTE3
Ml0gIFs8ZmZmZmZmZmY4MTBjNTU1Nj5dIF9fY3B1X25vdGlmeSsweDIwLzB4MzcKWyAgNjUx
LjM3NTE3NF0gIFs8ZmZmZmZmZmY4MTBjNTU4MD5dIGNwdV9ub3RpZnkrMHgxMy8weDE1Clsg
IDY1MS4zNzUxNzddICBbPGZmZmZmZmZmODFhMjM3Y2Q+XSB0YWtlX2NwdV9kb3duKzB4Mjcv
MHgzYQpbICA2NTEuMzc1MTgxXSAgWzxmZmZmZmZmZjgxMTM2Mjg5Pl0gc3RvcF9tYWNoaW5l
X2NwdV9zdG9wKzB4OTMvMHhmMQpbICA2NTEuMzc1MTg0XSAgWzxmZmZmZmZmZjgxMTM2MTY3
Pl0gY3B1X3N0b3BwZXJfdGhyZWFkKzB4YTAvMHgxMmYKWyAgNjUxLjM3NTE4Nl0gIFs8ZmZm
ZmZmZmY4MTEzNjFmNj5dID8gY3B1X3N0b3BwZXJfdGhyZWFkKzB4MTJmLzB4MTJmClsgIDY1
MS4zNzUxOTBdICBbPGZmZmZmZmZmODExMTk3MTA+XSA/IGxvY2tfcmVsZWFzZV9ob2xkdGlt
ZS5wYXJ0LjcrMHhhMy8weGE4ClsgIDY1MS4zNzUxOTNdICBbPGZmZmZmZmZmODExMzVlNGI+
XSA/IGNwdV9zdG9wX3Nob3VsZF9ydW4rMHgzZi8weDQ3ClsgIDY1MS4zNzUxOTZdICBbPGZm
ZmZmZmZmODEwZWE5YjA+XSBzbXBib290X3RocmVhZF9mbisweDFjNS8weDFlMwpbICA2NTEu
Mzc1MTk5XSAgWzxmZmZmZmZmZjgxMGVhN2ViPl0gPyBsZ19nbG9iYWxfdW5sb2NrKzB4Njcv
MHg2NwpbICA2NTEuMzc1MjAzXSAgWzxmZmZmZmZmZjgxMGUzNmI3Pl0ga3RocmVhZCsweGQ4
LzB4ZTAKWyAgNjUxLjM3NTIwNl0gIFs8ZmZmZmZmZmY4MWEzYmZhZD5dID8gd2FpdF9mb3Jf
Y29tbW9uKzB4MTJmLzB4MTY0ClsgIDY1MS4zNzUyMTBdICBbPGZmZmZmZmZmODEwZTM1ZGY+
XSA/IGt0aHJlYWRfY3JlYXRlX29uX25vZGUrMHgxMjQvMHgxMjQKWyAgNjUxLjM3NTIxM10g
IFs8ZmZmZmZmZmY4MWE0NWZmYz5dIHJldF9mcm9tX2ZvcmsrMHg3Yy8weGIwClsgIDY1MS4z
NzUyMTZdICBbPGZmZmZmZmZmODEwZTM1ZGY+XSA/IGt0aHJlYWRfY3JlYXRlX29uX25vZGUr
MHgxMjQvMHgxMjQKWyAgNjUxLjM3NTI2OF0gc21wYm9vdDogQ1BVIDEgaXMgbm93IG9mZmxp
bmUKWyAgNjUxLjU5NjY3OV0gU01QIGFsdGVybmF0aXZlczogbG9ja2RlcDogZml4aW5nIHVw
IGFsdGVybmF0aXZlcwpbICA2NTEuNTk2Njg0XSBzbXBib290OiBCb290aW5nIE5vZGUgMCBQ
cm9jZXNzb3IgMSBBUElDIDB4MQova2VybmVsL3g4Nl82NC1sa3AtQ09ORklHX1NDU0lfREVC
VUcvYjkxZTgyZGM2YWQ1NWYyZDM5YjkyZTczMWM2YmI5NWNjNDRhOTIzYy9kbWVzZy1uZnNy
b290LWxrcC10dDAyLTQ6MjAxMzEwMTkxMTM4MjA6eDg2XzY0LWxrcC1DT05GSUdfU0NTSV9E
RUJVRzozLjEyLjAtcmM1LXdsLTAxMjQ5LWdiOTFlODJkOjMxNwova2VybmVsL3g4Nl82NC1s
a3AtQ09ORklHX1NDU0lfREVCVUcvYjkxZTgyZGM2YWQ1NWYyZDM5YjkyZTczMWM2YmI5NWNj
NDRhOTIzYy9kbWVzZy1uZnNyb290LXdhaW1lYS02OjIwMTMxMDE5MTUxMDQxOng4Nl82NC1s
a3AtQ09ORklHX1NDU0lfREVCVUc6My4xMi4wLXJjNS13bC0wMTI0OS1nYjkxZTgyZDozMTcK
L2tlcm5lbC94ODZfNjQtbGtwLUNPTkZJR19TQ1NJX0RFQlVHL2I5MWU4MmRjNmFkNTVmMmQz
OWI5MmU3MzFjNmJiOTVjYzQ0YTkyM2MvZG1lc2ctbmZzcm9vdC14aWFuLTI5OjIwMTMxMDE5
MjA1NDM0Ong4Nl82NC1sa3AtQ09ORklHX1NDU0lfREVCVUc6My4xMi4wLXJjNS13bC0wMTI0
OS1nYjkxZTgyZDozMTcKL2tlcm5lbC94ODZfNjQtbGtwLUNPTkZJR19TQ1NJX0RFQlVHL2I5
MWU4MmRjNmFkNTVmMmQzOWI5MmU3MzFjNmJiOTVjYzQ0YTkyM2MvZG1lc2ctbmZzcm9vdC1j
YWlyby0yOjIwMTMxMDE5MjA1MjE5Ong4Nl82NC1sa3AtQ09ORklHX1NDU0lfREVCVUc6My4x
Mi4wLXJjNS13bC0wMTI0OS1nYjkxZTgyZDozMTcKL2tlcm5lbC94ODZfNjQtbGtwLUNPTkZJ
R19TQ1NJX0RFQlVHL2I5MWU4MmRjNmFkNTVmMmQzOWI5MmU3MzFjNmJiOTVjYzQ0YTkyM2Mv
ZG1lc2ctbmZzcm9vdC1zbmItMjk6MjAxMzEwMTkyMDUyNDU6eDg2XzY0LWxrcC1DT05GSUdf
U0NTSV9ERUJVRzozLjEyLjAtcmM1LXdsLTAxMjQ5LWdiOTFlODJkOjMxNwova2VybmVsL3g4
Nl82NC1sa3AtQ09ORklHX1NDU0lfREVCVUcvYjkxZTgyZGM2YWQ1NWYyZDM5YjkyZTczMWM2
YmI5NWNjNDRhOTIzYy9kbWVzZy1xdWFudGFsLWlubi0zNDoyMDEzMTAxOTIwNTAxNDp4ODZf
NjQtbGtwLUNPTkZJR19TQ1NJX0RFQlVHOjMuMTIuMC1yYzUtd2wtMDEyNDktZ2I5MWU4MmQ6
MzE3Ci9rZXJuZWwveDg2XzY0LWxrcC1DT05GSUdfU0NTSV9ERUJVRy9iOTFlODJkYzZhZDU1
ZjJkMzliOTJlNzMxYzZiYjk1Y2M0NGE5MjNjL2RtZXNnLW5mc3Jvb3QtaW5uLTEyOjIwMTMx
MDE5MjA1MjA1Ong4Nl82NC1sa3AtQ09ORklHX1NDU0lfREVCVUc6My4xMi4wLXJjNS13bC0w
MTI0OS1nYjkxZTgyZDozMTcKL2tlcm5lbC94ODZfNjQtbGtwLUNPTkZJR19TQ1NJX0RFQlVH
L2I5MWU4MmRjNmFkNTVmMmQzOWI5MmU3MzFjNmJiOTVjYzQ0YTkyM2MvZG1lc2ctbmZzcm9v
dC1yb2FtLTE3OjIwMTMxMDE5MDcxNjM4Ong4Nl82NC1sa3AtQ09ORklHX1NDU0lfREVCVUc6
My4xMi4wLXJjNS13bC0wMTI0OS1nYjkxZTgyZDozMTcKL2tlcm5lbC94ODZfNjQtbGtwLUNP
TkZJR19TQ1NJX0RFQlVHL2I5MWU4MmRjNmFkNTVmMmQzOWI5MmU3MzFjNmJiOTVjYzQ0YTky
M2MvZG1lc2ctbmZzcm9vdC1qYWtldG93bi0xNToyMDEzMTAxOTA3MzQ0MDp4ODZfNjQtbGtw
LUNPTkZJR19TQ1NJX0RFQlVHOjMuMTIuMC1yYzUtd2wtMDEyNDktZ2I5MWU4MmQ6MzE3Ci9r
ZXJuZWwveDg2XzY0LWxrcC1DT05GSUdfU0NTSV9ERUJVRy9iOTFlODJkYzZhZDU1ZjJkMzli
OTJlNzMxYzZiYjk1Y2M0NGE5MjNjL2RtZXNnLXlvY3RvLWlubi0yNzoyMDEzMTAxOTIwNTY0
Mzp4ODZfNjQtbGtwLUNPTkZJR19TQ1NJX0RFQlVHOjMuMTIuMC1yYzUtd2wtMDEyNDktZ2I5
MWU4MmQ6MzE3Ci9rZXJuZWwveDg2XzY0LWxrcC1DT05GSUdfU0NTSV9ERUJVRy9iOTFlODJk
YzZhZDU1ZjJkMzliOTJlNzMxYzZiYjk1Y2M0NGE5MjNjL2RtZXNnLXF1YW50YWwtbmhtNC01
OjIwMTMxMDE4MjMyMTIxOng4Nl82NC1sa3AtQ09ORklHX1NDU0lfREVCVUc6My4xMi4wLXJj
NS13bC0wMTI0OS1nYjkxZTgyZDozMTcKL2tlcm5lbC94ODZfNjQtbGtwLUNPTkZJR19TQ1NJ
X0RFQlVHL2I5MWU4MmRjNmFkNTVmMmQzOWI5MmU3MzFjNmJiOTVjYzQ0YTkyM2MvZG1lc2ct
cXVhbnRhbC1zbmItNDg6MjAxMzEwMTkwNzE2MTQ6eDg2XzY0LWxrcC1DT05GSUdfU0NTSV9E
RUJVRzozLjEyLjAtcmM1LXdsLTAxMjQ5LWdiOTFlODJkOjMxNwova2VybmVsL3g4Nl82NC1s
a3AtQ09ORklHX1NDU0lfREVCVUcvYjkxZTgyZGM2YWQ1NWYyZDM5YjkyZTczMWM2YmI5NWNj
NDRhOTIzYy9kbWVzZy1uZnNyb290LWlubi0yNDoyMDEzMTAxOTA3MTEwOTp4ODZfNjQtbGtw
LUNPTkZJR19TQ1NJX0RFQlVHOjMuMTIuMC1yYzUtd2wtMDEyNDktZ2I5MWU4MmQ6MzE3Ci9r
ZXJuZWwveDg2XzY0LWxrcC1DT05GSUdfU0NTSV9ERUJVRy9iOTFlODJkYzZhZDU1ZjJkMzli
OTJlNzMxYzZiYjk1Y2M0NGE5MjNjL2RtZXNnLW5mc3Jvb3Qtcm9hbS0xODoyMDEzMTAxOTA3
MTcxNzp4ODZfNjQtbGtwLUNPTkZJR19TQ1NJX0RFQlVHOjMuMTIuMC1yYzUtd2wtMDEyNDkt
Z2I5MWU4MmQ6MzE3Ci9rZXJuZWwveDg2XzY0LWxrcC1DT05GSUdfU0NTSV9ERUJVRy9iOTFl
ODJkYzZhZDU1ZjJkMzliOTJlNzMxYzZiYjk1Y2M0NGE5MjNjL2RtZXNnLW5mc3Jvb3Qtcm9h
bS0yMzoyMDEzMTAxOTA3MTcyMTp4ODZfNjQtbGtwLUNPTkZJR19TQ1NJX0RFQlVHOjMuMTIu
MC1yYzUtd2wtMDEyNDktZ2I5MWU4MmQ6MzE3Ci9rZXJuZWwveDg2XzY0LWxrcC1DT05GSUdf
U0NTSV9ERUJVRy9iOTFlODJkYzZhZDU1ZjJkMzliOTJlNzMxYzZiYjk1Y2M0NGE5MjNjL2Rt
ZXNnLXF1YW50YWwtcm9hbS0yNToyMDEzMTAxOTIxMDUxMzp4ODZfNjQtbGtwLUNPTkZJR19T
Q1NJX0RFQlVHOjMuMTIuMC1yYzUtd2wtMDEyNDktZ2I5MWU4MmQ6MzE3Ci9rZXJuZWwveDg2
XzY0LWxrcC1DT05GSUdfU0NTSV9ERUJVRy9iOTFlODJkYzZhZDU1ZjJkMzliOTJlNzMxYzZi
Yjk1Y2M0NGE5MjNjL2RtZXNnLXF1YW50YWwtY2Fpcm8tNzoyMDEzMTAxOTIwNDk1Mzp4ODZf
NjQtbGtwLUNPTkZJR19TQ1NJX0RFQlVHOjMuMTIuMC1yYzUtd2wtMDEyNDktZ2I5MWU4MmQ6
MzE3Ci9rZXJuZWwveDg2XzY0LWxrcC1DT05GSUdfU0NTSV9ERUJVRy9iOTFlODJkYzZhZDU1
ZjJkMzliOTJlNzMxYzZiYjk1Y2M0NGE5MjNjL2RtZXNnLW5mc3Jvb3Qtcm9hbS0xMjoyMDEz
MTAxOTA3MTcyMzp4ODZfNjQtbGtwLUNPTkZJR19TQ1NJX0RFQlVHOjMuMTIuMC1yYzUtd2wt
MDEyNDktZ2I5MWU4MmQ6MzE3CjE6MTg6MTggYWxsX2dvb2Q6YmFkOmFsbF9iYWQgYm9vdHMK
CltkZXRhY2hlZCBIRUFEIGJjODIzOTFdIFJldmVydCAidmlydGlvLW5ldDogZG9uJ3QgcmVz
cG9uZCB0byBjcHUgaG90cGx1ZyBub3RpZmllciBpZiB3ZSdyZSBub3QgcmVhZHkiCiAxIGZp
bGUgY2hhbmdlZCwgOCBkZWxldGlvbnMoLSkKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVl
dWUva3ZtL3g4Nl82NC1sa3AtQ09ORklHX1NDU0lfREVCVUcvbGludXgtZGV2ZWw6ZGV2ZWwt
aW5uLXg4Nl82NC0yMDEzMTAxOTA2MzQ6YmM4MjM5MTllNDJiYzdhMzFlZTA2ZmEwNDAxOTRk
YjZmNDU1YzJlMzpiaXNlY3QtbmV0CgoyMDEzLTEwLTIwLTA0OjUzOjA1IGJjODIzOTE5ZTQy
YmM3YTMxZWUwNmZhMDQwMTk0ZGI2ZjQ1NWMyZTMgY29tcGlsaW5nCgoyMDEzLTEwLTIwLTA0
OjU3OjE4IGRldGVjdGluZyBib290IHN0YXRlIDMuMTIuMC1yYzUtd2wtMDEyNTAtZ2JjODIz
OTEuLi4uLi4uLgkxLi4uLi4uLi4uLi4uLi4JMy4uLgk1Li4uLi4JOC4JOS4JMTAuCTEyCTE0
CTE1CTE4CTI0CTM0Li4uLgkzNQkzNi4JMzgJNDAJNTAuLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4JNTEuLi4uLi4uLi4uLi4uLi4uLi4JNTIuLi4JNTMuLi4uLi4uLgk1NC4uLi4JNTUu
Li4uLi4uLi4uLgk1Nwk1OQk2MCBTVUNDRVNTCgoKPT09PT09PT09IHVwc3RyZWFtID09PT09
PT09PQpGZXRjaGluZyBsaW51cwpscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0v
eDg2XzY0LWxrcC1DT05GSUdfU0NTSV9ERUJVRy9saW51eC1kZXZlbDpkZXZlbC1pbm4teDg2
XzY0LTIwMTMxMDE5MDYzNDozMWQxNDFlM2E2NjYyNjlhM2I2ZmNjY2RkYjAzNTFjYWY3NDU0
MjQwOmJpc2VjdC1uZXQKCjIwMTMtMTAtMjAtMDY6MDQ6MjYgMzFkMTQxZTNhNjY2MjY5YTNi
NmZjY2NkZGIwMzUxY2FmNzQ1NDI0MCByZXVzZSAva2VybmVsL3g4Nl82NC1sa3AtQ09ORklH
X1NDU0lfREVCVUcvMzFkMTQxZTNhNjY2MjY5YTNiNmZjY2NkZGIwMzUxY2FmNzQ1NDI0MC92
bWxpbnV6LTMuMTIuMC1yYzYtMDAxNDAtZzMxZDE0MWUKCjIwMTMtMTAtMjAtMDY6MDQ6MjYg
ZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLgkxCTIuCTUu
Li4JNi4uLgk3Li4uLgk4CTExCTE1CTE4CTI2CTI3CTMxLgkzMgkzNAkzNQkzNi4uCTM5CTQz
CTQ2CTQ3CTQ4Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uCTQ5Li4uLi4uLi4uLgk1MC4uCTUyCTUzCTU2CTU5Li4uLgk2MCBTVUNDRVNTCgoK
PT09PT09PT09IGxpbnV4LW5leHQgPT09PT09PT09CkZldGNoaW5nIG5leHQKbHMgLWEgL2tl
cm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1sa3AtQ09ORklHX1NDU0lfREVCVUcv
bGludXgtZGV2ZWw6ZGV2ZWwtaW5uLXg4Nl82NC0yMDEzMTAxOTA2MzQ6YTBjZjFhYmMyNWFj
MTk3ZGQ5N2I4NTdjMGY2MzQxMDY2YThjYjFjZjpiaXNlY3QtbmV0CgoyMDEzLTEwLTIwLTA3
OjExOjMzIGEwY2YxYWJjMjVhYzE5N2RkOTdiODU3YzBmNjM0MTA2NmE4Y2IxY2YgcmV1c2Ug
L2tlcm5lbC94ODZfNjQtbGtwLUNPTkZJR19TQ1NJX0RFQlVHL2EwY2YxYWJjMjVhYzE5N2Rk
OTdiODU3YzBmNjM0MTA2NmE4Y2IxY2Yvdm1saW51ei0zLjEyLjAtcmMyLW5leHQtMjAxMzA5
MjctMDMxMDAtZ2EwY2YxYWIKCjIwMTMtMTAtMjAtMDc6MTE6MzMgZGV0ZWN0aW5nIGJvb3Qg
c3RhdGUgLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uCTguLi4uLi4JOS4uLi4JMTIJMTQJ
MTUJMTYJMTcJMjAuLgkyNQkyOAkzMS4JMzIJMzMuLgkzNAkzNi4uCTM3CTQwCTQxLi4uLi4u
Lgk0Mi4JNDMuLi4JNDkuLi4uLi4uLi4uLi4uLi4uCTUxCTUyLi4uLi4JNTMuLi4uLi4uLi4u
Li4uLgk1Ngk1Nwk1OQk2MCBTVUNDRVNTCgo=

--3MwIy2ne0vdjdPXF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-3.12.0-rc5-wl-01249-gb91e82d"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 3.12.0-rc5 Kernel Configuration
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
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_X86_64_SMP=y
CONFIG_X86_HT=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_HAVE_KERNEL_LZ4=y
CONFIG_KERNEL_GZIP=y
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_POSIX_MQUEUE=y
CONFIG_POSIX_MQUEUE_SYSCTL=y
# CONFIG_FHANDLE is not set
# CONFIG_AUDIT is not set

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_PENDING_IRQ=y
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
# CONFIG_NO_HZ_FULL is not set
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
# CONFIG_VIRT_CPU_ACCOUNTING_GEN is not set
# CONFIG_IRQ_TIME_ACCOUNTING is not set
CONFIG_BSD_PROCESS_ACCT=y
# CONFIG_BSD_PROCESS_ACCT_V3 is not set
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
CONFIG_TASK_XACCT=y
CONFIG_TASK_IO_ACCOUNTING=y

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
# CONFIG_PREEMPT_RCU is not set
CONFIG_RCU_STALL_COMMON=y
# CONFIG_RCU_USER_QS is not set
CONFIG_RCU_FANOUT=64
CONFIG_RCU_FANOUT_LEAF=16
# CONFIG_RCU_FANOUT_EXACT is not set
# CONFIG_RCU_FAST_NO_HZ is not set
# CONFIG_TREE_RCU_TRACE is not set
CONFIG_RCU_NOCB_CPU=y
CONFIG_RCU_NOCB_CPU_NONE=y
# CONFIG_RCU_NOCB_CPU_ZERO is not set
# CONFIG_RCU_NOCB_CPU_ALL is not set
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=20
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANTS_PROT_NUMA_PROT_NONE=y
CONFIG_ARCH_USES_NUMA_PROT_NONE=y
# CONFIG_NUMA_BALANCING_DEFAULT_ENABLED is not set
CONFIG_NUMA_BALANCING=y
CONFIG_CGROUPS=y
# CONFIG_CGROUP_DEBUG is not set
# CONFIG_CGROUP_FREEZER is not set
# CONFIG_CGROUP_DEVICE is not set
CONFIG_CPUSETS=y
CONFIG_PROC_PID_CPUSET=y
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_RESOURCE_COUNTERS=y
CONFIG_MEMCG=y
CONFIG_MEMCG_SWAP=y
CONFIG_MEMCG_SWAP_ENABLED=y
CONFIG_MEMCG_KMEM=y
CONFIG_CGROUP_HUGETLB=y
CONFIG_CGROUP_PERF=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
# CONFIG_CFS_BANDWIDTH is not set
# CONFIG_RT_GROUP_SCHED is not set
CONFIG_BLK_CGROUP=y
CONFIG_DEBUG_BLK_CGROUP=y
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
CONFIG_IPC_NS=y
# CONFIG_USER_NS is not set
CONFIG_PID_NS=y
CONFIG_NET_NS=y
# CONFIG_UIDGID_STRICT_TYPE_CHECKS is not set
# CONFIG_SCHED_AUTOGROUP is not set
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
CONFIG_RD_LZ4=y
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
# CONFIG_EXPERT is not set
CONFIG_UID16=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
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
CONFIG_SLUB_CPU_PARTIAL=y
CONFIG_PROFILING=y
CONFIG_TRACEPOINTS=y
CONFIG_OPROFILE=y
# CONFIG_OPROFILE_EVENT_MULTIPLEX is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_KPROBES=y
# CONFIG_JUMP_LABEL is not set
CONFIG_OPTPROBES=y
CONFIG_KPROBES_ON_FTRACE=y
CONFIG_UPROBES=y
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_KRETPROBES=y
CONFIG_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_USE_GENERIC_SMP_HELPERS=y
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
CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=y
CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_COMPAT_OLD_SIGACTION=y

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
# CONFIG_MODULE_FORCE_LOAD is not set
CONFIG_MODULE_UNLOAD=y
# CONFIG_MODULE_FORCE_UNLOAD is not set
CONFIG_MODVERSIONS=y
CONFIG_MODULE_SRCVERSION_ALL=y
# CONFIG_MODULE_SIG is not set
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
# CONFIG_BLK_DEV_INTEGRITY is not set
CONFIG_BLK_DEV_THROTTLING=y
# CONFIG_BLK_CMDLINE_PARSER is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
# CONFIG_ACORN_PARTITION is not set
# CONFIG_AIX_PARTITION is not set
CONFIG_OSF_PARTITION=y
CONFIG_AMIGA_PARTITION=y
# CONFIG_ATARI_PARTITION is not set
CONFIG_MAC_PARTITION=y
CONFIG_MSDOS_PARTITION=y
CONFIG_BSD_DISKLABEL=y
CONFIG_MINIX_SUBPARTITION=y
CONFIG_SOLARIS_X86_PARTITION=y
CONFIG_UNIXWARE_DISKLABEL=y
# CONFIG_LDM_PARTITION is not set
CONFIG_SGI_PARTITION=y
# CONFIG_ULTRIX_PARTITION is not set
CONFIG_SUN_PARTITION=y
CONFIG_KARMA_PARTITION=y
CONFIG_EFI_PARTITION=y
# CONFIG_SYSV68_PARTITION is not set
# CONFIG_CMDLINE_PARTITION is not set
CONFIG_BLOCK_COMPAT=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
CONFIG_CFQ_GROUP_IOSCHED=y
# CONFIG_DEFAULT_DEADLINE is not set
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"
CONFIG_PREEMPT_NOTIFIERS=y
CONFIG_PADATA=y
CONFIG_ASN1=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
CONFIG_X86_MPPARSE=y
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_VSMP is not set
# CONFIG_X86_INTEL_LPSS is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_PARAVIRT_SPINLOCKS is not set
# CONFIG_XEN is not set
# CONFIG_XEN_PRIVILEGED_GUEST is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
# CONFIG_MEMTEST is not set
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
CONFIG_HPET_EMULATE_RTC=y
CONFIG_DMI=y
CONFIG_GART_IOMMU=y
# CONFIG_CALGARY_IOMMU is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
# CONFIG_MAXSMP is not set
CONFIG_NR_CPUS=256
CONFIG_SCHED_SMT=y
CONFIG_SCHED_MC=y
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
CONFIG_X86_MCE=y
CONFIG_X86_MCE_INTEL=y
# CONFIG_X86_MCE_AMD is not set
CONFIG_X86_MCE_THRESHOLD=y
CONFIG_X86_MCE_INJECT=y
CONFIG_X86_THERMAL_VECTOR=y
# CONFIG_I8K is not set
# CONFIG_MICROCODE is not set
# CONFIG_MICROCODE_INTEL_EARLY is not set
# CONFIG_MICROCODE_AMD_EARLY is not set
# CONFIG_X86_MSR is not set
# CONFIG_X86_CPUID is not set
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_DIRECT_GBPAGES=y
CONFIG_NUMA=y
CONFIG_AMD_NUMA=y
CONFIG_X86_64_ACPI_NUMA=y
CONFIG_NODES_SPAN_OTHER_NODES=y
# CONFIG_NUMA_EMU is not set
CONFIG_NODES_SHIFT=6
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_MEMORY_PROBE=y
CONFIG_ARCH_PROC_KCORE_TEXT=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_NEED_MULTIPLE_NODES=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
# CONFIG_MOVABLE_NODE is not set
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
# CONFIG_MEMORY_HOTREMOVE is not set
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=999999
CONFIG_BALLOON_COMPACTION=y
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
# CONFIG_KSM is not set
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_MEMORY_FAILURE is not set
CONFIG_TRANSPARENT_HUGEPAGE=y
# CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS is not set
CONFIG_TRANSPARENT_HUGEPAGE_MADVISE=y
CONFIG_CROSS_MEMORY_ATTACH=y
# CONFIG_CLEANCACHE is not set
# CONFIG_FRONTSWAP is not set
# CONFIG_CMA is not set
# CONFIG_ZBUD is not set
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=y
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
# CONFIG_MTRR_SANITIZER is not set
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
CONFIG_X86_SMAP=y
CONFIG_EFI=y
# CONFIG_EFI_STUB is not set
# CONFIG_SECCOMP is not set
# CONFIG_CC_STACKPROTECTOR is not set
# CONFIG_HZ_100 is not set
CONFIG_HZ_250=y
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=250
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
# CONFIG_CRASH_DUMP is not set
CONFIG_KEXEC_JUMP=y
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
CONFIG_PHYSICAL_ALIGN=0x1000000
CONFIG_HOTPLUG_CPU=y
# CONFIG_BOOTPARAM_HOTPLUG_CPU0 is not set
# CONFIG_DEBUG_HOTPLUG_CPU0 is not set
CONFIG_COMPAT_VDSO=y
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y
CONFIG_USE_PERCPU_NUMA_NODE_ID=y

#
# Power management and ACPI options
#
CONFIG_ARCH_HIBERNATION_HEADER=y
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_HIBERNATE_CALLBACKS=y
CONFIG_HIBERNATION=y
CONFIG_PM_STD_PARTITION=""
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
CONFIG_PM_AUTOSLEEP=y
# CONFIG_PM_WAKELOCKS is not set
CONFIG_PM_RUNTIME=y
CONFIG_PM=y
CONFIG_PM_DEBUG=y
CONFIG_PM_ADVANCED_DEBUG=y
CONFIG_PM_TEST_SUSPEND=y
CONFIG_PM_SLEEP_DEBUG=y
# CONFIG_PM_TRACE_RTC is not set
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS is not set
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_FAN=y
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_IPMI is not set
CONFIG_ACPI_HOTPLUG_CPU=y
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_NUMA=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
CONFIG_ACPI_BLACKLIST_YEAR=0
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
# CONFIG_ACPI_HOTPLUG_MEMORY is not set
# CONFIG_ACPI_SBS is not set
CONFIG_ACPI_HED=y
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_BGRT is not set
CONFIG_ACPI_APEI=y
CONFIG_ACPI_APEI_GHES=y
CONFIG_ACPI_APEI_PCIEAER=y
CONFIG_ACPI_APEI_EINJ=y
CONFIG_ACPI_APEI_ERST_DEBUG=y
# CONFIG_SFI is not set

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_GOV_COMMON=y
CONFIG_CPU_FREQ_STAT=y
CONFIG_CPU_FREQ_STAT_DETAILS=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y

#
# x86 CPU frequency scaling drivers
#
# CONFIG_X86_INTEL_PSTATE is not set
# CONFIG_X86_PCC_CPUFREQ is not set
CONFIG_X86_ACPI_CPUFREQ=y
CONFIG_X86_ACPI_CPUFREQ_CPB=y
CONFIG_X86_POWERNOW_K8=y
# CONFIG_X86_AMD_FREQ_SENSITIVITY is not set
CONFIG_X86_SPEEDSTEP_CENTRINO=y
# CONFIG_X86_P4_CLOCKMOD is not set

#
# shared options
#
# CONFIG_X86_SPEEDSTEP_LIB is not set

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
# CONFIG_CPU_IDLE_MULTIPLE_DRIVERS is not set
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
CONFIG_INTEL_IDLE=y

#
# Memory power savings
#
# CONFIG_I7300_IDLE is not set

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
CONFIG_PCIEPORTBUS=y
CONFIG_HOTPLUG_PCI_PCIE=y
CONFIG_PCIEAER=y
# CONFIG_PCIE_ECRC is not set
# CONFIG_PCIEAER_INJECT is not set
CONFIG_PCIEASPM=y
CONFIG_PCIEASPM_DEBUG=y
CONFIG_PCIEASPM_DEFAULT=y
# CONFIG_PCIEASPM_POWERSAVE is not set
# CONFIG_PCIEASPM_PERFORMANCE is not set
CONFIG_PCIE_PME=y
CONFIG_PCI_MSI=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
# CONFIG_PCI_STUB is not set
CONFIG_HT_IRQ=y
# CONFIG_PCI_IOV is not set
# CONFIG_PCI_PRI is not set
# CONFIG_PCI_PASID is not set
CONFIG_PCI_IOAPIC=y
CONFIG_PCI_LABEL=y

#
# PCI host controller drivers
#
CONFIG_ISA_DMA_API=y
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
CONFIG_PCMCIA=y
CONFIG_PCMCIA_LOAD_CIS=y
CONFIG_CARDBUS=y

#
# PC-card bridges
#
CONFIG_YENTA=y
CONFIG_YENTA_O2=y
CONFIG_YENTA_RICOH=y
CONFIG_YENTA_TI=y
CONFIG_YENTA_ENE_TUNE=y
CONFIG_YENTA_TOSHIBA=y
# CONFIG_PD6729 is not set
# CONFIG_I82092 is not set
CONFIG_PCCARD_NONSTATIC=y
CONFIG_HOTPLUG_PCI=y
CONFIG_HOTPLUG_PCI_ACPI=y
# CONFIG_HOTPLUG_PCI_ACPI_IBM is not set
# CONFIG_HOTPLUG_PCI_CPCI is not set
# CONFIG_HOTPLUG_PCI_SHPC is not set
# CONFIG_RAPIDIO is not set
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
# CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
CONFIG_BINFMT_SCRIPT=y
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=y
CONFIG_COREDUMP=y
CONFIG_IA32_EMULATION=y
CONFIG_IA32_AOUT=y
# CONFIG_X86_X32 is not set
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_KEYS_COMPAT=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_NET=y

#
# Networking options
#
CONFIG_PACKET=y
# CONFIG_PACKET_DIAG is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
CONFIG_XFRM_USER=y
# CONFIG_XFRM_SUB_POLICY is not set
# CONFIG_XFRM_MIGRATE is not set
# CONFIG_XFRM_STATISTICS is not set
# CONFIG_NET_KEY is not set
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
CONFIG_IP_ADVANCED_ROUTER=y
# CONFIG_IP_FIB_TRIE_STATS is not set
CONFIG_IP_MULTIPLE_TABLES=y
CONFIG_IP_ROUTE_MULTIPATH=y
CONFIG_IP_ROUTE_VERBOSE=y
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
CONFIG_IP_PNP_BOOTP=y
CONFIG_IP_PNP_RARP=y
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE_DEMUX is not set
CONFIG_NET_IP_TUNNEL=y
CONFIG_IP_MROUTE=y
# CONFIG_IP_MROUTE_MULTIPLE_TABLES is not set
CONFIG_IP_PIMSM_V1=y
CONFIG_IP_PIMSM_V2=y
CONFIG_SYN_COOKIES=y
# CONFIG_INET_AH is not set
# CONFIG_INET_ESP is not set
# CONFIG_INET_IPCOMP is not set
# CONFIG_INET_XFRM_TUNNEL is not set
CONFIG_INET_TUNNEL=y
# CONFIG_INET_XFRM_MODE_TRANSPORT is not set
# CONFIG_INET_XFRM_MODE_TUNNEL is not set
CONFIG_INET_XFRM_MODE_BEET=y
# CONFIG_INET_LRO is not set
# CONFIG_INET_DIAG is not set
CONFIG_TCP_CONG_ADVANCED=y
CONFIG_TCP_CONG_BIC=y
# CONFIG_TCP_CONG_CUBIC is not set
# CONFIG_TCP_CONG_WESTWOOD is not set
# CONFIG_TCP_CONG_HTCP is not set
# CONFIG_TCP_CONG_HSTCP is not set
# CONFIG_TCP_CONG_HYBLA is not set
# CONFIG_TCP_CONG_VEGAS is not set
# CONFIG_TCP_CONG_SCALABLE is not set
# CONFIG_TCP_CONG_LP is not set
# CONFIG_TCP_CONG_VENO is not set
# CONFIG_TCP_CONG_YEAH is not set
# CONFIG_TCP_CONG_ILLINOIS is not set
CONFIG_DEFAULT_BIC=y
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG="bic"
# CONFIG_TCP_MD5SIG is not set
CONFIG_IPV6=y
# CONFIG_IPV6_PRIVACY is not set
# CONFIG_IPV6_ROUTER_PREF is not set
# CONFIG_IPV6_OPTIMISTIC_DAD is not set
# CONFIG_INET6_AH is not set
# CONFIG_INET6_ESP is not set
# CONFIG_INET6_IPCOMP is not set
# CONFIG_IPV6_MIP6 is not set
# CONFIG_INET6_XFRM_TUNNEL is not set
# CONFIG_INET6_TUNNEL is not set
CONFIG_INET6_XFRM_MODE_TRANSPORT=y
CONFIG_INET6_XFRM_MODE_TUNNEL=y
CONFIG_INET6_XFRM_MODE_BEET=y
# CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION is not set
CONFIG_IPV6_SIT=y
# CONFIG_IPV6_SIT_6RD is not set
CONFIG_IPV6_NDISC_NODETYPE=y
# CONFIG_IPV6_TUNNEL is not set
# CONFIG_IPV6_GRE is not set
# CONFIG_IPV6_MULTIPLE_TABLES is not set
# CONFIG_IPV6_MROUTE is not set
CONFIG_NETWORK_SECMARK=y
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
# CONFIG_NETFILTER is not set
# CONFIG_IP_DCCP is not set
CONFIG_IP_SCTP=y
# CONFIG_NET_SCTPPROBE is not set
# CONFIG_SCTP_DBG_OBJCNT is not set
CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5=y
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1 is not set
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE is not set
CONFIG_SCTP_COOKIE_HMAC_MD5=y
# CONFIG_SCTP_COOKIE_HMAC_SHA1 is not set
# CONFIG_RDS is not set
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
# CONFIG_L2TP is not set
# CONFIG_BRIDGE is not set
CONFIG_HAVE_NET_DSA=y
CONFIG_VLAN_8021Q=y
# CONFIG_VLAN_8021Q_GVRP is not set
# CONFIG_VLAN_8021Q_MVRP is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
# CONFIG_IEEE802154 is not set
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
CONFIG_DNS_RESOLVER=y
# CONFIG_BATMAN_ADV is not set
# CONFIG_OPENVSWITCH is not set
# CONFIG_VSOCKETS is not set
# CONFIG_NETLINK_MMAP is not set
# CONFIG_NETLINK_DIAG is not set
# CONFIG_NET_MPLS_GSO is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
# CONFIG_NETPRIO_CGROUP is not set
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
# CONFIG_BPF_JIT is not set
CONFIG_NET_FLOW_LIMIT=y

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
# CONFIG_NET_TCPPROBE is not set
# CONFIG_NET_DROP_MONITOR is not set
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
# CONFIG_AF_RXRPC is not set
CONFIG_FIB_RULES=y
CONFIG_WIRELESS=y
# CONFIG_CFG80211 is not set
# CONFIG_LIB80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
# CONFIG_NET_9P is not set
# CONFIG_CAIF is not set
# CONFIG_CEPH_LIB is not set
# CONFIG_NFC is not set
CONFIG_HAVE_BPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH="/sbin/hotplug"
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
# CONFIG_DMA_SHARED_BUFFER is not set

#
# Bus devices
#
CONFIG_CONNECTOR=y
CONFIG_PROC_EVENTS=y
# CONFIG_MTD is not set
# CONFIG_PARPORT is not set
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_FD is not set
# CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
# CONFIG_BLK_CPQ_DA is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=y
CONFIG_BLK_DEV_LOOP_MIN_COUNT=8
# CONFIG_BLK_DEV_CRYPTOLOOP is not set
# CONFIG_BLK_DEV_DRBD is not set
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_NVME is not set
# CONFIG_BLK_DEV_SX8 is not set
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=16384
# CONFIG_BLK_DEV_XIP is not set
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
CONFIG_VIRTIO_BLK=y
# CONFIG_BLK_DEV_HD is not set
# CONFIG_BLK_DEV_RBD is not set
# CONFIG_BLK_DEV_RSXX is not set

#
# Misc devices
#
# CONFIG_SENSORS_LIS3LV02D is not set
# CONFIG_AD525X_DPOT is not set
# CONFIG_DUMMY_IRQ is not set
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
# CONFIG_ICS932S401 is not set
# CONFIG_ATMEL_SSC is not set
# CONFIG_ENCLOSURE_SERVICES is not set
# CONFIG_HP_ILO is not set
# CONFIG_APDS9802ALS is not set
# CONFIG_ISL29003 is not set
# CONFIG_ISL29020 is not set
# CONFIG_SENSORS_TSL2550 is not set
# CONFIG_SENSORS_BH1780 is not set
# CONFIG_SENSORS_BH1770 is not set
# CONFIG_SENSORS_APDS990X is not set
# CONFIG_HMC6352 is not set
# CONFIG_DS1682 is not set
# CONFIG_VMWARE_BALLOON is not set
# CONFIG_BMP085_I2C is not set
# CONFIG_PCH_PHUB is not set
# CONFIG_USB_SWITCH_FSA9480 is not set
# CONFIG_SRAM is not set
# CONFIG_C2PORT is not set

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
# CONFIG_EEPROM_LEGACY is not set
# CONFIG_EEPROM_MAX6875 is not set
# CONFIG_EEPROM_93CX6 is not set
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
# CONFIG_SENSORS_LIS3_I2C is not set

#
# Altera FPGA firmware download module
#
# CONFIG_ALTERA_STAPL is not set
# CONFIG_INTEL_MEI is not set
# CONFIG_INTEL_MEI_ME is not set
# CONFIG_VMWARE_VMCI is not set
CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
# CONFIG_SCSI_TGT is not set
CONFIG_SCSI_NETLINK=y
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
# CONFIG_CHR_DEV_ST is not set
# CONFIG_CHR_DEV_OSST is not set
CONFIG_BLK_DEV_SR=y
CONFIG_BLK_DEV_SR_VENDOR=y
CONFIG_CHR_DEV_SG=y
# CONFIG_CHR_DEV_SCH is not set
CONFIG_SCSI_MULTI_LUN=y
CONFIG_SCSI_CONSTANTS=y
CONFIG_SCSI_LOGGING=y
CONFIG_SCSI_SCAN_ASYNC=y

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
CONFIG_SCSI_FC_ATTRS=y
CONFIG_SCSI_ISCSI_ATTRS=y
CONFIG_SCSI_SAS_ATTRS=y
CONFIG_SCSI_SAS_LIBSAS=y
# CONFIG_SCSI_SAS_ATA is not set
CONFIG_SCSI_SAS_HOST_SMP=y
# CONFIG_SCSI_SRP_ATTRS is not set
CONFIG_SCSI_LOWLEVEL=y
# CONFIG_ISCSI_TCP is not set
# CONFIG_ISCSI_BOOT_SYSFS is not set
# CONFIG_SCSI_CXGB3_ISCSI is not set
# CONFIG_SCSI_CXGB4_ISCSI is not set
# CONFIG_SCSI_BNX2_ISCSI is not set
# CONFIG_SCSI_BNX2X_FCOE is not set
# CONFIG_BE2ISCSI is not set
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
# CONFIG_SCSI_HPSA is not set
# CONFIG_SCSI_3W_9XXX is not set
# CONFIG_SCSI_3W_SAS is not set
CONFIG_SCSI_ACARD=y
CONFIG_SCSI_AACRAID=y
CONFIG_SCSI_AIC7XXX=y
CONFIG_AIC7XXX_CMDS_PER_DEVICE=4
CONFIG_AIC7XXX_RESET_DELAY_MS=15000
# CONFIG_AIC7XXX_DEBUG_ENABLE is not set
CONFIG_AIC7XXX_DEBUG_MASK=0
# CONFIG_AIC7XXX_REG_PRETTY_PRINT is not set
CONFIG_SCSI_AIC7XXX_OLD=y
CONFIG_SCSI_AIC79XX=y
CONFIG_AIC79XX_CMDS_PER_DEVICE=4
CONFIG_AIC79XX_RESET_DELAY_MS=15000
# CONFIG_AIC79XX_DEBUG_ENABLE is not set
CONFIG_AIC79XX_DEBUG_MASK=0
# CONFIG_AIC79XX_REG_PRETTY_PRINT is not set
CONFIG_SCSI_AIC94XX=y
# CONFIG_AIC94XX_DEBUG is not set
# CONFIG_SCSI_MVSAS is not set
# CONFIG_SCSI_MVUMI is not set
# CONFIG_SCSI_DPT_I2O is not set
# CONFIG_SCSI_ADVANSYS is not set
# CONFIG_SCSI_ARCMSR is not set
# CONFIG_SCSI_ESAS2R is not set
CONFIG_MEGARAID_NEWGEN=y
CONFIG_MEGARAID_MM=y
CONFIG_MEGARAID_MAILBOX=y
CONFIG_MEGARAID_LEGACY=y
CONFIG_MEGARAID_SAS=y
CONFIG_SCSI_MPT2SAS=m
CONFIG_SCSI_MPT2SAS_MAX_SGE=128
# CONFIG_SCSI_MPT2SAS_LOGGING is not set
CONFIG_SCSI_MPT3SAS=m
CONFIG_SCSI_MPT3SAS_MAX_SGE=128
# CONFIG_SCSI_MPT3SAS_LOGGING is not set
# CONFIG_SCSI_UFSHCD is not set
CONFIG_SCSI_HPTIOP=y
CONFIG_SCSI_BUSLOGIC=y
# CONFIG_SCSI_FLASHPOINT is not set
# CONFIG_VMWARE_PVSCSI is not set
# CONFIG_LIBFC is not set
# CONFIG_LIBFCOE is not set
# CONFIG_FCOE is not set
# CONFIG_FCOE_FNIC is not set
# CONFIG_SCSI_DMX3191D is not set
# CONFIG_SCSI_EATA is not set
# CONFIG_SCSI_FUTURE_DOMAIN is not set
CONFIG_SCSI_GDTH=y
CONFIG_SCSI_ISCI=m
# CONFIG_SCSI_IPS is not set
# CONFIG_SCSI_INITIO is not set
# CONFIG_SCSI_INIA100 is not set
# CONFIG_SCSI_STEX is not set
# CONFIG_SCSI_SYM53C8XX_2 is not set
# CONFIG_SCSI_IPR is not set
CONFIG_SCSI_QLOGIC_1280=y
CONFIG_SCSI_QLA_FC=y
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
# CONFIG_SCSI_DH is not set
# CONFIG_SCSI_OSD_INITIATOR is not set
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_VERBOSE_ERROR=y
CONFIG_ATA_ACPI=y
# CONFIG_SATA_ZPODD is not set
CONFIG_SATA_PMP=y

#
# Controllers with non-SFF native interface
#
CONFIG_SATA_AHCI=y
# CONFIG_SATA_AHCI_PLATFORM is not set
# CONFIG_SATA_INIC162X is not set
# CONFIG_SATA_ACARD_AHCI is not set
# CONFIG_SATA_SIL24 is not set
CONFIG_ATA_SFF=y

#
# SFF controllers with custom DMA interface
#
# CONFIG_PDC_ADMA is not set
# CONFIG_SATA_QSTOR is not set
# CONFIG_SATA_SX4 is not set
CONFIG_ATA_BMDMA=y

#
# SATA SFF controllers with BMDMA
#
CONFIG_ATA_PIIX=y
# CONFIG_SATA_HIGHBANK is not set
# CONFIG_SATA_MV is not set
# CONFIG_SATA_NV is not set
# CONFIG_SATA_PROMISE is not set
# CONFIG_SATA_RCAR is not set
# CONFIG_SATA_SIL is not set
# CONFIG_SATA_SIS is not set
# CONFIG_SATA_SVW is not set
# CONFIG_SATA_ULI is not set
# CONFIG_SATA_VIA is not set
# CONFIG_SATA_VITESSE is not set

#
# PATA SFF controllers with BMDMA
#
# CONFIG_PATA_ALI is not set
# CONFIG_PATA_AMD is not set
# CONFIG_PATA_ARTOP is not set
# CONFIG_PATA_ATIIXP is not set
# CONFIG_PATA_ATP867X is not set
# CONFIG_PATA_CMD64X is not set
# CONFIG_PATA_CS5520 is not set
# CONFIG_PATA_CS5530 is not set
# CONFIG_PATA_CS5536 is not set
# CONFIG_PATA_CYPRESS is not set
# CONFIG_PATA_EFAR is not set
# CONFIG_PATA_HPT366 is not set
# CONFIG_PATA_HPT37X is not set
# CONFIG_PATA_HPT3X2N is not set
# CONFIG_PATA_HPT3X3 is not set
# CONFIG_PATA_IT8213 is not set
# CONFIG_PATA_IT821X is not set
# CONFIG_PATA_JMICRON is not set
# CONFIG_PATA_MARVELL is not set
# CONFIG_PATA_NETCELL is not set
# CONFIG_PATA_NINJA32 is not set
# CONFIG_PATA_NS87415 is not set
# CONFIG_PATA_OLDPIIX is not set
# CONFIG_PATA_OPTIDMA is not set
# CONFIG_PATA_PDC2027X is not set
# CONFIG_PATA_PDC_OLD is not set
# CONFIG_PATA_RADISYS is not set
# CONFIG_PATA_RDC is not set
# CONFIG_PATA_SC1200 is not set
# CONFIG_PATA_SCH is not set
# CONFIG_PATA_SERVERWORKS is not set
# CONFIG_PATA_SIL680 is not set
# CONFIG_PATA_SIS is not set
# CONFIG_PATA_TOSHIBA is not set
# CONFIG_PATA_TRIFLEX is not set
# CONFIG_PATA_VIA is not set
# CONFIG_PATA_WINBOND is not set

#
# PIO-only SFF controllers
#
# CONFIG_PATA_CMD640_PCI is not set
# CONFIG_PATA_MPIIX is not set
# CONFIG_PATA_NS87410 is not set
# CONFIG_PATA_OPTI is not set
# CONFIG_PATA_PCMCIA is not set
# CONFIG_PATA_RZ1000 is not set

#
# Generic fallback / legacy drivers
#
# CONFIG_PATA_ACPI is not set
# CONFIG_ATA_GENERIC is not set
# CONFIG_PATA_LEGACY is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
# CONFIG_MD_AUTODETECT is not set
CONFIG_MD_LINEAR=y
CONFIG_MD_RAID0=y
CONFIG_MD_RAID1=y
CONFIG_MD_RAID10=y
CONFIG_MD_RAID456=y
CONFIG_MD_MULTIPATH=y
CONFIG_MD_FAULTY=y
CONFIG_BCACHE=y
# CONFIG_BCACHE_DEBUG is not set
# CONFIG_BCACHE_EDEBUG is not set
# CONFIG_BCACHE_CLOSURES_DEBUG is not set
CONFIG_BLK_DEV_DM=y
# CONFIG_DM_DEBUG is not set
CONFIG_DM_BUFIO=y
CONFIG_DM_BIO_PRISON=y
CONFIG_DM_PERSISTENT_DATA=y
CONFIG_DM_CRYPT=y
CONFIG_DM_SNAPSHOT=y
# CONFIG_DM_THIN_PROVISIONING is not set
CONFIG_DM_CACHE=y
CONFIG_DM_CACHE_MQ=y
CONFIG_DM_CACHE_CLEANER=y
CONFIG_DM_MIRROR=y
# CONFIG_DM_RAID is not set
# CONFIG_DM_LOG_USERSPACE is not set
CONFIG_DM_ZERO=y
CONFIG_DM_MULTIPATH=y
# CONFIG_DM_MULTIPATH_QL is not set
# CONFIG_DM_MULTIPATH_ST is not set
CONFIG_DM_DELAY=y
# CONFIG_DM_UEVENT is not set
CONFIG_DM_FLAKEY=y
# CONFIG_DM_VERITY is not set
# CONFIG_DM_SWITCH is not set
# CONFIG_TARGET_CORE is not set
CONFIG_FUSION=y
CONFIG_FUSION_SPI=y
CONFIG_FUSION_FC=y
CONFIG_FUSION_SAS=y
CONFIG_FUSION_MAX_SGE=40
CONFIG_FUSION_CTL=y
# CONFIG_FUSION_LOGGING is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_I2O is not set
# CONFIG_MACINTOSH_DRIVERS is not set
CONFIG_NETDEVICES=y
CONFIG_MII=y
CONFIG_NET_CORE=y
# CONFIG_BONDING is not set
# CONFIG_DUMMY is not set
# CONFIG_EQUALIZER is not set
# CONFIG_NET_FC is not set
# CONFIG_NET_TEAM is not set
# CONFIG_MACVLAN is not set
# CONFIG_VXLAN is not set
# CONFIG_NETCONSOLE is not set
# CONFIG_NETPOLL is not set
# CONFIG_NET_POLL_CONTROLLER is not set
# CONFIG_TUN is not set
# CONFIG_VETH is not set
CONFIG_VIRTIO_NET=y
# CONFIG_NLMON is not set
# CONFIG_ARCNET is not set

#
# CAIF transport drivers
#
CONFIG_VHOST_NET=y
CONFIG_VHOST_RING=y
CONFIG_VHOST=y

#
# Distributed Switch Architecture drivers
#
# CONFIG_NET_DSA_MV88E6XXX is not set
# CONFIG_NET_DSA_MV88E6060 is not set
# CONFIG_NET_DSA_MV88E6XXX_NEED_PPU is not set
# CONFIG_NET_DSA_MV88E6131 is not set
# CONFIG_NET_DSA_MV88E6123_61_65 is not set
CONFIG_ETHERNET=y
CONFIG_MDIO=y
# CONFIG_NET_VENDOR_3COM is not set
CONFIG_NET_VENDOR_ADAPTEC=y
# CONFIG_ADAPTEC_STARFIRE is not set
CONFIG_NET_VENDOR_ALTEON=y
CONFIG_ACENIC=y
# CONFIG_ACENIC_OMIT_TIGON_I is not set
CONFIG_NET_VENDOR_AMD=y
CONFIG_AMD8111_ETH=y
CONFIG_PCNET32=y
# CONFIG_PCMCIA_NMCLAN is not set
CONFIG_NET_VENDOR_ARC=y
CONFIG_NET_VENDOR_ATHEROS=y
CONFIG_ATL2=y
CONFIG_ATL1=y
CONFIG_ATL1E=y
CONFIG_ATL1C=y
# CONFIG_ALX is not set
CONFIG_NET_CADENCE=y
# CONFIG_ARM_AT91_ETHER is not set
# CONFIG_MACB is not set
CONFIG_NET_VENDOR_BROADCOM=y
# CONFIG_B44 is not set
CONFIG_BNX2=y
# CONFIG_CNIC is not set
CONFIG_TIGON3=y
# CONFIG_BNX2X is not set
CONFIG_NET_VENDOR_BROCADE=y
# CONFIG_BNA is not set
# CONFIG_NET_CALXEDA_XGMAC is not set
CONFIG_NET_VENDOR_CHELSIO=y
# CONFIG_CHELSIO_T1 is not set
# CONFIG_CHELSIO_T3 is not set
# CONFIG_CHELSIO_T4 is not set
# CONFIG_CHELSIO_T4VF is not set
CONFIG_NET_VENDOR_CISCO=y
# CONFIG_ENIC is not set
# CONFIG_DNET is not set
CONFIG_NET_VENDOR_DEC=y
CONFIG_NET_TULIP=y
# CONFIG_DE2104X is not set
CONFIG_TULIP=y
# CONFIG_TULIP_MWI is not set
# CONFIG_TULIP_MMIO is not set
# CONFIG_TULIP_NAPI is not set
CONFIG_DE4X5=y
CONFIG_WINBOND_840=y
CONFIG_DM9102=y
CONFIG_ULI526X=y
# CONFIG_PCMCIA_XIRCOM is not set
CONFIG_NET_VENDOR_DLINK=y
CONFIG_DL2K=y
# CONFIG_SUNDANCE is not set
CONFIG_NET_VENDOR_EMULEX=y
# CONFIG_BE2NET is not set
CONFIG_NET_VENDOR_EXAR=y
# CONFIG_S2IO is not set
# CONFIG_VXGE is not set
CONFIG_NET_VENDOR_FUJITSU=y
# CONFIG_PCMCIA_FMVJ18X is not set
CONFIG_NET_VENDOR_HP=y
# CONFIG_HP100 is not set
CONFIG_NET_VENDOR_INTEL=y
CONFIG_E100=y
CONFIG_E1000=y
CONFIG_E1000E=y
CONFIG_IGB=y
CONFIG_IGB_HWMON=y
# CONFIG_IGBVF is not set
CONFIG_IXGB=y
CONFIG_IXGBE=y
CONFIG_IXGBE_HWMON=y
# CONFIG_IXGBEVF is not set
# CONFIG_I40E is not set
CONFIG_NET_VENDOR_I825XX=y
# CONFIG_IP1000 is not set
# CONFIG_JME is not set
CONFIG_NET_VENDOR_MARVELL=y
# CONFIG_MVMDIO is not set
CONFIG_SKGE=y
CONFIG_SKGE_DEBUG=y
# CONFIG_SKGE_GENESIS is not set
CONFIG_SKY2=y
CONFIG_SKY2_DEBUG=y
CONFIG_NET_VENDOR_MELLANOX=y
# CONFIG_MLX4_EN is not set
# CONFIG_MLX4_CORE is not set
# CONFIG_MLX5_CORE is not set
CONFIG_NET_VENDOR_MICREL=y
# CONFIG_KS8851_MLL is not set
# CONFIG_KSZ884X_PCI is not set
CONFIG_NET_VENDOR_MYRI=y
# CONFIG_MYRI10GE is not set
# CONFIG_FEALNX is not set
CONFIG_NET_VENDOR_NATSEMI=y
# CONFIG_NATSEMI is not set
# CONFIG_NS83820 is not set
CONFIG_NET_VENDOR_8390=y
# CONFIG_PCMCIA_AXNET is not set
CONFIG_NE2K_PCI=y
# CONFIG_PCMCIA_PCNET is not set
CONFIG_NET_VENDOR_NVIDIA=y
CONFIG_FORCEDETH=y
CONFIG_NET_VENDOR_OKI=y
# CONFIG_PCH_GBE is not set
# CONFIG_ETHOC is not set
# CONFIG_NET_PACKET_ENGINE is not set
CONFIG_NET_VENDOR_QLOGIC=y
# CONFIG_QLA3XXX is not set
# CONFIG_QLCNIC is not set
# CONFIG_QLGE is not set
# CONFIG_NETXEN_NIC is not set
CONFIG_NET_VENDOR_REALTEK=y
CONFIG_8139CP=y
CONFIG_8139TOO=y
CONFIG_8139TOO_PIO=y
# CONFIG_8139TOO_TUNE_TWISTER is not set
# CONFIG_8139TOO_8129 is not set
# CONFIG_8139_OLD_RX_RESET is not set
CONFIG_R8169=y
# CONFIG_SH_ETH is not set
CONFIG_NET_VENDOR_RDC=y
# CONFIG_R6040 is not set
CONFIG_NET_VENDOR_SEEQ=y
CONFIG_NET_VENDOR_SILAN=y
# CONFIG_SC92031 is not set
CONFIG_NET_VENDOR_SIS=y
CONFIG_SIS900=y
# CONFIG_SIS190 is not set
# CONFIG_SFC is not set
CONFIG_NET_VENDOR_SMSC=y
# CONFIG_PCMCIA_SMC91C92 is not set
# CONFIG_EPIC100 is not set
# CONFIG_SMSC911X is not set
# CONFIG_SMSC9420 is not set
CONFIG_NET_VENDOR_STMICRO=y
# CONFIG_STMMAC_ETH is not set
CONFIG_NET_VENDOR_SUN=y
# CONFIG_HAPPYMEAL is not set
# CONFIG_SUNGEM is not set
# CONFIG_CASSINI is not set
# CONFIG_NIU is not set
CONFIG_NET_VENDOR_TEHUTI=y
# CONFIG_TEHUTI is not set
CONFIG_NET_VENDOR_TI=y
# CONFIG_TLAN is not set
CONFIG_NET_VENDOR_VIA=y
CONFIG_VIA_RHINE=y
# CONFIG_VIA_RHINE_MMIO is not set
CONFIG_VIA_VELOCITY=y
CONFIG_NET_VENDOR_WIZNET=y
# CONFIG_WIZNET_W5100 is not set
# CONFIG_WIZNET_W5300 is not set
CONFIG_NET_VENDOR_XIRCOM=y
# CONFIG_PCMCIA_XIRC2PS is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_NET_SB1000 is not set
CONFIG_PHYLIB=y

#
# MII PHY device drivers
#
# CONFIG_AT803X_PHY is not set
# CONFIG_AMD_PHY is not set
# CONFIG_MARVELL_PHY is not set
# CONFIG_DAVICOM_PHY is not set
# CONFIG_QSEMI_PHY is not set
# CONFIG_LXT_PHY is not set
# CONFIG_CICADA_PHY is not set
# CONFIG_VITESSE_PHY is not set
# CONFIG_SMSC_PHY is not set
CONFIG_BROADCOM_PHY=y
# CONFIG_BCM87XX_PHY is not set
# CONFIG_ICPLUS_PHY is not set
# CONFIG_REALTEK_PHY is not set
# CONFIG_NATIONAL_PHY is not set
# CONFIG_STE10XP is not set
# CONFIG_LSI_ET1011C_PHY is not set
# CONFIG_MICREL_PHY is not set
# CONFIG_FIXED_PHY is not set
# CONFIG_MDIO_BITBANG is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set

#
# USB Network Adapters
#
CONFIG_USB_CATC=y
CONFIG_USB_KAWETH=y
CONFIG_USB_PEGASUS=y
CONFIG_USB_RTL8150=y
# CONFIG_USB_RTL8152 is not set
CONFIG_USB_USBNET=y
CONFIG_USB_NET_AX8817X=y
CONFIG_USB_NET_AX88179_178A=y
CONFIG_USB_NET_CDCETHER=y
CONFIG_USB_NET_CDC_EEM=y
CONFIG_USB_NET_CDC_NCM=y
# CONFIG_USB_NET_CDC_MBIM is not set
CONFIG_USB_NET_DM9601=y
# CONFIG_USB_NET_SR9700 is not set
CONFIG_USB_NET_SMSC75XX=y
CONFIG_USB_NET_SMSC95XX=y
CONFIG_USB_NET_GL620A=y
CONFIG_USB_NET_NET1080=y
CONFIG_USB_NET_PLUSB=y
CONFIG_USB_NET_MCS7830=y
CONFIG_USB_NET_RNDIS_HOST=y
CONFIG_USB_NET_CDC_SUBSET=y
CONFIG_USB_ALI_M5632=y
CONFIG_USB_AN2720=y
CONFIG_USB_BELKIN=y
CONFIG_USB_ARMLINUX=y
CONFIG_USB_EPSON2888=y
CONFIG_USB_KC2190=y
CONFIG_USB_NET_ZAURUS=y
# CONFIG_USB_NET_CX82310_ETH is not set
# CONFIG_USB_NET_KALMIA is not set
# CONFIG_USB_NET_QMI_WWAN is not set
CONFIG_USB_NET_INT51X1=y
CONFIG_USB_IPHETH=y
CONFIG_USB_SIERRA_NET=y
# CONFIG_USB_VL600 is not set
CONFIG_WLAN=y
# CONFIG_PCMCIA_RAYCS is not set
# CONFIG_AIRO is not set
# CONFIG_ATMEL is not set
# CONFIG_AIRO_CS is not set
# CONFIG_PCMCIA_WL3501 is not set
# CONFIG_PRISM54 is not set
# CONFIG_USB_ZD1201 is not set
# CONFIG_HOSTAP is not set
# CONFIG_WL_TI is not set

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#
# CONFIG_WAN is not set
# CONFIG_VMXNET3 is not set
# CONFIG_ISDN is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=y
# CONFIG_INPUT_POLLDEV is not set
# CONFIG_INPUT_SPARSEKMAP is not set
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
# CONFIG_INPUT_JOYDEV is not set
CONFIG_INPUT_EVDEV=y
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5588 is not set
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
# CONFIG_KEYBOARD_QT2160 is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_TCA8418 is not set
# CONFIG_KEYBOARD_LM8333 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_XTKBD is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_CYPRESS=y
CONFIG_MOUSE_PS2_LIFEBOOK=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
# CONFIG_MOUSE_PS2_ELANTECH is not set
# CONFIG_MOUSE_PS2_SENTELIC is not set
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
CONFIG_MOUSE_SERIAL=y
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
# CONFIG_MOUSE_CYAPA is not set
# CONFIG_MOUSE_VSXXXAA is not set
# CONFIG_MOUSE_SYNAPTICS_I2C is not set
# CONFIG_MOUSE_SYNAPTICS_USB is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
CONFIG_INPUT_MISC=y
# CONFIG_INPUT_AD714X is not set
# CONFIG_INPUT_BMA150 is not set
# CONFIG_INPUT_PCSPKR is not set
# CONFIG_INPUT_MMA8450 is not set
# CONFIG_INPUT_MPU3050 is not set
# CONFIG_INPUT_ATLAS_BTNS is not set
# CONFIG_INPUT_ATI_REMOTE2 is not set
# CONFIG_INPUT_KEYSPAN_REMOTE is not set
# CONFIG_INPUT_KXTJ9 is not set
# CONFIG_INPUT_POWERMATE is not set
# CONFIG_INPUT_YEALINK is not set
# CONFIG_INPUT_CM109 is not set
# CONFIG_INPUT_UINPUT is not set
# CONFIG_INPUT_PCF8574 is not set
# CONFIG_INPUT_ADXL34X is not set
# CONFIG_INPUT_CMA3000 is not set
# CONFIG_INPUT_IDEAPAD_SLIDEBAR is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
# CONFIG_SERIO_ALTERA_PS2 is not set
# CONFIG_SERIO_PS2MULT is not set
# CONFIG_SERIO_ARC_PS2 is not set
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_TTY=y
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_VT_CONSOLE_SLEEP=y
CONFIG_HW_CONSOLE=y
CONFIG_VT_HW_CONSOLE_BINDING=y
CONFIG_UNIX98_PTYS=y
# CONFIG_DEVPTS_MULTIPLE_INSTANCES is not set
# CONFIG_LEGACY_PTYS is not set
CONFIG_SERIAL_NONSTANDARD=y
# CONFIG_ROCKETPORT is not set
# CONFIG_CYCLADES is not set
# CONFIG_MOXA_INTELLIO is not set
# CONFIG_MOXA_SMARTIO is not set
# CONFIG_SYNCLINK is not set
# CONFIG_SYNCLINKMP is not set
# CONFIG_SYNCLINK_GT is not set
# CONFIG_NOZOMI is not set
# CONFIG_ISI is not set
# CONFIG_N_HDLC is not set
# CONFIG_N_GSM is not set
# CONFIG_TRACE_SINK is not set
CONFIG_DEVKMEM=y

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
CONFIG_SERIAL_8250_NR_UARTS=32
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
CONFIG_SERIAL_8250_MANY_PORTS=y
CONFIG_SERIAL_8250_SHARE_IRQ=y
CONFIG_SERIAL_8250_DETECT_IRQ=y
CONFIG_SERIAL_8250_RSA=y
# CONFIG_SERIAL_8250_DW is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MFD_HSU is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
# CONFIG_SERIAL_SCCNXP is not set
# CONFIG_SERIAL_TIMBERDALE is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_PCH_UART is not set
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
# CONFIG_SERIAL_ST_ASC is not set
CONFIG_HVC_DRIVER=y
CONFIG_VIRTIO_CONSOLE=y
CONFIG_IPMI_HANDLER=m
# CONFIG_IPMI_PANIC_EVENT is not set
CONFIG_IPMI_DEVICE_INTERFACE=m
CONFIG_IPMI_SI=m
CONFIG_IPMI_WATCHDOG=m
CONFIG_IPMI_POWEROFF=m
CONFIG_HW_RANDOM=y
# CONFIG_HW_RANDOM_TIMERIOMEM is not set
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=y
CONFIG_HW_RANDOM_VIA=y
CONFIG_HW_RANDOM_VIRTIO=y
CONFIG_NVRAM=y
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set

#
# PCMCIA character devices
#
# CONFIG_SYNCLINK_CS is not set
# CONFIG_CARDMAN_4000 is not set
# CONFIG_CARDMAN_4040 is not set
# CONFIG_IPWIRELESS is not set
# CONFIG_MWAVE is not set
# CONFIG_RAW_DRIVER is not set
CONFIG_HPET=y
# CONFIG_HPET_MMAP is not set
# CONFIG_HANGCHECK_TIMER is not set
# CONFIG_TCG_TPM is not set
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
# CONFIG_I2C_CHARDEV is not set
# CONFIG_I2C_MUX is not set
CONFIG_I2C_HELPER_AUTO=y
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
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_EG20T is not set
# CONFIG_I2C_OCORES is not set
# CONFIG_I2C_PCA_PLATFORM is not set
# CONFIG_I2C_PXA_PCI is not set
# CONFIG_I2C_SIMTEC is not set
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_DIOLAN_U2C is not set
# CONFIG_I2C_PARPORT_LIGHT is not set
# CONFIG_I2C_TAOS_EVM is not set
# CONFIG_I2C_TINY_USB is not set

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_STUB is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set
# CONFIG_HSI is not set

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
# CONFIG_PPS_CLIENT_KTIMER is not set
# CONFIG_PPS_CLIENT_LDISC is not set
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
# CONFIG_PTP_1588_CLOCK_PCH is not set
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
CONFIG_GPIO_DEVRES=y
# CONFIG_GPIOLIB is not set
# CONFIG_W1 is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_DS2780 is not set
# CONFIG_BATTERY_DS2781 is not set
# CONFIG_BATTERY_DS2782 is not set
# CONFIG_BATTERY_SBS is not set
# CONFIG_BATTERY_BQ27x00 is not set
# CONFIG_BATTERY_MAX17040 is not set
# CONFIG_BATTERY_MAX17042 is not set
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_LP8727 is not set
# CONFIG_CHARGER_BQ2415X is not set
# CONFIG_CHARGER_SMB347 is not set
# CONFIG_POWER_RESET is not set
# CONFIG_POWER_AVS is not set
CONFIG_HWMON=y
# CONFIG_HWMON_VID is not set
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
# CONFIG_SENSORS_ABITUGURU is not set
# CONFIG_SENSORS_ABITUGURU3 is not set
# CONFIG_SENSORS_AD7414 is not set
# CONFIG_SENSORS_AD7418 is not set
# CONFIG_SENSORS_ADM1021 is not set
# CONFIG_SENSORS_ADM1025 is not set
# CONFIG_SENSORS_ADM1026 is not set
# CONFIG_SENSORS_ADM1029 is not set
# CONFIG_SENSORS_ADM1031 is not set
# CONFIG_SENSORS_ADM9240 is not set
# CONFIG_SENSORS_ADT7410 is not set
# CONFIG_SENSORS_ADT7411 is not set
# CONFIG_SENSORS_ADT7462 is not set
# CONFIG_SENSORS_ADT7470 is not set
# CONFIG_SENSORS_ADT7475 is not set
# CONFIG_SENSORS_ASC7621 is not set
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_FAM15H_POWER is not set
# CONFIG_SENSORS_ASB100 is not set
# CONFIG_SENSORS_ATXP1 is not set
# CONFIG_SENSORS_DS620 is not set
# CONFIG_SENSORS_DS1621 is not set
# CONFIG_SENSORS_I5K_AMB is not set
# CONFIG_SENSORS_F71805F is not set
# CONFIG_SENSORS_F71882FG is not set
# CONFIG_SENSORS_F75375S is not set
# CONFIG_SENSORS_FSCHMD is not set
# CONFIG_SENSORS_G760A is not set
# CONFIG_SENSORS_G762 is not set
# CONFIG_SENSORS_GL518SM is not set
# CONFIG_SENSORS_GL520SM is not set
# CONFIG_SENSORS_HIH6130 is not set
# CONFIG_SENSORS_HTU21 is not set
# CONFIG_SENSORS_CORETEMP is not set
# CONFIG_SENSORS_IBMAEM is not set
# CONFIG_SENSORS_IBMPEX is not set
# CONFIG_SENSORS_IT87 is not set
# CONFIG_SENSORS_JC42 is not set
# CONFIG_SENSORS_LINEAGE is not set
# CONFIG_SENSORS_LM63 is not set
# CONFIG_SENSORS_LM73 is not set
# CONFIG_SENSORS_LM75 is not set
# CONFIG_SENSORS_LM77 is not set
# CONFIG_SENSORS_LM78 is not set
# CONFIG_SENSORS_LM80 is not set
# CONFIG_SENSORS_LM83 is not set
# CONFIG_SENSORS_LM85 is not set
# CONFIG_SENSORS_LM87 is not set
# CONFIG_SENSORS_LM90 is not set
# CONFIG_SENSORS_LM92 is not set
# CONFIG_SENSORS_LM93 is not set
# CONFIG_SENSORS_LTC4151 is not set
# CONFIG_SENSORS_LTC4215 is not set
# CONFIG_SENSORS_LTC4245 is not set
# CONFIG_SENSORS_LTC4261 is not set
# CONFIG_SENSORS_LM95234 is not set
# CONFIG_SENSORS_LM95241 is not set
# CONFIG_SENSORS_LM95245 is not set
# CONFIG_SENSORS_MAX16065 is not set
# CONFIG_SENSORS_MAX1619 is not set
# CONFIG_SENSORS_MAX1668 is not set
# CONFIG_SENSORS_MAX197 is not set
# CONFIG_SENSORS_MAX6639 is not set
# CONFIG_SENSORS_MAX6642 is not set
# CONFIG_SENSORS_MAX6650 is not set
# CONFIG_SENSORS_MAX6697 is not set
# CONFIG_SENSORS_MCP3021 is not set
# CONFIG_SENSORS_NCT6775 is not set
# CONFIG_SENSORS_NTC_THERMISTOR is not set
# CONFIG_SENSORS_PC87360 is not set
# CONFIG_SENSORS_PC87427 is not set
# CONFIG_SENSORS_PCF8591 is not set
# CONFIG_PMBUS is not set
# CONFIG_SENSORS_SHT21 is not set
# CONFIG_SENSORS_SIS5595 is not set
# CONFIG_SENSORS_SMM665 is not set
# CONFIG_SENSORS_DME1737 is not set
# CONFIG_SENSORS_EMC1403 is not set
# CONFIG_SENSORS_EMC2103 is not set
# CONFIG_SENSORS_EMC6W201 is not set
# CONFIG_SENSORS_SMSC47M1 is not set
# CONFIG_SENSORS_SMSC47M192 is not set
# CONFIG_SENSORS_SMSC47B397 is not set
# CONFIG_SENSORS_SCH56XX_COMMON is not set
# CONFIG_SENSORS_SCH5627 is not set
# CONFIG_SENSORS_SCH5636 is not set
# CONFIG_SENSORS_ADS1015 is not set
# CONFIG_SENSORS_ADS7828 is not set
# CONFIG_SENSORS_AMC6821 is not set
# CONFIG_SENSORS_INA209 is not set
# CONFIG_SENSORS_INA2XX is not set
# CONFIG_SENSORS_THMC50 is not set
# CONFIG_SENSORS_TMP102 is not set
# CONFIG_SENSORS_TMP401 is not set
# CONFIG_SENSORS_TMP421 is not set
# CONFIG_SENSORS_VIA_CPUTEMP is not set
# CONFIG_SENSORS_VIA686A is not set
# CONFIG_SENSORS_VT1211 is not set
# CONFIG_SENSORS_VT8231 is not set
# CONFIG_SENSORS_W83781D is not set
# CONFIG_SENSORS_W83791D is not set
# CONFIG_SENSORS_W83792D is not set
# CONFIG_SENSORS_W83793 is not set
# CONFIG_SENSORS_W83795 is not set
# CONFIG_SENSORS_W83L785TS is not set
# CONFIG_SENSORS_W83L786NG is not set
# CONFIG_SENSORS_W83627HF is not set
# CONFIG_SENSORS_W83627EHF is not set
# CONFIG_SENSORS_APPLESMC is not set

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_GOV_STEP_WISE=y
CONFIG_THERMAL_GOV_USER_SPACE=y
# CONFIG_CPU_THERMAL is not set
# CONFIG_THERMAL_EMULATION is not set
# CONFIG_INTEL_POWERCLAMP is not set
CONFIG_X86_PKG_TEMP_THERMAL=m

#
# Texas Instruments thermal drivers
#
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
# CONFIG_WATCHDOG_NOWAYOUT is not set

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=y
# CONFIG_ACQUIRE_WDT is not set
# CONFIG_ADVANTECH_WDT is not set
# CONFIG_ALIM1535_WDT is not set
# CONFIG_ALIM7101_WDT is not set
# CONFIG_F71808E_WDT is not set
# CONFIG_SP5100_TCO is not set
# CONFIG_SC520_WDT is not set
# CONFIG_SBC_FITPC2_WATCHDOG is not set
# CONFIG_EUROTECH_WDT is not set
# CONFIG_IB700_WDT is not set
# CONFIG_IBMASR is not set
# CONFIG_WAFER_WDT is not set
CONFIG_I6300ESB_WDT=y
# CONFIG_IE6XX_WDT is not set
CONFIG_ITCO_WDT=y
CONFIG_ITCO_VENDOR_SUPPORT=y
# CONFIG_IT8712F_WDT is not set
# CONFIG_IT87_WDT is not set
# CONFIG_HP_WATCHDOG is not set
# CONFIG_SC1200_WDT is not set
# CONFIG_PC87413_WDT is not set
# CONFIG_NV_TCO is not set
# CONFIG_60XX_WDT is not set
# CONFIG_SBC8360_WDT is not set
# CONFIG_CPU5_WDT is not set
# CONFIG_SMSC_SCH311X_WDT is not set
# CONFIG_SMSC37B787_WDT is not set
# CONFIG_VIA_WDT is not set
# CONFIG_W83627HF_WDT is not set
# CONFIG_W83697HF_WDT is not set
# CONFIG_W83697UG_WDT is not set
# CONFIG_W83877F_WDT is not set
# CONFIG_W83977F_WDT is not set
# CONFIG_MACHZ_WDT is not set
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
# CONFIG_MFD_AS3711 is not set
# CONFIG_PMIC_ADP5520 is not set
# CONFIG_MFD_CROS_EC is not set
# CONFIG_PMIC_DA903X is not set
# CONFIG_MFD_DA9052_I2C is not set
# CONFIG_MFD_DA9055 is not set
# CONFIG_MFD_DA9063 is not set
# CONFIG_MFD_MC13XXX_I2C is not set
# CONFIG_HTC_PASIC3 is not set
CONFIG_LPC_ICH=y
# CONFIG_LPC_SCH is not set
# CONFIG_MFD_JANZ_CMODIO is not set
# CONFIG_MFD_KEMPLD is not set
# CONFIG_MFD_88PM800 is not set
# CONFIG_MFD_88PM805 is not set
# CONFIG_MFD_88PM860X is not set
# CONFIG_MFD_MAX77686 is not set
# CONFIG_MFD_MAX77693 is not set
# CONFIG_MFD_MAX8907 is not set
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
# CONFIG_MFD_MAX8998 is not set
# CONFIG_MFD_VIPERBOARD is not set
# CONFIG_MFD_RETU is not set
# CONFIG_MFD_PCF50633 is not set
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_RTSX_PCI is not set
# CONFIG_MFD_RC5T583 is not set
# CONFIG_MFD_SEC_CORE is not set
# CONFIG_MFD_SI476X_CORE is not set
# CONFIG_MFD_SM501 is not set
# CONFIG_MFD_SMSC is not set
# CONFIG_ABX500_CORE is not set
# CONFIG_MFD_STMPE is not set
# CONFIG_MFD_SYSCON is not set
# CONFIG_MFD_TI_AM335X_TSCADC is not set
# CONFIG_MFD_LP8788 is not set
# CONFIG_MFD_PALMAS is not set
# CONFIG_TPS6105X is not set
# CONFIG_TPS6507X is not set
# CONFIG_MFD_TPS65090 is not set
# CONFIG_MFD_TPS65217 is not set
# CONFIG_MFD_TPS6586X is not set
# CONFIG_MFD_TPS80031 is not set
# CONFIG_TWL4030_CORE is not set
# CONFIG_TWL6040_CORE is not set
# CONFIG_MFD_WL1273_CORE is not set
# CONFIG_MFD_LM3533 is not set
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_VX855 is not set
# CONFIG_MFD_ARIZONA_I2C is not set
# CONFIG_MFD_WM8400 is not set
# CONFIG_MFD_WM831X_I2C is not set
# CONFIG_MFD_WM8350_I2C is not set
# CONFIG_MFD_WM8994 is not set
# CONFIG_REGULATOR is not set
# CONFIG_MEDIA_SUPPORT is not set

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
# CONFIG_DRM is not set
# CONFIG_VGASTATE is not set
# CONFIG_VIDEO_OUTPUT_CONTROL is not set
# CONFIG_FB is not set
# CONFIG_EXYNOS_VIDEO is not set
# CONFIG_BACKLIGHT_LCD_SUPPORT is not set

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
CONFIG_VGACON_SOFT_SCROLLBACK=y
CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=64
CONFIG_DUMMY_CONSOLE=y
# CONFIG_SOUND is not set

#
# HID support
#
CONFIG_HID=y
CONFIG_HID_BATTERY_STRENGTH=y
# CONFIG_HIDRAW is not set
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
# CONFIG_HID_ACRUX is not set
CONFIG_HID_APPLE=y
# CONFIG_HID_APPLEIR is not set
# CONFIG_HID_AUREAL is not set
CONFIG_HID_BELKIN=y
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
CONFIG_HID_CYPRESS=y
CONFIG_HID_DRAGONRISE=y
# CONFIG_DRAGONRISE_FF is not set
# CONFIG_HID_EMS_FF is not set
# CONFIG_HID_ELECOM is not set
# CONFIG_HID_ELO is not set
CONFIG_HID_EZKEY=y
# CONFIG_HID_HOLTEK is not set
# CONFIG_HID_HUION is not set
# CONFIG_HID_KEYTOUCH is not set
CONFIG_HID_KYE=y
# CONFIG_HID_UCLOGIC is not set
# CONFIG_HID_WALTOP is not set
CONFIG_HID_GYRATION=y
# CONFIG_HID_ICADE is not set
CONFIG_HID_TWINHAN=y
CONFIG_HID_KENSINGTON=y
# CONFIG_HID_LCPOWER is not set
# CONFIG_HID_LENOVO_TPKBD is not set
CONFIG_HID_LOGITECH=y
CONFIG_HID_LOGITECH_DJ=m
CONFIG_LOGITECH_FF=y
# CONFIG_LOGIRUMBLEPAD2_FF is not set
# CONFIG_LOGIG940_FF is not set
CONFIG_LOGIWHEELS_FF=y
# CONFIG_HID_MAGICMOUSE is not set
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
# CONFIG_HID_MULTITOUCH is not set
CONFIG_HID_NTRIG=y
CONFIG_HID_ORTEK=y
CONFIG_HID_PANTHERLORD=y
# CONFIG_PANTHERLORD_FF is not set
CONFIG_HID_PETALYNX=y
# CONFIG_HID_PICOLCD is not set
# CONFIG_HID_PRIMAX is not set
# CONFIG_HID_ROCCAT is not set
# CONFIG_HID_SAITEK is not set
CONFIG_HID_SAMSUNG=y
# CONFIG_HID_SPEEDLINK is not set
# CONFIG_HID_STEELSERIES is not set
CONFIG_HID_SUNPLUS=y
CONFIG_HID_GREENASIA=y
# CONFIG_GREENASIA_FF is not set
CONFIG_HID_SMARTJOYPLUS=y
# CONFIG_SMARTJOYPLUS_FF is not set
# CONFIG_HID_TIVO is not set
CONFIG_HID_TOPSEED=y
CONFIG_HID_THRUSTMASTER=y
CONFIG_THRUSTMASTER_FF=y
# CONFIG_HID_XINMO is not set
CONFIG_HID_ZEROPLUS=y
# CONFIG_ZEROPLUS_FF is not set
# CONFIG_HID_ZYDACRON is not set
# CONFIG_HID_SENSOR_HUB is not set

#
# USB HID support
#
CONFIG_USB_HID=y
CONFIG_HID_PID=y
CONFIG_USB_HIDDEV=y

#
# I2C HID support
#
# CONFIG_I2C_HID is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
# CONFIG_USB_DEBUG is not set
# CONFIG_USB_ANNOUNCE_NEW_DEVICES is not set

#
# Miscellaneous USB options
#
CONFIG_USB_DEFAULT_PERSIST=y
# CONFIG_USB_DYNAMIC_MINORS is not set
# CONFIG_USB_OTG is not set
CONFIG_USB_MON=y
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
# CONFIG_USB_XHCI_HCD is not set
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
CONFIG_USB_EHCI_TT_NEWSCHED=y
CONFIG_USB_EHCI_PCI=y
# CONFIG_USB_EHCI_HCD_PLATFORM is not set
# CONFIG_USB_OXU210HP_HCD is not set
# CONFIG_USB_ISP116X_HCD is not set
# CONFIG_USB_ISP1760_HCD is not set
# CONFIG_USB_ISP1362_HCD is not set
# CONFIG_USB_FUSBH200_HCD is not set
# CONFIG_USB_FOTG210_HCD is not set
CONFIG_USB_OHCI_HCD=y
CONFIG_USB_OHCI_HCD_PCI=y
# CONFIG_USB_OHCI_HCD_PLATFORM is not set
CONFIG_USB_UHCI_HCD=y
# CONFIG_USB_SL811_HCD is not set
# CONFIG_USB_R8A66597_HCD is not set
# CONFIG_USB_HCD_TEST_MODE is not set

#
# USB Device Class drivers
#
# CONFIG_USB_ACM is not set
# CONFIG_USB_PRINTER is not set
# CONFIG_USB_WDM is not set
# CONFIG_USB_TMC is not set

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
CONFIG_USB_STORAGE=y
# CONFIG_USB_STORAGE_DEBUG is not set
# CONFIG_USB_STORAGE_REALTEK is not set
CONFIG_USB_STORAGE_DATAFAB=y
CONFIG_USB_STORAGE_FREECOM=y
CONFIG_USB_STORAGE_ISD200=y
CONFIG_USB_STORAGE_USBAT=y
CONFIG_USB_STORAGE_SDDR09=y
CONFIG_USB_STORAGE_SDDR55=y
CONFIG_USB_STORAGE_JUMPSHOT=y
CONFIG_USB_STORAGE_ALAUDA=y
# CONFIG_USB_STORAGE_ONETOUCH is not set
# CONFIG_USB_STORAGE_KARMA is not set
# CONFIG_USB_STORAGE_CYPRESS_ATACB is not set
# CONFIG_USB_STORAGE_ENE_UB6250 is not set

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
# CONFIG_USB_MICROTEK is not set
# CONFIG_USB_DWC3 is not set
# CONFIG_USB_CHIPIDEA is not set

#
# USB port drivers
#
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
# CONFIG_USB_EMI62 is not set
# CONFIG_USB_EMI26 is not set
# CONFIG_USB_ADUTUX is not set
# CONFIG_USB_SEVSEG is not set
# CONFIG_USB_RIO500 is not set
# CONFIG_USB_LEGOTOWER is not set
# CONFIG_USB_LCD is not set
# CONFIG_USB_LED is not set
# CONFIG_USB_CYPRESS_CY7C63 is not set
# CONFIG_USB_CYTHERM is not set
# CONFIG_USB_IDMOUSE is not set
# CONFIG_USB_FTDI_ELAN is not set
# CONFIG_USB_APPLEDISPLAY is not set
# CONFIG_USB_SISUSBVGA is not set
# CONFIG_USB_LD is not set
# CONFIG_USB_TRANCEVIBRATOR is not set
# CONFIG_USB_IOWARRIOR is not set
CONFIG_USB_TEST=y
# CONFIG_USB_EHSET_TEST_FIXTURE is not set
# CONFIG_USB_ISIGHTFW is not set
# CONFIG_USB_YUREX is not set
# CONFIG_USB_EZUSB_FX2 is not set
# CONFIG_USB_HSIC_USB3503 is not set

#
# USB Physical Layer drivers
#
# CONFIG_USB_PHY is not set
# CONFIG_NOP_USB_XCEIV is not set
# CONFIG_AM335X_PHY_USB is not set
# CONFIG_SAMSUNG_USB2PHY is not set
# CONFIG_SAMSUNG_USB3PHY is not set
# CONFIG_USB_ISP1301 is not set
# CONFIG_USB_RCAR_PHY is not set
# CONFIG_USB_GADGET is not set
# CONFIG_UWB is not set
# CONFIG_MMC is not set
# CONFIG_MEMSTICK is not set
# CONFIG_NEW_LEDS is not set
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
CONFIG_EDAC=y
CONFIG_EDAC_LEGACY_SYSFS=y
# CONFIG_EDAC_DEBUG is not set
CONFIG_EDAC_MM_EDAC=y
CONFIG_EDAC_GHES=y
CONFIG_EDAC_E752X=y
# CONFIG_EDAC_I82975X is not set
# CONFIG_EDAC_I3000 is not set
# CONFIG_EDAC_I3200 is not set
# CONFIG_EDAC_X38 is not set
# CONFIG_EDAC_I5400 is not set
# CONFIG_EDAC_I7CORE is not set
# CONFIG_EDAC_I5000 is not set
# CONFIG_EDAC_I5100 is not set
# CONFIG_EDAC_I7300 is not set
# CONFIG_EDAC_SBRIDGE is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
CONFIG_RTC_SYSTOHC=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
# CONFIG_RTC_DEBUG is not set

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
CONFIG_RTC_INTF_PROC=y
CONFIG_RTC_INTF_DEV=y
# CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#
# CONFIG_RTC_DRV_DS1307 is not set
# CONFIG_RTC_DRV_DS1374 is not set
# CONFIG_RTC_DRV_DS1672 is not set
# CONFIG_RTC_DRV_DS3232 is not set
# CONFIG_RTC_DRV_MAX6900 is not set
# CONFIG_RTC_DRV_RS5C372 is not set
# CONFIG_RTC_DRV_ISL1208 is not set
# CONFIG_RTC_DRV_ISL12022 is not set
# CONFIG_RTC_DRV_X1205 is not set
# CONFIG_RTC_DRV_PCF2127 is not set
# CONFIG_RTC_DRV_PCF8523 is not set
# CONFIG_RTC_DRV_PCF8563 is not set
# CONFIG_RTC_DRV_PCF8583 is not set
# CONFIG_RTC_DRV_M41T80 is not set
# CONFIG_RTC_DRV_BQ32K is not set
# CONFIG_RTC_DRV_S35390A is not set
# CONFIG_RTC_DRV_FM3130 is not set
# CONFIG_RTC_DRV_RX8581 is not set
# CONFIG_RTC_DRV_RX8025 is not set
# CONFIG_RTC_DRV_EM3027 is not set
# CONFIG_RTC_DRV_RV3029C2 is not set

#
# SPI RTC drivers
#

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
# CONFIG_RTC_DRV_DS1286 is not set
# CONFIG_RTC_DRV_DS1511 is not set
# CONFIG_RTC_DRV_DS1553 is not set
# CONFIG_RTC_DRV_DS1742 is not set
# CONFIG_RTC_DRV_STK17TA8 is not set
# CONFIG_RTC_DRV_M48T86 is not set
# CONFIG_RTC_DRV_M48T35 is not set
# CONFIG_RTC_DRV_M48T59 is not set
# CONFIG_RTC_DRV_MSM6242 is not set
# CONFIG_RTC_DRV_BQ4802 is not set
# CONFIG_RTC_DRV_RP5C01 is not set
# CONFIG_RTC_DRV_V3020 is not set
# CONFIG_RTC_DRV_DS2404 is not set

#
# on-CPU RTC drivers
#
# CONFIG_RTC_DRV_MOXART is not set

#
# HID Sensor RTC drivers
#
# CONFIG_RTC_DRV_HID_SENSOR_TIME is not set
# CONFIG_DMADEVICES is not set
# CONFIG_AUXDISPLAY is not set
# CONFIG_UIO is not set
# CONFIG_VIRT_DRIVERS is not set
CONFIG_VIRTIO=y

#
# Virtio drivers
#
CONFIG_VIRTIO_PCI=y
CONFIG_VIRTIO_BALLOON=y
CONFIG_VIRTIO_MMIO=y
# CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
# CONFIG_STAGING is not set
CONFIG_X86_PLATFORM_DEVICES=y
# CONFIG_ACERHDF is not set
# CONFIG_ASUS_LAPTOP is not set
# CONFIG_CHROMEOS_LAPTOP is not set
# CONFIG_FUJITSU_TABLET is not set
# CONFIG_HP_ACCEL is not set
# CONFIG_THINKPAD_ACPI is not set
# CONFIG_SENSORS_HDAPS is not set
# CONFIG_INTEL_MENLOW is not set
# CONFIG_EEEPC_LAPTOP is not set
# CONFIG_ACPI_WMI is not set
# CONFIG_TOPSTAR_LAPTOP is not set
# CONFIG_TOSHIBA_BT_RFKILL is not set
# CONFIG_ACPI_CMPC is not set
# CONFIG_INTEL_IPS is not set
# CONFIG_IBM_RTL is not set
# CONFIG_XO15_EBOOK is not set
# CONFIG_SAMSUNG_Q10 is not set
# CONFIG_INTEL_RST is not set
# CONFIG_INTEL_SMARTCONNECT is not set
# CONFIG_PVPANIC is not set

#
# Hardware Spinlock drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
# CONFIG_MAILBOX is not set
CONFIG_IOMMU_SUPPORT=y
# CONFIG_AMD_IOMMU is not set
# CONFIG_INTEL_IOMMU is not set
# CONFIG_IRQ_REMAP is not set

#
# Remoteproc drivers
#
# CONFIG_STE_MODEM_RPROC is not set

#
# Rpmsg drivers
#
# CONFIG_PM_DEVFREQ is not set
# CONFIG_EXTCON is not set
# CONFIG_MEMORY is not set
# CONFIG_IIO is not set
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set
# CONFIG_IPACK_BUS is not set
# CONFIG_RESET_CONTROLLER is not set
# CONFIG_FMC is not set

#
# Firmware Drivers
#
CONFIG_EDD=y
# CONFIG_EDD_OFF is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_DELL_RBU=y
CONFIG_DCDBAS=y
CONFIG_DMIID=y
# CONFIG_DMI_SYSFS is not set
# CONFIG_ISCSI_IBFT_FIND is not set
# CONFIG_GOOGLE_FIRMWARE is not set

#
# EFI (Extensible Firmware Interface) Support
#
# CONFIG_EFI_VARS is not set

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_EXT2_FS=y
CONFIG_EXT2_FS_XATTR=y
CONFIG_EXT2_FS_POSIX_ACL=y
CONFIG_EXT2_FS_SECURITY=y
CONFIG_EXT2_FS_XIP=y
CONFIG_EXT3_FS=y
# CONFIG_EXT3_DEFAULTS_TO_ORDERED is not set
CONFIG_EXT3_FS_XATTR=y
CONFIG_EXT3_FS_POSIX_ACL=y
CONFIG_EXT3_FS_SECURITY=y
CONFIG_EXT4_FS=y
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
# CONFIG_EXT4_DEBUG is not set
CONFIG_FS_XIP=y
CONFIG_JBD=y
# CONFIG_JBD_DEBUG is not set
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
CONFIG_REISERFS_FS=y
# CONFIG_REISERFS_CHECK is not set
CONFIG_REISERFS_PROC_INFO=y
CONFIG_REISERFS_FS_XATTR=y
CONFIG_REISERFS_FS_POSIX_ACL=y
CONFIG_REISERFS_FS_SECURITY=y
# CONFIG_JFS_FS is not set
CONFIG_XFS_FS=y
CONFIG_XFS_QUOTA=y
CONFIG_XFS_POSIX_ACL=y
CONFIG_XFS_RT=y
CONFIG_XFS_DEBUG=y
# CONFIG_GFS2_FS is not set
# CONFIG_OCFS2_FS is not set
CONFIG_BTRFS_FS=y
CONFIG_BTRFS_FS_POSIX_ACL=y
# CONFIG_BTRFS_FS_CHECK_INTEGRITY is not set
# CONFIG_BTRFS_FS_RUN_SANITY_TESTS is not set
# CONFIG_BTRFS_DEBUG is not set
# CONFIG_BTRFS_ASSERT is not set
# CONFIG_NILFS2_FS is not set
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
# CONFIG_FANOTIFY is not set
CONFIG_QUOTA=y
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
# CONFIG_PRINT_QUOTA_WARNING is not set
# CONFIG_QUOTA_DEBUG is not set
CONFIG_QUOTA_TREE=y
# CONFIG_QFMT_V1 is not set
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
CONFIG_AUTOFS4_FS=y
CONFIG_FUSE_FS=y
# CONFIG_CUSE is not set
CONFIG_GENERIC_ACL=y

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
CONFIG_UDF_FS=y
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="ascii"
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_TMPFS_XATTR=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
# CONFIG_ADFS_FS is not set
# CONFIG_AFFS_FS is not set
# CONFIG_ECRYPT_FS is not set
# CONFIG_HFS_FS is not set
# CONFIG_HFSPLUS_FS is not set
# CONFIG_BEFS_FS is not set
# CONFIG_BFS_FS is not set
# CONFIG_EFS_FS is not set
# CONFIG_LOGFS is not set
# CONFIG_CRAMFS is not set
# CONFIG_SQUASHFS is not set
# CONFIG_VXFS_FS is not set
# CONFIG_MINIX_FS is not set
# CONFIG_OMFS_FS is not set
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
# CONFIG_QNX6FS_FS is not set
CONFIG_ROMFS_FS=y
CONFIG_ROMFS_BACKED_BY_BLOCK=y
CONFIG_ROMFS_ON_BLOCK=y
CONFIG_PSTORE=y
# CONFIG_PSTORE_CONSOLE is not set
# CONFIG_PSTORE_FTRACE is not set
# CONFIG_PSTORE_RAM is not set
# CONFIG_SYSV_FS is not set
# CONFIG_UFS_FS is not set
# CONFIG_F2FS_FS is not set
# CONFIG_EFIVAR_FS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=y
CONFIG_NFS_V2=y
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
CONFIG_NFS_V4=y
# CONFIG_NFS_SWAP is not set
CONFIG_NFS_V4_1=y
# CONFIG_NFS_V4_2 is not set
CONFIG_PNFS_FILE_LAYOUT=m
CONFIG_PNFS_BLOCK=m
CONFIG_NFS_V4_1_IMPLEMENTATION_ID_DOMAIN="kernel.org"
CONFIG_ROOT_NFS=y
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
CONFIG_NFSD=y
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V3_ACL=y
CONFIG_NFSD_V4=y
# CONFIG_NFSD_FAULT_INJECTION is not set
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_ACL_SUPPORT=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=y
CONFIG_SUNRPC_BACKCHANNEL=y
CONFIG_RPCSEC_GSS_KRB5=y
# CONFIG_SUNRPC_DEBUG is not set
# CONFIG_CEPH_FS is not set
CONFIG_CIFS=y
# CONFIG_CIFS_STATS is not set
CONFIG_CIFS_WEAK_PW_HASH=y
# CONFIG_CIFS_UPCALL is not set
CONFIG_CIFS_XATTR=y
CONFIG_CIFS_POSIX=y
# CONFIG_CIFS_ACL is not set
CONFIG_CIFS_DEBUG=y
# CONFIG_CIFS_DEBUG2 is not set
# CONFIG_CIFS_DFS_UPCALL is not set
# CONFIG_CIFS_SMB2 is not set
# CONFIG_NCP_FS is not set
# CONFIG_CODA_FS is not set
# CONFIG_AFS_FS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="utf8"
CONFIG_NLS_CODEPAGE_437=y
# CONFIG_NLS_CODEPAGE_737 is not set
# CONFIG_NLS_CODEPAGE_775 is not set
# CONFIG_NLS_CODEPAGE_850 is not set
# CONFIG_NLS_CODEPAGE_852 is not set
# CONFIG_NLS_CODEPAGE_855 is not set
# CONFIG_NLS_CODEPAGE_857 is not set
# CONFIG_NLS_CODEPAGE_860 is not set
# CONFIG_NLS_CODEPAGE_861 is not set
# CONFIG_NLS_CODEPAGE_862 is not set
# CONFIG_NLS_CODEPAGE_863 is not set
# CONFIG_NLS_CODEPAGE_864 is not set
# CONFIG_NLS_CODEPAGE_865 is not set
# CONFIG_NLS_CODEPAGE_866 is not set
# CONFIG_NLS_CODEPAGE_869 is not set
# CONFIG_NLS_CODEPAGE_936 is not set
# CONFIG_NLS_CODEPAGE_950 is not set
# CONFIG_NLS_CODEPAGE_932 is not set
# CONFIG_NLS_CODEPAGE_949 is not set
# CONFIG_NLS_CODEPAGE_874 is not set
# CONFIG_NLS_ISO8859_8 is not set
# CONFIG_NLS_CODEPAGE_1250 is not set
# CONFIG_NLS_CODEPAGE_1251 is not set
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=y
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
# CONFIG_NLS_ISO8859_4 is not set
# CONFIG_NLS_ISO8859_5 is not set
# CONFIG_NLS_ISO8859_6 is not set
# CONFIG_NLS_ISO8859_7 is not set
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
# CONFIG_NLS_ISO8859_15 is not set
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
# CONFIG_NLS_MAC_ROMAN is not set
# CONFIG_NLS_MAC_CELTIC is not set
# CONFIG_NLS_MAC_CENTEURO is not set
# CONFIG_NLS_MAC_CROATIAN is not set
# CONFIG_NLS_MAC_CYRILLIC is not set
# CONFIG_NLS_MAC_GAELIC is not set
# CONFIG_NLS_MAC_GREEK is not set
# CONFIG_NLS_MAC_ICELAND is not set
# CONFIG_NLS_MAC_INUIT is not set
# CONFIG_NLS_MAC_ROMANIAN is not set
# CONFIG_NLS_MAC_TURKISH is not set
CONFIG_NLS_UTF8=y
# CONFIG_DLM is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
# CONFIG_BOOT_PRINTK_DELAY is not set
CONFIG_DYNAMIC_DEBUG=y

#
# Compile-time checks and compiler options
#
# CONFIG_DEBUG_INFO is not set
CONFIG_ENABLE_WARN_DEPRECATED=y
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=2048
# CONFIG_STRIP_ASM_SYMS is not set
# CONFIG_READABLE_ASM is not set
# CONFIG_UNUSED_SYMBOLS is not set
CONFIG_DEBUG_FS=y
# CONFIG_HEADERS_CHECK is not set
CONFIG_DEBUG_SECTION_MISMATCH=y
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
CONFIG_MAGIC_SYSRQ=y
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
# CONFIG_DEBUG_PAGEALLOC is not set
# CONFIG_DEBUG_OBJECTS is not set
# CONFIG_SLUB_DEBUG_ON is not set
# CONFIG_SLUB_STATS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_STACK_USAGE is not set
# CONFIG_DEBUG_VM is not set
# CONFIG_DEBUG_VIRTUAL is not set
CONFIG_DEBUG_MEMORY_INIT=y
# CONFIG_DEBUG_PER_CPU_MAPS is not set
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
# CONFIG_DEBUG_STACKOVERFLOW is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_DEBUG_SHIRQ is not set

#
# Debug Lockups and Hangs
#
# CONFIG_LOCKUP_DETECTOR is not set
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
# CONFIG_BOOTPARAM_HUNG_TASK_PANIC is not set
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=0
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_SCHED_DEBUG=y
CONFIG_SCHEDSTATS=y
CONFIG_TIMER_STATS=y

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_RT_MUTEX_TESTER is not set
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
CONFIG_DEBUG_LOCK_ALLOC=y
# CONFIG_PROVE_LOCKING is not set
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
# CONFIG_DEBUG_KOBJECT_RELEASE is not set
CONFIG_DEBUG_BUGVERBOSE=y
# CONFIG_DEBUG_WRITECOUNT is not set
# CONFIG_DEBUG_LIST is not set
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
CONFIG_SPARSE_RCU_POINTER=y
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=60
# CONFIG_RCU_CPU_STALL_INFO is not set
# CONFIG_RCU_TRACE is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
# CONFIG_FAULT_INJECTION is not set
CONFIG_LATENCYTOP=y
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
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
CONFIG_TRACER_MAX_TRACE=y
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_EVENT_TRACING=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
CONFIG_FUNCTION_TRACER=y
CONFIG_FUNCTION_GRAPH_TRACER=y
CONFIG_IRQSOFF_TRACER=y
CONFIG_SCHED_TRACER=y
CONFIG_FTRACE_SYSCALLS=y
CONFIG_TRACER_SNAPSHOT=y
CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP=y
CONFIG_BRANCH_PROFILE_NONE=y
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
# CONFIG_PROFILE_ALL_BRANCHES is not set
# CONFIG_STACK_TRACER is not set
CONFIG_BLK_DEV_IO_TRACE=y
CONFIG_KPROBE_EVENT=y
CONFIG_UPROBE_EVENT=y
CONFIG_PROBE_EVENTS=y
CONFIG_DYNAMIC_FTRACE=y
CONFIG_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_FUNCTION_PROFILER=y
CONFIG_FTRACE_MCOUNT_RECORD=y
# CONFIG_FTRACE_STARTUP_TEST is not set
CONFIG_MMIOTRACE=y
# CONFIG_MMIOTRACE_TEST is not set
# CONFIG_RING_BUFFER_BENCHMARK is not set
# CONFIG_RING_BUFFER_STARTUP_TEST is not set

#
# Runtime Testing
#
CONFIG_LKDTM=y
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_KPROBES_SANITY_TEST is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_RBTREE_TEST is not set
# CONFIG_INTERVAL_TREE_TEST is not set
CONFIG_ATOMIC64_SELFTEST=y
# CONFIG_ASYNC_RAID6_TEST is not set
# CONFIG_TEST_STRING_HELPERS is not set
# CONFIG_TEST_KSTRTOX is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
CONFIG_DMA_API_DEBUG=y
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
# CONFIG_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
# CONFIG_X86_PTDUMP is not set
CONFIG_DEBUG_RODATA=y
CONFIG_DEBUG_RODATA_TEST=y
# CONFIG_DEBUG_SET_MODULE_RONX is not set
# CONFIG_DEBUG_NX_TEST is not set
CONFIG_DOUBLEFAULT=y
# CONFIG_DEBUG_TLBFLUSH is not set
# CONFIG_IOMMU_DEBUG is not set
# CONFIG_IOMMU_STRESS is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
# CONFIG_X86_DECODER_SELFTEST is not set
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
CONFIG_IO_DELAY_0X80=y
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=0
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
# CONFIG_OPTIMIZE_INLINING is not set
# CONFIG_DEBUG_NMI_SELFTEST is not set
# CONFIG_X86_DEBUG_STATIC_CPU_HAS is not set

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_ENCRYPTED_KEYS is not set
# CONFIG_KEYS_DEBUG_PROC_KEYS is not set
# CONFIG_SECURITY_DMESG_RESTRICT is not set
# CONFIG_SECURITY is not set
# CONFIG_SECURITYFS is not set
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
CONFIG_CRYPTO_PCOMP=y
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_PCRYPT=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_TEST=m
CONFIG_CRYPTO_ABLK_HELPER_X86=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
CONFIG_CRYPTO_GCM=y
CONFIG_CRYPTO_SEQIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
CONFIG_CRYPTO_PCBC=y
CONFIG_CRYPTO_XTS=y

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=y
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
CONFIG_CRYPTO_CRCT10DIF=y
# CONFIG_CRYPTO_CRCT10DIF_PCLMUL is not set
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
CONFIG_CRYPTO_RMD128=y
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=y
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=y
# CONFIG_CRYPTO_SHA256_SSSE3 is not set
# CONFIG_CRYPTO_SHA512_SSSE3 is not set
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_TGR192=y
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
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
# CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64 is not set
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
# CONFIG_CRYPTO_SERPENT_AVX2_X86_64 is not set
CONFIG_CRYPTO_TEA=y
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=y

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_ZLIB=y
CONFIG_CRYPTO_LZO=y
# CONFIG_CRYPTO_LZ4 is not set
# CONFIG_CRYPTO_LZ4HC is not set

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_USER_API=y
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_USER_API_SKCIPHER=y
CONFIG_CRYPTO_HW=y
# CONFIG_CRYPTO_DEV_PADLOCK is not set
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
CONFIG_PUBLIC_KEY_ALGO_RSA=y
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
# CONFIG_KVM_MMU_AUDIT is not set
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_RAID6_PQ=y
CONFIG_BITREVERSE=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_PERCPU_RWSEM=y
CONFIG_ARCH_USE_CMPXCHG_LOCKREF=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
# CONFIG_CRC7 is not set
CONFIG_LIBCRC32C=y
# CONFIG_CRC8 is not set
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
CONFIG_XZ_DEC_IA64=y
CONFIG_XZ_DEC_ARM=y
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
# CONFIG_XZ_DEC_TEST is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
# CONFIG_AVERAGE is not set
CONFIG_CLZ_TAB=y
# CONFIG_CORDIC is not set
# CONFIG_DDR is not set
CONFIG_MPILIB=y
CONFIG_OID_REGISTRY=y
CONFIG_UCS2_STRING=y

--3MwIy2ne0vdjdPXF
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--3MwIy2ne0vdjdPXF--
