From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: Re: [PATCH] PPC: bpf_jit_comp: add SKF_AD_PKTTYPE instruction
Date: Wed, 29 Oct 2014 13:21:06 +0400
Message-ID: <CAOJe8K0t3G-bHm_24GjrTp9mmKnYZS1_bdGgrwQBLjC_s5is6w@mail.gmail.com>
References: <1414351406-4122-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Denis Kirjanov <kda@linux-powerpc.org>,
	Matt Evans <matt@ozlabs.org>, netdev@vger.kernel.org
To: linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:57853 "EHLO
	mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755492AbaJ2JVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 05:21:07 -0400
Received: by mail-oi0-f42.google.com with SMTP id a3so1356167oib.29
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2014 02:21:06 -0700 (PDT)
In-Reply-To: <1414351406-4122-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Any feedback from PPC folks?

On 10/26/14, Denis Kirjanov <kda@linux-powerpc.org> wrote:
> Cc: Matt Evans <matt@ozlabs.org>
> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
> ---
>  arch/powerpc/include/asm/ppc-opcode.h | 1 +
>  arch/powerpc/net/bpf_jit.h            | 7 +++++++
>  arch/powerpc/net/bpf_jit_comp.c       | 5 +++++
>  3 files changed, 13 insertions(+)
>
> diff --git a/arch/powerpc/include/asm/ppc-opcode.h
> b/arch/powerpc/include/asm/ppc-opcode.h
> index 6f85362..1a52877 100644
> --- a/arch/powerpc/include/asm/ppc-opcode.h
> +++ b/arch/powerpc/include/asm/ppc-opcode.h
> @@ -204,6 +204,7 @@
>  #define PPC_INST_ERATSX_DOT		0x7c000127
>
>  /* Misc instructions for BPF compiler */
> +#define PPC_INST_LBZ			0x88000000
>  #define PPC_INST_LD			0xe8000000
>  #define PPC_INST_LHZ			0xa0000000
>  #define PPC_INST_LHBRX			0x7c00062c
> diff --git a/arch/powerpc/net/bpf_jit.h b/arch/powerpc/net/bpf_jit.h
> index 9aee27c..c406aa9 100644
> --- a/arch/powerpc/net/bpf_jit.h
> +++ b/arch/powerpc/net/bpf_jit.h
> @@ -87,6 +87,9 @@ DECLARE_LOAD_FUNC(sk_load_byte_msh);
>  #define PPC_STD(r, base, i)	EMIT(PPC_INST_STD | ___PPC_RS(r) |	      \
>  				     ___PPC_RA(base) | ((i) & 0xfffc))
>
> +
> +#define PPC_LBZ(r, base, i)	EMIT(PPC_INST_LBZ | ___PPC_RT(r) |	      \
> +				     ___PPC_RA(base) | IMM_L(i))
>  #define PPC_LD(r, base, i)	EMIT(PPC_INST_LD | ___PPC_RT(r) |	      \
>  				     ___PPC_RA(base) | IMM_L(i))
>  #define PPC_LWZ(r, base, i)	EMIT(PPC_INST_LWZ | ___PPC_RT(r) |	      \
> @@ -96,6 +99,10 @@ DECLARE_LOAD_FUNC(sk_load_byte_msh);
>  #define PPC_LHBRX(r, base, b)	EMIT(PPC_INST_LHBRX | ___PPC_RT(r) |	      \
>  				     ___PPC_RA(base) | ___PPC_RB(b))
>  /* Convenience helpers for the above with 'far' offsets: */
> +#define PPC_LBZ_OFFS(r, base, i) do { if ((i) < 32768) PPC_LBZ(r, base, i);
>   \
> +		else {	PPC_ADDIS(r, base, IMM_HA(i));			      \
> +			PPC_LBZ(r, r, IMM_L(i)); } } while(0)
> +
>  #define PPC_LD_OFFS(r, base, i) do { if ((i) < 32768) PPC_LD(r, base, i);
>   \
>  		else {	PPC_ADDIS(r, base, IMM_HA(i));			      \
>  			PPC_LD(r, r, IMM_L(i)); } } while(0)
> diff --git a/arch/powerpc/net/bpf_jit_comp.c
> b/arch/powerpc/net/bpf_jit_comp.c
> index cbae2df..d110e28 100644
> --- a/arch/powerpc/net/bpf_jit_comp.c
> +++ b/arch/powerpc/net/bpf_jit_comp.c
> @@ -407,6 +407,11 @@ static int bpf_jit_build_body(struct bpf_prog *fp, u32
> *image,
>  			PPC_LHZ_OFFS(r_A, r_skb, offsetof(struct sk_buff,
>  							  queue_mapping));
>  			break;
> +		case BPF_ANC | SKF_AD_PKTTYPE:
> +			PPC_LBZ_OFFS(r_A, r_skb, PKT_TYPE_OFFSET());
> +			PPC_ANDI(r_A, r_A, PKT_TYPE_MAX);
> +			PPC_SRWI(r_A, r_A, 5);
> +			break;
>  		case BPF_ANC | SKF_AD_CPU:
>  #ifdef CONFIG_SMP
>  			/*
> --
> 2.1.0
>
>
