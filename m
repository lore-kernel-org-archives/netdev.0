From: Matt Evans <matt@ozlabs.org>
Subject: Re: [RESEND PATCH 2/2] ppc: bpf_jit: support MOD operation
Date: Mon, 23 Sep 2013 01:13:45 +1000
Message-ID: <F41DB09C-2D43-48DA-AE0A-4988B887F65C@ozlabs.org>
References: <1379748334-3313-1-git-send-email-murzin.v@gmail.com> <1379748334-3313-2-git-send-email-murzin.v@gmail.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"benh@kernel.crashing.org" <benh@kernel.crashing.org>,
	"paulus@samba.org" <paulus@samba.org>,
	"edumazet@google.com" <edumazet@google.com>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	Vladimir Murzin <murzin.v@gmail.com>
To: Vladimir Murzin <murzin.v@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:32837 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752033Ab3IVPNs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Sep 2013 11:13:48 -0400
In-Reply-To: <1379748334-3313-2-git-send-email-murzin.v@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vladimir,

On 21 Sep 2013, at 17:25, Vladimir Murzin <murzin.v@gmail.com> wrote:

> commit b6069a9570 (filter: add MOD operation) added generic
> support for modulus operation in BPF.
> 
> This patch brings JIT support for PPC64
> 
> Signed-off-by: Vladimir Murzin <murzin.v@gmail.com>
> Acked-by: Matt Evans <matt@ozlabs.org>

Not this version, though; see below. 

> ---
> arch/powerpc/net/bpf_jit_comp.c | 22 ++++++++++++++++++++++
> 1 file changed, 22 insertions(+)
> 
> diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
> index bf56e33..96f24dc 100644
> --- a/arch/powerpc/net/bpf_jit_comp.c
> +++ b/arch/powerpc/net/bpf_jit_comp.c
> @@ -193,6 +193,28 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
>                PPC_MUL(r_A, r_A, r_scratch1);
>            }
>            break;
> +        case BPF_S_ALU_MOD_X: /* A %= X; */
> +            ctx->seen |= SEEN_XREG;
> +            PPC_CMPWI(r_X, 0);
> +            if (ctx->pc_ret0 != -1) {
> +                PPC_BCC(COND_EQ, addrs[ctx->pc_ret0]);
> +            } else {
> +                PPC_BCC_SHORT(COND_NE, (ctx->idx*4)+12);
> +                PPC_LI(r_ret, 0);
> +                PPC_JMP(exit_addr);
> +            }
> +            PPC_DIVWU(r_scratch1, r_A, r_X);
> +            PPC_MUL(r_scratch1, r_X, r_scratch1);
> +            PPC_SUB(r_A, r_A, r_scratch1);
> +            break;
> +        case BPF_S_ALU_MOD_K: /* A %= K; */
> +#define r_scratch2 (r_scratch1 + 1)

Old version of this patch, still?  I had hoped that r_scratch2 would be defined in the header.

> +            PPC_LI32(r_scratch2, K);
> +            PPC_DIVWU(r_scratch1, r_A, r_scratch2);
> +            PPC_MUL(r_scratch1, r_scratch2, r_scratch1);
> +            PPC_SUB(r_A, r_A, r_scratch1);
> +#undef r_scratch2

And remember this guy too.. :)


Matt

> +            break;
>        case BPF_S_ALU_DIV_X: /* A /= X; */
>            ctx->seen |= SEEN_XREG;
>            PPC_CMPWI(r_X, 0);
> -- 
> 1.8.1.5
