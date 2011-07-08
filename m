From: David Miller <davem@davemloft.net>
Subject: Re: ipv4: Simplify ARP hash function.
Date: Fri, 08 Jul 2011 10:54:30 -0700 (PDT)
Message-ID: <20110708.105430.2072718553430519147.davem@davemloft.net>
References: <20110708.101056.89960389404725087.davem@davemloft.net>
	<mj+md-20110708.173556.16517.nikam@ucw.cz>
	<20110708.104739.169518036069870432.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mj@ucw.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46804 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750757Ab1GHRye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 13:54:34 -0400
In-Reply-To: <20110708.104739.169518036069870432.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 08 Jul 2011 10:47:39 -0700 (PDT)

> From: Martin Mares <mj@ucw.cz>
> Date: Fri, 8 Jul 2011 19:40:55 +0200
> 
>> The hash function is linear, so it can be reduced to:
>> 
>> 	a = key ^ dev->ifindex
>> 	return (a >> 8) ^ (a >> 16) ^ (a >> 24)				// (1)
>> 	     ^ (hash_rnd >> 8) ^ (hash_rnd >> 16) ^ (hash_rnd >> 24)	// (2)
> 
> Is this really the same?  The inclusion of a full 32-bit xor
> with hash_rnd before folding was intentional, so that the
> final folding occurs on a completely "random" value.

For example, try out this test program.  Run as "./x ${RANDOM_VALUE}",
it shows that the attacker cannot simply just iterate by the number of
hash table slots to create collisions, assuming a hash table size of
256 slots:

--------------------
#include <stdlib.h>
#include <stdio.h>

int main(int argc, char **argp)
{
	int i, rnd;

	rnd = atoi(argp[1]);
	for (i = 1; i < (64 * 1024); i += 256) {
		int x = (i ^ rnd);

		x ^= (x >> 8) ^ (x << 16) ^ (x >> 24);

		x &= 0xff;

		printf("%d\n", x);
	}
	return 0;
}

