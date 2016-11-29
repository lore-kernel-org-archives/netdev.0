From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: bpf debug info
Date: Tue, 29 Nov 2016 21:23:10 +0100
Message-ID: <583DE3AE.8030103@iogearbox.net>
References: <20161129064217.GA20124@ast-mbp.thefacebook.com> <583D9AA4.8050601@iogearbox.net> <20161129153818.51104fab@jkicinski-Precision-T1700> <20161129185116.GA22581@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Brenden Blanco <bblanco@plumgrid.com>,
        Thomas Graf <tgraf@suug.ch>, Wangnan <wangnan0@huawei.com>,
        He Kuang <hekuang@huawei.com>, kernel-team@fb.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33907 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756691AbcK2UXP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 15:23:15 -0500
In-Reply-To: <20161129185116.GA22581@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/29/2016 07:51 PM, Alexei Starovoitov wrote:
> On Tue, Nov 29, 2016 at 03:38:18PM +0000, Jakub Kicinski wrote:
[...]
>>>> So next step is to improve verifier messages to be more human friendly.
>>>> The step after is to introduce BPF_COMMENT pseudo instruction
>>>> that will be ignored by the interpreter yet it will contain the text
>>>> of original source code. Then llvm-objdump step won't be necessary.
>>>> The bpf loader will load both instructions and pieces of C sources.
>>>> Then verifier errors should be even easier to read and humans
>>>> can easily understand the purpose of the program.
>>>
>>> So the BPF_COMMENT pseudo insn will get stripped away from the insn array
>>> after verification step, so we don't need to hold/account for this mem? I
>>> assume in it's ->imm member it will just hold offset into text blob?
>>
>> Associating any form of opaque data with programs always makes me
>> worried about opening a side channel of communication with a specialized
>> user space implementations/compilers.  But I guess if the BPF_COMMENTs
>> are stripped in the verifier as Daniel assumes drivers and JITs will
>> never see it.
>
> yes. the idea that it's a comment. It can contain any text,
> not only C code, but any other language.
> It's definitely going to be stripped before JITs and kernel will
> not make any safety or translation decisions based on such comment.
>
>> Just to clarify, however - is there any reason why pushing the source
>> code into the kernel is necessary?  Or is it just for convenience?
>> Provided the user space loader has access to the debug info it should
>> have no problems matching the verifier output to code lines?
>
> correct. just for convenience. The user space has to keep .o around,
> since it can crash, would have to reload and so on.
> Only for some script that ssh-es into servers and wants to see
> what is being loaded, it might help to dump full asm and these comments
> along with prog_digest that Daniel is working on in parallel.

Which would mean we'd need to keep it around somewhere (prog aux data?)
in post-verification time (so potentially drivers/JITs could see it, too,
just not inside insn stream). Some API glue code could probably blind
this information for the JITing time to stop incentive of playing side
channel games (e.g. core code could encrypt the pointer value and only
core kernel knows how to access that data, no modules, no out-of-tree
code). The other thing I'm wondering is, when we strip this info anyway
from the insn stream to keep it in aux data (so it can later be reconstructed
on a dump), then perhaps that is best done before prog loading time? It
would then allow to keep complexity with stripping that insns out of the
verifier. If semantics are that these comments are acting as a hole/gap
(in a similar sense of what we have with cBPF today), then it can never
become a jmp target and loaders could strip it out already (instead of
teaching DFS, etc about it), and prepare a meta data structure in bpf_attr
for bpf(2), and verifier works based on that one. What makes this problematic
however is when you have rewrites in the kernel (ctx access, constant
blinding, etc), but perhaps they could just adjust the offsets from that
meta data thing as well?

> Alternatively instead of doing BPF_COMMENT we can load the whole .o
> as-is into bpffs as a blob. Later (based on digest) the kernel can
> dump such .o back for user space to run objdump on. It all can be
> done without kernel involvement. Like tc command can copy .o and so on.
> But not everything is using tc.

That means kernel must ensure/verify that loaded insns also come from
that claimed object file; not sure if easily possible w/o parsing elf.
It could work if the kernel loads everything based on the content of
the object file itself, but that is not possible anymore since we have
bpf(2) already for doing that (but also would add a lot of complexity).

> Another alternative is to do a decompiler from bpf binary
> into meaningful C code. It's not trivial and names will be lost.
> bpf_comment approach is pretty cheap from kernel point of view
> and greatly helps visibility when users don't cheat with debug info.

Agree, it's non-trivial, would be really nice to have, though, so also
non-cooperative -g users could be better examined.

Thanks,
Daniel
