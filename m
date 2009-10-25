From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH next-next-2.6] netdev: better dev_name_hash
Date: Sun, 25 Oct 2009 23:55:32 +0200
Message-ID: <200910252355.32640.opurdila@ixiacom.com>
References: <200910252158.53921.opurdila@ixiacom.com> <4AE4C1FA.7000002@gmail.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_UlM5KrQU7WCbcUD"
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:26036 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752390AbZJYV60 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2009 17:58:26 -0400
In-Reply-To: <4AE4C1FA.7000002@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_UlM5KrQU7WCbcUD
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Sunday 25 October 2009 23:24:10 you wrote:
> Octavian Purdila a =E9crit :
> > The current dev_name_hash is not very good at spreading entries when a
> > large number of interfaces of the same type (e.g. ethXXXXX) are used.
>=20
> Very true
>=20
> > Here are some performance numbers for creating 16000 dummy interfaces
> > with and without the patch (with per device sysctl entries disabled)
> >
> >     With patch                      Without patch
> >
> >     real    0m 2.27s                real    0m 4.32s
> >     user    0m 0.00s                user    0m 0.00s
> >     sys     0m 1.13s                sys     0m 2.16s
>=20
> 1) A program to show hash distribution would be more convincing,
> and could show that 17 multiplier is better, not 31 :)
>=20

You beat me to it :)=20

But anyways, I've attached mine as well , which compares orig, jhash, new17=
,=20
new31, with different number of interfaces as well as different hash bits.=
=20

The score it shows its the number of iterations needed to find all elements=
 in=20
the hash (good enough metric?)

My results shows that new17 is better or very close to jhash2. And I think =
its=20
lighter then jhash too.

> 2) Why full_name_hash() not changed as well ?

I don't think it is going to be as easy to "benchmark" this, as it is used=
=20
with more diverse inputs.=20

AFAIK, full_name_hash is used by the dentry code, meaning that it cashes pa=
th=20
names? If so, perhaps we can use find {/etc,/bin,/sbin,/usr} as input patte=
rns?=20

My results:

$ ./dev_name_hash ixint 255 0 8
score 1140
$ ./dev_name_hash ixint 255 1 8
score 379
$ ./dev_name_hash ixint 255 2 8
score 461
$ ./dev_name_hash ixint 255 3 8
score 329
$ ./dev_name_hash ixint 1000 0 8
score 26074
$ ./dev_name_hash ixint 1000 1 8
score 2887
$ ./dev_name_hash ixint 1000 2 8
score 2853
$ ./dev_name_hash ixint 1000 3 8
score 3713
$ ./dev_name_hash ixint 16000 0 8
score 3689828
$ ./dev_name_hash ixint 16000 1 8
score 516389
$ ./dev_name_hash ixint 16000 2 8
score 515292
$ ./dev_name_hash ixint 16000 3 8
score 554042
$ ./dev_name_hash ixint 16000 0 16
score 24741
$ ./dev_name_hash ixint 16000 1 16
score 17949
$ ./dev_name_hash ixint 16000 2 16
score 16715
$ ./dev_name_hash ixint 16000 3 16
score 18125

--Boundary-00=_UlM5KrQU7WCbcUD
Content-Type: text/x-csrc;
  charset="UTF-8";
  name="dev_name_hash.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="dev_name_hash.c"

#define _GNU_SOURCE
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <net/if.h>

typedef unsigned int u32;
typedef unsigned char u8;

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
static inline u32 jhash(const void *key, u32 length, u32 initval)
{
	u32 a, b, c, len;
	const u8 *k = key;

	len = length;
	a = b = JHASH_GOLDEN_RATIO;
	c = initval;

	while (len >= 12) {
		a += (k[0] +((u32)k[1]<<8) +((u32)k[2]<<16) +((u32)k[3]<<24));
		b += (k[4] +((u32)k[5]<<8) +((u32)k[6]<<16) +((u32)k[7]<<24));
		c += (k[8] +((u32)k[9]<<8) +((u32)k[10]<<16)+((u32)k[11]<<24));

		__jhash_mix(a,b,c);

		k += 12;
		len -= 12;
	}

	c += length;
	switch (len) {
	case 11: c += ((u32)k[10]<<24);
	case 10: c += ((u32)k[9]<<16);
	case 9 : c += ((u32)k[8]<<8);
	case 8 : b += ((u32)k[7]<<24);
	case 7 : b += ((u32)k[6]<<16);
	case 6 : b += ((u32)k[5]<<8);
	case 5 : b += k[4];
	case 4 : a += ((u32)k[3]<<24);
	case 3 : a += ((u32)k[2]<<16);
	case 2 : a += ((u32)k[1]<<8);
	case 1 : a += k[0];
	};

	__jhash_mix(a,b,c);

	return c;
}


/* Name hashing routines. Initial hash value */
/* Hash courtesy of the R5 hash in reiserfs modulo sign bits */
#define init_name_hash()		0

/* partial hash update function. Assume roughly 4 bits per character */
static inline unsigned long
partial_name_hash(unsigned long c, unsigned long prevhash)
{
	return (prevhash + (c << 4) + (c >> 4)) * 11;
}

/*
 * Finally: cut down the number of bits to a int value (and try to avoid
 * losing bits)
 */
static inline unsigned long end_name_hash(unsigned long hash)
{
	return (unsigned int) hash;
}

/* Compute the hash for a name string. */
static inline unsigned int
full_name_hash(const char *name, unsigned int len)
{
	unsigned long hash = init_name_hash();
	while (len--)
		hash = partial_name_hash(*name++, hash);
	return end_name_hash(hash);
}

unsigned int dev_name_hash_new17(const char *name)
{
	unsigned hash = 0;
	int len = strnlen(name, IFNAMSIZ);
	int i;

	for (i = 0; i < len; ++i)
		hash = 17 * hash + name[i];
	return hash;
}

unsigned int dev_name_hash_new31(const char *name)
{
	unsigned hash = 0;
	int len = strnlen(name, IFNAMSIZ);
	int i;

	for (i = 0; i < len; ++i)
		hash = 31 * hash + name[i];
	return hash;
}

unsigned int dev_name_hash_orig(const char *name)
{
	return full_name_hash(name, strnlen(name, IFNAMSIZ));
}

unsigned int dev_name_hash_jhash(const char *name)
{
	return jhash(name, strnlen(name, IFNAMSIZ), 0);
}

typedef unsigned int (*dev_hash_name)(const char *name);

dev_hash_name hfn[] = {
	dev_name_hash_orig,
	dev_name_hash_jhash,
	dev_name_hash_new17,
	dev_name_hash_new31,
};

struct hocs {
	unsigned value;
	int occurences;
};

#if 0
#define debug(x...) printf(x)
#else
#define debug(x...) 
#endif

int main(int argc, char **argv)
{
	char dev_name[64];
	int no, htype, i, j, score, hbits;
	unsigned *h;
	/* stores hash elements by value and number of occurences */
	struct hocs *hocs;

	if (argc != 5) {
		fprintf(stderr, "syntax: dev_name_hash prefix no_of_names hash_type hash_bits\n");
		return -1;
	}

	no = atoi(argv[2]);
	if (no <= 0) {
		fprintf(stderr, "invalid number: %d\n", no);
		return -1;
	}

	htype = atoi(argv[3]);
	if (htype < 0 || htype >= sizeof(hfn)) {
		fprintf(stderr, "invalid hash type: %d\n", htype);
		return -1;
	}

	hbits = atoi(argv[4]);
	if (hbits <= 0) {
		fprintf(stderr, "invalid hash bits: %d\n", hbits);
		return -1;
	}
	
	h = malloc(no * sizeof(unsigned));

	for(i = 0; i < no; i++) {
		snprintf(dev_name, sizeof(dev_name), "%s%d", argv[1], i);
		h[i] = hfn[htype](dev_name) & ((1 << hbits) - 1);
		debug("h[i] = %x\n", h[i]);
	}

	hocs = malloc(no * sizeof(struct hocs));
	memset(hocs, 0, no * sizeof(unsigned));

	/* find occurences */
	for(i = 0; i < no; i++) {
		unsigned hash, dup;

		hash= h[i];
		dup = 0;
		hocs[i].value = hash;
		
		/* did we count this value already? */
		for(j = 0; j < i; j++) {
			if (i == j)
				continue;
			if (hocs[j].value == hash) {
				dup = 1;
				break;
			}
		}
		if (dup)
			continue;

		hocs[i].occurences = 1;

		for(j = 0; j < no; j++) {
			if (i == j)
				continue;
			if (hash == h[j])
				hocs[i].occurences++;
		}
	}

	/* the score is the number of iterations required to find each element
	   once */
	score = 0;
	for(i = 0; i < no; i++) {
		debug("hocs[%d] value = %x occurences = %d\n", i, hocs[i].value, hocs[i].occurences);
		score += hocs[i].occurences * (hocs[i].occurences + 1) / 2;
	}

	printf("score %d\n", score);

	return 0;
}

--Boundary-00=_UlM5KrQU7WCbcUD--
