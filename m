From: "Rune Torgersen" <runet@innovsys.com>
Subject: RE: Oops in fs_enet driver with preempt-rt
Date: Tue, 20 May 2008 09:53:14 -0500
Message-ID: <DCEAAC0833DD314AB0B58112AD99B93B046E72C3@ismail.innsys.innovsys.com>
References: <DCEAAC0833DD314AB0B58112AD99B93B046E728C@ismail.innsys.innovsys.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <linux-kernel@vger.kernel.org>, <linuxppc-dev@ozlabs.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.innovsys.com ([66.115.232.196]:40400 "EHLO
	mail.innovsys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756892AbYETOyP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 10:54:15 -0400
Content-class: urn:content-classes:message
In-Reply-To: <DCEAAC0833DD314AB0B58112AD99B93B046E728C@ismail.innsys.innovsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rune Torgersen wrote:
> Hi
> I am trying to get preempt-rt (v2.6.25.4-rt1) to work on a Freescale
> 8280 CPU (arch/powerpc) 
> 
> I get the follwing oops when trying to enable ethernet:
> (looks like a null pointer dereference in
> drivers/net/fs_enet/fs_enet-main.c:106)

And if I disable NAPI I get this one instead:

Bringing up the eth1 interface...Unable to handle kernel paging request
for data at address 0x00000000
Faulting instruction address: 0xc019706c
Oops: Kernel access of bad area, sig: 11 [#1]
PREEMPT Innovative Systems ApMax
Modules linked in:
NIP: c019706c LR: c0196d84 CTR: c0198790
REGS: ef2c3cb0 TRAP: 0300   Not tainted  (2.6.25.4-rt1)
MSR: 00009032 <EE,ME,IR,DR>  CR: 42004222  XER: 00000000
DAR: 00000000, DSISR: 20000000
TASK = ef2ac590[114] 'ifconfig' THREAD: ef2c2000
GPR00: 00000000 ef2c3d60 ef2ac590 ef37f000 00000008 00000000 ef2c3d5c
0000008c
GPR08: ef2c3d38 00000008 ef2c3d40 00000001 22000222 10021454 00000000
100a37b0
GPR16: 10090000 ef3e71e0 ef3e71e0 00000000 10070000 00000008 100192c0
00008914
GPR24: ef37f000 ef37f5a0 00000000 c0196d34 00000000 ef37f5a0 fffffff4
ef2973a0
NIP [c019706c] fs_enet_interrupt+0x338/0x5f4
LR [c0196d84] fs_enet_interrupt+0x50/0x5f4
Call Trace:
[ef2c3d60] [c024a270] __spin_unlock_irqrestore+0x20/0x4c (unreliable)
[ef2c3db0] [c0049a04] request_irq+0xb8/0xfc
[ef2c3de0] [c0198044] fs_enet_open+0x8c/0x210
[ef2c3e00] [c01d9b4c] dev_open+0x80/0xe8
[ef2c3e10] [c01d89ac] dev_change_flags+0xc8/0x19c
[ef2c3e30] [c021bfb0] devinet_ioctl+0x284/0x6f0
[ef2c3e90] [c021c8fc] inet_ioctl+0xc0/0xf4
[ef2c3ea0] [c01cbec4] sock_ioctl+0x200/0x23c
[ef2c3ec0] [c00810c0] vfs_ioctl+0x44/0xa8
[ef2c3ee0] [c0081520] do_vfs_ioctl+0x3fc/0x440
[ef2c3f10] [c00815a4] sys_ioctl+0x40/0x70
[ef2c3f40] [c000fcf0] ret_from_syscall+0x0/0x38
--- Exception: c01 at 0xff6a37c
    LR = 0xffecd58
Instruction dump:
7c0004ac b01c0000 72e02000 3b9c0008 41820008 839d00bc 813d00a0 7f03c378
81290034 7d2903a6 4e800421 7c0004ac <a01c0000> 0c000000 4c00012c
5417043e
---[ end trace 61ff5e5c97ddf707 ]---

Seems to be caused by line 471 in fs_enet_main:

0xc0196d84 is in fs_enet_interrupt
(drivers/net/fs_enet/fs_enet-main.c:473).
468                     if (fpi->use_napi)
469                             int_clr_events &= ~fep->ev_napi_rx;
470
471                     (*fep->ops->clear_int_events)(dev,
int_clr_events);
472
473                     if (int_events & fep->ev_err)
474                             (*fep->ops->ev_error)(dev, int_events);
475
476                     if (int_events & fep->ev_rx) {
477                             if (!fpi->use_napi)
(gdb)     
