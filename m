From: Stephen Hemminger <shemminger@osdl.org>
Subject: Fw: [Bug 6421] New: kernel 2.6.10-2.6.16 on alpha:
 arch/alpha/kernel/io.c, iowrite16_rep() BUG_ON((unsigned long)src & 0x1)
 triggered
Date: Fri, 21 Apr 2006 10:27:57 -0700
Message-ID: <20060421102757.45d26db0@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:58593 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932133AbWDUR2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 13:28:02 -0400
To: Paul Gortmaker <p_gortmaker@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Looks like PIO at unaligned addresses doesn't work on alpha...

Begin forwarded message:

Date: Fri, 21 Apr 2006 02:35:45 -0700
=46rom: bugme-daemon@bugzilla.kernel.org
To: shemminger@osdl.org
Subject: [Bug 6421] New: kernel 2.6.10-2.6.16 on alpha: arch/alpha/kern=
el/io.c, iowrite16_rep() BUG_ON((unsigned long)src & 0x1) triggered


http://bugzilla.kernel.org/show_bug.cgi?id=3D6421

           Summary: kernel 2.6.10-2.6.16 on alpha: arch/alpha/kernel/io=
=2Ec,
                    iowrite16_rep() BUG_ON((unsigned long)src & 0x1)
                    triggered
    Kernel Version: 2.6.16
            Status: NEW
          Severity: blocking
             Owner: shemminger@osdl.org
         Submitter: tomri@gmx.net


Most recent kernel where this bug did not occur: 2.6.10 (i think so)


Distribution: self build (RH9, FC4/5 on alpha mix)=20
Hardware Environment: alpha sx164pc board with ne200 ISA card.
Software Environment:
Problem Description:

Since 2.6.10 the BUG_ON() in arch/alpha/kernel/io.c iowrite16_rep()=20
is triggered randomly, but reproducable on linux alpha platform with
ne2000/8390 ISA network card.

ne.c:v1.10 9/23/94 Donald Becker (becker@scyld.com)
Last modified Nov 1, 2000 by Paul Gortmaker
NE*000 ethercard probe at 0x320: 00 80 29 63 4a f6
eth%d: NE2000 found at 0x320, using IRQ 5.

I=C2=B4ve traced this back to drivers/net/8390.c:
 ei_start_xmit().
I add a workaround, because else the system won't be usable any more in
ei_start_xmit() like this:
  if ( (unsigned long) skb->data & 0x1)
        {
                printk(KERN_WARNING "ei_start_xmit(): skb->data unalign=
ed %p
align to %p length %i\n", skb->data, scratch, send_length);
                if ( send_length >=3D 128 ) goto normal;
                memset( scratch, 0, 128);
                memcpy( scratch, skb->data, send_length < 128 ? send_le=
ngth : 128);
                ei_block_output(dev, send_length, scratch, output_page)=
;
        }
        else
        {
normal:
            ei_block_output(dev, send_length, skb->data, output_page);
        }
And the output in the kernel ring buffer is:
dmesg | grep xmit
ei_start_xmit(): skb->data unaligned fffffc0019be55d5 align to fffffc00=
1ef37620
length 60
ei_start_xmit(): skb->data unaligned fffffc0019be55d5 align to fffffc00=
1ef37620
length 60
ei_start_xmit(): skb->data unaligned fffffc0008ceb735 align to fffffc00=
019dbb18
length 60
ei_start_xmit(): skb->data unaligned fffffc000ea787c5 align to fffffc00=
1f683540
length 60
ei_start_xmit(): skb->data unaligned fffffc000e864fe9 align to fffffc00=
0b737350
length 60
ei_start_xmit(): skb->data unaligned fffffc0008cd883f align to fffffc00=
0b737350
length 60

So why is the skb->data address unaligned over time the system is runni=
ng?

Steps to reproduce:
Every time. I think with higher system load the BUG is triggered earlie=
r.

Here some stack traces with BUG_ON/ WARN_ON added by me in more places =
to trace
down the problem:
Kernel bug at net/ipv4/ip_output.c:297
cc1(2841): Kernel Bug 1
pc =3D [<fffffc000062a92c>]  ra =3D [<fffffc00006407c8>]  ps =3D 0000  =
  Not tainted
pc is at ip_queue_xmit+0x59c/0x690
ra is at tcp_transmit_skb+0x588/0xbb0
v0 =3D fffffffffffffbc4  t0 =3D 000000000cfa4195  t1 =3D fffffc0000785d=
18
t2 =3D fffffc00014e26e0  t3 =3D 0000003000000000  t4 =3D 00000030000000=
00
t5 =3D fffffc000cfa41a9  t6 =3D 0000000200000000  t7 =3D fffffc00062d80=
00
a0 =3D fffffc001c14ef40  a1 =3D 0000000000000000  a2 =3D 00000000140000=
00
a3 =3D 0000000000000600  a4 =3D 0000000000000000  a5 =3D 00000000000000=
00
t8 =3D 0000000000000000  t9 =3D fffffc000cfa41a9  t10=3D 00000000000000=
01
t11=3D 0000000000000200  pv =3D fffffc000062a390  at =3D 00000000000000=
00
gp =3D fffffc00007f1600  sp =3D fffffc00062db6e0
Trace:
[<fffffc00006407c8>] tcp_transmit_skb+0x588/0xbb0
[<fffffc00006469ac>] tcp_v4_send_check+0x11c/0x150
[<fffffc00006406cc>] tcp_transmit_skb+0x48c/0xbb0
[<fffffc0000641c48>] tcp_retransmit_skb+0x128/0x7d0
[<fffffc00006436ec>] tcp_xmit_retransmit_queue+0x1bc/0x3c0
[<fffffc00005f5618>] sk_reset_timer+0x28/0x60
[<fffffc000063b8a0>] tcp_ack+0x16e0/0x1e80
[<fffffc000063ec58>] tcp_rcv_state_process+0x6c8/0x13f0
[<fffffc0000649078>] tcp_v4_do_rcv+0x128/0x480
[<fffffc000064a068>] tcp_v4_rcv+0xc98/0xcb0
[<fffffc000062556c>] ip_local_deliver+0x1ac/0x400
[<fffffc0000625110>] ip_rcv+0x480/0x730
[<fffffc0000601794>] netif_receive_skb+0x174/0x300
[<fffffc00006019ec>] process_backlog+0xcc/0x1b0
[<fffffc0000600394>] net_rx_action+0xb4/0x1a0
[<fffffc0000330cb0>] __do_softirq+0x90/0x130
[<fffffc00003162e8>] handle_IRQ_event+0x48/0x110
[<fffffc0000330db4>] do_softirq+0x64/0x70
[<fffffc0000316c14>] handle_irq+0x124/0x1b0
[<fffffc000031ff28>] isa_device_interrupt+0x28/0x40
[<fffffc000031fe38>] pyxis_device_interrupt+0x68/0x130
[<fffffc0000317328>] do_entInt+0x118/0x190
[<fffffc00003112d0>] ret_from_sys_call+0x0/0x10
[<fffffc0000393b90>] __link_path_walk+0x900/0x10a0
[<fffffc00004ff080>] memcmp+0x0/0x70
[<fffffc0000393b90>] __link_path_walk+0x900/0x10a0
[<fffffc00003943c0>] link_path_walk+0x90/0x1b0
[<fffffc00004ff080>] memcmp+0x0/0x70
[<fffffc0000393b90>] __link_path_walk+0x900/0x10a0
[<fffffc00003943c0>] link_path_walk+0x90/0x1b0
[<fffffc00003956d8>] __path_lookup_intent_open+0x78/0xe0
[<fffffc000037aa48>] do_sys_open+0x58/0xe0
[<fffffc0000395b50>] open_namei+0xa0/0x9e0
[<fffffc000037a990>] filp_open+0x30/0x90
[<fffffc000037aa64>] do_sys_open+0x74/0xe0
[<fffffc000037aa48>] do_sys_open+0x58/0xe0
[<fffffc00003112b4>] entSys+0xa4/0xc0

Code: e43fff8c  203ff7ff  44610001  b02b00c8  c3ffff88  00000081 <00000=
129> 006
Debug: sleeping function called from invalid context at
include/linux/rwsem.h:43in_atomic():1, irqs_di
sabled():0
fffffc00062db488 0000000000000001 fffffc000032b4c4 fffffc0000751600
       0000000000000000 0000000000000001 fffffc000032dc60 fffffc00062db=
5f8
       0000000000000000 0000000000000005 fffffc000031258c fffffc00062db=
5f8
       0000000000000000 fffffc00062db5f8 0000000000000000 0000000000000=
000
       0000000000000014 0000000000000000 0000000000000000 fffffc00062db=
5f8
       0000000000000000 0000000000000000 fffffc0000312668 0000000000000=
001
Trace:
[<fffffc000032b4c4>] profile_task_exit+0x34/0xd0
[<fffffc000032dc60>] do_exit+0x40/0xeb0
[<fffffc000031258c>] die_if_kernel+0xdc/0xe0
[<fffffc0000312668>] do_entIF+0x58/0x350
[<fffffc00003112d0>] ret_from_sys_call+0x0/0x10
[<fffffc0000600394>] net_rx_action+0xb4/0x1a0
[<fffffc00003362d8>] run_timer_softirq+0x128/0x250
[<fffffc0000330cb0>] __do_softirq+0x90/0x130
[<fffffc0000310f0c>] entMM+0x9c/0xc0
[<fffffc00006407c8>] tcp_transmit_skb+0x588/0xbb0
[<fffffc000062a390>] ip_queue_xmit+0x0/0x690
[<fffffc000062a92c>] ip_queue_xmit+0x59c/0x690
[<fffffc00006407c8>] tcp_transmit_skb+0x588/0xbb0
[<fffffc00006469ac>] tcp_v4_send_check+0x11c/0x150
[<fffffc00006406cc>] tcp_transmit_skb+0x48c/0xbb0
[<fffffc0000641c48>] tcp_retransmit_skb+0x128/0x7d0
[<fffffc00006436ec>] tcp_xmit_retransmit_queue+0x1bc/0x3c0
[<fffffc00005f5618>] sk_reset_timer+0x28/0x60
[<fffffc000063b8a0>] tcp_ack+0x16e0/0x1e80
[<fffffc000063ec58>] tcp_rcv_state_process+0x6c8/0x13f0
[<fffffc0000649078>] tcp_v4_do_rcv+0x128/0x480
[<fffffc000064a068>] tcp_v4_rcv+0xc98/0xcb0
[<fffffc00006406cc>] tcp_transmit_skb+0x48c/0xbb0
[<fffffc0000641c48>] tcp_retransmit_skb+0x128/0x7d0
[<fffffc00006436ec>] tcp_xmit_retransmit_queue+0x1bc/0x3c0
[<fffffc00005f5618>] sk_reset_timer+0x28/0x60
[<fffffc000063b8a0>] tcp_ack+0x16e0/0x1e80
[<fffffc000063ec58>] tcp_rcv_state_process+0x6c8/0x13f0
[<fffffc0000649078>] tcp_v4_do_rcv+0x128/0x480
[<fffffc000064a068>] tcp_v4_rcv+0xc98/0xcb0
[<fffffc000062556c>] ip_local_deliver+0x1ac/0x400
[<fffffc0000625110>] ip_rcv+0x480/0x730
[<fffffc0000601794>] netif_receive_skb+0x174/0x300
[<fffffc00006019ec>] process_backlog+0xcc/0x1b0
[<fffffc0000600394>] net_rx_action+0xb4/0x1a0
[<fffffc0000330cb0>] __do_softirq+0x90/0x130
[<fffffc00003162e8>] handle_IRQ_event+0x48/0x110
[<fffffc0000330db4>] do_softirq+0x64/0x70
[<fffffc0000316c14>] handle_irq+0x124/0x1b0
[<fffffc000031ff28>] isa_device_interrupt+0x28/0x40
[<fffffc000031fe38>] pyxis_device_interrupt+0x68/0x130
[<fffffc0000317328>] do_entInt+0x118/0x190
[<fffffc00003112d0>] ret_from_sys_call+0x0/0x10
[<fffffc0000393b90>] __link_path_walk+0x900/0x10a0
[<fffffc00004ff080>] memcmp+0x0/0x70
[<fffffc0000393b90>] __link_path_walk+0x900/0x10a0
[<fffffc00003943c0>] link_path_walk+0x90/0x1b0
[<fffffc00003956d8>] __path_lookup_intent_open+0x78/0xe0
[<fffffc000037aa48>] do_sys_open+0x58/0xe0
[<fffffc0000395b50>] open_namei+0xa0/0x9e0
[<fffffc000037a990>] filp_open+0x30/0x90
[<fffffc000037aa64>] do_sys_open+0x74/0xe0
[<fffffc000037aa48>] do_sys_open+0x58/0xe0
[<fffffc00003112b4>] entSys+0xa4/0xc0

fffffc00062db4c8 0000000000000005 fffffc000031258c fffffc00062db5f8
       0000000000000000 fffffc00062db5f8 0000000000000000 0000000000000=
000
       0000000000000014 0000000000000000 0000000000000000 fffffc00062db=
5f8
       0000000000000000 0000000000000000 fffffc0000312668 0000000000000=
001
       0000000000000001 0000000000000000 fffffc00003112d0 fffffc001c14e=
f40
       fffffc00127f6460 fffffc00127f6460 fffffc00062db600 fffffc0000600=
394
Trace:
[<fffffc000031258c>] die_if_kernel+0xdc/0xe0
[<fffffc0000312668>] do_entIF+0x58/0x350
[<fffffc00003112d0>] ret_from_sys_call+0x0/0x10
[<fffffc0000600394>] net_rx_action+0xb4/0x1a0
[<fffffc00003362d8>] run_timer_softirq+0x128/0x250
[<fffffc0000330cb0>] __do_softirq+0x90/0x130
[<fffffc0000310f0c>] entMM+0x9c/0xc0
[<fffffc00006407c8>] tcp_transmit_skb+0x588/0xbb0
[<fffffc000062a390>] ip_queue_xmit+0x0/0x690
[<fffffc000062a92c>] ip_queue_xmit+0x59c/0x690
[<fffffc00006407c8>] tcp_transmit_skb+0x588/0xbb0
[<fffffc00006469ac>] tcp_v4_send_check+0x11c/0x150
[<fffffc00006406cc>] tcp_transmit_skb+0x48c/0xbb0
[<fffffc0000641c48>] tcp_retransmit_skb+0x128/0x7d0
[<fffffc00006436ec>] tcp_xmit_retransmit_queue+0x1bc/0x3c0
[<fffffc00005f5618>] sk_reset_timer+0x28/0x60
[<fffffc000063b8a0>] tcp_ack+0x16e0/0x1e80
[<fffffc000063ec58>] tcp_rcv_state_process+0x6c8/0x13f0
[<fffffc0000649078>] tcp_v4_do_rcv+0x128/0x480
[<fffffc000064a068>] tcp_v4_rcv+0xc98/0xcb0
[<fffffc000062556c>] ip_local_deliver+0x1ac/0x400
[<fffffc0000625110>] ip_rcv+0x480/0x730
[<fffffc0000601794>] netif_receive_skb+0x174/0x300
[<fffffc00006019ec>] process_backlog+0xcc/0x1b0
[<fffffc0000600394>] net_rx_action+0xb4/0x1a0
[<fffffc0000330cb0>] __do_softirq+0x90/0x130
[<fffffc00003162e8>] handle_IRQ_event+0x48/0x110
[<fffffc0000330db4>] do_softirq+0x64/0x70
[<fffffc0000316c14>] handle_irq+0x124/0x1b0
[<fffffc000031ff28>] isa_device_interrupt+0x28/0x40
[<fffffc000031fe38>] pyxis_device_interrupt+0x68/0x130
[<fffffc0000317328>] do_entInt+0x118/0x190
[<fffffc00003112d0>] ret_from_sys_call+0x0/0x10
[<fffffc0000393b90>] __link_path_walk+0x900/0x10a0
[<fffffc00004ff080>] memcmp+0x0/0x70
[<fffffc0000393b90>] __link_path_walk+0x900/0x10a0
[<fffffc00003943c0>] link_path_walk+0x90/0x1b0
[<fffffc00003956d8>] __path_lookup_intent_open+0x78/0xe0
[<fffffc000037aa48>] do_sys_open+0x58/0xe0
[<fffffc0000395b50>] open_namei+0xa0/0x9e0
[<fffffc000037a990>] filp_open+0x30/0x90
[<fffffc000037aa64>] do_sys_open+0x74/0xe0
[<fffffc000037aa48>] do_sys_open+0x58/0xe0
[<fffffc00003112b4>] entSys+0xa4/0xc0

Kernel panic - not syncing: Aiee, killing interrupt handler!
 fffffc00062db438 fffffc0016924620 fffffc000032e818 fffffc00062db5f8
       0000000000000000 0000000000000001 fffffc00062db4a8 0000000000000=
008
       fffffc00062db588 0000000000007049 ffffffffffffffff fffffc00062db=
438
       fffffc0000000008 0000000000000001 fffffc000032e800 0000000000007=
049
       ffffffffffffffff fffffc00062db438 fffffc0000000008 0000000000000=
001
       fffffc000031258c fffffc00062db5f8 0000000000000000 fffffc00062db=
5f8
Trace:
[<fffffc000032e818>] do_exit+0xbf8/0xeb0
[<fffffc000032e800>] do_exit+0xbe0/0xeb0
[<fffffc000031258c>] die_if_kernel+0xdc/0xe0
[<fffffc0000312668>] do_entIF+0x58/0x350
[<fffffc00003112d0>] ret_from_sys_call+0x0/0x10
[<fffffc0000600394>] net_rx_action+0xb4/0x1a0
[<fffffc00003362d8>] run_timer_softirq+0x128/0x250
[<fffffc0000330cb0>] __do_softirq+0x90/0x130
[<fffffc0000310f0c>] entMM+0x9c/0xc0
[<fffffc00006407c8>] tcp_transmit_skb+0x588/0xbb0
[<fffffc000062a390>] ip_queue_xmit+0x0/0x690
[<fffffc000062a92c>] ip_queue_xmit+0x59c/0x690
[<fffffc00006407c8>] tcp_transmit_skb+0x588/0xbb0
[<fffffc00006469ac>] tcp_v4_send_check+0x11c/0x150
[<fffffc00006406cc>] tcp_transmit_skb+0x48c/0xbb0
[<fffffc0000641c48>] tcp_retransmit_skb+0x128/0x7d0
[<fffffc00006436ec>] tcp_xmit_retransmit_queue+0x1bc/0x3c0
[<fffffc00005f5618>] sk_reset_timer+0x28/0x60
[<fffffc000063b8a0>] tcp_ack+0x16e0/0x1e80
[<fffffc000063ec58>] tcp_rcv_state_process+0x6c8/0x13f0
[<fffffc0000649078>] tcp_v4_do_rcv+0x128/0x480
[<fffffc000064a068>] tcp_v4_rcv+0xc98/0xcb0
[<fffffc000062556c>] ip_local_deliver+0x1ac/0x400
[<fffffc0000625110>] ip_rcv+0x480/0x730
[<fffffc0000601794>] netif_receive_skb+0x174/0x300
[<fffffc00006019ec>] process_backlog+0xcc/0x1b0
[<fffffc0000600394>] net_rx_action+0xb4/0x1a0
[<fffffc0000330cb0>] __do_softirq+0x90/0x130
[<fffffc00003162e8>] handle_IRQ_event+0x48/0x110
[<fffffc0000330db4>] do_softirq+0x64/0x70
[<fffffc0000316c14>] handle_irq+0x124/0x1b0
[<fffffc000031ff28>] isa_device_interrupt+0x28/0x40
[<fffffc000031fe38>] pyxis_device_interrupt+0x68/0x130
[<fffffc0000317328>] do_entInt+0x118/0x190
[<fffffc00003112d0>] ret_from_sys_call+0x0/0x10
[<fffffc0000393b90>] __link_path_walk+0x900/0x10a0
[<fffffc00004ff080>] memcmp+0x0/0x70
[<fffffc0000393b90>] __link_path_walk+0x900/0x10a0
[<fffffc00003943c0>] link_path_walk+0x90/0x1b0
[<fffffc00003956d8>] __path_lookup_intent_open+0x78/0xe0
[<fffffc000037aa48>] do_sys_open+0x58/0xe0
[<fffffc0000395b50>] open_namei+0xa0/0x9e0
[<fffffc000037a990>] filp_open+0x30/0x90
[<fffffc000037aa64>] do_sys_open+0x74/0xe0
[<fffffc000037aa48>] do_sys_open+0x58/0xe0
[<fffffc00003112b4>] entSys+0xa4/0xc0

Welcome! This system runs Red Hat Linux release 9 (Shrike) (ttyS1)

merlin login: kjournald starting.  Commit interval 5 seconds
EXT3-fs warning: maximal mount count reached, running e2fsck is recomme=
nded
EXT3 FS on loop5, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
Kernel bug at net/ipv4/tcp_output.c:277
cc1(28797): Kernel Bug 1
pc =3D [<fffffc0000640c74>]  ra =3D [<fffffc0000641cd8>]  ps =3D 0000  =
  Not tainted
pc is at tcp_transmit_skb+0x9e4/0xbf0
ra is at tcp_retransmit_skb+0x128/0x7d0
v0 =3D 0000000000000000  t0 =3D 0000000015198b6f  t1 =3D 00000000000000=
01
t2 =3D ffffffffffffffbf  t3 =3D 0000000000004308  t4 =3D fffffc00148b11=
c0
t5 =3D 0000000000000001  t6 =3D 0000000000000000  t7 =3D fffffc00097940=
00
a0 =3D fffffc00148b1120  a1 =3D fffffc0001a6f820  a2 =3D 00000000000000=
01
a3 =3D 0000000000000020  a4 =3D fffffc0009797bd8  a5 =3D 00000000000000=
00
t8 =3D fffffc00148b11c0  t9 =3D 0000000000000000  t10=3D 00000000000018=
00
t11=3D 00000000000005b4  pv =3D fffffc000065aba0  at =3D 00000000000000=
01
gp =3D fffffc00007f1600  sp =3D fffffc0009797ac8
Trace:
[<fffffc0000641cd8>] tcp_retransmit_skb+0x128/0x7d0
[<fffffc000064379c>] tcp_xmit_retransmit_queue+0x1dc/0x400
[<fffffc00005f5618>] sk_reset_timer+0x28/0x60
[<fffffc000063b414>] tcp_ack+0x1204/0x1e80
[<fffffc000063eca8>] tcp_rcv_state_process+0x6c8/0x13f0
[<fffffc0000649148>] tcp_v4_do_rcv+0x128/0x480
[<fffffc000064a138>] tcp_v4_rcv+0xc98/0xcb0
[<fffffc00006255bc>] ip_local_deliver+0x1ac/0x400
[<fffffc0000625160>] ip_rcv+0x480/0x730
[<fffffc00006017a4>] netif_receive_skb+0x184/0x330
[<fffffc0000601a24>] process_backlog+0xd4/0x1d0
[<fffffc0000600394>] net_rx_action+0xb4/0x1a0
[<fffffc0000330cb0>] __do_softirq+0x90/0x130
[<fffffc0000330db4>] do_softirq+0x64/0x70
[<fffffc0000316c14>] handle_irq+0x124/0x1b0
[<fffffc000031ff28>] isa_device_interrupt+0x28/0x40
[<fffffc000031fe38>] pyxis_device_interrupt+0x68/0x130
[<fffffc0000317328>] do_entInt+0x118/0x190
[<fffffc00003112d0>] ret_from_sys_call+0x0/0x10

Code: 44430481  43e10003  c3ffffaa  4821f623  c3ffffc1  00000081 <00000=
115> 006
Debug: sleeping function called from invalid context at
include/linux/rwsem.h:43in_atomic():1, irqs_di
sabled():0
fffffc0009797870 0000000000000001 fffffc000032b4c4 fffffc0000751600
       fffffc00148b11c0 0000000000000001 fffffc000032dc60 fffffc0009797=
9e0
       0000000000000000 0000000000000005 fffffc000031258c fffffc0009797=
9e0
       0000000000000000 fffffc00097979e0 0000000000000020 fffffc0001a6f=
878
       0000000000000019 fffffc00148b11c0 0000000000000000 fffffc0009797=
9e0
       0000000000000020 fffffc00148b11c0 fffffc0000312668 0000000000000=
001
Trace:
[<fffffc000032b4c4>] profile_task_exit+0x34/0xd0
[<fffffc000032dc60>] do_exit+0x40/0xeb0
[<fffffc000031258c>] die_if_kernel+0xdc/0xe0
[<fffffc0000312668>] do_entIF+0x58/0x350
[<fffffc00003112d0>] ret_from_sys_call+0x0/0x10
[<fffffc0000641cd8>] tcp_retransmit_skb+0x128/0x7d0
[<fffffc000065aba0>] inet_sk_rebuild_header+0x0/0x5f0
[<fffffc0000640c74>] tcp_transmit_skb+0x9e4/0xbf0
[<fffffc0000641cd8>] tcp_retransmit_skb+0x128/0x7d0
[<fffffc000064379c>] tcp_xmit_retransmit_queue+0x1dc/0x400
[<fffffc00005f5618>] sk_reset_timer+0x28/0x60
[<fffffc000063b414>] tcp_ack+0x1204/0x1e80
[<fffffc000063eca8>] tcp_rcv_state_process+0x6c8/0x13f0
[<fffffc0000649148>] tcp_v4_do_rcv+0x128/0x480
[<fffffc000064a138>] tcp_v4_rcv+0xc98/0xcb0
[<fffffc00006255bc>] ip_local_deliver+0x1ac/0x400
[<fffffc0000625160>] ip_rcv+0x480/0x730
[<fffffc00006017a4>] netif_receive_skb+0x184/0x330
[<fffffc0000601a24>] process_backlog+0xd4/0x1d0
[<fffffc0000600394>] net_rx_action+0xb4/0x1a0
[<fffffc0000330cb0>] __do_softirq+0x90/0x130
[<fffffc0000330db4>] do_softirq+0x64/0x70
[<fffffc0000316c14>] handle_irq+0x124/0x1b0
[<fffffc000031ff28>] isa_device_interrupt+0x28/0x40
[<fffffc000031fe38>] pyxis_device_interrupt+0x68/0x130
[<fffffc0000317328>] do_entInt+0x118/0x190
[<fffffc00003112d0>] ret_from_sys_call+0x0/0x10

fffffc00097978b0 0000000000000005 fffffc000031258c fffffc00097979e0
       0000000000000000 fffffc00097979e0 0000000000000020 fffffc0001a6f=
878
       0000000000000019 fffffc00148b11c0 0000000000000000 fffffc0009797=
9e0
       0000000000000020 fffffc00148b11c0 fffffc0000312668 0000000000000=
001
       0000000000000001 0000000000000000 fffffc00003112d0 0000000000000=
001
       fffffc00148b1120 fffffc0001a6f820 fffffc00146db9e0 0000000000044=
854
Trace:
Trace:
[<fffffc000031258c>] die_if_kernel+0xdc/0xe0
[<fffffc0000312668>] do_entIF+0x58/0x350
[<fffffc00003112d0>] ret_from_sys_call+0x0/0x10
[<fffffc0000641cd8>] tcp_retransmit_skb+0x128/0x7d0
[<fffffc000065aba0>] inet_sk_rebuild_header+0x0/0x5f0
[<fffffc0000640c74>] tcp_transmit_skb+0x9e4/0xbf0
[<fffffc0000641cd8>] tcp_retransmit_skb+0x128/0x7d0
[<fffffc000064379c>] tcp_xmit_retransmit_queue+0x1dc/0x400
[<fffffc00005f5618>] sk_reset_timer+0x28/0x60
[<fffffc000063b414>] tcp_ack+0x1204/0x1e80
[<fffffc000063eca8>] tcp_rcv_state_process+0x6c8/0x13f0
[<fffffc0000649148>] tcp_v4_do_rcv+0x128/0x480
[<fffffc000064a138>] tcp_v4_rcv+0xc98/0xcb0
[<fffffc00006255bc>] ip_local_deliver+0x1ac/0x400
[<fffffc0000625160>] ip_rcv+0x480/0x730
[<fffffc00006017a4>] netif_receive_skb+0x184/0x330
[<fffffc0000601a24>] process_backlog+0xd4/0x1d0
[<fffffc0000600394>] net_rx_action+0xb4/0x1a0
[<fffffc0000330cb0>] __do_softirq+0x90/0x130
[<fffffc0000330db4>] do_softirq+0x64/0x70
[<fffffc0000316c14>] handle_irq+0x124/0x1b0
[<fffffc000031ff28>] isa_device_interrupt+0x28/0x40
[<fffffc000031fe38>] pyxis_device_interrupt+0x68/0x130
[<fffffc0000317328>] do_entInt+0x118/0x190
[<fffffc00003112d0>] ret_from_sys_call+0x0/0x10

Kernel panic - not syncing: Aiee, killing interrupt handler!
 fffffc0009797820 fffffc0004cc0540 fffffc000032e818 fffffc00097979e0
       0000000000000000 0000000000000001 fffffc0009797890 0000000000000=
008
       fffffc0009797970 000000000000671a ffffffffffffffff fffffc0009797=
820
       ffffffff00000008 0000000000000001 fffffc000032e800 0000000000006=
71a
       ffffffffffffffff fffffc0009797820 ffffffff00000008 0000000000000=
001
       fffffc000031258c fffffc00097979e0 0000000000000000 fffffc0009797=
9e0
Trace:
[<fffffc000032e818>] do_exit+0xbf8/0xeb0
[<fffffc000032e800>] do_exit+0xbe0/0xeb0
[<fffffc000031258c>] die_if_kernel+0xdc/0xe0
[<fffffc0000312668>] do_entIF+0x58/0x350
[<fffffc00003112d0>] ret_from_sys_call+0x0/0x10
[<fffffc0000641cd8>] tcp_retransmit_skb+0x128/0x7d0
[<fffffc000065aba0>] inet_sk_rebuild_header+0x0/0x5f0
[<fffffc0000640c74>] tcp_transmit_skb+0x9e4/0xbf0
[<fffffc0000641cd8>] tcp_retransmit_skb+0x128/0x7d0
[<fffffc000064379c>] tcp_xmit_retransmit_queue+0x1dc/0x400
[<fffffc00005f5618>] sk_reset_timer+0x28/0x60
[<fffffc000063b414>] tcp_ack+0x1204/0x1e80
[<fffffc000063eca8>] tcp_rcv_state_process+0x6c8/0x13f0
[<fffffc0000649148>] tcp_v4_do_rcv+0x128/0x480
[<fffffc000064a138>] tcp_v4_rcv+0xc98/0xcb0
[<fffffc00006255bc>] ip_local_deliver+0x1ac/0x400
[<fffffc0000625160>] ip_rcv+0x480/0x730
[<fffffc00006017a4>] netif_receive_skb+0x184/0x330
[<fffffc0000601a24>] process_backlog+0xd4/0x1d0
[<fffffc0000600394>] net_rx_action+0xb4/0x1a0
[<fffffc0000330cb0>] __do_softirq+0x90/0x130
[<fffffc0000330db4>] do_softirq+0x64/0x70
[<fffffc0000316c14>] handle_irq+0x124/0x1b0
[<fffffc000031ff28>] isa_device_interrupt+0x28/0x40
[<fffffc000031fe38>] pyxis_device_interrupt+0x68/0x130
[<fffffc0000317328>] do_entInt+0x118/0x190
[<fffffc00003112d0>] ret_from_sys_call+0x0/0x10
elcome! This system runs Red Hat Linux release 9 (Shrike) (ttyS1)

merlin login: Kernel bug at net/ipv4/tcp_output.c:1403
squid(3726): Kernel Bug 1
pc =3D [<fffffc00006422c4>]  ra =3D [<fffffc0000642244>]  ps =3D 0000  =
  Not tainted
pc is at tcp_retransmit_skb+0x774/0x800
ra is at tcp_retransmit_skb+0x6f4/0x800
v0 =3D 0000000000000000  t0 =3D 0000000000000001  t1 =3D ffffffff9f29aa=
65
t2 =3D ffffffff9f29aa65  t3 =3D 0000000000004308  t4 =3D fffffc001c440a=
11
t5 =3D ffffffff9f29a934  t6 =3D 0000000000000001  t7 =3D fffffc00111940=
00
a0 =3D fffffc001139d160  a1 =3D fffffc0019a36ce0  a2 =3D 00000000000001=
31
a3 =3D 000000000000008c  a4 =3D 00d00057804c4012  a5 =3D 00000000000000=
00
t8 =3D fffffc001139d200  t9 =3D 0000000000000042  t10=3D 00000000000000=
00
t11=3D 0000000000000564  pv =3D fffffc0000641b50  at =3D 00000000000000=
00
gp =3D fffffc00007f1600  sp =3D fffffc0011197908
Trace:
[<fffffc000064554c>] tcp_write_timer+0x2bc/0x7a0
[<fffffc00003362d8>] run_timer_softirq+0x128/0x250
[<fffffc0000645290>] tcp_write_timer+0x0/0x7a0
[<fffffc0000330cb0>] __do_softirq+0x90/0x130
[<fffffc0000330db4>] do_softirq+0x64/0x70
[<fffffc0000330f9c>] local_bh_enable+0x6c/0xb0
[<fffffc0000603c88>] dev_queue_xmit+0xd8/0x3b0
[<fffffc000060b228>] neigh_resolve_output+0x128/0x370
[<fffffc000062c484>] ip_output+0x1d4/0x430
[<fffffc000062a680>] ip_queue_xmit+0x300/0x690
[<fffffc00006407c8>] tcp_transmit_skb+0x598/0xbf0
[<fffffc00006406cc>] tcp_transmit_skb+0x49c/0xbf0
[<fffffc0000632080>] cleanup_rbuf+0xc0/0x1b0
[<fffffc00006335a4>] tcp_recvmsg+0x3a4/0xa10
[<fffffc00005f572c>] sock_common_recvmsg+0x3c/0x60
[<fffffc0000330cb0>] __do_softirq+0x90/0x130
[<fffffc00005f4f5c>] sock_aio_read+0x14c/0x1b0
[<fffffc000037bb74>] do_sync_read+0xb4/0x110
[<fffffc000037c504>] vfs_read+0x184/0x190
[<fffffc000037c458>] vfs_read+0xd8/0x190
[<fffffc0000345590>] autoremove_wake_function+0x0/0x60
[<fffffc000037c638>] sys_read+0x68/0xb0
[<fffffc00003112b4>] entSys+0xa4/0xc0
Code: f41ffe69  c3ffffaf  2ffe0000  47ff041f  2ffe0000  00000081 <00000=
57b> 006
Debug: sleeping function called from invalid context at
include/linux/rwsem.h:43in_atomic():1, irqs_di
sabled():0
fffffc00111976b0 0000000000000001 fffffc000032b4c4 fffffc0000751600
       0000000000200200 0000000000000001 fffffc000032dc60 fffffc0011197=
820
       0000000000000000 0000000000000005 fffffc000031258c fffffc0011197=
820
       0000000000000000 fffffc0011197820 0000000000000564 fffffc0019a36=
d38
       fffffc0000816620 0000000000200200 0000000000000000 fffffc0011197=
820
       0000000000000564 0000000000200200 fffffc0000312668 0000000000000=
001
Trace:
[<fffffc000032b4c4>] profile_task_exit+0x34/0xd0
[<fffffc000032dc60>] do_exit+0x40/0xeb0
[<fffffc000031258c>] die_if_kernel+0xdc/0xe0
[<fffffc0000312668>] do_entIF+0x58/0x350
[<fffffc00003112d0>] ret_from_sys_call+0x0/0x10
[<fffffc0000336498>] update_process_times+0x98/0x190
[<fffffc0000642244>] tcp_retransmit_skb+0x6f4/0x800
[<fffffc0000641b50>] tcp_retransmit_skb+0x0/0x800
[<fffffc00006422c4>] tcp_retransmit_skb+0x774/0x800
[<fffffc000064554c>] tcp_write_timer+0x2bc/0x7a0
[<fffffc00003362d8>] run_timer_softirq+0x128/0x250
[<fffffc0000645290>] tcp_write_timer+0x0/0x7a0
[<fffffc0000330cb0>] __do_softirq+0x90/0x130
[<fffffc0000330db4>] do_softirq+0x64/0x70
[<fffffc0000330f9c>] local_bh_enable+0x6c/0xb0
[<fffffc0000603c88>] dev_queue_xmit+0xd8/0x3b0
[<fffffc000060b228>] neigh_resolve_output+0x128/0x370
[<fffffc000062c484>] ip_output+0x1d4/0x430
[<fffffc000062a680>] ip_queue_xmit+0x300/0x690
[<fffffc00006407c8>] tcp_transmit_skb+0x598/0xbf0
[<fffffc00006406cc>] tcp_transmit_skb+0x49c/0xbf0
[<fffffc0000632080>] cleanup_rbuf+0xc0/0x1b0
[<fffffc00006335a4>] tcp_recvmsg+0x3a4/0xa10
[<fffffc00005f572c>] sock_common_recvmsg+0x3c/0x60
[<fffffc0000330cb0>] __do_softirq+0x90/0x130
[<fffffc00005f4f5c>] sock_aio_read+0x14c/0x1b0
[<fffffc000037bb74>] do_sync_read+0xb4/0x110
[<fffffc000037c504>] vfs_read+0x184/0x190
[<fffffc000037c458>] vfs_read+0xd8/0x190
[<fffffc0000345590>] autoremove_wake_function+0x0/0x60
[<fffffc000037c638>] sys_read+0x68/0xb0
[<fffffc00003112b4>] entSys+0xa4/0xc0

fffffc00111976f0 0000000000000005 fffffc000031258c fffffc0011197820
       0000000000000000 fffffc0011197820 0000000000000564 fffffc0019a36=
d38
       fffffc0000816620 0000000000200200 0000000000000000 fffffc0011197=
820
       0000000000000564 0000000000200200 fffffc0000312668 0000000000000=
001
       0000000000000001 0000000000000000 fffffc00003112d0 fffffc001139d=
160
       fffffc001139d160 fffffc0019a36ce0 fffffc000082fd48 fffffc0000751=
600
Trace:
[<fffffc000031258c>] die_if_kernel+0xdc/0xe0
[<fffffc0000312668>] do_entIF+0x58/0x350
[<fffffc00003112d0>] ret_from_sys_call+0x0/0x10
[<fffffc0000336498>] update_process_times+0x98/0x190
[<fffffc0000642244>] tcp_retransmit_skb+0x6f4/0x800
[<fffffc0000641b50>] tcp_retransmit_skb+0x0/0x800
[<fffffc00006422c4>] tcp_retransmit_skb+0x774/0x800
[<fffffc000064554c>] tcp_write_timer+0x2bc/0x7a0
[<fffffc00003362d8>] run_timer_softirq+0x128/0x250
[<fffffc0000645290>] tcp_write_timer+0x0/0x7a0
[<fffffc0000330cb0>] __do_softirq+0x90/0x130
[<fffffc0000330db4>] do_softirq+0x64/0x70
[<fffffc0000330f9c>] local_bh_enable+0x6c/0xb0
[<fffffc0000603c88>] dev_queue_xmit+0xd8/0x3b0
[<fffffc000060b228>] neigh_resolve_output+0x128/0x370
[<fffffc000062c484>] ip_output+0x1d4/0x430
[<fffffc000062a680>] ip_queue_xmit+0x300/0x690
[<fffffc00006407c8>] tcp_transmit_skb+0x598/0xbf0
[<fffffc00006406cc>] tcp_transmit_skb+0x49c/0xbf0
[<fffffc0000632080>] cleanup_rbuf+0xc0/0x1b0
[<fffffc00006335a4>] tcp_recvmsg+0x3a4/0xa10
[<fffffc00005f572c>] sock_common_recvmsg+0x3c/0x60
[<fffffc0000330cb0>] __do_softirq+0x90/0x130
[<fffffc00005f4f5c>] sock_aio_read+0x14c/0x1b0
[<fffffc000037bb74>] do_sync_read+0xb4/0x110
[<fffffc000037c504>] vfs_read+0x184/0x190
[<fffffc000037c458>] vfs_read+0xd8/0x190
[<fffffc0000345590>] autoremove_wake_function+0x0/0x60
[<fffffc000037c638>] sys_read+0x68/0xb0
[<fffffc00003112b4>] entSys+0xa4/0xc0
Kernel bug at include/linux/skbuff.h:505
cc1(28040): Kernel Bug 1
pc =3D [<fffffc0000680914>]  ra =3D [<fffffc0000601380>]  ps =3D 0000  =
  Not tainted
pc is at packet_rcv_spkt+0x344/0x3e0
ra is at dev_queue_xmit_nit+0x1a0/0x1f0
v0 =3D fffffc00199f9560  t0 =3D 000000000175149f  t1 =3D 00000500000000=
00
t2 =3D 0000000000000001  t3 =3D fffffc0001751000  t4 =3D fffffc00017514=
9f
t5 =3D fffffc00017514d5  t6 =3D 0000000200000000  t7 =3D fffffc000bfe80=
00
a0 =3D fffffc00199f9560  a1 =3D fffffc001a6a8800  a2 =3D fffffc001eb1ce=
18
a3 =3D fffffc001a6a8800  a4 =3D fffffc00199f9560  a5 =3D 00000000000000=
00
t8 =3D 0000000000000000  t9 =3D 0000000000000000  t10=3D 00000000000000=
00
t11=3D 0000000000000000  pv =3D fffffc00006805d0  at =3D 00000000000000=
00
gp =3D fffffc00007f1600  sp =3D fffffc000bfebb58
Trace:
[<fffffc0000601380>] dev_queue_xmit_nit+0x1a0/0x1f0
[<fffffc0000612010>] qdisc_restart+0x1e0/0x2b0
[<fffffc0000603c68>] dev_queue_xmit+0xb8/0x3b0
[<fffffc000060b228>] neigh_resolve_output+0x128/0x370
[<fffffc000062c3b4>] ip_output+0x1d4/0x420
[<fffffc000062a5e0>] ip_queue_xmit+0x2e0/0x640
[<fffffc00006406d8>] tcp_transmit_skb+0x588/0xbb0
[<fffffc000064689c>] tcp_v4_send_check+0x11c/0x150
[<fffffc00006405dc>] tcp_transmit_skb+0x48c/0xbb0
[<fffffc0000641b48>] tcp_retransmit_skb+0x118/0x7b0
[<fffffc000064539c>] tcp_write_timer+0x2bc/0x7a0
[<fffffc0000335d28>] process_timeout+0x18/0x30
[<fffffc0000335d10>] process_timeout+0x0/0x30
[<fffffc00003362d8>] run_timer_softirq+0x128/0x250
[<fffffc00006450e0>] tcp_write_timer+0x0/0x7a0
[<fffffc0000330cb0>] __do_softirq+0x90/0x130
[<fffffc0000330db4>] do_softirq+0x64/0x70
[<fffffc0000316c14>] handle_irq+0x124/0x1b0
[<fffffc0000317384>] do_entInt+0x174/0x190
[<fffffc00003112d0>] ret_from_sys_call+0x0/0x10

file(14663): Kernel Bug 1
pc =3D [<fffffffc0021593c>]  ra =3D [<fffffc0000611eb8>]  ps =3D 0000  =
  Not tainted
pc is at ei_start_xmit+0x36c/0x3c0 [8390]
ra is at qdisc_restart+0x88/0x2b0
v0 =3D 0000000000000000  t0 =3D 0000000000000001  t1 =3D fffffc0012c74a=
af
t2 =3D 0000000000000036  t3 =3D fffffc00012dfa48  t4 =3D fffffc001b95b5=
3e
t5 =3D fffffc0012c74ae5  t6 =3D 0000000200000000  t7 =3D fffffc001cc340=
00
a0 =3D fffffc000bc29540  a1 =3D fffffc001a524800  a2 =3D 00000000000000=
04
a3 =3D fffffc001a524800  a4 =3D fffffc001b95b4e0  a5 =3D 00000000000000=
00
t8 =3D 0000000000000000  t9 =3D 0000000000000000  t10=3D 00000000000000=
00
t11=3D 0000000000000000  pv =3D fffffffc002155d0  at =3D 00000000000000=
00
gp =3D fffffffc0020f530  sp =3D fffffc001cc378f8
Trace:
[<fffffc0000611eb8>] qdisc_restart+0x88/0x2b0
[<fffffc0000603c68>] dev_queue_xmit+0xb8/0x3b0
[<fffffc000060b228>] neigh_resolve_output+0x128/0x370
[<fffffc000062c3e4>] ip_output+0x1d4/0x420
[<fffffc000062a610>] ip_queue_xmit+0x2e0/0x640
[<fffffc0000640708>] tcp_transmit_skb+0x588/0xbb0
[<fffffc00006468cc>] tcp_v4_send_check+0x11c/0x150
[<fffffc000064060c>] tcp_transmit_skb+0x48c/0xbb0
[<fffffc0000641b78>] tcp_retransmit_skb+0x118/0x7b0
[<fffffc000064360c>] tcp_xmit_retransmit_queue+0x1bc/0x3c0
[<fffffc00005f5618>] sk_reset_timer+0x28/0x60
[<fffffc000063b7e0>] tcp_ack+0x16e0/0x1e80
[<fffffc000063eb98>] tcp_rcv_state_process+0x6c8/0x13f0
[<fffffc0000648f98>] tcp_v4_do_rcv+0x128/0x480
[<fffffc0000649f88>] tcp_v4_rcv+0xc98/0xcb0
[<fffffc000062550c>] ip_local_deliver+0x1ac/0x400
[<fffffc00006250b0>] ip_rcv+0x480/0x730
[<fffffc0000601794>] netif_receive_skb+0x174/0x300
[<fffffc00006019ec>] process_backlog+0xcc/0x1b0
[<fffffc0000600394>] net_rx_action+0xb4/0x1a0
[<fffffc0000330cb0>] __do_softirq+0x90/0x130
[<fffffc0000330db4>] do_softirq+0x64/0x70
[<fffffc0000316c14>] handle_irq+0x124/0x1b0
[<fffffc000031ff28>] isa_device_interrupt+0x28/0x40
[<fffffc000031fe38>] pyxis_device_interrupt+0x68/0x130
[<fffffc0000317328>] do_entInt+0x118/0x190
[<fffffc00003112d0>] ret_from_sys_call+0x0/0x10
Kernel bug at include/linux/skbuff.h:505
cc1(19157): Kernel Bug 1
pc =3D [<fffffc0000680914>]  ra =3D [<fffffc0000601380>]  ps =3D 0000  =
  Not tainted
pc is at packet_rcv_spkt+0x344/0x3e0
ra is at dev_queue_xmit_nit+0x1a0/0x1f0
v0 =3D fffffc0019244760  t0 =3D 0000000005e35bbf  t1 =3D 00000500000000=
00
t2 =3D 0000000000000001  t3 =3D fffffc0005e35800  t4 =3D fffffc0005e35b=
bf
t5 =3D fffffc0005e35bf5  t6 =3D 0000000200000000  t7 =3D fffffc000df440=
00
a0 =3D fffffc0019244760  a1 =3D fffffc000f355000  a2 =3D fffffc000f9722=
18
a3 =3D fffffc000f355000  a4 =3D fffffc0019244760  a5 =3D 00000000000000=
00
t8 =3D 0000000000000000  t9 =3D 0000000000000000  t10=3D 00000000000000=
00
t11=3D 0000000000000000  pv =3D fffffc00006805d0  at =3D 00000000000000=
00
gp =3D fffffc00007f1600  sp =3D fffffc000df47b58
Trace:
[<fffffc0000601380>] dev_queue_xmit_nit+0x1a0/0x1f0
[<fffffc0000612010>] qdisc_restart+0x1e0/0x2b0
[<fffffc0000603c68>] dev_queue_xmit+0xb8/0x3b0
[<fffffc000060b228>] neigh_resolve_output+0x128/0x370
[<fffffc000062c3b4>] ip_output+0x1d4/0x420
[<fffffc000062a5e0>] ip_queue_xmit+0x2e0/0x640
[<fffffc00006406d8>] tcp_transmit_skb+0x588/0xbb0
[<fffffc000064689c>] tcp_v4_send_check+0x11c/0x150
[<fffffc00006405dc>] tcp_transmit_skb+0x48c/0xbb0
[<fffffc0000641b48>] tcp_retransmit_skb+0x118/0x7b0
[<fffffc000064539c>] tcp_write_timer+0x2bc/0x7a0
[<fffffc0000336498>] update_process_times+0x98/0x190
[<fffffc00003362d8>] run_timer_softirq+0x128/0x250
[<fffffc00006450e0>] tcp_write_timer+0x0/0x7a0
[<fffffc0000330cb0>] __do_softirq+0x90/0x130
[<fffffc0000330db4>] do_softirq+0x64/0x70
[<fffffc0000316c14>] handle_irq+0x124/0x1b0
[<fffffc0000317384>] do_entInt+0x174/0x190
[<fffffc00003112d0>] ret_from_sys_call+0x0/0x10

Badness in ne_block_output at drivers/net/ne.c:720
fffffc000908bae8 0000000000000000 fffffffc00215708 fffffc0019916bc0
       fffffc0019916800 fffffc00060e5ae0 0000000000000040 0000000000000=
03c
       fffffc890000032f 0000000000000000 fffffc001928c980 fffffc001a6bb=
400
       fffffc0000680784 fffffc001928c9d8 fffffc0000601380 fffffc001928c=
980
       fffffffc00215630 fffffc0019916bc0 fffffc001b9a4c4d fffffc0019916=
bc0
       fffffc0000611eb8 fffffc0019916800 fffffc001741b000 0000000000000=
000
Trace:
[<fffffc0000680784>] packet_rcv_spkt+0x1a4/0x3b0
[<fffffc0000601380>] dev_queue_xmit_nit+0x1a0/0x1f0
[<fffffc0000611eb8>] qdisc_restart+0x88/0x2b0
[<fffffc0000603c68>] dev_queue_xmit+0xb8/0x3b0
[<fffffc000060b228>] neigh_resolve_output+0x128/0x370
[<fffffc000062c3e4>] ip_output+0x1d4/0x420
[<fffffc000062a610>] ip_queue_xmit+0x2e0/0x640
[<fffffc0000640708>] tcp_transmit_skb+0x588/0xbb0
[<fffffc00006468cc>] tcp_v4_send_check+0x11c/0x150
[<fffffc000064060c>] tcp_transmit_skb+0x48c/0xbb0
[<fffffc0000641b78>] tcp_retransmit_skb+0x118/0x7b0
[<fffffc00006453cc>] tcp_write_timer+0x2bc/0x7a0
[<fffffc0000336498>] update_process_times+0x98/0x190
[<fffffc00003362d8>] run_timer_softirq+0x128/0x250
[<fffffc0000645110>] tcp_write_timer+0x0/0x7a0
[<fffffc0000330cb0>] __do_softirq+0x90/0x130
[<fffffc0000330db4>] do_softirq+0x64/0x70
[<fffffc0000316c14>] handle_irq+0x124/0x1b0
[<fffffc0000317384>] do_entInt+0x174/0x190
[<fffffc00003112d0>] ret_from_sys_call+0x0/0x10

ne_block_output(): buf not aligned 1b9a4c4d (count 60)
Kernel bug at arch/alpha/kernel/io.c:355
cc1(22129): Kernel Bug 1
pc =3D [<fffffc000031b96c>]  ra =3D [<fffffffc0021a68c>]  ps =3D 0000  =
  Not tainted
pc is at iowrite16_rep+0xdc/0xf0
ra is at ne_block_output+0x18c/0x3a0 [ne]
v0 =3D fffffc8900000330  t0 =3D 0000000000000001  t1 =3D fffffc0019916b=
c0
t2 =3D 000000000000001e  t3 =3D 0000000000000328  t4 =3D 00000000000003=
29
t5 =3D 0000000000000327  t6 =3D 0000000000004000  t7 =3D fffffc00090880=
00
a0 =3D fffffc8900000330  a1 =3D fffffc001b9a4c4d  a2 =3D 00000000000000=
1e
a3 =3D 000000000000000a  a4 =3D fffffffffffffffc  a5 =3D 00000000000000=
01
t8 =3D 0000000000000000  t9 =3D fffffc00004ff570  t10=3D 00000000000000=
00
t11=3D 000000000000000a  pv =3D fffffc000031b980  at =3D 00000000000000=
00
gp =3D fffffc00007f1600  sp =3D fffffc000908bac8
Trace:
[<fffffc0000611eb8>] qdisc_restart+0x88/0x2b0
[<fffffc0000603c68>] dev_queue_xmit+0xb8/0x3b0
[<fffffc000060b228>] neigh_resolve_output+0x128/0x370
[<fffffc000062c3e4>] ip_output+0x1d4/0x420
[<fffffc000062a610>] ip_queue_xmit+0x2e0/0x640
[<fffffc0000640708>] tcp_transmit_skb+0x588/0xbb0
[<fffffc00006468cc>] tcp_v4_send_check+0x11c/0x150
[<fffffc000064060c>] tcp_transmit_skb+0x48c/0xbb0
[<fffffc0000641b78>] tcp_retransmit_skb+0x118/0x7b0
[<fffffc00006453cc>] tcp_write_timer+0x2bc/0x7a0
[<fffffc0000336498>] update_process_times+0x98/0x190
[<fffffc00003362d8>] run_timer_softirq+0x128/0x250
[<fffffc0000645110>] tcp_write_timer+0x0/0x7a0
[<fffffc0000330cb0>] __do_softirq+0x90/0x130
[<fffffc0000330db4>] do_softirq+0x64/0x70
[<fffffc0000316c14>] handle_irq+0x124/0x1b0
[<fffffc0000317384>] do_entInt+0x174/0x190
[<fffffc00003112d0>] ret_from_sys_call+0x0/0x10

=46eel free to contact me, for further stack traces.

------- You are receiving this mail because: -------
You are the assignee for the bug, or are watching the assignee.
