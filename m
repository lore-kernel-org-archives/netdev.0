From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] alpha: fix alignment problem in csum_ipv6_magic()
Date: Thu, 21 Jun 2007 16:35:01 -0700
Message-ID: <20070621163501.00903134.akpm@linux-foundation.org>
References: <20070617012020.A7626@jurassic.park.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rth@twiddle.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Dustin Marquess <jailbird@alcatraz.fdf.net>
To: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:45466 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750717AbXFUXgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 19:36:19 -0400
In-Reply-To: <20070617012020.A7626@jurassic.park.msu.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Sun, 17 Jun 2007 01:20:20 +0400 Ivan Kokshaysky <ink@jurassic.park.msu.ru> wrote:
> Hopefully this fixes http://bugzilla.kernel.org/show_bug.cgi?id=8635
> 
> The struct in6_addr passed to csum_ipv6_magic() is 4 byte aligned,
> so we can't use the regular 64-bit loads.
> Since the cost of handling of 4 byte and 1 byte aligned 64-bit data is
> roughly the same, this code can cope with any src/dst [mis]alignment.
> 
> Signed-off-by: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
> 
> Ivan.
> 
> --- 2.6.22-rc4/arch/alpha/lib/ev6-csum_ipv6_magic.S	Sun Feb  4 21:44:54 2007
> +++ linux/arch/alpha/lib/ev6-csum_ipv6_magic.S	Sun Jun 17 00:41:53 2007
> @@ -46,6 +46,10 @@
>   * add the 3 low ushorts together, generating a uint
>   * a final add of the 2 lower ushorts
>   * truncating the result.
> + *
> + * Misalignment handling added by Ivan Kokshaysky <ink@jurassic.park.msu.ru>
> + * The cost is 16 instructions (~8 cycles), including two extra loads which
> + * may cause additional delay in rare cases (load-load replay traps).
>   */
>  
>  	.globl csum_ipv6_magic
> @@ -55,25 +59,45 @@
>  csum_ipv6_magic:
>  	.prologue 0
>  
> -	ldq	$0,0($16)	# L : Latency: 3
> +	ldq_u	$0,0($16)	# L : Latency: 3
>  	inslh	$18,7,$4	# U : 0000000000AABBCC
> -	ldq	$1,8($16)	# L : Latency: 3
> +	ldq_u	$1,8($16)	# L : Latency: 3
>  	sll	$19,8,$7	# U : U L U L : 0x00000000 00aabb00
>  
> +	and	$16,7,$6	# E : src misalignment
> +	ldq_u	$5,15($16)	# L : Latency: 3
>  	zapnot	$20,15,$20	# U : zero extend incoming csum
> -	ldq	$2,0($17)	# L : Latency: 3
> -	sll	$19,24,$19	# U : U L L U : 0x000000aa bb000000
> -	inswl	$18,3,$18	# U : 000000CCDD000000
> +	ldq_u	$2,0($17)	# L : U L U L : Latency: 3
> +
> +	extql	$0,$6,$0	# U :
> +	extqh	$1,$6,$22	# U :
> +	ldq_u	$3,8($17)	# L : Latency: 3
> +	sll	$19,24,$19	# U : U U L U : 0x000000aa bb000000
> +
> +	cmoveq	$6,$31,$22	# E : src aligned?
> +	ldq_u	$23,15($17)	# L : Latency: 3
> +	or	$18,$4,$18	# E : 000000CCDDAABBCC
> +	extql	$1,$6,$1	# U : U L L U :
>  
> -	ldq	$3,8($17)	# L : Latency: 3
> -	bis	$18,$4,$18	# E : 000000CCDDAABBCC
> +	or	$0,$22,$0	# E : 1st src word complete
> +	extqh	$5,$6,$5	# U :
>  	addl	$19,$7,$19	# E : <sign bits>bbaabb00
> -	nop			# E : U L U L
> +	and	$17,7,$6	# E : L U L U : dst misalignment
>  
> +	inswl	$18,3,$18	# U : 000000CCDD000000
> +	or	$1,$5,$1	# E : 2nd src word complete
> +	extql	$2,$6,$2	# U :
> +	extqh	$3,$6,$22	# U : U L U U :
> +
> +	cmoveq	$6,$31,$22	# E : dst aligned?
> +	extql	$3,$6,$3	# U :
>  	addq	$20,$0,$20	# E : begin summing the words
> +	extqh	$23,$6,$23	# U : L U L U :
> +
>  	srl	$18,16,$4	# U : 0000000000CCDDAA
> +	or	$2,$22,$2	# E : 1st dst word complete
>  	zap	$19,0x3,$19	# U : <sign bits>bbaa0000
> -	nop			# E : L U U L
> +	or	$3,$23,$3	# E : U L U L : 2nd dst word complete
>  
>  	cmpult	$20,$0,$0	# E :
>  	addq	$20,$1,$20	# E :
> --- 2.6.22-rc4/arch/alpha/lib/csum_ipv6_magic.S	Sun Feb  4 21:44:54 2007
> +++ linux/arch/alpha/lib/csum_ipv6_magic.S	Sun Jun 17 00:29:28 2007
> @@ -7,6 +7,9 @@
>   *                                __u32 len,
>   *                                unsigned short proto,
>   *                                unsigned int csum);
> + *
> + * Misalignment handling (which costs 16 instructions / 8 cycles) 
> + * added by Ivan Kokshaysky <ink@jurassic.park.msu.ru>
>   */
>  
>  	.globl csum_ipv6_magic
> @@ -16,37 +19,57 @@
>  csum_ipv6_magic:
>  	.prologue 0
>  
> -	ldq	$0,0($16)	# e0    : load src & dst addr words
> +	ldq_u	$0,0($16)	# e0    : load src & dst addr words
>  	zapnot	$20,15,$20	# .. e1 : zero extend incoming csum
>  	extqh	$18,1,$4	# e0    : byte swap len & proto while we wait
> -	ldq	$1,8($16)	# .. e1 :
> +	ldq_u	$21,7($16)	# .. e1 : handle misalignment
>  
>  	extbl	$18,1,$5	# e0	:
> -	ldq	$2,0($17)	# .. e1 :
> +	ldq_u	$1,8($16)	# .. e1 :
>  	extbl	$18,2,$6	# e0 	:
> -	ldq	$3,8($17)	# .. e1 :
> +	ldq_u	$22,15($16)	# .. e1 :
>  
>  	extbl	$18,3,$18	# e0	:
> +	ldq_u	$2,0($17)	# .. e1 :
>  	sra	$4,32,$4	# e0	:
> +	ldq_u	$23,7($17)	# .. e1 :
> +
> +	extql	$0,$16,$0	# e0	:
> +	ldq_u	$3,8($17)	# .. e1 :
> +	extqh	$21,$16,$21	# e0	:
> +	ldq_u	$24,15($17)	# .. e1 :
> +
>  	sll	$5,16,$5	# e0	:
> +	or	$0,$21,$0	# .. e1 : 1st src word complete
> +	extql	$1,$16,$1	# e0	:
>  	addq	$20,$0,$20	# .. e1 : begin summing the words
>  
> -	sll	$6,8,$6		# e0	:
> +	extqh	$22,$16,$22	# e0	:
>  	cmpult	$20,$0,$0	# .. e1 :
> -	extwh	$19,7,$7	# e0    :
> -	or	$4,$18,$18	# .. e1 :
> +	sll	$6,8,$6		# e0	:
> +	or	$1,$22,$1	# .. e1 : 2nd src word complete
>  
> -	extbl	$19,1,$19	# e0    :
> +	extql	$2,$17,$2	# e0	:
> +	or	$4,$18,$18	# .. e1 :
> +	extqh	$23,$17,$23	# e0	:
>  	or	$5,$6,$5	# .. e1 :
> -	or	$18,$5,$18	# e0    : len complete
> -	or	$19,$7,$19	# .. e1 :
>  
> -	sll	$19,48,$19	# e0    :
> +	extql	$3,$17,$3	# e0	:
> +	or	$2,$23,$2	# .. e1 : 1st dst word complete
> +	extqh	$24,$17,$24	# e0	:
> +	or	$18,$5,$18	# .. e1 : len complete
> +
> +	extwh	$19,7,$7	# e0    :
> +	or	$3,$24,$3	# .. e1 : 2nd dst word complete
> +	extbl	$19,1,$19	# e0    :
>  	addq	$20,$1,$20	# .. e1 :
> -	sra	$19,32,$19	# e0    : proto complete
> +
> +	or	$19,$7,$19	# e0    :
>  	cmpult	$20,$1,$1	# .. e1 :
> +	sll	$19,48,$19	# e0    :
> +	nop			# .. e0 :
>  
> -	nop			# e0    :
> +	sra	$19,32,$19	# e0    : proto complete
>  	addq	$20,$2,$20	# .. e1 :
>  	cmpult	$20,$2,$2	# e0    :
>  	addq	$20,$3,$20	# .. e1 :
> @@ -84,7 +107,7 @@ csum_ipv6_magic:
>  	extwl	$0,2,$1		# e0    : fold 17-bit value
>  	zapnot	$0,3,$0		# .. e1 :
>  	addq	$0,$1,$0	# e0    :
> -	not	$0,$0		# e1    : and complement.
> +	not	$0,$0		# .. e1 : and complement.
>  
>  	zapnot	$0,3,$0		# e0    :
>  	ret			# .. e1 :

In http://bugzilla.kernel.org/show_bug.cgi?id=8659, Dustin is reporting
that this patch broke tcp-on-ipv6.


