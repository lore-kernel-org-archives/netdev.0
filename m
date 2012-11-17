From: Matt Evans <matt@ozlabs.org>
Subject: Re: [PATCH net-next 1/2] PPC: net: bpf_jit_comp: add XOR instruction for BPF JIT
Date: Sat, 17 Nov 2012 00:00:38 +0000
Message-ID: <744A32A4-3F1F-4253-9ECB-59DBCC240847@ozlabs.org>
References: <20121108213939.GA29696@thinkbox>
Mime-Version: 1.0 (Apple Message framework v1085)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: davem@davemloft.net, benh@kernel.crashing.org,
	netdev@vger.kernel.org
To: Daniel Borkmann <dxchgb@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:38095 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753815Ab2KQAAt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 19:00:49 -0500
In-Reply-To: <20121108213939.GA29696@thinkbox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,


On 08/11/2012, at 9:39 PM, Daniel Borkmann wrote:

> This patch is a follow-up for patch "filter: add XOR instruction for use
> with X/K" that implements BPF PowerPC JIT parts for the BPF XOR operation.
> 
> Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
> Cc: Matt Evans <matt@ozlabs.org>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> ---
> Disclaimer: uncompiled and untested, since I don't have a PPC machine,
> but it should (hopefully) integrate cleanly; impl. after PPC instruction
> reference.

Unfortunately I can only compile and test this mentally, but it looks fine, instruction formats correct etc.  Thanks!


Acked-by: Matt Evans <matt@ozlabs.org>



Matt

> 
> arch/powerpc/include/asm/ppc-opcode.h |    3 +++
> arch/powerpc/net/bpf_jit.h            |    6 ++++++
> arch/powerpc/net/bpf_jit_comp.c       |   11 +++++++++++
> 3 files changed, 20 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/powerpc/include/asm/ppc-opcode.h b/arch/powerpc/include/asm/ppc-opcode.h
> index 5f73ce6..42b1f43 100644
> --- a/arch/powerpc/include/asm/ppc-opcode.h
> +++ b/arch/powerpc/include/asm/ppc-opcode.h
> @@ -168,9 +168,12 @@
> #define PPC_INST_AND			0x7c000038
> #define PPC_INST_ANDDOT			0x7c000039
> #define PPC_INST_OR			0x7c000378
> +#define PPC_INST_XOR			0x7c000278
> #define PPC_INST_ANDI			0x70000000
> #define PPC_INST_ORI			0x60000000
> #define PPC_INST_ORIS			0x64000000
> +#define PPC_INST_XORI			0x68000000
> +#define PPC_INST_XORIS			0x6c000000
> #define PPC_INST_NEG			0x7c0000d0
> #define PPC_INST_BRANCH			0x48000000
> #define PPC_INST_BRANCH_COND		0x40800000
> diff --git a/arch/powerpc/net/bpf_jit.h b/arch/powerpc/net/bpf_jit.h
> index 1fc8109..8a5dfaf 100644
> --- a/arch/powerpc/net/bpf_jit.h
> +++ b/arch/powerpc/net/bpf_jit.h
> @@ -134,6 +134,12 @@ DECLARE_LOAD_FUNC(sk_load_byte_msh);
> 				     ___PPC_RS(a) | IMM_L(i))
> #define PPC_ORIS(d, a, i)	EMIT(PPC_INST_ORIS | ___PPC_RA(d) |	      \
> 				     ___PPC_RS(a) | IMM_L(i))
> +#define PPC_XOR(d, a, b)	EMIT(PPC_INST_XOR | ___PPC_RA(d) |	      \
> +				     ___PPC_RS(a) | ___PPC_RB(b))
> +#define PPC_XORI(d, a, i)	EMIT(PPC_INST_XORI | ___PPC_RA(d) |	      \
> +				     ___PPC_RS(a) | IMM_L(i))
> +#define PPC_XORIS(d, a, i)	EMIT(PPC_INST_XORIS | ___PPC_RA(d) |	      \
> +				     ___PPC_RS(a) | IMM_L(i))
> #define PPC_SLW(d, a, s)	EMIT(PPC_INST_SLW | ___PPC_RA(d) |	      \
> 				     ___PPC_RS(a) | ___PPC_RB(s))
> #define PPC_SRW(d, a, s)	EMIT(PPC_INST_SRW | ___PPC_RA(d) |	      \
> diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
> index dd11306..b9434de 100644
> --- a/arch/powerpc/net/bpf_jit_comp.c
> +++ b/arch/powerpc/net/bpf_jit_comp.c
> @@ -232,6 +232,17 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
> 			if (K >= 65536)
> 				PPC_ORIS(r_A, r_A, IMM_H(K));
> 			break;
> +		case BPF_S_ANC_ALU_XOR_X:
> +		case BPF_S_ALU_XOR_X: /* A ^= X */
> +			ctx->seen |= SEEN_XREG;
> +			PPC_XOR(r_A, r_A, r_X);
> +			break;
> +		case BPF_S_ALU_XOR_K: /* A ^= K */
> +			if (IMM_L(K))
> +				PPC_XORI(r_A, r_A, IMM_L(K));
> +			if (K >= 65536)
> +				PPC_XORIS(r_A, r_A, IMM_H(K));
> +			break;
> 		case BPF_S_ALU_LSH_X: /* A <<= X; */
> 			ctx->seen |= SEEN_XREG;
> 			PPC_SLW(r_A, r_A, r_X);
