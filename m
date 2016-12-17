From: "George Spelvin" <linux@sciencehorizons.net>
Subject: Re: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: 17 Dec 2016 07:42:43 -0500
Message-ID: <20161217124243.16746.qmail@ns.sciencehorizons.net>
References: <CAHmME9rxCYfwyF6EADWqpAEt+yqCPgCLUVH0FPdAy7r-oPnrRg@mail.gmail.com>
Cc: ak@linux.intel.com, davem@davemloft.net, David.Laight@aculab.com,
        djb@cr.yp.to, ebiggers3@gmail.com, hannes@stressinduktion.org,
        jeanphilippe.aumasson@gmail.com,
        kernel-hardening@lists.openwall.com, linux-crypto@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux@sciencehorizons.net,
        luto@amacapital.net, netdev@vger.kernel.org, tom@herbertland.com,
        torvalds@linux-foundation.org, tytso@mit.edu,
        vegard.nossum@gmail.com
To: Jason@zx2c4.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9rxCYfwyF6EADWqpAEt+yqCPgCLUVH0FPdAy7r-oPnrRg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

BTW, here's some SipHash code I wrote for Linux a while ago.

My target application was ext4 directory hashing, resulting in different
implementation choices, although I still think that a rolled-up
implementation like this is reasonable.  Reducing I-cache impact speeds
up the calling code.

One thing I'd like to suggest you steal is the way it handles the
fetch of the final partial word.  It's a lot smaller and faster than
an 8-way case statement.


#include <linux/bitops.h>	/* For rol64 */
#include <linux/cryptohash.h>
#include <asm/byteorder.h>
#include <asm/unaligned.h>

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

	/*
	 * Mix in the 128-bit hash seed.  This is in a format convenient
	 * to the ext3/ext4 code.  Please feel free to adapt the
	 * */
	if (seed) {
		m = seed[2] | (uint64_t)seed[3] << 32;
		b ^= m;
		d ^= m;
		m = seed[0] | (uint64_t)seed[1] << 32;
		/* a ^= m; is done in loop below */
		c ^= m;
	}

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

/*
 * No objection to EXPORT_SYMBOL, but we should probably figure out
 * how the seed[] array should work first.  Homework for the first
 * person to want to call it from a module!
 */
