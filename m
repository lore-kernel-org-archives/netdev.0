From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: rtk8168 driver help needed
Date: Thu, 19 May 2016 17:38:26 -0400
Message-ID: <573E3252.6000207@ti.com>
References: <572D147C.8020203@ti.com>
 <20160507083511.GA18421@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:54157 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751297AbcESVi3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 May 2016 17:38:29 -0400
In-Reply-To: <20160507083511.GA18421@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/07/2016 04:35 AM, Francois Romieu wrote:
> Murali Karicheri <m-karicheri2@ti.com> :
> [...]
>> I am trying to integrate the rtl8168 PCIe card to have Ethernet functional
>> on my Keystone EVM.
> 
> Which (EVM) one ?
> 
>> I purchased the rtl8111c Gib card from Amazon. The Card is detected
>> by the RC and I can see it is enumerated and show up when doing lspci command.
> 
> What does "the RC" mean ? A different PC ?
> 
>> However I can't get the Ethernet port functional.
> 
>> Does this need MSI interrupt ?
> 
> No.
> 
>> I can't see it has requested any.
> 
> Yes, something went really, really wrong. See below.
> 
I have figured out why I was getting all zeros over the PCIe bus. The PCIe 
address range used by the CPU to access the PCI space is wrong. Once that
is fixed, I was able to test few PCIe EP devices such as Intel e1000e, Broadcom
tg3, Marvel SATA etc. But the rtk8168 driver still don't work. I have following
log now.

[    2.372877] pci_bus 0000:00: root bus resource [bus 00-ff]
[    2.378362] pci_bus 0000:00: root bus resource [io  0x0000-0x3fff]
[    2.384609] pci_bus 0000:00: root bus resource [mem 0x70000000-0x7fffffff]
[    2.392155] PCI: bus0: Fast back to back transfers disabled
[    2.411222] PCI: bus1: Fast back to back transfers disabled
[    2.416964] pci 0000:00:00.0: BAR 8: assigned [mem 0x70000000-0x700fffff]
[    2.423927] pci 0000:00:00.0: BAR 9: assigned [mem 0x70100000-0x701fffff
pref]
[    2.431217] pci 0000:00:00.0: BAR 7: assigned [io  0x1000-0x1fff]
[    2.437315] pci 0000:01:00.0: BAR 6: assigned [mem 0x70100000-0x7011ffff
pref]
[    2.444597] pci 0000:01:00.0: BAR 4: assigned [mem 0x70120000-0x7012ffff
64bit pref]
[    2.452383] pci 0000:01:00.0: BAR 2: assigned [mem 0x70000000-0x70000fff
64bit]
[    2.459705] pci 0000:01:00.0: BAR 0: assigned [io  0x1000-0x10ff]
[    2.465825] pci 0000:00:00.0: PCI bridge to [bus 01]
[    2.470788] pci 0000:00:00.0:   bridge window [io  0x1000-0x1fff]
[    2.476905] pci 0000:00:00.0:   bridge window [mem 0x70000000-0x700fffff]
[    2.483711] pci 0000:00:00.0:   bridge window [mem 0x70100000-0x701fffff
pref]


And then 

root@k2g-evm:~# lspci -v
00:00.0 PCI bridge: Texas Instruments Device b00b (rev 01) (prog-if 00 [Normal
decode])
        Flags: bus master, fast devsel, latency 0, IRQ 287
        Memory at <ignored> (32-bit, non-prefetchable)
        Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
        I/O behind bridge: 00001000-00001fff
        Memory behind bridge: 70000000-700fffff
        Prefetchable memory behind bridge: 70100000-701fffff
        Capabilities: [40] Power Management version 3
        Capabilities: [50] MSI: Enable+ Count=1/1 Maskable- 64bit+
        Capabilities: [70] Express Root Port (Slot-), MSI 00
        Capabilities: [100] Advanced Error Reporting
        Kernel driver in use: pcieport
lspci: Unable to load libkmod resources: error -12

01:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168/8411
PCI Express Gigabit Ethernet Controller (rev 02)
        Subsystem: Realtek Semiconductor Co., Ltd. Device 0123
        Flags: fast devsel, IRQ 319
        I/O ports at 1000 [disabled] [size=256]
        Memory at 70000000 (64-bit, non-prefetchable) [disabled] [size=4K]
        Memory at 70120000 (64-bit, prefetchable) [disabled] [size=64K]
        [virtual] Expansion ROM at 70100000 [disabled] [size=128K]
        Capabilities: [40] Power Management version 0
        Capabilities: [50] MSI: Enable- Count=1/1 Maskable- 64bit+
        Capabilities: [70] Express Endpoint, MSI 01
        Capabilities: [b0] MSI-X: Enable- Count=2 Masked-
        Capabilities: [d0] Vital Product Data
        Capabilities: [100] Advanced Error Reporting
        Capabilities: [140] Virtual Channel
        Capabilities: [160] Device Serial Number 01-00-00-00-68-4c-e0-00


And then

root@k2g-evm:/# insmod r8169.ko
[   43.980877] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[   43.986609] r8169 0000:01:00.0: enabling device (0140 -> 0143)
[   43.993132] r8169 0000:01:00.0: limiting MRRS to 256
[   44.004152] r8169 0000:01:00.0 eth1: RTL8168c/8111c at 0xf0f56000,
00:e0:4c:21:16:2c, XID 1c4000c0 IRQ 288
[   44.024167] r8169 0000:01:00.0 eth1: jumbo features [frames: 6128 bytes, tx
checksumming: ko]
root@k2g-evm:/# ifup eth1
[   51.782650] r8169 0000:01:00.0 eth1: link down
[   51.787121] r8169 0000:01:00.0 eth1: link down
[   51.792348] IPv6: ADDRCONF(NETDEV_UP): eth1: link is not ready
udhcpc (v1.23.1) started
Sending discover...
[   54.158011] r8169 0000:01:00.0 eth1: link up
[   54.162344] IPv6: ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
Sending discover...
Sending discover...
No lease, forking to background
root@k2g-evm:/# ifconfig
eth0      Link encap:Ethernet  HWaddr 50:72:24:D6:DE:ED
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

eth1      Link encap:Ethernet  HWaddr 00:E0:4C:21:16:2C
          inet6 addr: fe80::2e0:4cff:fe21:162c/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)


Looks like there is nothing transmitted.


For Broadcom tg3, I get

[    2.353188] pci_bus 0000:00: root bus resource [bus 00-ff]
[    2.358673] pci_bus 0000:00: root bus resource [io  0x0000-0x3fff]
[    2.364924] pci_bus 0000:00: root bus resource [mem 0x70000000-0x7fffffff]
[    2.372468] PCI: bus0: Fast back to back transfers disabled
[    2.378612] pci 0000:01:00.0: reg 0x10: can't handle BAR above 4GB (bus
address 0x2400460302000000)
[    2.388393] pci 0000:01:00.0: disabling ASPM on pre-1.1 PCIe device.  You can
enable it with 'pcie_aspm=force'
[    2.398565] PCI: bus1: Fast back to back transfers disabled
[    2.404437] pci 0000:00:00.0: BAR 8: assigned [mem 0x70000000-0x700fffff]
[    2.411322] pci 0000:01:00.0: BAR 0: assigned [mem 0x70000000-0x7000ffff
64bit]
[    2.418648] pci 0000:00:00.0: PCI bridge to [bus 01]
[    2.423682] pci 0000:00:00.0:   bridge window [mem 0x70000000-0x700fffff]
[    2.430978] pcieport 0000:00:00.0: Signaling PME through PCIe PME interrupt
[    2.438106] pci 0000:01:00.0: Signaling PME through PCIe PME interrupt
[    2.445532] keystone-navigator-qmss soc:qmss@4020000: qmgr start queue 0,
number of queues 128
[    2.454489] keystone-navigator-qmss soc:qmss@4020000: added qmgr start queue

And then

root@k2g-evm:~# lspci -v
00:00.0 PCI bridge: Texas Instruments Device b00b (rev 01) (prog-if 00 [Normal
decode])
        Flags: bus master, fast devsel, latency 0, IRQ 287
        Memory at <ignored> (32-bit, non-prefetchable)
        Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
        Memory behind bridge: 70000000-700fffff
        Capabilities: [40] Power Management version 3
        Capabilities: [50] MSI: Enable+ Count=1/1 Maskable- 64bit+
        Capabilities: [70] Express Root Port (Slot-), MSI 00
        Capabilities: [100] Advanced Error Reporting
        Kernel driver in use: pcieport
lspci: Unable to load libkmod resources: error -12

01:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5721 Gigabit
Ethernet PCI Express (rev 21)
        Subsystem: Broadcom Corporation NetXtreme BCM5721 Gigabit Ethernet PCI
Express
        Flags: fast devsel, IRQ 319
        Memory at 70000000 (64-bit, non-prefetchable) [disabled] [size=64K]
        Capabilities: [48] Power Management version 2
        Capabilities: [50] Vital Product Data
        Capabilities: [58] MSI: Enable- Count=1/8 Maskable- 64bit+
        Capabilities: [d0] Express Endpoint, MSI 00
        Capabilities: [100] Advanced Error Reporting
        Capabilities: [13c] Virtual Channel
        Capabilities: [160] Device Serial Number 00-10-18-ff-fe-27-cc-c0
        Capabilities: [16c] Power Budgeting <?>


And then

root@k2g-evm:/# insmod tg3.ko
[   49.615358] tg3.c:v3.137 (May 11, 2014)
[   49.619223] tg3 0000:01:00.0: enabling device (0140 -> 0142)
[   49.625590] tg3 0000:01:00.0: limiting MRRS to 256
[   49.654559] tg3 0000:01:00.0 eth1: Tigon3 [partno(BCM95721A211F) rev 4201]
(PCI Express) MAC address 00:10:18:27:cc:c0
[   49.675314] tg3 0000:01:00.0 eth1: attached PHY is 5750 (10/100/1000Base-T
Ethernet) (WireSpeed[1], EEE[0])
[   49.698863] tg3 0000:01:00.0 eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0]
TSOcap[1]
[   49.715708] tg3 0000:01:00.0 eth1: dma_rwctrl[76180000] dma_mask[64-bit]
root@k2g-evm:/#
root@k2g-evm:/#
root@k2g-evm:/#
root@k2g-evm:/# ifp eth1
-sh: ifp: command not found
root@k2g-evm:/# ifup eth1
[   59.207581] IPv6: ADDRCONF(NETDEV_UP): eth1: link is not ready
udhcpc (v1.23.1) started
Sending discover...
Sending discover...
[   62.361817] tg3 0000:01:00.0 eth1: Link is up at 1000 Mbps, full duplex
[   62.368436] tg3 0000:01:00.0 eth1: Flow control is on for TX and on for RX
[   62.376029] IPv6: ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
Sending select for 192.168.0.27...
Lease of 192.168.0.27 obtained, lease time 864000
/etc/udhcpc.d/50default: Adding DNS 192.168.0.2
/etc/udhcpc.d/50default: Adding DNS 192.168.0.10
root@k2g-evm:/#
root@k2g-evm:/#
root@k2g-evm:/#
root@k2g-evm:/# ping 192.168.0.21
PING 192.168.0.21 (192.168.0.21): 56 data bytes
64 bytes from 192.168.0.21: seq=0 ttl=64 time=0.752 ms
64 bytes from 192.168.0.21: seq=1 ttl=64 time=0.384 ms
64 bytes from 192.168.0.21: seq=2 ttl=64 time=0.341 ms
64 bytes from 192.168.0.21: seq=3 ttl=64 time=0.277 ms

Do you what could be wrong with rtk8168?

Murali


> [...]
>> [    2.303965] PCI host bridge /soc/pcie@21800000 ranges:
>> [    2.309108]   No bus range found for /soc/pcie@21800000, using [bus 00-ff]
>> [    2.316269]    IO 0x23250000..0x23253fff -> 0x00000000
>> [    2.321499]   MEM 0x50000000..0x5fffffff -> 0x50000000
>> [    2.331666] keystone-pcie 21801000.pcie: PCI host bridge to bus 0000:00
>> [    2.338283] pci_bus 0000:00: root bus resource [bus 00-ff]
>> [    2.343937] pci_bus 0000:00: root bus resource [io  0x0000-0x3fff]
>> [    2.350114] pci_bus 0000:00: root bus resource [mem 0x50000000-0x5fffffff]
>> [    2.357095] pci 0000:00:00.0: [104c:b00b] type 01 class 0x060400
>> [    2.357665] PCI: bus0: Fast back to back transfers disabled
>> [    2.363717] pci 0000:01:00.0: [10ec:8168] type 00 class 0x020000
>> [    2.363809] pci 0000:01:00.0: reg 0x10: [io  0x0000-0x00ff]
>> [    2.363867] pci 0000:01:00.0: reg 0x18: [mem 0x00000000-0x00000fff 64bit]
>> [    2.363909] pci 0000:01:00.0: reg 0x20: [mem 0x00000000-0x0000ffff 64bit pref]
>> [    2.363939] pci 0000:01:00.0: reg 0x30: [mem 0x00000000-0x0001ffff pref]
>> [    2.364099] pci 0000:01:00.0: supports D1 D2
>> [    2.364116] pci 0000:01:00.0: PME# supported from D0 D1 D2 D3hot D3cold
>> [    2.381251] PCI: bus1: Fast back to back transfers disabled
>> [    2.386989] pci 0000:00:00.0: BAR 8: assigned [mem 0x50000000-0x500fffff]
>> [    2.393937] pci 0000:00:00.0: BAR 9: assigned [mem 0x50100000-0x501fffff pref]
>> [    2.401221] pci 0000:00:00.0: BAR 7: assigned [io  0x1000-0x1fff]
>> [    2.407320] pci 0000:01:00.0: BAR 6: assigned [mem 0x50100000-0x5011ffff pref]
>> [    2.414597] pci 0000:01:00.0: BAR 4: assigned [mem 0x50120000-0x5012ffff 64bit pref]
>> [    2.422380] pci 0000:01:00.0: BAR 2: assigned [mem 0x50000000-0x50000fff 64bit]
>> [    2.429702] pci 0000:01:00.0: BAR 0: assigned [io  0x1000-0x10ff]
>> [    2.435821] pci 0000:00:00.0: PCI bridge to [bus 01]
>> [    2.440783] pci 0000:00:00.0:   bridge window [io  0x1000-0x1fff]
>> [    2.446896] pci 0000:00:00.0:   bridge window [mem 0x50000000-0x500fffff]
>> [    2.453699] pci 0000:00:00.0:   bridge window [mem 0x50100000-0x501fffff pref]
>> [    2.461453] pcieport 0000:00:00.0: Signaling PME through PCIe PME interrupt
>> [    2.468411] pci 0000:01:00.0: Signaling PME through PCIe PME interrupt
>> [    2.475075] pcie_pme 0000:00:00.0:pcie01: service driver pcie_pme loaded
>> [    2.475392] aer 0000:00:00.0:pcie02: service driver aer loaded
>> [    2.475652] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
>> [    2.481419] r8169 0000:01:00.0: enabling device (0140 -> 0143)
>> [    2.488865] r8169 0000:01:00.0 eth0: RTL8169 at 0xf0d6a000, 00:00:00:00:00:00, XID 00000000 IRQ 286
> 
> No need to go further, there is a serious problem here.
> 
> Most of the XID bits are read from a mapped register. They're definitely not
> expected to be null as the driver requires it to identify a proper chipset
> (the common PCI configuration registers only tell that you aren't dealing
> with a coffee machine).
> 
> Any read returning zeroes would not surprize me.
> 
> [...]
>> Can someone help me figure out what is missing ?
> 
> Hardly at this point. I can only suggest to switch power off, plug
> the 8168 device in a x86 (32 or 64 bits) system and check how it behaves.
> 


-- 
Murali Karicheri
Linux Kernel, Keystone
