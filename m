From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v3 07/29] x86: bpf_jit, use ENTRY+ENDPROC
Date: Fri, 21 Apr 2017 12:32:15 -0700
Message-ID: <20170421193213.GB91454@ast-mbp.thefacebook.com>
References: <20170421141305.25180-1-jslaby@suse.cz>
 <20170421141305.25180-7-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mingo@redhat.com, tglx@linutronix.de, hpa@zytor.com,
        x86@kernel.org, jpoimboe@redhat.com, linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:35437 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424996AbdDUTcT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 15:32:19 -0400
Content-Disposition: inline
In-Reply-To: <20170421141305.25180-7-jslaby@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 21, 2017 at 04:12:43PM +0200, Jiri Slaby wrote:
> Do not use a custom macro FUNC for starts of the global functions, use
> ENTRY instead.
> 
> And while at it, annotate also ends of the functions by ENDPROC.
> 
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: James Morris <jmorris@namei.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: x86@kernel.org
> Cc: netdev@vger.kernel.org
> ---
>  arch/x86/net/bpf_jit.S | 32 ++++++++++++++++++--------------
>  1 file changed, 18 insertions(+), 14 deletions(-)
> 
> diff --git a/arch/x86/net/bpf_jit.S b/arch/x86/net/bpf_jit.S
> index f2a7faf4706e..762c29fb8832 100644
> --- a/arch/x86/net/bpf_jit.S
> +++ b/arch/x86/net/bpf_jit.S
> @@ -23,16 +23,12 @@
>  	32 /* space for rbx,r13,r14,r15 */ + \
>  	8 /* space for skb_copy_bits */)
>  
> -#define FUNC(name) \
> -	.globl name; \
> -	.type name, @function; \
> -	name:
> -
> -FUNC(sk_load_word)
> +ENTRY(sk_load_word)
>  	test	%esi,%esi
>  	js	bpf_slow_path_word_neg
> +ENDPROC(sk_load_word)

this doens't look right.
It will add alignment nops in critical paths of these pseudo functions.
I'm also not sure whether it will still work afterwards.
Was it tested?
I'd prefer if this code kept as-is.

> -FUNC(sk_load_word_positive_offset)
> +ENTRY(sk_load_word_positive_offset)
>  	mov	%r9d,%eax		# hlen
>  	sub	%esi,%eax		# hlen - offset
>  	cmp	$3,%eax
> @@ -40,12 +36,14 @@ FUNC(sk_load_word_positive_offset)
>  	mov     (SKBDATA,%rsi),%eax
>  	bswap   %eax  			/* ntohl() */
>  	ret
> +ENDPROC(sk_load_word_positive_offset)
>  
> -FUNC(sk_load_half)
> +ENTRY(sk_load_half)
>  	test	%esi,%esi
>  	js	bpf_slow_path_half_neg
> +ENDPROC(sk_load_half)
>  
> -FUNC(sk_load_half_positive_offset)
> +ENTRY(sk_load_half_positive_offset)
>  	mov	%r9d,%eax
>  	sub	%esi,%eax		#	hlen - offset
>  	cmp	$1,%eax
> @@ -53,16 +51,19 @@ FUNC(sk_load_half_positive_offset)
>  	movzwl	(SKBDATA,%rsi),%eax
>  	rol	$8,%ax			# ntohs()
>  	ret
> +ENDPROC(sk_load_half_positive_offset)
>  
> -FUNC(sk_load_byte)
> +ENTRY(sk_load_byte)
>  	test	%esi,%esi
>  	js	bpf_slow_path_byte_neg
> +ENDPROC(sk_load_byte)
>  
> -FUNC(sk_load_byte_positive_offset)
> +ENTRY(sk_load_byte_positive_offset)
>  	cmp	%esi,%r9d   /* if (offset >= hlen) goto bpf_slow_path_byte */
>  	jle	bpf_slow_path_byte
>  	movzbl	(SKBDATA,%rsi),%eax
>  	ret
> +ENDPROC(sk_load_byte_positive_offset)
>  
>  /* rsi contains offset and can be scratched */
>  #define bpf_slow_path_common(LEN)		\
> @@ -119,31 +120,34 @@ bpf_slow_path_word_neg:
>  	cmp	SKF_MAX_NEG_OFF, %esi	/* test range */
>  	jl	bpf_error	/* offset lower -> error  */
>  
> -FUNC(sk_load_word_negative_offset)
> +ENTRY(sk_load_word_negative_offset)
>  	sk_negative_common(4)
>  	mov	(%rax), %eax
>  	bswap	%eax
>  	ret
> +ENDPROC(sk_load_word_negative_offset)
>  
>  bpf_slow_path_half_neg:
>  	cmp	SKF_MAX_NEG_OFF, %esi
>  	jl	bpf_error
>  
> -FUNC(sk_load_half_negative_offset)
> +ENTRY(sk_load_half_negative_offset)
>  	sk_negative_common(2)
>  	mov	(%rax),%ax
>  	rol	$8,%ax
>  	movzwl	%ax,%eax
>  	ret
> +ENDPROC(sk_load_half_negative_offset)
>  
>  bpf_slow_path_byte_neg:
>  	cmp	SKF_MAX_NEG_OFF, %esi
>  	jl	bpf_error
>  
> -FUNC(sk_load_byte_negative_offset)
> +ENTRY(sk_load_byte_negative_offset)
>  	sk_negative_common(1)
>  	movzbl	(%rax), %eax
>  	ret
> +ENDPROC(sk_load_byte_negative_offset)
>  
>  bpf_error:
>  # force a return 0 from jit handler
> -- 
> 2.12.2
> 
