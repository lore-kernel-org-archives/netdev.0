From: David Miller <davem@davemloft.net>
Subject: Re: ipv4: Simplify ARP hash function.
Date: Fri, 08 Jul 2011 12:51:18 -0700 (PDT)
Message-ID: <20110708.125118.886216418938741383.davem@davemloft.net>
References: <CAL1RGDWbCi_nE8tRp9zyX3Z1yBHKP9ygxNV6TNKp4Up+0g2EPA@mail.gmail.com>
	<20110708.122742.1006323245708104141.davem@davemloft.net>
	<CAHXqBFKE_hLvFgL1_7F+k+pQ0+tEuhBqeRUOtgaM1yrjvXQQww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: roland@purestorage.com, johnwheffner@gmail.com, mj@ucw.cz,
	netdev@vger.kernel.org
To: mirqus@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48359 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752168Ab1GHTv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 15:51:26 -0400
In-Reply-To: <CAHXqBFKE_hLvFgL1_7F+k+pQ0+tEuhBqeRUOtgaM1yrjvXQQww@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirqus@gmail.com>
Date: Fri, 8 Jul 2011 21:39:18 +0200

> With b[3] =3D b[0] ^ b[1] ^ b[2] you get 2^24 keys that hash to the s=
ame bucket.

Ok, I'm convinced, thanks :-)

--------------------
#include <stdlib.h>
#include <stdio.h>

int hashfn(unsigned int key, unsigned int rnd)
{
	unsigned int x =3D key ^ rnd;

	x ^=3D (x >> 8) ^ (x >> 16) ^ (x >> 24);

	return x & 0xff;
}

int count[256];

unsigned int collide(unsigned int key)
{
	unsigned int b0 =3D key >> 24;
	unsigned int b1 =3D (key >> 16) & 0xff;
	unsigned int b2 =3D (key >> 8) & 0xff;

	key &=3D ~0xff;
	key |=3D (b0 ^ b1 ^ b2);

	return key;
}

int main(int argc, char **argp)
{
	unsigned int rnd =3D atoi(argp[1]);
	unsigned int i;

	for (i =3D 0; i < (64 * 1024); i++) {
		unsigned int key =3D i << 8;
		unsigned int hash;

		key =3D collide(key);
		hash =3D hashfn(key, rnd);
		printf("%u: %u\n", key, hash);
		count[hash]++;
	}
	for (i =3D 0; i < 256; i++)
		printf("COUNT[%3u]=3D%3u\n", i, count[i]);
	return 0;
}
