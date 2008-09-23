From: Bryan Phillippe <u1@terran.org>
Subject: Re: [PATCH] MIPS checksum fix
Date: Tue, 23 Sep 2008 14:52:24 -0700
Message-ID: <BFB5F5A7-2980-4BCB-A14D-9EB6114B031B@terran.org>
References: <Pine.LNX.4.55.0809171104290.17103@cliff.in.clinika.pl> <20080917.222350.41199051.anemo@mba.ocn.ne.jp> <Pine.LNX.4.55.0809171501450.17103@cliff.in.clinika.pl> <20080918.002705.78730226.anemo@mba.ocn.ne.jp> <Pine.LNX.4.55.0809171917580.17103@cliff.in.clinika.pl> <20080918220734.GA19222@linux-mips.org> <Pine.LNX.4.55.0809190112090.22686@cliff.in.clinika.pl> <20080919112304.GB13440@linux-mips.org> <20080919114743.GA19359@linux-mips.org> <20080919120752.GA19877@linux-mips.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: "Maciej W. Rozycki" <macro@linux-mips.org>,
	linux-mips@linux-mips.org, netdev@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>,
	Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:50642
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752831AbYIWVzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 17:55:13 -0400
In-Reply-To: <20080919120752.GA19877@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sep 19, 2008, at 5:07 AM, Ralf Baechle wrote:

> On Fri, Sep 19, 2008 at 01:47:43PM +0200, Ralf Baechle wrote:
>
>> I'm interested in test reports of this on all sorts of  
>> configurations -
>> 32-bit, 64-bit, big / little endian, R2 processors and pre-R2.  In
>> particular Cavium being the only MIPS64 R2 implementation would be
>> interesting.  This definately is stuff which should go upstream for  
>> 2.6.27.
>
> There was a trivial bug in the R2 code.
>
>> From 97ad23f4696a322cb3bc379a25a8c0f6526751d6 Mon Sep 17 00:00:00  
>> 2001
> From: Ralf Baechle <ralf@linux-mips.org>
> Date: Fri, 19 Sep 2008 14:05:53 +0200
> Subject: [PATCH] [MIPS] Fix 64-bit csum_partial,  
> __csum_partial_copy_user and csum_partial_copy
>
> On 64-bit machines it wouldn't handle a possible carry when adding the
> 32-bit folded checksum and checksum argument.
>
> While at it, add a few trivial optimizations, also for R2 processors.

I tried this patch (with and without Atsushi's addition, shown below)  
on a MIPS64 today and the checksums were all bad (i.e. worse than the  
original problem).

Note that I had to manually create the diff, because of "malformed  
patch" errors at line 21 (second hunk).

If anyone would like to send me an updated unified diff for this  
issue, I can re-test today within the next day.

--
-bp

> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
>
> diff --git a/arch/mips/lib/csum_partial.S b/arch/mips/lib/ 
> csum_partial.S
> index 8d77841..c77a7a0 100644
> --- a/arch/mips/lib/csum_partial.S
> +++ b/arch/mips/lib/csum_partial.S
> @@ -53,12 +53,14 @@
> #define UNIT(unit)  ((unit)*NBYTES)
>
> #define ADDC(sum,reg)						\
> -	.set	push;						\
> -	.set	noat;						\
> 	ADD	sum, reg;					\
> 	sltu	v1, sum, reg;					\
> 	ADD	sum, v1;					\
> -	.set	pop
> +
> +#define ADDC32(sum,reg)						\
> +	addu	sum, reg;					\
> +	sltu	v1, sum, reg;					\
> +	addu	sum, v1;					\
>
> #define CSUM_BIGCHUNK1(src, offset, sum, _t0, _t1, _t2, _t3)	\
> 	LOAD	_t0, (offset + UNIT(0))(src);			\
> @@ -254,8 +256,6 @@ LEAF(csum_partial)
> 1:	ADDC(sum, t1)
>
> 	/* fold checksum */
> -	.set	push
> -	.set	noat
> #ifdef USE_DOUBLE
> 	dsll32	v1, sum, 0
> 	daddu	sum, v1
> @@ -263,24 +263,25 @@ LEAF(csum_partial)
> 	dsra32	sum, sum, 0
> 	addu	sum, v1
> #endif
> -	sll	v1, sum, 16
> -	addu	sum, v1
> -	sltu	v1, sum, v1
> -	srl	sum, sum, 16
> -	addu	sum, v1
>
> 	/* odd buffer alignment? */
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
> 	srl	sum, sum, 8
> -	or	sum, v1
> -	andi	sum, 0xffff
> -	.set	pop
> +	and	sum, sum, v1
> +	or	sum, sum, t0
> 1:
> +#endif
> 	.set	reorder
> 	/* Add the passed partial csum.  */
> -	ADDC(sum, a2)
> +	ADDC32(sum, a2)
> 	jr	ra
> 	.set	noreorder
> 	END(csum_partial)
> @@ -656,8 +657,6 @@ EXC(	sb	t0, NBYTES-2(dst), .Ls_exc)
> 	ADDC(sum, t2)
> .Ldone:
> 	/* fold checksum */
> -	.set	push
> -	.set	noat
> #ifdef USE_DOUBLE
> 	dsll32	v1, sum, 0
> 	daddu	sum, v1
> @@ -665,23 +664,23 @@ EXC(	sb	t0, NBYTES-2(dst), .Ls_exc)
> 	dsra32	sum, sum, 0
> 	addu	sum, v1
> #endif
> -	sll	v1, sum, 16
> -	addu	sum, v1
> -	sltu	v1, sum, v1
> -	srl	sum, sum, 16
> -	addu	sum, v1
>
> -	/* odd buffer alignment? */
> -	beqz	odd, 1f
> -	 nop
> -	sll	v1, sum, 8
> +#ifdef CPU_MIPSR2
> +	wsbh	v1, sum
> +	movn	sum, v1, odd
> +#else
> +	beqz	odd, 1f			/* odd buffer alignment? */
> +	 lui	v1, 0x00ff
> +	addu	v1, 0x00ff
> +	and	t0, sum, v1
> +	sll	t0, t0, 8
> 	srl	sum, sum, 8
> -	or	sum, v1
> -	andi	sum, 0xffff
> -	.set	pop
> +	and	sum, sum, v1
> +	or	sum, sum, t0
> 1:
> +#endif
> 	.set reorder
> -	ADDC(sum, psum)
> +	ADDC32(sum, psum)
> 	jr	ra
> 	.set noreorder
>
>



Begin forwarded message:

> From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
> Date: September 19, 2008 8:43:19 AM PDT
> To: u1@terran.org
> Cc: macro@linux-mips.org, linux-mips@linux-mips.org
> Subject: Re: MIPS checksum bug
>
> On Fri, 19 Sep 2008 01:17:04 +0900 (JST), Atsushi Nemoto <anemo@mba.ocn.ne.jp 
> > wrote:
>> Thank you for testing.  Though this patch did not fixed your problem,
>> I still have a doubt on 64-bit optimization.
>>
>> If your hardware could run 32-bit kernel, could you confirm the
>> problem can happens in 32-bit too or not?
>
> I think I found possible breakage on 64-bit path.
>
> There are some "lw" (and "ulw") used in 64-bit path and they should be
> "lwu" (and "ulwu" ... but there is no such pseudo insn) to avoid
> sign-extention.
>
> Here is a completely untested patch.
>
> diff --git a/arch/mips/lib/csum_partial.S b/arch/mips/lib/ 
> csum_partial.S
> index 8d77841..40f9174 100644
> --- a/arch/mips/lib/csum_partial.S
> +++ b/arch/mips/lib/csum_partial.S
> @@ -39,12 +39,14 @@
> #ifdef USE_DOUBLE
>
> #define LOAD   ld
> +#define LOAD32 lwu
> #define ADD    daddu
> #define NBYTES 8
>
> #else
>
> #define LOAD   lw
> +#define LOAD32 lw
> #define ADD    addu
> #define NBYTES 4
>
> @@ -60,6 +62,14 @@
> 	ADD	sum, v1;					\
> 	.set	pop
>
> +#define ADDC32(sum,reg)						\
> +	.set	push;						\
> +	.set	noat;						\
> +	addu	sum, reg;					\
> +	sltu	v1, sum, reg;					\
> +	addu	sum, v1;					\
> +	.set	pop
> +
> #define CSUM_BIGCHUNK1(src, offset, sum, _t0, _t1, _t2, _t3)	\
> 	LOAD	_t0, (offset + UNIT(0))(src);			\
> 	LOAD	_t1, (offset + UNIT(1))(src);			\
> @@ -132,7 +142,7 @@ LEAF(csum_partial)
> 	beqz	t8, .Lqword_align
> 	 andi	t8, src, 0x8
>
> -	lw	t0, 0x00(src)
> +	LOAD32	t0, 0x00(src)
> 	LONG_SUBU	a1, a1, 0x4
> 	ADDC(sum, t0)
> 	PTR_ADDU	src, src, 0x4
> @@ -211,7 +221,7 @@ LEAF(csum_partial)
> 	LONG_SRL	t8, t8, 0x2
>
> .Lend_words:
> -	lw	t0, (src)
> +	LOAD32	t0, (src)
> 	LONG_SUBU	t8, t8, 0x1
> 	ADDC(sum, t0)
> 	.set	reorder				/* DADDI_WAR */
> @@ -229,6 +239,9 @@ LEAF(csum_partial)
>
> 	/* Still a full word to go  */
> 	ulw	t1, (src)
> +#ifdef USE_DOUBLE
> +	add	t1, zero	/* clear upper 32bit */
> +#endif
> 	PTR_ADDIU	src, 4
> 	ADDC(sum, t1)
>
> @@ -280,7 +293,7 @@ LEAF(csum_partial)
> 1:
> 	.set	reorder
> 	/* Add the passed partial csum.  */
> -	ADDC(sum, a2)
> +	ADDC32(sum, a2)
> 	jr	ra
> 	.set	noreorder
> 	END(csum_partial)
> @@ -681,7 +694,7 @@ EXC(	sb	t0, NBYTES-2(dst), .Ls_exc)
> 	.set	pop
> 1:
> 	.set reorder
> -	ADDC(sum, psum)
> +	ADDC32(sum, psum)
> 	jr	ra
> 	.set noreorder
>
