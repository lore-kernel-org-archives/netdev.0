From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rhashtable: Fix reader/rehash race
Date: Fri, 13 Mar 2015 08:49:44 +1100
Message-ID: <20150312214944.GA20117@gondor.apana.org.au>
References: <20150312110749.GA19285@gondor.apana.org.au>
 <20150312133749.GB21620@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:41806 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752737AbbCLVtr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 17:49:47 -0400
Content-Disposition: inline
In-Reply-To: <20150312133749.GB21620@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2015 at 01:37:49PM +0000, Thomas Graf wrote:
> On 03/12/15 at 10:07pm, Herbert Xu wrote:
> > There is a potential race condition between readers and the rehasher.
> > In particular, the rehasher could have started a rehash while the
> > reader finishes a scan of the old table but fails to see the new
> > table pointer.
> > 
> > This patch closes this window by adding smp_wmb/smp_rmb.
> >     
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Are you sure this is sufficient? I think it is still possible
> for a rehash to preempt a reader in between:
> 
>         tbl = rht_dereference_rcu(ht->future_tbl, ht);
>         if (unlikely(tbl != old_tbl))
> 
> in which case old entries will be moved to the new table
> without the reader seeing them. I don't see how ensuring order
> solves this.

It doesn't matter.  The wmb/smb guarauntees that if the reader
cannot find the element in the old table then it must see the
new table pointer.  Vice versa if it cannot see the new table
pointer then the element (if it existed at all) must be in the
old table.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
