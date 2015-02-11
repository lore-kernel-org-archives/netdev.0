From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 7/7] cls_bpf: add initial eBPF support for
 programmable classifiers
Date: Tue, 10 Feb 2015 18:16:29 -0800
Message-ID: <CAMEtUuzAeukNAynQtMbjLYQcB+kxM+XaFFsB1tvrHjxUskJdZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:41589 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238AbbBKCQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 21:16:50 -0500
Received: by mail-qc0-f173.google.com with SMTP id w7so692732qcr.4
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 18:16:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 On Tue, Feb 10, 2015 at 4:15 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> This work extends the classic BPF programmable classifier by extending
> its scope also to native eBPF code. This allows for implementing
> custom C-like classifiers, compiling them with the LLVM eBPF backend
> and loading the resulting object file via tc into the kernel.
>
> Simple, minimal toy example:
>
>   #include <linux/ip.h>
>   #include <linux/if_ether.h>
>   #include <linux/bpf.h>
>
>   #include "tc_bpf_api.h"
>
>   __section("classify")
>   int cls_main(struct sk_buff *skb)
>   {
>     return (0x800 << 16) | load_byte(skb, ETH_HLEN + __builtin_offsetof(struct iphdr, tos));
>   }
>
>   char __license[] __section("license") = "GPL";
>
> The classifier can then be compiled into eBPF opcodes and loaded via
> tc, f.e.:
>
>   clang -O2 -emit-llvm -c cls.c -o - | llc -march=bpf -filetype=obj -o cls.o
>   tc filter add dev em1 parent 1: bpf run object-file cls.o [...]
>
> As it has been demonstrated, the scope can even reach up to a fully
> fledged flow dissector (similarly as in samples/bpf/sockex2_kern.c).
> For tc, maps are allowed to be used, but from kernel context only,
> in other words eBPF code can keep state across filter invocations.
> Similarly as in socket filters, we may extend functionality for eBPF
> classifiers over time depending on the use cases. For that purpose,
> I have added the BPF_PROG_TYPE_SCHED_CLS program type for the cls_bpf
> classifier module, so we can allow additional functions/accessors.
>
> I was wondering whether cls_bpf and act_bpf may share C programs, I
> can imagine that at some point, we may introduce i) some common
> handlers for both (or even beyond their scope), and/or ii) some
> restricted function space for each of them. Both can be abstracted
> through struct bpf_verifier_ops in future. The context of a cls_bpf
> versus act_bpf is slightly different though: a cls_bpf program will
> return a specific classid whereas act_bpf a drop/non-drop return
> code. That said, we can surely have a "classify" and "action" section
> in a single object file, or considered mentioned constraint add a
> possibility of a shared section.
>
> The workflow for getting native eBPF running from tc [1] is as
> follows: for f_bpf, I've added a slightly modified ELF parser code
> from Alexei's kernel sample, which reads out the LLVM compiled
> object, sets up maps (and dynamically fixes up map fds) if any,
> and loads the eBPF instructions all centrally through the bpf
> syscall. The resulting fd from the loaded program itself is being
> passed down to cls_bpf, which looks up struct bpf_prog from the
> fd store, and holds reference, so that it stays available also
> after tc program lifetime. On tc filter destruction, it will then
> drop its reference.
>
>   [1] http://git.breakpoint.cc/cgit/dborkman/iproute2.git/log/?h=ebpf
>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

nice. really nice :)
everything looks simple and straightforward.

The only question, do we need new BPF_PROG_TYPE_SCHED_CLS for it ?
Potential alternatives:
1.
inside 'enum bpf_prog_type {' do
BPF_PROG_TYPE_SCHED_CLS = BPF_PROG_TYPE_SOCKET_FILTER,

2.
in core/filter.c do:
bpf_register_prog_type(&sock_type);
bpf_register_prog_type(&cls_type);
static struct bpf_prog_type_list cls_type = {
        .ops = &sock_filter_ops,
        .type = BPF_PROG_TYPE_SCHED_CLS,
};

this way, initially, cls and sockets will have the same set
of helpers and later we can diverge them if necessary,
since BPF_PROG_TYPE_SCHED_CLS will be reserved.

Also avoids all module related problems I mentioned in the other thread.
