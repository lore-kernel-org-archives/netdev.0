From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/2] bpf: allow extended BPF programs access
 skb fields
Date: Fri, 13 Mar 2015 10:57:31 +0100
Message-ID: <5502B48B.7040909@iogearbox.net>
References: <1426213271-8363-1-git-send-email-ast@plumgrid.com> <1426213271-8363-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426213271-8363-2-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/13/2015 03:21 AM, Alexei Starovoitov wrote:
> introduce user accessible mirror of in-kernel 'struct sk_buff':
> struct __sk_buff {
>      __u32 len;
>      __u32 pkt_type;
>      __u32 mark;
>      __u32 ifindex;
>      __u32 queue_mapping;
> };
>
> bpf programs can do:
> struct __sk_buff *ptr;
> var = ptr->pkt_type;
>
> which will be compiled to bpf assembler as:
> dst_reg = *(u32 *)(src_reg + 4) // 4 == offsetof(struct __sk_buff, pkt_type)
>
> bpf verifier will check validity of access and will convert it to:
> dst_reg = *(u8 *)(src_reg + offsetof(struct sk_buff, __pkt_type_offset))
> dst_reg &= 7
>
> since 'pkt_type' is a bitfield.
>
> When pkt_type field is moved around, goes into different structure, removed or
> its size changes, the function sk_filter_convert_ctx_access() would need to be
> updated. Just like the function convert_bpf_extensions() in case of classic bpf.

For each member, I'd also add BUILD_BUG_ON()s similarly as we have in
convert_bpf_extensions(). That way, people won't forget to adjust the
code.

General idea for this offset map looks good, imho. Well defined members
that are already exported to uapi e.g. through classic socket filters or
other socket api places could be used here.

> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
...
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index 3fa1af8a58d7..66a82d6cd75b 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -168,4 +168,12 @@ enum bpf_func_id {
>   	__BPF_FUNC_MAX_ID,
>   };
>
> +struct __sk_buff {
> +	__u32 len;
> +	__u32 pkt_type;
> +	__u32 mark;
> +	__u32 ifindex;
> +	__u32 queue_mapping;
> +};

I'd add a comment saying that fields may _only_ be safely added at
the end of the structure. Rearranging or removing members here,
naturally would break user space.

The remaining fields we export in classic BPF would be skb->hash,
skb->protocol, skb->vlan_tci, are we adding them as well to match
up functionality with classic BPF? For example, I can see hash being
useful as a key to be used with eBPF maps, etc.

...
> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> index e6b522496250..c22ebd36fa4b 100644
> --- a/kernel/bpf/verifier.c
> +++ b/kernel/bpf/verifier.c
...
> +/* convert load instructions that access fields of 'struct __sk_buff'
> + * into sequence of instructions that access fields of 'struct sk_buff'
> + */
> +static int convert_ctx_accesses(struct verifier_env *env)
> +{
> +	struct bpf_insn *insn = env->prog->insnsi;
> +	int insn_cnt = env->prog->len;
> +	struct bpf_insn insn_buf[16];
> +	struct bpf_prog *new_prog;
> +	u32 cnt;
> +	int i;
> +
> +	if (!env->prog->aux->ops->convert_ctx_access)
> +		return 0;
> +
> +	for (i = 0; i < insn_cnt; i++, insn++) {
> +		if (insn->code != (BPF_LDX | BPF_MEM | BPF_W))
> +			continue;
> +
> +		if (insn->imm != PTR_TO_CTX) {
> +			/* clear internal mark */
> +			insn->imm = 0;
> +			continue;
> +		}
> +
> +		cnt = env->prog->aux->ops->
> +			convert_ctx_access(insn->dst_reg, insn->src_reg,
> +					   insn->off, insn_buf);
> +		if (cnt == 0 || cnt >= ARRAY_SIZE(insn_buf)) {
> +			verbose("bpf verifier is misconfigured\n");
> +			return -EINVAL;
> +		}
> +
> +		if (cnt == 1) {
> +			memcpy(insn, insn_buf, sizeof(*insn));
> +			continue;
> +		}
> +
> +		/* several new insns need to be inserted. Make room for them */
> +		insn_cnt += cnt - 1;
> +		new_prog = bpf_prog_realloc(env->prog,
> +					    bpf_prog_size(insn_cnt),
> +					    GFP_USER);
> +		if (!new_prog)
> +			return -ENOMEM;

Seems a bit expensive, do you think we could speculatively allocate a
bit more space in bpf_prog_load() when we detect that we have access
to ctx that we need to convert?

> +		new_prog->len = insn_cnt;
> +
> +		memmove(new_prog->insnsi + i + cnt, new_prog->insns + i + 1,
> +			sizeof(*insn) * (insn_cnt - i - cnt));
> +
> +		/* copy substitute insns in place of load instruction */
> +		memcpy(new_prog->insnsi + i, insn_buf, sizeof(*insn) * cnt);
> +
> +		/* adjust branches in the whole program */
> +		adjust_branches(new_prog, i, cnt - 1);
> +
> +		/* keep walking new program and skip insns we just inserted */
> +		env->prog = new_prog;
> +		insn = new_prog->insnsi + i + cnt - 1;
> +		i += cnt - 1;
> +	}
> +
> +	return 0;
> +}
> +
>   static void free_states(struct verifier_env *env)
>   {
>   	struct verifier_state_list *sl, *sln;
...
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 7a4eb7030dba..b5fcc7e2b608 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
...
> +
> +static u32 sk_filter_convert_ctx_access(int dst_reg, int src_reg, int ctx_off,
> +					struct bpf_insn *insn_buf)
> +{
> +	struct bpf_insn *insn = insn_buf;
> +
> +	switch (ctx_off) {
> +	case offsetof(struct __sk_buff, len):
> +		*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg,
> +				      offsetof(struct sk_buff, len));
> +		break;
> +
> +	case offsetof(struct __sk_buff, mark):
> +		*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg,
> +				      offsetof(struct sk_buff, mark));
> +		break;
> +
> +	case offsetof(struct __sk_buff, ifindex):
> +		*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg,
> +				      offsetof(struct sk_buff, skb_iif));
> +		break;

This would only work for incoming skbs, but not outgoing ones
f.e. in case of {cls,act}_bpf.

> +	case offsetof(struct __sk_buff, pkt_type):
> +		*insn++ = BPF_LDX_MEM(BPF_B, dst_reg, src_reg, PKT_TYPE_OFFSET());
> +		*insn++ = BPF_ALU32_IMM(BPF_AND, dst_reg, PKT_TYPE_MAX);
> +#ifdef __BIG_ENDIAN_BITFIELD
> +		*insn++ = BPF_ALU32_IMM(BPF_RSH, dst_reg, 5);
> +#endif
> +		break;
...
