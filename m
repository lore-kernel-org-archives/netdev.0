From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: bpf debug info
Date: Tue, 29 Nov 2016 10:51:17 -0800
Message-ID: <20161129185116.GA22581@ast-mbp.thefacebook.com>
References: <20161129064217.GA20124@ast-mbp.thefacebook.com>
 <583D9AA4.8050601@iogearbox.net>
 <20161129153818.51104fab@jkicinski-Precision-T1700>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        Brenden Blanco <bblanco@plumgrid.com>,
        Thomas Graf <tgraf@suug.ch>, Wangnan <wangnan0@huawei.com>,
        He Kuang <hekuang@huawei.com>, kernel-team@fb.com
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33189 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751758AbcK2SvW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 13:51:22 -0500
Received: by mail-pg0-f65.google.com with SMTP id 3so17156416pgd.0
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 10:51:22 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161129153818.51104fab@jkicinski-Precision-T1700>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2016 at 03:38:18PM +0000, Jakub Kicinski wrote:
> 
> >>> [...]
> > > So next step is to improve verifier messages to be more human friendly.
> > > The step after is to introduce BPF_COMMENT pseudo instruction
> > > that will be ignored by the interpreter yet it will contain the text
> > > of original source code. Then llvm-objdump step won't be necessary.
> > > The bpf loader will load both instructions and pieces of C sources.
> > > Then verifier errors should be even easier to read and humans
> > > can easily understand the purpose of the program.  
> > 
> > So the BPF_COMMENT pseudo insn will get stripped away from the insn array
> > after verification step, so we don't need to hold/account for this mem? I
> > assume in it's ->imm member it will just hold offset into text blob?
> 
> Associating any form of opaque data with programs always makes me
> worried about opening a side channel of communication with a specialized
> user space implementations/compilers.  But I guess if the BPF_COMMENTs
> are stripped in the verifier as Daniel assumes drivers and JITs will
> never see it.

yes. the idea that it's a comment. It can contain any text,
not only C code, but any other language.
It's definitely going to be stripped before JITs and kernel will
not make any safety or translation decisions based on such comment.

> Just to clarify, however - is there any reason why pushing the source
> code into the kernel is necessary?  Or is it just for convenience?
> Provided the user space loader has access to the debug info it should
> have no problems matching the verifier output to code lines?

correct. just for convenience. The user space has to keep .o around,
since it can crash, would have to reload and so on.
Only for some script that ssh-es into servers and wants to see
what is being loaded, it might help to dump full asm and these comments
along with prog_digest that Daniel is working on in parallel.
Alternatively instead of doing BPF_COMMENT we can load the whole .o
as-is into bpffs as a blob. Later (based on digest) the kernel can
dump such .o back for user space to run objdump on. It all can be
done without kernel involvement. Like tc command can copy .o and so on.
But not everything is using tc.
Another alternative is to do a decompiler from bpf binary
into meaningful C code. It's not trivial and names will be lost.
bpf_comment approach is pretty cheap from kernel point of view
and greatly helps visibility when users don't cheat with debug info.
