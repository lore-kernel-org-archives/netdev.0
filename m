From: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Subject: Re: [PATCH v2 net-next 1/2] bpf: allow extended BPF programs access
 skb fields
Date: Sat, 14 Mar 2015 02:46:31 +0100
Message-ID: <550392F7.9040308@iogearbox.net>
References: <1426273064-4837-1-git-send-email-ast@plumgrid.com> <1426273064-4837-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1426273064-4837-2-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/13/2015 07:57 PM, Alexei Starovoitov wrote:
> introduce user accessible mirror of in-kernel 'struct sk_buff':
> struct __sk_buff {
>      __u32 len;
>      __u32 pkt_type;
>      __u32 mark;
>      __u32 queue_mapping;
> };
>
> bpf programs can do:
>
> int bpf_prog(struct __sk_buff *skb)
> {
>      __u32 var = skb->pkt_type;
>
> which will be compiled to bpf assembler as:
>
> dst_reg = *(u32 *)(src_reg + 4) // 4 == offsetof(struct __sk_buff, pkt_type)
>
> bpf verifier will check validity of access and will convert it to:
>
> dst_reg = *(u8 *)(src_reg + offsetof(struct sk_buff, __pkt_type_offset))
> dst_reg &= 7
>
> since skb->pkt_type is a bitfield.
>
> Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
...
> +static u32 convert_skb_access(int skb_field, int dst_reg, int src_reg,
> +			      struct bpf_insn *insn_buf)
> +{
> +	struct bpf_insn *insn = insn_buf;
> +
> +	switch (skb_field) {
> +	case SKF_AD_MARK:
> +		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, mark) != 4);
> +
> +		*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg,
> +				      offsetof(struct sk_buff, mark));
> +		break;
> +
> +	case SKF_AD_PKTTYPE:
> +		*insn++ = BPF_LDX_MEM(BPF_B, dst_reg, src_reg, PKT_TYPE_OFFSET());
> +		*insn++ = BPF_ALU32_IMM(BPF_AND, dst_reg, PKT_TYPE_MAX);
> +#ifdef __BIG_ENDIAN_BITFIELD
> +		*insn++ = BPF_ALU32_IMM(BPF_RSH, dst_reg, 5);
> +#endif
> +		break;
> +
> +	case SKF_AD_QUEUE:
> +		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, queue_mapping) != 2);
> +
> +		*insn++ = BPF_LDX_MEM(BPF_H, dst_reg, src_reg,
> +				      offsetof(struct sk_buff, queue_mapping));
> +		break;
> +	}
> +
> +	return insn - insn_buf;
> +}
> +
>   static bool convert_bpf_extensions(struct sock_filter *fp,
>   				   struct bpf_insn **insnp)
>   {
>   	struct bpf_insn *insn = *insnp;
> +	u32 cnt;
>
>   	switch (fp->k) {
>   	case SKF_AD_OFF + SKF_AD_PROTOCOL:
> @@ -167,13 +200,8 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
>   		break;
>
>   	case SKF_AD_OFF + SKF_AD_PKTTYPE:
> -		*insn++ = BPF_LDX_MEM(BPF_B, BPF_REG_A, BPF_REG_CTX,
> -				      PKT_TYPE_OFFSET());
> -		*insn = BPF_ALU32_IMM(BPF_AND, BPF_REG_A, PKT_TYPE_MAX);
> -#ifdef __BIG_ENDIAN_BITFIELD
> -		insn++;
> -                *insn = BPF_ALU32_IMM(BPF_RSH, BPF_REG_A, 5);
> -#endif
> +		cnt = convert_skb_access(SKF_AD_PKTTYPE, BPF_REG_A, BPF_REG_CTX, insn);
> +		insn += cnt - 1;
>   		break;
>
>   	case SKF_AD_OFF + SKF_AD_IFINDEX:
> @@ -197,10 +225,8 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
>   		break;
>
>   	case SKF_AD_OFF + SKF_AD_MARK:
> -		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, mark) != 4);
> -
> -		*insn = BPF_LDX_MEM(BPF_W, BPF_REG_A, BPF_REG_CTX,
> -				    offsetof(struct sk_buff, mark));
> +		cnt = convert_skb_access(SKF_AD_MARK, BPF_REG_A, BPF_REG_CTX, insn);
> +		insn += cnt - 1;
>   		break;
>
>   	case SKF_AD_OFF + SKF_AD_RXHASH:
> @@ -211,10 +237,8 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
>   		break;
>
>   	case SKF_AD_OFF + SKF_AD_QUEUE:
> -		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, queue_mapping) != 2);
> -
> -		*insn = BPF_LDX_MEM(BPF_H, BPF_REG_A, BPF_REG_CTX,
> -				    offsetof(struct sk_buff, queue_mapping));
> +		cnt = convert_skb_access(SKF_AD_QUEUE, BPF_REG_A, BPF_REG_CTX, insn);
> +		insn += cnt - 1;
>   		break;
>
>   	case SKF_AD_OFF + SKF_AD_VLAN_TAG:
> @@ -1147,13 +1171,55 @@ sk_filter_func_proto(enum bpf_func_id func_id)
...
> +static u32 sk_filter_convert_ctx_access(int dst_reg, int src_reg, int ctx_off,
> +					struct bpf_insn *insn_buf)
> +{
> +	struct bpf_insn *insn = insn_buf;
> +
> +	switch (ctx_off) {
> +	case offsetof(struct __sk_buff, len):
> +		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, len) != 4);
> +
> +		*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg,
> +				      offsetof(struct sk_buff, len));
> +		break;
> +
> +	case offsetof(struct __sk_buff, mark):
> +		return convert_skb_access(SKF_AD_MARK, dst_reg, src_reg, insn);
> +
> +	case offsetof(struct __sk_buff, pkt_type):
> +		return convert_skb_access(SKF_AD_PKTTYPE, dst_reg, src_reg, insn);
> +
> +	case offsetof(struct __sk_buff, queue_mapping):
> +		return convert_skb_access(SKF_AD_QUEUE, dst_reg, src_reg, insn);
> +	}
> +
> +	return insn - insn_buf;
>   }

Hmm, I actually liked the previous version much better. :(

Now, some members use convert_skb_access() and some skb members are
converted directly in-place in both, convert_bpf_extensions() _and_
in sk_filter_convert_ctx_access().

Previously, it was much more consistent, which I like better. And only
because of the simple BUILD_BUG_ON()? :/
