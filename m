From: Vladimir Murzin <murzin.v@gmail.com>
Subject: Re: [PATCH] ppc: bpf_jit: support MOD operation
Date: Wed, 11 Sep 2013 18:15:57 +0200
Message-ID: <20130911161553.GB1967@hp530>
References: <1377643792-10327-1-git-send-email-murzin.v@gmail.com>
 <20130902174842.GA1866@hp530>
 <1378154750.3978.43.camel@pasglop>
 <20130903195819.GA1971@hp530>
 <52264C0D.3000409@redhat.com>
 <5226DB64.3020207@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	linuxppc-dev@lists.ozlabs.org, paulus@samba.org,
	davem@davemloft.net, Matt Evans <matt@ozlabs.org>,
	netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:58979 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756618Ab3IKQQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 12:16:22 -0400
Received: by mail-la0-f44.google.com with SMTP id eo20so7654912lab.17
        for <netdev@vger.kernel.org>; Wed, 11 Sep 2013 09:16:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5226DB64.3020207@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 04, 2013 at 09:04:04AM +0200, Daniel Borkmann wrote:
> On 09/03/2013 10:52 PM, Daniel Borkmann wrote:
> > On 09/03/2013 09:58 PM, Vladimir Murzin wrote:
> [...]
> >>> Do you have a test case/suite by any chance ?
> >>>
> >>> Ben.
> >>>
> >>
> >> Hi Ben!
> >>
> >> Thanks for your feedback.
> >>
> >> This patch is only compile tested. I have no real hardware, but I'll
> >> probably bring up qemu ppc64 till end of the week...
> >> Meanwhile, I've made simple how-to for testing. You can use it if you wish.
> >> It is mainly based on the [1] and rechecked on x86-64.

Finally I've managed to bring up qemu ppc64 and done simple testing. As a
result I could see difference in opcodes for divide instruction - I've just
sent the patch for that.

WRT mod instruction result is:

For BPF program

(000) ldh      [12]
(001) jeq      #0x800           jt 2	jf 10
(002) ldh      [16]
(003) sub      #20
(004) mod      #5
(005) jeq      #0x0             jt 10	jf 6
(006) ldb      [20]
(007) and      #0x20
(008) jeq      #0x20            jt 9	jf 10
(009) ret      #65535
(010) ret      #0

The following code is generated (with patch divw to divwu applied)

244 bytes emitted from JIT compiler (pass:3, flen:11)
d0000000015c0018 + <x>:
   0:	mflr    r0
   4:	std     r0,16(r1)
   8:	std     r14,-144(r1)
   c:	std     r15,-136(r1)
  10:	stdu    r1,-288(r1)
  14:	lwz     r7,108(r3)
  18:	lwz     r15,104(r3)
  1c:	subf    r15,r7,r15
  20:	ld      r14,216(r3)
  24:	lis     r7,-16384
  28:	rldicr  r7,r7,32,31
  2c:	oris    r7,r7,9
  30:	ori     r7,r7,43428
  34:	mtlr    r7
  38:	li      r6,12
  3c:	blrl
  40:	blt-    0x00000000000000dc
  44:	nop
  48:	cmplwi  r4,2048
  4c:	bne-    0x00000000000000d8
  50:	nop
  54:	lis     r7,-16384
  58:	rldicr  r7,r7,32,31
  5c:	oris    r7,r7,9
  60:	ori     r7,r7,43428
  64:	mtlr    r7
  68:	li      r6,16
  6c:	blrl
  70:	blt-    0x00000000000000dc
  74:	nop
  78:	addi    r4,r4,-20
  7c:	li      r8,5
  80:	divwu   r7,r4,r8
  84:	mullw   r7,r8,r7
  88:	subf    r4,r7,r4
  8c:	cmplwi  r4,0
  90:	beq-    0x00000000000000d8
  94:	nop
  98:	lis     r7,-16384
  9c:	rldicr  r7,r7,32,31
  a0:	oris    r7,r7,9
  a4:	ori     r7,r7,43456
  a8:	mtlr    r7
  ac:	li      r6,20
  b0:	blrl
  b4:	blt-    0x00000000000000dc
  b8:	nop
  bc:	andi.   r4,r4,32
  c0:	cmplwi  r4,32
  c4:	bne-    0x00000000000000d8
  c8:	nop
  cc:	li      r3,-1
  d0:	addis   r3,r3,1
  d4:	b       0x00000000000000dc
  d8:	li      r3,0
  dc:	addi    r1,r1,288
  e0:	ld      r0,16(r1)
  e4:	mtlr    r0
  e8:	ld      r14,-144(r1)
  ec:	ld      r15,-136(r1)
  f0:	blr

Raw codes are

flen=11 proglen=244 pass=3 image=d0000000015c0018
JIT code: 00000000: 7c 08 02 a6 f8 01 00 10 f9 c1 ff 70 f9 e1 ff 78
JIT code: 00000010: f8 21 fe e1 80 e3 00 6c 81 e3 00 68 7d e7 78 50
JIT code: 00000020: e9 c3 00 d8 3c e0 c0 00 78 e7 07 c6 64 e7 00 09
JIT code: 00000030: 60 e7 a9 a4 7c e8 03 a6 38 c0 00 0c 4e 80 00 21
JIT code: 00000040: 41 80 00 9c 60 00 00 00 28 04 08 00 40 82 00 8c
JIT code: 00000050: 60 00 00 00 3c e0 c0 00 78 e7 07 c6 64 e7 00 09
JIT code: 00000060: 60 e7 a9 a4 7c e8 03 a6 38 c0 00 10 4e 80 00 21
JIT code: 00000070: 41 80 00 6c 60 00 00 00 38 84 ff ec 39 00 00 05
JIT code: 00000080: 7c e4 43 96 7c e8 39 d6 7c 87 20 50 28 04 00 00
JIT code: 00000090: 41 82 00 48 60 00 00 00 3c e0 c0 00 78 e7 07 c6
JIT code: 000000a0: 64 e7 00 09 60 e7 a9 c0 7c e8 03 a6 38 c0 00 14
JIT code: 000000b0: 4e 80 00 21 41 80 00 28 60 00 00 00 70 84 00 20
JIT code: 000000c0: 28 04 00 20 40 82 00 14 60 00 00 00 38 60 ff ff
JIT code: 000000d0: 3c 63 00 01 48 00 00 08 38 60 00 00 38 21 01 20
JIT code: 000000e0: e8 01 00 10 7c 08 03 a6 e9 c1 ff 70 e9 e1 ff 78
JIT code: 000000f0: 4e 80 00 20

Ben,

How do you feel about it?

> >
> > Please also cc netdev on BPF related changes.
> >
> > Actually, your test plan can be further simplified ...
> >
> > For retrieving and disassembling the JIT image, we have bpf_jit_disasm [1].
> >
> >   1) echo 2 > /proc/sys/net/core/bpf_jit_enable
> >   2) ... attach filter ...
> >   3) bpf_jit_disasm -o
> >
> > For generating a simple stupid test filter, you can use bpfc [2] (also
> > see its man page). E.g. ...
> >
> >    # cat blub
> >    ldi #10
> >    mod #8
> >    ret a
> >    # bpfc blub
> >    { 0x0, 0, 0, 0x0000000a },
> >    { 0x94, 0, 0, 0x00000008 },
> >    { 0x16, 0, 0, 0x00000000 },
> 
> Plus something like ...
> 
> ldxi #0
> mod x
> ret a
> 

Thanks Daniel!

Unfortunately, I couldn't trigger JIT compiler with the pair bpfc/netsniff-ng
(even for x86-64). I guess I missed something. I'd be very grateful if you
point at my mistakes.

> For longer-term testing, also trinity has BPF support. ;)
> 

Wow! Could do give some hint how to run this for BPF only?

> > And load this array e.g. either into a small C program that attaches this
> > as BPF filter, or simply do bpfc blub > blub2 and run netsniff-ng -f blub2\
> > -s -i eth0, that should also do it.
> >
> > Then, when attached, the kernel should truncate incoming frames for pf_packet
> > into max length of 2, just as an example.
> >
> >    [1] kernel tree, tools/net/bpf_jit_disasm.c
> >    [2] git clone git://github.com/borkmann/netsniff-ng.git

Thanks
Vladimir
