From: Alexei Starovoitov via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [RFC PATCH net-next 3/5] bpf/verifier: feed
 pointer-to-unknown-scalar casts into scalar ALU path
Date: Wed, 7 Jun 2017 19:35:42 -0700
Message-ID: <20170608023540.5ecmmobhl2rtgrg5@ast-mbp>
References: <92db9689-af6a-e172-ba57-195e588f9cc0@solarflare.com>
	<47ecf6ca-ae89-7fc3-3cd5-a47009b6ede9@solarflare.com>
Reply-To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <47ecf6ca-ae89-7fc3-3cd5-a47009b6ede9-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 07, 2017 at 03:58:50PM +0100, Edward Cree wrote:
> If pointer leaks are allowed, and adjust_ptr_min_max_vals returns -EACCES,
>  treat the pointer as an unknown scalar and try again, because we might be
>  able to conclude something about the result (e.g. pointer & 0x40 is either
>  0 or 0x40).
> 
> Signed-off-by: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
> ---
>  kernel/bpf/verifier.c | 244 ++++++++++++++++++++++++++------------------------
>  1 file changed, 127 insertions(+), 117 deletions(-)
> 
> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> index dd06e4e..1ff5b5d 100644
> --- a/kernel/bpf/verifier.c
> +++ b/kernel/bpf/verifier.c
> @@ -1566,6 +1566,8 @@ static void coerce_reg_to_32(struct bpf_reg_state *reg)
>  /* Handles arithmetic on a pointer and a scalar: computes new min/max and align.
>   * Caller must check_reg_overflow all argument regs beforehand.
>   * Caller should also handle BPF_MOV case separately.
> + * If we return -EACCES, caller may want to try again treating pointer as a
> + * scalar.  So we only emit a diagnostic if !env->allow_ptr_leaks.
>   */
>  static int adjust_ptr_min_max_vals(struct bpf_verifier_env *env,
>  				   struct bpf_insn *insn,
> @@ -1588,43 +1590,29 @@ static int adjust_ptr_min_max_vals(struct bpf_verifier_env *env,
>  
>  	if (BPF_CLASS(insn->code) != BPF_ALU64) {
>  		/* 32-bit ALU ops on pointers produce (meaningless) scalars */
> -		if (!env->allow_ptr_leaks) {
> +		if (!env->allow_ptr_leaks)
>  			verbose("R%d 32-bit pointer arithmetic prohibited\n",
>  				dst);
> -			return -EACCES;
> -		}
> -		__mark_reg_unknown(dst_reg);
> -		/* High bits are known zero */
> -		dst_reg->align.mask = (u32)-1;
> -		return 0;
> +		return -EACCES;
>  	}
>  
>  	if (ptr_reg->type == PTR_TO_MAP_VALUE_OR_NULL) {
> -		if (!env->allow_ptr_leaks) {
> +		if (!env->allow_ptr_leaks)
>  			verbose("R%d pointer arithmetic on PTR_TO_MAP_VALUE_OR_NULL prohibited, null-check it first\n",
>  				dst);
> -			return -EACCES;
> -		}
> -		__mark_reg_unknown(dst_reg);
> -		return 0;
> +		return -EACCES;
>  	}
>  	if (ptr_reg->type == CONST_PTR_TO_MAP) {
> -		if (!env->allow_ptr_leaks) {
> +		if (!env->allow_ptr_leaks)
>  			verbose("R%d pointer arithmetic on CONST_PTR_TO_MAP prohibited\n",
>  				dst);
> -			return -EACCES;
> -		}
> -		__mark_reg_unknown(dst_reg);
> -		return 0;
> +		return -EACCES;
>  	}
>  	if (ptr_reg->type == PTR_TO_PACKET_END) {
> -		if (!env->allow_ptr_leaks) {
> +		if (!env->allow_ptr_leaks)
>  			verbose("R%d pointer arithmetic on PTR_TO_PACKET_END prohibited\n",
>  				dst);
> -			return -EACCES;
> -		}
> -		__mark_reg_unknown(dst_reg);
> -		return 0;
> +		return -EACCES;
>  	}
>  
>  	/* In case of 'scalar += pointer', dst_reg inherits pointer type and id.
> @@ -1648,8 +1636,9 @@ static int adjust_ptr_min_max_vals(struct bpf_verifier_env *env,
>  			break;
>  		}
>  		if (max_val == BPF_REGISTER_MAX_RANGE) {
> -			verbose("R%d tried to add unbounded value to pointer\n",
> -				dst);
> +			if (!env->allow_ptr_leaks)
> +				verbose("R%d tried to add unbounded value to pointer\n",
> +					dst);
>  			return -EACCES;
>  		}
>  		/* A new variable offset is created.  Note that off_reg->off
> @@ -1676,28 +1665,20 @@ static int adjust_ptr_min_max_vals(struct bpf_verifier_env *env,
>  	case BPF_SUB:
>  		if (dst_reg == off_reg) {
>  			/* scalar -= pointer.  Creates an unknown scalar */
> -			if (!env->allow_ptr_leaks) {
> +			if (!env->allow_ptr_leaks)
>  				verbose("R%d tried to subtract pointer from scalar\n",
>  					dst);
> -				return -EACCES;
> -			}
> -			/* Make it an unknown scalar */
> -			__mark_reg_unknown(dst_reg);
> -			break;
> +			return -EACCES;
>  		}
>  		/* We don't allow subtraction from FP, because (according to
>  		 * test_verifier.c test "invalid fp arithmetic", JITs might not
>  		 * be able to deal with it.
>  		 */
>  		if (ptr_reg->type == PTR_TO_STACK) {
> -			if (!env->allow_ptr_leaks) {
> +			if (!env->allow_ptr_leaks)
>  				verbose("R%d subtraction from stack pointer prohibited\n",
>  					dst);
> -				return -EACCES;
> -			}
> -			/* Make it an unknown scalar */
> -			__mark_reg_unknown(dst_reg);
> -			break;
> +			return -EACCES;
>  		}
>  		if (known && (ptr_reg->off - min_val ==
>  			      (s64)(s32)(ptr_reg->off - min_val))) {
> @@ -1713,14 +1694,10 @@ static int adjust_ptr_min_max_vals(struct bpf_verifier_env *env,
>  		 * This can happen if off_reg is an immediate.
>  		 */
>  		if ((s64)max_val < 0) {
> -			if (!env->allow_ptr_leaks) {
> +			if (!env->allow_ptr_leaks)
>  				verbose("R%d tried to subtract negative max_val %lld from pointer\n",
>  					dst, (s64)max_val);
> -				return -EACCES;
> -			}
> -			/* Make it an unknown scalar */
> -			__mark_reg_unknown(dst_reg);
> -			break;
> +			return -EACCES;
>  		}
>  		/* A new variable offset is created.  If the subtrahend is known
>  		 * nonnegative, then any reg->range we had before is still good.
> @@ -1747,99 +1724,37 @@ static int adjust_ptr_min_max_vals(struct bpf_verifier_env *env,
>  		 * (However, in principle we could allow some cases, e.g.
>  		 * ptr &= ~3 which would reduce min_value by 3.)
>  		 */
> -		if (!env->allow_ptr_leaks) {
> +		if (!env->allow_ptr_leaks)
>  			verbose("R%d bitwise operator %s on pointer prohibited\n",
>  				dst, bpf_alu_string[opcode >> 4]);
> -			return -EACCES;
> -		}
> -		/* Make it an unknown scalar */
> -		__mark_reg_unknown(dst_reg);
> +		return -EACCES;
>  	default:
>  		/* other operators (e.g. MUL,LSH) produce non-pointer results */
> -		if (!env->allow_ptr_leaks) {
> +		if (!env->allow_ptr_leaks)
>  			verbose("R%d pointer arithmetic with %s operator prohibited\n",
>  				dst, bpf_alu_string[opcode >> 4]);
> -			return -EACCES;
> -		}
> -		/* Make it an unknown scalar */
> -		__mark_reg_unknown(dst_reg);
> +		return -EACCES;
>  	}
>  
>  	check_reg_overflow(dst_reg);
>  	return 0;
>  }
>  
> -/* Handles ALU ops other than BPF_END, BPF_NEG and BPF_MOV: computes new min/max
> - * and align.
> - * TODO: check this is legit for ALU32, particularly around negatives
> - */
> -static int adjust_reg_min_max_vals(struct bpf_verifier_env *env,
> -				   struct bpf_insn *insn)
> +static int adjust_scalar_min_max_vals(struct bpf_verifier_env *env,
> +				      struct bpf_insn *insn,
> +				      struct bpf_reg_state *dst_reg,
> +				      struct bpf_reg_state *src_reg)
>  {
> -	struct bpf_reg_state *regs = env->cur_state.regs, *dst_reg, *src_reg;
> -	struct bpf_reg_state *ptr_reg = NULL, off_reg = {0};
> +	struct bpf_reg_state *regs = env->cur_state.regs;
>  	s64 min_val = BPF_REGISTER_MIN_RANGE;
>  	u64 max_val = BPF_REGISTER_MAX_RANGE;
>  	u8 opcode = BPF_OP(insn->code);
>  	bool src_known, dst_known;
>  
> -	dst_reg = &regs[insn->dst_reg];
> -	check_reg_overflow(dst_reg);
> -	src_reg = NULL;
> -	if (dst_reg->type != SCALAR_VALUE)
> -		ptr_reg = dst_reg;
> -	if (BPF_SRC(insn->code) == BPF_X) {
> -		src_reg = &regs[insn->src_reg];
> -		check_reg_overflow(src_reg);
> -
> -		if (src_reg->type != SCALAR_VALUE) {
> -			if (dst_reg->type != SCALAR_VALUE) {
> -				/* Combining two pointers by any ALU op yields
> -				 * an arbitrary scalar.
> -				 */
> -				if (!env->allow_ptr_leaks) {
> -					verbose("R%d pointer %s pointer prohibited\n",
> -						insn->dst_reg,
> -						bpf_alu_string[opcode >> 4]);
> -					return -EACCES;
> -				}
> -				mark_reg_unknown(regs, insn->dst_reg);
> -				return 0;
> -			} else {
> -				/* scalar += pointer
> -				 * This is legal, but we have to reverse our
> -				 * src/dest handling in computing the range
> -				 */
> -				return adjust_ptr_min_max_vals(env, insn,
> -							       src_reg, dst_reg);
> -			}
> -		} else if (ptr_reg) {
> -			/* pointer += scalar */
> -			return adjust_ptr_min_max_vals(env, insn,
> -						       dst_reg, src_reg);
> -		}
> -	} else {
> -		/* Pretend the src is a reg with a known value, since we only
> -		 * need to be able to read from this state.
> -		 */
> -		off_reg.type = SCALAR_VALUE;
> -		off_reg.align = tn_const(insn->imm);
> -		off_reg.min_value = insn->imm;
> -		off_reg.max_value = insn->imm;
> -		src_reg = &off_reg;
> -		if (ptr_reg) /* pointer += K */
> -			return adjust_ptr_min_max_vals(env, insn,
> -						       ptr_reg, src_reg);
> -	}
> -
> -	/* Got here implies adding two SCALAR_VALUEs */
> -	if (WARN_ON_ONCE(ptr_reg)) {
> -		verbose("verifier internal error\n");
> -		return -EINVAL;
> -	}
> -	if (WARN_ON(!src_reg)) {
> -		verbose("verifier internal error\n");
> -		return -EINVAL;

such large back and forth move doesn't help reviewing.
may be just merge it into previous patch?
Or keep that function in the right place in patch 2 already?
