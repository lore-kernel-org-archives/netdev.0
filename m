From: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Subject: lockdep problem? netlink_dump & rtnl_lock
Date: Wed, 18 Nov 2015 11:11:36 +0100
Message-ID: <201511181111.36160.a.miskiewicz@gmail.com>
Reply-To: arekm@maven.pl
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35353 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752182AbbKRKLj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 05:11:39 -0500
Received: by wmeo63 with SMTP id o63so11635397wme.2
        for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 02:11:37 -0800 (PST)
Received: from xps.localnet ([91.234.176.242])
        by smtp.gmail.com with ESMTPSA id 143sm436799wmv.18.2015.11.18.02.11.37
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Nov 2015 02:11:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi.

I'm running 4.3.0 kernel (+ few backported mm patches). Machine is doin=
g many rsnapshots
in parallel (so heavily loaded).

I'm seeing this from time to time (below). What would be the reason for=
 so long hangs?

[ 2278.385668] INFO: task snmpd:1775 blocked for more than 120 seconds.
[ 2278.392089]       Not tainted 4.3.0-0.1 #1
[ 2278.396226] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disab=
les this message.
[ 2278.404111] snmpd           D ffff88081fc158c0     0  1775      1 0x=
00000000
[ 2278.411229]  ffff8807e6a8bcf8 0000000000000082 ffffffff81c13500 ffff=
8807ebb88d80
[ 2278.418753]  ffff8807e6a8c000 ffff8807ebb88d80 ffffffff81cc7c84 0000=
0000ffffffff
[ 2278.426286]  ffffffff81cc7c88 ffff8807e6a8bd10 ffffffff8161c203 ffff=
ffff81cc7c80
[ 2278.433854] Call Trace:
[ 2278.436341]  [<ffffffff8161c203>] schedule+0x33/0x80
[ 2278.441349]  [<ffffffff8161c49e>] schedule_preempt_disabled+0xe/0x10
[ 2278.447733]  [<ffffffff8161d833>] __mutex_lock_slowpath+0xb3/0x120
[ 2278.453956]  [<ffffffff8161d8bf>] mutex_lock+0x1f/0x30
[ 2278.459133]  [<ffffffff81523f15>] rtnl_lock+0x15/0x20
[ 2278.464212]  [<ffffffff8158b902>] devinet_ioctl+0xd2/0x6e0
[ 2278.469757]  [<ffffffff81208c14>] ? mntput+0x24/0x40
[ 2278.474769]  [<ffffffff811ebe62>] ? __fput+0x142/0x200
[ 2278.479955]  [<ffffffff8158d5a0>] inet_ioctl+0x50/0x70
[ 2278.485122]  [<ffffffff814f6e05>] sock_do_ioctl+0x25/0x50
[ 2278.490578]  [<ffffffff814f7322>] sock_ioctl+0x1d2/0x290
[ 2278.495920]  [<ffffffff811fc3f5>] do_vfs_ioctl+0x295/0x470
[ 2278.501444]  [<ffffffff814f6cd6>] ? sock_alloc_file+0xa6/0x130
[ 2278.507338]  [<ffffffff81090eb4>] ? task_work_add+0x44/0x60
[ 2278.512942]  [<ffffffff811ebff7>] ? fput+0x47/0x90
[ 2278.517771]  [<ffffffff811fc649>] SyS_ioctl+0x79/0x90
[ 2278.522845]  [<ffffffff8161f876>] entry_SYSCALL_64_fastpath+0x16/0x7=
5
[ 2278.529341] INFO: task sudo:4534 blocked for more than 120 seconds.
[ 2278.535635]       Not tainted 4.3.0-0.1 #1
[ 2278.539759] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disab=
les this message.
[ 2278.547680] sudo            D 0000000000000000     0  4534      1 0x=
00000004
[ 2278.554825]  ffff880080677bb8 0000000000000086 ffff8807f3874380 ffff=
8807f3eb8000
[ 2278.562389]  ffff880080678000 ffff8807f3eb8000 ffffffff81cc7c84 0000=
0000ffffffff
[ 2278.569914]  ffffffff81cc7c88 ffff880080677bd0 ffffffff8161c203 ffff=
ffff81cc7c80
[ 2278.577436] Call Trace:
[ 2278.579911]  [<ffffffff8161c203>] schedule+0x33/0x80
[ 2278.584918]  [<ffffffff8161c49e>] schedule_preempt_disabled+0xe/0x10
[ 2278.591329]  [<ffffffff8161d833>] __mutex_lock_slowpath+0xb3/0x120
[ 2278.597571]  [<ffffffff8161d8bf>] mutex_lock+0x1f/0x30
[ 2278.602743]  [<ffffffff8154746e>] __netlink_dump_start+0x5e/0x190
[ 2278.608890]  [<ffffffff81526100>] ? rtnl_fill_ifinfo+0x13f0/0x13f0
[ 2278.615105]  [<ffffffff81526eac>] rtnetlink_rcv_msg+0x1bc/0x230
[ 2278.621054]  [<ffffffff81526100>] ? rtnl_fill_ifinfo+0x13f0/0x13f0
[ 2278.627262]  [<ffffffff81526cf0>] ? rtnetlink_rcv+0x30/0x30
[ 2278.632861]  [<ffffffff815498d4>] netlink_rcv_skb+0xa4/0xc0
[ 2278.638463]  [<ffffffff81526ce8>] rtnetlink_rcv+0x28/0x30
[ 2278.643908]  [<ffffffff81548fc7>] netlink_unicast+0x127/0x1a0
[ 2278.649692]  [<ffffffff81549604>] netlink_sendmsg+0x4f4/0x5f0
[ 2278.655480]  [<ffffffff814f8bd8>] sock_sendmsg+0x38/0x50
[ 2278.660830]  [<ffffffff814fa2a1>] SyS_sendto+0x101/0x150
[ 2278.666189]  [<ffffffff814f6cd6>] ? sock_alloc_file+0xa6/0x130
[ 2278.672064]  [<ffffffff81206715>] ? fd_install+0x25/0x30
[ 2278.677407]  [<ffffffff814f985f>] ? SyS_socket+0x9f/0xf0
[ 2278.682749]  [<ffffffff8161f876>] entry_SYSCALL_64_fastpath+0x16/0x7=
5








 [ 7433.492510] INFO: task bird:1503 blocked for more than 120 seconds.
[ 7433.498819]       Not tainted 4.3.0-0.1 #1
[ 7433.502954] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disab=
les this message.
[ 7433.510840] bird            D ffff88081fd158c0     0  1503      1 0x=
00000000
[ 7433.517966]  ffff8807eb923bb8 0000000000000086 ffff8807fb711b00 ffff=
8807f38a4380
[ 7433.525493]  ffff8807eb924000 ffff8807f38a4380 ffffffff81cc7c84 0000=
0000ffffffff
[ 7433.533017]  ffffffff81cc7c88 ffff8807eb923bd0 ffffffff8161c203 ffff=
ffff81cc7c80
[ 7433.540561] Call Trace:
[ 7433.543050]  [<ffffffff8161c203>] schedule+0x33/0x80
[ 7433.548041]  [<ffffffff8161c49e>] schedule_preempt_disabled+0xe/0x10
[ 7433.554415]  [<ffffffff8161d833>] __mutex_lock_slowpath+0xb3/0x120
[ 7433.560624]  [<ffffffff8161d8bf>] mutex_lock+0x1f/0x30
[ 7433.565810]  [<ffffffff81546be1>] netlink_dump+0x21/0x2c0
[ 7433.571236]  [<ffffffff815470c9>] netlink_recvmsg+0x249/0x3d0
[ 7433.577005]  [<ffffffff814f8eeb>] sock_recvmsg+0x3b/0x50
[ 7433.582347]  [<ffffffff814f96ab>] ___sys_recvmsg+0xdb/0x1f0
[ 7433.587952]  [<ffffffff810146ec>] ? __switch_to+0x25c/0x4a0
[ 7433.593579]  [<ffffffff810a6f17>] ? update_curr+0xb7/0x130
[ 7433.599115]  [<ffffffff810a354c>] ? __enqueue_entity+0x6c/0x70
[ 7433.604970]  [<ffffffff810a44f1>] ? set_next_entity+0x71/0x840
[ 7433.610832]  [<ffffffff810146ec>] ? __switch_to+0x25c/0x4a0
[ 7433.616431]  [<ffffffff814fa9b1>] __sys_recvmsg+0x51/0x90
[ 7433.621873]  [<ffffffff814faa02>] SyS_recvmsg+0x12/0x20
[ 7433.627125]  [<ffffffff8161f876>] entry_SYSCALL_64_fastpath+0x16/0x7=
5
[ 7433.633642] INFO: task kworker/3:4:12895 blocked for more than 120 s=
econds.
[ 7433.640651]       Not tainted 4.3.0-0.1 #1
[ 7433.644797] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disab=
les this message.
[ 7433.652682] kworker/3:4     D 0000000000000000     0 12895      2 0x=
00000000
[ 7433.659794] Workqueue: ipv6_addrconf addrconf_verify_work
[ 7433.665240]  ffff8803b0073d58 0000000000000046 ffff880781adb600 ffff=
880736aa3600
[ 7433.672763]  ffff8803b0074000 ffff880736aa3600 ffffffff81cc7c84 0000=
0000ffffffff
[ 7433.680287]  ffffffff81cc7c88 ffff8803b0073d70 ffffffff8161c203 ffff=
ffff81cc7c80
[ 7433.687811] Call Trace:
[ 7433.690288]  [<ffffffff8161c203>] schedule+0x33/0x80
[ 7433.695297]  [<ffffffff8161c49e>] schedule_preempt_disabled+0xe/0x10
[ 7433.701688]  [<ffffffff8161d833>] __mutex_lock_slowpath+0xb3/0x120
[ 7433.707923]  [<ffffffff8161d8bf>] mutex_lock+0x1f/0x30
[ 7433.713093]  [<ffffffff81523f15>] rtnl_lock+0x15/0x20
[ 7433.718168]  [<ffffffff815c903e>] addrconf_verify_work+0xe/0x20
[ 7433.724114]  [<ffffffff8108cc6f>] process_one_work+0x14f/0x430
[ 7433.730006]  [<ffffffff8108cf9b>] worker_thread+0x4b/0x4b0
[ 7433.735517]  [<ffffffff8161bb71>] ? __schedule+0x2a1/0x900
[ 7433.741031]  [<ffffffff8108cf50>] ? process_one_work+0x430/0x430
[ 7433.747083]  [<ffffffff8108cf50>] ? process_one_work+0x430/0x430
[ 7433.753131]  [<ffffffff81092be8>] kthread+0xd8/0xf0
[ 7433.758063]  [<ffffffff81092b10>] ? kthread_worker_fn+0x170/0x170
[ 7433.764204]  [<ffffffff8161fc0f>] ret_from_fork+0x3f/0x70
[ 7433.769657]  [<ffffffff81092b10>] ? kthread_worker_fn+0x170/0x170

config:
http://sprunge.us/BBLN

# ethtool -i eth0
driver: igb
version: 5.3.0-k
firmware-version: 3.16, 0x800004d7
bus-info: 0000:05:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: no

# lspci -v
00:00.0 Host bridge: Intel Corporation Xeon E3-1200 v3 Processor DRAM C=
ontroller (rev 06)
        Subsystem: Super Micro Computer Inc Device 0804
        Flags: bus master, fast devsel, latency 0
        Capabilities: [e0] Vendor Specific Information: Len=3D0c <?>
        Kernel driver in use: ie31200_edac
        Kernel modules: ie31200_edac

00:01.0 PCI bridge: Intel Corporation Xeon E3-1200 v3/4th Gen Core Proc=
essor PCI Express x16 Controller (rev 06) (prog-if 00 [Normal decode])
        Flags: bus master, fast devsel, latency 0
        Bus: primary=3D00, secondary=3D01, subordinate=3D01, sec-latenc=
y=3D0
        Capabilities: [88] Subsystem: Super Micro Computer Inc Device 0=
804
        Capabilities: [80] Power Management version 3
        Capabilities: [90] MSI: Enable+ Count=3D1/1 Maskable- 64bit-
        Capabilities: [a0] Express Root Port (Slot+), MSI 00
        Capabilities: [100] Virtual Channel
        Capabilities: [140] Root Complex Link
        Capabilities: [d94] #19
        Kernel driver in use: pcieport
        Kernel modules: shpchp

00:01.1 PCI bridge: Intel Corporation Xeon E3-1200 v3/4th Gen Core Proc=
essor PCI Express x8 Controller (rev 06) (prog-if 00 [Normal decode])
        Flags: bus master, fast devsel, latency 0
        Bus: primary=3D00, secondary=3D02, subordinate=3D02, sec-latenc=
y=3D0
        I/O behind bridge: 0000e000-0000efff
        Memory behind bridge: f7100000-f72fffff
        Capabilities: [88] Subsystem: Super Micro Computer Inc Device 0=
804
        Capabilities: [80] Power Management version 3
        Capabilities: [90] MSI: Enable+ Count=3D1/1 Maskable- 64bit-
        Capabilities: [a0] Express Root Port (Slot+), MSI 00
        Capabilities: [100] Virtual Channel
        Capabilities: [140] Root Complex Link
        Capabilities: [d94] #19
        Kernel driver in use: pcieport
        Kernel modules: shpchp

00:14.0 USB controller: Intel Corporation 8 Series/C220 Series Chipset =
=46amily USB xHCI (rev 05) (prog-if 30 [XHCI])
        Subsystem: Super Micro Computer Inc Device 0804
        Flags: bus master, medium devsel, latency 0, IRQ 34
        Memory at f7500000 (64-bit, non-prefetchable) [size=3D64K]
        Capabilities: [70] Power Management version 2
        Capabilities: [80] MSI: Enable+ Count=3D1/8 Maskable- 64bit+
        Kernel driver in use: xhci_hcd
        Kernel modules: xhci_pci

00:1a.0 USB controller: Intel Corporation 8 Series/C220 Series Chipset =
=46amily USB EHCI #2 (rev 05) (prog-if 20 [EHCI])
        Subsystem: Super Micro Computer Inc Device 0804
        Flags: bus master, medium devsel, latency 0, IRQ 16
        Memory at f7513000 (32-bit, non-prefetchable) [size=3D1K]
        Capabilities: [50] Power Management version 2
        Capabilities: [58] Debug port: BAR=3D1 offset=3D00a0
        Capabilities: [98] PCI Advanced Features
        Kernel driver in use: ehci-pci
        Kernel modules: ehci_pci

00:1c.0 PCI bridge: Intel Corporation 8 Series/C220 Series Chipset Fami=
ly PCI Express Root Port #1 (rev d5) (prog-if 00 [Normal decode])
        Flags: bus master, fast devsel, latency 0
        Bus: primary=3D00, secondary=3D03, subordinate=3D04, sec-latenc=
y=3D0
        I/O behind bridge: 0000d000-0000dfff
        Memory behind bridge: f6000000-f70fffff
        Capabilities: [40] Express Root Port (Slot+), MSI 00
        Capabilities: [80] MSI: Enable+ Count=3D1/1 Maskable- 64bit-
        Capabilities: [90] Subsystem: Super Micro Computer Inc Device 0=
804
        Capabilities: [a0] Power Management version 3
        Kernel driver in use: pcieport
        Kernel modules: shpchp

00:1c.2 PCI bridge: Intel Corporation 8 Series/C220 Series Chipset Fami=
ly PCI Express Root Port #3 (rev d5) (prog-if 00 [Normal decode])
        Flags: bus master, fast devsel, latency 0
        Bus: primary=3D00, secondary=3D05, subordinate=3D05, sec-latenc=
y=3D0
        I/O behind bridge: 0000c000-0000cfff
        Memory behind bridge: f7400000-f74fffff
        Capabilities: [40] Express Root Port (Slot+), MSI 00
        Capabilities: [80] MSI: Enable+ Count=3D1/1 Maskable- 64bit-
        Capabilities: [90] Subsystem: Super Micro Computer Inc Device 0=
804
        Capabilities: [a0] Power Management version 3
        Kernel driver in use: pcieport
        Kernel modules: shpchp

00:1c.3 PCI bridge: Intel Corporation 8 Series/C220 Series Chipset Fami=
ly PCI Express Root Port #4 (rev d5) (prog-if 00 [Normal decode])
        Flags: bus master, fast devsel, latency 0
        Bus: primary=3D00, secondary=3D06, subordinate=3D06, sec-latenc=
y=3D0
        I/O behind bridge: 0000b000-0000bfff
        Memory behind bridge: f7300000-f73fffff
        Capabilities: [40] Express Root Port (Slot+), MSI 00
        Capabilities: [80] MSI: Enable+ Count=3D1/1 Maskable- 64bit-
        Capabilities: [90] Subsystem: Super Micro Computer Inc Device 0=
804
        Capabilities: [a0] Power Management version 3
        Kernel driver in use: pcieport
        Kernel modules: shpchp

00:1d.0 USB controller: Intel Corporation 8 Series/C220 Series Chipset =
=46amily USB EHCI #1 (rev 05) (prog-if 20 [EHCI])
        Subsystem: Super Micro Computer Inc Device 0804
        Flags: bus master, medium devsel, latency 0, IRQ 23
        Memory at f7512000 (32-bit, non-prefetchable) [size=3D1K]
        Capabilities: [50] Power Management version 2
        Capabilities: [58] Debug port: BAR=3D1 offset=3D00a0
        Capabilities: [98] PCI Advanced Features
        Kernel driver in use: ehci-pci
        Kernel modules: ehci_pci

00:1f.0 ISA bridge: Intel Corporation C222 Series Chipset Family Server=
 Essential SKU LPC Controller (rev 05)
        Subsystem: Super Micro Computer Inc Device 0804
        Flags: bus master, medium devsel, latency 0
        Capabilities: [e0] Vendor Specific Information: Len=3D0c <?>
        Kernel driver in use: lpc_ich
        Kernel modules: lpc_ich

00:1f.2 SATA controller: Intel Corporation 8 Series/C220 Series Chipset=
 Family 6-port SATA Controller 1 [AHCI mode] (rev 05) (prog-if 01 [AHCI=
 1.0])
        Subsystem: Super Micro Computer Inc Device 0804
        Flags: bus master, 66MHz, medium devsel, latency 0, IRQ 29
        I/O ports at f050 [size=3D8]
        I/O ports at f040 [size=3D4]
        I/O ports at f030 [size=3D8]
        I/O ports at f020 [size=3D4]
        I/O ports at f000 [size=3D32]
        Memory at f7511000 (32-bit, non-prefetchable) [size=3D2K]
        Capabilities: [80] MSI: Enable+ Count=3D1/1 Maskable- 64bit-
        Capabilities: [70] Power Management version 3
        Capabilities: [a8] SATA HBA v1.0
        Kernel driver in use: ahci
        Kernel modules: ahci

00:1f.3 SMBus: Intel Corporation 8 Series/C220 Series Chipset Family SM=
Bus Controller (rev 05)
        Subsystem: Super Micro Computer Inc Device 0804
        Flags: medium devsel, IRQ 18
        Memory at f7510000 (64-bit, non-prefetchable) [size=3D256]
        I/O ports at 0580 [size=3D32]
        Kernel driver in use: i801_smbus
        Kernel modules: i2c_i801

00:1f.6 Signal processing controller: Intel Corporation 8 Series Chipse=
t Family Thermal Management Controller (rev 05)
        Subsystem: Super Micro Computer Inc Device 0804
        Flags: bus master, fast devsel, latency 0, IRQ 10
        Memory at dfff00000 (64-bit, non-prefetchable) [size=3D4K]
        Capabilities: [50] Power Management version 3
        Capabilities: [80] MSI: Enable- Count=3D1/1 Maskable- 64bit-

02:00.0 Serial Attached SCSI controller: LSI Logic / Symbios Logic SAS2=
308 PCI-Express Fusion-MPT SAS-2 (rev 05)
        Subsystem: Super Micro Computer Inc Device 0691
        Flags: bus master, fast devsel, latency 0
        I/O ports at e000 [size=3D256]
        Memory at f7240000 (64-bit, non-prefetchable) [size=3D64K]
        Memory at f7200000 (64-bit, non-prefetchable) [size=3D256K]
        Expansion ROM at f7100000 [disabled] [size=3D1M]
        Capabilities: [50] Power Management version 3
        Capabilities: [68] Express Endpoint, MSI 00
        Capabilities: [d0] Vital Product Data
        Capabilities: [a8] MSI: Enable- Count=3D1/1 Maskable- 64bit+
        Capabilities: [c0] MSI-X: Enable+ Count=3D16 Masked-
        Capabilities: [100] Advanced Error Reporting
        Capabilities: [1e0] #19
        Capabilities: [1c0] Power Budgeting <?>
        Capabilities: [190] #16
        Capabilities: [148] Alternative Routing-ID Interpretation (ARI)
        Kernel driver in use: mpt2sas
        Kernel modules: mpt2sas

03:00.0 PCI bridge: ASPEED Technology, Inc. AST1150 PCI-to-PCI Bridge (=
rev 03) (prog-if 00 [Normal decode])
        Flags: bus master, fast devsel, latency 0
        Bus: primary=3D03, secondary=3D04, subordinate=3D04, sec-latenc=
y=3D0
        I/O behind bridge: 0000d000-0000dfff
        Memory behind bridge: f6000000-f70fffff
        Capabilities: [50] MSI: Enable- Count=3D1/1 Maskable- 64bit+
        Capabilities: [78] Power Management version 3
        Capabilities: [80] Express PCI-Express to PCI/PCI-X Bridge, MSI=
 00
        Capabilities: [a4] Subsystem: Super Micro Computer Inc Device 0=
804
        Capabilities: [100] Virtual Channel
        Kernel modules: shpchp

04:00.0 VGA compatible controller: ASPEED Technology, Inc. ASPEED Graph=
ics Family (rev 30) (prog-if 00 [VGA controller])
        Subsystem: Super Micro Computer Inc Device 0804
        Flags: bus master, medium devsel, latency 0, IRQ 11
        Memory at f6000000 (32-bit, non-prefetchable) [size=3D16M]
        Memory at f7000000 (32-bit, non-prefetchable) [size=3D128K]
        I/O ports at d000 [size=3D128]
        Expansion ROM at <unassigned> [disabled]
        Capabilities: [40] Power Management version 3
        Capabilities: [50] MSI: Enable- Count=3D1/4 Maskable- 64bit+

05:00.0 Ethernet controller: Intel Corporation I210 Gigabit Network Con=
nection (rev 03)
        Subsystem: Super Micro Computer Inc Device 1533
        Flags: bus master, fast devsel, latency 0
        Memory at f7400000 (32-bit, non-prefetchable) [size=3D512K]
        I/O ports at c000 [size=3D32]
        Memory at f7480000 (32-bit, non-prefetchable) [size=3D16K]
        Capabilities: [40] Power Management version 3
        Capabilities: [50] MSI: Enable- Count=3D1/1 Maskable+ 64bit+
        Capabilities: [70] MSI-X: Enable+ Count=3D5 Masked-
        Capabilities: [a0] Express Endpoint, MSI 00
        Capabilities: [100] Advanced Error Reporting
        Capabilities: [140] Device Serial Number 00-25-90-ff-ff-87-5d-0=
e
        Capabilities: [1a0] Transaction Processing Hints
        Kernel driver in use: igb
        Kernel modules: igb

06:00.0 Ethernet controller: Intel Corporation I210 Gigabit Network Con=
nection (rev 03)
        Subsystem: Super Micro Computer Inc Device 1533
        Flags: bus master, fast devsel, latency 0
        Memory at f7300000 (32-bit, non-prefetchable) [size=3D512K]
        I/O ports at b000 [size=3D32]
        Memory at f7380000 (32-bit, non-prefetchable) [size=3D16K]
        Capabilities: [40] Power Management version 3
        Capabilities: [50] MSI: Enable- Count=3D1/1 Maskable+ 64bit+
        Capabilities: [70] MSI-X: Enable+ Count=3D5 Masked-
        Capabilities: [a0] Express Endpoint, MSI 00
        Capabilities: [100] Advanced Error Reporting
        Capabilities: [140] Device Serial Number 00-25-90-ff-ff-87-5d-0=
f
        Capabilities: [1a0] Transaction Processing Hints
        Kernel driver in use: igb
        Kernel modules: igb


--=20
Arkadiusz Mi=C5=9Bkiewicz, arekm / ( maven.pl | pld-linux.org )
