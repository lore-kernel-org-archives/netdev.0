From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] sparc64: eBPF JIT
Date: Mon, 17 Apr 2017 18:12:45 -0700 (PDT)
Message-ID: <20170417.181245.1402412750148031248.davem@davemloft.net>
References: <20170416.233825.1748421481008153466.davem@davemloft.net>
        <20170417232740.GB96258@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sparclinux@vger.kernel.org, netdev@vger.kernel.org, ast@kernel.org,
        daniel@iogearbox.net
To: alexei.starovoitov@gmail.com
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <20170417232740.GB96258@ast-mbp.thefacebook.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Mon, 17 Apr 2017 16:27:42 -0700

> On Sun, Apr 16, 2017 at 11:38:25PM -0400, David Miller wrote:
>> +static void build_prologue(struct jit_ctx *ctx)
>> +{
>> +	s32 stack_needed = 176;
>> +
>> +	if (ctx->saw_frame_pointer)
>> +		stack_needed += MAX_BPF_STACK;
>> +
>> +	/* save %sp, -176, %sp */
>> +	emit(SAVE | IMMED | RS1(SP) | S13(-stack_needed) | RD(SP), ctx);
>> +
>> +	if (ctx->saw_ld_abs_ind) {
>> +		load_skb_regs(ctx, bpf2sparc[BPF_REG_1]);
>> +	} else {
>> +		emit_nop(ctx);
>> +		emit_nop(ctx);
>> +		emit_nop(ctx);
>> +		emit_nop(ctx);
> 
> why 4 nops? to keep prologue size constant w/ and w/o caching ?
> does it help somehow? I'm assuming that's prep for next step
> of tail_call.

I need to make some adjustments to how the branch offsets are done
if the prologue is variable size.  Simply an implementation issue,
which I intend to fix, nothing more.

> 
>> +	if (insn->src_reg == BPF_REG_FP || insn->dst_reg == BPF_REG_FP) {
>> +		ctx->saw_frame_pointer = true;
>> +		if (BPF_CLASS(code) == BPF_ALU ||
>> +		    BPF_CLASS(code) == BPF_ALU64) {
>> +			pr_err_once("ALU op on FP not supported by JIT\n");
>> +			return -EINVAL;
> 
> That should be fine. The verifier checks for that:
>   /* check whether register used as dest operand can be written to */
>   if (regno == BPF_REG_FP) {
>           verbose("frame pointer is read only\n");
>           return -EACCES;
>   }

I need to trap it as a source as well, because if that is allowed then
I have to add special handling to every ALU operation we allow.

The reason is that the sparc64 stack is biased by 2047 bytes.  So
I have to adjust every FP relative reference to include that 2047
bias.

Can LLVM and CLANG emit arithmetic operations with FP as source?

>> +	/* dst = imm64 */
>> +	case BPF_LD | BPF_IMM | BPF_DW:
>> +	{
>> +		const struct bpf_insn insn1 = insn[1];
>> +		u64 imm64;
>> +
>> +		if (insn1.code != 0 || insn1.src_reg != 0 ||
>> +		    insn1.dst_reg != 0 || insn1.off != 0) {
>> +			/* Note: verifier in BPF core must catch invalid
>> +			 * instructions.
>> +			 */
>> +			pr_err_once("Invalid BPF_LD_IMM64 instruction\n");
>> +			return -EINVAL;
> 
> verifier should catch that too, but extra check doesn't hurt.

I just copied from anoter JIT, I can remove it.

> all looks great to me.

Thanks for reviewing.

> 
