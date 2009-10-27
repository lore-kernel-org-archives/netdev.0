From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] dcache: better name hash function
Date: Tue, 27 Oct 2009 10:07:36 -0700
Message-ID: <20091027100736.5303f1ab@nehalam>
References: <19864844.24581256620784317.JavaMail.root@tahiti.vyatta.com>
 <4AE68E23.20205@gmail.com>
 <4AE69829.9070207@gmail.com>
 <4AE6A16F.4020002@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Al Viro <viro@zeniv.linux.org.uk>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756311AbZJ0RHj@vger.kernel.org>
In-Reply-To: <4AE6A16F.4020002@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 27 Oct 2009 08:29:51 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Eric Dumazet a =C3=A9crit :
> >=20
> >=20
> > 511 value on 64bit, and 1023 on 32bit arches are nice because
> > hashsz * sizeof(pointer) <=3D 4096, wasting space for one pointer o=
nly.
> >=20
> > Conclusion : jhash and 511/1023 hashsize for netdevices,
> > no divides, only one multiply for the fold.
>=20
> Just forget about 511 & 1023, as power of two works too.
>=20
> -> 512 & 1024 + jhash
>=20
> Guess what, David already said this :)


Rather than wasting space, or doing expensive, modulus; just folding
the higher bits back with XOR redistributes the bits better.


On fast machine (Nehalam):

100000000 Iterations
256 Slots (order 8)
Algorithm             Time       Ratio       Max   StdDev
string10             2.505290       1.00    390628   0.00
xor                  2.521329       1.00    392120   2.14
SuperFastHash        2.781745       1.00    397027   4.43
fnv32                2.847892       1.00    392139   0.98
djb2                 2.886342       1.00    390827   0.12
string_hash31        2.900980       1.00    391001   0.20
string_hash17        2.938708       1.00    391122   0.20
full_name_hash       3.080886       1.00    390860   0.10
jhash_string         3.092161       1.00    392775   1.08
fnv64                5.340740       1.00    392854   0.88
kr_hash              2.395757       7.30   4379091 1568.25

On slow machine (CULV):
100000000 Iterations
256 Slots (order 8)
Algorithm             Time       Ratio       Max   StdDev
string10             10.807174       1.00    390628   0.00
SuperFastHash        11.397303       1.00    397027   4.43
xor                  11.660968       1.00    392120   2.14
djb2                 11.674707       1.00    390827   0.12
jhash_string         11.997104       1.00    392775   1.08
fnv32                12.289086       1.00    392139   0.98
string_hash17        12.863864       1.00    391122   0.20
full_name_hash       13.249483       1.00    390860   0.10
string_hash31        13.668270       1.00    391001   0.20
fnv64                39.808964       1.00    392854   0.88
kr_hash              10.316305       7.30   4379091 1568.25

So Eric's string10 is fastest for special case of fooNNN style names.
But probably isn't best for general strings. Orignal function
is >20% slower, which is surprising probably because of overhead
of 2 shifts and multipy. jenkins and fnv are both 10% slower.

The following seems to give best results (combination of 16bit trick
and string17).


static unsigned int xor17(const unsigned char *key, unsigned int len)
{
    	uint32_t h =3D 0;
	unsigned int rem;

	rem =3D len & 1;
	len >>=3D 1;

	while (len--) {
		h =3D ((h << 4) + h) ^ get_unaligned16(key);
		key +=3D sizeof(uint16_t);
	}

	if (rem)
		h =3D ((h << 4) + h) ^ *key;


    	return h;
}
