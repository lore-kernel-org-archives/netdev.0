From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH next-next-2.6] netdev: better dev_name_hash
Date: Sun, 25 Oct 2009 22:24:10 +0100
Message-ID: <4AE4C1FA.7000002@gmail.com>
References: <200910252158.53921.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:50979 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753638AbZJYVYM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2009 17:24:12 -0400
In-Reply-To: <200910252158.53921.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila a =C3=A9crit :
> The current dev_name_hash is not very good at spreading entries when =
a
> large number of interfaces of the same type (e.g. ethXXXXX) are used.

Very true

>=20
> Here are some performance numbers for creating 16000 dummy interfaces=
 with
> and without the patch (with per device sysctl entries disabled)
>=20
>     With patch                      Without patch
>=20
>     real    0m 2.27s                real    0m 4.32s
>     user    0m 0.00s                user    0m 0.00s
>     sys     0m 1.13s                sys     0m 2.16s
>=20

1) A program to show hash distribution would be more convincing,
and could show that 17 multiplier is better, not 31 :)

2) Why full_name_hash() not changed as well ?


$ cat test.c
#include <stdio.h>
#define init_name_hash()                0

/* partial hash update function. Assume roughly 4 bits per character */
static inline unsigned long
partial_name_hash(unsigned long c, unsigned long prevhash)
{
        return (prevhash + (c << 4) + (c >> 4)) * 11;
}

/*
 * Finally: cut down the number of bits to a int value (and try to avoi=
d
 * losing bits)
 */
static inline unsigned long end_name_hash(unsigned long hash)
{
        return (unsigned int) hash;
}

/* Compute the hash for a name string. */
static inline unsigned int
full_name_hash(const unsigned char *name, unsigned int len)
{
        unsigned long hash =3D init_name_hash();
        while (len--)
                hash =3D partial_name_hash(*name++, hash);
        return end_name_hash(hash);
}

static inline unsigned int
string_hash31(const unsigned char *name, unsigned int len)
{
        unsigned hash =3D 0;
        int i;

        for (i =3D 0; i < len; ++i)
                hash =3D 31 * hash + name[i];
        return hash;
}

static inline unsigned int
string_hash17(const unsigned char *name, unsigned int len)
{
        unsigned hash =3D 0;
        int i;

        for (i =3D 0; i < len; ++i)
                hash =3D 17 * hash + name[i];
        return hash;
}

unsigned int hashdist1[256], hashdist2[256], hashdist3[256];

void print_dist(unsigned int *dist, const char *name)
{
        unsigned int i;

        printf("%s[] =3D {\n", name);
        for (i =3D 0; i < 256; i++) {
                printf("%d, ", dist[i]);
                if ((i & 15) =3D=3D 15) putchar('\n');
        }
        printf("};\n");
}

int main()
{
        int i;
        unsigned int hash;
        unsigned char name[16];

        for (i =3D 0; i < 16000; i++) {
                unsigned int len =3D sprintf(name, "dummy%d", i);

                hash =3D full_name_hash(name, len);
                hashdist1[hash & 255]++;

                hash =3D string_hash31(name, len);
                hashdist2[hash & 255]++;

                hash =3D string_hash17(name, len);
                hashdist3[hash & 255]++;
                }
        print_dist(hashdist1, "full_name_hash");
        print_dist(hashdist2, "string_hash31");
        print_dist(hashdist3, "string_hash17");
        return 0;
}

$ gcc -o test test.c
$ ./test
full_name_hash[] =3D {
0, 0, 0, 375, 0, 0, 562, 0, 0, 0, 6, 0, 0, 0, 0, 56,
0, 0, 0, 374, 0, 0, 562, 0, 0, 0, 5, 0, 0, 0, 0, 57,
0, 0, 0, 375, 0, 0, 562, 0, 0, 0, 6, 1, 0, 0, 0, 56,
0, 0, 0, 375, 0, 0, 563, 0, 0, 0, 5, 1, 0, 0, 0, 56,
0, 0, 0, 375, 0, 0, 563, 0, 0, 0, 6, 1, 0, 0, 0, 56,
0, 0, 0, 375, 0, 0, 562, 0, 0, 0, 6, 0, 0, 0, 0, 57,
0, 0, 0, 375, 0, 0, 563, 0, 0, 0, 5, 0, 0, 0, 0, 56,
0, 0, 0, 376, 0, 0, 563, 0, 0, 0, 6, 1, 0, 0, 0, 56,
0, 0, 0, 375, 0, 0, 562, 0, 0, 0, 5, 1, 0, 0, 0, 57,
0, 0, 0, 374, 0, 0, 563, 0, 0, 0, 6, 1, 0, 0, 0, 56,
0, 0, 0, 375, 0, 0, 563, 0, 0, 0, 6, 1, 0, 0, 0, 56,
0, 0, 0, 376, 0, 0, 562, 0, 0, 0, 6, 0, 0, 0, 0, 56,
0, 0, 0, 375, 0, 0, 562, 0, 0, 0, 5, 0, 0, 0, 0, 56,
0, 0, 0, 375, 0, 0, 562, 0, 0, 0, 5, 1, 0, 0, 0, 56,
0, 0, 0, 375, 0, 0, 563, 0, 0, 0, 6, 1, 0, 0, 0, 57,
0, 0, 0, 375, 0, 0, 563, 0, 0, 0, 6, 1, 0, 0, 0, 56,
};
string_hash31[] =3D {
42, 54, 67, 81, 92, 103, 116, 125, 131, 131, 133, 128, 121, 110, 101, 8=
7,
72, 59, 47, 36, 25, 17, 12, 8, 4, 4, 6, 7, 11, 15, 24, 32,
42, 54, 68, 79, 91, 105, 117, 127, 130, 135, 133, 129, 120, 113, 100, 8=
6,
71, 58, 46, 33, 24, 16, 11, 6, 4, 4, 5, 7, 10, 16, 23, 32,
41, 54, 66, 78, 91, 104, 117, 123, 130, 133, 134, 127, 122, 112, 101, 8=
6,
72, 61, 47, 35, 25, 19, 12, 8, 5, 6, 6, 7, 11, 16, 24, 31,
43, 54, 66, 78, 92, 106, 116, 125, 131, 136, 132, 129, 121, 112, 98, 84=
,
72, 58, 44, 32, 24, 16, 11, 6, 5, 5, 4, 7, 10, 17, 23, 32,
41, 54, 65, 78, 92, 105, 116, 123, 132, 133, 133, 127, 122, 111, 99, 86=
,
74, 60, 45, 35, 26, 19, 12, 8, 7, 5, 5, 7, 12, 17, 24, 31,
43, 54, 66, 80, 94, 107, 116, 126, 131, 135, 131, 129, 120, 110, 97, 85=
,
71, 56, 44, 33, 25, 16, 11, 7, 5, 3, 4, 7, 11, 17, 22, 32,
43, 54, 66, 80, 94, 105, 115, 124, 133, 132, 132, 127, 121, 110, 99, 87=
,
74, 59, 46, 37, 26, 19, 12, 9, 6, 4, 5, 8, 12, 16, 23, 32,
43, 53, 67, 81, 94, 105, 116, 128, 132, 135, 133, 130, 121, 112, 100, 8=
8,
72, 57, 46, 34, 25, 17, 11, 7, 4, 3, 5, 8, 11, 16, 22, 33,
};
string_hash17[] =3D {
68, 73, 72, 69, 62, 57, 52, 53, 60, 66, 71, 69, 69, 68, 67, 64,
67, 68, 70, 68, 63, 56, 53, 51, 57, 64, 68, 71, 68, 67, 66, 65,
62, 65, 67, 68, 64, 59, 55, 52, 54, 60, 67, 69, 69, 65, 65, 61,
59, 60, 63, 64, 64, 60, 55, 54, 54, 61, 67, 72, 72, 71, 66, 64,
60, 59, 60, 64, 64, 62, 58, 56, 55, 59, 66, 70, 73, 69, 67, 62,
58, 53, 56, 57, 60, 59, 57, 54, 53, 56, 62, 69, 71, 72, 67, 64,
57, 53, 51, 54, 58, 60, 59, 57, 57, 56, 63, 69, 74, 74, 71, 65,
60, 53, 50, 52, 55, 58, 59, 58, 57, 58, 61, 68, 73, 80, 77, 73,
66, 59, 52, 52, 54, 60, 61, 58, 58, 58, 59, 64, 71, 73, 78, 71,
66, 57, 50, 46, 50, 54, 59, 61, 58, 59, 60, 65, 70, 75, 78, 80,
72, 65, 56, 50, 49, 53, 59, 63, 62, 60, 62, 63, 68, 72, 77, 77,
76, 67, 58, 49, 46, 49, 55, 60, 62, 62, 59, 62, 65, 70, 72, 78,
75, 73, 62, 53, 47, 47, 52, 58, 63, 62, 63, 61, 64, 67, 71, 73,
76, 72, 68, 57, 49, 46, 50, 57, 62, 65, 65, 65, 64, 67, 69, 73,
76, 76, 71, 65, 54, 49, 49, 55, 62, 65, 65, 64, 65, 63, 66, 67,
71, 71, 70, 63, 57, 49, 47, 52, 58, 65, 66, 67, 65, 67, 65, 67,
};

