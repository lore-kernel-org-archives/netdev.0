From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: bpf: undefined shift in __bpf_prog_run
Date: Fri, 4 Dec 2015 10:43:35 -0800
Message-ID: <20151204184333.GA42737@ast-mbp.thefacebook.com>
References: <CACT4Y+ZxoR3UjLgcNdUm4fECLMx2VdtfrENMtRRCdgHB2n0bJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>,
	Andrey Ryabinin <ryabinin.a.a@gmail.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33413 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751633AbbLDSnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2015 13:43:41 -0500
Content-Disposition: inline
In-Reply-To: <CACT4Y+ZxoR3UjLgcNdUm4fECLMx2VdtfrENMtRRCdgHB2n0bJA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 04, 2015 at 12:17:08PM +0100, Dmitry Vyukov wrote:
> Hello,
> 
> UBSAN reports the following undefined behavior:
> 
> UBSAN: Undefined behaviour in kernel/bpf/core.c:336:2
> shift exponent 2835 is to large for 32-bit type 'unsigned int'
> CPU: 1 PID: 14227 Comm: syzkaller_execu Not tainted 4.4.0-rc3+ #142
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>  0000000000000001 ffff88003892f898 ffffffff82c747b8 0000000041b58ab3
>  ffffffff878cbc05 ffffffff82c74706 ffff88003892f860 ffff88003892f9a0
>  0000000000000000 0000000000000b13 ffffffff88178de2 0000000000000020
> Call Trace:
>  [<ffffffff82d684f0>] __ubsan_handle_shift_out_of_bounds+0x294/0x2e5
> lib/ubsan.c:417
>  [<ffffffff8160a408>] __bpf_prog_run+0x8f48/0x9ac0 kernel/bpf/core.c:336
>  [<     inline     >] seccomp_run_filters kernel/seccomp.c:198
>  [<     inline     >] __seccomp_phase1_filter kernel/seccomp.c:588
>  [<ffffffff8156ddfb>] seccomp_phase1+0x1cb/0x990 kernel/seccomp.c:667
>  [<ffffffff8100651f>] syscall_trace_enter_phase1+0x28f/0x4e0
> arch/x86/entry/common.c:132
>  [<ffffffff8691b939>] tracesys+0xd/0x44 arch/x86/entry/entry_64.S:240

is it with some random seccomp program?
If normal libseccomp generates such programs than it needs to be fixed.

> Such shifts have undefined behavior according to C standard and behave
> differently on different archs. I guess we don't want to rely on any
> kind of undefined behavior in bpf/seccomp. And generally want to
> completely define results of all operations in bpf.

bpf is an engine and we're not going to slow down each shift operation
by extra run-time checks or masks.
In other words bpf shift instruction == shift in C. Both undefined
with for large operands.
If seccomp is relying on undefined behavior, it should be fixed.
