From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH] MIPS checksum fix
Date: Fri, 19 Sep 2008 23:09:52 +0900 (JST)
Message-ID: <20080919.230952.128619158.anemo@mba.ocn.ne.jp>
References: <20080919112304.GB13440@linux-mips.org>
	<20080919114743.GA19359@linux-mips.org>
	<20080919120752.GA19877@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: macro@linux-mips.org, u1@terran.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
To: ralf@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.235.107]:61878 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750846AbYISOJe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Sep 2008 10:09:34 -0400
In-Reply-To: <20080919120752.GA19877@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 Sep 2008 14:07:52 +0200, Ralf Baechle <ralf@linux-mips.org> wrote:
> From 97ad23f4696a322cb3bc379a25a8c0f6526751d6 Mon Sep 17 00:00:00 2001
> From: Ralf Baechle <ralf@linux-mips.org>
> Date: Fri, 19 Sep 2008 14:05:53 +0200
> Subject: [PATCH] [MIPS] Fix 64-bit csum_partial, __csum_partial_copy_user and csum_partial_copy

... and __csum_partial_copy_nocheck, you mean? ;)

> On 64-bit machines it wouldn't handle a possible carry when adding the
> 32-bit folded checksum and checksum argument.
> 
> While at it, add a few trivial optimizations, also for R2 processors.

I think it would be better splitting bugfix and optimization.  This
code is too complex to do many things at a time, isn't it?

> @@ -53,12 +53,14 @@
>  #define UNIT(unit)  ((unit)*NBYTES)
>  
>  #define ADDC(sum,reg)						\
> -	.set	push;						\
> -	.set	noat;						\
>  	ADD	sum, reg;					\
>  	sltu	v1, sum, reg;					\
>  	ADD	sum, v1;					\
> -	.set	pop

Is this required?  Just a cleanup?

> @@ -254,8 +256,6 @@ LEAF(csum_partial)
>  1:	ADDC(sum, t1)
>  
>  	/* fold checksum */
> -	.set	push
> -	.set	noat
>  #ifdef USE_DOUBLE
>  	dsll32	v1, sum, 0
>  	daddu	sum, v1
> @@ -263,24 +263,25 @@ LEAF(csum_partial)
>  	dsra32	sum, sum, 0
>  	addu	sum, v1
>  #endif
> -	sll	v1, sum, 16
> -	addu	sum, v1
> -	sltu	v1, sum, v1
> -	srl	sum, sum, 16
> -	addu	sum, v1
>  
>  	/* odd buffer alignment? */
> -	beqz	t7, 1f
> -	 nop
> -	sll	v1, sum, 8
> +#ifdef CPU_MIPSR2
> +	wsbh	v1, sum	
> +	movn	sum, v1, t7
> +#else
> +	beqz	t7, 1f			/* odd buffer alignment? */
> +	 lui	v1, 0x00ff
> +	addu	v1, 0x00ff
> +	and	t0, sum, v1
> +	sll	t0, t0, 8
>  	srl	sum, sum, 8
> -	or	sum, v1
> -	andi	sum, 0xffff
> -	.set	pop
> +	and	sum, sum, v1
> +	or	sum, sum, t0
>  1:
> +#endif

Is this just an optimization?  or contain any fixes?

---
Atsushi Nemoto
