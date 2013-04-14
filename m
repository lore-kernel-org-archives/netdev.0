From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH repost for-3.9] pci: avoid work_on_cpu for nested SRIOV
 probes
Date: Sun, 14 Apr 2013 15:58:55 +0300
Message-ID: <516AA80F.7040505@mellanox.com>
References: <20130411153030.GA22743@redhat.com> <20130411180517.GJ17641@mtj.dyndns.org> <20130411185853.GE23301@redhat.com> <20130411190408.GM17641@mtj.dyndns.org> <20130411191717.GB25515@redhat.com> <20130411192005.GN17641@mtj.dyndns.org> <20130411203053.GC25515@redhat.com> <20130411204104.GC11956@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="------------010600070305030002060908"
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Ming Lei <ming.lei@canonical.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Roland Dreier <roland@kernel.org>,
	netdev <netdev@vger.kernel.org>, Yan Burman <yanb@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Bjorn Helgaas <bhelgaas@google.com>,
	<linux-pci@vger.kernel.org>
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:54483 "EHLO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751397Ab3DNNAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Apr 2013 09:00:35 -0400
In-Reply-To: <20130411204104.GC11956@mtj.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------010600070305030002060908
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit

On 11/04/2013 23:41, Tejun Heo wrote:
> Hello,
>
> On Thu, Apr 11, 2013 at 11:30:53PM +0300, Michael S. Tsirkin wrote:
>> Okay, so you are saying it's a false-positive?
> Yeah, I think so.  It didn't actually lock up, right?  It it did,
> our analysis upto this point is likely to be completely wrong.
>
>> Want to send a patch so Or can try it out?
> Hmmm... something like the following on the workqueue side (completely untested).
>
> diff --git a/include/linux/workqueue.h b/include/linux/workqueue.h
> index 8afab27..899d470 100644
> --- a/include/linux/workqueue.h
> +++ b/include/linux/workqueue.h
> @@ -466,14 +466,21 @@ static inline bool __deprecated flush_delayed_work_sync(struct delayed_work *dwo
>   }
>   
>   #ifndef CONFIG_SMP
> -static inline long work_on_cpu(unsigned int cpu, long (*fn)(void *), void *arg)
> +static inline long work_on_cpu_nested(unsigned int cpu, long (*fn)(void *),
> +				      void *arg, int subclass)
>   {
>   	return fn(arg);
>   }
>   #else
> -long work_on_cpu(unsigned int cpu, long (*fn)(void *), void *arg);
> +long work_on_cpu_nested(unsigned int cpu, long (*fn)(void *), void *arg,
> +			int subclass);
>   #endif /* CONFIG_SMP */
>   
> +static inline long work_on_cpu(unsigned int cpu, long (*fn)(void *), void *arg)
> +{
> +	return work_on_cpu_nested(cpu, fn, arg, 0);
> +}
> +
>   #ifdef CONFIG_FREEZER
>   extern void freeze_workqueues_begin(void);
>   extern bool freeze_workqueues_busy(void);
> diff --git a/kernel/workqueue.c b/kernel/workqueue.c
> index 81f2457..c2be670 100644
> --- a/kernel/workqueue.c
> +++ b/kernel/workqueue.c
> @@ -3555,25 +3555,30 @@ static void work_for_cpu_fn(struct work_struct *work)
>   }
>   
>   /**
> - * work_on_cpu - run a function in user context on a particular cpu
> + * work_on_cpu_nested - run a function in user context on a particular cpu
>    * @cpu: the cpu to run on
>    * @fn: the function to run
>    * @arg: the function arg
> + * @subclass: lockdep subclass
>    *
>    * This will return the value @fn returns.
>    * It is up to the caller to ensure that the cpu doesn't go offline.
>    * The caller must not hold any locks which would prevent @fn from completing.
> + *
> + * XXX: explain @subclass
>    */
> -long work_on_cpu(unsigned int cpu, long (*fn)(void *), void *arg)
> +long work_on_cpu_nested(unsigned int cpu, long (*fn)(void *), void *arg,
> +			int subclass)
>   {
>   	struct work_for_cpu wfc = { .fn = fn, .arg = arg };
>   
>   	INIT_WORK_ONSTACK(&wfc.work, work_for_cpu_fn);
> +	lock_set_subclass(&wfc.work.lockdep_map, subclass, _RET_IP_);
>   	schedule_work_on(cpu, &wfc.work);
>   	flush_work(&wfc.work);
>   	return wfc.ret;
>   }
> -EXPORT_SYMBOL_GPL(work_on_cpu);
> +EXPORT_SYMBOL_GPL(work_on_cpu_nested);
>   #endif /* CONFIG_SMP */
>   
>   #ifdef CONFIG_FREEZER

Hi,

So the patch eliminated the lockdep warning for mlx4 nested probing 
sequence, but introduced lockdep warning for
00:13.0 PIC: Intel Corporation 7500/5520/5500/X58 I/O Hub I/OxAPIC 
Interrupt Controller (rev 22)

... see below the lockdep output and the lspci listings, attached is the 
full boot sequence dmesg
and my .config -  this I was running against the net git as of commit 
2e0cbf2cc2c9371f0aa198857d799175ffe231a6
"net: mvmdio: add select PHYLIB"

 From quick tests - the system is operative with the patch as it was 
without it - e.g mlx4 VFs probed on the host
is working OK and also the 1g Intel NIC.


We have holiday here Mon/Tues, so I will be able to test further patches Wed

Or.




=====================================
[ BUG: bad unlock balance detected! ]
3.9.0-rc6+ #53 Not tainted
-------------------------------------
swapper/0/1 is trying to release lock ((&wfc.work)) at:
[<ffffffff8122014c>] pci_device_probe+0xfc/0x120
but there are no more locks to release!

other info that might help us debug this:
2 locks held by swapper/0/1:
  #0:  (&__lockdep_no_validate__){......}, at: [<ffffffff812da443>] 
__driver_attach+0x53/0xb0
  #1:  (&__lockdep_no_validate__){......}, at: [<ffffffff812da451>] 
__driver_attach+0x61/0xb0

stack backtrace:
Pid: 1, comm: swapper/0 Not tainted 3.9.0-rc6+ #53
Call Trace:
[<ffffffff8122014c>] ? pci_device_probe+0xfc/0x120
  [<ffffffff81093529>] print_unlock_imbalance_bug+0xf9/0x100
  [<ffffffff8109616f>] lock_set_class+0x27f/0x7c0
  [<ffffffff81091d9e>] ? mark_held_locks+0x9e/0x130
  [<ffffffff8122014c>] ? pci_device_probe+0xfc/0x120
  [<ffffffff81066aeb>] work_on_cpu_nested+0x8b/0xc0
  [<ffffffff810633c0>] ? keventd_up+0x20/0x20
  [<ffffffff8121f420>] ? pci_pm_prepare+0x60/0x60
  [<ffffffff8122014c>] pci_device_probe+0xfc/0x120
  [<ffffffff812da0fa>] ? driver_sysfs_add+0x7a/0xb0
  [<ffffffff812da24f>] driver_probe_device+0x8f/0x230
  [<ffffffff812da493>] __driver_attach+0xa3/0xb0
  [<ffffffff812da3f0>] ? driver_probe_device+0x230/0x230
  [<ffffffff812da3f0>] ? driver_probe_device+0x230/0x230
  [<ffffffff812d86fc>] bus_for_each_dev+0x8c/0xb0
  [<ffffffff812da079>] driver_attach+0x19/0x20
  [<ffffffff812d91a0>] bus_add_driver+0x1f0/0x250
  [<ffffffff818bd596>] ? dmi_pcie_pme_disable_msi+0x21/0x21
  [<ffffffff812daadf>] driver_register+0x6f/0x150
  [<ffffffff818bd596>] ? dmi_pcie_pme_disable_msi+0x21/0x21
  [<ffffffff8122026f>] __pci_register_driver+0x5f/0x70
  [<ffffffff818bd5ff>] pcie_portdrv_init+0x69/0x7a
  [<ffffffff810001fd>] do_one_initcall+0x3d/0x170
  [<ffffffff81895943>] kernel_init_freeable+0x10d/0x19c
  [<ffffffff818959d2>] ? kernel_init_freeable+0x19c/0x19c
  [<ffffffff8145a040>] ? rest_init+0x160/0x160
  [<ffffffff8145a049>] kernel_init+0x9/0xf0
  [<ffffffff8146ca6c>] ret_from_fork+0x7c/0xb0
  [<ffffffff8145a040>] ? rest_init+0x160/0x160
ioapic: probe of 0000:00:13.0 failed with error -22
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
intel_idle: MWAIT substates: 0x1120
intel_idle: v0.4 model 0x2C
intel_idle: lapic_timer_reliable_states 0xffffffff
ACPI: Requesting acpi_cpufreq
ERST: Failed to get Error Log Address Range.

# lspci
00:00.0 Host bridge: Intel Corporation 5520 I/O Hub to ESI Port (rev 22)
00:01.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express 
Root Port 1 (rev 22)
00:03.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express 
Root Port 3 (rev 22)
00:05.0 PCI bridge: Intel Corporation 5520/X58 I/O Hub PCI Express Root 
Port 5 (rev 22)
00:07.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express 
Root Port 7 (rev 22)
00:09.0 PCI bridge: Intel Corporation 7500/5520/5500/X58 I/O Hub PCI 
Express Root Port 9 (rev 22)
00:13.0 PIC: Intel Corporation 7500/5520/5500/X58 I/O Hub I/OxAPIC 
Interrupt Controller (rev 22)
00:14.0 PIC: Intel Corporation 7500/5520/5500/X58 I/O Hub System 
Management Registers (rev 22)
00:14.1 PIC: Intel Corporation 7500/5520/5500/X58 I/O Hub GPIO and 
Scratch Pad Registers (rev 22)
00:14.2 PIC: Intel Corporation 7500/5520/5500/X58 I/O Hub Control Status 
and RAS Registers (rev 22)
00:14.3 PIC: Intel Corporation 7500/5520/5500/X58 I/O Hub Throttle 
Registers (rev 22)
00:16.0 System peripheral: Intel Corporation 5520/5500/X58 Chipset 
QuickData Technology Device (rev 22)
00:16.1 System peripheral: Intel Corporation 5520/5500/X58 Chipset 
QuickData Technology Device (rev 22)
00:16.2 System peripheral: Intel Corporation 5520/5500/X58 Chipset 
QuickData Technology Device (rev 22)
00:16.3 System peripheral: Intel Corporation 5520/5500/X58 Chipset 
QuickData Technology Device (rev 22)
00:16.4 System peripheral: Intel Corporation 5520/5500/X58 Chipset 
QuickData Technology Device (rev 22)
00:16.5 System peripheral: Intel Corporation 5520/5500/X58 Chipset 
QuickData Technology Device (rev 22)
00:16.6 System peripheral: Intel Corporation 5520/5500/X58 Chipset 
QuickData Technology Device (rev 22)
00:16.7 System peripheral: Intel Corporation 5520/5500/X58 Chipset 
QuickData Technology Device (rev 22)
00:1a.0 USB controller: Intel Corporation 82801JI (ICH10 Family) USB 
UHCI Controller #4
00:1a.1 USB controller: Intel Corporation 82801JI (ICH10 Family) USB 
UHCI Controller #5
00:1a.2 USB controller: Intel Corporation 82801JI (ICH10 Family) USB 
UHCI Controller #6
00:1a.7 USB controller: Intel Corporation 82801JI (ICH10 Family) USB2 
EHCI Controller #2
00:1d.0 USB controller: Intel Corporation 82801JI (ICH10 Family) USB 
UHCI Controller #1
00:1d.1 USB controller: Intel Corporation 82801JI (ICH10 Family) USB 
UHCI Controller #2
00:1d.2 USB controller: Intel Corporation 82801JI (ICH10 Family) USB 
UHCI Controller #3
00:1d.7 USB controller: Intel Corporation 82801JI (ICH10 Family) USB2 
EHCI Controller #1
00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev 90)
00:1f.0 ISA bridge: Intel Corporation 82801JIR (ICH10R) LPC Interface 
Controller
00:1f.2 IDE interface: Intel Corporation 82801JI (ICH10 Family) 4 port 
SATA IDE Controller #1
00:1f.3 SMBus: Intel Corporation 82801JI (ICH10 Family) SMBus Controller
00:1f.5 IDE interface: Intel Corporation 82801JI (ICH10 Family) 2 port 
SATA IDE Controller #2
01:00.0 Ethernet controller: Intel Corporation 82576 Gigabit Network 
Connection (rev 01)
01:00.1 Ethernet controller: Intel Corporation 82576 Gigabit Network 
Connection (rev 01)
04:00.0 Network controller: Mellanox Technologies MT27500 Family 
[ConnectX-3]
04:00.1 Network controller: Mellanox Technologies MT27500 Family 
[ConnectX-3 Virtual Function]
04:00.2 Network controller: Mellanox Technologies MT27500 Family 
[ConnectX-3 Virtual Function]
04:00.3 Network controller: Mellanox Technologies MT27500 Family 
[ConnectX-3 Virtual Function]
05:00.0 Ethernet controller: Intel Corporation 82599EB 10-Gigabit 
SFI/SFP+ Network Connection (rev 01)
05:00.1 Ethernet controller: Intel Corporation 82599EB 10-Gigabit 
SFI/SFP+ Network Connection (rev 01)
05:10.0 Ethernet controller: Intel Corporation 82599 Ethernet Controller 
Virtual Function (rev 01)
05:10.1 Ethernet controller: Intel Corporation 82599 Ethernet Controller 
Virtual Function (rev 01)
07:01.0 VGA compatible controller: Matrox Electronics Systems Ltd. MGA 
G200eW WPCM450 (rev 0a)
fe:00.0 Host bridge: Intel Corporation Xeon 5600 Series QuickPath 
Architecture Generic Non-core Registers (rev 02)
fe:00.1 Host bridge: Intel Corporation Xeon 5600 Series QuickPath 
Architecture System Address Decoder (rev 02)
fe:02.0 Host bridge: Intel Corporation Xeon 5600 Series QPI Link 0 (rev 02)
fe:02.1 Host bridge: Intel Corporation Xeon 5600 Series QPI Physical 0 
(rev 02)
fe:02.2 Host bridge: Intel Corporation Xeon 5600 Series Mirror Port Link 
0 (rev 02)
fe:02.3 Host bridge: Intel Corporation Xeon 5600 Series Mirror Port Link 
1 (rev 02)
fe:02.4 Host bridge: Intel Corporation Xeon 5600 Series QPI Link 1 (rev 02)
fe:02.5 Host bridge: Intel Corporation Xeon 5600 Series QPI Physical 1 
(rev 02)
fe:03.0 Host bridge: Intel Corporation Xeon 5600 Series Integrated 
Memory Controller Registers (rev 02)
fe:03.1 Host bridge: Intel Corporation Xeon 5600 Series Integrated 
Memory Controller Target Address Decoder (rev 02)
fe:03.2 Host bridge: Intel Corporation Xeon 5600 Series Integrated 
Memory Controller RAS Registers (rev 02)
fe:03.4 Host bridge: Intel Corporation Xeon 5600 Series Integrated 
Memory Controller Test Registers (rev 02)
fe:04.0 Host bridge: Intel Corporation Xeon 5600 Series Integrated 
Memory Controller Channel 0 Control (rev 02)
fe:04.1 Host bridge: Intel Corporation Xeon 5600 Series Integrated 
Memory Controller Channel 0 Address (rev 02)
fe:04.2 Host bridge: Intel Corporation Xeon 5600 Series Integrated 
Memory Controller Channel 0 Rank (rev 02)
fe:04.3 Host bridge: Intel Corporation Xeon 5600 Series Integrated 
Memory Controller Channel 0 Thermal Control (rev 02)
fe:05.0 Host bridge: Intel Corporation Xeon 5600 Series Integrated 
Memory Controller Channel 1 Control (rev 02)
fe:05.1 Host bridge: Intel Corporation Xeon 5600 Series Integrated 
Memory Controller Channel 1 Address (rev 02)
fe:05.2 Host bridge: Intel Corporation Xeon 5600 Series Integrated 
Memory Controller Channel 1 Rank (rev 02)
fe:05.3 Host bridge: Intel Corporation Xeon 5600 Series Integrated 
Memory Controller Channel 1 Thermal Control (rev 02)
fe:06.0 Host bridge: Intel Corporation Xeon 5600 Series Integrated 
Memory Controller Channel 2 Control (rev 02)
fe:06.1 Host bridge: Intel Corporation Xeon 5600 Series Integrated 
Memory Controller Channel 2 Address (rev 02)
fe:06.2 Host bridge: Intel Corporation Xeon 5600 Series Integrated 
Memory Controller Channel 2 Rank (rev 02)
fe:06.3 Host bridge: Intel Corporation Xeon 5600 Series Integrated 
Memory Controller Channel 2 Thermal Control (rev 02)
ff:00.0 Host bridge: Intel Corporation Xeon 5600 Series QuickPath 
Architecture Generic Non-core Registers (rev 02)
ff:00.1 Host bridge: Intel Corporation Xeon 5600 Series QuickPath 
Architecture System Address Decoder (rev 02)
ff:02.0 Host bridge: Intel Corporation Xeon 5600 Series QPI Link 0 (rev 02)
ff:02.1 Host bridge: Intel Corporation Xeon 5600 Series QPI Physical 0 
(rev 02)
ff:02.2 Host bridge: Intel Corporation Xeon 5600 Series Mirror Port Link 
0 (rev 02)
ff:02.3 Host bridge: Intel Corporation Xeon 5600 Series Mirror Port Link 
1 (rev 02)
ff:02.4 Host bridge: Intel Corporation Xeon 5600 Series QPI Link 1 (rev 02)
ff:02.5 Host bridge: Intel Corporation Xeon 5600 Series QPI Physical 1 
(rev 02)
ff:03.0 Host bridge: Intel Corporation Xeon 5600 Series Integrated 
Memory Controller Registers (rev 02)
ff:03.1 Host bridge: Intel Corporation Xeon 5600 Series Integrated 
Memory Controller Target Address Decoder (rev 02)
ff:03.2 Host bridge: Intel Corporation Xeon 5600 Series Integrated 
Memory Controller RAS Registers (rev 02)
ff:03.4 Host bridge: Intel Corporation Xeon 5600 Series Integrated 
Memory Controller Test Registers (rev 02)
ff:04.0 Host bridge: Intel Corporation Xeon 5600 Series Integrated 
Memory Controller Channel 0 Control (rev 02)
ff:04.1 Host bridge: Intel Corporation Xeon 5600 Series Integrated 
Memory Controller Channel 0 Address (rev 02)
ff:04.2 Host bridge: Intel Corporation Xeon 5600 Series Integrated 
Memory Controller Channel 0 Rank (rev 02)
ff:04.3 Host bridge: Intel Corporation Xeon 5600 Series Integrated 
Memory Controller Channel 0 Thermal Control (rev 02)
ff:05.0 Host bridge: Intel Corporation Xeon 5600 Series Integrated 
Memory Controller Channel 1 Control (rev 02)
ff:05.1 Host bridge: Intel Corporation Xeon 5600 Series Integrated 
Memory Controller Channel 1 Address (rev 02)
ff:05.2 Host bridge: Intel Corporation Xeon 5600 Series Integrated 
Memory Controller Channel 1 Rank (rev 02)
ff:05.3 Host bridge: Intel Corporation Xeon 5600 Series Integrated 
Memory Controller Channel 1 Thermal Control (rev 02)
ff:06.0 Host bridge: Intel Corporation Xeon 5600 Series Integrated 
Memory Controller Channel 2 Control (rev 02)
ff:06.1 Host bridge: Intel Corporation Xeon 5600 Series Integrated 
Memory Controller Channel 2 Address (rev 02)
ff:06.2 Host bridge: Intel Corporation Xeon 5600 Series Integrated 
Memory Controller Channel 2 Rank (rev 02)
ff:06.3 Host bridge: Intel Corporation Xeon 5600 Series Integrated 
Memory Controller Channel 2 Thermal Control (rev 02)



--------------010600070305030002060908
Content-Type: text/plain; charset="windows-1255";
	name="dmesg-net-2e0cbf2-tejun-patched"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="dmesg-net-2e0cbf2-tejun-patched"

Linux version 3.9.0-rc6+ (root@vsa3.lab.mtl.com) (gcc version 4.4.6 20110731 (Red Hat 4.4.6-3) (GCC) ) #53 SMP PREEMPT Sun Apr 14 16:32:35 IDT 2013
Command line: root=UUID=b660033b-759d-4155-9fb6-67f671cf460e console=tty0 console=ttyS0,115200n8 rhgb intel_iommu=on 
e820: BIOS-provided physical RAM map:
BIOS-e820: [mem 0x0000000000000000-0x00000000000997ff] usable
BIOS-e820: [mem 0x0000000000099800-0x000000000009ffff] reserved
BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reserved
BIOS-e820: [mem 0x0000000000100000-0x00000000bf77ffff] usable
BIOS-e820: [mem 0x00000000bf78e000-0x00000000bf78ffff] type 9
BIOS-e820: [mem 0x00000000bf790000-0x00000000bf79dfff] ACPI data
BIOS-e820: [mem 0x00000000bf79e000-0x00000000bf7cffff] ACPI NVS
BIOS-e820: [mem 0x00000000bf7d0000-0x00000000bf7dffff] reserved
BIOS-e820: [mem 0x00000000bf7ec000-0x00000000bfffffff] reserved
BIOS-e820: [mem 0x00000000e0000000-0x00000000efffffff] reserved
BIOS-e820: [mem 0x00000000fee00000-0x00000000fee00fff] reserved
BIOS-e820: [mem 0x00000000ffc00000-0x00000000ffffffff] reserved
BIOS-e820: [mem 0x0000000100000000-0x000000063fffffff] usable
NX (Execute Disable) protection: active
SMBIOS 2.6 present.
DMI: Supermicro X8DTU/X8DTU, BIOS 2.1c       08/03/2012
e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
e820: remove [mem 0x000a0000-0x000fffff] usable
No AGP bridge found
e820: last_pfn = 0x640000 max_arch_pfn = 0x400000000
MTRR default type: uncachable
MTRR fixed ranges enabled:
  00000-9FFFF write-back
  A0000-BFFFF uncachable
  C0000-CBFFF write-protect
  CC000-DFFFF uncachable
  E0000-E3FFF write-protect
  E4000-E7FFF write-through
  E8000-EBFFF write-protect
  EC000-EFFFF write-through
  F0000-FFFFF write-protect
MTRR variable ranges enabled:
  0 base 0000000000 mask FC00000000 write-back
  1 base 0400000000 mask FE00000000 write-back
  2 base 0600000000 mask FFC0000000 write-back
  3 base 00C0000000 mask FFC0000000 uncachable
  4 base 00BF800000 mask FFFF800000 uncachable
  5 disabled
  6 disabled
  7 disabled
  8 disabled
  9 disabled
x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
original variable MTRRs
reg 0, base: 0GB, range: 16GB, type WB
reg 1, base: 16GB, range: 8GB, type WB
reg 2, base: 24GB, range: 1GB, type WB
reg 3, base: 3GB, range: 1GB, type UC
reg 4, base: 3064MB, range: 8MB, type UC
total RAM covered: 24568M
Found optimal setting for mtrr clean up
 gran_size: 64K 	chunk_size: 16M 	num_reg: 7  	lose cover RAM: 0G
New variable MTRRs
reg 0, base: 0GB, range: 2GB, type WB
reg 1, base: 2GB, range: 1GB, type WB
reg 2, base: 3064MB, range: 8MB, type UC
reg 3, base: 4GB, range: 4GB, type WB
reg 4, base: 8GB, range: 8GB, type WB
reg 5, base: 16GB, range: 8GB, type WB
reg 6, base: 24GB, range: 1GB, type WB
e820: update [mem 0xbf800000-0xffffffff] usable ==> reserved
e820: last_pfn = 0xbf780 max_arch_pfn = 0x400000000
found SMP MP-table at [mem 0x000ff780-0x000ff78f] mapped at [ffff8800000ff780]
Base memory trampoline at [ffff880000092000] 92000 size 28672
Using GB pages for direct mapping
init_memory_mapping: [mem 0x00000000-0x000fffff]
 [mem 0x00000000-0x000fffff] page 4k
BRK [0x021e4000, 0x021e4fff] PGTABLE
BRK [0x021e5000, 0x021e5fff] PGTABLE
BRK [0x021e6000, 0x021e6fff] PGTABLE
init_memory_mapping: [mem 0x63fe00000-0x63fffffff]
 [mem 0x63fe00000-0x63fffffff] page 1G
init_memory_mapping: [mem 0x63c000000-0x63fdfffff]
 [mem 0x63c000000-0x63fdfffff] page 1G
init_memory_mapping: [mem 0x600000000-0x63bffffff]
 [mem 0x600000000-0x63bffffff] page 1G
init_memory_mapping: [mem 0x00100000-0xbf77ffff]
 [mem 0x00100000-0x001fffff] page 4k
 [mem 0x00200000-0x3fffffff] page 2M
 [mem 0x40000000-0x7fffffff] page 1G
 [mem 0x80000000-0xbf5fffff] page 2M
 [mem 0xbf600000-0xbf77ffff] page 4k
init_memory_mapping: [mem 0x100000000-0x5ffffffff]
 [mem 0x100000000-0x5ffffffff] page 1G
RAMDISK: [mem 0x37b70000-0x37feffff]
ACPI: RSDP 00000000000face0 00024 (v02 ACPIAM)
ACPI: XSDT 00000000bf790100 0008C (v01 SMCI            20120803 MSFT 00000097)
ACPI: FACP 00000000bf790290 000F4 (v03 080312 FACP1521 20120803 MSFT 00000097)
ACPI: DSDT 00000000bf7906a0 06580 (v01  10600 10600000 00000000 INTL 20051117)
ACPI: FACS 00000000bf79e000 00040
ACPI: APIC 00000000bf790390 0011E (v01 080312 APIC1521 20120803 MSFT 00000097)
ACPI: MCFG 00000000bf7904b0 0003C (v01 080312 OEMMCFG  20120803 MSFT 00000097)
ACPI: SLIT 00000000bf7904f0 00030 (v01 080312 OEMSLIT  20120803 MSFT 00000097)
ACPI: OEMB 00000000bf79e040 00086 (v01 080312 OEMB1521 20120803 MSFT 00000097)
ACPI: SRAT 00000000bf79a6a0 00190 (v01 080312 OEMSRAT  00000001 INTL 00000001)
ACPI: HPET 00000000bf79a830 00038 (v01 080312 OEMHPET  20120803 MSFT 00000097)
ACPI: DMAR 00000000bf79e0d0 00130 (v01    AMI  OEMDMAR 00000001 MSFT 00000097)
ACPI: SSDT 00000000bf7a08f0 00363 (v01 DpgPmm    CpuPm 00000012 INTL 20051117)
ACPI: EINJ 00000000bf79a870 00130 (v01  AMIER AMI_EINJ 20120803 MSFT 00000097)
ACPI: BERT 00000000bf79aa00 00030 (v01  AMIER AMI_BERT 20120803 MSFT 00000097)
ACPI: ERST 00000000bf79aa30 001B0 (v01  AMIER AMI_ERST 20120803 MSFT 00000097)
ACPI: HEST 00000000bf79abe0 000A8 (v01  AMIER ABC_HEST 20120803 MSFT 00000097)
ACPI: Local APIC address 0xfee00000
SRAT: PXM 0 -> APIC 0x00 -> Node 0
SRAT: PXM 0 -> APIC 0x02 -> Node 0
SRAT: PXM 0 -> APIC 0x04 -> Node 0
SRAT: PXM 0 -> APIC 0x10 -> Node 0
SRAT: PXM 0 -> APIC 0x12 -> Node 0
SRAT: PXM 0 -> APIC 0x14 -> Node 0
SRAT: PXM 1 -> APIC 0x20 -> Node 1
SRAT: PXM 1 -> APIC 0x22 -> Node 1
SRAT: PXM 1 -> APIC 0x24 -> Node 1
SRAT: PXM 1 -> APIC 0x30 -> Node 1
SRAT: PXM 1 -> APIC 0x32 -> Node 1
SRAT: PXM 1 -> APIC 0x34 -> Node 1
SRAT: Node 0 PXM 0 [mem 0x00000000-0x0009ffff]
SRAT: Node 0 PXM 0 [mem 0x00100000-0xbfffffff]
SRAT: Node 0 PXM 0 [mem 0x100000000-0x33fffffff]
SRAT: Node 1 PXM 1 [mem 0x340000000-0x63fffffff]
NUMA: Initialized distance table, cnt=2
NUMA: Node 0 [mem 0x00000000-0x0009ffff] + [mem 0x00100000-0xbfffffff] -> [mem 0x00000000-0xbfffffff]
NUMA: Node 0 [mem 0x00000000-0xbfffffff] + [mem 0x100000000-0x33fffffff] -> [mem 0x00000000-0x33fffffff]
Initmem setup node 0 [mem 0x00000000-0x33fffffff]
  NODE_DATA [mem 0x33fffb000-0x33fffffff]
Initmem setup node 1 [mem 0x340000000-0x63fffffff]
  NODE_DATA [mem 0x63fff8000-0x63fffcfff]
 [ffffea0000000000-ffffea000cffffff] PMD -> [ffff880333e00000-ffff88033fdfffff] on node 0
 [ffffea000d000000-ffffea0018ffffff] PMD -> [ffff880633600000-ffff88063f5fffff] on node 1
Zone ranges:
  DMA      [mem 0x00001000-0x00ffffff]
  DMA32    [mem 0x01000000-0xffffffff]
  Normal   [mem 0x100000000-0x63fffffff]
Movable zone start for each node
Early memory node ranges
  node   0: [mem 0x00001000-0x00098fff]
  node   0: [mem 0x00100000-0xbf77ffff]
  node   0: [mem 0x100000000-0x33fffffff]
  node   1: [mem 0x340000000-0x63fffffff]
On node 0 totalpages: 3143448
  DMA zone: 64 pages used for memmap
  DMA zone: 22 pages reserved
  DMA zone: 3992 pages, LIFO batch:0
  DMA32 zone: 12190 pages used for memmap
  DMA32 zone: 780160 pages, LIFO batch:31
  Normal zone: 36864 pages used for memmap
  Normal zone: 2359296 pages, LIFO batch:31
On node 1 totalpages: 3145728
  Normal zone: 49152 pages used for memmap
  Normal zone: 3145728 pages, LIFO batch:31
ACPI: PM-Timer IO Port: 0x808
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x04] enabled)
ACPI: LAPIC (acpi_id[0x04] lapic_id[0x10] enabled)
ACPI: LAPIC (acpi_id[0x05] lapic_id[0x12] enabled)
ACPI: LAPIC (acpi_id[0x06] lapic_id[0x14] enabled)
ACPI: LAPIC (acpi_id[0x07] lapic_id[0x20] enabled)
ACPI: LAPIC (acpi_id[0x08] lapic_id[0x22] enabled)
ACPI: LAPIC (acpi_id[0x09] lapic_id[0x24] enabled)
ACPI: LAPIC (acpi_id[0x0a] lapic_id[0x30] enabled)
ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x32] enabled)
ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x34] enabled)
ACPI: LAPIC (acpi_id[0x0d] lapic_id[0x8c] disabled)
ACPI: LAPIC (acpi_id[0x0e] lapic_id[0x8d] disabled)
ACPI: LAPIC (acpi_id[0x0f] lapic_id[0x8e] disabled)
ACPI: LAPIC (acpi_id[0x10] lapic_id[0x8f] disabled)
ACPI: LAPIC (acpi_id[0x11] lapic_id[0x90] disabled)
ACPI: LAPIC (acpi_id[0x12] lapic_id[0x91] disabled)
ACPI: LAPIC (acpi_id[0x13] lapic_id[0x92] disabled)
ACPI: LAPIC (acpi_id[0x14] lapic_id[0x93] disabled)
ACPI: LAPIC (acpi_id[0x15] lapic_id[0x94] disabled)
ACPI: LAPIC (acpi_id[0x16] lapic_id[0x95] disabled)
ACPI: LAPIC (acpi_id[0x17] lapic_id[0x96] disabled)
ACPI: LAPIC (acpi_id[0x18] lapic_id[0x97] disabled)
ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
ACPI: IOAPIC (id[0x01] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 1, version 32, address 0xfec00000, GSI 0-23
ACPI: IOAPIC (id[0x03] address[0xfec8a000] gsi_base[24])
IOAPIC[1]: apic_id 3, version 32, address 0xfec8a000, GSI 24-47
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Using ACPI (MADT) for SMP configuration information
ACPI: HPET id: 0x8086a301 base: 0xfed00000
smpboot: 24 Processors exceeds NR_CPUS limit of 16
smpboot: Allowing 16 CPUs, 4 hotplug CPUs
nr_irqs_gsi: 64
e820: [mem 0xc0000000-0xdfffffff] available for PCI devices
setup_percpu: NR_CPUS:16 nr_cpumask_bits:16 nr_cpu_ids:16 nr_node_ids:2
PERCPU: Embedded 26 pages/cpu @ffff880333c00000 s77056 r8192 d21248 u262144
pcpu-alloc: s77056 r8192 d21248 u262144 alloc=1*2097152
pcpu-alloc: [0] 00 01 02 03 04 05 12 14 [1] 06 07 08 09 10 11 13 15 
Built 2 zonelists in Zone order, mobility grouping on.  Total pages: 6190884
Policy zone: Normal
Kernel command line: root=UUID=b660033b-759d-4155-9fb6-67f671cf460e console=tty0 console=ttyS0,115200n8 rhgb intel_iommu=on 
Intel-IOMMU: enabled
PID hash table entries: 4096 (order: 3, 32768 bytes)
__ex_table already sorted, skipping sort
Checking aperture...
No AGP bridge found
Calgary: detecting Calgary via BIOS EBDA area
Calgary: Unable to locate Rio Grande table in EBDA - bailing!
Memory: 24671856k/26214400k available (4547k kernel code, 1057696k absent, 484848k reserved, 4157k data, 848k init)
SLUB: Genslabs=15, HWalign=64, Order=0-3, MinObjects=0, CPUs=16, Nodes=2
Preemptible hierarchical RCU implementation.
	RCU lockdep checking is enabled.
	Additional per-CPU info printed with stalls.
NR_IRQS:4352 nr_irqs:1216 16
Console: colour VGA+ 80x25
console [tty0] enabled
console [ttyS0] enabled
Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
... MAX_LOCKDEP_SUBCLASSES:  8
... MAX_LOCK_DEPTH:          48
... MAX_LOCKDEP_KEYS:        8191
... CLASSHASH_SIZE:          4096
... MAX_LOCKDEP_ENTRIES:     16384
... MAX_LOCKDEP_CHAINS:      32768
... CHAINHASH_SIZE:          16384
 memory used by lock dependency info: 5855 kB
 per task-struct memory footprint: 1920 bytes
hpet clockevent registered
tsc: Fast TSC calibration failed
tsc: PIT calibration matches HPET. 1 loops
tsc: Detected 2666.762 MHz processor
Calibrating delay loop (skipped), value calculated using timer frequency.. 5333.52 BogoMIPS (lpj=10667048)
pid_max: default: 32768 minimum: 301
Security Framework initialized
Dentry cache hash table entries: 4194304 (order: 13, 33554432 bytes)
Inode-cache hash table entries: 2097152 (order: 12, 16777216 bytes)
Mount-cache hash table entries: 256
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
ENERGY_PERF_BIAS: Set to 'normal', was 'performance'
ENERGY_PERF_BIAS: View and update with x86_energy_perf_policy(8)
mce: CPU supports 9 MCE banks
CPU0: Thermal monitoring enabled (TM1)
Last level iTLB entries: 4KB 512, 2MB 7, 4MB 7
Last level dTLB entries: 4KB 512, 2MB 32, 4MB 32
tlb_flushall_shift: 6
Freeing SMP alternatives: 16k freed
ACPI: Core revision 20130117
ACPI: All ACPI Tables successfully acquired
Switched APIC routing to physical flat.
..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
smpboot: CPU0: Intel(R) Xeon(R) CPU           X5650  @ 2.67GHz (fam: 06, model: 2c, stepping: 02)
Performance Events: PEBS fmt1+, 16-deep LBR, Westmere events, Intel PMU driver.
perf_event_intel: CPUID marked event: 'bus cycles' unavailable
... version:                3
... bit width:              48
... generic registers:      4
... value mask:             0000ffffffffffff
... max period:             000000007fffffff
... fixed-purpose events:   3
... event mask:             000000070000000f
SMP alternatives: lockdep: fixing up alternatives
NMI watchdog: enabled on all CPUs, permanently consumes one hw-PMU counter.
smpboot: Booting Node   0, Processors  #1
SMP alternatives: lockdep: fixing up alternatives
 #2
SMP alternatives: lockdep: fixing up alternatives
 #3
SMP alternatives: lockdep: fixing up alternatives
 #4
SMP alternatives: lockdep: fixing up alternatives
 #5
SMP alternatives: lockdep: fixing up alternatives
 OK
smpboot: Booting Node   1, Processors  #6
SMP alternatives: lockdep: fixing up alternatives
 #7
SMP alternatives: lockdep: fixing up alternatives
 #8
SMP alternatives: lockdep: fixing up alternatives
 #9
SMP alternatives: lockdep: fixing up alternatives
 #10
SMP alternatives: lockdep: fixing up alternatives
 #11
Brought up 12 CPUs
smpboot: Total of 12 processors activated (64802.88 BogoMIPS)
PM: Registering ACPI NVS region [mem 0xbf79e000-0xbf7cffff] (204800 bytes)
NET: Registered protocol family 16
ACPI: bus type PCI registered
PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xe0000000-0xefffffff] (base 0xe0000000)
PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved in E820
PCI: Using configuration type 1 for base access
bio: create slab <bio-0> at 0
ACPI: Added _OSI(Module Device)
ACPI: Added _OSI(Processor Device)
ACPI: Added _OSI(3.0 _SCP Extensions)
ACPI: Added _OSI(Processor Aggregator Device)
ACPI: EC: Look up EC in DSDT
ACPI: Executed 1 blocks of module-level executable AML code
ACPI: SSDT 00000000bf79e200 026E8 (v01 DpgPmm  P001Ist 00000011 INTL 20051117)
ACPI: Dynamic OEM Table Load:
ACPI: SSDT           (null) 026E8 (v01 DpgPmm  P001Ist 00000011 INTL 20051117)
ACPI: Interpreter enabled
ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S2_] (20130117/hwxface-568)
ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S3_] (20130117/hwxface-568)
ACPI: (supports S0 S1 S5)
ACPI: Using IOAPIC for interrupt routing
HEST: Table parsing has been initialized.
PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
acpi PNP0A08:00: host bridge window expanded to [mem 0xf0000000-0xfed8ffff]; [mem 0xfed40000-0xfed44fff] ignored
PCI host bridge to bus 0000:00
pci_bus 0000:00: root bus resource [bus 00-ff]
pci_bus 0000:00: root bus resource [io  0x0000-0x03af]
pci_bus 0000:00: root bus resource [io  0x03e0-0x0cf7]
pci_bus 0000:00: root bus resource [io  0x03b0-0x03bb]
pci_bus 0000:00: root bus resource [io  0x03c0-0x03df]
pci_bus 0000:00: root bus resource [io  0x0d00-0xefff]
pci_bus 0000:00: root bus resource [io  0xf000-0xffff]
pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff]
pci_bus 0000:00: root bus resource [mem 0x000d0000-0x000dffff]
pci_bus 0000:00: root bus resource [mem 0xc0000000-0xdfffffff]
pci_bus 0000:00: root bus resource [mem 0xf0000000-0xfed8ffff]
pci 0000:00:00.0: [8086:3406] type 00 class 0x060000
pci 0000:00:00.0: PME# supported from D0 D3hot D3cold
pci 0000:00:01.0: [8086:3408] type 01 class 0x060400
pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
pci 0000:00:01.0: System wakeup disabled by ACPI
pci 0000:00:03.0: [8086:340a] type 01 class 0x060400
pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
pci 0000:00:03.0: System wakeup disabled by ACPI
pci 0000:00:05.0: [8086:340c] type 01 class 0x060400
pci 0000:00:05.0: PME# supported from D0 D3hot D3cold
pci 0000:00:05.0: System wakeup disabled by ACPI
pci 0000:00:07.0: [8086:340e] type 01 class 0x060400
pci 0000:00:07.0: PME# supported from D0 D3hot D3cold
pci 0000:00:07.0: System wakeup disabled by ACPI
pci 0000:00:09.0: [8086:3410] type 01 class 0x060400
pci 0000:00:09.0: PME# supported from D0 D3hot D3cold
pci 0000:00:09.0: System wakeup disabled by ACPI
pci 0000:00:13.0: [8086:342d] type 00 class 0x080020
pci 0000:00:13.0: reg 10: [mem 0xfec8a000-0xfec8afff]
pci 0000:00:13.0: PME# supported from D0 D3hot D3cold
pci 0000:00:14.0: [8086:342e] type 00 class 0x080000
pci 0000:00:14.1: [8086:3422] type 00 class 0x080000
pci 0000:00:14.2: [8086:3423] type 00 class 0x080000
pci 0000:00:14.3: [8086:3438] type 00 class 0x080000
pci 0000:00:16.0: [8086:3430] type 00 class 0x088000
pci 0000:00:16.0: reg 10: [mem 0xfbef8000-0xfbefbfff 64bit]
pci 0000:00:16.1: [8086:3431] type 00 class 0x088000
pci 0000:00:16.1: reg 10: [mem 0xfbef4000-0xfbef7fff 64bit]
pci 0000:00:16.2: [8086:3432] type 00 class 0x088000
pci 0000:00:16.2: reg 10: [mem 0xfbef0000-0xfbef3fff 64bit]
pci 0000:00:16.3: [8086:3433] type 00 class 0x088000
pci 0000:00:16.3: reg 10: [mem 0xfbeec000-0xfbeeffff 64bit]
pci 0000:00:16.4: [8086:3429] type 00 class 0x088000
pci 0000:00:16.4: reg 10: [mem 0xfbee8000-0xfbeebfff 64bit]
pci 0000:00:16.5: [8086:342a] type 00 class 0x088000
pci 0000:00:16.5: reg 10: [mem 0xfbee4000-0xfbee7fff 64bit]
pci 0000:00:16.6: [8086:342b] type 00 class 0x088000
pci 0000:00:16.6: reg 10: [mem 0xfbee0000-0xfbee3fff 64bit]
pci 0000:00:16.7: [8086:342c] type 00 class 0x088000
pci 0000:00:16.7: reg 10: [mem 0xfbedc000-0xfbedffff 64bit]
pci 0000:00:1a.0: [8086:3a37] type 00 class 0x0c0300
pci 0000:00:1a.0: reg 20: [io  0xcc00-0xcc1f]
pci 0000:00:1a.0: System wakeup disabled by ACPI
pci 0000:00:1a.1: [8086:3a38] type 00 class 0x0c0300
pci 0000:00:1a.1: reg 20: [io  0xc880-0xc89f]
pci 0000:00:1a.1: System wakeup disabled by ACPI
pci 0000:00:1a.2: [8086:3a39] type 00 class 0x0c0300
pci 0000:00:1a.2: reg 20: [io  0xc800-0xc81f]
pci 0000:00:1a.2: System wakeup disabled by ACPI
pci 0000:00:1a.7: [8086:3a3c] type 00 class 0x0c0320
pci 0000:00:1a.7: reg 10: [mem 0xfbeda000-0xfbeda3ff]
pci 0000:00:1a.7: PME# supported from D0 D3hot D3cold
pci 0000:00:1a.7: System wakeup disabled by ACPI
pci 0000:00:1d.0: [8086:3a34] type 00 class 0x0c0300
pci 0000:00:1d.0: reg 20: [io  0xc480-0xc49f]
pci 0000:00:1d.0: System wakeup disabled by ACPI
pci 0000:00:1d.1: [8086:3a35] type 00 class 0x0c0300
pci 0000:00:1d.1: reg 20: [io  0xc400-0xc41f]
pci 0000:00:1d.1: System wakeup disabled by ACPI
pci 0000:00:1d.2: [8086:3a36] type 00 class 0x0c0300
pci 0000:00:1d.2: reg 20: [io  0xc080-0xc09f]
pci 0000:00:1d.2: System wakeup disabled by ACPI
pci 0000:00:1d.7: [8086:3a3a] type 00 class 0x0c0320
pci 0000:00:1d.7: reg 10: [mem 0xfbed8000-0xfbed83ff]
pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
pci 0000:00:1d.7: System wakeup disabled by ACPI
pci 0000:00:1e.0: [8086:244e] type 01 class 0x060401
pci 0000:00:1e.0: System wakeup disabled by ACPI
pci 0000:00:1f.0: [8086:3a16] type 00 class 0x060100
pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at 0a00 (mask 00ff)
pci 0000:00:1f.0: ICH7 LPC Generic IO decode 2 PIO at 4700 (mask 00ff)
pci 0000:00:1f.0: ICH7 LPC Generic IO decode 3 PIO at 1640 (mask 000f)
pci 0000:00:1f.0: ICH7 LPC Generic IO decode 4 PIO at 0ca0 (mask 000f)
pci 0000:00:1f.2: [8086:3a20] type 00 class 0x01018f
pci 0000:00:1f.2: reg 10: [io  0xc000-0xc007]
pci 0000:00:1f.2: reg 14: [io  0xbc00-0xbc03]
pci 0000:00:1f.2: reg 18: [io  0xb880-0xb887]
pci 0000:00:1f.2: reg 1c: [io  0xb800-0xb803]
pci 0000:00:1f.2: reg 20: [io  0xb480-0xb48f]
pci 0000:00:1f.2: reg 24: [io  0xb400-0xb40f]
pci 0000:00:1f.3: [8086:3a30] type 00 class 0x0c0500
pci 0000:00:1f.3: reg 10: [mem 0xfbed6000-0xfbed60ff 64bit]
pci 0000:00:1f.3: reg 20: [io  0x0400-0x041f]
pci 0000:00:1f.5: [8086:3a26] type 00 class 0x010185
pci 0000:00:1f.5: reg 10: [io  0xb000-0xb007]
pci 0000:00:1f.5: reg 14: [io  0xac00-0xac03]
pci 0000:00:1f.5: reg 18: [io  0xa880-0xa887]
pci 0000:00:1f.5: reg 1c: [io  0xa800-0xa803]
pci 0000:00:1f.5: reg 20: [io  0xa480-0xa48f]
pci 0000:00:1f.5: reg 24: [io  0xa400-0xa40f]
pci 0000:01:00.0: [8086:10c9] type 00 class 0x020000
pci 0000:01:00.0: reg 10: [mem 0xfaee0000-0xfaefffff]
pci 0000:01:00.0: reg 14: [mem 0xfaec0000-0xfaedffff]
pci 0000:01:00.0: reg 18: [io  0xdc00-0xdc1f]
pci 0000:01:00.0: reg 1c: [mem 0xfae9c000-0xfae9ffff]
pci 0000:01:00.0: reg 30: [mem 0xfaea0000-0xfaebffff pref]
pci 0000:01:00.0: PME# supported from D0 D3hot D3cold
pci 0000:01:00.1: [8086:10c9] type 00 class 0x020000
pci 0000:01:00.1: reg 10: [mem 0xfae60000-0xfae7ffff]
pci 0000:01:00.1: reg 14: [mem 0xfae40000-0xfae5ffff]
pci 0000:01:00.1: reg 18: [io  0xd880-0xd89f]
pci 0000:01:00.1: reg 1c: [mem 0xfae1c000-0xfae1ffff]
pci 0000:01:00.1: reg 30: [mem 0xfae20000-0xfae3ffff pref]
pci 0000:01:00.1: PME# supported from D0 D3hot D3cold
pci 0000:00:01.0: PCI bridge to [bus 01]
pci 0000:00:01.0:   bridge window [io  0xd000-0xdfff]
pci 0000:00:01.0:   bridge window [mem 0xfae00000-0xfaefffff]
pci 0000:00:03.0: PCI bridge to [bus 02]
pci 0000:00:05.0: PCI bridge to [bus 03]
pci 0000:04:00.0: [15b3:1003] type 00 class 0x028000
pci 0000:04:00.0: reg 10: [mem 0xfb900000-0xfb9fffff 64bit]
pci 0000:04:00.0: reg 18: [mem 0xf8000000-0xf87fffff 64bit pref]
pci 0000:04:00.0: reg 134: [mem 0xf4000000-0xf47fffff 64bit pref]
pci 0000:00:07.0: PCI bridge to [bus 04]
pci 0000:00:07.0:   bridge window [mem 0xfb900000-0xfb9fffff]
pci 0000:00:07.0:   bridge window [mem 0xf4000000-0xf87fffff 64bit pref]
pci 0000:05:00.0: [8086:10fb] type 00 class 0x020000
pci 0000:05:00.0: reg 10: [mem 0xf8f80000-0xf8ffffff 64bit pref]
pci 0000:05:00.0: reg 18: [io  0xec00-0xec1f]
pci 0000:05:00.0: reg 20: [mem 0xf8f7c000-0xf8f7ffff 64bit pref]
pci 0000:05:00.0: PME# supported from D0 D3hot
pci 0000:05:00.0: reg 184: [mem 0xfbd00000-0xfbd03fff 64bit]
pci 0000:05:00.0: reg 190: [mem 0xfbc00000-0xfbc03fff 64bit]
pci 0000:05:00.1: [8086:10fb] type 00 class 0x020000
pci 0000:05:00.1: reg 10: [mem 0xf8e80000-0xf8efffff 64bit pref]
pci 0000:05:00.1: reg 18: [io  0xe880-0xe89f]
pci 0000:05:00.1: reg 20: [mem 0xf8e7c000-0xf8e7ffff 64bit pref]
pci 0000:05:00.1: PME# supported from D0 D3hot
pci 0000:05:00.1: reg 184: [mem 0xfbb00000-0xfbb03fff 64bit]
pci 0000:05:00.1: reg 190: [mem 0xfba00000-0xfba03fff 64bit]
pci 0000:00:09.0: PCI bridge to [bus 05-06]
pci 0000:00:09.0:   bridge window [io  0xe000-0xefff]
pci 0000:00:09.0:   bridge window [mem 0xfba00000-0xfbdfffff]
pci 0000:00:09.0:   bridge window [mem 0xf8e00000-0xf8ffffff 64bit pref]
pci 0000:07:01.0: [102b:0532] type 00 class 0x030000
pci 0000:07:01.0: reg 10: [mem 0xf9000000-0xf9ffffff pref]
pci 0000:07:01.0: reg 14: [mem 0xfaffc000-0xfaffffff]
pci 0000:07:01.0: reg 18: [mem 0xfb000000-0xfb7fffff]
pci 0000:00:1e.0: PCI bridge to [bus 07] (subtractive decode)
pci 0000:00:1e.0:   bridge window [mem 0xfaf00000-0xfb7fffff]
pci 0000:00:1e.0:   bridge window [mem 0xf9000000-0xf9ffffff 64bit pref]
pci 0000:00:1e.0:   bridge window [io  0x0000-0x03af] (subtractive decode)
pci 0000:00:1e.0:   bridge window [io  0x03e0-0x0cf7] (subtractive decode)
pci 0000:00:1e.0:   bridge window [io  0x03b0-0x03bb] (subtractive decode)
pci 0000:00:1e.0:   bridge window [io  0x03c0-0x03df] (subtractive decode)
pci 0000:00:1e.0:   bridge window [io  0x0d00-0xefff] (subtractive decode)
pci 0000:00:1e.0:   bridge window [io  0xf000-0xffff] (subtractive decode)
pci 0000:00:1e.0:   bridge window [mem 0x000a0000-0x000bffff] (subtractive decode)
pci 0000:00:1e.0:   bridge window [mem 0x000d0000-0x000dffff] (subtractive decode)
pci 0000:00:1e.0:   bridge window [mem 0xc0000000-0xdfffffff] (subtractive decode)
pci 0000:00:1e.0:   bridge window [mem 0xf0000000-0xfed8ffff] (subtractive decode)
pci_bus 0000:00: on NUMA node 0 (pxm 0)
acpi PNP0A08:00: Requesting ACPI _OSC control (0x1d)
acpi PNP0A08:00: ACPI _OSC control (0x10) granted
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 6 7 10 11 12 14 *15)
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 6 7 10 11 12 *14 15)
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 6 7 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 6 7 10 *11 12 14 15)
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 6 7 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 6 *7 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 6 7 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 *6 7 10 11 12 14 15)
ACPI: Enabled 1 GPEs in block 00 to 3F
acpi root: \_SB_.PCI0 notify handler is installed
Found 1 acpi root devices
ACPI: No dock devices found.
vgaarb: device added: PCI:0000:07:01.0,decodes=io+mem,owns=io+mem,locks=none
vgaarb: loaded
vgaarb: bridge control possible 0000:07:01.0
ACPI: bus type USB registered
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
EDAC MC: Ver: 3.0.0
PCI: Using ACPI for IRQ routing
PCI: Discovered peer bus fe
PCI: root bus fe: using default resources
PCI: Probing PCI hardware (bus fe)
PCI host bridge to bus 0000:fe
pci_bus 0000:fe: root bus resource [io  0x0000-0xffff]
pci_bus 0000:fe: root bus resource [mem 0x00000000-0xffffffffff]
pci_bus 0000:fe: No busn resource found for root bus, will use [bus fe-ff]
pci 0000:fe:00.0: [8086:2c70] type 00 class 0x060000
pci 0000:fe:00.1: [8086:2d81] type 00 class 0x060000
pci 0000:fe:02.0: [8086:2d90] type 00 class 0x060000
pci 0000:fe:02.1: [8086:2d91] type 00 class 0x060000
pci 0000:fe:02.2: [8086:2d92] type 00 class 0x060000
pci 0000:fe:02.3: [8086:2d93] type 00 class 0x060000
pci 0000:fe:02.4: [8086:2d94] type 00 class 0x060000
pci 0000:fe:02.5: [8086:2d95] type 00 class 0x060000
pci 0000:fe:03.0: [8086:2d98] type 00 class 0x060000
pci 0000:fe:03.1: [8086:2d99] type 00 class 0x060000
pci 0000:fe:03.2: [8086:2d9a] type 00 class 0x060000
pci 0000:fe:03.4: [8086:2d9c] type 00 class 0x060000
pci 0000:fe:04.0: [8086:2da0] type 00 class 0x060000
pci 0000:fe:04.1: [8086:2da1] type 00 class 0x060000
pci 0000:fe:04.2: [8086:2da2] type 00 class 0x060000
pci 0000:fe:04.3: [8086:2da3] type 00 class 0x060000
pci 0000:fe:05.0: [8086:2da8] type 00 class 0x060000
pci 0000:fe:05.1: [8086:2da9] type 00 class 0x060000
pci 0000:fe:05.2: [8086:2daa] type 00 class 0x060000
pci 0000:fe:05.3: [8086:2dab] type 00 class 0x060000
pci 0000:fe:06.0: [8086:2db0] type 00 class 0x060000
pci 0000:fe:06.1: [8086:2db1] type 00 class 0x060000
pci 0000:fe:06.2: [8086:2db2] type 00 class 0x060000
pci 0000:fe:06.3: [8086:2db3] type 00 class 0x060000
pci_bus 0000:fe: busn_res: [bus fe-ff] end is updated to fe
PCI: Discovered peer bus ff
PCI: root bus ff: using default resources
PCI: Probing PCI hardware (bus ff)
PCI host bridge to bus 0000:ff
pci_bus 0000:ff: root bus resource [io  0x0000-0xffff]
pci_bus 0000:ff: root bus resource [mem 0x00000000-0xffffffffff]
pci_bus 0000:ff: No busn resource found for root bus, will use [bus ff-ff]
pci 0000:ff:00.0: [8086:2c70] type 00 class 0x060000
pci 0000:ff:00.1: [8086:2d81] type 00 class 0x060000
pci 0000:ff:02.0: [8086:2d90] type 00 class 0x060000
pci 0000:ff:02.1: [8086:2d91] type 00 class 0x060000
pci 0000:ff:02.2: [8086:2d92] type 00 class 0x060000
pci 0000:ff:02.3: [8086:2d93] type 00 class 0x060000
pci 0000:ff:02.4: [8086:2d94] type 00 class 0x060000
pci 0000:ff:02.5: [8086:2d95] type 00 class 0x060000
pci 0000:ff:03.0: [8086:2d98] type 00 class 0x060000
pci 0000:ff:03.1: [8086:2d99] type 00 class 0x060000
pci 0000:ff:03.2: [8086:2d9a] type 00 class 0x060000
pci 0000:ff:03.4: [8086:2d9c] type 00 class 0x060000
pci 0000:ff:04.0: [8086:2da0] type 00 class 0x060000
pci 0000:ff:04.1: [8086:2da1] type 00 class 0x060000
pci 0000:ff:04.2: [8086:2da2] type 00 class 0x060000
pci 0000:ff:04.3: [8086:2da3] type 00 class 0x060000
pci 0000:ff:05.0: [8086:2da8] type 00 class 0x060000
pci 0000:ff:05.1: [8086:2da9] type 00 class 0x060000
pci 0000:ff:05.2: [8086:2daa] type 00 class 0x060000
pci 0000:ff:05.3: [8086:2dab] type 00 class 0x060000
pci 0000:ff:06.0: [8086:2db0] type 00 class 0x060000
pci 0000:ff:06.1: [8086:2db1] type 00 class 0x060000
pci 0000:ff:06.2: [8086:2db2] type 00 class 0x060000
pci 0000:ff:06.3: [8086:2db3] type 00 class 0x060000
pci_bus 0000:ff: busn_res: [bus ff] end is updated to ff
PCI: pci_cache_line_size set to 64 bytes
e820: reserve RAM buffer [mem 0x00099800-0x0009ffff]
e820: reserve RAM buffer [mem 0xbf780000-0xbfffffff]
hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
hpet0: 4 comparators, 64-bit 14.318180 MHz counter
Switching to clocksource hpet
pnp: PnP ACPI init
ACPI: bus type PNP registered
system 00:00: [mem 0xfed1c000-0xfed1ffff] has been reserved
system 00:00: Plug and Play ACPI device, IDs PNP0c01 (active)
pnp 00:01: [dma 4]
pnp 00:01: Plug and Play ACPI device, IDs PNP0200 (active)
pnp 00:02: Plug and Play ACPI device, IDs PNP0b00 (active)
pnp 00:03: Plug and Play ACPI device, IDs PNP0800 (active)
pnp 00:04: Plug and Play ACPI device, IDs PNP0c04 (active)
system 00:05: [io  0x0a10-0x0a1f] has been reserved
system 00:05: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:06: [dma 0 disabled]
pnp 00:06: Plug and Play ACPI device, IDs PNP0501 (active)
pnp 00:07: [dma 0 disabled]
pnp 00:07: Plug and Play ACPI device, IDs PNP0501 (active)
system 00:08: [io  0x0ca2-0x0ca3] has been reserved
system 00:08: [io  0x0cf8-0x0cff] could not be reserved
system 00:08: [io  0x04d0-0x04d1] has been reserved
system 00:08: [io  0x0800-0x087f] has been reserved
system 00:08: [io  0x0500-0x057f] has been reserved
system 00:08: [mem 0x00000400-0x000004ff] could not be reserved
system 00:08: [mem 0xfed1c000-0xfed1ffff] has been reserved
system 00:08: [mem 0xfed20000-0xfed3ffff] has been reserved
system 00:08: [mem 0xfed40000-0xfed8ffff] has been reserved
system 00:08: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:09: Plug and Play ACPI device, IDs PNP0103 (active)
system 00:0a: [mem 0xfec00000-0xfec00fff] could not be reserved
system 00:0a: [mem 0xfee00000-0xfee00fff] has been reserved
system 00:0a: Plug and Play ACPI device, IDs PNP0c02 (active)
system 00:0b: [mem 0xe0000000-0xefffffff] has been reserved
system 00:0b: Plug and Play ACPI device, IDs PNP0c02 (active)
system 00:0c: [mem 0x000c0000-0x000cffff] could not be reserved
system 00:0c: [mem 0x000e0000-0x000fffff] could not be reserved
system 00:0c: [mem 0xfed90000-0xffffffff] could not be reserved
system 00:0c: Plug and Play ACPI device, IDs PNP0c01 (active)
pnp: PnP ACPI: found 13 devices
ACPI: bus type PNP unregistered
pci 0000:00:01.0: PCI bridge to [bus 01]
pci 0000:00:01.0:   bridge window [io  0xd000-0xdfff]
pci 0000:00:01.0:   bridge window [mem 0xfae00000-0xfaefffff]
pci 0000:00:03.0: PCI bridge to [bus 02]
pci 0000:00:05.0: PCI bridge to [bus 03]
pci 0000:00:07.0: PCI bridge to [bus 04]
pci 0000:00:07.0:   bridge window [mem 0xfb900000-0xfb9fffff]
pci 0000:00:07.0:   bridge window [mem 0xf4000000-0xf87fffff 64bit pref]
pci 0000:00:09.0: PCI bridge to [bus 05-06]
pci 0000:00:09.0:   bridge window [io  0xe000-0xefff]
pci 0000:00:09.0:   bridge window [mem 0xfba00000-0xfbdfffff]
pci 0000:00:09.0:   bridge window [mem 0xf8e00000-0xf8ffffff 64bit pref]
pci 0000:00:1e.0: PCI bridge to [bus 07]
pci 0000:00:1e.0:   bridge window [mem 0xfaf00000-0xfb7fffff]
pci 0000:00:1e.0:   bridge window [mem 0xf9000000-0xf9ffffff 64bit pref]
pci 0000:00:1e.0: setting latency timer to 64
pci_bus 0000:00: resource 4 [io  0x0000-0x03af]
pci_bus 0000:00: resource 5 [io  0x03e0-0x0cf7]
pci_bus 0000:00: resource 6 [io  0x03b0-0x03bb]
pci_bus 0000:00: resource 7 [io  0x03c0-0x03df]
pci_bus 0000:00: resource 8 [io  0x0d00-0xefff]
pci_bus 0000:00: resource 9 [io  0xf000-0xffff]
pci_bus 0000:00: resource 10 [mem 0x000a0000-0x000bffff]
pci_bus 0000:00: resource 11 [mem 0x000d0000-0x000dffff]
pci_bus 0000:00: resource 12 [mem 0xc0000000-0xdfffffff]
pci_bus 0000:00: resource 13 [mem 0xf0000000-0xfed8ffff]
pci_bus 0000:01: resource 0 [io  0xd000-0xdfff]
pci_bus 0000:01: resource 1 [mem 0xfae00000-0xfaefffff]
pci_bus 0000:04: resource 1 [mem 0xfb900000-0xfb9fffff]
pci_bus 0000:04: resource 2 [mem 0xf4000000-0xf87fffff 64bit pref]
pci_bus 0000:05: resource 0 [io  0xe000-0xefff]
pci_bus 0000:05: resource 1 [mem 0xfba00000-0xfbdfffff]
pci_bus 0000:05: resource 2 [mem 0xf8e00000-0xf8ffffff 64bit pref]
pci_bus 0000:07: resource 1 [mem 0xfaf00000-0xfb7fffff]
pci_bus 0000:07: resource 2 [mem 0xf9000000-0xf9ffffff 64bit pref]
pci_bus 0000:07: resource 4 [io  0x0000-0x03af]
pci_bus 0000:07: resource 5 [io  0x03e0-0x0cf7]
pci_bus 0000:07: resource 6 [io  0x03b0-0x03bb]
pci_bus 0000:07: resource 7 [io  0x03c0-0x03df]
pci_bus 0000:07: resource 8 [io  0x0d00-0xefff]
pci_bus 0000:07: resource 9 [io  0xf000-0xffff]
pci_bus 0000:07: resource 10 [mem 0x000a0000-0x000bffff]
pci_bus 0000:07: resource 11 [mem 0x000d0000-0x000dffff]
pci_bus 0000:07: resource 12 [mem 0xc0000000-0xdfffffff]
pci_bus 0000:07: resource 13 [mem 0xf0000000-0xfed8ffff]
pci_bus 0000:fe: resource 4 [io  0x0000-0xffff]
pci_bus 0000:fe: resource 5 [mem 0x00000000-0xffffffffff]
pci_bus 0000:ff: resource 4 [io  0x0000-0xffff]
pci_bus 0000:ff: resource 5 [mem 0x00000000-0xffffffffff]
NET: Registered protocol family 2
TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
TCP bind hash table entries: 65536 (order: 10, 4194304 bytes)
TCP: Hash tables configured (established 262144 bind 65536)
TCP: reno registered
UDP hash table entries: 16384 (order: 9, 2621440 bytes)
UDP-Lite hash table entries: 16384 (order: 9, 2621440 bytes)
NET: Registered protocol family 1
pci 0000:07:01.0: Boot video device
PCI: CLS 256 bytes, default 64
Trying to unpack rootfs image as initramfs...
Freeing initrd memory: 4608k freed
dmar: Host address width 40
dmar: DRHD base: 0x000000fbffe000 flags: 0x1
dmar: IOMMU 0: reg_base_addr fbffe000 ver 1:0 cap c90780106f0462 ecap f020fe
dmar: RMRR base: 0x000000000ec000 end: 0x000000000effff
dmar: RMRR base: 0x000000bf7ec000 end: 0x000000bf7fffff
dmar: ATSR flags: 0x0
IOMMU 0 0xfbffe000: using Queued invalidation
IOMMU: Setting RMRR:
IOMMU: Setting identity map for device 0000:00:1d.0 [0xbf7ec000 - 0xbf7fffff]
IOMMU: Setting identity map for device 0000:00:1d.1 [0xbf7ec000 - 0xbf7fffff]
IOMMU: Setting identity map for device 0000:00:1d.2 [0xbf7ec000 - 0xbf7fffff]
IOMMU: Setting identity map for device 0000:00:1d.7 [0xbf7ec000 - 0xbf7fffff]
IOMMU: Setting identity map for device 0000:00:1a.0 [0xbf7ec000 - 0xbf7fffff]
IOMMU: Setting identity map for device 0000:00:1a.1 [0xbf7ec000 - 0xbf7fffff]
IOMMU: Setting identity map for device 0000:00:1a.2 [0xbf7ec000 - 0xbf7fffff]
IOMMU: Setting identity map for device 0000:00:1a.7 [0xbf7ec000 - 0xbf7fffff]
IOMMU: Setting identity map for device 0000:00:1d.0 [0xec000 - 0xeffff]
IOMMU: Setting identity map for device 0000:00:1d.1 [0xec000 - 0xeffff]
IOMMU: Setting identity map for device 0000:00:1d.2 [0xec000 - 0xeffff]
IOMMU: Setting identity map for device 0000:00:1d.7 [0xec000 - 0xeffff]
IOMMU: Setting identity map for device 0000:00:1a.0 [0xec000 - 0xeffff]
IOMMU: Setting identity map for device 0000:00:1a.1 [0xec000 - 0xeffff]
IOMMU: Setting identity map for device 0000:00:1a.2 [0xec000 - 0xeffff]
IOMMU: Setting identity map for device 0000:00:1a.7 [0xec000 - 0xeffff]
IOMMU: Prepare 0-16MiB unity mapping for LPC
IOMMU: Setting identity map for device 0000:00:1f.0 [0x0 - 0xffffff]
PCI-DMA: Intel(R) Virtualization Technology for Directed I/O
sha1_ssse3: Using SSSE3 optimized SHA-1 implementation
audit: initializing netlink socket (disabled)
type=2000 audit(1365943124.860:1): initialized
HugeTLB registered 2 MB page size, pre-allocated 0 pages
VFS: Disk quotas dquot_6.5.2
Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
msgmni has been set to 32768
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
io scheduler noop registered
io scheduler deadline registered
io scheduler cfq registered (default)

=====================================
[ BUG: bad unlock balance detected! ]
3.9.0-rc6+ #53 Not tainted
-------------------------------------
swapper/0/1 is trying to release lock ((&wfc.work)) at:
[<ffffffff8122014c>] pci_device_probe+0xfc/0x120
but there are no more locks to release!

other info that might help us debug this:
2 locks held by swapper/0/1:
 #0:  (&__lockdep_no_validate__){......}, at: [<ffffffff812da443>] __driver_attach+0x53/0xb0
 #1:  (&__lockdep_no_validate__){......}, at: [<ffffffff812da451>] __driver_attach+0x61/0xb0

stack backtrace:
Pid: 1, comm: swapper/0 Not tainted 3.9.0-rc6+ #53
Call Trace:
 [<ffffffff8122014c>] ? pci_device_probe+0xfc/0x120
 [<ffffffff81093529>] print_unlock_imbalance_bug+0xf9/0x100
 [<ffffffff8109616f>] lock_set_class+0x27f/0x7c0
 [<ffffffff81091d9e>] ? mark_held_locks+0x9e/0x130
 [<ffffffff8122014c>] ? pci_device_probe+0xfc/0x120
 [<ffffffff81066aeb>] work_on_cpu_nested+0x8b/0xc0
 [<ffffffff810633c0>] ? keventd_up+0x20/0x20
 [<ffffffff8121f420>] ? pci_pm_prepare+0x60/0x60
 [<ffffffff8122014c>] pci_device_probe+0xfc/0x120
 [<ffffffff812da0fa>] ? driver_sysfs_add+0x7a/0xb0
 [<ffffffff812da24f>] driver_probe_device+0x8f/0x230
 [<ffffffff812da493>] __driver_attach+0xa3/0xb0
 [<ffffffff812da3f0>] ? driver_probe_device+0x230/0x230
 [<ffffffff812da3f0>] ? driver_probe_device+0x230/0x230
 [<ffffffff812d86fc>] bus_for_each_dev+0x8c/0xb0
 [<ffffffff812da079>] driver_attach+0x19/0x20
 [<ffffffff812d91a0>] bus_add_driver+0x1f0/0x250
 [<ffffffff818bd596>] ? dmi_pcie_pme_disable_msi+0x21/0x21
 [<ffffffff812daadf>] driver_register+0x6f/0x150
 [<ffffffff818bd596>] ? dmi_pcie_pme_disable_msi+0x21/0x21
 [<ffffffff8122026f>] __pci_register_driver+0x5f/0x70
 [<ffffffff818bd5ff>] pcie_portdrv_init+0x69/0x7a
 [<ffffffff810001fd>] do_one_initcall+0x3d/0x170
 [<ffffffff81895943>] kernel_init_freeable+0x10d/0x19c
 [<ffffffff818959d2>] ? kernel_init_freeable+0x19c/0x19c
 [<ffffffff8145a040>] ? rest_init+0x160/0x160
 [<ffffffff8145a049>] kernel_init+0x9/0xf0
 [<ffffffff8146ca6c>] ret_from_fork+0x7c/0xb0
 [<ffffffff8145a040>] ? rest_init+0x160/0x160
ioapic: probe of 0000:00:13.0 failed with error -22
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
intel_idle: MWAIT substates: 0x1120
intel_idle: v0.4 model 0x2C
intel_idle: lapic_timer_reliable_states 0xffffffff
ACPI: Requesting acpi_cpufreq
ERST: Failed to get Error Log Address Range.
ghes_edac: This EDAC driver relies on BIOS to enumerate memory and get error reports.
ghes_edac: Unfortunately, not all BIOSes reflect the memory layout correctly.
ghes_edac: So, the end result of using this driver varies from vendor to vendor.
ghes_edac: If you find incorrect reports, please contact your hardware vendor
ghes_edac: to correct its BIOS.
ghes_edac: This system has 13 DIMM sockets.
EDAC MC0: Giving out device to 'ghes_edac.c' 'ghes_edac': DEV ghes
EDAC MC1: Giving out device to 'ghes_edac.c' 'ghes_edac': DEV ghes
[Firmware Warn]: GHES: Poll interval is 0 for generic hardware error source: 1, disabled.
GHES: Failed to enable APEI firmware first mode.
Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
00:06: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
00:07: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
Linux agpgart interface v0.103
[drm] Initialized drm 1.1.0 20060810
brd: module loaded
Uniform Multi-Platform E-IDE driver
ide_generic: please use "probe_mask=0x3f" module parameter for probing all legacy ISA IDE ports
Probing IDE interface ide0...
tsc: Refined TSC clocksource calibration: 2666.761 MHz
Switching to clocksource tsc
ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
Probing IDE interface ide1...
ide1 at 0x170-0x177,0x376 on irq 15
ide-gd driver 1.18
i8042: PNP: No PS/2 controller found. Probing ports directly.
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mousedev: PS/2 mouse device common for all mice
rtc_cmos 00:02: RTC can wake from S4
rtc_cmos 00:02: rtc core: registered rtc_cmos as rtc0
rtc_cmos 00:02: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
EDAC i7core: Couldn't find mci handler
EDAC i7core: Couldn't find mci handler
i7core_edac: probe of 0000:00:14.0 failed with error -22
cpuidle: using governor ladder
cpuidle: using governor menu
usbcore: registered new interface driver usbhid
usbhid: USB HID core driver
TCP: cubic registered
Initializing XFRM netlink socket
NET: Registered protocol family 17
Key type dns_resolver registered
registered taskstats version 1
Freeing unused kernel memory: 848k freed
Write protecting the kernel read-only data: 8192k
Freeing unused kernel memory: 1584k freed
Freeing unused kernel memory: 136k freed
dracut: dracut-004-302.el6
udev: starting version 147
udevd (920): /proc/920/oom_adj is deprecated, please use /proc/920/oom_score_adj instead.
dracut: Starting plymouth daemon
uhci_hcd: USB Universal Host Controller Interface driver
uhci_hcd 0000:00:1a.0: setting latency timer to 64
uhci_hcd 0000:00:1a.0: UHCI Host Controller
uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 1
uhci_hcd 0000:00:1a.0: irq 16, io base 0x0000cc00
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 2 ports detected
uhci_hcd 0000:00:1a.1: setting latency timer to 64
uhci_hcd 0000:00:1a.1: UHCI Host Controller
uhci_hcd 0000:00:1a.1: new USB bus registered, assigned bus number 2
uhci_hcd 0000:00:1a.1: irq 21, io base 0x0000c880
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
uhci_hcd 0000:00:1a.2: setting latency timer to 64
uhci_hcd 0000:00:1a.2: UHCI Host Controller
uhci_hcd 0000:00:1a.2: new USB bus registered, assigned bus number 3
uhci_hcd 0000:00:1a.2: irq 19, io base 0x0000c800
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
uhci_hcd 0000:00:1d.0: setting latency timer to 64
uhci_hcd 0000:00:1d.0: UHCI Host Controller
uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 4
uhci_hcd 0000:00:1d.0: irq 23, io base 0x0000c480
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
uhci_hcd 0000:00:1d.1: setting latency timer to 64
uhci_hcd 0000:00:1d.1: UHCI Host Controller
uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 5
uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000c400
hub 5-0:1.0: USB hub found
hub 5-0:1.0: 2 ports detected
uhci_hcd 0000:00:1d.2: setting latency timer to 64
uhci_hcd 0000:00:1d.2: UHCI Host Controller
uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 6
uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000c080
hub 6-0:1.0: USB hub found
hub 6-0:1.0: 2 ports detected
SCSI subsystem initialized
ACPI: bus type ATA registered
libata version 3.00 loaded.
ata_piix 0000:00:1f.2: version 2.13
ata_piix 0000:00:1f.2: MAP [
 P0 P2 P1 P3 ]
ata_piix 0000:00:1f.2: setting latency timer to 64
scsi0 : ata_piix
scsi1 : ata_piix
ata1: SATA max UDMA/133 cmd 0xc000 ctl 0xbc00 bmdma 0xb480 irq 19
ata2: SATA max UDMA/133 cmd 0xb880 ctl 0xb800 bmdma 0xb488 irq 19
ata_piix 0000:00:1f.5: MAP [
 P0 -- P1 -- ]
ata_piix 0000:00:1f.5: setting latency timer to 64
scsi2 : ata_piix
scsi3 : ata_piix
ata3: SATA max UDMA/133 cmd 0xb000 ctl 0xac00 bmdma 0xa480 irq 19
ata4: SATA max UDMA/133 cmd 0xa880 ctl 0xa800 bmdma 0xa488 irq 19
usb 2-1: new full-speed USB device number 2 using uhci_hcd
input: American Megatrends Inc. Virtual Keyboard and Mouse as /devices/pci0000:00/0000:00:1a.1/usb2/2-1/2-1:1.0/input/input0
hid-generic 0003:046B:FF10.0001: input: USB HID v1.10 Keyboard [American Megatrends Inc. Virtual Keyboard and Mouse] on usb-0000:00:1a.1-1/input0
input: American Megatrends Inc. Virtual Keyboard and Mouse as /devices/pci0000:00/0000:00:1a.1/usb2/2-1/2-1:1.1/input/input1
hid-generic 0003:046B:FF10.0002: input: USB HID v1.10 Mouse [American Megatrends Inc. Virtual Keyboard and Mouse] on usb-0000:00:1a.1-1/input1
ata4: SATA link down (SStatus 0 SControl 300)
ata3: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
ata3.00: ATAPI: DV-28S-W, 1.2A, max UDMA/100
ata3.00: configured for UDMA/100
ata2.00: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata2.01: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata1.00: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata1.01: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata2.00: ATA-8: WDC WD5003ABYX-01WERA0, 01.01S01, max UDMA/133
ata2.00: 976773168 sectors, multi 16: LBA48 NCQ (depth 0/32)
ata2.01: ATA-8: WDC WD5003ABYX-01WERA0, 01.01S01, max UDMA/133
ata2.01: 976773168 sectors, multi 16: LBA48 NCQ (depth 0/32)
ata1.00: ATA-8: WDC WD5003ABYX-01WERA0, 01.01S01, max UDMA/133
ata1.00: 976773168 sectors, multi 16: LBA48 NCQ (depth 0/32)
ata1.01: ATA-8: WDC WD5003ABYX-01WERA0, 01.01S01, max UDMA/133
ata1.01: 976773168 sectors, multi 16: LBA48 NCQ (depth 0/32)
ata2.00: configured for UDMA/133
ata1.00: configured for UDMA/133
ata2.01: configured for UDMA/133
ata1.01: configured for UDMA/133
scsi 0:0:0:0: Direct-Access     ATA      WDC WD5003ABYX-0 01.0 PQ: 0 ANSI: 5
scsi 0:0:1:0: Direct-Access     ATA      WDC WD5003ABYX-0 01.0 PQ: 0 ANSI: 5
ttyS0: 7 input overrun(s)
scsi 1:0:0:0: Direct-Access     ATA      WDC WD5003ABYX-0 01.0 PQ: 0 ANSI: 5
sd 0:0:0:0: [sda] 976773168 512-byte logical blocks: (500 GB/465 GiB)
sd 0:0:1:0: [sdb] 976773168 512-byte logical blocks: (500 GB/465 GiB)
sd 1:0:0:0: [sdc] 976773168 512-byte logical blocks: (500 GB/465 GiB)
sd 1:0:0:0: [sdc] Write Protect is off
sd 1:0:0:0: [sdc] Mode Sense: 00 3a 00 00
sd 1:0:0:0: [sdc] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 0:0:1:0: [sdb] Write Protect is off
sd 0:0:1:0: [sdb] Mode Sense: 00 3a 00 00
sd 0:0:1:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
scsi 1:0:1:0: Direct-Access     ATA      WDC WD5003ABYX-0 01.0 PQ: 0 ANSI: 5
scsi 2:0:0:0: CD-ROM            TEAC     DV-28S-W         1.2A PQ: 0 ANSI: 5
 sdb: sdb1
 sdc:
sd 1:0:1:0: [sdd] 976773168 512-byte logical blocks: (500 GB/465 GiB)
sd 1:0:1:0: [sdd] Write Protect is off
sd 1:0:1:0: [sdd] Mode Sense: 00 3a 00 00
sd 1:0:1:0: [sdd] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 0:0:1:0: [sdb] Attached SCSI disk
sd 1:0:0:0: [sdc] Attached SCSI disk
 sdd: unknown partition table
sd 1:0:1:0: [sdd] Attached SCSI disk
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sda: sda1 sda2 sda3 sda4 < sda5 sda6 sda7 >
sd 0:0:0:0: [sda] Attached SCSI disk
EXT3-fs (sda7): recovery required on readonly filesystem
EXT3-fs (sda7): write access will be enabled during recovery
kjournald starting.  Commit interval 5 seconds
EXT3-fs (sda7): recovery complete
EXT3-fs (sda7): mounted filesystem with writeback data mode
dracut: Mounted root filesystem /dev/sda7
dracut: /sbin/load_policy: Can't load policy: No such device
dracut: Switching root
udev: starting version 147
input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input2
ACPI: Power Button [PWRB]
input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input3
ACPI: Power Button [PWRF]
pps_core: LinuxPPS API ver. 1 registered
pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
PTP clock support registered
dca service started, version 1.12.1
igb: Intel(R) Gigabit Ethernet Network Driver - version 4.1.2-k
igb: Copyright (c) 2007-2013 Intel Corporation.
igb 0000:01:00.0: irq 65 for MSI/MSI-X
igb 0000:01:00.0: irq 66 for MSI/MSI-X
igb 0000:01:00.0: irq 67 for MSI/MSI-X
igb 0000:01:00.0: irq 68 for MSI/MSI-X
igb 0000:01:00.0: irq 69 for MSI/MSI-X
igb 0000:01:00.0: irq 70 for MSI/MSI-X
igb 0000:01:00.0: irq 71 for MSI/MSI-X
igb 0000:01:00.0: irq 72 for MSI/MSI-X
igb 0000:01:00.0: irq 73 for MSI/MSI-X
igb 0000:01:00.0: added PHC on eth0
igb 0000:01:00.0: Intel(R) Gigabit Ethernet Network Connection
igb 0000:01:00.0: eth0: (PCIe:2.5Gb/s:Width x4) 00:25:90:36:9c:ec
igb 0000:01:00.0: eth0: PBA No: FFFFFF-0FF
igb 0000:01:00.0: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
ttyS0: 4 input overrun(s)
igb 0000:01:00.1: irq 74 for MSI/MSI-X
igb 0000:01:00.1: irq 75 for MSI/MSI-X
igb 0000:01:00.1: irq 76 for MSI/MSI-X
igb 0000:01:00.1: irq 77 for MSI/MSI-X
igb 0000:01:00.1: irq 78 for MSI/MSI-X
igb 0000:01:00.1: irq 79 for MSI/MSI-X
igb 0000:01:00.1: irq 80 for MSI/MSI-X
igb 0000:01:00.1: irq 81 for MSI/MSI-X
igb 0000:01:00.1: irq 82 for MSI/MSI-X
igb 0000:01:00.1: added PHC on eth1
igb 0000:01:00.1: Intel(R) Gigabit Ethernet Network Connection
igb 0000:01:00.1: eth1: (PCIe:2.5Gb/s:Width x4) 00:25:90:36:9c:ed
igb 0000:01:00.1: eth1: PBA No: FFFFFF-0FF
igb 0000:01:00.1: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
mlx4_core: Mellanox ConnectX core driver v1.1 (Dec, 2011)
mlx4_core: Initializing 0000:04:00.0
mlx4_core 0000:04:00.0: Enabling SR-IOV with 3 VFs
pci 0000:04:00.1: [15b3:1004] type 00 class 0x028000
mlx4_core: Initializing 0000:04:00.1
mlx4_core 0000:04:00.1: enabling device (0000 -> 0002)
mlx4_core 0000:04:00.1: Detected virtual function - running in slave mode
mlx4_core 0000:04:00.1: Sending reset
mlx4_core 0000:04:00.1: Got slave FLRed from Communication channel (ret:0x1)
mlx4_core 0000:04:00.1: slave is currently in themiddle of FLR. retrying...(try num:1)
mlx4_core 0000:04:00.1: Communication channel is not idle.my toggle is 1 (cmd:0x0)
mlx4_core 0000:04:00.1: slave is currently in themiddle of FLR. retrying...(try num:2)
mlx4_core 0000:04:00.1: Communication channel is not idle.my toggle is 1 (cmd:0x0)
mlx4_core 0000:04:00.1: slave is currently in themiddle of FLR. retrying...(try num:3)
mlx4_core 0000:04:00.1: Communication channel is not idle.my toggle is 1 (cmd:0x0)
mlx4_core 0000:04:00.1: slave is currently in themiddle of FLR. retrying...(try num:4)
mlx4_core 0000:04:00.1: Communication channel is not idle.my toggle is 1 (cmd:0x0)
mlx4_core 0000:04:00.1: slave is currently in themiddle of FLR. retrying...(try num:5)
mlx4_core 0000:04:00.1: Communication channel is not idle.my toggle is 1 (cmd:0x0)
mlx4_core 0000:04:00.1: slave is currently in themiddle of FLR. retrying...(try num:6)
mlx4_core 0000:04:00.1: Communication channel is not idle.my toggle is 1 (cmd:0x0)
mlx4_core 0000:04:00.1: slave is currently in themiddle of FLR. retrying...(try num:7)
mlx4_core 0000:04:00.1: Communication channel is not idle.my toggle is 1 (cmd:0x0)
mlx4_core 0000:04:00.1: slave is currently in themiddle of FLR. retrying...(try num:8)
mlx4_core 0000:04:00.1: Communication channel is not idle.my toggle is 1 (cmd:0x0)
mlx4_core 0000:04:00.1: slave is currently in themiddle of FLR. retrying...(try num:9)
mlx4_core 0000:04:00.1: Communication channel is not idle.my toggle is 1 (cmd:0x0)
mlx4_core 0000:04:00.1: slave is currently in themiddle of FLR. retrying...(try num:10)
mlx4_core 0000:04:00.1: Communication channel is not idle.my toggle is 1 (cmd:0x0)
mlx4_core 0000:04:00.1: slave driver version is not supported by the master
mlx4_core 0000:04:00.1: Communication channel is not idle.my toggle is 1 (cmd:0x0)
mlx4_core 0000:04:00.1: Failed to initialize slave
mlx4_core: probe of 0000:04:00.1 failed with error -5
pci 0000:04:00.2: [15b3:1004] type 00 class 0x028000
mlx4_core: Initializing 0000:04:00.2
mlx4_core 0000:04:00.2: enabling device (0000 -> 0002)
mlx4_core 0000:04:00.2: Skipping virtual function:2
pci 0000:04:00.3: [15b3:1004] type 00 class 0x028000
mlx4_core: Initializing 0000:04:00.3
mlx4_core 0000:04:00.3: enabling device (0000 -> 0002)
mlx4_core 0000:04:00.3: Skipping virtual function:3
mlx4_core 0000:04:00.0: Running in master mode
mlx4_core 0000:04:00.0: FW version 2.11.500 (cmd intf rev 3), max commands 16
mlx4_core 0000:04:00.0: Catastrophic error buffer at 0x1f020, size 0x10, BAR 0
mlx4_core 0000:04:00.0: Communication vector bar:2 offset:0x800
mlx4_core 0000:04:00.0: FW size 385 KB
mlx4_core 0000:04:00.0: Clear int @ f0058, BAR 0
mlx4_core 0000:04:00.0: Mapped 26 chunks/6168 KB for FW.
mlx4_core 0000:04:00.0: BlueFlame available (reg size 512, regs/page 8)
mlx4_core 0000:04:00.0: Base MM extensions: flags 00104cc0, rsvd L_Key 00008000
mlx4_core 0000:04:00.0: Max ICM size 4294967296 MB
mlx4_core 0000:04:00.0: Max QPs: 16777216, reserved QPs: 64, entry size: 256
mlx4_core 0000:04:00.0: Max SRQs: 16777216, reserved SRQs: 64, entry size: 128
mlx4_core 0000:04:00.0: Max CQs: 16777216, reserved CQs: 128, entry size: 128
mlx4_core 0000:04:00.0: Max EQs: 32, reserved EQs: 28, entry size: 128
mlx4_core 0000:04:00.0: reserved MPTs: 256, reserved MTTs: 32
mlx4_core 0000:04:00.0: Max PDs: 131072, reserved PDs: 4, reserved UARs: 7
mlx4_core 0000:04:00.0: Max QP/MCG: 131072, reserved MGMs: 0
mlx4_core 0000:04:00.0: Max CQEs: 4194304, max WQEs: 16384, max SRQ WQEs: 16384
mlx4_core 0000:04:00.0: Local CA ACK delay: 15, max MTU: 4096, port width cap: 2
mlx4_core 0000:04:00.0: Max SQ desc size: 1008, max SQ S/G: 62
mlx4_core 0000:04:00.0: Max RQ desc size: 512, max RQ S/G: 32
mlx4_core 0000:04:00.0: Max GSO size: 131072
mlx4_core 0000:04:00.0: Max counters: 256
mlx4_core 0000:04:00.0: Max RSS Table size: 256
mlx4_core 0000:04:00.0: DEV_CAP flags:
mlx4_core 0000:04:00.0:     RC transport
mlx4_core 0000:04:00.0:     UC transport
mlx4_core 0000:04:00.0:     UD transport
mlx4_core 0000:04:00.0:     XRC transport
mlx4_core 0000:04:00.0:     FCoIB support
mlx4_core 0000:04:00.0:     SRQ support
mlx4_core 0000:04:00.0:     IPoIB checksum offload
mlx4_core 0000:04:00.0:     P_Key violation counter
mlx4_core 0000:04:00.0:     Q_Key violation counter
mlx4_core 0000:04:00.0:     DPDP
mlx4_core 0000:04:00.0:     Big LSO headers
mlx4_core 0000:04:00.0:     APM support
mlx4_core 0000:04:00.0:     Atomic ops support
mlx4_core 0000:04:00.0:     Address vector port checking support
mlx4_core 0000:04:00.0:     UD multicast support
mlx4_core 0000:04:00.0:     Router support
mlx4_core 0000:04:00.0:     IBoE support
mlx4_core 0000:04:00.0:     Unicast loopback support
mlx4_core 0000:04:00.0:     FCS header control
mlx4_core 0000:04:00.0:     UDP RSS support
mlx4_core 0000:04:00.0:     Unicast VEP steering support
mlx4_core 0000:04:00.0:     Multicast VEP steering support
mlx4_core 0000:04:00.0:     Counters support
mlx4_core 0000:04:00.0:     Port management change event support
mlx4_core 0000:04:00.0:     64 byte EQE support
mlx4_core 0000:04:00.0:     64 byte CQE support
mlx4_core 0000:04:00.0:     RSS support
mlx4_core 0000:04:00.0:     RSS Toeplitz Hash Function support
mlx4_core 0000:04:00.0:     RSS XOR Hash Function support
mlx4_core 0000:04:00.0:     Device manage flow steering support
mlx4_core 0000:04:00.0: 64B EQEs/CQEs supported by the device but not enabled
mlx4_core 0000:04:00.0: Steering mode is: B0 steering, oper_log_mgm_entry_size = 10, modparam log_num_mgm_entry_size = 10
mlx4_core 0000:04:00.0:   profile[ 0] (  CMPT): 2^26 entries @ 0x         0, size 0x 100000000
mlx4_core 0000:04:00.0:   profile[ 1] (RDMARC): 2^22 entries @ 0x 100000000, size 0x   8000000
mlx4_core 0000:04:00.0:   profile[ 2] (   MTT): 2^24 entries @ 0x 108000000, size 0x   8000000
mlx4_core 0000:04:00.0:   profile[ 3] (    QP): 2^18 entries @ 0x 110000000, size 0x   4000000
mlx4_core 0000:04:00.0:   profile[ 4] (  DMPT): 2^19 entries @ 0x 114000000, size 0x   2000000
mlx4_core 0000:04:00.0:   profile[ 5] (  ALTC): 2^18 entries @ 0x 116000000, size 0x   1000000
mlx4_core 0000:04:00.0:   profile[ 6] (   SRQ): 2^16 entries @ 0x 117000000, size 0x    800000
mlx4_core 0000:04:00.0:   profile[ 7] (    CQ): 2^16 entries @ 0x 117800000, size 0x    800000
mlx4_core 0000:04:00.0:   profile[ 8] (   MCG): 2^13 entries @ 0x 118000000, size 0x    800000
mlx4_core 0000:04:00.0:   profile[ 9] (  AUXC): 2^18 entries @ 0x 118800000, size 0x     40000
mlx4_core 0000:04:00.0:   profile[10] (    EQ): 2^10 entries @ 0x 118840000, size 0x     20000
mlx4_core 0000:04:00.0: HCA context memory: reserving 4596096 KB
mlx4_core 0000:04:00.0: 4596096 KB of HCA context requires 9068 KB aux memory.
mlx4_core 0000:04:00.0: Mapped 39 chunks/9068 KB for ICM aux.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 0 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 40000000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 80000000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/64 KB at c0000000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/128 KB at 118840000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 108000000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 114000000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 110000000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 118800000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 116000000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 100000000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 117800000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 117000000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 118000000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 118040000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 118080000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 1180c0000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 118100000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 118140000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 118180000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 1181c0000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 118200000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 118240000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 118280000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 1182c0000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 118300000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 118340000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 118380000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 1183c0000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 118400000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 118440000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 118480000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 1184c0000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 118500000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 118540000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 118580000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 1185c0000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 118600000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 118640000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 118680000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 1186c0000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 118700000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 118740000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 118780000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 1187c0000 for ICM.
ttyS0: 3 input overrun(s)
mlx4_core 0000:04:00.0: Started init_resource_tracker: 80 slaves
mlx4_core 0000:04:00.0: irq 83 for MSI/MSI-X
mlx4_core 0000:04:00.0: irq 84 for MSI/MSI-X
mlx4_core 0000:04:00.0: irq 85 for MSI/MSI-X
mlx4_core 0000:04:00.0: irq 86 for MSI/MSI-X
mlx4_core 0000:04:00.0: NOP command IRQ test passed
mlx4_core: Initializing 0000:04:00.1
mlx4_core 0000:04:00.1: enabling device (0000 -> 0002)
mlx4_core 0000:04:00.1: Detected virtual function - running in slave mode
mlx4_core 0000:04:00.1: Sending reset
mlx4_core 0000:04:00.0: Received reset from slave:1
mlx4_core 0000:04:00.1: Sending vhcr0
mlx4_core 0000:04:00.1: BlueFlame not available
mlx4_core 0000:04:00.1: Base MM extensions: flags 0688fdff, rsvd L_Key 00008000
mlx4_core 0000:04:00.1: Max ICM size 4294967296 MB
mlx4_core 0000:04:00.1: Max QPs: 16777216, reserved QPs: 64, entry size: 256
mlx4_core 0000:04:00.1: Max SRQs: 16777216, reserved SRQs: 64, entry size: 128
mlx4_core 0000:04:00.1: Max CQs: 16777216, reserved CQs: 128, entry size: 128
mlx4_core 0000:04:00.1: Max EQs: 32, reserved EQs: 28, entry size: 128
mlx4_core 0000:04:00.1: reserved MPTs: 256, reserved MTTs: 32
mlx4_core 0000:04:00.1: Max PDs: 131072, reserved PDs: 4, reserved UARs: 7
mlx4_core 0000:04:00.1: Max QP/MCG: 131072, reserved MGMs: 0
mlx4_core 0000:04:00.1: Max CQEs: 4194304, max WQEs: 16384, max SRQ WQEs: 16384
mlx4_core 0000:04:00.1: Local CA ACK delay: 15, max MTU: 4096, port width cap: 2
mlx4_core 0000:04:00.1: Max SQ desc size: 1008, max SQ S/G: 62
mlx4_core 0000:04:00.1: Max RQ desc size: 512, max RQ S/G: 32
mlx4_core 0000:04:00.1: Max GSO size: 131072
mlx4_core 0000:04:00.1: Max counters: 256
mlx4_core 0000:04:00.1: Max RSS Table size: 256
mlx4_core 0000:04:00.1: DEV_CAP flags:
mlx4_core 0000:04:00.1:     RC transport
mlx4_core 0000:04:00.1:     UC transport
mlx4_core 0000:04:00.1:     UD transport
mlx4_core 0000:04:00.1:     XRC transport
mlx4_core 0000:04:00.1:     FCoIB support
mlx4_core 0000:04:00.1:     SRQ support
mlx4_core 0000:04:00.1:     IPoIB checksum offload
mlx4_core 0000:04:00.1:     P_Key violation counter
mlx4_core 0000:04:00.1:     Q_Key violation counter
mlx4_core 0000:04:00.1:     DPDP
mlx4_core 0000:04:00.1:     Big LSO headers
mlx4_core 0000:04:00.1:     APM support
mlx4_core 0000:04:00.1:     Atomic ops support
mlx4_core 0000:04:00.1:     Address vector port checking support
mlx4_core 0000:04:00.1:     UD multicast support
mlx4_core 0000:04:00.1:     Router support
mlx4_core 0000:04:00.1:     IBoE support
mlx4_core 0000:04:00.1:     Unicast loopback support
mlx4_core 0000:04:00.1:     FCS header control
mlx4_core 0000:04:00.1:     UDP RSS support
mlx4_core 0000:04:00.1:     Unicast VEP steering support
mlx4_core 0000:04:00.1:     Multicast VEP steering support
mlx4_core 0000:04:00.1:     Counters support
mlx4_core 0000:04:00.1:     Port management change event support
mlx4_core 0000:04:00.1:     64 byte EQE support
mlx4_core 0000:04:00.1:     64 byte CQE support
mlx4_core 0000:04:00.1:     RSS support
mlx4_core 0000:04:00.1:     RSS Toeplitz Hash Function support
mlx4_core 0000:04:00.1:     RSS XOR Hash Function support
mlx4_core 0000:04:00.1: 64B EQEs/CQEs supported by the device but not enabled
mlx4_core 0000:04:00.1: HCA minimum page size:512
mlx4_core 0000:04:00.1: Steering mode is: B0 steering
mlx4_core 0000:04:00.1: Failed to map blue flame area
mlx4_core 0000:04:00.1: irq 87 for MSI/MSI-X
mlx4_core 0000:04:00.1: irq 88 for MSI/MSI-X
mlx4_core 0000:04:00.1: irq 89 for MSI/MSI-X
mlx4_core 0000:04:00.1: irq 90 for MSI/MSI-X
mlx4_core 0000:04:00.1: NOP command IRQ test passed
mlx4_core: Initializing 0000:04:00.2
mlx4_core 0000:04:00.2: enabling device (0000 -> 0002)
mlx4_core 0000:04:00.2: Skipping virtual function:2
mlx4_core: Initializing 0000:04:00.3
mlx4_core 0000:04:00.3: enabling device (0000 -> 0002)
mlx4_core 0000:04:00.3: Skipping virtual function:3
mlx4_en: Mellanox ConnectX HCA Ethernet driver v2.0 (Dec 2011)
mlx4_en 0000:04:00.0: Activating port:1
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 110040000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 1000c0000 for ICM.
mlx4_en: eth2: Using 96 TX rings
mlx4_en: eth2: Using 4 RX rings
mlx4_en: eth2: Initializing port
mlx4_en 0000:04:00.0: Activating port:2
mlx4_en: eth3: Using 96 TX rings
mlx4_en: eth3: Using 4 RX rings
mlx4_en: eth3: Initializing port
mlx4_en 0000:04:00.1: Activating port:1
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 110080000 for ICM.
mlx4_core 0000:04:00.0: Mapped 1 chunks/256 KB at 100100000 for ICM.
mlx4_en: eth4: Using 96 TX rings
mlx4_en: eth4: Using 4 RX rings
mlx4_en: eth4: Initializing port
mlx4_en 0000:04:00.1: Activating port:2
mlx4_en: eth4: Using 96 TX rings
mlx4_en: eth4: Using 4 RX rings
mlx4_en: eth4: Initializing port
<mlx4_ib> mlx4_ib_add: mlx4_ib: Mellanox ConnectX InfiniBand driver v1.0 (April 4, 2008)
mlx4_core 0000:04:00.0: RoCE is not supported over SRIOV as yet
mlx4_core 0000:04:00.1: RoCE is not supported over SRIOV as yet
ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 3.11.33-k
ixgbe: Copyright (c) 1999-2013 Intel Corporation.
ixgbe 0000:05:00.0: Enabling SR-IOV VFs using the module parameter is deprecated - please use the pci sysfs interface.
pci 0000:05:10.0: [8086:10ed] type 00 class 0x020000
ixgbe 0000:05:00.0 (unregistered net_device): SR-IOV enabled with 1 VFs
ixgbe 0000:05:00.0: irq 91 for MSI/MSI-X
ixgbe 0000:05:00.0: irq 92 for MSI/MSI-X
ixgbe 0000:05:00.0: Multiqueue Disabled: Rx Queue count = 1, Tx Queue count = 1
ixgbe 0000:05:00.0: (PCI Express:5.0GT/s:Width x8) 00:1b:21:55:1d:00
ixgbe 0000:05:00.0: MAC: 2, PHY: 1, PBA No: E68793-002
ixgbe 0000:05:00.0 eth2: IOV is enabled with 1 VFs
ixgbe 0000:05:00.0 eth2: IOV: VF 0 is enabled MAC ee:98:d8:2e:82:b3
ixgbe 0000:05:00.0: Intel(R) 10 Gigabit Network Connection
ttyS0: 29 input overrun(s)
ixgbe 0000:05:00.1: Enabling SR-IOV VFs using the module parameter is deprecated - please use the pci sysfs interface.
pci 0000:05:10.1: [8086:10ed] type 00 class 0x020000
ixgbe 0000:05:00.1 (unregistered net_device): SR-IOV enabled with 1 VFs
ixgbe 0000:05:00.1: irq 93 for MSI/MSI-X
ixgbe 0000:05:00.1: irq 94 for MSI/MSI-X
ixgbe 0000:05:00.1: Multiqueue Disabled: Rx Queue count = 1, Tx Queue count = 1
ixgbe 0000:05:00.1: (PCI Express:5.0GT/s:Width x8) 00:1b:21:55:1d:01
ixgbe 0000:05:00.1: MAC: 2, PHY: 9, SFP+: 4, PBA No: E68793-002
ixgbe 0000:05:00.1 eth3: IOV is enabled with 1 VFs
ixgbe 0000:05:00.1 eth3: IOV: VF 0 is enabled MAC 0a:84:35:50:f5:c1
ixgbe 0000:05:00.1: Intel(R) 10 Gigabit Network Connection
ioatdma: Intel(R) QuickData Technology Driver 4.00
ioatdma 0000:00:16.0: irq 95 for MSI/MSI-X
igb 0000:01:00.0: DCA enabled
igb 0000:01:00.1: DCA enabled
ioatdma 0000:00:16.1: irq 96 for MSI/MSI-X
ioatdma 0000:00:16.2: irq 97 for MSI/MSI-X
ioatdma 0000:00:16.3: irq 98 for MSI/MSI-X
ioatdma 0000:00:16.4: irq 99 for MSI/MSI-X
ioatdma 0000:00:16.5: irq 100 for MSI/MSI-X
ioatdma 0000:00:16.6: irq 101 for MSI/MSI-X
ioatdma 0000:00:16.7: irq 102 for MSI/MSI-X
ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
Warning! ehci_hcd should always be loaded before uhci_hcd and ohci_hcd, not after
ehci-pci: EHCI PCI platform driver
ehci-pci 0000:00:1a.7: setting latency timer to 64
ehci-pci 0000:00:1a.7: EHCI Host Controller
ehci-pci 0000:00:1a.7: new USB bus registered, assigned bus number 7
ehci-pci 0000:00:1a.7: debug port 1
ehci-pci 0000:00:1a.7: cache line size of 256 is not supported
ehci-pci 0000:00:1a.7: irq 18, io mem 0xfbeda000
ehci-pci 0000:00:1a.7: USB 2.0 started, EHCI 1.00
hub 7-0:1.0: USB hub found
hub 7-0:1.0: 6 ports detected
ehci-pci 0000:00:1d.7: setting latency timer to 64
ehci-pci 0000:00:1d.7: EHCI Host Controller
ehci-pci 0000:00:1d.7: new USB bus registered, assigned bus number 8
ehci-pci 0000:00:1d.7: debug port 1
ehci-pci 0000:00:1d.7: cache line size of 256 is not supported
ehci-pci 0000:00:1d.7: irq 23, io mem 0xfbed8000
ehci-pci 0000:00:1d.7: USB 2.0 started, EHCI 1.00
hub 8-0:1.0: USB hub found
hub 8-0:1.0: 6 ports detected
sd 0:0:0:0: Attached scsi generic sg0 type 0
sd 0:0:1:0: Attached scsi generic sg1 type 0
sd 1:0:0:0: Attached scsi generic sg2 type 0
sd 1:0:1:0: Attached scsi generic sg3 type 0
scsi 2:0:0:0: Attached scsi generic sg4 type 5
i801_smbus 0000:00:1f.3: SMBus using PCI Interrupt
md: bind<sdc>
input: PC Speaker as /devices/platform/pcspkr/input/input4
usb 2-1: USB disconnect, device number 2
mlx4_en: eth17: Link Up
mlx4_en: eth19: Link Up
device-mapper: ioctl: 4.24.0-ioctl (2013-01-15) initialised: dm-devel@redhat.com
usb 2-1: new full-speed USB device number 3 using uhci_hcd
microcode: CPU0 sig=0x206c2, pf=0x1, revision=0x15
microcode: CPU1 sig=0x206c2, pf=0x1, revision=0x15
microcode: CPU2 sig=0x206c2, pf=0x1, revision=0x15
microcode: CPU3 sig=0x206c2, pf=0x1, revision=0x15
microcode: CPU4 sig=0x206c2, pf=0x1, revision=0x15
microcode: CPU5 sig=0x206c2, pf=0x1, revision=0x15
microcode: CPU6 sig=0x206c2, pf=0x1, revision=0x15
input: American Megatrends Inc. Virtual Keyboard and Mouse as /devices/pci0000:00/0000:00:1a.1/usb2/2-1/2-1:1.0/input/input5
microcode: CPU7 sig=0x206c2, pf=0x1, revision=0x15
microcode: CPU8 sig=0x206c2, pf=0x1, revision=0x15
ttyS0: 5 input overrun(s)
hid-generic 0003:046B:FF10.0003: input: USB HID v1.10 Keyboard [American Megatrends Inc. Virtual Keyboard and Mouse] on usb-0000:00:1a.1-1/input0
microcode: CPU9 sig=0x206c2, pf=0x1, revision=0x15
microcode: CPU10 sig=0x206c2, pf=0x1, revision=0x15
input: American Megatrends Inc. Virtual Keyboard and Mouse as /devices/pci0000:00/0000:00:1a.1/usb2/2-1/2-1:1.1/input/input6
microcode: CPU11 sig=0x206c2, pf=0x1, revision=0x15
microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
hid-generic 0003:046B:FF10.0004: input: USB HID v1.10 Mouse [American Megatrends Inc. Virtual Keyboard and Mouse] on usb-0000:00:1a.1-1/input1
kvm: VM_EXIT_LOAD_IA32_PERF_GLOBAL_CTRL does not work properly. Using workaround
ixgbevf: Intel(R) 10 Gigabit PCI Express Virtual Function Network Driver - version 2.7.12-k
ixgbevf: Copyright (c) 2009 - 2012 Intel Corporation.
ixgbevf 0000:05:10.0: enabling device (0000 -> 0002)
ixgbevf 0000:05:10.0: PF still in reset state, assigning new address
ixgbevf 0000:05:10.0: irq 103 for MSI/MSI-X
ixgbevf 0000:05:10.0: irq 104 for MSI/MSI-X
ixgbevf 0000:05:10.1: enabling device (0000 -> 0002)
ixgbevf 0000:05:10.1: PF still in reset state, assigning new address
ixgbevf 0000:05:10.1: irq 105 for MSI/MSI-X
ixgbevf 0000:05:10.1: irq 106 for MSI/MSI-X
tun: Universal TUN/TAP device driver, 1.6
tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
md: raid0 personality registered for level 0
md/raid0:md127: too few disks (1 of 2) - aborting!
md: pers->run() failed ...
EXT3-fs (sda7): using internal journal
kjournald starting.  Commit interval 5 seconds
EXT3-fs (sda1): using internal journal
EXT3-fs (sda1): recovery complete
EXT3-fs (sda1): mounted filesystem with writeback data mode
EXT4-fs (sdb1): mounted filesystem with ordered data mode. Opts: (null)
Adding 2047996k swap on /dev/sda5.  Priority:-1 extents:1 across:2047996k 
NET: Registered protocol family 10
IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
device eth0 entered promiscuous mode
IPv6: ADDRCONF(NETDEV_UP): br0: link is not ready
igb: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
br0: port 1(eth0) entered forwarding state
br0: port 1(eth0) entered forwarding state
IPv6: ADDRCONF(NETDEV_CHANGE): br0: link becomes ready
br0: port 1(eth0) entered forwarding state
RPC: Registered named UNIX socket transport module.
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
RPC: Registered tcp NFSv4.1 backchannel transport module.
8021q: 802.1Q VLAN Support v1.8
8021q: adding VLAN 0 to HW filter on device eth0
device virbr0-nic entered promiscuous mode
device virbr0-nic left promiscuous mode
virbr0: port 1(virbr0-nic) entered disabled state
device br0 entered promiscuous mode
device br0 left promiscuous mode
NFS: Registering the id_resolver key type
Key type id_resolver registered
Key type id_legacy registered
device lo entered promiscuous mode
device lo left promiscuous mode
ps[4216]: segfault at 7fff9a8ad0a8 ip 0000000000402f7c sp 00007fff9a8ad0b0 error 6 in ps[400000+14000]

--------------010600070305030002060908
Content-Type: text/plain; charset="windows-1255"; name="config-net-2e0cbf2"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="config-net-2e0cbf2"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86 3.9.0-rc5 Kernel Configuration
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
CONFIG_ARCH_HAS_DEFAULT_IDLE=y
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
CONFIG_HAVE_INTEL_TXT=y
CONFIG_X86_64_SMP=y
CONFIG_X86_HT=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
CONFIG_ARCH_CPU_PROBE_RELEASE=y
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
CONFIG_LOCALVERSION=""
# CONFIG_LOCALVERSION_AUTO is not set
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_KERNEL_GZIP=y
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
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
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_IRQ_DOMAIN=y
# CONFIG_IRQ_DOMAIN_DEBUG is not set
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_ALWAYS_USE_PERSISTENT_CLOCK=y
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
# CONFIG_TASK_XACCT is not set

#
# RCU Subsystem
#
CONFIG_TREE_PREEMPT_RCU=y
CONFIG_PREEMPT_RCU=y
CONFIG_RCU_STALL_COMMON=y
# CONFIG_RCU_USER_QS is not set
CONFIG_RCU_FANOUT=64
CONFIG_RCU_FANOUT_LEAF=16
# CONFIG_RCU_FANOUT_EXACT is not set
# CONFIG_RCU_FAST_NO_HZ is not set
# CONFIG_TREE_RCU_TRACE is not set
CONFIG_RCU_BOOST=y
CONFIG_RCU_BOOST_PRIO=1
CONFIG_RCU_BOOST_DELAY=500
# CONFIG_RCU_NOCB_CPU is not set
# CONFIG_IKCONFIG is not set
CONFIG_LOG_BUF_SHIFT=17
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANTS_PROT_NUMA_PROT_NONE=y
# CONFIG_NUMA_BALANCING is not set
# CONFIG_CGROUPS is not set
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_NAMESPACES=y
# CONFIG_UTS_NS is not set
# CONFIG_IPC_NS is not set
# CONFIG_USER_NS is not set
# CONFIG_PID_NS is not set
# CONFIG_NET_NS is not set
CONFIG_UIDGID_CONVERTED=y
# CONFIG_UIDGID_STRICT_TYPE_CHECKS is not set
# CONFIG_SCHED_AUTOGROUP is not set
# CONFIG_SYSFS_DEPRECATED is not set
# CONFIG_RELAY is not set
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
# CONFIG_EXPERT is not set
CONFIG_HAVE_UID16=y
CONFIG_UID16=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_HOTPLUG=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_PCI_QUIRKS=y
CONFIG_SLUB_DEBUG=y
CONFIG_COMPAT_BRK=y
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_PROFILING is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_KPROBES is not set
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
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
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
# CONFIG_MODULE_SRCVERSION_ALL is not set
# CONFIG_MODULE_SIG is not set
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
# CONFIG_BLK_DEV_INTEGRITY is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
# CONFIG_ACORN_PARTITION is not set
# CONFIG_OSF_PARTITION is not set
# CONFIG_AMIGA_PARTITION is not set
# CONFIG_ATARI_PARTITION is not set
# CONFIG_MAC_PARTITION is not set
CONFIG_MSDOS_PARTITION=y
CONFIG_BSD_DISKLABEL=y
# CONFIG_MINIX_SUBPARTITION is not set
# CONFIG_SOLARIS_X86_PARTITION is not set
# CONFIG_UNIXWARE_DISKLABEL is not set
CONFIG_LDM_PARTITION=y
# CONFIG_LDM_DEBUG is not set
# CONFIG_SGI_PARTITION is not set
# CONFIG_ULTRIX_PARTITION is not set
# CONFIG_SUN_PARTITION is not set
# CONFIG_KARMA_PARTITION is not set
CONFIG_EFI_PARTITION=y
# CONFIG_SYSV68_PARTITION is not set
CONFIG_BLOCK_COMPAT=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
# CONFIG_DEFAULT_DEADLINE is not set
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"
CONFIG_PREEMPT_NOTIFIERS=y
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
CONFIG_SCHED_OMIT_FRAME_POINTER=y
# CONFIG_PARAVIRT_GUEST is not set
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
CONFIG_CALGARY_IOMMU=y
CONFIG_CALGARY_IOMMU_ENABLED_BY_DEFAULT=y
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
# CONFIG_MAXSMP is not set
CONFIG_NR_CPUS=16
# CONFIG_SCHED_SMT is not set
CONFIG_SCHED_MC=y
# CONFIG_PREEMPT_NONE is not set
# CONFIG_PREEMPT_VOLUNTARY is not set
CONFIG_PREEMPT=y
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
CONFIG_X86_MCE=y
CONFIG_X86_MCE_INTEL=y
# CONFIG_X86_MCE_AMD is not set
CONFIG_X86_MCE_THRESHOLD=y
# CONFIG_X86_MCE_INJECT is not set
CONFIG_X86_THERMAL_VECTOR=y
# CONFIG_I8K is not set
CONFIG_MICROCODE=m
CONFIG_MICROCODE_INTEL=y
CONFIG_MICROCODE_AMD=y
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_MICROCODE_INTEL_LIB=y
CONFIG_MICROCODE_INTEL_EARLY=y
CONFIG_MICROCODE_EARLY=y
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_DIRECT_GBPAGES=y
CONFIG_NUMA=y
# CONFIG_AMD_NUMA is not set
CONFIG_X86_64_ACPI_NUMA=y
CONFIG_NODES_SPAN_OTHER_NODES=y
# CONFIG_NUMA_EMU is not set
CONFIG_NODES_SHIFT=6
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
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
CONFIG_MEMORY_ISOLATION=y
# CONFIG_MOVABLE_NODE is not set
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
# CONFIG_MEMORY_HOTPLUG is not set
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
CONFIG_MEMORY_FAILURE=y
# CONFIG_HWPOISON_INJECT is not set
CONFIG_TRANSPARENT_HUGEPAGE=y
CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
# CONFIG_TRANSPARENT_HUGEPAGE_MADVISE is not set
CONFIG_CROSS_MEMORY_ATTACH=y
# CONFIG_CLEANCACHE is not set
# CONFIG_FRONTSWAP is not set
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=1
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
CONFIG_X86_SMAP=y
CONFIG_EFI=y
# CONFIG_EFI_STUB is not set
CONFIG_SECCOMP=y
# CONFIG_CC_STACKPROTECTOR is not set
# CONFIG_HZ_100 is not set
CONFIG_HZ_250=y
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=250
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x1000000
CONFIG_HOTPLUG_CPU=y
# CONFIG_BOOTPARAM_HOTPLUG_CPU0 is not set
# CONFIG_DEBUG_HOTPLUG_CPU0 is not set
CONFIG_COMPAT_VDSO=y
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_USE_PERCPU_NUMA_NODE_ID=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
# CONFIG_HIBERNATION is not set
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
# CONFIG_PM_AUTOSLEEP is not set
# CONFIG_PM_WAKELOCKS is not set
CONFIG_PM_RUNTIME=y
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS is not set
CONFIG_ACPI_PROCFS_POWER=y
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_PROC_EVENT=y
CONFIG_ACPI_AC=m
CONFIG_ACPI_BATTERY=m
CONFIG_ACPI_BUTTON=m
CONFIG_ACPI_VIDEO=m
CONFIG_ACPI_FAN=y
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_I2C=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_HOTPLUG_CPU=y
CONFIG_ACPI_PROCESSOR_AGGREGATOR=m
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_NUMA=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
CONFIG_ACPI_BLACKLIST_YEAR=0
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
# CONFIG_ACPI_SBS is not set
CONFIG_ACPI_HED=y
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_BGRT is not set
CONFIG_ACPI_APEI=y
CONFIG_ACPI_APEI_GHES=y
CONFIG_ACPI_APEI_PCIEAER=y
CONFIG_ACPI_APEI_MEMORY_FAILURE=y
# CONFIG_ACPI_APEI_EINJ is not set
# CONFIG_ACPI_APEI_ERST_DEBUG is not set
# CONFIG_SFI is not set

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_TABLE=y
CONFIG_CPU_FREQ_GOV_COMMON=y
# CONFIG_CPU_FREQ_STAT is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=m
CONFIG_CPU_FREQ_GOV_USERSPACE=m
CONFIG_CPU_FREQ_GOV_ONDEMAND=m
# CONFIG_CPU_FREQ_GOV_CONSERVATIVE is not set

#
# x86 CPU frequency scaling drivers
#
# CONFIG_X86_INTEL_PSTATE is not set
# CONFIG_X86_PCC_CPUFREQ is not set
CONFIG_X86_ACPI_CPUFREQ=y
# CONFIG_X86_ACPI_CPUFREQ_CPB is not set
# CONFIG_X86_POWERNOW_K8 is not set
# CONFIG_X86_SPEEDSTEP_CENTRINO is not set
# CONFIG_X86_P4_CLOCKMOD is not set

#
# shared options
#
# CONFIG_X86_SPEEDSTEP_LIB is not set
CONFIG_CPU_IDLE=y
# CONFIG_CPU_IDLE_MULTIPLE_DRIVERS is not set
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
CONFIG_INTEL_IDLE=y

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
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
CONFIG_PCIEPORTBUS=y
# CONFIG_HOTPLUG_PCI_PCIE is not set
CONFIG_PCIEAER=y
# CONFIG_PCIE_ECRC is not set
# CONFIG_PCIEAER_INJECT is not set
CONFIG_PCIEASPM=y
# CONFIG_PCIEASPM_DEBUG is not set
CONFIG_PCIEASPM_DEFAULT=y
# CONFIG_PCIEASPM_POWERSAVE is not set
# CONFIG_PCIEASPM_PERFORMANCE is not set
CONFIG_PCIE_PME=y
CONFIG_ARCH_SUPPORTS_MSI=y
CONFIG_PCI_MSI=y
# CONFIG_PCI_DEBUG is not set
CONFIG_PCI_REALLOC_ENABLE_AUTO=y
CONFIG_PCI_STUB=m
CONFIG_HT_IRQ=y
CONFIG_PCI_ATS=y
CONFIG_PCI_IOV=y
CONFIG_PCI_PRI=y
CONFIG_PCI_PASID=y
CONFIG_PCI_IOAPIC=y
CONFIG_PCI_LABEL=y
CONFIG_ISA_DMA_API=y
CONFIG_AMD_NB=y
# CONFIG_PCCARD is not set
CONFIG_HOTPLUG_PCI=y
CONFIG_HOTPLUG_PCI_ACPI=m
CONFIG_HOTPLUG_PCI_ACPI_IBM=m
# CONFIG_HOTPLUG_PCI_CPCI is not set
CONFIG_HOTPLUG_PCI_SHPC=m
# CONFIG_RAPIDIO is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
# CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=y
CONFIG_COREDUMP=y
CONFIG_IA32_EMULATION=y
# CONFIG_IA32_AOUT is not set
# CONFIG_X86_X32 is not set
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_KEYS_COMPAT=y
CONFIG_HAVE_TEXT_POKE_SMP=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_NET=y

#
# Networking options
#
CONFIG_PACKET=y
CONFIG_PACKET_DIAG=m
CONFIG_UNIX=y
CONFIG_UNIX_DIAG=y
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
CONFIG_XFRM_USER=y
# CONFIG_XFRM_SUB_POLICY is not set
# CONFIG_XFRM_MIGRATE is not set
# CONFIG_XFRM_STATISTICS is not set
CONFIG_XFRM_IPCOMP=m
CONFIG_NET_KEY=m
# CONFIG_NET_KEY_MIGRATE is not set
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
CONFIG_IP_ADVANCED_ROUTER=y
# CONFIG_IP_FIB_TRIE_STATS is not set
CONFIG_IP_MULTIPLE_TABLES=y
CONFIG_IP_ROUTE_MULTIPATH=y
CONFIG_IP_ROUTE_VERBOSE=y
CONFIG_IP_ROUTE_CLASSID=y
# CONFIG_IP_PNP is not set
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE_DEMUX is not set
CONFIG_IP_MROUTE=y
# CONFIG_IP_MROUTE_MULTIPLE_TABLES is not set
CONFIG_IP_PIMSM_V1=y
CONFIG_IP_PIMSM_V2=y
CONFIG_ARPD=y
CONFIG_SYN_COOKIES=y
# CONFIG_INET_AH is not set
# CONFIG_INET_ESP is not set
# CONFIG_INET_IPCOMP is not set
# CONFIG_INET_XFRM_TUNNEL is not set
CONFIG_INET_TUNNEL=m
# CONFIG_INET_XFRM_MODE_TRANSPORT is not set
# CONFIG_INET_XFRM_MODE_TUNNEL is not set
# CONFIG_INET_XFRM_MODE_BEET is not set
CONFIG_INET_LRO=y
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
CONFIG_INET_UDP_DIAG=m
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_CUBIC=y
CONFIG_DEFAULT_TCP_CONG="cubic"
# CONFIG_TCP_MD5SIG is not set
CONFIG_IPV6=m
CONFIG_IPV6_PRIVACY=y
# CONFIG_IPV6_ROUTER_PREF is not set
# CONFIG_IPV6_OPTIMISTIC_DAD is not set
CONFIG_INET6_AH=m
CONFIG_INET6_ESP=m
CONFIG_INET6_IPCOMP=m
# CONFIG_IPV6_MIP6 is not set
CONFIG_INET6_XFRM_TUNNEL=m
CONFIG_INET6_TUNNEL=m
CONFIG_INET6_XFRM_MODE_TRANSPORT=m
CONFIG_INET6_XFRM_MODE_TUNNEL=m
CONFIG_INET6_XFRM_MODE_BEET=m
# CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION is not set
CONFIG_IPV6_SIT=m
# CONFIG_IPV6_SIT_6RD is not set
CONFIG_IPV6_NDISC_NODETYPE=y
CONFIG_IPV6_TUNNEL=m
# CONFIG_IPV6_GRE is not set
# CONFIG_IPV6_MULTIPLE_TABLES is not set
# CONFIG_IPV6_MROUTE is not set
# CONFIG_NETLABEL is not set
CONFIG_NETWORK_SECMARK=y
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
# CONFIG_NETFILTER is not set
# CONFIG_IP_DCCP is not set
# CONFIG_IP_SCTP is not set
# CONFIG_RDS is not set
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
# CONFIG_L2TP is not set
CONFIG_STP=m
CONFIG_BRIDGE=m
CONFIG_BRIDGE_IGMP_SNOOPING=y
# CONFIG_BRIDGE_VLAN_FILTERING is not set
CONFIG_HAVE_NET_DSA=y
CONFIG_VLAN_8021Q=m
# CONFIG_VLAN_8021Q_GVRP is not set
# CONFIG_VLAN_8021Q_MVRP is not set
# CONFIG_DECNET is not set
CONFIG_LLC=m
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
# CONFIG_IEEE802154 is not set
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
CONFIG_NET_SCH_CBQ=m
CONFIG_NET_SCH_HTB=m
CONFIG_NET_SCH_HFSC=m
CONFIG_NET_SCH_PRIO=m
# CONFIG_NET_SCH_MULTIQ is not set
CONFIG_NET_SCH_RED=m
# CONFIG_NET_SCH_SFB is not set
CONFIG_NET_SCH_SFQ=m
CONFIG_NET_SCH_TEQL=m
CONFIG_NET_SCH_TBF=m
CONFIG_NET_SCH_GRED=m
CONFIG_NET_SCH_DSMARK=m
CONFIG_NET_SCH_NETEM=m
# CONFIG_NET_SCH_DRR is not set
# CONFIG_NET_SCH_MQPRIO is not set
# CONFIG_NET_SCH_CHOKE is not set
# CONFIG_NET_SCH_QFQ is not set
CONFIG_NET_SCH_CODEL=m
CONFIG_NET_SCH_FQ_CODEL=m
# CONFIG_NET_SCH_PLUG is not set

#
# Classification
#
CONFIG_NET_CLS=y
# CONFIG_NET_CLS_BASIC is not set
CONFIG_NET_CLS_TCINDEX=m
CONFIG_NET_CLS_ROUTE4=m
CONFIG_NET_CLS_FW=m
CONFIG_NET_CLS_U32=m
CONFIG_CLS_U32_PERF=y
# CONFIG_CLS_U32_MARK is not set
CONFIG_NET_CLS_RSVP=m
CONFIG_NET_CLS_RSVP6=m
# CONFIG_NET_CLS_FLOW is not set
# CONFIG_NET_EMATCH is not set
# CONFIG_NET_CLS_ACT is not set
CONFIG_NET_CLS_IND=y
CONFIG_NET_SCH_FIFO=y
CONFIG_DCB=y
CONFIG_DNS_RESOLVER=y
# CONFIG_BATMAN_ADV is not set
# CONFIG_OPENVSWITCH is not set
# CONFIG_VSOCKETS is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
CONFIG_BQL=y
# CONFIG_BPF_JIT is not set

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
# CONFIG_AF_RXRPC is not set
CONFIG_FIB_RULES=y
# CONFIG_WIRELESS is not set
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
# CONFIG_DEVTMPFS is not set
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
CONFIG_DMA_SHARED_BUFFER=y

#
# Bus devices
#
CONFIG_CONNECTOR=m
# CONFIG_MTD is not set
# CONFIG_PARPORT is not set
CONFIG_PNP=y
# CONFIG_PNP_DEBUG_MESSAGES is not set

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_FD is not set
CONFIG_BLK_DEV_PCIESSD_MTIP32XX=m
# CONFIG_BLK_CPQ_DA is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=m
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
# CONFIG_VIRTIO_BLK is not set
# CONFIG_BLK_DEV_HD is not set
# CONFIG_BLK_DEV_RBD is not set
# CONFIG_BLK_DEV_RSXX is not set

#
# Misc devices
#
# CONFIG_SENSORS_LIS3LV02D is not set
# CONFIG_AD525X_DPOT is not set
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_INTEL_MID_PTI is not set
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
# CONFIG_VMWARE_VMCI is not set
CONFIG_HAVE_IDE=y
CONFIG_IDE=y

#
# Please see Documentation/ide/ide.txt for help/info on IDE drives
#
CONFIG_IDE_XFER_MODE=y
CONFIG_IDE_ATAPI=y
# CONFIG_BLK_DEV_IDE_SATA is not set
CONFIG_IDE_GD=y
CONFIG_IDE_GD_ATA=y
# CONFIG_IDE_GD_ATAPI is not set
CONFIG_BLK_DEV_IDECD=m
CONFIG_BLK_DEV_IDECD_VERBOSE_ERRORS=y
# CONFIG_BLK_DEV_IDETAPE is not set
# CONFIG_BLK_DEV_IDEACPI is not set
# CONFIG_IDE_TASK_IOCTL is not set
CONFIG_IDE_PROC_FS=y

#
# IDE chipset support/bugfixes
#
CONFIG_IDE_GENERIC=y
# CONFIG_BLK_DEV_PLATFORM is not set
# CONFIG_BLK_DEV_CMD640 is not set
CONFIG_BLK_DEV_IDEPNP=y
CONFIG_BLK_DEV_IDEDMA_SFF=y

#
# PCI IDE chipsets support
#
CONFIG_BLK_DEV_IDEPCI=y
CONFIG_IDEPCI_PCIBUS_ORDER=y
# CONFIG_BLK_DEV_OFFBOARD is not set
CONFIG_BLK_DEV_GENERIC=y
# CONFIG_BLK_DEV_OPTI621 is not set
# CONFIG_BLK_DEV_RZ1000 is not set
CONFIG_BLK_DEV_IDEDMA_PCI=y
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
CONFIG_BLK_DEV_PIIX=y
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
CONFIG_BLK_DEV_IDEDMA=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=m
CONFIG_RAID_ATTRS=m
CONFIG_SCSI=m
CONFIG_SCSI_DMA=y
CONFIG_SCSI_TGT=m
CONFIG_SCSI_NETLINK=y
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=m
# CONFIG_CHR_DEV_ST is not set
# CONFIG_CHR_DEV_OSST is not set
# CONFIG_BLK_DEV_SR is not set
CONFIG_CHR_DEV_SG=m
# CONFIG_CHR_DEV_SCH is not set
# CONFIG_SCSI_MULTI_LUN is not set
CONFIG_SCSI_CONSTANTS=y
CONFIG_SCSI_LOGGING=y
CONFIG_SCSI_SCAN_ASYNC=y

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=m
CONFIG_SCSI_FC_ATTRS=m
# CONFIG_SCSI_FC_TGT_ATTRS is not set
CONFIG_SCSI_ISCSI_ATTRS=m
CONFIG_SCSI_SAS_ATTRS=m
CONFIG_SCSI_SAS_LIBSAS=m
# CONFIG_SCSI_SAS_ATA is not set
CONFIG_SCSI_SAS_HOST_SMP=y
CONFIG_SCSI_SRP_ATTRS=m
CONFIG_SCSI_SRP_TGT_ATTRS=y
CONFIG_SCSI_LOWLEVEL=y
CONFIG_ISCSI_TCP=m
CONFIG_ISCSI_BOOT_SYSFS=m
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
CONFIG_SCSI_AACRAID=m
CONFIG_SCSI_AIC7XXX=m
CONFIG_AIC7XXX_CMDS_PER_DEVICE=32
CONFIG_AIC7XXX_RESET_DELAY_MS=5000
CONFIG_AIC7XXX_DEBUG_ENABLE=y
CONFIG_AIC7XXX_DEBUG_MASK=0
CONFIG_AIC7XXX_REG_PRETTY_PRINT=y
# CONFIG_SCSI_AIC7XXX_OLD is not set
CONFIG_SCSI_AIC79XX=m
CONFIG_AIC79XX_CMDS_PER_DEVICE=32
CONFIG_AIC79XX_RESET_DELAY_MS=5000
CONFIG_AIC79XX_DEBUG_ENABLE=y
CONFIG_AIC79XX_DEBUG_MASK=0
CONFIG_AIC79XX_REG_PRETTY_PRINT=y
CONFIG_SCSI_AIC94XX=m
CONFIG_AIC94XX_DEBUG=y
# CONFIG_SCSI_MVSAS is not set
# CONFIG_SCSI_MVUMI is not set
CONFIG_SCSI_DPT_I2O=m
CONFIG_SCSI_ADVANSYS=m
# CONFIG_SCSI_ARCMSR is not set
CONFIG_MEGARAID_NEWGEN=y
CONFIG_MEGARAID_MM=m
CONFIG_MEGARAID_MAILBOX=m
# CONFIG_MEGARAID_LEGACY is not set
CONFIG_MEGARAID_SAS=m
CONFIG_SCSI_MPT2SAS=m
CONFIG_SCSI_MPT2SAS_MAX_SGE=128
# CONFIG_SCSI_MPT2SAS_LOGGING is not set
# CONFIG_SCSI_MPT3SAS is not set
# CONFIG_SCSI_UFSHCD is not set
# CONFIG_SCSI_HPTIOP is not set
# CONFIG_SCSI_BUSLOGIC is not set
# CONFIG_VMWARE_PVSCSI is not set
# CONFIG_LIBFC is not set
# CONFIG_LIBFCOE is not set
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
# CONFIG_SCSI_STEX is not set
# CONFIG_SCSI_SYM53C8XX_2 is not set
# CONFIG_SCSI_IPR is not set
CONFIG_SCSI_QLOGIC_1280=m
CONFIG_SCSI_QLA_FC=m
CONFIG_SCSI_QLA_ISCSI=m
# CONFIG_SCSI_LPFC is not set
# CONFIG_SCSI_DC395x is not set
# CONFIG_SCSI_DC390T is not set
# CONFIG_SCSI_DEBUG is not set
# CONFIG_SCSI_PMCRAID is not set
# CONFIG_SCSI_PM8001 is not set
CONFIG_SCSI_SRP=m
# CONFIG_SCSI_BFA_FC is not set
# CONFIG_SCSI_VIRTIO is not set
# CONFIG_SCSI_CHELSIO_FCOE is not set
# CONFIG_SCSI_DH is not set
# CONFIG_SCSI_OSD_INITIATOR is not set
CONFIG_ATA=m
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_VERBOSE_ERROR=y
CONFIG_ATA_ACPI=y
# CONFIG_SATA_ZPODD is not set
CONFIG_SATA_PMP=y

#
# Controllers with non-SFF native interface
#
CONFIG_SATA_AHCI=m
CONFIG_SATA_AHCI_PLATFORM=m
CONFIG_SATA_INIC162X=m
CONFIG_SATA_ACARD_AHCI=m
CONFIG_SATA_SIL24=m
CONFIG_ATA_SFF=y

#
# SFF controllers with custom DMA interface
#
CONFIG_PDC_ADMA=m
CONFIG_SATA_QSTOR=m
CONFIG_SATA_SX4=m
CONFIG_ATA_BMDMA=y

#
# SATA SFF controllers with BMDMA
#
CONFIG_ATA_PIIX=m
CONFIG_SATA_HIGHBANK=m
CONFIG_SATA_MV=m
CONFIG_SATA_NV=m
CONFIG_SATA_PROMISE=m
CONFIG_SATA_SIL=m
CONFIG_SATA_SIS=m
CONFIG_SATA_SVW=m
CONFIG_SATA_ULI=m
CONFIG_SATA_VIA=m
CONFIG_SATA_VITESSE=m

#
# PATA SFF controllers with BMDMA
#
# CONFIG_PATA_ALI is not set
# CONFIG_PATA_AMD is not set
# CONFIG_PATA_ARASAN_CF is not set
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
CONFIG_PATA_SIS=m
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
# CONFIG_PATA_RZ1000 is not set

#
# Generic fallback / legacy drivers
#
# CONFIG_PATA_ACPI is not set
# CONFIG_ATA_GENERIC is not set
# CONFIG_PATA_LEGACY is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
CONFIG_MD_AUTODETECT=y
CONFIG_MD_LINEAR=m
CONFIG_MD_RAID0=m
CONFIG_MD_RAID1=m
CONFIG_MD_RAID10=m
CONFIG_MD_RAID456=m
CONFIG_MD_MULTIPATH=m
# CONFIG_MD_FAULTY is not set
CONFIG_BLK_DEV_DM=m
# CONFIG_DM_DEBUG is not set
CONFIG_DM_CRYPT=m
CONFIG_DM_SNAPSHOT=m
# CONFIG_DM_THIN_PROVISIONING is not set
# CONFIG_DM_CACHE is not set
CONFIG_DM_MIRROR=m
CONFIG_DM_RAID=m
# CONFIG_DM_LOG_USERSPACE is not set
CONFIG_DM_ZERO=m
CONFIG_DM_MULTIPATH=m
# CONFIG_DM_MULTIPATH_QL is not set
# CONFIG_DM_MULTIPATH_ST is not set
# CONFIG_DM_DELAY is not set
# CONFIG_DM_UEVENT is not set
# CONFIG_DM_FLAKEY is not set
# CONFIG_DM_VERITY is not set
# CONFIG_TARGET_CORE is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_I2O is not set
# CONFIG_MACINTOSH_DRIVERS is not set
CONFIG_NETDEVICES=y
CONFIG_NET_CORE=y
# CONFIG_BONDING is not set
# CONFIG_DUMMY is not set
# CONFIG_EQUALIZER is not set
# CONFIG_NET_FC is not set
# CONFIG_MII is not set
# CONFIG_NET_TEAM is not set
CONFIG_MACVLAN=m
CONFIG_MACVTAP=m
# CONFIG_VXLAN is not set
# CONFIG_NETCONSOLE is not set
# CONFIG_NETPOLL is not set
# CONFIG_NET_POLL_CONTROLLER is not set
CONFIG_TUN=m
# CONFIG_VETH is not set
CONFIG_VIRTIO_NET=m
# CONFIG_ARCNET is not set

#
# CAIF transport drivers
#

#
# Distributed Switch Architecture drivers
#
# CONFIG_NET_DSA_MV88E6XXX is not set
# CONFIG_NET_DSA_MV88E6060 is not set
# CONFIG_NET_DSA_MV88E6XXX_NEED_PPU is not set
# CONFIG_NET_DSA_MV88E6131 is not set
# CONFIG_NET_DSA_MV88E6123_61_65 is not set
CONFIG_ETHERNET=y
CONFIG_MDIO=m
# CONFIG_NET_VENDOR_3COM is not set
# CONFIG_NET_VENDOR_ADAPTEC is not set
# CONFIG_NET_VENDOR_ALTEON is not set
# CONFIG_NET_VENDOR_AMD is not set
# CONFIG_NET_VENDOR_ATHEROS is not set
# CONFIG_NET_CADENCE is not set
# CONFIG_NET_VENDOR_BROADCOM is not set
# CONFIG_NET_VENDOR_BROCADE is not set
# CONFIG_NET_CALXEDA_XGMAC is not set
# CONFIG_NET_VENDOR_CHELSIO is not set
# CONFIG_NET_VENDOR_CISCO is not set
# CONFIG_DNET is not set
# CONFIG_NET_VENDOR_DEC is not set
# CONFIG_NET_VENDOR_DLINK is not set
# CONFIG_NET_VENDOR_EMULEX is not set
# CONFIG_NET_VENDOR_EXAR is not set
# CONFIG_NET_VENDOR_HP is not set
CONFIG_NET_VENDOR_INTEL=y
# CONFIG_E100 is not set
CONFIG_E1000=m
CONFIG_E1000E=m
CONFIG_IGB=m
CONFIG_IGB_HWMON=y
CONFIG_IGB_DCA=y
CONFIG_IGBVF=m
CONFIG_IXGB=m
CONFIG_IXGBE=m
CONFIG_IXGBE_HWMON=y
CONFIG_IXGBE_DCA=y
CONFIG_IXGBE_DCB=y
CONFIG_IXGBEVF=m
CONFIG_NET_VENDOR_I825XX=y
# CONFIG_IP1000 is not set
# CONFIG_JME is not set
# CONFIG_NET_VENDOR_MARVELL is not set
CONFIG_NET_VENDOR_MELLANOX=y
CONFIG_MLX4_EN=m
CONFIG_MLX4_EN_DCB=y
CONFIG_MLX4_CORE=m
CONFIG_MLX4_DEBUG=y
# CONFIG_NET_VENDOR_MICREL is not set
# CONFIG_NET_VENDOR_MYRI is not set
# CONFIG_FEALNX is not set
# CONFIG_NET_VENDOR_NATSEMI is not set
# CONFIG_NET_VENDOR_NVIDIA is not set
# CONFIG_NET_VENDOR_OKI is not set
# CONFIG_ETHOC is not set
# CONFIG_NET_PACKET_ENGINE is not set
# CONFIG_NET_VENDOR_QLOGIC is not set
# CONFIG_NET_VENDOR_REALTEK is not set
# CONFIG_NET_VENDOR_RDC is not set
# CONFIG_NET_VENDOR_SEEQ is not set
# CONFIG_NET_VENDOR_SILAN is not set
# CONFIG_NET_VENDOR_SIS is not set
# CONFIG_SFC is not set
# CONFIG_NET_VENDOR_SMSC is not set
# CONFIG_NET_VENDOR_STMICRO is not set
# CONFIG_NET_VENDOR_SUN is not set
# CONFIG_NET_VENDOR_TEHUTI is not set
# CONFIG_NET_VENDOR_TI is not set
# CONFIG_NET_VENDOR_VIA is not set
# CONFIG_NET_VENDOR_WIZNET is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_NET_SB1000 is not set
# CONFIG_PHYLIB is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set

#
# USB Network Adapters
#
# CONFIG_USB_CATC is not set
# CONFIG_USB_KAWETH is not set
# CONFIG_USB_PEGASUS is not set
# CONFIG_USB_RTL8150 is not set
# CONFIG_USB_USBNET is not set
# CONFIG_USB_IPHETH is not set
# CONFIG_WLAN is not set

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
CONFIG_INPUT_POLLDEV=m
CONFIG_INPUT_SPARSEKMAP=m
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_INPUT_JOYDEV=m
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
CONFIG_MOUSE_SERIAL=m
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
# CONFIG_MOUSE_CYAPA is not set
# CONFIG_MOUSE_VSXXXAA is not set
# CONFIG_MOUSE_SYNAPTICS_I2C is not set
# CONFIG_MOUSE_SYNAPTICS_USB is not set
CONFIG_INPUT_JOYSTICK=y
# CONFIG_JOYSTICK_ANALOG is not set
# CONFIG_JOYSTICK_A3D is not set
# CONFIG_JOYSTICK_ADI is not set
# CONFIG_JOYSTICK_COBRA is not set
# CONFIG_JOYSTICK_GF2K is not set
# CONFIG_JOYSTICK_GRIP is not set
# CONFIG_JOYSTICK_GRIP_MP is not set
# CONFIG_JOYSTICK_GUILLEMOT is not set
# CONFIG_JOYSTICK_INTERACT is not set
# CONFIG_JOYSTICK_SIDEWINDER is not set
# CONFIG_JOYSTICK_TMDC is not set
# CONFIG_JOYSTICK_IFORCE is not set
# CONFIG_JOYSTICK_WARRIOR is not set
# CONFIG_JOYSTICK_MAGELLAN is not set
# CONFIG_JOYSTICK_SPACEORB is not set
# CONFIG_JOYSTICK_SPACEBALL is not set
# CONFIG_JOYSTICK_STINGER is not set
# CONFIG_JOYSTICK_TWIDJOY is not set
# CONFIG_JOYSTICK_ZHENHUA is not set
# CONFIG_JOYSTICK_AS5011 is not set
# CONFIG_JOYSTICK_JOYDUMP is not set
# CONFIG_JOYSTICK_XPAD is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
CONFIG_INPUT_MISC=y
# CONFIG_INPUT_AD714X is not set
# CONFIG_INPUT_BMA150 is not set
CONFIG_INPUT_PCSPKR=m
# CONFIG_INPUT_MMA8450 is not set
# CONFIG_INPUT_MPU3050 is not set
# CONFIG_INPUT_ATLAS_BTNS is not set
# CONFIG_INPUT_ATI_REMOTE2 is not set
# CONFIG_INPUT_KEYSPAN_REMOTE is not set
# CONFIG_INPUT_KXTJ9 is not set
# CONFIG_INPUT_POWERMATE is not set
# CONFIG_INPUT_YEALINK is not set
# CONFIG_INPUT_CM109 is not set
CONFIG_INPUT_UINPUT=m
# CONFIG_INPUT_PCF8574 is not set
# CONFIG_INPUT_ADXL34X is not set
# CONFIG_INPUT_CMA3000 is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=m
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
# CONFIG_VT_HW_CONSOLE_BINDING is not set
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
# CONFIG_DEVKMEM is not set
# CONFIG_STALDRV is not set

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
# CONFIG_SERIAL_8250_DEPRECATED_OPTIONS is not set
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_DMA=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_NR_UARTS=64
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
# CONFIG_SERIAL_8250_MANY_PORTS is not set
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
# CONFIG_VIRTIO_CONSOLE is not set
# CONFIG_IPMI_HANDLER is not set
# CONFIG_HW_RANDOM is not set
# CONFIG_NVRAM is not set
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_MWAVE is not set
# CONFIG_RAW_DRIVER is not set
CONFIG_HPET=y
CONFIG_HPET_MMAP=y
# CONFIG_HANGCHECK_TIMER is not set
# CONFIG_TCG_TPM is not set
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
CONFIG_I2C_CHARDEV=m
CONFIG_I2C_MUX=m

#
# Multiplexer I2C Chip support
#
# CONFIG_I2C_MUX_PCA9541 is not set
# CONFIG_I2C_MUX_PCA954x is not set
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
CONFIG_I2C_I801=m
CONFIG_I2C_ISCH=m
# CONFIG_I2C_ISMT is not set
CONFIG_I2C_PIIX4=m
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set

#
# ACPI drivers
#
CONFIG_I2C_SCMI=m

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_DESIGNWARE_PCI is not set
CONFIG_I2C_EG20T=m
CONFIG_I2C_INTEL_MID=m
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
CONFIG_PPS=m
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
CONFIG_PTP_1588_CLOCK=m

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
# CONFIG_BATTERY_GOLDFISH is not set
# CONFIG_POWER_RESET is not set
# CONFIG_POWER_AVS is not set
CONFIG_HWMON=m
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
# CONFIG_SENSORS_GL518SM is not set
# CONFIG_SENSORS_GL520SM is not set
# CONFIG_SENSORS_HIH6130 is not set
# CONFIG_SENSORS_CORETEMP is not set
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
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_GOV_STEP_WISE=y
# CONFIG_THERMAL_GOV_USER_SPACE is not set
CONFIG_CPU_THERMAL=y
# CONFIG_THERMAL_EMULATION is not set
# CONFIG_INTEL_POWERCLAMP is not set
CONFIG_WATCHDOG=y
# CONFIG_WATCHDOG_CORE is not set
# CONFIG_WATCHDOG_NOWAYOUT is not set

#
# Watchdog Device Drivers
#
# CONFIG_SOFT_WATCHDOG is not set
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
# CONFIG_I6300ESB_WDT is not set
# CONFIG_IE6XX_WDT is not set
# CONFIG_ITCO_WDT is not set
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
CONFIG_MFD_CORE=m
# CONFIG_MFD_88PM860X is not set
# CONFIG_MFD_88PM800 is not set
# CONFIG_MFD_88PM805 is not set
# CONFIG_MFD_SM501 is not set
# CONFIG_MFD_RTSX_PCI is not set
# CONFIG_MFD_TI_AM335X_TSCADC is not set
# CONFIG_HTC_PASIC3 is not set
# CONFIG_MFD_LM3533 is not set
# CONFIG_TPS6105X is not set
# CONFIG_TPS6507X is not set
# CONFIG_MFD_TPS65217 is not set
# CONFIG_MFD_TPS6586X is not set
# CONFIG_MFD_TPS80031 is not set
# CONFIG_TWL4030_CORE is not set
# CONFIG_TWL6040_CORE is not set
# CONFIG_MFD_STMPE is not set
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_SMSC is not set
# CONFIG_PMIC_DA903X is not set
# CONFIG_MFD_DA9052_I2C is not set
# CONFIG_MFD_DA9055 is not set
# CONFIG_PMIC_ADP5520 is not set
# CONFIG_MFD_LP8788 is not set
# CONFIG_MFD_MAX77686 is not set
# CONFIG_MFD_MAX77693 is not set
# CONFIG_MFD_MAX8907 is not set
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
# CONFIG_MFD_MAX8998 is not set
# CONFIG_MFD_SEC_CORE is not set
# CONFIG_MFD_ARIZONA_I2C is not set
# CONFIG_MFD_WM8400 is not set
# CONFIG_MFD_WM831X_I2C is not set
# CONFIG_MFD_WM8350_I2C is not set
# CONFIG_MFD_WM8994 is not set
# CONFIG_MFD_PCF50633 is not set
# CONFIG_MFD_MC13XXX_I2C is not set
# CONFIG_ABX500_CORE is not set
# CONFIG_MFD_CS5535 is not set
CONFIG_LPC_SCH=m
# CONFIG_LPC_ICH is not set
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_JANZ_CMODIO is not set
# CONFIG_MFD_VX855 is not set
# CONFIG_MFD_WL1273_CORE is not set
# CONFIG_MFD_TPS65090 is not set
# CONFIG_MFD_RC5T583 is not set
# CONFIG_MFD_PALMAS is not set
# CONFIG_MFD_VIPERBOARD is not set
# CONFIG_MFD_RETU is not set
# CONFIG_MFD_AS3711 is not set
# CONFIG_REGULATOR is not set
# CONFIG_MEDIA_SUPPORT is not set

#
# Graphics support
#
CONFIG_AGP=y
# CONFIG_AGP_AMD64 is not set
CONFIG_AGP_INTEL=y
# CONFIG_AGP_SIS is not set
# CONFIG_AGP_VIA is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
CONFIG_DRM=y
CONFIG_DRM_KMS_HELPER=m
# CONFIG_DRM_LOAD_EDID_FIRMWARE is not set
CONFIG_DRM_TTM=m

#
# I2C encoder or helper chips
#
# CONFIG_DRM_I2C_CH7006 is not set
# CONFIG_DRM_I2C_SIL164 is not set
# CONFIG_DRM_I2C_NXP_TDA998X is not set
# CONFIG_DRM_TDFX is not set
# CONFIG_DRM_R128 is not set
CONFIG_DRM_RADEON=m
# CONFIG_DRM_RADEON_UMS is not set
# CONFIG_DRM_NOUVEAU is not set
# CONFIG_DRM_I915 is not set
# CONFIG_DRM_MGA is not set
# CONFIG_DRM_SIS is not set
# CONFIG_DRM_VIA is not set
# CONFIG_DRM_SAVAGE is not set
# CONFIG_DRM_VMWGFX is not set
# CONFIG_DRM_GMA500 is not set
# CONFIG_DRM_UDL is not set
# CONFIG_DRM_AST is not set
# CONFIG_DRM_MGAG200 is not set
# CONFIG_DRM_CIRRUS_QEMU is not set
CONFIG_VGASTATE=m
CONFIG_VIDEO_OUTPUT_CONTROL=m
CONFIG_HDMI=y
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_DDC=m
CONFIG_FB_BOOT_VESA_SUPPORT=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
# CONFIG_FB_SYS_FILLRECT is not set
# CONFIG_FB_SYS_COPYAREA is not set
# CONFIG_FB_SYS_IMAGEBLIT is not set
# CONFIG_FB_FOREIGN_ENDIAN is not set
# CONFIG_FB_SYS_FOPS is not set
# CONFIG_FB_WMT_GE_ROPS is not set
# CONFIG_FB_SVGALIB is not set
# CONFIG_FB_MACMODES is not set
CONFIG_FB_BACKLIGHT=y
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
CONFIG_FB_VGA16=m
# CONFIG_FB_UVESA is not set
CONFIG_FB_VESA=y
# CONFIG_FB_EFI is not set
# CONFIG_FB_N411 is not set
# CONFIG_FB_HGA is not set
# CONFIG_FB_S1D13XXX is not set
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_I740 is not set
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_MATROX is not set
CONFIG_FB_RADEON=m
CONFIG_FB_RADEON_I2C=y
CONFIG_FB_RADEON_BACKLIGHT=y
# CONFIG_FB_RADEON_DEBUG is not set
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
# CONFIG_FB_TMIO is not set
# CONFIG_FB_SMSCUFX is not set
# CONFIG_FB_UDL is not set
# CONFIG_FB_GOLDFISH is not set
# CONFIG_FB_VIRTUAL is not set
# CONFIG_FB_METRONOME is not set
# CONFIG_FB_MB862XX is not set
# CONFIG_FB_BROADSHEET is not set
# CONFIG_FB_AUO_K190X is not set
# CONFIG_EXYNOS_VIDEO is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=m
# CONFIG_LCD_PLATFORM is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
# CONFIG_BACKLIGHT_GENERIC is not set
# CONFIG_BACKLIGHT_APPLE is not set
# CONFIG_BACKLIGHT_SAHARA is not set
# CONFIG_BACKLIGHT_ADP8860 is not set
# CONFIG_BACKLIGHT_ADP8870 is not set
# CONFIG_BACKLIGHT_LM3630 is not set
# CONFIG_BACKLIGHT_LM3639 is not set
# CONFIG_BACKLIGHT_LP855X is not set

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
# CONFIG_VGACON_SOFT_SCROLLBACK is not set
CONFIG_DUMMY_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=y
# CONFIG_FRAMEBUFFER_CONSOLE_ROTATION is not set
# CONFIG_FONTS is not set
CONFIG_FONT_8x8=y
CONFIG_FONT_8x16=y
CONFIG_LOGO=y
# CONFIG_LOGO_LINUX_MONO is not set
# CONFIG_LOGO_LINUX_VGA16 is not set
CONFIG_LOGO_LINUX_CLUT224=y
# CONFIG_SOUND is not set

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
# CONFIG_HIDRAW is not set
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
# CONFIG_HID_ACRUX is not set
CONFIG_HID_APPLE=y
# CONFIG_HID_AUREAL is not set
CONFIG_HID_BELKIN=y
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
CONFIG_HID_CYPRESS=y
CONFIG_HID_DRAGONRISE=y
# CONFIG_DRAGONRISE_FF is not set
# CONFIG_HID_EMS_FF is not set
CONFIG_HID_EZKEY=y
# CONFIG_HID_HOLTEK is not set
# CONFIG_HID_KEYTOUCH is not set
CONFIG_HID_KYE=y
# CONFIG_HID_UCLOGIC is not set
# CONFIG_HID_WALTOP is not set
CONFIG_HID_GYRATION=y
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
CONFIG_HID_SONY=y
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
CONFIG_USB_ARCH_HAS_OHCI=y
CONFIG_USB_ARCH_HAS_EHCI=y
CONFIG_USB_ARCH_HAS_XHCI=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
# CONFIG_USB_DEBUG is not set
# CONFIG_USB_ANNOUNCE_NEW_DEVICES is not set

#
# Miscellaneous USB options
#
# CONFIG_USB_DYNAMIC_MINORS is not set
# CONFIG_USB_SUSPEND is not set
# CONFIG_USB_DWC3 is not set
CONFIG_USB_MON=y
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
CONFIG_USB_XHCI_HCD=m
# CONFIG_USB_XHCI_HCD_DEBUGGING is not set
CONFIG_USB_EHCI_HCD=m
CONFIG_USB_EHCI_ROOT_HUB_TT=y
CONFIG_USB_EHCI_TT_NEWSCHED=y
CONFIG_USB_EHCI_PCI=m
# CONFIG_USB_OXU210HP_HCD is not set
# CONFIG_USB_ISP116X_HCD is not set
# CONFIG_USB_ISP1760_HCD is not set
# CONFIG_USB_ISP1362_HCD is not set
CONFIG_USB_OHCI_HCD=m
# CONFIG_USB_OHCI_HCD_PLATFORM is not set
# CONFIG_USB_EHCI_HCD_PLATFORM is not set
# CONFIG_USB_OHCI_BIG_ENDIAN_DESC is not set
# CONFIG_USB_OHCI_BIG_ENDIAN_MMIO is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_UHCI_HCD=m
# CONFIG_USB_SL811_HCD is not set
# CONFIG_USB_R8A66597_HCD is not set
# CONFIG_USB_CHIPIDEA is not set

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
CONFIG_USB_STORAGE=m
# CONFIG_USB_STORAGE_DEBUG is not set
# CONFIG_USB_STORAGE_REALTEK is not set
# CONFIG_USB_STORAGE_DATAFAB is not set
# CONFIG_USB_STORAGE_FREECOM is not set
# CONFIG_USB_STORAGE_ISD200 is not set
# CONFIG_USB_STORAGE_USBAT is not set
# CONFIG_USB_STORAGE_SDDR09 is not set
# CONFIG_USB_STORAGE_SDDR55 is not set
# CONFIG_USB_STORAGE_JUMPSHOT is not set
# CONFIG_USB_STORAGE_ALAUDA is not set
# CONFIG_USB_STORAGE_ONETOUCH is not set
# CONFIG_USB_STORAGE_KARMA is not set
# CONFIG_USB_STORAGE_CYPRESS_ATACB is not set
# CONFIG_USB_STORAGE_ENE_UB6250 is not set

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
# CONFIG_USB_MICROTEK is not set

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
# CONFIG_USB_TEST is not set
# CONFIG_USB_ISIGHTFW is not set
# CONFIG_USB_YUREX is not set
# CONFIG_USB_EZUSB_FX2 is not set
# CONFIG_USB_HSIC_USB3503 is not set

#
# USB Physical Layer drivers
#
# CONFIG_OMAP_USB3 is not set
# CONFIG_OMAP_CONTROL_USB is not set
# CONFIG_USB_ISP1301 is not set
# CONFIG_USB_RCAR_PHY is not set
# CONFIG_USB_GADGET is not set

#
# OTG and related infrastructure
#
# CONFIG_NOP_USB_XCEIV is not set
# CONFIG_UWB is not set
# CONFIG_MMC is not set
# CONFIG_MEMSTICK is not set
# CONFIG_NEW_LEDS is not set
# CONFIG_ACCESSIBILITY is not set
CONFIG_INFINIBAND=m
CONFIG_INFINIBAND_USER_MAD=m
CONFIG_INFINIBAND_USER_ACCESS=m
CONFIG_INFINIBAND_USER_MEM=y
CONFIG_INFINIBAND_ADDR_TRANS=y
CONFIG_INFINIBAND_MTHCA=m
CONFIG_INFINIBAND_MTHCA_DEBUG=y
# CONFIG_INFINIBAND_IPATH is not set
# CONFIG_INFINIBAND_QIB is not set
# CONFIG_INFINIBAND_AMSO1100 is not set
CONFIG_MLX4_INFINIBAND=m
# CONFIG_INFINIBAND_NES is not set
# CONFIG_INFINIBAND_OCRDMA is not set
CONFIG_INFINIBAND_IPOIB=m
CONFIG_INFINIBAND_IPOIB_CM=y
CONFIG_INFINIBAND_IPOIB_DEBUG=y
# CONFIG_INFINIBAND_IPOIB_DEBUG_DATA is not set
CONFIG_INFINIBAND_SRP=m
CONFIG_INFINIBAND_ISER=m
CONFIG_EDAC=y
CONFIG_EDAC_LEGACY_SYSFS=y
# CONFIG_EDAC_DEBUG is not set
CONFIG_EDAC_MM_EDAC=y
CONFIG_EDAC_GHES=y
CONFIG_EDAC_E752X=y
CONFIG_EDAC_I82975X=y
CONFIG_EDAC_I3000=y
CONFIG_EDAC_I3200=y
CONFIG_EDAC_X38=y
CONFIG_EDAC_I5400=y
CONFIG_EDAC_I7CORE=y
CONFIG_EDAC_I5000=y
CONFIG_EDAC_I5100=y
CONFIG_EDAC_I7300=y
CONFIG_EDAC_SBRIDGE=y
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
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

#
# HID Sensor RTC drivers
#
# CONFIG_RTC_DRV_HID_SENSOR_TIME is not set
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
CONFIG_INTEL_MID_DMAC=m
CONFIG_INTEL_IOATDMA=m
# CONFIG_DW_DMAC is not set
# CONFIG_TIMB_DMA is not set
CONFIG_PCH_DMA=m
CONFIG_DMA_ENGINE=y

#
# DMA Clients
#
CONFIG_NET_DMA=y
# CONFIG_ASYNC_TX_DMA is not set
# CONFIG_DMATEST is not set
CONFIG_DCA=m
# CONFIG_AUXDISPLAY is not set
# CONFIG_UIO is not set
# CONFIG_VFIO is not set
CONFIG_VIRTIO=m

#
# Virtio drivers
#
CONFIG_VIRTIO_PCI=m
CONFIG_VIRTIO_BALLOON=m
CONFIG_VIRTIO_MMIO=m
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
# CONFIG_DELL_LAPTOP is not set
# CONFIG_FUJITSU_LAPTOP is not set
# CONFIG_FUJITSU_TABLET is not set
# CONFIG_HP_ACCEL is not set
# CONFIG_PANASONIC_LAPTOP is not set
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
# CONFIG_SAMSUNG_LAPTOP is not set
# CONFIG_SAMSUNG_Q10 is not set
# CONFIG_APPLE_GMUX is not set

#
# Hardware Spinlock drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
# CONFIG_MAILBOX is not set
CONFIG_IOMMU_API=y
CONFIG_IOMMU_SUPPORT=y
# CONFIG_AMD_IOMMU is not set
CONFIG_DMAR_TABLE=y
CONFIG_INTEL_IOMMU=y
CONFIG_INTEL_IOMMU_DEFAULT_ON=y
CONFIG_INTEL_IOMMU_FLOPPY_WA=y
# CONFIG_IRQ_REMAP is not set

#
# Remoteproc drivers
#
# CONFIG_STE_MODEM_RPROC is not set

#
# Rpmsg drivers
#
# CONFIG_VIRT_DRIVERS is not set
# CONFIG_PM_DEVFREQ is not set
# CONFIG_EXTCON is not set
# CONFIG_MEMORY is not set
# CONFIG_IIO is not set
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set
# CONFIG_IPACK_BUS is not set

#
# Firmware Drivers
#
CONFIG_EDD=m
# CONFIG_EDD_OFF is not set
CONFIG_FIRMWARE_MEMMAP=y
# CONFIG_EFI_VARS is not set
CONFIG_DELL_RBU=m
CONFIG_DCDBAS=m
CONFIG_DMIID=y
# CONFIG_DMI_SYSFS is not set
# CONFIG_ISCSI_IBFT_FIND is not set
# CONFIG_GOOGLE_FIRMWARE is not set

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_EXT2_FS=y
CONFIG_EXT2_FS_XATTR=y
CONFIG_EXT2_FS_POSIX_ACL=y
CONFIG_EXT2_FS_SECURITY=y
# CONFIG_EXT2_FS_XIP is not set
CONFIG_EXT3_FS=m
# CONFIG_EXT3_DEFAULTS_TO_ORDERED is not set
CONFIG_EXT3_FS_XATTR=y
CONFIG_EXT3_FS_POSIX_ACL=y
CONFIG_EXT3_FS_SECURITY=y
CONFIG_EXT4_FS=m
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
# CONFIG_EXT4_DEBUG is not set
CONFIG_JBD=m
# CONFIG_JBD_DEBUG is not set
CONFIG_JBD2=m
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
# CONFIG_REISERFS_FS is not set
# CONFIG_JFS_FS is not set
# CONFIG_XFS_FS is not set
# CONFIG_GFS2_FS is not set
# CONFIG_OCFS2_FS is not set
# CONFIG_BTRFS_FS is not set
# CONFIG_NILFS2_FS is not set
CONFIG_FS_POSIX_ACL=y
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
# CONFIG_FANOTIFY is not set
CONFIG_QUOTA=y
CONFIG_QUOTA_NETLINK_INTERFACE=y
CONFIG_PRINT_QUOTA_WARNING=y
# CONFIG_QUOTA_DEBUG is not set
CONFIG_QUOTA_TREE=y
# CONFIG_QFMT_V1 is not set
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
CONFIG_AUTOFS4_FS=m
# CONFIG_FUSE_FS is not set

#
# Caches
#
# CONFIG_FSCACHE is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=m
CONFIG_JOLIET=y
CONFIG_ZISOFS=y
CONFIG_UDF_FS=m
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=m
CONFIG_MSDOS_FS=m
CONFIG_VFAT_FS=m
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
# CONFIG_TMPFS_POSIX_ACL is not set
# CONFIG_TMPFS_XATTR is not set
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=m
CONFIG_MISC_FILESYSTEMS=y
# CONFIG_ADFS_FS is not set
# CONFIG_AFFS_FS is not set
CONFIG_ECRYPT_FS=m
# CONFIG_ECRYPT_FS_MESSAGING is not set
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
# CONFIG_ROMFS_FS is not set
CONFIG_PSTORE=y
# CONFIG_PSTORE_CONSOLE is not set
# CONFIG_PSTORE_RAM is not set
# CONFIG_SYSV_FS is not set
# CONFIG_UFS_FS is not set
# CONFIG_F2FS_FS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=m
CONFIG_NFS_V2=m
CONFIG_NFS_V3=m
CONFIG_NFS_V3_ACL=y
CONFIG_NFS_V4=m
# CONFIG_NFS_SWAP is not set
CONFIG_NFS_V4_1=y
CONFIG_PNFS_FILE_LAYOUT=m
CONFIG_PNFS_BLOCK=m
CONFIG_NFS_V4_1_IMPLEMENTATION_ID_DOMAIN="kernel.org"
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
CONFIG_NFS_DEBUG=y
# CONFIG_NFSD is not set
CONFIG_LOCKD=m
CONFIG_LOCKD_V4=y
CONFIG_NFS_ACL_SUPPORT=m
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=m
CONFIG_SUNRPC_GSS=m
CONFIG_SUNRPC_BACKCHANNEL=y
CONFIG_SUNRPC_XPRT_RDMA=m
CONFIG_SUNRPC_DEBUG=y
# CONFIG_CEPH_FS is not set
# CONFIG_CIFS is not set
# CONFIG_NCP_FS is not set
# CONFIG_CODA_FS is not set
# CONFIG_AFS_FS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="utf8"
CONFIG_NLS_CODEPAGE_437=y
# CONFIG_NLS_CODEPAGE_737 is not set
# CONFIG_NLS_CODEPAGE_775 is not set
CONFIG_NLS_CODEPAGE_850=m
# CONFIG_NLS_CODEPAGE_852 is not set
CONFIG_NLS_CODEPAGE_855=m
# CONFIG_NLS_CODEPAGE_857 is not set
# CONFIG_NLS_CODEPAGE_860 is not set
# CONFIG_NLS_CODEPAGE_861 is not set
CONFIG_NLS_CODEPAGE_862=m
# CONFIG_NLS_CODEPAGE_863 is not set
# CONFIG_NLS_CODEPAGE_864 is not set
# CONFIG_NLS_CODEPAGE_865 is not set
CONFIG_NLS_CODEPAGE_866=m
# CONFIG_NLS_CODEPAGE_869 is not set
# CONFIG_NLS_CODEPAGE_936 is not set
# CONFIG_NLS_CODEPAGE_950 is not set
# CONFIG_NLS_CODEPAGE_932 is not set
# CONFIG_NLS_CODEPAGE_949 is not set
# CONFIG_NLS_CODEPAGE_874 is not set
CONFIG_NLS_ISO8859_8=m
# CONFIG_NLS_CODEPAGE_1250 is not set
CONFIG_NLS_CODEPAGE_1251=m
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=m
CONFIG_NLS_ISO8859_2=m
# CONFIG_NLS_ISO8859_3 is not set
# CONFIG_NLS_ISO8859_4 is not set
CONFIG_NLS_ISO8859_5=m
# CONFIG_NLS_ISO8859_6 is not set
# CONFIG_NLS_ISO8859_7 is not set
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
CONFIG_NLS_ISO8859_15=m
CONFIG_NLS_KOI8_R=m
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
CONFIG_NLS_UTF8=m
# CONFIG_DLM is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
# CONFIG_PRINTK_TIME is not set
CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
CONFIG_ENABLE_WARN_DEPRECATED=y
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=2048
CONFIG_MAGIC_SYSRQ=y
# CONFIG_STRIP_ASM_SYMS is not set
# CONFIG_READABLE_ASM is not set
CONFIG_UNUSED_SYMBOLS=y
CONFIG_DEBUG_FS=y
# CONFIG_HEADERS_CHECK is not set
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_DEBUG_KERNEL=y
# CONFIG_DEBUG_SHIRQ is not set
CONFIG_LOCKUP_DETECTOR=y
CONFIG_HARDLOCKUP_DETECTOR=y
# CONFIG_BOOTPARAM_HARDLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=0
# CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=0
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
# CONFIG_BOOTPARAM_HUNG_TASK_PANIC is not set
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=0
# CONFIG_SCHED_DEBUG is not set
# CONFIG_SCHEDSTATS is not set
# CONFIG_TIMER_STATS is not set
# CONFIG_DEBUG_OBJECTS is not set
# CONFIG_SLUB_DEBUG_ON is not set
# CONFIG_SLUB_STATS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_PREEMPT=y
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_RT_MUTEX_TESTER is not set
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
CONFIG_LOCKDEP=y
# CONFIG_LOCK_STAT is not set
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_TRACE_IRQFLAGS=y
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_STACK_USAGE is not set
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_INFO=y
CONFIG_DEBUG_INFO_REDUCED=y
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
CONFIG_PROVE_RCU=y
CONFIG_PROVE_RCU_REPEATEDLY=y
CONFIG_PROVE_RCU_DELAY=y
CONFIG_SPARSE_RCU_POINTER=y
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=60
CONFIG_RCU_CPU_STALL_VERBOSE=y
CONFIG_RCU_CPU_STALL_INFO=y
# CONFIG_RCU_TRACE is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
# CONFIG_DEBUG_PER_CPU_MAPS is not set
# CONFIG_LKDTM is not set
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
# CONFIG_FAULT_INJECTION is not set
# CONFIG_LATENCYTOP is not set
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
# CONFIG_RBTREE_TEST is not set
# CONFIG_INTERVAL_TREE_TEST is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_DYNAMIC_DEBUG is not set
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_ATOMIC64_SELFTEST is not set
# CONFIG_ASYNC_RAID6_TEST is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_KMEMCHECK is not set
# CONFIG_TEST_KSTRTOX is not set
# CONFIG_STRICT_DEVMEM is not set
# CONFIG_X86_VERBOSE_BOOTUP is not set
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
# CONFIG_DEBUG_STACKOVERFLOW is not set
# CONFIG_X86_PTDUMP is not set
CONFIG_DEBUG_RODATA=y
# CONFIG_DEBUG_RODATA_TEST is not set
CONFIG_DEBUG_SET_MODULE_RONX=y
# CONFIG_DEBUG_NX_TEST is not set
# CONFIG_DEBUG_TLBFLUSH is not set
# CONFIG_IOMMU_DEBUG is not set
# CONFIG_IOMMU_STRESS is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
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
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
# CONFIG_DEBUG_NMI_SELFTEST is not set

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_ENCRYPTED_KEYS is not set
CONFIG_KEYS_DEBUG_PROC_KEYS=y
# CONFIG_SECURITY_DMESG_RESTRICT is not set
CONFIG_SECURITY=y
# CONFIG_SECURITYFS is not set
CONFIG_SECURITY_NETWORK=y
# CONFIG_SECURITY_NETWORK_XFRM is not set
# CONFIG_SECURITY_PATH is not set
# CONFIG_INTEL_TXT is not set
# CONFIG_SECURITY_SELINUX is not set
# CONFIG_SECURITY_SMACK is not set
# CONFIG_SECURITY_TOMOYO is not set
# CONFIG_SECURITY_APPARMOR is not set
# CONFIG_SECURITY_YAMA is not set
# CONFIG_IMA is not set
# CONFIG_EVM is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_XOR_BLOCKS=m
CONFIG_ASYNC_CORE=m
CONFIG_ASYNC_MEMCPY=m
CONFIG_ASYNC_XOR=m
CONFIG_ASYNC_PQ=m
CONFIG_ASYNC_RAID6_RECOV=m
CONFIG_ASYNC_TX_DISABLE_PQ_VAL_DMA=y
CONFIG_ASYNC_TX_DISABLE_XOR_VAL_DMA=y
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=m
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=m
# CONFIG_CRYPTO_PCRYPT is not set
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=m
# CONFIG_CRYPTO_TEST is not set
CONFIG_CRYPTO_ABLK_HELPER_X86=y
CONFIG_CRYPTO_GLUE_HELPER_X86=m

#
# Authenticated Encryption with Associated Data
#
# CONFIG_CRYPTO_CCM is not set
# CONFIG_CRYPTO_GCM is not set
# CONFIG_CRYPTO_SEQIV is not set

#
# Block modes
#
CONFIG_CRYPTO_CBC=m
# CONFIG_CRYPTO_CTR is not set
# CONFIG_CRYPTO_CTS is not set
CONFIG_CRYPTO_ECB=m
CONFIG_CRYPTO_LRW=y
# CONFIG_CRYPTO_PCBC is not set
CONFIG_CRYPTO_XTS=y

#
# Hash modes
#
CONFIG_CRYPTO_HMAC=y
# CONFIG_CRYPTO_XCBC is not set
# CONFIG_CRYPTO_VMAC is not set

#
# Digest
#
CONFIG_CRYPTO_CRC32C=m
CONFIG_CRYPTO_CRC32C_X86_64=y
CONFIG_CRYPTO_CRC32C_INTEL=m
# CONFIG_CRYPTO_CRC32 is not set
# CONFIG_CRYPTO_CRC32_PCLMUL is not set
# CONFIG_CRYPTO_GHASH is not set
CONFIG_CRYPTO_MD4=m
CONFIG_CRYPTO_MD5=m
CONFIG_CRYPTO_MICHAEL_MIC=m
# CONFIG_CRYPTO_RMD128 is not set
# CONFIG_CRYPTO_RMD160 is not set
# CONFIG_CRYPTO_RMD256 is not set
# CONFIG_CRYPTO_RMD320 is not set
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=y
CONFIG_CRYPTO_SHA256=m
CONFIG_CRYPTO_SHA512=m
# CONFIG_CRYPTO_TGR192 is not set
CONFIG_CRYPTO_WP512=m
# CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL is not set

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=y
# CONFIG_CRYPTO_ANUBIS is not set
CONFIG_CRYPTO_ARC4=m
CONFIG_CRYPTO_BLOWFISH=m
CONFIG_CRYPTO_BLOWFISH_COMMON=m
CONFIG_CRYPTO_BLOWFISH_X86_64=m
# CONFIG_CRYPTO_CAMELLIA is not set
# CONFIG_CRYPTO_CAMELLIA_X86_64 is not set
# CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64 is not set
CONFIG_CRYPTO_CAST_COMMON=m
CONFIG_CRYPTO_CAST5=m
CONFIG_CRYPTO_CAST5_AVX_X86_64=m
CONFIG_CRYPTO_CAST6=m
CONFIG_CRYPTO_CAST6_AVX_X86_64=m
CONFIG_CRYPTO_DES=m
# CONFIG_CRYPTO_FCRYPT is not set
CONFIG_CRYPTO_KHAZAD=m
# CONFIG_CRYPTO_SALSA20 is not set
# CONFIG_CRYPTO_SALSA20_X86_64 is not set
# CONFIG_CRYPTO_SEED is not set
CONFIG_CRYPTO_SERPENT=m
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=m
CONFIG_CRYPTO_SERPENT_AVX_X86_64=m
CONFIG_CRYPTO_TEA=m
CONFIG_CRYPTO_TWOFISH=m
CONFIG_CRYPTO_TWOFISH_COMMON=m
CONFIG_CRYPTO_TWOFISH_X86_64=m
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=m
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=m

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=m
# CONFIG_CRYPTO_ZLIB is not set
# CONFIG_CRYPTO_LZO is not set

#
# Random Number Generation
#
# CONFIG_CRYPTO_ANSI_CPRNG is not set
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
CONFIG_CRYPTO_HW=y
# CONFIG_CRYPTO_DEV_PADLOCK is not set
# CONFIG_ASYMMETRIC_KEY_TYPE is not set
CONFIG_HAVE_KVM=y
CONFIG_HAVE_KVM_IRQCHIP=y
CONFIG_HAVE_KVM_EVENTFD=y
CONFIG_KVM_APIC_ARCHITECTURE=y
CONFIG_KVM_MMIO=y
CONFIG_KVM_ASYNC_PF=y
CONFIG_HAVE_KVM_MSI=y
CONFIG_HAVE_KVM_CPU_RELAX_INTERCEPT=y
CONFIG_VIRTUALIZATION=y
CONFIG_KVM=m
CONFIG_KVM_INTEL=m
# CONFIG_KVM_AMD is not set
CONFIG_VHOST_NET=m
# CONFIG_BINARY_PRINTF is not set

#
# Library routines
#
CONFIG_RAID6_PQ=m
CONFIG_BITREVERSE=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_CRC_CCITT=m
CONFIG_CRC16=m
CONFIG_CRC_T10DIF=m
CONFIG_CRC_ITU_T=m
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
# CONFIG_CRC7 is not set
CONFIG_LIBCRC32C=m
# CONFIG_CRC8 is not set
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=m
CONFIG_LZO_DECOMPRESS=y
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
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
# CONFIG_AVERAGE is not set
# CONFIG_CORDIC is not set
# CONFIG_DDR is not set

--------------010600070305030002060908--
