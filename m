From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 4/4] rhashtable: Add parent argument to mutex_is_held
Date: Sat, 15 Nov 2014 11:16:26 +0000
Message-ID: <20141115111626.GP19157@casper.infradead.org>
References: <20141113101025.GA3728@gondor.apana.org.au>
 <E1XorN4-0000zn-0H@gondolin.me.apana.org.au>
 <20141113103723.GO19157@casper.infradead.org>
 <20141113103834.GA4024@gondor.apana.org.au>
 <20141113104124.GA24379@casper.infradead.org>
 <20141113104343.GA4112@gondor.apana.org.au>
 <20141115032512.GA19299@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	paulmck@linux.vnet.ibm.com, josh@joshtriplett.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:41110 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752649AbaKOLQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Nov 2014 06:16:29 -0500
Content-Disposition: inline
In-Reply-To: <20141115032512.GA19299@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/15/14 at 11:25am, Herbert Xu wrote:
> On Thu, Nov 13, 2014 at 06:43:43PM +0800, Herbert Xu wrote:
> > On Thu, Nov 13, 2014 at 10:41:24AM +0000, Thomas Graf wrote:
> > >
> > > Never mind. You did fix it. I looked at the wrong patch.
> > 
> > OK.  Now comes the fun part of shoehorning the xfrm_policy bydst
> > hash into rhashtable :)
> 
> Thomas, it appears that rhashtable as it stands cannot handle
> changing the random seed because of the way it constructs the
> new hash table without degrading into a linked list.  Is there
> something I'm missing?
> 
> FWIW my hashtable in net/bridge/br_multicast.c handles rehashing
> correctly.  Any objections to me converting rhashtable to use my
> scheme instead?

Can you elaborate a bit?

The point of rhashtable is to not require two sets of linked list
pointers as done by MDB or OVS flow tables to work around the
increased cache footprint of that approach. The difference of the
two algos is dicussed in this paper [0].

The disadvantage of rhashtable is that, AFAIK, the hash function
cannot change while resizing as it would break the mutual linked
lists.

rhashtable will eventually be converted to per bucket locks with
deferred resizing to allow concurrent insertions and removal to
multiple buckets and to allow for mutations from atomic context
which is needed to use it for TCP hashtables. This work is in
progress:
http://lwn.net/Articles/611951/

Eric mentioned he is working on the rcu'ification of sockets which
is what is missing to make it work.

[0] https://www.usenix.org/legacy/event/atc11/tech/final_files/Triplett.pdf
