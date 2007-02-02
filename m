From: Mattia Dongili <malattia@linux.it>
Subject: dynticks + iptables almost stops the boot process [was: Re: 2.6.20-rc6-mm3]
Date: Fri, 2 Feb 2007 20:18:02 +0100
Message-ID: <20070202191802.GA4262@inferi.kami.home>
References: <20070129204528.eb8d695e.akpm@osdl.org> <20070131215241.GB2890@inferi.kami.home> <20070131232130.GC4137@inferi.kami.home> <1170358572.29240.292.camel@localhost.localdomain> <1170360101.29240.297.camel@localhost.localdomain> <20070201211137.GA2830@inferi.kami.home> <1170369202.29240.339.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	mingo@redhat.com, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1423066AbXBBTSq@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1170369202.29240.339.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cc-ing netdev and netfilter-devel, the beginning of the thread is here
http://lkml.org/lkml/2007/1/31/306

On Thu, Feb 01, 2007 at 11:33:22PM +0100, Thomas Gleixner wrote:
> Mattia,
...
> May I ask you for another test ? Please turn on high resolution timers
> and check, if the same strange behaviour is happening.

Yep, here we go again. Still seeing long stalls but no negative expires
offset.
Actually one more test I did is disabling my iptables script and the
boot process went fine. The script is just:

  #!/bin/sh
  iptables -F INPUT
  iptables -F FORWARD
  iptables -F OUTPUT
  iptables -P INPUT DROP
  iptables -P FORWARD ACCEPT
  iptables -A INPUT -i lo -j ACCEPT
  iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
  iptables -A INPUT -p tcp --dport ssh -j ACCEPT
  # LAN 
  iptables -I INPUT -s 10.0.0.0/8 -j ACCEPT
  # LAN UML
  iptables -I INPUT -s 172.20.0.0/16 -j ACCEPT
  echo "iptables: MASQUERADING for virtual machines"
  iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
  iptables -t nat -A POSTROUTING -o eth2 -j MASQUERADE
  sysctl -w net.ipv4.ip_forward=1

and executing it from a shell once the boot process is done doesn't
generate all that strangeness/slowness...

Dmesg with iptables script enabled:

[    0.000000] Linux version 2.6.20-rc6-mm3-1 (mattia@tadamune) (gcc version 4.1.2 20061115 (prerelease) (Debian 4.1.1-21)) #8 SMP Fri Feb 2 10:26:07 CET 2007
[    0.000000] BIOS-provided physical RAM map:
[    0.000000] sanitize start
[    0.000000] sanitize end
[    0.000000] copy_e820_map() start: 0000000000000000 size: 000000000009f800 end: 000000000009f800 type: 1
[    0.000000] copy_e820_map() type is E820_RAM
[    0.000000] copy_e820_map() start: 000000000009f800 size: 0000000000000800 end: 00000000000a0000 type: 2
[    0.000000] copy_e820_map() start: 00000000000dc000 size: 0000000000024000 end: 0000000000100000 type: 2
[    0.000000] copy_e820_map() start: 0000000000100000 size: 000000003fd70000 end: 000000003fe70000 type: 1
[    0.000000] copy_e820_map() type is E820_RAM
[    0.000000] copy_e820_map() start: 000000003fe70000 size: 0000000000090000 end: 000000003ff00000 type: 4
[    0.000000] copy_e820_map() start: 000000003ff00000 size: 0000000000100000 end: 0000000040000000 type: 2
[    0.000000] copy_e820_map() start: 00000000e0000000 size: 0000000010000000 end: 00000000f0000000 type: 2
[    0.000000] copy_e820_map() start: 00000000fec00000 size: 0000000000010000 end: 00000000fec10000 type: 2
[    0.000000] copy_e820_map() start: 00000000fed14000 size: 0000000000006000 end: 00000000fed1a000 type: 2
[    0.000000] copy_e820_map() start: 00000000fed1c000 size: 0000000000074000 end: 00000000fed90000 type: 2
[    0.000000] copy_e820_map() start: 00000000fee00000 size: 0000000000001000 end: 00000000fee01000 type: 2
[    0.000000] copy_e820_map() start: 00000000ff000000 size: 0000000001000000 end: 0000000100000000 type: 2
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
[    0.000000]  BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000dc000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000003fe70000 (usable)
[    0.000000]  BIOS-e820: 000000003fe70000 - 000000003ff00000 (ACPI NVS)
[    0.000000]  BIOS-e820: 000000003ff00000 - 0000000040000000 (reserved)
[    0.000000]  BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
[    0.000000]  BIOS-e820: 00000000fec00000 - 00000000fec10000 (reserved)
[    0.000000]  BIOS-e820: 00000000fed14000 - 00000000fed1a000 (reserved)
[    0.000000]  BIOS-e820: 00000000fed1c000 - 00000000fed90000 (reserved)
[    0.000000]  BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
[    0.000000]  BIOS-e820: 00000000ff000000 - 0000000100000000 (reserved)
[    0.000000] 126MB HIGHMEM available.
[    0.000000] 896MB LOWMEM available.
[    0.000000] found SMP MP-table at 000f6480
[    0.000000] Entering add_active_range(0, 0, 261744) 0 entries of 256 used
[    0.000000] sizeof(struct page) = 32
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA             0 ->     4096
[    0.000000]   Normal       4096 ->   229376
[    0.000000]   HighMem    229376 ->   261744
[    0.000000] early_node_map[1] active PFN ranges
[    0.000000]     0:        0 ->   261744
[    0.000000] On node 0 totalpages: 261744
[    0.000000] Node 0 memmap at 0xc1000000 size 8388608 first pfn 0xc1000000
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 4064 pages, LIFO batch:0
[    0.000000]   Normal zone: 1760 pages used for memmap
[    0.000000]   Normal zone: 223520 pages, LIFO batch:31
[    0.000000]   HighMem zone: 252 pages used for memmap
[    0.000000]   HighMem zone: 32116 pages, LIFO batch:7
[    0.000000] DMI present.
[    0.000000] ACPI: RSDP @ 0x000f63b0/0x0014 (v000 PTLTD )
[    0.000000] ACPI: RSDT @ 0x3fe764ef/0x0048 (v001   Sony       N0 0x20060710 PTL  0x00000000)
[    0.000000] ACPI: FACP @ 0x3fe7ddde/0x0084 (v002   Sony       N0 0x20060710 PTL  0x0000005A)
[    0.000000] ACPI: DSDT @ 0x3fe77e33/0x5FAB (v001   Sony       N0 0x20060710 PTL  0x0100000E)
[    0.000000] ACPI: FACS @ 0x3fe7efc0/0x0040
[    0.000000] ACPI: APIC @ 0x3fe7de62/0x0068 (v001   Sony       N0 0x20060710 PTL  0x0000005A)
[    0.000000] ACPI: BOOT @ 0x3fe7dfd8/0x0028 (v001   Sony       N0 0x20060710 PTL  0x00000001)
[    0.000000] ACPI: MCFG @ 0x3fe7df02/0x003C (v001   Sony       N0 0x20060710 PTL  0x0000005A)
[    0.000000] ACPI: TCPA @ 0x3fe7df3e/0x0032 (v001   Sony       N0 0x20060710 PTL  0x00005A52)
[    0.000000] ACPI: APIC @ 0x3fe7df70/0x0068 (v001   Sony       N0 0x20060710 PTL  0x00000000)
[    0.000000] ACPI: SSDT @ 0x3fe776b1/0x077E (v001   Sony       N0 0x20060710 PTL  0x20050624)
[    0.000000] ACPI: SSDT @ 0x3fe76ee6/0x07CB (v001   Sony       N0 0x20060710 PTL  0x20050624)
[    0.000000] ACPI: SSDT @ 0x3fe76537/0x04E2 (v001   Sony       N0 0x20060710 PTL  0x20050624)
[    0.000000] ACPI: PM-Timer IO Port: 0x1008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] Processor #0 6:15 APIC version 20
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] Processor #1 6:15 APIC version 20
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x01] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 1, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] Allocating PCI resources starting at 50000000 (gap: 40000000:a0000000)
[    0.000000] Detected 1833.542 MHz processor.
[   12.656208] Built 1 zonelists.  Total pages: 259700
[   12.656213] Kernel command line: root=/dev/sda3 ro vga=extended resume=/dev/sda5 clocksource=pmtmr
[   12.656378] mapped APIC to ffffd000 (fee00000)
[   12.656380] mapped IOAPIC to ffffc000 (fec00000)
[   12.656383] Enabling fast FPU save and restore... done.
[   12.656385] Enabling unmasked SIMD FPU exception support... done.
[   12.656391] Initializing CPU#0
[   12.656448] PID hash table entries: 4096 (order: 12, 16384 bytes)
[   12.661847] Console: colour VGA+ 80x50
[   12.667663] Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
[   12.668011] Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
[   12.688698] Memory: 1034188k/1046976k available (1867k kernel code, 12244k reserved, 684k data, 212k init, 129472k highmem)
[   12.688800] virtual kernel memory layout:
[   12.688801]     fixmap  : 0xfff9d000 - 0xfffff000   ( 392 kB)
[   12.688802]     pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
[   12.688803]     vmalloc : 0xf8800000 - 0xff7fe000   ( 111 MB)
[   12.688804]     lowmem  : 0xc0000000 - 0xf8000000   ( 896 MB)
[   12.688805]       .init : 0xc0384000 - 0xc03b9000   ( 212 kB)
[   12.688806]       .data : 0xc02d2cd9 - 0xc037dff4   ( 684 kB)
[   12.688807]       .text : 0xc0100000 - 0xc02d2cd9   (1867 kB)
[   12.689406] Checking if this processor honours the WP bit even in supervisor mode... Ok.
[   12.769590] Calibrating delay using timer specific routine.. 3671.19 BogoMIPS (lpj=7342397)
[   12.769770] Security Framework v1.0.0 initialized
[   12.769849] Capability LSM initialized
[   12.769933] Mount-cache hash table entries: 512
[   12.770090] CPU: After generic identify, caps: bfebfbff 20100000 00000000 00000000 0000e3bd 00000000 00000001
[   12.770097] monitor/mwait feature present.
[   12.770172] using mwait in idle threads.
[   12.770248] CPU: L1 I cache: 32K, L1 D cache: 32K
[   12.770384] CPU: L2 cache: 2048K
[   12.770458] CPU: Physical Processor ID: 0
[   12.770532] CPU: Processor Core ID: 0
[   12.770606] CPU: After all inits, caps: bfebfbff 20100000 00000000 00003940 0000e3bd 00000000 00000001
[   12.770612] Intel machine check architecture supported.
[   12.770690] Intel machine check reporting enabled on CPU#0.
[   12.770770] Compat vDSO mapped to ffffe000.
[   12.770852] Checking 'hlt' instruction... OK.
[   12.785704] SMP alternatives: switching to UP code
[   12.785933] ACPI: Core revision 20070126
[   12.792086] Parsing all Control Methods:
[   12.792319] Table [DSDT](id 0001) - 923 Objects with 104 Devices 193 Methods 29 Regions
[   12.792608] Parsing all Control Methods:
[   12.792798] Table [SSDT](id 0002) - 13 Objects with 3 Devices 4 Methods 0 Regions
[   12.793091] Parsing all Control Methods:
[   12.793284] Table [SSDT](id 0003) - 14 Objects with 3 Devices 5 Methods 0 Regions
[   12.793588] Parsing all Control Methods:
[   12.793782] Table [SSDT](id 0004) - 13 Objects with 0 Devices 4 Methods 0 Regions
[   12.793941]  tbxface-0586 [02] tb_load_namespace     : ACPI Tables successfully acquired
[   12.797708] evxfevnt-0091 [02] enable                : Transition to ACPI mode successful
[   12.797933] CPU0: Intel(R) Core(TM)2 CPU         T5600  @ 1.83GHz stepping 06
[   12.798140] SMP alternatives: switching to SMP code
[   12.798232] Booting processor 1/1 eip 3000
[   12.808821] Initializing CPU#1
[   12.889486] Calibrating delay using timer specific routine.. 3667.19 BogoMIPS (lpj=7334396)
[   12.889492] CPU: After generic identify, caps: bfebfbff 20100000 00000000 00000000 0000e3bd 00000000 00000001
[   12.889497] monitor/mwait feature present.
[   12.889499] CPU: L1 I cache: 32K, L1 D cache: 32K
[   12.889501] CPU: L2 cache: 2048K
[   12.889503] CPU: Physical Processor ID: 0
[   12.889504] CPU: Processor Core ID: 1
[   12.889506] CPU: After all inits, caps: bfebfbff 20100000 00000000 00003940 0000e3bd 00000000 00000001
[   12.889510] Intel machine check architecture supported.
[   12.889513] Intel machine check reporting enabled on CPU#1.
[   12.889861] CPU1: Intel(R) Core(TM)2 CPU         T5600  @ 1.83GHz stepping 06
[   12.890742] Total of 2 processors activated (7338.39 BogoMIPS).
[   12.891017] ENABLING IO-APIC IRQs
[   12.891289] ..TIMER: vector=0x31 apic1=0 pin1=2 apic2=-1 pin2=-1
[   13.169253] APIC calibration not consistent with PM Timer: 232ms instead of 100ms
[   13.169344] APIC delta adjusted to PM-Timer: 1041739 (2416977)
[   13.277458] checking TSC synchronization [CPU#0 -> CPU#1]: passed.
[   13.297587] Brought up 2 CPUs
[   13.486037] migration_cost=58
[   13.486405] NET: Registered protocol family 16
[   13.486556] ACPI: bus type pci registered
[   13.486640] PCI: Using MMCONFIG
[   13.487555] Setting up standard PCI resources
[   13.492475] evgpeblk-0952 [04] ev_create_gpe_block   : GPE 00 to 1F [_GPE] 4 regs on int 0x9
[   13.493460] evgpeblk-1049 [03] ev_initialize_gpe_bloc: Found 8 Wake, Enabled 5 Runtime GPEs in this block
[   13.494380] Completing Region/Field/Buffer/Package initialization:.........................................................................
[   13.500284] Initialized 29/29 Regions 4/4 Fields 29/29 Buffers 11/38 Packages (972 nodes)
[   13.500444] Initializing Device/Processor/Thermal objects by executing _INI methods:...
[   13.501726] Executed 3 _INI methods requiring 2 _STA executions (examined 117 objects)
[   13.501901] ACPI: Interpreter enabled
[   13.501975] ACPI: Using IOAPIC for interrupt routing
[   13.502134] Found System \ [ffffffff]
[   13.502189] Found Processor \_PR_.CPU0 [c1907dd8]
[   13.502233] Found Processor \_PR_.CPU1 [c1907dc4]
[   13.502299] Found Device \_SB_ [c19073c4]
[   13.502357] Found Device \_SB_.LID0 [c190da40]
[   13.502421] Found Device \_SB_.PWRB [c190da04]
[   13.502483] Found Device \_SB_.PCI0 [c190d9a0]
[   13.502551] Found Device \_SB_.PCI0.PDRC [c190d7c0]
[   13.502613] Found Device \_SB_.PCI0.PEGP [c190dfcc]
[   13.502679] Found Device \_SB_.PCI0.GFX0 [c190df90]
[   13.502749] Found Device \_SB_.PCI0.HDEF [c190df68]
[   13.502811] Found Device \_SB_.PCI0.RP01 [c190df04]
[   13.502881] Found Device \_SB_.PCI0.RP01.S1F0 [c190de50]
[   13.502950] Found Device \_SB_.PCI0.RP01.S1F1 [c190ddec]
[   13.503017] Found Device \_SB_.PCI0.RP01.S1F2 [c190dd88]
[   13.503092] Found Device \_SB_.PCI0.RP01.S1F3 [c190dd24]
[   13.503159] Found Device \_SB_.PCI0.RP01.S1F4 [c190dcc0]
[   13.503226] Found Device \_SB_.PCI0.RP01.S1F5 [c190dc5c]
[   13.503295] Found Device \_SB_.PCI0.RP01.S1F6 [c190f748]
[   13.503366] Found Device \_SB_.PCI0.RP01.S1F7 [c190f6e4]
[   13.503431] Found Device \_SB_.PCI0.RP02 [c190f66c]
[   13.503604] Found Device \_SB_.PCI0.RP02.WLAN [c190f5b8]
[   13.503670] Found Device \_SB_.PCI0.RP03 [c190f52c]
[   13.503739] Found Device \_SB_.PCI0.RP03.TLAN [c190f464]
[   13.503804] Found Device \_SB_.PCI0.RP04 [c190f414]
[   13.503873] Found Device \_SB_.PCI0.RP04.DLAN [c190f34c]
[   13.503935] Found Device \_SB_.PCI0.RP04.S4F1 [c190f2e8]
[   13.504000] Found Device \_SB_.PCI0.RP04.S4F2 [c190fc0c]
[   13.504063] Found Device \_SB_.PCI0.RP04.S4F3 [c190fbd0]
[   13.504125] Found Device \_SB_.PCI0.RP04.S4F4 [c190fb94]
[   13.504187] Found Device \_SB_.PCI0.RP04.S4F5 [c190fb58]
[   13.504249] Found Device \_SB_.PCI0.RP04.S4F6 [c190fb1c]
[   13.504312] Found Device \_SB_.PCI0.RP04.S4F7 [c190fae0]
[   13.504380] Found Device \_SB_.PCI0.RP05 [c190faa4]
[   13.504443] Found Device \_SB_.PCI0.RP05.EX2P [c190f9dc]
[   13.504505] Found Device \_SB_.PCI0.RP05.S5F1 [c190f978]
[   13.504567] Found Device \_SB_.PCI0.RP05.S5F2 [c190f93c]
[   13.504632] Found Device \_SB_.PCI0.RP05.S5F3 [c190f900]
[   13.504694] Found Device \_SB_.PCI0.RP05.S5F4 [c190f8c4]
[   13.504759] Found Device \_SB_.PCI0.RP05.S5F5 [c190f888]
[   13.504820] Found Device \_SB_.PCI0.RP05.S5F6 [c190f84c]
[   13.504883] Found Device \_SB_.PCI0.RP05.S5F7 [c190f810]
[   13.504948] Found Device \_SB_.PCI0.RP06 [c190f7d4]
[   13.505024] Found Device \_SB_.PCI0.RP06.S6F0 [c190ffa4]
[   13.505093] Found Device \_SB_.PCI0.RP06.S6F1 [c190ff40]
[   13.505168] Found Device \_SB_.PCI0.RP06.S6F2 [c190fedc]
[   13.505236] Found Device \_SB_.PCI0.RP06.S6F3 [c190fe78]
[   13.505306] Found Device \_SB_.PCI0.RP06.S6F4 [c190fe14]
[   13.505375] Found Device \_SB_.PCI0.RP06.S6F5 [c190fdb0]
[   13.505444] Found Device \_SB_.PCI0.RP06.S6F6 [c190fd4c]
[   13.505513] Found Device \_SB_.PCI0.RP06.S6F7 [c190fce8]
[   13.505586] Found Device \_SB_.PCI0.USB1 [c190fc70]
[   13.505657] Found Device \_SB_.PCI0.USB2 [c1910748]
[   13.505728] Found Device \_SB_.PCI0.USB3 [c19106d0]
[   13.505798] Found Device \_SB_.PCI0.USB4 [c1910658]
[   13.505869] Found Device \_SB_.PCI0.USB7 [c19105e0]
[   13.505932] Found Device \_SB_.PCI0.USB7.HUB7 [c19105b8]
[   13.505999] Found Device \_SB_.PCI0.USB7.HUB7.PRT1 [c1910590]
[   13.506061] Found Device \_SB_.PCI0.USB7.HUB7.PRT2 [c1910568]
[   13.506124] Found Device \_SB_.PCI0.USB7.HUB7.PRT3 [c1910540]
[   13.506187] Found Device \_SB_.PCI0.USB7.HUB7.PRT4 [c1910518]
[   13.506251] Found Device \_SB_.PCI0.USB7.HUB7.PRT5 [c19104f0]
[   13.506313] Found Device \_SB_.PCI0.USB7.HUB7.PRT6 [c19104c8]
[   13.506378] Found Device \_SB_.PCI0.USB7.HUB7.PRT7 [c19104a0]
[   13.506441] Found Device \_SB_.PCI0.USB7.HUB7.PRT8 [c1910478]
[   13.506508] Found Device \_SB_.PCI0.PCIB [c191043c]
[   13.506581] Found Device \_SB_.PCI0.PCIB.SLT0 [c1910414]
[   13.506652] Found Device \_SB_.PCI0.PCIB.LANC [c19103d8]
[   13.506821] Found Device \_SB_.PCI0.PCIB.CRD2 [c191039c]
[   13.506894] Found Device \_SB_.PCI0.PCIB.S294 [c19102c0]
[   13.506957] Found Device \_SB_.PCI0.PCIB.MST2 [c1910bf8]
[   13.507126] Found Device \_SB_.PCI0.PCIB.CRD0 [c1910bd0]
[   13.507195] Found Device \_SB_.PCI0.PCIB.SD94 [c1910af4]
[   13.507260] Found Device \_SB_.PCI0.PCIB.MMST [c1910acc]
[   13.507323] Found Device \_SB_.PCI0.AUD0 [c1910a90]
[   13.507390] Found Device \_SB_.PCI0.MODM [c1910a68]
[   13.507456] Found Device \_SB_.PCI0.LPCB [c1910a40]
[   13.507672] Found Device \_SB_.PCI0.LPCB.LNKA [c19108ec]
[   13.507870] Found Device \_SB_.PCI0.LPCB.LNKB [c191084c]
[   13.508068] Found Device \_SB_.PCI0.LPCB.LNKC [c19107ac]
[   13.508263] Found Device \_SB_.PCI0.LPCB.LNKD [c1910f90]
[   13.508462] Found Device \_SB_.PCI0.LPCB.LNKE [c1910ef0]
[   13.508659] Found Device \_SB_.PCI0.LPCB.LNKF [c1910e50]
[   13.508854] Found Device \_SB_.PCI0.LPCB.LNKG [c1910db0]
[   13.509051] Found Device \_SB_.PCI0.LPCB.LNKH [c1910d10]
[   13.509125] Found Device \_SB_.PCI0.LPCB.EC0_ [c1910c70]
[   13.513058] Found Device \_SB_.PCI0.LPCB.EC0_.BAT1 [c1911a18]
[   13.513223] Found Device \_SB_.PCI0.LPCB.EC0_.ACAD [c1911950]
[   13.513283] Found Device \_SB_.PCI0.LPCB.DMAC [c19118ec]
[   13.513344] Found Device \_SB_.PCI0.LPCB.FWHD [c19118b0]
[   13.513500] Found Device \_SB_.PCI0.LPCB.IPIC [c19117fc]
[   13.513560] Found Device \_SB_.PCI0.LPCB.MATH [c19117c0]
[   13.513620] Found Device \_SB_.PCI0.LPCB.LDRC [c1911784]
[   13.513685] Found Device \_SB_.PCI0.LPCB.RTC_ [c1911f90]
[   13.513744] Found Device \_SB_.PCI0.LPCB.TIMR [c1911f54]
[   13.513927] Found Device \_SB_.PCI0.LPCB.TPM_ [c1911f18]
[   13.517907] Found Device \_SB_.PCI0.LPCB.SPIC [c1911ea0]
[   13.517973] Found Device \_SB_.PCI0.LPCB.SNC_ [c1911dd8]
[   13.518038] Found Device \_SB_.PCI0.LPCB.PS2K [c1913748]
[   13.518103] Found Device \_SB_.PCI0.LPCB.PS2M [c191370c]
[   13.518178] Found Device \_SB_.PCI0.PATA [c19136bc]
[   13.518246] Found Device \_SB_.PCI0.PATA.PRID [c19135a4]
[   13.518309] Found Device \_SB_.PCI0.PATA.PRID.P_D0 [c1913554]
[   13.518372] Found Device \_SB_.PCI0.PATA.PRID.P_D1 [c1913518]
[   13.518438] Found Device \_SB_.PCI0.SATA [c191348c]
[   13.518513] Found Device \_SB_.PCI0.SATA.PRID [c19139dc]
[   13.518575] Found Device \_SB_.PCI0.SATA.PRID.P_D0 [c191398c]
[   13.518637] Found Device \_SB_.PCI0.SATA.PRID.P_D1 [c1913950]
[   13.518701] Found Device \_SB_.PCI0.SATA.SECD [c19138d8]
[   13.518765] Found Device \_SB_.PCI0.SATA.SECD.S_D0 [c1913888]
[   13.518828] Found Device \_SB_.PCI0.SATA.SECD.S_D1 [c1913838]
[   13.518896] Found Device \_SB_.PCI0.SBUS [c1913310]
[   13.520899] Found Thermal Zone \_TZ_ [c190739c]
[   13.520948] Found Thermal Zone \_TZ_.ATF0 [c190d4a0]
[   13.520996] Found Thermal Zone \_TZ_.DTS0 [c190d3ec]
[   13.521042] Found Thermal Zone \_TZ_.DTS1 [c190d34c]
[   13.521395] ACPI: PCI Root Bridge [PCI0] (0000:00)
[   13.522092] PCI quirk: region 1000-107f claimed by ICH6 ACPI/GPIO/TCO
[   13.522172] PCI quirk: region 1180-11bf claimed by ICH6 GPIO
[   13.522488] Boot video device is 0000:01:00.0
[   13.523508] PCI: Transparent bridge - 0000:00:1e.0
[   13.523649] PCI: Bus #0a (-#0d) is hidden behind transparent bridge #09 (-#0a) (try 'pci=assign-busses')
[   13.528498] Please report the result to linux-kernel to fix this permanently
[   13.528651] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[   13.529228] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEGP._PRT]
[   13.529473] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.RP01._PRT]
[   13.529721] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.RP02._PRT]
[   13.529956] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.RP03._PRT]
[   13.530192] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.RP04._PRT]
[   13.530461] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCIB._PRT]
[   13.537398] ACPI: PCI Interrupt Link [LNKA] (IRQs 10) *5
[   13.537878] ACPI: PCI Interrupt Link [LNKB] (IRQs *10)
[   13.538297] ACPI: PCI Interrupt Link [LNKC] (IRQs *10)
[   13.538715] ACPI: PCI Interrupt Link [LNKD] (IRQs *10)
[   13.539134] ACPI: PCI Interrupt Link [LNKE] (IRQs 10) *0, disabled.
[   13.539671] ACPI: PCI Interrupt Link [LNKF] (IRQs *10)
[   13.540088] ACPI: PCI Interrupt Link [LNKG] (IRQs *10)
[   13.540506] ACPI: PCI Interrupt Link [LNKH] (IRQs *10)
[   13.540898] Linux Plug and Play Support v0.97 (c) Adam Belay
[   13.540983] pnp: PnP ACPI init
[   13.544418] pnp: PnP ACPI: found 11 devices
[   13.544497] PnPBIOS: Disabled by ACPI PNP
[   13.544687] SCSI subsystem initialized
[   13.544792] libata version 2.00 loaded.
[   13.544845] PCI: Using ACPI for IRQ routing
[   13.544921] PCI: If a device doesn't work, try "pci=routeirq".  If it helps, post a report
[   13.545180] NET: Registered protocol family 8
[   13.545256] NET: Registered protocol family 20
[   13.545371] pnp: 00:01: iomem range 0xe0000000-0xefffffff could not be reserved
[   13.545461] pnp: 00:01: iomem range 0xfed14000-0xfed17fff could not be reserved
[   13.545551] pnp: 00:01: iomem range 0xfed18000-0xfed18fff could not be reserved
[   13.545641] pnp: 00:01: iomem range 0xfed19000-0xfed19fff could not be reserved
[   13.545999] PCI: Failed to allocate mem resource #6:20000@d0000000 for 0000:01:00.0
[   13.546089] PCI: Bridge: 0000:00:01.0
[   13.546163]   IO window: disabled.
[   13.546238]   MEM window: dc000000-ddffffff
[   13.546314]   PREFETCH window: c0000000-cfffffff
[   13.546389] PCI: Bridge: 0000:00:1c.0
[   13.546465]   IO window: 2000-2fff
[   13.546543]   MEM window: d6000000-d7ffffff
[   13.546620]   PREFETCH window: d0000000-d1ffffff
[   13.546699] PCI: Bridge: 0000:00:1c.1
[   13.546773]   IO window: disabled.
[   13.546850]   MEM window: de100000-de1fffff
[   13.546927]   PREFETCH window: disabled.
[   13.547004] PCI: Bridge: 0000:00:1c.2
[   13.547080]   IO window: 3000-3fff
[   13.547158]   MEM window: d8000000-d9ffffff
[   13.547235]   PREFETCH window: d2000000-d3ffffff
[   13.547314] PCI: Bridge: 0000:00:1c.3
[   13.547389]   IO window: 4000-4fff
[   13.547466]   MEM window: da000000-dbffffff
[   13.547544]   PREFETCH window: d4000000-d5ffffff
[   13.547629] PCI: Bus 10, cardbus bridge: 0000:09:04.0
[   13.547705]   IO window: 00005000-000050ff
[   13.547783]   IO window: 00005400-000054ff
[   13.547861]   PREFETCH window: 50000000-53ffffff
[   13.547941]   MEM window: 54000000-57ffffff
[   13.548018] PCI: Bridge: 0000:00:1e.0
[   13.548094]   IO window: 5000-5fff
[   13.548171]   MEM window: de000000-de0fffff
[   13.548249]   PREFETCH window: 50000000-53ffffff
[   13.548335] ACPI: PCI Interrupt 0000:00:01.0[A] -> GSI 16 (level, low) -> IRQ 16
[   13.548484] PCI: Setting latency timer of device 0000:00:01.0 to 64
[   13.548503] ACPI: PCI Interrupt 0000:00:1c.0[A] -> GSI 16 (level, low) -> IRQ 16
[   13.548654] PCI: Setting latency timer of device 0000:00:1c.0 to 64
[   13.548675] ACPI: PCI Interrupt 0000:00:1c.1[B] -> GSI 17 (level, low) -> IRQ 17
[   13.548826] PCI: Setting latency timer of device 0000:00:1c.1 to 64
[   13.548847] ACPI: PCI Interrupt 0000:00:1c.2[C] -> GSI 18 (level, low) -> IRQ 18
[   13.548997] PCI: Setting latency timer of device 0000:00:1c.2 to 64
[   13.549018] ACPI: PCI Interrupt 0000:00:1c.3[D] -> GSI 19 (level, low) -> IRQ 19
[   13.549171] PCI: Setting latency timer of device 0000:00:1c.3 to 64
[   13.549183] PCI: Setting latency timer of device 0000:00:1e.0 to 64
[   13.549205] ACPI: PCI Interrupt 0000:09:04.0[A] -> GSI 20 (level, low) -> IRQ 20
[   13.549378] NET: Registered protocol family 2
[   13.597074] IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
[   13.597225] TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
[   13.597767] TCP bind hash table entries: 65536 (order: 7, 524288 bytes)
[   13.598088] TCP: Hash tables configured (established 131072 bind 65536)
[   13.598166] TCP reno registered
[   13.609250] Simple Boot Flag at 0x37 set to 0x1
[   13.609726] audit: initializing netlink socket (disabled)
[   13.609813] audit(1170412029.500:1): initialized
[   13.609958] highmem bounce pool size: 64 pages
[   13.610151] JFS: nTxBlock = 8080, nTxLock = 64646
[   13.613505] io scheduler noop registered
[   13.613644] io scheduler anticipatory registered
[   13.613778] io scheduler deadline registered
[   13.613922] io scheduler cfq registered (default)
[   13.614399] PCI: Setting latency timer of device 0000:00:01.0 to 64
[   13.614417] assign_interrupt_mode Found MSI capability
[   13.614515] Allocate Port Service[0000:00:01.0:pcie00]
[   13.614551] Allocate Port Service[0000:00:01.0:pcie03]
[   13.614609] PCI: Setting latency timer of device 0000:00:1c.0 to 64
[   13.614661] assign_interrupt_mode Found MSI capability
[   13.614772] Allocate Port Service[0000:00:1c.0:pcie00]
[   13.614800] Allocate Port Service[0000:00:1c.0:pcie02]
[   13.614828] Allocate Port Service[0000:00:1c.0:pcie03]
[   13.614937] PCI: Setting latency timer of device 0000:00:1c.1 to 64
[   13.614989] assign_interrupt_mode Found MSI capability
[   13.615100] Allocate Port Service[0000:00:1c.1:pcie00]
[   13.615132] Allocate Port Service[0000:00:1c.1:pcie02]
[   13.615159] Allocate Port Service[0000:00:1c.1:pcie03]
[   13.615267] PCI: Setting latency timer of device 0000:00:1c.2 to 64
[   13.615318] assign_interrupt_mode Found MSI capability
[   13.615430] Allocate Port Service[0000:00:1c.2:pcie00]
[   13.615458] Allocate Port Service[0000:00:1c.2:pcie02]
[   13.615486] Allocate Port Service[0000:00:1c.2:pcie03]
[   13.615596] PCI: Setting latency timer of device 0000:00:1c.3 to 64
[   13.615648] assign_interrupt_mode Found MSI capability
[   13.615759] Allocate Port Service[0000:00:1c.3:pcie00]
[   13.615792] Allocate Port Service[0000:00:1c.3:pcie02]
[   13.615820] Allocate Port Service[0000:00:1c.3:pcie03]
[   13.616662] ACPI: SSDT @ 0x3fe76cb5/0x01A8 (v001   Sony       N0 0x20060710 PTL  0x20050624)
[   13.616935] Parsing all Control Methods:
[   13.617186] Table [SSDT](id 0075) - 5 Objects with 0 Devices 3 Methods 0 Regions
[   13.617548] ACPI: SSDT @ 0x3fe76a19/0x0217 (v001   Sony       N0 0x20060710 PTL  0x20050624)
[   13.617782] Parsing all Control Methods:
[   13.618024] Table [SSDT](id 0076) - 1 Objects with 0 Devices 1 Methods 0 Regions
[   13.619237] ACPI: CPU0 (power states: C1[C1] C2[C2])
[   13.619491] ACPI: Processor [CPU0] (supports 8 throttling states)
[   13.620251] ACPI: SSDT @ 0x3fe76e5d/0x0089 (v001   Sony       N0 0x20060710 PTL  0x20050624)
[   13.620502] Parsing all Control Methods:
[   13.620746] Table [SSDT](id 007B) - 3 Objects with 0 Devices 3 Methods 0 Regions
[   13.621099] ACPI: SSDT @ 0x3fe76c30/0x0085 (v001   Sony       N0 0x20060710 PTL  0x20050624)
[   13.621333] Parsing all Control Methods:
[   13.621575] Table [SSDT](id 007C) - 1 Objects with 0 Devices 1 Methods 0 Regions
[   13.622492] ACPI: CPU1 (power states: C1[C1] C2[C2])
[   13.622745] ACPI: Processor [CPU1] (supports 8 throttling states)
[   13.626038] isapnp: Scanning for PnP cards...
[   13.980304] isapnp: No Plug & Play device found
[   13.983323] Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing disabled
[   13.984586] RAMDISK driver initialized: 16 RAM disks of 8192K size 1024 blocksize
[   13.984757] Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
[   13.984837] ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
[   13.984956] ICH7: IDE controller at PCI slot 0000:00:1f.1
[   13.985043] ACPI: PCI Interrupt 0000:00:1f.1[B] -> GSI 22 (level, low) -> IRQ 21
[   13.985196] ICH7: chipset revision 2
[   13.985270] ICH7: not 100% native mode: will probe irqs later
[   13.985355]     ide0: BM-DMA at 0x1880-0x1887, BIOS settings: hda:DMA, hdb:pio
[   13.985570] Probing IDE interface ide0...
[   14.718632] hda: MATSHITADVD-RAM UJ-842S, ATAPI CD/DVD-ROM drive
[   15.054051] hda: selected mode 0x42
[   15.054400] ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
[   15.057040] ata_piix 0000:00:1f.2: version 2.00ac7
[   15.057045] ata_piix 0000:00:1f.2: MAP [ P0 P2 XX XX ]
[   15.057415] ata_piix 0000:00:1f.2: invalid MAP value 0
[   15.209918] ACPI: PCI Interrupt 0000:00:1f.2[B] -> GSI 22 (level, low) -> IRQ 21
[   15.210091] PCI: Setting latency timer of device 0000:00:1f.2 to 64
[   15.210146] ata1: SATA max UDMA/133 cmd 0x18C8 ctl 0x18AE bmdma 0x18B0 irq 21
[   15.210259] ata2: SATA max UDMA/133 cmd 0x18C0 ctl 0x18AA bmdma 0x18B8 irq 21
[   15.210348] scsi0 : ata_piix
[   15.384675] ata1.00: ATA-6, max UDMA/100, 195371568 sectors: LBA48 NCQ (depth 0/32)
[   15.384772] ata1.00: ata1: dev 0 multi count 16
[   15.400425] ata1.00: configured for UDMA/100
[   15.400511] scsi1 : ata_piix
[   15.564861] ATA: abnormal status 0x7F on port 0x18C7
[   15.565018] scsi 0:0:0:0: Direct-Access     ATA      TOSHIBA MK1032GS AS02 PQ: 0 ANSI: 5
[   15.565202] SCSI device sda: 195371568 512-byte hdwr sectors (100030 MB)
[   15.565288] sda: Write Protect is off
[   15.565363] sda: Mode Sense: 00 3a 00 00
[   15.565377] SCSI device sda: write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   15.565500] SCSI device sda: 195371568 512-byte hdwr sectors (100030 MB)
[   15.565591] sda: Write Protect is off
[   15.569839] sda: Mode Sense: 00 3a 00 00
[   15.569854] SCSI device sda: write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   15.569945]  sda: sda1 sda2 sda3 sda4 < sda5 sda6 sda7 >
[   15.646086] sd 0:0:0:0: Attached scsi disk sda
[   15.646299] PNP: PS/2 Controller [PNP0303:PS2K,PNP0f13:PS2M] at 0x60,0x64 irq 1,12
[   15.648809] serio: i8042 KBD port at 0x60,0x64 irq 1
[   15.648887] serio: i8042 AUX port at 0x60,0x64 irq 12
[   15.649038] mice: PS/2 mouse device common for all mice
[   15.679204] TCP bic registered
[   15.679286] NET: Registered protocol family 1
[   15.679363] NET: Registered protocol family 17
[   15.679504] Starting balanced_irq
[   15.679583] Using IPI No-Shortcut mode
[   15.680054] ACPI: (supports S0 S3 S4 S5)
[   15.681502] Time: acpi_pm clocksource has been installed.
[   15.681613] Switched to high resolution mode on CPU 0
[   15.681621] Switched to high resolution mode on CPU 1
[   15.689289] input: AT Translated Set 2 keyboard as /class/input/input0
[   15.819666] VFS: Mounted root (jfs filesystem) readonly.
[   15.819891] Freeing unused kernel memory: 212k freed
[   18.061181] ACPI: PCI Interrupt 0000:07:00.0[A] -> GSI 18 (level, low) -> IRQ 18
[   18.061343] PCI: Setting latency timer of device 0000:07:00.0 to 64
[   18.061399] sky2 v1.10 addr 0xd8000000 irq 18 Yukon-FE (0xb7) rev 1
[   18.061602] sky2 eth0: addr 00:13:a9:41:76:84
[   18.184759] Linux agpgart interface v0.102 (c) Dave Jones
[   18.230566] usbcore: registered new interface driver usbfs
[   18.230670] usbcore: registered new interface driver hub
[   18.230790] usbcore: registered new device driver usb
[   18.334957] Real Time Clock Driver v1.12ac
[   18.436259] tpm_inf_pnp 00:07: Found TPM with ID IFX0102
[   18.436392] tpm_inf_pnp 00:07: TPM found: config base 0x2e, io base 0x1670, chip version 0x000b, vendor id 0x15d1 (Infineon), product id 0x000b (SLB 9635 TT 1.2)
[   18.806843] agpgart: Detected an Intel 945GM Chipset.
[   18.824115] agpgart: AGP aperture is 256M @ 0x0
[   18.825199] hda: ATAPI 24X DVD-ROM DVD-R-RAM CD-R/RW drive, 2048kB Cache, UDMA(33)
[   18.825791] Uniform CD-ROM driver Revision: 3.20
[   18.829288] USB Universal Host Controller Interface driver v3.0
[   18.829413] ACPI: PCI Interrupt 0000:00:1d.0[A] -> GSI 19 (level, low) -> IRQ 19
[   18.829603] PCI: Setting latency timer of device 0000:00:1d.0 to 64
[   18.829606] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[   18.829802] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 1
[   18.829948] uhci_hcd 0000:00:1d.0: irq 19, io base 0x00001800
[   18.830061] usb usb1: new device found, idVendor=0000, idProduct=0000
[   18.830151] usb usb1: new device strings: Mfr=3, Product=2, SerialNumber=1
[   18.830233] usb usb1: Product: UHCI Host Controller
[   18.830311] usb usb1: Manufacturer: Linux 2.6.20-rc6-mm3-1 uhci_hcd
[   18.830406] usb usb1: SerialNumber: 0000:00:1d.0
[   18.830554] usb usb1: configuration #1 chosen from 1 choice
[   18.830653] hub 1-0:1.0: USB hub found
[   18.830734] hub 1-0:1.0: 2 ports detected
[   18.839049] input: PC Speaker as /class/input/input1
[   18.934472] ACPI: PCI Interrupt 0000:00:1d.1[B] -> GSI 19 (level, low) -> IRQ 19
[   18.934648] PCI: Setting latency timer of device 0000:00:1d.1 to 64
[   18.934652] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[   18.934760] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 2
[   18.934883] uhci_hcd 0000:00:1d.1: irq 19, io base 0x00001820
[   18.934997] usb usb2: new device found, idVendor=0000, idProduct=0000
[   18.935078] usb usb2: new device strings: Mfr=3, Product=2, SerialNumber=1
[   18.935158] usb usb2: Product: UHCI Host Controller
[   18.935237] usb usb2: Manufacturer: Linux 2.6.20-rc6-mm3-1 uhci_hcd
[   18.935325] usb usb2: SerialNumber: 0000:00:1d.1
[   18.935450] usb usb2: configuration #1 chosen from 1 choice
[   18.935550] hub 2-0:1.0: USB hub found
[   18.935628] hub 2-0:1.0: 2 ports detected
[   19.038311] ACPI: PCI Interrupt 0000:00:1d.2[C] -> GSI 19 (level, low) -> IRQ 19
[   19.038476] PCI: Setting latency timer of device 0000:00:1d.2 to 64
[   19.038480] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[   19.038586] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 3
[   19.038707] uhci_hcd 0000:00:1d.2: irq 19, io base 0x00001840
[   19.038824] usb usb3: new device found, idVendor=0000, idProduct=0000
[   19.038907] usb usb3: new device strings: Mfr=3, Product=2, SerialNumber=1
[   19.038988] usb usb3: Product: UHCI Host Controller
[   19.039067] usb usb3: Manufacturer: Linux 2.6.20-rc6-mm3-1 uhci_hcd
[   19.039147] usb usb3: SerialNumber: 0000:00:1d.2
[   19.039272] usb usb3: configuration #1 chosen from 1 choice
[   19.039372] hub 3-0:1.0: USB hub found
[   19.039452] hub 3-0:1.0: 2 ports detected
[   19.065078] input: PS/2 Mouse as /class/input/input2
[   19.083976] input: AlpsPS/2 ALPS GlidePoint as /class/input/input3
[   19.142238] ACPI: PCI Interrupt 0000:00:1d.3[A] -> GSI 19 (level, low) -> IRQ 19
[   19.142416] PCI: Setting latency timer of device 0000:00:1d.3 to 64
[   19.142420] uhci_hcd 0000:00:1d.3: UHCI Host Controller
[   19.142517] uhci_hcd 0000:00:1d.3: new USB bus registered, assigned bus number 4
[   19.142634] uhci_hcd 0000:00:1d.3: irq 19, io base 0x00001860
[   19.142745] usb usb4: new device found, idVendor=0000, idProduct=0000
[   19.142824] usb usb4: new device strings: Mfr=3, Product=2, SerialNumber=1
[   19.142902] usb usb4: Product: UHCI Host Controller
[   19.142977] usb usb4: Manufacturer: Linux 2.6.20-rc6-mm3-1 uhci_hcd
[   19.143055] usb usb4: SerialNumber: 0000:00:1d.3
[   19.143179] usb usb4: configuration #1 chosen from 1 choice
[   19.143277] hub 4-0:1.0: USB hub found
[   19.143354] hub 4-0:1.0: 2 ports detected
[   19.246296] ACPI: PCI Interrupt 0000:00:1d.7[D] -> GSI 23 (level, low) -> IRQ 22
[   19.246466] PCI: Setting latency timer of device 0000:00:1d.7 to 64
[   19.246469] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[   19.246564] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 5
[   19.246680] ehci_hcd 0000:00:1d.7: debug port 1
[   19.246759] PCI: cache line size of 32 is not supported by device 0000:00:1d.7
[   19.246768] ehci_hcd 0000:00:1d.7: irq 22, io mem 0xde404000
[   19.250743] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
[   19.250843] usb usb5: new device found, idVendor=0000, idProduct=0000
[   19.250921] usb usb5: new device strings: Mfr=3, Product=2, SerialNumber=1
[   19.250999] usb usb5: Product: EHCI Host Controller
[   19.251075] usb usb5: Manufacturer: Linux 2.6.20-rc6-mm3-1 ehci_hcd
[   19.251152] usb usb5: SerialNumber: 0000:00:1d.7
[   19.251271] usb usb5: configuration #1 chosen from 1 choice
[   19.251367] hub 5-0:1.0: USB hub found
[   19.251446] hub 5-0:1.0: 8 ports detected
[   19.277992] usb 2-2: new full speed USB device using uhci_hcd and address 2
[   19.354179] Yenta: CardBus bridge found at 0000:09:04.0 [104d:81e6]
[   19.354284] Yenta: Using CSCINT to route CSC interrupts to PCI
[   19.354364] Yenta: Routing CardBus interrupts to PCI
[   19.354448] Yenta TI: socket 0000:09:04.0, mfunc 0x01a21b22, devctl 0x64
[   19.586447] Yenta: ISA IRQ mask 0x0cf8, PCI irq 20
[   19.586529] Socket status: 30000006
[   19.586604] Yenta: Raising subordinate bus# of parent bus (#09) from #0a to #0d
[   19.586697] pcmcia: parent PCI bridge I/O window: 0x5000 - 0x5fff
[   19.586775] cs: IO port probe 0x5000-0x5fff: clean.
[   19.587174] pcmcia: parent PCI bridge Memory window: 0xde000000 - 0xde0fffff
[   19.587253] pcmcia: parent PCI bridge Memory window: 0x50000000 - 0x53ffffff
[   19.588679] ACPI: PCI Interrupt 0000:09:04.2[C] -> GSI 22 (level, low) -> IRQ 21
[   19.589299] ACPI: PCI Interrupt 0000:00:1b.0[A] -> GSI 21 (level, low) -> IRQ 23
[   19.589466] PCI: Setting latency timer of device 0000:00:1b.0 to 64
[   19.933584] cs: IO port probe 0x100-0x3af: clean.
[   19.935977] cs: IO port probe 0x3e0-0x4ff: excluding 0x4d0-0x4d7
[   19.937170] cs: IO port probe 0x820-0x8ff: clean.
[   19.938154] cs: IO port probe 0xc00-0xcf7: clean.
[   19.939237] cs: IO port probe 0xa00-0xaff: clean.
[   20.093211] usb 5-4: new high speed USB device using ehci_hcd and address 2
[   20.271285] Adding 979924k swap on /dev/sda5.  Priority:-1 extents:1 across:979924k
[   20.288742] usb 5-4: new device found, idVendor=054c, idProduct=0281
[   20.288838] usb 5-4: new device strings: Mfr=1, Product=2, SerialNumber=3
[   20.288922] usb 5-4: Product: UMH-U09
[   20.289027] usb 5-4: Manufacturer: Sony
[   20.289105] usb 5-4: SerialNumber: F000001C9B3A
[   20.293450] usb 5-4: configuration #1 chosen from 1 choice
[   20.345108] Initializing USB Mass Storage driver...
[   20.772574] usb 5-6: new high speed USB device using ehci_hcd and address 4
[   20.905671] usb 5-6: new device found, idVendor=05ca, idProduct=1830
[   20.905758] usb 5-6: new device strings: Mfr=0, Product=0, SerialNumber=0
[   20.905960] usb 5-6: configuration #1 chosen from 1 choice
[   21.328108] scsi2 : SCSI emulation for USB Mass Storage devices
[   21.328262] usb-storage: device found at 2
[   21.328264] usb-storage: waiting for device to settle before scanning
[   21.328279] usbcore: registered new interface driver usb-storage
[   21.328360] USB Mass Storage support registered.
[   21.567772] usb 3-1: new full speed USB device using uhci_hcd and address 2
[   21.744417] usb 3-1: new device found, idVendor=0483, idProduct=2016
[   21.744506] usb 3-1: new device strings: Mfr=1, Product=2, SerialNumber=0
[   21.744590] usb 3-1: Product: Biometric Coprocessor
[   21.744681] usb 3-1: Manufacturer: STMicroelectronics
[   21.744828] usb 3-1: configuration #1 chosen from 1 choice
[   21.952816] loop: loaded (max 8 devices)
[   21.983379] usb 4-1: new low speed USB device using uhci_hcd and address 2
[   22.001582] ACPI Sony Notebook Control Driver v0.3 successfully installed
[   22.019053] sonypi: Sony Programmable I/O Controller Driver v1.26.
[   22.019225] sonypi: detected type3 model, verbose = 0, fnkeyinit = off, camera = off, compat = off, mask = 0xffffffff, useinput = on, acpi = on
[   22.019342] sonypi: enabled at irq=11, port1=0x1080, port2=0x1084
[   22.019422] sonypi: device allocated minor is 63
[   22.019537] input: Sony Vaio Jogdial as /class/input/input4
[   22.019674] input: Sony Vaio Keys as /class/input/input5
[   22.106584] device-mapper: ioctl: 4.11.0-ioctl (2006-10-12) initialised: dm-devel@redhat.com
[   22.136391] usb 4-1: new device found, idVendor=054c, idProduct=01bb
[   22.136479] usb 4-1: new device strings: Mfr=0, Product=0, SerialNumber=0
[   22.136664] usb 4-1: configuration #1 chosen from 1 choice
[   22.379003] usb 4-2: new full speed USB device using uhci_hcd and address 3
[   22.584979] usb 4-2: new device found, idVendor=044e, idProduct=300c
[   22.585076] usb 4-2: new device strings: Mfr=1, Product=2, SerialNumber=0
[   22.585160] usb 4-2: Product: UGX
[   22.585249] usb 4-2: Manufacturer: ALPS
[   22.585399] usb 4-2: configuration #1 chosen from 1 choice
[   22.670906] Bluetooth: Core ver 2.11
[   22.671035] NET: Registered protocol family 31
[   22.671114] Bluetooth: HCI device and connection manager initialized
[   22.671199] Bluetooth: HCI socket layer initialized
[   22.688799] Bluetooth: HCI USB driver ver 2.9
[   22.691978] usbcore: registered new interface driver hci_usb
[   26.332403] scsi 2:0:0:0: Direct-Access     Sony     USB   HS-CARD    4.52 PQ: 0 ANSI: 0
[   26.382660] sd 2:0:0:0: Attached scsi removable disk sdb
[   26.383857] usb-storage: device scan complete
[   32.697299] sky2 eth0: enabling interface
[   32.699562] sky2 eth0: ram buffer 4K
[   34.363018] sky2 eth0: Link is up at 100 Mbps, half duplex, flow control none
[   34.858053] ip_tables: (C) 2000-2006 Netfilter Core Team
[   38.536595] SysRq : Show Pending Timers
[   38.536753] Timer List Version: v0.3
[   38.536832] HRTIMER_MAX_CLOCK_BASES: 2
[   38.536921] now at 25625437072 nsecs
[   38.536995] 
[   38.536995] cpu: 0
[   38.537138]  clock 0:
[   38.537210]   .index:      0
[   38.537283]   .resolution: 1 nsecs
[   38.537357]   .get_time:   ktime_get_real
[   38.537552]   .offset:     1170412030250277102 nsecs
[   38.537627] active timers:
[   38.537700]  clock 1:
[   38.537772]   .index:      1
[   38.537845]   .resolution: 1 nsecs
[   38.537919]   .get_time:   ktime_get
[   38.538110]   .offset:     0 nsecs
[   38.538184] active timers:
[   38.538257]  #0: <c037fd90>, tick_sched_timer, S:01
[   38.538632]  # expires at 25744000000 nsecs [in 118562928 nsecs]
[   38.538709]   .expires_next   : 25744000000 nsecs
[   38.538785]   .hres_active    : 1
[   38.538858]   .nr_events      : 832
[   38.538932]   .nohz_mode      : 2
[   38.539006]   .idle_tick      : 25600000000 nsecs
[   38.539081]   .tick_stopped   : 1
[   38.539155]   .idle_jiffies   : 4294898695
[   38.539230]   .idle_calls     : 8136
[   38.539303]   .idle_sleeps    : 2806
[   38.539377]   .idle_entrytime : 25599683442 nsecs
[   38.539453]   .idle_sleeptime : 21020446767 nsecs
[   38.539528]   .last_jiffies   : 4294898695
[   38.539603]   .next_jiffies   : 4294898732
[   38.539678]   .idle_expires   : 25744000000 nsecs
[   38.539754] jiffies: 4294898702
[   38.539827] 
[   38.539827] cpu: 1
[   38.539970]  clock 0:
[   38.540042]   .index:      0
[   38.540114]   .resolution: 1 nsecs
[   38.540188]   .get_time:   ktime_get_real
[   38.540381]   .offset:     1170412030250277102 nsecs
[   38.540456] active timers:
[   38.540529]  clock 1:
[   38.540601]   .index:      1
[   38.540674]   .resolution: 1 nsecs
[   38.540747]   .get_time:   ktime_get
[   38.540939]   .offset:     0 nsecs
[   38.541012] active timers:
[   38.541085]  #0: <c037fd90>, tick_sched_timer, S:01
[   38.541456]  # expires at 25804000000 nsecs [in 178562928 nsecs]
[   38.541534]   .expires_next   : 25804000000 nsecs
[   38.541609]   .hres_active    : 1
[   38.541682]   .nr_events      : 309
[   38.541756]   .nohz_mode      : 2
[   38.541830]   .idle_tick      : 23808000000 nsecs
[   38.541905]   .tick_stopped   : 1
[   38.541980]   .idle_jiffies   : 4294898247
[   38.542054]   .idle_calls     : 1120
[   38.542128]   .idle_sleeps    : 599
[   38.542202]   .idle_entrytime : 23804134269 nsecs
[   38.542278]   .idle_sleeptime : 20142520988 nsecs
[   38.542354]   .last_jiffies   : 4294898247
[   38.542428]   .next_jiffies   : 4294898747
[   38.542503]   .idle_expires   : 25804000000 nsecs
[   38.542579] jiffies: 4294898702
[   38.542652] 
[   38.542723] 
[   38.542724] Tick Device: mode:     1
[   38.542868] Clock Event Device: pit
[   38.543000]  max_delta_ns:   27461866
[   38.543074]  min_delta_ns:   12571
[   38.543148]  mult:           5124677
[   38.543222]  shift:          32
[   38.543296]  mode:           3
[   38.543369]  next_event:     25744000000 nsecs
[   38.543444]  set_next_event: pit_next_event
[   38.543637]  set_mode:       init_pit_timer
[   38.543830]  event_handler:  tick_handle_oneshot_broadcast
[   38.544025] tick_broadcast_mask: 00000003
[   38.544100] tick_broadcast_oneshot_mask: 00000003
[   38.544175] 
[   38.544246] 
[   38.544247] Tick Device: mode:     1
[   38.544391] Clock Event Device: lapic
[   38.544523]  max_delta_ns:   805300686
[   38.544597]  min_delta_ns:   1439
[   38.544671]  mult:           44739553
[   38.544745]  shift:          32
[   38.544818]  mode:           1
[   38.544892]  next_event:     25744000000 nsecs
[   38.544966]  set_next_event: lapic_next_event
[   38.545161]  set_mode:       lapic_timer_setup
[   38.545354]  event_handler:  hrtimer_interrupt
[   38.545546] 
[   38.545547] Tick Device: mode:     1
[   38.545690] Clock Event Device: lapic
[   38.545823]  max_delta_ns:   805300686
[   38.545897]  min_delta_ns:   1439
[   38.545971]  mult:           44739553
[   38.546045]  shift:          32
[   38.546118]  mode:           1
[   38.546191]  next_event:     25804000000 nsecs
[   38.546266]  set_next_event: lapic_next_event
[   38.546459]  set_mode:       lapic_timer_setup
[   38.546651]  event_handler:  hrtimer_interrupt
[   38.546844] 
[   43.097678] NET: Registered protocol family 10
[   54.028419] eth0: no IPv6 routers present
[   72.783796] Netfilter messages via NETLINK v0.30.
[   72.792104] nf_conntrack version 0.5.0 (8179 buckets, 65432 max)
[   93.040358] SysRq : Show Pending Timers
[   93.040516] Timer List Version: v0.3
[   93.040596] HRTIMER_MAX_CLOCK_BASES: 2
[   93.040684] now at 80181794744 nsecs
[   93.040759] 
[   93.040759] cpu: 0
[   93.040901]  clock 0:
[   93.040973]   .index:      0
[   93.041046]   .resolution: 1 nsecs
[   93.041119]   .get_time:   ktime_get_real
[   93.041315]   .offset:     1170412030250277102 nsecs
[   93.041391] active timers:
[   93.041463]  clock 1:
[   93.041536]   .index:      1
[   93.041608]   .resolution: 1 nsecs
[   93.041681]   .get_time:   ktime_get
[   93.041873]   .offset:     0 nsecs
[   93.041947] active timers:
[   93.042020]  #0: <c037fd90>, tick_sched_timer, S:01
[   93.042396]  # expires at 80244000000 nsecs [in 62205256 nsecs]
[   93.042474]   .expires_next   : 80244000000 nsecs
[   93.042549]   .hres_active    : 1
[   93.042623]   .nr_events      : 1384
[   93.042697]   .nohz_mode      : 2
[   93.042770]   .idle_tick      : 80164000000 nsecs
[   93.042846]   .tick_stopped   : 1
[   93.042920]   .idle_jiffies   : 4294912337
[   93.042995]   .idle_calls     : 24765
[   93.043069]   .idle_sleeps    : 5493
[   93.043143]   .idle_entrytime : 80176068269 nsecs
[   93.043219]   .idle_sleeptime : 75405772638 nsecs
[   93.043295]   .last_jiffies   : 4294912340
[   93.043369]   .next_jiffies   : 4294912357
[   93.043444]   .idle_expires   : 80244000000 nsecs
[   93.043520] jiffies: 4294912341
[   93.043593] 
[   93.043594] cpu: 1
[   93.047898]  clock 0:
[   93.047970]   .index:      0
[   93.048043]   .resolution: 1 nsecs
[   93.048117]   .get_time:   ktime_get_real
[   93.048310]   .offset:     1170412030250277102 nsecs
[   93.048386] active timers:
[   93.048459]  clock 1:
[   93.048531]   .index:      1
[   93.048604]   .resolution: 1 nsecs
[   93.048677]   .get_time:   ktime_get
[   93.048868]   .offset:     0 nsecs
[   93.048942] active timers:
[   93.049015]  #0: <c037fd90>, tick_sched_timer, S:01
[   93.049387]  # expires at 81804000000 nsecs [in 1622205256 nsecs]
[   93.049465]   .expires_next   : 81804000000 nsecs
[   93.049540]   .hres_active    : 1
[   93.049613]   .nr_events      : 344
[   93.049687]   .nohz_mode      : 2
[   93.049761]   .idle_tick      : 79808000000 nsecs
[   93.049836]   .tick_stopped   : 1
[   93.049910]   .idle_jiffies   : 4294912247
[   93.049984]   .idle_calls     : 1211
[   93.050059]   .idle_sleeps    : 689
[   93.050132]   .idle_entrytime : 79804094667 nsecs
[   93.050208]   .idle_sleeptime : 76115837652 nsecs
[   93.050283]   .last_jiffies   : 4294912247
[   93.050358]   .next_jiffies   : 4294912747
[   93.050432]   .idle_expires   : 81804000000 nsecs
[   93.050508] jiffies: 4294912341
[   93.050581] 
[   93.050652] 
[   93.050653] Tick Device: mode:     1
[   93.050796] Clock Event Device: pit
[   93.050929]  max_delta_ns:   27461866
[   93.051004]  min_delta_ns:   12571
[   93.051077]  mult:           5124677
[   93.051151]  shift:          32
[   93.051224]  mode:           3
[   93.051297]  next_event:     80244000000 nsecs
[   93.051372]  set_next_event: pit_next_event
[   93.051566]  set_mode:       init_pit_timer
[   93.051758]  event_handler:  tick_handle_oneshot_broadcast
[   93.051953] tick_broadcast_mask: 00000003
[   93.052027] tick_broadcast_oneshot_mask: 00000003
[   93.052103] 
[   93.052174] 
[   93.052174] Tick Device: mode:     1
[   93.052318] Clock Event Device: lapic
[   93.052451]  max_delta_ns:   805300686
[   93.052525]  min_delta_ns:   1439
[   93.052599]  mult:           44739553
[   93.052673]  shift:          32
[   93.052746]  mode:           1
[   93.052819]  next_event:     80244000000 nsecs
[   93.052894]  set_next_event: lapic_next_event
[   93.053088]  set_mode:       lapic_timer_setup
[   93.053280]  event_handler:  hrtimer_interrupt
[   93.053473] 
[   93.053474] Tick Device: mode:     1
[   93.053618] Clock Event Device: lapic
[   93.053750]  max_delta_ns:   805300686
[   93.053824]  min_delta_ns:   1439
[   93.053898]  mult:           44739553
[   93.053972]  shift:          32
[   93.054045]  mode:           1
[   93.054118]  next_event:     81804000000 nsecs
[   93.054193]  set_next_event: lapic_next_event
[   93.054386]  set_mode:       lapic_timer_setup
[   93.054578]  event_handler:  hrtimer_interrupt
[   93.054771] 
[  163.063574] ACPI: Battery Slot [BAT1] (battery present)
[  163.071194] ACPI: AC Adapter [ACAD] (on-line)
[  163.079679] input: Lid Switch as /class/input/input6
[  163.079854] ACPI: Lid Switch [LID0]
[  163.080022] input: Power Button (CM) as /class/input/input7
[  163.080174] ACPI: Power Button (CM) [PWRB]
[  163.113964] ACPI: Thermal Zone [ATF0] (47 C)
[  163.115124] ACPI: Thermal Zone [DTS0] (47 C)
[  163.116289] ACPI: Thermal Zone [DTS1] (51 C)
[  166.417461] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[  166.517243] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
[  166.517485] NFSD: starting 90-second grace period
[  168.733062] Bluetooth: L2CAP ver 2.8
[  168.733160] Bluetooth: L2CAP socket layer initialized
[  168.996893] Bluetooth: RFCOMM socket layer initialized
[  168.997001] Bluetooth: RFCOMM TTY layer initialized
[  168.997090] Bluetooth: RFCOMM ver 1.8


-- 
mattia
:wq!
