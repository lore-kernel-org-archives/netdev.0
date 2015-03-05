From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: Re: [PATCH] filter: introduce SKF_AD_VLAN_PROTO BPF extension
Date: Thu, 5 Mar 2015 11:57:05 +0300
Message-ID: <CAOJe8K1_imrFKTafER6+RRFQfZPE3POGmpMbuxZ+NG6wG6hRyQ@mail.gmail.com>
References: <1425501718-12066-1-git-send-email-msekleta@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Alexei Starovoitov <ast@plumgrid.com>,
	Jiri Pirko <jpirko@redhat.com>
To: Michal Sekletar <msekleta@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f173.google.com ([209.85.160.173]:38733 "EHLO
	mail-yk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753132AbbCEI5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 03:57:06 -0500
Received: by ykp9 with SMTP id 9so22618710ykp.5
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 00:57:05 -0800 (PST)
In-Reply-To: <1425501718-12066-1-git-send-email-msekleta@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/4/15, Michal Sekletar <msekleta@redhat.com> wrote:
> This commit introduces new BPF extension. It makes possible to load value
> of
> skb->vlan_proto (vlan tpid) to register A.
>
> Currently, vlan header is removed from frame and information is available
> to
> userspace only via tpacket interface. Hence, it is not possible to install
> filter which uses value of vlan tpid field.
>
> AFAICT only way how to filter based on tpid value is to reconstruct
> original
> frame encapsulation and interpret BPF filter code in userspace. Doing that
> is
> way slower than doing filtering in kernel.
>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> Cc: Jiri Pirko <jpirko@redhat.com>
> Signed-off-by: Michal Sekletar <msekleta@redhat.com>
> ---
>  Documentation/networking/filter.txt |  1 +
>  arch/arm/net/bpf_jit_32.c           |  6 ++++++
>  arch/mips/net/bpf_jit.c             |  6 ++++++
>  arch/powerpc/net/bpf_jit_comp.c     |  5 +++++
>  arch/s390/net/bpf_jit_comp.c        |  5 +++++
>  arch/sparc/net/bpf_jit_comp.c       |  3 +++
>  include/linux/filter.h              |  1 +
>  include/uapi/linux/filter.h         |  3 ++-
>  net/core/filter.c                   | 10 ++++++++++
>  tools/net/bpf_exp.l                 |  1 +
>  tools/net/bpf_exp.y                 | 11 ++++++++++-
>  11 files changed, 50 insertions(+), 2 deletions(-)
>
> diff --git a/Documentation/networking/filter.txt
> b/Documentation/networking/filter.txt
> index 9930ecfb..3155c4c 100644
> --- a/Documentation/networking/filter.txt
> +++ b/Documentation/networking/filter.txt
> @@ -282,6 +282,7 @@ Possible BPF extensions are shown in the following
> table:
>    vlan_tci                              skb_vlan_tag_get(skb)
>    vlan_pr                               skb_vlan_tag_present(skb)
>    rand                                  prandom_u32()
> +  vlan_proto                            skb->vlan_proto
>
>  These extensions can also be prefixed with '#'.
>  Examples for low-level BPF:
> diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
> index e1268f9..2954e05 100644
> --- a/arch/arm/net/bpf_jit_32.c
> +++ b/arch/arm/net/bpf_jit_32.c
> @@ -843,6 +843,12 @@ b_epilogue:
>  			else
>  				OP_IMM3(ARM_AND, r_A, r_A, VLAN_TAG_PRESENT, ctx);
>  			break;
> +		case BPF_ANC | SKF_AD_VLAN_PROTO:
> +			ctx->seen |= SEEN_SKB;
> +			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, vlan_proto) != 2);
> +			off = offsetof(struct sk_buff, vlan_proto);
> +			emit(ARM_LDR_I(r_A, r_skb, off), ctx);
> +			break;
>  		case BPF_ANC | SKF_AD_QUEUE:
>  			ctx->seen |= SEEN_SKB;
>  			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff,
> diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
> index 5d61393..732fb1d 100644
> --- a/arch/mips/net/bpf_jit.c
> +++ b/arch/mips/net/bpf_jit.c
> @@ -1295,6 +1295,12 @@ jmp_cmp:
>  				emit_sltu(r_A, r_zero, r_A, ctx);
>  			}
>  			break;
> +		case BPF_ANC | SKF_AD_VLAN_PROTO:
> +			ctx->flags |= SEEN_SKB | SEEN_A;
> +			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, vlan_proto) != 2);
> +			off = offsetof(struct sk_buff, vlan_proto);
> +			emit_load(r_A, r_skb, off, ctx);
> +			break;
>  		case BPF_ANC | SKF_AD_PKTTYPE:
>  			ctx->flags |= SEEN_SKB;
>
> diff --git a/arch/powerpc/net/bpf_jit_comp.c
> b/arch/powerpc/net/bpf_jit_comp.c
> index 17cea18..acfa732 100644
> --- a/arch/powerpc/net/bpf_jit_comp.c
> +++ b/arch/powerpc/net/bpf_jit_comp.c
> @@ -399,6 +399,11 @@ static int bpf_jit_build_body(struct bpf_prog *fp, u32
> *image,
>  				PPC_SRWI(r_A, r_A, 12);
>  			}
>  			break;
> +		case BPF_ANC | SKF_AD_VLAN_PROTO:
> +			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, vlan_proto) != 2);
> +			PPC_LWZ_OFFS(r_A, r_skb, offsetof(struct sk_buff,
> +							  vlan_proto));
You're going to load a halfword, so lhz has to be used

> +			break;
>  		case BPF_ANC | SKF_AD_QUEUE:
>  			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff,
>  						  queue_mapping) != 2);
> diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
> index bbd1981..55b6db7 100644
> --- a/arch/s390/net/bpf_jit_comp.c
> +++ b/arch/s390/net/bpf_jit_comp.c
> @@ -722,6 +722,11 @@ call_fn:	/* lg %r1,<d(function)>(%r13) */
>  			EMIT4_DISP(0x88500000, 12);
>  		}
>  		break;
> +	case BPF_ANC | SKF_AD_VLAN_PROTO: /* A = skb->vlan_proto */
> +		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, vlan_proto) != 2);
> +		/* l %r5,<d(vlan_proto)>(%r2) */
> +		EMIT4_DISP(0x58502000, offsetof(struct sk_buff, vlan_proto));
> +		break;
>  	case BPF_ANC | SKF_AD_PKTTYPE:
>  		/* lhi %r5,0 */
>  		EMIT4(0xa7580000);
> diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
> index 7931eee..cf3e6ac 100644
> --- a/arch/sparc/net/bpf_jit_comp.c
> +++ b/arch/sparc/net/bpf_jit_comp.c
> @@ -624,6 +624,9 @@ void bpf_jit_compile(struct bpf_prog *fp)
>  					emit_and(r_A, r_TMP, r_A);
>  				}
>  				break;
> +			case BPF_ANC | SKF_AD_VLAN_PROTO:
> +				emit_skb_load32(vlan_proto, r_A);
> +				break;
>  			case BPF_LD | BPF_W | BPF_LEN:
>  				emit_skb_load32(len, r_A);
>  				break;
> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index 9ee8c67..3ec42a1 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -454,6 +454,7 @@ static inline u16 bpf_anc_helper(const struct
> sock_filter *ftest)
>  		BPF_ANCILLARY(VLAN_TAG_PRESENT);
>  		BPF_ANCILLARY(PAY_OFFSET);
>  		BPF_ANCILLARY(RANDOM);
> +		BPF_ANCILLARY(VLAN_PROTO);
>  		}
>  		/* Fallthrough. */
>  	default:
> diff --git a/include/uapi/linux/filter.h b/include/uapi/linux/filter.h
> index 47785d5..aef103bf 100644
> --- a/include/uapi/linux/filter.h
> +++ b/include/uapi/linux/filter.h
> @@ -77,7 +77,8 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
>  #define SKF_AD_VLAN_TAG_PRESENT 48
>  #define SKF_AD_PAY_OFFSET	52
>  #define SKF_AD_RANDOM	56
> -#define SKF_AD_MAX	60
> +#define SKF_AD_VLAN_PROTO	60
> +#define SKF_AD_MAX	64
>  #define SKF_NET_OFF   (-0x100000)
>  #define SKF_LL_OFF    (-0x200000)
>
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 7a4eb70..b14cc40 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -236,6 +236,16 @@ static bool convert_bpf_extensions(struct sock_filter
> *fp,
>  		}
>  		break;
>
> +	case SKF_AD_OFF + SKF_AD_VLAN_PROTO:
> +		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, vlan_proto) != 2);
> +
> +		/* A = *(u16 *) (CTX + offsetof(vlan_proto)) */
> +		*insn++ = BPF_LDX_MEM(BPF_H, BPF_REG_A, BPF_REG_CTX,
> +				      offsetof(struct sk_buff, vlan_proto));
> +		/* A = ntohs(A) [emitting a nop or swap16] */
> +		*insn = BPF_ENDIAN(BPF_FROM_BE, BPF_REG_A, 16);
> +		break;
> +
>  	case SKF_AD_OFF + SKF_AD_PAY_OFFSET:
>  	case SKF_AD_OFF + SKF_AD_NLATTR:
>  	case SKF_AD_OFF + SKF_AD_NLATTR_NEST:
> diff --git a/tools/net/bpf_exp.l b/tools/net/bpf_exp.l
> index 833a966..0d4e72f 100644
> --- a/tools/net/bpf_exp.l
> +++ b/tools/net/bpf_exp.l
> @@ -93,6 +93,7 @@ extern void yyerror(const char *str);
>  "#"?("vlan_tci") { return K_VLANT; }
>  "#"?("vlan_pr")	{ return K_VLANP; }
>  "#"?("rand")	{ return K_RAND; }
> +"#"?("vlan_proto")	{ return K_VLANPR; }
>
>  ":"		{ return ':'; }
>  ","		{ return ','; }
> diff --git a/tools/net/bpf_exp.y b/tools/net/bpf_exp.y
> index e6306c5..9c7a0e7 100644
> --- a/tools/net/bpf_exp.y
> +++ b/tools/net/bpf_exp.y
> @@ -56,7 +56,7 @@ static void bpf_set_jmp_label(char *label, enum jmp_type
> type);
>  %token OP_LDXI
>
>  %token K_PKT_LEN K_PROTO K_TYPE K_NLATTR K_NLATTR_NEST K_MARK K_QUEUE
> K_HATYPE
> -%token K_RXHASH K_CPU K_IFIDX K_VLANT K_VLANP K_POFF K_RAND
> +%token K_RXHASH K_CPU K_IFIDX K_VLANT K_VLANP K_POFF K_RAND K_VLANPR
>
>  %token ':' ',' '[' ']' '(' ')' 'x' 'a' '+' 'M' '*' '&' '#' '%'
>
> @@ -167,6 +167,9 @@ ldb
>  	| OP_LDB K_RAND {
>  		bpf_set_curr_instr(BPF_LD | BPF_B | BPF_ABS, 0, 0,
>  				   SKF_AD_OFF + SKF_AD_RANDOM); }
> +	| OP_LDB K_VLANPR {
> +		bpf_set_curr_instr(BPF_LD | BPF_B | BPF_ABS, 0, 0,
> +				   SKF_AD_OFF + SKF_AD_VLAN_PROTO); }
>  	;
>
>  ldh
> @@ -218,6 +221,9 @@ ldh
>  	| OP_LDH K_RAND {
>  		bpf_set_curr_instr(BPF_LD | BPF_H | BPF_ABS, 0, 0,
>  				   SKF_AD_OFF + SKF_AD_RANDOM); }
> +	| OP_LDH K_VLANPR {
> +		bpf_set_curr_instr(BPF_LD | BPF_H | BPF_ABS, 0, 0,
> +				   SKF_AD_OFF + SKF_AD_VLAN_PROTO); }
>  	;
>
>  ldi
> @@ -274,6 +280,9 @@ ld
>  	| OP_LD K_RAND {
>  		bpf_set_curr_instr(BPF_LD | BPF_W | BPF_ABS, 0, 0,
>  				   SKF_AD_OFF + SKF_AD_RANDOM); }
> +	| OP_LD K_VLANPR {
> +		bpf_set_curr_instr(BPF_LD | BPF_W | BPF_ABS, 0, 0,
> +				   SKF_AD_OFF + SKF_AD_VLAN_PROTO); }
>  	| OP_LD 'M' '[' number ']' {
>  		bpf_set_curr_instr(BPF_LD | BPF_MEM, 0, 0, $4); }
>  	| OP_LD '[' 'x' '+' number ']' {
> --
> 1.8.3.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
