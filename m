From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH 00/13] mvneta Buffer Management and enhancements
Date: Wed, 02 Dec 2015 11:40:22 +0100
Message-ID: <87si3l2kx5.fsf@free-electrons.com>
References: <1448178839-3541-1-git-send-email-mw@semihalf.com>
	<87lh9f4dbt.fsf@free-electrons.com>
	<CAPv3WKc+HbirDxKy5n6W5O5BUTDEc3X5et5dTKdp81WOXjphGg@mail.gmail.com>
	<874mg248jf.fsf@free-electrons.com>
	<CAPv3WKc8VrgH+aAfHBMwvuOxP17SnXCajtzpxmXf4rt+WFcE-w@mail.gmail.com>
	<CAPv3WKdAhk71HW8nvMWXUApySE5_WNgx4PDrj4+R4Tv6FVGNqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Jason Cooper <jason@lakedaemon.net>,
	Yair Mahalalel <myair@marvell.com>, netdev@vger.kernel.org,
	Simon Guinot <simon.guinot@sequanux.org>,
	linux-kernel@vger.kernel.org, Evan Wang <xswang@marvell.com>,
	Tomasz Nowicki <tn@semihalf.com>, nadavh@marvell.com,
	Lior Amsalem <alior@marvell.com>,
	Grzegorz Jaszczyk <jaz@semihalf.com>, nitroshift@yahoo.com,
	"David S. Miller" <davem@davemloft.net>,
	"linux-arm-kernel\@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Marcin Wojtas <mw@semihalf.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPv3WKdAhk71HW8nvMWXUApySE5_WNgx4PDrj4+R4Tv6FVGNqA@mail.gmail.com>
	(Marcin Wojtas's message of "Wed, 2 Dec 2015 00:34:46 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marcin,
=20
 On mer., d=C3=A9c. 02 2015, Marcin Wojtas <mw@semihalf.com> wrote:

> Gregory,
>
> Please apply below patch:
> http://pastebin.com/t42xyU3i
> It will confirm if there's an overflow for CS0 size in your setup.
> Please let know.

Indeed it is an overflow. In v4.0 the size was correct because it was n=
o
longer compute as is: w->size =3D (size | ~DDR_SIZE_MASK) + 1;

But the commit was reverted because it caused other issues.


>
> So far the issue may have been not noticed, because in every IO drive=
r
> using mvebu_mbus_dram_info for configuring MBUS windows, there's
> following substraction:
> (cs->size - 1) & 0xfffff000
>
> I think there are two options:
> 1. Change size type to u64.

If we switch to u64 we really must pay attention to be sure that it
won't be used to be written in a register, but the regsiter remains
32bits.

> 2. Change condition in mvebu_mbus_get_dram_win_info to:
> if (cs->base <=3D phyaddr && phyaddr <=3D (cs->base + cs->size -1))

I think it would be the best solution.

Gregory

>
> I'm looking forward to your information and opinion.
>
> Best regards,
> Marcin
>
> 2015-12-01 22:40 GMT+01:00 Marcin Wojtas <mw@semihalf.com>:
>> Hi Gregory,
>>
>> Thanks for the log. I think it may be an overall problem with 4GB si=
ze
>> representation in mvebu_mbus_dram_info structure? Maybe whole DRAM
>> space is associated to CS0, and the 4GB size (0x1 0000 0000) does no=
t
>> fit u32 variable?
>>
>> Best regards,
>> Marcin
>>
>> 2015-12-01 14:12 GMT+01:00 Gregory CLEMENT <gregory.clement@free-ele=
ctrons.com>:
>>> Hi Marcin,
>>>
>>>  On lun., nov. 30 2015, Marcin Wojtas <mw@semihalf.com> wrote:
>>> [...]
>>>>>> 5. Enable BM on Armada XP and 38X development boards - those one=
s and
>>>>>> A370 I could check on my own. In all cases they survived night-l=
ong
>>>>>> linerate iperf. Also tests were performed with A388 SoC working =
as a
>>>>>> network bridge between two packet generators. They showed increa=
se of
>>>>>> maximum processed 64B packets by ~20k (~555k packets with BM ena=
bled
>>>>>> vs ~535 packets without BM). Also when pushing 1500B-packets wit=
h a
>>>>>> line rate achieved, CPU load decreased from around 25% without B=
M vs
>>>>>> 18-20% with BM.
>>>>>
>>>>> I was trying to test the BM part of tour series on the Armada XP =
GP
>>>>> board. However it failed very quickly during the pool allocation.=
 After
>>>>> a first debug I found that the size of the cs used in the
>>>>> mvebu_mbus_dram_info struct was 0. I have applied your series on =
a
>>>>> v4.4-rc1 kernel. At this stage I don't know if it is a regression=
 in the
>>>>> mbus driver, a misconfiguration on my side or something else.
>>>>>
>>>>> Does it ring a bell for you?
>>>>
>>>> Frankly, I'm a bit surprised, I've never seen such problems on any=
 of
>>>> the boards (AXP-GP/DB, A38X-DB/GP/AP). Did mvebu_mbus_dram_win_inf=
o
>>>> function exit with an error? Can you please apply below diff:
>>>> http://pastebin.com/2ws1txWk
>>>
>>> Yes it exited with errors and I added the same kind traces. It was =
how I
>>> knew that the size was 0!
>>>
>>> I've just rebuild a fresh kernel using mvebu_v7_defconfig and addin=
g
>>> your patch, I got the same issue (see the log at the end of the ema=
il.)
>>>
>>>
>>> But the good news is that on the same kernel on Armada 388 GP the p=
ool
>>> allocation does not fail. I really suspect an issue with my u-boot.
>>>
>>>
>>>> And send me a full log beginning from u-boot?
>>>>
>>>>>
>>>>> How do you test test it exactly?
>>>>> Especially on which kernel and with which U-Boot?
>>>>>
>>>>
>>>> I've just re-built the patchset I sent, which is on top of 4.4-rc1=
=2E
>>>>
>>>> I use AXP-GP, 78460 @ 1600MHz, 2GB DRAM, and everything works fine=
=2E My
>>>> u-boot version: v2011.12 2014_T2.0_eng_dropv2.
>>>
>>> My config is AXP-GP, 78460 @ 1300MHz, 8GB DRAM (only 4GB are used
>>> because I didn't activated LPAE), but the main difference is the U-=
Boot
>>> version: v2011.12 2014_T2.eng_dropv1.ATAG-test02.
>>>
>>> Thanks,
>>>
>>> Gregory
>>>
>>>
>>> [    0.000000] Booting Linux on physical CPU 0x0
>>> [    0.000000] Linux version 4.4.0-rc1-00013-g76f111f9bdf8-dirty (g=
clement@FE-laptop) (gcc version 5.2.1 20151010 (Ubuntu 5.2.1-22ubuntu1)=
 ) #1024 SMP Tue Dec 1 14:02:52 CET 2015
>>> [    0.000000] CPU: ARMv7 Processor [562f5842] revision 2 (ARMv7), =
cr=3D10c5387d
>>> [    0.000000] CPU: PIPT / VIPT nonaliasing data cache, PIPT instru=
ction cache
>>> [    0.000000] Machine model: Marvell Armada XP Development Board D=
B-MV784MP-GP
>>> [    0.000000] Memory policy: Data cache writealloc
>>> [    0.000000] PERCPU: Embedded 12 pages/cpu @ee1ac000 s18752 r8192=
 d22208 u49152
>>> [    0.000000] Built 1 zonelists in Zone order, mobility grouping o=
n.  Total pages: 981504
>>> [    0.000000] Kernel command line: console=3DttyS0,115200 earlypri=
ntk mvneta.rxq_def=3D2
>>> [    0.000000] log_buf_len individual max cpu contribution: 4096 by=
tes
>>> [    0.000000] log_buf_len total cpu_extra contributions: 12288 byt=
es
>>> [    0.000000] log_buf_len min size: 16384 bytes
>>> [    0.000000] log_buf_len: 32768 bytes
>>> [    0.000000] early log buf free: 14924(91%)
>>> [    0.000000] PID hash table entries: 4096 (order: 2, 16384 bytes)
>>> [    0.000000] Dentry cache hash table entries: 131072 (order: 7, 5=
24288 bytes)
>>> [    0.000000] Inode-cache hash table entries: 65536 (order: 6, 262=
144 bytes)
>>> [    0.000000] Memory: 3888204K/3932160K available (5576K kernel co=
de, 251K rwdata, 1544K rodata, 4460K init, 207K bss, 43956K reserved, 0=
K cma-reserved, 3145728K highmem)
>>> [    0.000000] Virtual kernel memory layout:
>>> [    0.000000]     vector  : 0xffff0000 - 0xffff1000   (   4 kB)
>>> [    0.000000]     fixmap  : 0xffc00000 - 0xfff00000   (3072 kB)
>>> [    0.000000]     vmalloc : 0xf0800000 - 0xff800000   ( 240 MB)
>>> [    0.000000]     lowmem  : 0xc0000000 - 0xf0000000   ( 768 MB)
>>> [    0.000000]     pkmap   : 0xbfe00000 - 0xc0000000   (   2 MB)
>>> [    0.000000]     modules : 0xbf000000 - 0xbfe00000   (  14 MB)
>>> [    0.000000]       .text : 0xc0008000 - 0xc06fc374   (7121 kB)
>>> [    0.000000]       .init : 0xc06fd000 - 0xc0b58000   (4460 kB)
>>> [    0.000000]       .data : 0xc0b58000 - 0xc0b96d00   ( 252 kB)
>>> [    0.000000]        .bss : 0xc0b96d00 - 0xc0bcaa58   ( 208 kB)
>>> [    0.000000] Hierarchical RCU implementation.
>>> [    0.000000]  Build-time adjustment of leaf fanout to 32.
>>> [    0.000000] NR_IRQS:16 nr_irqs:16 16
>>> [    0.000000] L2C: DT/platform modifies aux control register: 0x1a=
69ef10 -> 0x1a69ef12
>>> [    0.000000] Aurora cache controller enabled, 32 ways, 2048 kB
>>> [    0.000000] Aurora: CACHE_ID 0x00000100, AUX_CTRL 0x1a69ef12
>>> [    0.000000] Switching to timer-based delay loop, resolution 40ns
>>> [    0.000004] sched_clock: 32 bits at 25MHz, resolution 40ns, wrap=
s every 85899345900ns
>>> [    0.000015] clocksource: armada_370_xp_clocksource: mask: 0xffff=
ffff max_cycles: 0xffffffff, max_idle_ns: 76450417870 ns
>>> [    0.000305] Console: colour dummy device 80x30
>>> [    0.000322] Calibrating delay loop (skipped), value calculated u=
sing timer frequency.. 50.00 BogoMIPS (lpj=3D250000)
>>> [    0.000332] pid_max: default: 32768 minimum: 301
>>> [    0.000417] Mount-cache hash table entries: 2048 (order: 1, 8192=
 bytes)
>>> [    0.000425] Mountpoint-cache hash table entries: 2048 (order: 1,=
 8192 bytes)
>>> [    0.000737] CPU: Testing write buffer coherency: ok
>>> [    0.000880] CPU0: thread -1, cpu 0, socket 0, mpidr 80000000
>>> [    0.001006] Setting up static identity map for 0x8280 - 0x82d8
>>> [    0.001224] mvebu-soc-id: MVEBU SoC ID=3D0x7846, Rev=3D0x2
>>> [    0.001321] mvebu-pmsu: Initializing Power Management Service Un=
it
>>> [    0.002062] Booting CPU 1
>>> [    0.004402] CPU1: thread -1, cpu 1, socket 0, mpidr 80000001
>>> [    0.004645] Booting CPU 2
>>> [    0.006984] CPU2: thread -1, cpu 2, socket 0, mpidr 80000002
>>> [    0.007219] Booting CPU 3
>>> [    0.009558] CPU3: thread -1, cpu 3, socket 0, mpidr 80000003
>>> [    0.009605] Brought up 4 CPUs
>>> [    0.009615] SMP: Total of 4 processors activated (200.00 BogoMIP=
S).
>>> [    0.009620] CPU: All CPU(s) started in SVC mode.
>>> [    0.009957] devtmpfs: initialized
>>> [    0.012369] VFP support v0.3: implementor 56 architecture 2 part=
 20 variant 9 rev 6
>>> [    0.012525] clocksource: jiffies: mask: 0xffffffff max_cycles: 0=
xffffffff, max_idle_ns: 19112604462750000 ns
>>> [    0.012657] pinctrl core: initialized pinctrl subsystem
>>> [    0.013188] NET: Registered protocol family 16
>>> [    0.013368] DMA: preallocated 256 KiB pool for atomic coherent a=
llocations
>>> [    0.040064] cpuidle: using governor ladder
>>> [    0.070061] cpuidle: using governor menu
>>> [    0.075168] hw-breakpoint: Debug register access (0xee003e17) ca=
used undefined instruction on CPU 3
>>> [    0.075172] hw-breakpoint: Debug register access (0xee003e17) ca=
used undefined instruction on CPU 1
>>> [    0.075176] hw-breakpoint: Debug register access (0xee003e17) ca=
used undefined instruction on CPU 2
>>> [    0.075179] hw-breakpoint: CPU 1 failed to disable vector catch
>>> [    0.075196] hw-breakpoint: Debug register access (0xee003e17) ca=
used undefined instruction on CPU 0
>>> [    0.110815] vgaarb: loaded
>>> [    0.110981] SCSI subsystem initialized
>>> [    0.111306] usbcore: registered new interface driver usbfs
>>> [    0.111349] usbcore: registered new interface driver hub
>>> [    0.111398] usbcore: registered new device driver usb
>>> [    0.111640] Advanced Linux Sound Architecture Driver Initialized=
=2E
>>> [    0.111991] Bluetooth: Core ver 2.21
>>> [    0.112024] NET: Registered protocol family 31
>>> [    0.112029] Bluetooth: HCI device and connection manager initial=
ized
>>> [    0.112040] Bluetooth: HCI socket layer initialized
>>> [    0.112048] Bluetooth: L2CAP socket layer initialized
>>> [    0.112067] Bluetooth: SCO socket layer initialized
>>> [    0.112462] clocksource: Switched to clocksource armada_370_xp_c=
locksource
>>> [    0.119267] NET: Registered protocol family 2
>>> [    0.119629] TCP established hash table entries: 8192 (order: 3, =
32768 bytes)
>>> [    0.119690] TCP bind hash table entries: 8192 (order: 4, 65536 b=
ytes)
>>> [    0.119749] TCP: Hash tables configured (established 8192 bind 8=
192)
>>> [    0.119791] UDP hash table entries: 512 (order: 2, 16384 bytes)
>>> [    0.119814] UDP-Lite hash table entries: 512 (order: 2, 16384 by=
tes)
>>> [    0.119945] NET: Registered protocol family 1
>>> [    0.120143] RPC: Registered named UNIX socket transport module.
>>> [    0.120150] RPC: Registered udp transport module.
>>> [    0.120155] RPC: Registered tcp transport module.
>>> [    0.120160] RPC: Registered tcp NFSv4.1 backchannel transport mo=
dule.
>>> [    0.290263] hw perfevents: enabled with armv7_cortex_a9 PMU driv=
er, 7 counters available
>>> [    0.291305] futex hash table entries: 1024 (order: 4, 65536 byte=
s)
>>> [    0.292696] bounce: pool size: 64 pages
>>> [    0.292746] Block layer SCSI generic (bsg) driver version 0.4 lo=
aded (major 252)
>>> [    0.292758] io scheduler noop registered
>>> [    0.292766] io scheduler deadline registered
>>> [    0.292779] io scheduler cfq registered (default)
>>> [    0.293754] armada-xp-pinctrl f1018000.pin-ctrl: registered pinc=
trl driver
>>> [    0.294186] irq: Cannot allocate irq_descs @ IRQ48, assuming pre=
-allocated
>>> [    0.294451] irq: Cannot allocate irq_descs @ IRQ80, assuming pre=
-allocated
>>> [    0.294612] irq: Cannot allocate irq_descs @ IRQ112, assuming pr=
e-allocated
>>> [    0.295033] mv_xor f1060900.xor: Marvell shared XOR driver
>>> [    0.332873] mv_xor f1060900.xor: Marvell XOR (Registers Mode): (=
 xor cpy intr )
>>> [    0.372848] mv_xor f1060900.xor: Marvell XOR (Registers Mode): (=
 xor cpy intr )
>>> [    0.372958] mv_xor f10f0900.xor: Marvell shared XOR driver
>>> [    0.412850] mv_xor f10f0900.xor: Marvell XOR (Registers Mode): (=
 xor cpy intr )
>>> [    0.452845] mv_xor f10f0900.xor: Marvell XOR (Registers Mode): (=
 xor cpy intr )
>>> [    0.492634] Serial: 8250/16550 driver, 4 ports, IRQ sharing disa=
bled
>>> [    0.493897] console [ttyS0] disabled
>>> [    0.514007] f1012000.serial: ttyS0 at MMIO 0xf1012000 (irq =3D 2=
0, base_baud =3D 15625000) is a 16550A
>>> [    1.200947] console [ttyS0] enabled
>>> [    1.225041] f1012100.serial: ttyS1 at MMIO 0xf1012100 (irq =3D 2=
1, base_baud =3D 15625000) is a 16550A
>>> [    1.254648] f1012200.serial: ttyS2 at MMIO 0xf1012200 (irq =3D 3=
3, base_baud =3D 15625000) is a 16550A
>>> [    1.284237] f1012300.serial: ttyS3 at MMIO 0xf1012300 (irq =3D 3=
4, base_baud =3D 15625000) is a 16550A
>>> [    1.294303] sata_mv f10a0000.sata: slots 32 ports 2
>>> [    1.300098] scsi host0: sata_mv
>>> [    1.303511] scsi host1: sata_mv
>>> [    1.306805] ata1: SATA max UDMA/133 irq 31
>>> [    1.310913] ata2: SATA max UDMA/133 irq 31
>>> [    1.315482] pxa3xx-nand f10d0000.nand: This platform can't do DM=
A on this device
>>> [    1.323280] nand: device found, Manufacturer ID: 0x2c, Chip ID: =
0x38
>>> [    1.329650] nand: Micron MT29F8G08ABABAWP
>>> [    1.333684] nand: 1024 MiB, SLC, erase size: 512 KiB, page size:=
 4096, OOB size: 224
>>> [    1.341450] pxa3xx-nand f10d0000.nand: ECC strength 16, ECC step=
 size 2048
>>> [    1.349163] Bad block table found at page 261888, version 0x01
>>> [    1.355385] Bad block table found at page 262016, version 0x01
>>> [    1.364466] pxa3xx_nand-0: 'partitions' subnode not found on /so=
c/internal-regs/nand@d0000. Trying to parse direct subnodes as partitio=
ns.
>>> [    1.378215] m25p80 spi0.0: n25q128a13 (16384 Kbytes)
>>> [    1.385098] spi0.0: 'partitions' subnode not found on /soc/inter=
nal-regs/spi@10600/spi-flash@0. Trying to parse direct subnodes as part=
itions.
>>> [    1.399136] libphy: Fixed MDIO Bus: probed
>>> [    1.403396] libphy: orion_mdio_bus: probed
>>> [    1.415856] mvneta_bm f10c0000.bm: Buffer Manager for network co=
ntroller enabled
>>> [    1.424232] size =3D 0x0, target =3D 0x0, attr =3D 0x1e
>>> [    1.428949] mvebu_mbus: invalid dram address 0x2d194000
>>> [    1.434204] mvneta_bm f10c0000.bm: fail to create pool 0
>>> [    1.439532] mvneta f1070000.ethernet eth0: fail to obtain long p=
ool for port
>>> [    1.446607] mvneta f1070000.ethernet: use SW buffer management
>>> [    1.452696] mvneta f1070000.ethernet eth0: Using hardware mac ad=
dress 00:50:43:68:1c:28
>>> [    1.461529] size =3D 0x0, target =3D 0x0, attr =3D 0x1e
>>> [    1.466258] mvebu_mbus: invalid dram address 0x2d198000
>>> [    1.471501] mvneta_bm f10c0000.bm: fail to create pool 1
>>> [    1.476836] mvneta f1074000.ethernet eth1: fail to obtain long p=
ool for port
>>> [    1.483910] mvneta f1074000.ethernet: use SW buffer management
>>> [    1.489994] mvneta f1074000.ethernet eth1: Using random mac addr=
ess be:14:de:e2:be:cf
>>> [    1.498661] size =3D 0x0, target =3D 0x0, attr =3D 0x1e
>>> [    1.503391] mvebu_mbus: invalid dram address 0x2d10c000
>>> [    1.508633] mvneta_bm f10c0000.bm: fail to create pool 2
>>> [    1.513968] mvneta f1030000.ethernet eth2: fail to obtain long p=
ool for port
>>> [    1.521035] mvneta f1030000.ethernet: use SW buffer management
>>> [    1.527121] mvneta f1030000.ethernet eth2: Using random mac addr=
ess 86:3c:f8:02:31:cf
>>> [    1.535810] size =3D 0x0, target =3D 0x0, attr =3D 0x1e
>>> [    1.540527] mvebu_mbus: invalid dram address 0x2d752000
>>> [    1.545781] mvneta_bm f10c0000.bm: fail to create pool 3
>>> [    1.551108] mvneta f1034000.ethernet eth3: fail to obtain long p=
ool for port
>>> [    1.558182] mvneta f1034000.ethernet: use SW buffer management
>>> [    1.564269] mvneta f1034000.ethernet eth3: Using random mac addr=
ess 7e:3e:74:8c:93:50
>>> [    1.572297] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) =
Driver
>>> [    1.578863] ehci-pci: EHCI PCI platform driver
>>> [    1.583371] ehci-orion: EHCI orion driver
>>> [    1.587476] orion-ehci f1050000.usb: EHCI Host Controller
>>> [    1.592916] orion-ehci f1050000.usb: new USB bus registered, ass=
igned bus number 1
>>> [    1.600567] orion-ehci f1050000.usb: irq 27, io mem 0xf1050000
>>> [    1.622494] orion-ehci f1050000.usb: USB 2.0 started, EHCI 1.00
>>> [    1.628967] hub 1-0:1.0: USB hub found
>>> [    1.632806] hub 1-0:1.0: 1 port detected
>>> [    1.637018] orion-ehci f1051000.usb: EHCI Host Controller
>>> [    1.642468] orion-ehci f1051000.usb: new USB bus registered, ass=
igned bus number 2
>>> [    1.650111] orion-ehci f1051000.usb: irq 28, io mem 0xf1051000
>>> [    1.672467] orion-ehci f1051000.usb: USB 2.0 started, EHCI 1.00
>>> [    1.678908] hub 2-0:1.0: USB hub found
>>> [    1.682736] hub 2-0:1.0: 1 port detected
>>> [    1.687203] usbcore: registered new interface driver usb-storage
>>> [    1.693454] mousedev: PS/2 mouse device common for all mice
>>> [    1.699593] rtc-mv f1010300.rtc: rtc core: registered f1010300.r=
tc as rtc0
>>> [    1.706641] i2c /dev entries driver
>>> [    1.711074] orion_wdt: Initial timeout 171 sec
>>> [    1.715770] cpu: dev_pm_opp_of_cpumask_add_table: couldn't find =
opp table for cpu:0, -19
>>> [    1.723985] cpu: dev_pm_opp_of_cpumask_add_table: couldn't find =
opp table for cpu:1, -19
>>> [    1.732174] cpu: dev_pm_opp_of_cpumask_add_table: couldn't find =
opp table for cpu:2, -19
>>> [    1.740372] cpu: dev_pm_opp_of_cpumask_add_table: couldn't find =
opp table for cpu:3, -19
>>> [    1.748968] sdhci: Secure Digital Host Controller Interface driv=
er
>>> [    1.755176] sdhci: Copyright(c) Pierre Ossman
>>> [    1.759723] sdhci-pltfm: SDHCI platform and OF driver helper
>>> [    1.765805] usbcore: registered new interface driver usbhid
>>> [    1.771394] usbhid: USB HID core driver
>>> [    1.775730] f0000000.nor: Found 1 x16 devices at 0x0 in 16-bit b=
ank. Manufacturer ID 0x000089 Chip ID 0x000018
>>> [    1.785775] Intel/Sharp Extended Query Table at 0x0031
>>> [    1.790936] Intel/Sharp Extended Query Table at 0x0031
>>> [    1.796106] Using buffer write method
>>> [    1.799778] cfi_cmdset_0001: Erase suspend on write enabled
>>> [    1.809269] f0000000.nor: 'partitions' subnode not found on /soc=
/devbus-bootcs/nor@0. Trying to parse direct subnodes as partitions.
>>> [    1.822513] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl F3=
00)
>>> [    1.829037] NET: Registered protocol family 10
>>> [    1.834180] sit: IPv6 over IPv4 tunneling driver
>>> [    1.839209] NET: Registered protocol family 17
>>> [    1.842687] ata1.00: ATA-9: TS8GHSD310, 20111220, max UDMA/133
>>> [    1.842692] ata1.00: 15621984 sectors, multi 1: LBA48 NCQ (depth=
 31/32)
>>> [    1.856343] ThumbEE CPU extension supported.
>>> [    1.860632] Registering SWP/SWPB emulation handler
>>> [    1.862685] ata1.00: configured for UDMA/133
>>> [    1.862993] scsi 0:0:0:0: Direct-Access     ATA      TS8GHSD310 =
      1220 PQ: 0 ANSI: 5
>>> [    1.863646] sd 0:0:0:0: [sda] 15621984 512-byte logical blocks: =
(7.99 GB/7.44 GiB)
>>> [    1.863838] sd 0:0:0:0: [sda] Write Protect is off
>>> [    1.863907] sd 0:0:0:0: [sda] Write cache: enabled, read cache: =
enabled, doesn't support DPO or FUA
>>> [    1.873801]  sda: sda1 sda2 sda3 < sda5 > sda4
>>> [    1.875389] sd 0:0:0:0: [sda] Attached SCSI disk
>>> [    1.909334] rtc-mv f1010300.rtc: setting system clock to 2001-01=
-20 07:57:42 UTC (979977462)
>>> [    1.918901] ALSA device list:
>>> [    1.921878]   No soundcards found.
>>> [    2.222505] ata2: SATA link down (SStatus 0 SControl F300)
>>> [    2.230484] Freeing unused kernel memory: 4460K (c06fd000 - c0b5=
8000)
>>>
>>> --
>>> Gregory Clement, Free Electrons
>>> Kernel, drivers, real-time and embedded Linux
>>> development, consulting, training and support.
>>> http://free-electrons.com
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--=20
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
