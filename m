From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 6/9] powerpc32: optimise a few instructions in
 csum_partial()
Date: Thu, 22 Oct 2015 22:30:40 -0500
Message-ID: <1445571040.701.149.camel@freescale.com>
References: <cover.1442876807.git.christophe.leroy@c-s.fr>
	 <0a4e1624642137dc2b16bbb68ea87b1a479dfa34.1442876807.git.christophe.leroy@c-s.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	<linux-kernel@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>,
	<netdev@vger.kernel.org>
To: Christophe Leroy <christophe.leroy@c-s.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0a4e1624642137dc2b16bbb68ea87b1a479dfa34.1442876807.git.christophe.leroy@c-s.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-09-22 at 16:34 +0200, Christophe Leroy wrote:
> r5 does contain the value to be updated, so lets use r5 all way long
> for that. It makes the code more readable.
> 
> To avoid confusion, it is better to use adde instead of addc
> 
> The first addition is useless. Its only purpose is to clear carry.
> As r4 is a signed int that is always positive, this can be done by
> using srawi instead of srwi
> 
> Let's also remove the comment about bdnz having no overhead as it
> is not correct on all powerpc, at least on MPC8xx
> 
> In the last part, in our situation, the remaining quantity of bytes
> to be proceeded is between 0 and 3. Therefore, we can base that part
> on the value of bit 31 and bit 30 of r4 instead of anding r4 with 3
> then proceding on comparisons and substractions.
> 
> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
> ---
>  arch/powerpc/lib/checksum_32.S | 37 +++++++++++++++++--------------------
>  1 file changed, 17 insertions(+), 20 deletions(-)

Do you have benchmarks for these optimizations?

-Scott

> 
> diff --git a/arch/powerpc/lib/checksum_32.S b/arch/powerpc/lib/checksum_32.S
> index 3472372..9c12602 100644
> --- a/arch/powerpc/lib/checksum_32.S
> +++ b/arch/powerpc/lib/checksum_32.S
> @@ -27,35 +27,32 @@
>   * csum_partial(buff, len, sum)
>   */
>  _GLOBAL(csum_partial)
> -     addic   r0,r5,0
>       subi    r3,r3,4
> -     srwi.   r6,r4,2
> +     srawi.  r6,r4,2         /* Divide len by 4 and also clear carry */
>       beq     3f              /* if we're doing < 4 bytes */
> -     andi.   r5,r3,2         /* Align buffer to longword boundary */
> +     andi.   r0,r3,2         /* Align buffer to longword boundary */
>       beq+    1f
> -     lhz     r5,4(r3)        /* do 2 bytes to get aligned */
> -     addi    r3,r3,2
> +     lhz     r0,4(r3)        /* do 2 bytes to get aligned */
>       subi    r4,r4,2
> -     addc    r0,r0,r5
> +     addi    r3,r3,2
>       srwi.   r6,r4,2         /* # words to do */
> +     adde    r5,r5,r0
>       beq     3f
>  1:   mtctr   r6
> -2:   lwzu    r5,4(r3)        /* the bdnz has zero overhead, so it should */
> -     adde    r0,r0,r5        /* be unnecessary to unroll this loop */
> +2:   lwzu    r0,4(r3)
> +     adde    r5,r5,r0
>       bdnz    2b
> -     andi.   r4,r4,3
> -3:   cmpwi   0,r4,2
> -     blt+    4f
> -     lhz     r5,4(r3)
> +3:   andi.   r0,r4,2
> +     beq+    4f
> +     lhz     r0,4(r3)
>       addi    r3,r3,2
> -     subi    r4,r4,2
> -     adde    r0,r0,r5
> -4:   cmpwi   0,r4,1
> -     bne+    5f
> -     lbz     r5,4(r3)
> -     slwi    r5,r5,8         /* Upper byte of word */
> -     adde    r0,r0,r5
> -5:   addze   r3,r0           /* add in final carry */
> +     adde    r5,r5,r0
> +4:   andi.   r0,r4,1
> +     beq+    5f
> +     lbz     r0,4(r3)
> +     slwi    r0,r0,8         /* Upper byte of word */
> +     adde    r5,r5,r0
> +5:   addze   r3,r5           /* add in final carry */
>       blr
>  
>  /*
