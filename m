From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: bpf debug info
Date: Tue, 29 Nov 2016 09:01:17 -0800
Message-ID: <20161129170115.GB22217@ast-mbp.thefacebook.com>
References: <20161129064217.GA20124@ast-mbp.thefacebook.com>
 <583D9AA4.8050601@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Brenden Blanco <bblanco@plumgrid.com>,
        Thomas Graf <tgraf@suug.ch>, Wangnan <wangnan0@huawei.com>,
        He Kuang <hekuang@huawei.com>, kernel-team@fb.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33980 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754091AbcK2RBV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 12:01:21 -0500
Received: by mail-pg0-f67.google.com with SMTP id e9so16878928pgc.1
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 09:01:20 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <583D9AA4.8050601@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2016 at 04:11:32PM +0100, Daniel Borkmann wrote:
> On 11/29/2016 07:42 AM, Alexei Starovoitov wrote:
> [...]
> >The support for debug information in BPF was recently added to llvm.
> >
> >In order to use it recompile bpf programs with the following patch
> >in samples/bpf/Makefile
> >@@ -155,4 +155,4 @@ $(obj)/%.o: $(src)/%.c
> >         $(CLANG) $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) \
> >                 -D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
> >                 -Wno-compare-distinct-pointer-types \
> >-               -O2 -emit-llvm -c $< -o -| $(LLC) -march=bpf -filetype=obj -o $@
> >+               -O2 -emit-llvm -g -c $< -o -| $(LLC) -march=bpf -filetype=obj -o $@
> >
> >and compiled .o files can be consumed by standard llvm-objdump utility.
> >
> >$ llvm-objdump -S -no-show-raw-insn samples/bpf/xdp1_kern.o
> >xdp1_kern.o:    file format ELF64-BPF
> >
> >Disassembly of section xdp1:
> >xdp_prog1:
> >; {
> >        0:       r2 = *(u32 *)(r1 + 4)
> >; void *data = (void *)(long)ctx->data;
> >        8:       r1 = *(u32 *)(r1 + 0)
> >; if (data + nh_off > data_end)
> >       10:       r3 = r1
> >       18:       r3 += 14
> >       20:       if r3 > r2 goto 55
> >; h_proto = eth->h_proto;
> >       28:       r3 = *(u8 *)(r1 + 12)
> >       30:       r4 = *(u8 *)(r1 + 13)
> >       38:       r4 <<= 8
> >       40:       r4 |= r3
> >; if (h_proto == htons(ETH_P_8021Q) || h_proto == htons(ETH_P_8021AD)) {
> >       48:       if r4 == 43144 goto 2
> >       50:       r3 = 14
> >       58:       if r4 != 129 goto 5
> >
> >LBB0_3:
> >; if (data + nh_off > data_end)
> >       60:       r3 = r1
> >       68:       r3 += 18
> >       70:       if r3 > r2 goto 45
> >       78:       r3 = 18
> >; h_proto = vhdr->h_vlan_encapsulated_proto;
> >       80:       r4 = *(u16 *)(r1 + 16)
> >
> >LBB0_5:
> >       88:       r5 = r4
> >       90:       r5 &= 65535
> >; if (h_proto == htons(ETH_P_8021Q) || h_proto == htons(ETH_P_8021AD)) {
> >       98:       if r5 == 43144 goto 1
> >       a0:       if r5 != 129 goto 9
> >
> >Notice that 'clang -S -o a.s' output and llvm-objdump disassembler
> >were changed to use kernel verifier style, so now it should be easier
> >to see what's going on.
> 
> Sounds really useful, is that scheduled for llvm 3.10 release?

llvm 4.0 :)

> That debugging info is stored in dwarf format into the obj, right?

right.

> Would be nice if also pahole could work on bpf object files.

yeah. pahole need to be taught to recognize bpf e_machine type and relocations.

> >The main advantage of debug info is that verifier error messages
> >are now easier to correlate to original C code.
> 
> Does that mean that the old -S output format is not available anymore?
> Personally, I liked that one better tbh, was hoping someone would have
> added asm parsing for it, so compilation from .S to .o also works.

we can still do a proper assembler form .s into .o
llvm infra is flexible enough. I can point somebody on what places
inside llvm bpf backend to extend to add full parsing of .s

> >If I try to run samples/bpf/test_cls_bpf.sh the verifier will complain:
> >R0=imm0,min_value=0,max_value=0 R1=pkt(id=0,off=0,r=42) R2=pkt_end
> >112: (0f) r4 += r3
> >113: (0f) r1 += r4
> >114: (b7) r0 = 2
> >115: (69) r2 = *(u16 *)(r1 +2)
> >invalid access to packet, off=2 size=2, R1(id=3,off=0,r=0)
> >
> >Now multiply 115 * 8 and convert to hex. This is address 0x398 in llvm-objdump:
> >; struct udphdr *udp = data + tp_off;
> >      388:       r1 += r4
> >      390:       r0 = 2
> >; if (udp->dest == htons(DEFAULT_PKTGEN_UDP_PORT) ||
> >      398:       r2 = *(u16 *)(r1 + 2)
> >      3a0:       if r2 == 2304 goto 16
> >
> >Now it's clear which line of C code is causing the verifier to reject.
> [...]
> 
> Could llvm-objdump switch line numbering for bpf same way as verifier
> output, so mapping step is not really needed?

you mean that llvm-objdump to print 113,114,115 ?
I guess it's doable. Will give it a try.

> So the BPF_COMMENT pseudo insn will get stripped away from the insn array
> after verification step, so we don't need to hold/account for this mem?

that was the idea, but if we keep src in there, we might want to keep
it for some future 'dump program' debugging step?

> I assume in it's ->imm member it will just hold offset into text blob?

yes. 

> Given that the generated verifier log can already become huge nowadays up
> to a point where less than 4k insns prog fails to load due to reaching max
> kernel allowed verifier buffer size, is the plan to only dump C code for
> last few lines or for everything?

right. that's a good point.
