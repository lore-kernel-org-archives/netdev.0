From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] tcp_cubic: use 32 bit math
Date: Tue, 13 Mar 2007 21:50:20 +0100
Message-ID: <20070313205020.GA5418@1wt.eu>
References: <20070307170731.2b4397e3@freekitty> <20070307.185539.48527371.davem@davemloft.net> <45EF7EB7.8040806@linux-foundation.org> <20070307.195135.74749102.davem@davemloft.net> <20070310114826.GB1608@1wt.eu> <20070312141156.08e88b0e@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	rkuhn@e18.physik.tu-muenchen.de, andi@firstfloor.org,
	dada1@cosmosbay.com, jengelh@linux01.gwdg.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1163 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933266AbXCMUzN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2007 16:55:13 -0400
Content-Disposition: inline
In-Reply-To: <20070312141156.08e88b0e@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

On Mon, Mar 12, 2007 at 02:11:56PM -0700, Stephen Hemminger wrote:
> > Oh BTW, I have a newer version with a first approximation of the
> > cbrt() before the div64_64, which allows us to reduce from 3 div64
> > to only 2 div64. This results in a version which is twice as fast
> > as the initial one (ncubic), but with slightly less accuracy (0.286%
> > compared to 0.247). But I see that other functions such as hcbrt()
> > had a 1.5% avg error, so I think this is not dramatic.
> 
> Ignore my hcbrt() it was a less accurate version of andi's stuff.

OK.

> > Also, I managed to remove all other divides, to be kind with CPUs
> > having a slow divide instruction or no divide at all. Since we compute
> > on limited range (22 bits), we can multiply then shift right. It shows
> > me even slightly better time on pentium-m and athlon, with a slightly
> > higher avg error (0.297% compared to 0.286%), and slightly smaller
> > code.
> 
> What does the code look like?

Well, I have cleaned it a little bit, there were more comments and ifdefs
than code ! I've appended it to the end of this mail.

I have changed it a bit, because I noticed that integer divide precision
was so coarse that there were other possibilities to play with the bits.

I have experimented with combinations of several methods :
  - replace integer divides with multiplies/shifts where possible.

  - compensation for divide imprecisions by adding/removing small
    values bofore/after them. Often, the integer result of 1/(x*(x-1))
    is closer to (float)1/(float)x^2 than 1/(x*x). This is because
    the divide always truncates the result.

  - use direct result lookup for small values. Small inputs give small
    outputs which have very few moving bits. Many different values fit
    in a 32bit integer, so we use a shift offset to lookup the value.
    I used this in an fls function I wrote a while ago, that I should
    also post because it is up to twice as fast as the kernel's.
    Sometimes it seems faster to lookup in from memory, sometimes it
    is faster from an immediate value. Maybe more visible differences
    would show up on RISC CPUs where loading 32 bits immediate needs
    two instructions. I don't know yet, I've not tested on my sparc
    yet.

  - use small lookup tables (64 bytes) with 6 bits inputs and at least
    as many on output. We only lookup the 6 MSB and return the 2-3 MSB
    of the result.

  - iterative search and manual refinment of the lookup tables for best
    accuracy. The avg error rate can easily be halved this way.

I have duplicated tried several functions with 0, 1, 2 and 3 divides.
Several of them offer better accuracy over what we currently have, in
less cycles. Others offer faster results (up to 5 times) with slightly
less accuracy.

There is one function which is not to be used, but is just here for
comparison (ncubic_0div). It does no divide but has awful avg error.

But one which is interesting is the ncubic_tab0. It does not use any
divide at all, even not any div64. It shows a 0.6% avg error, which I'm
not sure is enough or not. It is 6.7 times faster than initial ncubic()
with less accuracy, and 4 times smaller. I suspect that it can differ
more on architectures which have no divide instruction.

Is 0.6% avg error rate is too much, ncubic_tab1() uses one single div64
and is twice slower (still nearly 3 times faster than ncubic). It show
0.195% avg error, which is better than initial ncubic. I think that it
is a good tradeoff.

If best accuracy is an absolute requirement, then I have a variation of
ncubic (ncubic_3div) which does 0.17% in 2/3 of the time (compared to
0.247%), and which is slightly smaller.

I have also added a "size" column, indicating approximative function
size, provided that the compiler does not reorder the code. On gcc 3.4,
it's OK, but 4.1 returns garbage. That does not matter, it's just a
rough estimate anyway.

Here are the results classed by speed :

/* Sample output on a Pentium-M 600 MHz :

Function          clocks mean(us)  max(us)  std(us) Avg err size
ncubic_tab0           79     0.66     7.20     1.04  0.613%  160
ncubic_0div           84     0.70     7.64     1.57  4.521%  192
ncubic_1div          178     1.48    16.27     1.81  0.443%  336
ncubic_tab1          179     1.49    16.34     1.85  0.195%  320
ncubic_ndiv3         263     2.18    24.04     3.59  0.250%  512
ncubic_2div          270     2.24    24.70     2.77  0.187%  512
ncubic32_1           359     2.98    32.81     3.59  0.238%  544
ncubic_3div          361     2.99    33.08     3.79  0.170%  656
ncubic32             364     3.02    33.29     3.51  0.247%  544
ncubic               529     4.39    48.39     4.92  0.247%  720
hcbrt                539     4.47    49.25     5.98  1.580%   96
ocubic               732     4.93    61.83     7.22  0.274%  320
acbrt                842     6.98    76.73     8.55  0.275%  192
bictcp              1032     6.95    86.30     9.04  0.172%  768

And now by avg error :

ncubic_3div          361     2.99    33.08     3.79  0.170%  656
bictcp              1032     6.95    86.30     9.04  0.172%  768
ncubic_2div          270     2.24    24.70     2.77  0.187%  512
ncubic_tab1          179     1.49    16.34     1.85  0.195%  320
ncubic32_1           359     2.98    32.81     3.59  0.238%  544
ncubic               529     4.39    48.39     4.92  0.247%  720
ncubic32             364     3.02    33.29     3.51  0.247%  544
ncubic_ndiv3         263     2.18    24.04     3.59  0.250%  512
ocubic               732     4.93    61.83     7.22  0.274%  320
acbrt                842     6.98    76.73     8.55  0.275%  192
ncubic_1div          178     1.48    16.27     1.81  0.443%  336
ncubic_tab0           79     0.66     7.20     1.04  0.613%  160
hcbrt                539     4.47    49.25     5.98  1.580%   96
ncubic_0div           84     0.70     7.64     1.57  4.521%  192


And here comes the code. I have tried to document it a bit, as much
as can be done on experimentation code. It is often easier to use
a pencil and paper to understand how the bits move.

Regards,
Willy



/*
Here is a better version of the benchmark code.
It has the original code used in 2.4 version of Cubic for comparison

-----------------------------------------------------------
*/
/* Test and measure perf of cube root algorithms.  */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>
#include <unistd.h>

#ifdef __x86_64

#define rdtscll(val) do { \
     unsigned int __a,__d; \
     asm volatile("rdtsc" : "=a" (__a), "=d" (__d)); \
     (val) = ((unsigned long)__a) | (((unsigned long)__d)<<32); \
} while(0)

# define do_div(n,base) ({					\
	uint32_t __base = (base);				\
	uint32_t __rem;						\
	__rem = ((uint64_t)(n)) % __base;			\
	(n) = ((uint64_t)(n)) / __base;				\
	__rem;							\
 })


/**
 * __ffs - find first bit in word.
 * @word: The word to search
 *
 * Undefined if no bit exists, so code should check against 0 first.
 */
static __inline__ unsigned long __ffs(unsigned long word)
{
	__asm__("bsfq %1,%0"
		:"=r" (word)
		:"rm" (word));
	return word;
}

/*
 * __fls: find last bit set.
 * @word: The word to search
 *
 * Undefined if no zero exists, so code should check against ~0UL first.
 */
static inline unsigned long __fls(unsigned long word)
{
	__asm__("bsrq %1,%0"
		:"=r" (word)
		:"rm" (word));
	return word;
}

/**
 * ffs - find first bit set
 * @x: the word to search
 *
 * This is defined the same way as
 * the libc and compiler builtin ffs routines, therefore
 * differs in spirit from the above ffz (man ffs).
 */
static __inline__ int ffs(int x)
{
	int r;

	__asm__("bsfl %1,%0\n\t"
		"cmovzl %2,%0" 
		: "=r" (r) : "rm" (x), "r" (-1));
	return r+1;
}

/**
 * fls - find last bit set
 * @x: the word to search
 *
 * This is defined the same way as ffs.
 */
static inline int fls(int x)
{
	int r;

	__asm__("bsrl %1,%0\n\t"
		"cmovzl %2,%0"
		: "=&r" (r) : "rm" (x), "rm" (-1));
	return r+1;
}

/**
 * fls64 - find last bit set in 64 bit word
 * @x: the word to search
 *
 * This is defined the same way as fls.
 */
static inline int fls64(uint64_t x)
{
	if (x == 0)
		return 0;
	return __fls(x) + 1;
}

static inline uint64_t div64_64(uint64_t dividend, uint64_t divisor)
{
	return dividend / divisor;
}

#elif __i386

#define rdtscll(val) \
     __asm__ __volatile__("rdtsc" : "=A" (val))

/**
 * ffs - find first bit set
 * @x: the word to search
 *
 * This is defined the same way as
 * the libc and compiler builtin ffs routines, therefore
 * differs in spirit from the above ffz() (man ffs).
 */
static inline int ffs(int x)
{
	int r;

	__asm__("bsfl %1,%0\n\t"
		"jnz 1f\n\t"
		"movl $-1,%0\n"
		"1:" : "=r" (r) : "rm" (x));
	return r+1;
}

/**
 * fls - find last bit set
 * @x: the word to search
 *
 * This is defined the same way as ffs().
 */
static inline int fls(int x)
{
	int r;

	__asm__("bsrl %1,%0\n\t"
		"jnz 1f\n\t"
		"movl $-1,%0\n"
		"1:" : "=r" (r) : "rm" (x));
	return r+1;
}

static inline int fls64(uint64_t x)
{
	uint32_t h = x >> 32;
	if (h)
		return fls(h) + 32;
	return fls(x);
}


#define do_div(n,base) ({ \
	unsigned long __upper, __low, __high, __mod, __base; \
	__base = (base); \
	asm("":"=a" (__low), "=d" (__high):"A" (n)); \
	__upper = __high; \
	if (__high) { \
		__upper = __high % (__base); \
		__high = __high / (__base); \
	} \
	asm("divl %2":"=a" (__low), "=d" (__mod):"rm" (__base), "0" (__low), "1" (__upper)); \
	asm("":"=A" (n):"a" (__low),"d" (__high)); \
	__mod; \
})


/* 64bit divisor, dividend and result. dynamic precision */
static uint64_t div64_64(uint64_t dividend, uint64_t divisor)
{
	uint32_t d = divisor;

	if (divisor > 0xffffffffULL) {
		unsigned int shift = fls(divisor >> 32);

		d = divisor >> shift;
		dividend >>= shift;
	}

	/* avoid 64 bit division if possible */
	if (dividend >> 32)
		do_div(dividend, d);
	else
		dividend = (uint32_t) dividend / d;

	return dividend;
}

/* this one only works when the result is below 32 bits */
static uint32_t div64_64_32(uint64_t dividend, uint64_t divisor)
{
	uint32_t d = divisor;

	if (divisor > 0xffffffffULL) {
		unsigned int shift = fls(divisor >> 32);

		d = divisor >> shift;
		dividend >>= shift;
	}

	/* avoid 64 bit division if possible */
	if (dividend >> 32)
		do_div(dividend, d);
	else
		dividend = (uint32_t) dividend / d;
	return dividend;
}
#endif

/* Andi Kleen's version */
uint32_t acbrt(uint64_t x)
{
	uint32_t y = 0;
	int s;

	for (s = 63; s >= 0; s -= 3) {
		uint64_t b, bs;

		y = 2 * y;
		b = 3 * y * (y+1) + 1;
		bs = b << s;
		if (x >= bs && (b == (bs>>s))) {  /* avoid overflow */
			x -= bs;
			y++;
		}
	}
	return y;
}
uint32_t end_acbrt() { }

/* My version of hacker's delight */
uint32_t hcbrt(uint64_t x)
{
	int s = 60;
	uint32_t y = 0;

	do {
		uint64_t b;
		y = 2*y;
		b = (uint64_t)(3*y*(y + 1) + 1) << s;
		s = s - 3;
		if (x >= b) {
			x = x - b;
			y = y + 1;
		}
	} while(s >= 0);

	return y;
}
uint32_t end_hcbrt() { }

/* calculate the cubic root of x using Newton-Raphson */
static uint32_t ocubic(uint64_t a)
{
	uint32_t x, x1;

	/* Initial estimate is based on:
	 * cbrt(x) = exp(log(x) / 3)
	 */
	x = 1u << (fls64(a)/3);

	/*
	 * Iteration based on:
	 *                         2
	 * x    = ( 2 * x  +  a / x  ) / 3
	 *  k+1          k         k
	 */
	do {
		x1 = x;

		x = (2 * x + div64_64(a, (uint64_t)x * x)) / 3;
	} while (abs(x1 - x) > 1);

	return x;
}
static uint32_t end_ocubic() { }

/* calculate the cubic root of x using Newton-Raphson */
static uint32_t ncubic(uint64_t a)
{
	uint64_t x;

	/* Initial estimate is based on:
	 * cbrt(x) = exp(log(x) / 3)
	 */
	x = 1u << (fls64(a)/3);

	/* Converges in 3 iterations to > 32 bits */
	x = (2 * x + div64_64(a, x*x)) / 3;
	x = (2 * x + div64_64(a, x*x)) / 3;
	x = (2 * x + div64_64(a, x*x)) / 3;

	return x;
}
static uint32_t end_ncubic() { }

/* calculate the cubic root of x using Newton-Raphson.
 * Avg err ~= 0.247%
 */
static uint32_t ncubic32(uint64_t a)
{
	uint32_t x;

	/* Initial estimate is based on:
	 * cbrt(x) = exp(log(x) / 3)
	 */
	x = 1u << (fls64(a)/3);

	/* Converges in 3 iterations to > 32 bits */
	/* We can do 32bit maths here :
	 *   x ~= cbrt(a) so (a/x^2) ~= cbrt(a) which is about 22 bits max
	 */
	x = (2 * x + (uint32_t)div64_64(a, (uint64_t)x*(uint64_t)x)) / 3;
	x = (2 * x + (uint32_t)div64_64(a, (uint64_t)x*(uint64_t)x)) / 3;
	x = (2 * x + (uint32_t)div64_64(a, (uint64_t)x*(uint64_t)x)) / 3;

	return x;
}
static uint32_t end_ncubic32() { }

/* calculate the cubic root of x using Newton-Raphson - small refinement.
 * Avg err ~= 0.238%
 */
static uint32_t ncubic32_1(uint64_t a)
{
	uint32_t x;

	/* Initial estimate is based on:
	 * cbrt(x) = exp(log(x) / 3)
	 */
	x = 1u << ((fls64(a)+1)/3);

	/* Converges in 3 iterations to > 32 bits */
	/* We can do 32bit maths here :
	 *   x ~= cbrt(a) so (a/x^2) ~= cbrt(a) which is about 22 bits max
	 */
	x = (2 * x + (uint32_t)div64_64(a, (uint64_t)x*(uint64_t)x)) / 3;
	x = (2 * x + (uint32_t)div64_64(a, (uint64_t)x*(uint64_t)x)) / 3;
	x = (2 * x + (uint32_t)div64_64(a, (uint64_t)x*(uint64_t)x)) / 3;

	return x;
}
static uint32_t end_ncubic32_1() { }


int man_adj;

#define ALIGN64 __attribute__ ((aligned (8)))

/* calculate the cubic root of x using Newton-Raphson with less divides.
 * Avg err ~= 0.250%
 */
static uint32_t ncubic_ndiv3(uint64_t a)
{
	uint32_t x;
	uint32_t b;
	uint32_t y;

	/*
	 * For low values (between 2 and 63), we use a direct mapping of the
	 * input divided by 4 (between 0 and 15) to the output between 1 and 4.
	 * Those 4 values can be stored as two bits if we store the result
	 * minus 1, which constitute 32 bits for the 16 values.
	 * We use a uint32_t for this, which we shift right by a/4.
	 *
	 * a / 4   = 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
	 * a_max   = 63 59 55 51 47 43 39 35 31 27 23 19 15 11 07 03
	 * a_min   = 60 56 52 48 44 40 36 32 28 24 20 16 12 08 04 00
	 * cbrt(a) =  4  4  4  4  4  3  3  3  3  3  3  3  2  2  2  1
	 * bits    = 11 11 11 11 11 10 10 10 10 10 10 10 01 01 01 00
	 *         = 0xFFEAAA54UL
	 */
	ALIGN64 static uint32_t cbrt_x_4m1 = 0xFFEAAA54UL;


	/* For higher values, we use an initial estimation based on this fact :
	 *   cbrt(x) = exp(log(x) / 3)
	 * and :
	 *   cbrt(x * y) = cbrt(x) * cbrt(y)
	 *
	 * So for a block of 3 input bits, we can get 1 output bit, and for
	 * 6 input bits, we get 2 output bits (3 in fact due to rounding up).
	 * So we have to operate on 3bit boundaries, and check the highest
	 * 6 bits to provide 2 to 3 bits on output.
	 *
	 * Let's consider n the value so that we have between 4 and 6 MSB
	 * between bits 3n and 3n+5. We will set the output bits between
	 * n and n+2.
	 *
	 * We have 64 possible values for the 6 MSB. But since a cbrt()
	 * output changes slower than its input, we can easily focus on
	 * the 4 MSB only. This means 16 values. Just like above for the
	 * small values, we can store 16 * 2 bits in a uint32_t.
	 *
	 * The little difference is that we are not seeking exact output
	 * result, but the closest value to the exact output, to improve
	 * convergence speed. To achieve this, we start with same values
	 * as above, and iteratively refine them by hand so that the average
	 * error reaches its minimum.
	 *
	 * Theorical map value is     0xFFEAAA64UL.
	 * Experimental best value is 0xFFAFAA94UL.
	 *
	 * In order to find blocks of 3 bits aligned on 3n bits boundaries,
	 * we have to shift right by multiples of 3 bits. We want to avoid
	 * a costly divide, so we instead multiply by 84 and shift right by 8,
	 * as this returns the same values for inputs below and 64.
	 *
	 * For the results, we still have to divide by 3 multiple times. We
	 * know the result as well as intermediate values are less than 2^22,
	 * so we can use the same principle with shifted arithmetics :
	 *
	 *    341/1024 < 1/3 < 342/1024
	 *
	 * Rouding errors on integer maths generally can be compensated for by
	 * small offset adjustments before divides. Some have been added after
	 * experimentations to provide better accuracy.
	 *
	 */
	ALIGN64 static uint32_t cbrt_4msb2lsb = 0xFFAFAA94UL; /* cbrt([0..63]/4)-1 */

	b = fls64(a);

	if (b <= 1)
		return b;

	else if (b < 7) {
		/* a in [0..63] */
		uint32_t bits;
		bits = (uint8_t)a >> 1;
		bits &= ~1;
		return 1 + ((cbrt_x_4m1 >> bits) & 0x03);
	}

	/* We will shift a right by 3n bits, to retrieve bits 3n..3n+5.
	 * We want (b - 1) / 3 for b between 7 and 64 so that we have a
	 * a bit shift count between 2 and 21 inclusive.
	 */
	b = (b * 84) >> 8;

	y = (a >> (b * 3 - 1)) << 1;
	x = 1 + ((cbrt_4msb2lsb >> y) & 3);
	x = (x << b) >> 1;

	/* x += 6; // provides slightly better accuracy (0.246% vs 0.250%) */

	x = (2 * x + (uint32_t)div64_64(a, (uint64_t)x*(uint64_t)(x - 1)));
	x = ((x * 344) >> 10);  /* = x/2.977 ~= x/3 */

	x = (2 * x + (uint32_t)div64_64(a, (uint64_t)x*(uint64_t)(x - 1)));
	x = ((x * 341) >> 10);  /* = x/3.003 ~= x/3 */
	return x;
}
static uint32_t end_ncubic_ndiv3() { }


/* We use this constant to extract the 3 highest bits of <a> and shift them
 * 2 bits left in order to provide a 4bit-aligned shift pointer to an uint32_t.
 */
#define VAL_3BIT_TO_SHIFT4(a,b) (((a) >> ((b) * 3)) << 2)


/* calculate the cubic root of x using Newton-Raphson in 3 divides after first
 * approximation.
 *
 * Avg err ~= 0.170%
 */
static uint32_t ncubic_3div(uint64_t a)
{
	uint32_t x;
	uint32_t b;
	uint32_t shift;

	/*
	 * For large values, 3 bits inputs are enough.
	 *
	 * We store 4*cbrt(8*x)-1 for x in [0..7]
	 *
	 *  x     |   cbrt      | 4*cbrt | int | int |
	 *  range |   range     | approx | val.|  -3 |
	 * -------+-------------+--------+-----+-----+
	 * 56..63 | 3.83 - 3.98 | 15.66  | 16  |  13 |
	 * 48..55 | 3.63 - 3.80 | 14.93  | 15  |  12 |
	 * 40..47 | 3.42 - 3.61 | 14.12  | 14  |  11 |
	 * 32..39 | 3.17 - 3.39 | 13.21  | 13  |  10 |
	 * 24..31 | 2.88 - 3.14 | 12.15  | 12  |   9 |
	 * 16..23 | 2.51 - 2.84 | 10.86  | 11  |   8 |
	 * 08..15 | 2.00 - 2.46 |  9.16  |  9  |   6 |
	 * 00..07 | 1.00 - 1.91 |  6.35  |  6  |   3 |
	 *
	 * We can store (4*cbrt(x)-3) in 4 bits for x in [0..63].
	 * So we use the following map : 0xDCBA9863UL
	 */
	ALIGN64 static uint32_t cbrt_3msb_4lsb = 0xDCBA9863UL;

	b = fls64(a);

	if (b <= 1)
		return b;
	if (b < 7) {
		/* a in [0..63] */
		uint32_t bits;
		bits = (uint8_t)a >> 1;
		bits &= ~1;
		return 1 + ((0xFFEAAA54UL >> bits) & 0x03);
	}

	/* We want (b - 1) / 3 for b between 7 and 64 so that we have a
	 * a bit shift count between 2 and 21 inclusive.
	 */
	b = (b * 84) >> 8;

	/* We want the highest 3bit block from 'a'  */
	x = ((0xDCBA9863UL >> VAL_3BIT_TO_SHIFT4(a, b)) & 0x0F) + 3;
	x = (x << b) >> 3;

	x = (2 * x + (uint32_t)div64_64(a, (uint64_t)x*(uint64_t)x));
	x = ((x * 348) >> 10);  // = x/2.94. Gives best precision here.

	x = (2 * x + (uint32_t)div64_64(a, (uint64_t)x*(uint64_t)x));
	x = ((x * 352) >> 10);  // = x/2.91. Gives best precision here

	x = (2 * x + (uint32_t)div64_64(a, (uint64_t)x*(uint64_t)(x - 1)));
	x = ((x * 341) >> 10);  // = x/3.003 ~= x/3
	return x;
}
static uint32_t end_ncubic_3div() { }



/* calculate the cubic root of x using Newton-Raphson in 2 divides after first
 * approximation.
 *
 * Avg err ~= 0.187%
 */
static uint32_t ncubic_2div(uint64_t a)
{
	uint32_t x;
	uint32_t b;
	uint32_t shift;

	/*
	 * For large values, 3 bits inputs are enough.
	 *
	 * We store 4*cbrt(8*x)-1 for x in [0..7]
	 *
	 *  x     |   cbrt      | 4*cbrt | int | int |
	 *  range |   range     | approx | val.|  -3 |
	 * -------+-------------+--------+-----+-----+
	 * 56..63 | 3.83 - 3.98 | 15.66  | 16  |  13 |
	 * 48..55 | 3.63 - 3.80 | 14.93  | 15  |  12 |
	 * 40..47 | 3.42 - 3.61 | 14.12  | 14  |  11 |
	 * 32..39 | 3.17 - 3.39 | 13.21  | 13  |  10 |
	 * 24..31 | 2.88 - 3.14 | 12.15  | 12  |   9 |
	 * 16..23 | 2.51 - 2.84 | 10.86  | 11  |   8 |
	 * 08..15 | 2.00 - 2.46 |  9.16  |  9  |   6 |
	 * 00..07 | 1.00 - 1.91 |  6.35  |  6  |   3 |
	 *
	 * We can store (4*cbrt(x)-3) in 4 bits for x in [0..63].
	 * So we use the following map : 0xDCBA9863UL
	 */
	ALIGN64 static uint32_t cbrt_3msb_4lsb = 0xDCBA9863UL;

	b = fls64(a);

	if (b <= 1)
		return b;
	else if (b < 7) {
		/* a in [0..63] */
		uint32_t bits;
		bits = (uint8_t)a >> 1;
		bits &= ~1;
		return 1 + ((0xFFEAAA54UL >> bits) & 0x03);
	}

	/* We want (b - 1) / 3 for b between 7 and 64 so that we have a
	 * a bit shift count between 2 and 21 inclusive.
	 */
	b = (b * 84) >> 8;

	/* We want the highest 3bit block from 'a'  */
	shift = (a >> (b * 3)) << 2;      /* shift is 0..28 now. */

	x = ((/*cbrt_3msb_4lsb*/0xDCBA9863UL >> shift) & 0x0F) + 3;
	x = (x << b) >> 3;

	x = (2 * x + (uint32_t)div64_64(a, (uint64_t)x*(uint64_t)x));
	x = ((x * 352) >> 10);  // = x/2.91. Gives best precision here.

	x = (2 * x + (uint32_t)div64_64(a, (uint64_t)x*(uint64_t)(x - 1)));
	x = ((x * 341) >> 10);  // = x/3.003 ~= x/3
	return x;
}
static uint32_t end_ncubic_2div() { }


/* calculate the cubic root of x using Newton-Raphson in a single divide after
 * first approximation.
 *
 * Avg err ~= 0.443%
 */
static uint32_t ncubic_1div(uint64_t a)
{
	uint32_t x;
	uint32_t b;
	uint32_t shift;

	/*
	 * For large values, 3 bits inputs are enough.
	 *
	 * We store 4*cbrt(8*x)-1 for x in [0..7]
	 *
	 *  x     |   cbrt      | 4*cbrt | int | int |
	 *  range |   range     | approx | val.|  -3 |
	 * -------+-------------+--------+-----+-----+
	 * 56..63 | 3.83 - 3.98 | 15.66  | 16  |  13 |
	 * 48..55 | 3.63 - 3.80 | 14.93  | 15  |  12 |
	 * 40..47 | 3.42 - 3.61 | 14.12  | 14  |  11 |
	 * 32..39 | 3.17 - 3.39 | 13.21  | 13  |  10 |
	 * 24..31 | 2.88 - 3.14 | 12.15  | 12  |   9 |
	 * 16..23 | 2.51 - 2.84 | 10.86  | 11  |   8 |
	 * 08..15 | 2.00 - 2.46 |  9.16  |  9  |   6 |
	 * 00..07 | 1.00 - 1.91 |  6.35  |  6  |   3 |
	 *
	 * We can store (4*cbrt(x)-3) in 4 bits for x in [0..63].
	 * So we use the following map : 0xDCBA9863UL
	 */
	ALIGN64 static uint32_t cbrt_3msb_4lsb = 0xDCBA9863UL;

	b = fls64(a);

	if (b < 7) {
		if (b <= 1)
			return b;
		/* a in [0..63] */
		uint32_t bits;
		bits = (uint8_t)a >> 1;
		bits &= ~1;
		return 1 + ((0xFFEAAA54UL >> bits) & 0x03);
	}

	/* We want (b - 1) / 3 for b between 7 and 64 so that we have a
	 * a bit shift count between 2 and 21 inclusive.
	 */
	b = (b * 84) >> 8;

	/* We want the highest 3bit block from 'a'  */
	x = ((/*cbrt_3msb_4lsb*/0xDCBA9863UL >> VAL_3BIT_TO_SHIFT4(a, b)) & 0x0F) + 3;
	x = (x << b) >> 3;

	/* one divide is enough to get a value within 0.4% */
	x = (2 * x + (uint32_t)div64_64(a, (uint64_t)x * (uint64_t)(x - 1)));
	x = ((x * 341) >> 10);
	return x;
}
static uint32_t end_ncubic_1div() { }


/* calculate the cubic root of x using only an approximation.
 * Avg err ~= 4.521%
 */
static uint32_t ncubic_0div(uint64_t a)
{
	uint32_t x;
	uint32_t b;

	/*
	 * For large values, 3 bits inputs are enough.
	 *
	 * We store 4*cbrt(8*x)-1 for x in [0..7]
	 *
	 *  x     |   cbrt      | 4*cbrt | int | int |
	 *  range |   range     | approx | val.|  -3 |
	 * -------+-------------+--------+-----+-----+
	 * 56..63 | 3.83 - 3.98 | 15.66  | 16  |  13 |
	 * 48..55 | 3.63 - 3.80 | 14.93  | 15  |  12 |
	 * 40..47 | 3.42 - 3.61 | 14.12  | 14  |  11 |
	 * 32..39 | 3.17 - 3.39 | 13.21  | 13  |  10 |
	 * 24..31 | 2.88 - 3.14 | 12.15  | 12  |   9 |
	 * 16..23 | 2.51 - 2.84 | 10.86  | 11  |   8 |
	 * 08..15 | 2.00 - 2.46 |  9.16  |  9  |   6 |
	 * 00..07 | 1.00 - 1.91 |  6.35  |  6  |   3 |
	 *
	 * We can store (4*cbrt(x)-3) in 4 bits for x in [0..63].
	 * So we use the following map : 0xDCBA9863UL
	 */
	ALIGN64 static uint32_t cbrt_3msb_4lsb = 0xDCBA9863UL;

	b = fls64(a);

	if (b < 7) {
		if (b <= 1)
			return b;
		/* a in [0..63] */
		uint32_t bits;
		bits = (uint8_t)a >> 1;
		bits &= ~1;
		return 1 + ((0xFFEAAA54UL >> bits) & 0x03);
	}

	/* We want (b - 1) / 3 for b between 7 and 64 so that we have a
	 * a bit shift count between 2 and 21 inclusive.
	 */
	b = (b * 84) >> 8;

	/* We want the highest 3bit block from 'a'  */
	x = ((/*cbrt_3msb_4lsb*/0xDCBA9863UL >> VAL_3BIT_TO_SHIFT4(a, b)) & 0x0F) + 3;
	x = (x << b) >> 3;
	return x;
}
static uint32_t end_ncubic_0div() { }



/* calculate the cubic root of x using table lookups only.
 * Avg err ~= 0.613%
 */
static uint32_t ncubic_tab0(uint64_t a)
{
	uint32_t b;
	uint32_t shift;

	/*
	 * cbrt(x) MSB values for x MSB values in [0..63].
	 * Precomputed then refined by hand - Willy Tarreau
	 *
	 * For x in [0..63],
	 *   v = cbrt(x << 18) - 1
	 *   cbrt(x) = (v[x] + 1) >> 6
	 */
	static uint8_t v[] = {
		/* 0x00 */    0,   63,   63,   63,  127,  127,  127,  127,
		/* 0x08 */  129,  135,  139,  143,  147,  152,  155,  160,
		/* 0x10 */  161,  165,  168,  172,  174,  177,  179,  182,
		/* 0x18 */  184,  188,  190,  193,  195,  197,  199,  202,
		/* 0x20 */  203,  205,  207,  209,  212,  213,  215,  217,
		/* 0x28 */  219,  221,  222,  224,  226,  227,  229,  231,
		/* 0x30 */  232,  234,  236,  237,  239,  240,  241,  243,
		/* 0x38 */  244,  246,  247,  249,  251,  252,  253,  255,
	};

	b = fls64(a);

	if (b < 7)
		/* a in [0..63] */
		return (v[(uint32_t)a] + 31) >> 6;

	b = ((b * 84) >> 8) - 1;
	shift = (a >> (b * 3));
	return ((uint32_t)(v[shift] + 1) << b) >> 6;
}
static uint32_t end_ncubic_tab0() { }


/* calculate the cubic root of x using a table lookup followed by one
 * Newton-Raphson iteration.
 * Avg err ~= 0.195%
 */
static uint32_t ncubic_tab1(uint64_t a)
{
	uint32_t x;
	uint32_t b;
	uint32_t z;
	uint32_t shift;

	/*
	 * cbrt(x) MSB values for x MSB values in [0..63].
	 * Precomputed then refined by hand - Willy Tarreau
	 *
	 * For x in [0..63],
	 *   v = cbrt(x << 18) - 1
	 *   cbrt(x) = (v[x] + 10) >> 6
	 */
	static uint8_t v[] = {
		/* 0x00 */    0,   54,   54,   54,  118,  118,  118,  118,
		/* 0x08 */  123,  129,  134,  138,  143,  147,  151,  156,
		/* 0x10 */  157,  161,  164,  168,  170,  173,  176,  179,
		/* 0x18 */  181,  185,  187,  190,  192,  194,  197,  199,
		/* 0x20 */  200,  202,  204,  206,  209,  211,  213,  215,
		/* 0x28 */  217,  219,  221,  222,  224,  225,  227,  229,
		/* 0x30 */  231,  232,  234,  236,  237,  239,  240,  242,
		/* 0x38 */  244,  245,  246,  248,  250,  251,  252,  254,
	};

	b = fls64(a);
	if (b < 7) {
		/* a in [0..63] */
		return ((uint32_t)v[(uint32_t)a] + 35) >> 6;
	}

	b = ((b * 84) >> 8) - 1;
	shift = (a >> (b * 3));

	x = ((uint32_t)(((uint32_t)v[shift] + 10) << b)) >> 6;

	/* one divide is enough to get a value within 0.19% */
	x = (2 * x + (uint32_t)div64_64(a, (uint64_t)x * (uint64_t)(x - 1)));
	x = ((x * 341) >> 10);
	return x;
}
static uint32_t end_ncubic_tab1() { }



/* 65536 times the cubic root of 0,    1,     2,     3,      4,      5,      6,      7*/
static uint64_t bictcp_table[8] = {0, 65536, 82570, 94519, 104030, 112063, 119087, 125367};

/* calculate the cubic root of x
   the basic idea is that x can be expressed as i*8^j
   so cubic_root(x) = cubic_root(i)*2^j
   in the following code, x is i, and y is 2^j
   because of integer calculation, there are errors in calculation
   so finally use binary search to find out the exact solution.
   Avg err ~= 0.172%
*/

static uint32_t bictcp(uint64_t x)
{
        uint64_t y, app, target, start, end, mid, start_diff, end_diff;

        if (x == 0)
                return 0;

        target = x;

        /*first estimate lower and upper bound*/
        y = 1;
        while (x >= 8){
                x = (x >> 3);
                y = (y << 1);
        }
        start = (y*bictcp_table[x])>>16;
        if (x==7)
                end = (y<<1);
        else
                end = (y*bictcp_table[x+1]+65535)>>16;

        /*binary search for more accurate one*/
        while (start < end-1) {
                mid = (start+end) >> 1;
                app = mid*mid*mid;
                if (app < target)
                        start = mid;
                else if (app > target)
                        end = mid;
                else
                        return mid;
        }

        /*find the most accurate one from start and end*/
        app = start*start*start;
        if (app < target)
                start_diff = target - app;
        else
                start_diff = app - target;
        app = end*end*end;
        if (app < target)
                end_diff = target - app;
        else
                end_diff = app - target;

        return (start_diff < end_diff) ? start : end;
}
static uint32_t end_bictcp() { }


#define NCASES 1000
static uint64_t cases[NCASES];
static double results[NCASES];

static double ticks_per_usec;
static unsigned long long start, end;

static void dotest(const char *name, uint32_t (*func)(uint64_t), int size)
{
	int i;
	unsigned long long t, mx = 0, sum = 0, sum_sq = 0;
	double mean, std, err = 0;

	for (i = 0; i < NCASES; i++) {
		uint64_t x = cases[i];
		uint32_t v;

		rdtscll(start);
		v = (*func)(x);
		rdtscll(end);

		t = end - start;
		if (t > mx) mx = t;
		sum += t; sum_sq += t*t;

		err += fabs(((double) v - results[i]) / results[i]);
	}

	mean = (double) sum / ticks_per_usec / NCASES ;
	std = sqrtl( (double) sum_sq / ticks_per_usec / NCASES - mean * mean);

	printf("%-15s %8llu %8.2f %8.2f %8.2f  %.03f%% %4d\n", name, 
	       (unsigned long long) sum / NCASES, mean, std, 
	       (double) mx / ticks_per_usec, err * 100./ NCASES,
	       size);
}

int main(int argc, char **argv)
{
	uint64_t x;
	int i;

	printf("Calibrating\n");
	rdtscll(start);
	sleep(2);
	rdtscll(end);
	ticks_per_usec = (double) (end - start) / 2000000.;

	for (i = 0; i < 63; i++) 
		cases[i] = 1ull << i;
	x = ~0;
	while (x != 0) {
		cases[i++] = x;
		x >>= 1;
	}
	x = ~0;
	while (x != 0) {
		cases[i++] = x;
		x <<= 1;
	}

	while (i < NCASES)
		cases[i++] = (uint64_t) random()  * (uint64_t) random();

	for (i = 0; i < NCASES; i++) 
		results[i] = cbrt((double)cases[i]);

	printf("Function          clocks mean(us)  max(us)  std(us) Avg err size\n");
	
#define DOTEST(x)	dotest(#x, x, end_##x-x)
	DOTEST(bictcp);
	DOTEST(ocubic);
	DOTEST(ncubic);
	DOTEST(ncubic32);
	DOTEST(ncubic32_1);
	DOTEST(ncubic_ndiv3);

	DOTEST(ncubic_3div);
	DOTEST(ncubic_2div);
	DOTEST(ncubic_1div);
	DOTEST(ncubic_0div);
	DOTEST(ncubic_tab1);
	DOTEST(ncubic_tab0);
	//for (man_adj = 0; man_adj < 16; man_adj++) {
	//	printf("%02d : ", man_adj);
	//	DOTEST(ncubic_tab1);
	//}
	DOTEST(acbrt);
	DOTEST(hcbrt);
	return 0;
}


