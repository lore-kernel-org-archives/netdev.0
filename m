From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH v2 net] x86: bpf_jit: fix two bugs in eBPF JIT compiler
Date: Mon, 13 Oct 2014 10:36:05 -0700
Message-ID: <20141013173605.GB30018@birch.djwong.org>
References: <1412998223-3805-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@kernel.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1412998223-3805-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 10, 2014 at 08:30:23PM -0700, Alexei Starovoitov wrote:
> 1.
> JIT compiler using multi-pass approach to converge to final image size,
> since x86 instructions are variable length. It starts with large
> gaps between instructions (so some jumps may use imm32 instead of imm8)
> and iterates until total program size is the same as in previous pass.
> This algorithm works only if program size is strictly decreasing.
> Programs that use LD_ABS insn need additional code in prologue, but it
> was not emitted during 1st pass, so there was a chance that 2nd pass would
> adjust imm32->imm8 jump offsets to the same number of bytes as increase in
> prologue, which may cause algorithm to erroneously decide that size converged.
> Fix it by always emitting largest prologue in the first pass which
> is detected by oldproglen==0 check.
> Also change error check condition 'proglen != oldproglen' to fail gracefully.
> 
> 2.
> while staring at the code realized that 64-byte buffer may not be enough
> when 1st insn is large, so increase it to 128 to avoid buffer overflow
> (theoretical maximum size of prologue+div is 109) and add runtime check.
> 
> Fixes: 622582786c9e ("net: filter: x86: internal BPF JIT")
> Reported-by: Darrick J. Wong <darrick.wong@oracle.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

This fixes the crash, thank you!

Tested-by: Darrick J. Wong <darrick.wong@oracle.com>

--D

> ---
> v1->v2: reduce chances of stack corruption in case of future bugs (suggested by Eric)
> 
> note in classic BPF programs 1st insn is always short move, but native eBPF
> programs may trigger buffer overflow. I couldn't force the crash with overflow,
> since there are no further calls while this part of stack is used.
> Both are ugly bugs regardless.
> When net-next opens I will add narrowed down testcase from 'nmap' to testsuite.
> 
>  arch/x86/net/bpf_jit_comp.c |   25 +++++++++++++++++++------
>  1 file changed, 19 insertions(+), 6 deletions(-)
> 
> diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
> index d56cd1f..3f62734 100644
> --- a/arch/x86/net/bpf_jit_comp.c
> +++ b/arch/x86/net/bpf_jit_comp.c
> @@ -182,12 +182,17 @@ struct jit_context {
>  	bool seen_ld_abs;
>  };
>  
> +/* maximum number of bytes emitted while JITing one eBPF insn */
> +#define BPF_MAX_INSN_SIZE	128
> +#define BPF_INSN_SAFETY		64
> +
>  static int do_jit(struct bpf_prog *bpf_prog, int *addrs, u8 *image,
>  		  int oldproglen, struct jit_context *ctx)
>  {
>  	struct bpf_insn *insn = bpf_prog->insnsi;
>  	int insn_cnt = bpf_prog->len;
> -	u8 temp[64];
> +	bool seen_ld_abs = ctx->seen_ld_abs | (oldproglen == 0);
> +	u8 temp[BPF_MAX_INSN_SIZE + BPF_INSN_SAFETY];
>  	int i;
>  	int proglen = 0;
>  	u8 *prog = temp;
> @@ -225,7 +230,7 @@ static int do_jit(struct bpf_prog *bpf_prog, int *addrs, u8 *image,
>  	EMIT2(0x31, 0xc0); /* xor eax, eax */
>  	EMIT3(0x4D, 0x31, 0xED); /* xor r13, r13 */
>  
> -	if (ctx->seen_ld_abs) {
> +	if (seen_ld_abs) {
>  		/* r9d : skb->len - skb->data_len (headlen)
>  		 * r10 : skb->data
>  		 */
> @@ -685,7 +690,7 @@ xadd:			if (is_imm8(insn->off))
>  		case BPF_JMP | BPF_CALL:
>  			func = (u8 *) __bpf_call_base + imm32;
>  			jmp_offset = func - (image + addrs[i]);
> -			if (ctx->seen_ld_abs) {
> +			if (seen_ld_abs) {
>  				EMIT2(0x41, 0x52); /* push %r10 */
>  				EMIT2(0x41, 0x51); /* push %r9 */
>  				/* need to adjust jmp offset, since
> @@ -699,7 +704,7 @@ xadd:			if (is_imm8(insn->off))
>  				return -EINVAL;
>  			}
>  			EMIT1_off32(0xE8, jmp_offset);
> -			if (ctx->seen_ld_abs) {
> +			if (seen_ld_abs) {
>  				EMIT2(0x41, 0x59); /* pop %r9 */
>  				EMIT2(0x41, 0x5A); /* pop %r10 */
>  			}
> @@ -804,7 +809,8 @@ emit_jmp:
>  			goto common_load;
>  		case BPF_LD | BPF_ABS | BPF_W:
>  			func = CHOOSE_LOAD_FUNC(imm32, sk_load_word);
> -common_load:		ctx->seen_ld_abs = true;
> +common_load:
> +			ctx->seen_ld_abs = seen_ld_abs = true;
>  			jmp_offset = func - (image + addrs[i]);
>  			if (!func || !is_simm32(jmp_offset)) {
>  				pr_err("unsupported bpf func %d addr %p image %p\n",
> @@ -878,6 +884,11 @@ common_load:		ctx->seen_ld_abs = true;
>  		}
>  
>  		ilen = prog - temp;
> +		if (ilen > BPF_MAX_INSN_SIZE) {
> +			pr_err("bpf_jit_compile fatal insn size error\n");
> +			return -EFAULT;
> +		}
> +
>  		if (image) {
>  			if (unlikely(proglen + ilen > oldproglen)) {
>  				pr_err("bpf_jit_compile fatal error\n");
> @@ -934,9 +945,11 @@ void bpf_int_jit_compile(struct bpf_prog *prog)
>  			goto out;
>  		}
>  		if (image) {
> -			if (proglen != oldproglen)
> +			if (proglen != oldproglen) {
>  				pr_err("bpf_jit: proglen=%d != oldproglen=%d\n",
>  				       proglen, oldproglen);
> +				goto out;
> +			}
>  			break;
>  		}
>  		if (proglen == oldproglen) {
> -- 
> 1.7.9.5
> 
