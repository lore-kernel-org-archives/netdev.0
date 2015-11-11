From: Z Lim <zlim.lnx@gmail.com>
Subject: Re: [PATCH 1/2] arm64: bpf: add 'store immediate' instruction
Date: Tue, 10 Nov 2015 18:45:39 -0800
Message-ID: <CABg9mct-_AF9+kvZ0OG_JTMHkfj+OEsR2vonrxF=yD-yA6ihQw@mail.gmail.com>
References: <1447195301-16757-1-git-send-email-yang.shi@linaro.org>
	<1447195301-16757-2-git-send-email-yang.shi@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@kernel.org>, daniel@iogearbox.net,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>, Xi Wang <xi.wang@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	linaro-kernel@lists.linaro.org
To: Yang Shi <yang.shi@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:34745 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751807AbbKKCpk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2015 21:45:40 -0500
In-Reply-To: <1447195301-16757-2-git-send-email-yang.shi@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 10, 2015 at 2:41 PM, Yang Shi <yang.shi@linaro.org> wrote:
> aarch64 doesn't have native store immediate instruction, such operation

Actually, aarch64 does have "STR (immediate)". For arm64 JIT, we can
consider using it as an optimization.

You may also want to consider adding a note about the corresponding test cases:
    commit cffc642d93f9 ("test_bpf: add 173 new testcases for eBPF").

Otherwise, the patch below looks good.
Reviewed-by: Zi Shen Lim <zlim.lnx@gmail.com>

> has to be implemented by the below instruction sequence:
>
> Load immediate to register
> Store register
>
> Signed-off-by: Yang Shi <yang.shi@linaro.org>
> CC: Zi Shen Lim <zlim.lnx@gmail.com>
> CC: Xi Wang <xi.wang@gmail.com>
> ---
>  arch/arm64/net/bpf_jit_comp.c | 20 +++++++++++++++++++-
>  1 file changed, 19 insertions(+), 1 deletion(-)
>
> diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
> index 6809647..49c1f1b 100644
> --- a/arch/arm64/net/bpf_jit_comp.c
> +++ b/arch/arm64/net/bpf_jit_comp.c
> @@ -563,7 +563,25 @@ emit_cond_jmp:
>         case BPF_ST | BPF_MEM | BPF_H:
>         case BPF_ST | BPF_MEM | BPF_B:
>         case BPF_ST | BPF_MEM | BPF_DW:
> -               goto notyet;
> +               /* Load imm to a register then store it */
> +               ctx->tmp_used = 1;
> +               emit_a64_mov_i(1, tmp2, off, ctx);
> +               emit_a64_mov_i(1, tmp, imm, ctx);
> +               switch (BPF_SIZE(code)) {
> +               case BPF_W:
> +                       emit(A64_STR32(tmp, dst, tmp2), ctx);
> +                       break;
> +               case BPF_H:
> +                       emit(A64_STRH(tmp, dst, tmp2), ctx);
> +                       break;
> +               case BPF_B:
> +                       emit(A64_STRB(tmp, dst, tmp2), ctx);
> +                       break;
> +               case BPF_DW:
> +                       emit(A64_STR64(tmp, dst, tmp2), ctx);
> +                       break;
> +               }
> +               break;
>
>         /* STX: *(size *)(dst + off) = src */
>         case BPF_STX | BPF_MEM | BPF_W:
> --
> 2.0.2
>
