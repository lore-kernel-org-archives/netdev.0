From: Joy Latten <latten@austin.ibm.com>
Subject: Re: IPSec kernel oops on ppc64
Date: Wed, 30 Aug 2006 11:36:26 -0500
Message-ID: <200608301636.k7UGaQY5002569@faith.austin.ibm.com>
Cc: davem@davemloft.net, gcwilson@us.ibm.com, jmorris@redhat.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:33940 "EHLO e5.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751024AbWH3Qrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2006 12:47:36 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7UGlZqM032454
	for <netdev@vger.kernel.org>; Wed, 30 Aug 2006 12:47:35 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7UGlZvu288814
	for <netdev@vger.kernel.org>; Wed, 30 Aug 2006 12:47:35 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7UGlYDW012297
	for <netdev@vger.kernel.org>; Wed, 30 Aug 2006 12:47:35 -0400
To: anton@au1.ibm.com, herbert@gondor.apana.org.au,
	linuxppc-dev@ozlabs.org, paulus@au1.ibm.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>--
>diff --git a/arch/powerpc/lib/memcpy_64.S b/arch/powerpc/lib/memcpy_64.S
>index fd66acf..9e8d9e7 100644
>--- a/arch/powerpc/lib/memcpy_64.S
>+++ b/arch/powerpc/lib/memcpy_64.S
>@@ -11,6 +11,7 @@ #include <asm/ppc_asm.h>
> 
> 	.align	7
> _GLOBAL(memcpy)
>+	std	r3,-8(r1)
> 	mtcrf	0x01,r5
> 	cmpldi	cr1,r5,16
> 	neg	r6,r3		# LS 3 bits = # bytes to 8-byte dest bdry
>@@ -53,7 +54,8 @@ _GLOBAL(memcpy)
> 2:	bf	cr7*4+3,3f
> 	rotldi	r9,r9,8
> 	stb	r9,0(r3)
>-3:	blr
>+3:	ld	r3,-8(r1)
>+	blr
> 
> .Lsrc_unaligned:
> 	srdi	r6,r5,3
>@@ -167,4 +169,5 @@ _GLOBAL(memcpy)
> 3:	bf	cr7*4+3,4f
> 	lbz	r0,0(r4)
> 	stb	r0,0(r3)
>-4:	blr
>+4:	ld	r3,-8(r1)
>+	blr


Hi,

I tried the patch on the following:
linux-2.6.17 + patch-2.6.18-rc1

The good news is that the pings worked great!
So perhaps ESP is working ok with ICMP.

But when I tried to do sftp, I still got the oops.
I don't think TCP and ESP are working.

I pasted below info as well as the disassembled routine,
just in case.

Regards,
Joy

====================================================================
root@hvracer1 jml]# sftp joy-hv4
Connecting to joy-hv4...
kernel BUG in skb_to_sgvec at net/xfrm/xfrm_algo.c:611!
cpu 0x0: Vector: 700 (Program Check) at [c00000000257b280]
    pc: c000000000305ea4: .skb_to_sgvec+0x288/0x2ec
    lr: d0000000006305f0: .esp_output+0x350/0x4e4 [esp4]
    sp: c00000000257b500
   msr: 8000000000029032
  current = 0xc000000042320b00
  paca    = 0xc000000000414380
    pid   = 2007, comm = ssh
kernel BUG in skb_to_sgvec at net/xfrm/xfrm_algo.c:611!
enter ? for help
0:mon> t
[c00000000257b5d0] d0000000006305f0 .esp_output+0x350/0x4e4 [esp4]
[c00000000257b6b0] c0000000002fe758 .xfrm4_output_finish2+0x2bc/0x3d8
[c00000000257b750] c0000000002fea28 .xfrm4_output+0x74/0x88
[c00000000257b7d0] c0000000002c1504 .ip_queue_xmit+0x474/0x50c
[c00000000257b8c0] c0000000002d4a88 .tcp_transmit_skb+0x818/0x884
[c00000000257b970] c0000000002d7c7c .tcp_connect+0x318/0x3bc
[c00000000257ba10] c0000000002dc228 .tcp_v4_connect+0x4dc/0x674
[c00000000257bb80] c0000000002ea6a0 .inet_stream_connect+0x10c/0x358
[c00000000257bc60] c000000000283fd0 .sys_connect+0xd8/0x120
[c00000000257bd90] c0000000002a4c54 .compat_sys_socketcall+0xdc/0x214
[c00000000257be30] c00000000000871c syscall_exit+0x0/0x40
--- Exception: c00 (System Call) at 0000000007a9f8fc
SP (ff88f230) is in userspace
0:mon> r
R00 = 0000000000000058   R16 = 00000000080704d8
R01 = c00000000257b500   R17 = 0000000008065d68
R02 = c0000000005261d0   R18 = 00000000ff88f2dc
R03 = c000000041da2d00   R19 = 0000000000000001
R04 = c00000003d8a9660   R20 = c00000000257bcd8
R05 = 0000000000000028   R21 = 0000000000000000
R06 = 000000000000023c   R22 = 0000000000000001
R07 = c000000000660208   R23 = 0000000000000010
R08 = 00000000000041da   R24 = 0000000000000001
R09 = 0000000000000000   R25 = c00000003d8a9660
R10 = 0000000000000028   R26 = 0000000000000050
R11 = 0000000000107680   R27 = 0000000000000050
R12 = d0000000006312f8   R28 = 0000000000000008
R13 = c000000000414380   R29 = 0000000000000000
R14 = 0000000000000000   R30 = c0000000004c09a8
R15 = 000000000806379c   R31 = c0000000329221a0
pc  = c000000000305ea4 .skb_to_sgvec+0x288/0x2ec
lr  = d0000000006305f0 .esp_output+0x350/0x4e4 [esp4]
msr = 8000000000029032   cr  = 28000442
ctr = c000000000305c1c   xer = 0000000000000000   trap =  700
0:mon> S
msr  = 8000000000001032  sprg0= 0000000000000000
pvr  = 00000000003a0202  sprg1= c000000000414380
dec  = 00000000f2fd7ff0  sprg2= c000000000414380
sp   = c00000000257ab10  sprg3= c000000000414380
toc  = c0000000005261d0  dar  = 00000000ff88dfb0
0:mon> u
SLB contents of cpu 0
00 c000000008000000 0000408f92c94500
01 d000000008000000 0000f09b89af5400
02 c000000078000000 000045cb97751500
03 0000000010000000 000036ab4f98cc80
04 0000000000000000 0000f41e71baac80
05 00000000f0000000 0000ff55e973fc80
06 0000000040000000 0000f71c2b416c80
07 0000000010000000 0000f4dde01c5c80
08 c000000040000000 0000438d4c500500
09 0000000000000000 000004abd053cc80
10 00000000f0000000 00000fe3480d1c80
11 0000000040000000 000007a989da8c80
12 0000000010000000 0000056b3eb57c80
13 0000000000000000 0000f41e71baac80
14 00000000f0000000 0000ff55e973fc80
15 0000000040000000 0000f71c2b416c80
16 c000000038000000 000042cdddee5500
17 0000000010000000 0000f4dde01c5c80
18 0000000000000000 000004abd053cc80
19 00000000f0000000 00000fe3480d1c80
20 0000000040000000 000007a989da8c80
21 0000000010000000 0000056b3eb57c80
22 c000000070000000 000045cb97751500
23 0000000000000000 00008110f15afc80
24 00000000f0000000 00008c4869144c80
25 0000000040000000 0000840eaae1bc80
26 0000000000000000 0000cc36017edc80
27 00000000f0000000 0000d76d79382c80
28 0000000040000000 0000cf33bb059c80
29 0000000000000000 00008110f15afc80
30 00000000f0000000 00008c4869144c80
31 0000000040000000 0000840eaae1bc80
32 c000000040000000 0000438d4c500500
33 0000000000000000 0000cc36017edc80
34 00000000f0000000 0000d76d79382c80
35 0000000040000000 0000cf33bb059c80
36 c000000070000000 000045cb97751500
37 c000000048000000 0000438d4c500500
38 0000000008000000 000004abd053cc80
39 00000000f8000000 00000fe3480d1c80
40 0000000048000000 000007a989da8c80
41 0000000000000000 0000f41e71baac80
42 00000000f0000000 0000ff55e973fc80
43 0000000040000000 0000f71c2b416c80
44 0000000010000000 0000f4dde01c5c80
45 0000000000000000 000035ebe1371c80
46 00000000f0000000 0000412358f06c80
47 0000000040000000 000038e99abddc80
48 0000000010000000 000036ab4f98cc80
49 0000000000000000 0000f41e71baac80
50 00000000f0000000 0000ff55e973fc80
51 0000000040000000 0000f71c2b416c80
52 0000000010000000 0000f4dde01c5c80
53 0000000000000000 000035ebe1371c80
54 00000000f0000000 0000412358f06c80
55 0000000040000000 000038e99abddc80
56 0000000010000000 000036ab4f98cc80
57 0000000000000000 00006e61b00bfc80
58 00000000f0000000 0000799927c54c80
59 0000000040000000 0000715f6992bc80
60 0000000010000000 00006f211e6dac80
61 0000000000000000 000035ebe1371c80
62 00000000f0000000 0000412358f06c80
63 0000000040000000 000038e99abddc80
0:mon> e
cpu 0x0: Vector: 700 (Program Check) at [c00000000257b280]
    pc: c000000000305ea4: .skb_to_sgvec+0x288/0x2ec
    lr: d0000000006305f0: .esp_output+0x350/0x4e4 [esp4]
    sp: c00000000257b500
   msr: 8000000000029032
  current = 0xc000000042320b00
  paca    = 0xc000000000414380
    pid   = 2007, comm = ssh
kernel BUG in skb_to_sgvec at net/xfrm/xfrm_algo.c:611!
0:mon>

=============================================================================
0000000000000120 <.skb_to_sgvec>:
 120:   7c 08 02 a6     mflr    r0
 124:   fa a1 ff a8     std     r21,-88(r1)
 128:   fb 21 ff c8     std     r25,-56(r1)
 12c:   fb 61 ff d8     std     r27,-40(r1)
 130:   fb 81 ff e0     std     r28,-32(r1)
 134:   fb c1 ff f0     std     r30,-16(r1)
 138:   fb e1 ff f8     std     r31,-8(r1)
 13c:   fa c1 ff b0     std     r22,-80(r1)
 140:   fa e1 ff b8     std     r23,-72(r1)
 144:   fb 01 ff c0     std     r24,-64(r1)
 148:   fb 41 ff d0     std     r26,-48(r1)
 14c:   fb a1 ff e8     std     r29,-24(r1)
 150:   f8 01 00 10     std     r0,16(r1)
 154:   f8 21 ff 31     stdu    r1,-208(r1)
 158:   eb c2 00 00     ld      r30,0(r2)
 15c:   7c 7f 1b 78     mr      r31,r3
 160:   7c 99 23 78     mr      r25,r4
 164:   7c bb 2b 78     mr      r27,r5
 168:   7c dc 33 78     mr      r28,r6
 16c:   3a a0 00 00     li      r21,0
 170:   80 1f 00 88     lwz     r0,136(r31)
 174:   81 3f 00 8c     lwz     r9,140(r31)
 178:   3b 00 00 00     li      r24,0
 17c:   7c 09 00 50     subf    r0,r9,r0
 180:   7c 1a 07 b4     extsw   r26,r0
 184:   7c 1b d0 50     subf    r0,r27,r26
 188:   7c 00 07 b4     extsw   r0,r0
 18c:   2f 80 00 00     cmpwi   cr7,r0,0
 190:   40 9d 00 a4     ble-    cr7,234 <.skb_to_sgvec+0x114>
 194:   7f 9c 00 00     cmpw    cr7,r28,r0
 198:   7f 8a e3 78     mr      r10,r28
 19c:   40 9d 00 08     ble-    cr7,1a4 <.skb_to_sgvec+0x84>
 1a0:   7c 0a 03 78     mr      r10,r0
 1a4:   e8 1f 00 d8     ld      r0,216(r31)
 1a8:   3d 20 40 00     lis     r9,16384
 1ac:   e9 7e 80 18     ld      r11,-32744(r30)
 1b0:   7d 4a 07 b4     extsw   r10,r10
 1b4:   38 e0 00 00     li      r7,0
 1b8:   79 29 07 c6     rldicr  r9,r9,32,31
 1bc:   7c 1b 02 14     add     r0,r27,r0
 1c0:   7c 00 4a 14     add     r0,r0,r9
 1c4:   78 09 d9 60     rldicl  r9,r0,27,37
 1c8:   78 08 84 02     rldicl  r8,r0,48,16
 1cc:   78 00 46 02     rldicl  r0,r0,40,24
 1d0:   79 29 1f 24     rldicr  r9,r9,3,60
 1d4:   7d 29 58 2a     ldx     r9,r9,r11
 1d8:   2f a9 00 00     cmpdi   cr7,r9,0
 1dc:   41 9e 00 0c     beq-    cr7,1e8 <.skb_to_sgvec+0xc8>
 1e0:   78 00 1c 28     rldic   r0,r0,3,48
 1e4:   7c e9 02 14     add     r7,r9,r0
 1e8:   e8 07 00 00     ld      r0,0(r7)
 1ec:   79 0b 36 64     rldicr  r11,r8,6,57
 1f0:   7d 2a e0 50     subf    r9,r10,r28
 1f4:   7d 3c 07 b4     extsw   r28,r9
 1f8:   78 00 07 64     rldicr  r0,r0,0,61
 1fc:   2f bc 00 00     cmpdi   cr7,r28,0
 200:   7c 00 5a 14     add     r0,r0,r11
 204:   f8 19 00 00     std     r0,0(r25)
 208:   e8 1f 00 d8     ld      r0,216(r31)
 20c:   91 59 00 0c     stw     r10,12(r25)
 210:   7c 1b 02 14     add     r0,r27,r0
 214:   54 00 04 3e     clrlwi  r0,r0,16
 218:   90 19 00 08     stw     r0,8(r25)
 21c:   40 9e 00 0c     bne-    cr7,228 <.skb_to_sgvec+0x108>
 220:   3b 00 00 01     li      r24,1
 224:   48 00 01 a4     b       3c8 <.skb_to_sgvec+0x2a8>
 228:   7c 0a da 14     add     r0,r10,r27
 22c:   3b 00 00 01     li      r24,1
 230:   7c 1b 07 b4     extsw   r27,r0
 234:   3a c0 00 00     li      r22,0
 238:   3a e0 00 10     li      r23,16
 23c:   48 00 00 ac     b       2e8 <.skb_to_sgvec+0x1c8>
 240:   40 b8 00 18     bge+    cr6,258 <.skb_to_sgvec+0x138>
 244:   e8 7e 80 20     ld      r3,-32736(r30)
 248:   e8 9e 80 28     ld      r4,-32728(r30)
 24c:   e8 be 80 30     ld      r5,-32720(r30)
 250:   48 00 00 01     bl      250 <.skb_to_sgvec+0x130>
 254:   60 00 00 00     nop
 258:   e8 1f 00 e8     ld      r0,232(r31)
 25c:   7b a9 26 e4     rldicr  r9,r29,4,59
 260:   7b 0a 2e a4     rldicr  r10,r24,5,58
 264:   39 18 00 01     addi    r8,r24,1
 268:   7c b9 52 14     add     r5,r25,r10
 26c:   7d 29 02 14     add     r9,r9,r0
 270:   7d 60 ba 14     add     r11,r0,r23
 274:   3a f7 00 10     addi    r23,r23,16
 278:   a0 09 00 22     lhz     r0,34(r9)
 27c:   38 cb 00 08     addi    r6,r11,8
 280:   7c 00 d2 14     add     r0,r0,r26
 284:   7c 07 07 b4     extsw   r7,r0
 288:   7c 1b 38 50     subf    r0,r27,r7
 28c:   7c 00 07 b4     extsw   r0,r0
 290:   2f 80 00 00     cmpwi   cr7,r0,0
 294:   7c 09 03 78     mr      r9,r0
 298:   7f 00 e0 00     cmpw    cr6,r0,r28
 29c:   40 9d 00 48     ble-    cr7,2e4 <.skb_to_sgvec+0x1c4>
 2a0:   7d 18 07 b4     extsw   r24,r8
 2a4:   40 99 00 08     ble-    cr6,2ac <.skb_to_sgvec+0x18c>
 2a8:   7f 89 e3 78     mr      r9,r28
 2ac:   e8 0b 00 08     ld      r0,8(r11)
 2b0:   7d 29 07 b4     extsw   r9,r9
 2b4:   7d 69 e0 50     subf    r11,r9,r28
 2b8:   7c 19 51 2a     stdx    r0,r25,r10
 2bc:   7d 7c 07 b4     extsw   r28,r11
 2c0:   7d 69 da 14     add     r11,r9,r27
 2c4:   2f bc 00 00     cmpdi   cr7,r28,0
 2c8:   a0 06 00 08     lhz     r0,8(r6)
 2cc:   91 25 00 0c     stw     r9,12(r5)
 2d0:   7c 00 da 14     add     r0,r0,r27
 2d4:   7d 7b 07 b4     extsw   r27,r11
 2d8:   7c 1a 00 50     subf    r0,r26,r0
 2dc:   90 05 00 08     stw     r0,8(r5)
 2e0:   41 9e 00 e8     beq-    cr7,3c8 <.skb_to_sgvec+0x2a8>
 2e4:   7c fa 3b 78     mr      r26,r7
 2e8:   e8 7f 00 e8     ld      r3,232(r31)
 2ec:   7e dd 07 b4     extsw   r29,r22
 2f0:   7c 1c da 14     add     r0,r28,r27
 2f4:   3a d6 00 01     addi    r22,r22,1
 2f8:   38 c0 02 3c     li      r6,572
 2fc:   7f 00 d0 00     cmpw    cr6,r0,r26
 300:   a1 23 00 04     lhz     r9,4(r3)
 304:   7f 89 e8 00     cmpw    cr7,r9,r29
 308:   41 9d ff 38     bgt+    cr7,240 <.skb_to_sgvec+0x120>
 30c:   eb a3 00 10     ld      r29,16(r3)
 310:   2f bd 00 00     cmpdi   cr7,r29,0
 314:   41 9e 00 94     beq-    cr7,3a8 <.skb_to_sgvec+0x288>
 318:   7c 1b e2 14     add     r0,r27,r28
 31c:   38 c0 02 55     li      r6,597
 320:   7f 80 d0 00     cmpw    cr7,r0,r26
 324:   40 bc 00 18     bge+    cr7,33c <.skb_to_sgvec+0x21c>
 328:   e8 9e 80 28     ld      r4,-32728(r30)
 32c:   e8 be 80 30     ld      r5,-32720(r30)
 330:   e8 7e 80 20     ld      r3,-32736(r30)
 334:   48 00 00 01     bl      334 <.skb_to_sgvec+0x214>
 338:   60 00 00 00     nop
 33c:   80 1d 00 88     lwz     r0,136(r29)
 340:   7d 5a d8 50     subf    r10,r26,r27
 344:   7b 0b 2e a4     rldicr  r11,r24,5,58
 348:   7f a3 eb 78     mr      r3,r29
 34c:   7d 45 07 b4     extsw   r5,r10
 350:   7c 99 5a 14     add     r4,r25,r11
 354:   7c 00 d2 14     add     r0,r0,r26
 358:   7c 00 07 b4     extsw   r0,r0
 35c:   7d 3b 00 50     subf    r9,r27,r0
 360:   7c 1a 03 78     mr      r26,r0
 364:   7d 3f 07 b4     extsw   r31,r9
 368:   2f 9f 00 00     cmpwi   cr7,r31,0
 36c:   7f e6 fb 78     mr      r6,r31
 370:   7f 1f e0 00     cmpw    cr6,r31,r28
 374:   40 9d 00 2c     ble-    cr7,3a0 <.skb_to_sgvec+0x280>
 378:   41 99 00 38     bgt-    cr6,3b0 <.skb_to_sgvec+0x290>
 37c:   48 00 00 01     bl      37c <.skb_to_sgvec+0x25c>
 380:   7c 1f e0 50     subf    r0,r31,r28
 384:   7d 3f da 14     add     r9,r31,r27
 388:   7c 63 c2 14     add     r3,r3,r24
 38c:   7c 1c 07 b4     extsw   r28,r0
 390:   7d 3b 07 b4     extsw   r27,r9
 394:   7c 78 07 b4     extsw   r24,r3
 398:   2f bc 00 00     cmpdi   cr7,r28,0
 39c:   41 9e 00 2c     beq-    cr7,3c8 <.skb_to_sgvec+0x2a8>
 3a0:   eb bd 00 00     ld      r29,0(r29)
 3a4:   4b ff ff 6c     b       310 <.skb_to_sgvec+0x1f0>
 3a8:   0b 1c 00 00     tdnei   r28,0
 3ac:   48 00 00 1c     b       3c8 <.skb_to_sgvec+0x2a8>
 3b0:   7c 15 c2 14     add     r0,r21,r24
 3b4:   7f 39 5a 14     add     r25,r25,r11
 3b8:   7d 5b 07 b4     extsw   r27,r10
 3bc:   7f bf eb 78     mr      r31,r29
 3c0:   7c 15 07 b4     extsw   r21,r0
 3c4:   4b ff fd ac     b       170 <.skb_to_sgvec+0x50>
 3c8:   38 21 00 d0     addi    r1,r1,208
 3cc:   7c 75 c2 14     add     r3,r21,r24
 3d0:   e8 01 00 10     ld      r0,16(r1)
 3d4:   7c 63 07 b4     extsw   r3,r3
 3d8:   ea a1 ff a8     ld      r21,-88(r1)
 3dc:   ea c1 ff b0     ld      r22,-80(r1)
 3e0:   ea e1 ff b8     ld      r23,-72(r1)
 3e4:   eb 01 ff c0     ld      r24,-64(r1)
 3e8:   eb 21 ff c8     ld      r25,-56(r1)
 3ec:   eb 41 ff d0     ld      r26,-48(r1)
 3f0:   eb 61 ff d8     ld      r27,-40(r1)
 3f4:   7c 08 03 a6     mtlr    r0
 3f8:   eb 81 ff e0     ld      r28,-32(r1)
 3fc:   eb a1 ff e8     ld      r29,-24(r1)
 400:   eb c1 ff f0     ld      r30,-16(r1)
 404:   eb e1 ff f8     ld      r31,-8(r1)
 408:   4e 80 00 20     blr

