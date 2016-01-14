From: John <john.phillips5@hpe.com>
Subject: Kernel memory leak in bnx2x driver with vxlan tunnel
Date: Thu, 14 Jan 2016 10:17:39 -0700
Message-ID: <5697D833.5010506@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, david.roth@hpe.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t6225.austin.hp.com ([15.73.96.126]:42251 "EHLO
	g1t6225.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752394AbcANRWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 12:22:44 -0500
Received: from g2t4618.austin.hp.com (g2t4618.austin.hp.com [15.73.212.83])
	(using TLSv1.2 with cipher DHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by g1t6225.austin.hp.com (Postfix) with ESMTPS id C512F3EDA
	for <netdev@vger.kernel.org>; Thu, 14 Jan 2016 17:22:43 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm getting what seems to be a kernel memory leak while doing a TCP
throughput test between two VMs on identical systems, in order to test a
broadcom NIC's performance with a kernel 4.4.0-rc8 and OpenVSwitch version
2.4.90. The host system of the receiving (server) VM leaks memory during the
throughput test. The memory leaks fast enough to make the system completely
unusable within five minutes. Once I stop the throughput test, the 
memory stops
leaking. A couple of times, the kernel on the host system has actually 
killed
the qemu process for me, but this doesn't happen reliably. The leaked memory
doesn't become available again even after the VM is killed.

To investigate this, I compiled a 4.4.0-rc8 kernel with kmemleak. I can 
scan the
leaking system during and after killing the throughput test and get the
following stack trace over and over again:

unreferenced object 0xffff880464f11488 (size 256):
   comm "softirq", pid 0, jiffies 4312675043 (age 379.184s)
   hex dump (first 32 bytes):
     6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
   backtrace:
     [<ffffffff81550e28>] kmemleak_alloc+0x28/0x50
     [<ffffffff811a8bac>] __kmalloc+0x11c/0x2a0
     [<ffffffff8146972e>] metadata_dst_alloc+0x1e/0x40
     [<ffffffff814ed476>] udp_tun_rx_dst+0x126/0x1c0
     [<ffffffff8140be68>] vxlan_udp_encap_recv+0x148/0xb10
     [<ffffffff814cabe9>] udp_queue_rcv_skb+0x1e9/0x480
     [<ffffffff814cb77c>] __udp4_lib_rcv+0x45c/0x700
     [<ffffffff814cbf0a>] udp_rcv+0x1a/0x20
     [<ffffffff8149ae54>] ip_local_deliver_finish+0x94/0x1e0
     [<ffffffff8149b150>] ip_local_deliver+0x60/0xd0
     [<ffffffff8149ab39>] ip_rcv_finish+0x99/0x320
     [<ffffffff8149b41e>] ip_rcv+0x25e/0x380
     [<ffffffff814602db>] __netif_receive_skb_core+0x2cb/0xa00
     [<ffffffff81460a26>] __netif_receive_skb+0x16/0x70
     [<ffffffff81460aa3>] netif_receive_skb_internal+0x23/0x80
     [<ffffffff814615f5>] napi_gro_receive+0xa5/0xd0

I pulled down the kernel tree from
http://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git, and 
did a git
bisect and got this:

58ce31cca1ffe057f4744c3f671e3e84606d3d4a is the first bad commit
commit 58ce31cca1ffe057f4744c3f671e3e84606d3d4a
Author: Tom Herbert <tom@herbertland.com>
Date:   Wed Aug 19 17:07:33 2015 -0700

     vxlan: GRO support at tunnel layer

     Add calls to gro_cells infrastructure to do GRO when receiving on a 
tunnel.

     Testing:

     Ran 200 netperf TCP_STREAM instance

       - With fix (GRO enabled on VXLAN interface)

         Verify GRO is happening.

         9084 MBps tput
         3.44% CPU utilization

       - Without fix (GRO disabled on VXLAN interface)

         Verified no GRO is happening.

         9084 MBps tput
         5.54% CPU utilization

     Signed-off-by: Tom Herbert <tom@herbertland.com>
     Signed-off-by: David S. Miller <davem@davemloft.net>

:040000 040000 a7d49cb2e24ebddf620c01e27515cc756b32e46f 
c3951c16da75ff3e0db1322b8ccb3e61975b1242 M      drivers
:040000 040000 f36442958138eafdd472c58d06ea35be66990aa1 
0e29d513e575dd11f459c59df71e05db074363de M      include

For the test I'm using two HP Proliant dl360gen9's. I put two matching 
broadcom
PCIe cards in each machine and ran throughput tests between two VMs on 
either
machine, using the throughput testing program iperf3. On each host we 
had a qemu
VM attached to an OVS bridge; these bridges are connected over a VxLAN 
tunnel as
detailed here: https://community.mellanox.com/docs/DOC-1446.

The test went well with an Intel Niantic NIC, and I saw high (8.04 Gb/s)
throughput over an eighteen hour throughput test. There was no memory leak.
However, when I put in a Broadcom NIC on both systems I get the above memory
leak, if they have a VM on the receving end of the test. lspci -v output 
for the
Broadcom NIC below:

04:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM57810 
10 Gigabit Ethernet (rev 10)
         Subsystem: Hewlett-Packard Company HP FlexFabric 10Gb 2-port 
534FLR-SFP+ Adapter
         Flags: bus master, fast devsel, latency 0
         Memory at 97000000 (64-bit, prefetchable) [size=8M]
         Memory at 96800000 (64-bit, prefetchable) [size=8M]
         Memory at 98800000 (64-bit, prefetchable) [size=64K]
         [virtual] Expansion ROM at 98880000 [disabled] [size=512K]
         Capabilities: [48] Power Management version 3
         Capabilities: [50] Vital Product Data
         Capabilities: [a0] MSI-X: Enable+ Count=32 Masked-
         Capabilities: [ac] Express Endpoint, MSI 00
         Capabilities: [100] Advanced Error Reporting
         Capabilities: [13c] Device Serial Number 14-58-d0-ff-fe-52-5b-d8
         Capabilities: [150] Power Budgeting <?>
         Capabilities: [160] Virtual Channel
         Capabilities: [1b8] Alternative Routing-ID Interpretation (ARI)
         Capabilities: [1c0] Single Root I/O Virtualization (SR-IOV)
         Capabilities: [220] #15
         Capabilities: [300] #19
         Kernel driver in use: bnx2x

ethtool -i info:
driver: bnx2x
version: 1.712.30-0
firmware-version: bc 7.8.24
bus-info: 0000:04:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: yes

dmesg bnx2x output:
[    1.506071] bnx2x: QLogic 5771x/578xx 10/20-Gigabit Ethernet Driver 
bnx2x 1.712.30-0 (2014/02/10)
[    1.506205] bnx2x 0000:04:00.0: msix capability found
[    1.506297] bnx2x 0000:04:00.0: part number 
394D4342-31383735-31543030-47303030
[    1.555970] bnx2x 0000:04:00.1: msix capability found
[    1.556061] bnx2x 0000:04:00.1: part number 
394D4342-31383735-31543030-47303030
[   10.360477] bnx2x 0000:04:00.1 eth9: renamed from eth3
[   10.584371] bnx2x 0000:04:00.0 rename3: renamed from eth1
[  588.956002] bnx2x 0000:04:00.0 rename3: using MSI-X  IRQs: sp 70 
fp[0] 74 ... fp[7] 81
[  589.208675] bnx2x 0000:04:00.0 rename3: Added vxlan dest port 4789
[  640.159842] bnx2x 0000:04:00.1 eth10: renamed from eth9
[  642.432216] bnx2x 0000:04:00.1 eth10: using MSI-X  IRQs: sp 82 fp[0] 
84 ... fp[7] 91
[  642.700576] bnx2x 0000:04:00.1 eth10: Added vxlan dest port 4789
[ 1098.368845] bnx2x 0000:04:00.1 eth10: using MSI-X  IRQs: sp 82 fp[0] 
84 ... fp[7] 91
[ 1109.277182] bnx2x 0000:04:00.1 eth10_nolink: renamed from eth10
[ 1115.368873] bnx2x 0000:04:00.0 eth10: renamed from rename3
[ 1117.928156] bnx2x 0000:04:00.0 eth10: using MSI-X  IRQs: sp 70 fp[0] 
74 ... fp[7] 81
[ 1118.214861] bnx2x 0000:04:00.0 eth10: NIC Link is Up, 10000 Mbps full 
duplex, Flow control: ON - receive & transmit

I've tried disabling all offloads (gro included) but the leak still 
happens.
