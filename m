From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 2/3] bpf: Track alignment of MAP pointers in verifier.
Date: Sun, 14 May 2017 16:31:10 +0200
Message-ID: <59186A2E.2010904@iogearbox.net>
References: <20170512.222856.46437864475991511.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52116 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753421AbdENObQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 14 May 2017 10:31:16 -0400
In-Reply-To: <20170512.222856.46437864475991511.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/13/2017 04:28 AM, David Miller wrote:
>
> Just like packet pointers, track the known alignment of MAP pointers.
>
> In order to facilitate the state tracking, move the register offset
> field into where there is an unused 32-bit padding slot on 64-bit.
>
> The check logic is the same as for packet pointers, except we do not
> apply NET_IP_ALIGN to the calculations.
>
> Also, there are several restrictions that apply to packet pointers
> which we do not extend to MAP pointers.  For example, the
> MAX_PACKET_OFF limitation and the "adding integer with < 48 upper zero
> bits" thing.
>
> When we add a variable to the MAP pointer, all of the state
> transitions are identical except that we elide the reg->range clear
> because it is a packet pointer specific piece of state.
>
> This changes the string emitted when an unaligned access is trapped by
> the verifier.  Therefore, we need to adjust the search string used by
> test_verifier.c
>
> Signed-off-by: David S. Miller <davem@davemloft.net>

(Sorry for late reply, still thinking/reviewing on it.)

[...]
> @@ -823,10 +825,27 @@ static int check_pkt_ptr_alignment(const struct bpf_reg_state *reg,
>   }
>
>   static int check_val_ptr_alignment(const struct bpf_reg_state *reg,
> -				   int size, bool strict)
> +				   int off, int size, bool strict)
>   {
> -	if (strict && size != 1) {
> -		verbose("Unknown alignment. Only byte-sized access allowed in value access.\n");
> +	int reg_off;
> +
> +	/* Byte size accesses are always allowed. */
> +	if (!strict || size == 1)
> +		return 0;
> +
> +	reg_off = reg->off;
> +	if (reg->id) {
> +		if (reg->aux_off_align % size) {
> +			verbose("Value access is only %u byte aligned, %d byte access not allowed\n",
> +				reg->aux_off_align, size);
> +			return -EACCES;
> +		}
> +		reg_off += reg->aux_off;
> +	}

What are the semantics of using id here? In ptr_to_pkt, we have it, so
that eventually, in find_good_pkt_pointers() we can match on id and update
the range for all such regs with the same id. I'm just wondering as the
side effect of this is that this makes state pruning worse.

Also, reg->off is currently only used in ptr_to_pkt types and checked as
well in check_packet_access(). Now as semantics change, do we need to check
for it as well in check_map_access_adj() which we currently don't do?

> +	if ((reg_off + off) % size != 0) {
> +		verbose("misaligned value access off %d+%d size %d\n",
> +			reg_off, off, size);
>   		return -EACCES;
>   	}
>
> @@ -846,7 +865,7 @@ static int check_ptr_alignment(struct bpf_verifier_env *env,
>   	case PTR_TO_PACKET:
>   		return check_pkt_ptr_alignment(reg, off, size, strict);
>   	case PTR_TO_MAP_VALUE_ADJ:
> -		return check_val_ptr_alignment(reg, size, strict);
> +		return check_val_ptr_alignment(reg, off, size, strict);
>   	default:
>   		if (off % size != 0) {
>   			verbose("misaligned access off %d size %d\n",
[...]
> -static int check_packet_ptr_add(struct bpf_verifier_env *env,
> -				struct bpf_insn *insn)
> +static int check_pointer_add(struct bpf_verifier_env *env,
> +			     struct bpf_insn *insn, bool is_packet)
>   {
>   	struct bpf_reg_state *regs = env->cur_state.regs;
>   	struct bpf_reg_state *dst_reg = &regs[insn->dst_reg];
> @@ -1468,28 +1489,28 @@ static int check_packet_ptr_add(struct bpf_verifier_env *env,
>   	s32 imm;
>
>   	if (BPF_SRC(insn->code) == BPF_K) {
> -		/* pkt_ptr += imm */
> +		/* pointer += imm */
>   		imm = insn->imm;
>
>   add_imm:
> -		if (imm < 0) {
> -			verbose("addition of negative constant to packet pointer is not allowed\n");
> -			return -EACCES;
> -		}
> -		if (imm >= MAX_PACKET_OFF ||
> -		    imm + dst_reg->off >= MAX_PACKET_OFF) {
> -			verbose("constant %d is too large to add to packet pointer\n",
> -				imm);
> -			return -EACCES;
> +		if (is_packet) {
> +			if (imm < 0) {
> +				verbose("addition of negative constant to packet pointer is not allowed\n");
> +				return -EACCES;
> +			}
> +			if (imm >= MAX_PACKET_OFF ||
> +			    imm + dst_reg->off >= MAX_PACKET_OFF) {
> +				verbose("constant %d is too large to add to packet pointer\n",
> +					imm);
> +				return -EACCES;
> +			}
>   		}
> -		/* a constant was added to pkt_ptr.
> +		/* a constant was added to the pointer.
>   		 * Remember it while keeping the same 'id'
>   		 */
>   		dst_reg->off += imm;

Can this now overflow for map type? Also in the UNKNOWN_VALUE case
below since overflow checks are then only enforced in ptr_to_pkt case?

>   	} else {
> -		bool had_id;
> -
> -		if (src_reg->type == PTR_TO_PACKET) {
> +		if (is_packet && src_reg->type == PTR_TO_PACKET) {
>   			/* R6=pkt(id=0,off=0,r=62) R7=imm22; r7 += r6 */
>   			tmp_reg = *dst_reg;  /* save r7 state */
>   			*dst_reg = *src_reg; /* copy pkt_ptr state r6 into r7 */

I believe clang could probably generate something similar also for
map value pointers.

> @@ -1503,46 +1524,62 @@ static int check_packet_ptr_add(struct bpf_verifier_env *env,
>   		}
>
>   		if (src_reg->type == CONST_IMM) {
> -			/* pkt_ptr += reg where reg is known constant */
> +			/* pointer += reg where reg is known constant */
>   			imm = src_reg->imm;
>   			goto add_imm;
>   		}
> -		/* disallow pkt_ptr += reg
> +		/* disallow pointer += reg
>   		 * if reg is not uknown_value with guaranteed zero upper bits
> -		 * otherwise pkt_ptr may overflow and addition will become
> +		 * otherwise pointer_ptr may overflow and addition will become
>   		 * subtraction which is not allowed
>   		 */
>   		if (src_reg->type != UNKNOWN_VALUE) {
> -			verbose("cannot add '%s' to ptr_to_packet\n",
> +			verbose("cannot add '%s' to pointer\n",
>   				reg_type_str[src_reg->type]);
>   			return -EACCES;
>   		}
> -		if (src_reg->imm < 48) {
> +		if (is_packet && src_reg->imm < 48) {
>   			verbose("cannot add integer value with %lld upper zero bits to ptr_to_packet\n",
>   				src_reg->imm);
>   			return -EACCES;
>   		}
>
> -		had_id = (dst_reg->id != 0);
> -
> -		/* dst_reg stays as pkt_ptr type and since some positive
> +		/* dst_reg stays as the same type and since some positive
>   		 * integer value was added to the pointer, increment its 'id'
>   		 */
>   		dst_reg->id = ++env->id_gen;
>
> -		/* something was added to pkt_ptr, set range to zero */
>   		dst_reg->aux_off += dst_reg->off;
>   		dst_reg->off = 0;
> -		dst_reg->range = 0;
> -		if (had_id)
> +
> +		if (is_packet) {
> +			/* something was added to packet ptr, set range to zero */
> +			dst_reg->range = 0;
> +		}
> +		if (dst_reg->aux_off_align) {
>   			dst_reg->aux_off_align = min(dst_reg->aux_off_align,
