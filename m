From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 5/5] MIPS: Add support for eBPF JIT.
Date: Fri, 26 May 2017 17:14:04 +0200
Message-ID: <5928463C.5000204@iogearbox.net>
References: <20170526003826.10834-1-david.daney@cavium.com> <20170526003826.10834-6-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Markos Chandras <markos.chandras@imgtec.com>
To: David Daney <david.daney@cavium.com>,
        Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
        ralf@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60069 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756716AbdEZPOJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 11:14:09 -0400
In-Reply-To: <20170526003826.10834-6-david.daney@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/26/2017 02:38 AM, David Daney wrote:
> Since the eBPF machine has 64-bit registers, we only support this in
> 64-bit kernels.  As of the writing of this commit log test-bpf is showing:
>
>    test_bpf: Summary: 316 PASSED, 0 FAILED, [308/308 JIT'ed]
>
> All current test cases are successfully compiled.
>
> Signed-off-by: David Daney <david.daney@cavium.com>

Awesome work!

Did you also manage to run tools/testing/selftests/bpf/ fine with
the JIT enabled?

[...]
> +struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
> +{
> +	struct jit_ctx ctx;
> +	unsigned int alloc_size;
> +
> +	/* Only 64-bit kernel supports eBPF */
> +	if (!IS_ENABLED(CONFIG_64BIT) || !bpf_jit_enable)

Isn't this already reflected by the following?

   select HAVE_EBPF_JIT if (64BIT && !CPU_MICROMIPS)

> +		return prog;
> +
> +	memset(&ctx, 0, sizeof(ctx));
> +
> +	ctx.offsets = kcalloc(prog->len + 1, sizeof(*ctx.offsets), GFP_KERNEL);
> +	if (ctx.offsets == NULL)
> +		goto out;
> +
> +	ctx.reg_val_types = kcalloc(prog->len + 1, sizeof(*ctx.reg_val_types), GFP_KERNEL);
> +	if (ctx.reg_val_types == NULL)
> +		goto out;
> +
> +	ctx.skf = prog;
> +
> +	if (reg_val_propagate(&ctx))
> +		goto out;
> +
> +	/* First pass discovers used resources */
> +	if (build_int_body(&ctx))
> +		goto out;
> +
> +	/* Second pass generates offsets */
> +	ctx.idx = 0;
> +	if (gen_int_prologue(&ctx))
> +		goto out;
> +	if (build_int_body(&ctx))
> +		goto out;
> +	if (build_int_epilogue(&ctx))
> +		goto out;
> +
> +	alloc_size = 4 * ctx.idx;
> +
> +	ctx.target = module_alloc(alloc_size);

You would need to use bpf_jit_binary_alloc() like all other
eBPF JITs do, otherwise kallsyms of the JITed progs would
break.

> +	if (ctx.target == NULL)
> +		goto out;
> +
> +	/* Clean it */
> +	memset(ctx.target, 0, alloc_size);
> +
> +	/* Third pass generates the code */
> +	ctx.idx = 0;
> +	if (gen_int_prologue(&ctx))
> +		goto out;
> +	if (build_int_body(&ctx))
> +		goto out;
> +	if (build_int_epilogue(&ctx))
> +		goto out;
> +	/* Update the icache */
> +	flush_icache_range((ptr)ctx.target, (ptr)(ctx.target + ctx.idx));
> +
> +	if (bpf_jit_enable > 1)
> +		/* Dump JIT code */
> +		bpf_jit_dump(prog->len, alloc_size, 2, ctx.target);
> +
> +	prog->bpf_func = (void *)ctx.target;
> +	prog->jited = 1;
> +
> +out:
> +	kfree(ctx.offsets);
> +	kfree(ctx.reg_val_types);
> +
> +	return prog;
> +}
