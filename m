From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH RFC] sparc64: eBPF JIT
Date: Mon, 17 Apr 2017 16:27:42 -0700
Message-ID: <20170417232740.GB96258@ast-mbp.thefacebook.com>
References: <20170416.233825.1748421481008153466.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sparclinux@vger.kernel.org, netdev@vger.kernel.org, ast@kernel.org,
        daniel@iogearbox.net
To: David Miller <davem@davemloft.net>
Return-path: <sparclinux-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170416.233825.1748421481008153466.davem@davemloft.net>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 16, 2017 at 11:38:25PM -0400, David Miller wrote:
> 
> There are a bunch of things I want to do still, and I know that I have
> to attend to sparc32 more cleanly, but I wanted to post this now that
> I have it passing the BPF testsuite completely:
> 
> [24174.315421] test_bpf: Summary: 305 PASSED, 0 FAILED, [297/297 JIT'ed]

Nice!

> +static void build_prologue(struct jit_ctx *ctx)
> +{
> +	s32 stack_needed = 176;
> +
> +	if (ctx->saw_frame_pointer)
> +		stack_needed += MAX_BPF_STACK;
> +
> +	/* save %sp, -176, %sp */
> +	emit(SAVE | IMMED | RS1(SP) | S13(-stack_needed) | RD(SP), ctx);
> +
> +	if (ctx->saw_ld_abs_ind) {
> +		load_skb_regs(ctx, bpf2sparc[BPF_REG_1]);
> +	} else {
> +		emit_nop(ctx);
> +		emit_nop(ctx);
> +		emit_nop(ctx);
> +		emit_nop(ctx);

why 4 nops? to keep prologue size constant w/ and w/o caching ?
does it help somehow? I'm assuming that's prep for next step
of tail_call.

> +	if (insn->src_reg == BPF_REG_FP || insn->dst_reg == BPF_REG_FP) {
> +		ctx->saw_frame_pointer = true;
> +		if (BPF_CLASS(code) == BPF_ALU ||
> +		    BPF_CLASS(code) == BPF_ALU64) {
> +			pr_err_once("ALU op on FP not supported by JIT\n");
> +			return -EINVAL;

That should be fine. The verifier checks for that:
  /* check whether register used as dest operand can be written to */
  if (regno == BPF_REG_FP) {
          verbose("frame pointer is read only\n");
          return -EACCES;
  }

> +	/* dst = imm64 */
> +	case BPF_LD | BPF_IMM | BPF_DW:
> +	{
> +		const struct bpf_insn insn1 = insn[1];
> +		u64 imm64;
> +
> +		if (insn1.code != 0 || insn1.src_reg != 0 ||
> +		    insn1.dst_reg != 0 || insn1.off != 0) {
> +			/* Note: verifier in BPF core must catch invalid
> +			 * instructions.
> +			 */
> +			pr_err_once("Invalid BPF_LD_IMM64 instruction\n");
> +			return -EINVAL;

verifier should catch that too, but extra check doesn't hurt.

> +	/* STX XADD: lock *(u32 *)(dst + off) += src */
> +	case BPF_STX | BPF_XADD | BPF_W: {
> +		const u8 tmp = bpf2sparc[TMP_REG_1];
> +		const u8 tmp2 = bpf2sparc[TMP_REG_2];
> +		const u8 tmp3 = bpf2sparc[TMP_REG_3];
> +		s32 real_off = off;
> +
> +		ctx->tmp_1_used = true;
> +		ctx->tmp_2_used = true;
> +		ctx->tmp_3_used = true;
> +		if (dst == FP)
> +			real_off += STACK_BIAS;
> +		emit_loadimm(real_off, tmp, ctx);
> +		emit_alu3(ADD, dst, tmp, tmp, ctx);
> +
> +		emit(LD32 | RS1(tmp) | RS2(G0) | RD(tmp2), ctx);
> +		emit_alu3(ADD, tmp2, src, tmp3, ctx);
> +		emit(CAS | ASI(ASI_P) | RS1(tmp) | RS2(tmp2) | RD(tmp3), ctx);
> +		emit_cmp(tmp2, tmp3, ctx);
> +		emit_branch(BNE, 4, 0, ctx);
> +		emit_nop(ctx);

loops in bpf code! run for your life ;)

> +	if (bpf_jit_enable > 1)
> +		bpf_jit_dump(prog->len, image_size, 2, ctx.image);
> +	bpf_flush_icache(ctx.image, ctx.image + image_size);
> +
> +	bpf_jit_binary_lock_ro(header);

all looks great to me.
Thanks!

