From: David Miller <davem@davemloft.net>
Subject: Re: rhashtable: Add cap on number of elements in hash table
Date: Thu, 14 May 2015 22:22:17 -0400 (EDT)
Message-ID: <20150514.222217.1991822787577994078.davem@davemloft.net>
References: <20150423.115919.1353583175267783165.davem@davemloft.net>
	<20150424005729.GA27075@gondor.apana.org.au>
	<20150513080640.GA27800@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org, kaber@trash.net,
	tgraf@suug.ch, johannes.berg@intel.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43968 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423401AbbEOCWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 22:22:24 -0400
In-Reply-To: <20150513080640.GA27800@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 13 May 2015 16:06:40 +0800

> We currently have no limit on the number of elements in a hash table.
> This is a problem because some users (tipc) set a ceiling on the
> maximum table size and when that is reached the hash table may
> degenerate.  Others may encounter OOM when growing and if we allow
> insertions when that happens the hash table perofrmance may also
> suffer.
> 
> This patch adds a new paramater insecure_max_entries which becomes
> the cap on the table.  If unset it defaults to max_size.  If it is
> also zero it means that there is no cap on the number of elements
> in the table.  However, the table will grow whenever the utilisation
> hits 100% and if that growth fails, you will get ENOMEM on insertion.
> 
> As allowing >100% utilisation is potentially dangerous, the name
> contains the word insecure.
> 
> Note that the cap is not a hard limit.  This is done for performance
> reasons as enforcing a hard limit will result in use of atomic ops
> that are heavier than the ones we currently use.
> 
> The reasoning is that we're only guarding against a gross over-
> subscription of the table, rather than a small breach of the limit.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

I'm not so sure I can get behind this change.

For the default case where we propagate max_size into this new limt,
if we grow the hash table to it's maximum size, and then just go one
past the limit, we're going to start failing inserts.

In my opinion, up to at least 2 X max_size, it's safe to allow the
insert.  Assuming a well choosen hash function and a roughly even
distribution.

A two entry deep hash chain is not a reason to fail a hash insertion.

Failures on hash insertions we would not do in pretty much any other
hash implementation in the kernel.  I'd seriously would rather have
3 entry deep hash chains than no new connections at all.

If an administrator has to analyze some situation where this is
happening and they see -E2BIG propagating into their applications,
this is going to be surprising.  And when they do all of the work
to figure out what is causing it, I am pretty sure they will be
somewhat upset that we considered it OK to do this.

So I'd like you to take some time to reconsider hash insert failures,
and only do them when it's going to create an unnaceptable, _massive_
hardship for the machine.  And I do not think that 2 or 3 entry deep
hash chains quality.

Thanks.
