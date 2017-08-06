From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v4 net-next 01/13] bpf/verifier: rework value tracking
Date: Mon, 07 Aug 2017 01:35:59 +0200
Message-ID: <5987A7DF.6080203@iogearbox.net>
References: <22441d84-0a11-5c00-2d2a-25e7dbafa6c2@solarflare.com> <8a5e37eb-2397-c986-79c5-02908fbbdee0@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        iovisor-dev <iovisor-dev@lists.iovisor.org>
To: Edward Cree <ecree@solarflare.com>, davem@davemloft.net,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8a5e37eb-2397-c986-79c5-02908fbbdee0@solarflare.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/03/2017 06:11 PM, Edward Cree wrote:
> Unifies adjusted and unadjusted register value types (e.g. FRAME_POINTER is
>   now just a PTR_TO_STACK with zero offset).
> Tracks value alignment by means of tracking known & unknown bits.  This
>   also replaces the 'reg->imm' (leading zero bits) calculations for (what
>   were) UNKNOWN_VALUEs.
> If pointer leaks are allowed, and adjust_ptr_min_max_vals returns -EACCES,
>   treat the pointer as an unknown scalar and try again, because we might be
>   able to conclude something about the result (e.g. pointer & 0x40 is either
>   0 or 0x40).
>
> Signed-off-by: Edward Cree <ecree@solarflare.com>
[...]
> +static int adjust_scalar_min_max_vals(struct bpf_verifier_env *env,
> +				      struct bpf_insn *insn,
> +				      struct bpf_reg_state *dst_reg,
> +				      struct bpf_reg_state *src_reg)
>   {
>   	struct bpf_reg_state *regs = env->cur_state.regs;
[...]
> -	} else if (insn->imm < BPF_REGISTER_MAX_RANGE &&
> -		   (s64)insn->imm > BPF_REGISTER_MIN_RANGE) {
> -		min_val = max_val = insn->imm;
> -		src_align = calc_align(insn->imm);
> +	if (BPF_CLASS(insn->code) != BPF_ALU64) {
> +		/* 32-bit ALU ops are (32,32)->64 */
> +		coerce_reg_to_32(dst_reg);
> +		coerce_reg_to_32(src_reg);
>   	}
> -
[...]
> -			dst_reg->max_value = BPF_REGISTER_MAX_RANGE;
> +	if (BPF_CLASS(insn->code) != BPF_ALU64) {
> +		/* 32-bit ALU ops are (32,32)->64 */
> +		coerce_reg_to_32(dst_reg);
> +		coerce_reg_to_32(src_reg);
>   	}

Looks like the same check was added twice here right after
the first one? Shouldn't we just temporarily coerce the src
reg to 32 bit here given in the actual op the src reg is not
being modified?

Thanks,
Daniel

> +	min_val = src_reg->min_value;
> +	max_val = src_reg->max_value;
> +	src_known = tnum_is_const(src_reg->var_off);
> +	dst_known = tnum_is_const(dst_reg->var_off);
>
>   	switch (opcode) {
