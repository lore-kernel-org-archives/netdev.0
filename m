From: Jan Seiffert <kaffeemonster@googlemail.com>
Subject: Re: [PATCH 1/3] net: bpf jit: ppc: optimize choose_load_func error
 path
Date: Wed, 09 Oct 2013 00:50:32 +0200
Message-ID: <52548C38.9040308@googlemail.com>
References: <1381249910-17338-1-git-send-email-murzin.v@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: av1474@comtv.ru, Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Matt Evans <matt@ozlabs.org>
To: Vladimir Murzin <murzin.v@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f54.google.com ([209.85.214.54]:59432 "EHLO
	mail-bk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755341Ab3JHWuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 18:50:37 -0400
Received: by mail-bk0-f54.google.com with SMTP id mz12so3593548bkb.13
        for <netdev@vger.kernel.org>; Tue, 08 Oct 2013 15:50:36 -0700 (PDT)
In-Reply-To: <1381249910-17338-1-git-send-email-murzin.v@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vladimir Murzin schrieb:
> Macro CHOOSE_LOAD_FUNC returns handler for "any offset" if checks for K
> were not passed. At the same time handlers for "any offset" cases make
> the same checks against r_addr at run-time, that will always lead to
> bpf_error.
> 

Hmmm, if i only would remember why i wrote it that way....
I memory serves me right the idea was to always have a solid fall back, no
matter what, to the generic load function which works more like the load_pointer
from filter.c.
This way the COOSE-macro may could have been used at more places, but that
never played out.

And since all i wanted was to get the negative indirect load fixed,
optimizing the constant error case was not on my plate.
That you can get your negative K filter JITed in the first place, even
if the constant error case was slower than necessary, was good enough ;)

The ARM JIT is broken till this date...

You can have my
I'm-OK-with-this: Jan Seiffert <kaffeemonster@googlemail.com>

for all three patches, -ENOTIME for a full review ATM.

> Run-time checks are still necessary for indirect load operations, but
> error path for absolute and mesh loads are worth to optimize during bpf
> compile time.
> 
> Signed-off-by: Vladimir Murzin <murzin.v@gmail.com>
> 
> Cc: Jan Seiffert <kaffeemonster@googlemail.com>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Daniel Borkmann <dborkman@redhat.com>
> Cc: Matt Evans <matt@ozlabs.org>
> 
> ---
>  arch/powerpc/net/bpf_jit_comp.c |    7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
> index bf56e33..754320a 100644
> --- a/arch/powerpc/net/bpf_jit_comp.c
> +++ b/arch/powerpc/net/bpf_jit_comp.c
> @@ -132,7 +132,7 @@ static void bpf_jit_build_epilogue(u32 *image, struct codegen_context *ctx)
>  }
>  
>  #define CHOOSE_LOAD_FUNC(K, func) \
> -	((int)K < 0 ? ((int)K >= SKF_LL_OFF ? func##_negative_offset : func) : func##_positive_offset)
> +	((int)K < 0 ? ((int)K >= SKF_LL_OFF ? func##_negative_offset : NULL) : func##_positive_offset)
>  
>  /* Assemble the body code between the prologue & epilogue. */
>  static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
> @@ -427,6 +427,11 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
>  		case BPF_S_LD_B_ABS:
>  			func = CHOOSE_LOAD_FUNC(K, sk_load_byte);
>  		common_load:
> +			if (!func) {
> +				PPC_LI(r_ret, 0);
> +				PPC_JMP(exit_addr);
> +				break;
> +			}
>  			/* Load from [K]. */
>  			ctx->seen |= SEEN_DATAREF;
>  			PPC_LI64(r_scratch1, func);
> 


-- 
An UDP packet walks into a
