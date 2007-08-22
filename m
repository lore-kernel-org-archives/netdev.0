From: Andrew Morton <akpm@linux-foundation.org>
Subject: net-2.6.24 failure with netconsole
Date: Tue, 21 Aug 2007 22:54:38 -0700
Message-ID: <20070821225438.9493f44c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:47147 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753990AbXHVFyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 01:54:52 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Has anyone tested all this new napi stuff with netconsole?  It's pretty
disastrous.  It immediately goes BUG in napi_enable().

David, there's basically no reason ever why anyone should add BUG() or
BUG_ON() to net code.  Please consider rejecting any patches which add new
ones.  WARN_ON() is *much* better.  It at least gives the user a chance of
getting some disgnostic info out, of performing additional tests or even of
using their kernel if they want to test something else.  The only reason to
choose BUG over WARN is if we're actually concerned about scrogging
people's data, or serious things like that (ie: filesystems and mm).


I did this:

--- a/include/linux/netdevice.h~a
+++ a/include/linux/netdevice.h
@@ -328,7 +328,7 @@ static inline void napi_disable(struct n
 
 static inline void napi_enable(struct napi_struct *n)
 {
-	BUG_ON(!test_bit(NAPI_STATE_SCHED, &n->state));
+	WARN_ON(!test_bit(NAPI_STATE_SCHED, &n->state));
 	smp_mb__before_clear_bit();
 	clear_bit(NAPI_STATE_SCHED, &n->state);
 }
_

Which enabled me to see this, via netconsole:

netconsole: local port 4444
netconsole: local IP 192.168.2.36
netconsole: interface eth0
netconsole: remote port 5140
netconsole: remote IP 192.168.2.33
netconsole: remote ethernet address 00:0d:56:c6:c6:cc
netconsole: device eth0 not up yet, forcing it
WARNING: at include/linux/netdevice.h:331 napi_enable()
 [<c0103bfa>] show_trace_log_lvl+0x1a/0x30
 [<c0104822>] show_trace+0x12/0x20
 [<c0104846>] dump_stack+0x16/0x20
 [<c02e3989>] e100_up+0x159/0x160
 [<c02e39ae>] e100_open+0x1e/0x60
 [<c0354bb8>] dev_open+0x38/0x80
 [<c03605eb>] netpoll_setup+0x15b/0x390
 [<c051d754>] init_netconsole+0xf4/0x1d0
 [<c05045f2>] kernel_init+0x142/0x320
 [<c0103807>] kernel_thread_helper+0x7/0x10

Which used to be a BUG.  It later oopsed via a null-pointer deref in
net_rx_action(), which is a much preferable result.


config is at http://userweb.kernel.org/~akpm/config-vmm.txt, full dmesg is
below.

This of course renders net-2.6.24 unusable so I'll drop it for now.  Please
let me know when it's safe to use again, thanks.



BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
 BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 0000000038000000 (usable)
 BIOS-e820: 00000000fec00000 - 00000000fec01000 (reserved)
 BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
 BIOS-e820: 00000000fffc0000 - 0000000100000000 (reserved)
0MB HIGHMEM available.
896MB LOWMEM available.
found SMP MP-table at 000fb4c0
Entering add_active_range(0, 0, 229376) 0 entries of 256 used
Zone PFN ranges:
  DMA             0 ->     4096
  Normal       4096 ->   229376
  HighMem    229376 ->   229376
Movable zone start PFN for each node
early_node_map[1] active PFN ranges
    0:        0 ->   229376
On node 0 totalpages: 229376
  DMA zone: 52 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 4044 pages, LIFO batch:0
  Normal zone: 2860 pages used for memmap
  Normal zone: 222420 pages, LIFO batch:31
  HighMem zone: 0 pages used for memmap
  Movable zone: 0 pages used for memmap
DMI 2.1 present.
Intel MultiProcessor Specification v1.4
    Virtual Wire compatibility mode.
OEM ID: INTEL    Product ID: 440BX        APIC at: 0xFEE00000
Processor #0 6:8 APIC version 17
Processor #1 6:8 APIC version 17
I/O APIC #2 Version 17 at 0xFEC00000.
Enabling APIC mode:  Flat.  Using 1 I/O APICs
Processors: 2
Allocating PCI resources starting at 40000000 (gap: 38000000:c6c00000)
Built 1 zonelists in Zone order.  Total pages: 226464
Kernel command line: auto BOOT_IMAGE=d ro root=1602 BOOT_FILE=/boot/bzImage-2.6.23-rc3 profile=1 nmi_watchdog=1 netconsole=4444@192.168.2.36/eth0,5140@192.168.2.33/00:0D:56:C6:C6:CC resume=/dev/hdc3 initcall_debug ignore_loglevel
kernel profiling enabled (shift: 1)
debug: ignoring loglevel setting.
mapped APIC to ffffb000 (fee00000)
mapped IOAPIC to ffffa000 (fec00000)
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Initializing CPU#0
PID hash table entries: 4096 (order: 12, 16384 bytes)
Detected 851.936 MHz processor.
Console: colour VGA+ 80x50
console [tty0] enabled
Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
... MAX_LOCKDEP_SUBCLASSES:    8
... MAX_LOCK_DEPTH:          30
... MAX_LOCKDEP_KEYS:        2048
... CLASSHASH_SIZE:           1024
... MAX_LOCKDEP_ENTRIES:     8192
... MAX_LOCKDEP_CHAINS:      16384
... CHAINHASH_SIZE:          8192
 memory used by lock dependency info: 992 kB
 per task-struct memory footprint: 1200 bytes
------------------------
| Locking API testsuite:
----------------------------------------------------------------------------
                                 | spin |wlock |rlock |mutex | wsem | rsem |
  --------------------------------------------------------------------------
                     A-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
                 A-B-B-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
             A-B-B-C-C-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
             A-B-C-A-B-C deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
         A-B-B-C-C-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
         A-B-C-D-B-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
         A-B-C-D-B-C-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
                    double unlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
                  initialize held:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
                 bad unlock order:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
  --------------------------------------------------------------------------
              recursive read-lock:             |  ok  |             |  ok  |
           recursive read-lock #2:             |  ok  |             |  ok  |
            mixed read-write-lock:             |  ok  |             |  ok  |
            mixed write-read-lock:             |  ok  |             |  ok  |
  --------------------------------------------------------------------------
     hard-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
     soft-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
     hard-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
     soft-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
       sirq-safe-A => hirqs-on/12:  ok  |  ok  |  ok  |
       sirq-safe-A => hirqs-on/21:  ok  |  ok  |  ok  |
         hard-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
         soft-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
         hard-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
         soft-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
      hard-irq lock-inversion/123:  ok  |  ok  |  ok  |
      soft-irq lock-inversion/123:  ok  |  ok  |  ok  |
      hard-irq lock-inversion/132:  ok  |  ok  |  ok  |
      soft-irq lock-inversion/132:  ok  |  ok  |  ok  |
      hard-irq lock-inversion/213:  ok  |  ok  |  ok  |
      soft-irq lock-inversion/213:  ok  |  ok  |  ok  |
      hard-irq lock-inversion/231:  ok  |  ok  |  ok  |
      soft-irq lock-inversion/231:  ok  |  ok  |  ok  |
      hard-irq lock-inversion/312:  ok  |  ok  |  ok  |
      soft-irq lock-inversion/312:  ok  |  ok  |  ok  |
      hard-irq lock-inversion/321:  ok  |  ok  |  ok  |
      soft-irq lock-inversion/321:  ok  |  ok  |  ok  |
      hard-irq read-recursion/123:  ok  |
      soft-irq read-recursion/123:  ok  |
      hard-irq read-recursion/132:  ok  |
      soft-irq read-recursion/132:  ok  |
      hard-irq read-recursion/213:  ok  |
      soft-irq read-recursion/213:  ok  |
      hard-irq read-recursion/231:  ok  |
      soft-irq read-recursion/231:  ok  |
      hard-irq read-recursion/312:  ok  |
      soft-irq read-recursion/312:  ok  |
      hard-irq read-recursion/321:  ok  |
      soft-irq read-recursion/321:  ok  |
-------------------------------------------------------
Good, all 218 testcases passed! |
---------------------------------
Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
Memory: 891620k/917504k available (2891k kernel code, 25392k reserved, 1189k data, 296k init, 0k highmem)
virtual kernel memory layout:
    fixmap  : 0xffee2000 - 0xfffff000   (1140 kB)
    pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
    vmalloc : 0xf8800000 - 0xff7fe000   ( 111 MB)
    lowmem  : 0xc0000000 - 0xf8000000   ( 896 MB)
      .init : 0xc0504000 - 0xc054e000   ( 296 kB)
      .data : 0xc03d2e5f - 0xc04fc624   (1189 kB)
      .text : 0xc0100000 - 0xc03d2e5f   (2891 kB)
Checking if this processor honours the WP bit even in supervisor mode... Ok.
Calibrating delay using timer specific routine.. 1706.80 BogoMIPS (lpj=3413611)
Mount-cache hash table entries: 512
CPU: After generic identify, caps: 0383fbff 00000000 00000000 00000000 00000000 00000000 00000000 00000000
CPU: L1 I cache: 16K, L1 D cache: 16K
CPU: L2 cache: 256K
CPU: After all inits, caps: 0383fbff 00000000 00000000 00000040 00000000 00000000 00000000 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#0.
Compat vDSO mapped to ffffe000.
Checking 'hlt' instruction... OK.
lockdep: not fixing up alternatives.
CPU0: Intel Pentium III (Coppermine) stepping 03
lockdep: not fixing up alternatives.
Booting processor 1/1 eip 2000
Initializing CPU#1
Calibrating delay using timer specific routine.. 1704.06 BogoMIPS (lpj=3408125)
CPU: After generic identify, caps: 0383fbff 00000000 00000000 00000000 00000000 00000000 00000000 00000000
CPU: L1 I cache: 16K, L1 D cache: 16K
CPU: L2 cache: 256K
CPU: After all inits, caps: 0383fbff 00000000 00000000 00000040 00000000 00000000 00000000 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#1.
CPU1: Intel Pentium III (Coppermine) stepping 03
Total of 2 processors activated (3410.86 BogoMIPS).
ExtINT not setup in hardware but reported by MP table
ENABLING IO-APIC IRQs
..TIMER: vector=0x31 apic1=0 pin1=2 apic2=0 pin2=0
APIC timer registered as dummy, due to nmi_watchdog=1!
checking TSC synchronization [CPU#0 -> CPU#1]: passed.
Brought up 2 CPUs
khelper used greatest stack depth: 7184 bytes left
Calling initcall 0xc051fba0: init_cpufreq_transition_notifier_list+0x0/0x20()
initcall 0xc051fba0: init_cpufreq_transition_notifier_list+0x0/0x20() returned 0.
initcall 0xc051fba0 ran for 0 msecs: init_cpufreq_transition_notifier_list+0x0/0x20()
Calling initcall 0xc050c480: cpufreq_tsc+0x0/0x20()
initcall 0xc050c480: cpufreq_tsc+0x0/0x20() returned 0.
initcall 0xc050c480 ran for 0 msecs: cpufreq_tsc+0x0/0x20()
Calling initcall 0xc050cc70: reboot_init+0x0/0x20()
initcall 0xc050cc70: reboot_init+0x0/0x20() returned 0.
initcall 0xc050cc70 ran for 0 msecs: reboot_init+0x0/0x20()
Calling initcall 0xc0512a90: sysctl_init+0x0/0x20()
initcall 0xc0512a90: sysctl_init+0x0/0x20() returned 0.
initcall 0xc0512a90 ran for 0 msecs: sysctl_init+0x0/0x20()
Calling initcall 0xc0513410: init_jiffies_clocksource+0x0/0x10()
initcall 0xc0513410: init_jiffies_clocksource+0x0/0x10() returned 0.
initcall 0xc0513410 ran for 0 msecs: init_jiffies_clocksource+0x0/0x10()
Calling initcall 0xc05136c0: pm_init+0x0/0x30()
initcall 0xc05136c0: pm_init+0x0/0x30() returned 0.
initcall 0xc05136c0 ran for 0 msecs: pm_init+0x0/0x30()
Calling initcall 0xc0513960: ksysfs_init+0x0/0x50()
initcall 0xc0513960: ksysfs_init+0x0/0x50() returned 0.
initcall 0xc0513960 ran for 0 msecs: ksysfs_init+0x0/0x50()
Calling initcall 0xc05163c0: filelock_init+0x0/0x30()
initcall 0xc05163c0: filelock_init+0x0/0x30() returned 0.
initcall 0xc05163c0 ran for 0 msecs: filelock_init+0x0/0x30()
Calling initcall 0xc0516ec0: init_aout_binfmt+0x0/0x10()
initcall 0xc0516ec0: init_aout_binfmt+0x0/0x10() returned 0.
initcall 0xc0516ec0 ran for 0 msecs: init_aout_binfmt+0x0/0x10()
Calling initcall 0xc0516ed0: init_misc_binfmt+0x0/0x40()
initcall 0xc0516ed0: init_misc_binfmt+0x0/0x40() returned 0.
initcall 0xc0516ed0 ran for 0 msecs: init_misc_binfmt+0x0/0x40()
Calling initcall 0xc0516f10: init_script_binfmt+0x0/0x10()
initcall 0xc0516f10: init_script_binfmt+0x0/0x10() returned 0.
initcall 0xc0516f10 ran for 0 msecs: init_script_binfmt+0x0/0x10()
Calling initcall 0xc0516f20: init_elf_binfmt+0x0/0x10()
initcall 0xc0516f20: init_elf_binfmt+0x0/0x10() returned 0.
initcall 0xc0516f20 ran for 0 msecs: init_elf_binfmt+0x0/0x10()
Calling initcall 0xc0517e70: debugfs_init+0x0/0x50()
initcall 0xc0517e70: debugfs_init+0x0/0x50() returned 0.
initcall 0xc0517e70 ran for 0 msecs: debugfs_init+0x0/0x50()
Calling initcall 0xc0518690: random32_init+0x0/0x60()
initcall 0xc0518690: random32_init+0x0/0x60() returned 0.
initcall 0xc0518690 ran for 0 msecs: random32_init+0x0/0x60()
Calling initcall 0xc051fb20: cpufreq_core_init+0x0/0x80()
initcall 0xc051fb20: cpufreq_core_init+0x0/0x80() returned 0.
initcall 0xc051fb20 ran for 0 msecs: cpufreq_core_init+0x0/0x80()
Calling initcall 0xc0521d50: sock_init+0x0/0x60()
initcall 0xc0521d50: sock_init+0x0/0x60() returned 0.
initcall 0xc0521d50 ran for 0 msecs: sock_init+0x0/0x60()
Calling initcall 0xc05224d0: netpoll_init+0x0/0x40()
initcall 0xc05224d0: netpoll_init+0x0/0x40() returned 0.
initcall 0xc05224d0 ran for 0 msecs: netpoll_init+0x0/0x40()
Calling initcall 0xc05225c0: netlink_proto_init+0x0/0x160()
NET: Registered protocol family 16
initcall 0xc05225c0: netlink_proto_init+0x0/0x160() returned 0.
initcall 0xc05225c0 ran for 0 msecs: netlink_proto_init+0x0/0x160()
Calling initcall 0xc0518520: kobject_uevent_init+0x0/0x50()
initcall 0xc0518520: kobject_uevent_init+0x0/0x50() returned 0.
initcall 0xc0518520 ran for 0 msecs: kobject_uevent_init+0x0/0x50()
Calling initcall 0xc05187c0: pcibus_class_init+0x0/0x10()
initcall 0xc05187c0: pcibus_class_init+0x0/0x10() returned 0.
initcall 0xc05187c0 ran for 0 msecs: pcibus_class_init+0x0/0x10()
Calling initcall 0xc0518e10: pci_driver_init+0x0/0x10()
initcall 0xc0518e10: pci_driver_init+0x0/0x10() returned 0.
initcall 0xc0518e10 ran for 3 msecs: pci_driver_init+0x0/0x10()
Calling initcall 0xc051ab60: tty_class_init+0x0/0x30()
initcall 0xc051ab60: tty_class_init+0x0/0x30() returned 0.
initcall 0xc051ab60 ran for 0 msecs: tty_class_init+0x0/0x30()
Calling initcall 0xc051b500: vtconsole_class_init+0x0/0xe0()
initcall 0xc051b500: vtconsole_class_init+0x0/0xe0() returned 0.
initcall 0xc051b500 ran for 0 msecs: vtconsole_class_init+0x0/0xe0()
Calling initcall 0xc051f2a0: eisa_init+0x0/0x30()
EISA bus registered
initcall 0xc051f2a0: eisa_init+0x0/0x30() returned 0.
initcall 0xc051f2a0 ran for 0 msecs: eisa_init+0x0/0x30()
Calling initcall 0xc050c340: init_pit_clocksource+0x0/0x90()
initcall 0xc050c340: init_pit_clocksource+0x0/0x90() returned 0.
initcall 0xc050c340 ran for 0 msecs: init_pit_clocksource+0x0/0x90()
Calling initcall 0xc0520660: dmi_id_init+0x0/0x290()
initcall 0xc0520660: dmi_id_init+0x0/0x290() returned 0.
initcall 0xc0520660 ran for 3 msecs: dmi_id_init+0x0/0x290()
Calling initcall 0xc0520c00: pci_access_init+0x0/0x50()
PCI: PCI BIOS revision 2.10 entry at 0xfdb81, last bus=1
PCI: Using configuration type 1
initcall 0xc0520c00: pci_access_init+0x0/0x50() returned 0.
initcall 0xc0520c00 ran for 53 msecs: pci_access_init+0x0/0x50()
Calling initcall 0xc050bd00: request_standard_resources+0x0/0x390()
Setting up standard PCI resources
initcall 0xc050bd00: request_standard_resources+0x0/0x390() returned 0.
initcall 0xc050bd00 ran for 7 msecs: request_standard_resources+0x0/0x390()
Calling initcall 0xc050c160: topology_init+0x0/0x40()
initcall 0xc050c160: topology_init+0x0/0x40() returned 0.
initcall 0xc050c160 ran for 3 msecs: topology_init+0x0/0x40()
Calling initcall 0xc0512e60: param_sysfs_init+0x0/0x180()
khelper used greatest stack depth: 7068 bytes left
initcall 0xc0512e60: param_sysfs_init+0x0/0x180() returned 0.
initcall 0xc0512e60 ran for 11 msecs: param_sysfs_init+0x0/0x180()
Calling initcall 0xc014a1b0: pm_sysrq_init+0x0/0x20()
initcall 0xc014a1b0: pm_sysrq_init+0x0/0x20() returned 0.
initcall 0xc014a1b0 ran for 0 msecs: pm_sysrq_init+0x0/0x20()
Calling initcall 0xc0516b20: init_bio+0x0/0xc0()
initcall 0xc0516b20: init_bio+0x0/0xc0() returned 0.
initcall 0xc0516b20 ran for 3 msecs: init_bio+0x0/0xc0()
Calling initcall 0xc0518230: genhd_device_init+0x0/0x60()
initcall 0xc0518230: genhd_device_init+0x0/0x60() returned 0.
initcall 0xc0518230 ran for 0 msecs: genhd_device_init+0x0/0x60()
Calling initcall 0xc0518fe0: pnp_init+0x0/0x20()
Linux Plug and Play Support v0.97 (c) Adam Belay
initcall 0xc0518fe0: pnp_init+0x0/0x20() returned 0.
initcall 0xc0518fe0 ran for 0 msecs: pnp_init+0x0/0x20()
Calling initcall 0xc0519170: pnpbios_init+0x0/0x3a0()
PnPBIOS: Scanning system for PnP BIOS support...
PnPBIOS: Found PnP BIOS installation structure at 0xc00f7150
PnPBIOS: PnP BIOS version 1.0, entry 0xf0000:0x6aa4, dseg 0xf0000
PnPBIOS: 15 nodes reported by PnP BIOS; 15 recorded by driver
initcall 0xc0519170: pnpbios_init+0x0/0x3a0() returned 0.
initcall 0xc0519170 ran for 7 msecs: pnpbios_init+0x0/0x3a0()
Calling initcall 0xc051afb0: misc_init+0x0/0x80()
initcall 0xc051afb0: misc_init+0x0/0x80() returned 0.
initcall 0xc051afb0 ran for 3 msecs: misc_init+0x0/0x80()
Calling initcall 0xc02c9690: cn_init+0x0/0xd0()
initcall 0xc02c9690: cn_init+0x0/0xd0() returned 0.
initcall 0xc02c9690 ran for 0 msecs: cn_init+0x0/0xd0()
Calling initcall 0xc051e280: init_scsi+0x0/0xb0()
SCSI subsystem initialized
initcall 0xc051e280: init_scsi+0x0/0xb0() returned 0.
initcall 0xc051e280 ran for 3 msecs: init_scsi+0x0/0xb0()
Calling initcall 0xc051e7f0: serio_init+0x0/0xa0()
initcall 0xc051e7f0: serio_init+0x0/0xa0() returned 0.
initcall 0xc051e7f0 ran for 0 msecs: serio_init+0x0/0xa0()
Calling initcall 0xc051ecb0: gameport_init+0x0/0xa0()
initcall 0xc051ecb0: gameport_init+0x0/0xa0() returned 0.
initcall 0xc051ecb0 ran for 0 msecs: gameport_init+0x0/0xa0()
Calling initcall 0xc051ed50: input_init+0x0/0x110()
initcall 0xc051ed50: input_init+0x0/0x110() returned 0.
initcall 0xc051ed50 ran for 0 msecs: input_init+0x0/0x110()
Calling initcall 0xc05211c0: pci_legacy_init+0x0/0xf0()
PCI: Probing PCI hardware
PCI: Probing PCI hardware (bus 00)
PCI quirk: region 0400-043f claimed by PIIX4 ACPI
PCI quirk: region 0440-044f claimed by PIIX4 SMB
PIIX4 devres B PIO at 0290-0297
PCI: Firmware left 0000:00:10.0 e100 interrupts enabled, disabling
initcall 0xc05211c0: pci_legacy_init+0x0/0xf0() returned 0.
initcall 0xc05211c0 ran for 7 msecs: pci_legacy_init+0x0/0xf0()
Calling initcall 0xc05217b0: pcibios_irq_init+0x0/0x510()
initcall 0xc05217b0: pcibios_irq_init+0x0/0x510() returned 0.
initcall 0xc05217b0 ran for 3 msecs: pcibios_irq_init+0x0/0x510()
Calling initcall 0xc0521cc0: pcibios_init+0x0/0x90()
initcall 0xc0521cc0: pcibios_init+0x0/0x90() returned 0.
initcall 0xc0521cc0 ran for 0 msecs: pcibios_init+0x0/0x90()
Calling initcall 0xc0521e10: proto_init+0x0/0x30()
initcall 0xc0521e10: proto_init+0x0/0x30() returned 0.
initcall 0xc0521e10 ran for 0 msecs: proto_init+0x0/0x30()
Calling initcall 0xc0521f80: net_dev_init+0x0/0x1d0()
initcall 0xc0521f80: net_dev_init+0x0/0x1d0() returned 0.
initcall 0xc0521f80 ran for 3 msecs: net_dev_init+0x0/0x1d0()
Calling initcall 0xc0522190: neigh_init+0x0/0x80()
initcall 0xc0522190: neigh_init+0x0/0x80() returned 0.
initcall 0xc0522190 ran for 0 msecs: neigh_init+0x0/0x80()
Calling initcall 0xc0522720: genl_init+0x0/0xc0()
initcall 0xc0522720: genl_init+0x0/0xc0() returned 0.
initcall 0xc0522720 ran for 15 msecs: genl_init+0x0/0xc0()
Calling initcall 0xc0513300: clocksource_done_booting+0x0/0x20()
initcall 0xc0513300: clocksource_done_booting+0x0/0x20() returned 0.
initcall 0xc0513300 ran for 0 msecs: clocksource_done_booting+0x0/0x20()
Calling initcall 0xc0516330: init_pipe_fs+0x0/0x60()
initcall 0xc0516330: init_pipe_fs+0x0/0x60() returned 0.
initcall 0xc0516330 ran for 0 msecs: init_pipe_fs+0x0/0x60()
Calling initcall 0xc0516d30: eventpoll_init+0x0/0x90()
initcall 0xc0516d30: eventpoll_init+0x0/0x90() returned 0.
initcall 0xc0516d30 ran for 0 msecs: eventpoll_init+0x0/0x90()
Calling initcall 0xc0516dc0: anon_inode_init+0x0/0x100()
initcall 0xc0516dc0: anon_inode_init+0x0/0x100() returned 0.
Time: tsc clocksource has been installed.
initcall 0xc0516dc0 ran for 0 msecs: anon_inode_init+0x0/0x100()
Calling initcall 0xc0519140: pnp_system_init+0x0/0x10()
pnp: the driver 'system' has been registered
pnp: match found with the PnP device '00:00' and the driver 'system'
pnp: 00:00: iomem range 0x0-0x9fbff could not be reserved
pnp: 00:00: iomem range 0x9fc00-0x9ffff could not be reserved
pnp: 00:00: iomem range 0xe0000-0xfffff could not be reserved
pnp: 00:00: iomem range 0x100000-0x37ffffff could not be reserved
pnp: match found with the PnP device '00:08' and the driver 'system'
pnp: 00:08: ioport range 0x4d0-0x4d1 has been reserved
pnp: 00:08: ioport range 0xcf8-0xcff could not be reserved
pnp: 00:08: iomem range 0x0-0x0 could not be reserved
pnp: 00:08: iomem range 0x0-0x0 could not be reserved
pnp: 00:08: iomem range 0x0-0x0 could not be reserved
pnp: 00:08: iomem range 0x0-0x0 could not be reserved
pnp: match found with the PnP device '00:09' and the driver 'system'
pnp: 00:09: ioport range 0x290-0x297 has been reserved
pnp: 00:09: ioport range 0x398-0x399 has been reserved
initcall 0xc0519140: pnp_system_init+0x0/0x10() returned 0.
initcall 0xc0519140 ran for 1 msecs: pnp_system_init+0x0/0x10()
Calling initcall 0xc051a860: chr_dev_init+0x0/0xa0()
initcall 0xc051a860: chr_dev_init+0x0/0xa0() returned 0.
initcall 0xc051a860 ran for 3 msecs: chr_dev_init+0x0/0xa0()
Calling initcall 0xc051bd80: firmware_class_init+0x0/0x70()
initcall 0xc051bd80: firmware_class_init+0x0/0x70() returned 0.
initcall 0xc051bd80 ran for 0 msecs: firmware_class_init+0x0/0x70()
Calling initcall 0xc051fc70: cpufreq_gov_performance_init+0x0/0x10()
initcall 0xc051fc70: cpufreq_gov_performance_init+0x0/0x10() returned 0.
initcall 0xc051fc70 ran for 0 msecs: cpufreq_gov_performance_init+0x0/0x10()
Calling initcall 0xc0520900: pcibios_assign_resources+0x0/0x80()
PCI: Bridge: 0000:00:01.0
  IO window: d000-dfff
  MEM window: fc600000-fe6fffff
  PREFETCH window: e4400000-f44fffff
initcall 0xc0520900: pcibios_assign_resources+0x0/0x80() returned 0.
initcall 0xc0520900 ran for 0 msecs: pcibios_assign_resources+0x0/0x80()
Calling initcall 0xc0523220: inet_init+0x0/0x2f0()
NET: Registered protocol family 2
IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
TCP established hash table entries: 65536 (order: 9, 2359296 bytes)
TCP bind hash table entries: 65536 (order: 9, 2097152 bytes)
TCP: Hash tables configured (established 65536 bind 65536)
TCP reno registered
initcall 0xc0523220: inet_init+0x0/0x2f0() returned 0.
initcall 0xc0523220 ran for 106 msecs: inet_init+0x0/0x2f0()
Calling initcall 0xc050a1b0: populate_rootfs+0x0/0x100()
checking if image is initramfs...it isn't (no cpio magic); looks like an initrd
Freeing initrd memory: 265k freed
initcall 0xc050a1b0: populate_rootfs+0x0/0x100() returned 0.
initcall 0xc050a1b0 ran for 136 msecs: populate_rootfs+0x0/0x100()
Calling initcall 0xc050b000: i8259A_init_sysfs+0x0/0x30()
initcall 0xc050b000: i8259A_init_sysfs+0x0/0x30() returned 0.
initcall 0xc050b000 ran for 0 msecs: i8259A_init_sysfs+0x0/0x30()
Calling initcall 0xc050b130: sbf_init+0x0/0xe0()
initcall 0xc050b130: sbf_init+0x0/0xe0() returned 0.
initcall 0xc050b130 ran for 0 msecs: sbf_init+0x0/0xe0()
Calling initcall 0xc050c130: i8237A_init_sysfs+0x0/0x30()
initcall 0xc050c130: i8237A_init_sysfs+0x0/0x30() returned 0.
initcall 0xc050c130 ran for 0 msecs: i8237A_init_sysfs+0x0/0x30()
Calling initcall 0xc010c700: cache_sysfs_init+0x0/0x60()
initcall 0xc010c700: cache_sysfs_init+0x0/0x60() returned 0.
initcall 0xc010c700 ran for 0 msecs: cache_sysfs_init+0x0/0x60()
Calling initcall 0xc050cb10: thermal_throttle_init_device+0x0/0xb0()
initcall 0xc050cb10: thermal_throttle_init_device+0x0/0xb0() returned 0.
initcall 0xc050cb10 ran for 0 msecs: thermal_throttle_init_device+0x0/0xb0()
Calling initcall 0xc050cd90: msr_init+0x0/0x110()
initcall 0xc050cd90: msr_init+0x0/0x110() returned 0.
initcall 0xc050cd90 ran for 1 msecs: msr_init+0x0/0x110()
Calling initcall 0xc050cea0: cpuid_init+0x0/0x110()
initcall 0xc050cea0: cpuid_init+0x0/0x110() returned 0.
initcall 0xc050cea0 ran for 1 msecs: cpuid_init+0x0/0x110()
Calling initcall 0xc050dee0: init_lapic_sysfs+0x0/0x40()
initcall 0xc050dee0: init_lapic_sysfs+0x0/0x40() returned 0.
initcall 0xc050dee0 ran for 0 msecs: init_lapic_sysfs+0x0/0x40()
Calling initcall 0xc050f400: ioapic_init_sysfs+0x0/0xe0()
initcall 0xc050f400: ioapic_init_sysfs+0x0/0xe0() returned 0.
initcall 0xc050f400 ran for 0 msecs: ioapic_init_sysfs+0x0/0xe0()
Calling initcall 0xc0510e20: add_pcspkr+0x0/0x50()
initcall 0xc0510e20: add_pcspkr+0x0/0x50() returned 0.
initcall 0xc0510e20 ran for 0 msecs: add_pcspkr+0x0/0x50()
Calling initcall 0xc05118f0: init_sched_debug_procfs+0x0/0x30()
initcall 0xc05118f0: init_sched_debug_procfs+0x0/0x30() returned 0.
initcall 0xc05118f0 ran for 0 msecs: init_sched_debug_procfs+0x0/0x30()
Calling initcall 0xc0512500: create_proc_profile+0x0/0x1c0()
initcall 0xc0512500: create_proc_profile+0x0/0x1c0() returned 0.
initcall 0xc0512500 ran for 0 msecs: create_proc_profile+0x0/0x1c0()
Calling initcall 0xc0512980: ioresources_init+0x0/0x40()
initcall 0xc0512980: ioresources_init+0x0/0x40() returned 0.
initcall 0xc0512980 ran for 0 msecs: ioresources_init+0x0/0x40()
Calling initcall 0xc0512b00: uid_cache_init+0x0/0x80()
initcall 0xc0512b00: uid_cache_init+0x0/0x80() returned 0.
initcall 0xc0512b00 ran for 0 msecs: uid_cache_init+0x0/0x80()
Calling initcall 0xc0512fe0: init_posix_timers+0x0/0x90()
initcall 0xc0512fe0: init_posix_timers+0x0/0x90() returned 0.
initcall 0xc0512fe0 ran for 0 msecs: init_posix_timers+0x0/0x90()
Calling initcall 0xc0513070: init_posix_cpu_timers+0x0/0xa0()
initcall 0xc0513070: init_posix_cpu_timers+0x0/0xa0() returned 0.
initcall 0xc0513070 ran for 0 msecs: init_posix_cpu_timers+0x0/0xa0()
Calling initcall 0xc0513140: latency_init+0x0/0x30()
initcall 0xc0513140: latency_init+0x0/0x30() returned 0.
initcall 0xc0513140 ran for 0 msecs: latency_init+0x0/0x30()
Calling initcall 0xc0513170: nsproxy_cache_init+0x0/0x30()
initcall 0xc0513170: nsproxy_cache_init+0x0/0x30() returned 0.
initcall 0xc0513170 ran for 0 msecs: nsproxy_cache_init+0x0/0x30()
Calling initcall 0xc05131a0: timekeeping_init_device+0x0/0x30()
initcall 0xc05131a0: timekeeping_init_device+0x0/0x30() returned 0.
initcall 0xc05131a0 ran for 0 msecs: timekeeping_init_device+0x0/0x30()
Calling initcall 0xc05133c0: init_clocksource_sysfs+0x0/0x50()
initcall 0xc05133c0: init_clocksource_sysfs+0x0/0x50() returned 0.
initcall 0xc05133c0 ran for 0 msecs: init_clocksource_sysfs+0x0/0x50()
Calling initcall 0xc0513420: init_timer_list_procfs+0x0/0x30()
initcall 0xc0513420: init_timer_list_procfs+0x0/0x30() returned 0.
initcall 0xc0513420 ran for 0 msecs: init_timer_list_procfs+0x0/0x30()
Calling initcall 0xc0513570: lockdep_proc_init+0x0/0x40()
initcall 0xc0513570: lockdep_proc_init+0x0/0x40() returned 0.
initcall 0xc0513570 ran for 0 msecs: lockdep_proc_init+0x0/0x40()
Calling initcall 0xc05135b0: init+0x0/0xc0()
initcall 0xc05135b0: init+0x0/0xc0() returned 0.
initcall 0xc05135b0 ran for 0 msecs: init+0x0/0xc0()
Calling initcall 0xc0513670: proc_dma_init+0x0/0x20()
initcall 0xc0513670: proc_dma_init+0x0/0x20() returned 0.
initcall 0xc0513670 ran for 0 msecs: proc_dma_init+0x0/0x20()
Calling initcall 0xc0145cd0: percpu_modinit+0x0/0x70()
initcall 0xc0145cd0: percpu_modinit+0x0/0x70() returned 0.
initcall 0xc0145cd0 ran for 0 msecs: percpu_modinit+0x0/0x70()
Calling initcall 0xc0513690: kallsyms_init+0x0/0x30()
initcall 0xc0513690: kallsyms_init+0x0/0x30() returned 0.
initcall 0xc0513690 ran for 0 msecs: kallsyms_init+0x0/0x30()
Calling initcall 0xc0513770: audit_init+0x0/0x120()
audit: initializing netlink socket (disabled)
audit(1187793065.784:1): initialized
initcall 0xc0513770: audit_init+0x0/0x120() returned 0.
initcall 0xc0513770 ran for 0 msecs: audit_init+0x0/0x120()
Calling initcall 0xc0513920: audit_tree_init+0x0/0x40()
initcall 0xc0513920: audit_tree_init+0x0/0x40() returned 0.
initcall 0xc0513920 ran for 0 msecs: audit_tree_init+0x0/0x40()
Calling initcall 0xc0513a70: utsname_sysctl_init+0x0/0x20()
initcall 0xc0513a70: utsname_sysctl_init+0x0/0x20() returned 0.
initcall 0xc0513a70 ran for 0 msecs: utsname_sysctl_init+0x0/0x20()
Calling initcall 0xc0514ce0: init_per_zone_pages_min+0x0/0x60()
initcall 0xc0514ce0: init_per_zone_pages_min+0x0/0x60() returned 0.
initcall 0xc0514ce0 ran for 0 msecs: init_per_zone_pages_min+0x0/0x60()
Calling initcall 0xc05159f0: pdflush_init+0x0/0x20()
initcall 0xc05159f0: pdflush_init+0x0/0x20() returned 0.
initcall 0xc05159f0 ran for 0 msecs: pdflush_init+0x0/0x20()
Calling initcall 0xc0515a40: kswapd_init+0x0/0x30()
initcall 0xc0515a40: kswapd_init+0x0/0x30() returned 0.
initcall 0xc0515a40 ran for 0 msecs: kswapd_init+0x0/0x30()
Calling initcall 0xc0515a70: setup_vmstat+0x0/0x50()
initcall 0xc0515a70: setup_vmstat+0x0/0x50() returned 0.
initcall 0xc0515a70 ran for 0 msecs: setup_vmstat+0x0/0x50()
Calling initcall 0xc0515bb0: init_emergency_pool+0x0/0x70()
initcall 0xc0515bb0: init_emergency_pool+0x0/0x70() returned 0.
initcall 0xc0515bb0 ran for 0 msecs: init_emergency_pool+0x0/0x70()
Calling initcall 0xc0515c20: procswaps_init+0x0/0x20()
initcall 0xc0515c20: procswaps_init+0x0/0x20() returned 0.
initcall 0xc0515c20 ran for 0 msecs: procswaps_init+0x0/0x20()
Calling initcall 0xc0515c80: hugetlb_init+0x0/0x70()
Total HugeTLB memory allocated, 0
initcall 0xc0515c80: hugetlb_init+0x0/0x70() returned 0.
initcall 0xc0515c80 ran for 0 msecs: hugetlb_init+0x0/0x70()
Calling initcall 0xc0515cf0: init_tmpfs+0x0/0xd0()
initcall 0xc0515cf0: init_tmpfs+0x0/0xd0() returned 0.
initcall 0xc0515cf0 ran for 0 msecs: init_tmpfs+0x0/0xd0()
Calling initcall 0xc0515e40: cpucache_init+0x0/0x40()
initcall 0xc0515e40: cpucache_init+0x0/0x40() returned 0.
initcall 0xc0515e40 ran for 0 msecs: cpucache_init+0x0/0x40()
Calling initcall 0xc0516390: fasync_init+0x0/0x30()
initcall 0xc0516390: fasync_init+0x0/0x30() returned 0.
initcall 0xc0516390 ran for 0 msecs: fasync_init+0x0/0x30()
Calling initcall 0xc0516a50: aio_setup+0x0/0x70()
initcall 0xc0516a50: aio_setup+0x0/0x70() returned 0.
initcall 0xc0516a50 ran for 0 msecs: aio_setup+0x0/0x70()
Calling initcall 0xc0516c60: inotify_setup+0x0/0x10()
initcall 0xc0516c60: inotify_setup+0x0/0x10() returned 0.
initcall 0xc0516c60 ran for 0 msecs: inotify_setup+0x0/0x10()
Calling initcall 0xc0516c70: inotify_user_setup+0x0/0xc0()
initcall 0xc0516c70: inotify_user_setup+0x0/0xc0() returned 0.
initcall 0xc0516c70 ran for 0 msecs: inotify_user_setup+0x0/0xc0()
Calling initcall 0xc0516f30: init_mbcache+0x0/0x20()
initcall 0xc0516f30: init_mbcache+0x0/0x20() returned 0.
initcall 0xc0516f30 ran for 0 msecs: init_mbcache+0x0/0x20()
Calling initcall 0xc0516f50: dnotify_init+0x0/0x30()
initcall 0xc0516f50: dnotify_init+0x0/0x30() returned 0.
initcall 0xc0516f50 ran for 0 msecs: dnotify_init+0x0/0x30()
Calling initcall 0xc0517360: init_devpts_fs+0x0/0x30()
initcall 0xc0517360: init_devpts_fs+0x0/0x30() returned 0.
initcall 0xc0517360 ran for 0 msecs: init_devpts_fs+0x0/0x30()
Calling initcall 0xc0517390: init_ext3_fs+0x0/0x60()
initcall 0xc0517390: init_ext3_fs+0x0/0x60() returned 0.
initcall 0xc0517390 ran for 0 msecs: init_ext3_fs+0x0/0x60()
Calling initcall 0xc05173f0: init_ext4_fs+0x0/0x80()
initcall 0xc05173f0: init_ext4_fs+0x0/0x80() returned 0.
initcall 0xc05173f0 ran for 0 msecs: init_ext4_fs+0x0/0x80()
Calling initcall 0xc0517530: journal_init+0x0/0x100()
initcall 0xc0517530: journal_init+0x0/0x100() returned 0.
initcall 0xc0517530 ran for 0 msecs: journal_init+0x0/0x100()
Calling initcall 0xc05176b0: journal_init+0x0/0xe0()
initcall 0xc05176b0: journal_init+0x0/0xe0() returned 0.
initcall 0xc05176b0 ran for 0 msecs: journal_init+0x0/0xe0()
Calling initcall 0xc0517790: init_ext2_fs+0x0/0x60()
initcall 0xc0517790: init_ext2_fs+0x0/0x60() returned 0.
initcall 0xc0517790 ran for 0 msecs: init_ext2_fs+0x0/0x60()
Calling initcall 0xc0517800: init_ramfs_fs+0x0/0x10()
initcall 0xc0517800: init_ramfs_fs+0x0/0x10() returned 0.
initcall 0xc0517800 ran for 0 msecs: init_ramfs_fs+0x0/0x10()
Calling initcall 0xc0517810: init_hugetlbfs_fs+0x0/0x80()
initcall 0xc0517810: init_hugetlbfs_fs+0x0/0x80() returned 0.
initcall 0xc0517810 ran for 0 msecs: init_hugetlbfs_fs+0x0/0x80()
Calling initcall 0xc05178d0: init_fat_fs+0x0/0x60()
initcall 0xc05178d0: init_fat_fs+0x0/0x60() returned 0.
initcall 0xc05178d0 ran for 0 msecs: init_fat_fs+0x0/0x60()
Calling initcall 0xc0517930: init_msdos_fs+0x0/0x10()
initcall 0xc0517930: init_msdos_fs+0x0/0x10() returned 0.
initcall 0xc0517930 ran for 0 msecs: init_msdos_fs+0x0/0x10()
Calling initcall 0xc0517940: init_vfat_fs+0x0/0x10()
initcall 0xc0517940: init_vfat_fs+0x0/0x10() returned 0.
initcall 0xc0517940 ran for 0 msecs: init_vfat_fs+0x0/0x10()
Calling initcall 0xc0517950: init_iso9660_fs+0x0/0x70()
initcall 0xc0517950: init_iso9660_fs+0x0/0x70() returned 0.
initcall 0xc0517950 ran for 0 msecs: init_iso9660_fs+0x0/0x70()
Calling initcall 0xc0517ad0: init_nfs_fs+0x0/0xc0()
initcall 0xc0517ad0: init_nfs_fs+0x0/0xc0() returned 0.
initcall 0xc0517ad0 ran for 0 msecs: init_nfs_fs+0x0/0xc0()
Calling initcall 0xc0517d40: init_nfsd+0x0/0xa0()
Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
initcall 0xc0517d40: init_nfsd+0x0/0xa0() returned 0.
initcall 0xc0517d40 ran for 2 msecs: init_nfsd+0x0/0xa0()
Calling initcall 0xc0517de0: init_nlm+0x0/0x20()
initcall 0xc0517de0: init_nlm+0x0/0x20() returned 0.
initcall 0xc0517de0 ran for 0 msecs: init_nlm+0x0/0x20()
Calling initcall 0xc0517e00: init_autofs4_fs+0x0/0x10()
initcall 0xc0517e00: init_autofs4_fs+0x0/0x10() returned 0.
initcall 0xc0517e00 ran for 0 msecs: init_autofs4_fs+0x0/0x10()
Calling initcall 0xc0517e10: init_udf_fs+0x0/0x60()
initcall 0xc0517e10: init_udf_fs+0x0/0x60() returned 0.
initcall 0xc0517e10 ran for 0 msecs: init_udf_fs+0x0/0x60()
Calling initcall 0xc0517ec0: ipc_init+0x0/0x20()
initcall 0xc0517ec0: ipc_init+0x0/0x20() returned 0.
initcall 0xc0517ec0 ran for 0 msecs: ipc_init+0x0/0x20()
Calling initcall 0xc0518000: ipc_sysctl_init+0x0/0x20()
initcall 0xc0518000: ipc_sysctl_init+0x0/0x20() returned 0.
initcall 0xc0518000 ran for 0 msecs: ipc_sysctl_init+0x0/0x20()
Calling initcall 0xc0518020: crypto_algapi_init+0x0/0x10()
initcall 0xc0518020: crypto_algapi_init+0x0/0x10() returned 0.
initcall 0xc0518020 ran for 0 msecs: crypto_algapi_init+0x0/0x10()
Calling initcall 0xc0518050: cryptomgr_init+0x0/0x10()
initcall 0xc0518050: cryptomgr_init+0x0/0x10() returned 0.
initcall 0xc0518050 ran for 0 msecs: cryptomgr_init+0x0/0x10()
Calling initcall 0xc0518060: init+0x0/0x10()
initcall 0xc0518060: init+0x0/0x10() returned 0.
initcall 0xc0518060 ran for 0 msecs: init+0x0/0x10()
Calling initcall 0xc0518070: crypto_cbc_module_init+0x0/0x10()
initcall 0xc0518070: crypto_cbc_module_init+0x0/0x10() returned 0.
initcall 0xc0518070 ran for 0 msecs: crypto_cbc_module_init+0x0/0x10()
Calling initcall 0xc0518080: init+0x0/0x40()
initcall 0xc0518080: init+0x0/0x40() returned 0.
initcall 0xc0518080 ran for 0 msecs: init+0x0/0x40()
Calling initcall 0xc0518420: noop_init+0x0/0x10()
io scheduler noop registered
initcall 0xc0518420: noop_init+0x0/0x10() returned 0.
initcall 0xc0518420 ran for 0 msecs: noop_init+0x0/0x10()
Calling initcall 0xc0518430: as_init+0x0/0x10()
io scheduler anticipatory registered (default)
initcall 0xc0518430: as_init+0x0/0x10() returned 0.
initcall 0xc0518430 ran for 0 msecs: as_init+0x0/0x10()
Calling initcall 0xc0518440: deadline_init+0x0/0x10()
io scheduler deadline registered
initcall 0xc0518440: deadline_init+0x0/0x10() returned 0.
initcall 0xc0518440 ran for 0 msecs: deadline_init+0x0/0x10()
Calling initcall 0xc0518450: cfq_init+0x0/0xd0()
io scheduler cfq registered
initcall 0xc0518450: cfq_init+0x0/0xd0() returned 0.
initcall 0xc0518450 ran for 0 msecs: cfq_init+0x0/0xd0()
Calling initcall 0xc0518710: percpu_counter_startup+0x0/0x20()
initcall 0xc0518710: percpu_counter_startup+0x0/0x20() returned 0.
initcall 0xc0518710 ran for 0 msecs: percpu_counter_startup+0x0/0x20()
Calling initcall 0xc0518730: audit_classes_init+0x0/0x50()
initcall 0xc0518730: audit_classes_init+0x0/0x50() returned 0.
initcall 0xc0518730 ran for 0 msecs: audit_classes_init+0x0/0x50()
Calling initcall 0xc029bcb0: pci_init+0x0/0x30()
Limiting direct PCI/PCI transfers.
Boot video device is 0000:01:00.0
initcall 0xc029bcb0: pci_init+0x0/0x30() returned 0.
initcall 0xc029bcb0 ran for 0 msecs: pci_init+0x0/0x30()
Calling initcall 0xc0518e70: pci_proc_init+0x0/0x70()
initcall 0xc0518e70: pci_proc_init+0x0/0x70() returned 0.
initcall 0xc0518e70 ran for 0 msecs: pci_proc_init+0x0/0x70()
Calling initcall 0xc0518ee0: pci_hotplug_init+0x0/0x60()
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
initcall 0xc0518ee0: pci_hotplug_init+0x0/0x60() returned 0.
initcall 0xc0518ee0 ran for 0 msecs: pci_hotplug_init+0x0/0x60()
Calling initcall 0xc05195f0: pnpbios_thread_init+0x0/0x60()
initcall 0xc05195f0: pnpbios_thread_init+0x0/0x60() returned 0.
initcall 0xc05195f0 ran for 0 msecs: pnpbios_thread_init+0x0/0x60()
Calling initcall 0xc051a2c0: isapnp_init+0x0/0x4a0()
isapnp: Scanning for PnP cards...
isapnp: No Plug & Play device found
initcall 0xc051a2c0: isapnp_init+0x0/0x4a0() returned 0.
initcall 0xc051a2c0 ran for 340 msecs: isapnp_init+0x0/0x4a0()
Calling initcall 0xc051a910: rand_initialize+0x0/0x30()
initcall 0xc051a910: rand_initialize+0x0/0x30() returned 0.
initcall 0xc051a910 ran for 0 msecs: rand_initialize+0x0/0x30()
Calling initcall 0xc051a940: tty_init+0x0/0x1f0()
initcall 0xc051a940: tty_init+0x0/0x1f0() returned 0.
initcall 0xc051a940 ran for 27 msecs: tty_init+0x0/0x1f0()
Calling initcall 0xc051ab90: pty_init+0x0/0x420()
khelper used greatest stack depth: 6920 bytes left
khelper used greatest stack depth: 6804 bytes left
initcall 0xc051ab90: pty_init+0x0/0x420() returned 0.
initcall 0xc051ab90 ran for 244 msecs: pty_init+0x0/0x420()
Calling initcall 0xc051b610: rtc_init+0x0/0x1b0()
Real Time Clock Driver v1.12ac
initcall 0xc051b610: rtc_init+0x0/0x1b0() returned 0.
initcall 0xc051b610 ran for 0 msecs: rtc_init+0x0/0x1b0()
Calling initcall 0xc051b7c0: agp_init+0x0/0x30()
Linux agpgart interface v0.102
initcall 0xc051b7c0: agp_init+0x0/0x30() returned 0.
initcall 0xc051b7c0 ran for 0 msecs: agp_init+0x0/0x30()
Calling initcall 0xc051b850: agp_intel_init+0x0/0x40()
agpgart: suspend/resume problematic: resume with 3D/DRI active may lockup X.Org
on some chipset/BIOS combos (see DEBUG_AGP_PM in intel-agp.c)
agpgart: Detected an Intel 440BX Chipset.
agpgart: AGP aperture is 64M @ 0xf8000000
initcall 0xc051b850: agp_intel_init+0x0/0x40() returned 0.
initcall 0xc051b850 ran for 5 msecs: agp_intel_init+0x0/0x40()
Calling initcall 0xc051b890: cn_proc_init+0x0/0x40()
initcall 0xc051b890: cn_proc_init+0x0/0x40() returned 0.
initcall 0xc051b890 ran for 0 msecs: cn_proc_init+0x0/0x40()
Calling initcall 0xc051ba80: serial8250_init+0x0/0x130()
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing disabled
serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
initcall 0xc051ba80: serial8250_init+0x0/0x130() returned 0.
initcall 0xc051ba80 ran for 3 msecs: serial8250_init+0x0/0x130()
Calling initcall 0xc051bbb0: serial8250_pnp_init+0x0/0x10()
pnp: the driver 'serial' has been registered
pnp: match found with the PnP device '00:0b' and the driver 'serial'
00:0b: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
pnp: match found with the PnP device '00:0c' and the driver 'serial'
00:0c: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
initcall 0xc051bbb0: serial8250_pnp_init+0x0/0x10() returned 0.
initcall 0xc051bbb0 ran for 3 msecs: serial8250_pnp_init+0x0/0x10()
Calling initcall 0xc051bbc0: serial8250_pci_init+0x0/0x20()
initcall 0xc051bbc0: serial8250_pci_init+0x0/0x20() returned 0.
initcall 0xc051bbc0 ran for 0 msecs: serial8250_pci_init+0x0/0x20()
Calling initcall 0xc051bd40: isa_bus_init+0x0/0x40()
initcall 0xc051bd40: isa_bus_init+0x0/0x40() returned 0.
initcall 0xc051bd40 ran for 0 msecs: isa_bus_init+0x0/0x40()
Calling initcall 0xc02d93e0: topology_sysfs_init+0x0/0x50()
initcall 0xc02d93e0: topology_sysfs_init+0x0/0x50() returned 0.
initcall 0xc02d93e0 ran for 0 msecs: topology_sysfs_init+0x0/0x50()
Calling initcall 0xc051c0e0: floppy_init+0x0/0xf10()
Floppy drive(s): fd0 is 1.44M
FDC 0 is a post-1991 82077
initcall 0xc051c0e0: floppy_init+0x0/0xf10() returned 0.
initcall 0xc051c0e0 ran for 19 msecs: floppy_init+0x0/0xf10()
Calling initcall 0xc051d040: rd_init+0x0/0x1e0()
RAMDISK driver initialized: 16 RAM disks of 4096K size 1024 blocksize
initcall 0xc051d040: rd_init+0x0/0x1e0() returned 0.
initcall 0xc051d040 ran for 7 msecs: rd_init+0x0/0x1e0()
Calling initcall 0xc051d240: loop_init+0x0/0x180()
loop: module loaded
initcall 0xc051d240: loop_init+0x0/0x180() returned 0.
initcall 0xc051d240 ran for 3 msecs: loop_init+0x0/0x180()
Calling initcall 0xc051d3c0: e100_init_module+0x0/0x60()
e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
e100: Copyright(c) 1999-2006 Intel Corporation
e100: eth0: e100_probe: addr 0xfc5ff000, irq 11, MAC addr 00:90:27:70:14:CD
initcall 0xc051d3c0: e100_init_module+0x0/0x60() returned 0.
initcall 0xc051d3c0 ran for 22 msecs: e100_init_module+0x0/0x60()
Calling initcall 0xc051d490: net_olddevs_init+0x0/0x90()
initcall 0xc051d490: net_olddevs_init+0x0/0x90() returned 0.
initcall 0xc051d490 ran for 0 msecs: net_olddevs_init+0x0/0x90()
Calling initcall 0xc051d520: loopback_init+0x0/0x30()
initcall 0xc051d520: loopback_init+0x0/0x30() returned 0.
initcall 0xc051d520 ran for 0 msecs: loopback_init+0x0/0x30()
Calling initcall 0xc051d550: dummy_init_module+0x0/0xd0()
initcall 0xc051d550: dummy_init_module+0x0/0xd0() returned 0.
initcall 0xc051d550 ran for 0 msecs: dummy_init_module+0x0/0xd0()
Calling initcall 0xc051d620: rtl8169_init_module+0x0/0x20()
initcall 0xc051d620: rtl8169_init_module+0x0/0x20() returned 0.
initcall 0xc051d620 ran for 0 msecs: rtl8169_init_module+0x0/0x20()
Calling initcall 0xc051d660: init_netconsole+0x0/0x1d0()
netconsole: local port 4444
netconsole: local IP 192.168.2.36
netconsole: interface eth0
netconsole: remote port 5140
netconsole: remote IP 192.168.2.33
netconsole: remote ethernet address 00:0d:56:c6:c6:cc
netconsole: device eth0 not up yet, forcing it
WARNING: at include/linux/netdevice.h:331 napi_enable()
 [<c0103bfa>] show_trace_log_lvl+0x1a/0x30
 [<c0104822>] show_trace+0x12/0x20
 [<c0104846>] dump_stack+0x16/0x20
 [<c02e3989>] e100_up+0x159/0x160
 [<c02e39ae>] e100_open+0x1e/0x60
 [<c0354bb8>] dev_open+0x38/0x80
 [<c03605eb>] netpoll_setup+0x15b/0x390
 [<c051d754>] init_netconsole+0xf4/0x1d0
 [<c05045f2>] kernel_init+0x142/0x320
 [<c0103807>] kernel_thread_helper+0x7/0x10
 =======================
e100: eth0: e100_watchdog: link up, 100Mbps, full-duplex
netconsole: carrier detect appears untrustworthy, waiting 4 seconds
console [netcon0] enabled
netconsole: network logging started
initcall 0xc051d660: init_netconsole+0x0/0x1d0() returned 0.
initcall 0xc051d660 ran for 3968 msecs: init_netconsole+0x0/0x1d0()
Calling initcall 0xc051d830: piix_ide_init+0x0/0xb0()
initcall 0xc051d830: piix_ide_init+0x0/0xb0() returned 0.
initcall 0xc051d830 ran for 0 msecs: piix_ide_init+0x0/0xb0()
Calling initcall 0xc051d8e0: generic_ide_init+0x0/0x20()
initcall 0xc051d8e0: generic_ide_init+0x0/0x20() returned 0.
initcall 0xc051d8e0 ran for 0 msecs: generic_ide_init+0x0/0x20()
Calling initcall 0xc051d9a0: ide_init+0x0/0x70()
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
PIIX4: IDE controller at PCI slot 0000:00:07.1
PIIX4: chipset revision 1
PIIX4: not 100% native mode: will probe irqs later
    ide0: BM-DMA at 0xffa0-0xffa7, BIOS settings: hda:pio, hdb:pio
    ide1: BM-DMA at 0xffa8-0xffaf, BIOS settings: hdc:DMA, hdd:pio
Probing IDE interface ide0...
Probing IDE interface ide1...
hdc: MAXTOR 6L080J4, ATA DISK drive
hdc: host max PIO4 wanted PIO255(auto-tune) selected PIO4
hdc: selected mode 0x42
ide1 at 0x170-0x177,0x376 on irq 15
initcall 0xc051d9a0: ide_init+0x0/0x70() returned 0.
initcall 0xc051d9a0 ran for 1465 msecs: ide_init+0x0/0x70()
Calling initcall 0xc051e1a0: ide_generic_init+0x0/0x10()
Probing IDE interface ide0...
initcall 0xc051e1a0: ide_generic_init+0x0/0x10() returned 0.
initcall 0xc051e1a0 ran for 546 msecs: ide_generic_init+0x0/0x10()
Calling initcall 0xc051e1b0: idedisk_init+0x0/0x10()
hdc: max request size: 128KiB
hdc: 156355584 sectors (80054 MB) w/1819KiB Cache, CHS=65535/16/63, UDMA(33)
hdc: cache flushes supported
 hdc: hdc1 hdc2 hdc3 hdc4 < hdc5 hdc6 >
initcall 0xc051e1b0: idedisk_init+0x0/0x10() returned 0.
initcall 0xc051e1b0 ran for 36 msecs: idedisk_init+0x0/0x10()
Calling initcall 0xc051e1c0: ide_cdrom_init+0x0/0x10()
initcall 0xc051e1c0: ide_cdrom_init+0x0/0x10() returned 0.
initcall 0xc051e1c0 ran for 0 msecs: ide_cdrom_init+0x0/0x10()
Calling initcall 0xc051e1d0: idetape_init+0x0/0x90()
initcall 0xc051e1d0: idetape_init+0x0/0x90() returned 0.
initcall 0xc051e1d0 ran for 0 msecs: idetape_init+0x0/0x90()
Calling initcall 0xc051e260: idefloppy_init+0x0/0x20()
ide-floppy driver 0.99.newide
initcall 0xc051e260: idefloppy_init+0x0/0x20() returned 0.
initcall 0xc051e260 ran for 0 msecs: idefloppy_init+0x0/0x20()
Calling initcall 0xc051e530: spi_transport_init+0x0/0x30()
initcall 0xc051e530: spi_transport_init+0x0/0x30() returned 0.
initcall 0xc051e530 ran for 0 msecs: spi_transport_init+0x0/0x30()
Calling initcall 0xc051e560: fc_transport_init+0x0/0x50()
initcall 0xc051e560: fc_transport_init+0x0/0x50() returned 0.
initcall 0xc051e560 ran for 1 msecs: fc_transport_init+0x0/0x50()
Calling initcall 0xc051e5b0: init_sd+0x0/0x90()
initcall 0xc051e5b0: init_sd+0x0/0x90() returned 0.
initcall 0xc051e5b0 ran for 1 msecs: init_sd+0x0/0x90()
Calling initcall 0xc051e640: init_sr+0x0/0x50()
initcall 0xc051e640: init_sr+0x0/0x50() returned 0.
initcall 0xc051e640 ran for 0 msecs: init_sr+0x0/0x50()
Calling initcall 0xc051e690: init_sg+0x0/0x150()
initcall 0xc051e690: init_sg+0x0/0x150() returned 0.
initcall 0xc051e690 ran for 0 msecs: init_sg+0x0/0x150()
Calling initcall 0xc051e7e0: cdrom_init+0x0/0x10()
initcall 0xc051e7e0: cdrom_init+0x0/0x10() returned 0.
initcall 0xc051e7e0 ran for 0 msecs: cdrom_init+0x0/0x10()
Calling initcall 0xc051e890: i8042_init+0x0/0x3f0()
pnp: the driver 'i8042 kbd' has been registered
pnp: match found with the PnP device '00:05' and the driver 'i8042 kbd'
pnp: the driver 'i8042 aux' has been registered
PNP: PS/2 Controller [PNP0303] at 0x60,0x64 irq 1
PNP: PS/2 appears to have AUX port disabled, if this is incorrect please boot with i8042.nopnp
serio: i8042 KBD port at 0x60,0x64 irq 1
initcall 0xc051e890: i8042_init+0x0/0x3f0() returned 0.
initcall 0xc051e890 ran for 2 msecs: i8042_init+0x0/0x3f0()
Calling initcall 0xc051ec80: serport_init+0x0/0x30()
initcall 0xc051ec80: serport_init+0x0/0x30() returned 0.
initcall 0xc051ec80 ran for 0 msecs: serport_init+0x0/0x30()
Calling initcall 0xc051ee60: mousedev_init+0x0/0x90()
mice: PS/2 mouse device common for all mice
initcall 0xc051ee60: mousedev_init+0x0/0x90() returned 0.
initcall 0xc051ee60 ran for 1 msecs: mousedev_init+0x0/0x90()
Calling initcall 0xc051eef0: atkbd_init+0x0/0x20()
initcall 0xc051eef0: atkbd_init+0x0/0x20() returned 0.
initcall 0xc051eef0 ran for 0 msecs: atkbd_init+0x0/0x20()
Calling initcall 0xc051ef10: psmouse_init+0x0/0x60()
input: AT Translated Set 2 keyboard as /class/input/input0
initcall 0xc051ef10: psmouse_init+0x0/0x60() returned 0.
initcall 0xc051ef10 ran for 36 msecs: psmouse_init+0x0/0x60()
Calling initcall 0xc051ef70: edac_init+0x0/0xb0()
EDAC MC: Ver: 2.1.0 Aug 21 2007
EDAC DEBUG: edac_pci_dev_parity_clear()
EDAC DEBUG: edac_pci_dev_parity_clear()
EDAC DEBUG: edac_pci_dev_parity_clear()
EDAC DEBUG: edac_pci_dev_parity_clear()
EDAC DEBUG: edac_pci_dev_parity_clear()
EDAC DEBUG: edac_pci_dev_parity_clear()
EDAC DEBUG: edac_pci_dev_parity_clear()
EDAC DEBUG: edac_pci_dev_parity_clear()
EDAC DEBUG: edac_pci_dev_parity_clear()
EDAC DEBUG: edac_sysfs_setup_mc_kset()
EDAC DEBUG: edac_sysfs_setup_mc_kset() Registered '.../edac/mc' kobject
initcall 0xc051ef70: edac_init+0x0/0xb0() returned 0.
initcall 0xc051ef70 ran for 1 msecs: edac_init+0x0/0xb0()
Calling initcall 0xc051f020: amd76x_init+0x0/0x20()
initcall 0xc051f020: amd76x_init+0x0/0x20() returned 0.
initcall 0xc051f020 ran for 0 msecs: amd76x_init+0x0/0x20()
Calling initcall 0xc051f040: e7xxx_init+0x0/0x20()
initcall 0xc051f040: e7xxx_init+0x0/0x20() returned 0.
initcall 0xc051f040 ran for 0 msecs: e7xxx_init+0x0/0x20()
Calling initcall 0xc051f060: e752x_init+0x0/0x40()
initcall 0xc051f060: e752x_init+0x0/0x40() returned 0.
initcall 0xc051f060 ran for 0 msecs: e752x_init+0x0/0x40()
Calling initcall 0xc051f0a0: i82875p_init+0x0/0xf0()
EDAC DEBUG: 875p pci_get_device fail
initcall 0xc051f0a0: i82875p_init+0x0/0xf0() returned -19.
initcall 0xc051f0a0 ran for 0 msecs: i82875p_init+0x0/0xf0()
Calling initcall 0xc051f190: i82860_init+0x0/0xf0()
EDAC DEBUG: 860 pci_get_device fail
initcall 0xc051f190: i82860_init+0x0/0xf0() returned -19.
initcall 0xc051f190 ran for 0 msecs: i82860_init+0x0/0xf0()
Calling initcall 0xc051f280: r82600_init+0x0/0x20()
initcall 0xc051f280: r82600_init+0x0/0x20() returned 0.
initcall 0xc051f280 ran for 0 msecs: r82600_init+0x0/0x20()
Calling initcall 0xc051faa0: pci_eisa_init_module+0x0/0x20()
initcall 0xc051faa0: pci_eisa_init_module+0x0/0x20() returned 0.
initcall 0xc051faa0 ran for 0 msecs: pci_eisa_init_module+0x0/0x20()
Calling initcall 0xc051fac0: virtual_eisa_root_init+0x0/0x60()
EISA: Probing bus 0 at eisa.0
initcall 0xc051fac0: virtual_eisa_root_init+0x0/0x60() returned -1.
initcall 0xc051fac0 ran for 1 msecs: virtual_eisa_root_init+0x0/0x60()
initcall at 0xc051fac0: virtual_eisa_root_init+0x0/0x60(): returned with error code -1
Calling initcall 0xc051fbc0: cpufreq_stats_init+0x0/0xb0()
initcall 0xc051fbc0: cpufreq_stats_init+0x0/0xb0() returned 0.
initcall 0xc051fbc0 ran for 0 msecs: cpufreq_stats_init+0x0/0xb0()
Calling initcall 0xc05208f0: hid_init+0x0/0x10()
initcall 0xc05208f0: hid_init+0x0/0x10() returned 0.
initcall 0xc05208f0 ran for 0 msecs: hid_init+0x0/0x10()
Calling initcall 0xc0522350: flow_cache_init+0x0/0x180()
initcall 0xc0522350: flow_cache_init+0x0/0x180() returned 0.
initcall 0xc0522350 ran for 0 msecs: flow_cache_init+0x0/0x180()
Calling initcall 0xc0522510: llc_init+0x0/0x70()
initcall 0xc0522510: llc_init+0x0/0x70() returned 0.
initcall 0xc0522510 ran for 0 msecs: llc_init+0x0/0x70()
Calling initcall 0xc0522580: snap_init+0x0/0x40()
initcall 0xc0522580: snap_init+0x0/0x40() returned 0.
initcall 0xc0522580 ran for 0 msecs: snap_init+0x0/0x40()
Calling initcall 0xc0523810: xfrm4_beet_init+0x0/0x20()
initcall 0xc0523810: xfrm4_beet_init+0x0/0x20() returned 0.
initcall 0xc0523810 ran for 0 msecs: xfrm4_beet_init+0x0/0x20()
Calling initcall 0xc0523830: xfrm4_transport_init+0x0/0x20()
initcall 0xc0523830: xfrm4_transport_init+0x0/0x20() returned 0.
initcall 0xc0523830 ran for 0 msecs: xfrm4_transport_init+0x0/0x20()
Calling initcall 0xc0523850: xfrm4_tunnel_init+0x0/0x20()
initcall 0xc0523850: xfrm4_tunnel_init+0x0/0x20() returned 0.
initcall 0xc0523850 ran for 0 msecs: xfrm4_tunnel_init+0x0/0x20()
Calling initcall 0xc0523870: inet_diag_init+0x0/0x70()
initcall 0xc0523870: inet_diag_init+0x0/0x70() returned 0.
initcall 0xc0523870 ran for 0 msecs: inet_diag_init+0x0/0x70()
Calling initcall 0xc05238e0: tcp_diag_init+0x0/0x10()
initcall 0xc05238e0: tcp_diag_init+0x0/0x10() returned 0.
initcall 0xc05238e0 ran for 0 msecs: tcp_diag_init+0x0/0x10()
Calling initcall 0xc05238f0: cubictcp_register+0x0/0xb0()
TCP cubic registered
initcall 0xc05238f0: cubictcp_register+0x0/0xb0() returned 0.
initcall 0xc05238f0 ran for 0 msecs: cubictcp_register+0x0/0xb0()
Calling initcall 0xc0523b70: af_unix_init+0x0/0x80()
NET: Registered protocol family 1
initcall 0xc0523b70: af_unix_init+0x0/0x80() returned 0.
initcall 0xc0523b70 ran for 0 msecs: af_unix_init+0x0/0x80()
Calling initcall 0xc0523bf0: packet_init+0x0/0x60()
NET: Registered protocol family 17
initcall 0xc0523bf0: packet_init+0x0/0x60() returned 0.
initcall 0xc0523bf0 ran for 0 msecs: packet_init+0x0/0x60()
Calling initcall 0xc0523c50: ipsec_pfkey_init+0x0/0x90()
NET: Registered protocol family 15
initcall 0xc0523c50: ipsec_pfkey_init+0x0/0x90() returned 0.
initcall 0xc0523c50 ran for 0 msecs: ipsec_pfkey_init+0x0/0x90()
Calling initcall 0xc0523ce0: br_init+0x0/0xb0()
initcall 0xc0523ce0: br_init+0x0/0xb0() returned 0.
initcall 0xc0523ce0 ran for 0 msecs: br_init+0x0/0xb0()
Calling initcall 0xc0523e70: init_sunrpc+0x0/0x60()
initcall 0xc0523e70: init_sunrpc+0x0/0x60() returned 0.
initcall 0xc0523e70 ran for 0 msecs: init_sunrpc+0x0/0x60()
Calling initcall 0xc0523ed0: init_rpcsec_gss+0x0/0x40()
initcall 0xc0523ed0: init_rpcsec_gss+0x0/0x40() returned 0.
initcall 0xc0523ed0 ran for 0 msecs: init_rpcsec_gss+0x0/0x40()
Calling initcall 0xc0523f10: init_kerberos_module+0x0/0x29()
initcall 0xc0523f10: init_kerberos_module+0x0/0x29() returned 0.
initcall 0xc0523f10 ran for 0 msecs: init_kerberos_module+0x0/0x29()
Calling initcall 0xc050ec70: check_nmi_watchdog+0x0/0x1e0()
Testing NMI watchdog ... OK.
initcall 0xc050ec70: check_nmi_watchdog+0x0/0x1e0() returned 0.
initcall 0xc050ec70 ran for 75 msecs: check_nmi_watchdog+0x0/0x1e0()
Calling initcall 0xc050ec00: init_lapic_nmi_sysfs+0x0/0x40()
initcall 0xc050ec00: init_lapic_nmi_sysfs+0x0/0x40() returned 0.
initcall 0xc050ec00 ran for 0 msecs: init_lapic_nmi_sysfs+0x0/0x40()
Calling initcall 0xc0510690: balanced_irq_init+0x0/0x1e0()
Starting balanced_irq
initcall 0xc0510690: balanced_irq_init+0x0/0x1e0() returned 0.
initcall 0xc0510690 ran for 0 msecs: balanced_irq_init+0x0/0x1e0()
Calling initcall 0xc050efc0: io_apic_bug_finalize+0x0/0x20()
initcall 0xc050efc0: io_apic_bug_finalize+0x0/0x20() returned 0.
initcall 0xc050efc0 ran for 0 msecs: io_apic_bug_finalize+0x0/0x20()
Calling initcall 0xc0511760: print_ipi_mode+0x0/0x30()
Using IPI No-Shortcut mode
initcall 0xc0511760: print_ipi_mode+0x0/0x30() returned 0.
initcall 0xc0511760 ran for 0 msecs: print_ipi_mode+0x0/0x30()
Calling initcall 0xc0512310: disable_boot_consoles+0x0/0x50()
initcall 0xc0512310: disable_boot_consoles+0x0/0x50() returned 0.
initcall 0xc0512310 ran for 0 msecs: disable_boot_consoles+0x0/0x50()
Calling initcall 0xc0513ab0: taskstats_init+0x0/0x60()
initcall 0xc0513ab0: taskstats_init+0x0/0x60() returned 0.
initcall 0xc0513ab0 ran for 0 msecs: taskstats_init+0x0/0x60()
Calling initcall 0xc0518630: random32_reseed+0x0/0x60()
initcall 0xc0518630: random32_reseed+0x0/0x60() returned 0.
initcall 0xc0518630 ran for 0 msecs: random32_reseed+0x0/0x60()
Calling initcall 0xc0518e20: pci_sysfs_init+0x0/0x50()
initcall 0xc0518e20: pci_sysfs_init+0x0/0x50() returned 0.
initcall 0xc0518e20 ran for 0 msecs: pci_sysfs_init+0x0/0x50()
Calling initcall 0xc051a900: seqgen_init+0x0/0x10()
initcall 0xc051a900: seqgen_init+0x0/0x10() returned 0.
initcall 0xc051a900 ran for 0 msecs: seqgen_init+0x0/0x10()
Calling initcall 0xc030ad00: scsi_complete_async_scans+0x0/0x100()
initcall 0xc030ad00: scsi_complete_async_scans+0x0/0x100() returned 0.
initcall 0xc030ad00 ran for 0 msecs: scsi_complete_async_scans+0x0/0x100()
Calling initcall 0xc05203e0: edd_init+0x0/0x280()
BIOS EDD facility v0.16 2004-Jun-25, 6 devices found
initcall 0xc05203e0: edd_init+0x0/0x280() returned 0.
initcall 0xc05203e0 ran for 2 msecs: edd_init+0x0/0x280()
Calling initcall 0xc0522f30: tcp_congestion_default+0x0/0x10()
initcall 0xc0522f30: tcp_congestion_default+0x0/0x10() returned 0.
initcall 0xc0522f30 ran for 0 msecs: tcp_congestion_default+0x0/0x10()
RAMDISK: Compressed image found at block 0
RAMDISK: incomplete write (-28 != 32768) 4194304
EXT3-fs: INFO: recovery required on readonly filesystem.
EXT3-fs: write access will be enabled during recovery.
(fs/jbd/recovery.c, 255): journal_recover: JBD: recovery, exit status 0, recovered transactions 102287 to 102300
(fs/jbd/recovery.c, 257): journal_recover: JBD: Replayed 1011 and revoked 0/34 blocks
kjournald starting.  Commit interval 5 seconds
EXT3-fs: recovery complete.
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem) readonly.
Freeing unused kernel memory: 296k freed
Write protecting the kernel read-only data: 976k
hostname used greatest stack depth: 6580 bytes left
uname used greatest stack depth: 6472 bytes left
mount used greatest stack depth: 5792 bytes left
hotplug used greatest stack depth: 5664 bytes left
hotplug used greatest stack depth: 5508 bytes left
EXT3 FS on hdc2, internal journal
Adding 1020116k swap on /dev/hdc3.  Priority:-1 extents:1 across:1020116k
kjournald starting.  Commit interval 5 seconds
EXT3 FS on hdc1, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
process `syslogd' is using obsolete setsockopt SO_BSDCOMPAT
BUG: unable to handle kernel NULL pointer dereference at virtual address 000002b0
 printing eip:
c0355075
*pde = 00000000
Oops: 0000 [#1]
SMP 
Modules linked in:
CPU:    0
EIP:    0060:[<c0355075>]    Not tainted VLI
EFLAGS: 00010246   (2.6.23-rc3 #3)
EIP is at net_rx_action+0x75/0x170
eax: 00000000   ebx: c1b6d298   ecx: 00000004   edx: 00000001
esi: 0000012c   edi: c054ada0   ebp: f5c1bb8c   esp: f5c1bb6c
ds: 007b   es: 007b   fs: 00d8  gs: 0033  ss: 0068
Process rpc.statd (pid: 1958, ti=f5c1a000 task=f6bf0f60 task.ti=f5c1a000)
Stack: f5c1bb78 fffef555 f5c1bb84 c1b6d298 c1b6d298 00000001 c04f5f58 c054ada0 
       f5c1bba8 c01263c7 0000000a 00000000 00000046 c04e3760 00000000 f5c1bbb4 
       c0126497 00000202 f5c1bbd0 c01266f5 00000246 c04e3760 c04e38e0 c04e3760 
Call Trace:
 [<c0103bfa>] show_trace_log_lvl+0x1a/0x30
 [<c0103cb9>] show_stack_log_lvl+0xa9/0xd0
 [<c0103ec9>] show_registers+0x1e9/0x2f0
 [<c01040e1>] die+0x111/0x260
 [<c0115cdc>] do_page_fault+0x18c/0x6a0
 [<c03d203a>] error_code+0x72/0x78
 [<c01263c7>] __do_softirq+0x87/0x100
 [<c0126497>] do_softirq+0x57/0x60
 [<c01266f5>] local_bh_enable+0xb5/0x150
 [<c0355748>] dev_queue_xmit+0xa8/0x330
 [<c035b11f>] neigh_resolve_output+0xcf/0x250
 [<c036fc53>] ip_output+0x1d3/0x2c0
 [<c036e4ff>] ip_push_pending_frames+0x25f/0x400
 [<c038b643>] udp_push_pending_frames+0x153/0x340
 [<c038c8c4>] udp_sendmsg+0x324/0x780
 [<c0392b44>] inet_sendmsg+0x34/0x60
 [<c0347d55>] sock_sendmsg+0xc5/0xf0
 [<c034870f>] sys_sendto+0xbf/0xe0
 [<c0349050>] sys_socketcall+0x1b0/0x280
 [<c0102b52>] sysenter_past_esp+0x5f/0x99
 =======================
Code: e8 21 9d de ff fb 8b 5d ec 39 5d e0 0f 84 8f 00 00 00 85 f6 0f 8e ac 00 00 00 a1 40 60 4f c0 39 45 e4 0f 85 9e 00 00 00 8b 43 38 <8b> 80 b0 02 00 00 85 c0 74 74 8d 43 18 89 df e8 e7 c8 07 00 64 
EIP: [<c0355075>] net_rx_action+0x75/0x170 SS:ESP 0068:f5c1bb6c
Kernel panic - not syncing: Fatal exception in interrupt

