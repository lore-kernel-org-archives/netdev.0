From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v3 net-next 02/12] bpf/verifier: rework value tracking
Date: Wed, 28 Jun 2017 17:15:10 +0200
Message-ID: <5953C7FE.1050205@iogearbox.net>
References: <adc11342-737f-4e06-bce3-f0a92b5594a5@solarflare.com> <2244b48b-f415-3239-6912-cb09f0abc546@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        iovisor-dev <iovisor-dev@lists.iovisor.org>
To: Edward Cree <ecree@solarflare.com>, davem@davemloft.net,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54785 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752057AbdF1PPS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 11:15:18 -0400
In-Reply-To: <2244b48b-f415-3239-6912-cb09f0abc546@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/27/2017 02:56 PM, Edward Cree wrote:
> Tracks value alignment by means of tracking known & unknown bits.
> Tightens some min/max value checks and fixes a couple of bugs therein.

You mean the one in relation to patch 1/12? Would be good to elaborate
here since otherwise this gets forgotten few weeks later.

Could you also document all the changes that verifier will then start
allowing for after the patch?

> If pointer leaks are allowed, and adjust_ptr_min_max_vals returns -EACCES,
>   treat the pointer as an unknown scalar and try again, because we might be
>   able to conclude something about the result (e.g. pointer & 0x40 is either
>   0 or 0x40).
>
> Signed-off-by: Edward Cree <ecree@solarflare.com>
[...]
>   /* check whether memory at (regno + off) is accessible for t = (read | write)
> @@ -899,52 +965,79 @@ static int check_mem_access(struct bpf_verifier_env *env, int insn_idx, u32 regn
>   	struct bpf_reg_state *reg = &state->regs[regno];
>   	int size, err = 0;
>
> -	if (reg->type == PTR_TO_STACK)
> -		off += reg->imm;
> -
>   	size = bpf_size_to_bytes(bpf_size);
>   	if (size < 0)
>   		return size;
>
[...]
> -	if (reg->type == PTR_TO_MAP_VALUE ||
> -	    reg->type == PTR_TO_MAP_VALUE_ADJ) {
> +	/* for access checks, reg->off is just part of off */
> +	off += reg->off;

Could you elaborate on why removing the reg->type == PTR_TO_STACK?
Also in context of below PTR_TO_CTX.

[...]
>   	} else if (reg->type == PTR_TO_CTX) {
> -		enum bpf_reg_type reg_type = UNKNOWN_VALUE;
> +		enum bpf_reg_type reg_type = SCALAR_VALUE;
>
>   		if (t == BPF_WRITE && value_regno >= 0 &&
>   		    is_pointer_value(env, value_regno)) {
>   			verbose("R%d leaks addr into ctx\n", value_regno);
>   			return -EACCES;
>   		}
> +		/* ctx accesses must be at a fixed offset, so that we can
> +		 * determine what type of data were returned.
> +		 */
> +		if (!tnum_is_const(reg->var_off)) {
> +			char tn_buf[48];
> +
> +			tnum_strn(tn_buf, sizeof(tn_buf), reg->var_off);
> +			verbose("variable ctx access var_off=%s off=%d size=%d",
> +				tn_buf, off, size);
> +			return -EACCES;
> +		}
> +		off += reg->var_off.value;

... f.e. in PTR_TO_CTX case the only access that is currently
allowed is LDX/STX with fixed offset from insn->off, which is
passed as off param to check_mem_access(). Can you elaborate on
off += reg->var_off.value? Meaning we make this more dynamic
as long as access is known const?

>   		err = check_ctx_access(env, insn_idx, off, size, t, &reg_type);
>   		if (!err && t == BPF_READ && value_regno >= 0) {
> -			mark_reg_unknown_value_and_range(state->regs,
> -							 value_regno);
> -			/* note that reg.[id|off|range] == 0 */
> +			/* ctx access returns either a scalar, or a
> +			 * PTR_TO_PACKET[_END].  In the latter case, we know
> +			 * the offset is zero.
> +			 */
> +			if (reg_type == SCALAR_VALUE)
> +				mark_reg_unknown(state->regs, value_regno);
> +			else
> +				mark_reg_known_zero(state->regs, value_regno);
> +			state->regs[value_regno].id = 0;
> +			state->regs[value_regno].off = 0;
> +			state->regs[value_regno].range = 0;
>   			state->regs[value_regno].type = reg_type;
> -			state->regs[value_regno].aux_off = 0;
> -			state->regs[value_regno].aux_off_align = 0;
>   		}
>
> -	} else if (reg->type == FRAME_PTR || reg->type == PTR_TO_STACK) {
> +	} else if (reg->type == PTR_TO_STACK) {
[...]
