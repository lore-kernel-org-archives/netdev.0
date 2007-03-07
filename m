From: Sami Farin <7atbggg02@sneakemail.com>
Subject: Re: [RFC] div64_64 support
Date: Wed, 7 Mar 2007 20:32:56 +0200
Message-ID: <20070307183256.pkas62fucy2vugqg@m.safari.iki.fi>
References: <20070223170527.4ca695b2@freekitty> <20070305155714.3abe1b5e@freekitty> <20070306133404.GA864@one.firstfloor.org> <200703061519.20346.dada1@cosmosbay.com> <20070306144529.GA2004@one.firstfloor.org> <84C47260-4B57-4568-8197-58F438A6F737@e18.physik.tu-muenchen.de> <20070306102941.32471d57@freekitty> <20070306215349.hquin7d6pfy2n5d2@m.safari.iki.fi> <20070306222435.cbpv63ltximq6lrf@m.safari.iki.fi> <45EEE445.4080806@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="lxxn4zbbedxzdonw"
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965447AbXCGSdF@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <45EEE445.4080806@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--lxxn4zbbedxzdonw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Mar 07, 2007 at 11:11:49 -0500, Chuck Ebbert wrote:
> Sami Farin wrote:
> > On Tue, Mar 06, 2007 at 23:53:49 +0200, Sami Farin wrote:
> > ...
> >> And I found bug in gcc-4.1.2, it gave 0 for ncubic results
> >> when doing 1000 loops test... gcc-4.0.3 works.
> > 
> > Found it.
> > 
> > --- cbrt-test.c~	2007-03-07 00:20:54.735248105 +0200
> > +++ cbrt-test.c	2007-03-07 00:21:03.964864343 +0200
> > @@ -209,7 +209,7 @@
> >  
> >  	__asm__("bsrl %1,%0\n\t"
> >  		"cmovzl %2,%0"
> > -		: "=&r" (r) : "rm" (x), "rm" (-1));
> > +		: "=&r" (r) : "rm" (x), "rm" (-1) : "memory");
> >  	return r+1;
> >  }
> >  
> > Now Linux 2.6 does not have "memory" in fls, maybe it causes
> > some gcc funnies some people are seeing.
> 
> Can you post the difference in the generated code with that change?

Fun.. looks when not using "memory" gcc does not even bother
calling ncubic() 666 times.  So it gets better timings ( 42/666=0 ) =)

--- cbrt-test-no_memory.s	2007-03-07 20:22:27.838466385 +0200
+++ cbrt-test-using_memory.s	2007-03-07 20:22:38.237013197 +0200
...
 main:
 	leal	4(%esp), %ecx
 	andl	$-16, %esp
 	pushl	-4(%ecx)
 	pushl	%ebp
 	pushl	%edi
 	pushl	%esi
 	pushl	%ebx
 	pushl	%ecx
-	subl	$136, %esp
+	subl	$152, %esp
 	movl	$.LC0, (%esp)
 	call	puts
 	xorl	%edx, %edx
 	movl	$27, %eax
 	call	ncubic
 	cmpl	$3, %eax
-	je	.L83
+	je	.L87
 	movl	$.LC1, (%esp)
 	call	puts
-.L83:
-	xorl	%eax, %eax
-	xorl	%edi, %edi
-	movl	%eax, 88(%esp)
+.L87:
 	xorl	%eax, %eax
-	xorl	%esi, %esi
+	xorl	%ebp, %ebp
 	movl	%eax, 92(%esp)
 	xorl	%eax, %eax
-	xorl	%ebp, %ebp
+	xorl	%edi, %edi
 	movl	%eax, 96(%esp)
 	xorl	%eax, %eax
+	xorl	%esi, %esi
 	movl	%eax, 100(%esp)
 	xorl	%eax, %eax
 	movl	%eax, 104(%esp)
 	xorl	%eax, %eax
 	movl	%eax, 108(%esp)
-	movl	%edi, 112(%esp)
-	movl	%esi, 116(%esp)
-	.p2align 4,,15
-.L84:
+	xorl	%eax, %eax
+	movl	%eax, 112(%esp)
+	movl	%ebp, 116(%esp)
+	movl	%edi, 120(%esp)
+	movl	%esi, 124(%esp)
+.L88:
 #APP
 	movl $0, %eax
 	cpuid
 	rdtsc
 
 #NO_APP
 	movl	%eax, 56(%esp)
 	movl	%edx, 60(%esp)
 #APP
 	movl $0, %eax
 	cpuid
 	rdtsc
 
 #NO_APP
 	movl	%eax, %esi
 	movl	%edx, %edi
 	subl	56(%esp), %esi
 	sbbl	60(%esp), %edi
 	cmpl	$0, %edi
 	ja	.L66
 	cmpl	$999, %esi
-	jbe	.L84
+	jbe	.L88
 .L66:
+	movl	92(%esp), %edx
+	leal	(%edx,%edx,2), %eax
+	movl	cases+4(,%eax,4), %edi
+	movl	cases(,%eax,4), %esi
+	movl	%edi, %edx
+	movl	%esi, %eax
+	call	ncubic
 #APP
 	movl $0, %eax
 	cpuid
 	rdtsc
 
 #NO_APP
-	movl	%eax, %esi
-	movl	%edx, %edi
+	movl	$666, %ebx
+	movl	%eax, 128(%esp)
+	movl	%edx, 132(%esp)
+	.p2align 4,,15
+.L67:
+	movl	%esi, %eax
+	movl	%edi, %edx
+	call	ncubic
+	decl	%ebx
+	movl	%eax, %ebp
+	jne	.L67
 #APP
 	movl $0, %eax
 	cpuid
 	rdtsc
 
 #NO_APP
-	subl	%esi, %eax
+	subl	128(%esp), %eax
 	movl	$666, %ebx
-	sbbl	%edi, %edx
-	xorl	%ecx, %ecx
 	movl	%ebx, 8(%esp)
+	sbbl	132(%esp), %edx
+	xorl	%ecx, %ecx
 	movl	%ecx, 12(%esp)
 	movl	%eax, (%esp)
 	movl	%edx, 4(%esp)
 	call	__udivdi3
-	addl	%eax, 104(%esp)
+	addl	%eax, 112(%esp)
 	movl	%edx, %ecx
 	movl	%eax, %ebx
 	movl	%edx, %esi
-	adcl	%edx, 108(%esp)
+	adcl	%edx, 116(%esp)
 	imull	%eax, %ecx
 	mull	%ebx
 	addl	%ecx, %ecx
 	movl	%eax, 56(%esp)
 	addl	%ecx, %edx
 	movl	56(%esp), %eax
-	addl	%eax, 112(%esp)
+	addl	%eax, 120(%esp)
 	movl	%edx, 60(%esp)
 	movl	60(%esp), %edx
-	adcl	%edx, 116(%esp)
-	cmpl	%esi, 92(%esp)
-	ja	.L67
-	jb	.L68
-	cmpl	%ebx, 88(%esp)
-	jae	.L67
-.L68:
-	movl	%ebx, 88(%esp)
-	movl	%esi, 92(%esp)
-.L67:
-	leal	(%ebp,%ebp,2), %ebx
-	sall	$2, %ebx
-	movl	cases+4(%ebx), %edx
-	movl	cases(%ebx), %eax
-	call	ncubic
-	movl	cases+8(%ebx), %edx
-	subl	%eax, %edx
-	movl	%edx, %eax
-	sarl	$31, %eax
-	xorl	%eax, %edx
-	subl	%eax, %edx
-	movl	%edx, %ecx
-	sarl	$31, %ecx
-	addl	%edx, 96(%esp)
-	adcl	%ecx, 100(%esp)
-	incl	%ebp
-	cmpl	$183, %ebp
-	jbe	.L84
-	movl	108(%esp), %eax
-	fildll	104(%esp)
-	testl	%eax, %eax
-	js	.L85
+	adcl	%edx, 124(%esp)
+	cmpl	%esi, 100(%esp)
+	ja	.L69
+	jb	.L70
+	cmpl	%ebx, 96(%esp)
+	jae	.L69
 .L70:
-	fstpl	120(%esp)
+	movl	%ebx, 96(%esp)
+	movl	%esi, 100(%esp)
+.L69:
+	movl	92(%esp), %edx
+	leal	(%edx,%edx,2), %eax
+	movl	cases+8(,%eax,4), %eax
+	subl	%ebp, %eax
+	movl	%eax, %ecx
+	sarl	$31, %ecx
+	xorl	%ecx, %eax
+	subl	%ecx, %eax
+	cltd
+	addl	%eax, 104(%esp)
+	adcl	%edx, 108(%esp)
+	incl	92(%esp)
+	cmpl	$183, 92(%esp)
+	jbe	.L88
 	movl	116(%esp), %eax
-	fldl	120(%esp)
+	fildll	112(%esp)
+	testl	%eax, %eax
+	js	.L89
+.L72:
+	fstpl	136(%esp)
+	movl	124(%esp), %eax
+	fldl	136(%esp)
 	fdivl	.LC7
 	testl	%eax, %eax
 	flds	.LC4
 	fdivr	%st, %st(1)
-	fildll	112(%esp)
-	js	.L86
-.L71:
-	fstpl	120(%esp)
-	fldl	120(%esp)
+	fildll	120(%esp)
+	js	.L90
+.L73:
+	fstpl	136(%esp)
+	fldl	136(%esp)
 	fdivl	.LC7
 	fdivp	%st, %st(1)
 	fld	%st(1)
 	fmul	%st(2), %st
 	fsubrp	%st, %st(1)
 	fld	%st(0)
 	fsqrt
 	fucomi	%st(0), %st
-	jp	.L88
-	je	.L89
-.L88:
+	jp	.L92
+	je	.L93
+.L92:
 	fstp	%st(0)
 	fstpl	(%esp)
 	fstpl	64(%esp)
 	call	sqrt
 	fldl	64(%esp)
 	fxch	%st(1)
-.L72:
-	movl	96(%esp), %eax
-	movl	100(%esp), %edx
-	fildll	88(%esp)
+.L74:
+	movl	104(%esp), %eax
+	movl	108(%esp), %edx
+	fildll	96(%esp)
 	movl	%eax, 40(%esp)
-	movl	92(%esp), %eax
+	movl	100(%esp), %eax
 	movl	%edx, 44(%esp)
 	testl	%eax, %eax
-	js	.L87
-.L73:
-	fstpl	120(%esp)
-	movl	104(%esp), %eax
+	js	.L91
+.L75:
+	fstpl	136(%esp)
+	movl	112(%esp), %eax
 	movl	$184, %ebp
-	fldl	120(%esp)
+	fldl	136(%esp)
 	xorl	%edi, %edi
 	movl	$.LC5, %esi
 	fdivl	.LC7
-	movl	108(%esp), %edx
+	movl	116(%esp), %edx
 	movl	%ebp, 8(%esp)
 	movl	%edi, 12(%esp)
 	movl	%eax, (%esp)
 	movl	%edx, 4(%esp)
 	fstpl	32(%esp)
 	fstpl	24(%esp)
 	fstpl	16(%esp)
 	call	__udivdi3
 	movl	%esi, 4(%esp)
 	movl	$.LC6, (%esp)
 	movl	%eax, 8(%esp)
 	movl	%edx, 12(%esp)
 	call	printf
-	addl	$136, %esp
+	addl	$152, %esp
 	xorl	%eax, %eax
 	popl	%ecx
 	popl	%ebx
 	popl	%esi
 	popl	%edi
 	popl	%ebp
 	leal	-4(%ecx), %esp
 	ret
-.L89:
+.L93:
 	fstp	%st(1)
+	jmp	.L74
+.L89:
+	fadds	.LC2
 	jmp	.L72
-.L85:
+.L91:
 	fadds	.LC2
-	jmp	.L70
-.L87:
+	jmp	.L75
+.L90:
 	fadds	.LC2
 	jmp	.L73
-.L86:
-	fadds	.LC2
-	jmp	.L71
 	.size	main, .-main
 	.section	.rodata
 	.align 32
 	.type	cases, @object
 	.size	cases, 2208
 cases:
...


-- 

--lxxn4zbbedxzdonw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="cbrt-test.c"

/*

Don't count the existing Newton-Raphson out. It turns out that to get enough
precision for 32 bits, only 4 iterations are needed. By unrolling those, it
gets much better timing.

Slightly gross test program (with original cubic wraparound bug fixed).

---

*/

/* Test and measure perf of cube root algorithms.  */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>

#define MEMCLOBBER 1

/**
 * ffs - find first bit set
 * @x: the word to search
 *
 * This is defined the same way as
 * the libc and compiler builtin ffs routines, therefore
 * differs in spirit from the above ffz (man ffs).
 */
static inline int ffs(int x)
{
	int r;

	__asm__("bsfl %1,%0\n\t"
		"cmovzl %2,%0" 
#if MEMCLOBBER
		: "=&r" (r) : "rm" (x), "r" (-1) : "memory");
#else
		: "=&r" (r) : "rm" (x), "r" (-1));
#endif
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
#if MEMCLOBBER
		: "=&r" (r) : "rm" (x), "r" (-1) : "memory" );
#else
		: "=&r" (r) : "rm" (x), "r" (-1));
#endif
	return r+1;
}

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
static inline unsigned long __ffs(unsigned long word)
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

#define rdtscll_start(val) \
     __asm__ __volatile__("movl $0, %%eax\n\tcpuid\n\trdtsc\n" : "=A" (val) : : "ebx", "ecx")

#define rdtscll(val) \
     __asm__ __volatile__("rdtsc" : "=A" (val))

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
		uint64_t x2;

		x2 = x;
		x2 *= x;
		x1 = x;

		x = (2 * x + div64_64(a, x2)) / 3;
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

static const struct cbrt {
	uint64_t	in;
	uint32_t	result;
} cases[] = {
	{1, 1}, {2, 1}, {3, 1}, {4, 1}, {5, 1}, {6, 1}, {7, 1}, 
	{8, 2}, {9, 2}, {10, 2}, {11, 2}, {12, 2}, {13, 2}, {14, 2},
	{15, 2}, {16, 2}, {17, 2}, {18, 2}, {19, 2}, {20, 2}, {21, 2}, {22, 2},
	{23, 2}, {24, 2}, {25, 2}, {26, 2}, {27, 3}, {28, 3}, {29, 3}, {30, 3},
	{31, 3}, {32, 3}, {33, 3}, {34, 3}, {35, 3}, {36, 3}, {37, 3}, {38, 3},
	{39, 3}, {40, 3}, {99, 4}, {100, 4}, {101, 4}, 
	{ 125ull, 5 }, { 216ull, 6 },  { 343ull, 7 }, { 512ull, 8 }, 
	{ 1000ull, 10 },  { 1331ull, 11 },
	{ 8000ull, 20 },  { 9261ull, 21 },
	{32767, 31},	 {32768, 32}, {32769, 32}, 
	{ 64000ull, 40 },  { 68921ull, 41 },
	{ 512000ull, 80 },  { 531441ull, 81 },
	{ 1000000ull, 100 },  { 1030301ull, 101 },
	{ 4096000ull, 160 },  { 4173281ull, 161 },
	{ 16387064ull, 254 },  { 16581375ull, 255 },
	{ 16777216ull, 256 },  { 16974593ull, 257 },
	{ 131096512ull, 508 },  { 131872229ull, 509 },
	{ 132651000ull, 510 },  { 133432831ull, 511 },
	{ 134217728ull, 512 },  { 135005697ull, 513 },
	{ 1000000000ull, 1000 },  { 1003003001ull, 1001 },
	{ 1006012008ull, 1002 },  { 1009027027ull, 1003 },
	{ 1061208000ull, 1020 },  { 1064332261ull, 1021 },
	{ 1067462648ull, 1022 },  { 1070599167ull, 1023 },
	
	{1073741823, 1023}, {1073741824, 1024}, {1073741825, 1024},
	{~0, 2642245},
/* 100 random values */
 { 7749363893351949254ull, 1978891},  { 7222815480849057907ull, 1933016},
 { 8408462745175416063ull, 2033475},  { 3091884191388096748ull, 1456826},
 { 2562019500164152525ull, 1368340},  { 4403210617922443179ull, 1639041},
 { 3364542905362882299ull, 1498449},  { 8782769017716072774ull, 2063211},
 { 5863405773976003266ull, 1803225},  { 1306053050111174648ull, 1093084},
 { 150346236956174824ull, 531737},  { 1265737889039205261ull, 1081719},
 { 1445109530774087002ull, 1130577},  { 1197105577171186275ull, 1061803},
 { 9213452462461015967ull, 2096399},  { 4730966302945445786ull, 1678739},
 { 5650605098630667570ull, 1781141},  { 5880381756353009591ull, 1804963},
 { 4552499520046621784ull, 1657359},  { 2697991130065918298ull, 1392131},
 { 4858364911220984157ull, 1693674},  { 3691457481531040535ull, 1545489},
 { 2613117305472506601ull, 1377377},  { 7449943749836318932ull, 1953069},
 { 643378865959570610ull, 863287},  { 4851450802679832774ull, 1692871},
 { 1772859812839988916ull, 1210295},  { 8210946489571640849ull, 2017426},
 { 591875965497384322ull, 839608},  { 4221553402965100097ull, 1616183},
 { 2197744667347238205ull, 1300146},  { 8321400714356781191ull, 2026432},
 { 2459557415995497961ull, 1349850},  { 3460673533926954145ull, 1512586},
 { 4727304344741345505ull, 1678306},  { 4903203917250634599ull, 1698869},
 { 4036494370831490817ull, 1592214},  { 8585205035691420311ull, 2047624},
 { 2622143824319236828ull, 1378961},  { 5902762718897731478ull, 1807250},
 { 6344401509618197560ull, 1851243},  { 4059247793194552874ull, 1595200},
 { 7648030174294342832ull, 1970228},  { 2111858627070002939ull, 1282985},
 { 3231502273651985583ull, 1478432},  { 8821862535190318932ull, 2066268},
 { 6062559696943389464ull, 1823414},  { 4054224670122353756ull, 1594541},
 { 3674929609692563482ull, 1543179},  { 6310802012126231363ull, 1847969},
 { 4450190829039920890ull, 1644849},  { 8764531173541462842ull, 2061782},
 { 1361923252301505833ull, 1108453},  { 5912924843615600614ull, 1808287},
 { 5714768882048811324ull, 1787857},  { 7249589769047033748ull, 1935401},
 { 4123157012528828376ull, 1603528},  { 1729687638268160097ull, 1200390},
 { 5132287771298228729ull, 1724925},  { 1564349257200314043ull, 1160854},
 { 951586254223522969ull, 983594},  { 4569664949094662293ull, 1659439},
 { 9082730968228181483ull, 2086437},  { 6312891027251024051ull, 1848173},
 { 6915415788559031791ull, 1905194},  { 2713150456497618688ull, 1394733},
 { 5390954890749602465ull, 1753430},  { 1405547745908296421ull, 1120164},
 { 1157301728707637259ull, 1049902},  { 1513573187112042448ull, 1148156},
 { 687416080475161159ull, 882551},  { 484496930861389501ull, 785411},
 { 1625256440396143907ull, 1175729},  { 7358388240824901288ull, 1945035},
 { 6055730836615196283ull, 1822729},  { 5897962221937294789ull, 1806760},
 { 862205218853780339ull, 951780},  { 4798091009445823173ull, 1686641},
 { 644772714391937867ull, 863910},  { 4255852691293155171ull, 1620549},
 { 5287931004512034672ull, 1742188},  { 479051048987854372ull, 782457},
 { 9223312736680112286ull, 2097147},  { 8208392001457969628ull, 2017217},
 { 9203071384420047828ull, 2095612},  { 8029313043584389618ull, 2002439},
 { 38384068872053008ull, 337326},  { 5477688516749455419ull, 1762784},
 { 1504622508868036557ull, 1145888},  { 8421184723110053200ull, 2034500},
 { 3312070181890020423ull, 1490618},  { 5344298403762143580ull, 1748357},
 { 6340030040222269807ull, 1850818},  { 4895839553118470425ull, 1698018},
 { 2806627376195262363ull, 1410570},  { 5321619225005368821ull, 1745880},
 { 6897323351052656353ull, 1903532},  { 326700202259382556ull, 688731},
 { 7685269066741890339ull, 1973420},  { 8054506481558450217ull, 2004531},
};
#define NCASES (sizeof(cases)/sizeof(cases[0]))


static double ticks_per_usec = 2979.0;

static void show(const char *func, uint64_t sum, uint64_t sq, 
		 unsigned long long mx, unsigned long long err)
{
	double mean, std;

	mean = (double) sum / ticks_per_usec / NCASES ;
	std = sqrtl( (double) sq / ticks_per_usec / NCASES - mean * mean);

	printf("%-10s %8llu %8.3f %8.3f %8.3f %11llu\n", func, 
	       (unsigned long long) sum / NCASES, mean, std, 
	       (double) mx / ticks_per_usec, err);
}


int main(int argc, char **argv)
{
	int i;
	uint32_t c;
	unsigned long long start, end, t, mx;
	unsigned long long err, sum, sum_sq, cerr;
	int loops;

#if 0
	rdtscll(start);
	sleep(2);
	rdtscll(end);
	ticks_per_usec = (double) (end - start) / 2000000.;
#endif

	printf("Function     clocks mean(us)  max(us)  std(us) total error\n");

#define DOTEST(func) \
	if (func(27) != 3) printf("ouch\n"); \
	sum = sum_sq = mx = 0; \
	for (err = 0, i = 0; i < NCASES; i++) { \
		do { \
			rdtscll_start(start); \
			rdtscll_start(end); \
		} while ((end - start) < 1000); \
		c = func(cases[i].in); \
		loops = 667; \
		rdtscll_start(start);		\
		while (--loops > 0) c = func(cases[i].in); \
		rdtscll_start(end); \
		t = (end - start) / 666; sum += t; sum_sq += t*t; \
		if (t > mx) mx = t; \
		cerr = abs((long) cases[i].result - c); \
		err += cerr; \
	} \
	show(#func, sum, sum_sq, mx, err);

	//DOTEST(ocubic);
	DOTEST(ncubic);
	//DOTEST(acbrt);
	//DOTEST(hcbrt);
	return 0;
}


--lxxn4zbbedxzdonw--
