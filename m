From: David Miller <davem@davemloft.net>
Subject: more test_progs...
Date: Tue, 25 Apr 2017 12:52:17 -0400 (EDT)
Message-ID: <20170425.125217.1962662516948420246.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41870 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1432211AbdDYQwT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 12:52:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I'm trying to get test_progs working in net-next on sparc, it can't
even load the first BPF program.  It's triggering this verifier
check:

static int check_pkt_ptr_alignment(const struct bpf_reg_state *reg,
                                   int off, int size)
{
        if (reg->id && size != 1) {
                verbose("Unknown alignment. Only byte-sized access allowed in packet access.\n");

Specifically (this is test_pkt_access.o of course):

libbpf: load bpf program failed: Permission denied
libbpf: -- BEGIN DUMP LOG ---
libbpf: 
0: (b7) r0 = 2
1: (61) r2 = *(u32 *)(r1 +80)

r2 = skb->data_end

2: (61) r1 = *(u32 *)(r1 +76)

r1 = skb->data

3: (bf) r4 = r1

r4 = skb->data

4: (07) r4 += 14

r4 += sizeof(struct ethhdr);

5: (2d) if r4 > r2 goto pc+37

if out of range, exit

 R0=imm2,min_value=2,max_value=2 R1=pkt(id=0,off=0,r=14) R2=pkt_end R4=pkt(id=0,off=14,r=14) R10=fp

R1/R2/R4 analysis seems correct

6: (71) r5 = *(u8 *)(r1 +13)
7: (71) r3 = *(u8 *)(r1 +12)
8: (67) r3 <<= 8
9: (4f) r3 |= r5

Load eth->h_proto

10: (15) if r3 == 0xdd86 goto pc+9
 R0=imm2,min_value=2,max_value=2 R1=pkt(id=0,off=0,r=14) R2=pkt_end R3=inv R4=pkt(id=0,off=14,r=14) R5=inv56 R10=fp

Hmmm, endianness looks wrong here.  "-target bpf" defaults to the
endianness of whatever cpu that llvm was built for, right?

Maybe I need to make even more adjustments to selftests/bpf/Makefile
handling of clang options...

Anyways this is checking for ipv6, if so goto insn 25

11: (55) if r3 != 0x8 goto pc+29
 R0=imm2,min_value=2,max_value=2 R1=pkt(id=0,off=0,r=14) R2=pkt_end R3=inv,min_value=8,max_value=8 R4=pkt(id=0,off=14,r=14) R5=inv56 R10=fp

IPV4:

12: (bf) r3 = r1
13: (07) r3 += 34
14: (2d) if r3 > r2 goto pc+28

Make sure pkt + 34 is in range

 R0=imm2,min_value=2,max_value=2 R1=pkt(id=0,off=0,r=34) R2=pkt_end R3=pkt(id=0,off=34,r=34) R4=pkt(id=0,off=14,r=34) R5=inv56 R10=fp
15: (b7) r3 = 3
16: (71) r5 = *(u8 *)(r4 +0)
17: (67) r5 <<= 2
18: (57) r5 &= 60
19: (05) goto pc+5

IPV6:

25: (bf) r4 = r1
26: (0f) r4 += r5
27: (07) r4 += 14
28: (15) if r4 == 0x0 goto pc+12
 R0=imm2,min_value=2,max_value=2 R1=pkt(id=0,off=0,r=34) R2=pkt_end R3=imm3,min_value=3,max_value=3 R4=pkt(id=1,off=14,r=0) R5=inv58,min_value=0,max_value=60 R10=fp
29: (bf) r5 = r4
30: (07) r5 += 20
31: (2d) if r5 > r2 goto pc+11
 R0=imm2,min_value=2,max_value=2 R1=pkt(id=0,off=0,r=34) R2=pkt_end R3=imm3,min_value=3,max_value=3 R4=pkt(id=1,off=14,r=34) R5=pkt(id=1,off=34,r=34) R10=fp
32: (0f) r1 += r3
33: (71) r1 = *(u8 *)(r1 +20)

Load ipv6 nexthdr

34: (57) r1 &= 255
35: (55) if r1 != 0x6 goto pc+7

if proto not TCP skip

 R0=imm2,min_value=2,max_value=2 R1=inv56,min_value=6,max_value=6 R2=pkt_end R3=imm3,min_value=3,max_value=3 R4=pkt(id=1,off=14,r=34) R5=pkt(id=1,off=34,r=34) R10=fp
36: (07) r4 += 18
37: (2d) if r4 > r2 goto pc+5
 R0=imm2,min_value=2,max_value=2 R1=inv56,min_value=6,max_value=6 R2=pkt_end R3=imm3,min_value=3,max_value=3 R4=pkt(id=1,off=32,r=34) R5=pkt(id=1,off=34,r=34) R10=fp
38: (b7) r0 = 0
39: (69) r1 = *(u16 *)(r4 +0)
Unknown alignment. Only byte-sized access allowed in packet access.

And this seems to load the urgent pointer as a u16 which is what the verifier rejects.

Oh I see, this is guarded by CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS.

How in the world is this supposed to work?
