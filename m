From: Anton Vorontsov <cbouatmailru@gmail.com>
Subject: Re: [PATCH] gianfar: Revive the driver for eTSEC devices (disable
	timestamping)
Date: Thu, 10 Jun 2010 13:31:59 +0400
Message-ID: <20100610093159.GA30822@oksana.dev.rtsoft.ru>
References: <20100609193219.GA8629@oksana.dev.rtsoft.ru>
	<20100610062907.GA3390@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="KsGdsel6WgEHnImy"
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Manfred Rudigier <Manfred.Rudigier@omicron.at>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20100610062907.GA3390@riccoc20.at.omicron.at>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org


--KsGdsel6WgEHnImy
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

On Thu, Jun 10, 2010 at 08:29:08AM +0200, Richard Cochran wrote:
> On Wed, Jun 09, 2010 at 11:32:19PM +0400, Anton Vorontsov wrote:
> > Since commit cc772ab7cdcaa24d1fae332d92a1602788644f7a ("gianfar: Add
> > hardware RX timestamping support"), the driver no longer works on
> > at least MPC8313ERDB and MPC8568EMDS boards (and possibly much more
> > boards as well).
> 
> What do you mean by, "no longer works?" The driver works fine for us,

For me it doesn't even able to receive DHCP answer, boot logs
attached. tcpdump on the host side:

12:56:15.266562 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:e0:0c:00:7e:21, length 548
12:56:15.266697 IP 10.0.0.2.67 > 10.0.0.32.68: BOOTP/DHCP, Reply, length 324
12:56:22.106691 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:e0:0c:00:7e:21, length 548
12:56:22.106843 IP 10.0.0.2.67 > 10.0.0.32.68: BOOTP/DHCP, Reply, length 324
12:56:33.698908 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:e0:0c:00:7e:21, length 548
12:56:33.699083 IP 10.0.0.2.67 > 10.0.0.32.68: BOOTP/DHCP, Reply, length 324
12:56:53.607275 IP 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 00:e0:0c:00:7e:21, length 548
12:56:53.607430 IP 10.0.0.2.67 > 10.0.0.32.68: BOOTP/DHCP, Reply, length 324

> > That's how MPC8313 Reference Manual describes RCTRL_TS_ENABLE bit:
> > 
> >   Timestamp incoming packets as padding bytes. PAL field is set
> >   to 8 if the PAL field is programmed to less than 8. Must be set
> >   to zero if TMR_CTRL[TE]=0.
> > 
> > I see that the commit above sets this bit, but it doesn't handle
> > TMR_CTRL. Manfred probably had this bit set by the firmware for
> > his boards. But obviously this isn't true for all boards in the
> > wild.
> 
> No, we did not set TMR_CTRL[TE].

So, you deliberately violate the spec and expect it to work
everywhere? :-)

> For the Rx timestamps, we simply enabled them unconditionally. The
> effect of not setting TMR_CTRL[TE] was that the timestamps were
> invalid, but that should not matter if user space has not configured
> the PTP clock.

It seems to matter here, but I haven't tested if enabling the
TE bit actually solves the problem. Disabling timestamping
makes the driver work for sure though.

> > Also, I recall that Freescale BSPs were explicitly disabling the
> > timestamping because of a performance drop.
> 
> The BSPs that we have, for the MPC8313ERDB and the P2020RBD both
> include a (hacky) PTP timestmaping driver. Can you be more specific
> about where and when Freescale is disabling timestamping?

Well, bitshrine site no longer allows[1] to list patches at
http://www.bitshrine.org/gpp/ , but there was a patch for sure.

I'll try to find it in a bunch of .iso files that I have on disk
tho.

> > For now, the best way to deal with this is just disable the
> > timestamping, and later we can discuss proper device tree bindings
> > and implement enabling this feature via some property.
> 
> Okay, but now we want to identify what exactly works and what not. As
> mentioned, we tested this driver on four different boards and did not
> see any problems.

Sure thing, I would happily test any patches. Or if you need
to dump some register from my board, feel free to send a patch
that adds a bunch of printks and I'll send the output to you.

Thanks,

[1] http://lists.nongnu.org/archive/html/ltib/2010-04/msg00192.html

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2

--KsGdsel6WgEHnImy
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename="wk.log"

U-Boot 1.1.6 (Oct  9 2007 - 20:42:39) MPC83XX

Clock configuration:
  Coherent System Bus:  166 MHz
  Core:                 333 MHz
  Local Bus Controller: 166 MHz
  Local Bus:             41 MHz
  DDR:                  333 MHz
  SEC:                   55 MHz
  I2C1:                 166 MHz
  I2C2:                 166 MHz
  TSEC1:                166 MHz
  TSEC2:                166 MHz
  USB MPH:                0 MHz
  USB DR:                55 MHz
CPU: MPC8313E, Rev: 10 at 333.333 MHz
Board: Freescale MPC8313ERDB
I2C:   ready
DRAM:  Initializing
   DDR RAM: 128 MB
FLASH:  8 MB
NAND:  32 MiB
In:    serial
Out:   serial
Err:   serial
Net:   TSEC0, TSEC1
=>
=>
=> setenv ethact TSEC1 ; setenv ipaddr 10.0.0.99 ; setenv serverip 10.0.0.2 ; setenv bootargs console=ttyS0,115200 ip=on debug ; tftp a00000 uImage ; tftp 900000 dtb ; bootm a00000 - 900000
Waiting for PHY auto negotiation to complete. done
Speed: 100, full duplex
Using TSEC1 device
TFTP from server 10.0.0.2; our IP address is 10.0.0.99
Filename 'uImage'.
Load address: 0xa00000
Loading: #################################################################
         #################################################################
         #################################################################
         #################################################################
         ##############################
done
Bytes transferred = 1482399 (169e9f hex)
Speed: 100, full duplex
Using TSEC1 device
TFTP from server 10.0.0.2; our IP address is 10.0.0.99
Filename 'dtb'.
Load address: 0x900000
Loading: ####
done
Bytes transferred = 20000 (4e20 hex)
## Booting image at 00a00000 ...
   Image Name:   Linux-2.6.35-rc2-00059-gf7c3a62
   Created:      2010-06-10   8:59:46 UTC
   Image Type:   PowerPC Linux Kernel Image (gzip compressed)
   Data Size:    1482335 Bytes =  1.4 MB
   Load Address: 00000000
   Entry Point:  00000000
   Verifying Checksum ... OK
   Uncompressing Kernel Image ... OK
   Booting using flat device tree at 0x900000
Using MPC831x RDB machine description
Linux version 2.6.35-rc2-00059-gf7c3a62 (cbou@oksana) (gcc version 4.2.0 (MontaVista 4.2.0-16.0.20.0800760 2008-04-05)) #85 Thu Jun 10 12:59:44 MSD 2010
Found legacy serial port 0 for /soc8313@e0000000/serial@4500
  mem=e0004500, taddr=e0004500, irq=0, clk=166666660, speed=0
Found legacy serial port 1 for /soc8313@e0000000/serial@4600
  mem=e0004600, taddr=e0004600, irq=0, clk=166666660, speed=0
bootconsole [udbg0] enabled
setup_arch: bootmem
mpc831x_rdb_setup_arch()
arch: exit
Top of RAM: 0x8000000, Total RAM: 0x8000000
Memory hole size: 0MB
Zone PFN ranges:
  DMA      0x00000000 -> 0x00008000
  Normal   empty
Movable zone start PFN for each node
early_node_map[1] active PFN ranges
    0: 0x00000000 -> 0x00008000
On node 0 totalpages: 32768
free_area_init_node: node 0, pgdat c0302840, node_mem_map c0321000
  DMA zone: 256 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 32512 pages, LIFO batch:7
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 32512
Kernel command line: console=ttyS0,115200 ip=on debug
PID hash table entries: 512 (order: -1, 2048 bytes)
Dentry cache hash table entries: 16384 (order: 4, 65536 bytes)
Inode-cache hash table entries: 8192 (order: 3, 32768 bytes)
Memory: 126708k/131072k available (2980k kernel code, 4364k reserved, 136k data, 83k bss, 164k init)
Kernel virtual memory layout:
  * 0xfffdf000..0xfffff000  : fixmap
  * 0xfdffc000..0xfe000000  : early ioremap
  * 0xc9000000..0xfdffc000  : vmalloc & ioremap
SLUB: Genslabs=13, HWalign=32, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
Hierarchical RCU implementation.
        RCU-based detection of stalled CPUs is disabled.
        Verbose stalled-CPUs detection is disabled.
NR_IRQS:512 nr_irqs:512
IPIC (128 IRQ sources) at c9000700
time_init: decrementer frequency = 41.666665 MHz
time_init: processor frequency   = 333.333320 MHz
clocksource: timebase mult[6000004] shift[22] registered
clockevent: decrementer mult[aaaaaa3] shift[32] cpu[0]
pid_max: default: 32768 minimum: 301
Mount-cache hash table entries: 512
NET: Registered protocol family 16

  alloc irq_desc for 38 on node 0
  alloc kstat_irqs on node 0
irq: irq 38 on host /soc8313@e0000000/pic@700 mapped to virtual irq 38
Registering ipic with sysfs...
bio: create slab <bio-0> at 0
SCSI subsystem initialized
Switching to clocksource timebase
NET: Registered protocol family 2
IP route cache hash table entries: 1024 (order: 0, 4096 bytes)
TCP established hash table entries: 4096 (order: 3, 32768 bytes)
TCP bind hash table entries: 4096 (order: 2, 16384 bytes)
TCP: Hash tables configured (established 4096 bind 4096)
TCP reno registered
UDP hash table entries: 256 (order: 0, 4096 bytes)
UDP-Lite hash table entries: 256 (order: 0, 4096 bytes)
NET: Registered protocol family 1
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
RPC: Registered tcp NFSv4.1 backchannel transport module.
  alloc irq_desc for 16 on node 0
  alloc kstat_irqs on node 0
irq: irq 9 on host /soc8313@e0000000/pic@700 mapped to virtual irq 16
  alloc irq_desc for 17 on node 0
  alloc kstat_irqs on node 0
irq: irq 10 on host /soc8313@e0000000/pic@700 mapped to virtual irq 17
msgmni has been set to 247
alg: No test for stdrng (krng)
io scheduler noop registered
io scheduler deadline registered
io scheduler cfq registered (default)
Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
serial8250.0: ttyS0 at MMIO 0xe0004500 (irq = 16) is a 16550A
console [ttyS0] enabled, bootconsole disabled
console [ttyS0] enabled, bootconsole disabled
serial8250.0: ttyS1 at MMIO 0xe0004600 (irq = 17) is a 16550A
brd: module loaded
loop: module loaded
Fixed MDIO Bus: probed
  alloc irq_desc for 37 on node 0
  alloc kstat_irqs on node 0
irq: irq 37 on host /soc8313@e0000000/pic@700 mapped to virtual irq 37
  alloc irq_desc for 36 on node 0
  alloc kstat_irqs on node 0
irq: irq 36 on host /soc8313@e0000000/pic@700 mapped to virtual irq 36
  alloc irq_desc for 35 on node 0
  alloc kstat_irqs on node 0
irq: irq 35 on host /soc8313@e0000000/pic@700 mapped to virtual irq 35
eth0: Gianfar Ethernet Controller Version 1.2, 00:04:9f:ef:23:33
eth0: Running with NAPI enabled
eth0: RX BD ring size for Q[0]: 256
eth0: TX BD ring size for Q[0]: 256
  alloc irq_desc for 34 on node 0
  alloc kstat_irqs on node 0
irq: irq 34 on host /soc8313@e0000000/pic@700 mapped to virtual irq 34
  alloc irq_desc for 33 on node 0
  alloc kstat_irqs on node 0
irq: irq 33 on host /soc8313@e0000000/pic@700 mapped to virtual irq 33
  alloc irq_desc for 32 on node 0
  alloc kstat_irqs on node 0
irq: irq 32 on host /soc8313@e0000000/pic@700 mapped to virtual irq 32
eth1: Gianfar Ethernet Controller Version 1.2, 00:e0:0c:00:7e:21
eth1: Running with NAPI enabled
eth1: RX BD ring size for Q[0]: 256
eth1: TX BD ring size for Q[0]: 256
Freescale PowerQUICC MII Bus: probed
  alloc irq_desc for 20 on node 0
  alloc kstat_irqs on node 0
irq: irq 20 on host /soc8313@e0000000/pic@700 mapped to virtual irq 20
Freescale PowerQUICC MII Bus: probed
md: linear personality registered for level -1
md: raid0 personality registered for level 0
md: raid1 personality registered for level 1
TCP cubic registered
NET: Registered protocol family 17
Sending DHCP requests .
PHY: 0:01 - Link is Up - 1000/Full
PHY: mdio@e0024520:04 - Link is Up - 100/Full
., OK
IP-Config: Got DHCP answer from 10.0.0.2, my address is 10.0.0.32
IP-Config: Complete:
     device=eth1, addr=10.0.0.32, mask=255.255.255.0, gw=10.0.0.2,
     host=10.0.0.32, domain=local.net, nis-domain=(none),
     bootserver=10.0.0.2, rootserver=10.0.0.2, rootpath=/opt/montavista/cge/devkit/ppc/83xx/target/
md: Waiting for all devices to be available before autodetect
md: If you don't use raid, use raid=noautodetect
md: Autodetecting RAID arrays.
md: Scanned 0 and added 0 devices.
md: autorun ...
md: ... autorun DONE.
Looking up port of RPC 100003/2 on 10.0.0.2
Looking up port of RPC 100005/1 on 10.0.0.2
VFS: Mounted root (nfs filesystem) readonly on device 0:10.
Freeing unused kernel memory: 164k init

--KsGdsel6WgEHnImy
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename="nwk.log"

U-Boot 1.1.6 (Oct  9 2007 - 20:42:39) MPC83XX

Clock configuration:
  Coherent System Bus:  166 MHz
  Core:                 333 MHz
  Local Bus Controller: 166 MHz
  Local Bus:             41 MHz
  DDR:                  333 MHz
  SEC:                   55 MHz
  I2C1:                 166 MHz
  I2C2:                 166 MHz
  TSEC1:                166 MHz
  TSEC2:                166 MHz
  USB MPH:                0 MHz
  USB DR:                55 MHz
CPU: MPC8313E, Rev: 10 at 333.333 MHz
Board: Freescale MPC8313ERDB
I2C:   ready
DRAM:  Initializing
   DDR RAM: 128 MB
FLASH:  8 MB
NAND:  32 MiB
In:    serial
Out:   serial
Err:   serial
Net:   TSEC0, TSEC1
=>
=>
=> setenv ethact TSEC1 ; setenv ipaddr 10.0.0.99 ; setenv serverip 10.0.0.2 ; setenv bootargs console=ttyS0,115200 ip=on debug ; tftp a00000 uImage ; tftp 900000 dtb ; bootm a00000 - 900000
Waiting for PHY auto negotiation to complete. done
Speed: 100, full duplex
Using TSEC1 device
TFTP from server 10.0.0.2; our IP address is 10.0.0.99
Filename 'uImage'.
Load address: 0xa00000
Loading: #################################################################
         #################################################################
         #################################################################
         #################################################################
         ##############################
done
Bytes transferred = 1482397 (169e9d hex)
Speed: 100, full duplex
Using TSEC1 device
TFTP from server 10.0.0.2; our IP address is 10.0.0.99
Filename 'dtb'.
Load address: 0x900000
Loading: ####
done
Bytes transferred = 20000 (4e20 hex)
## Booting image at 00a00000 ...
   Image Name:   Linux-2.6.35-rc2-00058-ge411f2d
   Created:      2010-06-10   8:52:33 UTC
   Image Type:   PowerPC Linux Kernel Image (gzip compressed)
   Data Size:    1482333 Bytes =  1.4 MB
   Load Address: 00000000
   Entry Point:  00000000
   Verifying Checksum ... OK
   Uncompressing Kernel Image ... OK
   Booting using flat device tree at 0x900000
Using MPC831x RDB machine description
Linux version 2.6.35-rc2-00058-ge411f2d (cbou@oksana) (gcc version 4.2.0 (MontaVista 4.2.0-16.0.20.0800760 2008-04-05)) #84 Thu Jun 10 12:52:32 MSD 2010
Found legacy serial port 0 for /soc8313@e0000000/serial@4500
  mem=e0004500, taddr=e0004500, irq=0, clk=166666660, speed=0
Found legacy serial port 1 for /soc8313@e0000000/serial@4600
  mem=e0004600, taddr=e0004600, irq=0, clk=166666660, speed=0
bootconsole [udbg0] enabled
setup_arch: bootmem
mpc831x_rdb_setup_arch()
arch: exit
Top of RAM: 0x8000000, Total RAM: 0x8000000
Memory hole size: 0MB
Zone PFN ranges:
  DMA      0x00000000 -> 0x00008000
  Normal   empty
Movable zone start PFN for each node
early_node_map[1] active PFN ranges
    0: 0x00000000 -> 0x00008000
On node 0 totalpages: 32768
free_area_init_node: node 0, pgdat c0302840, node_mem_map c0321000
  DMA zone: 256 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 32512 pages, LIFO batch:7
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 32512
Kernel command line: console=ttyS0,115200 ip=on debug
PID hash table entries: 512 (order: -1, 2048 bytes)
Dentry cache hash table entries: 16384 (order: 4, 65536 bytes)
Inode-cache hash table entries: 8192 (order: 3, 32768 bytes)
Memory: 126708k/131072k available (2980k kernel code, 4364k reserved, 136k data, 83k bss, 164k init)
Kernel virtual memory layout:
  * 0xfffdf000..0xfffff000  : fixmap
  * 0xfdffc000..0xfe000000  : early ioremap
  * 0xc9000000..0xfdffc000  : vmalloc & ioremap
SLUB: Genslabs=13, HWalign=32, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
Hierarchical RCU implementation.
        RCU-based detection of stalled CPUs is disabled.
        Verbose stalled-CPUs detection is disabled.
NR_IRQS:512 nr_irqs:512
IPIC (128 IRQ sources) at c9000700
time_init: decrementer frequency = 41.666665 MHz
time_init: processor frequency   = 333.333320 MHz
clocksource: timebase mult[6000004] shift[22] registered
clockevent: decrementer mult[aaaaaa3] shift[32] cpu[0]
pid_max: default: 32768 minimum: 301
Mount-cache hash table entries: 512
NET: Registered protocol family 16

  alloc irq_desc for 38 on node 0
  alloc kstat_irqs on node 0
irq: irq 38 on host /soc8313@e0000000/pic@700 mapped to virtual irq 38
Registering ipic with sysfs...
bio: create slab <bio-0> at 0
SCSI subsystem initialized
Switching to clocksource timebase
NET: Registered protocol family 2
IP route cache hash table entries: 1024 (order: 0, 4096 bytes)
TCP established hash table entries: 4096 (order: 3, 32768 bytes)
TCP bind hash table entries: 4096 (order: 2, 16384 bytes)
TCP: Hash tables configured (established 4096 bind 4096)
TCP reno registered
UDP hash table entries: 256 (order: 0, 4096 bytes)
UDP-Lite hash table entries: 256 (order: 0, 4096 bytes)
NET: Registered protocol family 1
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
RPC: Registered tcp NFSv4.1 backchannel transport module.
  alloc irq_desc for 16 on node 0
  alloc kstat_irqs on node 0
irq: irq 9 on host /soc8313@e0000000/pic@700 mapped to virtual irq 16
  alloc irq_desc for 17 on node 0
  alloc kstat_irqs on node 0
irq: irq 10 on host /soc8313@e0000000/pic@700 mapped to virtual irq 17
msgmni has been set to 247
alg: No test for stdrng (krng)
io scheduler noop registered
io scheduler deadline registered
io scheduler cfq registered (default)
Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
serial8250.0: ttyS0 at MMIO 0xe0004500 (irq = 16) is a 16550A
console [ttyS0] enabled, bootconsole disabled
console [ttyS0] enabled, bootconsole disabled
serial8250.0: ttyS1 at MMIO 0xe0004600 (irq = 17) is a 16550A
brd: module loaded
loop: module loaded
Fixed MDIO Bus: probed
  alloc irq_desc for 37 on node 0
  alloc kstat_irqs on node 0
irq: irq 37 on host /soc8313@e0000000/pic@700 mapped to virtual irq 37
  alloc irq_desc for 36 on node 0
  alloc kstat_irqs on node 0
irq: irq 36 on host /soc8313@e0000000/pic@700 mapped to virtual irq 36
  alloc irq_desc for 35 on node 0
  alloc kstat_irqs on node 0
irq: irq 35 on host /soc8313@e0000000/pic@700 mapped to virtual irq 35
eth0: Gianfar Ethernet Controller Version 1.2, 00:04:9f:ef:23:33
eth0: Running with NAPI enabled
eth0: RX BD ring size for Q[0]: 256
eth0: TX BD ring size for Q[0]: 256
  alloc irq_desc for 34 on node 0
  alloc kstat_irqs on node 0
irq: irq 34 on host /soc8313@e0000000/pic@700 mapped to virtual irq 34
  alloc irq_desc for 33 on node 0
  alloc kstat_irqs on node 0
irq: irq 33 on host /soc8313@e0000000/pic@700 mapped to virtual irq 33
  alloc irq_desc for 32 on node 0
  alloc kstat_irqs on node 0
irq: irq 32 on host /soc8313@e0000000/pic@700 mapped to virtual irq 32
eth1: Gianfar Ethernet Controller Version 1.2, 00:e0:0c:00:7e:21
eth1: Running with NAPI enabled
eth1: RX BD ring size for Q[0]: 256
eth1: TX BD ring size for Q[0]: 256
Freescale PowerQUICC MII Bus: probed
  alloc irq_desc for 20 on node 0
  alloc kstat_irqs on node 0
irq: irq 20 on host /soc8313@e0000000/pic@700 mapped to virtual irq 20
Freescale PowerQUICC MII Bus: probed
md: linear personality registered for level -1
md: raid0 personality registered for level 0
md: raid1 personality registered for level 1
TCP cubic registered
NET: Registered protocol family 17
Sending DHCP requests .
PHY: 0:01 - Link is Up - 1000/Full
PHY: mdio@e0024520:04 - Link is Up - 100/Full
..... timed out!
IP-Config: Reopening network devices...
Sending DHCP requests .
PHY: 0:01 - Link is Up - 1000/Full
PHY: mdio@e0024520:04 - Link is Up - 100/Full
.

--KsGdsel6WgEHnImy
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@lists.ozlabs.org
https://lists.ozlabs.org/listinfo/linuxppc-dev
--KsGdsel6WgEHnImy--
