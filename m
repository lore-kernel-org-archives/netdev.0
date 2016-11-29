From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: bpf debug info
Date: Mon, 28 Nov 2016 22:42:19 -0800
Message-ID: <20161129064217.GA20124@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Thomas Graf <tgraf@suug.ch>, Wangnan <wangnan0@huawei.com>,
        He Kuang <hekuang@huawei.com>, kernel-team@fb.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35459 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751317AbcK2GmY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 01:42:24 -0500
Received: by mail-pg0-f66.google.com with SMTP id p66so15421126pga.2
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 22:42:24 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

The support for debug information in BPF was recently added to llvm.

In order to use it recompile bpf programs with the following patch
in samples/bpf/Makefile
@@ -155,4 +155,4 @@ $(obj)/%.o: $(src)/%.c
        $(CLANG) $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) \
                -D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
                -Wno-compare-distinct-pointer-types \
-               -O2 -emit-llvm -c $< -o -| $(LLC) -march=bpf -filetype=obj -o $@
+               -O2 -emit-llvm -g -c $< -o -| $(LLC) -march=bpf -filetype=obj -o $@

and compiled .o files can be consumed by standard llvm-objdump utility.

$ llvm-objdump -S -no-show-raw-insn samples/bpf/xdp1_kern.o
xdp1_kern.o:    file format ELF64-BPF

Disassembly of section xdp1:
xdp_prog1:
; {
       0:       r2 = *(u32 *)(r1 + 4)
; void *data = (void *)(long)ctx->data;
       8:       r1 = *(u32 *)(r1 + 0)
; if (data + nh_off > data_end)
      10:       r3 = r1
      18:       r3 += 14
      20:       if r3 > r2 goto 55
; h_proto = eth->h_proto;
      28:       r3 = *(u8 *)(r1 + 12)
      30:       r4 = *(u8 *)(r1 + 13)
      38:       r4 <<= 8
      40:       r4 |= r3
; if (h_proto == htons(ETH_P_8021Q) || h_proto == htons(ETH_P_8021AD)) {
      48:       if r4 == 43144 goto 2
      50:       r3 = 14
      58:       if r4 != 129 goto 5

LBB0_3:
; if (data + nh_off > data_end)
      60:       r3 = r1
      68:       r3 += 18
      70:       if r3 > r2 goto 45
      78:       r3 = 18
; h_proto = vhdr->h_vlan_encapsulated_proto;
      80:       r4 = *(u16 *)(r1 + 16)

LBB0_5:
      88:       r5 = r4
      90:       r5 &= 65535
; if (h_proto == htons(ETH_P_8021Q) || h_proto == htons(ETH_P_8021AD)) {
      98:       if r5 == 43144 goto 1
      a0:       if r5 != 129 goto 9

Notice that 'clang -S -o a.s' output and llvm-objdump disassembler
were changed to use kernel verifier style, so now it should be easier
to see what's going on.

The main advantage of debug info is that verifier error messages
are now easier to correlate to original C code.

For example, say, in samples/bpf/parse_varlen.c I forgot
to compare pointer into packet with data_end:
--- a/samples/bpf/parse_varlen.c
+++ b/samples/bpf/parse_varlen.c
@@ -33,8 +33,8 @@ static int udp(void *data, uint64_t tp_off, void *data_end)
 {
        struct udphdr *udp = data + tp_off;

-       if (udp + 1 > data_end)
-               return 0;
+//     if (udp + 1 > data_end)
+//             return 0;
        if (udp->dest == htons(DEFAULT_PKTGEN_UDP_PORT) ||
            udp->source == htons(DEFAULT_PKTGEN_UDP_PORT)) {

If I try to run samples/bpf/test_cls_bpf.sh the verifier will complain:
R0=imm0,min_value=0,max_value=0 R1=pkt(id=0,off=0,r=42) R2=pkt_end
112: (0f) r4 += r3
113: (0f) r1 += r4
114: (b7) r0 = 2
115: (69) r2 = *(u16 *)(r1 +2)
invalid access to packet, off=2 size=2, R1(id=3,off=0,r=0)

Now multiply 115 * 8 and convert to hex. This is address 0x398 in llvm-objdump:
; struct udphdr *udp = data + tp_off;
     388:       r1 += r4
     390:       r0 = 2
; if (udp->dest == htons(DEFAULT_PKTGEN_UDP_PORT) ||
     398:       r2 = *(u16 *)(r1 + 2)
     3a0:       if r2 == 2304 goto 16

Now it's clear which line of C code is causing the verifier to reject.

It's still not obvious why register R1 is 'invalid pointer to packet'.
The 'r=0' part of 'R1(id=3,off=0,r=0)' stands for zero bytes were
verified to be valid in this register.
Since 'if (udp + 1 > data_end)' was not done, the kernel doesn't
know that there are valid bytes in the packet after 'udp' pointer.

So next step is to improve verifier messages to be more human friendly.
The step after is to introduce BPF_COMMENT pseudo instruction
that will be ignored by the interpreter yet it will contain the text
of original source code. Then llvm-objdump step won't be necessary.
The bpf loader will load both instructions and pieces of C sources.
Then verifier errors should be even easier to read and humans
can easily understand the purpose of the program.

PS
A year ago He Kuang reported that dwarf emitted by bpf llvm backend is broken.
Sorry it took so long to fix. It's probably still broken on big endian,
since I've only tested on x86.
