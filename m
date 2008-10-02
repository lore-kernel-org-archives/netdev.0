From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when gc_elasticity is exceeded
Date: Thu, 2 Oct 2008 11:13:58 +0400
Message-ID: <20081002071358.GA20406@2ka.mipt.ru>
References: <48E141F3.9000903@cosmosbay.com> <20080929223801.GA3157@hmsreliant.think-freely.org> <48E1C104.2080801@cosmosbay.com> <20080930.071023.07946874.davem@davemloft.net> <48E25F02.8030303@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, nhorman@tuxdriver.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:39153 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751133AbYJBHQm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2008 03:16:42 -0400
Content-Disposition: inline
In-Reply-To: <48E25F02.8030303@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Tue, Sep 30, 2008 at 07:16:50PM +0200, Eric Dumazet (dada1@cosmosbay.com) wrote:
> No problem, but my suggestion to use a separate threshold than elasticity
> was apparently not taken into consideration.
> 
> I ran an experiment on a big stable machine with 2^19 rtcache slots,
> scanning all chains and found *many* of them having length > elasticity,
> maximum being 13. I am sure its allowed by statistics laws.
> 
> (average chain length : 3.55)
> 
> In order to avoid unecessary cache invalidation, we need some 
> calculation from a statistics expert.
> 
> Given rt_hash_size and elasticity (or rt_max_size), compute the "maximum 
> reasonable" chain length, ie some X number where probability(chain_length < 
> X) > 0.9999
> 
> (CCed Evgeniy Polyakov :) )
 
:)

If it is a hash table with fixed size, and hash is being produced like
some function result modulo size of the table, then there will be always
fluctuations with longer chain lenghts than 'usual', since, for example,
hash function produces result in 2^32 field, which hash table size is
only 2^20 or something smaller than maxiumum hash result. When I
analyzed Jenkin's hash I mistakenly concluded that such pikes are result
of the hash distribution itself and not final modulo operation.

Plus, it is always a gaussian distribution, so there will be (although
depending on parameters amount may be small enough) entries with longer
and smaller than average chains.

I tested list walking speed compared to rb-tree and trie on p4 machines
without prefetch and lists with upto 10 element are processed faster
than anything else, so if your average chain lengths are less than 10
elements, you are in a good condition.

Also I have a tricky algorithm to automatically scale RCU protected hash
table (with additional overhead at scale time though, but I believe it
is not a problem), which just waits to be implemented in netchannels, so
long chain length problem can be fixed, if algorithm works. Ok, I've
finished my advertisement rants :)

-- 
	Evgeniy Polyakov
