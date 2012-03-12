From: Peter Volkov <pva@gentoo.org>
Subject: bnx2: generic-receive-offload causes packet drops
Date: Mon, 12 Mar 2012 12:54:29 +0400
Message-ID: <1331542469.10004.26.camel@tablet>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:36394 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752110Ab2CLIz7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2012 04:55:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Michael. We use Broadcom Corporation NetXtreme II BCM5709 Gigabit
Ethernet adapters on two servers NFS server and NFS client. For some
reason generic-receive-offload causes lots of packet drops on nfs client
during large volume data transfers.

Our setup consists of two servers: server A with 14 and server B with 4
gigabit network cards and 2 10GbE. All interfaces are combined in
bonding (mode=4) and we use vlans on top of aggregated bond0 device.
Server A provides nfs service. While gro is enabled on server B data
copying from server hangs after first ~60 Mbytes copied.  At the same
time if gro is enabled on nfs server and writing to nfs sever works.
Note: our nfs service is provided by zfs in kernel module. On servers we
use linux kernel versions 3.2.6 (server A) and 3.2.9 (server B).  

So questions:  Is this expected? What information can we provide to
debug is issue?


server A (nfs):
 # ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc mq master bond0 state UP qlen 1000
    link/ether 00:10:18:a8:a3:48 brd ff:ff:ff:ff:ff:ff
3: eth1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc mq master bond0 state UP qlen 1000
    link/ether 00:10:18:a8:a3:48 brd ff:ff:ff:ff:ff:ff
4: eth2: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc mq master bond0 state UP qlen 1000
    link/ether 00:10:18:a8:a3:48 brd ff:ff:ff:ff:ff:ff
5: eth3: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc mq master bond0 state UP qlen 1000
    link/ether 00:10:18:a8:a3:48 brd ff:ff:ff:ff:ff:ff
6: eth4: <NO-CARRIER,BROADCAST,MULTICAST,SLAVE,UP> mtu 1500 qdisc mq master bond0 state DOWN qlen 1000
    link/ether 00:10:18:a8:a3:48 brd ff:ff:ff:ff:ff:ff
7: eth5: <NO-CARRIER,BROADCAST,MULTICAST,SLAVE,UP> mtu 1500 qdisc mq master bond0 state DOWN qlen 1000
    link/ether 00:10:18:a8:a3:48 brd ff:ff:ff:ff:ff:ff
8: eth6: <NO-CARRIER,BROADCAST,MULTICAST,SLAVE,UP> mtu 1500 qdisc mq master bond0 state DOWN qlen 1000
    link/ether 00:10:18:a8:a3:48 brd ff:ff:ff:ff:ff:ff
9: eth7: <NO-CARRIER,BROADCAST,MULTICAST,SLAVE,UP> mtu 1500 qdisc mq master bond0 state DOWN qlen 1000
    link/ether 00:10:18:a8:a3:48 brd ff:ff:ff:ff:ff:ff
10: eth8: <NO-CARRIER,BROADCAST,MULTICAST,SLAVE,UP> mtu 1500 qdisc mq master bond0 state DOWN qlen 1000
    link/ether 00:10:18:a8:a3:48 brd ff:ff:ff:ff:ff:ff
11: eth9: <NO-CARRIER,BROADCAST,MULTICAST,SLAVE,UP> mtu 1500 qdisc mq master bond0 state DOWN qlen 1000
    link/ether 00:10:18:a8:a3:48 brd ff:ff:ff:ff:ff:ff
12: eth10: <NO-CARRIER,BROADCAST,MULTICAST,SLAVE,UP> mtu 1500 qdisc mq master bond0 state DOWN qlen 1000
    link/ether 00:10:18:a8:a3:48 brd ff:ff:ff:ff:ff:ff
13: eth11: <NO-CARRIER,BROADCAST,MULTICAST,SLAVE,UP> mtu 1500 qdisc mq master bond0 state DOWN qlen 1000
    link/ether 00:10:18:a8:a3:48 brd ff:ff:ff:ff:ff:ff
14: eth12: <NO-CARRIER,BROADCAST,MULTICAST,SLAVE,UP> mtu 1500 qdisc pfifo_fast master bond0 state DOWN qlen 1000
    link/ether 00:10:18:a8:a3:48 brd ff:ff:ff:ff:ff:ff
15: eth13: <NO-CARRIER,BROADCAST,MULTICAST,SLAVE,UP> mtu 1500 qdisc pfifo_fast master bond0 state DOWN qlen 1000
    link/ether 00:10:18:a8:a3:48 brd ff:ff:ff:ff:ff:ff
16: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP 
    link/ether 00:10:18:a8:a3:48 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::210:18ff:fea8:a348/64 scope link 
       valid_lft forever preferred_lft forever
17: vlan160@bond0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP 
    link/ether 00:10:18:a8:a3:48 brd ff:ff:ff:ff:ff:ff
    inet 10.36.198.101/26 brd 10.36.198.127 scope global vlan160
    inet6 fe80::210:18ff:fea8:a348/64 scope link 
       valid_lft forever preferred_lft forever
18: vlan161@bond0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP 
    link/ether 00:10:18:a8:a3:48 brd ff:ff:ff:ff:ff:ff
    inet 192.168.185.37/26 brd 192.168.185.63 scope global vlan161
    inet6 fe80::210:18ff:fea8:a348/64 scope link 
       valid_lft forever preferred_lft forever

 # cat /proc/net/bonding/bond0 
Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)

Bonding Mode: IEEE 802.3ad Dynamic link aggregation
Transmit Hash Policy: layer2 (0)
MII Status: up
MII Polling Interval (ms): 0
Up Delay (ms): 0
Down Delay (ms): 0

802.3ad info
LACP rate: slow
Min links: 0
Aggregator selection policy (ad_select): stable
Active Aggregator Info:
	Aggregator ID: 1
	Number of ports: 4
	Actor Key: 17
	Partner Key: 15
	Partner Mac Address: 02:00:00:00:00:64

Slave Interface: eth0
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 00:10:18:a8:a3:48
Aggregator ID: 1
Slave queue ID: 0

Slave Interface: eth1
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 00:10:18:a8:a3:4a
Aggregator ID: 1
Slave queue ID: 0

Slave Interface: eth2
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 00:10:18:a8:a3:4c
Aggregator ID: 1
Slave queue ID: 0

Slave Interface: eth3
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 00:10:18:a8:a3:4e
Aggregator ID: 1
Slave queue ID: 0

Slave Interface: eth4
MII Status: up
Speed: Unknown
Duplex: Unknown
Link Failure Count: 0
Permanent HW addr: 00:10:18:a8:a3:28
Aggregator ID: 5
Slave queue ID: 0

Slave Interface: eth5
MII Status: up
Speed: Unknown
Duplex: Unknown
Link Failure Count: 0
Permanent HW addr: 00:10:18:a8:a3:2a
Aggregator ID: 6
Slave queue ID: 0

Slave Interface: eth6
MII Status: up
Speed: Unknown
Duplex: Unknown
Link Failure Count: 0
Permanent HW addr: 00:10:18:a8:a3:2c
Aggregator ID: 7
Slave queue ID: 0

Slave Interface: eth7
MII Status: up
Speed: Unknown
Duplex: Unknown
Link Failure Count: 0
Permanent HW addr: 00:10:18:a8:a3:2e
Aggregator ID: 8
Slave queue ID: 0

Slave Interface: eth8
MII Status: up
Speed: Unknown
Duplex: Unknown
Link Failure Count: 0
Permanent HW addr: 00:10:18:a8:a3:e0
Aggregator ID: 9
Slave queue ID: 0

Slave Interface: eth9
MII Status: up
Speed: Unknown
Duplex: Unknown
Link Failure Count: 0
Permanent HW addr: 00:10:18:a8:a3:e2
Aggregator ID: 10
Slave queue ID: 0

Slave Interface: eth10
MII Status: up
Speed: Unknown
Duplex: Unknown
Link Failure Count: 0
Permanent HW addr: 00:10:18:a8:a3:e4
Aggregator ID: 11
Slave queue ID: 0

Slave Interface: eth11
MII Status: up
Speed: Unknown
Duplex: Unknown
Link Failure Count: 0
Permanent HW addr: 00:10:18:a8:a3:e6
Aggregator ID: 12
Slave queue ID: 0

Slave Interface: eth12
MII Status: up
Speed: Unknown
Duplex: Unknown
Link Failure Count: 0
Permanent HW addr: 00:25:90:55:b7:a9
Aggregator ID: 13
Slave queue ID: 0

Slave Interface: eth13
MII Status: up
Speed: Unknown
Duplex: Unknown
Link Failure Count: 0
Permanent HW addr: 00:25:90:55:b7:a8
Aggregator ID: 14
Slave queue ID: 0


 # lspci -v
00:00.0 Host bridge: Intel Corporation Xeon E3-1200 Processor Family DRAM Controller (rev 09)
	Subsystem: Super Micro Computer Inc Device 0624
	Flags: bus master, fast devsel, latency 0
	Capabilities: [e0] Vendor Specific Information: Len=0c <?>

00:01.0 PCI bridge: Intel Corporation Xeon E3-1200/2nd Generation Core Processor Family PCI Express Root Port (rev 09) (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
	I/O behind bridge: 0000e000-0000efff
	Memory behind bridge: dea00000-deafffff
	Capabilities: [88] Subsystem: Super Micro Computer Inc Device 0624
	Capabilities: [80] Power Management version 3
	Capabilities: [90] MSI: Enable+ Count=1/1 Maskable- 64bit-
	Capabilities: [a0] Express Root Port (Slot+), MSI 00
	Capabilities: [100] Virtual Channel
	Capabilities: [140] Root Complex Link
	Kernel driver in use: pcieport

00:01.1 PCI bridge: Intel Corporation Xeon E3-1200/2nd Generation Core Processor Family PCI Express Root Port (rev 09) (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=00, secondary=02, subordinate=05, sec-latency=0
	Memory behind bridge: d6000000-ddffffff
	Capabilities: [88] Subsystem: Super Micro Computer Inc Device 0624
	Capabilities: [80] Power Management version 3
	Capabilities: [90] MSI: Enable+ Count=1/1 Maskable- 64bit-
	Capabilities: [a0] Express Root Port (Slot+), MSI 00
	Capabilities: [100] Virtual Channel
	Capabilities: [140] Root Complex Link
	Kernel driver in use: pcieport

00:06.0 PCI bridge: Intel Corporation Xeon E3-1200/2nd Generation Core Processor Family PCI Express Root Port (rev 09) (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=00, secondary=06, subordinate=09, sec-latency=0
	Memory behind bridge: ce000000-d5ffffff
	Capabilities: [88] Subsystem: Super Micro Computer Inc Device 0624
	Capabilities: [80] Power Management version 3
	Capabilities: [90] MSI: Enable+ Count=1/1 Maskable- 64bit-
	Capabilities: [a0] Express Root Port (Slot+), MSI 00
	Capabilities: [100] Virtual Channel
	Capabilities: [140] Root Complex Link
	Kernel driver in use: pcieport

00:19.0 Ethernet controller: Intel Corporation 82579LM Gigabit Network Connection (rev 05)
	Subsystem: Super Micro Computer Inc Device 1502
	Flags: bus master, fast devsel, latency 0, IRQ 52
	Memory at deb00000 (32-bit, non-prefetchable) [size=128K]
	Memory at deb23000 (32-bit, non-prefetchable) [size=4K]
	I/O ports at f000 [size=32]
	Capabilities: [c8] Power Management version 2
	Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
	Capabilities: [e0] PCI Advanced Features
	Kernel driver in use: e1000e

00:1a.0 USB controller: Intel Corporation 6 Series/C200 Series Chipset Family USB Enhanced Host Controller #2 (rev 05) (prog-if 20 [EHCI])
	Subsystem: Super Micro Computer Inc Device 0624
	Flags: bus master, medium devsel, latency 0, IRQ 16
	Memory at deb22000 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [50] Power Management version 2
	Capabilities: [58] Debug port: BAR=1 offset=00a0
	Capabilities: [98] PCI Advanced Features
	Kernel driver in use: ehci_hcd

00:1c.0 PCI bridge: Intel Corporation 6 Series/C200 Series Chipset Family PCI Express Root Port 1 (rev b5) (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=00, secondary=0a, subordinate=0d, sec-latency=0
	Memory behind bridge: c6000000-cdffffff
	Capabilities: [40] Express Root Port (Slot+), MSI 00
	Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
	Capabilities: [90] Subsystem: Super Micro Computer Inc Device 0624
	Capabilities: [a0] Power Management version 2
	Kernel driver in use: pcieport

00:1c.4 PCI bridge: Intel Corporation 6 Series/C200 Series Chipset Family PCI Express Root Port 5 (rev b5) (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=00, secondary=0e, subordinate=0e, sec-latency=0
	I/O behind bridge: 0000d000-0000dfff
	Memory behind bridge: de900000-de9fffff
	Capabilities: [40] Express Root Port (Slot+), MSI 00
	Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
	Capabilities: [90] Subsystem: Super Micro Computer Inc Device 0624
	Capabilities: [a0] Power Management version 2
	Kernel driver in use: pcieport

00:1d.0 USB controller: Intel Corporation 6 Series/C200 Series Chipset Family USB Enhanced Host Controller #1 (rev 05) (prog-if 20 [EHCI])
	Subsystem: Super Micro Computer Inc Device 0624
	Flags: bus master, medium devsel, latency 0, IRQ 23
	Memory at deb21000 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [50] Power Management version 2
	Capabilities: [58] Debug port: BAR=1 offset=00a0
	Capabilities: [98] PCI Advanced Features
	Kernel driver in use: ehci_hcd

00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev a5) (prog-if 01 [Subtractive decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=00, secondary=0f, subordinate=0f, sec-latency=64
	Memory behind bridge: de000000-de8fffff
	Prefetchable memory behind bridge: 00000000fb000000-00000000fbffffff
	Capabilities: [50] Subsystem: Super Micro Computer Inc Device 0624

00:1f.0 ISA bridge: Intel Corporation C204 Chipset Family LPC Controller (rev 05)
	Subsystem: Super Micro Computer Inc Device 0624
	Flags: bus master, medium devsel, latency 0
	Capabilities: [e0] Vendor Specific Information: Len=0c <?>

00:1f.3 SMBus: Intel Corporation 6 Series/C200 Series Chipset Family SMBus Controller (rev 05)
	Subsystem: Super Micro Computer Inc Device 0624
	Flags: medium devsel, IRQ 18
	Memory at deb20000 (64-bit, non-prefetchable) [size=256]
	I/O ports at 1180 [size=32]
	Kernel modules: i2c-i801

01:00.0 RAID bus controller: LSI Logic / Symbios Logic MegaRAID SAS 2108 [Liberator] (rev 05)
	Subsystem: LSI Logic / Symbios Logic MegaRAID SAS 9261-8i
	Flags: bus master, fast devsel, latency 0, IRQ 16
	I/O ports at e000 [size=256]
	Memory at dea60000 (64-bit, non-prefetchable) [size=16K]
	Memory at dea00000 (64-bit, non-prefetchable) [size=256K]
	Expansion ROM at dea40000 [disabled] [size=128K]
	Capabilities: [50] Power Management version 3
	Capabilities: [68] Express Endpoint, MSI 00
	Capabilities: [d0] Vital Product Data
	Capabilities: [a8] MSI: Enable- Count=1/1 Maskable- 64bit+
	Capabilities: [c0] MSI-X: Enable+ Count=15 Masked-
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [138] Power Budgeting <?>
	Kernel driver in use: megaraid_sas

02:00.0 PCI bridge: Integrated Device Technology, Inc. PES12T3G2 PCI Express Gen2 Switch (rev 01) (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=02, secondary=03, subordinate=05, sec-latency=0
	Memory behind bridge: d6000000-ddffffff
	Capabilities: [40] Express Upstream Port, MSI 00
	Capabilities: [c0] Power Management version 3
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [200] Virtual Channel
	Kernel driver in use: pcieport

03:02.0 PCI bridge: Integrated Device Technology, Inc. PES12T3G2 PCI Express Gen2 Switch (rev 01) (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=03, secondary=04, subordinate=04, sec-latency=0
	Memory behind bridge: da000000-ddffffff
	Capabilities: [40] Express Downstream Port (Slot-), MSI 00
	Capabilities: [c0] Power Management version 3
	Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [200] Virtual Channel
	Kernel driver in use: pcieport

03:04.0 PCI bridge: Integrated Device Technology, Inc. PES12T3G2 PCI Express Gen2 Switch (rev 01) (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=03, secondary=05, subordinate=05, sec-latency=0
	Memory behind bridge: d6000000-d9ffffff
	Capabilities: [40] Express Downstream Port (Slot-), MSI 00
	Capabilities: [c0] Power Management version 3
	Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [200] Virtual Channel
	Kernel driver in use: pcieport

04:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
	Subsystem: Broadcom Corporation Device 0906
	Flags: bus master, fast devsel, latency 0, IRQ 19
	Memory at dc000000 (64-bit, non-prefetchable) [size=32M]
	Capabilities: [48] Power Management version 3
	Capabilities: [50] Vital Product Data
	Capabilities: [58] MSI: Enable- Count=1/16 Maskable- 64bit+
	Capabilities: [a0] MSI-X: Enable+ Count=9 Masked-
	Capabilities: [ac] Express Endpoint, MSI 00
	Capabilities: [100] Device Serial Number 00-10-18-ff-fe-a8-a3-48
	Capabilities: [110] Advanced Error Reporting
	Capabilities: [150] Power Budgeting <?>
	Capabilities: [160] Virtual Channel
	Kernel driver in use: bnx2

04:00.1 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
	Subsystem: Broadcom Corporation Device 0906
	Flags: bus master, fast devsel, latency 0, IRQ 16
	Memory at da000000 (64-bit, non-prefetchable) [size=32M]
	Capabilities: [48] Power Management version 3
	Capabilities: [50] Vital Product Data
	Capabilities: [58] MSI: Enable- Count=1/16 Maskable- 64bit+
	Capabilities: [a0] MSI-X: Enable+ Count=9 Masked-
	Capabilities: [ac] Express Endpoint, MSI 00
	Capabilities: [100] Device Serial Number 00-10-18-ff-fe-a8-a3-4a
	Capabilities: [110] Advanced Error Reporting
	Capabilities: [150] Power Budgeting <?>
	Capabilities: [160] Virtual Channel
	Kernel driver in use: bnx2

05:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
	Subsystem: Broadcom Corporation Device 1906
	Flags: bus master, fast devsel, latency 0, IRQ 17
	Memory at d8000000 (64-bit, non-prefetchable) [size=32M]
	Capabilities: [48] Power Management version 3
	Capabilities: [50] Vital Product Data
	Capabilities: [58] MSI: Enable- Count=1/16 Maskable- 64bit+
	Capabilities: [a0] MSI-X: Enable+ Count=9 Masked-
	Capabilities: [ac] Express Endpoint, MSI 00
	Capabilities: [100] Device Serial Number 00-10-18-ff-fe-a8-a3-4c
	Capabilities: [110] Advanced Error Reporting
	Capabilities: [150] Power Budgeting <?>
	Capabilities: [160] Virtual Channel
	Kernel driver in use: bnx2

05:00.1 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
	Subsystem: Broadcom Corporation Device 1906
	Flags: bus master, fast devsel, latency 0, IRQ 18
	Memory at d6000000 (64-bit, non-prefetchable) [size=32M]
	Capabilities: [48] Power Management version 3
	Capabilities: [50] Vital Product Data
	Capabilities: [58] MSI: Enable- Count=1/16 Maskable- 64bit+
	Capabilities: [a0] MSI-X: Enable+ Count=9 Masked-
	Capabilities: [ac] Express Endpoint, MSI 00
	Capabilities: [100] Device Serial Number 00-10-18-ff-fe-a8-a3-4e
	Capabilities: [110] Advanced Error Reporting
	Capabilities: [150] Power Budgeting <?>
	Capabilities: [160] Virtual Channel
	Kernel driver in use: bnx2

06:00.0 PCI bridge: Integrated Device Technology, Inc. PES12T3G2 PCI Express Gen2 Switch (rev 01) (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=06, secondary=07, subordinate=09, sec-latency=0
	Memory behind bridge: ce000000-d5ffffff
	Capabilities: [40] Express Upstream Port, MSI 00
	Capabilities: [c0] Power Management version 3
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [200] Virtual Channel
	Kernel driver in use: pcieport

07:02.0 PCI bridge: Integrated Device Technology, Inc. PES12T3G2 PCI Express Gen2 Switch (rev 01) (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=07, secondary=08, subordinate=08, sec-latency=0
	Memory behind bridge: d2000000-d5ffffff
	Capabilities: [40] Express Downstream Port (Slot-), MSI 00
	Capabilities: [c0] Power Management version 3
	Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [200] Virtual Channel
	Kernel driver in use: pcieport

07:04.0 PCI bridge: Integrated Device Technology, Inc. PES12T3G2 PCI Express Gen2 Switch (rev 01) (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=07, secondary=09, subordinate=09, sec-latency=0
	Memory behind bridge: ce000000-d1ffffff
	Capabilities: [40] Express Downstream Port (Slot-), MSI 00
	Capabilities: [c0] Power Management version 3
	Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [200] Virtual Channel
	Kernel driver in use: pcieport

08:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
	Subsystem: Broadcom Corporation Device 0906
	Flags: bus master, fast devsel, latency 0, IRQ 17
	Memory at d4000000 (64-bit, non-prefetchable) [size=32M]
	Capabilities: [48] Power Management version 3
	Capabilities: [50] Vital Product Data
	Capabilities: [58] MSI: Enable- Count=1/16 Maskable- 64bit+
	Capabilities: [a0] MSI-X: Enable+ Count=9 Masked-
	Capabilities: [ac] Express Endpoint, MSI 00
	Capabilities: [100] Device Serial Number 00-10-18-ff-fe-a8-a3-28
	Capabilities: [110] Advanced Error Reporting
	Capabilities: [150] Power Budgeting <?>
	Capabilities: [160] Virtual Channel
	Kernel driver in use: bnx2

08:00.1 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
	Subsystem: Broadcom Corporation Device 0906
	Flags: bus master, fast devsel, latency 0, IRQ 18
	Memory at d2000000 (64-bit, non-prefetchable) [size=32M]
	Capabilities: [48] Power Management version 3
	Capabilities: [50] Vital Product Data
	Capabilities: [58] MSI: Enable- Count=1/16 Maskable- 64bit+
	Capabilities: [a0] MSI-X: Enable+ Count=9 Masked-
	Capabilities: [ac] Express Endpoint, MSI 00
	Capabilities: [100] Device Serial Number 00-10-18-ff-fe-a8-a3-2a
	Capabilities: [110] Advanced Error Reporting
	Capabilities: [150] Power Budgeting <?>
	Capabilities: [160] Virtual Channel
	Kernel driver in use: bnx2

09:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
	Subsystem: Broadcom Corporation Device 1906
	Flags: bus master, fast devsel, latency 0, IRQ 19
	Memory at d0000000 (64-bit, non-prefetchable) [size=32M]
	Capabilities: [48] Power Management version 3
	Capabilities: [50] Vital Product Data
	Capabilities: [58] MSI: Enable- Count=1/16 Maskable- 64bit+
	Capabilities: [a0] MSI-X: Enable+ Count=9 Masked-
	Capabilities: [ac] Express Endpoint, MSI 00
	Capabilities: [100] Device Serial Number 00-10-18-ff-fe-a8-a3-2c
	Capabilities: [110] Advanced Error Reporting
	Capabilities: [150] Power Budgeting <?>
	Capabilities: [160] Virtual Channel
	Kernel driver in use: bnx2

09:00.1 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
	Subsystem: Broadcom Corporation Device 1906
	Flags: bus master, fast devsel, latency 0, IRQ 16
	Memory at ce000000 (64-bit, non-prefetchable) [size=32M]
	Capabilities: [48] Power Management version 3
	Capabilities: [50] Vital Product Data
	Capabilities: [58] MSI: Enable- Count=1/16 Maskable- 64bit+
	Capabilities: [a0] MSI-X: Enable+ Count=9 Masked-
	Capabilities: [ac] Express Endpoint, MSI 00
	Capabilities: [100] Device Serial Number 00-10-18-ff-fe-a8-a3-2e
	Capabilities: [110] Advanced Error Reporting
	Capabilities: [150] Power Budgeting <?>
	Capabilities: [160] Virtual Channel
	Kernel driver in use: bnx2

0a:00.0 PCI bridge: Integrated Device Technology, Inc. PES12T3G2 PCI Express Gen2 Switch (rev 01) (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=0a, secondary=0b, subordinate=0d, sec-latency=0
	Memory behind bridge: c6000000-cdffffff
	Capabilities: [40] Express Upstream Port, MSI 00
	Capabilities: [c0] Power Management version 3
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [200] Virtual Channel
	Kernel driver in use: pcieport

0b:02.0 PCI bridge: Integrated Device Technology, Inc. PES12T3G2 PCI Express Gen2 Switch (rev 01) (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=0b, secondary=0c, subordinate=0c, sec-latency=0
	Memory behind bridge: ca000000-cdffffff
	Capabilities: [40] Express Downstream Port (Slot-), MSI 00
	Capabilities: [c0] Power Management version 3
	Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [200] Virtual Channel
	Kernel driver in use: pcieport

0b:04.0 PCI bridge: Integrated Device Technology, Inc. PES12T3G2 PCI Express Gen2 Switch (rev 01) (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=0b, secondary=0d, subordinate=0d, sec-latency=0
	Memory behind bridge: c6000000-c9ffffff
	Capabilities: [40] Express Downstream Port (Slot-), MSI 00
	Capabilities: [c0] Power Management version 3
	Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [200] Virtual Channel
	Kernel driver in use: pcieport

0c:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
	Subsystem: Broadcom Corporation Device 0906
	Flags: bus master, fast devsel, latency 0, IRQ 18
	Memory at cc000000 (64-bit, non-prefetchable) [size=32M]
	Capabilities: [48] Power Management version 3
	Capabilities: [50] Vital Product Data
	Capabilities: [58] MSI: Enable- Count=1/16 Maskable- 64bit+
	Capabilities: [a0] MSI-X: Enable+ Count=9 Masked-
	Capabilities: [ac] Express Endpoint, MSI 00
	Capabilities: [100] Device Serial Number 00-10-18-ff-fe-a8-a3-e0
	Capabilities: [110] Advanced Error Reporting
	Capabilities: [150] Power Budgeting <?>
	Capabilities: [160] Virtual Channel
	Kernel driver in use: bnx2

0c:00.1 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
	Subsystem: Broadcom Corporation Device 0906
	Flags: bus master, fast devsel, latency 0, IRQ 19
	Memory at ca000000 (64-bit, non-prefetchable) [size=32M]
	Capabilities: [48] Power Management version 3
	Capabilities: [50] Vital Product Data
	Capabilities: [58] MSI: Enable- Count=1/16 Maskable- 64bit+
	Capabilities: [a0] MSI-X: Enable+ Count=9 Masked-
	Capabilities: [ac] Express Endpoint, MSI 00
	Capabilities: [100] Device Serial Number 00-10-18-ff-fe-a8-a3-e2
	Capabilities: [110] Advanced Error Reporting
	Capabilities: [150] Power Budgeting <?>
	Capabilities: [160] Virtual Channel
	Kernel driver in use: bnx2

0d:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
	Subsystem: Broadcom Corporation Device 1906
	Flags: bus master, fast devsel, latency 0, IRQ 16
	Memory at c8000000 (64-bit, non-prefetchable) [size=32M]
	Capabilities: [48] Power Management version 3
	Capabilities: [50] Vital Product Data
	Capabilities: [58] MSI: Enable- Count=1/16 Maskable- 64bit+
	Capabilities: [a0] MSI-X: Enable+ Count=9 Masked-
	Capabilities: [ac] Express Endpoint, MSI 00
	Capabilities: [100] Device Serial Number 00-10-18-ff-fe-a8-a3-e4
	Capabilities: [110] Advanced Error Reporting
	Capabilities: [150] Power Budgeting <?>
	Capabilities: [160] Virtual Channel
	Kernel driver in use: bnx2

0d:00.1 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
	Subsystem: Broadcom Corporation Device 1906
	Flags: bus master, fast devsel, latency 0, IRQ 17
	Memory at c6000000 (64-bit, non-prefetchable) [size=32M]
	Capabilities: [48] Power Management version 3
	Capabilities: [50] Vital Product Data
	Capabilities: [58] MSI: Enable- Count=1/16 Maskable- 64bit+
	Capabilities: [a0] MSI-X: Enable+ Count=9 Masked-
	Capabilities: [ac] Express Endpoint, MSI 00
	Capabilities: [100] Device Serial Number 00-10-18-ff-fe-a8-a3-e6
	Capabilities: [110] Advanced Error Reporting
	Capabilities: [150] Power Budgeting <?>
	Capabilities: [160] Virtual Channel
	Kernel driver in use: bnx2

0e:00.0 Ethernet controller: Intel Corporation 82574L Gigabit Network Connection
	Subsystem: Super Micro Computer Inc Device 0000
	Flags: bus master, fast devsel, latency 0, IRQ 16
	Memory at de900000 (32-bit, non-prefetchable) [size=128K]
	I/O ports at d000 [size=32]
	Memory at de920000 (32-bit, non-prefetchable) [size=16K]
	Capabilities: [c8] Power Management version 2
	Capabilities: [d0] MSI: Enable- Count=1/1 Maskable- 64bit+
	Capabilities: [e0] Express Endpoint, MSI 00
	Capabilities: [a0] MSI-X: Enable+ Count=5 Masked-
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [140] Device Serial Number 00-25-90-ff-ff-55-b7-a8
	Kernel driver in use: e1000e

0f:03.0 VGA compatible controller: Matrox Graphics, Inc. MGA G200eW WPCM450 (rev 0a) (prog-if 00 [VGA controller])
	Flags: bus master, medium devsel, latency 64, IRQ 7
	Memory at fb000000 (32-bit, prefetchable) [size=16M]
	Memory at de800000 (32-bit, non-prefetchable) [size=16K]
	Memory at de000000 (32-bit, non-prefetchable) [size=8M]
	Expansion ROM at <unassigned> [disabled]
	Capabilities: [dc] Power Management version 1


Server B:
 # ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc mq master bond0 state UP qlen 1000
    link/ether 3c:d9:2b:ef:e0:3c brd ff:ff:ff:ff:ff:ff
3: eth1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc mq master bond0 state UP qlen 1000
    link/ether 3c:d9:2b:ef:e0:3c brd ff:ff:ff:ff:ff:ff
4: eth2: <NO-CARRIER,BROADCAST,MULTICAST,SLAVE,UP> mtu 1500 qdisc mq master bond0 state DOWN qlen 1000
    link/ether 3c:d9:2b:ef:e0:3c brd ff:ff:ff:ff:ff:ff
5: eth3: <NO-CARRIER,BROADCAST,MULTICAST,SLAVE,UP> mtu 1500 qdisc mq master bond0 state DOWN qlen 1000
    link/ether 3c:d9:2b:ef:e0:3c brd ff:ff:ff:ff:ff:ff
6: eth4: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN qlen 1000
    link/ether 78:e3:b5:f5:86:30 brd ff:ff:ff:ff:ff:ff
7: eth5: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN qlen 1000
    link/ether 78:e3:b5:f5:86:34 brd ff:ff:ff:ff:ff:ff
17: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP 
    link/ether 3c:d9:2b:ef:e0:3c brd ff:ff:ff:ff:ff:ff
    inet6 fe80::3ed9:2bff:feef:e03c/64 scope link 
       valid_lft forever preferred_lft forever
18: vlan160@bond0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP 
    link/ether 3c:d9:2b:ef:e0:3c brd ff:ff:ff:ff:ff:ff
    inet 10.36.198.92/26 brd 10.36.198.127 scope global vlan160
    inet6 fe80::3ed9:2bff:feef:e03c/64 scope link 
       valid_lft forever preferred_lft forever
19: vlan161@bond0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP 
    link/ether 3c:d9:2b:ef:e0:3c brd ff:ff:ff:ff:ff:ff
    inet 192.168.185.28/26 brd 192.168.185.63 scope global vlan161
    inet6 fe80::3ed9:2bff:feef:e03c/64 scope link 
       valid_lft forever preferred_lft forever
20: vlan162@bond0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP 
    link/ether 3c:d9:2b:ef:e0:3c brd ff:ff:ff:ff:ff:ff
    inet 172.30.10.28/24 brd 172.30.10.255 scope global vlan162
    inet6 fe80::3ed9:2bff:feef:e03c/64 scope link 
       valid_lft forever preferred_lft forever
21: vlan163@bond0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP 
    link/ether 3c:d9:2b:ef:e0:3c brd ff:ff:ff:ff:ff:ff
    inet 172.30.33.28/24 brd 172.30.33.255 scope global vlan163
    inet6 fe80::3ed9:2bff:feef:e03c/64 scope link 
       valid_lft forever preferred_lft forever
22: vlan171@bond0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP 
    link/ether 3c:d9:2b:ef:e0:3c brd ff:ff:ff:ff:ff:ff
    inet XX/27 brd XX scope global vlan171
    inet6 fe80::3ed9:2bff:feef:e03c/64 scope link 
       valid_lft forever preferred_lft forever
 # cat /proc/net/bonding/bond0 
Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)

Bonding Mode: IEEE 802.3ad Dynamic link aggregation
Transmit Hash Policy: layer2 (0)
MII Status: up
MII Polling Interval (ms): 0
Up Delay (ms): 0
Down Delay (ms): 0

802.3ad info
LACP rate: slow
Min links: 0
Aggregator selection policy (ad_select): stable
Active Aggregator Info:
	Aggregator ID: 1
	Number of ports: 2
	Actor Key: 17
	Partner Key: 4
	Partner Mac Address: 02:00:00:00:00:64

Slave Interface: eth0
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 3c:d9:2b:ef:e0:3c
Aggregator ID: 1
Slave queue ID: 0

Slave Interface: eth1
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 3c:d9:2b:ef:e0:3e
Aggregator ID: 1
Slave queue ID: 0

Slave Interface: eth2
MII Status: up
Speed: Unknown
Duplex: Unknown
Link Failure Count: 0
Permanent HW addr: 3c:d9:2b:ef:e0:44
Aggregator ID: 3
Slave queue ID: 0

Slave Interface: eth3
MII Status: up
Speed: Unknown
Duplex: Unknown
Link Failure Count: 0
Permanent HW addr: 3c:d9:2b:ef:e0:46
Aggregator ID: 4
Slave queue ID: 0
 # lspci -v
00:00.0 Host bridge: Intel Corporation 5520 I/O Hub to ESI Port (rev 13)
	Subsystem: Hewlett-Packard Company Device 330b
	Flags: fast devsel
	Capabilities: [60] MSI: Enable- Count=1/2 Maskable+ 64bit-
	Capabilities: [90] Express Root Port (Slot-), MSI 00
	Capabilities: [e0] Power Management version 3
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [150] Access Control Services
	Capabilities: [160] Vendor Specific Information: ID=0002 Rev=0 Len=00c <?>

00:01.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express Root Port 1 (rev 13) (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=00, secondary=05, subordinate=05, sec-latency=0
	I/O behind bridge: 00004000-00004fff
	Memory behind bridge: f3d00000-f3ffffff
	Prefetchable memory behind bridge: 00000000df000000-00000000df0fffff
	Capabilities: [40] Subsystem: Hewlett-Packard Company Device 330b
	Capabilities: [60] MSI: Enable- Count=1/2 Maskable+ 64bit-
	Capabilities: [90] Express Root Port (Slot-), MSI 00
	Capabilities: [e0] Power Management version 3
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [150] Access Control Services
	Capabilities: [160] Vendor Specific Information: ID=0002 Rev=0 Len=00c <?>
	Kernel driver in use: pcieport

00:02.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express Root Port 2 (rev 13) (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=00, secondary=0c, subordinate=0c, sec-latency=0
	Capabilities: [40] Subsystem: Hewlett-Packard Company Device 330b
	Capabilities: [60] MSI: Enable- Count=1/2 Maskable+ 64bit-
	Capabilities: [90] Express Root Port (Slot-), MSI 00
	Capabilities: [e0] Power Management version 3
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [150] Access Control Services
	Kernel driver in use: pcieport

00:03.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express Root Port 3 (rev 13) (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=00, secondary=09, subordinate=0b, sec-latency=0
	Capabilities: [40] Subsystem: Hewlett-Packard Company Device 330b
	Capabilities: [60] MSI: Enable- Count=1/2 Maskable+ 64bit-
	Capabilities: [90] Express Root Port (Slot-), MSI 00
	Capabilities: [e0] Power Management version 3
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [150] Access Control Services
	Capabilities: [160] Vendor Specific Information: ID=0002 Rev=0 Len=00c <?>
	Kernel driver in use: pcieport

00:04.0 PCI bridge: Intel Corporation 5520/X58 I/O Hub PCI Express Root Port 4 (rev 13) (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=00, secondary=0d, subordinate=0d, sec-latency=0
	Capabilities: [40] Subsystem: Hewlett-Packard Company Device 330b
	Capabilities: [60] MSI: Enable- Count=1/2 Maskable+ 64bit-
	Capabilities: [90] Express Root Port (Slot-), MSI 00
	Capabilities: [e0] Power Management version 3
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [150] Access Control Services
	Kernel driver in use: pcieport

00:05.0 PCI bridge: Intel Corporation 5520/X58 I/O Hub PCI Express Root Port 5 (rev 13) (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=00, secondary=0e, subordinate=0e, sec-latency=0
	Capabilities: [40] Subsystem: Hewlett-Packard Company Device 330b
	Capabilities: [60] MSI: Enable- Count=1/2 Maskable+ 64bit-
	Capabilities: [90] Express Root Port (Slot-), MSI 00
	Capabilities: [e0] Power Management version 3
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [150] Access Control Services
	Kernel driver in use: pcieport

00:06.0 PCI bridge: Intel Corporation 5520/X58 I/O Hub PCI Express Root Port 6 (rev 13) (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=00, secondary=0f, subordinate=0f, sec-latency=0
	Capabilities: [40] Subsystem: Hewlett-Packard Company Device 330b
	Capabilities: [60] MSI: Enable- Count=1/2 Maskable+ 64bit-
	Capabilities: [90] Express Root Port (Slot-), MSI 00
	Capabilities: [e0] Power Management version 3
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [150] Access Control Services
	Kernel driver in use: pcieport

00:07.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express Root Port 7 (rev 13) (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=00, secondary=03, subordinate=03, sec-latency=0
	Memory behind bridge: ea000000-edffffff
	Prefetchable memory behind bridge: 00000000df100000-00000000df1fffff
	Capabilities: [40] Subsystem: Hewlett-Packard Company Device 330b
	Capabilities: [60] MSI: Enable- Count=1/2 Maskable+ 64bit-
	Capabilities: [90] Express Root Port (Slot-), MSI 00
	Capabilities: [e0] Power Management version 3
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [150] Access Control Services
	Capabilities: [160] Vendor Specific Information: ID=0002 Rev=0 Len=00c <?>
	Kernel driver in use: pcieport

00:08.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express Root Port 8 (rev 13) (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=00, secondary=04, subordinate=04, sec-latency=0
	Memory behind bridge: ee000000-f1ffffff
	Prefetchable memory behind bridge: 00000000df200000-00000000df2fffff
	Capabilities: [40] Subsystem: Hewlett-Packard Company Device 330b
	Capabilities: [60] MSI: Enable- Count=1/2 Maskable+ 64bit-
	Capabilities: [90] Express Root Port (Slot-), MSI 00
	Capabilities: [e0] Power Management version 3
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [150] Access Control Services
	Kernel driver in use: pcieport

00:09.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express Root Port 9 (rev 13) (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=00, secondary=06, subordinate=08, sec-latency=0
	Memory behind bridge: f4000000-fbffffff
	Prefetchable memory behind bridge: 00000000df300000-00000000df3fffff
	Capabilities: [40] Subsystem: Hewlett-Packard Company Device 330b
	Capabilities: [60] MSI: Enable- Count=1/2 Maskable+ 64bit-
	Capabilities: [90] Express Root Port (Slot-), MSI 00
	Capabilities: [e0] Power Management version 3
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [150] Access Control Services
	Kernel driver in use: pcieport

00:0a.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express Root Port 10 (rev 13) (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=00, secondary=10, subordinate=10, sec-latency=0
	Capabilities: [40] Subsystem: Hewlett-Packard Company Device 330b
	Capabilities: [60] MSI: Enable- Count=1/2 Maskable+ 64bit-
	Capabilities: [90] Express Root Port (Slot-), MSI 00
	Capabilities: [e0] Power Management version 3
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [150] Access Control Services
	Kernel driver in use: pcieport

00:0d.0 Host bridge: Intel Corporation Device 343a (rev 13)
	Flags: fast devsel
	Capabilities: [40] Express Root Complex Integrated Endpoint, MSI 00
	Capabilities: [60] #00 [0000]
	Capabilities: [100] Vendor Specific Information: ID=0001 Rev=0 Len=0b8 <?>
	Capabilities: [800] Vendor Specific Information: ID=0001 Rev=0 Len=0b8 <?>

00:0d.1 Host bridge: Intel Corporation Device 343b (rev 13)
	Flags: fast devsel
	Capabilities: [40] Express Root Complex Integrated Endpoint, MSI 00
	Capabilities: [60] #00 [0000]
	Capabilities: [100] Vendor Specific Information: ID=0001 Rev=0 Len=0b8 <?>
	Capabilities: [800] Vendor Specific Information: ID=0001 Rev=0 Len=0b8 <?>

00:0d.2 Host bridge: Intel Corporation Device 343c (rev 13)
	Flags: fast devsel
	Capabilities: [40] Express Root Complex Integrated Endpoint, MSI 00
	Capabilities: [60] #00 [0000]

00:0d.3 Host bridge: Intel Corporation Device 343d (rev 13)
	Flags: fast devsel
	Capabilities: [40] Express Root Complex Integrated Endpoint, MSI 00
	Capabilities: [60] #00 [0000]
	Capabilities: [100] Vendor Specific Information: ID=0001 Rev=0 Len=0b8 <?>

00:0d.4 Host bridge: Intel Corporation 5520/5500/X58 Physical Layer Port 0 (rev 13)
	Flags: fast devsel
	Capabilities: [40] Express Root Complex Integrated Endpoint, MSI 00
	Capabilities: [60] #00 [0000]

00:0d.5 Host bridge: Intel Corporation 5520/5500 Physical Layer Port 1 (rev 13)
	Flags: fast devsel
	Capabilities: [40] Express Root Complex Integrated Endpoint, MSI 00
	Capabilities: [60] #00 [0000]

00:0d.6 Host bridge: Intel Corporation Device 341a (rev 13)
	Flags: fast devsel
	Capabilities: [40] Express Root Complex Integrated Endpoint, MSI 00
	Capabilities: [60] #00 [0000]

00:0e.0 Host bridge: Intel Corporation Device 341c (rev 13)
	Flags: fast devsel
	Capabilities: [40] Express Root Complex Integrated Endpoint, MSI 00
	Capabilities: [60] #00 [0000]
	Capabilities: [100] Vendor Specific Information: ID=0001 Rev=0 Len=0b8 <?>

00:0e.1 Host bridge: Intel Corporation Device 341d (rev 13)
	Flags: fast devsel
	Capabilities: [40] Express Root Complex Integrated Endpoint, MSI 00
	Capabilities: [60] #00 [0000]

00:0e.2 Host bridge: Intel Corporation Device 341e (rev 13)
	Flags: fast devsel
	Capabilities: [40] Express Root Complex Integrated Endpoint, MSI 00
	Capabilities: [60] #00 [0000]

00:0e.3 Host bridge: Intel Corporation Device 341f (rev 13)
	Flags: fast devsel
	Capabilities: [40] Express Root Complex Integrated Endpoint, MSI 00
	Capabilities: [60] #00 [0000]

00:0e.4 Host bridge: Intel Corporation Device 3439 (rev 13)
	Flags: fast devsel
	Capabilities: [40] Express Root Complex Integrated Endpoint, MSI 00

00:14.0 PIC: Intel Corporation 5520/5500/X58 I/O Hub System Management Registers (rev 13) (prog-if 00 [8259])
	Subsystem: Device 003c:000b
	Flags: fast devsel
	Capabilities: [40] Express Root Complex Integrated Endpoint, MSI 00
	Kernel driver in use: i7core_edac

00:14.1 PIC: Intel Corporation 5520/5500/X58 I/O Hub GPIO and Scratch Pad Registers (rev 13) (prog-if 00 [8259])
	Subsystem: Device 003c:000b
	Flags: fast devsel
	Capabilities: [40] Express Root Complex Integrated Endpoint, MSI 00

00:14.2 PIC: Intel Corporation 5520/5500/X58 I/O Hub Control Status and RAS Registers (rev 13) (prog-if 00 [8259])
	Subsystem: Device 003c:000b
	Flags: fast devsel
	Capabilities: [40] Express Root Complex Integrated Endpoint, MSI 00

00:1c.0 PCI bridge: Intel Corporation 82801JI (ICH10 Family) PCI Express Root Port 1 (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=00, secondary=11, subordinate=11, sec-latency=0
	Capabilities: [40] Express Root Port (Slot-), MSI 00
	Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
	Capabilities: [90] Subsystem: Hewlett-Packard Company Device 330d
	Capabilities: [a0] Power Management version 2
	Capabilities: [100] Virtual Channel
	Capabilities: [180] Root Complex Link
	Kernel driver in use: pcieport

00:1c.4 PCI bridge: Intel Corporation 82801JI (ICH10 Family) PCI Express Root Port 5 (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
	I/O behind bridge: 00003000-00003fff
	Memory behind bridge: e9d00000-e9ffffff
	Prefetchable memory behind bridge: 00000000df400000-00000000df4fffff
	Capabilities: [40] Express Root Port (Slot-), MSI 00
	Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
	Capabilities: [90] Subsystem: Hewlett-Packard Company Device 330d
	Capabilities: [a0] Power Management version 2
	Capabilities: [100] Virtual Channel
	Capabilities: [180] Root Complex Link
	Kernel driver in use: pcieport

00:1d.0 USB controller: Intel Corporation 82801JI (ICH10 Family) USB UHCI Controller #1 (prog-if 00 [UHCI])
	Subsystem: Hewlett-Packard Company Device 330d
	Flags: bus master, medium devsel, latency 0, IRQ 20
	I/O ports at 1000 [size=32]
	Capabilities: [50] PCI Advanced Features
	Kernel driver in use: uhci_hcd

00:1d.1 USB controller: Intel Corporation 82801JI (ICH10 Family) USB UHCI Controller #2 (prog-if 00 [UHCI])
	Subsystem: Hewlett-Packard Company Device 330d
	Flags: bus master, medium devsel, latency 0, IRQ 23
	I/O ports at 1020 [size=32]
	Capabilities: [50] PCI Advanced Features
	Kernel driver in use: uhci_hcd

00:1d.2 USB controller: Intel Corporation 82801JI (ICH10 Family) USB UHCI Controller #3 (prog-if 00 [UHCI])
	Subsystem: Hewlett-Packard Company Device 330d
	Flags: bus master, medium devsel, latency 0, IRQ 22
	I/O ports at 1040 [size=32]
	Capabilities: [50] PCI Advanced Features
	Kernel driver in use: uhci_hcd

00:1d.3 USB controller: Intel Corporation 82801JI (ICH10 Family) USB UHCI Controller #6 (prog-if 00 [UHCI])
	Subsystem: Hewlett-Packard Company Device 330d
	Flags: bus master, medium devsel, latency 0, IRQ 23
	I/O ports at 1060 [size=32]
	Capabilities: [50] PCI Advanced Features
	Kernel driver in use: uhci_hcd

00:1d.7 USB controller: Intel Corporation 82801JI (ICH10 Family) USB2 EHCI Controller #1 (prog-if 20 [EHCI])
	Subsystem: Hewlett-Packard Company Device 330d
	Flags: bus master, medium devsel, latency 0, IRQ 20
	Memory at e9bf0000 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [50] Power Management version 2
	Capabilities: [58] Debug port: BAR=1 offset=00a0
	Capabilities: [98] PCI Advanced Features
	Kernel driver in use: ehci_hcd

00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev 90) (prog-if 01 [Subtractive decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=32
	I/O behind bridge: 00002000-00002fff
	Memory behind bridge: e9c00000-e9cfffff
	Prefetchable memory behind bridge: 00000000e0000000-00000000e7ffffff
	Capabilities: [50] Subsystem: Hewlett-Packard Company Device 330d

00:1f.0 ISA bridge: Intel Corporation 82801JIB (ICH10) LPC Interface Controller
	Flags: bus master, medium devsel, latency 0
	Capabilities: [e0] Vendor Specific Information: Len=0c <?>

01:03.0 VGA compatible controller: Advanced Micro Devices [AMD] nee ATI ES1000 (rev 02) (prog-if 00 [VGA controller])
	Subsystem: Hewlett-Packard Company Device 31fb
	Flags: bus master, stepping, medium devsel, latency 64, IRQ 23
	Memory at e0000000 (32-bit, prefetchable) [size=128M]
	I/O ports at 2000 [size=256]
	Memory at e9cf0000 (32-bit, non-prefetchable) [size=64K]
	[virtual] Expansion ROM at e9c00000 [disabled] [size=128K]
	Capabilities: [50] Power Management version 2
	Kernel driver in use: radeon

02:00.0 System peripheral: Hewlett-Packard Company Integrated Lights-Out Standard Slave Instrumentation & System Support (rev 04)
	Subsystem: Hewlett-Packard Company Device 3309
	Flags: bus master, fast devsel, latency 0, IRQ 16
	I/O ports at 3000 [size=256]
	Memory at e9ff0000 (32-bit, non-prefetchable) [size=512]
	I/O ports at 3400 [size=256]
	Capabilities: [78] Power Management version 3
	Capabilities: [b0] MSI: Enable- Count=1/1 Maskable- 64bit+
	Capabilities: [c0] Express Legacy Endpoint, MSI 00
	Kernel driver in use: hpwdt

02:00.2 System peripheral: Hewlett-Packard Company Integrated Lights-Out Standard Management Processor Support and Messaging (rev 04)
	Subsystem: Hewlett-Packard Company Device 3309
	Flags: bus master, fast devsel, latency 0, IRQ 17
	I/O ports at 3800 [size=256]
	Memory at e9fe0000 (32-bit, non-prefetchable) [size=256]
	Memory at e9e00000 (32-bit, non-prefetchable) [size=1M]
	Memory at e9d80000 (32-bit, non-prefetchable) [size=512K]
	Memory at e9d70000 (32-bit, non-prefetchable) [size=32K]
	Memory at e9d60000 (32-bit, non-prefetchable) [size=32K]
	[virtual] Expansion ROM at df400000 [disabled] [size=64K]
	Capabilities: [78] Power Management version 3
	Capabilities: [b0] MSI: Enable- Count=1/1 Maskable- 64bit+
	Capabilities: [c0] Express Legacy Endpoint, MSI 00
	Kernel driver in use: hpilo

02:00.4 USB controller: Hewlett-Packard Company Integrated Lights-Out Standard Virtual USB Controller (rev 01) (prog-if 00 [UHCI])
	Subsystem: Hewlett-Packard Company iLO2 GXL/iLO3 GXE
	Flags: bus master, fast devsel, latency 0, IRQ 17
	I/O ports at 3c00 [size=32]
	Capabilities: [70] MSI: Enable- Count=1/1 Maskable- 64bit+
	Capabilities: [80] Express Legacy Endpoint, MSI 00
	Capabilities: [f0] Power Management version 3
	Kernel driver in use: uhci_hcd

03:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
	Subsystem: Hewlett-Packard Company NC382i Integrated Multi-port PCI Express Gigabit Server Adapter
	Flags: bus master, fast devsel, latency 0, IRQ 30
	Memory at ec000000 (64-bit, non-prefetchable) [size=32M]
	[virtual] Expansion ROM at df100000 [disabled] [size=64K]
	Capabilities: [48] Power Management version 3
	Capabilities: [50] Vital Product Data
	Capabilities: [58] MSI: Enable- Count=1/16 Maskable- 64bit+
	Capabilities: [a0] MSI-X: Enable+ Count=9 Masked-
	Capabilities: [ac] Express Endpoint, MSI 00
	Capabilities: [100] Device Serial Number 3c-d9-2b-ff-fe-ef-e0-3c
	Capabilities: [110] Advanced Error Reporting
	Capabilities: [150] Power Budgeting <?>
	Capabilities: [160] Virtual Channel
	Kernel driver in use: bnx2

03:00.1 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
	Subsystem: Hewlett-Packard Company NC382i Integrated Multi-port PCI Express Gigabit Server Adapter
	Flags: bus master, fast devsel, latency 0, IRQ 37
	Memory at ea000000 (64-bit, non-prefetchable) [size=32M]
	[virtual] Expansion ROM at df110000 [disabled] [size=64K]
	Capabilities: [48] Power Management version 3
	Capabilities: [50] Vital Product Data
	Capabilities: [58] MSI: Enable- Count=1/16 Maskable- 64bit+
	Capabilities: [a0] MSI-X: Enable+ Count=9 Masked-
	Capabilities: [ac] Express Endpoint, MSI 00
	Capabilities: [100] Device Serial Number 3c-d9-2b-ff-fe-ef-e0-3e
	Capabilities: [110] Advanced Error Reporting
	Capabilities: [150] Power Budgeting <?>
	Capabilities: [160] Virtual Channel
	Kernel driver in use: bnx2

04:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
	Subsystem: Hewlett-Packard Company NC382i Integrated Multi-port PCI Express Gigabit Server Adapter
	Flags: bus master, fast devsel, latency 0, IRQ 31
	Memory at f0000000 (64-bit, non-prefetchable) [size=32M]
	[virtual] Expansion ROM at df200000 [disabled] [size=64K]
	Capabilities: [48] Power Management version 3
	Capabilities: [50] Vital Product Data
	Capabilities: [58] MSI: Enable- Count=1/16 Maskable- 64bit+
	Capabilities: [a0] MSI-X: Enable+ Count=9 Masked-
	Capabilities: [ac] Express Endpoint, MSI 00
	Capabilities: [100] Device Serial Number 3c-d9-2b-ff-fe-ef-e0-44
	Capabilities: [110] Advanced Error Reporting
	Capabilities: [150] Power Budgeting <?>
	Capabilities: [160] Virtual Channel
	Kernel driver in use: bnx2

04:00.1 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
	Subsystem: Hewlett-Packard Company NC382i Integrated Multi-port PCI Express Gigabit Server Adapter
	Flags: bus master, fast devsel, latency 0, IRQ 39
	Memory at ee000000 (64-bit, non-prefetchable) [size=32M]
	[virtual] Expansion ROM at df210000 [disabled] [size=64K]
	Capabilities: [48] Power Management version 3
	Capabilities: [50] Vital Product Data
	Capabilities: [58] MSI: Enable- Count=1/16 Maskable- 64bit+
	Capabilities: [a0] MSI-X: Enable+ Count=9 Masked-
	Capabilities: [ac] Express Endpoint, MSI 00
	Capabilities: [100] Device Serial Number 3c-d9-2b-ff-fe-ef-e0-46
	Capabilities: [110] Advanced Error Reporting
	Capabilities: [150] Power Budgeting <?>
	Capabilities: [160] Virtual Channel
	Kernel driver in use: bnx2

05:00.0 RAID bus controller: Hewlett-Packard Company Smart Array G6 controllers (rev 01)
	Subsystem: Hewlett-Packard Company Smart Array P410i
	Flags: bus master, fast devsel, latency 0, IRQ 28
	Memory at f3e00000 (64-bit, non-prefetchable) [size=2M]
	Memory at f3df0000 (64-bit, non-prefetchable) [size=4K]
	I/O ports at 4000 [size=256]
	[virtual] Expansion ROM at df000000 [disabled] [size=512K]
	Capabilities: [40] Power Management version 3
	Capabilities: [50] MSI: Enable- Count=1/1 Maskable- 64bit+
	Capabilities: [70] Express Endpoint, MSI 00
	Capabilities: [ac] MSI-X: Enable+ Count=16 Masked-
	Capabilities: [100] Advanced Error Reporting
	Kernel driver in use: hpsa
	Kernel modules: hpsa

06:00.0 Ethernet controller: NetXen Incorporated NX3031 Multifunction 1/10-Gigabit Server Adapter (rev 42)
	Subsystem: Hewlett-Packard Company NC522SFP Dual Port 10GbE Server Adapter
	Flags: bus master, fast devsel, latency 0, IRQ 32
	Memory at fbe00000 (64-bit, non-prefetchable) [size=2M]
	Memory at f8000000 (64-bit, non-prefetchable) [size=32M]
	[virtual] Expansion ROM at df300000 [disabled] [size=64K]
	Capabilities: [40] MSI-X: Enable+ Count=64 Masked-
	Capabilities: [80] Power Management version 3
	Capabilities: [a0] MSI: Enable- Count=1/32 Maskable- 64bit+
	Capabilities: [c0] Express Endpoint, MSI 00
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [140] Device Serial Number 59-69-46-61-6e-48-73-75
	Kernel driver in use: netxen_nic

06:00.1 Ethernet controller: NetXen Incorporated NX3031 Multifunction 1/10-Gigabit Server Adapter (rev 42)
	Subsystem: Hewlett-Packard Company NC522SFP Dual Port 10GbE Server Adapter
	Flags: bus master, fast devsel, latency 0, IRQ 32
	Memory at f7e00000 (64-bit, non-prefetchable) [size=2M]
	Memory at f4000000 (64-bit, non-prefetchable) [size=32M]
	Capabilities: [40] MSI-X: Enable+ Count=64 Masked-
	Capabilities: [80] Power Management version 3
	Capabilities: [a0] MSI: Enable- Count=1/32 Maskable- 64bit+
	Capabilities: [c0] Express Endpoint, MSI 00
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [140] Device Serial Number 59-69-46-61-6e-48-73-75
	Kernel driver in use: netxen_nic

3f:00.0 Host bridge: Intel Corporation Xeon 5600 Series QuickPath Architecture Generic Non-core Registers (rev 02)
	Subsystem: Hewlett-Packard Company Device 330c
	Flags: bus master, fast devsel, latency 0

3f:00.1 Host bridge: Intel Corporation Xeon 5600 Series QuickPath Architecture System Address Decoder (rev 02)
	Subsystem: Hewlett-Packard Company Device 330c
	Flags: bus master, fast devsel, latency 0

3f:02.0 Host bridge: Intel Corporation Xeon 5600 Series QPI Link 0 (rev 02)
	Subsystem: Hewlett-Packard Company Device 330c
	Flags: bus master, fast devsel, latency 0

3f:02.1 Host bridge: Intel Corporation Xeon 5600 Series QPI Physical 0 (rev 02)
	Subsystem: Hewlett-Packard Company Device 330c
	Flags: bus master, fast devsel, latency 0

3f:02.2 Host bridge: Intel Corporation Xeon 5600 Series Mirror Port Link 0 (rev 02)
	Subsystem: Hewlett-Packard Company Device 330c
	Flags: bus master, fast devsel, latency 0

3f:02.3 Host bridge: Intel Corporation Xeon 5600 Series Mirror Port Link 1 (rev 02)
	Subsystem: Hewlett-Packard Company Device 330c
	Flags: bus master, fast devsel, latency 0

3f:02.4 Host bridge: Intel Corporation Xeon 5600 Series QPI Link 1 (rev 02)
	Subsystem: Hewlett-Packard Company Device 330c
	Flags: bus master, fast devsel, latency 0

3f:02.5 Host bridge: Intel Corporation Xeon 5600 Series QPI Physical 1 (rev 02)
	Subsystem: Hewlett-Packard Company Device 330c
	Flags: bus master, fast devsel, latency 0

3f:03.0 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Registers (rev 02)
	Subsystem: Hewlett-Packard Company Device 330c
	Flags: bus master, fast devsel, latency 0

3f:03.1 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Target Address Decoder (rev 02)
	Subsystem: Hewlett-Packard Company Device 330c
	Flags: bus master, fast devsel, latency 0

3f:03.2 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller RAS Registers (rev 02)
	Subsystem: Hewlett-Packard Company Device 330c
	Flags: bus master, fast devsel, latency 0

3f:03.4 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Test Registers (rev 02)
	Subsystem: Hewlett-Packard Company Device 330c
	Flags: bus master, fast devsel, latency 0

3f:04.0 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 0 Control (rev 02)
	Subsystem: Hewlett-Packard Company Device 330c
	Flags: bus master, fast devsel, latency 0

3f:04.1 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 0 Address (rev 02)
	Subsystem: Hewlett-Packard Company Device 330c
	Flags: bus master, fast devsel, latency 0

3f:04.2 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 0 Rank (rev 02)
	Subsystem: Hewlett-Packard Company Device 330c
	Flags: bus master, fast devsel, latency 0

3f:04.3 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 0 Thermal Control (rev 02)
	Subsystem: Hewlett-Packard Company Device 330c
	Flags: bus master, fast devsel, latency 0

3f:05.0 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 1 Control (rev 02)
	Subsystem: Hewlett-Packard Company Device 330c
	Flags: bus master, fast devsel, latency 0

3f:05.1 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 1 Address (rev 02)
	Subsystem: Hewlett-Packard Company Device 330c
	Flags: bus master, fast devsel, latency 0

3f:05.2 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 1 Rank (rev 02)
	Subsystem: Hewlett-Packard Company Device 330c
	Flags: bus master, fast devsel, latency 0

3f:05.3 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 1 Thermal Control (rev 02)
	Subsystem: Hewlett-Packard Company Device 330c
	Flags: bus master, fast devsel, latency 0

3f:06.0 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 2 Control (rev 02)
	Subsystem: Hewlett-Packard Company Device 330c
	Flags: bus master, fast devsel, latency 0

3f:06.1 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 2 Address (rev 02)
	Subsystem: Hewlett-Packard Company Device 330c
	Flags: bus master, fast devsel, latency 0

3f:06.2 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 2 Rank (rev 02)
	Subsystem: Hewlett-Packard Company Device 330c
	Flags: bus master, fast devsel, latency 0

3f:06.3 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 2 Thermal Control (rev 02)
	Subsystem: Hewlett-Packard Company Device 330c
	Flags: bus master, fast devsel, latency 0



--
Peter.
