From: "George Spelvin" <linux@sciencehorizons.net>
Subject: Re: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: 16 Dec 2016 18:44:08 -0500
Message-ID: <20161216234408.30174.qmail@ns.sciencehorizons.net>
References: <CAHmME9oEhmqW3320Ch+Rczu_=CxQyUQXCGLnYjDm-CYbWugnSw@mail.gmail.com>
Cc: ak@linux.intel.com, davem@davemloft.net, David.Laight@aculab.com,
        djb@cr.yp.to, ebiggers3@gmail.com, hannes@stressinduktion.org,
        jeanphilippe.aumasson@gmail.com,
        kernel-hardening@lists.openwall.com, linux-crypto@vger.kernel.org,
        linux-kernel@vger.kernel.org, luto@amacapital.net,
        netdev@vger.kernel.org, tom@herbertland.com,
        torvalds@linux-foundation.org, tytso@mit.edu,
        vegard.nossum@gmail.com
To: Jason@zx2c4.com, linux@sciencehorizons.net
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <CAHmME9oEhmqW3320Ch+Rczu_=CxQyUQXCGLnYjDm-CYbWugnSw@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 64-bit security for an RNG is not reasonable even with rekeying. No no
> no. Considering we already have a massive speed-up here with the
> secure version, there's zero reason to start weakening the security
> because we're trigger happy with our benchmarks. No no no.

Just to clarify, I was discussing the idea with Ted (who's in charge of
the whole thing, not me), not trying to make any sort of final decision
on the subject.  I need to look at the various users (46 non-trivial ones
for get_random_int, 15 for get_random_long) and see what their security
requirements actually are.

I'm also trying to see if HalfSipHash can be used in a way that gives
slightly more than 64 bits of effective security.

The problem is that the old MD5-based transform had unclear, but
obviously ample, security.  There were 64 bytes of global secret and
16 chaining bytes per CPU.  Adapting SipHash (even the full version)
takes more thinking.

An actual HalfSipHash-based equivalent to the existing code would be:

#define RANDOM_INT_WORDS (64 / sizeof(long))	/* 16 or 8 */

static u32 random_int_secret[RANDOM_INT_WORDS]
	____cacheline_aligned __read_mostly;
static DEFINE_PER_CPU(unsigned long[4], get_random_int_hash)
		__aligned(sizeof(unsigned long));

unsigned long get_random_long(void)
{
	unsigned long *hash = get_cpu_var(get_random_int_hash);
	unsigned long v0 = hash[0], v1 = hash[1], v2 = hash[2], v3 = hash[3];
	int i;

	/* This could be improved, but it's equivalent */
	v0 += current->pid + jiffies + random_get_entropy();

	for (i = 0; i < RANDOM_INT_WORDS; i++) {
		v3 ^= random_int_secret[i];
		HSIPROUND;
		HSIPROUND;
		v0 ^= random_int_secret[i];
	}
	/* To be equivalent, we *don't* finalize the transform */

	hash[0] = v0; hash[1] = v1; hash[2] = v2; hash[3] = v3;
	put_cpu_var(get_random_int_hash);

	return v0 ^ v1 ^ v2 ^ v3;
}

I don't think there's a 2^64 attack on that.

But 64 bytes of global secret is ridiculous if the hash function
doesn't require that minimum block size.  It'll take some thinking.


Ths advice I'd give now is:
- Implement
unsigned long hsiphash(const void *data, size_t len, const unsigned long key[2])
  .. as SipHash on 64-bit (maybe SipHash-1-3, still being discussed) and
  HalfSipHash on 32-bit.
- Document when it may or may not be used carefully.
- #define get_random_int (unsigned)get_random_long
- Ted, Andy Lutorminski and I will try to figure out a construction of
  get_random_long() that we all like.


('scuse me for a few hours, I have some unrelated things I really *should*
be working on...)
