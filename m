From: Tobias Diedrich <ranma+kernel@tdiedrich.de>
Subject: Re: [linux-pm] [PATCH 0/4] Fix forcedeth hibernate/wake-on-lan
	problems
Date: Sun, 1 Jun 2008 09:49:36 +0200
Message-ID: <20080601074935.GA2529@yamamaya.is-a-geek.org>
References: <20080531221223.GA2630@yamamaya.is-a-geek.org> <Pine.LNX.4.44L0.0805312247100.18240-100000@netrider.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	David Brownell <david-b@pacbell.net>,
	linux-acpi@vger.kernel.org, linux-pm@lists.linux-foundation.org
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yumi.tdiedrich.de ([85.10.210.183]:56729 "EHLO mx.tdiedrich.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750828AbYFAHuQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2008 03:50:16 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L0.0805312247100.18240-100000@netrider.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alan Stern wrote:
> On Sun, 1 Jun 2008, Tobias Diedrich wrote:
>=20
> > Ok, after another long debugging session I finally found out the
> > reason for the immediate reboot (after finding the place that
> > suspends the serial console (drivers/pnp) and disabling that suspen=
d
> > path):
> > The system is woken up by USB activity! (Optical mouse, anyone?)
> >=20
> > Lo and behold:
> > drivers/usb/core/hcd-pci.c tries it's best to activate 'wake on
> > usb', which I didn't know since it apparently also never worked.
> > However, after applying the 'use platform_enable_wakeup'-patch,
> > not only forcedeth wake starts working, also usb wake.
> > If I prevent usb wake:
> > |echo disabled > /sys/devices/pci0000\:00/0000\:00\:02.0/power/wake=
up'
> > |echo disabled > /sys/devices/pci0000\:00/0000\:00\:02.1/power/wake=
up'
> > And then hibernate in platform mode, the immediate reboot is gone
> > and waking up using magic packets works fine even without setting u=
p
> > /proc/acpi/wakeup first.
> >=20
> > Maybe I should try hooking mouse and keyboard onto different usb
> > host controllers, so I can disable wakeup for the mouse host
> > controller and enable wakeup for the keyboard host controller,
> > then it should be possible to wake the system by pressing a key. :)
>=20
> You don't need to do that.  Wakeup can be set specifically for each=20
> individual USB device, provided CONFIG_USB_SUSPEND is enabled.

Cool, I didn't know that. :)

> On Sun, 1 Jun 2008, Tobias Diedrich wrote:
>=20
> > (BTW I first thought the 'immediate reboot because of usb wake' eff=
ect is
> > caused by the optical mouse generating a wake event, but it rather
> > seems to be a problem with a flaky secondary usb host controller,
> > which sees a connected device where nothing is attached)
>=20
> Can you provide debugging information (i.e., CONFIG_USB_DEBUG) with t=
he=20
> details on this bogus wakeup?

Sure.
Here is the complete log of one boot and two s2disk_platform cycles
captured using the serial console (in the first s2disk I forgot to
remove the 'turn off /sys/bus/usb/device/usb?/power/wakeup' part).

Interestingly even with power/wakeup disabled for usb1 and usb2,
which I assume to be the usb root ports, I could wake up the system
by pressing a key on my keyboard (which didn't work before turning
on CONFIG_USB_SUSPEND).

On the second suspend the system rebooted immediately as expected
(I power/wakeup for usb1 and usb2 back on and disabled the part in
the script).

I think this might be some general usb hw flakiness, since it seems
to detect (and has so for a long time) a non-existing device:

lsusb output:
Bus 002 Device 003: ID 045e:00db Microsoft Corp. Natural Ergonomic Keyb=
oard 4000 V1.0
Bus 002 Device 002: ID 045e:0040 Microsoft Corp. Wheel Mouse Optical
Bus 002 Device 001: ID 1d6b:0001 =20
Bus 001 Device 001: ID 1d6b:0002 =20

bogus device?:
[14316046.469949] usb 2-4: new full speed USB device using ohci_hcd and=
 address 12
[14316046.679951] usb 2-4: device descriptor read/64, error -62
[14316046.986619] usb 2-4: device descriptor read/64, error -62
[14316047.263284] usb 2-4: new full speed USB device using ohci_hcd and=
 address 13
[14316047.476614] usb 2-4: device descriptor read/64, error -62
[14316047.786618] usb 2-4: device descriptor read/64, error -62
[14316048.063282] usb 2-4: new full speed USB device using ohci_hcd and=
 address 14
[14316048.499945] usb 2-4: device not accepting address 14, error -62
[14316048.669950] usb 2-4: new full speed USB device using ohci_hcd and=
 address 15
[14316049.106612] usb 2-4: device not accepting address 15, error -62
[14316049.112960] hub 2-0:1.0: unable to enumerate USB device on port 4


complete log:
[    0.000000] Linux version 2.6.26-rc4 (ranma@melchior) (gcc version 4=
=2E2.3 (Debian 4.2.3-5)) #28 PREEMPT Sun Jun 1 09:06:24 CEST 2008
[    0.000000] Command line: root=3D/dev/sda5 resume=3D/dev/sda6 vga=3D=
6 apic=3Dverbose console=3DttyS0,115200 console=3Dtty0 pci=3Dnomsi no_c=
onsole_suspend ro
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
[    0.000000]  BIOS-e820: 000000000009f800 - 00000000000a0000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserve=
d)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000007fee0000 (usable)
[    0.000000]  BIOS-e820: 000000007fee0000 - 000000007fee3000 (ACPI NV=
S)
[    0.000000]  BIOS-e820: 000000007fee3000 - 000000007fef0000 (ACPI da=
ta)
[    0.000000]  BIOS-e820: 000000007fef0000 - 000000007ff00000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000f0000000 - 00000000f4000000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000fec00000 - 0000000100000000 (reserve=
d)
[    0.000000] max_pfn_mapped =3D 1048576
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x70106=
00070106
[    0.000000] init_memory_mapping
[    0.000000] DMI 2.4 present.
[    0.000000] ACPI: RSDP 000F7D20, 0024 (r2 Nvidia)
[    0.000000] ACPI: XSDT 7FEE3100, 004C (r1 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: FACP 7FEEADC0, 00F4 (r3 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: DSDT 7FEE3280, 7ACE (r1 NVIDIA AWRDACPI     1000 M=
SFT  3000000)
[    0.000000] ACPI: FACS 7FEE0000, 0040
[    0.000000] ACPI: SSDT 7FEEB000, 0136 (r1 PTLTD  POWERNOW        1  =
LTP        1)
[    0.000000] ACPI: HPET 7FEEB180, 0038 (r1 Nvidia ASUSACPI 42302E31 A=
WRD       98)
[    0.000000] ACPI: MCFG 7FEEB200, 003C (r1 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: APIC 7FEEAF00, 0098 (r1 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000]   early res: 0 [0-fff] BIOS data page
[    0.000000]   early res: 1 [6000-7fff] TRAMPOLINE
[    0.000000]   early res: 2 [200000-d3638f] TEXT DATA BSS
[    0.000000]   early res: 3 [9f800-fffff] BIOS reserved
[    0.000000]   early res: 4 [8000-bfff] PGTABLE
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA             0 ->     4096
[    0.000000]   DMA32        4096 ->  1048576
[    0.000000]   Normal    1048576 ->  1048576
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     0:        0 ->      159
[    0.000000]     0:      256 ->   524000
[    0.000000] Detected use of extended apic ids on hypertransport bus
[    0.000000] ACPI: PM-Timer IO Port: 0x1008
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x03] disabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x03] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x04] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 4, version 0, address 0xfec00000, GSI=
 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high lev=
el)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 14 global_irq 14 high e=
dge)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 15 global_irq 15 high e=
dge)
[    0.000000] Setting APIC routing to flat
[    0.000000] ACPI: HPET id: 0x10de8201 base: 0xfefff000
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
[    0.000000] mapped IOAPIC to ffffffffff5fa000 (00000000fec00000)
[    0.000000] PM: Registered nosave memory: 000000000009f000 - 0000000=
0000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 0000000=
0000f0000
[    0.000000] PM: Registered nosave memory: 00000000000f0000 - 0000000=
000100000
[    0.000000] Allocating PCI resources starting at 80000000 (gap: 7ff0=
0000:70100000)
[14315324.233334] Built 1 zonelists in Zone order, mobility grouping on=
=2E  Total pages: 513763
[14315324.233334] Kernel command line: root=3D/dev/sda5 resume=3D/dev/s=
da6 vga=3D6 apic=3Dverbose console=3DttyS0,115200 console=3Dtty0 pci=3D=
nomsi no_console_suspend ro
[14315324.233334] Initializing CPU#0
[14315324.233334] PID hash table entries: 4096 (order: 12, 32768 bytes)
[14315324.233334] Extended CMOS year: 2000
[14315324.233334] TSC calibrated against PM_TIMER
[14315324.233334] time.c: Detected 2411.107 MHz processor.
[14315324.233334] Console: colour VGA+ 80x60
[14315324.233334] console [tty0] enabled
[14315324.233334] console [ttyS0] enabled
[14315324.233334] Lock dependency validator: Copyright (c) 2006 Red Hat=
, Inc., Ingo Molnar
[14315324.233334] ... MAX_LOCKDEP_SUBCLASSES:    8
[14315324.233334] ... MAX_LOCK_DEPTH:          48
[14315324.233334] ... MAX_LOCKDEP_KEYS:        2048
[14315324.233334] ... CLASSHASH_SIZE:           1024
[14315324.233334] ... MAX_LOCKDEP_ENTRIES:     8192
[14315324.233334] ... MAX_LOCKDEP_CHAINS:      16384
[14315324.233334] ... CHAINHASH_SIZE:          8192
[14315324.233334]  memory used by lock dependency info: 1648 kB
[14315324.233334]  per task-struct memory footprint: 2688 bytes
[14315324.233334] Dentry cache hash table entries: 262144 (order: 9, 20=
97152 bytes)
[14315324.233334] Inode-cache hash table entries: 131072 (order: 8, 104=
8576 bytes)
[14315324.233334] Checking aperture...
[14315324.233334] Node 0: aperture @ ab94000000 size 32 MB
[14315324.233334] Aperture beyond 4GB. Ignoring.
[14315324.233334] No AGP bridge found
[14315324.233334] Memory: 2051692k/2096000k available (4624k kernel cod=
e, 43544k reserved, 2268k data, 260k init)
[14315324.316528] Calibrating delay using timer specific routine.. 4827=
=2E00 BogoMIPS (lpj=3D8043211)
[14315324.322857] Mount-cache hash table entries: 256
[14315324.327217] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64=
 bytes/line)
[14315324.333327] CPU: L2 Cache: 512K (64 bytes/line)
[14315324.336660] CPU: AMD Athlon(tm) 64 Processor 3800+ stepping 01
[14315324.342947] ACPI: Core revision 20080321
[14315324.359992] Parsing all Control Methods:
[14315324.364011] Table [DSDT](id 0001) - 1203 Objects with 101 Devices=
 380 Methods 44 Regions
[14315324.369992] Parsing all Control Methods:
[14315324.373967] Table [SSDT](id 0002) - 4 Objects with 0 Devices 0 Me=
thods 0 Regions
[14315324.379991]  tbxface-0598 [02] tb_load_namespace     : ACPI Table=
s successfully acquired
[14315324.389990] evxfevnt-0091 [02] enable                : Transition=
 to ACPI mode successful
[14315324.398904] enabled ExtINT on CPU#0
[14315324.402998] ENABLING IO-APIC IRQs
[14315324.406656] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 =
pin2=3D-1
[14315324.442963] Using local APIC timer interrupts.
[14315324.449986] Detected 12.557 MHz APIC timer.
[14315324.453320] net_namespace: 1272 bytes
[14315324.456653] NET: Registered protocol family 16
[14315324.460262] No dock devices found.
[14315324.464194] TOM: 0000000080000000 aka 2048M
[14315324.468795] ACPI: bus type pci registered
[14315324.473293] PCI: Using configuration type 1 for base access
[14315324.481636] evgpeblk-0956 [04] ev_create_gpe_block   : GPE 00 to =
1F [_GPE] 4 regs on int 0x9
[14315324.490696] evgpeblk-0956 [04] ev_create_gpe_block   : GPE 20 to =
5F [_GPE] 8 regs on int 0x9
[14315324.509805] Completing Region/Field/Buffer/Package initialization=
:......................................................................=
=2E....................................................................=
=2E.......................................
[14315324.545447] Initialized 39/44 Regions 11/11 Fields 40/40 Buffers =
89/101 Packages (1216 nodes)
[14315324.549980] Initializing Device/Processor/Thermal objects by exec=
uting _INI methods:...
[14315324.556256] Executed 3 _INI methods requiring 1 _STA executions (=
examined 108 objects)
[14315324.559979] evgpeblk-1052 [03] ev_initialize_gpe_bloc: Found 9 Wa=
ke, Enabled 0 Runtime GPEs in this block
[14315324.569979] evgpeblk-1052 [03] ev_initialize_gpe_bloc: Found 0 Wa=
ke, Enabled 1 Runtime GPEs in this block
[14315324.579978] ACPI: Interpreter enabled
[14315324.583311] ACPI: (supports S0 S1 S3 S4 S5)
[14315324.587948] ACPI: Using IOAPIC for interrupt routing
[14315324.615454] ACPI: PCI Root Bridge [PCI0] (0000:00)
[14315324.619975] PCI: Transparent bridge - 0000:00:06.0
[14315324.713931] ACPI: PCI Interrupt Link [LNK1] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.722733] ACPI: PCI Interrupt Link [LNK2] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.728224] ACPI: PCI Interrupt Link [LNK3] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.735722] ACPI: PCI Interrupt Link [LNK4] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.741551] ACPI: PCI Interrupt Link [LNK5] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.750168] ACPI: PCI Interrupt Link [LNK6] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.758958] ACPI: PCI Interrupt Link [LNK7] (IRQs 5 7 9 10 *11 14=
 15)
[14315324.763301] ACPI: PCI Interrupt Link [LNK8] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.768608] ACPI: PCI Interrupt Link [LP2P] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.777265] ACPI: PCI Interrupt Link [LUBA] (IRQs 5 7 9 10 *11 14=
 15)
[14315324.784758] ACPI: PCI Interrupt Link [LMAC] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.792250] ACPI: PCI Interrupt Link [LMC1] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.796634] ACPI: PCI Interrupt Link [LAZA] (IRQs *5 7 9 10 11 14=
 15)
[14315324.800688] ACPI: PCI Interrupt Link [LPMU] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.809482] ACPI: PCI Interrupt Link [LSMB] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.813827] ACPI: PCI Interrupt Link [LUB2] (IRQs *5 7 9 10 11 14=
 15)
[14315324.821294] ACPI: PCI Interrupt Link [LIDE] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.829954] ACPI: PCI Interrupt Link [LSID] (IRQs *5 7 9 10 11 14=
 15)
[14315324.834333] ACPI: PCI Interrupt Link [LFID] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.841605] ACPI: PCI Interrupt Link [LSA2] (IRQs 5 7 9 10 *11 14=
 15)
[14315324.849225] ACPI: PCI Interrupt Link [APC1] (IRQs 16) *0, disable=
d.
[14315324.853301] ACPI: PCI Interrupt Link [APC2] (IRQs 17) *0, disable=
d.
[14315324.857246] ACPI: PCI Interrupt Link [APC3] (IRQs 18) *0
[14315324.863511] ACPI: PCI Interrupt Link [APC4] (IRQs 19) *0, disable=
d.
[14315324.870581] ACPI: PCI Interrupt Link [APC5] (IRQs 16) *0, disable=
d.
[14315324.877827] ACPI: PCI Interrupt Link [APC6] (IRQs 16) *0, disable=
d.
[14315324.885078] ACPI: PCI Interrupt Link [APC7] (IRQs 16) *0
[14315324.889968] ACPI: PCI Interrupt Link [APC8] (IRQs 16) *0, disable=
d.
[14315324.895427] ACPI: PCI Interrupt Link [APCF] (IRQs 20 21 22 23) *0
[14315324.899968] ACPI: PCI Interrupt Link [APCH] (IRQs 20 21 22 23) *0
[14315324.903301] ACPI: PCI Interrupt Link [AMC1] (IRQs 20 21 22 23) *0
[14315324.907248] ACPI: PCI Interrupt Link [APMU] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.915379] ACPI: PCI Interrupt Link [AAZA] (IRQs 20 21 22 23) *0
[14315324.919968] ACPI: PCI Interrupt Link [APCS] (IRQs 20 21 22 23) *0
[14315324.923301] ACPI: PCI Interrupt Link [APCL] (IRQs 20 21 22 23) *0
[14315324.927247] ACPI: PCI Interrupt Link [APCM] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.934990] ACPI: PCI Interrupt Link [APCZ] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.943235] ACPI: PCI Interrupt Link [APSI] (IRQs 20 21 22 23) *0
[14315324.947245] ACPI: PCI Interrupt Link [APSJ] (IRQs 20 21 22 23) *0
[14315324.954299] ACPI: PCI Interrupt Link [ASA2] (IRQs 20 21 22 23) *0
[14315324.961445] Linux Plug and Play Support v0.97 (c) Adam Belay
[14315324.966635] pnp: PnP ACPI init
[14315324.969968] ACPI: bus type pnp registered
[14315324.982451] pnp: PnP ACPI: found 13 devices
[14315324.986635] ACPI: ACPI bus type pnp unregistered
[14315324.989968] SCSI subsystem initialized
[14315324.993377] usbcore: registered new interface driver usbfs
[14315324.999287] usbcore: registered new interface driver hub
[14315325.003301] usbcore: registered new device driver usb
[14315325.006635] PCI: Using ACPI for IRQ routing
[14315325.009968] testing the IO APIC.......................
[14315325.013301]=20
[14315325.013301] .................................... done.
[14315325.027785] Bluetooth: Core ver 2.11
[14315325.031917] NET: Registered protocol family 31
[14315325.036635] Bluetooth: HCI device and connection manager initiali=
zed
[14315325.039968] Bluetooth: HCI socket layer initialized
[14315325.043301] DMAR:parse DMAR table failure.
[14315325.054043] system 00:01: ioport range 0x1000-0x107f has been res=
erved
[14315325.060940] system 00:01: ioport range 0x1080-0x10ff has been res=
erved
[14315325.067827] system 00:01: ioport range 0x1400-0x147f has been res=
erved
[14315325.074713] system 00:01: ioport range 0x1480-0x14ff has been res=
erved
[14315325.081599] system 00:01: ioport range 0x1800-0x187f has been res=
erved
[14315325.088485] system 00:01: ioport range 0x1880-0x18ff has been res=
erved
[14315325.095383] system 00:02: ioport range 0x4d0-0x4d1 has been reser=
ved
[14315325.102096] system 00:02: ioport range 0x800-0x87f has been reser=
ved
[14315325.108810] system 00:02: ioport range 0x290-0x297 has been reser=
ved
[14315325.115545] system 00:0b: iomem range 0xf0000000-0xf3ffffff could=
 not be reserved
[14315325.123493] system 00:0c: iomem range 0xcd000-0xcffff has been re=
served
[14315325.130468] system 00:0c: iomem range 0xf0000-0xf7fff could not b=
e reserved
[14315325.139923] system 00:0c: iomem range 0xf8000-0xfbfff could not b=
e reserved
[14315325.147331] system 00:0c: iomem range 0xfc000-0xfffff could not b=
e reserved
[14315325.154737] system 00:0c: iomem range 0xfefff000-0xfefff0ff could=
 not be reserved
[14315325.162662] system 00:0c: iomem range 0x7fee0000-0x7fefffff could=
 not be reserved
[14315325.170117] system 00:0c: iomem range 0xffff0000-0xffffffff could=
 not be reserved
[14315325.178042] system 00:0c: iomem range 0x0-0x9ffff could not be re=
served
[14315325.185014] system 00:0c: iomem range 0x100000-0x7fedffff could n=
ot be reserved
[14315325.199644] system 00:0c: iomem range 0xfec00000-0xfec00fff could=
 not be reserved
[14315325.206697] system 00:0c: iomem range 0xfee00000-0xfeefffff could=
 not be reserved
[14315325.214622] system 00:0c: iomem range 0xfefff000-0xfeffffff could=
 not be reserved
[14315325.222574] system 00:0c: iomem range 0xfff80000-0xfff80fff could=
 not be reserved
[14315325.230499] system 00:0c: iomem range 0xfff90000-0xfffbffff could=
 not be reserved
[14315325.238429] system 00:0c: iomem range 0xfffed000-0xfffeffff could=
 not be reserved
[14315325.247393] PCI: Bridge: 0000:00:06.0
[14315325.251010]   IO window: 9000-9fff
[14315325.254789]   MEM window: disabled.
[14315325.259839]   PREFETCH window: disabled.
[14315325.263706] PCI: Bridge: 0000:00:0a.0
[14315325.267734]   IO window: 8000-8fff
[14315325.271508]   MEM window: 0xfde00000-0xfdefffff
[14315325.276406]   PREFETCH window: 0x00000000e8000000-0x00000000effff=
fff
[14315325.283120] PCI: Bridge: 0000:00:0e.0
[14315325.287151]   IO window: 6000-7fff
[14315325.290924]   MEM window: 0xfdd00000-0xfddfffff
[14315325.295819]   PREFETCH window: disabled.
[14315325.300188] NET: Registered protocol family 2
[14315325.336002] IP route cache hash table entries: 65536 (order: 7, 5=
24288 bytes)
[14315325.344144] TCP established hash table entries: 262144 (order: 10=
, 4194304 bytes)
[14315325.353336] TCP bind hash table entries: 65536 (order: 9, 3670016=
 bytes)
[14315325.365879] TCP: Hash tables configured (established 262144 bind =
65536)
[14315325.372885] TCP reno registered
[14315325.385861] NET: Registered protocol family 1
[14315325.392316] Installing knfsd (copyright (C) 1996 okir@monad.swb.d=
e).
[14315325.399451] JFFS2 version 2.2. (NAND) =C3=82=C2=A9 2001-2006 Red =
Hat, Inc.
[14315325.405975] fuse init (API version 7.9)
[14315325.410333] SGI XFS with security attributes, large block/inode n=
umbers, no debug enabled
[14315325.419250] msgmni has been set to 4007 for ipc namespace fffffff=
f808882f0
[14315325.426690] Block layer SCSI generic (bsg) driver version 0.4 loa=
ded (major 254)
[14315325.434542] io scheduler noop registered
[14315325.439746] io scheduler anticipatory registered
[14315325.444057] io scheduler deadline registered
[14315325.449069] io scheduler cfq registered (default)
[14315325.466317] pci 0000:00:05.0: Enabling HT MSI Mapping
[14315325.471768] pci 0000:00:05.1: Enabling HT MSI Mapping
[14315325.476878] pci 0000:00:05.2: Enabling HT MSI Mapping
[14315325.482326] pci 0000:00:06.0: Enabling HT MSI Mapping
[14315325.487762] pci 0000:00:06.1: Enabling HT MSI Mapping
[14315325.493216] pci 0000:00:08.0: Enabling HT MSI Mapping
[14315325.498657] pci 0000:00:09.0: Enabling HT MSI Mapping
[14315325.504089] pci 0000:00:0a.0: Enabling HT MSI Mapping
[14315325.509542] pci 0000:00:0e.0: Enabling HT MSI Mapping
[14315325.515240] assign_interrupt_mode Found MSI capability
[14315325.520563] assign_interrupt_mode Found MSI capability
[14315325.526830] input: Power Button (FF) as /class/input/input0
[14315325.532803] ACPI: Power Button (FF) [PWRF]
[14315325.537393] input: Power Button (CM) as /class/input/input1
[14315325.543334] ACPI: Power Button (CM) [PWRB]
[14315325.549405] ACPI: PNP0C0B:00 is registered as cooling_device0
[14315325.556669] ACPI: Fan [FAN] (on)
[14315325.560283] ACPI: ACPI0007:00 is registered as cooling_device1
[14315325.566782] ACPI: Expecting a [Reference] package element, found =
type 0
[14315325.574062] ACPI: LNXTHERM:01 is registered as thermal_zone0
[14315325.580526] ACPI: Thermal Zone [THRM] (40 C)
[14315325.603598] Real Time Clock Driver v1.12ac
[14315325.608082] Linux agpgart interface v0.103
[14315325.612554] Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, =
IRQ sharing disabled
[14315325.622766] serial8250: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550=
A
[14315325.630112] 00:09: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
[14315325.637619] loop: module loaded
[14315325.641039] e1000e: Intel(R) PRO/1000 Network Driver - 0.3.3.3-k2
[14315325.647521] e1000e: Copyright (c) 1999-2008 Intel Corporation.
[14315325.653835] e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
[14315325.660291] e100: Copyright(c) 1999-2006 Intel Corporation
[14315325.666298] tun: Universal TUN/TAP device driver, 1.6
[14315325.671719] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com=
>
[14315325.678486] Driver 'sd' needs updating - please use bus_type meth=
ods
[14315325.685250] Driver 'sr' needs updating - please use bus_type meth=
ods
[14315325.692968] ACPI: PCI Interrupt Link [APSI] enabled at IRQ 23
[14315325.699090] ACPI: PCI Interrupt 0000:00:05.0[A] -> Link [APSI] ->=
 GSI 23 (level, low) -> IRQ 23
[14315325.708856] sata_nv 0000:00:05.0: Using SWNCQ mode
[14315325.714155] scsi0 : sata_nv
[14315325.717573] scsi1 : sata_nv
[14315325.721157] ata1: SATA max UDMA/133 cmd 0x9f0 ctl 0xbf0 bmdma 0xd=
c00 irq 23
[14315325.729249] ata2: SATA max UDMA/133 cmd 0x970 ctl 0xb70 bmdma 0xd=
c08 irq 23
[14315326.206695] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300=
)
[14315326.220214] ata1.00: ATA-8: SAMSUNG HD501LJ, CR100-12, max UDMA7
[14315326.226591] ata1.00: 976773168 sectors, multi 1: LBA48 NCQ (depth=
 31/32)
[14315326.240528] ata1.00: configured for UDMA/133
[14315326.573689] ata2: SATA link down (SStatus 0 SControl 300)
[14315326.592884] isa bounce pool size: 16 pages
[14315326.596954] scsi 0:0:0:0: Direct-Access     ATA      SAMSUNG HD50=
1LJ  CR10 PQ: 0 ANSI: 5
[14315326.606003] sd 0:0:0:0: [sda] 976773168 512-byte hardware sectors=
 (500108 MB)
[14315326.613427] sd 0:0:0:0: [sda] Write Protect is off
[14315326.618629] sd 0:0:0:0: [sda] Write cache: enabled, read cache: e=
nabled, doesn't support DPO or FUA
[14315326.627076] sd 0:0:0:0: [sda] 976773168 512-byte hardware sectors=
 (500108 MB)
[14315326.636278] sd 0:0:0:0: [sda] Write Protect is off
[14315326.640932] sd 0:0:0:0: [sda] Write cache: enabled, read cache: e=
nabled, doesn't support DPO or FUA
[14315326.650430]  sda: sda1 sda2 sda3 sda4 < sda5 sda6 sda7 >
[14315326.691809] sd 0:0:0:0: [sda] Attached SCSI disk
[14315326.697309] sd 0:0:0:0: Attached scsi generic sg0 type 0
[14315326.706671] ACPI: PCI Interrupt Link [APSJ] enabled at IRQ 22
[14315326.712679] ACPI: PCI Interrupt 0000:00:05.1[B] -> Link [APSJ] ->=
 GSI 22 (level, low) -> IRQ 22
[14315326.720959] sata_nv 0000:00:05.1: Using SWNCQ mode
[14315326.726665] scsi2 : sata_nv
[14315326.730009] scsi3 : sata_nv
[14315326.733588] ata3: SATA max UDMA/133 cmd 0x9e0 ctl 0xbe0 bmdma 0xc=
800 irq 22
[14315326.740998] ata4: SATA max UDMA/133 cmd 0x960 ctl 0xb60 bmdma 0xc=
808 irq 22
[14315327.077024] ata3: SATA link down (SStatus 0 SControl 300)
[14315327.423689] ata4: SATA link down (SStatus 0 SControl 300)
[14315327.443336] ACPI: PCI Interrupt Link [ASA2] enabled at IRQ 21
[14315327.449341] ACPI: PCI Interrupt 0000:00:05.2[C] -> Link [ASA2] ->=
 GSI 21 (level, low) -> IRQ 21
[14315327.457739] sata_nv 0000:00:05.2: Using SWNCQ mode
[14315327.463435] scsi4 : sata_nv
[14315327.466797] scsi5 : sata_nv
[14315327.470365] ata5: SATA max UDMA/133 cmd 0xc400 ctl 0xc000 bmdma 0=
xb400 irq 21
[14315327.477943] ata6: SATA max UDMA/133 cmd 0xbc00 ctl 0xb800 bmdma 0=
xb408 irq 21
[14315327.813749] ata5: SATA link down (SStatus 0 SControl 300)
[14315328.303360] ata6: SATA link up 1.5 Gbps (SStatus 113 SControl 300=
)
[14315328.316777] ata6.00: ATAPI: TSSTcorp CDDVDW SH-S203B, SB00, max U=
DMA/100
[14315328.336778] ata6.00: configured for UDMA/100
[14315328.355468] scsi 5:0:0:0: CD-ROM            TSSTcorp CDDVDW SH-S2=
03B  SB00 PQ: 0 ANSI: 5
[14315328.366670] sr0: scsi3-mmc drive: 125x/125x writer dvd-ram cd/rw =
xa/form2 cdda tray
[14315328.373341] Uniform CD-ROM driver Revision: 3.20
[14315328.380357] sr 5:0:0:0: Attached scsi generic sg1 type 5
[14315328.391894] block2mtd: version $Revision: 1.30 $
[14315328.397846] ACPI: PCI Interrupt Link [APCL] enabled at IRQ 20
[14315328.403986] ACPI: PCI Interrupt 0000:00:02.1[B] -> Link [APCL] ->=
 GSI 20 (level, low) -> IRQ 20
[14315328.413704] ehci_hcd 0000:00:02.1: EHCI Host Controller
[14315328.420231] ehci_hcd 0000:00:02.1: new USB bus registered, assign=
ed bus number 1
[14315328.427723] ehci_hcd 0000:00:02.1: debug port 1
[14315328.433160] ehci_hcd 0000:00:02.1: irq 20, io mem 0xfe02e000
[14315328.448349] ehci_hcd 0000:00:02.1: USB 2.0 started, EHCI 1.00, dr=
iver 10 Dec 2004
[14315328.456845] usb usb1: configuration #1 chosen from 1 choice
[14315328.462979] hub 1-0:1.0: USB hub found
[14315328.467136] hub 1-0:1.0: 10 ports detected
[14315328.573556] usb usb1: New USB device found, idVendor=3D1d6b, idPr=
oduct=3D0002
[14315328.580717] usb usb1: New USB device strings: Mfr=3D3, Product=3D=
2, SerialNumber=3D1
[14315328.588392] usb usb1: Product: EHCI Host Controller
[14315328.595058] usb usb1: Manufacturer: Linux 2.6.26-rc4 ehci_hcd
[14315328.600310] usb usb1: SerialNumber: 0000:00:02.1
[14315328.607391] ACPI: PCI Interrupt Link [APCF] enabled at IRQ 23
[14315328.613502] ACPI: PCI Interrupt 0000:00:02.0[A] -> Link [APCF] ->=
 GSI 23 (level, low) -> IRQ 23
[14315328.622764] ohci_hcd 0000:00:02.0: OHCI Host Controller
[14315328.628592] ohci_hcd 0000:00:02.0: new USB bus registered, assign=
ed bus number 2
[14315328.636474] ohci_hcd 0000:00:02.0: irq 23, io mem 0xfe02f000
[14315328.695724] usb usb2: configuration #1 chosen from 1 choice
[14315328.701789] hub 2-0:1.0: USB hub found
[14315328.705943] hub 2-0:1.0: 10 ports detected
[14315328.783404] hub 1-0:1.0: unable to enumerate USB device on port 1
[14315328.816650] usb usb2: New USB device found, idVendor=3D1d6b, idPr=
oduct=3D0001
[14315328.823342] usb usb2: New USB device strings: Mfr=3D3, Product=3D=
2, SerialNumber=3D1
[14315328.830616] usb usb2: Product: OHCI Host Controller
[14315328.835858] usb usb2: Manufacturer: Linux 2.6.26-rc4 ohci_hcd
[14315328.840212] usb usb2: SerialNumber: 0000:00:02.0
[14315328.846458] USB Universal Host Controller Interface driver v3.0
[14315328.986691] hub 1-0:1.0: unable to enumerate USB device on port 3
[14315329.163356] hub 1-0:1.0: unable to enumerate USB device on port 4
[14315329.169974] usbcore: registered new interface driver usblp
[14315329.176790] PNP: No PS/2 controller found. Probing ports directly=
=2E
[14315329.183811] serio: i8042 KBD port at 0x60,0x64 irq 1
[14315329.189375] serio: i8042 AUX port at 0x60,0x64 irq 12
[14315329.195449] mice: PS/2 mouse device common for all mice
[14315329.219956] i2c /dev entries driver
[14315329.223980] i2c-adapter i2c-0: nForce2 SMBus adapter at 0x1c00
[14315329.230289] i2c-adapter i2c-1: nForce2 SMBus adapter at 0x1c40
[14315329.236621] it87: Found IT8716F chip at 0x290, revision 0
[14315329.240605] it87: in3 is VCC (+5V)
[14315329.246525] it87: in7 is VCCH (+5V Stand-By)
[14315329.276668] md: raid1 personality registered for level 1
[14315329.283566] device-mapper: ioctl: 4.13.0-ioctl (2007-10-18) initi=
alised: dm-devel@redhat.com
[14315329.292582] Bluetooth: HCI USB driver ver 2.9
[14315329.450012] usb 2-1: new low speed USB device using ohci_hcd and =
address 2
[14315329.636693] usb 2-1: configuration #1 chosen from 1 choice
[14315329.660003] usb 2-1: New USB device found, idVendor=3D045e, idPro=
duct=3D0040
[14315329.666684] usb 2-1: New USB device strings: Mfr=3D1, Product=3D3=
, SerialNumber=3D0
[14315329.674262] usb 2-1: Product: Microsoft 3-Button Mouse with Intel=
liEye(TM)
[14315329.683288] usb 2-1: Manufacturer: Microsoft
[14315329.963344] usb 2-3: new low speed USB device using ohci_hcd and =
address 3
[14315330.156679] usb 2-3: configuration #1 chosen from 1 choice
[14315330.193336] usb 2-3: New USB device found, idVendor=3D045e, idPro=
duct=3D00db
[14315330.200017] usb 2-3: New USB device strings: Mfr=3D1, Product=3D2=
, SerialNumber=3D0
[14315330.207602] usb 2-3: Product: Natural=C2=AE Ergonomic Keyboard 40=
00
[14315330.213796] usb 2-3: Manufacturer: Microsoft
[14315330.496678] usb 2-4: new full speed USB device using ohci_hcd and=
 address 4
[14315330.670011] usb 2-4: device descriptor read/64, error -62
[14315330.943344] usb 2-4: device descriptor read/64, error -62
[14315331.210011] usb 2-4: new full speed USB device using ohci_hcd and=
 address 5
[14315331.383344] usb 2-4: device descriptor read/64, error -62
[14315331.656677] usb 2-4: device descriptor read/64, error -62
[14315331.923344] usb 2-4: new full speed USB device using ohci_hcd and=
 address 6
[14315332.336674] usb 2-4: device not accepting address 6, error -62
[14315332.500011] usb 2-4: new full speed USB device using ohci_hcd and=
 address 7
[14315332.913341] usb 2-4: device not accepting address 7, error -62
[14315332.919546] hub 2-0:1.0: unable to enumerate USB device on port 4
[14315332.926358] usbcore: registered new interface driver hci_usb
[14315332.932679] Bluetooth: HCI UART driver ver 2.2
[14315332.938855] Bluetooth: HCI H4 protocol initialized
[14315332.943679] Bluetooth: HCI BCSP protocol initialized
[14315332.949029] cpuidle: using governor ladder
[14315332.953490] cpuidle: using governor menu
[14315332.963336] input: Microsoft Microsoft 3-Button Mouse with Intell=
iEye(TM) as /class/input/input2
[14315332.994617] input: USB HID v1.10 Mouse [Microsoft Microsoft 3-But=
ton Mouse with IntelliEye(TM)] on usb-0000:00:02.0-1
[14315333.013341] input: Microsoft Natural=C2=AE Ergonomic Keyboard 400=
0 as /class/input/input3
[14315333.047434] input: USB HID v1.11 Keyboard [Microsoft Natural=C2=AE=
 Ergonomic Keyboard 4000] on usb-0000:00:02.0-3
[14315333.070002] input: Microsoft Natural=C2=AE Ergonomic Keyboard 400=
0 as /class/input/input4
[14315333.104253] input: USB HID v1.11 Device [Microsoft Natural=C2=AE =
Ergonomic Keyboard 4000] on usb-0000:00:02.0-3
[14315333.114512] usbcore: registered new interface driver usbhid
[14315333.120305] usbhid: v2.6:USB HID core driver
[14315333.126452] Advanced Linux Sound Architecture Driver Version 1.0.=
16.
[14315333.134233] ALSA device list:
[14315333.137578]   No soundcards found.
[14315333.141510] GACT probability on
[14315333.145020] Mirror/redirect action on
[14315333.150212] u32 classifier
[14315333.153287]     Performance counters on
[14315333.154901]     input device check on=20
[14315333.159018]     Actions configured=20
[14315333.166486] IPv4 over IPv4 tunneling driver
[14315333.170629] ip_tables: (C) 2000-2006 Netfilter Core Team
[14315333.176416] TCP bic registered
[14315333.179848] TCP cubic registered
[14315333.183441] TCP westwood registered
[14315333.187300] TCP htcp registered
[14315333.190813] TCP vegas registered
[14315333.194411] TCP yeah registered
[14315333.197923] Initializing XFRM netlink socket
[14315333.202884] NET: Registered protocol family 10
[14315333.210003] IPv6 over IPv4 tunneling driver
[14315333.216669] NET: Registered protocol family 17
[14315333.221405] NET: Registered protocol family 15
[14315333.226324] Bridge firewalling registered
[14315333.230726] Bluetooth: L2CAP ver 2.9
[14315333.236670] Bluetooth: L2CAP socket layer initialized
[14315333.240010] Bluetooth: SCO (Voice Link) ver 0.5
[14315333.245429] Bluetooth: SCO socket layer initialized
[14315333.250384] Bluetooth: RFCOMM socket layer initialized
[14315333.255904] Bluetooth: RFCOMM TTY layer initialized
[14315333.261155] Bluetooth: RFCOMM ver 1.8
[14315333.266419] Bluetooth: BNEP (Ethernet Emulation) ver 1.2
[14315333.270458] Bluetooth: HIDP (Human Interface Emulation) ver 1.2
[14315333.277052] RPC: Registered udp transport module.
[14315333.282436] RPC: Registered tcp transport module.
[14315333.287563] 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelat=
ech.com>
[14315333.296237] All bugs added by David S. Miller <davem@redhat.com>
[14315333.300148] powernow-k8: Found 1 AMD Athlon(tm) 64 Processor 3800=
+ processors (1 cpu cores) (version 2.20.00)
[14315333.313310] powernow-k8:    0 : fid 0x10 (2400 MHz), vid 0x8
[14315333.316895] powernow-k8:    1 : fid 0xe (2200 MHz), vid 0xa
[14315333.323065] powernow-k8:    2 : fid 0xc (2000 MHz), vid 0xc
[14315333.335676] powernow-k8:    3 : fid 0xa (1800 MHz), vid 0xe
[14315333.341612] powernow-k8:    4 : fid 0x2 (1000 MHz), vid 0x12
[14315333.350003] md: Autodetecting RAID arrays.
[14315333.354367] md: Scanned 0 and added 0 devices.
[14315333.358509] md: autorun ...
[14315333.361835] md: ... autorun DONE.
[14315333.381886] kjournald starting.  Commit interval 5 seconds
[14315333.387883] EXT3-fs: mounted filesystem with ordered data mode.
[14315333.394472] VFS: Mounted root (ext3 filesystem) readonly.
[14315333.400861] Freeing unused kernel memory: 260k freed
[14315333.406477] Write protecting the kernel read-only data: 6480k
[14315334.057088] Marking TSC unstable due to cpufreq changes
[14315334.230019] Clocksource tsc unstable (delta =3D -103393192 ns)
[14315336.340991] scsi6 : pata_amd
[14315336.344444] scsi7 : pata_amd
[14315336.349256] ata7: PATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0xf=
000 irq 14
[14315336.364276] ata8: PATA max UDMA/133 cmd 0x170 ctl 0x376 bmdma 0xf=
008 irq 15
[14315336.559195] ata7.01: ATAPI: Pioneer DVD-ROM ATAPIModel DVD-106S 0=
122, E1.22, max UDMA/66
[14315336.581322] ata7.01: configured for UDMA/66
[14315336.598214] scsi 6:0:1:0: CD-ROM            PIONEER  DVD-ROM DVD-=
106  1.22 PQ: 0 ANSI: 5
[14315336.610878] sr1: scsi3-mmc drive: 40x/40x cd/rw xa/form2 cdda tra=
y
[14315336.617824] sr 6:0:1:0: Attached scsi generic sg2 type 5
[14315336.639413] ACPI: PCI Interrupt Link [AAZA] enabled at IRQ 22
[14315336.645635] ACPI: PCI Interrupt 0000:00:06.1[B] -> Link [AAZA] ->=
 GSI 22 (level, low) -> IRQ 22
[14315336.656334] ALSA sound/pci/hda/hda_intel.c:1904: chipset global c=
apabilities =3D 0x4401
[14315336.690054] ALSA sound/pci/hda/hda_intel.c:745: codec_mask =3D 0x=
1
[14315336.728674] ALSA sound/pci/hda/hda_codec.c:2350: hda_codec: model=
 '6stack-dig' is selected for config 1043:81f6 (Asus M2N-SLI)
[14315337.118212] ALSA sound/pci/hda/hda_codec.c:1127: Cannot find slav=
e Headphone Playback Volume, skipped
[14315337.129724] ALSA sound/pci/hda/hda_codec.c:1127: Cannot find slav=
e Mono Playback Volume, skipped
[14315337.139447] ALSA sound/pci/hda/hda_codec.c:1127: Cannot find slav=
e Speaker Playback Volume, skipped
[14315337.148749] ALSA sound/pci/hda/hda_codec.c:1127: Cannot find slav=
e Speaker Playback Switch, skipped
[14315337.161249] forcedeth: Reverse Engineered nForce ethernet driver.=
 Version 0.61.
[14315337.169779] ACPI: PCI Interrupt Link [APCH] enabled at IRQ 21
[14315337.175914] ACPI: PCI Interrupt 0000:00:08.0[A] -> Link [APCH] ->=
 GSI 21 (level, low) -> IRQ 21
[14315337.702535] forcedeth 0000:00:08.0: ifname eth0, PHY OUI 0x5043 @=
 1, addr 00:17:31:aa:1e:89
[14315337.711357] forcedeth 0000:00:08.0: highdma csum vlan pwrctl mgmt=
 timirq gbit lnktim msi msi-x desc-v3
[14315337.750004] gameport: EMU10K1 is pci0000:01:08.1/gameport0, io 0x=
9800, speed 1201kHz
[14315337.765496] ACPI: PCI Interrupt Link [APC3] enabled at IRQ 18
[14315337.771668] ACPI: PCI Interrupt 0000:01:08.0[A] -> ACPI: PCI Inte=
rrupt Link [AMC1] enabled at IRQ 20
[14315337.783535] Link [APC3] -> GSI 18 (level, low) -> IRQ 18
[14315337.797875] ACPI: PCI Interrupt 0000:00:09.0[A] -> ALSA sound/pci=
/emu10k1/emu10k1_main.c:1748: vendor=3D0x1102, device=3D0x2, subsystem_=
vendor_id=3D0x80641102, subsystem_id=3D0x8064
[14315337.819202] Link [AMC1] -> GSI 20 (level, low) -> IRQ 20
[14315337.833609] ALSA sound/pci/emu10k1/emu10k1_main.c:1773: Sound car=
d name=3DSB Live 5.1
[14315338.353675] forcedeth 0000:00:09.0: ifname eth1, PHY OUI 0x5043 @=
 1, addr 00:17:31:ac:c6:64
[14315338.362986] forcedeth 0000:00:09.0: highdma csum vlan pwrctl mgmt=
 timirq gbit lnktim msi msi-x desc-v3
[14315339.093711] Adding 3911788k swap on /dev/sda6.  Priority:-1 exten=
ts:1 across:3911788k
[14315339.279495] EXT3 FS on sda5, internal journal
[14315344.690008] br0: Dropping NETIF_F_UFO since no NETIF_F_HW_CSUM fe=
ature.
[14315356.516848]=20
[14315356.516850] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[14315356.520007] [ INFO: inconsistent lock state ]
[14315356.520007] 2.6.26-rc4 #28
[14315356.520007] ---------------------------------
[14315356.520007] inconsistent {in-hardirq-W} -> {hardirq-on-W} usage.
[14315356.520007] ethtool/1985 [HC0[0]:SC0[1]:HE1:SE0] takes:
[14315356.520007]  (&np->lock){++..}, at: [<ffffffffa000c5fd>] nv_set_s=
ettings+0xc8/0x3de [forcedeth]
[14315356.520008] {in-hardirq-W} state was registered at:
[14315356.520008]   [<ffffffffffffffff>] 0xffffffffffffffff
[14315356.520008] irq event stamp: 3606
[14315356.520008] hardirqs last  enabled at (3605): [<ffffffff8068106f>=
] _spin_unlock_irqrestore+0x3f/0x68
[14315356.520008] hardirqs last disabled at (3604): [<ffffffff80680d38>=
] _spin_lock_irqsave+0x13/0x46
[14315356.520008] softirqs last  enabled at (3534): [<ffffffff80246ba5>=
] __do_softirq+0xbc/0xc5
[14315356.520008] softirqs last disabled at (3606): [<ffffffff80680b33>=
] _spin_lock_bh+0x11/0x41
[14315356.520008]=20
[14315356.520008] other info that might help us debug this:
[14315356.520008] 2 locks held by ethtool/1985:
[14315356.520008]  #0:  (rtnl_mutex){--..}, at: [<ffffffff80596072>] rt=
nl_lock+0x12/0x14
[14315356.520008]  #1:  (_xmit_ETHER){-+..}, at: [<ffffffffa000c5e8>] n=
v_set_settings+0xb3/0x3de [forcedeth]
[14315356.520008]=20
[14315356.520008] stack backtrace:
[14315356.520008] Pid: 1985, comm: ethtool Not tainted 2.6.26-rc4 #28
[14315356.520008]=20
[14315356.520008] Call Trace:
[14315356.520008]  [<ffffffff8025f190>] print_usage_bug+0x162/0x173
[14315356.520008]  [<ffffffff8025fa8b>] mark_lock+0x231/0x41f
[14315356.520008]  [<ffffffff802607cf>] __lock_acquire+0x4e7/0xcac
[14315356.520008]  [<ffffffff8025fe64>] ? trace_hardirqs_on+0xf1/0x115
[14315356.520008]  [<ffffffff80272c3a>] ? disable_irq_nosync+0x6f/0x7b
[14315356.520008]  [<ffffffff80261375>] lock_acquire+0x55/0x6e
[14315356.520008]  [<ffffffffa000c5fd>] ? :forcedeth:nv_set_settings+0x=
c8/0x3de
[14315356.520008]  [<ffffffff80680b15>] _spin_lock+0x2f/0x3c
[14315356.520008]  [<ffffffffa000c5fd>] :forcedeth:nv_set_settings+0xc8=
/0x3de
[14315356.520008]  [<ffffffff8058f8bb>] dev_ethtool+0x186/0xea3
[14315356.520008]  [<ffffffff8067f446>] ? mutex_lock_nested+0x243/0x275
[14315356.520008]  [<ffffffff8025df2b>] ? debug_mutex_free_waiter+0x46/=
0x4a
[14315356.520008]  [<ffffffff8067f469>] ? mutex_lock_nested+0x266/0x275
[14315356.520008]  [<ffffffff8058e1ce>] dev_ioctl+0x4eb/0x600
[14315356.520008]  [<ffffffff8068106f>] ? _spin_unlock_irqrestore+0x3f/=
0x68
[14315356.520008]  [<ffffffff80580f91>] sock_ioctl+0x1f5/0x202
[14315356.520008]  [<ffffffff802a322e>] vfs_ioctl+0x2a/0x77
[14315356.520008]  [<ffffffff802a34d6>] do_vfs_ioctl+0x25b/0x270
[14315356.520008]  [<ffffffff806807b6>] ? trace_hardirqs_on_thunk+0x35/=
0x3a
[14315356.520008]  [<ffffffff802a352d>] sys_ioctl+0x42/0x65
[14315356.520008]  [<ffffffff8021fffb>] system_call_after_swapgs+0x7b/0=
x80
[14315356.520008]=20
[14315356.786222] eth0: link down.
[14315356.794850] eth1: link down.
[14315356.812266] br0: port 2(eth1) entering disabled state
[14315360.086673] eth1: link up.
[14315360.086679] br0: port 2(eth1) entering learning state
[14315360.850884] ALSA sound/pci/hda/hda_intel.c:1318: azx_pcm_prepare:=
 bufsize=3D0x1800, format=3D0x4011
[14315360.867017] ALSA sound/pci/hda/hda_codec.c:716: hda_codec_setup_s=
tream: NID=3D0x2, stream=3D0x5, channel=3D0, format=3D0x4011
[14315360.900023] ALSA sound/pci/hda/hda_codec.c:716: hda_codec_setup_s=
tream: NID=3D0x4, stream=3D0x5, channel=3D0, format=3D0x4011
[14315360.917746] ALSA sound/pci/hda/hda_codec.c:716: hda_codec_setup_s=
tream: NID=3D0x6, stream=3D0x5, channel=3D0, format=3D0x4011
[14315360.936740] ALSA sound/pci/hda/hda_codec.c:716: hda_codec_setup_s=
tream: NID=3D0x5, stream=3D0x5, channel=3D0, format=3D0x4011
[14315360.953352] ALSA sound/pci/hda/hda_codec.c:716: hda_codec_setup_s=
tream: NID=3D0xa, stream=3D0x5, channel=3D0, format=3D0x4011
[14315360.980039] ALSA sound/pci/hda/hda_codec.c:728: hda_codec_cleanup=
_stream: NID=3D0x4
[14315360.989433] ALSA sound/pci/hda/hda_codec.c:728: hda_codec_cleanup=
_stream: NID=3D0x6
[14315360.998047] ALSA sound/pci/hda/hda_codec.c:728: hda_codec_cleanup=
_stream: NID=3D0x5
[14315361.010006] ALSA sound/pci/hda/hda_codec.c:728: hda_codec_cleanup=
_stream: NID=3D0xa
[14315361.017106] ALSA sound/pci/hda/hda_codec.c:728: hda_codec_cleanup=
_stream: NID=3D0x2
[14315361.096677] br0: topology change detected, propagating
[14315361.102234] br0: port 2(eth1) entering forwarding state
[14315361.127387] warning: `ntpd' uses 32-bit capabilities (legacy supp=
ort in use)
[14315370.790944] [drm] Initialized drm 1.1.0 20060810
[14315370.863426] ACPI: PCI Interrupt Link [APC7] enabled at IRQ 16
[14315370.873077] IOAPIC[0]: Set routing entry (4-16 -> 0x71 -> IRQ 16 =
Mode:1 Active:1)
[14315370.878347] ACPI: PCI Interrupt 0000:02:00.0[A] -> Link [APC7] ->=
 GSI 16 (level, low) -> IRQ 16
[14315370.887791] PCI: Setting latency timer of device 0000:02:00.0 to =
64
[14315370.894798] [drm] Initialized radeon 1.28.0 20060524 on minor 0
[14315372.590005] [drm] Setting GART location based on new memory map
[14315372.891221] [drm] Loading R300 Microcode
[14315372.895667] [drm] writeback test succeeded in 1 usecs
[14315498.823670] usb usb1: usb auto-resume
[14315498.828106] ehci_hcd 0000:00:02.1: resume root hub
[14315498.896667] hub 1-0:1.0: hub_resume
[14315498.900484] hub 1-0:1.0: state 7 ports 10 chg 0000 evt 0000
[14315501.576676] hub 1-0:1.0: hub_suspend
[14315501.580562] usb usb1: bus auto-suspend
[14315501.584590] ehci_hcd 0000:00:02.1: suspend root hub
[14315986.250681] PM: Hibernation mode set to 'platform'
[14315986.262135] PM: Marking nosave pages: 000000000009f000 - 00000000=
00100000
[14315986.268938] PM: Basic memory bitmaps created
[14315986.275559] PM: Syncing filesystems ... done.
[14315986.281302] Freezing user space processes ... (elapsed 0.01 secon=
ds) done.
[14315986.302172] Freezing remaining freezable tasks ... (elapsed 0.00 =
seconds) done.
[14315986.311774] PM: Shrinking memory...  =08-=08done (0 pages freed)
[14315986.381882] PM: Freed 0 kbytes in 0.06 seconds (0.00 MB/s)
[14315986.391641] hub 2-0:1.0: hub_suspend
[14315986.394524] usb usb2: bus suspend
[14315986.397661] ohci_hcd 0000:00:02.0: suspend root hub
[14315986.402857] sd 0:0:0:0: [sda] Synchronizing SCSI cache
[14315986.416245] ACPI: PCI interrupt for device 0000:01:08.0 disabled
[14315986.422433] ACPI handle has no context!
[14315986.437294] ACPI: PCI interrupt for device 0000:00:09.0 disabled
[14315986.457213] ACPI: PCI interrupt for device 0000:00:08.0 disabled
[14315986.489964] ACPI: PCI interrupt for device 0000:00:06.1 disabled
[14315986.509671] ACPI: PCI interrupt for device 0000:00:05.2 disabled
[14315986.513325] ACPI: PCI interrupt for device 0000:00:05.1 disabled
[14315986.519720] ACPI: PCI interrupt for device 0000:00:05.0 disabled
[14315986.526071] ata8: port disabled. ignoring.
[14315986.532436] ACPI: PCI interrupt for device 0000:00:02.1 disabled
[14315986.536836] ehci_hcd 0000:00:02.1: --> no state change
[14315986.543206] ACPI: PCI interrupt for device 0000:00:02.0 disabled
[14315986.548623] ohci_hcd 0000:00:02.0: --> no state change
[14315986.555166] ACPI: Preparing to enter system sleep state S4
[14315986.563274] Extended CMOS year: 2000
[14315986.563274] PM: Creating hibernation image:=20
[14315986.563274] PM: Need to copy 81901 pages
[14315986.563274] PM: Normal pages needed: 81901 + 1024 + 38, available=
 pages: 442001
[14315986.563274] PM: Hibernation image created (81901 pages copied)
[14315986.563274] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x70=
10600070106
[14315986.563274] svm_cpu_init: svm_data is NULL on 0
[14315986.563274] Extended CMOS year: 2000
[14315986.578298] ACPI: Unable to turn cooling device [ffff81007f842f50=
] 'off'
[14315986.585910] ohci_hcd 0000:00:02.0: PCI legacy resume
[14315986.592483] ACPI: PCI Interrupt 0000:00:02.0[A] -> Link [APCF] ->=
 GSI 23 (level, low) -> IRQ 23
[14315986.601596] PCI: Setting latency timer of device 0000:00:02.0 to =
64
[14315986.606980] ohci_hcd 0000:00:02.0: powerup ports
[14315986.635128] ehci_hcd 0000:00:02.1: PCI legacy resume
[14315986.639069] ACPI: PCI Interrupt 0000:00:02.1[B] -> Link [APCL] ->=
 GSI 20 (level, low) -> IRQ 20
[14315986.648268] PCI: Setting latency timer of device 0000:00:02.1 to =
64
[14315986.654320] PM: Writing back config space on device 0000:00:04.0 =
at offset 1 (was b00001, writing b00005)
[14315986.664193] PCI: Setting latency timer of device 0000:00:04.0 to =
64
[14315986.672444] PM: Writing back config space on device 0000:00:05.0 =
at offset 1 (was b00003, writing b00007)
[14315986.686607] ata8: port disabled. ignoring.
[14315986.689887] ACPI: PCI Interrupt 0000:00:05.0[A] -> Link [APSI] ->=
 GSI 23 (level, low) -> IRQ 23
[14315986.698256] PCI: Setting latency timer of device 0000:00:05.0 to =
64
[14315986.704608] PM: Writing back config space on device 0000:00:05.1 =
at offset 1 (was b00003, writing b00007)
[14315986.714616] ACPI: PCI Interrupt 0000:00:05.1[B] -> Link [APSJ] ->=
 GSI 22 (level, low) -> IRQ 22
[14315986.725062] PCI: Setting latency timer of device 0000:00:05.1 to =
64
[14315986.730649] PM: Writing back config space on device 0000:00:05.2 =
at offset 1 (was b00003, writing b00007)
[14315986.740907] ACPI: PCI Interrupt 0000:00:05.2[C] -> Link [ASA2] ->=
 GSI 21 (level, low) -> IRQ 21
[14315986.751487] PCI: Setting latency timer of device 0000:00:05.2 to =
64
[14315986.757101] PCI: Setting latency timer of device 0000:00:06.0 to =
64
[14315986.776624] PM: Writing back config space on device 0000:00:06.1 =
at offset f (was 5020200, writing 5020205)
[14315986.786839] PM: Writing back config space on device 0000:00:06.1 =
at offset 4 (was 0, writing fe020000)
[14315986.796835] PM: Writing back config space on device 0000:00:06.1 =
at offset 1 (was b00000, writing b00002)
[14315986.806652] ACPI: PCI Interrupt 0000:00:06.1[B] -> Link [AAZA] ->=
 GSI 22 (level, low) -> IRQ 22
[14315986.815909] PCI: Setting latency timer of device 0000:00:06.1 to =
64
[14315986.841174] ata7.01: ACPI cmd ef/03:44:00:00:00:b0 filtered out
[14315986.846526] ata7.01: ACPI cmd ef/03:0c:00:00:00:b0 filtered out
[14315986.853216] ata7: nv_mode_filter: 0x1f01f&0x1f01f->0x1f01f, BIOS=3D=
0x1f000 (0xc50000) ACPI=3D0x1f01f (600:30:0x1c)
[14315986.876773] ata7.01: configured for UDMA/66
[14315987.026629] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300=
)
[14315987.044422] ata2: SATA link down (SStatus 0 SControl 300)
[14315987.053013] ata1.00: ACPI cmd ef/03:46:00:00:00:a0 filtered out
[14315987.056619] ata1.00: ACPI cmd f5/00:00:00:00:00:a0 filtered out
[14315987.086474] ata6: SATA link up 1.5 Gbps (SStatus 113 SControl 300=
)
[14315987.100696] ata4: SATA link down (SStatus 0 SControl 300)
[14315987.106528] ata5: SATA link down (SStatus 0 SControl 300)
[14315987.113327] ata6.00: ACPI cmd ef/03:46:00:00:00:a0 filtered out
[14315987.119156] ata3: SATA link down (SStatus 0 SControl 300)
[14315987.130853] ata6.00: configured for UDMA/100
[14315987.135041] ata1.00: configured for UDMA/133
[14315987.139861] sd 0:0:0:0: [sda] 976773168 512-byte hardware sectors=
 (500108 MB)
[14315987.149821] sd 0:0:0:0: [sda] Write Protect is off
[14315987.153694] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[14315987.159532] sd 0:0:0:0: [sda] Write cache: enabled, read cache: e=
nabled, doesn't support DPO or FUA
[14315987.253291] PM: Writing back config space on device 0000:00:08.0 =
at offset f (was 14010100, writing 1401010a)
[14315987.263676] PM: Writing back config space on device 0000:00:08.0 =
at offset 7 (was 0, writing fe028000)
[14315987.273674] PM: Writing back config space on device 0000:00:08.0 =
at offset 6 (was 0, writing fe029000)
[14315987.283223] PM: Writing back config space on device 0000:00:08.0 =
at offset 5 (was 1, writing b001)
[14315987.293222] PM: Writing back config space on device 0000:00:08.0 =
at offset 4 (was 0, writing fe02a000)
[14315987.302646] PM: Writing back config space on device 0000:00:08.0 =
at offset 1 (was b00000, writing b00007)
[14315987.313036] eth0: no link during initialization.
[14315987.329957] PM: Writing back config space on device 0000:00:09.0 =
at offset f (was 14010100, writing 1401010a)
[14315987.340347] PM: Writing back config space on device 0000:00:09.0 =
at offset 7 (was 0, writing fe025000)
[14315987.350344] PM: Writing back config space on device 0000:00:09.0 =
at offset 6 (was 0, writing fe026000)
[14315987.359896] PM: Writing back config space on device 0000:00:09.0 =
at offset 5 (was 1, writing ac01)
[14315987.369897] PM: Writing back config space on device 0000:00:09.0 =
at offset 4 (was 0, writing fe027000)
[14315987.379327] PM: Writing back config space on device 0000:00:09.0 =
at offset 1 (was b00000, writing b00007)
[14315987.392577] PCI: Setting latency timer of device 0000:00:0a.0 to =
64
[14315987.397575] PCI: Setting latency timer of device 0000:00:0e.0 to =
64
[14315987.416636] ACPI: PCI Interrupt 0000:01:08.0[A] -> Link [APC3] ->=
 GSI 18 (level, low) -> IRQ 18
[14315987.435121] ACPI: PCI Interrupt 0000:02:00.0[A] -> Link [APC7] ->=
 GSI 16 (level, low) -> IRQ 16
[14315987.444992] PCI: Setting latency timer of device 0000:02:00.0 to =
64
[14315987.450509] sd 0:0:0:0: [sda] Starting disk
[14315987.461766] usb usb1: usb resume
[14315987.468753] ehci_hcd 0000:00:02.1: resume root hub
[14315987.536706] hub 1-0:1.0: hub_resume
[14315987.540738] usb usb2: usb resume
[14315987.544405] ohci_hcd 0000:00:02.0: resume root hub
[14315987.616616] hub 2-0:1.0: hub_resume
[14315987.620615] PM: writing image.
[14315987.624243] PM: Free swap pages: 977947
[14315987.631831] PM: Saving image data pages (82061 pages) ...     =08=
=08=08=08  0%=08=08=08=08  1%=08=08=08=08  2%=08=08=08=08  3%=08=08=08=08=
  4%=08=08=08=08  5%=08=08=08=08  6%=08=08=08=08  7%=08=08=08=08  8%=08=
=08=08=08  9%=08=08=08=08 10%=08=08=08=08 11%=08=08=08=08 12%=08=08=08=08=
 13%=08=08=08=08 14%=08=08=08=08 15%=08=08=08=08 16%=08=08=08=08 17%=08=
=08=08=08 18%=08=08=08=08 19%=08=08=08=08 20%=08=08=08=08 21%=08=08=08=08=
 22%=08=08=08=08 23%=08=08=08=08 24%=08=08=08=08 25%=08=08=08=08 26%=08=
=08=08=08 27%=08=08=08=08 28%=08=08=08=08 29%=08=08=08=08 30%=08=08=08=08=
 31%=08=08=08=08 32%=08=08=08=08 33%=08=08=08=08 34%=08=08=08=08 35%=08=
=08=08=08 36%=08=08=08=08 37%=08=08=08=08 38%=08=08=08=08 39%=08=08=08=08=
 40%=08=08=08=08 41%=08=08=08=08 42%=08=08=08=08 43%=08=08=08=08 44%=08=
=08=08=08 45%=08=08=08=08 46%=08=08=08=08 47%=08=08=08=08 48%=08=08=08=08=
 49%=08=08=08=08 50%=08=08=08=08 51%=08=08=08=08 52%=08=08=08=08 53%=08=
=08=08=08 54%=08=08=08=08 55%=08=08=08=08 56%=08=08=08=08 57%=08=08=08=08=
 58%=08=08=08=08 59%=08=08=08=08 60%=08=08=08=08 61%=08=08=08=08 62%=08=
=08=08=08 63%=08=08=08=08 64%=08=08=08=08 65%=08=08=08=08 66%=08=08=08=08=
 67%=08=08=08=08 68%=08=08=08=08 69%=08=08=08=08 70%=08=08=08=08 71%=08=
=08=08=08 72%=08=08=08=08 73%=08=08=08=08 74%=08=08=08=08 75%=08=08=08=08=
 76%=08=08=08=08 77%=08=08=08=08 78%=08=08=08=08 79%=08=08=08=08 80%=08=
=08=08=08 81%=08=08=08=08 82%=08=08=08=08 83%=08=08=08=08 84%=08=08=08=08=
 85%=08=08=08=08 86%=08=08=08=08 87%=08=08=08=08 88%=08=08=08=08 89%=08=
=08=08=08 90%=08=08=08=08 91%=08=08=08=08 92%=08=08=08=08 93%=08=08=08=08=
 94%=08=08=08=08 95%=08=08=08=08 96%=08=08=08=08 97%=08=08=08=08 98%=08=
=08=08=08 99%=08=08=08=08100%=08=08=08=08done
[14315991.823947] PM: Wrote 328244 kbytes in 4.18 seconds (78.52 MB/s)
[14315991.831374] PM: S|
[14315992.111206] ohci_hcd 0000:00:02.0: Unlink after no-IRQ?  Controll=
er is probably using the wrong IRQ.
[14315992.125935] usb 2-3: usb suspend
[14315992.140442] usb 2-1: usb suspend
[14315992.156628] hub 2-0:1.0: hub_suspend
[14315992.160623] usb usb2: bus suspend
[14315992.164341] ohci_hcd 0000:00:02.0: suspend root hub
[14315992.169625] hub 1-0:1.0: hub_suspend
[14315992.176288] usb usb1: bus suspend
[14315992.177833] ehci_hcd 0000:00:02.1: suspend root hub
[14315992.182633] sd 0:0:0:0: [sda] Synchronizing SCSI cache
[14315992.189475] sd 0:0:0:0: [sda] Stopping disk
[14315992.623539] ACPI: PCI interrupt for device 0000:01:08.0 disabled
[14315992.630323] ACPI handle has no context!
[14315992.686627] ACPI: PCI interrupt for device 0000:00:06.1 disabled
[14315992.706451] ACPI: PCI interrupt for device 0000:00:05.2 disabled
[14315992.723228] ACPI: PCI interrupt for device 0000:00:05.1 disabled
[14315992.739839] ACPI: PCI interrupt for device 0000:00:05.0 disabled
[14315992.756495] ata8: port disabled. ignoring.
[14315992.771213] ACPI: PCI interrupt for device 0000:00:02.1 disabled
[14315992.789743] ehci_hcd 0000:00:02.1: --> PCI D3/wakeup
[14315992.792010] ACPI: PCI interrupt for device 0000:00:02.0 disabled
[14315992.811783] ohci_hcd 0000:00:02.0: --> PCI D3/wakeup
[14315992.815627] ACPI: Preparing to enter system sleep state S4
[14315992.825538] Extended CMOS year: 2000
[14315992.826645]  hwsleep-0324 [03] enter_sleep_state     : Entering s=
leep state [S4]
[    0.000000] Command line: root=3D/dev/sda5 resume=3D/dev/sda6 vga=3D=
6 apic=3Dverbose console=3DttyS0,115200 console=3Dtty0 pci=3Dnomsi no_c=
onsole_suspend ro
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
[    0.000000]  BIOS-e820: 000000000009f800 - 00000000000a0000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserve=
d)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000007fee0000 (usable)
[    0.000000]  BIOS-e820: 000000007fee0000 - 000000007fee3000 (ACPI NV=
S)
[    0.000000]  BIOS-e820: 000000007fee3000 - 000000007fef0000 (ACPI da=
ta)
[    0.000000]  BIOS-e820: 000000007fef0000 - 000000007ff00000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000f0000000 - 00000000f4000000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000fec00000 - 0000000100000000 (reserve=
d)
[    0.000000] max_pfn_mapped =3D 1048576
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x70106=
00070106
[    0.000000] init_memory_mapping
[    0.000000] DMI 2.4 present.
[    0.000000] ACPI: RSDP 000F7D20, 0024 (r2 Nvidia)
[    0.000000] ACPI: XSDT 7FEE3100, 004C (r1 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: FACP 7FEEADC0, 00F4 (r3 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: DSDT 7FEE3280, 7ACE (r1 NVIDIA AWRDACPI     1000 M=
SFT  3000000)
[    0.000000] ACPI: FACS 7FEE0000, 0040
[    0.000000] ACPI: SSDT 7FEEB000, 0136 (r1 PTLTD  POWERNOW        1  =
LTP        1)
[    0.000000] ACPI: HPET 7FEEB180, 0038 (r1 Nvidia ASUSACPI 42302E31 A=
WRD       98)
[    0.000000] ACPI: MCFG 7FEEB200, 003C (r1 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: APIC 7FEEAF00, 0098 (r1 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000]   early res: 0 [0-fff] BIOS data page
[    0.000000]   early res: 1 [6000-7fff] TRAMPOLINE
[    0.000000]   early res: 2 [200000-d3638f] TEXT DATA BSS
[    0.000000]   early res: 3 [9f800-fffff] BIOS reserved
[    0.000000]   early res: 4 [8000-bfff] PGTABLE
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA             0 ->     4096
[    0.000000]   DMA32        4096 ->  1048576
[    0.000000]   Normal    1048576 ->  1048576
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     0:        0 ->      159
[    0.000000]     0:      256 ->   524000
[    0.000000] Detected use of extended apic ids on hypertransport bus
[    0.000000] ACPI: PM-Timer IO Port: 0x1008
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x03] disabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x03] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x04] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 4, version 0, address 0xfec00000, GSI=
 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high lev=
el)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 14 global_irq 14 high e=
dge)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 15 global_irq 15 high e=
dge)
[    0.000000] Setting APIC routing to flat
[    0.000000] ACPI: HPET id: 0x10de8201 base: 0xfefff000
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
[    0.000000] mapped IOAPIC to ffffffffff5fa000 (00000000fec00000)
[    0.000000] PM: Registered nosave memory: 000000000009f000 - 0000000=
0000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 0000000=
0000f0000
[    0.000000] PM: Registered nosave memory: 00000000000f0000 - 0000000=
000100000
[    0.000000] Allocating PCI resources starting at 80000000 (gap: 7ff0=
0000:70100000)
[14315324.233334] Built 1 zonelists in Zone order, mobility grouping on=
=2E  Total pages: 513763
[14315324.233334] Kernel command line: root=3D/dev/sda5 resume=3D/dev/s=
da6 vga=3D6 apic=3Dverbose console=3DttyS0,115200 console=3Dtty0 pci=3D=
nomsi no_console_suspend ro
[14315324.233334] Initializing CPU#0
[14315324.233334] PID hash table entries: 4096 (order: 12, 32768 bytes)
[14315324.233334] Extended CMOS year: 2000
[14315324.233334] TSC calibrated against PM_TIMER
[14315324.233334] time.c: Detected 2411.116 MHz processor.
[14315324.233334] Console: colour VGA+ 80x60
[14315324.233334] console [tty0] enabled
[14315324.233334] console [ttyS0] enabled
[14315324.233334] Lock dependency validator: Copyright (c) 2006 Red Hat=
, Inc., Ingo Molnar
[14315324.233334] ... MAX_LOCKDEP_SUBCLASSES:    8
[14315324.233334] ... MAX_LOCK_DEPTH:          48
[14315324.233334] ... MAX_LOCKDEP_KEYS:        2048
[14315324.233334] ... CLASSHASH_SIZE:           1024
[14315324.233334] ... MAX_LOCKDEP_ENTRIES:     8192
[14315324.233334] ... MAX_LOCKDEP_CHAINS:      16384
[14315324.233334] ... CHAINHASH_SIZE:          8192
[14315324.233334]  memory used by lock dependency info: 1648 kB
[14315324.233334]  per task-struct memory footprint: 2688 bytes
[14315324.233334] Dentry cache hash table entries: 262144 (order: 9, 20=
97152 bytes)
[14315324.233334] Inode-cache hash table entries: 131072 (order: 8, 104=
8576 bytes)
[14315324.233334] Checking aperture...
[14315324.233334] Node 0: aperture @ 289c000000 size 32 MB
[14315324.233334] Aperture beyond 4GB. Ignoring.
[14315324.233334] No AGP bridge found
[14315324.233334] Memory: 2051692k/2096000k available (4624k kernel cod=
e, 43544k reserved, 2268k data, 260k init)
[14315324.316528] Calibrating delay using timer specific routine.. 4827=
=2E99 BogoMIPS (lpj=3D8043188)
[14315324.322866] Mount-cache hash table entries: 256
[14315324.327216] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64=
 bytes/line)
[14315324.333327] CPU: L2 Cache: 512K (64 bytes/line)
[14315324.336660] CPU: AMD Athlon(tm) 64 Processor 3800+ stepping 01
[14315324.342949] ACPI: Core revision 20080321
[14315324.359992] Parsing all Control Methods:
[14315324.364011] Table [DSDT](id 0001) - 1203 Objects with 101 Devices=
 380 Methods 44 Regions
[14315324.369992] Parsing all Control Methods:
[14315324.373967] Table [SSDT](id 0002) - 4 Objects with 0 Devices 0 Me=
thods 0 Regions
[14315324.379991]  tbxface-0598 [02] tb_load_namespace     : ACPI Table=
s successfully acquired
[14315324.389990] evxfevnt-0091 [02] enable                : Transition=
 to ACPI mode successful
[14315324.398905] enabled ExtINT on CPU#0
[14315324.403006] ENABLING IO-APIC IRQs
[14315324.406656] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 =
pin2=3D-1
[14315324.442963] Using local APIC timer interrupts.
[14315324.449986] Detected 12.557 MHz APIC timer.
[14315324.453320] net_namespace: 1272 bytes
[14315324.456653] NET: Registered protocol family 16
[14315324.460279] No dock devices found.
[14315324.464209] TOM: 0000000080000000 aka 2048M
[14315324.468810] ACPI: bus type pci registered
[14315324.473327] PCI: Using configuration type 1 for base access
[14315324.485055] evgpeblk-0956 [04] ev_create_gpe_block   : GPE 00 to =
1F [_GPE] 4 regs on int 0x9
[14315324.494056] evgpeblk-0956 [04] ev_create_gpe_block   : GPE 20 to =
5F [_GPE] 8 regs on int 0x9
[14315324.513173] Completing Region/Field/Buffer/Package initialization=
:......................................................................=
=2E....................................................................=
=2E.......................................
[14315324.548804] Initialized 39/44 Regions 11/11 Fields 40/40 Buffers =
89/101 Packages (1216 nodes)
[14315324.553313] Initializing Device/Processor/Thermal objects by exec=
uting _INI methods:...
[14315324.559599] Executed 3 _INI methods requiring 1 _STA executions (=
examined 108 objects)
[14315324.563312] evgpeblk-1052 [03] ev_initialize_gpe_bloc: Found 9 Wa=
ke, Enabled 0 Runtime GPEs in this block
[14315324.573312] evgpeblk-1052 [03] ev_initialize_gpe_bloc: Found 0 Wa=
ke, Enabled 1 Runtime GPEs in this block
[14315324.583311] ACPI: Interpreter enabled
[14315324.586644] ACPI: (supports S0 S1 S3 S4 S5)
[14315324.591289] ACPI: Using IOAPIC for interrupt routing
[14315324.618925] ACPI: PCI Root Bridge [PCI0] (0000:00)
[14315324.623308] PCI: Transparent bridge - 0000:00:06.0
[14315324.717297] ACPI: PCI Interrupt Link [LNK1] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.726104] ACPI: PCI Interrupt Link [LNK2] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.731566] ACPI: PCI Interrupt Link [LNK3] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.739052] ACPI: PCI Interrupt Link [LNK4] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.744887] ACPI: PCI Interrupt Link [LNK5] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.753505] ACPI: PCI Interrupt Link [LNK6] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.762300] ACPI: PCI Interrupt Link [LNK7] (IRQs 5 7 9 10 *11 14=
 15)
[14315324.766634] ACPI: PCI Interrupt Link [LNK8] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.771942] ACPI: PCI Interrupt Link [LP2P] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.778222] ACPI: PCI Interrupt Link [LUBA] (IRQs 5 7 9 10 *11 14=
 15)
[14315324.785019] ACPI: PCI Interrupt Link [LMAC] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.792423] ACPI: PCI Interrupt Link [LMC1] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.796634] ACPI: PCI Interrupt Link [LAZA] (IRQs *5 7 9 10 11 14=
 15)
[14315324.800686] ACPI: PCI Interrupt Link [LPMU] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.809480] ACPI: PCI Interrupt Link [LSMB] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.813829] ACPI: PCI Interrupt Link [LUB2] (IRQs *5 7 9 10 11 14=
 15)
[14315324.821297] ACPI: PCI Interrupt Link [LIDE] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.830093] ACPI: PCI Interrupt Link [LSID] (IRQs *5 7 9 10 11 14=
 15)
[14315324.837596] ACPI: PCI Interrupt Link [LFID] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.845095] ACPI: PCI Interrupt Link [LSA2] (IRQs 5 7 9 10 *11 14=
 15)
[14315324.852709] ACPI: PCI Interrupt Link [APC1] (IRQs 16) *0, disable=
d.
[14315324.856634] ACPI: PCI Interrupt Link [APC2] (IRQs 17) *0, disable=
d.
[14315324.860580] ACPI: PCI Interrupt Link [APC3] (IRQs 18) *0
[14315324.866844] ACPI: PCI Interrupt Link [APC4] (IRQs 19) *0, disable=
d.
[14315324.874099] ACPI: PCI Interrupt Link [APC5] (IRQs 16) *0, disable=
d.
[14315324.881348] ACPI: PCI Interrupt Link [APC6] (IRQs 16) *0, disable=
d.
[14315324.888598] ACPI: PCI Interrupt Link [APC7] (IRQs 16) *0
[14315324.893301] ACPI: PCI Interrupt Link [APC8] (IRQs 16) *0, disable=
d.
[14315324.898761] ACPI: PCI Interrupt Link [APCF] (IRQs 20 21 22 23) *0
[14315324.903301] ACPI: PCI Interrupt Link [APCH] (IRQs 20 21 22 23) *0
[14315324.906634] ACPI: PCI Interrupt Link [AMC1] (IRQs 20 21 22 23) *0
[14315324.910582] ACPI: PCI Interrupt Link [APMU] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.918714] ACPI: PCI Interrupt Link [AAZA] (IRQs 20 21 22 23) *0
[14315324.923301] ACPI: PCI Interrupt Link [APCS] (IRQs 20 21 22 23) *0
[14315324.926634] ACPI: PCI Interrupt Link [APCL] (IRQs 20 21 22 23) *0
[14315324.930582] ACPI: PCI Interrupt Link [APCM] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.938324] ACPI: PCI Interrupt Link [APCZ] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.946569] ACPI: PCI Interrupt Link [APSI] (IRQs 20 21 22 23) *0
[14315324.950580] ACPI: PCI Interrupt Link [APSJ] (IRQs 20 21 22 23) *0
[14315324.957634] ACPI: PCI Interrupt Link [ASA2] (IRQs 20 21 22 23) *0
[14315324.964780] Linux Plug and Play Support v0.97 (c) Adam Belay
[14315324.969968] pnp: PnP ACPI init
[14315324.973301] ACPI: bus type pnp registered
[14315324.985823] pnp: PnP ACPI: found 13 devices
[14315324.989968] ACPI: ACPI bus type pnp unregistered
[14315324.993301] SCSI subsystem initialized
[14315324.996759] usbcore: registered new interface driver usbfs
[14315325.002670] usbcore: registered new interface driver hub
[14315325.006635] usbcore: registered new device driver usb
[14315325.009968] PCI: Using ACPI for IRQ routing
[14315325.013301] testing the IO APIC.......................
[14315325.016635]=20
[14315325.016635] .................................... done.
[14315325.031049] Bluetooth: Core ver 2.11
[14315325.035185] NET: Registered protocol family 31
[14315325.039968] Bluetooth: HCI device and connection manager initiali=
zed
[14315325.043301] Bluetooth: HCI socket layer initialized
[14315325.046635] DMAR:parse DMAR table failure.
[14315325.057361] system 00:01: ioport range 0x1000-0x107f has been res=
erved
[14315325.064251] system 00:01: ioport range 0x1080-0x10ff has been res=
erved
[14315325.071137] system 00:01: ioport range 0x1400-0x147f has been res=
erved
[14315325.078022] system 00:01: ioport range 0x1480-0x14ff has been res=
erved
[14315325.084910] system 00:01: ioport range 0x1800-0x187f has been res=
erved
[14315325.091796] system 00:01: ioport range 0x1880-0x18ff has been res=
erved
[14315325.098693] system 00:02: ioport range 0x4d0-0x4d1 has been reser=
ved
[14315325.105406] system 00:02: ioport range 0x800-0x87f has been reser=
ved
[14315325.112119] system 00:02: ioport range 0x290-0x297 has been reser=
ved
[14315325.118858] system 00:0b: iomem range 0xf0000000-0xf3ffffff could=
 not be reserved
[14315325.126797] system 00:0c: iomem range 0xcd000-0xcffff has been re=
served
[14315325.133778] system 00:0c: iomem range 0xf0000-0xf7fff could not b=
e reserved
[14315325.143248] system 00:0c: iomem range 0xf8000-0xfbfff could not b=
e reserved
[14315325.150653] system 00:0c: iomem range 0xfc000-0xfffff could not b=
e reserved
[14315325.158059] system 00:0c: iomem range 0xfefff000-0xfefff0ff could=
 not be reserved
[14315325.165984] system 00:0c: iomem range 0x7fee0000-0x7fefffff could=
 not be reserved
[14315325.173440] system 00:0c: iomem range 0xffff0000-0xffffffff could=
 not be reserved
[14315325.181365] system 00:0c: iomem range 0x0-0x9ffff could not be re=
served
[14315325.188337] system 00:0c: iomem range 0x100000-0x7fedffff could n=
ot be reserved
[14315325.202969] system 00:0c: iomem range 0xfec00000-0xfec00fff could=
 not be reserved
[14315325.210022] system 00:0c: iomem range 0xfee00000-0xfeefffff could=
 not be reserved
[14315325.217947] system 00:0c: iomem range 0xfefff000-0xfeffffff could=
 not be reserved
[14315325.225900] system 00:0c: iomem range 0xfff80000-0xfff80fff could=
 not be reserved
[14315325.233830] system 00:0c: iomem range 0xfff90000-0xfffbffff could=
 not be reserved
[14315325.241760] system 00:0c: iomem range 0xfffed000-0xfffeffff could=
 not be reserved
[14315325.250722] PCI: Bridge: 0000:00:06.0
[14315325.254332]   IO window: 9000-9fff
[14315325.258111]   MEM window: disabled.
[14315325.263163]   PREFETCH window: disabled.
[14315325.267029] PCI: Bridge: 0000:00:0a.0
[14315325.271058]   IO window: 8000-8fff
[14315325.274831]   MEM window: 0xfde00000-0xfdefffff
[14315325.279727]   PREFETCH window: 0x00000000e8000000-0x00000000effff=
fff
[14315325.286443] PCI: Bridge: 0000:00:0e.0
[14315325.290472]   IO window: 6000-7fff
[14315325.294245]   MEM window: 0xfdd00000-0xfddfffff
[14315325.299141]   PREFETCH window: disabled.
[14315325.303509] NET: Registered protocol family 2
[14315325.339327] IP route cache hash table entries: 65536 (order: 7, 5=
24288 bytes)
[14315325.347472] TCP established hash table entries: 262144 (order: 10=
, 4194304 bytes)
[14315325.356669] TCP bind hash table entries: 65536 (order: 9, 3670016=
 bytes)
[14315325.369177] TCP: Hash tables configured (established 262144 bind =
65536)
[14315325.376181] TCP reno registered
[14315325.389176] NET: Registered protocol family 1
[14315325.395754] Installing knfsd (copyright (C) 1996 okir@monad.swb.d=
e).
[14315325.402891] JFFS2 version 2.2. (NAND) =C3=82=C2=A9 2001-2006 Red =
Hat, Inc.
[14315325.409416] fuse init (API version 7.9)
[14315325.413774] SGI XFS with security attributes, large block/inode n=
umbers, no debug enabled
[14315325.422698] msgmni has been set to 4007 for ipc namespace fffffff=
f808882f0
[14315325.430145] Block layer SCSI generic (bsg) driver version 0.4 loa=
ded (major 254)
[14315325.437997] io scheduler noop registered
[14315325.443166] io scheduler anticipatory registered
[14315325.447466] io scheduler deadline registered
[14315325.452480] io scheduler cfq registered (default)
[14315325.469713] pci 0000:00:05.0: Enabling HT MSI Mapping
[14315325.475169] pci 0000:00:05.1: Enabling HT MSI Mapping
[14315325.480288] pci 0000:00:05.2: Enabling HT MSI Mapping
[14315325.485738] pci 0000:00:06.0: Enabling HT MSI Mapping
[14315325.491174] pci 0000:00:06.1: Enabling HT MSI Mapping
[14315325.496626] pci 0000:00:08.0: Enabling HT MSI Mapping
[14315325.502069] pci 0000:00:09.0: Enabling HT MSI Mapping
[14315325.507500] pci 0000:00:0a.0: Enabling HT MSI Mapping
[14315325.512953] pci 0000:00:0e.0: Enabling HT MSI Mapping
[14315325.518653] assign_interrupt_mode Found MSI capability
[14315325.523975] assign_interrupt_mode Found MSI capability
[14315325.530243] input: Power Button (FF) as /class/input/input0
[14315325.536222] ACPI: Power Button (FF) [PWRF]
[14315325.540812] input: Power Button (CM) as /class/input/input1
[14315325.546753] ACPI: Power Button (CM) [PWRB]
[14315325.552821] ACPI: PNP0C0B:00 is registered as cooling_device0
[14315325.558944] ACPI: Fan [FAN] (on)
[14315325.562831] ACPI: ACPI0007:00 is registered as cooling_device1
[14315325.570104] ACPI: Expecting a [Reference] package element, found =
type 0
[14315325.577473] ACPI: LNXTHERM:01 is registered as thermal_zone0
[14315325.583938] ACPI: Thermal Zone [THRM] (40 C)
[14315325.610263] Real Time Clock Driver v1.12ac
[14315325.614742] Linux agpgart interface v0.103
[14315325.619213] Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, =
IRQ sharing disabled
[14315325.629426] serial8250: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550=
A
[14315325.636741] 00:09: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
[14315325.644310] loop: module loaded
[14315325.647672] e1000e: Intel(R) PRO/1000 Network Driver - 0.3.3.3-k2
[14315325.654153] e1000e: Copyright (c) 1999-2008 Intel Corporation.
[14315325.660478] e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
[14315325.666934] e100: Copyright(c) 1999-2006 Intel Corporation
[14315325.672973] tun: Universal TUN/TAP device driver, 1.6
[14315325.678389] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com=
>
[14315325.685197] Driver 'sd' needs updating - please use bus_type meth=
ods
[14315325.691990] Driver 'sr' needs updating - please use bus_type meth=
ods
[14315325.699727] ACPI: PCI Interrupt Link [APSI] enabled at IRQ 23
[14315325.705854] ACPI: PCI Interrupt 0000:00:05.0[A] -> Link [APSI] ->=
 GSI 23 (level, low) -> IRQ 23
[14315325.715675] sata_nv 0000:00:05.0: Using SWNCQ mode
[14315325.720975] scsi0 : sata_nv
[14315325.724440] scsi1 : sata_nv
[14315325.728031] ata1: SATA max UDMA/133 cmd 0x9f0 ctl 0xbf0 bmdma 0xd=
c00 irq 23
[14315325.736121] ata2: SATA max UDMA/133 cmd 0x970 ctl 0xb70 bmdma 0xd=
c08 irq 23
[14315326.213362] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300=
)
[14315326.243549] ata1.00: ATA-8: SAMSUNG HD501LJ, CR100-12, max UDMA7
[14315326.249924] ata1.00: 976773168 sectors, multi 1: LBA48 NCQ (depth=
 31/32)
[14315326.263860] ata1.00: configured for UDMA/133
[14315326.597023] ata2: SATA link down (SStatus 0 SControl 300)
[14315326.616245] isa bounce pool size: 16 pages
[14315326.620287] scsi 0:0:0:0: Direct-Access     ATA      SAMSUNG HD50=
1LJ  CR10 PQ: 0 ANSI: 5
[14315326.629360] sd 0:0:0:0: [sda] 976773168 512-byte hardware sectors=
 (500108 MB)
[14315326.636789] sd 0:0:0:0: [sda] Write Protect is off
[14315326.641991] sd 0:0:0:0: [sda] Write cache: enabled, read cache: e=
nabled, doesn't support DPO or FUA
[14315326.652984] sd 0:0:0:0: [sda] 976773168 512-byte hardware sectors=
 (500108 MB)
[14315326.660029] sd 0:0:0:0: [sda] Write Protect is off
[14315326.664333] sd 0:0:0:0: [sda] Write cache: enabled, read cache: e=
nabled, doesn't support DPO or FUA
[14315326.673832]  sda: sda1 sda2 sda3 sda4 < sda5 sda6 sda7 >
[14315326.733373] sd 0:0:0:0: [sda] Attached SCSI disk
[14315326.741834] sd 0:0:0:0: Attached scsi generic sg0 type 0
[14315326.749400] ACPI: PCI Interrupt Link [APSJ] enabled at IRQ 22
[14315326.755559] ACPI: PCI Interrupt 0000:00:05.1[B] -> Link [APSJ] ->=
 GSI 22 (level, low) -> IRQ 22
[14315326.766066] sata_nv 0000:00:05.1: Using SWNCQ mode
[14315326.771298] scsi2 : sata_nv
[14315326.774646] scsi3 : sata_nv
[14315326.779736] ata3: SATA max UDMA/133 cmd 0x9e0 ctl 0xbe0 bmdma 0xc=
800 irq 22
[14315326.786676] ata4: SATA max UDMA/133 cmd 0x960 ctl 0xb60 bmdma 0xc=
808 irq 22
[14315327.120357] ata3: SATA link down (SStatus 0 SControl 300)
[14315327.467022] ata4: SATA link down (SStatus 0 SControl 300)
[14315327.486670] ACPI: PCI Interrupt Link [ASA2] enabled at IRQ 21
[14315327.492679] ACPI: PCI Interrupt 0000:00:05.2[C] -> Link [ASA2] ->=
 GSI 21 (level, low) -> IRQ 21
[14315327.501079] sata_nv 0000:00:05.2: Using SWNCQ mode
[14315327.506771] scsi4 : sata_nv
[14315327.510118] scsi5 : sata_nv
[14315327.513669] ata5: SATA max UDMA/133 cmd 0xc400 ctl 0xc000 bmdma 0=
xb400 irq 21
[14315327.521249] ata6: SATA max UDMA/133 cmd 0xbc00 ctl 0xb800 bmdma 0=
xb408 irq 21
[14315327.857023] ata5: SATA link down (SStatus 0 SControl 300)
[14315328.346694] ata6: SATA link up 1.5 Gbps (SStatus 113 SControl 300=
)
[14315328.360110] ata6.00: ATAPI: TSSTcorp CDDVDW SH-S203B, SB00, max U=
DMA/100
[14315328.380111] ata6.00: configured for UDMA/100
[14315328.398843] scsi 5:0:0:0: CD-ROM            TSSTcorp CDDVDW SH-S2=
03B  SB00 PQ: 0 ANSI: 5
[14315328.410003] sr0: scsi3-mmc drive: 125x/125x writer dvd-ram cd/rw =
xa/form2 cdda tray
[14315328.416674] Uniform CD-ROM driver Revision: 3.20
[14315328.423724] sr 5:0:0:0: Attached scsi generic sg1 type 5
[14315328.435246] block2mtd: version $Revision: 1.30 $
[14315328.442473] ACPI: PCI Interrupt Link [APCL] enabled at IRQ 20
[14315328.446685] ACPI: PCI Interrupt 0000:00:02.1[B] -> Link [APCL] ->=
 GSI 20 (level, low) -> IRQ 20
[14315328.457118] ehci_hcd 0000:00:02.1: EHCI Host Controller
[14315328.463634] ehci_hcd 0000:00:02.1: new USB bus registered, assign=
ed bus number 1
[14315328.471119] ehci_hcd 0000:00:02.1: debug port 1
[14315328.476547] ehci_hcd 0000:00:02.1: irq 20, io mem 0xfe02e000
[14315328.491682] ehci_hcd 0000:00:02.1: USB 2.0 started, EHCI 1.00, dr=
iver 10 Dec 2004
[14315328.500162] usb usb1: configuration #1 chosen from 1 choice
[14315328.506296] hub 1-0:1.0: USB hub found
[14315328.510445] hub 1-0:1.0: 10 ports detected
[14315328.616897] usb usb1: New USB device found, idVendor=3D1d6b, idPr=
oduct=3D0002
[14315328.624059] usb usb1: New USB device strings: Mfr=3D3, Product=3D=
2, SerialNumber=3D1
[14315328.631737] usb usb1: Product: EHCI Host Controller
[14315328.638403] usb usb1: Manufacturer: Linux 2.6.26-rc4 ehci_hcd
[14315328.643654] usb usb1: SerialNumber: 0000:00:02.1
[14315328.650676] ACPI: PCI Interrupt Link [APCF] enabled at IRQ 23
[14315328.656787] ACPI: PCI Interrupt 0000:00:02.0[A] -> Link [APCF] ->=
 GSI 23 (level, low) -> IRQ 23
[14315328.666056] ohci_hcd 0000:00:02.0: OHCI Host Controller
[14315328.673336] ohci_hcd 0000:00:02.0: new USB bus registered, assign=
ed bus number 2
[14315328.680048] ohci_hcd 0000:00:02.0: irq 23, io mem 0xfe02f000
[14315328.739096] usb usb2: configuration #1 chosen from 1 choice
[14315328.745173] hub 2-0:1.0: USB hub found
[14315328.749310] hub 2-0:1.0: 10 ports detected
[14315328.826737] hub 1-0:1.0: unable to enumerate USB device on port 1
[14315328.859995] usb usb2: New USB device found, idVendor=3D1d6b, idPr=
oduct=3D0001
[14315328.866675] usb usb2: New USB device strings: Mfr=3D3, Product=3D=
2, SerialNumber=3D1
[14315328.873961] usb usb2: Product: OHCI Host Controller
[14315328.879205] usb usb2: Manufacturer: Linux 2.6.26-rc4 ohci_hcd
[14315328.883557] usb usb2: SerialNumber: 0000:00:02.0
[14315328.889802] USB Universal Host Controller Interface driver v3.0
[14315329.030024] hub 1-0:1.0: unable to enumerate USB device on port 3
[14315329.206690] hub 1-0:1.0: unable to enumerate USB device on port 4
[14315329.213291] usbcore: registered new interface driver usblp
[14315329.220135] PNP: No PS/2 controller found. Probing ports directly=
=2E
[14315329.227168] serio: i8042 KBD port at 0x60,0x64 irq 1
[14315329.232704] serio: i8042 AUX port at 0x60,0x64 irq 12
[14315329.238736] mice: PS/2 mouse device common for all mice
[14315329.263258] i2c /dev entries driver
[14315329.267314] i2c-adapter i2c-0: nForce2 SMBus adapter at 0x1c00
[14315329.273623] i2c-adapter i2c-1: nForce2 SMBus adapter at 0x1c40
[14315329.279949] it87: Found IT8716F chip at 0x290, revision 0
[14315329.283937] it87: in3 is VCC (+5V)
[14315329.289850] it87: in7 is VCCH (+5V Stand-By)
[14315329.320001] md: raid1 personality registered for level 1
[14315329.327686] device-mapper: ioctl: 4.13.0-ioctl (2007-10-18) initi=
alised: dm-devel@redhat.com
[14315329.339952] Bluetooth: HCI USB driver ver 2.9
[14315329.493345] usb 2-1: new low speed USB device using ohci_hcd and =
address 2
[14315329.680026] usb 2-1: configuration #1 chosen from 1 choice
[14315329.703336] usb 2-1: New USB device found, idVendor=3D045e, idPro=
duct=3D0040
[14315329.710017] usb 2-1: New USB device strings: Mfr=3D1, Product=3D3=
, SerialNumber=3D0
[14315329.717602] usb 2-1: Product: Microsoft 3-Button Mouse with Intel=
liEye(TM)
[14315329.726619] usb 2-1: Manufacturer: Microsoft
[14315330.006678] usb 2-3: new low speed USB device using ohci_hcd and =
address 3
[14315330.200012] usb 2-3: configuration #1 chosen from 1 choice
[14315330.236669] usb 2-3: New USB device found, idVendor=3D045e, idPro=
duct=3D00db
[14315330.243350] usb 2-3: New USB device strings: Mfr=3D1, Product=3D2=
, SerialNumber=3D0
[14315330.250927] usb 2-3: Product: Natural=C2=AE Ergonomic Keyboard 40=
00
[14315330.257121] usb 2-3: Manufacturer: Microsoft
[14315330.540011] usb 2-4: new full speed USB device using ohci_hcd and=
 address 4
[14315330.713344] usb 2-4: device descriptor read/64, error -62
[14315330.986677] usb 2-4: device descriptor read/64, error -62
[14315331.253344] usb 2-4: new full speed USB device using ohci_hcd and=
 address 5
[14315331.426677] usb 2-4: device descriptor read/64, error -62
[14315331.700011] usb 2-4: device descriptor read/64, error -62
[14315331.966678] usb 2-4: new full speed USB device using ohci_hcd and=
 address 6
[14315332.380008] usb 2-4: device not accepting address 6, error -62
[14315332.543344] usb 2-4: new full speed USB device using ohci_hcd and=
 address 7
[14315332.956675] usb 2-4: device not accepting address 7, error -62
[14315332.962884] hub 2-0:1.0: unable to enumerate USB device on port 4
[14315332.969681] usbcore: registered new interface driver hci_usb
[14315332.976016] Bluetooth: HCI UART driver ver 2.2
[14315332.982175] Bluetooth: HCI H4 protocol initialized
[14315332.986991] Bluetooth: HCI BCSP protocol initialized
[14315332.992341] cpuidle: using governor ladder
[14315332.996802] cpuidle: using governor menu
[14315333.006669] input: Microsoft Microsoft 3-Button Mouse with Intell=
iEye(TM) as /class/input/input2
[14315333.037967] input: USB HID v1.10 Mouse [Microsoft Microsoft 3-But=
ton Mouse with IntelliEye(TM)] on usb-0000:00:02.0-1
[14315333.056674] input: Microsoft Natural=C2=AE Ergonomic Keyboard 400=
0 as /class/input/input3
[14315333.090722] input: USB HID v1.11 Keyboard [Microsoft Natural=C2=AE=
 Ergonomic Keyboard 4000] on usb-0000:00:02.0-3
[14315333.113335] input: Microsoft Natural=C2=AE Ergonomic Keyboard 400=
0 as /class/input/input4
[14315333.147542] input: USB HID v1.11 Device [Microsoft Natural=C2=AE =
Ergonomic Keyboard 4000] on usb-0000:00:02.0-3
[14315333.157794] usbcore: registered new interface driver usbhid
[14315333.163615] usbhid: v2.6:USB HID core driver
[14315333.169753] Advanced Linux Sound Architecture Driver Version 1.0.=
16.
[14315333.177526] ALSA device list:
[14315333.180871]   No soundcards found.
[14315333.184803] GACT probability on
[14315333.188313] Mirror/redirect action on
[14315333.193511] u32 classifier
[14315333.196590]     Performance counters on
[14315333.198201]     input device check on=20
[14315333.202321]     Actions configured=20
[14315333.209755] IPv4 over IPv4 tunneling driver
[14315333.213971] ip_tables: (C) 2000-2006 Netfilter Core Team
[14315333.219759] TCP bic registered
[14315333.223189] TCP cubic registered
[14315333.226782] TCP westwood registered
[14315333.230632] TCP htcp registered
[14315333.234141] TCP vegas registered
[14315333.237735] TCP yeah registered
[14315333.241240] Initializing XFRM netlink socket
[14315333.246173] NET: Registered protocol family 10
[14315333.253336] IPv6 over IPv4 tunneling driver
[14315333.260003] NET: Registered protocol family 17
[14315333.266655] NET: Registered protocol family 15
[14315333.270137] Bridge firewalling registered
[14315333.274547] Bluetooth: L2CAP ver 2.9
[14315333.278487] Bluetooth: L2CAP socket layer initialized
[14315333.283907] Bluetooth: SCO (Voice Link) ver 0.5
[14315333.288799] Bluetooth: SCO socket layer initialized
[14315333.293704] Bluetooth: RFCOMM socket layer initialized
[14315333.299223] Bluetooth: RFCOMM TTY layer initialized
[14315333.304474] Bluetooth: RFCOMM ver 1.8
[14315333.309739] Bluetooth: BNEP (Ethernet Emulation) ver 1.2
[14315333.313777] Bluetooth: HIDP (Human Interface Emulation) ver 1.2
[14315333.320383] RPC: Registered udp transport module.
[14315333.325755] RPC: Registered tcp transport module.
[14315333.330882] 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelat=
ech.com>
[14315333.339565] All bugs added by David S. Miller <davem@redhat.com>
[14315333.343476] powernow-k8: Found 1 AMD Athlon(tm) 64 Processor 3800=
+ processors (1 cpu cores) (version 2.20.00)
[14315333.356638] powernow-k8:    0 : fid 0x10 (2400 MHz), vid 0x8
[14315333.360223] powernow-k8:    1 : fid 0xe (2200 MHz), vid 0xa
[14315333.366392] powernow-k8:    2 : fid 0xc (2000 MHz), vid 0xc
[14315333.379005] powernow-k8:    3 : fid 0xa (1800 MHz), vid 0xe
[14315333.384939] powernow-k8:    4 : fid 0x2 (1000 MHz), vid 0x12
[14315333.397176] Freezing user space processes ... (elapsed 0.00 secon=
ds) done.
[14315333.405713] Freezing remaining freezable tasks ... (elapsed 0.00 =
seconds) done.
[14315333.413728] PM: Loading image data pages (82061 pages) ...     =08=
=08=08=08  0%=08=08=08=08  1%=08=08=08=08  2%=08=08=08=08  3%=08=08=08=08=
  4%=08=08=08=08  5%=08=08=08=08  6%=08=08=08=08  7%=08=08=08=08  8%Mar=
king TSC unstable due to cpufreq changes
[14315334.100080] =08=08=08=08  9%=08=08=08=08 10%=08=08=08=08 11%=08=08=
=08=08 12%=08=08=08=08 13%=08=08=08=08 14%=08=08=08=08 15%=08=08=08=08 =
16%=08=08=08=08 17%=08=08=08=08 18%=08=08=08=08 19%=08=08=08=08 20%=08=08=
=08=08 21%=08=08=08=08 22%=08=08=08=08 23%<4>Clocksource tsc unstable (=
delta =3D -83348826 ns)
[14315334.761277] =08=08=08=08 24%=08=08=08=08 25%=08=08=08=08 26%=08=08=
=08=08 27%=08=08=08=08 28%=08=08=08=08 29%=08=08=08=08 30%=08=08=08=08 =
31%=08=08=08=08 32%=08=08=08=08 33%=08=08=08=08 34%=08=08=08=08 35%=08=08=
=08=08 36%=08=08=08=08 37%=08=08=08=08 38%=08=08=08=08 39%=08=08=08=08 =
40%=08=08=08=08 41%=08=08=08=08 42%=08=08=08=08 43%=08=08=08=08 44%=08=08=
=08=08 45%=08=08=08=08 46%=08=08=08=08 47%=08=08=08=08 48%=08=08=08=08 =
49%=08=08=08=08 50%=08=08=08=08 51%=08=08=08=08 52%=08=08=08=08 53%=08=08=
=08=08 54%=08=08=08=08 55%=08=08=08=08 56%=08=08=08=08 57%=08=08=08=08 =
58%=08=08=08=08 59%=08=08=08=08 60%=08=08=08=08 61%=08=08=08=08 62%=08=08=
=08=08 63%=08=08=08=08 64%=08=08=08=08 65%=08=08=08=08 66%=08=08=08=08 =
67%=08=08=08=08 68%=08=08=08=08 69%=08=08=08=08 70%=08=08=08=08 71%=08=08=
=08=08 72%=08=08=08=08 73%=08=08=08=08 74%=08=08=08=08 75%=08=08=08=08 =
76%=08=08=08=08 77%=08=08=08=08 78%=08=08=08=08 79%=08=08=08=08 80%=08=08=
=08=08 81%=08=08=08=08 82%=08=08=08=08 83%=08=08=08=08 84%=08=08=08=08 =
85%=08=08=08=08 86%=08=08=08=08 87%=08=08=08=08 88%=08=08=08=08 89%=08=08=
=08=08 90%=08=08=08=08 91%=08=08=08=08 92%=08=08=08=08 93%=08=08=08=08 =
94%=08=08=08=08 95%=08=08=08=08 96%=08=08=08=08 97%=08=08=08=08 98%=08=08=
=08=08 99%=08=08=08=08100%=08=08=08=08done
[14315338.103363] PM: Read 328244 kbytes in 4.69 seconds (69.98 MB/s)
[14315338.118467] sd 0:0:0:0: [sda] Synchronizing SCSI cache
[14315338.125657] ACPI: PCI interrupt for device 0000:00:05.2 disabled
[14315338.132768] ACPI: PCI interrupt for device 0000:00:05.1 disabled
[14315338.139434] ACPI: PCI interrupt for device 0000:00:05.0 disabled
[14315338.145877] ACPI: PCI interrupt for device 0000:00:02.0 disabled
[14315338.152470] Extended CMOS year: 2000
[14315986.563274] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x70=
10600070106
[14315986.563274] evxfevnt-0079 [02] enable                : System is =
already in ACPI mode
[14315986.563274] svm_cpu_init: svm_data is NULL on 0
[14315986.563274] Extended CMOS year: 2000
[14315986.589380] ACPI: Unable to turn cooling device [ffff81007f842f50=
] 'off'
[14315986.595650] ohci_hcd 0000:00:02.0: PCI legacy resume
[14315986.602250] ACPI: PCI Interrupt 0000:00:02.0[A] -> Link [APCF] ->=
 GSI 23 (level, low) -> IRQ 23
[14315986.610740] PCI: Setting latency timer of device 0000:00:02.0 to =
64
[14315986.616840] ohci_hcd 0000:00:02.0: lost power
[14315986.676746] ohci_hcd 0000:00:02.0: OHCI controller state
[14315986.682550] ohci_hcd 0000:00:02.0: OHCI 1.0, NO legacy support re=
gisters
[14315986.689553] ohci_hcd 0000:00:02.0: control 0x683 RWE RWC HCFS=3Do=
perational CBSR=3D3
[14315986.699552] ohci_hcd 0000:00:02.0: cmdstatus 0x00000 SOC=3D0
[14315986.703045] ohci_hcd 0000:00:02.0: intrstatus 0x00000044 RHSC SF
[14315986.709712] ohci_hcd 0000:00:02.0: intrenable 0x8000000a MIE RD W=
DH
[14315986.716023] ohci_hcd 0000:00:02.0: hcca frame #002b
[14315986.722593] ohci_hcd 0000:00:02.0: roothub.a 0100120a POTPGT=3D1 =
NOCP NPS NDP=3D10(10)
[14315986.728984] ohci_hcd 0000:00:02.0: roothub.b 00000000 PPCM=3D0000=
 DR=3D0000
[14315986.735900] ohci_hcd 0000:00:02.0: roothub.status 00008000 DRWE
[14315986.742568] ohci_hcd 0000:00:02.0: roothub.portstatus [0] 0x00010=
301 CSC LSDA PPS CCS
[14315986.752122] ohci_hcd 0000:00:02.0: roothub.portstatus [1] 0x00000=
100 PPS
[14315986.757264] ohci_hcd 0000:00:02.0: roothub.portstatus [2] 0x00010=
301 CSC LSDA PPS CCS
[14315986.765496] ohci_hcd 0000:00:02.0: roothub.portstatus [3] 0x00010=
101 CSC PPS CCS
[14315986.775496] ohci_hcd 0000:00:02.0: roothub.portstatus [4] 0x00000=
100 PPS
[14315986.780480] ohci_hcd 0000:00:02.0: roothub.portstatus [5] 0x00000=
100 PPS
[14315986.787580] ohci_hcd 0000:00:02.0: roothub.portstatus [6] 0x00000=
100 PPS
[14315986.794677] ohci_hcd 0000:00:02.0: roothub.portstatus [7] 0x00000=
100 PPS
[14315986.801774] ohci_hcd 0000:00:02.0: roothub.portstatus [8] 0x00000=
100 PPS
[14315986.808870] ohci_hcd 0000:00:02.0: roothub.portstatus [9] 0x00000=
100 PPS
[14315986.815970] ohci_hcd 0000:00:02.0: restart complete
[14315986.822637] usb usb2: root hub lost power or was reset
[14315986.827920] ohci_hcd 0000:00:02.0: suspend root hub
[14315986.832075] ehci_hcd 0000:00:02.1: PCI legacy resume
[14315986.838745] ACPI: PCI Interrupt 0000:00:02.1[B] -> Link [APCL] ->=
 GSI 20 (level, low) -> IRQ 20
[14315986.847146] PCI: Setting latency timer of device 0000:00:02.1 to =
64
[14315986.853423] ehci_hcd 0000:00:02.1: lost power, restarting
[14315986.859232] usb usb1: root hub lost power or was reset
[14315986.865901] ehci_hcd 0000:00:02.1: reset command 080b02 park=3D3 =
ithresh=3D8 period=3D1024 Reset HALT
[14315986.874772] ehci_hcd 0000:00:02.1: debug port 1
[14315986.878896] PCI: cache line size of 64 is not supported by device=
 0000:00:02.1
[14315986.888901] PM: Writing back config space on device 0000:00:04.0 =
at offset b (was 82391043, writing 8239f043)
[14315986.897045] PCI: Setting latency timer of device 0000:00:04.0 to =
64
[14315986.910015] ata8: port disabled. ignoring.
[14315986.914630] PM: Writing back config space on device 0000:00:05.0 =
at offset 1 (was b00003, writing b00007)
[14315986.924729] ACPI: PCI Interrupt 0000:00:05.0[A] -> Link [APSI] ->=
 GSI 23 (level, low) -> IRQ 23
[14315986.934453] PCI: Setting latency timer of device 0000:00:05.0 to =
64
[14315986.941010] PM: Writing back config space on device 0000:00:05.1 =
at offset 1 (was b00003, writing b00007)
[14315986.951635] ACPI: PCI Interrupt 0000:00:05.1[B] -> Link [APSJ] ->=
 GSI 22 (level, low) -> IRQ 22
[14315986.961165] PCI: Setting latency timer of device 0000:00:05.1 to =
64
[14315986.968038] PM: Writing back config space on device 0000:00:05.2 =
at offset 1 (was b00003, writing b00007)
[14315986.978536] ACPI: PCI Interrupt 0000:00:05.2[C] -> Link [ASA2] ->=
 GSI 21 (level, low) -> IRQ 21
[14315986.988059] PCI: Setting latency timer of device 0000:00:05.2 to =
64
[14315986.994917] PCI: Setting latency timer of device 0000:00:06.0 to =
64
[14315987.013297] PM: Writing back config space on device 0000:00:06.1 =
at offset 1 (was b00006, writing b00002)
[14315987.023378] ACPI: PCI Interrupt 0000:00:06.1[B] -> Link [AAZA] ->=
 GSI 22 (level, low) -> IRQ 22
[14315987.032679] PCI: Setting latency timer of device 0000:00:06.1 to =
64
[14315987.085970] ata7.01: ACPI cmd ef/03:44:00:00:00:b0 filtered out
[14315987.089928] ata7.01: ACPI cmd ef/03:0c:00:00:00:b0 filtered out
[14315987.096627] ata7: nv_mode_filter: 0x1f01f&0x1f01f->0x1f01f, BIOS=3D=
0x1f000 (0xc50000) ACPI=3D0x1f01f (600:30:0x1c)
[14315987.113600] ata7.01: configured for UDMA/66
[14315987.263295] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300=
)
[14315987.325767] ata6: SATA link up 1.5 Gbps (SStatus 113 SControl 300=
)
[14315987.352457] ata2: SATA link down (SStatus 0 SControl 300)
[14315987.357660] ata1.00: ACPI cmd ef/03:46:00:00:00:a0 filtered out
[14315987.363714] ata1.00: ACPI cmd f5/00:00:00:00:00:a0 filtered out
[14315987.370155] ata6.00: ACPI cmd ef/03:46:00:00:00:a0 filtered out
[14315987.379831] ata3: SATA link down (SStatus 0 SControl 300)
[14315987.382567] ata5: SATA link down (SStatus 0 SControl 300)
[14315987.389289] ata4: SATA link down (SStatus 0 SControl 300)
[14315987.395472] ata6.00: configured for UDMA/100
[14315987.401731] ata1.00: configured for UDMA/133
[14315987.405175] sd 0:0:0:0: [sda] 976773168 512-byte hardware sectors=
 (500108 MB)
[14315987.412932] sd 0:0:0:0: [sda] Write Protect is off
[14315987.419578] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[14315987.424926] sd 0:0:0:0: [sda] Write cache: enabled, read cache: e=
nabled, doesn't support DPO or FUA
[14315987.467065] eth0: no link during initialization.
[14315987.484033] PCI: Setting latency timer of device 0000:00:0a.0 to =
64
[14315987.491779] PCI: Setting latency timer of device 0000:00:0e.0 to =
64
[14315987.509959] PM: Writing back config space on device 0000:01:08.0 =
at offset 1 (was 2900005, writing 2900001)
[14315987.520213] ACPI: PCI Interrupt 0000:01:08.0[A] -> Link [APC3] ->=
 GSI 18 (level, low) -> IRQ 18
[14315987.537783] ACPI: PCI Interrupt 0000:02:00.0[A] -> Link [APC7] ->=
 GSI 16 (level, low) -> IRQ 16
[14315987.548735] PCI: Setting latency timer of device 0000:02:00.0 to =
64
[14315987.555499] sd 0:0:0:0: [sda] Starting disk
[14315987.585461] usb usb1: usb resume
[14315987.609591] ehci_hcd 0000:00:02.1: resume root hub after power lo=
ss
[14315987.689950] ehci_hcd 0000:00:02.1: port 4 low speed --> companion
[14315987.696455] ehci_hcd 0000:00:02.1: port 3 low speed --> companion
[14315987.703118] ehci_hcd 0000:00:02.1: port 1 low speed --> companion
[14315987.799951] ehci_hcd 0000:00:02.1: GetStatus port 4 status 003402=
 POWER OWNER sig=3Dk CSC
[14315987.808460] ehci_hcd 0000:00:02.1: GetStatus port 3 status 003402=
 POWER OWNER sig=3Dk CSC
[14315987.818459] ehci_hcd 0000:00:02.1: GetStatus port 1 status 003402=
 POWER OWNER sig=3Dk CSC
[14315987.836617] hub 1-0:1.0: hub_reset_resume
[14315987.841029] hub 1-0:1.0: trying to enable port power on non-switc=
hable hub
[14315987.949971] usb usb2: usb resume
[14315987.953634] ohci_hcd 0000:00:02.0: wakeup root hub
[14315988.026616] hub 2-0:1.0: hub_reset_resume
[14315988.031030] hub 2-0:1.0: trying to enable port power on non-switc=
hable hub
[14315988.139956] ohci_hcd 0000:00:02.0: GetStatus roothub.portstatus [=
3] =3D 0x00010101 CSC PPS CCS
[14315988.159949] usb 2-1: finish reset-resume
[14315988.419952] ohci_hcd 0000:00:02.0: GetStatus roothub.portstatus [=
0] =3D 0x00100303 PRSC LSDA PPS PES CCS
[14315988.479955] usb 2-1: reset low speed USB device using ohci_hcd an=
d address 2
[14315988.743285] ohci_hcd 0000:00:02.0: GetStatus roothub.portstatus [=
0] =3D 0x00100303 PRSC LSDA PPS PES CCS
[14315988.846616] usb 2-3: finish reset-resume
[14315989.106618] ohci_hcd 0000:00:02.0: GetStatus roothub.portstatus [=
2] =3D 0x00100303 PRSC LSDA PPS PES CCS
[14315989.166618] usb 2-3: reset low speed USB device using ohci_hcd an=
d address 3
[14315989.433285] ohci_hcd 0000:00:02.0: GetStatus roothub.portstatus [=
2] =3D 0x00100303 PRSC LSDA PPS PES CCS
[14315989.516610] usb 2-3: manual set_interface for iface 0, alt 0
[14315989.537646] usb 2-3: manual set_interface for iface 1, alt 0
[14315989.554579] PM: Image restored successfully.
[14315989.624012] Restarting tasks ... <7>hub 1-0:1.0: state 7 ports 10=
 chg 0000 evt 0000
[14315989.635191] usb usb1: remote wakeup needed for autosuspend
[14315989.639411] hub 2-0:1.0: state 7 ports 10 chg 0000 evt 0010
[14315989.646085] ohci_hcd 0000:00:02.0: GetStatus roothub.portstatus [=
3] =3D 0x00010101 CSC PPS CCS
[14315989.655410] hub 2-0:1.0: port 4, status 0101, change 0001, 12 Mb/=
s
[14315989.734100] done.
[14315989.737591] PM: Basic memory bitmaps freed
[14315989.803290] hub 2-0:1.0: debounce: port 4: total 100ms stable 100=
ms status 0x101
[14315989.916620] ohci_hcd 0000:00:02.0: GetStatus roothub.portstatus [=
3] =3D 0x00100103 PRSC PPS PES CCS
[14315989.979960] usb 2-4: new full speed USB device using ohci_hcd and=
 address 8
[14315989.988178] ohci_hcd 0000:00:02.0: urb ffff810079c53680 path 4 ep=
0in 5ec20000 cc 5 --> status -62
[14315990.002481] ohci_hcd 0000:00:02.0: urb ffff810079c53680 path 4 ep=
0in 5ec20000 cc 5 --> status -62
[14315990.009944] ohci_hcd 0000:00:02.0: urb ffff810079c53680 path 4 ep=
0in 5ec20000 cc 5 --> status -62
[14315990.126620] ohci_hcd 0000:00:02.0: GetStatus roothub.portstatus [=
3] =3D 0x00100103 PRSC PPS PES CCS
[14315990.186620] usb 2-4: device descriptor read/64, error -62
[14315990.294084] ohci_hcd 0000:00:02.0: urb ffff810079c53680 path 4 ep=
0in 5ec20000 cc 5 --> status -62
[14315990.303277] ohci_hcd 0000:00:02.0: urb ffff810079c53680 path 4 ep=
0in 5ec20000 cc 5 --> status -62
[14315990.303277] ohci_hcd 0000:00:02.0: urb ffff810079c53680 path 4 ep=
0in 5ec20000 cc 5 --> status -62
[14315990.433285] ohci_hcd 0000:00:02.0: GetStatus roothub.portstatus [=
3] =3D 0x00100103 PRSC PPS PES CCS
[14315990.493290] usb 2-4: device descriptor read/64, error -62
[14315990.706618] ohci_hcd 0000:00:02.0: GetStatus roothub.portstatus [=
3] =3D 0x00100103 PRSC PPS PES CCS
[14315990.769956] usb 2-4: new full speed USB device using ohci_hcd and=
 address 9
[14315990.780758] ohci_hcd 0000:00:02.0: urb ffff810079c53680 path 4 ep=
0in 5ec20000 cc 5 --> status -62
[14315990.791297] ohci_hcd 0000:00:02.0: urb ffff810079c53680 path 4 ep=
0in 5ec20000 cc 5 --> status -62
[14315990.804078] ohci_hcd 0000:00:02.0: urb ffff810079c53680 path 4 ep=
0in 5ec20000 cc 5 --> status -62
[14315990.919953] ohci_hcd 0000:00:02.0: GetStatus roothub.portstatus [=
3] =3D 0x00100103 PRSC PPS PES CCS
[14315990.979957] usb 2-4: device descriptor read/64, error -62
[14315991.087264] ohci_hcd 0000:00:02.0: urb ffff810079c53680 path 4 ep=
0in 5ec20000 cc 5 --> status -62
[14315991.096610] ohci_hcd 0000:00:02.0: urb ffff810079c53680 path 4 ep=
0in 5ec20000 cc 5 --> status -62
[14315991.096614] ohci_hcd 0000:00:02.0: urb ffff810079c53680 path 4 ep=
0in 5ec20000 cc 5 --> status -62
[14315991.229953] ohci_hcd 0000:00:02.0: GetStatus roothub.portstatus [=
3] =3D 0x00100103 PRSC PPS PES CCS
[14315991.289964] usb 2-4: device descriptor read/64, error -62
[14315991.503285] ohci_hcd 0000:00:02.0: GetStatus roothub.portstatus [=
3] =3D 0x00100103 PRSC PPS PES CCS
[14315991.566624] usb 2-4: new full speed USB device using ohci_hcd and=
 address 10
[14315991.577744] ohci_hcd 0000:00:02.0: urb ffff810079c53680 path 4 ep=
0out 5ec20000 cc 5 --> status -62
[14315991.790449] ohci_hcd 0000:00:02.0: urb ffff810079c53680 path 4 ep=
0out 5ec20000 cc 5 --> status -62
[14315992.003284] usb 2-4: device not accepting address 10, error -62
[14315992.113285] ohci_hcd 0000:00:02.0: GetStatus roothub.portstatus [=
3] =3D 0x00100103 PRSC PPS PES CCS
[14315992.173291] usb 2-4: new full speed USB device using ohci_hcd and=
 address 11
[14315992.184180] ohci_hcd 0000:00:02.0: urb ffff810079c53680 path 4 ep=
0out 5ec20000 cc 5 --> status -62
[14315992.397242] ohci_hcd 0000:00:02.0: urb ffff810079c53680 path 4 ep=
0out 5ec20000 cc 5 --> status -62
[14315992.609950] usb 2-4: device not accepting address 11, error -62
[14315992.616293] hub 2-0:1.0: unable to enumerate USB device on port 4
[14315992.626214] hub 2-0:1.0: state 7 ports 10 chg 0000 evt 0010
[14315999.439944] [drm] Loading R300 Microcode
[14316042.515071] PM: Hibernation mode set to 'platform'
[14316042.526291] PM: Marking nosave pages: 000000000009f000 - 00000000=
00100000
[14316042.536589] PM: Basic memory bitmaps created
[14316042.538198] PM: Syncing filesystems ... done.
[14316042.550112] Freezing user space processes ... (elapsed 0.00 secon=
ds) done.
[14316042.565534] Freezing remaining freezable tasks ... (elapsed 0.00 =
seconds) done.
[14316042.574058] PM: Shrinking memory...  =08-=08done (0 pages freed)
[14316042.771984] PM: Freed 0 kbytes in 0.19 seconds (0.00 MB/s)
[14316042.779933] hub 2-0:1.0: hub_suspend
[14316042.783880] usb usb2: bus suspend
[14316042.789752] ohci_hcd 0000:00:02.0: suspend root hub
[14316042.793447] hub 1-0:1.0: hub_suspend
[14316042.797397] usb usb1: bus suspend
[14316042.801079] ehci_hcd 0000:00:02.1: suspend root hub
[14316042.806378] sd 0:0:0:0: [sda] Synchronizing SCSI cache
[14316042.819280] ACPI: PCI interrupt for device 0000:01:08.0 disabled
[14316042.825677] ACPI handle has no context!
[14316042.879962] ACPI: PCI interrupt for device 0000:00:06.1 disabled
[14316042.899754] ACPI: PCI interrupt for device 0000:00:05.2 disabled
[14316042.903324] ACPI: PCI interrupt for device 0000:00:05.1 disabled
[14316042.909780] ACPI: PCI interrupt for device 0000:00:05.0 disabled
[14316042.916204] ata8: port disabled. ignoring.
[14316042.922637] ACPI: PCI interrupt for device 0000:00:02.1 disabled
[14316042.929007] ehci_hcd 0000:00:02.1: --> no state change
[14316042.932395] ACPI: PCI interrupt for device 0000:00:02.0 disabled
[14316042.939043] ohci_hcd 0000:00:02.0: --> no state change
[14316042.945692] ACPI: Preparing to enter system sleep state S4
[14316042.952727] Extended CMOS year: 2000
[14316042.953739] PM: Creating hibernation image:=20
[14316042.953739] PM: Need to copy 82428 pages
[14316042.953739] PM: Normal pages needed: 82428 + 1024 + 38, available=
 pages: 441474
[14316042.953739] PM: Hibernation image created (82428 pages copied)
[14316042.953739] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x70=
10600070106
[14316042.953739] svm_cpu_init: svm_data is NULL on 0
[14316042.953739] Extended CMOS year: 2000
[14316042.966088] ACPI: Unable to turn cooling device [ffff81007f842f50=
] 'off'
[14316042.976587] ohci_hcd 0000:00:02.0: PCI legacy resume
[14316042.979948] ACPI: PCI Interrupt 0000:00:02.0[A] -> Link [APCF] ->=
 GSI 23 (level, low) -> IRQ 23
[14316042.989587] PCI: Setting latency timer of device 0000:00:02.0 to =
64
[14316042.996229] ohci_hcd 0000:00:02.0: powerup ports
[14316043.022910] ehci_hcd 0000:00:02.1: PCI legacy resume
[14316043.026611] ACPI: PCI Interrupt 0000:00:02.1[B] -> Link [APCL] ->=
 GSI 20 (level, low) -> IRQ 20
[14316043.036198] PCI: Setting latency timer of device 0000:00:02.1 to =
64
[14316043.042853] PM: Writing back config space on device 0000:00:04.0 =
at offset 1 (was b00001, writing b00005)
[14316043.052878] PCI: Setting latency timer of device 0000:00:04.0 to =
64
[14316043.062714] PM: Writing back config space on device 0000:00:05.0 =
at offset 1 (was b00003, writing b00007)
[14316043.074451] ata8: port disabled. ignoring.
[14316043.078822] ACPI: PCI Interrupt 0000:00:05.0[A] -> Link [APSI] ->=
 GSI 23 (level, low) -> IRQ 23
[14316043.088715] PCI: Setting latency timer of device 0000:00:05.0 to =
64
[14316043.095744] PM: Writing back config space on device 0000:00:05.1 =
at offset 1 (was b00003, writing b00007)
[14316043.105945] ACPI: PCI Interrupt 0000:00:05.1[B] -> Link [APSJ] ->=
 GSI 22 (level, low) -> IRQ 22
[14316043.113674] PCI: Setting latency timer of device 0000:00:05.1 to =
64
[14316043.123267] PM: Writing back config space on device 0000:00:05.2 =
at offset 1 (was b00003, writing b00007)
[14316043.133264] ACPI: PCI Interrupt 0000:00:05.2[C] -> Link [ASA2] ->=
 GSI 21 (level, low) -> IRQ 21
[14316043.140088] PCI: Setting latency timer of device 0000:00:05.2 to =
64
[14316043.146850] PCI: Setting latency timer of device 0000:00:06.0 to =
64
[14316043.166620] PM: Writing back config space on device 0000:00:06.1 =
at offset f (was 5020200, writing 5020205)
[14316043.176821] PM: Writing back config space on device 0000:00:06.1 =
at offset 4 (was 0, writing fe020000)
[14316043.186581] PM: Writing back config space on device 0000:00:06.1 =
at offset 1 (was b00000, writing b00002)
[14316043.199936] ACPI: PCI Interrupt 0000:00:06.1[B] -> Link [AAZA] ->=
 GSI 22 (level, low) -> IRQ 22
[14316043.207524] PCI: Setting latency timer of device 0000:00:06.1 to =
64
[14316043.231202] ata7.01: ACPI cmd ef/03:44:00:00:00:b0 filtered out
[14316043.236607] ata7.01: ACPI cmd ef/03:0c:00:00:00:b0 filtered out
[14316043.243198] ata7: nv_mode_filter: 0x1f01f&0x1f01f->0x1f01f, BIOS=3D=
0x1f000 (0xc50000) ACPI=3D0x1f01f (600:30:0x1c)
[14316043.266812] ata7.01: configured for UDMA/66
[14316043.416621] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300=
)
[14316043.434478] ata2: SATA link down (SStatus 0 SControl 300)
[14316043.453759] ata1.00: ACPI cmd ef/03:46:00:00:00:a0 filtered out
[14316043.460338] ata4: SATA link down (SStatus 0 SControl 300)
[14316043.476354] ata6: SATA link up 1.5 Gbps (SStatus 113 SControl 300=
)
[14316043.483008] ata1.00: ACPI cmd f5/00:00:00:00:00:a0 filtered out
[14316043.499809] ata6.00: ACPI cmd ef/03:46:00:00:00:a0 filtered out
[14316043.506447] ata5: SATA link down (SStatus 0 SControl 300)
[14316043.513068] ata3: SATA link down (SStatus 0 SControl 300)
[14316043.524158] ata6.00: configured for UDMA/100
[14316043.528288] ata1.00: configured for UDMA/133
[14316043.533090] sd 0:0:0:0: [sda] 976773168 512-byte hardware sectors=
 (500108 MB)
[14316043.543053] sd 0:0:0:0: [sda] Write Protect is off
[14316043.546928] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[14316043.552768] sd 0:0:0:0: [sda] Write cache: enabled, read cache: e=
nabled, doesn't support DPO or FUA
[14316043.646619] PM: Writing back config space on device 0000:00:08.0 =
at offset f (was 14010100, writing 1401010a)
[14316043.657001] PM: Writing back config space on device 0000:00:08.0 =
at offset 7 (was 0, writing fe028000)
[14316043.666998] PM: Writing back config space on device 0000:00:08.0 =
at offset 6 (was 0, writing fe029000)
[14316043.676541] PM: Writing back config space on device 0000:00:08.0 =
at offset 5 (was 1, writing b001)
[14316043.686542] PM: Writing back config space on device 0000:00:08.0 =
at offset 4 (was 0, writing fe02a000)
[14316043.695962] PM: Writing back config space on device 0000:00:08.0 =
at offset 1 (was b00000, writing b00007)
[14316043.706310] eth0: no link during initialization.
[14316043.723285] PM: Writing back config space on device 0000:00:09.0 =
at offset f (was 14010100, writing 1401010a)
[14316043.733675] PM: Writing back config space on device 0000:00:09.0 =
at offset 7 (was 0, writing fe025000)
[14316043.743671] PM: Writing back config space on device 0000:00:09.0 =
at offset 6 (was 0, writing fe026000)
[14316043.753222] PM: Writing back config space on device 0000:00:09.0 =
at offset 5 (was 1, writing ac01)
[14316043.763222] PM: Writing back config space on device 0000:00:09.0 =
at offset 4 (was 0, writing fe027000)
[14316043.772644] PM: Writing back config space on device 0000:00:09.0 =
at offset 1 (was b00000, writing b00007)
[14316043.785895] PCI: Setting latency timer of device 0000:00:0a.0 to =
64
[14316043.790896] PCI: Setting latency timer of device 0000:00:0e.0 to =
64
[14316043.809963] ACPI: PCI Interrupt 0000:01:08.0[A] -> Link [APC3] ->=
 GSI 18 (level, low) -> IRQ 18
[14316043.828438] ACPI: PCI Interrupt 0000:02:00.0[A] -> Link [APC7] ->=
 GSI 16 (level, low) -> IRQ 16
[14316043.838298] PCI: Setting latency timer of device 0000:02:00.0 to =
64
[14316043.843816] sd 0:0:0:0: [sda] Starting disk
[14316043.858391] usb usb1: usb resume
[14316043.918524] ehci_hcd 0000:00:02.1: resume root hub
[14316043.986610] hub 1-0:1.0: hub_resume
[14316043.990514] usb usb2: usb resume
[14316043.994137] ohci_hcd 0000:00:02.0: resume root hub
[14316044.066609] hub 2-0:1.0: hub_resume
[14316044.070613] PM: writing image.
[14316044.074110] PM: Free swap pages: 977947
[14316044.079438] PM: Saving image data pages (82589 pages) ...     =08=
=08=08=08  0%=08=08=08=08  1%=08=08=08=08  2%=08=08=08=08  3%=08=08=08=08=
  4%=08=08=08=08  5%=08=08=08=08  6%=08=08=08=08  7%=08=08=08=08  8%=08=
=08=08=08  9%=08=08=08=08 10%=08=08=08=08 11%=08=08=08=08 12%=08=08=08=08=
 13%=08=08=08=08 14%=08=08=08=08 15%=08=08=08=08 16%=08=08=08=08 17%=08=
=08=08=08 18%=08=08=08=08 19%=08=08=08=08 20%=08=08=08=08 21%=08=08=08=08=
 22%=08=08=08=08 23%=08=08=08=08 24%=08=08=08=08 25%=08=08=08=08 26%=08=
=08=08=08 27%=08=08=08=08 28%=08=08=08=08 29%=08=08=08=08 30%=08=08=08=08=
 31%=08=08=08=08 32%=08=08=08=08 33%=08=08=08=08 34%=08=08=08=08 35%=08=
=08=08=08 36%=08=08=08=08 37%=08=08=08=08 38%=08=08=08=08 39%=08=08=08=08=
 40%=08=08=08=08 41%=08=08=08=08 42%=08=08=08=08 43%=08=08=08=08 44%=08=
=08=08=08 45%=08=08=08=08 46%=08=08=08=08 47%=08=08=08=08 48%=08=08=08=08=
 49%=08=08=08=08 50%=08=08=08=08 51%=08=08=08=08 52%=08=08=08=08 53%=08=
=08=08=08 54%=08=08=08=08 55%=08=08=08=08 56%=08=08=08=08 57%=08=08=08=08=
 58%=08=08=08=08 59%=08=08=08=08 60%=08=08=08=08 61%=08=08=08=08 62%=08=
=08=08=08 63%=08=08=08=08 64%=08=08=08=08 65%=08=08=08=08 66%=08=08=08=08=
 67%=08=08=08=08 68%=08=08=08=08 69%=08=08=08=08 70%=08=08=08=08 71%=08=
=08=08=08 72%=08=08=08=08 73%=08=08=08=08 74%=08=08=08=08 75%=08=08=08=08=
 76%=08=08=08=08 77%=08=08=08=08 78%=08=08=08=08 79%=08=08=08=08 80%=08=
=08=08=08 81%=08=08=08=08 82%=08=08=08=08 83%=08=08=08=08 84%=08=08=08=08=
 85%=08=08=08=08 86%=08=08=08=08 87%=08=08=08=08 88%=08=08=08=08 89%=08=
=08=08=08 90%=08=08=08=08 91%=08=08=08=08 92%=08=08=08=08 93%=08=08=08=08=
 94%=08=08=08=08 95%=08=08=08=08 96%=08=08=08=08 97%=08=08=08=08 98%=08=
=08=08=08 99%=08=08=08=08100%=08=08=08=08done
[14316048.280494] PM: Wrote 330356 kbytes in 4.19 seconds (78.84 MB/s)
[14316048.287753] PM: S|
[14316048.677728] ohci_hcd 0000:00:02.0: Unlink after no-IRQ?  Controll=
er is probably using the wrong IRQ.
[14316048.692267] usb 2-3: usb suspend
[14316048.714043] usb 2-1: usb suspend
[14316048.729956] hub 2-0:1.0: hub_suspend
[14316048.733955] usb usb2: bus suspend
[14316048.737675] ohci_hcd 0000:00:02.0: suspend root hub
[14316048.742965] hub 1-0:1.0: hub_suspend
[14316048.749629] usb usb1: bus suspend
[14316048.751176] ehci_hcd 0000:00:02.1: suspend root hub
[14316048.755970] sd 0:0:0:0: [sda] Synchronizing SCSI cache
[14316048.762812] sd 0:0:0:0: [sda] Stopping disk
[14316049.190010] ACPI: PCI interrupt for device 0000:01:08.0 disabled
[14316049.196537] ACPI handle has no context!
[14316049.253289] ACPI: PCI interrupt for device 0000:00:06.1 disabled
[14316049.273115] ACPI: PCI interrupt for device 0000:00:05.2 disabled
[14316049.289891] ACPI: PCI interrupt for device 0000:00:05.1 disabled
[14316049.306511] ACPI: PCI interrupt for device 0000:00:05.0 disabled
[14316049.323158] ata8: port disabled. ignoring.
[14316049.337876] ACPI: PCI interrupt for device 0000:00:02.1 disabled
[14316049.356406] ehci_hcd 0000:00:02.1: --> PCI D3/wakeup
[14316049.358672] ACPI: PCI interrupt for device 0000:00:02.0 disabled
[14316049.378443] ohci_hcd 0000:00:02.0: --> PCI D3/wakeup
[14316049.382302] ACPI: Preparing to enter system sleep state S4
[14316049.392357] Extended CMOS year: 2000
[14316049.393306]  hwsleep-0324 [03] enter_sleep_state     : Entering s=
leep state [S4]
[    0.000000] Command line: root=3D/dev/sda5 resume=3D/dev/sda6 vga=3D=
6 apic=3Dverbose console=3DttyS0,115200 console=3Dtty0 pci=3Dnomsi no_c=
onsole_suspend ro
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
[    0.000000]  BIOS-e820: 000000000009f800 - 00000000000a0000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserve=
d)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000007fee0000 (usable)
[    0.000000]  BIOS-e820: 000000007fee0000 - 000000007fee3000 (ACPI NV=
S)
[    0.000000]  BIOS-e820: 000000007fee3000 - 000000007fef0000 (ACPI da=
ta)
[    0.000000]  BIOS-e820: 000000007fef0000 - 000000007ff00000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000f0000000 - 00000000f4000000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000fec00000 - 0000000100000000 (reserve=
d)
[    0.000000] max_pfn_mapped =3D 1048576
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x70106=
00070106
[    0.000000] init_memory_mapping
[    0.000000] DMI 2.4 present.
[    0.000000] ACPI: RSDP 000F7D20, 0024 (r2 Nvidia)
[    0.000000] ACPI: XSDT 7FEE3100, 004C (r1 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: FACP 7FEEADC0, 00F4 (r3 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: DSDT 7FEE3280, 7ACE (r1 NVIDIA AWRDACPI     1000 M=
SFT  3000000)
[    0.000000] ACPI: FACS 7FEE0000, 0040
[    0.000000] ACPI: SSDT 7FEEB000, 0136 (r1 PTLTD  POWERNOW        1  =
LTP        1)
[    0.000000] ACPI: HPET 7FEEB180, 0038 (r1 Nvidia ASUSACPI 42302E31 A=
WRD       98)
[    0.000000] ACPI: MCFG 7FEEB200, 003C (r1 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000] ACPI: APIC 7FEEAF00, 0098 (r1 Nvidia ASUSACPI 42302E31 A=
WRD        0)
[    0.000000]   early res: 0 [0-fff] BIOS data page
[    0.000000]   early res: 1 [6000-7fff] TRAMPOLINE
[    0.000000]   early res: 2 [200000-d3638f] TEXT DATA BSS
[    0.000000]   early res: 3 [9f800-fffff] BIOS reserved
[    0.000000]   early res: 4 [8000-bfff] PGTABLE
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA             0 ->     4096
[    0.000000]   DMA32        4096 ->  1048576
[    0.000000]   Normal    1048576 ->  1048576
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     0:        0 ->      159
[    0.000000]     0:      256 ->   524000
[    0.000000] Detected use of extended apic ids on hypertransport bus
[    0.000000] ACPI: PM-Timer IO Port: 0x1008
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x03] disabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x03] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x04] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 4, version 0, address 0xfec00000, GSI=
 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high lev=
el)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 14 global_irq 14 high e=
dge)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 15 global_irq 15 high e=
dge)
[    0.000000] Setting APIC routing to flat
[    0.000000] ACPI: HPET id: 0x10de8201 base: 0xfefff000
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
[    0.000000] mapped IOAPIC to ffffffffff5fa000 (00000000fec00000)
[    0.000000] PM: Registered nosave memory: 000000000009f000 - 0000000=
0000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 0000000=
0000f0000
[    0.000000] PM: Registered nosave memory: 00000000000f0000 - 0000000=
000100000
[    0.000000] Allocating PCI resources starting at 80000000 (gap: 7ff0=
0000:70100000)
[14315324.233334] Built 1 zonelists in Zone order, mobility grouping on=
=2E  Total pages: 513763
[14315324.233334] Kernel command line: root=3D/dev/sda5 resume=3D/dev/s=
da6 vga=3D6 apic=3Dverbose console=3DttyS0,115200 console=3Dtty0 pci=3D=
nomsi no_console_suspend ro
[14315324.233334] Initializing CPU#0
[14315324.233334] PID hash table entries: 4096 (order: 12, 32768 bytes)
[14315324.233334] Extended CMOS year: 2000
[14315324.233334] TSC calibrated against PM_TIMER
[14315324.233334] time.c: Detected 2411.099 MHz processor.
[14315324.233334] Console: colour VGA+ 80x60
[14315324.233334] console [tty0] enabled
[14315324.233334] console [ttyS0] enabled
[14315324.233334] Lock dependency validator: Copyright (c) 2006 Red Hat=
, Inc., Ingo Molnar
[14315324.233334] ... MAX_LOCKDEP_SUBCLASSES:    8
[14315324.233334] ... MAX_LOCK_DEPTH:          48
[14315324.233334] ... MAX_LOCKDEP_KEYS:        2048
[14315324.233334] ... CLASSHASH_SIZE:           1024
[14315324.233334] ... MAX_LOCKDEP_ENTRIES:     8192
[14315324.233334] ... MAX_LOCKDEP_CHAINS:      16384
[14315324.233334] ... CHAINHASH_SIZE:          8192
[14315324.233334]  memory used by lock dependency info: 1648 kB
[14315324.233334]  per task-struct memory footprint: 2688 bytes
[14315324.233334] Dentry cache hash table entries: 262144 (order: 9, 20=
97152 bytes)
[14315324.233334] Inode-cache hash table entries: 131072 (order: 8, 104=
8576 bytes)
[14315324.233334] Checking aperture...
[14315324.233334] Node 0: aperture @ 89c000000 size 32 MB
[14315324.233334] Aperture beyond 4GB. Ignoring.
[14315324.233334] No AGP bridge found
[14315324.233334] Memory: 2051692k/2096000k available (4624k kernel cod=
e, 43544k reserved, 2268k data, 260k init)
[14315324.316528] Calibrating delay using timer specific routine.. 4827=
=2E00 BogoMIPS (lpj=3D8043205)
[14315324.322857] Mount-cache hash table entries: 256
[14315324.327216] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64=
 bytes/line)
[14315324.333327] CPU: L2 Cache: 512K (64 bytes/line)
[14315324.336660] CPU: AMD Athlon(tm) 64 Processor 3800+ stepping 01
[14315324.342949] ACPI: Core revision 20080321
[14315324.359992] Parsing all Control Methods:
[14315324.364011] Table [DSDT](id 0001) - 1203 Objects with 101 Devices=
 380 Methods 44 Regions
[14315324.369992] Parsing all Control Methods:
[14315324.373967] Table [SSDT](id 0002) - 4 Objects with 0 Devices 0 Me=
thods 0 Regions
[14315324.379991]  tbxface-0598 [02] tb_load_namespace     : ACPI Table=
s successfully acquired
[14315324.389990] evxfevnt-0091 [02] enable                : Transition=
 to ACPI mode successful
[14315324.398902] enabled ExtINT on CPU#0
[14315324.402995] ENABLING IO-APIC IRQs
[14315324.406656] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 =
pin2=3D-1
[14315324.442963] Using local APIC timer interrupts.
[14315324.449986] Detected 12.557 MHz APIC timer.
[14315324.453320] net_namespace: 1272 bytes
[14315324.456653] NET: Registered protocol family 16
[14315324.460264] No dock devices found.
[14315324.464193] TOM: 0000000080000000 aka 2048M
[14315324.468794] ACPI: bus type pci registered
[14315324.473293] PCI: Using configuration type 1 for base access
[14315324.481638] evgpeblk-0956 [04] ev_create_gpe_block   : GPE 00 to =
1F [_GPE] 4 regs on int 0x9
[14315324.490697] evgpeblk-0956 [04] ev_create_gpe_block   : GPE 20 to =
5F [_GPE] 8 regs on int 0x9
[14315324.509805] Completing Region/Field/Buffer/Package initialization=
:......................................................................=
=2E....................................................................=
=2E.......................................
[14315324.545438] Initialized 39/44 Regions 11/11 Fields 40/40 Buffers =
89/101 Packages (1216 nodes)
[14315324.549980] Initializing Device/Processor/Thermal objects by exec=
uting _INI methods:...
[14315324.556256] Executed 3 _INI methods requiring 1 _STA executions (=
examined 108 objects)
[14315324.559979] evgpeblk-1052 [03] ev_initialize_gpe_bloc: Found 9 Wa=
ke, Enabled 0 Runtime GPEs in this block
[14315324.569979] evgpeblk-1052 [03] ev_initialize_gpe_bloc: Found 0 Wa=
ke, Enabled 1 Runtime GPEs in this block
[14315324.579978] ACPI: Interpreter enabled
[14315324.583311] ACPI: (supports S0 S1 S3 S4 S5)
[14315324.587956] ACPI: Using IOAPIC for interrupt routing
[14315324.615461] ACPI: PCI Root Bridge [PCI0] (0000:00)
[14315324.619975] PCI: Transparent bridge - 0000:00:06.0
[14315324.713902] ACPI: PCI Interrupt Link [LNK1] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.722705] ACPI: PCI Interrupt Link [LNK2] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.728225] ACPI: PCI Interrupt Link [LNK3] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.735728] ACPI: PCI Interrupt Link [LNK4] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.741552] ACPI: PCI Interrupt Link [LNK5] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.750170] ACPI: PCI Interrupt Link [LNK6] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.758961] ACPI: PCI Interrupt Link [LNK7] (IRQs 5 7 9 10 *11 14=
 15)
[14315324.763301] ACPI: PCI Interrupt Link [LNK8] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.768606] ACPI: PCI Interrupt Link [LP2P] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.777265] ACPI: PCI Interrupt Link [LUBA] (IRQs 5 7 9 10 *11 14=
 15)
[14315324.784756] ACPI: PCI Interrupt Link [LMAC] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.792248] ACPI: PCI Interrupt Link [LMC1] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.796634] ACPI: PCI Interrupt Link [LAZA] (IRQs *5 7 9 10 11 14=
 15)
[14315324.800688] ACPI: PCI Interrupt Link [LPMU] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.809481] ACPI: PCI Interrupt Link [LSMB] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.813830] ACPI: PCI Interrupt Link [LUB2] (IRQs *5 7 9 10 11 14=
 15)
[14315324.821293] ACPI: PCI Interrupt Link [LIDE] (IRQs 5 7 9 10 11 14 =
15) *0, disabled.
[14315324.829952] ACPI: PCI Interrupt Link [LSID] (IRQs *5 7 9 10 11 14=
 15)
[14315324.834335] ACPI: PCI Interrupt Link [LFID] (IRQs 5 7 9 *10 11 14=
 15)
[14315324.841605] ACPI: PCI Interrupt Link [LSA2] (IRQs 5 7 9 10 *11 14=
 15)
[14315324.849224] ACPI: PCI Interrupt Link [APC1] (IRQs 16) *0, disable=
d.
[14315324.853301] ACPI: PCI Interrupt Link [APC2] (IRQs 17) *0, disable=
d.
[14315324.857248] ACPI: PCI Interrupt Link [APC3] (IRQs 18) *0
[14315324.863512] ACPI: PCI Interrupt Link [APC4] (IRQs 19) *0, disable=
d.
[14315324.870578] ACPI: PCI Interrupt Link [APC5] (IRQs 16) *0, disable=
d.
[14315324.877826] ACPI: PCI Interrupt Link [APC6] (IRQs 16) *0, disable=
d.
[14315324.885076] ACPI: PCI Interrupt Link [APC7] (IRQs 16) *0
[14315324.889968] ACPI: PCI Interrupt Link [APC8] (IRQs 16) *0, disable=
d.
[14315324.895428] ACPI: PCI Interrupt Link [APCF] (IRQs 20 21 22 23) *0
[14315324.899968] ACPI: PCI Interrupt Link [APCH] (IRQs 20 21 22 23) *0
[14315324.903301] ACPI: PCI Interrupt Link [AMC1] (IRQs 20 21 22 23) *0
[14315324.907248] ACPI: PCI Interrupt Link [APMU] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.915381] ACPI: PCI Interrupt Link [AAZA] (IRQs 20 21 22 23) *0
[14315324.919968] ACPI: PCI Interrupt Link [APCS] (IRQs 20 21 22 23) *0
[14315324.923301] ACPI: PCI Interrupt Link [APCL] (IRQs 20 21 22 23) *0
[14315324.927248] ACPI: PCI Interrupt Link [APCM] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.934992] ACPI: PCI Interrupt Link [APCZ] (IRQs 20 21 22 23) *0=
, disabled.
[14315324.943228] ACPI: PCI Interrupt Link [APSI] (IRQs 20 21 22 23) *0
[14315324.947246] ACPI: PCI Interrupt Link [APSJ] (IRQs 20 21 22 23) *0
[14315324.954299] ACPI: PCI Interrupt Link [ASA2] (IRQs 20 21 22 23) *0
[14315324.961381] Linux Plug and Play Support v0.97 (c) Adam Belay
[14315324.966635] pnp: PnP ACPI init
[14315324.969968] ACPI: bus type pnp registered
[14315324.982451] pnp: PnP ACPI: found 13 devices
[14315324.986635] ACPI: ACPI bus type pnp unregistered
[14315324.989968] SCSI subsystem initialized
[14315324.993332] usbcore: registered new interface driver usbfs
[14315324.999240] usbcore: registered new interface driver hub
[14315325.003301] usbcore: registered new device driver usb
[14315325.006635] PCI: Using ACPI for IRQ routing
[14315325.009968] testing the IO APIC.......................
[14315325.013301]=20
[14315325.013301] .................................... done.
[14315325.027803] Bluetooth: Core ver 2.11
[14315325.031935] NET: Registered protocol family 31
[14315325.036635] Bluetooth: HCI device and connection manager initiali=
zed
[14315325.039968] Bluetooth: HCI socket layer initialized
[14315325.043301] DMAR:parse DMAR table failure.
[14315325.054041] system 00:01: ioport range 0x1000-0x107f has been res=
erved
[14315325.060937] system 00:01: ioport range 0x1080-0x10ff has been res=
erved
[14315325.067822] system 00:01: ioport range 0x1400-0x147f has been res=
erved
[14315325.074710] system 00:01: ioport range 0x1480-0x14ff has been res=
erved
[14315325.081595] system 00:01: ioport range 0x1800-0x187f has been res=
erved
[14315325.088483] system 00:01: ioport range 0x1880-0x18ff has been res=
erved
[14315325.095381] system 00:02: ioport range 0x4d0-0x4d1 has been reser=
ved
[14315325.102093] system 00:02: ioport range 0x800-0x87f has been reser=
ved
[14315325.108807] system 00:02: ioport range 0x290-0x297 has been reser=
ved
[14315325.115543] system 00:0b: iomem range 0xf0000000-0xf3ffffff could=
 not be reserved
[14315325.123491] system 00:0c: iomem range 0xcd000-0xcffff has been re=
served
[14315325.130464] system 00:0c: iomem range 0xf0000-0xf7fff could not b=
e reserved
[14315325.139923] system 00:0c: iomem range 0xf8000-0xfbfff could not b=
e reserved
[14315325.147328] system 00:0c: iomem range 0xfc000-0xfffff could not b=
e reserved
[14315325.154735] system 00:0c: iomem range 0xfefff000-0xfefff0ff could=
 not be reserved
[14315325.162659] system 00:0c: iomem range 0x7fee0000-0x7fefffff could=
 not be reserved
[14315325.170116] system 00:0c: iomem range 0xffff0000-0xffffffff could=
 not be reserved
[14315325.178043] system 00:0c: iomem range 0x0-0x9ffff could not be re=
served
[14315325.185017] system 00:0c: iomem range 0x100000-0x7fedffff could n=
ot be reserved
[14315325.199647] system 00:0c: iomem range 0xfec00000-0xfec00fff could=
 not be reserved
[14315325.206708] system 00:0c: iomem range 0xfee00000-0xfeefffff could=
 not be reserved
[14315325.214634] system 00:0c: iomem range 0xfefff000-0xfeffffff could=
 not be reserved
[14315325.222585] system 00:0c: iomem range 0xfff80000-0xfff80fff could=
 not be reserved
[14315325.230510] system 00:0c: iomem range 0xfff90000-0xfffbffff could=
 not be reserved
[14315325.238441] system 00:0c: iomem range 0xfffed000-0xfffeffff could=
 not be reserved
[14315325.247394] PCI: Bridge: 0000:00:06.0
[14315325.251018]   IO window: 9000-9fff
[14315325.254790]   MEM window: disabled.
[14315325.259831]   PREFETCH window: disabled.
[14315325.263697] PCI: Bridge: 0000:00:0a.0
[14315325.267727]   IO window: 8000-8fff
[14315325.271501]   MEM window: 0xfde00000-0xfdefffff
[14315325.276395]   PREFETCH window: 0x00000000e8000000-0x00000000effff=
fff
[14315325.283110] PCI: Bridge: 0000:00:0e.0
[14315325.287142]   IO window: 6000-7fff
[14315325.290913]   MEM window: 0xfdd00000-0xfddfffff
[14315325.295811]   PREFETCH window: disabled.
[14315325.300178] NET: Registered protocol family 2
[14315325.335996] IP route cache hash table entries: 65536 (order: 7, 5=
24288 bytes)
[14315325.344142] TCP established hash table entries: 262144 (order: 10=
, 4194304 bytes)
[14315325.353337] TCP bind hash table entries: 65536 (order: 9, 3670016=
 bytes)
[14315325.365827] TCP: Hash tables configured (established 262144 bind =
65536)
[14315325.372834] TCP reno registered
[14315325.385835] NET: Registered protocol family 1
[14315325.392305] Installing knfsd (copyright (C) 1996 okir@monad.swb.d=
e).
[14315325.399441] JFFS2 version 2.2. (NAND) =C3=82=C2=A9 2001-2006 Red =
Hat, Inc.
[14315325.405968] fuse init (API version 7.9)
[14315325.410326] SGI XFS with security attributes, large block/inode n=
umbers, no debug enabled
[14315325.419254] msgmni has been set to 4007 for ipc namespace fffffff=
f808882f0
[14315325.426697] Block layer SCSI generic (bsg) driver version 0.4 loa=
ded (major 254)
[14315325.434550] io scheduler noop registered
[14315325.439766] io scheduler anticipatory registered
[14315325.444075] io scheduler deadline registered
[14315325.449091] io scheduler cfq registered (default)
[14315325.466344] pci 0000:00:05.0: Enabling HT MSI Mapping
[14315325.471799] pci 0000:00:05.1: Enabling HT MSI Mapping
[14315325.476916] pci 0000:00:05.2: Enabling HT MSI Mapping
[14315325.482372] pci 0000:00:06.0: Enabling HT MSI Mapping
[14315325.487809] pci 0000:00:06.1: Enabling HT MSI Mapping
[14315325.493262] pci 0000:00:08.0: Enabling HT MSI Mapping
[14315325.498703] pci 0000:00:09.0: Enabling HT MSI Mapping
[14315325.504135] pci 0000:00:0a.0: Enabling HT MSI Mapping
[14315325.509588] pci 0000:00:0e.0: Enabling HT MSI Mapping
[14315325.515287] assign_interrupt_mode Found MSI capability
[14315325.520606] assign_interrupt_mode Found MSI capability
[14315325.526881] input: Power Button (FF) as /class/input/input0
[14315325.532858] ACPI: Power Button (FF) [PWRF]
[14315325.537449] input: Power Button (CM) as /class/input/input1
[14315325.543390] ACPI: Power Button (CM) [PWRB]
[14315325.549458] ACPI: PNP0C0B:00 is registered as cooling_device0
[14315325.555580] ACPI: Fan [FAN] (on)
[14315325.559460] ACPI: ACPI0007:00 is registered as cooling_device1
[14315325.566720] ACPI: Expecting a [Reference] package element, found =
type 0
[14315325.574102] ACPI: LNXTHERM:01 is registered as thermal_zone0
[14315325.580563] ACPI: Thermal Zone [THRM] (40 C)
[14315325.603595] Real Time Clock Driver v1.12ac
[14315325.608075] Linux agpgart interface v0.103
[14315325.612547] Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, =
IRQ sharing disabled
[14315325.622760] serial8250: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550=
A
[14315325.630102] 00:09: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
[14315325.637596] loop: module loaded
[14315325.641032] e1000e: Intel(R) PRO/1000 Network Driver - 0.3.3.3-k2
[14315325.647514] e1000e: Copyright (c) 1999-2008 Intel Corporation.
[14315325.653829] e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
[14315325.660284] e100: Copyright(c) 1999-2006 Intel Corporation
[14315325.666293] tun: Universal TUN/TAP device driver, 1.6
[14315325.671712] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com=
>
[14315325.678480] Driver 'sd' needs updating - please use bus_type meth=
ods
[14315325.685243] Driver 'sr' needs updating - please use bus_type meth=
ods
[14315325.692949] ACPI: PCI Interrupt Link [APSI] enabled at IRQ 23
[14315325.699077] ACPI: PCI Interrupt 0000:00:05.0[A] -> Link [APSI] ->=
 GSI 23 (level, low) -> IRQ 23
[14315325.708827] sata_nv 0000:00:05.0: Using SWNCQ mode
[14315325.714123] scsi0 : sata_nv
[14315325.717541] scsi1 : sata_nv
[14315325.721110] ata1: SATA max UDMA/133 cmd 0x9f0 ctl 0xbf0 bmdma 0xd=
c00 irq 23
[14315325.729217] ata2: SATA max UDMA/133 cmd 0x970 ctl 0xb70 bmdma 0xd=
c08 irq 23
[14315326.206695] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300=
)
[14315326.220214] ata1.00: ATA-8: SAMSUNG HD501LJ, CR100-12, max UDMA7
[14315326.226587] ata1.00: 976773168 sectors, multi 1: LBA48 NCQ (depth=
 31/32)
[14315326.240521] ata1.00: configured for UDMA/133
[14315326.573691] ata2: SATA link down (SStatus 0 SControl 300)
[14315326.592889] isa bounce pool size: 16 pages
[14315326.596955] scsi 0:0:0:0: Direct-Access     ATA      SAMSUNG HD50=
1LJ  CR10 PQ: 0 ANSI: 5
[14315326.606007] sd 0:0:0:0: [sda] 976773168 512-byte hardware sectors=
 (500108 MB)
[14315326.613434] sd 0:0:0:0: [sda] Write Protect is off
[14315326.618637] sd 0:0:0:0: [sda] Write cache: enabled, read cache: e=
nabled, doesn't support DPO or FUA
[14315326.627081] sd 0:0:0:0: [sda] 976773168 512-byte hardware sectors=
 (500108 MB)
[14315326.636275] sd 0:0:0:0: [sda] Write Protect is off
[14315326.640928] sd 0:0:0:0: [sda] Write cache: enabled, read cache: e=
nabled, doesn't support DPO or FUA
[14315326.650427]  sda: sda1 sda2 sda3 sda4 < sda5 sda6 sda7 >
[14315326.740003] sd 0:0:0:0: [sda] Attached SCSI disk
[14315326.748229] sd 0:0:0:0: Attached scsi generic sg0 type 0
[14315326.755781] ACPI: PCI Interrupt Link [APSJ] enabled at IRQ 22
[14315326.761936] ACPI: PCI Interrupt 0000:00:05.1[B] -> Link [APSJ] ->=
 GSI 22 (level, low) -> IRQ 22
[14315326.772452] sata_nv 0000:00:05.1: Using SWNCQ mode
[14315326.777683] scsi2 : sata_nv
[14315326.781028] scsi3 : sata_nv
[14315326.784603] ata3: SATA max UDMA/133 cmd 0x9e0 ctl 0xbe0 bmdma 0xc=
800 irq 22
[14315326.792706] ata4: SATA max UDMA/133 cmd 0x960 ctl 0xb60 bmdma 0xc=
808 irq 22
[14315327.127025] ata3: SATA link down (SStatus 0 SControl 300)
[14315327.473691] ata4: SATA link down (SStatus 0 SControl 300)
[14315327.493337] ACPI: PCI Interrupt Link [ASA2] enabled at IRQ 21
[14315327.499341] ACPI: PCI Interrupt 0000:00:05.2[C] -> Link [ASA2] ->=
 GSI 21 (level, low) -> IRQ 21
[14315327.507738] sata_nv 0000:00:05.2: Using SWNCQ mode
[14315327.513425] scsi4 : sata_nv
[14315327.516781] scsi5 : sata_nv
[14315327.520348] ata5: SATA max UDMA/133 cmd 0xc400 ctl 0xc000 bmdma 0=
xb400 irq 21
[14315327.527925] ata6: SATA max UDMA/133 cmd 0xbc00 ctl 0xb800 bmdma 0=
xb408 irq 21
[14315327.863749] ata5: SATA link down (SStatus 0 SControl 300)
[14315328.353361] ata6: SATA link up 1.5 Gbps (SStatus 113 SControl 300=
)
[14315328.383444] ata6.00: ATAPI: TSSTcorp CDDVDW SH-S203B, SB00, max U=
DMA/100
[14315328.436778] ata6.00: configured for UDMA/100
[14315328.476668] scsi 5:0:0:0: CD-ROM            TSSTcorp CDDVDW SH-S2=
03B  SB00 PQ: 0 ANSI: 5
[14315328.600002] sr0: scsi3-mmc drive: 125x/48x writer dvd-ram cd/rw x=
a/form2 cdda tray
[14315328.642296] Uniform CD-ROM driver Revision: 3.20
[14315328.649446] sr 5:0:0:0: Attached scsi generic sg1 type 5
[14315328.659784] block2mtd: version $Revision: 1.30 $
[14315328.667052] ACPI: PCI Interrupt Link [APCL] enabled at IRQ 20
[14315328.673194] ACPI: PCI Interrupt 0000:00:02.1[B] -> Link [APCL] ->=
 GSI 20 (level, low) -> IRQ 20
[14315328.682802] ehci_hcd 0000:00:02.1: EHCI Host Controller
[14315328.689317] ehci_hcd 0000:00:02.1: new USB bus registered, assign=
ed bus number 1
[14315328.696829] ehci_hcd 0000:00:02.1: debug port 1
[14315328.702248] ehci_hcd 0000:00:02.1: irq 20, io mem 0xfe02e000
[14315328.716567] ehci_hcd 0000:00:02.1: USB 2.0 started, EHCI 1.00, dr=
iver 10 Dec 2004
[14315328.723891] usb usb1: configuration #1 chosen from 1 choice
[14315328.730025] hub 1-0:1.0: USB hub found
[14315328.734185] hub 1-0:1.0: 10 ports detected
[14315328.840224] usb usb1: New USB device found, idVendor=3D1d6b, idPr=
oduct=3D0002
[14315328.847386] usb usb1: New USB device strings: Mfr=3D3, Product=3D=
2, SerialNumber=3D1
[14315328.855061] usb usb1: Product: EHCI Host Controller
[14315328.861727] usb usb1: Manufacturer: Linux 2.6.26-rc4 ehci_hcd
[14315328.866980] usb usb1: SerialNumber: 0000:00:02.1
[14315328.873993] ACPI: PCI Interrupt Link [APCF] enabled at IRQ 23
[14315328.880101] ACPI: PCI Interrupt 0000:00:02.0[A] -> Link [APCF] ->=
 GSI 23 (level, low) -> IRQ 23
[14315328.889364] ohci_hcd 0000:00:02.0: OHCI Host Controller
[14315328.896669] ohci_hcd 0000:00:02.0: new USB bus registered, assign=
ed bus number 2
[14315328.903383] ohci_hcd 0000:00:02.0: irq 23, io mem 0xfe02f000
[14315328.962374] usb usb2: configuration #1 chosen from 1 choice
[14315328.968432] hub 2-0:1.0: USB hub found
[14315328.972586] hub 2-0:1.0: 10 ports detected
[14315329.050071] hub 1-0:1.0: unable to enumerate USB device on port 1
[14315329.083321] usb usb2: New USB device found, idVendor=3D1d6b, idPr=
oduct=3D0001
[14315329.090008] usb usb2: New USB device strings: Mfr=3D3, Product=3D=
2, SerialNumber=3D1
[14315329.097286] usb usb2: Product: OHCI Host Controller
[14315329.102530] usb usb2: Manufacturer: Linux 2.6.26-rc4 ohci_hcd
[14315329.106885] usb usb2: SerialNumber: 0000:00:02.0
[14315329.113130] USB Universal Host Controller Interface driver v3.0
[14315329.253357] hub 1-0:1.0: unable to enumerate USB device on port 3
[14315329.430023] hub 1-0:1.0: unable to enumerate USB device on port 4
[14315329.436621] usbcore: registered new interface driver usblp
[14315329.443451] PNP: No PS/2 controller found. Probing ports directly=
=2E
[14315329.450472] serio: i8042 KBD port at 0x60,0x64 irq 1
[14315329.456021] serio: i8042 AUX port at 0x60,0x64 irq 12
[14315329.462037] mice: PS/2 mouse device common for all mice
[14315329.486561] i2c /dev entries driver
[14315329.490643] i2c-adapter i2c-0: nForce2 SMBus adapter at 0x1c00
[14315329.496959] i2c-adapter i2c-1: nForce2 SMBus adapter at 0x1c40
[14315329.503281] it87: Found IT8716F chip at 0x290, revision 0
[14315329.507267] it87: in3 is VCC (+5V)
[14315329.513179] it87: in7 is VCCH (+5V Stand-By)
[14315329.543335] md: raid1 personality registered for level 1
[14315329.550473] device-mapper: ioctl: 4.13.0-ioctl (2007-10-18) initi=
alised: dm-devel@redhat.com
[14315329.559489] Bluetooth: HCI USB driver ver 2.9
[14315329.716679] usb 2-1: new low speed USB device using ohci_hcd and =
address 2
[14315329.903359] usb 2-1: configuration #1 chosen from 1 choice
[14315329.926669] usb 2-1: New USB device found, idVendor=3D045e, idPro=
duct=3D0040
[14315329.933351] usb 2-1: New USB device strings: Mfr=3D1, Product=3D3=
, SerialNumber=3D0
[14315329.940927] usb 2-1: Product: Microsoft 3-Button Mouse with Intel=
liEye(TM)
[14315329.949952] usb 2-1: Manufacturer: Microsoft
[14315330.230013] usb 2-3: new low speed USB device using ohci_hcd and =
address 3
[14315330.423345] usb 2-3: configuration #1 chosen from 1 choice
[14315330.460003] usb 2-3: New USB device found, idVendor=3D045e, idPro=
duct=3D00db
[14315330.466683] usb 2-3: New USB device strings: Mfr=3D1, Product=3D2=
, SerialNumber=3D0
[14315330.474261] usb 2-3: Product: Natural=C2=AE Ergonomic Keyboard 40=
00
[14315330.480453] usb 2-3: Manufacturer: Microsoft
[14315330.763344] usb 2-4: new full speed USB device using ohci_hcd and=
 address 4
[14315330.936678] usb 2-4: device descriptor read/64, error -62
[14315331.210011] usb 2-4: device descriptor read/64, error -62
[14315331.476678] usb 2-4: new full speed USB device using ohci_hcd and=
 address 5
[14315331.650011] usb 2-4: device descriptor read/64, error -62
[14315331.923344] usb 2-4: device descriptor read/64, error -62
[14315332.190011] usb 2-4: new full speed USB device using ohci_hcd and=
 address 6
[14315332.603341] usb 2-4: device not accepting address 6, error -62
[14315332.766677] usb 2-4: new full speed USB device using ohci_hcd and=
 address 7
[14315333.180008] usb 2-4: device not accepting address 7, error -62
[14315333.186213] hub 2-0:1.0: unable to enumerate USB device on port 4
[14315333.193008] usbcore: registered new interface driver hci_usb
[14315333.199346] Bluetooth: HCI UART driver ver 2.2
[14315333.205504] Bluetooth: HCI H4 protocol initialized
[14315333.210322] Bluetooth: HCI BCSP protocol initialized
[14315333.215671] cpuidle: using governor ladder
[14315333.220135] cpuidle: using governor menu
[14315333.230002] input: Microsoft Microsoft 3-Button Mouse with Intell=
iEye(TM) as /class/input/input2
[14315333.261274] input: USB HID v1.10 Mouse [Microsoft Microsoft 3-But=
ton Mouse with IntelliEye(TM)] on usb-0000:00:02.0-1
[14315333.280007] input: Microsoft Natural=C2=AE Ergonomic Keyboard 400=
0 as /class/input/input3
[14315333.314087] input: USB HID v1.11 Keyboard [Microsoft Natural=C2=AE=
 Ergonomic Keyboard 4000] on usb-0000:00:02.0-3
[14315333.336668] input: Microsoft Natural=C2=AE Ergonomic Keyboard 400=
0 as /class/input/input4
[14315333.370899] input: USB HID v1.11 Device [Microsoft Natural=C2=AE =
Ergonomic Keyboard 4000] on usb-0000:00:02.0-3
[14315333.381147] usbcore: registered new interface driver usbhid
[14315333.386945] usbhid: v2.6:USB HID core driver
[14315333.393085] Advanced Linux Sound Architecture Driver Version 1.0.=
16.
[14315333.400869] ALSA device list:
[14315333.404208]   No soundcards found.
[14315333.408145] GACT probability on
[14315333.411653] Mirror/redirect action on
[14315333.416853] u32 classifier
[14315333.419931]     Performance counters on
[14315333.421542]     input device check on=20
[14315333.425661]     Actions configured=20
[14315333.433116] IPv4 over IPv4 tunneling driver
[14315333.437304] ip_tables: (C) 2000-2006 Netfilter Core Team
[14315333.443091] TCP bic registered
[14315333.446522] TCP cubic registered
[14315333.450115] TCP westwood registered
[14315333.453967] TCP htcp registered
[14315333.457479] TCP vegas registered
[14315333.461077] TCP yeah registered
[14315333.464582] Initializing XFRM netlink socket
[14315333.469529] NET: Registered protocol family 10
[14315333.476669] IPv6 over IPv4 tunneling driver
[14315333.483336] NET: Registered protocol family 17
[14315333.490002] NET: Registered protocol family 15
[14315333.493450] Bridge firewalling registered
[14315333.497860] Bluetooth: L2CAP ver 2.9
[14315333.501800] Bluetooth: L2CAP socket layer initialized
[14315333.507218] Bluetooth: SCO (Voice Link) ver 0.5
[14315333.512112] Bluetooth: SCO socket layer initialized
[14315333.517037] Bluetooth: RFCOMM socket layer initialized
[14315333.522549] Bluetooth: RFCOMM TTY layer initialized
[14315333.527800] Bluetooth: RFCOMM ver 1.8
[14315333.533062] Bluetooth: BNEP (Ethernet Emulation) ver 1.2
[14315333.537101] Bluetooth: HIDP (Human Interface Emulation) ver 1.2
[14315333.543695] RPC: Registered udp transport module.
[14315333.549077] RPC: Registered tcp transport module.
[14315333.554204] 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelat=
ech.com>
[14315333.562880] All bugs added by David S. Miller <davem@redhat.com>
[14315333.566792] powernow-k8: Found 1 AMD Athlon(tm) 64 Processor 3800=
+ processors (1 cpu cores) (version 2.20.00)
[14315333.579955] powernow-k8:    0 : fid 0x10 (2400 MHz), vid 0x8
[14315333.583538] powernow-k8:    1 : fid 0xe (2200 MHz), vid 0xa
[14315333.589709] powernow-k8:    2 : fid 0xc (2000 MHz), vid 0xc
[14315333.602320] powernow-k8:    3 : fid 0xa (1800 MHz), vid 0xe
[14315333.608255] powernow-k8:    4 : fid 0x2 (1000 MHz), vid 0x12
[14315333.620496] Freezing user space processes ... (elapsed 0.00 secon=
ds) done.
[14315333.629026] Freezing remaining freezable tasks ... (elapsed 0.00 =
seconds) done.
[14315333.637034] PM: Loading image data pages (82589 pages) ...     =08=
=08=08=08  0%=08=08=08=08  1%=08=08=08=08  2%=08=08=08=08  3%=08=08=08=08=
  4%=08=08=08=08  5%=08=08=08=08  6%=08=08=08=08  7%=08=08=08=08  8%=08=
=08=08=08  9%=08=08=08=08 10%=08=08=08=08 11%=08=08=08=08 12%=08=08=08=08=
 13%=08=08=08=08 14%=08=08=08=08 15%=08=08=08=08 16%=08=08=08=08 17%=08=
=08=08=08 18%=08=08=08=08 19%=08=08=08=08 20%=08=08=08=08 21%=08=08=08=08=
 22%=08=08=08=08 23%=08=08=08=08 24%=08=08=08=08 25%=08=08=08=08 26%=08=
=08=08=08 27%=08=08=08=08 28%=08=08=08=08 29%=08=08=08=08 30%=08=08=08=08=
 31%Marking TSC unstable due to cpufreq changes
[14315335.330662] =08=08=08=08 32%=08=08=08=08 33%=08=08=08=08 34%=08=08=
=08=08 35%=08=08=08=08 36%=08=08=08=08 37%=08=08=08=08 38%=08=08=08=08 =
39%=08=08=08=08 40%<4>Clocksource tsc unstable (delta =3D -248506648 ns=
)
[14315335.735245] =08=08=08=08 41%=08=08=08=08 42%=08=08=08=08 43%=08=08=
=08=08 44%=08=08=08=08 45%=08=08=08=08 46%=08=08=08=08 47%=08=08=08=08 =
48%=08=08=08=08 49%=08=08=08=08 50%=08=08=08=08 51%=08=08=08=08 52%=08=08=
=08=08 53%=08=08=08=08 54%=08=08=08=08 55%=08=08=08=08 56%=08=08=08=08 =
57%=08=08=08=08 58%=08=08=08=08 59%=08=08=08=08 60%=08=08=08=08 61%=08=08=
=08=08 62%=08=08=08=08 63%=08=08=08=08 64%=08=08=08=08 65%=08=08=08=08 =
66%=08=08=08=08 67%=08=08=08=08 68%=08=08=08=08 69%=08=08=08=08 70%=08=08=
=08=08 71%=08=08=08=08 72%=08=08=08=08 73%=08=08=08=08 74%=08=08=08=08 =
75%=08=08=08=08 76%=08=08=08=08 77%=08=08=08=08 78%=08=08=08=08 79%=08=08=
=08=08 80%=08=08=08=08 81%=08=08=08=08 82%=08=08=08=08 83%=08=08=08=08 =
84%=08=08=08=08 85%=08=08=08=08 86%=08=08=08=08 87%=08=08=08=08 88%=08=08=
=08=08 89%=08=08=08=08 90%=08=08=08=08 91%=08=08=08=08 92%=08=08=08=08 =
93%=08=08=08=08 94%=08=08=08=08 95%=08=08=08=08 96%=08=08=08=08 97%=08=08=
=08=08 98%=08=08=08=08 99%=08=08=08=08100%=08=08=08=08done
[14315338.320334] PM: Read 330356 kbytes in 4.68 seconds (70.58 MB/s)
[14315338.341762] sd 0:0:0:0: [sda] Synchronizing SCSI cache
[14315338.350008] ACPI: PCI interrupt for device 0000:00:05.2 disabled
[14315338.354161] ACPI: PCI interrupt for device 0000:00:05.1 disabled
[14315338.360826] ACPI: PCI interrupt for device 0000:00:05.0 disabled
[14315338.367267] ACPI: PCI interrupt for device 0000:00:02.0 disabled
[14315338.373860] Extended CMOS year: 2000
[14316042.953739] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x70=
10600070106
[14316042.953739] evxfevnt-0079 [02] enable                : System is =
already in ACPI mode
[14316042.953739] svm_cpu_init: svm_data is NULL on 0
[14316042.953739] Extended CMOS year: 2000
[14316042.978446] ACPI: Unable to turn cooling device [ffff81007f842f50=
] 'off'
[14316042.985081] ohci_hcd 0000:00:02.0: PCI legacy resume
[14316042.991683] ACPI: PCI Interrupt 0000:00:02.0[A] -> Link [APCF] ->=
 GSI 23 (level, low) -> IRQ 23
[14316043.000127] PCI: Setting latency timer of device 0000:00:02.0 to =
64
[14316043.006555] ohci_hcd 0000:00:02.0: lost power
[14316043.067239] ohci_hcd 0000:00:02.0: OHCI controller state
[14316043.073837] ohci_hcd 0000:00:02.0: OHCI 1.0, NO legacy support re=
gisters
[14316043.080939] ohci_hcd 0000:00:02.0: control 0x683 RWE RWC HCFS=3Do=
perational CBSR=3D3
[14316043.088830] ohci_hcd 0000:00:02.0: cmdstatus 0x00000 SOC=3D0
[14316043.095497] ohci_hcd 0000:00:02.0: intrstatus 0x00000044 RHSC SF
[14316043.101379] ohci_hcd 0000:00:02.0: intrenable 0x8000000a MIE RD W=
DH
[14316043.107788] ohci_hcd 0000:00:02.0: hcca frame #002d
[14316043.113060] ohci_hcd 0000:00:02.0: roothub.a 0100120a POTPGT=3D1 =
NOCP NPS NDP=3D10(10)
[14316043.123059] ohci_hcd 0000:00:02.0: roothub.b 00000000 PPCM=3D0000=
 DR=3D0000
[14316043.128132] ohci_hcd 0000:00:02.0: roothub.status 00008000 DRWE
[14316043.134800] ohci_hcd 0000:00:02.0: roothub.portstatus [0] 0x00010=
301 CSC LSDA PPS CCS
[14316043.142770] ohci_hcd 0000:00:02.0: roothub.portstatus [1] 0x00000=
100 PPS
[14316043.149876] ohci_hcd 0000:00:02.0: roothub.portstatus [2] 0x00010=
301 CSC LSDA PPS CCS
[14316043.159876] ohci_hcd 0000:00:02.0: roothub.portstatus [3] 0x00010=
101 CSC PPS CCS
[14316043.166081] ohci_hcd 0000:00:02.0: roothub.portstatus [4] 0x00000=
100 PPS
[14316043.173177] ohci_hcd 0000:00:02.0: roothub.portstatus [5] 0x00000=
100 PPS
[14316043.183177] ohci_hcd 0000:00:02.0: roothub.portstatus [6] 0x00000=
100 PPS
[14316043.187374] ohci_hcd 0000:00:02.0: roothub.portstatus [7] 0x00000=
100 PPS
[14316043.194471] ohci_hcd 0000:00:02.0: roothub.portstatus [8] 0x00000=
100 PPS
[14316043.201571] ohci_hcd 0000:00:02.0: roothub.portstatus [9] 0x00000=
100 PPS
[14316043.208667] ohci_hcd 0000:00:02.0: restart complete
[14316043.215334] usb usb2: root hub lost power or was reset
[14316043.219485] ohci_hcd 0000:00:02.0: suspend root hub
[14316043.226154] ehci_hcd 0000:00:02.1: PCI legacy resume
[14316043.231435] ACPI: PCI Interrupt 0000:00:02.1[B] -> Link [APCL] ->=
 GSI 20 (level, low) -> IRQ 20
[14316043.239441] PCI: Setting latency timer of device 0000:00:02.1 to =
64
[14316043.246120] ehci_hcd 0000:00:02.1: lost power, restarting
[14316043.252770] usb usb1: root hub lost power or was reset
[14316043.258599] ehci_hcd 0000:00:02.1: reset command 080b02 park=3D3 =
ithresh=3D8 period=3D1024 Reset HALT
[14316043.267470] ehci_hcd 0000:00:02.1: debug port 1
[14316043.271595] PCI: cache line size of 64 is not supported by device=
 0000:00:02.1
[14316043.279323] PCI: Setting latency timer of device 0000:00:04.0 to =
64
[14316043.294538] ata8: port disabled. ignoring.
[14316043.300828] PM: Writing back config space on device 0000:00:05.0 =
at offset 1 (was b00003, writing b00007)
[14316043.310929] ACPI: PCI Interrupt 0000:00:05.0[A] -> Link [APSI] ->=
 GSI 23 (level, low) -> IRQ 23
[14316043.320659] PCI: Setting latency timer of device 0000:00:05.0 to =
64
[14316043.327303] PM: Writing back config space on device 0000:00:05.1 =
at offset 1 (was b00003, writing b00007)
[14316043.338069] ACPI: PCI Interrupt 0000:00:05.1[B] -> Link [APSJ] ->=
 GSI 22 (level, low) -> IRQ 22
[14316043.347650] PCI: Setting latency timer of device 0000:00:05.1 to =
64
[14316043.354561] PM: Writing back config space on device 0000:00:05.2 =
at offset 1 (was b00003, writing b00007)
[14316043.365135] ACPI: PCI Interrupt 0000:00:05.2[C] -> Link [ASA2] ->=
 GSI 21 (level, low) -> IRQ 21
[14316043.374686] PCI: Setting latency timer of device 0000:00:05.2 to =
64
[14316043.381567] PCI: Setting latency timer of device 0000:00:06.0 to =
64
[14316043.399958] PM: Writing back config space on device 0000:00:06.1 =
at offset 1 (was b00006, writing b00002)
[14316043.410047] ACPI: PCI Interrupt 0000:00:06.1[B] -> Link [AAZA] ->=
 GSI 22 (level, low) -> IRQ 22
[14316043.419357] PCI: Setting latency timer of device 0000:00:06.1 to =
64
[14316043.475393] ata7.01: ACPI cmd ef/03:44:00:00:00:b0 filtered out
[14316043.479959] ata7.01: ACPI cmd ef/03:0c:00:00:00:b0 filtered out
[14316043.486295] ata7: nv_mode_filter: 0x1f01f&0x1f01f->0x1f01f, BIOS=3D=
0x1f000 (0xc50000) ACPI=3D0x1f01f (600:30:0x1c)
[14316043.503603] ata7.01: configured for UDMA/66
[14316043.649959] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300=
)
[14316043.705849] ata6: SATA link up 1.5 Gbps (SStatus 113 SControl 300=
)
[14316043.761923] ata2: SATA link down (SStatus 0 SControl 300)
[14316043.768607] ata6.00: ACPI cmd ef/03:46:00:00:00:a0 filtered out
[14316043.774862] ata4: SATA link down (SStatus 0 SControl 300)
[14316043.781536] ata3: SATA link down (SStatus 0 SControl 300)
[14316043.787696] ata1.00: ACPI cmd ef/03:46:00:00:00:a0 filtered out
[14316043.793812] ata1.00: ACPI cmd f5/00:00:00:00:00:a0 filtered out
[14316043.800465] ata6.00: configured for UDMA/100
[14316043.805232] ata5: SATA link down (SStatus 0 SControl 300)
[14316043.811777] ata1.00: configured for UDMA/133
[14316043.819807] sd 0:0:0:0: [sda] 976773168 512-byte hardware sectors=
 (500108 MB)
[14316043.824302] sd 0:0:0:0: [sda] Write Protect is off
[14316043.829585] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[14316043.836316] sd 0:0:0:0: [sda] Write cache: enabled, read cache: e=
nabled, doesn't support DPO or FUA
[14316043.870403] eth0: no link during initialization.
[14316043.887365] PCI: Setting latency timer of device 0000:00:0a.0 to =
64
[14316043.895115] PCI: Setting latency timer of device 0000:00:0e.0 to =
64
[14316043.913287] PM: Writing back config space on device 0000:01:08.0 =
at offset 1 (was 2900005, writing 2900001)
[14316043.923545] ACPI: PCI Interrupt 0000:01:08.0[A] -> Link [APC3] ->=
 GSI 18 (level, low) -> IRQ 18
[14316043.941120] ACPI: PCI Interrupt 0000:02:00.0[A] -> Link [APC7] ->=
 GSI 16 (level, low) -> IRQ 16
[14316043.952082] PCI: Setting latency timer of device 0000:02:00.0 to =
64
[14316043.958846] sd 0:0:0:0: [sda] Starting disk
[14316043.969848] usb usb1: usb resume
[14316043.977995] ehci_hcd 0000:00:02.1: resume root hub after power lo=
ss
[14316044.073278] ehci_hcd 0000:00:02.1: port 4 low speed --> companion
[14316044.079790] ehci_hcd 0000:00:02.1: port 3 low speed --> companion
[14316044.086449] ehci_hcd 0000:00:02.1: port 1 low speed --> companion
[14316044.183280] ehci_hcd 0000:00:02.1: GetStatus port 4 status 003402=
 POWER OWNER sig=3Dk CSC
[14316044.198098] ehci_hcd 0000:00:02.1: GetStatus port 3 status 003402=
 POWER OWNER sig=3Dk CSC
[14316044.208097] ehci_hcd 0000:00:02.1: GetStatus port 1 status 003402=
 POWER OWNER sig=3Dk CSC
[14316044.226611] hub 1-0:1.0: hub_reset_resume
[14316044.231026] hub 1-0:1.0: trying to enable port power on non-switc=
hable hub
[14316044.339965] usb usb2: usb resume
[14316044.343635] ohci_hcd 0000:00:02.0: wakeup root hub
[14316044.416610] hub 2-0:1.0: hub_reset_resume
[14316044.421024] hub 2-0:1.0: trying to enable port power on non-switc=
hable hub
[14316044.529951] ohci_hcd 0000:00:02.0: GetStatus roothub.portstatus [=
3] =3D 0x00010101 CSC PPS CCS
[14316044.549943] usb 2-1: finish reset-resume
[14316044.809946] ohci_hcd 0000:00:02.0: GetStatus roothub.portstatus [=
0] =3D 0x00100303 PRSC LSDA PPS PES CCS
[14316044.869949] usb 2-1: reset low speed USB device using ohci_hcd an=
d address 2
[14316045.133279] ohci_hcd 0000:00:02.0: GetStatus roothub.portstatus [=
0] =3D 0x00100303 PRSC LSDA PPS PES CCS
[14316045.236610] usb 2-3: finish reset-resume
[14316045.496612] ohci_hcd 0000:00:02.0: GetStatus roothub.portstatus [=
2] =3D 0x00100303 PRSC LSDA PPS PES CCS
[14316045.556612] usb 2-3: reset low speed USB device using ohci_hcd an=
d address 3
[14316045.823279] ohci_hcd 0000:00:02.0: GetStatus roothub.portstatus [=
2] =3D 0x00100303 PRSC LSDA PPS PES CCS
[14316045.904597] usb 2-3: manual set_interface for iface 0, alt 0
[14316045.927640] usb 2-3: manual set_interface for iface 1, alt 0
[14316045.939040] PM: Image restored successfully.
[14316046.137987] Restarting tasks ... <7>hub 1-0:1.0: state 7 ports 10=
 chg 0000 evt 0000
[14316046.148422] hub 2-0:1.0: state 7 ports 10 chg 0000 evt 0010
[14316046.155074] ohci_hcd 0000:00:02.0: GetStatus roothub.portstatus [=
3] =3D 0x00010101 CSC PPS CCS
[14316046.164442] hub 2-0:1.0: port 4, status 0101, change 0001, 12 Mb/=
s
[14316046.257296] done.
[14316046.267195] PM: Basic memory bitmaps freed
[14316046.293285] hub 2-0:1.0: debounce: port 4: total 100ms stable 100=
ms status 0x101
[14316046.406614] ohci_hcd 0000:00:02.0: GetStatus roothub.portstatus [=
3] =3D 0x00100103 PRSC PPS PES CCS
[14316046.469949] usb 2-4: new full speed USB device using ohci_hcd and=
 address 12
[14316046.480843] ohci_hcd 0000:00:02.0: urb ffff810079c53080 path 4 ep=
0in 5ec20000 cc 5 --> status -62
[14316046.491303] ohci_hcd 0000:00:02.0: urb ffff810079c53080 path 4 ep=
0in 5ec20000 cc 5 --> status -62
[14316046.504082] ohci_hcd 0000:00:02.0: urb ffff810079c53080 path 4 ep=
0in 5ec20000 cc 5 --> status -62
[14316046.619948] ohci_hcd 0000:00:02.0: GetStatus roothub.portstatus [=
3] =3D 0x00100103 PRSC PPS PES CCS
[14316046.679951] usb 2-4: device descriptor read/64, error -62
[14316046.787270] ohci_hcd 0000:00:02.0: urb ffff810079c53080 path 4 ep=
0in 5ec20000 cc 5 --> status -62
[14316046.796604] ohci_hcd 0000:00:02.0: urb ffff810079c53080 path 4 ep=
0in 5ec20000 cc 5 --> status -62
[14316046.796608] ohci_hcd 0000:00:02.0: urb ffff810079c53080 path 4 ep=
0in 5ec20000 cc 5 --> status -62
[14316046.926614] ohci_hcd 0000:00:02.0: GetStatus roothub.portstatus [=
3] =3D 0x00100103 PRSC PPS PES CCS
[14316046.986619] usb 2-4: device descriptor read/64, error -62
[14316047.199946] ohci_hcd 0000:00:02.0: GetStatus roothub.portstatus [=
3] =3D 0x00100103 PRSC PPS PES CCS
[14316047.263284] usb 2-4: new full speed USB device using ohci_hcd and=
 address 13
[14316047.271820] ohci_hcd 0000:00:02.0: urb ffff810079c53080 path 4 ep=
0in 5ec20000 cc 5 --> status -62
[14316047.284069] ohci_hcd 0000:00:02.0: urb ffff810079c53080 path 4 ep=
0in 5ec20000 cc 5 --> status -62
[14316047.293272] ohci_hcd 0000:00:02.0: urb ffff810079c53080 path 4 ep=
0in 5ec20000 cc 5 --> status -62
[14316047.413281] ohci_hcd 0000:00:02.0: GetStatus roothub.portstatus [=
3] =3D 0x00100103 PRSC PPS PES CCS
[14316047.476614] usb 2-4: device descriptor read/64, error -62
[14316047.584063] ohci_hcd 0000:00:02.0: urb ffff810079c53080 path 4 ep=
0in 5ec20000 cc 5 --> status -62
[14316047.593272] ohci_hcd 0000:00:02.0: urb ffff810079c53080 path 4 ep=
0in 5ec20000 cc 5 --> status -62
[14316047.593275] ohci_hcd 0000:00:02.0: urb ffff810079c53080 path 4 ep=
0in 5ec20000 cc 5 --> status -62
[14316047.726613] ohci_hcd 0000:00:02.0: GetStatus roothub.portstatus [=
3] =3D 0x00100103 PRSC PPS PES CCS
[14316047.786618] usb 2-4: device descriptor read/64, error -62
[14316047.999946] ohci_hcd 0000:00:02.0: GetStatus roothub.portstatus [=
3] =3D 0x00100103 PRSC PPS PES CCS
[14316048.063282] usb 2-4: new full speed USB device using ohci_hcd and=
 address 14
[14316048.074171] ohci_hcd 0000:00:02.0: urb ffff810079c53080 path 4 ep=
0out 5ec20000 cc 5 --> status -62
[14316048.287247] ohci_hcd 0000:00:02.0: urb ffff810079c53080 path 4 ep=
0out 5ec20000 cc 5 --> status -62
[14316048.499945] usb 2-4: device not accepting address 14, error -62
[14316048.609947] ohci_hcd 0000:00:02.0: GetStatus roothub.portstatus [=
3] =3D 0x00100103 PRSC PPS PES CCS
[14316048.669950] usb 2-4: new full speed USB device using ohci_hcd and=
 address 15
[14316048.680847] ohci_hcd 0000:00:02.0: urb ffff810079c53080 path 4 ep=
0out 5ec20000 cc 5 --> status -62
[14316048.894040] ohci_hcd 0000:00:02.0: urb ffff810079c53080 path 4 ep=
0out 5ec20000 cc 5 --> status -62
[14316049.106612] usb 2-4: device not accepting address 15, error -62
[14316049.112960] hub 2-0:1.0: unable to enumerate USB device on port 4
[14316049.119635] hub 1-0:1.0: hub_suspend
[14316049.126148] usb usb1: bus auto-suspend
[14316049.127875] ehci_hcd 0000:00:02.1: suspend root hub
[14316049.137334] hub 2-0:1.0: state 7 ports 10 chg 0000 evt 0010
[14316054.935949] [drm] Loading R300 Microcode
[14316192.574403] usb usb1: usb auto-resume
[14316192.579981] ehci_hcd 0000:00:02.1: resume root hub
[14316192.686598] hub 1-0:1.0: hub_resume
[14316192.690414] hub 1-0:1.0: state 7 ports 10 chg 0000 evt 0000
[14316194.696600] hub 1-0:1.0: hub_suspend
[14316194.700479] usb usb1: bus auto-suspend
[14316194.704516] ehci_hcd 0000:00:02.1: suspend root hub

Kernel config:
#
# Automatically generated make config: don't edit
# Linux kernel version: 2.6.26-rc4
# Sun Jun  1 09:04:00 2008
#
CONFIG_64BIT=3Dy
# CONFIG_X86_32 is not set
CONFIG_X86_64=3Dy
CONFIG_X86=3Dy
CONFIG_ARCH_DEFCONFIG=3D"arch/x86/configs/x86_64_defconfig"
# CONFIG_GENERIC_LOCKBREAK is not set
CONFIG_GENERIC_TIME=3Dy
CONFIG_GENERIC_CMOS_UPDATE=3Dy
CONFIG_CLOCKSOURCE_WATCHDOG=3Dy
CONFIG_GENERIC_CLOCKEVENTS=3Dy
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=3Dy
CONFIG_LOCKDEP_SUPPORT=3Dy
CONFIG_STACKTRACE_SUPPORT=3Dy
CONFIG_HAVE_LATENCYTOP_SUPPORT=3Dy
CONFIG_FAST_CMPXCHG_LOCAL=3Dy
CONFIG_MMU=3Dy
CONFIG_ZONE_DMA=3Dy
CONFIG_GENERIC_ISA_DMA=3Dy
CONFIG_GENERIC_IOMAP=3Dy
CONFIG_GENERIC_BUG=3Dy
CONFIG_GENERIC_HWEIGHT=3Dy
# CONFIG_GENERIC_GPIO is not set
CONFIG_ARCH_MAY_HAVE_PC_FDC=3Dy
CONFIG_RWSEM_GENERIC_SPINLOCK=3Dy
# CONFIG_RWSEM_XCHGADD_ALGORITHM is not set
# CONFIG_ARCH_HAS_ILOG2_U32 is not set
# CONFIG_ARCH_HAS_ILOG2_U64 is not set
CONFIG_ARCH_HAS_CPU_IDLE_WAIT=3Dy
CONFIG_GENERIC_CALIBRATE_DELAY=3Dy
CONFIG_GENERIC_TIME_VSYSCALL=3Dy
CONFIG_ARCH_HAS_CPU_RELAX=3Dy
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=3Dy
CONFIG_HAVE_SETUP_PER_CPU_AREA=3Dy
# CONFIG_HAVE_CPUMASK_OF_CPU_MAP is not set
CONFIG_ARCH_HIBERNATION_POSSIBLE=3Dy
CONFIG_ARCH_SUSPEND_POSSIBLE=3Dy
CONFIG_ZONE_DMA32=3Dy
CONFIG_ARCH_POPULATES_NODE_MAP=3Dy
CONFIG_AUDIT_ARCH=3Dy
CONFIG_ARCH_SUPPORTS_AOUT=3Dy
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=3Dy
CONFIG_GENERIC_HARDIRQS=3Dy
CONFIG_GENERIC_IRQ_PROBE=3Dy
CONFIG_X86_BIOS_REBOOT=3Dy
CONFIG_X86_TRAMPOLINE=3Dy
# CONFIG_KTIME_SCALAR is not set
CONFIG_DEFCONFIG_LIST=3D"/lib/modules/$UNAME_RELEASE/.config"

#
# General setup
#
CONFIG_EXPERIMENTAL=3Dy
CONFIG_BROKEN_ON_SMP=3Dy
CONFIG_LOCK_KERNEL=3Dy
CONFIG_INIT_ENV_ARG_LIMIT=3D32
CONFIG_LOCALVERSION=3D""
CONFIG_LOCALVERSION_AUTO=3Dy
CONFIG_SWAP=3Dy
CONFIG_SYSVIPC=3Dy
CONFIG_SYSVIPC_SYSCTL=3Dy
# CONFIG_POSIX_MQUEUE is not set
CONFIG_BSD_PROCESS_ACCT=3Dy
CONFIG_BSD_PROCESS_ACCT_V3=3Dy
# CONFIG_TASKSTATS is not set
# CONFIG_AUDIT is not set
CONFIG_IKCONFIG=3Dy
CONFIG_IKCONFIG_PROC=3Dy
CONFIG_LOG_BUF_SHIFT=3D16
# CONFIG_CGROUPS is not set
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=3Dy
CONFIG_GROUP_SCHED=3Dy
CONFIG_FAIR_GROUP_SCHED=3Dy
# CONFIG_RT_GROUP_SCHED is not set
CONFIG_USER_SCHED=3Dy
# CONFIG_CGROUP_SCHED is not set
CONFIG_SYSFS_DEPRECATED=3Dy
CONFIG_SYSFS_DEPRECATED_V2=3Dy
# CONFIG_RELAY is not set
# CONFIG_NAMESPACES is not set
# CONFIG_BLK_DEV_INITRD is not set
CONFIG_CC_OPTIMIZE_FOR_SIZE=3Dy
CONFIG_SYSCTL=3Dy
CONFIG_EMBEDDED=3Dy
CONFIG_UID16=3Dy
CONFIG_SYSCTL_SYSCALL=3Dy
CONFIG_SYSCTL_SYSCALL_CHECK=3Dy
CONFIG_KALLSYMS=3Dy
CONFIG_KALLSYMS_ALL=3Dy
# CONFIG_KALLSYMS_EXTRA_PASS is not set
CONFIG_HOTPLUG=3Dy
CONFIG_PRINTK=3Dy
CONFIG_BUG=3Dy
CONFIG_ELF_CORE=3Dy
CONFIG_PCSPKR_PLATFORM=3Dy
# CONFIG_COMPAT_BRK is not set
CONFIG_BASE_FULL=3Dy
CONFIG_FUTEX=3Dy
CONFIG_ANON_INODES=3Dy
CONFIG_EPOLL=3Dy
CONFIG_SIGNALFD=3Dy
CONFIG_TIMERFD=3Dy
CONFIG_EVENTFD=3Dy
CONFIG_SHMEM=3Dy
CONFIG_VM_EVENT_COUNTERS=3Dy
CONFIG_SLAB=3Dy
# CONFIG_SLUB is not set
# CONFIG_SLOB is not set
# CONFIG_PROFILING is not set
# CONFIG_MARKERS is not set
CONFIG_HAVE_OPROFILE=3Dy
# CONFIG_KPROBES is not set
CONFIG_HAVE_KPROBES=3Dy
CONFIG_HAVE_KRETPROBES=3Dy
# CONFIG_HAVE_DMA_ATTRS is not set
CONFIG_PROC_PAGE_MONITOR=3Dy
CONFIG_SLABINFO=3Dy
CONFIG_RT_MUTEXES=3Dy
# CONFIG_TINY_SHMEM is not set
CONFIG_BASE_SMALL=3D0
CONFIG_MODULES=3Dy
# CONFIG_MODULE_FORCE_LOAD is not set
CONFIG_MODULE_UNLOAD=3Dy
CONFIG_MODULE_FORCE_UNLOAD=3Dy
# CONFIG_MODVERSIONS is not set
# CONFIG_MODULE_SRCVERSION_ALL is not set
CONFIG_KMOD=3Dy
CONFIG_BLOCK=3Dy
# CONFIG_BLK_DEV_IO_TRACE is not set
CONFIG_BLK_DEV_BSG=3Dy
CONFIG_BLOCK_COMPAT=3Dy

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=3Dy
CONFIG_IOSCHED_AS=3Dy
CONFIG_IOSCHED_DEADLINE=3Dy
CONFIG_IOSCHED_CFQ=3Dy
# CONFIG_DEFAULT_AS is not set
# CONFIG_DEFAULT_DEADLINE is not set
CONFIG_DEFAULT_CFQ=3Dy
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED=3D"cfq"
CONFIG_PREEMPT_NOTIFIERS=3Dy
CONFIG_CLASSIC_RCU=3Dy

#
# Processor type and features
#
CONFIG_TICK_ONESHOT=3Dy
CONFIG_NO_HZ=3Dy
CONFIG_HIGH_RES_TIMERS=3Dy
CONFIG_GENERIC_CLOCKEVENTS_BUILD=3Dy
# CONFIG_SMP is not set
CONFIG_X86_PC=3Dy
# CONFIG_X86_ELAN is not set
# CONFIG_X86_VOYAGER is not set
# CONFIG_X86_NUMAQ is not set
# CONFIG_X86_SUMMIT is not set
# CONFIG_X86_BIGSMP is not set
# CONFIG_X86_VISWS is not set
# CONFIG_X86_GENERICARCH is not set
# CONFIG_X86_ES7000 is not set
# CONFIG_X86_RDC321X is not set
# CONFIG_X86_VSMP is not set
# CONFIG_PARAVIRT_GUEST is not set
CONFIG_MEMTEST_BOOTPARAM=3Dy
CONFIG_MEMTEST_BOOTPARAM_VALUE=3D0
# CONFIG_M386 is not set
# CONFIG_M486 is not set
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
# CONFIG_M586MMX is not set
# CONFIG_M686 is not set
# CONFIG_MPENTIUMII is not set
# CONFIG_MPENTIUMIII is not set
# CONFIG_MPENTIUMM is not set
# CONFIG_MPENTIUM4 is not set
# CONFIG_MK6 is not set
# CONFIG_MK7 is not set
CONFIG_MK8=3Dy
# CONFIG_MCRUSOE is not set
# CONFIG_MEFFICEON is not set
# CONFIG_MWINCHIPC6 is not set
# CONFIG_MWINCHIP2 is not set
# CONFIG_MWINCHIP3D is not set
# CONFIG_MGEODEGX1 is not set
# CONFIG_MGEODE_LX is not set
# CONFIG_MCYRIXIII is not set
# CONFIG_MVIAC3_2 is not set
# CONFIG_MVIAC7 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_GENERIC_CPU is not set
CONFIG_X86_CPU=3Dy
CONFIG_X86_L1_CACHE_BYTES=3D64
CONFIG_X86_INTERNODE_CACHE_BYTES=3D64
CONFIG_X86_CMPXCHG=3Dy
CONFIG_X86_L1_CACHE_SHIFT=3D6
CONFIG_X86_GOOD_APIC=3Dy
CONFIG_X86_INTEL_USERCOPY=3Dy
CONFIG_X86_USE_PPRO_CHECKSUM=3Dy
CONFIG_X86_TSC=3Dy
CONFIG_X86_CMOV=3Dy
CONFIG_X86_MINIMUM_CPU_FAMILY=3D64
CONFIG_X86_DEBUGCTLMSR=3Dy
CONFIG_HPET_TIMER=3Dy
CONFIG_HPET_EMULATE_RTC=3Dy
CONFIG_DMI=3Dy
CONFIG_GART_IOMMU=3Dy
# CONFIG_CALGARY_IOMMU is not set
CONFIG_SWIOTLB=3Dy
CONFIG_IOMMU_HELPER=3Dy
# CONFIG_PREEMPT_NONE is not set
# CONFIG_PREEMPT_VOLUNTARY is not set
CONFIG_PREEMPT=3Dy
# CONFIG_PREEMPT_RCU is not set
CONFIG_X86_LOCAL_APIC=3Dy
CONFIG_X86_IO_APIC=3Dy
CONFIG_X86_MCE=3Dy
# CONFIG_X86_MCE_INTEL is not set
CONFIG_X86_MCE_AMD=3Dy
# CONFIG_I8K is not set
# CONFIG_MICROCODE is not set
# CONFIG_X86_MSR is not set
# CONFIG_X86_CPUID is not set
CONFIG_ARCH_SPARSEMEM_DEFAULT=3Dy
CONFIG_ARCH_SPARSEMEM_ENABLE=3Dy
CONFIG_ARCH_SELECT_MEMORY_MODEL=3Dy
CONFIG_SELECT_MEMORY_MODEL=3Dy
# CONFIG_FLATMEM_MANUAL is not set
# CONFIG_DISCONTIGMEM_MANUAL is not set
CONFIG_SPARSEMEM_MANUAL=3Dy
CONFIG_SPARSEMEM=3Dy
CONFIG_HAVE_MEMORY_PRESENT=3Dy
# CONFIG_SPARSEMEM_STATIC is not set
CONFIG_SPARSEMEM_EXTREME=3Dy
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=3Dy
CONFIG_SPARSEMEM_VMEMMAP=3Dy

#
# Memory hotplug is currently incompatible with Software Suspend
#
CONFIG_PAGEFLAGS_EXTENDED=3Dy
CONFIG_SPLIT_PTLOCK_CPUS=3D4
CONFIG_RESOURCES_64BIT=3Dy
CONFIG_ZONE_DMA_FLAG=3D1
CONFIG_BOUNCE=3Dy
CONFIG_VIRT_TO_BUS=3Dy
CONFIG_MTRR=3Dy
CONFIG_X86_PAT=3Dy
# CONFIG_EFI is not set
# CONFIG_SECCOMP is not set
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
CONFIG_HZ_300=3Dy
# CONFIG_HZ_1000 is not set
CONFIG_HZ=3D300
CONFIG_SCHED_HRTICK=3Dy
CONFIG_KEXEC=3Dy
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=3D0x200000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=3D0x200000
CONFIG_COMPAT_VDSO=3Dy
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=3Dy

#
# Power management options
#
CONFIG_ARCH_HIBERNATION_HEADER=3Dy
CONFIG_PM=3Dy
CONFIG_PM_DEBUG=3Dy
# CONFIG_PM_VERBOSE is not set
CONFIG_CAN_PM_TRACE=3Dy
# CONFIG_PM_TRACE_RTC is not set
CONFIG_PM_SLEEP=3Dy
CONFIG_SUSPEND=3Dy
CONFIG_SUSPEND_FREEZER=3Dy
CONFIG_HIBERNATION=3Dy
CONFIG_PM_STD_PARTITION=3D""
CONFIG_ACPI=3Dy
CONFIG_ACPI_SLEEP=3Dy
CONFIG_ACPI_PROCFS=3Dy
CONFIG_ACPI_PROCFS_POWER=3Dy
CONFIG_ACPI_SYSFS_POWER=3Dy
CONFIG_ACPI_PROC_EVENT=3Dy
CONFIG_ACPI_AC=3Dy
# CONFIG_ACPI_BATTERY is not set
CONFIG_ACPI_BUTTON=3Dy
CONFIG_ACPI_FAN=3Dy
CONFIG_ACPI_DOCK=3Dy
# CONFIG_ACPI_BAY is not set
CONFIG_ACPI_PROCESSOR=3Dy
CONFIG_ACPI_THERMAL=3Dy
# CONFIG_ACPI_WMI is not set
# CONFIG_ACPI_ASUS is not set
# CONFIG_ACPI_TOSHIBA is not set
CONFIG_ACPI_CUSTOM_DSDT_FILE=3D""
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ACPI_BLACKLIST_YEAR=3D0
CONFIG_ACPI_DEBUG=3Dy
CONFIG_ACPI_DEBUG_FUNC_TRACE=3Dy
CONFIG_ACPI_EC=3Dy
CONFIG_ACPI_POWER=3Dy
CONFIG_ACPI_SYSTEM=3Dy
CONFIG_X86_PM_TIMER=3Dy
# CONFIG_ACPI_CONTAINER is not set
# CONFIG_ACPI_SBS is not set

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=3Dy
CONFIG_CPU_FREQ_TABLE=3Dy
# CONFIG_CPU_FREQ_DEBUG is not set
CONFIG_CPU_FREQ_STAT=3Dy
# CONFIG_CPU_FREQ_STAT_DETAILS is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=3Dy
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=3Dy
CONFIG_CPU_FREQ_GOV_POWERSAVE=3Dy
CONFIG_CPU_FREQ_GOV_USERSPACE=3Dy
CONFIG_CPU_FREQ_GOV_ONDEMAND=3Dy
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=3Dy

#
# CPUFreq processor drivers
#
# CONFIG_X86_ACPI_CPUFREQ is not set
CONFIG_X86_POWERNOW_K8=3Dy
CONFIG_X86_POWERNOW_K8_ACPI=3Dy
# CONFIG_X86_SPEEDSTEP_CENTRINO is not set
# CONFIG_X86_P4_CLOCKMOD is not set

#
# shared options
#
# CONFIG_X86_ACPI_CPUFREQ_PROC_INTF is not set
# CONFIG_X86_SPEEDSTEP_LIB is not set
CONFIG_CPU_IDLE=3Dy
CONFIG_CPU_IDLE_GOV_LADDER=3Dy
CONFIG_CPU_IDLE_GOV_MENU=3Dy

#
# Bus options (PCI etc.)
#
CONFIG_PCI=3Dy
CONFIG_PCI_DIRECT=3Dy
# CONFIG_PCI_MMCONFIG is not set
CONFIG_PCI_DOMAINS=3Dy
CONFIG_DMAR=3Dy
CONFIG_DMAR_GFX_WA=3Dy
CONFIG_DMAR_FLOPPY_WA=3Dy
CONFIG_PCIEPORTBUS=3Dy
CONFIG_PCIEAER=3Dy
CONFIG_PCIEASPM=3Dy
CONFIG_PCIEASPM_DEBUG=3Dy
CONFIG_ARCH_SUPPORTS_MSI=3Dy
CONFIG_PCI_MSI=3Dy
CONFIG_PCI_LEGACY=3Dy
# CONFIG_PCI_DEBUG is not set
CONFIG_HT_IRQ=3Dy
CONFIG_ISA_DMA_API=3Dy
CONFIG_K8_NB=3Dy
# CONFIG_PCCARD is not set
# CONFIG_HOTPLUG_PCI is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=3Dy
CONFIG_COMPAT_BINFMT_ELF=3Dy
CONFIG_BINFMT_MISC=3Dy
CONFIG_IA32_EMULATION=3Dy
# CONFIG_IA32_AOUT is not set
CONFIG_COMPAT=3Dy
CONFIG_COMPAT_FOR_U64_ALIGNMENT=3Dy
CONFIG_SYSVIPC_COMPAT=3Dy

#
# Networking
#
CONFIG_NET=3Dy

#
# Networking options
#
CONFIG_PACKET=3Dy
CONFIG_PACKET_MMAP=3Dy
CONFIG_UNIX=3Dy
CONFIG_XFRM=3Dy
CONFIG_XFRM_USER=3Dy
# CONFIG_XFRM_SUB_POLICY is not set
# CONFIG_XFRM_MIGRATE is not set
# CONFIG_XFRM_STATISTICS is not set
CONFIG_NET_KEY=3Dy
# CONFIG_NET_KEY_MIGRATE is not set
CONFIG_INET=3Dy
CONFIG_IP_MULTICAST=3Dy
CONFIG_IP_ADVANCED_ROUTER=3Dy
CONFIG_ASK_IP_FIB_HASH=3Dy
# CONFIG_IP_FIB_TRIE is not set
CONFIG_IP_FIB_HASH=3Dy
CONFIG_IP_MULTIPLE_TABLES=3Dy
CONFIG_IP_ROUTE_MULTIPATH=3Dy
CONFIG_IP_ROUTE_VERBOSE=3Dy
# CONFIG_IP_PNP is not set
CONFIG_NET_IPIP=3Dy
# CONFIG_NET_IPGRE is not set
CONFIG_IP_MROUTE=3Dy
CONFIG_IP_PIMSM_V1=3Dy
CONFIG_IP_PIMSM_V2=3Dy
# CONFIG_ARPD is not set
CONFIG_SYN_COOKIES=3Dy
CONFIG_INET_AH=3Dy
CONFIG_INET_ESP=3Dy
CONFIG_INET_IPCOMP=3Dy
CONFIG_INET_XFRM_TUNNEL=3Dy
CONFIG_INET_TUNNEL=3Dy
CONFIG_INET_XFRM_MODE_TRANSPORT=3Dy
CONFIG_INET_XFRM_MODE_TUNNEL=3Dy
CONFIG_INET_XFRM_MODE_BEET=3Dy
CONFIG_INET_LRO=3Dy
CONFIG_INET_DIAG=3Dy
CONFIG_INET_TCP_DIAG=3Dy
CONFIG_TCP_CONG_ADVANCED=3Dy
CONFIG_TCP_CONG_BIC=3Dy
CONFIG_TCP_CONG_CUBIC=3Dy
CONFIG_TCP_CONG_WESTWOOD=3Dy
CONFIG_TCP_CONG_HTCP=3Dy
# CONFIG_TCP_CONG_HSTCP is not set
# CONFIG_TCP_CONG_HYBLA is not set
CONFIG_TCP_CONG_VEGAS=3Dy
# CONFIG_TCP_CONG_SCALABLE is not set
# CONFIG_TCP_CONG_LP is not set
# CONFIG_TCP_CONG_VENO is not set
CONFIG_TCP_CONG_YEAH=3Dy
# CONFIG_TCP_CONG_ILLINOIS is not set
# CONFIG_DEFAULT_BIC is not set
CONFIG_DEFAULT_CUBIC=3Dy
# CONFIG_DEFAULT_HTCP is not set
# CONFIG_DEFAULT_VEGAS is not set
# CONFIG_DEFAULT_WESTWOOD is not set
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG=3D"cubic"
# CONFIG_TCP_MD5SIG is not set
# CONFIG_IP_VS is not set
CONFIG_IPV6=3Dy
# CONFIG_IPV6_PRIVACY is not set
# CONFIG_IPV6_ROUTER_PREF is not set
# CONFIG_IPV6_OPTIMISTIC_DAD is not set
CONFIG_INET6_AH=3Dy
CONFIG_INET6_ESP=3Dy
CONFIG_INET6_IPCOMP=3Dy
# CONFIG_IPV6_MIP6 is not set
CONFIG_INET6_XFRM_TUNNEL=3Dy
CONFIG_INET6_TUNNEL=3Dy
CONFIG_INET6_XFRM_MODE_TRANSPORT=3Dy
CONFIG_INET6_XFRM_MODE_TUNNEL=3Dy
CONFIG_INET6_XFRM_MODE_BEET=3Dy
# CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION is not set
CONFIG_IPV6_SIT=3Dy
CONFIG_IPV6_NDISC_NODETYPE=3Dy
CONFIG_IPV6_TUNNEL=3Dy
# CONFIG_IPV6_MULTIPLE_TABLES is not set
CONFIG_IPV6_MROUTE=3Dy
CONFIG_IPV6_PIMSM_V2=3Dy
# CONFIG_NETWORK_SECMARK is not set
CONFIG_NETFILTER=3Dy
# CONFIG_NETFILTER_DEBUG is not set
CONFIG_NETFILTER_ADVANCED=3Dy
CONFIG_BRIDGE_NETFILTER=3Dy

#
# Core Netfilter Configuration
#
# CONFIG_NETFILTER_NETLINK_QUEUE is not set
# CONFIG_NETFILTER_NETLINK_LOG is not set
# CONFIG_NF_CONNTRACK is not set
CONFIG_NETFILTER_XTABLES=3Dy
CONFIG_NETFILTER_XT_TARGET_CLASSIFY=3Dy
# CONFIG_NETFILTER_XT_TARGET_DSCP is not set
CONFIG_NETFILTER_XT_TARGET_MARK=3Dy
CONFIG_NETFILTER_XT_TARGET_NFQUEUE=3Dy
# CONFIG_NETFILTER_XT_TARGET_NFLOG is not set
# CONFIG_NETFILTER_XT_TARGET_RATEEST is not set
# CONFIG_NETFILTER_XT_TARGET_TRACE is not set
# CONFIG_NETFILTER_XT_TARGET_TCPMSS is not set
# CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP is not set
# CONFIG_NETFILTER_XT_MATCH_COMMENT is not set
CONFIG_NETFILTER_XT_MATCH_DCCP=3Dy
# CONFIG_NETFILTER_XT_MATCH_DSCP is not set
# CONFIG_NETFILTER_XT_MATCH_ESP is not set
# CONFIG_NETFILTER_XT_MATCH_IPRANGE is not set
CONFIG_NETFILTER_XT_MATCH_LENGTH=3Dy
CONFIG_NETFILTER_XT_MATCH_LIMIT=3Dy
CONFIG_NETFILTER_XT_MATCH_MAC=3Dy
CONFIG_NETFILTER_XT_MATCH_MARK=3Dy
# CONFIG_NETFILTER_XT_MATCH_OWNER is not set
# CONFIG_NETFILTER_XT_MATCH_POLICY is not set
# CONFIG_NETFILTER_XT_MATCH_MULTIPORT is not set
CONFIG_NETFILTER_XT_MATCH_PHYSDEV=3Dy
CONFIG_NETFILTER_XT_MATCH_PKTTYPE=3Dy
# CONFIG_NETFILTER_XT_MATCH_QUOTA is not set
# CONFIG_NETFILTER_XT_MATCH_RATEEST is not set
CONFIG_NETFILTER_XT_MATCH_REALM=3Dy
CONFIG_NETFILTER_XT_MATCH_SCTP=3Dy
# CONFIG_NETFILTER_XT_MATCH_STATISTIC is not set
CONFIG_NETFILTER_XT_MATCH_STRING=3Dy
CONFIG_NETFILTER_XT_MATCH_TCPMSS=3Dy
# CONFIG_NETFILTER_XT_MATCH_TIME is not set
# CONFIG_NETFILTER_XT_MATCH_U32 is not set
# CONFIG_NETFILTER_XT_MATCH_HASHLIMIT is not set

#
# IP: Netfilter Configuration
#
# CONFIG_IP_NF_QUEUE is not set
CONFIG_IP_NF_IPTABLES=3Dy
CONFIG_IP_NF_MATCH_RECENT=3Dy
CONFIG_IP_NF_MATCH_ECN=3Dy
# CONFIG_IP_NF_MATCH_AH is not set
CONFIG_IP_NF_MATCH_TTL=3Dy
CONFIG_IP_NF_MATCH_ADDRTYPE=3Dy
CONFIG_IP_NF_FILTER=3Dy
CONFIG_IP_NF_TARGET_REJECT=3Dy
CONFIG_IP_NF_TARGET_LOG=3Dy
CONFIG_IP_NF_TARGET_ULOG=3Dy
CONFIG_IP_NF_MANGLE=3Dy
CONFIG_IP_NF_TARGET_ECN=3Dy
CONFIG_IP_NF_TARGET_TTL=3Dy
CONFIG_IP_NF_RAW=3Dy
# CONFIG_IP_NF_ARPTABLES is not set

#
# IPv6: Netfilter Configuration
#
CONFIG_IP6_NF_QUEUE=3Dy
# CONFIG_IP6_NF_IPTABLES is not set

#
# Bridge: Netfilter Configuration
#
# CONFIG_BRIDGE_NF_EBTABLES is not set
# CONFIG_IP_DCCP is not set
# CONFIG_IP_SCTP is not set
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
CONFIG_BRIDGE=3Dy
CONFIG_VLAN_8021Q=3Dy
# CONFIG_DECNET is not set
CONFIG_LLC=3Dy
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_ECONET is not set
# CONFIG_WAN_ROUTER is not set
CONFIG_NET_SCHED=3Dy

#
# Queueing/Scheduling
#
CONFIG_NET_SCH_CBQ=3Dy
CONFIG_NET_SCH_HTB=3Dy
# CONFIG_NET_SCH_HFSC is not set
CONFIG_NET_SCH_PRIO=3Dy
# CONFIG_NET_SCH_RR is not set
CONFIG_NET_SCH_RED=3Dy
CONFIG_NET_SCH_SFQ=3Dy
CONFIG_NET_SCH_TEQL=3Dy
CONFIG_NET_SCH_TBF=3Dy
CONFIG_NET_SCH_GRED=3Dy
CONFIG_NET_SCH_DSMARK=3Dy
# CONFIG_NET_SCH_NETEM is not set
CONFIG_NET_SCH_INGRESS=3Dy

#
# Classification
#
CONFIG_NET_CLS=3Dy
CONFIG_NET_CLS_BASIC=3Dy
CONFIG_NET_CLS_TCINDEX=3Dy
CONFIG_NET_CLS_ROUTE4=3Dy
CONFIG_NET_CLS_ROUTE=3Dy
CONFIG_NET_CLS_FW=3Dy
CONFIG_NET_CLS_U32=3Dy
CONFIG_CLS_U32_PERF=3Dy
CONFIG_CLS_U32_MARK=3Dy
# CONFIG_NET_CLS_RSVP is not set
# CONFIG_NET_CLS_RSVP6 is not set
# CONFIG_NET_CLS_FLOW is not set
# CONFIG_NET_EMATCH is not set
CONFIG_NET_CLS_ACT=3Dy
CONFIG_NET_ACT_POLICE=3Dy
CONFIG_NET_ACT_GACT=3Dy
CONFIG_GACT_PROB=3Dy
CONFIG_NET_ACT_MIRRED=3Dy
CONFIG_NET_ACT_IPT=3Dy
# CONFIG_NET_ACT_NAT is not set
CONFIG_NET_ACT_PEDIT=3Dy
# CONFIG_NET_ACT_SIMP is not set
CONFIG_NET_CLS_IND=3Dy
CONFIG_NET_SCH_FIFO=3Dy

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
CONFIG_BT=3Dy
CONFIG_BT_L2CAP=3Dy
CONFIG_BT_SCO=3Dy
CONFIG_BT_RFCOMM=3Dy
CONFIG_BT_RFCOMM_TTY=3Dy
CONFIG_BT_BNEP=3Dy
# CONFIG_BT_BNEP_MC_FILTER is not set
# CONFIG_BT_BNEP_PROTO_FILTER is not set
CONFIG_BT_HIDP=3Dy

#
# Bluetooth device drivers
#
CONFIG_BT_HCIUSB=3Dy
CONFIG_BT_HCIUSB_SCO=3Dy
CONFIG_BT_HCIUART=3Dy
CONFIG_BT_HCIUART_H4=3Dy
CONFIG_BT_HCIUART_BCSP=3Dy
# CONFIG_BT_HCIUART_LL is not set
# CONFIG_BT_HCIBCM203X is not set
# CONFIG_BT_HCIBPA10X is not set
# CONFIG_BT_HCIBFUSB is not set
# CONFIG_BT_HCIVHCI is not set
# CONFIG_AF_RXRPC is not set
CONFIG_FIB_RULES=3Dy

#
# Wireless
#
# CONFIG_CFG80211 is not set
# CONFIG_WIRELESS_EXT is not set
# CONFIG_MAC80211 is not set
# CONFIG_IEEE80211 is not set
# CONFIG_RFKILL is not set
# CONFIG_NET_9P is not set

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH=3D"/sbin/hotplug"
# CONFIG_STANDALONE is not set
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=3Dy
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_CONNECTOR is not set
CONFIG_MTD=3Dy
# CONFIG_MTD_DEBUG is not set
# CONFIG_MTD_CONCAT is not set
CONFIG_MTD_PARTITIONS=3Dy
# CONFIG_MTD_REDBOOT_PARTS is not set
# CONFIG_MTD_CMDLINE_PARTS is not set
# CONFIG_MTD_AR7_PARTS is not set

#
# User Modules And Translation Layers
#
CONFIG_MTD_CHAR=3Dy
CONFIG_MTD_BLKDEVS=3Dy
CONFIG_MTD_BLOCK=3Dy
# CONFIG_FTL is not set
# CONFIG_NFTL is not set
# CONFIG_INFTL is not set
# CONFIG_RFD_FTL is not set
# CONFIG_SSFDC is not set
# CONFIG_MTD_OOPS is not set

#
# RAM/ROM/Flash chip drivers
#
# CONFIG_MTD_CFI is not set
# CONFIG_MTD_JEDECPROBE is not set
CONFIG_MTD_MAP_BANK_WIDTH_1=3Dy
CONFIG_MTD_MAP_BANK_WIDTH_2=3Dy
CONFIG_MTD_MAP_BANK_WIDTH_4=3Dy
# CONFIG_MTD_MAP_BANK_WIDTH_8 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_32 is not set
CONFIG_MTD_CFI_I1=3Dy
CONFIG_MTD_CFI_I2=3Dy
# CONFIG_MTD_CFI_I4 is not set
# CONFIG_MTD_CFI_I8 is not set
# CONFIG_MTD_RAM is not set
# CONFIG_MTD_ROM is not set
# CONFIG_MTD_ABSENT is not set

#
# Mapping drivers for chip access
#
# CONFIG_MTD_COMPLEX_MAPPINGS is not set
# CONFIG_MTD_TS5500 is not set
# CONFIG_MTD_INTEL_VR_NOR is not set
# CONFIG_MTD_PLATRAM is not set

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
# CONFIG_MTD_SLRAM is not set
# CONFIG_MTD_PHRAM is not set
# CONFIG_MTD_MTDRAM is not set
CONFIG_MTD_BLOCK2MTD=3Dy

#
# Disk-On-Chip Device Drivers
#
# CONFIG_MTD_DOC2000 is not set
# CONFIG_MTD_DOC2001 is not set
# CONFIG_MTD_DOC2001PLUS is not set
# CONFIG_MTD_NAND is not set
# CONFIG_MTD_ONENAND is not set

#
# UBI - Unsorted block images
#
# CONFIG_MTD_UBI is not set
# CONFIG_PARPORT is not set
CONFIG_PNP=3Dy
# CONFIG_PNP_DEBUG is not set

#
# Protocols
#
CONFIG_PNPACPI=3Dy
CONFIG_BLK_DEV=3Dy
# CONFIG_BLK_DEV_FD is not set
# CONFIG_BLK_CPQ_DA is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=3Dy
CONFIG_BLK_DEV_CRYPTOLOOP=3Dy
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_UB is not set
# CONFIG_BLK_DEV_RAM is not set
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
CONFIG_MISC_DEVICES=3Dy
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_EEPROM_93CX6 is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
# CONFIG_FUJITSU_LAPTOP is not set
# CONFIG_MSI_LAPTOP is not set
# CONFIG_SONY_LAPTOP is not set
# CONFIG_THINKPAD_ACPI is not set
# CONFIG_INTEL_MENLOW is not set
# CONFIG_EEEPC_LAPTOP is not set
# CONFIG_ENCLOSURE_SERVICES is not set
CONFIG_HAVE_IDE=3Dy
# CONFIG_IDE is not set

#
# SCSI device support
#
# CONFIG_RAID_ATTRS is not set
CONFIG_SCSI=3Dy
CONFIG_SCSI_DMA=3Dy
# CONFIG_SCSI_TGT is not set
# CONFIG_SCSI_NETLINK is not set
CONFIG_SCSI_PROC_FS=3Dy

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=3Dy
# CONFIG_CHR_DEV_ST is not set
# CONFIG_CHR_DEV_OSST is not set
CONFIG_BLK_DEV_SR=3Dy
# CONFIG_BLK_DEV_SR_VENDOR is not set
CONFIG_CHR_DEV_SG=3Dy
# CONFIG_CHR_DEV_SCH is not set

#
# Some SCSI devices (e.g. CD jukebox) support multiple LUNs
#
CONFIG_SCSI_MULTI_LUN=3Dy
# CONFIG_SCSI_CONSTANTS is not set
# CONFIG_SCSI_LOGGING is not set
# CONFIG_SCSI_SCAN_ASYNC is not set
CONFIG_SCSI_WAIT_SCAN=3Dm

#
# SCSI Transports
#
# CONFIG_SCSI_SPI_ATTRS is not set
# CONFIG_SCSI_FC_ATTRS is not set
# CONFIG_SCSI_ISCSI_ATTRS is not set
# CONFIG_SCSI_SAS_ATTRS is not set
# CONFIG_SCSI_SAS_LIBSAS is not set
# CONFIG_SCSI_SRP_ATTRS is not set
CONFIG_SCSI_LOWLEVEL=3Dy
# CONFIG_ISCSI_TCP is not set
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
# CONFIG_SCSI_3W_9XXX is not set
# CONFIG_SCSI_ACARD is not set
# CONFIG_SCSI_AACRAID is not set
# CONFIG_SCSI_AIC7XXX is not set
# CONFIG_SCSI_AIC7XXX_OLD is not set
# CONFIG_SCSI_AIC79XX is not set
# CONFIG_SCSI_AIC94XX is not set
# CONFIG_SCSI_DPT_I2O is not set
# CONFIG_SCSI_ADVANSYS is not set
# CONFIG_SCSI_ARCMSR is not set
# CONFIG_MEGARAID_NEWGEN is not set
# CONFIG_MEGARAID_LEGACY is not set
# CONFIG_MEGARAID_SAS is not set
# CONFIG_SCSI_HPTIOP is not set
# CONFIG_SCSI_BUSLOGIC is not set
# CONFIG_SCSI_DMX3191D is not set
# CONFIG_SCSI_EATA is not set
# CONFIG_SCSI_FUTURE_DOMAIN is not set
# CONFIG_SCSI_GDTH is not set
# CONFIG_SCSI_IPS is not set
# CONFIG_SCSI_INITIO is not set
# CONFIG_SCSI_INIA100 is not set
# CONFIG_SCSI_MVSAS is not set
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
# CONFIG_SCSI_SRP is not set
CONFIG_ATA=3Dy
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_ACPI=3Dy
CONFIG_SATA_PMP=3Dy
CONFIG_SATA_AHCI=3Dy
# CONFIG_SATA_SIL24 is not set
CONFIG_ATA_SFF=3Dy
# CONFIG_SATA_SVW is not set
# CONFIG_ATA_PIIX is not set
# CONFIG_SATA_MV is not set
CONFIG_SATA_NV=3Dy
# CONFIG_PDC_ADMA is not set
# CONFIG_SATA_QSTOR is not set
# CONFIG_SATA_PROMISE is not set
# CONFIG_SATA_SX4 is not set
# CONFIG_SATA_SIL is not set
# CONFIG_SATA_SIS is not set
# CONFIG_SATA_ULI is not set
# CONFIG_SATA_VIA is not set
# CONFIG_SATA_VITESSE is not set
# CONFIG_SATA_INIC162X is not set
# CONFIG_PATA_ACPI is not set
# CONFIG_PATA_ALI is not set
CONFIG_PATA_AMD=3Dm
# CONFIG_PATA_ARTOP is not set
# CONFIG_PATA_ATIIXP is not set
# CONFIG_PATA_CMD640_PCI is not set
# CONFIG_PATA_CMD64X is not set
# CONFIG_PATA_CS5520 is not set
# CONFIG_PATA_CS5530 is not set
# CONFIG_PATA_CYPRESS is not set
# CONFIG_PATA_EFAR is not set
# CONFIG_ATA_GENERIC is not set
# CONFIG_PATA_HPT366 is not set
# CONFIG_PATA_HPT37X is not set
# CONFIG_PATA_HPT3X2N is not set
# CONFIG_PATA_HPT3X3 is not set
# CONFIG_PATA_IT821X is not set
# CONFIG_PATA_IT8213 is not set
# CONFIG_PATA_JMICRON is not set
# CONFIG_PATA_TRIFLEX is not set
# CONFIG_PATA_MARVELL is not set
# CONFIG_PATA_MPIIX is not set
# CONFIG_PATA_OLDPIIX is not set
# CONFIG_PATA_NETCELL is not set
# CONFIG_PATA_NINJA32 is not set
# CONFIG_PATA_NS87410 is not set
# CONFIG_PATA_NS87415 is not set
# CONFIG_PATA_OPTI is not set
# CONFIG_PATA_OPTIDMA is not set
# CONFIG_PATA_PDC_OLD is not set
# CONFIG_PATA_RADISYS is not set
# CONFIG_PATA_RZ1000 is not set
# CONFIG_PATA_SC1200 is not set
# CONFIG_PATA_SERVERWORKS is not set
# CONFIG_PATA_PDC2027X is not set
# CONFIG_PATA_SIL680 is not set
# CONFIG_PATA_SIS is not set
# CONFIG_PATA_VIA is not set
# CONFIG_PATA_WINBOND is not set
# CONFIG_PATA_PLATFORM is not set
# CONFIG_PATA_SCH is not set
CONFIG_MD=3Dy
CONFIG_BLK_DEV_MD=3Dy
# CONFIG_MD_LINEAR is not set
# CONFIG_MD_RAID0 is not set
CONFIG_MD_RAID1=3Dy
# CONFIG_MD_RAID10 is not set
# CONFIG_MD_RAID456 is not set
# CONFIG_MD_MULTIPATH is not set
# CONFIG_MD_FAULTY is not set
CONFIG_BLK_DEV_DM=3Dy
# CONFIG_DM_DEBUG is not set
CONFIG_DM_CRYPT=3Dy
CONFIG_DM_SNAPSHOT=3Dy
CONFIG_DM_MIRROR=3Dy
CONFIG_DM_ZERO=3Dy
# CONFIG_DM_MULTIPATH is not set
# CONFIG_DM_DELAY is not set
# CONFIG_DM_UEVENT is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_IEEE1394 is not set
# CONFIG_I2O is not set
# CONFIG_MACINTOSH_DRIVERS is not set
CONFIG_NETDEVICES=3Dy
# CONFIG_NETDEVICES_MULTIQUEUE is not set
# CONFIG_IFB is not set
# CONFIG_DUMMY is not set
# CONFIG_BONDING is not set
# CONFIG_MACVLAN is not set
# CONFIG_EQUALIZER is not set
CONFIG_TUN=3Dy
# CONFIG_VETH is not set
# CONFIG_NET_SB1000 is not set
# CONFIG_ARCNET is not set
# CONFIG_PHYLIB is not set
CONFIG_NET_ETHERNET=3Dy
CONFIG_MII=3Dy
# CONFIG_HAPPYMEAL is not set
# CONFIG_SUNGEM is not set
# CONFIG_CASSINI is not set
# CONFIG_NET_VENDOR_3COM is not set
# CONFIG_NET_TULIP is not set
# CONFIG_HP100 is not set
# CONFIG_IBM_NEW_EMAC_ZMII is not set
# CONFIG_IBM_NEW_EMAC_RGMII is not set
# CONFIG_IBM_NEW_EMAC_TAH is not set
# CONFIG_IBM_NEW_EMAC_EMAC4 is not set
CONFIG_NET_PCI=3Dy
# CONFIG_PCNET32 is not set
# CONFIG_AMD8111_ETH is not set
# CONFIG_ADAPTEC_STARFIRE is not set
# CONFIG_B44 is not set
CONFIG_FORCEDETH=3Dm
# CONFIG_FORCEDETH_NAPI is not set
# CONFIG_EEPRO100 is not set
CONFIG_E100=3Dy
# CONFIG_FEALNX is not set
# CONFIG_NATSEMI is not set
# CONFIG_NE2K_PCI is not set
# CONFIG_8139CP is not set
# CONFIG_8139TOO is not set
# CONFIG_R6040 is not set
# CONFIG_SIS900 is not set
# CONFIG_EPIC100 is not set
# CONFIG_SUNDANCE is not set
# CONFIG_VIA_RHINE is not set
# CONFIG_SC92031 is not set
CONFIG_NETDEV_1000=3Dy
# CONFIG_ACENIC is not set
# CONFIG_DL2K is not set
# CONFIG_E1000 is not set
CONFIG_E1000E=3Dy
CONFIG_E1000E_ENABLED=3Dy
# CONFIG_IP1000 is not set
# CONFIG_IGB is not set
# CONFIG_NS83820 is not set
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
CONFIG_R8169=3Dy
CONFIG_R8169_NAPI=3Dy
CONFIG_R8169_VLAN=3Dy
# CONFIG_SIS190 is not set
# CONFIG_SKGE is not set
# CONFIG_SKY2 is not set
# CONFIG_VIA_VELOCITY is not set
# CONFIG_TIGON3 is not set
# CONFIG_BNX2 is not set
# CONFIG_QLA3XXX is not set
# CONFIG_ATL1 is not set
CONFIG_NETDEV_10000=3Dy
# CONFIG_CHELSIO_T1 is not set
# CONFIG_CHELSIO_T3 is not set
# CONFIG_IXGBE is not set
# CONFIG_IXGB is not set
# CONFIG_S2IO is not set
# CONFIG_MYRI10GE is not set
# CONFIG_NETXEN_NIC is not set
# CONFIG_NIU is not set
# CONFIG_MLX4_CORE is not set
# CONFIG_TEHUTI is not set
# CONFIG_BNX2X is not set
# CONFIG_SFC is not set
# CONFIG_TR is not set

#
# Wireless LAN
#
# CONFIG_WLAN_PRE80211 is not set
# CONFIG_WLAN_80211 is not set
# CONFIG_IWLWIFI_LEDS is not set

#
# USB Network Adapters
#
# CONFIG_USB_CATC is not set
# CONFIG_USB_KAWETH is not set
# CONFIG_USB_PEGASUS is not set
# CONFIG_USB_RTL8150 is not set
CONFIG_USB_USBNET=3Dm
CONFIG_USB_NET_AX8817X=3Dm
CONFIG_USB_NET_CDCETHER=3Dm
# CONFIG_USB_NET_DM9601 is not set
# CONFIG_USB_NET_GL620A is not set
CONFIG_USB_NET_NET1080=3Dm
# CONFIG_USB_NET_PLUSB is not set
# CONFIG_USB_NET_MCS7830 is not set
# CONFIG_USB_NET_RNDIS_HOST is not set
# CONFIG_USB_NET_CDC_SUBSET is not set
CONFIG_USB_NET_ZAURUS=3Dm
# CONFIG_WAN is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set
# CONFIG_NET_FC is not set
# CONFIG_NETCONSOLE is not set
# CONFIG_NETPOLL is not set
# CONFIG_NET_POLL_CONTROLLER is not set
# CONFIG_ISDN is not set
# CONFIG_PHONE is not set

#
# Input device support
#
CONFIG_INPUT=3Dy
# CONFIG_INPUT_FF_MEMLESS is not set
# CONFIG_INPUT_POLLDEV is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=3Dy
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=3D1600
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=3D1200
CONFIG_INPUT_JOYDEV=3Dy
CONFIG_INPUT_EVDEV=3Dy
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=3Dy
CONFIG_KEYBOARD_ATKBD=3Dy
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
CONFIG_INPUT_MOUSE=3Dy
# CONFIG_MOUSE_PS2 is not set
# CONFIG_MOUSE_SERIAL is not set
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_VSXXXAA is not set
CONFIG_INPUT_JOYSTICK=3Dy
CONFIG_JOYSTICK_ANALOG=3Dm
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
# CONFIG_JOYSTICK_JOYDUMP is not set
# CONFIG_JOYSTICK_XPAD is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
CONFIG_INPUT_MISC=3Dy
# CONFIG_INPUT_PCSPKR is not set
# CONFIG_INPUT_ATLAS_BTNS is not set
# CONFIG_INPUT_ATI_REMOTE is not set
# CONFIG_INPUT_ATI_REMOTE2 is not set
# CONFIG_INPUT_KEYSPAN_REMOTE is not set
# CONFIG_INPUT_POWERMATE is not set
# CONFIG_INPUT_YEALINK is not set
# CONFIG_INPUT_UINPUT is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=3Dy
CONFIG_SERIO_I8042=3Dy
CONFIG_SERIO_SERPORT=3Dy
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=3Dy
# CONFIG_SERIO_RAW is not set
CONFIG_GAMEPORT=3Dm
# CONFIG_GAMEPORT_NS558 is not set
# CONFIG_GAMEPORT_L4 is not set
CONFIG_GAMEPORT_EMU10K1=3Dm
# CONFIG_GAMEPORT_FM801 is not set

#
# Character devices
#
CONFIG_VT=3Dy
CONFIG_VT_CONSOLE=3Dy
CONFIG_HW_CONSOLE=3Dy
# CONFIG_VT_HW_CONSOLE_BINDING is not set
CONFIG_DEVKMEM=3Dy
# CONFIG_SERIAL_NONSTANDARD is not set
# CONFIG_NOZOMI is not set

#
# Serial drivers
#
CONFIG_SERIAL_8250=3Dy
CONFIG_SERIAL_8250_CONSOLE=3Dy
CONFIG_FIX_EARLYCON_MEM=3Dy
CONFIG_SERIAL_8250_PCI=3Dy
CONFIG_SERIAL_8250_PNP=3Dy
CONFIG_SERIAL_8250_NR_UARTS=3D4
CONFIG_SERIAL_8250_RUNTIME_UARTS=3D4
# CONFIG_SERIAL_8250_EXTENDED is not set

#
# Non-8250 serial port support
#
CONFIG_SERIAL_CORE=3Dy
CONFIG_SERIAL_CORE_CONSOLE=3Dy
CONFIG_CONSOLE_POLL=3Dy
# CONFIG_SERIAL_JSM is not set
CONFIG_UNIX98_PTYS=3Dy
# CONFIG_LEGACY_PTYS is not set
# CONFIG_IPMI_HANDLER is not set
# CONFIG_HW_RANDOM is not set
# CONFIG_NVRAM is not set
CONFIG_RTC=3Dy
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_MWAVE is not set
# CONFIG_PC8736x_GPIO is not set
# CONFIG_RAW_DRIVER is not set
# CONFIG_HPET is not set
# CONFIG_HANGCHECK_TIMER is not set
# CONFIG_TCG_TPM is not set
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=3Dy
CONFIG_I2C=3Dy
CONFIG_I2C_BOARDINFO=3Dy
CONFIG_I2C_CHARDEV=3Dy
CONFIG_I2C_ALGOBIT=3Dm

#
# I2C Hardware Bus support
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_I810 is not set
# CONFIG_I2C_PIIX4 is not set
CONFIG_I2C_NFORCE2=3Dy
# CONFIG_I2C_OCORES is not set
# CONFIG_I2C_PARPORT_LIGHT is not set
# CONFIG_I2C_PROSAVAGE is not set
# CONFIG_I2C_SAVAGE4 is not set
# CONFIG_I2C_SIMTEC is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_TAOS_EVM is not set
# CONFIG_I2C_STUB is not set
# CONFIG_I2C_TINY_USB is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set
# CONFIG_I2C_VOODOO3 is not set
# CONFIG_I2C_PCA_PLATFORM is not set

#
# Miscellaneous I2C Chip support
#
# CONFIG_DS1682 is not set
# CONFIG_SENSORS_EEPROM is not set
# CONFIG_SENSORS_PCF8574 is not set
# CONFIG_PCF8575 is not set
# CONFIG_SENSORS_PCF8591 is not set
# CONFIG_SENSORS_MAX6875 is not set
# CONFIG_SENSORS_TSL2550 is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_I2C_DEBUG_CHIP is not set
# CONFIG_SPI is not set
# CONFIG_W1 is not set
CONFIG_POWER_SUPPLY=3Dy
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_BATTERY_DS2760 is not set
CONFIG_HWMON=3Dy
CONFIG_HWMON_VID=3Dy
# CONFIG_SENSORS_ABITUGURU is not set
# CONFIG_SENSORS_ABITUGURU3 is not set
# CONFIG_SENSORS_AD7418 is not set
# CONFIG_SENSORS_ADM1021 is not set
# CONFIG_SENSORS_ADM1025 is not set
# CONFIG_SENSORS_ADM1026 is not set
# CONFIG_SENSORS_ADM1029 is not set
# CONFIG_SENSORS_ADM1031 is not set
# CONFIG_SENSORS_ADM9240 is not set
# CONFIG_SENSORS_ADT7470 is not set
# CONFIG_SENSORS_ADT7473 is not set
CONFIG_SENSORS_K8TEMP=3Dm
# CONFIG_SENSORS_ASB100 is not set
# CONFIG_SENSORS_ATXP1 is not set
# CONFIG_SENSORS_DS1621 is not set
# CONFIG_SENSORS_I5K_AMB is not set
# CONFIG_SENSORS_F71805F is not set
# CONFIG_SENSORS_F71882FG is not set
# CONFIG_SENSORS_F75375S is not set
# CONFIG_SENSORS_FSCHER is not set
# CONFIG_SENSORS_FSCPOS is not set
# CONFIG_SENSORS_FSCHMD is not set
# CONFIG_SENSORS_GL518SM is not set
# CONFIG_SENSORS_GL520SM is not set
# CONFIG_SENSORS_CORETEMP is not set
CONFIG_SENSORS_IT87=3Dy
# CONFIG_SENSORS_LM63 is not set
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
# CONFIG_SENSORS_MAX1619 is not set
# CONFIG_SENSORS_MAX6650 is not set
# CONFIG_SENSORS_PC87360 is not set
# CONFIG_SENSORS_PC87427 is not set
# CONFIG_SENSORS_SIS5595 is not set
# CONFIG_SENSORS_DME1737 is not set
# CONFIG_SENSORS_SMSC47M1 is not set
# CONFIG_SENSORS_SMSC47M192 is not set
# CONFIG_SENSORS_SMSC47B397 is not set
# CONFIG_SENSORS_ADS7828 is not set
# CONFIG_SENSORS_THMC50 is not set
# CONFIG_SENSORS_VIA686A is not set
# CONFIG_SENSORS_VT1211 is not set
# CONFIG_SENSORS_VT8231 is not set
# CONFIG_SENSORS_W83781D is not set
# CONFIG_SENSORS_W83791D is not set
# CONFIG_SENSORS_W83792D is not set
# CONFIG_SENSORS_W83793 is not set
# CONFIG_SENSORS_W83L785TS is not set
# CONFIG_SENSORS_W83L786NG is not set
# CONFIG_SENSORS_W83627HF is not set
# CONFIG_SENSORS_W83627EHF is not set
# CONFIG_SENSORS_HDAPS is not set
# CONFIG_SENSORS_APPLESMC is not set
# CONFIG_HWMON_DEBUG_CHIP is not set
CONFIG_THERMAL=3Dy
# CONFIG_WATCHDOG is not set

#
# Sonics Silicon Backplane
#
CONFIG_SSB_POSSIBLE=3Dy
# CONFIG_SSB is not set

#
# Multifunction device drivers
#
# CONFIG_MFD_SM501 is not set
# CONFIG_HTC_PASIC3 is not set

#
# Multimedia devices
#

#
# Multimedia core support
#
CONFIG_VIDEO_DEV=3Dm
CONFIG_VIDEO_V4L2_COMMON=3Dm
CONFIG_VIDEO_ALLOW_V4L1=3Dy
CONFIG_VIDEO_V4L1_COMPAT=3Dy
# CONFIG_DVB_CORE is not set
CONFIG_VIDEO_MEDIA=3Dm

#
# Multimedia drivers
#
# CONFIG_MEDIA_ATTACH is not set
CONFIG_MEDIA_TUNER=3Dm
# CONFIG_MEDIA_TUNER_CUSTOMIZE is not set
CONFIG_MEDIA_TUNER_SIMPLE=3Dm
CONFIG_MEDIA_TUNER_TDA8290=3Dm
CONFIG_MEDIA_TUNER_TDA9887=3Dm
CONFIG_MEDIA_TUNER_TEA5761=3Dm
CONFIG_MEDIA_TUNER_TEA5767=3Dm
CONFIG_MEDIA_TUNER_MT20XX=3Dm
CONFIG_MEDIA_TUNER_XC2028=3Dm
CONFIG_MEDIA_TUNER_XC5000=3Dm
CONFIG_VIDEO_V4L2=3Dm
CONFIG_VIDEO_V4L1=3Dm
# CONFIG_VIDEO_CAPTURE_DRIVERS is not set
# CONFIG_RADIO_ADAPTERS is not set
# CONFIG_DAB is not set

#
# Graphics support
#
CONFIG_AGP=3Dy
CONFIG_AGP_AMD64=3Dy
# CONFIG_AGP_INTEL is not set
# CONFIG_AGP_SIS is not set
# CONFIG_AGP_VIA is not set
CONFIG_DRM=3Dm
# CONFIG_DRM_TDFX is not set
# CONFIG_DRM_R128 is not set
CONFIG_DRM_RADEON=3Dm
# CONFIG_DRM_MGA is not set
# CONFIG_DRM_SIS is not set
# CONFIG_DRM_VIA is not set
# CONFIG_DRM_SAVAGE is not set
# CONFIG_VGASTATE is not set
# CONFIG_VIDEO_OUTPUT_CONTROL is not set
CONFIG_FB=3Dm
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_DDC=3Dm
CONFIG_FB_CFB_FILLRECT=3Dm
CONFIG_FB_CFB_COPYAREA=3Dm
CONFIG_FB_CFB_IMAGEBLIT=3Dm
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
# CONFIG_FB_SYS_FILLRECT is not set
# CONFIG_FB_SYS_COPYAREA is not set
# CONFIG_FB_SYS_IMAGEBLIT is not set
# CONFIG_FB_FOREIGN_ENDIAN is not set
# CONFIG_FB_SYS_FOPS is not set
# CONFIG_FB_SVGALIB is not set
# CONFIG_FB_MACMODES is not set
# CONFIG_FB_BACKLIGHT is not set
CONFIG_FB_MODE_HELPERS=3Dy
# CONFIG_FB_TILEBLITTING is not set

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
# CONFIG_FB_ARC is not set
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_N411 is not set
# CONFIG_FB_HGA is not set
# CONFIG_FB_S1D13XXX is not set
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_INTEL is not set
# CONFIG_FB_MATROX is not set
CONFIG_FB_RADEON=3Dm
CONFIG_FB_RADEON_I2C=3Dy
# CONFIG_FB_RADEON_BACKLIGHT is not set
CONFIG_FB_RADEON_DEBUG=3Dy
# CONFIG_FB_ATY128 is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
# CONFIG_FB_SIS is not set
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
# CONFIG_FB_PM3 is not set
# CONFIG_FB_GEODE is not set
# CONFIG_FB_VIRTUAL is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=3Dy
# CONFIG_LCD_CLASS_DEVICE is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=3Dy
# CONFIG_BACKLIGHT_CORGI is not set
# CONFIG_BACKLIGHT_PROGEAR is not set

#
# Display device support
#
CONFIG_DISPLAY_SUPPORT=3Dy

#
# Display hardware drivers
#

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=3Dy
CONFIG_VGACON_SOFT_SCROLLBACK=3Dy
CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=3D64
CONFIG_VIDEO_SELECT=3Dy
CONFIG_DUMMY_CONSOLE=3Dy
CONFIG_FRAMEBUFFER_CONSOLE=3Dm
# CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY is not set
CONFIG_FRAMEBUFFER_CONSOLE_ROTATION=3Dy
CONFIG_FONTS=3Dy
# CONFIG_FONT_8x8 is not set
# CONFIG_FONT_8x16 is not set
# CONFIG_FONT_6x11 is not set
# CONFIG_FONT_7x14 is not set
# CONFIG_FONT_PEARL_8x8 is not set
# CONFIG_FONT_ACORN_8x8 is not set
# CONFIG_FONT_MINI_4x6 is not set
# CONFIG_FONT_SUN8x16 is not set
CONFIG_FONT_SUN12x22=3Dy
# CONFIG_FONT_10x18 is not set
CONFIG_LOGO=3Dy
CONFIG_LOGO_LINUX_MONO=3Dy
CONFIG_LOGO_LINUX_VGA16=3Dy
CONFIG_LOGO_LINUX_CLUT224=3Dy

#
# Sound
#
CONFIG_SOUND=3Dy

#
# Advanced Linux Sound Architecture
#
CONFIG_SND=3Dy
CONFIG_SND_TIMER=3Dy
CONFIG_SND_PCM=3Dy
CONFIG_SND_HWDEP=3Dm
CONFIG_SND_RAWMIDI=3Dm
CONFIG_SND_SEQUENCER=3Dy
# CONFIG_SND_SEQ_DUMMY is not set
CONFIG_SND_OSSEMUL=3Dy
CONFIG_SND_MIXER_OSS=3Dy
CONFIG_SND_PCM_OSS=3Dy
# CONFIG_SND_PCM_OSS_PLUGINS is not set
CONFIG_SND_SEQUENCER_OSS=3Dy
# CONFIG_SND_RTCTIMER is not set
# CONFIG_SND_DYNAMIC_MINORS is not set
# CONFIG_SND_SUPPORT_OLD_API is not set
CONFIG_SND_VERBOSE_PROCFS=3Dy
CONFIG_SND_VERBOSE_PRINTK=3Dy
CONFIG_SND_DEBUG=3Dy
CONFIG_SND_DEBUG_DETECT=3Dy
# CONFIG_SND_PCM_XRUN_DEBUG is not set
CONFIG_SND_VMASTER=3Dy

#
# Generic devices
#
# CONFIG_SND_PCSP is not set
CONFIG_SND_AC97_CODEC=3Dm
# CONFIG_SND_DUMMY is not set
# CONFIG_SND_VIRMIDI is not set
# CONFIG_SND_MTPAV is not set
# CONFIG_SND_SERIAL_U16550 is not set
# CONFIG_SND_MPU401 is not set

#
# PCI devices
#
# CONFIG_SND_AD1889 is not set
# CONFIG_SND_ALS300 is not set
# CONFIG_SND_ALS4000 is not set
# CONFIG_SND_ALI5451 is not set
# CONFIG_SND_ATIIXP is not set
# CONFIG_SND_ATIIXP_MODEM is not set
# CONFIG_SND_AU8810 is not set
# CONFIG_SND_AU8820 is not set
# CONFIG_SND_AU8830 is not set
# CONFIG_SND_AW2 is not set
# CONFIG_SND_AZT3328 is not set
# CONFIG_SND_BT87X is not set
# CONFIG_SND_CA0106 is not set
# CONFIG_SND_CMIPCI is not set
# CONFIG_SND_OXYGEN is not set
# CONFIG_SND_CS4281 is not set
# CONFIG_SND_CS46XX is not set
# CONFIG_SND_CS5530 is not set
# CONFIG_SND_DARLA20 is not set
# CONFIG_SND_GINA20 is not set
# CONFIG_SND_LAYLA20 is not set
# CONFIG_SND_DARLA24 is not set
# CONFIG_SND_GINA24 is not set
# CONFIG_SND_LAYLA24 is not set
# CONFIG_SND_MONA is not set
# CONFIG_SND_MIA is not set
# CONFIG_SND_ECHO3G is not set
# CONFIG_SND_INDIGO is not set
# CONFIG_SND_INDIGOIO is not set
# CONFIG_SND_INDIGODJ is not set
CONFIG_SND_EMU10K1=3Dm
# CONFIG_SND_EMU10K1X is not set
# CONFIG_SND_ENS1370 is not set
# CONFIG_SND_ENS1371 is not set
# CONFIG_SND_ES1938 is not set
# CONFIG_SND_ES1968 is not set
# CONFIG_SND_FM801 is not set
CONFIG_SND_HDA_INTEL=3Dm
# CONFIG_SND_HDA_HWDEP is not set
CONFIG_SND_HDA_CODEC_REALTEK=3Dy
CONFIG_SND_HDA_CODEC_ANALOG=3Dy
CONFIG_SND_HDA_CODEC_SIGMATEL=3Dy
CONFIG_SND_HDA_CODEC_VIA=3Dy
CONFIG_SND_HDA_CODEC_ATIHDMI=3Dy
CONFIG_SND_HDA_CODEC_CONEXANT=3Dy
CONFIG_SND_HDA_CODEC_CMEDIA=3Dy
CONFIG_SND_HDA_CODEC_SI3054=3Dy
CONFIG_SND_HDA_GENERIC=3Dy
# CONFIG_SND_HDA_POWER_SAVE is not set
# CONFIG_SND_HDSP is not set
# CONFIG_SND_HDSPM is not set
# CONFIG_SND_HIFIER is not set
# CONFIG_SND_ICE1712 is not set
# CONFIG_SND_ICE1724 is not set
# CONFIG_SND_INTEL8X0 is not set
# CONFIG_SND_INTEL8X0M is not set
# CONFIG_SND_KORG1212 is not set
# CONFIG_SND_MAESTRO3 is not set
# CONFIG_SND_MIXART is not set
# CONFIG_SND_NM256 is not set
# CONFIG_SND_PCXHR is not set
# CONFIG_SND_RIPTIDE is not set
# CONFIG_SND_RME32 is not set
# CONFIG_SND_RME96 is not set
# CONFIG_SND_RME9652 is not set
# CONFIG_SND_SONICVIBES is not set
# CONFIG_SND_TRIDENT is not set
# CONFIG_SND_VIA82XX is not set
# CONFIG_SND_VIA82XX_MODEM is not set
# CONFIG_SND_VIRTUOSO is not set
# CONFIG_SND_VX222 is not set
# CONFIG_SND_YMFPCI is not set
CONFIG_SND_AC97_POWER_SAVE=3Dy
CONFIG_SND_AC97_POWER_SAVE_DEFAULT=3D0

#
# USB devices
#
# CONFIG_SND_USB_AUDIO is not set
# CONFIG_SND_USB_USX2Y is not set
# CONFIG_SND_USB_CAIAQ is not set

#
# System on Chip audio support
#
# CONFIG_SND_SOC is not set

#
# ALSA SoC audio for Freescale SOCs
#

#
# SoC Audio for the Texas Instruments OMAP
#

#
# Open Sound System
#
# CONFIG_SOUND_PRIME is not set
CONFIG_AC97_BUS=3Dm
CONFIG_HID_SUPPORT=3Dy
CONFIG_HID=3Dy
# CONFIG_HID_DEBUG is not set
# CONFIG_HIDRAW is not set

#
# USB Input Devices
#
CONFIG_USB_HID=3Dy
# CONFIG_USB_HIDINPUT_POWERBOOK is not set
# CONFIG_HID_FF is not set
# CONFIG_USB_HIDDEV is not set
CONFIG_USB_SUPPORT=3Dy
CONFIG_USB_ARCH_HAS_HCD=3Dy
CONFIG_USB_ARCH_HAS_OHCI=3Dy
CONFIG_USB_ARCH_HAS_EHCI=3Dy
CONFIG_USB=3Dy
CONFIG_USB_DEBUG=3Dy
# CONFIG_USB_ANNOUNCE_NEW_DEVICES is not set

#
# Miscellaneous USB options
#
CONFIG_USB_DEVICEFS=3Dy
# CONFIG_USB_DEVICE_CLASS is not set
# CONFIG_USB_DYNAMIC_MINORS is not set
CONFIG_USB_SUSPEND=3Dy
# CONFIG_USB_OTG is not set
# CONFIG_USB_OTG_WHITELIST is not set
# CONFIG_USB_OTG_BLACKLIST_HUB is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
CONFIG_USB_EHCI_HCD=3Dy
# CONFIG_USB_EHCI_ROOT_HUB_TT is not set
# CONFIG_USB_EHCI_TT_NEWSCHED is not set
# CONFIG_USB_ISP116X_HCD is not set
# CONFIG_USB_ISP1760_HCD is not set
CONFIG_USB_OHCI_HCD=3Dy
# CONFIG_USB_OHCI_BIG_ENDIAN_DESC is not set
# CONFIG_USB_OHCI_BIG_ENDIAN_MMIO is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=3Dy
CONFIG_USB_UHCI_HCD=3Dy
# CONFIG_USB_SL811_HCD is not set
# CONFIG_USB_R8A66597_HCD is not set

#
# USB Device Class drivers
#
# CONFIG_USB_ACM is not set
CONFIG_USB_PRINTER=3Dy
# CONFIG_USB_WDM is not set

#
# NOTE: USB_STORAGE enables SCSI, and 'SCSI disk support'
#

#
# may also be needed; see USB_STORAGE Help for more information
#
CONFIG_USB_STORAGE=3Dm
# CONFIG_USB_STORAGE_DEBUG is not set
# CONFIG_USB_STORAGE_DATAFAB is not set
# CONFIG_USB_STORAGE_FREECOM is not set
# CONFIG_USB_STORAGE_ISD200 is not set
# CONFIG_USB_STORAGE_DPCM is not set
# CONFIG_USB_STORAGE_USBAT is not set
# CONFIG_USB_STORAGE_SDDR09 is not set
# CONFIG_USB_STORAGE_SDDR55 is not set
# CONFIG_USB_STORAGE_JUMPSHOT is not set
# CONFIG_USB_STORAGE_ALAUDA is not set
# CONFIG_USB_STORAGE_ONETOUCH is not set
# CONFIG_USB_STORAGE_KARMA is not set
CONFIG_USB_STORAGE_CYPRESS_ATACB=3Dy
# CONFIG_USB_LIBUSUAL is not set

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
# CONFIG_USB_MICROTEK is not set
CONFIG_USB_MON=3Dy

#
# USB port drivers
#
CONFIG_USB_SERIAL=3Dm
# CONFIG_USB_EZUSB is not set
CONFIG_USB_SERIAL_GENERIC=3Dy
# CONFIG_USB_SERIAL_AIRCABLE is not set
# CONFIG_USB_SERIAL_AIRPRIME is not set
# CONFIG_USB_SERIAL_ARK3116 is not set
# CONFIG_USB_SERIAL_BELKIN is not set
# CONFIG_USB_SERIAL_CH341 is not set
# CONFIG_USB_SERIAL_WHITEHEAT is not set
# CONFIG_USB_SERIAL_DIGI_ACCELEPORT is not set
# CONFIG_USB_SERIAL_CP2101 is not set
# CONFIG_USB_SERIAL_CYPRESS_M8 is not set
# CONFIG_USB_SERIAL_EMPEG is not set
# CONFIG_USB_SERIAL_FTDI_SIO is not set
# CONFIG_USB_SERIAL_FUNSOFT is not set
# CONFIG_USB_SERIAL_VISOR is not set
# CONFIG_USB_SERIAL_IPAQ is not set
# CONFIG_USB_SERIAL_IR is not set
# CONFIG_USB_SERIAL_EDGEPORT is not set
# CONFIG_USB_SERIAL_EDGEPORT_TI is not set
# CONFIG_USB_SERIAL_GARMIN is not set
# CONFIG_USB_SERIAL_IPW is not set
# CONFIG_USB_SERIAL_IUU is not set
# CONFIG_USB_SERIAL_KEYSPAN_PDA is not set
# CONFIG_USB_SERIAL_KEYSPAN is not set
# CONFIG_USB_SERIAL_KLSI is not set
# CONFIG_USB_SERIAL_KOBIL_SCT is not set
# CONFIG_USB_SERIAL_MCT_U232 is not set
# CONFIG_USB_SERIAL_MOS7720 is not set
# CONFIG_USB_SERIAL_MOS7840 is not set
# CONFIG_USB_SERIAL_MOTOROLA is not set
# CONFIG_USB_SERIAL_NAVMAN is not set
CONFIG_USB_SERIAL_PL2303=3Dm
# CONFIG_USB_SERIAL_OTI6858 is not set
# CONFIG_USB_SERIAL_SPCP8X5 is not set
# CONFIG_USB_SERIAL_HP4X is not set
# CONFIG_USB_SERIAL_SAFE is not set
# CONFIG_USB_SERIAL_SIERRAWIRELESS is not set
# CONFIG_USB_SERIAL_TI is not set
# CONFIG_USB_SERIAL_CYBERJACK is not set
# CONFIG_USB_SERIAL_XIRCOM is not set
# CONFIG_USB_SERIAL_OPTION is not set
# CONFIG_USB_SERIAL_OMNINET is not set
# CONFIG_USB_SERIAL_DEBUG is not set

#
# USB Miscellaneous drivers
#
# CONFIG_USB_EMI62 is not set
# CONFIG_USB_EMI26 is not set
# CONFIG_USB_ADUTUX is not set
# CONFIG_USB_AUERSWALD is not set
# CONFIG_USB_RIO500 is not set
# CONFIG_USB_LEGOTOWER is not set
# CONFIG_USB_LCD is not set
# CONFIG_USB_BERRY_CHARGE is not set
# CONFIG_USB_LED is not set
# CONFIG_USB_CYPRESS_CY7C63 is not set
# CONFIG_USB_CYTHERM is not set
# CONFIG_USB_PHIDGET is not set
# CONFIG_USB_IDMOUSE is not set
# CONFIG_USB_FTDI_ELAN is not set
# CONFIG_USB_APPLEDISPLAY is not set
# CONFIG_USB_SISUSBVGA is not set
# CONFIG_USB_LD is not set
# CONFIG_USB_TRANCEVIBRATOR is not set
# CONFIG_USB_IOWARRIOR is not set
# CONFIG_USB_TEST is not set
# CONFIG_USB_GADGET is not set
# CONFIG_MMC is not set
# CONFIG_MEMSTICK is not set
# CONFIG_NEW_LEDS is not set
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
# CONFIG_EDAC is not set
# CONFIG_RTC_CLASS is not set
CONFIG_DMADEVICES=3Dy

#
# DMA Devices
#
# CONFIG_INTEL_IOATDMA is not set
# CONFIG_UIO is not set

#
# Firmware Drivers
#
# CONFIG_EDD is not set
# CONFIG_DELL_RBU is not set
# CONFIG_DCDBAS is not set
CONFIG_DMIID=3Dy
# CONFIG_ISCSI_IBFT_FIND is not set

#
# File systems
#
CONFIG_EXT2_FS=3Dy
CONFIG_EXT2_FS_XATTR=3Dy
CONFIG_EXT2_FS_POSIX_ACL=3Dy
CONFIG_EXT2_FS_SECURITY=3Dy
# CONFIG_EXT2_FS_XIP is not set
CONFIG_EXT3_FS=3Dy
CONFIG_EXT3_FS_XATTR=3Dy
CONFIG_EXT3_FS_POSIX_ACL=3Dy
CONFIG_EXT3_FS_SECURITY=3Dy
# CONFIG_EXT4DEV_FS is not set
CONFIG_JBD=3Dy
# CONFIG_JBD_DEBUG is not set
CONFIG_FS_MBCACHE=3Dy
CONFIG_REISERFS_FS=3Dy
# CONFIG_REISERFS_CHECK is not set
# CONFIG_REISERFS_PROC_INFO is not set
# CONFIG_REISERFS_FS_XATTR is not set
# CONFIG_JFS_FS is not set
CONFIG_FS_POSIX_ACL=3Dy
CONFIG_XFS_FS=3Dy
# CONFIG_XFS_QUOTA is not set
# CONFIG_XFS_POSIX_ACL is not set
# CONFIG_XFS_RT is not set
# CONFIG_XFS_DEBUG is not set
# CONFIG_GFS2_FS is not set
# CONFIG_OCFS2_FS is not set
CONFIG_DNOTIFY=3Dy
CONFIG_INOTIFY=3Dy
CONFIG_INOTIFY_USER=3Dy
# CONFIG_QUOTA is not set
# CONFIG_AUTOFS_FS is not set
CONFIG_AUTOFS4_FS=3Dy
CONFIG_FUSE_FS=3Dy
CONFIG_GENERIC_ACL=3Dy

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=3Dy
CONFIG_JOLIET=3Dy
# CONFIG_ZISOFS is not set
CONFIG_UDF_FS=3Dy
CONFIG_UDF_NLS=3Dy

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=3Dy
CONFIG_MSDOS_FS=3Dy
CONFIG_VFAT_FS=3Dy
CONFIG_FAT_DEFAULT_CODEPAGE=3D932
CONFIG_FAT_DEFAULT_IOCHARSET=3D"utf8"
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=3Dy
CONFIG_PROC_KCORE=3Dy
CONFIG_PROC_SYSCTL=3Dy
CONFIG_SYSFS=3Dy
CONFIG_TMPFS=3Dy
CONFIG_TMPFS_POSIX_ACL=3Dy
# CONFIG_HUGETLBFS is not set
# CONFIG_HUGETLB_PAGE is not set
CONFIG_CONFIGFS_FS=3Dy

#
# Miscellaneous filesystems
#
# CONFIG_ADFS_FS is not set
# CONFIG_AFFS_FS is not set
# CONFIG_HFS_FS is not set
# CONFIG_HFSPLUS_FS is not set
# CONFIG_BEFS_FS is not set
# CONFIG_BFS_FS is not set
# CONFIG_EFS_FS is not set
CONFIG_JFFS2_FS=3Dy
CONFIG_JFFS2_FS_DEBUG=3D0
CONFIG_JFFS2_FS_WRITEBUFFER=3Dy
# CONFIG_JFFS2_FS_WBUF_VERIFY is not set
# CONFIG_JFFS2_SUMMARY is not set
# CONFIG_JFFS2_FS_XATTR is not set
# CONFIG_JFFS2_COMPRESSION_OPTIONS is not set
CONFIG_JFFS2_ZLIB=3Dy
# CONFIG_JFFS2_LZO is not set
CONFIG_JFFS2_RTIME=3Dy
# CONFIG_JFFS2_RUBIN is not set
CONFIG_CRAMFS=3Dy
# CONFIG_VXFS_FS is not set
# CONFIG_MINIX_FS is not set
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
# CONFIG_ROMFS_FS is not set
# CONFIG_SYSV_FS is not set
# CONFIG_UFS_FS is not set
CONFIG_NETWORK_FILESYSTEMS=3Dy
CONFIG_NFS_FS=3Dy
CONFIG_NFS_V3=3Dy
CONFIG_NFS_V3_ACL=3Dy
# CONFIG_NFS_V4 is not set
CONFIG_NFSD=3Dy
CONFIG_NFSD_V2_ACL=3Dy
CONFIG_NFSD_V3=3Dy
CONFIG_NFSD_V3_ACL=3Dy
# CONFIG_NFSD_V4 is not set
CONFIG_LOCKD=3Dy
CONFIG_LOCKD_V4=3Dy
CONFIG_EXPORTFS=3Dy
CONFIG_NFS_ACL_SUPPORT=3Dy
CONFIG_NFS_COMMON=3Dy
CONFIG_SUNRPC=3Dy
CONFIG_SUNRPC_GSS=3Dy
CONFIG_SUNRPC_BIND34=3Dy
CONFIG_RPCSEC_GSS_KRB5=3Dy
# CONFIG_RPCSEC_GSS_SPKM3 is not set
CONFIG_SMB_FS=3Dy
CONFIG_SMB_NLS_DEFAULT=3Dy
CONFIG_SMB_NLS_REMOTE=3D"cp850"
CONFIG_CIFS=3Dy
# CONFIG_CIFS_STATS is not set
# CONFIG_CIFS_WEAK_PW_HASH is not set
CONFIG_CIFS_XATTR=3Dy
CONFIG_CIFS_POSIX=3Dy
# CONFIG_CIFS_DEBUG2 is not set
# CONFIG_CIFS_EXPERIMENTAL is not set
# CONFIG_NCP_FS is not set
# CONFIG_CODA_FS is not set
# CONFIG_AFS_FS is not set

#
# Partition Types
#
# CONFIG_PARTITION_ADVANCED is not set
CONFIG_MSDOS_PARTITION=3Dy
CONFIG_NLS=3Dy
CONFIG_NLS_DEFAULT=3D"utf8"
CONFIG_NLS_CODEPAGE_437=3Dy
# CONFIG_NLS_CODEPAGE_737 is not set
# CONFIG_NLS_CODEPAGE_775 is not set
CONFIG_NLS_CODEPAGE_850=3Dy
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
CONFIG_NLS_CODEPAGE_932=3Dy
# CONFIG_NLS_CODEPAGE_949 is not set
# CONFIG_NLS_CODEPAGE_874 is not set
# CONFIG_NLS_ISO8859_8 is not set
# CONFIG_NLS_CODEPAGE_1250 is not set
# CONFIG_NLS_CODEPAGE_1251 is not set
# CONFIG_NLS_ASCII is not set
CONFIG_NLS_ISO8859_1=3Dy
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
# CONFIG_NLS_ISO8859_4 is not set
# CONFIG_NLS_ISO8859_5 is not set
# CONFIG_NLS_ISO8859_6 is not set
# CONFIG_NLS_ISO8859_7 is not set
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
CONFIG_NLS_ISO8859_15=3Dy
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
CONFIG_NLS_UTF8=3Dy
# CONFIG_DLM is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=3Dy
CONFIG_PRINTK_TIME=3Dy
CONFIG_ENABLE_WARN_DEPRECATED=3Dy
CONFIG_ENABLE_MUST_CHECK=3Dy
CONFIG_FRAME_WARN=3D3072
CONFIG_MAGIC_SYSRQ=3Dy
# CONFIG_UNUSED_SYMBOLS is not set
CONFIG_DEBUG_FS=3Dy
# CONFIG_HEADERS_CHECK is not set
CONFIG_DEBUG_KERNEL=3Dy
# CONFIG_DEBUG_SHIRQ is not set
CONFIG_DETECT_SOFTLOCKUP=3Dy
CONFIG_SCHED_DEBUG=3Dy
CONFIG_SCHEDSTATS=3Dy
CONFIG_TIMER_STATS=3Dy
# CONFIG_DEBUG_OBJECTS is not set
# CONFIG_DEBUG_SLAB is not set
CONFIG_DEBUG_PREEMPT=3Dy
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_RT_MUTEX_TESTER is not set
CONFIG_DEBUG_SPINLOCK=3Dy
CONFIG_DEBUG_MUTEXES=3Dy
CONFIG_DEBUG_LOCK_ALLOC=3Dy
CONFIG_PROVE_LOCKING=3Dy
CONFIG_LOCKDEP=3Dy
# CONFIG_LOCK_STAT is not set
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_TRACE_IRQFLAGS=3Dy
CONFIG_DEBUG_SPINLOCK_SLEEP=3Dy
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_STACKTRACE=3Dy
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=3Dy
CONFIG_DEBUG_INFO=3Dy
# CONFIG_DEBUG_VM is not set
# CONFIG_DEBUG_WRITECOUNT is not set
# CONFIG_DEBUG_LIST is not set
# CONFIG_DEBUG_SG is not set
CONFIG_FRAME_POINTER=3Dy
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_RCU_TORTURE_TEST is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_FAULT_INJECTION is not set
CONFIG_LATENCYTOP=3Dy
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=3Dy
CONFIG_KGDB=3Dy
CONFIG_KGDB_SERIAL_CONSOLE=3Dy
# CONFIG_KGDB_TESTS is not set
# CONFIG_NONPROMISC_DEVMEM is not set
CONFIG_EARLY_PRINTK=3Dy
# CONFIG_DEBUG_STACKOVERFLOW is not set
# CONFIG_DEBUG_STACK_USAGE is not set
# CONFIG_DEBUG_PAGEALLOC is not set
# CONFIG_X86_PTDUMP is not set
CONFIG_DEBUG_RODATA=3Dy
# CONFIG_DIRECT_GBPAGES is not set
# CONFIG_DEBUG_RODATA_TEST is not set
# CONFIG_DEBUG_NX_TEST is not set
CONFIG_X86_MPPARSE=3Dy
# CONFIG_IOMMU_DEBUG is not set
CONFIG_IO_DELAY_TYPE_0X80=3D0
CONFIG_IO_DELAY_TYPE_0XED=3D1
CONFIG_IO_DELAY_TYPE_UDELAY=3D2
CONFIG_IO_DELAY_TYPE_NONE=3D3
CONFIG_IO_DELAY_0X80=3Dy
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=3D0
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set

#
# Security options
#
# CONFIG_KEYS is not set
# CONFIG_SECURITY is not set
# CONFIG_SECURITY_FILE_CAPABILITIES is not set
CONFIG_CRYPTO=3Dy

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=3Dy
CONFIG_CRYPTO_AEAD=3Dy
CONFIG_CRYPTO_BLKCIPHER=3Dy
CONFIG_CRYPTO_HASH=3Dy
CONFIG_CRYPTO_MANAGER=3Dy
# CONFIG_CRYPTO_GF128MUL is not set
CONFIG_CRYPTO_NULL=3Dy
# CONFIG_CRYPTO_CRYPTD is not set
CONFIG_CRYPTO_AUTHENC=3Dy
# CONFIG_CRYPTO_TEST is not set

#
# Authenticated Encryption with Associated Data
#
# CONFIG_CRYPTO_CCM is not set
# CONFIG_CRYPTO_GCM is not set
# CONFIG_CRYPTO_SEQIV is not set

#
# Block modes
#
CONFIG_CRYPTO_CBC=3Dy
# CONFIG_CRYPTO_CTR is not set
# CONFIG_CRYPTO_CTS is not set
# CONFIG_CRYPTO_ECB is not set
# CONFIG_CRYPTO_LRW is not set
# CONFIG_CRYPTO_PCBC is not set
# CONFIG_CRYPTO_XTS is not set

#
# Hash modes
#
CONFIG_CRYPTO_HMAC=3Dy
# CONFIG_CRYPTO_XCBC is not set

#
# Digest
#
# CONFIG_CRYPTO_CRC32C is not set
# CONFIG_CRYPTO_MD4 is not set
CONFIG_CRYPTO_MD5=3Dy
CONFIG_CRYPTO_MICHAEL_MIC=3Dy
CONFIG_CRYPTO_SHA1=3Dy
CONFIG_CRYPTO_SHA256=3Dy
# CONFIG_CRYPTO_SHA512 is not set
# CONFIG_CRYPTO_TGR192 is not set
CONFIG_CRYPTO_WP512=3Dy

#
# Ciphers
#
CONFIG_CRYPTO_AES=3Dy
CONFIG_CRYPTO_AES_X86_64=3Dy
# CONFIG_CRYPTO_ANUBIS is not set
CONFIG_CRYPTO_ARC4=3Dy
CONFIG_CRYPTO_BLOWFISH=3Dy
# CONFIG_CRYPTO_CAMELLIA is not set
# CONFIG_CRYPTO_CAST5 is not set
# CONFIG_CRYPTO_CAST6 is not set
CONFIG_CRYPTO_DES=3Dy
# CONFIG_CRYPTO_FCRYPT is not set
# CONFIG_CRYPTO_KHAZAD is not set
# CONFIG_CRYPTO_SALSA20 is not set
# CONFIG_CRYPTO_SALSA20_X86_64 is not set
# CONFIG_CRYPTO_SEED is not set
# CONFIG_CRYPTO_SERPENT is not set
# CONFIG_CRYPTO_TEA is not set
# CONFIG_CRYPTO_TWOFISH is not set
# CONFIG_CRYPTO_TWOFISH_X86_64 is not set

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=3Dy
# CONFIG_CRYPTO_LZO is not set
CONFIG_CRYPTO_HW=3Dy
# CONFIG_CRYPTO_DEV_HIFN_795X is not set
CONFIG_HAVE_KVM=3Dy
CONFIG_VIRTUALIZATION=3Dy
CONFIG_KVM=3Dy
# CONFIG_KVM_INTEL is not set
CONFIG_KVM_AMD=3Dy
# CONFIG_VIRTIO_PCI is not set
# CONFIG_VIRTIO_BALLOON is not set

#
# Library routines
#
CONFIG_BITREVERSE=3Dy
CONFIG_GENERIC_FIND_FIRST_BIT=3Dy
CONFIG_GENERIC_FIND_NEXT_BIT=3Dy
# CONFIG_CRC_CCITT is not set
# CONFIG_CRC16 is not set
CONFIG_CRC_ITU_T=3Dy
CONFIG_CRC32=3Dy
# CONFIG_CRC7 is not set
# CONFIG_LIBCRC32C is not set
CONFIG_ZLIB_INFLATE=3Dy
CONFIG_ZLIB_DEFLATE=3Dy
CONFIG_TEXTSEARCH=3Dy
CONFIG_TEXTSEARCH_KMP=3Dy
CONFIG_TEXTSEARCH_BM=3Dy
CONFIG_TEXTSEARCH_FSM=3Dy
CONFIG_PLIST=3Dy
CONFIG_HAS_IOMEM=3Dy
CONFIG_HAS_IOPORT=3Dy
CONFIG_HAS_DMA=3Dy

--=20
Tobias						PGP: http://9ac7e0bc.uguu.de
=E3=81=93=E3=81=AE=E3=83=A1=E3=83=BC=E3=83=AB=E3=81=AF=E5=8D=81=E5=89=B2=
=E5=86=8D=E5=88=A9=E7=94=A8=E3=81=95=E3=82=8C=E3=81=9F=E3=83=93=E3=83=83=
=E3=83=88=E3=81=A7=E4=BD=9C=E3=82=89=E3=82=8C=E3=81=A6=E3=81=84=E3=81=BE=
=E3=81=99=E3=80=82
