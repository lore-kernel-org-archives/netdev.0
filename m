From: Ben Greear <greearb@candelatech.com>
Subject: Reproducible VLAN/e1000e crash in 2.6.36 vanilla.
Date: Mon, 25 Oct 2010 10:57:51 -0700
Message-ID: <4CC5C51F.3000606@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:48616 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753052Ab0JYR5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 13:57:52 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id o9PHvpIF026967
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 10:57:51 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


To re-create, setup 2 802.1q vlans on different physical interfaces on the same system,
set up routing rules such that send-to-self works, and pass traffic (UDP/IPv4 in this case,
but doesn't seem to matter).
Stop traffic, then attempt to create additional 802.1q vlans on the same physical interfaces.
The crash only appears to happen after having sent traffic on the interface.

Likely it will also crash if one system is sending to another, but so far we've
just tested sending-to-self.

This appears very reproducible for us, and appears to be the same problem that
I had reported against our hacked kernel here:

http://www.spinics.net/lists/netdev/msg144748.html


[root@ct503-60 ~]# general protection fault: 0000 [#1] PREEMPT SMP
last sysfs file: /sys/devices/virtual/net/eth2.103/type
CPU 2
Modules linked in: 8021q garp bridge stp llc veth arc4 michael_mic macvlan pktgen fuse nfs lockd fscach]

Pid: 0, comm: kworker/0:1 Not tainted 2.6.36 #32 X8DTU/X8DTU
RIP: 0010:[<ffffffff813cada1>]  [<ffffffff813cada1>] vlan_hwaccel_do_receive+0x64/0xca
RSP: 0018:ffff880001a43c10  EFLAGS: 00010287
RAX: 0000000000000002 RBX: ffff88031d1b0200 RCX: ffff88032d600000
RDX: ffff880001a43c00 RSI: ffff88031d1b0200 RDI: 0000000000000001
RBP: ffff880001a43c30 R08: 0000000000000067 R09: ffff8803217268c0
R10: ffff88031d1b0228 R11: 00000000000005f2 R12: ffff88032d600000
R13: ffff10032f040890 R14: 0000000000000000 R15: ffff880330b6ae00
FS:  0000000000000000(0000) GS:ffff880001a40000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000001d07be8 CR3: 0000000001642000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process kworker/0:1 (pid: 0, threadinfo ffff8803321f0000, task ffff88033209f700)
Stack:
  ffff880001a43c30 ffff88031d1b0200 ffff88032d600908 ffff88031d1b0208
<0> ffff880001a43c90 ffffffff81344313 ffff88031d1b0200 ffff88032d600908
<0> ffff880001a43c70 ffffffff81061d07 000000004cc5bf73 ffff88031d1b0200
Call Trace:
  <IRQ>
  [<ffffffff81344313>] __netif_receive_skb+0x36/0x3b3
  [<ffffffff81061d07>] ? ktime_get_real+0x11/0x3e
  [<ffffffff813454a5>] netif_receive_skb+0x67/0x6e
  [<ffffffff81345b8c>] napi_skb_finish+0x24/0x3b
  [<ffffffff813cb07f>] vlan_gro_receive+0x7b/0x80
  [<ffffffffa016d5b9>] e1000_receive_skb+0x51/0x6d [e1000e]
  [<ffffffffa016eeb0>] e1000_clean_rx_irq+0x1ed/0x292 [e1000e]
  [<ffffffffa016f287>] e1000_clean+0x75/0x221 [e1000e]
  [<ffffffff81345690>] net_rx_action+0xad/0x19c
  [<ffffffff81048926>] __do_softirq+0xa8/0x135
  [<ffffffff8100a99c>] call_softirq+0x1c/0x30
  [<ffffffff8100c085>] do_softirq+0x41/0x7e
  [<ffffffff81048ab8>] irq_exit+0x36/0x85
  [<ffffffff8100b7bf>] do_IRQ+0xad/0xc4
  [<ffffffff813ed4d3>] ret_from_intr+0x0/0x11
  <EOI>
  [<ffffffff8120dab2>] ? intel_idle+0xe6/0x112
  [<ffffffff8120da95>] ? intel_idle+0xc9/0x112
  [<ffffffff8131d121>] cpuidle_idle_call+0xab/0xe6
  [<ffffffff81008dd5>] cpu_idle+0x59/0xb5
  [<ffffffff813e6da8>] start_secondary+0x1a9/0x1ae
Code: 0d 0f b7 c0 41 8b 44 85 04 66 c7 83 bc 00 00 00 00 00 89 43 78 4d 8b ad d8 00 00 00 e8 c1 95 e0 f




-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

