From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: bpf debug info
Date: Tue, 29 Nov 2016 15:38:18 +0000
Message-ID: <20161129153818.51104fab@jkicinski-Precision-T1700>
References: <20161129064217.GA20124@ast-mbp.thefacebook.com>
        <583D9AA4.8050601@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        netdev@vger.kernel.org, Brenden Blanco <bblanco@plumgrid.com>,
        Thomas Graf <tgraf@suug.ch>, Wangnan <wangnan0@huawei.com>,
        He Kuang <hekuang@huawei.com>, kernel-team@fb.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.9]:39374 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932753AbcK2PiW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Nov 2016 10:38:22 -0500
In-Reply-To: <583D9AA4.8050601@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Nov 2016 16:11:32 +0100, Daniel Borkmann wrote:
> On 11/29/2016 07:42 AM, Alexei Starovoitov wrote:
> [...]
> > The support for debug information in BPF was recently added to llvm.
> >
> > In order to use it recompile bpf programs with the following patch
> > in samples/bpf/Makefile
> > @@ -155,4 +155,4 @@ $(obj)/%.o: $(src)/%.c
> >          $(CLANG) $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) \
> >                  -D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
> >                  -Wno-compare-distinct-pointer-types \
> > -               -O2 -emit-llvm -c $< -o -| $(LLC) -march=bpf -filetype=obj -o $@
> > +               -O2 -emit-llvm -g -c $< -o -| $(LLC) -march=bpf -filetype=obj -o $@
> >
> > and compiled .o files can be consumed by standard llvm-objdump utility.
> >
> > $ llvm-objdump -S -no-show-raw-insn samples/bpf/xdp1_kern.o
> > xdp1_kern.o:    file format ELF64-BPF
> >
> > Disassembly of section xdp1:
> > xdp_prog1:
> > ; {
> >         0:       r2 = *(u32 *)(r1 + 4)
> > ; void *data = (void *)(long)ctx->data;
> >         8:       r1 = *(u32 *)(r1 + 0)
> > ; if (data + nh_off > data_end)
> >        10:       r3 = r1
> >        18:       r3 += 14
> >        20:       if r3 > r2 goto 55
> > ; h_proto = eth->h_proto;
> >        28:       r3 = *(u8 *)(r1 + 12)
> >        30:       r4 = *(u8 *)(r1 + 13)
> >        38:       r4 <<= 8
> >        40:       r4 |= r3
> > ; if (h_proto == htons(ETH_P_8021Q) || h_proto == htons(ETH_P_8021AD)) {
> >        48:       if r4 == 43144 goto 2
> >        50:       r3 = 14
> >        58:       if r4 != 129 goto 5
> >
> > LBB0_3:
> > ; if (data + nh_off > data_end)
> >        60:       r3 = r1
> >        68:       r3 += 18
> >        70:       if r3 > r2 goto 45
> >        78:       r3 = 18
> > ; h_proto = vhdr->h_vlan_encapsulated_proto;
> >        80:       r4 = *(u16 *)(r1 + 16)
> >
> > LBB0_5:
> >        88:       r5 = r4
> >        90:       r5 &= 65535
> > ; if (h_proto == htons(ETH_P_8021Q) || h_proto == htons(ETH_P_8021AD)) {
> >        98:       if r5 == 43144 goto 1
> >        a0:       if r5 != 129 goto 9
> >
> > Notice that 'clang -S -o a.s' output and llvm-objdump disassembler
> > were changed to use kernel verifier style, so now it should be easier
> > to see what's going on.  

This sounds super useful!  Thanks a lot!

>>> [...]
> > So next step is to improve verifier messages to be more human friendly.
> > The step after is to introduce BPF_COMMENT pseudo instruction
> > that will be ignored by the interpreter yet it will contain the text
> > of original source code. Then llvm-objdump step won't be necessary.
> > The bpf loader will load both instructions and pieces of C sources.
> > Then verifier errors should be even easier to read and humans
> > can easily understand the purpose of the program.  
> 
> So the BPF_COMMENT pseudo insn will get stripped away from the insn array
> after verification step, so we don't need to hold/account for this mem? I
> assume in it's ->imm member it will just hold offset into text blob?

Associating any form of opaque data with programs always makes me
worried about opening a side channel of communication with a specialized
user space implementations/compilers.  But I guess if the BPF_COMMENTs
are stripped in the verifier as Daniel assumes drivers and JITs will
never see it.

Just to clarify, however - is there any reason why pushing the source
code into the kernel is necessary?  Or is it just for convenience?
Provided the user space loader has access to the debug info it should
have no problems matching the verifier output to code lines?
