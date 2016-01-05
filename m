From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] arm64: net: bpf: don't BUG() on large shifts
Date: Tue, 5 Jan 2016 09:55:58 -0800
Message-ID: <20160105175557.GC83548@ast-mbp.thefacebook.com>
References: <1452015543-6790-1-git-send-email-rabin@rab.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, zlim.lnx@gmail.com,
	yang.shi@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com,
	linux-arm-kernel@lists.infradead.org
To: Rabin Vincent <rabin@rab.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34684 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752800AbcAER4B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 12:56:01 -0500
Received: by mail-pa0-f44.google.com with SMTP id uo6so199362803pac.1
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 09:56:01 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1452015543-6790-1-git-send-email-rabin@rab.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 05, 2016 at 06:39:03PM +0100, Rabin Vincent wrote:
> Attempting to generate UBFM/SBFM instructions with shifts that can't be
> encoded in the immediate fields of the opcodes leads to a trigger of a
> BUG() in the instruction generation code.  As the ARMv8 ARM says: "The
> shift amounts must be in the range 0 to one less than the register width
> of the instruction, inclusive."  Make the JIT reject unencodable shifts
> instead of crashing.
> 
>  ------------[ cut here ]------------
>  kernel BUG at arch/arm64/kernel/insn.c:766!
>  Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
>  CPU: 0 PID: 669 Comm: insmod Not tainted 4.4.0-rc8+ #4
>  PC is at aarch64_insn_gen_bitfield+0xcc/0xd4
>  LR is at build_body+0x1000/0x2914
>  ..
>  Call trace:
>  [<ffffffc00008c65c>] aarch64_insn_gen_bitfield+0xcc/0xd4
>  [<ffffffc000096bfc>] build_body+0x1000/0x2914
>  [<ffffffc000098590>] bpf_int_jit_compile+0x7c/0x1b4
>  [<ffffffc000130d10>] bpf_prog_select_runtime+0x20/0xcc
>  [<ffffffc0004afbac>] bpf_prepare_filter+0x3d8/0x3e8
>  [<ffffffc0004afc30>] bpf_prog_create+0x74/0xa4
>  [<ffffffbffc3de1d4>] test_bpf_init+0x1d4/0x748 [test_bpf]
>  [<ffffffc00008293c>] do_one_initcall+0x90/0x1a8
>  [<ffffffc000140c4c>] do_init_module+0x60/0x1c8
>  [<ffffffc00011bdcc>] load_module+0x1554/0x1c98
>  [<ffffffc00011c62c>] SyS_init_module+0x11c/0x140
>  [<ffffffc000085cb0>] el0_svc_naked+0x24/0x28
> 
> Signed-off-by: Rabin Vincent <rabin@rab.in>
> ---
>  arch/arm64/net/bpf_jit_comp.c | 7 +++++++
>  1 file changed, 7 insertions(+)

this one is better to be addressed in verifier instead of eBPF JITs.
Please reject it in check_alu_op() instead.
Though this bug is arm64 only and doesn't affect x64, it's better
to reject such invalid programs, since shifts with large constants
can be only be created manually. llvm doesn't generate such things.
