From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: ipv4: Simplify ARP hash function.
Date: Fri, 8 Jul 2011 16:41:28 -0700
Message-ID: <20110708164128.50155c9c@nehalam.ftrdhcpuser.net>
References: <CAL1RGDWbCi_nE8tRp9zyX3Z1yBHKP9ygxNV6TNKp4Up+0g2EPA@mail.gmail.com>
	<20110708.122742.1006323245708104141.davem@davemloft.net>
	<CAL1RGDWTfchzBSv9rbgfg5DWvqB-Gi-RBpzDPGRUg96fNcf4Bw@mail.gmail.com>
	<20110708.153258.1997707802176810939.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: roland@purestorage.com, johnwheffner@gmail.com, mj@ucw.cz,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48941 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750904Ab1GHXlb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jul 2011 19:41:31 -0400
In-Reply-To: <20110708.153258.1997707802176810939.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What about using murmur hash which has a four byte pass as well.
  https://sites.google.com/site/murmurhash/
---
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#define u32 uint32_t

/* Do a one pass murmurhash2 */
static u32 arp_hashfn(u32 key, int ifindex, u32 hash_rnd)
{
	/* murmurhash mixiing constants */
	const unsigned int m = 0x5bd1e995;
	const int r = 24;

	/* Initialize the hash to a 'random' value  */
	unsigned int h = ifindex ^ hash_rnd;
	unsigned int k = key;

	k *= m; 
	k ^= k >> r; 
	k *= m; 
		
	h *= m; 
	h ^= k;

	/* Do a few final mixes of the hash to ensure the last few
	 * bytes are well-incorporated.
	 */

	h ^= h >> 13;
	h *= m;
	h ^= h >> 15;

	return h;
} 

int main(int argc, char **argv)
{
	u32 rnd, key, hash;
	int ifindex;

	key = atoi(argv[1]);
	ifindex = atoi(argv[2]);
	rnd = atoi(argv[3]);

	hash = arp_hashfn(key, ifindex, rnd);
	printf("%u, %d, %u => %u\n", key, ifindex, rnd, hash);
	return 0;
}
