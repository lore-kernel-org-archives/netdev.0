From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [PATCH 0/5] Assorted mvneta fixes
Date: Sun, 12 Jan 2014 20:21:20 +0100
Message-ID: <87ob3hovkf.fsf@natisbad.org>
References: <1389519069-1619-1-git-send-email-w@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:33688 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751026AbaALTYd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 14:24:33 -0500
Received: from smtp.natisbad.org (unknown [81.57.185.249])
	by smtp6-g21.free.fr (Postfix) with ESMTP id 307878225C
	for <netdev@vger.kernel.org>; Sun, 12 Jan 2014 20:23:35 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Willy Tarreau <w@1wt.eu> writes:

> this series provides some fixes for a number of issues met with the
> mvneta driver :
>
>   - driver lockup when reading stats while sending traffic from multi=
ple
>     CPUs : this obviously only happens on SMP and is the result of mi=
ssing
>     locking on the driver. The problem was present since the introduc=
tion
>     of the driver in 3.8. The first patch performs some changes that =
are
>     needed for the second one which actually fixes the issue by using
>     per-cpu counters. It could make sense to backport this to the rel=
evant
>     stable versions.
>
>   - mvneta_tx_timeout calls various functions to reset the NIC, and t=
hese
>     functions sleep, which is not allowed here, resulting in a panic.
>     Better completely disable this Tx timeout handler for now since i=
t is
>     never called. The problem was encountered while developing some n=
ew
>     features, it's uncertain whether it's possible to reproduce it wi=
th
>     regular usage, so maybe a backport to stable is not needed.
>
>   - replace the Tx timer with a real Tx IRQ. As first reported by Arn=
aud
>     Ebalard and explained by Eric Dumazet, there is no way this drive=
r
>     can work correctly if it uses a driver to recycle the Tx descript=
ors.
>     If too many packets are sent at once, the driver quickly ends up =
with
>     no descriptors (which happens twice as easily in GSO) and has to =
wait
>     10ms for recycling its descriptors and being able to send again. =
Eric
>     has worked around this in the core GSO code. But still when routi=
ng
>     traffic or sending UDP packets, the limitation is very visible. U=
sing
>     Tx IRQs allows Tx descriptors to be recycled when sent. The coale=
sce
>     value is still configurable using ethtool. This fix turns the UDP
>     send bitrate from 134 Mbps to 987 Mbps (ie: line rate). It's made=
 of
>     two patches, one to add the relevant bits from the original Marve=
ll's
>     driver, and another one to implement the change. I don't know if =
it
>     should be backported to stable, as the bug only causes poor perfo=
rmance.

=46irst, thanks a lot for that work!

=46unny enough, I spent some time this week-end trying to find the root
cause of some kernel freezes and panics appearing randomly after some G=
B
read on a ReadyNAS 102 configured as a NFS server.=20

I tested your fixes and performance series together on top of current
3.13.0-rc7 and I am now unable to reproduce the freeze and panics after
having read more than the 300GB of traffic from the NAS: following
bandwith with a bwm-ng shows the rate is also far more stable than w/
previous driver logic (55MB/sec). So, FWIW:

Tested-by: Arnaud Ebalard <arno@natisbad.org>

Willy, I can extend the test to RN2120 if you think it is useful to als=
o
do additional tests on a dual-core armada XP.



Now, just in case someone on netdev can find something useful in the
panics I gathered before your set, I have added those below. The fact
that the bugs have disappeared with your set would tend to confirm that
it was in the driver but at some point during the tests, I suspected th=
e
TCP stack when the device is stressed (NFS seems to do that very well o=
n
a 1.2GHz/512MB device). I did the following tests:

- on a 3.12.5, 3.13.0-rc4 and rc7 on a ReadyNAS 102
- 3.13.0-rc7 on a RN2120 (dual-core Armada XP w/ mvneta and 2GB of RAM)=
:
  no issue seen after 200GB of traffic transfered
- 3.13.0-rc7 on a Duo v2 (kirkwood 88F6282 @ 1.6GHz w/ mv643xx_eth): no
  issue=20



# [  755.601675] Unable to handle kernel paging request at virtual addr=
ess 00200200
[  755.608919] pgd =3D c0004000
[  755.611639] [00200200] *pgd=3D00000000
[  755.615234] Internal error: Oops: 815 [#1] ARM
[  755.619684] Modules linked in:
[  755.622755] CPU: 0 PID: 0 Comm: swapper Not tainted 3.12.5.rn102 #1
[  755.629033] task: c0769718 ti: c075c000 task.ti: c075c000
[  755.634446] PC is at destroy_conntrack+0x54/0xb8
[  755.639072] LR is at destroy_conntrack+0x40/0xb8
[  755.643697] pc : [<c04703b8>]    lr : [<c04703a4>]    psr: 200f0113
[  755.643697] sp : c075dcb8  ip : c051be4c  fp : c0595c30
[  755.655194] r10: deefee38  r9 : 00000004  r8 : df9aeee4
[  755.660426] r7 : df94f800  r6 : df9aec00  r5 : c0798798  r4 : df9b79=
a0
[  755.666963] r3 : 00200200  r2 : 80000001  r1 : 00000006  r0 : df9b79=
a0
[  755.673501] Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Seg=
ment kernel
[  755.680822] Control: 10c5387d  Table: 1fbb0019  DAC: 00000015
[  755.686576] Process swapper (pid: 0, stack limit =3D 0xc075c238)
[  755.692419] Stack: (0xc075dcb8 to 0xc075e000)
[  755.696784] dca0:                                                   =
    c0470364 dee8c540
[  755.704978] dcc0: df94f800 c046b674 00000000 c051bf74 c07645f4 dee8c=
540 c0764608 c04485a0
[  755.713173] dce0: 00000000 00000014 9b880c87 1348632e df9b79a0 c0764=
608 00000002 00000000
[  755.721367] dd00: 00000000 df94f800 deefee38 df35315c df94f800 c044b=
da8 c048cbac df94f800
[  755.729561] dd20: 00000000 c0764ce4 c0764cdc 00000000 00000000 dee44=
a00 df94f800 deefee38
[  755.737754] dd40: deefee38 df35315c 00000010 c04617c0 dee44a00 00000=
000 0000000e 00000000
[  755.745949] dd60: df35315c deefee38 df94f800 c044c114 dee44a60 00738=
0dd 00000000 dee0b3c0
[  755.754142] dd80: dee0b43c 0000000e 00000000 deefee38 df94f800 dee3a=
a80 00000010 c048cd8c
[  755.762335] dda0: 80000000 0b50a8c0 0000004f deefee38 dedb3440 00000=
000 dedb3618 dee3aa80
[  755.770529] ddc0: 0000004f 009c0000 c07a1180 c048d158 deefee38 c048d=
288 deefed80 dedb3440
[  755.778723] dde0: deefed80 00000001 0000004f 0000824f 00000020 dedb3=
440 deefee38 c076c438
[  755.786917] de00: 0000004f dee3aa80 c07a1180 c04a1ae8 9b878191 13486=
32e 008a633f 00000000
[  755.795111] de20: 00000002 00000000 00000000 0000824f 008a633f 00000=
000 dedb3440 dedb3440
[  755.803305] de40: deefed80 0000000f c076c438 c07a1990 0000004f c07a1=
b90 c07a1180 c04a34a8
[  755.811498] de60: dedb3440 dedb34dc 0000000f c04a51a4 ffff0bdc 00026=
259 00000000 dedb3440
[  755.819692] de80: 00000100 c04a5798 c076c438 c04a576c 00000000 dedb3=
440 00000100 c04a5810
[  755.827886] dea0: c075c000 c0023ad0 00000000 c0fa6140 c076d170 c075d=
ed0 00200200 00000000
[  755.836080] dec0: c076c438 c0023c68 c07a1d90 c07a1f90 c075ded0 c075d=
ed0 c0769718 00000001
[  755.844274] dee0: 00000004 c07a1048 c07a1040 c075c000 00000001 00000=
100 00000004 c001e8f4
[  755.852468] df00: 00000000 c004bb18 00000000 0000000a 00008250 00200=
000 df808800 600f0193
[  755.860662] df20: 00000010 00000000 c075df78 c07a04c0 00000001 c07a0=
4c0 00000000 c001ea6c
[  755.868856] df40: c077ef70 c001ec98 c077ef70 c000e9e4 c07eaf00 00000=
3ff c07eaf00 c00084d4
[  755.877049] df60: c000eb60 c004000c 600f0013 ffffffff c075dfac c0011=
000 00000000 00000000
[  755.885243] df80: 00000000 c076e0c0 c075c000 c075c000 c075c000 c0764=
0c4 c07a04c0 00000001
[  755.893437] dfa0: c07a04c0 00000000 01000000 c075dfc0 c000eb60 c0040=
00c 600f0013 ffffffff
[  755.901630] dfc0: c0fa4e40 c072f9dc ffffffff ffffffff c072f4f0 00000=
000 00000000 c0755318
[  755.909823] dfe0: 00000000 10c53c7d c0764074 c0755314 c076a670 00008=
070 00000000 00000000
[  755.918031] [<c04703b8>] (destroy_conntrack+0x54/0xb8) from [<c046b6=
74>] (nf_conntrack_destroy+0x18/0x24)
[  755.927628] [<c046b674>] (nf_conntrack_destroy+0x18/0x24) from [<c05=
1bf74>] (packet_rcv_spkt+0x128/0x12c)
[  755.937226] [<c051bf74>] (packet_rcv_spkt+0x128/0x12c) from [<c04485=
a0>] (dev_queue_xmit_nit+0x1ac/0x210)
[  755.946816] [<c04485a0>] (dev_queue_xmit_nit+0x1ac/0x210) from [<c04=
4bda8>] (dev_hard_start_xmit+0x2cc/0x484)
[  755.956759] [<c044bda8>] (dev_hard_start_xmit+0x2cc/0x484) from [<c0=
4617c0>] (sch_direct_xmit+0xa4/0x198)
[  755.966346] [<c04617c0>] (sch_direct_xmit+0xa4/0x198) from [<c044c11=
4>] (dev_queue_xmit+0x1b4/0x3b8)
[  755.975499] [<c044c114>] (dev_queue_xmit+0x1b4/0x3b8) from [<c048cd8=
c>] (ip_finish_output+0x1e0/0x3d0)
[  755.984824] [<c048cd8c>] (ip_finish_output+0x1e0/0x3d0) from [<c048d=
158>] (ip_local_out+0x28/0x2c)
[  755.993801] [<c048d158>] (ip_local_out+0x28/0x2c) from [<c048d288>] =
(ip_queue_xmit+0x12c/0x364)
[  756.002525] [<c048d288>] (ip_queue_xmit+0x12c/0x364) from [<c04a1ae8=
>] (tcp_transmit_skb+0x40c/0x868)
[  756.011764] [<c04a1ae8>] (tcp_transmit_skb+0x40c/0x868) from [<c04a3=
4a8>] (tcp_retransmit_skb+0x10/0xe8)
[  756.021267] [<c04a34a8>] (tcp_retransmit_skb+0x10/0xe8) from [<c04a5=
1a4>] (tcp_retransmit_timer+0x22c/0x694)
[  756.031116] [<c04a51a4>] (tcp_retransmit_timer+0x22c/0x694) from [<c=
04a576c>] (tcp_write_timer_handler+0x160/0x18c)
[  756.041574] [<c04a576c>] (tcp_write_timer_handler+0x160/0x18c) from =
[<c04a5810>] (tcp_write_timer+0x78/0x80)
[  756.051431] [<c04a5810>] (tcp_write_timer+0x78/0x80) from [<c0023ad0=
>] (call_timer_fn.isra.35+0x24/0x84)
[  756.060934] [<c0023ad0>] (call_timer_fn.isra.35+0x24/0x84) from [<c0=
023c68>] (run_timer_softirq+0x138/0x1b4)
[  756.070782] [<c0023c68>] (run_timer_softirq+0x138/0x1b4) from [<c001=
e8f4>] (__do_softirq+0xc8/0x1ac)
[  756.079933] [<c001e8f4>] (__do_softirq+0xc8/0x1ac) from [<c001ea6c>]=
 (do_softirq+0x48/0x54)
[  756.088301] [<c001ea6c>] (do_softirq+0x48/0x54) from [<c001ec98>] (i=
rq_exit+0x68/0xa4)
[  756.096240] [<c001ec98>] (irq_exit+0x68/0xa4) from [<c000e9e4>] (han=
dle_IRQ+0x34/0x84)
[  756.104174] [<c000e9e4>] (handle_IRQ+0x34/0x84) from [<c00084d4>] (a=
rmada_370_xp_handle_irq+0x44/0x4c)
[  756.113504] [<c00084d4>] (armada_370_xp_handle_irq+0x44/0x4c) from [=
<c0011000>] (__irq_svc+0x40/0x50)
[  756.122736] Exception stack(0xc075df78 to 0xc075dfc0)
[  756.127795] df60:                                                   =
    00000000 00000000
[  756.135990] df80: 00000000 c076e0c0 c075c000 c075c000 c075c000 c0764=
0c4 c07a04c0 00000001
[  756.144184] dfa0: c07a04c0 00000000 01000000 c075dfc0 c000eb60 c0040=
00c 600f0013 ffffffff
[  756.152386] [<c0011000>] (__irq_svc+0x40/0x50) from [<c004000c>] (cp=
u_startup_entry+0x44/0xe0)
[  756.161022] [<c004000c>] (cpu_startup_entry+0x44/0xe0) from [<c072f9=
dc>] (start_kernel+0x2c4/0x31c)
[  756.170085] Code: e3530000 0a000019 e5942004 e3120001 (e5832000)=20
[  756.176213] ---[ end trace 638dff0964bf92cd ]---
[  756.180839] Kernel panic - not syncing: Fatal exception in interrupt



[ 4606.485101] Unable to handle kernel paging request at virtual addres=
s 00200200
[ 4606.492365] pgd =3D c0004000
[ 4606.495077] [00200200] *pgd=3D00000000
[ 4606.498672] Internal error: Oops: 815 [#1] ARM
[ 4606.503122] Modules linked in:
[ 4606.506196] CPU: 0 PID: 4245 Comm: nfsd Not tainted 3.13.0-rc4.rn102=
-00256-gb7000adef17a-dirty #36
[ 4606.515169] task: df028dc0 ti: de598000 task.ti: de598000
[ 4606.520586] PC is at destroy_conntrack+0x54/0xb8
[ 4606.525212] LR is at destroy_conntrack+0x40/0xb8
[ 4606.529838] pc : [<c0481540>]    lr : [<c048152c>]    psr: 20000013
[ 4606.529838] sp : de599bc0  ip : c0536fac  fp : 00000000
[ 4606.541334] r10: de406238  r9 : 00000004  r8 : df0fd70c
[ 4606.546567] r7 : df99b800  r6 : df0fd400  r5 : c07bed78  r4 : de4133=
80
[ 4606.553104] r3 : 00200200  r2 : 00000a39  r1 : 00000006  r0 : de4133=
80
[ 4606.559643] Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Seg=
ment kernel
[ 4606.566963] Control: 10c5387d  Table: 1e768019  DAC: 00000015
[ 4606.572717] Process nfsd (pid: 4245, stack limit =3D 0xde598238)
[ 4606.578559] Stack: (0xde599bc0 to 0xde59a000)
[ 4606.582927] 9bc0: c04814ec ddde3f00 df99b800 c047c444 00000000 c0537=
0d4 c078a60c ddde3f00
[ 4606.591120] 9be0: c078a620 c0458960 00000000 df99b800 2ffd3da7 13481=
8b0 00000004 c078a620
[ 4606.599314] 9c00: 00000002 00000000 de406238 df99b800 dfbb095c c05b2=
198 00000000 c045c04c
[ 4606.607509] 9c20: c04a63f0 c047c524 c04a63f0 df99b800 00000000 c078a=
cfc 01933df9 00000000
[ 4606.615702] 9c40: 00000000 df2e5700 dfbb095c df99b800 df99b800 de406=
238 00000010 c04722d4
[ 4606.623896] 9c60: df2e5700 00000000 de406238 df99b800 dfbb095c df99b=
800 00000000 c045c42c
[ 4606.632089] 9c80: df2e5760 292a7186 df1a0600 df1a067c 0000000e 00000=
000 de406238 df99b800
[ 4606.640283] 9ca0: df24bf00 c04a65d0 80000000 0b50a8c0 00000000 de406=
238 de790f00 00000000
[ 4606.648477] 9cc0: de791104 df24bf00 00000000 009c0000 00000000 c04a6=
9a0 de406238 c04a6ad0
[ 4606.656671] 9ce0: 0003cec0 00000000 15a99438 00000000 00043a4c 00069=
231 00000020 de790f00
[ 4606.664864] 9d00: de406238 c0792768 00000000 df24bf00 00000000 c04bb=
2d4 2ffc758d 134818b0
[ 4606.673057] 9d20: df801780 00000000 00000002 00000000 00000000 00069=
231 0002f7f9 00000000
[ 4606.681251] 9d40: de790f00 de790f00 de406180 000005a8 dfbada80 00000=
960 00000000 15a99438
[ 4606.689444] 9d60: 00000000 c04bb954 de599d9f 000000d0 df801780 00000=
b50 000043e0 c044fa94
[ 4606.697639] 9d80: de406180 de790fbc 00000002 00000000 00000017 c044f=
ba4 00000000 de790f00
[ 4606.705833] 9da0: de406180 00000960 de790fbc de790f00 c0d5f640 00000=
000 00001000 c04bc2c4
[ 4606.714026] 9dc0: 00000020 de406d80 00001000 c04aed28 00000000 de599=
e38 df185400 c00ac654
[ 4606.722219] 9de0: 000005a8 00000000 de790fbc c0d5f650 00000b50 00000=
bb8 00000000 de790f00
[ 4606.730412] 9e00: df742000 00008000 00007040 00000000 de73d17c 00008=
000 de73d1c8 c04d2ed4
[ 4606.738605] 9e20: 00008000 c01acf5c 00000000 00000000 02600000 00000=
000 00008000 00008000
[ 4606.746799] 9e40: 00009000 c0446224 00008000 00000000 00001000 c054b=
9f4 00008000 df028df0
[ 4606.754993] 9e60: df028dc0 df742000 c000951c de73d000 de73d17c df742=
000 df3d1028 00000000
[ 4606.763186] 9e80: df331000 00000018 00000024 c054baa0 c0fc0620 00000=
040 c003a8e8 c0035830
[ 4606.771381] 9ea0: c0793470 de598000 de599ed4 c056b560 df028dc0 df3d1=
028 ffffffff df028dc0
[ 4606.779574] 9ec0: 00000002 df3d102c df331000 00000018 de599edc c056b=
9a4 de73d000 df3d1000
[ 4606.787767] 9ee0: c079eb34 df3d1028 00000000 c054bbcc de73d000 df3d1=
000 c079eb34 3c000180
[ 4606.795961] 9f00: de73d000 c05563b4 de73d000 c079eb70 c079eb34 ddcaa=
b00 c079eb4c c0548f40
[ 4606.804155] 9f20: df3d1000 df331018 df3d1024 01000000 df3d1000 de73d=
000 c080f758 de598000
[ 4606.812349] 9f40: c07bed78 00000000 00000000 00000000 00000000 c01a9=
5b0 00000000 00000000
[ 4606.820542] 9f60: df1d5e00 de73d000 c01a94fc c00328dc 00000000 00000=
000 00000000 de73d000
[ 4606.828735] 9f80: 00000000 de599f84 de599f84 00000000 de599f90 de599=
f90 de599fac df1d5e00
[ 4606.836929] 9fa0: c0032820 00000000 00000000 c000e298 00000000 00000=
000 00000000 00000000
[ 4606.845121] 9fc0: 00000000 00000000 00000000 00000000 00000000 00000=
000 00000000 00000000
[ 4606.853314] 9fe0: 00000000 00000000 00000000 00000000 00000013 00000=
000 00000000 00000000
[ 4606.861524] [<c0481540>] (destroy_conntrack+0x54/0xb8) from [<c047c4=
44>] (nf_conntrack_destroy+0x18/0x24)
[ 4606.871121] [<c047c444>] (nf_conntrack_destroy+0x18/0x24) from [<c05=
370d4>] (packet_rcv_spkt+0x128/0x12c)
[ 4606.880711] [<c05370d4>] (packet_rcv_spkt+0x128/0x12c) from [<c04589=
60>] (dev_queue_xmit_nit+0x1b0/0x214)
[ 4606.890301] [<c0458960>] (dev_queue_xmit_nit+0x1b0/0x214) from [<c04=
5c04c>] (dev_hard_start_xmit+0x2dc/0x504)
[ 4606.900236] [<c045c04c>] (dev_hard_start_xmit+0x2dc/0x504) from [<c0=
4722d4>] (sch_direct_xmit+0xa4/0x19c)
[ 4606.909823] [<c04722d4>] (sch_direct_xmit+0xa4/0x19c) from [<c045c42=
c>] (dev_queue_xmit+0x1b8/0x3c0)
[ 4606.918984] [<c045c42c>] (dev_queue_xmit+0x1b8/0x3c0) from [<c04a65d=
0>] (ip_finish_output+0x1e0/0x3d4)
[ 4606.928311] [<c04a65d0>] (ip_finish_output+0x1e0/0x3d4) from [<c04a6=
9a0>] (ip_local_out+0x28/0x2c)
[ 4606.937289] [<c04a69a0>] (ip_local_out+0x28/0x2c) from [<c04a6ad0>] =
(ip_queue_xmit+0x12c/0x364)
[ 4606.946014] [<c04a6ad0>] (ip_queue_xmit+0x12c/0x364) from [<c04bb2d4=
>] (tcp_transmit_skb+0x42c/0x86c)
[ 4606.955254] [<c04bb2d4>] (tcp_transmit_skb+0x42c/0x86c) from [<c04bb=
954>] (tcp_write_xmit+0x174/0xa74)
[ 4606.964581] [<c04bb954>] (tcp_write_xmit+0x174/0xa74) from [<c04bc2c=
4>] (__tcp_push_pending_frames+0x30/0x98)
[ 4606.974516] [<c04bc2c4>] (__tcp_push_pending_frames+0x30/0x98) from =
[<c04aed28>] (tcp_sendpage+0x648/0x6c0)
[ 4606.984285] [<c04aed28>] (tcp_sendpage+0x648/0x6c0) from [<c04d2ed4>=
] (inet_sendpage+0x48/0x98)
[ 4606.993007] [<c04d2ed4>] (inet_sendpage+0x48/0x98) from [<c0446224>]=
 (kernel_sendpage+0x24/0x3c)
[ 4607.001814] [<c0446224>] (kernel_sendpage+0x24/0x3c) from [<c054b9f4=
>] (svc_send_common+0xb4/0x110)
[ 4607.010879] [<c054b9f4>] (svc_send_common+0xb4/0x110) from [<c054baa=
0>] (svc_sendto+0x50/0x114)
[ 4607.019594] [<c054baa0>] (svc_sendto+0x50/0x114) from [<c054bbcc>] (=
svc_tcp_sendto+0x3c/0xb4)
[ 4607.028140] [<c054bbcc>] (svc_tcp_sendto+0x3c/0xb4) from [<c05563b4>=
] (svc_send+0x94/0xd8)
[ 4607.036421] [<c05563b4>] (svc_send+0x94/0xd8) from [<c0548f40>] (svc=
_process+0x1f0/0x698)
[ 4607.044617] [<c0548f40>] (svc_process+0x1f0/0x698) from [<c01a95b0>]=
 (nfsd+0xb4/0x118)
[ 4607.052557] [<c01a95b0>] (nfsd+0xb4/0x118) from [<c00328dc>] (kthrea=
d+0xbc/0xd8)
[ 4607.059975] [<c00328dc>] (kthread+0xbc/0xd8) from [<c000e298>] (ret_=
from_fork+0x14/0x3c)
[ 4607.068082] Code: e3530000 0a000019 e5942004 e3120001 (e5832000)=20
[ 4607.074211] ---[ end trace 6cf53cc3160e3eb5 ]---
[ 4607.078836] Kernel panic - not syncing: Fatal exception in interrupt



[  364.012886] Unable to handle kernel NULL pointer dereference at virt=
ual address 00000005
[  364.021020] pgd =3D c0004000
[  364.023733] [00000005] *pgd=3D00000000
[  364.027328] Internal error: Oops: 15 [#1] ARM
[  364.031690] Modules linked in:
[  364.034762] CPU: 0 PID: 4266 Comm: nfsd Not tainted 3.13.0-rc4.rn102=
-00256-gb7000ad-dirty #31
[  364.043300] task: dfbef340 ti: de982000 task.ti: de982000
[  364.048718] PC is at tcp_ack+0x5b4/0xccc
[  364.052652] LR is at kmem_cache_free+0x100/0x10c
[  364.057278] pc : [<c04b7730>]    lr : [<c008689c>]    psr: a00f0013
[  364.057278] sp : de983cb8  ip : dfa78600  fp : 00000000
[  364.068774] r10: 00000000  r9 : df088022  r8 : 00000009
[  364.074007] r7 : 0000020c  r6 : 00000000  r5 : dfa78480  r4 : de8b8a=
00
[  364.080544] r3 : 00000001  r2 : df088022  r1 : a00f0013  r0 : 000000=
00
[  364.087082] Flags: NzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Seg=
ment kernel
[  364.094403] Control: 10c5387d  Table: 1f158019  DAC: 00000015
[  364.100157] Process nfsd (pid: 4266, stack limit =3D 0xde982238)
[  364.105998] Stack: (0xde983cb8 to 0xde984000)
[  364.110363] 3ca0:                                                   =
    00000000 000018fa
[  364.118556] 3cc0: 01104e5a 00000000 000003ff df084ece 00000000 de8b8=
abc 00000008 00000402
[  364.126749] 3ce0: 00000009 000018fa 00000011 0000000f 40c99047 13423=
7de 00000009 00000002
[  364.134943] 3d00: 00000002 00000011 0000000a 00000011 ffffffff 00000=
008 c07c6ea4 c04b58dc
[  364.143137] 3d20: c0fb1d20 ffffffff c1444664 dee693c0 00000000 de8b8=
a00 c1444d64 dee69840
[  364.151331] 3d40: 00000020 c07c6ea4 c0fb1d20 00000001 00001000 c04b8=
4fc 00000000 00000020
[  364.159525] 3d60: de8b8a00 c04bb814 dee69840 de8b8a00 deee0100 00000=
000 c07c6ea4 c04c01a8
[  364.167719] 3d80: dedb1300 de8b8abc 00000002 0000010f dedb1300 c044f=
ba4 dfa78000 dee69840
[  364.175912] 3da0: dee69a80 de8b8a00 00000000 c044ad44 0000000f 00001=
000 dedb1300 000001c8
[  364.184105] 3dc0: de8b8abc de8b8a00 00000000 c04ae7c4 de6372c8 ded1b=
190 de983e60 c009fb50
[  364.192298] 3de0: 000005a8 00000000 de8b8abc c0fb1d30 00000b50 00000=
bb8 00000001 de8b8a00
[  364.200492] 3e00: de61b600 00008000 0000b084 00000000 dfa4e17c 00008=
000 dfa4e1d8 c04d2ec4
[  364.208687] 3e20: 00008000 00000000 f6ffffe0 dfa68cc0 de6372c8 00000=
000 00008000 00004000
[  364.216881] 3e40: 00005000 c0446224 00008000 de9c8008 00001000 c054b=
9e4 00008000 de6372c8
[  364.225074] 3e60: de628550 de61b600 de9c8008 dfa4e000 dfa4e17c de61b=
600 de9d7828 00000000
[  364.233268] 3e80: dfab8000 00000018 000000d8 c054ba90 c0fcf700 00000=
000 022c0bfc 00000000
[  364.241461] 3ea0: 0fd00000 000081a4 00000001 00000000 00000000 00000=
000 83c00000 00000002
[  364.249654] 3ec0: 52b60226 17708c82 52b60213 3a02a584 52b60213 3a02a=
584 dfa4e000 de9d7800
[  364.257847] 3ee0: c079e1e0 de9d7828 00000000 c054bbbc 00000000 de9c8=
008 000000d8 80000180
[  364.266040] 3f00: dfa4e000 c05563a4 dfa4e000 c079e2d0 c079e1e0 de801=
b00 c079e1f8 c0548f30
[  364.274234] 3f20: de9d7800 dfab8018 de9d7824 01000000 de9d7800 dfa4e=
000 c080f758 de982000
[  364.282427] 3f40: c07bed78 00000000 00000000 00000000 00000000 c01a9=
5b0 00000000 00000000
[  364.290621] 3f60: df91c180 dfa4e000 c01a94fc c00328dc fff3bf2f 00000=
000 7ffffe6e dfa4e000
[  364.298815] 3f80: 00000000 de983f84 de983f84 00000000 de983f90 de983=
f90 de983fac df91c180
[  364.307007] 3fa0: c0032820 00000000 00000000 c000e298 00000000 00000=
000 00000000 00000000
[  364.315200] 3fc0: 00000000 00000000 00000000 00000000 00000000 00000=
000 00000000 00000000
[  364.323393] 3fe0: 00000000 00000000 00000000 00000000 00000013 00000=
000 7dfefef9 ff3f7ffe
[  364.331593] [<c04b7730>] (tcp_ack+0x5b4/0xccc) from [<c04b84fc>] (tc=
p_rcv_established+0x328/0x5c8)
[  364.340575] [<c04b84fc>] (tcp_rcv_established+0x328/0x5c8) from [<c0=
4c01a8>] (tcp_v4_do_rcv+0x104/0x240)
[  364.350078] [<c04c01a8>] (tcp_v4_do_rcv+0x104/0x240) from [<c044ad44=
>] (release_sock+0x70/0x114)
[  364.358883] [<c044ad44>] (release_sock+0x70/0x114) from [<c04ae7c4>]=
 (tcp_sendpage+0xe4/0x6c0)
[  364.367521] [<c04ae7c4>] (tcp_sendpage+0xe4/0x6c0) from [<c04d2ec4>]=
 (inet_sendpage+0x48/0x98)
[  364.376157] [<c04d2ec4>] (inet_sendpage+0x48/0x98) from [<c0446224>]=
 (kernel_sendpage+0x24/0x3c)
[  364.384963] [<c0446224>] (kernel_sendpage+0x24/0x3c) from [<c054b9e4=
>] (svc_send_common+0xb4/0x110)
[  364.394028] [<c054b9e4>] (svc_send_common+0xb4/0x110) from [<c054ba9=
0>] (svc_sendto+0x50/0x114)
[  364.402745] [<c054ba90>] (svc_sendto+0x50/0x114) from [<c054bbbc>] (=
svc_tcp_sendto+0x3c/0xb4)
[  364.411291] [<c054bbbc>] (svc_tcp_sendto+0x3c/0xb4) from [<c05563a4>=
] (svc_send+0x94/0xd8)
[  364.419572] [<c05563a4>] (svc_send+0x94/0xd8) from [<c0548f30>] (svc=
_process+0x1f0/0x698)
[  364.427768] [<c0548f30>] (svc_process+0x1f0/0x698) from [<c01a95b0>]=
 (nfsd+0xb4/0x118)
[  364.435708] [<c01a95b0>] (nfsd+0xb4/0x118) from [<c00328dc>] (kthrea=
d+0xbc/0xd8)
[  364.443126] [<c00328dc>] (kthread+0xbc/0xd8) from [<c000e298>] (ret_=
from_fork+0x14/0x3c)
[  364.451233] Code: e06c1001 e3510000 a3877c02 eaffffa1 (e1d330b4)=20
[  364.457354] ---[ end trace f8f26a44a0df5a62 ]---
[  364.461982] Kernel panic - not syncing: Fatal exception in interrupt



[  506.914947] rpc-srv/tcp: nfsd: sent only 24708 when sending 65668 by=
tes - shutting down socket
[  509.586732] Unable to handle kernel NULL pointer dereference at virt=
ual address 00000355
[  509.594847] pgd =3D c0004000
[  509.597558] [00000355] *pgd=3D00000000
[  509.601154] Internal error: Oops: 17 [#1] ARM
[  509.605516] Modules linked in:
[  509.608589] CPU: 0 PID: 3251 Comm: nfsd Not tainted 3.13.0-rc4.rn102=
-00256-gb7000adef17a-dirty #36
[  509.617562] task: df270580 ti: df1ce000 task.ti: df1ce000
[  509.622982] PC is at tcp_wfree+0x10/0xd0
[  509.626917] LR is at skb_release_head_state+0x78/0xdc
[  509.631978] pc : [<c04b9ff4>]    lr : [<c044d5ec>]    psr: 40000093
[  509.631978] sp : df1cfb80  ip : c001943c  fp : dfbb0a44
[  509.643474] r10: c0790b4c  r9 : def70cc0  r8 : df99bbe0
[  509.648708] r7 : 00000000  r6 : 0000000e  r5 : 0000000c  r4 : def70c=
c0
[  509.655245] r3 : 00000019  r2 : 00000101  r1 : 40000013  r0 : def70c=
c0
[  509.661784] Flags: nZcv  IRQs off  FIQs on  Mode SVC_32  ISA ARM  Se=
gment kernel
[  509.669191] Control: 10c5387d  Table: 1f204019  DAC: 00000015
[  509.674947] Process nfsd (pid: 3251, stack limit =3D 0xdf1ce238)
[  509.680788] Stack: (0xdf1cfb80 to 0xdf1d0000)
[  509.685156] fb80: def70cc0 c044d5ec def70cc0 c04505f0 def70cc0 c0450=
634 dfbc10dc c0389b9c
[  509.693351] fba0: 00000000 c0812940 000000dc df99bbe0 dfbc1000 00000=
00e dfbc10dc 00000020
[  509.701545] fbc0: c07b6624 c038b46c c07c6d08 00003c74 dfbb0a44 df99b=
800 00000020 0000000e
[  509.709739] fbe0: df99bbf8 00000005 dfbb0800 00000040 c078a048 00000=
12c c07c6d00 c038b168
[  509.717933] fc00: df99bbf8 00000040 00000129 c07c6d00 c07c6d08 c0792=
768 c07c6d00 c045a0bc
[  509.726126] fc20: 00000001 000051d9 c04a63f0 00000001 0000000c c07c7=
a50 c07c7a40 df1ce000
[  509.734319] fc40: 00000003 00000101 0000000c c001ec38 df99b800 df0bc=
0b8 00000010 0000000a
[  509.742512] fc60: 000051d8 00308040 df0bc0b8 60000013 def22c7c 00000=
00e 00000000 df0bc0b8
[  509.750705] fc80: df99b800 df19d380 00000010 c001edfc df1ce000 c001e=
f48 00000000 00000000
[  509.758898] fca0: def22c7c c04a65f0 80000000 0b50a8c0 00000000 df0bc=
0b8 defbc500 00000000
[  509.767091] fcc0: defbc704 df19d380 00000000 009c0000 00000000 c04a6=
9a0 df0bc0b8 c04a6ad0
[  509.775284] fce0: df0bc000 defbc500 df0bc000 00000020 00000000 00005=
1d7 00000020 defbc500
[  509.783477] fd00: df0bc0b8 c0792768 00000000 df19d380 00000000 c04bb=
2d4 a498e3f3 1347edb1
[  509.791670] fd20: df801780 00000000 00000002 00000000 00000000 00005=
1d7 0001a260 00000000
[  509.799864] fd40: defbc500 defbc500 df0bc000 000005a8 df0bc600 00001=
3b8 00000000 46561119
[  509.808057] fd60: 00000000 c04bb954 df1cfd9f 000000d0 df801780 00006=
5d0 000043e0 c044fa94
[  509.816250] fd80: c078dc94 defbc5bc 00000002 00000000 00000017 df0bc=
000 df0bca80 defbc500
[  509.824443] fda0: df0bc000 00001000 defbc5bc defbc500 c0f49140 00000=
000 00001000 c04bc2c4
[  509.832638] fdc0: 00000020 00000000 00001000 c04aed28 dc433758 df157=
010 df1cfe60 c009fb50
[  509.840832] fde0: 000005a8 00000000 defbc5bc c0f49150 000065d0 00000=
bb8 00000000 defbc500
[  509.849025] fe00: df760c00 00008000 0000b084 00000000 df32417c 00008=
000 df3241d8 c04d2ed4
[  509.857218] fe20: 00008000 00000000 f6ffffe0 def72d80 dc433758 00000=
000 00008000 00004000
[  509.865412] fe40: 00005000 c0446224 00008000 df327008 00001000 c054b=
9f4 00008000 dc433758
[  509.873605] fe60: dc41dc38 df760c00 df327008 df324000 df32417c df760=
c00 df2a5028 00000000
[  509.881798] fe80: db8fa000 00000018 000000d8 c054baa0 c0f4bf40 00000=
000 017c0015 00000000
[  509.889991] fea0: 0fd00002 000081b4 00000001 000003e8 00000064 00000=
000 571b1954 00000001
[  509.898184] fec0: 52cf265e 3927740a 52ab1330 15f5fe64 52c835e1 293e4=
5a6 df324000 df2a5000
[  509.906378] fee0: c079e1e0 df2a5028 00000000 c054bbcc 00000000 df327=
008 000000d8 80000180
[  509.914573] ff00: df324000 c05563b4 df324000 c079e2d0 c079e1e0 df1eb=
280 c079e1f8 c0548f40
[  509.922767] ff20: 000000a0 db8fa018 df2a5024 01000000 df2a5000 df324=
000 c080f758 df1ce000
[  509.930960] ff40: c07bed78 00000000 00000000 00000000 00000000 c01a9=
5b0 00000000 00000000
[  509.939154] ff60: decff4c0 df324000 c01a94fc c00328dc 00000000 00000=
000 b6f12774 df324000
[  509.947348] ff80: 00000000 df1cff84 df1cff84 00000000 df1cff90 df1cf=
f90 df1cffac decff4c0
[  509.955541] ffa0: c0032820 00000000 00000000 c000e298 00000000 00000=
000 00000000 00000000
[  509.963735] ffc0: 00000000 00000000 00000000 00000000 00000000 00000=
000 00000000 00000000
[  509.971929] ffe0: 00000000 00000000 00000000 00000000 00000013 00000=
000 00000000 00000000
[  509.980129] [<c04b9ff4>] (tcp_wfree+0x10/0xd0) from [<c044d5ec>] (sk=
b_release_head_state+0x78/0xdc)
[  509.989197] [<c044d5ec>] (skb_release_head_state+0x78/0xdc) from [<c=
04505f0>] (skb_release_all+0xc/0x24)
[  509.998697] [<c04505f0>] (skb_release_all+0xc/0x24) from [<c0450634>=
] (__kfree_skb+0xc/0xb4)
[  510.007160] [<c0450634>] (__kfree_skb+0xc/0xb4) from [<c0389b9c>] (m=
vneta_txq_bufs_free+0x54/0xbc)
[  510.016140] [<c0389b9c>] (mvneta_txq_bufs_free+0x54/0xbc) from [<c03=
8b46c>] (mvneta_poll+0x304/0x3d4)
[  510.025382] [<c038b46c>] (mvneta_poll+0x304/0x3d4) from [<c045a0bc>]=
 (net_rx_action+0x98/0x180)
[  510.034103] [<c045a0bc>] (net_rx_action+0x98/0x180) from [<c001ec38>=
] (__do_softirq+0xc8/0x1f4)
[  510.042820] [<c001ec38>] (__do_softirq+0xc8/0x1f4) from [<c001edfc>]=
 (do_softirq+0x4c/0x58)
[  510.051189] [<c001edfc>] (do_softirq+0x4c/0x58) from [<c001ef48>] (l=
ocal_bh_enable+0x98/0xa8)
[  510.059741] [<c001ef48>] (local_bh_enable+0x98/0xa8) from [<c04a65f0=
>] (ip_finish_output+0x200/0x3d4)
[  510.068980] [<c04a65f0>] (ip_finish_output+0x200/0x3d4) from [<c04a6=
9a0>] (ip_local_out+0x28/0x2c)
[  510.077959] [<c04a69a0>] (ip_local_out+0x28/0x2c) from [<c04a6ad0>] =
(ip_queue_xmit+0x12c/0x364)
[  510.086677] [<c04a6ad0>] (ip_queue_xmit+0x12c/0x364) from [<c04bb2d4=
>] (tcp_transmit_skb+0x42c/0x86c)
[  510.095916] [<c04bb2d4>] (tcp_transmit_skb+0x42c/0x86c) from [<c04bb=
954>] (tcp_write_xmit+0x174/0xa74)
[  510.105242] [<c04bb954>] (tcp_write_xmit+0x174/0xa74) from [<c04bc2c=
4>] (__tcp_push_pending_frames+0x30/0x98)
[  510.115177] [<c04bc2c4>] (__tcp_push_pending_frames+0x30/0x98) from =
[<c04aed28>] (tcp_sendpage+0x648/0x6c0)
[  510.124947] [<c04aed28>] (tcp_sendpage+0x648/0x6c0) from [<c04d2ed4>=
] (inet_sendpage+0x48/0x98)
[  510.133671] [<c04d2ed4>] (inet_sendpage+0x48/0x98) from [<c0446224>]=
 (kernel_sendpage+0x24/0x3c)
[  510.142478] [<c0446224>] (kernel_sendpage+0x24/0x3c) from [<c054b9f4=
>] (svc_send_common+0xb4/0x110)
[  510.151544] [<c054b9f4>] (svc_send_common+0xb4/0x110) from [<c054baa=
0>] (svc_sendto+0x50/0x114)
[  510.160259] [<c054baa0>] (svc_sendto+0x50/0x114) from [<c054bbcc>] (=
svc_tcp_sendto+0x3c/0xb4)
[  510.168805] [<c054bbcc>] (svc_tcp_sendto+0x3c/0xb4) from [<c05563b4>=
] (svc_send+0x94/0xd8)
[  510.177086] [<c05563b4>] (svc_send+0x94/0xd8) from [<c0548f40>] (svc=
_process+0x1f0/0x698)
[  510.185281] [<c0548f40>] (svc_process+0x1f0/0x698) from [<c01a95b0>]=
 (nfsd+0xb4/0x118)
[  510.193220] [<c01a95b0>] (nfsd+0xb4/0x118) from [<c00328dc>] (kthrea=
d+0xbc/0xd8)
[  510.200638] [<c00328dc>] (kthread+0xbc/0xd8) from [<c000e298>] (ret_=
from_fork+0x14/0x3c)
[  510.208745] Code: e92d4010 e5903010 e10f1000 f10c0080 (e593233c)=20
[  510.214850] ---[ end trace 1b9a0384d0751058 ]---
[  510.219474] Kernel panic - not syncing: Fatal exception in interrupt



[ 1583.653300] rpc-srv/tcp: nfsd: sent only 36996 when sending 65668 by=
tes - shutting down socket
[ 1823.328992] rpc-srv/tcp: nfsd: sent only 36996 when sending 65668 by=
tes - shutting down socket
[ 1973.752840] rpc-srv/tcp: nfsd: sent only 57476 when sending 65668 by=
tes - shutting down socket
[ 2003.384672] rpc-srv/tcp: nfsd: sent only 36996 when sending 65668 by=
tes - shutting down socket
[ 2049.981672] rpc-srv/tcp: nfsd: sent only 41092 when sending 65668 by=
tes - shutting down socket
[ 2080.879621] rpc-srv/tcp: nfsd: sent only 45188 when sending 65668 by=
tes - shutting down socket
[ 2214.520542] rpc-srv/tcp: nfsd: sent only 20612 when sending 65668 by=
tes - shutting down socket
[ 2271.696256] ------------[ cut here ]------------
[ 2271.700897] kernel BUG at net/core/skbuff.c:1298!
[ 2271.705609] Internal error: Oops - BUG: 0 [#1] ARM
[ 2271.710406] Modules linked in:
[ 2271.713480] CPU: 0 PID: 2834 Comm: nfsd Not tainted 3.13.0-rc7.rn102=
-00126-g228fdc083b01-dirty #42
[ 2271.722456] task: dec2e2c0 ti: dfad2000 task.ti: dfad2000
[ 2271.727871] PC is at skb_put+0x40/0x50
[ 2271.731632] LR is at mvneta_rx+0x13c/0x3e4
[ 2271.735737] pc : [<c044f6f0>]    lr : [<c038afb8>]    psr: 200f0113
[ 2271.735737] sp : dfad39b0  ip : dfa6f4d2  fp : 00000000
[ 2271.747233] r10: 6750b026  r9 : dec12400  r8 : e14b0000
[ 2271.752465] r7 : 00000001  r6 : dedd9cc0  r5 : 000005a8  r4 : 000000=
29
[ 2271.759004] r3 : dfa6f4d2  r2 : c038afb8  r1 : 00000042  r0 : dedd9c=
c0
[ 2271.765541] Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Seg=
ment kernel
[ 2271.772862] Control: 10c5387d  Table: 1fbe0019  DAC: 00000015
[ 2271.778616] Process nfsd (pid: 2834, stack limit =3D 0xdfad2238)
[ 2271.784458] Stack: (0xdfad39b0 to 0xdfad4000)
[ 2271.788824] 39a0:                                     dfa6f4d2 00000=
029 e14b0520 dedd9cc0
[ 2271.797018] 39c0: 00000001 c038afb8 00000000 deef7c80 6750b026 00000=
000 6750afe4 00000000
[ 2271.805211] 39e0: 00000000 df1ffbe0 df1ff800 00000000 01627a2a 00000=
000 00000001 00000003
[ 2271.813405] 3a00: 00001000 00000040 00000100 00000000 00000000 dec12=
400 c07a61ac df1ff800
[ 2271.821599] 3a20: df1ffbe0 c038b2d8 dfad3a58 df1ffc14 dfad3a54 c038b=
260 df1ffc14 00000040
[ 2271.829792] 3a40: 0000012c c07b6680 c07b6688 c07822e8 c07b6680 c045a=
284 00000020 0003022b
[ 2271.837986] 3a60: ded13700 00000001 0000000c c07b7450 c07b7440 dfad2=
000 00000003 00000100
[ 2271.846179] 3a80: 0000000c c001ec38 c032aff4 ded13700 dedf4540 00000=
00a 0003022a 00308040
[ 2271.854373] 3aa0: 000003ff c0794ea0 00000018 00000000 000003ff c0802=
340 c077a048 0000ffff
[ 2271.862567] 3ac0: df45beec c001f020 c0794ea0 c000eaa4 c032c34c c0802=
340 dfad3b08 c00084dc
[ 2271.870761] 3ae0: c0291eec c032c34c 600f0013 ffffffff dfad3b3c dec6c=
024 dedf4540 dec6c0c0
[ 2271.878954] 3b00: df45beec c0011100 00030e08 00000000 00000001 00000=
000 dec6c000 df32e5b0
[ 2271.887148] 3b20: ded13700 df25d800 dec6c024 dedf4540 dec6c0c0 df45b=
eec 00030e45 dfad3b50
[ 2271.895343] 3b40: c0291eec c032c34c 600f0013 ffffffff ded13700 dec5a=
800 c07822e8 df32e5b0
[ 2271.903536] 3b60: 00000000 00000000 00000000 ded13700 ded13700 df32e=
5b0 df45beec c028aac0
[ 2271.911730] 3b80: ded13700 c028a414 00000000 00001800 00000000 dfad3=
ba8 00000000 600f0013
[ 2271.919923] 3ba0: df32e5b0 c028db48 dfad3ba8 dfad3ba8 dfad3bb0 dfad3=
bb0 dfad3bfc 00000020
[ 2271.928117] 3bc0: 00000020 0044d2fc 009c3fff 0044d31b df45bef0 c028d=
bb4 c011451c c0060ef0
[ 2271.936311] 3be0: dfad3bf4 00000020 00000000 ded08c00 00000012 dfad3=
bf4 dfad3bf4 91827364
[ 2271.944504] 3c00: dfad3c00 dfad3c00 dfad3c08 dfad3c08 dfad3c10 dfad3=
c10 ded08c00 0000000c
[ 2271.952698] 3c20: 0000000c c0f36120 00001000 0044d2dc df45beec 00004=
000 00000000 c006122c
[ 2271.960892] 3c40: 00000020 df45beec 00004000 c00ad640 0044d2dc 00000=
004 c077a108 00000010
[ 2271.969085] 3c60: 00000030 ded08c00 00000000 00000010 ded08c48 dfbc7=
680 00000000 dfad3c98
[ 2271.977278] 3c80: dfad3cd8 0000000c 00000010 00000000 c0568938 c00ac=
084 c0f12700 c0f0df40
[ 2271.985472] 3ca0: c0f018a0 c0f252e0 c0ee2820 c0efaf20 c0bf7da0 c0ef2=
f40 c0f3ede0 c0bd20e0
[ 2271.993666] 3cc0: c0f39780 c0f2ffe0 c0f36120 c0f20060 c0efb020 c0c12=
b00 00000000 00001000
[ 2272.001859] 3ce0: df967a80 00000000 00001000 dfaaddf8 00000000 00001=
000 c0fc9060 00000000
[ 2272.010053] 3d00: 00001000 dfad2000 00000000 00001000 dfab7000 00000=
000 00001000 00000004
[ 2272.018246] 3d20: 00000000 00001000 dfbd1280 00000000 00001000 dfaad=
df8 00000000 00001000
[ 2272.026440] 3d40: 00000980 00000000 00001000 34b96753 00000000 00001=
000 dfbd1280 00000000
[ 2272.034633] 3d60: 00001000 df92efd0 52d1b773 34b96753 0000000d dfbd1=
280 df1b2840 df967a80
[ 2272.042827] 3d80: dfbd1280 df1b2840 dfbd10c0 c01b14a8 00000008 df970=
c00 00000be4 00010000
[ 2272.051021] 3da0: 00000000 76d30000 00000005 dfad3e20 c07ff10c ded08=
c00 00010000 c00ad85c
[ 2272.059214] 3dc0: 00000000 5160cdfe ded08c00 ded08c00 dfad3e20 00010=
000 dfbc7680 00000000
[ 2272.067408] 3de0: ded08c00 c00ac2c0 00000000 dfaaf008 00000001 4d2d0=
000 00000004 dfad3e60
[ 2272.075601] 3e00: dfbc7680 c00ac55c 00000000 00000420 dfaaf008 00000=
110 00000000 c01acb0c
[ 2272.083795] 3e20: 4d2d0000 00000004 ffffffff ded08c00 dfaad1ac dfaaf=
118 dfaad000 df94cca8
[ 2272.091989] 3e40: c07ff10c df94cc98 000000d8 c01acf60 000000d8 c0088=
e64 4d2d0000 00000004
[ 2272.100182] 3e60: 00000000 00010000 00000000 dfaad000 4d2d0000 00000=
004 00000000 00000000
[ 2272.108375] 3e80: 00000000 00000000 4d2d0000 00000004 df94cc80 dfaad=
000 df94cca8 c01adc70
[ 2272.116569] 3ea0: dfaad5b8 00000010 dfaaf118 df916880 00000001 ded08=
c00 4d2d0000 00000004
[ 2272.124763] 3ec0: dfaae000 dfaad000 dfaaf000 dfaaf008 00000110 c01b5=
5d4 dfaad5b8 00000010
[ 2272.132956] 3ee0: dfaaf118 dfaad000 dfaad000 c078de58 ddaa9018 00000=
01c ddaa9000 ddaa9000
[ 2272.141150] 3f00: 00000018 c01a9b08 dfaad000 c078de58 c078dd68 ded7f=
400 c078dd80 c053c74c
[ 2272.149344] 3f20: 0000007c ddaa9018 dfb2e824 01000000 dfb2e800 dfaad=
000 c07ff158 dfad2000
[ 2272.157537] 3f40: c07ae900 00000000 00000000 00000000 00000000 c01a9=
5f4 00000000 00000000
[ 2272.165731] 3f60: df0ef100 dfaad000 c01a9540 c00328dc f8d833ff 00000=
000 94019502 dfaad000
[ 2272.173925] 3f80: 00000000 dfad3f84 dfad3f84 00000000 dfad3f90 dfad3=
f90 dfad3fac df0ef100
[ 2272.182118] 3fa0: c0032820 00000000 00000000 c000e298 00000000 00000=
000 00000000 00000000
[ 2272.190311] 3fc0: 00000000 00000000 00000000 00000000 00000000 00000=
000 00000000 00000000
[ 2272.198504] 3fe0: 00000000 00000000 00000000 00000000 00000013 00000=
000 f7f52314 4604fc6b
[ 2272.206705] [<c044f6f0>] (skb_put+0x40/0x50) from [<c038afb8>] (mvne=
ta_rx+0x13c/0x3e4)
[ 2272.214641] [<c038afb8>] (mvneta_rx+0x13c/0x3e4) from [<c038b2d8>] (=
mvneta_poll+0x78/0x16c)
[ 2272.223012] [<c038b2d8>] (mvneta_poll+0x78/0x16c) from [<c045a284>] =
(net_rx_action+0x98/0x180)
[ 2272.231646] [<c045a284>] (net_rx_action+0x98/0x180) from [<c001ec38>=
] (__do_softirq+0xc8/0x1f4)
[ 2272.240364] [<c001ec38>] (__do_softirq+0xc8/0x1f4) from [<c001f020>]=
 (irq_exit+0x6c/0xa8)
[ 2272.248563] [<c001f020>] (irq_exit+0x6c/0xa8) from [<c000eaa4>] (han=
dle_IRQ+0x34/0x84)
[ 2272.256497] [<c000eaa4>] (handle_IRQ+0x34/0x84) from [<c00084dc>] (a=
rmada_370_xp_handle_irq+0x4c/0xbc)
[ 2272.265826] [<c00084dc>] (armada_370_xp_handle_irq+0x4c/0xbc) from [=
<c0011100>] (__irq_svc+0x40/0x50)
[ 2272.275059] Exception stack(0xdfad3b08 to 0xdfad3b50)
[ 2272.280121] 3b00:                   00030e08 00000000 00000001 00000=
000 dec6c000 df32e5b0
[ 2272.288315] 3b20: ded13700 df25d800 dec6c024 dedf4540 dec6c0c0 df45b=
eec 00030e45 dfad3b50
[ 2272.296506] 3b40: c0291eec c032c34c 600f0013 ffffffff
[ 2272.301573] [<c0011100>] (__irq_svc+0x40/0x50) from [<c032c34c>] (sc=
si_request_fn+0x2ac/0x460)
[ 2272.310209] [<c032c34c>] (scsi_request_fn+0x2ac/0x460) from [<c028aa=
c0>] (__blk_run_queue+0x34/0x44)
[ 2272.319363] [<c028aac0>] (__blk_run_queue+0x34/0x44) from [<c028a414=
>] (__elv_add_request+0x154/0x268)
[ 2272.328690] [<c028a414>] (__elv_add_request+0x154/0x268) from [<c028=
db48>] (blk_flush_plug_list+0x1c0/0x21c)
[ 2272.338536] [<c028db48>] (blk_flush_plug_list+0x1c0/0x21c) from [<c0=
28dbb4>] (blk_finish_plug+0x10/0x34)
[ 2272.348042] [<c028dbb4>] (blk_finish_plug+0x10/0x34) from [<c0060ef0=
>] (__do_page_cache_readahead+0x194/0x260)
[ 2272.358065] [<c0060ef0>] (__do_page_cache_readahead+0x194/0x260) fro=
m [<c006122c>] (ra_submit+0x28/0x30)
[ 2272.367567] [<c006122c>] (ra_submit+0x28/0x30) from [<c00ad640>] (__=
generic_file_splice_read+0x2d0/0x498)
[ 2272.377154] [<c00ad640>] (__generic_file_splice_read+0x2d0/0x498) fr=
om [<c00ad85c>] (generic_file_splice_read+0x54/0x98)
[ 2272.388045] [<c00ad85c>] (generic_file_splice_read+0x54/0x98) from [=
<c00ac2c0>] (do_splice_to+0x6c/0x80)
[ 2272.397544] [<c00ac2c0>] (do_splice_to+0x6c/0x80) from [<c00ac55c>] =
(splice_direct_to_actor+0xa0/0x1c0)
[ 2272.406959] [<c00ac55c>] (splice_direct_to_actor+0xa0/0x1c0) from [<=
c01acf60>] (nfsd_vfs_read.isra.11+0xf8/0x148)
[ 2272.417243] [<c01acf60>] (nfsd_vfs_read.isra.11+0xf8/0x148) from [<c=
01adc70>] (nfsd_read+0x1dc/0x260)
[ 2272.426487] [<c01adc70>] (nfsd_read+0x1dc/0x260) from [<c01b55d4>] (=
nfsd3_proc_read+0xb4/0x10c)
[ 2272.435204] [<c01b55d4>] (nfsd3_proc_read+0xb4/0x10c) from [<c01a9b0=
8>] (nfsd_dispatch+0x74/0x168)
[ 2272.444183] [<c01a9b08>] (nfsd_dispatch+0x74/0x168) from [<c053c74c>=
] (svc_process+0x494/0x698)
[ 2272.452900] [<c053c74c>] (svc_process+0x494/0x698) from [<c01a95f4>]=
 (nfsd+0xb4/0x118)
[ 2272.460838] [<c01a95f4>] (nfsd+0xb4/0x118) from [<c00328dc>] (kthrea=
d+0xbc/0xd8)
[ 2272.468251] [<c00328dc>] (kthread+0xbc/0xd8) from [<c000e298>] (ret_=
from_fork+0x14/0x3c)
[ 2272.476357] Code: e5804050 8a000002 e1a0000c e8bd80f8 (e7f001f2)=20
[ 2272.482465] ---[ end trace e2211467fd4feba0 ]---
[ 2272.487090] Kernel panic - not syncing: Fatal exception in interrupt

After 100GB copied on  3.13.0-rc7.rn102-00126-g228fdc083b01-dirty w/
NET_SCHED and NF_TABLES desactiv=C3=A9s. The line above is
SKB_LINEAR_ASSERT test.

/**
 *	skb_put - add data to a buffer
 *	@skb: buffer to use
 *	@len: amount of data to add
 *
 *	This function extends the used data area of the buffer. If this woul=
d
 *	exceed the total buffer size the kernel will panic. A pointer to the
 *	first byte of the extra data is returned.
 */
unsigned char *skb_put(struct sk_buff *skb, unsigned int len)
{
	unsigned char *tmp =3D skb_tail_pointer(skb);
	SKB_LINEAR_ASSERT(skb);
	skb->tail +=3D len;
	skb->len  +=3D len;
	if (unlikely(skb->tail > skb->end))
		skb_over_panic(skb, len, __builtin_return_address(0));
	return tmp;
}
EXPORT_SYMBOL(skb_put);



On the same kernel:

[ 1075.021397] rpc-srv/tcp: nfsd: sent only 28804 when sending 65668 by=
tes - shutting down socket
[ 1088.620719] ------------[ cut here ]------------
[ 1088.625378] WARNING: CPU: 0 PID: 372 at net/ipv4/tcp_input.c:1821 tc=
p_sacktag_write_queue+0xab4/0xb48()
[ 1088.635225] ---[ end trace c836ddfbecd551ad ]---
[ 1088.639847] ------------[ cut here ]------------
[ 1088.644483] WARNING: CPU: 0 PID: 372 at net/ipv4/tcp_input.c:1822 tc=
p_sacktag_write_queue+0xac4/0xb48()
[ 1088.654247] ---[ end trace c836ddfbecd551ae ]---
[ 1088.658870] ------------[ cut here ]------------
[ 1088.663505] WARNING: CPU: 0 PID: 372 at net/ipv4/tcp_input.c:1823 tc=
p_sacktag_write_queue+0xad8/0xb48()
[ 1088.673270] ---[ end trace c836ddfbecd551af ]---
[ 1088.677893] ------------[ cut here ]------------
[ 1088.682526] WARNING: CPU: 0 PID: 372 at net/ipv4/tcp_input.c:3170 tc=
p_ack+0xbb0/0xccc()
[ 1088.690888] ---[ end trace c836ddfbecd551b0 ]---
[ 1088.695510] ------------[ cut here ]------------
[ 1088.700143] WARNING: CPU: 0 PID: 372 at net/ipv4/tcp_input.c:3171 tc=
p_ack+0xba0/0xccc()
[ 1088.708501] ---[ end trace c836ddfbecd551b1 ]---
[ 1088.713130] ------------[ cut here ]------------
[ 1088.717760] WARNING: CPU: 0 PID: 372 at net/ipv4/tcp_input.c:2251 tc=
p_fastretrans_alert+0x634/0x92c()
[ 1088.727353] ---[ end trace c836ddfbecd551b2 ]---
[ 1088.731985] ------------[ cut here ]------------
[ 1088.736616] WARNING: CPU: 0 PID: 372 at net/ipv4/tcp_output.c:1048 _=
_tcp_retransmit_skb+0x4b0/0x4c8()
[ 1088.746232] ---[ end trace c836ddfbecd551b3 ]---
[ 1088.750914] Unable to handle kernel NULL pointer dereference at virt=
ual address 00000050
[ 1088.759019] pgd =3D c0004000
[ 1088.761736] [00000050] *pgd=3D00000000
[ 1088.765330] Internal error: Oops: 17 [#1] ARM
[ 1088.769693] Modules linked in:
[ 1088.772764] CPU: 0 PID: 372 Comm: kswapd0 Tainted: G        W    3.1=
3.0-rc7.rn102-00126-g228fdc083b01-dirty #42
[ 1088.782868] task: df88d080 ti: df91e000 task.ti: df91e000
[ 1088.788281] PC is at skb_segment+0x1dc/0x788
[ 1088.792557] LR is at 0x0
[ 1088.795096] pc : [<c0451a38>]    lr : [<00000000>]    psr: 60000113
[ 1088.795096] sp : df91f7c8  ip : 000005a8  fp : 00000000
[ 1088.806592] r10: 00000000  r9 : 00000042  r8 : 00000001
[ 1088.811825] r7 : 00000000  r6 : 00004803  r5 : df2f2b6c  r4 : 000000=
00
[ 1088.818362] r3 : 00000000  r2 : 00000042  r1 : 0000008e  r0 : 00000b=
50
[ 1088.824900] Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Seg=
ment kernel
[ 1088.832222] Control: 10c5387d  Table: 1e72c019  DAC: 00000015
[ 1088.837976] Process kswapd0 (pid: 372, stack limit =3D 0xdf91e238)
[ 1088.843991] Stack: (0xdf91f7c8 to 0xdf920000)
[ 1088.848358] f7c0:                   fff3551f c07ae900 00000003 df124=
2a0 00000042 000005a8
[ 1088.856552] f7e0: df1ce3b0 00000000 000005a8 00000042 0000008e 00000=
000 00000001 00000000
[ 1088.864746] f800: 000000d0 000005a8 00000000 00000042 00000001 fffff=
fbe 00000000 df1ce3b0
[ 1088.872940] f820: 00000020 00000b70 00000000 00004803 00000002 00010=
000 c04add00 c04b96c8
[ 1088.881134] f840: c077a00c 000005a8 00000003 df1242a0 c077b230 00000=
b50 00000006 df1ce3b0
[ 1088.889327] f860: 0000aad8 00000014 0000009c 00000000 00000014 c04c6=
3dc c0fca9f8 df01b180
[ 1088.897520] f880: 0000008e 00000000 00000001 00004803 00000002 df1ce=
3b0 c077d9cc df1ce3b0
[ 1088.905713] f8a0: dfbb0874 df99b800 c05a50d8 c045bd8c 00000004 c077d=
9e0 00004803 00004803
[ 1088.913906] f8c0: 00000002 00010000 00000000 df1ce3b0 dfbb0874 c045c=
0a8 00000001 c04784c4
[ 1088.922099] f8e0: c049a110 df99b800 00000000 00000000 00000000 df270=
800 df99b800 df1ce3b0
[ 1088.930293] f900: df1ce3b0 dfbb0874 00000010 c0472420 df270800 00000=
000 00000042 00000000
[ 1088.938488] f920: dfbb0874 df1ce3b0 df99b800 c045c568 df270860 010d5=
3b9 00000000 de7a3cc0
[ 1088.946682] f940: de7a3d3c 0000000e 00000000 df1ce3b0 df99b800 df331=
c00 00000010 c049a2f0
[ 1088.954876] f960: 80000000 0b50a8c0 00000000 df1ce3b0 de738a00 00000=
000 de738c04 df331c00
[ 1088.963070] f980: 00000000 009c0000 00000000 c049a6c0 df1ce3b0 c049a=
7f0 df1ce300 de738a00
[ 1088.971265] f9a0: df1ce300 00000020 00000000 00013414 00000020 de738=
a00 df1ce3b0 c07822e8
[ 1088.979459] f9c0: 00000000 df331c00 00000000 c04aeff0 b0fd5e2e 13486=
e32 df801780 00000000
[ 1088.987653] f9e0: 00000002 00000000 00000000 00013414 00b89672 00000=
000 de738a00 de738a00
[ 1088.995846] fa00: df1ce300 000005a8 df10ad80 000032e8 00000000 f0827=
650 00000000 c04af670
[ 1089.004039] fa20: c0f89600 1f1e9180 df1e9180 de7e8e64 08e47f46 c0086=
880 de738a00 de738abc
[ 1089.012234] fa40: 00000001 de7e8e64 de7e8e50 c04a9608 df1e9180 de738=
a00 de7e8e64 df1e9180
[ 1089.020427] fa60: de738a00 de7e8e50 df1e9180 0000d703 c077a618 c04af=
fe0 00000020 de738a00
[ 1089.028620] fa80: de738a00 c04ac044 00000001 00000002 00000000 df91f=
b04 df1e9180 de738a00
[ 1089.036814] faa0: de73f700 de738a00 de7e8e50 c04b3ed4 c04958b0 c0478=
4c4 c04958b0 c04784c4
[ 1089.045008] fac0: df021e00 c077ab64 df1e9180 df1e9180 c07ae900 00000=
000 de738a00 c04b65d4
[ 1089.053203] fae0: df99b800 c0478544 00000000 df91fb04 c04958b0 80000=
000 c04955c8 c077ab64
[ 1089.061396] fb00: 2550a8c0 c077ab64 2550a8c0 c05af8f4 c077d470 00000=
000 c07ae900 df1e9180
[ 1089.069590] fb20: df1e9180 00000000 c077a618 c0495944 de7e8e50 c077d=
9e8 c077a628 df99b800
[ 1089.077785] fb40: df1e9180 c04956f0 df163400 c077a614 c077a614 c077d=
9e8 c077a628 df99b800
[ 1089.085979] fb60: 00000008 c0458074 00000003 00000000 00000002 e145e=
000 dfbc1400 df1e9180
[ 1089.094173] fb80: 00000000 c077a628 00000000 df1e9180 00000003 df1e9=
180 00000002 e145e000
[ 1089.102367] fba0: dfbc1400 df99bbe0 00000000 c045a538 00000004 00000=
007 e145e0e0 c038b000
[ 1089.110561] fbc0: 00000000 00000000 3584bb1e 00000000 3584bac0 00000=
000 df99b800 df99bbe0
[ 1089.118755] fbe0: df99b800 00000001 00b26d08 00000000 00000002 00000=
005 00000000 00000040
[ 1089.126950] fc00: 00000100 00000000 00000000 dfbc1400 c07a61ac df99b=
800 df99bbe0 c038b2d8
[ 1089.135144] fc20: 00000004 df99bc14 df99bc14 c038b260 df99bc14 00000=
040 0000012c c07b6680
[ 1089.143337] fc40: c07b6688 c07822e8 c07b6680 c045a284 00000002 00013=
409 0000000c 00000001
[ 1089.151531] fc60: 0000000c c07b7450 c07b7440 df91e000 00000003 00000=
100 0000000c c001ec38
[ 1089.159725] fc80: 00000004 0000000a 00013408 0000000a 00013408 00a48=
840 000003ff c0794ea0
[ 1089.167919] fca0: 00000018 00000000 000003ff c0802340 c077a048 0000f=
fff 00000001 c001f020
[ 1089.176113] fcc0: c0794ea0 c000eaa4 c006443c c0802340 df91fd00 c0008=
4dc c0064430 c006443c
[ 1089.184308] fce0: a0000013 ffffffff df91fd34 df91fd80 00000000 df79d=
13c 00000001 c0011100
[ 1089.192502] fd00: df79d13c 00020209 00020209 000200da c0e2e960 df91f=
f18 c0e2e960 df91fe18
[ 1089.200696] fd20: df91fd80 00000000 df79d13c 00000001 0000001a df91f=
d48 c0064430 c006443c
[ 1089.208890] fd40: a0000013 ffffffff c0e2e974 c00649ac c0802340 00000=
000 00000000 00000000
[ 1089.217084] fd60: 00000000 00000000 00000000 0000001a c07b5680 00000=
000 0000fdc4 00000000
[ 1089.225277] fd80: df91fd80 df91fd80 c0c1b354 c0de3f14 00000000 00ba0=
021 00000011 00ba003d
[ 1089.233470] fda0: c07fb6d0 c0dcd374 c07b5840 c00640e4 df91fe00 c07fb=
6d0 c07b58cc 00000020
[ 1089.241665] fdc0: c07b5830 c07b5680 df91fe18 df91e000 df91ff18 c0065=
8a0 df91fe04 df91fe0c
[ 1089.249858] fde0: df91fe08 df91fe10 df91fe14 00000000 c07839a8 c0784=
3c0 ffffffe0 00000001
[ 1089.258052] fe00: 00000020 00000000 00000000 00000000 00000000 00000=
000 c0dcd374 c0e994f4
[ 1089.266246] fe20: 00002fdf 00000002 df91fe64 00000000 00000000 df91f=
f18 df91e000 51eb851f
[ 1089.274440] fe40: c07b5830 c0065dcc c003a8e8 00000430 00000000 00000=
000 00000000 00000000
[ 1089.282634] fe60: 00000051 00000003 00000000 00000000 00000000 00000=
071 00000003 00000000
[ 1089.290828] fe80: 91827364 df91fe84 df91fe84 df91fe8c df91fe8c df91f=
e94 df91fe94 00000000
[ 1089.299021] fea0: 00000000 00000000 c07b5680 00000000 0000028c 00000=
000 00000000 c07b5680
[ 1089.307215] fec0: c07fc058 c0066420 00000000 00000000 df84c030 00000=
000 00000000 df91ff04
[ 1089.315409] fee0: 00000001 df91e000 00000000 51eb851f df91ff18 0001d=
f7d c07b5bdc 00000000
[ 1089.323603] ff00: c000951c 00000000 000000d0 00000000 00000000 00000=
000 0000001b 00000000
[ 1089.331797] ff20: 00000430 00000000 000000d0 00000001 00000001 00000=
001 00000000 0000000a
[ 1089.339991] ff40: 00000000 00000000 df88d080 00000000 df92d000 c07b5=
680 c0065fb8 00000000
[ 1089.348185] ff60: 00000000 00000000 00000000 c00328dc ffffffff 00000=
000 ffffffff c07b5680
[ 1089.356379] ff80: 00000000 df91ff84 df91ff84 00000000 df91ff90 df91f=
f90 df91ffac df92d000
[ 1089.364573] ffa0: c0032820 00000000 00000000 c000e298 00000000 00000=
000 00000000 00000000
[ 1089.372766] ffc0: 00000000 00000000 00000000 00000000 00000000 00000=
000 00000000 00000000
[ 1089.380959] ffe0: 00000000 00000000 00000000 00000000 00000013 00000=
000 fcc7b5ff dfffebbd
[ 1089.389159] [<c0451a38>] (skb_segment+0x1dc/0x788) from [<c04b96c8>]=
 (tcp_gso_segment+0xe4/0x390)
[ 1089.398051] [<c04b96c8>] (tcp_gso_segment+0xe4/0x390) from [<c04c63d=
c>] (inet_gso_segment+0x118/0x2dc)
[ 1089.407380] [<c04c63dc>] (inet_gso_segment+0x118/0x2dc) from [<c045b=
d8c>] (skb_mac_gso_segment+0xa4/0x178)
[ 1089.417055] [<c045bd8c>] (skb_mac_gso_segment+0xa4/0x178) from [<c04=
5c0a8>] (dev_hard_start_xmit+0x170/0x484)
[ 1089.426991] [<c045c0a8>] (dev_hard_start_xmit+0x170/0x484) from [<c0=
472420>] (sch_direct_xmit+0xa4/0x19c)
[ 1089.436577] [<c0472420>] (sch_direct_xmit+0xa4/0x19c) from [<c045c56=
8>] (__dev_queue_xmit+0x1ac/0x3b4)
[ 1089.445903] [<c045c568>] (__dev_queue_xmit+0x1ac/0x3b4) from [<c049a=
2f0>] (ip_finish_output+0x1e0/0x3d4)
[ 1089.455403] [<c049a2f0>] (ip_finish_output+0x1e0/0x3d4) from [<c049a=
6c0>] (ip_local_out+0x28/0x2c)
[ 1089.464379] [<c049a6c0>] (ip_local_out+0x28/0x2c) from [<c049a7f0>] =
(ip_queue_xmit+0x12c/0x364)
[ 1089.473097] [<c049a7f0>] (ip_queue_xmit+0x12c/0x364) from [<c04aeff0=
>] (tcp_transmit_skb+0x42c/0x86c)
[ 1089.482337] [<c04aeff0>] (tcp_transmit_skb+0x42c/0x86c) from [<c04af=
670>] (tcp_write_xmit+0x174/0xa74)
[ 1089.491664] [<c04af670>] (tcp_write_xmit+0x174/0xa74) from [<c04affe=
0>] (__tcp_push_pending_frames+0x30/0x98)
[ 1089.501599] [<c04affe0>] (__tcp_push_pending_frames+0x30/0x98) from =
[<c04ac044>] (tcp_rcv_established+0x144/0x5c8)
[ 1089.511968] [<c04ac044>] (tcp_rcv_established+0x144/0x5c8) from [<c0=
4b3ed4>] (tcp_v4_do_rcv+0x104/0x240)
[ 1089.521467] [<c04b3ed4>] (tcp_v4_do_rcv+0x104/0x240) from [<c04b65d4=
>] (tcp_v4_rcv+0x6ec/0x728)
[ 1089.530186] [<c04b65d4>] (tcp_v4_rcv+0x6ec/0x728) from [<c0495944>] =
(ip_local_deliver_finish+0x94/0x21c)
[ 1089.539686] [<c0495944>] (ip_local_deliver_finish+0x94/0x21c) from [=
<c04956f0>] (ip_rcv_finish+0x128/0x2e8)
[ 1089.549447] [<c04956f0>] (ip_rcv_finish+0x128/0x2e8) from [<c0458074=
>] (__netif_receive_skb_core+0x4c4/0x5d0)
[ 1089.559382] [<c0458074>] (__netif_receive_skb_core+0x4c4/0x5d0) from=
 [<c045a538>] (napi_gro_receive+0x74/0xa0)
[ 1089.569407] [<c045a538>] (napi_gro_receive+0x74/0xa0) from [<c038b00=
0>] (mvneta_rx+0x184/0x3e4)
[ 1089.578124] [<c038b000>] (mvneta_rx+0x184/0x3e4) from [<c038b2d8>] (=
mvneta_poll+0x78/0x16c)
[ 1089.586494] [<c038b2d8>] (mvneta_poll+0x78/0x16c) from [<c045a284>] =
(net_rx_action+0x98/0x180)
[ 1089.595124] [<c045a284>] (net_rx_action+0x98/0x180) from [<c001ec38>=
] (__do_softirq+0xc8/0x1f4)
[ 1089.603841] [<c001ec38>] (__do_softirq+0xc8/0x1f4) from [<c001f020>]=
 (irq_exit+0x6c/0xa8)
[ 1089.612036] [<c001f020>] (irq_exit+0x6c/0xa8) from [<c000eaa4>] (han=
dle_IRQ+0x34/0x84)
[ 1089.619970] [<c000eaa4>] (handle_IRQ+0x34/0x84) from [<c00084dc>] (a=
rmada_370_xp_handle_irq+0x4c/0xbc)
[ 1089.629297] [<c00084dc>] (armada_370_xp_handle_irq+0x4c/0xbc) from [=
<c0011100>] (__irq_svc+0x40/0x50)
[ 1089.638530] Exception stack(0xdf91fd00 to 0xdf91fd48)
[ 1089.643593] fd00: df79d13c 00020209 00020209 000200da c0e2e960 df91f=
f18 c0e2e960 df91fe18
[ 1089.651787] fd20: df91fd80 00000000 df79d13c 00000001 0000001a df91f=
d48 c0064430 c006443c
[ 1089.659977] fd40: a0000013 ffffffff
[ 1089.663483] [<c0011100>] (__irq_svc+0x40/0x50) from [<c006443c>] (pa=
ge_evictable+0x18/0x38)
[ 1089.671854] [<c006443c>] (page_evictable+0x18/0x38) from [<c00649ac>=
] (shrink_page_list+0xf4/0x9ec)
[ 1089.680919] [<c00649ac>] (shrink_page_list+0xf4/0x9ec) from [<c00658=
a0>] (shrink_inactive_list+0x220/0x3f4)
[ 1089.690681] [<c00658a0>] (shrink_inactive_list+0x220/0x3f4) from [<c=
0065dcc>] (shrink_lruvec+0x358/0x544)
[ 1089.700268] [<c0065dcc>] (shrink_lruvec+0x358/0x544) from [<c0066420=
>] (kswapd+0x468/0x7e4)
[ 1089.708639] [<c0066420>] (kswapd+0x468/0x7e4) from [<c00328dc>] (kth=
read+0xbc/0xd8)
[ 1089.716312] [<c00328dc>] (kthread+0xbc/0xd8) from [<c000e298>] (ret_=
from_fork+0x14/0x3c)
[ 1089.724418] Code: e157000b a35e0000 e58de01c 1a00009d (e59a2050)=20
[ 1089.730547] ---[ end trace c836ddfbecd551b4 ]---
[ 1089.735173] Kernel panic - not syncing: Fatal exception in interrupt
