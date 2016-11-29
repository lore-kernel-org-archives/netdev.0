From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: bpf debug info
Date: Tue, 29 Nov 2016 16:11:32 +0100
Message-ID: <583D9AA4.8050601@iogearbox.net>
References: <20161129064217.GA20124@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Brenden Blanco <bblanco@plumgrid.com>, Thomas Graf <tgraf@suug.ch>,
        Wangnan <wangnan0@huawei.com>, He Kuang <hekuang@huawei.com>,
        kernel-team@fb.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59517 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932360AbcK2PLf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 10:11:35 -0500
In-Reply-To: <20161129064217.GA20124@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/29/2016 07:42 AM, Alexei Starovoitov wrote:
[...]
> The support for debug information in BPF was recently added to llvm.
>
> In order to use it recompile bpf programs with the following patch
> in samples/bpf/Makefile
> @@ -155,4 +155,4 @@ $(obj)/%.o: $(src)/%.c
>          $(CLANG) $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) \
>                  -D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
>                  -Wno-compare-distinct-pointer-types \
> -               -O2 -emit-llvm -c $< -o -| $(LLC) -march=bpf -filetype=obj -o $@
> +               -O2 -emit-llvm -g -c $< -o -| $(LLC) -march=bpf -filetype=obj -o $@
>
> and compiled .o files can be consumed by standard llvm-objdump utility.
>
> $ llvm-objdump -S -no-show-raw-insn samples/bpf/xdp1_kern.o
> xdp1_kern.o:    file format ELF64-BPF
>
> Disassembly of section xdp1:
> xdp_prog1:
> ; {
>         0:       r2 = *(u32 *)(r1 + 4)
> ; void *data = (void *)(long)ctx->data;
>         8:       r1 = *(u32 *)(r1 + 0)
> ; if (data + nh_off > data_end)
>        10:       r3 = r1
>        18:       r3 += 14
>        20:       if r3 > r2 goto 55
> ; h_proto = eth->h_proto;
>        28:       r3 = *(u8 *)(r1 + 12)
>        30:       r4 = *(u8 *)(r1 + 13)
>        38:       r4 <<= 8
>        40:       r4 |= r3
> ; if (h_proto == htons(ETH_P_8021Q) || h_proto == htons(ETH_P_8021AD)) {
>        48:       if r4 == 43144 goto 2
>        50:       r3 = 14
>        58:       if r4 != 129 goto 5
>
> LBB0_3:
> ; if (data + nh_off > data_end)
>        60:       r3 = r1
>        68:       r3 += 18
>        70:       if r3 > r2 goto 45
>        78:       r3 = 18
> ; h_proto = vhdr->h_vlan_encapsulated_proto;
>        80:       r4 = *(u16 *)(r1 + 16)
>
> LBB0_5:
>        88:       r5 = r4
>        90:       r5 &= 65535
> ; if (h_proto == htons(ETH_P_8021Q) || h_proto == htons(ETH_P_8021AD)) {
>        98:       if r5 == 43144 goto 1
>        a0:       if r5 != 129 goto 9
>
> Notice that 'clang -S -o a.s' output and llvm-objdump disassembler
> were changed to use kernel verifier style, so now it should be easier
> to see what's going on.

Sounds really useful, is that scheduled for llvm 3.10 release?

That debugging info is stored in dwarf format into the obj, right?
Would be nice if also pahole could work on bpf object files.

> The main advantage of debug info is that verifier error messages
> are now easier to correlate to original C code.

Does that mean that the old -S output format is not available anymore?
Personally, I liked that one better tbh, was hoping someone would have
added asm parsing for it, so compilation from .S to .o also works.

> For example, say, in samples/bpf/parse_varlen.c I forgot
> to compare pointer into packet with data_end:
> --- a/samples/bpf/parse_varlen.c
> +++ b/samples/bpf/parse_varlen.c
> @@ -33,8 +33,8 @@ static int udp(void *data, uint64_t tp_off, void *data_end)
>   {
>          struct udphdr *udp = data + tp_off;
>
> -       if (udp + 1 > data_end)
> -               return 0;
> +//     if (udp + 1 > data_end)
> +//             return 0;
>          if (udp->dest == htons(DEFAULT_PKTGEN_UDP_PORT) ||
>              udp->source == htons(DEFAULT_PKTGEN_UDP_PORT)) {
>
> If I try to run samples/bpf/test_cls_bpf.sh the verifier will complain:
> R0=imm0,min_value=0,max_value=0 R1=pkt(id=0,off=0,r=42) R2=pkt_end
> 112: (0f) r4 += r3
> 113: (0f) r1 += r4
> 114: (b7) r0 = 2
> 115: (69) r2 = *(u16 *)(r1 +2)
> invalid access to packet, off=2 size=2, R1(id=3,off=0,r=0)
>
> Now multiply 115 * 8 and convert to hex. This is address 0x398 in llvm-objdump:
> ; struct udphdr *udp = data + tp_off;
>       388:       r1 += r4
>       390:       r0 = 2
> ; if (udp->dest == htons(DEFAULT_PKTGEN_UDP_PORT) ||
>       398:       r2 = *(u16 *)(r1 + 2)
>       3a0:       if r2 == 2304 goto 16
>
> Now it's clear which line of C code is causing the verifier to reject.
[...]

Could llvm-objdump switch line numbering for bpf same way as verifier
output, so mapping step is not really needed? Alternatively, on each
verifier error, there could be a hint with cmd to use regarding llvm-objdump.

> So next step is to improve verifier messages to be more human friendly.
> The step after is to introduce BPF_COMMENT pseudo instruction
> that will be ignored by the interpreter yet it will contain the text
> of original source code. Then llvm-objdump step won't be necessary.
> The bpf loader will load both instructions and pieces of C sources.
> Then verifier errors should be even easier to read and humans
> can easily understand the purpose of the program.

So the BPF_COMMENT pseudo insn will get stripped away from the insn array
after verification step, so we don't need to hold/account for this mem? I
assume in it's ->imm member it will just hold offset into text blob?

Given that the generated verifier log can already become huge nowadays up
to a point where less than 4k insns prog fails to load due to reaching max
kernel allowed verifier buffer size, is the plan to only dump C code for
last few lines or for everything?

> PS
> A year ago He Kuang reported that dwarf emitted by bpf llvm backend is broken.
> Sorry it took so long to fix. It's probably still broken on big endian,
> since I've only tested on x86.
>
