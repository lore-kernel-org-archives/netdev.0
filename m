From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 2/2] sparc64: Add eBPF JIT.
Date: Wed, 19 Apr 2017 11:35:39 +0200
Message-ID: <58F72F6B.9060808@iogearbox.net>
References: <20170418.145823.444134784458713460.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org
To: David Miller <davem@davemloft.net>, sparclinux@vger.kernel.org
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <20170418.145823.444134784458713460.davem@davemloft.net>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/18/2017 08:58 PM, David Miller wrote:
>
> This is an eBPF JIT for sparc64.  All major features are supported
> except for tail calls.
>
> test_bpf passes with no failures and all tests are JIT'd, both with
> and without hardening enabled.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>
[...]

While going over the code again, I noticed two minor
things that could still be changed before applying:

> +struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
> +{
> +	struct bpf_prog *tmp, *orig_prog = prog;
> +	struct bpf_binary_header *header;
> +	bool tmp_blinded = false;
> +	struct jit_ctx ctx;
> +	u32 image_size;
> +	u8 *image_ptr;
> +	int pass;
> +
> +	if (!bpf_jit_enable)
> +		return orig_prog;
> +
> +	if (!prog || !prog->len)
> +		return orig_prog;

This condition can be removed, see also 93a73d442d37
("bpf, x86/arm64: remove useless checks on prog"), since
there's no way we could land here under such circumstance.

> +	tmp = bpf_jit_blind_constants(prog);
> +	/* If blinding was requested and we failed during blinding,
> +	 * we must fall back to the interpreter.
> +	 */
> +	if (IS_ERR(tmp))
> +		return orig_prog;
> +	if (tmp != prog) {
> +		tmp_blinded = true;
> +		prog = tmp;
> +	}
> +
> +	memset(&ctx, 0, sizeof(ctx));
> +	ctx.prog = prog;
> +
> +	ctx.offset = kcalloc(prog->len, sizeof(unsigned int), GFP_KERNEL);
> +	if (ctx.offset == NULL) {
> +		prog = orig_prog;
> +		goto out;
> +	}
> +
> +	/* Fake pass to detect features used, and get an accurate assessment
> +	 * of what the final image size will be.
> +	 */
> +	if (build_body(&ctx)) {
> +		prog = orig_prog;
> +		goto out_off;
> +	}
> +	build_prologue(&ctx);
> +	build_epilogue(&ctx);
> +
> +	/* Now we know the actual image size. */
> +	image_size = sizeof(u32) * ctx.idx;
> +	header = bpf_jit_binary_alloc(image_size, &image_ptr,
> +				      sizeof(u32), jit_fill_hole);
> +	if (header == NULL) {
> +		prog = orig_prog;
> +		goto out_off;
> +	}
> +
> +	ctx.image = (u32 *)image_ptr;
> +
> +	for (pass = 1; pass < 3; pass++) {
> +		ctx.idx = 0;
> +
> +		build_prologue(&ctx);
> +
> +		if (build_body(&ctx)) {
> +			bpf_jit_binary_free(header);
> +			prog = orig_prog;
> +			goto out_off;
> +		}
> +
> +		build_epilogue(&ctx);
> +
> +		if (bpf_jit_enable > 1)
> +			pr_info("Pass %d: shrink = %d, seen = [%c%c%c%c%c]\n", pass,
> +				image_size - (ctx.idx * 4),
> +				ctx.tmp_1_used ? '1' : ' ',
> +				ctx.tmp_2_used ? '2' : ' ',
> +				ctx.tmp_3_used ? '3' : ' ',
> +				ctx.saw_ld_abs_ind ? 'L' : ' ',
> +				ctx.saw_frame_pointer ? 'F' : ' ');
> +	}
> +
> +	if (bpf_jit_enable > 1)
> +		bpf_jit_dump(prog->len, image_size, pass, ctx.image);
> +	bpf_flush_icache(ctx.image, ctx.image + image_size);

Since remaining parts were filled through jit_fill_hole(),
it would be better / more correct to flush the whole buffer,
see also the recent ppc64 commit 10528b9c45cf ("powerpc/bpf:
Flush the entire JIT buffer") that fixed it for their jit.

> +	bpf_jit_binary_lock_ro(header);
> +
> +	prog->bpf_func = (void *)ctx.image;
> +	prog->jited = 1;
> +
> +out_off:
> +	kfree(ctx.offset);

Thanks a lot,
Daniel
