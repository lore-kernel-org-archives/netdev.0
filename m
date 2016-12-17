From: "George Spelvin" <linux@sciencehorizons.net>
Subject: Re: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: 17 Dec 2016 10:21:22 -0500
Message-ID: <20161217152122.19677.qmail@ns.sciencehorizons.net>
References: <CALx6S351VFRZmEQphRQy6YtmZYPnOtTN7=XiNrJmhWJGv4HUBg@mail.gmail.com>
Cc: ak@linux.intel.com, davem@davemloft.net, David.Laight@aculab.com,
        djb@cr.yp.to, ebiggers3@gmail.com, hannes@stressinduktion.org,
        Jason@zx2c4.com, jeanphilippe.aumasson@gmail.com,
        kernel-hardening@lists.openwall.com, linux-crypto@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux@sciencehorizons.net,
        luto@amacapital.net, netdev@vger.kernel.org,
        torvalds@linux-foundation.org, tytso@mit.edu,
        vegard.nossum@gmail.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.sciencehorizons.net ([71.41.210.147]:39760 "HELO
        ns.sciencehorizons.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with SMTP id S1756607AbcLQPVY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2016 10:21:24 -0500
In-Reply-To: <CALx6S351VFRZmEQphRQy6YtmZYPnOtTN7=XiNrJmhWJGv4HUBg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To follow up on my comments that your benchmark results were peculiar,
here's my benchmark code.

It just computes the hash of all n*(n+1)/2 possible non-empty substrings
of a buffer of n (called "max" below) bytes.  "cpb" is "cycles per byte".

(The average length is (n+2)/3, c.f. https://oeis.org/A000292)

On x86-32, HSipHash is asymptotically twice the speed of SipHash,
rising to 2.5x for short strings:

SipHash/HSipHash benchmark, sizeof(long) = 4
 SipHash: max=   4 cycles=     10495 cpb=524.7500 (sum=47a4f5554869fa97)
HSipHash: max=   4 cycles=      3400 cpb=170.0000 (sum=146a863e)
 SipHash: max=   8 cycles=     24468 cpb=203.9000 (sum=21c41a86355affcc)
HSipHash: max=   8 cycles=      9237 cpb= 76.9750 (sum=d3b5e0cd)
 SipHash: max=  16 cycles=     94622 cpb=115.9583 (sum=26d816b72721e48f)
HSipHash: max=  16 cycles=     34499 cpb= 42.2782 (sum=16bb7475)
 SipHash: max=  32 cycles=    418767 cpb= 69.9811 (sum=dd5a97694b8a832d)
HSipHash: max=  32 cycles=    156695 cpb= 26.1857 (sum=eed00fcb)
 SipHash: max=  64 cycles=   2119152 cpb= 46.3101 (sum=a2a725aecc09ed00)
HSipHash: max=  64 cycles=   1008678 cpb= 22.0428 (sum=99b9f4f)
 SipHash: max= 128 cycles=  12728659 cpb= 35.5788 (sum=420878cd20272817)
HSipHash: max= 128 cycles=   5452931 cpb= 15.2419 (sum=f1f4ad18)
 SipHash: max= 256 cycles=  38931946 cpb= 13.7615 (sum=e05dfb28b90dfd98)
HSipHash: max= 256 cycles=  13807312 cpb=  4.8805 (sum=ceeafcc1)
 SipHash: max= 512 cycles= 205537380 cpb=  9.1346 (sum=7d129d4de145fbea)
HSipHash: max= 512 cycles= 103420960 cpb=  4.5963 (sum=7f15a313)
 SipHash: max=1024 cycles=1540259472 cpb=  8.5817 (sum=cca7cbdc778ca8af)
HSipHash: max=1024 cycles= 796090824 cpb=  4.4355 (sum=d8f3374f)

On x86-64, SipHash is consistently faster, asymptotically approaching 2x
for long strings:

SipHash/HSipHash benchmark, sizeof(long) = 8
 SipHash: max=   4 cycles=      2642 cpb=132.1000 (sum=47a4f5554869fa97)
HSipHash: max=   4 cycles=      2498 cpb=124.9000 (sum=146a863e)
 SipHash: max=   8 cycles=      5270 cpb= 43.9167 (sum=21c41a86355affcc)
HSipHash: max=   8 cycles=      7140 cpb= 59.5000 (sum=d3b5e0cd)
 SipHash: max=  16 cycles=     19950 cpb= 24.4485 (sum=26d816b72721e48f)
HSipHash: max=  16 cycles=     23546 cpb= 28.8554 (sum=16bb7475)
 SipHash: max=  32 cycles=     80188 cpb= 13.4004 (sum=dd5a97694b8a832d)
HSipHash: max=  32 cycles=    101218 cpb= 16.9148 (sum=eed00fcb)
 SipHash: max=  64 cycles=    373286 cpb=  8.1575 (sum=a2a725aecc09ed00)
HSipHash: max=  64 cycles=    535568 cpb= 11.7038 (sum=99b9f4f)
 SipHash: max= 128 cycles=   2075224 cpb=  5.8006 (sum=420878cd20272817)
HSipHash: max= 128 cycles=   3336820 cpb=  9.3270 (sum=f1f4ad18)
 SipHash: max= 256 cycles=  14276278 cpb=  5.0463 (sum=e05dfb28b90dfd98)
HSipHash: max= 256 cycles=  28847880 cpb= 10.1970 (sum=ceeafcc1)
 SipHash: max= 512 cycles=  50135180 cpb=  2.2281 (sum=7d129d4de145fbea)
HSipHash: max= 512 cycles=  86145916 cpb=  3.8286 (sum=7f15a313)
 SipHash: max=1024 cycles= 334111900 cpb=  1.8615 (sum=cca7cbdc778ca8af)
HSipHash: max=1024 cycles= 640432452 cpb=  3.5682 (sum=d8f3374f)


Here's the code; compile with -DSELFTEST.  (The main purpose of
printing the sum is to prevent dead code elimination.)


#if SELFTEST
#include <stdint.h>
#include <stdlib.h>

static inline uint64_t rol64(uint64_t word, unsigned int shift)
{
	return word << shift | word >> (64 - shift);
}

static inline uint32_t rol32(uint32_t word, unsigned int shift)
{
	return word << shift | word >> (32 - shift);
}

static inline uint64_t get_unaligned_le64(void const *p)
{
	return *(uint64_t const *)p;
}

static inline uint32_t get_unaligned_le32(void const *p)
{
	return *(uint32_t const *)p;
}

static inline uint64_t le64_to_cpup(uint64_t const *p)
{
	return *p;
}

static inline uint32_t le32_to_cpup(uint32_t const *p)
{
	return *p;
}


#else
#include <linux/bitops.h>	/* For rol64 */
#include <linux/cryptohash.h>
#include <asm/byteorder.h>
#include <asm/unaligned.h>
#endif

/* The basic ARX mixing function, taken from Skein */
#define SIP_MIX(a, b, s) ((a) += (b), (b) = rol64(b, s), (b) ^= (a))

/*
 * The complete SipRound.  Note that, when unrolled twice like below,
 * the 32-bit rotates drop out on 32-bit machines.
 */
#define SIP_ROUND(a, b, c, d) \
	(SIP_MIX(a, b, 13), SIP_MIX(c, d, 16), (a) = rol64(a, 32), \
	 SIP_MIX(c, b, 17), SIP_MIX(a, d, 21), (c) = rol64(c, 32))

/*
 * This is rolled up more than most implementations, resulting in about
 * 55% the code size.  Speed is a few precent slower.  A crude benchmark
 * (for (i=1; i <= max; i++) for (j = 0; j < 4096-i; j++) hash(buf+j, i);)
 * produces the following timings (in usec):
 *
 *		i386	i386	i386	x86_64	x86_64	x86_64	x86_64
 * Length	small	unroll  halfmd4 small	unroll	halfmd4 teahash
 * 1..4		   1069	   1029	   1608	    195	    160	    399	    690
 * 1..8		   2483	   2381	   3851	    410	    360	    988	   1659
 * 1..12           4303	   4152	   6207	    690	    618	   1642	   2690
 * 1..16           6122	   5931	   8668	    968	    876	   2363	   3786
 * 1..20           8348	   8137	  11245	   1323	   1185	   3162	   5567
 * 1..24          10580	  10327	  13935	   1657	   1504	   4066	   7635
 * 1..28          13211	  12956	  16803	   2069	   1871	   5028	   9759
 * 1..32          15843	  15572	  19725	   2470	   2260	   6084	  11932
 * 1..36          18864	  18609	  24259	   2934	   2678	   7566	  14794
 * 1..1024      5890194	6130242	10264816 881933	 881244	3617392	7589036
 *
 * The performance penalty is quite minor, decreasing for long strings,
 * and it's significantly faster than half_md4, so I'm going for the
 * I-cache win.
 */
uint64_t
siphash24(char const *in, size_t len, uint32_t const seed[4])
{
	uint64_t a = 0x736f6d6570736575;	/* somepseu */
	uint64_t b = 0x646f72616e646f6d;	/* dorandom */
	uint64_t c = 0x6c7967656e657261;	/* lygenera */
	uint64_t d = 0x7465646279746573;	/* tedbytes */
	uint64_t m = 0;
	uint8_t padbyte = len;

	m = seed[2] | (uint64_t)seed[3] << 32;
	b ^= m;
	d ^= m;
	m = seed[0] | (uint64_t)seed[1] << 32;
	/* a ^= m; is done in loop below */
	c ^= m;

	/*
	 * By using the same SipRound code for all iterations, we
	 * save space, at the expense of some branch prediction.  But
	 * branch prediction is hard because of variable length anyway.
	 */
	len = len/8 + 3;	/* Now number of rounds to perform */
	do {
		a ^= m;

		switch (--len) {
			unsigned bytes;

		default:	/* Full words */
			d ^= m = get_unaligned_le64(in);
			in += 8;
			break;
		case 2:		/* Final partial word */
			/*
			 * We'd like to do one 64-bit fetch rather than
			 * mess around with bytes, but reading past the end
			 * might hit a protection boundary.  Fortunately,
			 * we know that protection boundaries are aligned,
			 * so we can consider only three cases:
			 * - The remainder occupies zero words
			 * - The remainder fits into one word
			 * - The remainder straddles two words
			 */
			bytes = padbyte & 7;

			if (bytes == 0) {
				m = 0;
			} else {
				unsigned offset = (unsigned)(uintptr_t)in & 7;

				if (offset + bytes <= 8) {
					m = le64_to_cpup((uint64_t const *)
								(in - offset));
					m >>= 8*offset;
				} else {
					m = get_unaligned_le64(in);
				}
				m &= ((uint64_t)1 << 8*bytes) - 1;
			}
			/* Could use | or +, but ^ allows associativity */
			d ^= m ^= (uint64_t)padbyte << 56;
			break;
		case 1:		/* Beginning of finalization */
			m = 0;
			c ^= 0xff;
			/*FALLTHROUGH*/
		case 0:		/* Second half of finalization */
			break;
		}

		SIP_ROUND(a, b, c, d);
		SIP_ROUND(a, b, c, d);
	} while (len);

	return a ^ b ^ c ^ d;
}

#undef SIP_ROUND
#undef SIP_MIX


#define HSIP_MIX(a, b, s) ((a) += (b), (b) = rol32(b, s), (b) ^= (a))

/*
 * These are the PRELIMINARY rotate constants suggested by
 * Jean-Philippe Aumasson.  Update to final when available.
 */
#define HSIP_ROUND(a, b, c, d) \
	(HSIP_MIX(a, b,  5), HSIP_MIX(c, d,  8), (a) = rol32(a, 16), \
	 HSIP_MIX(c, b,  7), HSIP_MIX(a, d, 13), (c) = rol32(c, 16))

uint32_t
hsiphash24(char const *in, size_t len, uint32_t const key[2])
{
	uint32_t c = key[0];
	uint32_t d = key[1];
	uint32_t a =     0x6c796765 ^ 0x736f6d65;
	uint32_t b = d ^ 0x74656462 ^ 0x646f7261;
	uint32_t m = c;
	uint8_t padbyte = len;

	/*
	 * By using the same SipRound code for all iterations, we
	 * save space, at the expense of some branch prediction.  But
	 * branch prediction is hard because of variable length anyway.
	 */
	len = len/sizeof(m) + 3;	/* Now number of rounds to perform */
	do {
		a ^= m;

		switch (--len) {
			unsigned bytes;

		default:	/* Full words */
			d ^= m = get_unaligned_le32(in);
			in += sizeof(m);
			break;
		case 2:		/* Final partial word */
			/*
			 * We'd like to do one 32-bit fetch rather than
			 * mess around with bytes, but reading past the end
			 * might hit a protection boundary.  Fortunately,
			 * we know that protection boundaries are aligned,
			 * so we can consider only three cases:
			 * - The remainder occupies zero words
			 * - The remainder fits into one word
			 * - The remainder straddles two words
			 */
			bytes = padbyte & 3;

			if (bytes == 0) {
				m = 0;
			} else {
				unsigned offset = (unsigned)(uintptr_t)in & 3;

				if (offset + bytes <= 4) {
					m = le32_to_cpup((uint32_t const *)
								(in - offset));
					m >>= 8*offset;
				} else {
					m = get_unaligned_le32(in);
				}
				m &= ((uint32_t)1 << 8*bytes) - 1;
			}
			/* Could use | or +, but ^ allows associativity */
			d ^= m ^= (uint32_t)padbyte << 24;
			break;
		case 1:		/* Beginning of finalization */
			m = 0;
			c ^= 0xff;
			/*FALLTHROUGH*/
		case 0:		/* Second half of finalization */
			break;
		}

		HSIP_ROUND(a, b, c, d);
		HSIP_ROUND(a, b, c, d);
	} while (len);

	return a ^ b ^ c ^ d;
	// return c + d;
}

#undef HSIP_ROUND
#undef HSIP_MIX

/*
 * No objection to EXPORT_SYMBOL, but we should probably figure out
 * how the seed[] array should work first.  Homework for the first
 * person to want to call it from a module!
 */

#if SELFTEST

#include <stdio.h>

static uint64_t rdtsc()
{
	uint32_t eax, edx;

	asm volatile ("rdtsc" : "=a" (eax), "=d" (edx));
	return (uint64_t)edx << 32 | eax;
}

int
main(void)
{
	static char const buf[1024] = { 0 };
	unsigned max;
	static const uint32_t key[4] = { 1, 2, 3, 4 };

	printf("SipHash/HSipHash benchmark, sizeof(long) = %u\n",
		(unsigned)sizeof(long));
	for (unsigned max = 4; max <= 1024; max *= 2) {
		uint64_t sum1 = 0;
		uint32_t sum2 = 0;
		uint64_t cycles;
		uint32_t bytes = 0;

		/* A less lazy person could figure out the closed form */
		for (int i = 1; i <= max; i++)
			bytes += i * (max + 1 - i);

		cycles = rdtsc();
		for (int i = 1; i <= max; i++)
			for (int j = 0; j <= max-i; j++)
				sum1 += siphash24(buf+j, i, key);
		cycles = rdtsc() - cycles;

		printf(" SipHash: max=%4u cycles=%10llu cpb=%8.4f (sum=%llx)\n",
			max, cycles, (double)cycles/bytes, sum1);

		cycles = rdtsc();
		for (int i = 1; i <= max; i++)
			for (int j = 0; j <= max-i; j++)
				sum2 += hsiphash24(buf+j, i, key);
		cycles = rdtsc() - cycles;
		printf("HSipHash: max=%4u cycles=%10llu cpb=%8.4f (sum=%lx)\n",
			max, cycles, (double)cycles/bytes, sum2);
	}
	return 0;
}


#endif
