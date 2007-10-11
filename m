From: TAKANO Ryousei <takano@axe-inc.co.jp>
Subject: Regression in net-2.6.24?
Date: Thu, 11 Oct 2007 22:51:46 +0900 (JST)
Message-ID: <20071011.225146.94718703.takano@axe-inc.co.jp>
References: <119193240269-git-send-email-ilpo.jarvinen@helsinki.fi>
	<20071011.105526.17823985.takano@axe-inc.co.jp>
	<Pine.LNX.4.64.0710111300280.23026@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, ilpo.jarvinen@helsinki.fi,
	shemminger@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from axekw.axe-inc.co.jp ([61.199.217.67]:50261 "EHLO
	axekw.axe-inc.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753454AbXJKNv5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 09:51:57 -0400
In-Reply-To: <Pine.LNX.4.64.0710111300280.23026@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC PATCH] [TCP]: Fix lost_retrans loop vs fastpath probl=
ems
Date: Thu, 11 Oct 2007 13:12:49 +0300 (EEST)

> > But, I got=20
> > a kernel panic at net_rx_action() in our experimental setting.
> > I am using the net-2.6.24 kernel _without_ this patch.=20
> > (I will post a bug report separately).
>=20
> ...Please do. :-)
>=20
I have got a kernel panic, when I run the Iperf benchmark in the follow=
ing
setting. Each node has x86_64 dual processors and 2 tg3 NICs (BCM95704A=
6).
If the router does not regulate the bandwidth, a kernel panic does not =
occur.

Node A ----> Router -------> Delay -------> Node B
            (Policing rate:  emulator
   	     500Mbps)        (RTT: 20ms)


Ggit-bisect told me that the following commit causes a regression:

commit bea3348eef27e6044b6161fd04c3152215f96411
Author: Stephen Hemminger <shemminger@linux-foundation.org>
Date:   Wed Oct 3 16:41:36 2007 -0700

    [NET]: Make NAPI polling independent of struct net_device objects.


Here is Oops message:

Unable to handle kernel paging request at 0000000000100108 RIP:=20
 [<ffffffff80421d59>] net_rx_action+0x169/0x1c0
PGD f384d067 PUD 0=20
Oops: 0002 [1] SMP=20
CPU 0=20
Modules linked in: 8021q tcp_bic netconsole evdev joydev sg st sr_mod o=
hci_hcd i2c_amd756 i2c_amd8111 i2c_core ipv6 tg3 usbhid usbcore ff_meml=
ess dm_mod ext3 jbd sata_sil libata sd_mod scsi_mod
Pid: 0, comm: swapper Not tainted 2.6.23-rc9 #2
RIP: 0010:[<ffffffff80421d59>]  [<ffffffff80421d59>] net_rx_action+0x16=
9/0x1c0
RSP: 0018:ffffffff80847eb0  EFLAGS: 00010046
RAX: 0000000000200200 RBX: ffff8100f63ef750 RCX: 0000000000000246
RDX: 0000000000100100 RSI: ffffc20002e60204 RDI: ffff8100f63ef6c0
RBP: ffffffff80847ef0 R08: ffff810178b72fd8 R09: 0000000000000001
R10: 0000000000000003 R11: 0000000000000000 R12: 0000000000000040
R13: 0000000000000040 R14: ffff810003f51640 R15: 0000000000000000
=46S:  0000000040331960(0000) GS:ffffffff805d7000(0000) knlGS:000000000=
0000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 0000000000100108 CR3: 00000000f45b6000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffffffff806de000, task ffffffff8058=
b540)
Stack:  ffffffff80847eb0 000000ec80847eb0 00000001000b17ec 000000000000=
0009
 ffffffff805e10b0 ffffffff8083eee0 0000000000000000 0000000000000009
 ffffffff80847f30 ffffffff8023d935 0000000000000000 0000000000000046
Call Trace:
 <IRQ>  [<ffffffff8023d935>] __do_softirq+0x75/0x100
 [<ffffffff8020cb8c>] call_softirq+0x1c/0x30
 [<ffffffff8020dd89>] do_softirq+0x49/0xb0
 [<ffffffff8023d4e5>] irq_exit+0x45/0x50
 [<ffffffff8020e053>] do_IRQ+0x83/0x100
 [<ffffffff8020a310>] default_idle+0x0/0x50
 [<ffffffff8020bf11>] ret_from_intr+0x0/0xb
 <EOI>  [<ffffffff8020a33d>] default_idle+0x2d/0x50
 [<ffffffff8020aa72>] enter_idle+0x22/0x30
 [<ffffffff8020ab0c>] cpu_idle+0x8c/0xd0
 [<ffffffff804af6ec>] rest_init+0x5c/0x70
 [<ffffffff806e8baf>] start_kernel+0x28f/0x300
 [<ffffffff806e8140>] _sinittext+0x140/0x180


Code: 48 89 42 08 48 89 10 49 8b 46 08 4c 89 33 49 89 5e 08 48 89=20
RIP  [<ffffffff80421d59>] net_rx_action+0x169/0x1c0
 RSP <ffffffff80847eb0>
CR2: 0000000000100108
Kernel panic - not syncing: Aiee, killing interrupt handler!


RIP points at __list_del (net_rx_action -> list_move_tail -> __list_del=
).

$ objdump -S net/core/dev.o | less
	  <snip>
static inline void __list_del(struct list_head * prev, struct list_head=
 * next)
{
     b42:       48 8b 43 08             mov    0x8(%rbx),%rax
     b46:       48 8b 13                mov    (%rbx),%rdx
        next->prev =3D prev;
     b49:       48 89 42 08             mov    %rax,0x8(%rdx)  <=3D=3D=3D=
=3D
        prev->next =3D next;
     b4d:       48 89 10                mov    %rdx,(%rax)
     b50:       49 8b 46 08             mov    0x8(%r14),%rax
     b54:       4c 89 33                mov    %r14,(%rbx)
     b57:       49 89 5e 08             mov    %rbx,0x8(%r14)
     b5b:       48 89 18                mov    %rbx,(%rax)


What is happen and what information do you need to fix it?

Thanks in advance,
Ryousei Takano
