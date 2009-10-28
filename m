From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] dcache: better name hash function
Date: Tue, 27 Oct 2009 17:10:35 -0700
Message-ID: <20091027171035.39e18383@nehalam>
References: <19864844.24581256620784317.JavaMail.root@tahiti.vyatta.com>
	<4AE68E23.20205@gmail.com>
	<4AE69829.9070207@gmail.com>
	<4AE6A16F.4020002@gmail.com>
	<20091027100736.5303f1ab@nehalam>
	<alpine.LFD.2.01.0910271017170.31845@localhost.localdomain>
	<20091027160822.384dc109@nehalam>
	<alpine.LFD.2.01.0910271636100.31845@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/Kn6XsOHmPAZ2/5dnk/PtF0g"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Al Viro <viro@zeniv.linux.org.uk>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44484 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756891AbZJ1AKg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Oct 2009 20:10:36 -0400
In-Reply-To: <alpine.LFD.2.01.0910271636100.31845@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--MP_/Kn6XsOHmPAZ2/5dnk/PtF0g
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Tue, 27 Oct 2009 16:41:52 -0700 (PDT)
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> 
> 
> On Tue, 27 Oct 2009, Stephen Hemminger wrote:
> > 
> > Going back to basics. Run tests across different input sets.
> > Dropping off the slow ones like crc, md5, ...
> > Not using jhash because it doesn't have good character at a time
> > interface.
> > 
> > Also, the folding algorithm used matters. Since the kernel
> > already uses hash_long() to fold back to N bits, all the
> > tests were rerun with that.
> 
> Yeah, the 'hash_long()' folding matters for anything that doesn't multiply 
> big some big number to spread the bits out, because otherwise the bits 
> from the last character hashed will always be in the low bits.
> 
> That explains why our current hash looked so bad with your previous code.
> 
> From your numbers, I think we can dismiss 'kr_hash()' as having horrible 
> behavior with names like pppXXX (and that isn't just a special case: it's 
> also noticeably worse for your /home directory case, which means that the 
> bad behavior shows up in practice too, not just in some special cases).
> 
> 'elf' and 'pjw' don't have quite the same bad case, but the stddev for the 
> pppXXX cases are still clearly worse than the other alternatives. They 
> also seem to always be slower than what we already have. 
> 
> The 'fnv32' algorithm gets fairly good behavior, but seems bad on Itanium. 
> Looks like it depends on a fast multiplication unit, and all even your 
> "slow" ULV chip seems to be a Core2 one, so all your x86 targets have 
> that. And our current name hash still actually seems to do better in all 
> cases (maybe I missed some case) even if fnv32 is slightly faster on x86.
> 
> From your list 'string10' seems to get consistently good results and is at 
> or near the top of performance too. It seems to be the one that 
> consistently beats 'full_name_hash()' both in performance and in behavior 
> (string_hash17/31 come close, but aren't as clearly better performing).
> 
> But I haven't actually seen the hashes. Maybe there's something that makes 
> string10 bad?
> 
> Regardless, one thing your new numbers do say is that our current hash 
> really isn't that bad.
> 
> 		Linus

Agreed. Here is the reduced version of the program.
To run:
  find /home -printf '%f\n' 2>/dev/null | ./htest -n 100

--MP_/Kn6XsOHmPAZ2/5dnk/PtF0g
Content-Type: text/x-c++src; name=htest.c
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=htest.c

#include <stdio.h>
#include <stdint.h>
#include <malloc.h>
#include <sys/types.h>
#include <sys/time.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <getopt.h>

#define init_name_hash()                0

/* partial hash update function. Assume roughly 4 bits per character */
static inline unsigned long
partial_name_hash(unsigned long c, unsigned long prevhash)
{
        return (prevhash + (c << 4) + (c >> 4)) * 11;
}

/* Compute the hash for a name string. */
static unsigned int
full_name_hash(const unsigned char *name, unsigned int len)
{
        unsigned long hash = 0;
        while (len--)
                hash = partial_name_hash(*name++, hash);
        return hash;
}

static unsigned int
djb2(const unsigned char *str, unsigned int len)
{
	unsigned long hash = 5381;

        while (len--)
		hash = ((hash << 5) + hash) + *str++; /* hash * 33 + c */

        return hash;
}

static unsigned int
string_hash31(const unsigned char *name, unsigned int len)
{
        unsigned hash = 0;
        int i;

        for (i = 0; i < len; ++i)
                hash = 31 * hash + name[i];
        return hash;
}

static unsigned int
string_hash17(const unsigned char *name, unsigned int len)
{
        unsigned hash = 0;
        int i;

        for (i = 0; i < len; ++i)
                hash = 17 * hash + name[i];
        return hash;
}

static unsigned int 
string10(const unsigned char *name, unsigned int len)
{
        unsigned hash = 0;
        int i;

        for (i = 0; i < len; ++i)
		hash = hash * 10 + name[i] - '0';

        return hash;
}

static const uint32_t FNV_32_PRIME = 16777619u;
static const uint32_t FNV1_32_INIT = 2166136261u;

static unsigned int fnv32(const unsigned char *key, unsigned int len)
{
	uint32_t hval = FNV1_32_INIT;
	unsigned int i;

	for (i = 0; i < len; i++) {
		hval ^= key[i];
#if defined(NO_FNV_GCC_OPTIMIZATION)
		hval *= FNV_32_PRIME;
#else
		hval += (hval<<1) + (hval<<4) + (hval<<7)
			+ (hval<<8) + (hval<<24);
#endif
	}

	return hval;
}

static unsigned order = 8;
static unsigned iterations = 10000;
static char **names;
static unsigned num_names;

static void read_names(void)
{
	char line[1024];
	unsigned int n = 0;
	
	/* Read input to create name set */
	while (fgets(line, sizeof line, stdin) != NULL) {
		names = realloc(names, (n + 1) * sizeof(char *));
		names[n] = malloc(strlen(line) + 1);
		strcpy(names[n], line);
		++n;
	}
	num_names = n;
}

/* 2^31 + 2^29 - 2^25 + 2^22 - 2^19 - 2^16 + 1 */
#define GOLDEN_RATIO_PRIME_32 0x9e370001UL
/*  2^63 + 2^61 - 2^57 + 2^54 - 2^51 - 2^18 + 1 */
#define GOLDEN_RATIO_PRIME_64 0x9e37fffffffc0001UL

/* Unrolled version of hash_long() */
static inline unsigned int fold(unsigned int val, unsigned int bits)
{
	if (sizeof(val) == 8) {
		uint64_t hash = val;
		/*  Sigh, gcc can't optimise this alone like it does for 32 bits. */
		uint64_t n = hash;
		n <<= 18;
		hash -= n;
		n <<= 33;
		hash -= n;
		n <<= 3;
		hash += n;
		n <<= 3;
		hash -= n;
		n <<= 4;
		hash += n;
		n <<= 2;
		hash += n;

		/* High bits are more random, so use them. */
		return hash >> (64 - bits);
	} else {
		/* On some cpus multiply is faster, on others gcc will do shifts */
		uint32_t hash = val * GOLDEN_RATIO_PRIME_32;

		/* High bits are more random, so use them. */
		return hash >> (32 - bits);
	}
}

static void measure(const char *name,  
		    unsigned int (*hash)(const unsigned char *, unsigned int))
{
	unsigned int i;
	struct timeval t0, t1;
	unsigned int hashsz = 1 << order;
	unsigned int dist[hashsz];
	unsigned long long probes = 0;
	double t;
	unsigned long m = 0;
	const double avg = num_names / hashsz;
	double ideal = hashsz * (avg * (1 + avg)) / 2;
	double std = 0;

	memset(dist, 0, sizeof(unsigned int) * hashsz);

	gettimeofday(&t0, NULL);
	for (i = 0; i < num_names; i++) {
		unsigned char *name = (unsigned char *) names[i];
		size_t len = strlen(names[i]);
		unsigned int h = 0, j;

		for (j = 0; j < iterations; j++)
			h = hash(name, len);

		/* fold in extra bits */
		++dist[fold(h, order)];
	}
	gettimeofday(&t1, NULL);
	t = (double) (t1.tv_sec - t0.tv_sec);
	t += (double) (t1.tv_usec - t0.tv_usec) / 1000000.;

	for (i = 0; i < hashsz; i++) {
		unsigned int n = dist[i];
		double delta = (n - avg);

		if (n > m) m = n;	/* longest chain */
		
		std += delta * delta;	/* compute standard deviation */
		
		/* number of probes used when accessing 
		   is same as sum of arithmetic series */
		probes += ((uint64_t) n * (1 + n)) / 2;
	}


	printf("%-20s %f", name, t);
	printf(" %8.2f %9lu %6.2f\n",
	       (double) probes / ideal, m, sqrt(std / hashsz));

}
#define MEASURE(func)	measure(#func, &func)

int main(int argc, char **argv)
{
	int f;

	while ((f = getopt(argc, argv, "h:n:")) != -1)
		switch (f) {
		case 'n':
			iterations = strtoul(optarg, NULL, 0);
			break;

		case 'h':
			order = strtoul(optarg, NULL, 0);
			break;

		default:
			fprintf(stderr, 
				"Usage: %s -a -h hash -n testsize\n",
				argv[0]);
			return 1;
		}

	read_names();

	printf("Algorithm             Time       Ratio       Max   StdDev\n");

	MEASURE(full_name_hash);
	MEASURE(djb2);
	MEASURE(string10);
	MEASURE(string_hash17);
	MEASURE(string_hash31);

	MEASURE(fnv32);

        return 0;
}

--MP_/Kn6XsOHmPAZ2/5dnk/PtF0g--
