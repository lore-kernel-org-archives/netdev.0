From: "'tgraf@suug.ch'" <tgraf@suug.ch>
Subject: Re: [v1 PATCH 1/14] rhashtable: Remove shift from bucket_table
Date: Wed, 18 Mar 2015 09:51:02 +0000
Message-ID: <20150318095102.GL17829@casper.infradead.org>
References: <063D6719AE5E284EB5DD2968C1650D6D1CB024AB@AcuExch.aculab.com>
 <20150317105657.GE11089@casper.infradead.org>
 <20150317110041.GA11385@gondor.apana.org.au>
 <20150317112203.GG11089@casper.infradead.org>
 <20150317112726.GC11671@gondor.apana.org.au>
 <20150317115749.GJ17829@casper.infradead.org>
 <063D6719AE5E284EB5DD2968C1650D6D1CB02567@AcuExch.aculab.com>
 <20150317122033.GA12612@gondor.apana.org.au>
 <20150317124012.GH11089@casper.infradead.org>
 <20150317215638.GA16776@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:53613 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753123AbbCRJvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 05:51:05 -0400
Content-Disposition: inline
In-Reply-To: <20150317215638.GA16776@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/18/15 at 08:56am, Herbert Xu wrote:
> Actually 75% is just as bad.  To test that just repeat my script
> above and add head -n $((65536 / 4 * 3)) before the first sort.
> 
> My point is that to get below anything like a chain length limit
> of 2 (or even 4), your hash table is going to be mostly empty.
> OK 0.1% might be an exaggeration but it's certainly nowhere near 50%
> as your hash table size grows.
> 
> Please actually try out my test, here is a C program that will help
> you do it:

Thanks for providing that C program. I played around with it and
noticed a small typo which I fixed up. I'm attaching the version
I've used at the end of the mail.

Maybe there is a thinko on my part but the results I'm getting are
very impressive. I have a very hard time to produce more than a
single hash conflict for sequences up to 0..2^27.

I also tried with a pseudo random value for the u32 part of the key
instead of the sequence  number and got the same results.

I'm running it like this:
for i in $(seq 1 27); do \
echo $i: && ./jhash $((2**$i)) | uniq -D | uniq -c \
done

1:
2:
3:
      3 0x1
4:
      2 0xc
5:
6:
      2 0x2b
7:
8:
9:
10:
11:
      2 0x1c9
12:
13:
      2 0x9c7
      2 0x4e9
14:
15:
      2 0x5c8
16:
17:
18:
      2 0x34cb2
      2 0x21fd0
19:
      2 0x61fd0
      2 0x6e82f
20:
      2 0x61fd0
      2 0x6e82f
      2 0xfd571
21:
      2 0x1a0e02
      2 0x1776ea
22:
      2 0x379099
23:
      2 0x2650b6
      2 0x6dc5b5
      2 0x648fe1
      2 0x543446
24:
      2 0x8d60e0
      2 0x8726e5
25:
      2 0x1225f30
26:
      2 0x3a136f4
27:


--- jhash.c ---

#include <stdio.h>

typedef unsigned char u8;
typedef unsigned int u32;

static inline u32 rol32(u32 word, unsigned int shift)
{
	return (word << shift) | (word >> (32 - shift));
}

/* Best hash sizes are of power of two */
#define jhash_size(n)   ((u32)1<<(n))
/* Mask the hash value, i.e (value & jhash_mask(n)) instead of (value % n) */
#define jhash_mask(n)   (jhash_size(n)-1)

/* __jhash_mix -- mix 3 32-bit values reversibly. */
#define __jhash_mix(a, b, c)			\
{						\
	a -= c;  a ^= rol32(c, 4);  c += b;	\
	b -= a;  b ^= rol32(a, 6);  a += c;	\
	c -= b;  c ^= rol32(b, 8);  b += a;	\
	a -= c;  a ^= rol32(c, 16); c += b;	\
	b -= a;  b ^= rol32(a, 19); a += c;	\
	c -= b;  c ^= rol32(b, 4);  b += a;	\
}

/* __jhash_final - final mixing of 3 32-bit values (a,b,c) into c */
#define __jhash_final(a, b, c)			\
{						\
	c ^= b; c -= rol32(b, 14);		\
	a ^= c; a -= rol32(c, 11);		\
	b ^= a; b -= rol32(a, 25);		\
	c ^= b; c -= rol32(b, 16);		\
	a ^= c; a -= rol32(c, 4);		\
	b ^= a; b -= rol32(a, 14);		\
	c ^= b; c -= rol32(b, 24);		\
}

#define __get_unaligned_cpu32(x) (*(u32 *)(x))

/* An arbitrary initial parameter */
#define JHASH_INITVAL		0xdeadbeef

/* jhash - hash an arbitrary key
 * @k: sequence of bytes as key
 * @length: the length of the key
 * @initval: the previous hash, or an arbitray value
 *
 * The generic version, hashes an arbitrary sequence of bytes.
 * No alignment or length assumptions are made about the input key.
 *
 * Returns the hash value of the key. The result depends on endianness.
 */
static inline u32 jhash(const void *key, u32 length, u32 initval)
{
	u32 a, b, c;
	const u8 *k = key;

	/* Set up the internal state */
	a = b = c = JHASH_INITVAL + length + initval;

	/* All but the last block: affect some 32 bits of (a,b,c) */
	while (length > 12) {
		a += __get_unaligned_cpu32(k);
		b += __get_unaligned_cpu32(k + 4);
		c += __get_unaligned_cpu32(k + 8);
		__jhash_mix(a, b, c);
		length -= 12;
		k += 12;
	}
	/* Last block: affect all 32 bits of (c) */
	/* All the case statements fall through */
	switch (length) {
	case 12: c += (u32)k[11]<<24;
	case 11: c += (u32)k[10]<<16;
	case 10: c += (u32)k[9]<<8;
	case 9:  c += k[8];
	case 8:  b += (u32)k[7]<<24;
	case 7:  b += (u32)k[6]<<16;
	case 6:  b += (u32)k[5]<<8;
	case 5:  b += k[4];
	case 4:  a += (u32)k[3]<<24;
	case 3:  a += (u32)k[2]<<16;
	case 2:  a += (u32)k[1]<<8;
	case 1:  a += k[0];
		 __jhash_final(a, b, c);
	case 0: /* Nothing left to add */
		break;
	}

	return c;
}

/* jhash2 - hash an array of u32's
 * @k: the key which must be an array of u32's
 * @length: the number of u32's in the key
 * @initval: the previous hash, or an arbitray value
 *
 * Returns the hash value of the key.
 */
static inline u32 jhash2(const u32 *k, u32 length, u32 initval)
{
	u32 a, b, c;

	/* Set up the internal state */
	a = b = c = JHASH_INITVAL + (length<<2) + initval;

	/* Handle most of the key */
	while (length > 3) {
		a += k[0];
		b += k[1];
		c += k[2];
		__jhash_mix(a, b, c);
		length -= 3;
		k += 3;
	}

	/* Handle the last 3 u32's: all the case statements fall through */
	switch (length) {
	case 3: c += k[2];
	case 2: b += k[1];
	case 1: a += k[0];
		__jhash_final(a, b, c);
	case 0:	/* Nothing left to add */
		break;
	}

	return c;
}


/* jhash_3words - hash exactly 3, 2 or 1 word(s) */
static inline u32 jhash_3words(u32 a, u32 b, u32 c, u32 initval)
{
	a += JHASH_INITVAL;
	b += JHASH_INITVAL;
	c += initval;

	__jhash_final(a, b, c);

	return c;
}

static inline u32 jhash_2words(u32 a, u32 b, u32 initval)
{
	return jhash_3words(a, b, 0, initval);
}

static inline u32 jhash_1word(u32 a, u32 initval)
{
	return jhash_3words(a, 0, 0, initval);
}

int main(int argc, char **argv)
{
	int i;
	struct {
		void *s;
		void *t;
		u32 l;
	} k = { .s = 0 };
	int total;
	u32 initval;

	total = atoi(argv[1]);
	srandom(time(0));
	initval = random();

	for (i = 0; i < total; i++) {
		k.l = i;
		printf("0x%x\n", jhash2((u32 *)&k, sizeof(k)/4, initval) & (total - 1));
	}

	return 0;
}
