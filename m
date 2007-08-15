From: Bruce Cole <bacole@gmail.com>
Subject: Re: Realtek r8168 slow outbound transfer - potential fix/workaround
Date: Wed, 15 Aug 2007 00:17:54 -0700
Message-ID: <46C2A8A2.9090801@gmail.com>
References: <46C0A88E.7050802@gmail.com> <20070814211954.GA3552@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Gundersen <gundy@iinet.net.au>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.187]:45431 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752942AbXHOHVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 03:21:47 -0400
Received: by rv-out-0910.google.com with SMTP id k20so1656574rvb
        for <netdev@vger.kernel.org>; Wed, 15 Aug 2007 00:21:46 -0700 (PDT)
In-Reply-To: <20070814211954.GA3552@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rancois Romieu wrote:
> Bruce Cole <bacole@gmail.com> :
> [...]
>  =20
>> What's the status of this fix?  It (or something more refined) seems=
=20
>> necessary to correct the current performance problems with this driv=
er.
>>    =20
>
> An explanation or something more refined would be welcome.
>
>  =20
Are you indicating that you need more information on how to reproduce=20
the problem?  I believe the problem is 100% reproducible if you=20
configure a samba server with a realtek r8111 interface and drag&drop a=
=20
file from that server to a windows host on the directly connected lan. =
=20
This with both machine's host interfaces reporting 1000mbps full duplex=
=20
and a gig-e hub between.

I've just reproduced using a linux client as well, so it would be easy=20
to compare tcpdumps of the TCP sessions from both ends.  Note the=20
abysmal performance when I transfer *from* the server, but the=20
performance is fine when I transfer *to* the server:

  zpad(root): mount -t cifs -o username=3Dcole //192.168.1.11/u4 /mnt1
  Password:
  zpad(root): cd /mnt1/test
  zpad(root): ls -l t
  -rw-r--r-- 1 cole cole 52428800 2007-08-14 23:52 t
  zpad(root): date; cp -pr t ~/test/; date
  Tue Aug 14 11:57:35 PM
  Wed Aug 15 12:01:11 AM
  zpad(root): ls -l ~/test/t
  -rw-r--r-- 1 cole cole 50M 2007-08-14 23:52 /home/cole/test/t
  zpad(root): date; cp -pr ~/test/t tt; date
  Wed Aug 15 12:02:11 AM
  cp: setting permissions for `tt': Permission denied
  Wed Aug 15 12:02:13 AM
  zpad(root): ls -l tt
  -rwx------ 1 cole cole 52428800 2007-08-14 23:52 tt*
  zpad(root):

This test is with the vanilla 2.6.23-rc3 driver with NAPI enabled.


If you're hoping to receive a better fix than the spin wait, I could=20
probably help with that too but I'd need to see realtek's programming=20
documentation for this chip.

> [...]
>  =20
>> I can troubleshoot in more detail if that would help get a proper fi=
x
>> developed.
>>    =20
>
> Can you try 2.6.23-rc3 with NAPI enabled and send a complete dmesg +
> /proc/interrupts + ethtool -S output ?
>  =20
Sure, see below:
dmesg:
Linux version 2.6.23-0.104.rc3.fc8=20
(kojibuilder@xenbuilder2.fedora.redhat.com) (gcc version 4.1.2 20070723=
=20
(Red Hat 4.1.2-17)) #1 SMP Mon Aug 13 15:58:43 EDT 2007
Command line: ro root=3D/dev/sda6 rhgb quiet
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009e800 (usable)
 BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000007fee0000 (usable)
 BIOS-e820: 000000007fee0000 - 000000007fee3000 (ACPI NVS)
 BIOS-e820: 000000007fee3000 - 000000007fef0000 (ACPI data)
 BIOS-e820: 000000007fef0000 - 000000007ff00000 (reserved)
 BIOS-e820: 00000000f0000000 - 00000000f4000000 (reserved)
 BIOS-e820: 00000000fec00000 - 0000000100000000 (reserved)
Entering add_active_range(0, 0, 158) 0 entries of 3200 used
Entering add_active_range(0, 256, 524000) 1 entries of 3200 used
end_pfn_map =3D 1048576
DMI 2.4 present.
ACPI: RSDP 000F6FE0, 0014 (r0 GBT   )
ACPI: RSDT 7FEE3040, 003C (r1 GBT    GBTUACPI 42302E31 GBTU  1010101)
ACPI: FACP 7FEE30C0, 0074 (r1 GBT    GBTUACPI 42302E31 GBTU  1010101)
ACPI: DSDT 7FEE3180, 4B36 (r1 GBT    GBTUACPI     1000 MSFT  100000C)
ACPI: FACS 7FEE0000, 0040
ACPI: HPET 7FEE7E00, 0038 (r1 GBT    GBTUACPI 42302E31 GBTU       98)
ACPI: MCFG 7FEE7E80, 003C (r1 GBT    GBTUACPI 42302E31 GBTU  1010101)
ACPI: APIC 7FEE7D00, 0084 (r1 GBT    GBTUACPI 42302E31 GBTU  1010101)
ACPI: SSDT 7FEE7F00, 015C (r1  PmRef  Cpu0Ist     3000 INTL 20040311)
ACPI: SSDT 7FEE8390, 0275 (r1  PmRef    CpuPm     3000 INTL 20040311)
No NUMA configuration found
=46aking a node at 0000000000000000-000000007fee0000
Entering add_active_range(0, 0, 158) 0 entries of 3200 used
Entering add_active_range(0, 256, 524000) 1 entries of 3200 used
Bootmem setup node 0 0000000000000000-000000007fee0000
Zone PFN ranges:
  DMA             0 ->     4096
  DMA32        4096 ->  1048576
  Normal    1048576 ->  1048576
Movable zone start PFN for each node
early_node_map[2] active PFN ranges
    0:        0 ->      158
    0:      256 ->   524000
On node 0 totalpages: 523902
  DMA zone: 96 pages used for memmap
  DMA zone: 2488 pages reserved
  DMA zone: 1414 pages, LIFO batch:0
  DMA32 zone: 12185 pages used for memmap
  DMA32 zone: 507719 pages, LIFO batch:31
  Normal zone: 0 pages used for memmap
  Movable zone: 0 pages used for memmap
ACPI: PM-Timer IO Port: 0x408
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
Processor #0 (Bootup-CPU)
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
Processor #1
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] disabled)
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x03] disabled)
ACPI: LAPIC_NMI (acpi_id[0x00] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x01] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x02] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x03] dfl dfl lint[0x1])
ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 2, address 0xfec00000, GSI 0-23
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Setting APIC routing to flat
ACPI: HPET id: 0x8086a201 base: 0xfed00000
Using ACPI (MADT) for SMP configuration information
swsusp: Registered nosave memory region: 000000000009e000 - 00000000000=
a0000
swsusp: Registered nosave memory region: 00000000000a0000 - 00000000000=
f0000
swsusp: Registered nosave memory region: 00000000000f0000 - 00000000001=
00000
Allocating PCI resources starting at 80000000 (gap: 7ff00000:70100000)
SMP: Allowing 4 CPUs, 2 hotplug CPUs
PERCPU: Allocating 435848 bytes of per cpu data
Built 1 zonelists in Node order.  Total pages: 509133
Policy zone: DMA32
Kernel command line: ro root=3D/dev/sda6 rhgb quiet
Initializing CPU#0
PID hash table entries: 4096 (order: 12, 32768 bytes)
hpet clockevent registered
TSC calibrated against HPET
time.c: Detected 2800.002 MHz processor.
Console: colour VGA+ 80x25
console [tty0] enabled
Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molna=
r
=2E.. MAX_LOCKDEP_SUBCLASSES:    8
=2E.. MAX_LOCK_DEPTH:          30
=2E.. MAX_LOCKDEP_KEYS:        2048
=2E.. CLASSHASH_SIZE:           1024
=2E.. MAX_LOCKDEP_ENTRIES:     8192
=2E.. MAX_LOCKDEP_CHAINS:      16384
=2E.. CHAINHASH_SIZE:          8192
 memory used by lock dependency info: 1712 kB
 per task-struct memory footprint: 2160 bytes
Checking aperture...
Calgary: detecting Calgary via BIOS EBDA area
Calgary: Unable to locate Rio Grande table in EBDA - bailing!
Memory: 2031412k/2096000k available (2473k kernel code, 64196k reserved=
,=20
1434k data, 708k init)
SLUB: Genslabs=3D23, HWalign=3D64, Order=3D0-1, MinObjects=3D4, CPUs=3D=
4, Nodes=3D1
Calibrating delay using timer specific routine.. 5604.00 BogoMIPS=20
(lpj=3D2802000)
Security Framework v1.0.0 initialized
SELinux:  Initializing.
SELinux:  Starting in permissive mode
selinux_register_security:  Registering secondary module capability
Capability LSM initialized as secondary
Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes)
Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes)
Mount-cache hash table entries: 256
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 4096K
CPU 0/0 -> Node 0
using mwait in idle threads.
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
CPU0: Thermal monitoring enabled (TM2)
lockdep: not fixing up alternatives.
ACPI: Core revision 20070126
Using local APIC timer interrupts.
APIC timer calibration result 21874999
Detected 21.874 MHz APIC timer.
lockdep: not fixing up alternatives.
Booting processor 1/2 APIC 0x1
Initializing CPU#1
Calibrating delay using timer specific routine.. 5599.77 BogoMIPS=20
(lpj=3D2799888)
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 4096K
CPU 1/1 -> Node 0
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 1
CPU1: Thermal monitoring enabled (TM2)
Intel(R) Core(TM)2 Duo CPU     E6750  @ 2.66GHz stepping 0b
checking TSC synchronization [CPU#0 -> CPU#1]: passed.
Brought up 2 CPUs
sizeof(vma)=3D176 bytes
sizeof(page)=3D96 bytes
sizeof(inode)=3D1088 bytes
sizeof(dentry)=3D256 bytes
sizeof(ext3inode)=3D1488 bytes
sizeof(buffer_head)=3D104 bytes
sizeof(skbuff)=3D232 bytes
sizeof(task_struct)=3D4464 bytes
khelper used greatest stack depth: 6600 bytes left
khelper used greatest stack depth: 6352 bytes left
Time: 23:09:36  Date: 07/14/107
NET: Registered protocol family 16
ACPI: bus type pci registered
PCI: Using MMCONFIG at f0000000 - f3ffffff
mtrr: your CPUs had inconsistent variable MTRR settings
mtrr: probably your BIOS does not setup all CPUs.
mtrr: corrected configuration.
ACPI: EC: Look up EC in DSDT
ACPI: Interpreter enabled
ACPI: (supports S0 S3)
ACPI: Using IOAPIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (0000:00)
PCI: Transparent bridge - 0000:00:1e.0
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX4._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX5._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.HUB0._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 10 *11 12 14 15)
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 9 10 11 12 14 *15)
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 9 10 11 12 *14 15)
ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 9 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0,=20
disabled.
ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 *7 9 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNK0] (IRQs 3 4 5 6 7 9 10 11 *12 14 15)
ACPI: PCI Interrupt Link [LNK1] (IRQs 3 4 *5 6 7 9 10 11 12 14 15)
Linux Plug and Play Support v0.97 (c) Adam Belay
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp: PnP ACPI: found 13 devices
ACPI: ACPI bus type pnp unregistered
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
PCI: Using ACPI for IRQ routing
PCI: If a device doesn't work, try "pci=3Drouteirq".  If it helps, post=
 a=20
report
NetLabel: Initializing
NetLabel:  domain hash size =3D 128
NetLabel:  protocols =3D UNLABELED CIPSOv4
NetLabel:  unlabeled traffic allowed by default
PCI-GART: No AMD northbridge found.
hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
hpet0: 4 64-bit timers, 14318180 Hz
ACPI: RTC can wake from S4
Time: tsc clocksource has been installed.
Switched to high resolution mode on CPU 0
Switched to high resolution mode on CPU 1
pnp: 00:09: ioport range 0x400-0x4bf has been reserved
pnp: 00:0a: iomem range 0xf0000000-0xf3ffffff could not be reserved
pnp: 00:0b: iomem range 0xd5000-0xd7fff has been reserved
pnp: 00:0b: iomem range 0xf0000-0xf7fff could not be reserved
pnp: 00:0b: iomem range 0xf8000-0xfbfff could not be reserved
pnp: 00:0b: iomem range 0xfc000-0xfffff could not be reserved
PCI: Bridge: 0000:00:01.0
  IO window: b000-bfff
  MEM window: f4000000-f6ffffff
  PREFETCH window: e0000000-efffffff
PCI: Bridge: 0000:00:1c.0
  IO window: a000-afff
  MEM window: disabled.
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:1c.4
  IO window: c000-cfff
  MEM window: f9000000-f90fffff
  PREFETCH window: disabled.
PCI: Bridge: 0000:00:1c.5
  IO window: d000-dfff
  MEM window: f7000000-f8ffffff
  PREFETCH window: 80000000-800fffff
PCI: Bridge: 0000:00:1e.0
  IO window: disabled.
  MEM window: f9100000-f91fffff
  PREFETCH window: disabled.
ACPI: PCI Interrupt 0000:00:01.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:01.0 to 64
ACPI: PCI Interrupt 0000:00:1c.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:1c.0 to 64
ACPI: PCI Interrupt 0000:00:1c.4[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:1c.4 to 64
ACPI: PCI Interrupt 0000:00:1c.5[B] -> GSI 17 (level, low) -> IRQ 17
PCI: Setting latency timer of device 0000:00:1c.5 to 64
PCI: Setting latency timer of device 0000:00:1e.0 to 64
NET: Registered protocol family 2
IP route cache hash table entries: 65536 (order: 7, 524288 bytes)
TCP established hash table entries: 262144 (order: 12, 18874368 bytes)
TCP bind hash table entries: 65536 (order: 10, 4194304 bytes)
TCP: Hash tables configured (established 262144 bind 65536)
TCP reno registered
checking if image is initramfs... it is
=46reeing initrd memory: 3102k freed
khelper used greatest stack depth: 6280 bytes left
audit: initializing netlink socket (disabled)
audit(1187132976.577:1): initialized
Total HugeTLB memory allocated, 0
VFS: Disk quotas dquot_6.5.1
Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
SELinux:  Registering netfilter hooks
ksign: Installing public key data
Loading keyring
- Added public key 4C876821E00CB140
- User ID: Red Hat, Inc. (Kernel Module GPG key)
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered (default)
Boot video device is 0000:01:00.0
PCI: Setting latency timer of device 0000:00:01.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:01.0:pcie00]
Allocate Port Service[0000:00:01.0:pcie03]
PCI: Setting latency timer of device 0000:00:1c.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:1c.0:pcie00]
Allocate Port Service[0000:00:1c.0:pcie02]
Allocate Port Service[0000:00:1c.0:pcie03]
PCI: Setting latency timer of device 0000:00:1c.4 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:1c.4:pcie00]
Allocate Port Service[0000:00:1c.4:pcie02]
Allocate Port Service[0000:00:1c.4:pcie03]
PCI: Setting latency timer of device 0000:00:1c.5 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:1c.5:pcie00]
Allocate Port Service[0000:00:1c.5:pcie02]
Allocate Port Service[0000:00:1c.5:pcie03]
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
ACPI: Processor [CPU0] (supports 2 throttling states)
ACPI: SSDT 7FEE8300, 0087 (r1  PmRef  Cpu1Ist     3000 INTL 20040311)
ACPI: Processor [CPU1] (supports 2 throttling states)
ACPI Exception (processor_core-0791): AE_NOT_FOUND, Processor Device is=
=20
not present [20070126]
ACPI Exception (processor_core-0791): AE_NOT_FOUND, Processor Device is=
=20
not present [20070126]
cpuidle: driver acpi_idle failed to attach to cpu 1
cpuidle: driver acpi_idle failed to attach to cpu 0
Generic RTC Driver v1.07
Non-volatile memory driver v1.2
Linux agpgart interface v0.102
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing enable=
d
serial8250: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
00:07: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
RAMDISK driver initialized: 16 RAM disks of 16384K size 4096 blocksize
input: Macintosh mouse button emulation as /class/input/input0
PNP: PS/2 Controller [PNP0303:PS2K] at 0x60,0x64 irq 1
PNP: PS/2 appears to have AUX port disabled, if this is incorrect pleas=
e=20
boot with i8042.nopnp
serio: i8042 KBD port at 0x60,0x64 irq 1
mice: PS/2 mouse device common for all mice
input: AT Translated Set 2 keyboard as /class/input/input1
cpuidle: using governor menu
usbcore: registered new interface driver hiddev
usbcore: registered new interface driver usbhid
drivers/hid/usbhid/hid-core.c: v2.6:USB HID core driver
TCP cubic registered
Initializing XFRM netlink socket
NET: Registered protocol family 1
NET: Registered protocol family 17
  Magic number: 3:122:201
drivers/rtc/hctosys.c: unable to open rtc device (rtc0)
=46reeing unused kernel memory: 708k freed
Write protecting the kernel read-only data: 1032k
USB Universal Host Controller Interface driver v3.0
ACPI: PCI Interrupt 0000:00:1a.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:1a.0 to 64
uhci_hcd 0000:00:1a.0: UHCI Host Controller
uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 1
uhci_hcd 0000:00:1a.0: irq 16, io base 0x0000e100
usb usb1: configuration #1 chosen from 1 choice
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:1a.1[B] -> GSI 21 (level, low) -> IRQ 21
PCI: Setting latency timer of device 0000:00:1a.1 to 64
uhci_hcd 0000:00:1a.1: UHCI Host Controller
uhci_hcd 0000:00:1a.1: new USB bus registered, assigned bus number 2
uhci_hcd 0000:00:1a.1: irq 21, io base 0x0000e200
usb usb2: configuration #1 chosen from 1 choice
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:1a.2[C] -> GSI 18 (level, low) -> IRQ 18
PCI: Setting latency timer of device 0000:00:1a.2 to 64
uhci_hcd 0000:00:1a.2: UHCI Host Controller
uhci_hcd 0000:00:1a.2: new USB bus registered, assigned bus number 3
uhci_hcd 0000:00:1a.2: irq 18, io base 0x0000e000
usb usb3: configuration #1 chosen from 1 choice
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:1d.0[A] -> GSI 23 (level, low) -> IRQ 23
PCI: Setting latency timer of device 0000:00:1d.0 to 64
uhci_hcd 0000:00:1d.0: UHCI Host Controller
uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 4
uhci_hcd 0000:00:1d.0: irq 23, io base 0x0000e300
usb usb4: configuration #1 chosen from 1 choice
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
usb 1-1: new full speed USB device using uhci_hcd and address 2
ACPI: PCI Interrupt 0000:00:1d.1[B] -> GSI 19 (level, low) -> IRQ 19
PCI: Setting latency timer of device 0000:00:1d.1 to 64
uhci_hcd 0000:00:1d.1: UHCI Host Controller
uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 5
uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000e400
usb usb5: configuration #1 chosen from 1 choice
hub 5-0:1.0: USB hub found
hub 5-0:1.0: 2 ports detected
usb 1-1: configuration #1 chosen from 1 choice
hub 1-1:1.0: USB hub found
hub 1-1:1.0: 2 ports detected
ACPI: PCI Interrupt 0000:00:1d.2[C] -> GSI 18 (level, low) -> IRQ 18
PCI: Setting latency timer of device 0000:00:1d.2 to 64
uhci_hcd 0000:00:1d.2: UHCI Host Controller
uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 6
uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000e500
usb usb6: configuration #1 chosen from 1 choice
hub 6-0:1.0: USB hub found
hub 6-0:1.0: 2 ports detected
insmod used greatest stack depth: 5272 bytes left
ohci_hcd: 2006 August 04 USB 1.1 'Open' Host Controller (OHCI) Driver
ACPI: PCI Interrupt 0000:00:1a.7[C] -> GSI 18 (level, low) -> IRQ 18
PCI: Setting latency timer of device 0000:00:1a.7 to 64
ehci_hcd 0000:00:1a.7: EHCI Host Controller
ehci_hcd 0000:00:1a.7: new USB bus registered, assigned bus number 7
PCI: cache line size of 32 is not supported by device 0000:00:1a.7
ehci_hcd 0000:00:1a.7: irq 18, io mem 0xf9205000
ehci_hcd 0000:00:1a.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
usb usb7: configuration #1 chosen from 1 choice
hub 7-0:1.0: USB hub found
hub 7-0:1.0: 6 ports detected
ACPI: PCI Interrupt 0000:00:1d.7[A] -> GSI 23 (level, low) -> IRQ 23
PCI: Setting latency timer of device 0000:00:1d.7 to 64
ehci_hcd 0000:00:1d.7: EHCI Host Controller
ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 8
PCI: cache line size of 32 is not supported by device 0000:00:1d.7
ehci_hcd 0000:00:1d.7: irq 23, io mem 0xf9204000
ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
usb 1-1: USB disconnect, address 2
usb usb8: configuration #1 chosen from 1 choice
hub 8-0:1.0: USB hub found
hub 8-0:1.0: 6 ports detected
insmod used greatest stack depth: 5264 bytes left
SCSI subsystem initialized
libata version 2.21 loaded.
ahci 0000:00:1f.2: version 2.3
ACPI: PCI Interrupt 0000:00:1f.2[B] -> GSI 19 (level, low) -> IRQ 19
usb 7-1: new high speed USB device using ehci_hcd and address 2
usb 7-1: configuration #1 chosen from 1 choice
hub 7-1:1.0: USB hub found
hub 7-1:1.0: 2 ports detected
usb 7-1.1: new high speed USB device using ehci_hcd and address 4
ahci 0000:00:1f.2: AHCI 0001.0200 32 slots 6 ports 3 Gbps 0x3f impl SAT=
A=20
mode
ahci 0000:00:1f.2: flags: 64bit ncq sntf stag pm led clo pmp pio slum p=
art
PCI: Setting latency timer of device 0000:00:1f.2 to 64
scsi0 : ahci
scsi1 : ahci
scsi2 : ahci
scsi3 : ahci
scsi4 : ahci
scsi5 : ahci
ata1: SATA max UDMA/133 cmd 0xffffc2000033a100 ctl 0x0000000000000000=20
bmdma 0x0000000000000000 irq 2299
ata2: SATA max UDMA/133 cmd 0xffffc2000033a180 ctl 0x0000000000000000=20
bmdma 0x0000000000000000 irq 2299
ata3: SATA max UDMA/133 cmd 0xffffc2000033a200 ctl 0x0000000000000000=20
bmdma 0x0000000000000000 irq 2299
ata4: SATA max UDMA/133 cmd 0xffffc2000033a280 ctl 0x0000000000000000=20
bmdma 0x0000000000000000 irq 2299
ata5: SATA max UDMA/133 cmd 0xffffc2000033a300 ctl 0x0000000000000000=20
bmdma 0x0000000000000000 irq 2299
ata6: SATA max UDMA/133 cmd 0xffffc2000033a380 ctl 0x0000000000000000=20
bmdma 0x0000000000000000 irq 2299
usb 7-1.1: configuration #1 chosen from 1 choice
hub 7-1.1:1.0: USB hub found
hub 7-1.1:1.0: 4 ports detected
usb 7-1.2: new high speed USB device using ehci_hcd and address 5
ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata1.00: ATA-7: Maxtor 6H500F0, HA431DD0, max UDMA/133
ata1.00: 976773168 sectors, multi 0: LBA48 NCQ (depth 31/32)
ata1.00: configured for UDMA/133
usb 7-1.2: configuration #1 chosen from 1 choice
usb 1-2: new low speed USB device using uhci_hcd and address 3
ata2: SATA link down (SStatus 0 SControl 300)
usb 1-2: configuration #1 chosen from 1 choice
input: Microsft Microsoft Wireless Optical Desktop=AE 2.10 as=20
/class/input/input2
input: USB HID v1.11 Mouse [Microsft Microsoft Wireless Optical Desktop=
=AE=20
2.10] on usb-0000:00:1a.0-2
ata3: SATA link down (SStatus 0 SControl 300)
usb 6-1: new low speed USB device using uhci_hcd and address 2
usb 6-1: configuration #1 chosen from 1 choice
hiddev96: USB HID v1.00 Device [SmartHome SmartHome PowerLinc=20
Controller] on usb-0000:00:1d.2-1
ata4: SATA link down (SStatus 0 SControl 300)
ata5: SATA link down (SStatus 0 SControl 300)
ata6: SATA link down (SStatus 0 SControl 300)
scsi 0:0:0:0: Direct-Access     ATA      Maxtor 6H500F0   HA43 PQ: 0 AN=
SI: 5
sd 0:0:0:0: [sda] 976773168 512-byte hardware sectors (500108 MB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't=20
support DPO or FUA
sd 0:0:0:0: [sda] 976773168 512-byte hardware sectors (500108 MB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't=20
support DPO or FUA
 sda: sda1 sda2 < sda5 sda6 sda7 sda8 sda9 sda10 sda11 sda12 sda13 >
sd 0:0:0:0: [sda] Attached SCSI disk
ACPI: PCI Interrupt 0000:03:00.0[A] -> GSI 16 (level, low) -> IRQ 16
ahci 0000:03:00.0: AHCI 0001.0000 32 slots 2 ports 3 Gbps 0x3 impl SATA=
 mode
ahci 0000:03:00.0: flags: 64bit ncq pm led clo pmp pio slum part
PCI: Setting latency timer of device 0000:03:00.0 to 64
scsi6 : ahci
scsi7 : ahci
ata7: SATA max UDMA/133 cmd 0xffffc2000033c100 ctl 0x0000000000000000=20
bmdma 0x0000000000000000 irq 16
ata8: SATA max UDMA/133 cmd 0xffffc2000033c180 ctl 0x0000000000000000=20
bmdma 0x0000000000000000 irq 16
ata7: SATA link down (SStatus 0 SControl 300)
ata8: SATA link down (SStatus 0 SControl 300)
insmod used greatest stack depth: 3560 bytes left
Initializing USB Mass Storage driver...
scsi8 : SCSI emulation for USB Mass Storage devices
usb-storage: device found at 5
usbcore: registered new interface driver usb-storage
USB Mass Storage support registered.
usb-storage: waiting for device to settle before scanning
usb-storage: device scan complete
scsi 8:0:0:0: Direct-Access     SMSC     223 U HS-CF      3.60 PQ: 0 AN=
SI: 0
scsi 8:0:0:1: Direct-Access     SMSC     223 U HS-MS      3.60 PQ: 0 AN=
SI: 0
scsi 8:0:0:2: Direct-Access     SMSC     223 U HS-SM      3.60 PQ: 0 AN=
SI: 0
scsi 8:0:0:3: Direct-Access     SMSC     223 U HS-SD/MMC  3.60 PQ: 0 AN=
SI: 0
sd 8:0:0:0: [sdb] Attached SCSI removable disk
sd 8:0:0:1: [sdc] Attached SCSI removable disk
sd 8:0:0:2: [sdd] Attached SCSI removable disk
sd 8:0:0:3: [sde] Attached SCSI removable disk
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
SELinux:  Disabled at runtime.
SELinux:  Unregistering netfilter hooks
audit(1187132993.753:2): selinux=3D0 auid=3D4294967295
sd 0:0:0:0: Attached scsi generic sg0 type 0
sd 8:0:0:0: Attached scsi generic sg1 type 0
sd 8:0:0:1: Attached scsi generic sg2 type 0
sd 8:0:0:2: Attached scsi generic sg3 type 0
sd 8:0:0:3: Attached scsi generic sg4 type 0
shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
=46loppy drive(s): fd0 is 1.44M
iTCO_vendor_support: vendor-support=3D0
=46DC 0 is a post-1991 82077
rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
rtc0: alarms up to one month
iTCO_wdt: Intel TCO WatchDog Timer Driver v1.02 (26-Jul-2007)
iTCO_wdt: failed to reset NO_REBOOT flag, reboot disabled by hardware
iTCO_wdt: No card detected
ACPI: PCI Interrupt 0000:00:1f.3[C] -> GSI 18 (level, low) -> IRQ 18
input: Power Button (FF) as /class/input/input3
ACPI: Power Button (FF) [PWRF]
input: Power Button (CM) as /class/input/input4
ACPI: Power Button (CM) [PWRB]
r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded
ACPI: PCI Interrupt 0000:04:00.0[A] -> GSI 17 (level, low) -> IRQ 17
PCI: Setting latency timer of device 0000:04:00.0 to 64
eth0: RTL8168b/8111b at 0xffffc20000340000, 00:1a:4d:47:ec:73, XID=20
38000000 IRQ 17
ACPI: PCI Interrupt 0000:05:06.0[A] -> GSI 18 (level, low) -> IRQ 18
firewire_ohci: Added fw-ohci device 0000:05:06.0, OHCI version 1.10
ACPI: PCI Interrupt 0000:03:00.1[B] -> GSI 17 (level, low) -> IRQ 17
PCI: Setting latency timer of device 0000:03:00.1 to 64
scsi9 : pata_jmicron
scsi10 : pata_jmicron
ata9: PATA max UDMA/100 cmd 0x000000000001c000 ctl 0x000000000001c102=20
bmdma 0x000000000001c400 irq 17
ata10: PATA max UDMA/100 cmd 0x000000000001c200 ctl 0x000000000001c302=20
bmdma 0x000000000001c408 irq 17
nvidia: module license 'NVIDIA' taints kernel.
firewire_core: created new fw device fw0 (0 config rom retries, S400)
ACPI: PCI Interrupt 0000:01:00.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:01:00.0 to 64
NVRM: loading NVIDIA UNIX x86_64 Kernel Module  100.14.11  Wed Jun 13=20
16:33:22 PDT 2007
ACPI: PCI Interrupt 0000:00:1b.0[A] -> GSI 22 (level, low) -> IRQ 22
PCI: Setting latency timer of device 0000:00:1b.0 to 64
hda_codec: Unknown model for ALC882, trying auto-probe from BIOS...
loop: module loaded
lp: driver loaded but no devices found
NET: Registered protocol family 10
lo: Disabled Privacy Extensions
No dock devices found.
device-mapper: ioctl: 4.11.0-ioctl (2006-10-12) initialised:=20
dm-devel@redhat.com
device-mapper: multipath: version 1.0.5 loaded
EXT3 FS on sda6, internal journal
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sda8, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sda9, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sda10, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
fuse init (API version 7.8)
Adding 2000052k swap on /dev/sda5.  Priority:-1 extents:1 across:200005=
2k
ip6_tables: (C) 2000-2006 Netfilter Core Team
ip_tables: (C) 2000-2006 Netfilter Core Team
Netfilter messages via NETLINK v0.30.
nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
r8169: eth0: link up
r8169: eth0: link up
Bluetooth: Core ver 2.11
NET: Registered protocol family 31
Bluetooth: HCI device and connection manager initialized
Bluetooth: HCI socket layer initialized
Bluetooth: L2CAP ver 2.8
Bluetooth: L2CAP socket layer initialized
Bluetooth: RFCOMM socket layer initialized
Bluetooth: RFCOMM TTY layer initialized
Bluetooth: RFCOMM ver 1.8
Bluetooth: HIDP (Human Interface Emulation) ver 1.2
it87: Found IT8718F chip at 0x290, revision 4
it87: in3 is VCC (+5V)
coretemp coretemp.0: Using undocumented features, absolute temperature=20
might be wrong!
coretemp coretemp.1: Using undocumented features, absolute temperature=20
might be wrong!
eth0: no IPv6 routers present
Bridge firewalling registered
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
BUG kmalloc-96 (Tainted: P       ): Poison overwritten
-----------------------------------------------------------------------=
------

INFO: 0xffff810077d36d50-0xffff810077d36d57. First byte 0x0 instead of =
0x6b
INFO: Allocated in __nf_ct_ext_add+0x50/0x1bc [nf_conntrack] age=3D8806=
=20
cpu=3D0 pid=3D2908
INFO: Freed in __nf_ct_ext_add+0x14b/0x1bc [nf_conntrack] age=3D4805 cp=
u=3D0=20
pid=3D2908
INFO: Slab 0xffff8100039f0440 used=3D18 fp=3D0xffff810077d36d20=20
flags=3D0x700800000000c3
INFO: Object 0xffff810077d36d20 @offset=3D3360 fp=3D0xffff810077d36e70

Bytes b4 0xffff810077d36d10:  b6 1a fc ff 00 00 00 00 5a 5a 5a 5a 5a 5a=
=20
5a 5a =B6.=FC=FF....ZZZZZZZZ
  Object 0xffff810077d36d20:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b kkkkkkkkkkkkkkkk
  Object 0xffff810077d36d30:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b kkkkkkkkkkkkkkkk
  Object 0xffff810077d36d40:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b kkkkkkkkkkkkkkkk
  Object 0xffff810077d36d50:  00 00 00 00 00 00 00 00 6b 6b 6b 6b 6b 6b=
=20
6b 6b ........kkkkkkkk
  Object 0xffff810077d36d60:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b kkkkkkkkkkkkkkkk
  Object 0xffff810077d36d70:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b a5 kkkkkkkkkkkkkkk=A5
 Redzone 0xffff810077d36d80:  bb bb bb bb bb bb bb=20
bb                         =BB=BB=BB=BB=BB=BB=BB=BB      =20
 Padding 0xffff810077d36dc0:  5a 5a 5a 5a 5a 5a 5a=20
5a                         ZZZZZZZZ      =20

Call Trace:
 [<ffffffff810978c4>] check_bytes_and_report+0xa3/0xc9
 [<ffffffff81097b88>] check_object+0xc5/0x23a
 [<ffffffff81098f62>] __slab_alloc+0x41e/0x43b
 [<ffffffff88036be0>] :ext3:ext3_htree_store_dirent+0x2a/0xeb
 [<ffffffff88036be0>] :ext3:ext3_htree_store_dirent+0x2a/0xeb
 [<ffffffff8109a3a4>] __kmalloc+0x61/0xb5
 [<ffffffff88036be0>] :ext3:ext3_htree_store_dirent+0x2a/0xeb
 [<ffffffff8803e266>] :ext3:htree_dirblock_to_tree+0x103/0x13e
 [<ffffffff8803e31d>] :ext3:ext3_htree_fill_tree+0x7c/0x1cb
 [<ffffffff81098ec3>] __slab_alloc+0x37f/0x43b
 [<ffffffff88036d2d>] :ext3:ext3_readdir+0x8c/0x513
 [<ffffffff88036d2d>] :ext3:ext3_readdir+0x8c/0x513
 [<ffffffff810aadc0>] filldir+0x0/0xb7
 [<ffffffff88036e44>] :ext3:ext3_readdir+0x1a3/0x513
 [<ffffffff8109f9f1>] file_move+0x1d/0x49
 [<ffffffff810aadc0>] filldir+0x0/0xb7
 [<ffffffff81262bb6>] __mutex_lock_slowpath+0x299/0x2a6
 [<ffffffff810aadc0>] filldir+0x0/0xb7
 [<ffffffff810aaeee>] vfs_readdir+0x77/0xa9
 [<ffffffff810ab140>] sys_getdents+0x75/0xbd
 [<ffffffff8100bcbe>] system_call+0x7e/0x83

=46IX kmalloc-96: Restoring 0xffff810077d36d50-0xffff810077d36d57=3D0x6=
b

=46IX kmalloc-96: Marking all objects used
virbr0: no IPv6 routers present

interrupts:
           CPU0       CPU1     =20
  0:        112          1   IO-APIC-edge      timer
  1:       3310        122   IO-APIC-edge      i8042
  6:          5          1   IO-APIC-edge      floppy
  8:          0          0   IO-APIC-edge      rtc0
  9:          0          0   IO-APIC-fasteoi   acpi
 16:      14972      17489   IO-APIC-fasteoi   uhci_hcd:usb1, ahci, nvi=
dia
 17:         12        116   IO-APIC-fasteoi   libata, eth0
 18:      15068        438   IO-APIC-fasteoi   uhci_hcd:usb3,=20
uhci_hcd:usb6, ehci_hcd:usb7, firewire_ohci
 19:          0          0   IO-APIC-fasteoi   uhci_hcd:usb5
 21:          0          0   IO-APIC-fasteoi   uhci_hcd:usb2
 22:        100        100   IO-APIC-fasteoi   HDA Intel
 23:          1          1   IO-APIC-fasteoi   uhci_hcd:usb4, ehci_hcd:=
usb8
2299:       7922       3455   PCI-MSI-edge      ahci
NMI:          0          0
LOC:      57043      57922
ERR:          0

ethtool (shortly after boot):
NIC statistics:
     tx_packets: 137
     rx_packets: 38
     tx_errors: 0
     rx_errors: 0
     rx_missed: 0
     align_errors: 878
     tx_single_collisions: 0
     tx_multi_collisions: 0
     unicast: 22
     broadcast: 10
     multicast: 16
     tx_aborted: 0
     tx_underrun: 0
(and after some tests):
NIC statistics:
     tx_packets: 1273862
     rx_packets: 605126
     tx_errors: 0
     rx_errors: 0
     rx_missed: 0
     align_errors: 878
     tx_single_collisions: 0
     tx_multi_collisions: 0
     unicast: 604360
     broadcast: 643
     multicast: 766
     tx_aborted: 0
     tx_underrun: 0





