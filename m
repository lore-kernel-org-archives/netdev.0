From: Daniel Borkmann via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH v3 net-next 02/12] bpf/verifier: rework
	value tracking
Date: Wed, 28 Jun 2017 19:09:57 +0200
Message-ID: <5953E2E5.7040106@iogearbox.net>
References: <adc11342-737f-4e06-bce3-f0a92b5594a5@solarflare.com>
	<2244b48b-f415-3239-6912-cb09f0abc546@solarflare.com>
Reply-To: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <2244b48b-f415-3239-6912-cb09f0abc546-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
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

On 06/27/2017 02:56 PM, Edward Cree wrote:
> Tracks value alignment by means of tracking known & unknown bits.
> Tightens some min/max value checks and fixes a couple of bugs therein.
> If pointer leaks are allowed, and adjust_ptr_min_max_vals returns -EACCES,
>   treat the pointer as an unknown scalar and try again, because we might be
>   able to conclude something about the result (e.g. pointer & 0x40 is either
>   0 or 0x40).
>
> Signed-off-by: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
[...]
> +static int adjust_reg_min_max_vals(struct bpf_verifier_env *env,
> +				   struct bpf_insn *insn)
> +{
> +	struct bpf_reg_state *regs = env->cur_state.regs, *dst_reg, *src_reg;
> +	struct bpf_reg_state *ptr_reg = NULL, off_reg = {0};
> +	u8 opcode = BPF_OP(insn->code);
> +	int rc;
> +
> +	dst_reg = &regs[insn->dst_reg];
> +	check_reg_overflow(dst_reg);
> +	src_reg = NULL;
> +	if (dst_reg->type != SCALAR_VALUE)
> +		ptr_reg = dst_reg;
> +	if (BPF_SRC(insn->code) == BPF_X) {
> +		src_reg = &regs[insn->src_reg];
> +		check_reg_overflow(src_reg);
> +
> +		if (src_reg->type != SCALAR_VALUE) {
> +			if (dst_reg->type != SCALAR_VALUE) {
> +				/* Combining two pointers by any ALU op yields
> +				 * an arbitrary scalar.
> +				 */
> +				if (!env->allow_ptr_leaks) {
> +					verbose("R%d pointer %s pointer prohibited\n",
> +						insn->dst_reg,
> +						bpf_alu_string[opcode >> 4]);
> +					return -EACCES;
> +				}
> +				mark_reg_unknown(regs, insn->dst_reg);
> +				return 0;
> +			} else {
> +				/* scalar += pointer
> +				 * This is legal, but we have to reverse our
> +				 * src/dest handling in computing the range
> +				 */
> +				rc = adjust_ptr_min_max_vals(env, insn,
> +							     src_reg, dst_reg);
> +				if (rc == -EACCES && env->allow_ptr_leaks) {
> +					/* scalar += unknown scalar */
> +					__mark_reg_unknown(&off_reg);
> +					return adjust_scalar_min_max_vals(
> +							env, insn,
> +							dst_reg, &off_reg);

Could you elaborate on this one? If I understand it correctly, then
the scalar += pointer case would mean the following: given I have one
of the allowed pointer types in adjust_ptr_min_max_vals() then the
prior scalar type inherits the ptr type/id. I would then 'destroy' the
pointer value so we get a -EACCES on it. We mark the tmp off_reg as
scalar type, but shouldn't also actual dst_reg be marked as such
like in below pointer += scalar case, such that we undo the prior
ptr_type inheritance?

> +				}
> +				return rc;
> +			}
> +		} else if (ptr_reg) {
> +			/* pointer += scalar */
> +			rc = adjust_ptr_min_max_vals(env, insn,
> +						     dst_reg, src_reg);
> +			if (rc == -EACCES && env->allow_ptr_leaks) {
> +				/* unknown scalar += scalar */
> +				__mark_reg_unknown(dst_reg);
> +				return adjust_scalar_min_max_vals(
> +						env, insn, dst_reg, src_reg);
> +			}
> +			return rc;
> +		}
> +	} else {
[...]
