From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH next-next-2.6] netdev: better dev_name_hash
Date: Sun, 25 Oct 2009 23:30:16 -0700
Message-ID: <20091025233016.6860d9c7@nehalam>
References: <200910252158.53921.opurdila@ixiacom.com>
	<4AE4C1FA.7000002@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/hg0Dt9_Qt0xlGk=qq5xcQ6j"
Cc: Octavian Purdila <opurdila@ixiacom.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47384 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754417AbZJZGaU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Oct 2009 02:30:20 -0400
In-Reply-To: <4AE4C1FA.7000002@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--MP_/hg0Dt9_Qt0xlGk=qq5xcQ6j
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

I overkilled this with more functions and compared filenames as well.


genarated names (dummyNNNN)
Algorithm             Time (us)     Ratio       Max   StdDev
kr_hash                  277925   152408.6   468448 543.19
string_hash31            329356     5859.4    16042  44.18
SuperFastHash            324570     4885.9    10502   2.29
djb2                     327908     5608.5    15210  38.08
string_hash17            326769     4883.6     9896   0.76
full_name_hash           343196    63921.0   140628 343.62
jhash_string             463801     4883.8    10085   1.02
sdbm                     398587     9801.7    29634  99.18

filesystem names
Algorithm             Time (us)     Ratio       Max   StdDev
kr_hash                  278840   152314.9   468717 543.01
string_hash31            331206     5802.1    16004  42.87
SuperFastHash            325938     4887.5    13528   2.88
djb2                     330621     5607.1    15333  38.05
string_hash17            331181     4884.9    13274   1.78
full_name_hash           347312    63972.2   141336 343.77
jhash_string             466799     4885.2    13275   1.92
sdbm                     403691     9771.7    29629  98.88

Ratio is the average number of buckets examined when scanning
the whole set of names.


1) Increased hash buckets to 1024 which seems reasonable if we are
   going to test that many names.
2) Increased name size to 256 so that longer filenames could be
   checked and name blocks were not in same cache line

* SuperFastHash is too big to put inline


--MP_/hg0Dt9_Qt0xlGk=qq5xcQ6j
Content-Type: text/x-c++src; name=hashtest.c
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=hashtest.c

#include <stdio.h>
#include <stdint.h>
#include <malloc.h>
#include <sys/types.h>
#include <sys/time.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

static unsigned int
kr_hash(const unsigned char *str, unsigned int len)
{
	unsigned int hash = 0;

        while (len--)
	    hash += *str++;

	return hash;
}

static unsigned int
sdbm(const unsigned char *name, unsigned int len)
{
        unsigned long hash = 0;

        while (len--)
            hash = *name++ + (hash << 6) + (hash << 16) - hash;

        return hash;
}

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

/* will need to change to unaligned_access() */
static inline uint16_t get16bits(const unsigned char *data)
{
	return *(uint16_t *) data;
}

static inline unsigned int
SuperFastHash (const unsigned char * data, unsigned int len)
{
	uint32_t hash = len, tmp;
	int rem;

	rem = len & 3;
	len >>= 2;

	/* Main loop */
	for (;len > 0; len--) {
		hash  += get16bits (data);
		tmp    = (get16bits (data+2) << 11) ^ hash;
		hash   = (hash << 16) ^ tmp;
		data  += 2*sizeof (uint16_t);
		hash  += hash >> 11;
	}

	/* Handle end cases */
	switch (rem) {
        case 3: hash += get16bits (data);
                hash ^= hash << 16;
                hash ^= data[sizeof (uint16_t)] << 18;
                hash += hash >> 11;
                break;
        case 2: hash += get16bits (data);
                hash ^= hash << 11;
                hash += hash >> 17;
                break;
        case 1: hash += *data;
                hash ^= hash << 10;
                hash += hash >> 1;
	}

	/* Force "avalanching" of final 127 bits */
	hash ^= hash << 3;
	hash += hash >> 5;
	hash ^= hash << 4;
	hash += hash >> 17;
	hash ^= hash << 25;
	hash += hash >> 6;

	return hash;
}


/* NOTE: Arguments are modified. */
#define __jhash_mix(a, b, c) \
{ \
  a -= b; a -= c; a ^= (c>>13); \
  b -= c; b -= a; b ^= (a<<8); \
  c -= a; c -= b; c ^= (b>>13); \
  a -= b; a -= c; a ^= (c>>12);  \
  b -= c; b -= a; b ^= (a<<16); \
  c -= a; c -= b; c ^= (b>>5); \
  a -= b; a -= c; a ^= (c>>3);  \
  b -= c; b -= a; b ^= (a<<10); \
  c -= a; c -= b; c ^= (b>>15); \
}

/* The golden ration: an arbitrary value */
#define JHASH_GOLDEN_RATIO	0x9e3779b9

/* The most generic version, hashes an arbitrary sequence
 * of bytes.  No alignment or length assumptions are made about
 * the input key.
 */
static inline uint32_t jhash(const void *key, uint32_t length, uint32_t initval)
{
	uint32_t a, b, c, len;
	const uint8_t *k = key;

	len = length;
	a = b = JHASH_GOLDEN_RATIO;
	c = initval;

	while (len >= 12) {
		a += (k[0] +((uint32_t)k[1]<<8) +((uint32_t)k[2]<<16) +((uint32_t)k[3]<<24));
		b += (k[4] +((uint32_t)k[5]<<8) +((uint32_t)k[6]<<16) +((uint32_t)k[7]<<24));
		c += (k[8] +((uint32_t)k[9]<<8) +((uint32_t)k[10]<<16)+((uint32_t)k[11]<<24));

		__jhash_mix(a,b,c);

		k += 12;
		len -= 12;
	}

	c += length;
	switch (len) {
	case 11: c += ((uint32_t)k[10]<<24);
	case 10: c += ((uint32_t)k[9]<<16);
	case 9 : c += ((uint32_t)k[8]<<8);
	case 8 : b += ((uint32_t)k[7]<<24);
	case 7 : b += ((uint32_t)k[6]<<16);
	case 6 : b += ((uint32_t)k[5]<<8);
	case 5 : b += k[4];
	case 4 : a += ((uint32_t)k[3]<<24);
	case 3 : a += ((uint32_t)k[2]<<16);
	case 2 : a += ((uint32_t)k[1]<<8);
	case 1 : a += k[0];
	};

	__jhash_mix(a,b,c);

	return c;
}

static unsigned int
jhash_string(const unsigned char *name, unsigned int len)
{
	return jhash(name, len, 0);
}

#define TESTSIZE	10000000ul
#define HASHBITS	10
#define HASHSZ		(1<<HASHBITS)
#define HASHMSK		(HASHSZ-1)
#define IFNAMSIZ	256

static char *names[TESTSIZE];

static void generate_names(void)
{
	unsigned int i;
	char *buf = malloc(TESTSIZE * IFNAMSIZ);

	printf("\ngenarated names (dummyNNNN)\n");
	for (i = 0; i < TESTSIZE; i++) {
		snprintf(buf, IFNAMSIZ, "dummy%d", i);
		names[i] = buf;
		buf += IFNAMSIZ;
	}
}

static inline void measure(const char *name,  
			   unsigned int (*hash)(const unsigned char *, unsigned int))
{
	unsigned int i;
	struct timeval t0, t1;
	unsigned int dist[HASHSZ] = { 0 };
	unsigned long long ratio = 0;
	long us;
	unsigned long m = 0;
	const double avg = TESTSIZE / HASHSZ;
	double std = 0;

	gettimeofday(&t0, NULL);
	
	for (i = 0; i < TESTSIZE; i++) {
		const unsigned char *str = (const unsigned char *) names[i];
		unsigned int h = hash(str, strlen(names[i]));
		++dist[h & HASHMSK];
	}

	gettimeofday(&t1, NULL);
	us = (t1.tv_sec - t0.tv_sec) * 1000000;
	us += (t1.tv_usec - t0.tv_usec);

	for (i = 0; i < HASHSZ; i++) {
		unsigned int n = dist[i];
		unsigned long long s;
		double delta = (n - avg);

		s = n;
		s *= (1 + n);
		ratio += s / 2;
		if (n > m) m = n;
		
		std += delta * delta;
	}

	printf("%-20s %10ld %10.1f %8ld %6.2f\n", name, us, 
	       (double) ratio / (double)TESTSIZE, m, sqrt(std / TESTSIZE));

}
#define MEASURE(func)	measure(#func, &func)


static void filesystem_names(void)
{
	FILE *f = fopen("/tmp/names", "r");
	if (!f) { perror("/tmp/names"); exit(1); }
	unsigned int i = 0;
	char line[IFNAMSIZ];

	printf("\nfilesystem names\n");
	while (fgets(line, sizeof line, f) != NULL) {
		strncpy(names[i], line, IFNAMSIZ);
		if (++i == TESTSIZE)
			break;
	}
	fclose(f);

}


int main()
{

	generate_names();

	printf("Algorithm             Time (us)     Ratio       Max   StdDev\n");
	MEASURE(kr_hash);
	MEASURE(string_hash31);
	MEASURE(SuperFastHash);
	MEASURE(djb2);
	MEASURE(string_hash17);
	MEASURE(full_name_hash);
	MEASURE(jhash_string);
	MEASURE(sdbm);

	filesystem_names();

	printf("Algorithm             Time (us)     Ratio       Max   StdDev\n");
	MEASURE(kr_hash);
	MEASURE(string_hash31);
	MEASURE(SuperFastHash);
	MEASURE(djb2);
	MEASURE(string_hash17);
	MEASURE(full_name_hash);
	MEASURE(jhash_string);
	MEASURE(sdbm);

        return 0;
}

--MP_/hg0Dt9_Qt0xlGk=qq5xcQ6j--
