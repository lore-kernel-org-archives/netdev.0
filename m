From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: [OOPS] 2.4.25 fealnx: oops with heavy UDP traffic
Date: Sun, 21 Mar 2004 23:46:33 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403212346.33838.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: quoted-printable
Cc: Jeff Garzik <jgarzik@pobox.com>, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I can trigger this reliably with
  nc -nvu -l -p 19 </dev/zero >/dev/null
on one box and
  nc -nvu <ip_addr> 19 </dev/zero >/dev/null
on another. Second box oops instantly.
I wrote oops down by hand, mistakes are possible.
I substituted 77777777 to irrelevant regs etc.

Oops does not happen if I replace NIC with Intel one.

# lspci
00:05.0 Host bridge: Hint Corp VXPro II Chipset
00:05.1 ISA bridge: Hint Corp VXPro II Chipset
00:05.2 IDE interface: Hint Corp VXPro II IDE
00:08.0 VGA compatible controller: S3 Inc. 86c764/765 [Trio32/64/64V+] (r=
ev 54)
00:0a.0 Ethernet controller: MYSON Technology Inc SURECOM EP-320X-S 100/1=
0M Ethernet PCI Adapter

Looks like rx IRQ happened inside previous rx IRQ.

ksymoops 2.4.1 on i686 2.6.4-rc2-bk3.  Options used
     -V (specified)
     -K (specified)
     -L (specified)
     -o /lib/modules/2.4.25 (specified)
     -m /boot/2.4.25/System.map (specified)

No modules in ksyms, skipping objects
Unable to handle kernel NULL pointer dereference at virtual address 00000=
064
*pde =3D 00000000
Oops: 0000
CPU:    0
EIP:    0010:[<c01=C1=C17=D30>]    Not tainted
EFLAGS: 00010202
eax: 77777777 =9A ebx: 00000000 =9A ecx: 77777777 =9A edx: 77777777
esi: 00000000 =9A edi: 00000000 =9A ebp: 77777777 =9A esp: 77777777
ds: 7777 =9A es: 7777 =9A ss: 7777
Process nc (pid: 7, stackpage=3D77777777)
Stack: 77777777 77777777 77777777 77777777 77777777 77777777 77777777 777=
77777
Call Trace:    [<c01ff323>] [<c0109ae6>] [<c0109c5b>] [<c010c100>] [<c02e=
16c4>]
  [<c02e180b>] [<c02e0d76>] [<c08d9310>] [<c08d868d>] [<c02f6d34>] [<c02e=
b10e>]
  [<c02f6d34>] [<c02eb382>] [<c02f6d34>] [<c08db320>] [<c02f6b61>] [<c02f=
6d34>]
  [<c02c48b9>] [<c02e49b8>] [<c02e4abb>] [<c011a1cf>] [<c0109c96>] [<c010=
c100>]
  [<c032eccb>] [<c02e2374>] [<c0312b06>] [<c02f9aeb>] [<c02f9d34>] [<c031=
2a50>]
  [<c0312d72>] [<c0312a50>] [<c01bd7ef>] [<c012b60f>] [<c02ed177>] [<c031=
8ee5>]
  [<c02dd8a1>] [<c02dda85>] [<c0133446>] [<c0108b2b>]
Code: 8b 7b 64 85 ff 8b 83 88 00 00 00 0f 85 69 01 00 00
Using defaults from ksymoops -t elf32-i386 -a i386

Trace; c01ff323 <intr_handler+ab/314>
               drivers/net/fealnx.c:intr_handler():
               if (intr_status & (RI | RBU)) {
                        if (intr_status & RI)
                                netdev_rx(dev);   <=3D=3D=3D oopses insid=
e
                        else
                                reset_rx_descriptors(dev);
                }
Trace; c0109ae6 <handle_IRQ_event+32/60>
Trace; c0109c5b <do_IRQ+77/d4>
Trace; c010c100 <call_do_IRQ+5/d>
	second IRQ!
Trace; c02e16c4 <skb_copy_bits+48/1f8>
Trace; c02e180b <skb_copy_bits+18f/1f8>
Trace; c02e0d76 <skb_linearize+7e/100>
Trace; c08d9310 <END_OF_CODE+41f398/????>
Trace; c08d868d <END_OF_CODE+41e715/????>
Trace; c02f6d34 <ip_rcv_finish+0/204>
Trace; c02eb10e <nf_iterate+2e/78>
Trace; c02f6d34 <ip_rcv_finish+0/204>
Trace; c02eb382 <nf_hook_slow+5a/138>
Trace; c02f6d34 <ip_rcv_finish+0/204>
Trace; c08db320 <END_OF_CODE+4213a8/????>
Trace; c02f6b61 <ip_rcv+15d/1e8>
Trace; c02f6d34 <ip_rcv_finish+0/204>
Trace; c02c48b9 <fbcon_cfb24_putc+79/2ec>
Trace; c02e49b8 <process_backlog+6c/10c>
Trace; c02e4abb <net_rx_action+63/f4>
Trace; c011a1cf <do_softirq+97/9c>
Trace; c0109c96 <do_IRQ+b2/d4>
Trace; c010c100 <call_do_IRQ+5/d>
	first IRQ
Trace; c032eccb <csum_partial_copy_generic+83/e8>
Trace; c02e2374 <csum_partial_copy_fromiovecend+16c/1f4>
Trace; c0312b06 <udp_getfrag+b6/cc>
Trace; c02f9aeb <ip_build_xmit_slow+2db/4e0>
Trace; c02f9d34 <ip_build_xmit+44/350>
Trace; c0312a50 <udp_getfrag+0/cc>
Trace; c0312d72 <udp_sendmsg+1fa/3b4>
Trace; c0312a50 <udp_getfrag+0/cc>
Trace; c01bd7ef <do_con_write+27f/648>
Trace; c012b60f <kfree+2b/34>
Trace; c02ed177 <qdisc_restart+13/d8>
Trace; c0318ee5 <inet_sendmsg+31/3c>
Trace; c02dd8a1 <sock_sendmsg+59/8c>
Trace; c02dda85 <sock_write+89/98>
Trace; c0133446 <sys_write+82/f0>
Trace; c0108b2b <system_call+33/38>

Code;  00000000 Before first symbol
00000000 <_EIP>:
Code;  00000000 Before first symbol
   0:   8b 7b 64                  mov    0x64(%ebx),%edi
Code;  00000003 Before first symbol
   3:   85 ff                     test   %edi,%edi
Code;  00000005 Before first symbol
   5:   8b 83 88 00 00 00         mov    0x88(%ebx),%eax
Code;  0000000b Before first symbol
   b:   0f 85 69 01 00 00         jne    17a <_EIP+0x17a>

drivers/net/fealnx.c:netdev_rx():
                        if (pkt_len < rx_copybreak &&
                            (skb =3D dev_alloc_skb(pkt_len + 2)) !=3D NUL=
L) {
                                skb->dev =3D dev;
                                skb_reserve(skb, 2);    /* 16 byte align =
the IP header */
                                /* Call copy + cksum if available. */

#if ! defined(__alpha__)
                                eth_copy_and_sum(skb,
                                        np->cur_rx->skbuff->tail, pkt_len=
, 0);
                                skb_put(skb, pkt_len);
#else
                                memcpy(skb_put(skb, pkt_len),
                                        np->cur_rx->skbuff->tail, pkt_len=
);
#endif
                        } else {
                                skb_put(skb =3D np->cur_rx->skbuff, pkt_l=
en);
                                np->cur_rx->skbuff =3D NULL;
                                if (np->really_rx_count =3D=3D RX_RING_SI=
ZE)
                                        np->lack_rxbuf =3D np->cur_rx;
                                --np->really_rx_count;
                        }

gcc -S of the same place:
        cmpl    rx_copybreak, %ecx
        jl      .L667
.L619:
        movl    -16(%ebp), %ecx
        movl    148(%ecx), %eax
        movl    20(%eax), %ebx
        movl    100(%ebx), %edi <=3D=3D=3D oopses here
        testl   %edi, %edi
        movl    136(%ebx), %eax
        jne     .L661
--
vda
