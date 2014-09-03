From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v2 net-next] net: filter: export pkt_type_offset() helper
Date: Thu, 04 Sep 2014 00:01:32 +0200
Message-ID: <54078FBC.5050402@redhat.com>
References: <1409778511-21273-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Markos Chandras <markos.chandras@imgtec.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Denis Kirjanov <kda@linux-powerpc.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30723 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933168AbaICWCC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 18:02:02 -0400
In-Reply-To: <1409778511-21273-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/2014 11:08 PM, Denis Kirjanov wrote:
> Currently we have 2 pkt_type_offset functions doing
> the same thing and spread across the architecture files.
> Let's use the generic helper routine.
>
> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
> Cc: Markos Chandras <markos.chandras@imgtec.com>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Daniel Borkmann <dborkman@redhat.com>
> Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>
>
> V2: Initialize the pkt_type_offset through the pure_initcall()
> ---
>   arch/mips/net/bpf_jit.c      | 27 ++-------------------------
>   arch/s390/net/bpf_jit_comp.c | 31 -------------------------------
>   include/linux/filter.h       |  2 ++
>   net/core/filter.c            | 16 +++++++++++++---
>   4 files changed, 17 insertions(+), 59 deletions(-)
>
> diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
> index 05a5661..bb9b53f 100644
> --- a/arch/mips/net/bpf_jit.c
> +++ b/arch/mips/net/bpf_jit.c
> @@ -765,27 +765,6 @@ static u64 jit_get_skb_w(struct sk_buff *skb, unsigned offset)
>   	return (u64)err << 32 | ntohl(ret);
>   }
>
> -#ifdef __BIG_ENDIAN_BITFIELD
> -#define PKT_TYPE_MAX	(7 << 5)
> -#else
> -#define PKT_TYPE_MAX	7
> -#endif
> -static int pkt_type_offset(void)
> -{
> -	struct sk_buff skb_probe = {
> -		.pkt_type = ~0,
> -	};
> -	u8 *ct = (u8 *)&skb_probe;
> -	unsigned int off;
> -
> -	for (off = 0; off < sizeof(struct sk_buff); off++) {
> -		if (ct[off] == PKT_TYPE_MAX)
> -			return off;
> -	}
> -	pr_err_once("Please fix pkt_type_offset(), as pkt_type couldn't be found\n");
> -	return -1;
> -}
> -
>   static int build_body(struct jit_ctx *ctx)
>   {
>   	void *load_func[] = {jit_get_skb_b, jit_get_skb_h, jit_get_skb_w};
> @@ -1332,11 +1311,9 @@ jmp_cmp:
>   		case BPF_ANC | SKF_AD_PKTTYPE:
>   			ctx->flags |= SEEN_SKB;
>
> -			off = pkt_type_offset();
> -
> -			if (off < 0)
> +			if (pkt_type_offset < 0)
>   				return -1;
> -			emit_load_byte(r_tmp, r_skb, off, ctx);
> +			emit_load_byte(r_tmp, r_skb, pkt_type_offset, ctx);
>   			/* Keep only the last 3 bits */
>   			emit_andi(r_A, r_tmp, PKT_TYPE_MAX, ctx);
>   #ifdef __BIG_ENDIAN_BITFIELD
> diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
> index 61e45b7..caa0cab 100644
> --- a/arch/s390/net/bpf_jit_comp.c
> +++ b/arch/s390/net/bpf_jit_comp.c
> @@ -223,37 +223,6 @@ static void bpf_jit_epilogue(struct bpf_jit *jit)
>   	EMIT2(0x07fe);
>   }
>
> -/* Helper to find the offset of pkt_type in sk_buff
> - * Make sure its still a 3bit field starting at the MSBs within a byte.
> - */
> -#define PKT_TYPE_MAX 0xe0
> -static int pkt_type_offset;
> -
> -static int __init bpf_pkt_type_offset_init(void)
> -{
> -	struct sk_buff skb_probe = {
> -		.pkt_type = ~0,
> -	};
> -	char *ct = (char *)&skb_probe;
> -	int off;
> -
> -	pkt_type_offset = -1;
> -	for (off = 0; off < sizeof(struct sk_buff); off++) {
> -		if (!ct[off])
> -			continue;
> -		if (ct[off] == PKT_TYPE_MAX)
> -			pkt_type_offset = off;
> -		else {
> -			/* Found non matching bit pattern, fix needed. */
> -			WARN_ON_ONCE(1);
> -			pkt_type_offset = -1;
> -			return -1;
> -		}
> -	}
> -	return 0;
> -}
> -device_initcall(bpf_pkt_type_offset_init);
> -
>   /*
>    * make sure we dont leak kernel information to user
>    */
> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index a5227ab..6814b54 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -424,6 +424,8 @@ static inline void *bpf_load_pointer(const struct sk_buff *skb, int k,
>   	return bpf_internal_load_pointer_neg_helper(skb, k, size);
>   }
>
> +extern __read_mostly int pkt_type_offset;
> +

Nit:

extern unsigned int pkt_type_offset;

(Perhaps this should also rather be named bpf_pkt_type_offset to not
  cause any current/future name collisions when it's in the header?)

>   #ifdef CONFIG_BPF_JIT
>   #include <stdarg.h>
>   #include <linux/linkage.h>
> diff --git a/net/core/filter.c b/net/core/filter.c
> index d814b8a..edd17f1 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -96,21 +96,29 @@ EXPORT_SYMBOL(sk_filter);
>   #else
>   #define PKT_TYPE_MAX	7
>   #endif
> -static unsigned int pkt_type_offset(void)
> +
> +__read_mostly int pkt_type_offset;

Nit:

unsigned int pkt_type_offset __read_mostly;

> +static int __init init_pkt_type_offset(void)
>   {
>   	struct sk_buff skb_probe = { .pkt_type = ~0, };
>   	u8 *ct = (u8 *) &skb_probe;
>   	unsigned int off;
>
> +	pkt_type_offset = -1;
>   	for (off = 0; off < sizeof(struct sk_buff); off++) {
> -		if (ct[off] == PKT_TYPE_MAX)
> +		if (ct[off] == PKT_TYPE_MAX) {
> +			pkt_type_offset = off;
>   			return off;
> +		}
>   	}

Why not BUG_ON() when pkt_type_offset could not be found?

That way we would know that something is broken and you can
spare the checks for negative offsets everywhere ...

>   	pr_err_once("Please fix %s, as pkt_type couldn't be found!\n", __func__);
>   	return -1;
>   }
>
> +pure_initcall(init_pkt_type_offset);
> +
>   static u64 __skb_get_pay_offset(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
>   {
>   	return __skb_get_poff((struct sk_buff *)(unsigned long) ctx);
> @@ -190,8 +198,10 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
>   		break;
>
>   	case SKF_AD_OFF + SKF_AD_PKTTYPE:
> +		if (pkt_type_offset < 0)
> +			return false;
>   		*insn = BPF_LDX_MEM(BPF_B, BPF_REG_A, BPF_REG_CTX,
> -				    pkt_type_offset());
> +				    pkt_type_offset);
>   		if (insn->off < 0)
>   			return false;
>   		insn++;
>
