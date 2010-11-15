From: "Catalin(ux) M. BOIE" <catab@embedromix.ro>
Subject: bnx2 drops bigger packets (GRO related) between 2.6.34.7 and
 2.6.35.6
Date: Mon, 15 Nov 2010 10:56:29 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1011151029080.5987@mail.embedromix.ro>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: davem@davemloft.net, mchan@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.embedromix.ro ([80.96.69.110]:50484 "EHLO
	mail.embedromix.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754550Ab0KOJur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 04:50:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

OS: Fedora 14
Kernel: 2.6.35.6-48.fc14.x86_64 -> not working
Kernel 2.6.34.7-61.fc13.x86_64 -> working
Router doing LVS, 2 bnx2 cards:
bnx2: Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v2.0.15 (May 4, 2010)
Nov 12 13:40:14 nld-gate2 kernel: [   10.932944] bnx2 0000:03:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
Nov 12 13:40:14 nld-gate2 kernel: [   11.385796] bnx2 0000:03:00.0: eth0: Broadcom NetXtreme II BCM5708 1000Base-T (B2) PCI-X 64-bit 133MHz found at mem f8000000, IRQ 18, node addr 00:1b:78:02:50:f4
Nov 12 13:40:14 nld-gate2 kernel: [   11.385837] bnx2 0000:05:00.0: PCI INT A -> GSI 19 (level, low) -> IRQ 19
Nov 12 13:40:14 nld-gate2 kernel: [   11.720153] bnx2 0000:05:00.0: eth1: Broadcom NetXtreme II BCM5708 1000Base-T (B2) PCI-X 64-bit 133MHz found at mem fa000000, IRQ 19, node addr 00:1b:78:02:e0:62
Nov 12 13:40:14 nld-gate2 kernel: [   17.266011] bnx2 0000:03:00.0: eth0: using MSI
Nov 12 13:40:14 nld-gate2 kernel: [   19.507112] bnx2 0000:05:00.0: eth1: using MSI
Nov 12 13:40:14 nld-gate2 kernel: [   20.466635] bnx2 0000:03:00.0: eth0: NIC Copper Link is Up, 1000 Mbps full duplex
Nov 12 13:40:14 nld-gate2 kernel: [   22.759590] bnx2 0000:05:00.0: eth1: NIC Copper Link is Up, 1000 Mbps full duplex

If I disable GRO, everything is OK.

What I observed is that big packets (3 * 1460) are received on eth0, 
passed to eth1 and probably droped because they do not arrive at 
destination.

A dump (one way):

09:04:54.364906 IP (tos 0x0, ttl 63, id 0, offset 0, flags [DF], proto TCP (6), length 52)
     B.B.B.B.http > A.A.A.A.49265: Flags [S.], cksum 0x4ef2 (correct), seq 2561113748, ack 2289616327, win 5840, options [mss 1460,nop,nop,sackOK,nop,wscale 5], length 0
09:04:54.401265 IP (tos 0x0, ttl 63, id 11216, offset 0, flags [DF], proto TCP (6), length 40)
     B.B.B.B.http > A.A.A.A.49265: Flags [.], cksum 0xa445 (correct), seq 1, ack 374, win 216, length 0
09:04:54.506141 IP (tos 0x0, ttl 63, id 11217, offset 0, flags [DF], proto TCP (6), length 4420)

=== Here is a big packet:

     B.B.B.B.http > A.A.A.A.49265: Flags [.], cksum 0xb7ed (incorrect -> 0x7e77), seq 1:4381, ack 374, win 216, length 4380
09:04:57.515501 IP (tos 0x0, ttl 63, id 11220, offset 0, flags [DF], proto TCP (6), length 1500)

=== Here is retransmitted with 1460 bytes instead of 4380, after 3 seconds:

     B.B.B.B.http > A.A.A.A.49265: Flags [.], cksum 0xc841 (correct), seq 1:1461, ack 374, win 216, length 1460
09:04:57.578489 IP (tos 0x0, ttl 63, id 0, offset 0, flags [DF], proto TCP (6), length 52)
     B.B.B.B.http > A.A.A.A.49266: Flags [S.], cksum 0x8c70 (correct), seq 2597744105, ack 3136906307, win 5840, options [mss 1460,nop,nop,sackOK,nop,wscale 5], length 0
09:04:57.615500 IP (tos 0x0, ttl 63, id 3129, offset 0, flags [DF], proto TCP (6), length 40)
     B.B.B.B.http > A.A.A.A.49266: Flags [.], cksum 0xe178 (correct), seq 1, ack 449, win 216, length 0
09:04:57.630306 IP (tos 0x0, ttl 63, id 3130, offset 0, flags [DF], proto TCP (6), length 2780)
     B.B.B.B.http > A.A.A.A.49266: Flags [P.], cksum 0xb185 (incorrect -> 0x8cf0), seq 1:2741, ack 449, win 216, length 2740
09:04:57.750804 IP (tos 0x0, ttl 63, id 11221, offset 0, flags [DF], proto TCP (6), length 2960)
     B.B.B.B.http > A.A.A.A.49265: Flags [.], cksum 0xb239 (incorrect -> 0x7426), seq 4381:7301, ack 374, win 216, length 2920
09:05:00.635704 IP (tos 0x0, ttl 63, id 3132, offset 0, flags [DF], proto TCP (6), length 1500)
     B.B.B.B.http > A.A.A.A.49266: Flags [.], cksum 0x43b9 (correct), seq 1:1461, ack 449, win 216, length 1460

Let me know if you need more info.

Thank you.

--
Catalin(ux) M. BOIE
http://kernel.embedromix.ro/
