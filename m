From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] filter: added BPF random opcode
Date: Tue, 15 Apr 2014 09:24:09 +0200
Message-ID: <534CDE99.6090407@redhat.com>
References: <1397516569-31033-1-git-send-email-chema@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	ast@plumgrid.com
To: Chema Gonzalez <chema@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46879 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751852AbaDOHYZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2014 03:24:25 -0400
In-Reply-To: <1397516569-31033-1-git-send-email-chema@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Chema,

[cc'ing Alexei as well]

note, net-next is still closed, so you might need to resend this later
on again when it opens up.

On 04/15/2014 01:02 AM, Chema Gonzalez wrote:
> This should allow random packet sampling.
>
> Signed-off-by: Chema Gonzalez <chema@google.com>
> ---
>   Documentation/networking/filter.txt |  1 +
>   include/linux/filter.h              |  1 +
>   include/uapi/linux/filter.h         |  3 ++-
>   net/core/filter.c                   | 12 ++++++++++++
>   tools/net/bpf_exp.l                 |  1 +
>   tools/net/bpf_exp.y                 | 11 ++++++++++-
>   tools/net/icmp_random.bpf           | 12 ++++++++++++
>   7 files changed, 39 insertions(+), 2 deletions(-)
>   create mode 100644 tools/net/icmp_random.bpf
>
> diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
> index 81f940f..7192b46 100644
> --- a/Documentation/networking/filter.txt
> +++ b/Documentation/networking/filter.txt
> @@ -281,6 +281,7 @@ Possible BPF extensions are shown in the following table:
>     cpu                                   raw_smp_processor_id()
>     vlan_tci                              vlan_tx_tag_get(skb)
>     vlan_pr                               vlan_tx_tag_present(skb)
> +  random                                prandom_u32()
>
>   These extensions can also be prefixed with '#'.
>   Examples for low-level BPF:
> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index 262dcbb..49c28aa 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -224,6 +224,7 @@ enum {
>   	BPF_S_ANC_VLAN_TAG,
>   	BPF_S_ANC_VLAN_TAG_PRESENT,
>   	BPF_S_ANC_PAY_OFFSET,
> +	BPF_S_ANC_RANDOM,
>   };
>
>   #endif /* __LINUX_FILTER_H__ */
> diff --git a/include/uapi/linux/filter.h b/include/uapi/linux/filter.h
> index 8eb9cca..253b4d4 100644
> --- a/include/uapi/linux/filter.h
> +++ b/include/uapi/linux/filter.h
> @@ -130,7 +130,8 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
>   #define SKF_AD_VLAN_TAG	44
>   #define SKF_AD_VLAN_TAG_PRESENT 48
>   #define SKF_AD_PAY_OFFSET	52
> -#define SKF_AD_MAX	56
> +#define SKF_AD_RANDOM	56
> +#define SKF_AD_MAX	60
>   #define SKF_NET_OFF   (-0x100000)
>   #define SKF_LL_OFF    (-0x200000)
>
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 765556b..b2a80a1 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -637,6 +637,12 @@ static u64 __get_raw_cpu_id(u64 ctx, u64 A, u64 X, u64 r4, u64 r5)
>   	return raw_smp_processor_id();
>   }
>
> +/* note that this only generates 32-bit random numbers */
> +static u64 __skb_get_random(u64 ctx, u64 A, u64 X, u64 r4, u64 r5)
> +{
> +	return (u64)prandom_u32();
> +}
> +
>   /* Register mappings for user programs. */
>   #define A_REG		0
>   #define X_REG		7
> @@ -773,6 +779,7 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
>   	case SKF_AD_OFF + SKF_AD_NLATTR:
>   	case SKF_AD_OFF + SKF_AD_NLATTR_NEST:
>   	case SKF_AD_OFF + SKF_AD_CPU:
> +	case SKF_AD_OFF + SKF_AD_RANDOM:

I think instead of a function call, this sould rather be modelled
directly into the internal insn set and thus converted differently,
so we can spare us the call.

>   		/* arg1 = ctx */
>   		insn->code = BPF_ALU64 | BPF_MOV | BPF_X;
>   		insn->a_reg = ARG1_REG;
> @@ -806,6 +813,9 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
>   		case SKF_AD_OFF + SKF_AD_CPU:
>   			insn->imm = __get_raw_cpu_id - __bpf_call_base;
>   			break;
> +		case SKF_AD_OFF + SKF_AD_RANDOM:
> +			insn->imm = __skb_get_random - __bpf_call_base;
> +			break;
>   		}
>   		break;
>
> @@ -1356,6 +1366,7 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
>   			ANCILLARY(VLAN_TAG);
>   			ANCILLARY(VLAN_TAG_PRESENT);
>   			ANCILLARY(PAY_OFFSET);
> +			ANCILLARY(RANDOM);
>   			}
>
>   			/* ancillary operation unknown or unsupported */
> @@ -1741,6 +1752,7 @@ void sk_decode_filter(struct sock_filter *filt, struct sock_filter *to)
>   		[BPF_S_ANC_VLAN_TAG]	= BPF_LD|BPF_B|BPF_ABS,
>   		[BPF_S_ANC_VLAN_TAG_PRESENT] = BPF_LD|BPF_B|BPF_ABS,
>   		[BPF_S_ANC_PAY_OFFSET]	= BPF_LD|BPF_B|BPF_ABS,
> +		[BPF_S_ANC_RANDOM]	= BPF_LD|BPF_B|BPF_ABS,
>   		[BPF_S_LD_W_LEN]	= BPF_LD|BPF_W|BPF_LEN,
>   		[BPF_S_LD_W_IND]	= BPF_LD|BPF_W|BPF_IND,
>   		[BPF_S_LD_H_IND]	= BPF_LD|BPF_H|BPF_IND,
> diff --git a/tools/net/bpf_exp.l b/tools/net/bpf_exp.l
> index bf7be77..804256f 100644
> --- a/tools/net/bpf_exp.l
> +++ b/tools/net/bpf_exp.l
> @@ -92,6 +92,7 @@ extern void yyerror(const char *str);
>   "#"?("cpu")	{ return K_CPU; }
>   "#"?("vlan_tci") { return K_VLANT; }
>   "#"?("vlan_pr")	{ return K_VLANP; }
> +"#"?("random")	{ return K_RAND; }

Thanks for also updating bpf_asm ! :)

I think using just "rnd" is cleaner here.

>   ":"		{ return ':'; }
>   ","		{ return ','; }
> diff --git a/tools/net/bpf_exp.y b/tools/net/bpf_exp.y
> index d15efc9..e6306c5 100644
> --- a/tools/net/bpf_exp.y
> +++ b/tools/net/bpf_exp.y
> @@ -56,7 +56,7 @@ static void bpf_set_jmp_label(char *label, enum jmp_type type);
>   %token OP_LDXI
>
>   %token K_PKT_LEN K_PROTO K_TYPE K_NLATTR K_NLATTR_NEST K_MARK K_QUEUE K_HATYPE
> -%token K_RXHASH K_CPU K_IFIDX K_VLANT K_VLANP K_POFF
> +%token K_RXHASH K_CPU K_IFIDX K_VLANT K_VLANP K_POFF K_RAND
>
>   %token ':' ',' '[' ']' '(' ')' 'x' 'a' '+' 'M' '*' '&' '#' '%'
>
> @@ -164,6 +164,9 @@ ldb
>   	| OP_LDB K_POFF {
>   		bpf_set_curr_instr(BPF_LD | BPF_B | BPF_ABS, 0, 0,
>   				   SKF_AD_OFF + SKF_AD_PAY_OFFSET); }
> +	| OP_LDB K_RAND {
> +		bpf_set_curr_instr(BPF_LD | BPF_B | BPF_ABS, 0, 0,
> +				   SKF_AD_OFF + SKF_AD_RANDOM); }
>   	;
>
>   ldh
> @@ -212,6 +215,9 @@ ldh
>   	| OP_LDH K_POFF {
>   		bpf_set_curr_instr(BPF_LD | BPF_H | BPF_ABS, 0, 0,
>   				   SKF_AD_OFF + SKF_AD_PAY_OFFSET); }
> +	| OP_LDH K_RAND {
> +		bpf_set_curr_instr(BPF_LD | BPF_H | BPF_ABS, 0, 0,
> +				   SKF_AD_OFF + SKF_AD_RANDOM); }
>   	;
>
>   ldi
> @@ -265,6 +271,9 @@ ld
>   	| OP_LD K_POFF {
>   		bpf_set_curr_instr(BPF_LD | BPF_W | BPF_ABS, 0, 0,
>   				   SKF_AD_OFF + SKF_AD_PAY_OFFSET); }
> +	| OP_LD K_RAND {
> +		bpf_set_curr_instr(BPF_LD | BPF_W | BPF_ABS, 0, 0,
> +				   SKF_AD_OFF + SKF_AD_RANDOM); }
>   	| OP_LD 'M' '[' number ']' {
>   		bpf_set_curr_instr(BPF_LD | BPF_MEM, 0, 0, $4); }
>   	| OP_LD '[' 'x' '+' number ']' {
> diff --git a/tools/net/icmp_random.bpf b/tools/net/icmp_random.bpf
> new file mode 100644
> index 0000000..b9adcbf
> --- /dev/null
> +++ b/tools/net/icmp_random.bpf
> @@ -0,0 +1,12 @@
> +# icmp random packet sampling, 1 in 4
> +ldh [12]
> +jne #0x800, drop
> +ldb [23]
> +jneq #1, drop
> +# get a random uint32 number
> +ld random
> +mod #4
> +jneq #1, drop
> +ret #-1
> +drop: ret #0
> +
>

This example should rather go into Documentation/networking/filter.txt's
example section, rather than tools/net/ .
