From: "George Spelvin" <linux@horizon.com>
Subject: Re: [PATCH v4 net-next] net: Implement fast csum_partial for x86_64
Date: 28 Feb 2016 16:43:51 -0500
Message-ID: <20160228214351.28141.qmail@ns.horizon.com>
Cc: linux@horizon.com, netdev@vger.kernel.org
To: alexander.duyck@gmail.com, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.horizon.com ([71.41.210.147]:62141 "HELO ns.horizon.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755254AbcB1Vnx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2016 16:43:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was just noticing that these two:

> +static inline unsigned long add64_with_carry(unsigned long a, unsigned long b)
> +{
> +       asm("addq %2,%0\n\t"
> +           "adcq $0,%0"
> +           : "=r" (a)
> +           : "0" (a), "rm" (b));
> +       return a;
> +}
> +
> +static inline unsigned int add32_with_carry3(unsigned int a, unsigned int b,
> +                                            unsigned int c)
> +{
> +       asm("addl %2,%0\n\t"
> +           "adcl %3,%0\n\t"
> +           "adcl $0,%0"
> +           : "=r" (a)
> +           : "" (a), "rm" (b), "rm" (c));
> +
> +       return a;
> +}

Could use some additional GCC asm wizardry.

There are a couple of lesser-known inline asm features which
could be brought to bear here:

1) The "%" modifier, meaning "operation is commutative", and
2) Multiple alternatives, and the "?" modifier.
3) The earlyclobber modifier "&".


For the first, I'd make it

> +       asm("addq %2,%0\n\t"
> +           "adcq $0,%0"
> +           : "=%a,r?" (a)
> +           : "%0,0" (a), "g,g" (b));

I also switched "rm" to "g" (general operand), since it's more compact,
and an immediate operand is technically allowed.

By including the "%", this tells GCC that swapping the a and b inputs is
fine if that helps register allocation.

The comma separates two alternative sets of constraints.  "a,r?" says
there are two options: using register %eax, and a second using any
register which is slightly worse (larger code).  The later "g,g" shows
the corresponding constraints for b.

Technically, there's a third option and you could do something like

> +           : "=a,r?,rm!" (a)
> +           : "%0,0,0" (a), "g,g,r" (b));

Where if b is a register, then a could be a memory location (and the !
means "avoid unless it saves a spill"), but that's probably not even worth
telling gcc about.


The three-input form can do the same.  There's a third feature we should add:
an "earlyclobber" notation on the output, since otherwise GCC will
turn
	add32_with_carry3(a, b, a)
into
	addl %ebx,%eax
	addl %eax,%eax
	addl $0,%eax
... as unlikely as gcc is to find an opportunity for such an optimization.

What I'd *like* to write is

> +       asm("addl %2,%0\n\t"
> +           "adcl %3,%0\n\t"
> +           "adcl $0,%0"
> +           : "=&a,&r?" (a)
> +           : "%0,0" (a), "%g,g" (b), "g,g" (c));

... but TFM explains "GCC can only handle one commutative pair in an asm;
if you use more, the compiler may fail."  So I have to pick one.

Also, if the idiom is "add32_with_carry3(sum, result >> 32, result);", then
it would be better to add c then b to match the length of the
dependency chains.  I.e.

> +       asm("addl %2,%0\n\t"
> +           "adcl %3,%0\n\t"
> +           "adcl $0,%0"
> +           : "=&a,&r?" (a)
> +           : "%0,0" (a), "g,g" (c), "g,g" (b));

(I would have also switched to "+a,r?" constraints, but I'm not positive
how + interacts with %.)
