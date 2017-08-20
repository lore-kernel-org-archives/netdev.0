From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v3] arm: eBPF JIT compiler
Date: Mon, 21 Aug 2017 00:12:49 +0200
Message-ID: <599A0961.3010300@iogearbox.net>
References: <1503134429-29063-1-git-send-email-illusionist.neo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@fb.com,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        keescook@chromium.org, andrew@lunn.ch
To: Shubham Bansal <illusionist.neo@gmail.com>, linux@armlinux.org.uk,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43193 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753335AbdHTWNA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2017 18:13:00 -0400
In-Reply-To: <1503134429-29063-1-git-send-email-illusionist.neo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/19/2017 11:20 AM, Shubham Bansal wrote:
[...]
> diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
> index 61a0cb1..cc31f8b 100644
> --- a/arch/arm/Kconfig
> +++ b/arch/arm/Kconfig
> @@ -50,7 +50,7 @@ config ARM
>   	select HAVE_ARCH_SECCOMP_FILTER if (AEABI && !OABI_COMPAT)
>   	select HAVE_ARCH_TRACEHOOK
>   	select HAVE_ARM_SMCCC if CPU_V7
> -	select HAVE_CBPF_JIT
> +	select HAVE_EBPF_JIT
>   	select HAVE_CC_STACKPROTECTOR
>   	select HAVE_CONTEXT_TRACKING
>   	select HAVE_C_RECORDMCOUNT
> diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
> index d5b9fa1..ea7d079 100644
> --- a/arch/arm/net/bpf_jit_32.c
> +++ b/arch/arm/net/bpf_jit_32.c
> @@ -1,6 +1,7 @@
>   /*
> - * Just-In-Time compiler for BPF filters on 32bit ARM
> + * Just-In-Time compiler for eBPF filters on 32bit ARM
>    *
> + * Copyright (c) 2017 Shubham Bansal <illusionist.neo@gmail.com>
>    * Copyright (c) 2011 Mircea Gherzan <mgherzan@gmail.com>
>    *
>    * This program is free software; you can redistribute it and/or modify it
> @@ -8,6 +9,7 @@
>    * Free Software Foundation; version 2 of the License.
>    */
>
> +#include <linux/bpf.h>
>   #include <linux/bitops.h>
>   #include <linux/compiler.h>
>   #include <linux/errno.h>
> @@ -18,50 +20,96 @@
>   #include <linux/if_vlan.h>
>
>   #include <asm/cacheflush.h>
> -#include <asm/set_memory.h>
>   #include <asm/hwcap.h>
>   #include <asm/opcodes.h>
>
>   #include "bpf_jit_32.h"
>
> +int bpf_jit_enable __read_mostly;

[...]

With the below #ifdef __LITTLE_ENDIAN spanning the entire
bpf_int_jit_compile(), a user can then enable and compile
eBPF JIT for big endian, even set the bpf_jit_enable to 1
to turn it on, but it won't JIT anything, which is contrary
to the expectation.

This should rather be a hard dependency in the Kconfig, if
I got it correctly, expressed as e.g.

         select HAVE_EBPF_JIT if !CPU_ENDIAN_BE32

> +struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
>   {
> +#ifdef __LITTLE_ENDIAN
> +	struct bpf_prog *tmp, *orig_prog = prog;
>   	struct bpf_binary_header *header;
> +	bool tmp_blinded = false;
>   	struct jit_ctx ctx;
> -	unsigned tmp_idx;
> -	unsigned alloc_size;
> -	u8 *target_ptr;
> +	unsigned int tmp_idx;
> +	unsigned int image_size;
> +	u8 *image_ptr;
>
> +	/* If BPF JIT was not enabled then we must fall back to
> +	 * the interpreter.
> +	 */
>   	if (!bpf_jit_enable)
> -		return;
> +		return orig_prog;
>
> -	memset(&ctx, 0, sizeof(ctx));
> -	ctx.skf		= fp;
> -	ctx.ret0_fp_idx = -1;
> +	/* If constant blinding was enabled and we failed during blinding
> +	 * then we must fall back to the interpreter. Otherwise, we save
> +	 * the new JITed code.
> +	 */
> +	tmp = bpf_jit_blind_constants(prog);
>
> -	ctx.offsets = kzalloc(4 * (ctx.skf->len + 1), GFP_KERNEL);
> -	if (ctx.offsets == NULL)
> -		return;
> +	if (IS_ERR(tmp))
> +		return orig_prog;
> +	if (tmp != prog) {
> +		tmp_blinded = true;
> +		prog = tmp;
> +	}
> +
> +	memset(&ctx, 0, sizeof(ctx));
> +	ctx.prog = prog;
>
> -	/* fake pass to fill in the ctx->seen */
> -	if (unlikely(build_body(&ctx)))
> +	/* Not able to allocate memory for offsets[] , then
> +	 * we must fall back to the interpreter
> +	 */
> +	ctx.offsets = kcalloc(prog->len, sizeof(int), GFP_KERNEL);
> +	if (ctx.offsets == NULL) {
> +		prog = orig_prog;
>   		goto out;
> +	}
> +
> +	/* 1) fake pass to find in the length of the JITed code,
> +	 * to compute ctx->offsets and other context variables
> +	 * needed to compute final JITed code.
> +	 * Also, calculate random starting pointer/start of JITed code
> +	 * which is prefixed by random number of fault instructions.
> +	 *
> +	 * If the first pass fails then there is no chance of it
> +	 * being successful in the second pass, so just fall back
> +	 * to the interpreter.
> +	 */
> +	if (build_body(&ctx)) {
> +		prog = orig_prog;
> +		goto out_off;
> +	}
>
>   	tmp_idx = ctx.idx;
>   	build_prologue(&ctx);
>   	ctx.prologue_bytes = (ctx.idx - tmp_idx) * 4;
>
> +	ctx.epilogue_offset = ctx.idx;
> +
>   #if __LINUX_ARM_ARCH__ < 7
>   	tmp_idx = ctx.idx;
>   	build_epilogue(&ctx);
> @@ -1021,64 +1878,98 @@ void bpf_jit_compile(struct bpf_prog *fp)
>
>   	ctx.idx += ctx.imm_count;
>   	if (ctx.imm_count) {
> -		ctx.imms = kzalloc(4 * ctx.imm_count, GFP_KERNEL);
> -		if (ctx.imms == NULL)
> -			goto out;
> +		ctx.imms = kcalloc(ctx.imm_count, sizeof(u32), GFP_KERNEL);
> +		if (ctx.imms == NULL) {
> +			prog = orig_prog;
> +			goto out_off;
> +		}
>   	}
>   #else
> -	/* there's nothing after the epilogue on ARMv7 */
> +	/* there's nothing about the epilogue on ARMv7 */
>   	build_epilogue(&ctx);
>   #endif
> -	alloc_size = 4 * ctx.idx;
> -	header = bpf_jit_binary_alloc(alloc_size, &target_ptr,
> -				      4, jit_fill_hole);
> -	if (header == NULL)
> -		goto out;
> +	/* Now we can get the actual image size of the JITed arm code.
> +	 * Currently, we are not considering the THUMB-2 instructions
> +	 * for jit, although it can decrease the size of the image.
> +	 *
> +	 * As each arm instruction is of length 32bit, we are translating
> +	 * number of JITed intructions into the size required to store these
> +	 * JITed code.
> +	 */
> +	image_size = sizeof(u32) * ctx.idx;
> +
> +	/* Now we know the size of the structure to make */
> +	header = bpf_jit_binary_alloc(image_size, &image_ptr,
> +				      sizeof(u32), jit_fill_hole);
> +	/* Not able to allocate memory for the structure then
> +	 * we must fall back to the interpretation
> +	 */
> +	if (header == NULL) {
> +		prog = orig_prog;
> +		goto out_imms;
> +	}
>
> -	ctx.target = (u32 *) target_ptr;
> +	/* 2.) Actual pass to generate final JIT code */
> +	ctx.target = (u32 *) image_ptr;
>   	ctx.idx = 0;
>
>   	build_prologue(&ctx);
> +
> +	/* If building the body of the JITed code fails somehow,
> +	 * we fall back to the interpretation.
> +	 */
>   	if (build_body(&ctx) < 0) {
> -#if __LINUX_ARM_ARCH__ < 7
> -		if (ctx.imm_count)
> -			kfree(ctx.imms);
> -#endif
> +		image_ptr = NULL;
>   		bpf_jit_binary_free(header);
> -		goto out;
> +		prog = orig_prog;
> +		goto out_imms;
>   	}
>   	build_epilogue(&ctx);
>
> +	/* 3.) Extra pass to validate JITed Code */
> +	if (validate_code(&ctx)) {
> +		image_ptr = NULL;
> +		bpf_jit_binary_free(header);
> +		prog = orig_prog;
> +		goto out_imms;
> +	}
>   	flush_icache_range((u32)header, (u32)(ctx.target + ctx.idx));
>
> -#if __LINUX_ARM_ARCH__ < 7
> -	if (ctx.imm_count)
> -		kfree(ctx.imms);
> -#endif
> -
>   	if (bpf_jit_enable > 1)
>   		/* there are 2 passes here */
> -		bpf_jit_dump(fp->len, alloc_size, 2, ctx.target);
> +		bpf_jit_dump(prog->len, image_size, 2, ctx.target);
>
>   	set_memory_ro((unsigned long)header, header->pages);
> -	fp->bpf_func = (void *)ctx.target;
> -	fp->jited = 1;
> -out:
> +	prog->bpf_func = (void *)ctx.target;
> +	prog->jited = 1;
> +	prog->jited_len = image_size;
> +
> +out_imms:
> +#if __LINUX_ARM_ARCH__ < 7
> +	if (ctx.imm_count)
> +		kfree(ctx.imms);
> +#endif
> +out_off:
>   	kfree(ctx.offsets);
> -	return;
> +out:
> +	if (tmp_blinded)
> +		bpf_jit_prog_release_other(prog, prog == orig_prog ?
> +					   tmp : orig_prog);
> +#endif /* __LITTLE_ENDIAN */
> +	return prog;
>   }
