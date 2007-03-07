From: Willy Tarreau <w@1wt.eu>
Subject: Update to cube root benchmark code
Date: Wed, 7 Mar 2007 07:08:38 +0100
Message-ID: <20070307060838.GI943@1wt.eu>
References: <20070306144529.GA2004@one.firstfloor.org> <84C47260-4B57-4568-8197-58F438A6F737@e18.physik.tu-muenchen.de> <20070306102941.32471d57@freekitty> <20070306.135834.26100913.davem@davemloft.net> <20070306144706.4585c079@freekitty> <20070306145842.7d7fea84@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	rkuhn@e18.physik.tu-muenchen.de, andi@firstfloor.org,
	dada1@cosmosbay.com, jengelh@linux01.gwdg.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:4982 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932215AbXCGGNs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Mar 2007 01:13:48 -0500
Content-Disposition: inline
In-Reply-To: <20070306145842.7d7fea84@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

Thanks for this code, it's easy to experiment with it.
Let me propose this simple update with a variation on your ncubic() function.
I noticed that all intermediate results were far below 32 bits, so I did a
new version which is 30% faster on my athlon with the same results. This is
because we only use x and a/x^2 in the function, with x very close to cbrt(a).
So a/x^2 is very close to cbrt(a) which is at most 22 bits. So we only use
the 32 lower bits of the result of div64_64(), and all intermediate
computations can be done on 32 bits (including multiplies and divides).

willy@pcw:~$ ./bictcp 
Calibrating
Function     clocks  mean(us) max(us)  std(us)  Avg error
bictcp         1085     0.70    28.19     2.30 0.172%
ocubic          869     0.56    22.76     1.23 0.274%
ncubic          637     0.41    16.29     1.41 0.247%
ncubic32        435     0.28    11.18     1.03 0.247%
acbrt           824     0.53    21.03     0.85 0.275%
hcbrt           547     0.35    13.96     0.42 1.580%

I also tried to improve a bit by checking for early convergence and
returning before last divide, but it is worthless because it almost
never happens so it does not make the code any faster.

Here's the code. I think that it would be fine if we merged this
version since it's supposed to behave better on most 32 bits machines.

Best regards,
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

/* calculate the cubic root of x using Newton-Raphson */
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

/* 65536 times the cubic root of 0,    1,     2,     3,      4,      5,      6,      7*/
static uint64_t bictcp_table[8] = {0, 65536, 82570, 94519, 104030, 112063, 119087, 125367};

/* calculate the cubic root of x
   the basic idea is that x can be expressed as i*8^j
   so cubic_root(x) = cubic_root(i)*2^j
   in the following code, x is i, and y is 2^j
   because of integer calculation, there are errors in calculation
   so finally use binary search to find out the exact solution*/
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


#define NCASES 1000
static uint64_t cases[NCASES];
static double results[NCASES];

static double ticks_per_usec;
static unsigned long long start, end;

static void dotest(const char *name, uint32_t (*func)(uint64_t))
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

	printf("%-10s %8llu %8.2f %8.2f %8.2f %.03f%%\n", name, 
	       (unsigned long long) sum / NCASES, mean, std, 
	       (double) mx / ticks_per_usec, err * 100./ NCASES);
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

	printf("Function     clocks  mean(us) max(us)  std(us)  Avg error\n");
	
#define DOTEST(x)	dotest(#x, x)
	DOTEST(bictcp);
	DOTEST(ocubic);
	DOTEST(ncubic);
	DOTEST(ncubic32);
	DOTEST(acbrt);
	DOTEST(hcbrt);
	return 0;
}


