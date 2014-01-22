From: arno@natisbad.org (Arnaud Ebalard)
Subject: [BUG] null pointer dereference in tcp_gso_segment()
Date: Wed, 22 Jan 2014 22:46:39 +0100
Message-ID: <87r47z7kqo.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:50911 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753459AbaAVVrg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 16:47:36 -0500
Received: from smtp.natisbad.org (unknown [81.57.185.249])
	by smtp3-g21.free.fr (Postfix) with ESMTP id 87F26A6271
	for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 22:47:21 +0100 (CET)
To: David Miller <davem@davemloft.net>
To: Eric Dumazet <edumazet@google.com>
To: Daniel Borkmann <dborkman@redhat.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
To: Willy Tarreau <w@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The following is a backtrace I got while doing a simple transfer from my
NAS (ARMv7-based ReadyNAS 102) running a 3.13.0 kernel. Usage was a
simple file served by nginx. I managed to get a second identical one
in another session. As this did not looked like some random race
condition or some missing lock, I decided to take a look. Details are
given below. FWIW, driver is mvneta (w/ fixes and performance patches
you accepted for v3.14, David) and ethtool reports gso is enabled and tso
disabled.

[  943.860383] Unable to handle kernel NULL pointer dereference at virtual address 00000090
[  943.868497] pgd = c0004000
[  943.871217] [00000090] *pgd=00000000
[  943.874813] Internal error: Oops: 17 [#1] ARM
[  943.879175] Modules linked in:
[  943.882248] CPU: 0 PID: 0 Comm: swapper Not tainted 3.13.0.rn102-00594-ga0fa1dd3cdbc-dirty #63
[  943.890873] task: c0775620 ti: c0768000 task.ti: c0768000
[  943.896291] PC is at tcp_gso_segment+0x1d8/0x390
[  943.900925] LR is at skb_segment+0x510/0x788
[  943.905202] pc : [<c04b2094>]    lr : [<c0448b90>]    psr: 200f0113
[  943.905202] sp : c0769aa8  ip : 00005b27  fp : 00000001
[  943.916697] r10: 00005b27  r9 : 00000868  r8 : dfab5cb0
[  943.921930] r7 : 00000000  r6 : 4ef79279  r5 : 00000020  r4 : deeba830
[  943.928467] r3 : 000005a8  r2 : df993200  r1 : c04a63f8  r0 : 000005a8
[  943.935005] Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
[  943.942325] Control: 10c5387d  Table: 1534c019  DAC: 00000015
[  943.948079] Process swapper (pid: 0, stack limit = 0xc0768238)
[  943.953921] Stack: (0xc0769aa8 to 0xc076a000)
[  943.958288] 9aa0:                   c077000c 000005a8 0000e397 d52f3540 c0771230 00001c48
[  943.966481] 9ac0: 00000006 deeba830 0000c6bc 00000014 0000009c 00000000 00000014 c04beeb4
[  943.974674] 9ae0: c0fbb8ec dec2ab80 0000008e 00000000 00000001 00004803 00000002 deeba830
[  943.982867] 9b00: c07739cc deeba830 df27d15c df1fd800 c05a045c c0452dcc 00000004 c07739e0
[  943.991061] 9b20: 00004803 00004803 00000002 00010000 00000000 deeba830 df27d15c c04530e8
[  943.999254] 9b40: 00000001 c046fc40 c0492410 df1fd800 00000000 00000000 00000000 def06e00
[  944.007447] 9b60: df1fd800 deeba830 df1fd800 df27d15c 00000010 c0469af4 def06e00 00000000
[  944.015640] 9b80: 00000042 00000000 df27d15c df1fd800 deeba830 c04535b8 def06e60 000333c5
[  944.023834] 9ba0: 00000000 dfaf5180 dfaf51fc 0000000e 00000000 deeba830 df1fd800 def35580
[  944.032027] 9bc0: 00000010 c0492604 80000000 0b50a8c0 00000000 deeba830 df993200 00000000
[  944.040221] 9be0: df993404 def35580 00000000 009c0000 00000000 c0492a2c deeba830 c0492b5c
[  944.048414] 9c00: deeba780 df993200 deeba780 00000020 00000000 0000fb7b 00000020 df993200
[  944.056608] 9c20: deeba830 c0778368 00000000 def35580 00000000 c04a76e8 c3a0f5c7 134b291d
[  944.064802] 9c40: 00000001 00000000 00000002 00000000 00000000 0000fb7b 002411ee 00000000
[  944.072995] 9c60: 79e31870 df993200 deeba780 000005a8 4ef79279 00001c48 00000000 000021f0
[  944.081188] 9c80: 00000000 c04a7d68 c39c239b 134b291d 00000006 000016a0 000021f0 00000001
[  944.089381] 9ca0: 00000000 df9932bc 00000002 00000000 00000006 134b291d d52f3540 df993200
[  944.097575] 9cc0: d567e7e4 d52f3540 00000020 d567e7d0 d52f3540 0000ddc7 c0770618 c04a86d8
[  944.105768] 9ce0: 00000020 df993200 df993200 c04a4954 00000000 00000020 00000001 00000002
[  944.113961] 9d00: d52f3540 df993200 def35a00 df993200 d567e7d0 d52f3540 0000ddc7 c04ac61c
[  944.122154] 9d20: c048da1c c046fc40 c048da1c c046fc40 dec12140 c0770b64 d52f3540 d52f3540
[  944.130348] 9d40: c07a3dc0 00000000 df993200 c04aede0 df1fd800 c046fcc0 00000000 c0769d74
[  944.138541] 9d60: c048da1c 80000000 c048d734 c0770b64 0000000e c0770b64 3050a8c0 c05aacb4
[  944.146734] 9d80: c0773470 00000000 c07a3dc0 d52f3540 d52f3540 00000000 c0770618 c048dab0
[  944.154927] 9da0: d567e7d0 c07739e8 c0770628 df1fd800 d52f3540 c048d85c df1b4400 c0770614
[  944.163120] 9dc0: c0770614 c07739e8 c0770628 df1fd800 00000008 c044f018 00000003 00000000
[  944.171314] 9de0: e1424800 42000000 df1fd800 d52f3540 00000001 c0770628 00000000 d52f3540
[  944.179507] 9e00: 00000003 df3bd400 e1424800 42000000 df1fd800 d52f3540 00000001 c045153c
[  944.187700] 9e20: 00000004 c0019430 e1424000 c0382238 00000000 00000000 00000002 dfbc4600
[  944.195893] 9e40: 00000001 df1fdbe0 00000001 00000042 00000000 00000000 dee34000 00000040
[  944.204086] 9e60: df1fdbe0 00000100 00000000 00000100 df3bd400 c079b684 00000000 c0382354
[  944.212279] 9e80: c04ab2fc c04aa344 df993200 df1fd800 00000100 df1fdbfc 00000000 df993200
[  944.220473] 9ea0: 00000100 c04ab360 c0768000 c0023cf4 c0fba140 c03822b0 df1fdbfc 00000040
[  944.228666] 9ec0: 0000012c c07abb40 c07abb48 c0778368 c07abb40 c0451288 c0769ed8 0000fb7d
[  944.236859] 9ee0: c0fba140 00000001 0000000c c07ac850 c07ac840 c0768000 00000003 00000100
[  944.245052] 9f00: 0000000c c001ebd4 00000000 c004782c c0fba140 0000000a 0000fb7c 00200000
[  944.253245] 9f20: c0769f78 c078af20 00000018 00000000 c0769f78 c07abc01 00000001 c07abc01
[  944.261438] 9f40: 00000000 c001ef18 c078af20 c000ea44 c07f6f40 000003ff c07f6f40 c00084d8
[  944.269632] 9f60: c000ebc0 c0041c54 600f0013 ffffffff c0769fac c00110c0 00000000 00000000
[  944.277825] 9f80: 00000000 c0779a48 c0768000 c0768000 c0768000 c07700cc c07abc01 00000001
[  944.286018] 9fa0: c07abc01 00000000 01000000 c0769fc0 c000ebc0 c0041c54 600f0013 ffffffff
[  944.294211] 9fc0: c0761530 c073ba14 ffffffff ffffffff c073b4f0 00000000 00000000 c0761530
[  944.302405] 9fe0: 00000000 10c53c7d c0770078 c076152c c07765f8 00008070 00000000 00000000
[  944.310608] [<c04b2094>] (tcp_gso_segment+0x1d8/0x390) from [<c04beeb4>] (inet_gso_segment+0x118/0x2dc)
[  944.320029] [<c04beeb4>] (inet_gso_segment+0x118/0x2dc) from [<c0452dcc>] (skb_mac_gso_segment+0xa4/0x178)
[  944.329704] [<c0452dcc>] (skb_mac_gso_segment+0xa4/0x178) from [<c04530e8>] (dev_hard_start_xmit+0x170/0x484)
[  944.339643] [<c04530e8>] (dev_hard_start_xmit+0x170/0x484) from [<c0469af4>] (sch_direct_xmit+0xa4/0x19c)
[  944.349231] [<c0469af4>] (sch_direct_xmit+0xa4/0x19c) from [<c04535b8>] (__dev_queue_xmit+0x1bc/0x3dc)
[  944.358560] [<c04535b8>] (__dev_queue_xmit+0x1bc/0x3dc) from [<c0492604>] (ip_finish_output+0x1f4/0x440)
[  944.368060] [<c0492604>] (ip_finish_output+0x1f4/0x440) from [<c0492a2c>] (ip_local_out+0x28/0x2c)
[  944.377037] [<c0492a2c>] (ip_local_out+0x28/0x2c) from [<c0492b5c>] (ip_queue_xmit+0x12c/0x384)
[  944.385754] [<c0492b5c>] (ip_queue_xmit+0x12c/0x384) from [<c04a76e8>] (tcp_transmit_skb+0x42c/0x86c)
[  944.394992] [<c04a76e8>] (tcp_transmit_skb+0x42c/0x86c) from [<c04a7d68>] (tcp_write_xmit+0x174/0xa74)
[  944.404317] [<c04a7d68>] (tcp_write_xmit+0x174/0xa74) from [<c04a86d8>] (__tcp_push_pending_frames+0x30/0x98)
[  944.414252] [<c04a86d8>] (__tcp_push_pending_frames+0x30/0x98) from [<c04a4954>] (tcp_rcv_established+0x334/0x5a0)
[  944.424622] [<c04a4954>] (tcp_rcv_established+0x334/0x5a0) from [<c04ac61c>] (tcp_v4_do_rcv+0x104/0x240)
[  944.434122] [<c04ac61c>] (tcp_v4_do_rcv+0x104/0x240) from [<c04aede0>] (tcp_v4_rcv+0x6ec/0x728)
[  944.442838] [<c04aede0>] (tcp_v4_rcv+0x6ec/0x728) from [<c048dab0>] (ip_local_deliver_finish+0x94/0x21c)
[  944.452337] [<c048dab0>] (ip_local_deliver_finish+0x94/0x21c) from [<c048d85c>] (ip_rcv_finish+0x128/0x2e8)
[  944.462098] [<c048d85c>] (ip_rcv_finish+0x128/0x2e8) from [<c044f018>] (__netif_receive_skb_core+0x4c4/0x5d0)
[  944.472032] [<c044f018>] (__netif_receive_skb_core+0x4c4/0x5d0) from [<c045153c>] (napi_gro_receive+0x74/0xa0)
[  944.482054] [<c045153c>] (napi_gro_receive+0x74/0xa0) from [<c0382238>] (mvneta_rx+0x420/0x498)
[  944.490771] [<c0382238>] (mvneta_rx+0x420/0x498) from [<c0382354>] (mvneta_poll+0xa4/0x3b8)
[  944.499139] [<c0382354>] (mvneta_poll+0xa4/0x3b8) from [<c0451288>] (net_rx_action+0x98/0x180)
[  944.507773] [<c0451288>] (net_rx_action+0x98/0x180) from [<c001ebd4>] (__do_softirq+0xc8/0x1f4)
[  944.516491] [<c001ebd4>] (__do_softirq+0xc8/0x1f4) from [<c001ef18>] (irq_exit+0x6c/0xa8)
[  944.524690] [<c001ef18>] (irq_exit+0x6c/0xa8) from [<c000ea44>] (handle_IRQ+0x34/0x84)
[  944.532624] [<c000ea44>] (handle_IRQ+0x34/0x84) from [<c00084d8>] (armada_370_xp_handle_irq+0x48/0x50)
[  944.541953] [<c00084d8>] (armada_370_xp_handle_irq+0x48/0x50) from [<c00110c0>] (__irq_svc+0x40/0x50)
[  944.551186] Exception stack(0xc0769f78 to 0xc0769fc0)
[  944.556246] 9f60:                                                       00000000 00000000
[  944.564439] 9f80: 00000000 c0779a48 c0768000 c0768000 c0768000 c07700cc c07abc01 00000001
[  944.572632] 9fa0: c07abc01 00000000 01000000 c0769fc0 c000ebc0 c0041c54 600f0013 ffffffff
[  944.580835] [<c00110c0>] (__irq_svc+0x40/0x50) from [<c0041c54>] (cpu_startup_entry+0x44/0xe0)
[  944.589470] [<c0041c54>] (cpu_startup_entry+0x44/0xe0) from [<c073ba14>] (start_kernel+0x2fc/0x358)
[  944.598533] Code: e5942010 e5872010 e5977000 e59d3004 (e1d729b0) 
[  944.604662] ---[ end trace 39b798f37a10efc0 ]---
[  944.609288] Kernel panic - not syncing: Fatal exception in interrupt


Here is the beginning of the assembly dump of tcp_gso_segment() provided by
arm-linux-gnueabi-objdump -S -EL -D -b binary -m arm --start-address=0x4a9ebc
--stop-address=0x4aa24c Image. If you wonder, LOADADDR is 0x8000 during
compilation, which explains the address shift.

004a9ebc <.data+0x4a9ebc>:
  4a9ebc:	e92d4ff0 	push	{r4, r5, r6, r7, r8, r9, sl, fp, lr}
  4a9ec0:	e1a09003 	mov	r9, r3
  4a9ec4:	e5901054 	ldr	r1, [r0, #84]	; 0x54
  4a9ec8:	e24dd014 	sub	sp, sp, #20
  4a9ecc:	e5903050 	ldr	r3, [r0, #80]	; 0x50
  4a9ed0:	e1a04000 	mov	r4, r0
  4a9ed4:	e1a08002 	mov	r8, r2
  4a9ed8:	e0611003 	rsb	r1, r1, r3
  4a9edc:	e3510013 	cmp	r1, #19
  4a9ee0:	9a000099 	bls	0x4aa14c
  4a9ee4:	e1d439b0 	ldrh	r3, [r4, #144]	; 0x90
  4a9ee8:	e59420a0 	ldr	r2, [r4, #160]	; 0xa0
  4a9eec:	e0823003 	add	r3, r2, r3
  4a9ef0:	e5d3500c 	ldrb	r5, [r3, #12]
  4a9ef4:	e1a05225 	lsr	r5, r5, #4
  4a9ef8:	e1a05105 	lsl	r5, r5, #2
  4a9efc:	e3550013 	cmp	r5, #19
  4a9f00:	9a000097 	bls	0x4aa164
  4a9f04:	e5946050 	ldr	r6, [r4, #80]	; 0x50
  4a9f08:	e5943054 	ldr	r3, [r4, #84]	; 0x54
  4a9f0c:	e0631006 	rsb	r1, r3, r6
  4a9f10:	e1550001 	cmp	r5, r1
  4a9f14:	8a0000c0 	bhi	0x4aa21c
  4a9f18:	e065c006 	rsb	ip, r5, r6
  4a9f1c:	e584c050 	str	ip, [r4, #80]	; 0x50
  4a9f20:	e15c0003 	cmp	ip, r3
  4a9f24:	3a0000c6 	bcc	0x4aa244
  4a9f28:	e594709c 	ldr	r7, [r4, #156]	; 0x9c
  4a9f2c:	e59430a4 	ldr	r3, [r4, #164]	; 0xa4
  4a9f30:	e0833005 	add	r3, r3, r5
  4a9f34:	e58430a4 	str	r3, [r4, #164]	; 0xa4
  4a9f38:	e1d700b2 	ldrh	r0, [r7, #2]
  4a9f3c:	e15c0000 	cmp	ip, r0
  4a9f40:	e58d0004 	str	r0, [sp, #4]
  4a9f44:	9a000086 	bls	0x4aa164
  4a9f48:	e1d710b6 	ldrh	r1, [r7, #6]
  4a9f4c:	e3a02701 	mov	r2, #262144	; 0x40000
  4a9f50:	e3a03000 	mov	r3, #0
  4a9f54:	e1822008 	orr	r2, r2, r8
  4a9f58:	e1833009 	orr	r3, r3, r9
  4a9f5c:	e1a00801 	lsl	r0, r1, #16
  4a9f60:	e0022000 	and	r2, r2, r0
  4a9f64:	e1a0bfc0 	asr	fp, r0, #31
  4a9f68:	e1a0a000 	mov	sl, r0
  4a9f6c:	e003300b 	and	r3, r3, fp
  4a9f70:	e15b0003 	cmp	fp, r3
  4a9f74:	015a0002 	cmpeq	sl, r2
  4a9f78:	0a00007d 	beq	0x4aa174
  4a9f7c:	e5d4107e 	ldrb	r1, [r4, #126]	; 0x7e
  4a9f80:	e1a03009 	mov	r3, r9
  4a9f84:	e1a00004 	mov	r0, r4
  4a9f88:	e1a02008 	mov	r2, r8
  4a9f8c:	e7e071d1 	ubfx	r7, r1, #3, #1
  4a9f90:	e7c3119f 	bfc	r1, #3, #1
  4a9f94:	e5c4107e 	strb	r1, [r4, #126]	; 0x7e
  4a9f98:	e594b068 	ldr	fp, [r4, #104]	; 0x68
  4a9f9c:	ebfe59b7 	bl	0x440680
  4a9fa0:	e3700a01 	cmn	r0, #4096	; 0x1000
  4a9fa4:	e1a09000 	mov	r9, r0
  4a9fa8:	8a00006e 	bhi	0x4aa168
  4a9fac:	e1d929b0 	ldrh	r2, [r9, #144]	; 0x90
  4a9fb0:	e1e06006 	mvn	r6, r6
  4a9fb4:	e59980a0 	ldr	r8, [r9, #160]	; 0xa0
  4a9fb8:	e6ff6076 	uxth	r6, r6
  4a9fbc:	e58d6008 	str	r6, [sp, #8]
  4a9fc0:	e5d9307e 	ldrb	r3, [r9, #126]	; 0x7e
  4a9fc4:	e0888002 	add	r8, r8, r2
  4a9fc8:	e59f2278 	ldr	r2, [pc, #632]	; 0x4aa248
  4a9fcc:	e7c33197 	bfi	r3, r7, #3, #1
  4a9fd0:	e59d0004 	ldr	r0, [sp, #4]
  4a9fd4:	e5c9307e 	strb	r3, [r9, #126]	; 0x7e
  4a9fd8:	e05b2002 	subs	r2, fp, r2
  4a9fdc:	e1d831b0 	ldrh	r3, [r8, #16]
  4a9fe0:	e272b000 	rsbs	fp, r2, #0
  4a9fe4:	e59d1008 	ldr	r1, [sp, #8]
  4a9fe8:	e085c000 	add	ip, r5, r0
  4a9fec:	e0bbb002 	adcs	fp, fp, r2
  4a9ff0:	e1a07009 	mov	r7, r9
  4a9ff4:	e08cc001 	add	ip, ip, r1
  4a9ff8:	e58d900c 	str	r9, [sp, #12]
  4a9ffc:	e6bfcf3c 	rev	ip, ip
  4aa000:	e08cc003 	add	ip, ip, r3
  4aa004:	e3a03000 	mov	r3, #0
  4aa008:	e08cc86c 	add	ip, ip, ip, ror #16
  4aa00c:	e1a0c82c 	lsr	ip, ip, #16
  4aa010:	e1a09003 	mov	r9, r3
  4aa014:	e5986004 	ldr	r6, [r8, #4]
  4aa018:	e1a0a00c 	mov	sl, ip
  4aa01c:	e6bf6f36 	rev	r6, r6
  4aa020:	e5d8200d 	ldrb	r2, [r8, #13]
  4aa024:	e1c8a1b0 	strh	sl, [r8, #16]
  4aa028:	e20220f7 	and	r2, r2, #247	; 0xf7
  4aa02c:	e7c0201f 	bfc	r2, #0, #1
  4aa030:	e5c8200d 	strb	r2, [r8, #13]
  4aa034:	e5d72064 	ldrb	r2, [r7, #100]	; 0x64
  4aa038:	e202200c 	and	r2, r2, #12
  4aa03c:	e352000c 	cmp	r2, #12
  4aa040:	0a000009 	beq	0x4aa06c
  4aa044:	e1d709b0 	ldrh	r0, [r7, #144]	; 0x90
  4aa048:	e1a01005 	mov	r1, r5
  4aa04c:	e597e0a0 	ldr	lr, [r7, #160]	; 0xa0
  4aa050:	e597205c 	ldr	r2, [r7, #92]	; 0x5c
  4aa054:	e08e0000 	add	r0, lr, r0
  4aa058:	ebf7cc4c 	bl	0x29d190
  4aa05c:	e0800860 	add	r0, r0, r0, ror #16
  4aa060:	e1e02000 	mvn	r2, r0
  4aa064:	e1a02822 	lsr	r2, r2, #16
  4aa068:	e1c821b0 	strh	r2, [r8, #16]
  4aa06c:	e35b0000 	cmp	fp, #0
  4aa070:	0a000005 	beq	0x4aa08c
  4aa074:	e5941068 	ldr	r1, [r4, #104]	; 0x68
  4aa078:	e59720a8 	ldr	r2, [r7, #168]	; 0xa8
  4aa07c:	e5871068 	str	r1, [r7, #104]	; 0x68
  4aa080:	e0899002 	add	r9, r9, r2
  4aa084:	e5942010 	ldr	r2, [r4, #16]
  4aa088:	e5872010 	str	r2, [r7, #16]
  4aa08c:	e5977000 	ldr	r7, [r7]
  4aa090:	e59d3004 	ldr	r3, [sp, #4]
  4aa094:	e1d729b0 	ldrh	r2, [r7, #144]	; 0x90   <- HERE!
  4aa098:	e0866003 	add	r6, r6, r3
  4aa09c:	e59780a0 	ldr	r8, [r7, #160]	; 0xa0
  4aa0a0:	e6bf1f36 	rev	r1, r6
  4aa0a4:	e0888002 	add	r8, r8, r2
  4aa0a8:	e5d8200d 	ldrb	r2, [r8, #13]
  4aa0ac:	e5881004 	str	r1, [r8, #4]
  4aa0b0:	e7c7239f 	bfc	r2, #7, #1
  4aa0b4:	e5c8200d 	strb	r2, [r8, #13]
  4aa0b8:	e5972000 	ldr	r2, [r7]
  4aa0bc:	e3520000 	cmp	r2, #0
  4aa0c0:	1affffd6 	bne	0x4aa020


The line marked with the HERE! above is where the null pointer derefence
occurs. The code is in fact the (inlined) code of tcp_hdr(), which is in
turn the inlined code of tcp_transport_header() on given skb:

static inline unsigned char *skb_transport_header(const struct sk_buff *skb)
{
        return skb->head + skb->transport_header;
}

The call to tcp_hdr() is in the following loop in tcp_gso_segment():

     ...
  1  do {
  2          th->fin = th->psh = 0;
  3          th->check = newcheck;
  4
  5          if (skb->ip_summed != CHECKSUM_PARTIAL)
  6                  th->check =
  7                       csum_fold(csum_partial(skb_transport_header(skb),
  8                                              thlen, skb->csum));
  9
 10          seq += mss;
 11          if (copy_destructor) {
 12                  skb->destructor = gso_skb->destructor;
 13                  skb->sk = gso_skb->sk;
 14                  sum_truesize += skb->truesize;
 15          }
 16          skb = skb->next;
 17          th = tcp_hdr(skb);         <-- HERE!
 18
 19          th->seq = htonl(seq);
 20          th->cwr = 0;
 21  } while (skb->next);
     ...

Unless there is an assumption I missed somewhere in the function, the
problem may occur during the first round of the loop, because (unlike
the 'while' condition does at line 21) skb->next is not checked against
null at lines 17 above before it is passed to tcp_hdr() at line 18.

To be honest, I am asking because I am not familiar w/ the code and it
is somewhat old so I wonder why noone got hit before. AFAICT,
f4c50d990dcf ([NET]: Add software TSOv4) added TSOv4 support in 2006 via
introduction of tcp_tso_segmen() (with the same kind of deref but
possibly different assumptions) which was more recently modified via
28850dc7c7 (net: tcp: move GRO/GSO functions to tcp_offload) to become
tcp_gso_segment().

David, can you confirm the analysis and possibly comment on the
conditions needed for the bug to manifest?

Cheers,

a+
