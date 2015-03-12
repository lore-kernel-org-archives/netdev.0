From: Thomas Graf <tgraf@suug.ch>
Subject: Re: rhashtable: Fix reader/rehash race
Date: Thu, 12 Mar 2015 13:37:49 +0000
Message-ID: <20150312133749.GB21620@casper.infradead.org>
References: <20150312110749.GA19285@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50021 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754419AbbCLNhw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 09:37:52 -0400
Content-Disposition: inline
In-Reply-To: <20150312110749.GA19285@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/12/15 at 10:07pm, Herbert Xu wrote:
> There is a potential race condition between readers and the rehasher.
> In particular, the rehasher could have started a rehash while the
> reader finishes a scan of the old table but fails to see the new
> table pointer.
> 
> This patch closes this window by adding smp_wmb/smp_rmb.
>     
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Are you sure this is sufficient? I think it is still possible
for a rehash to preempt a reader in between:

        tbl = rht_dereference_rcu(ht->future_tbl, ht);
        if (unlikely(tbl != old_tbl))

in which case old entries will be moved to the new table
without the reader seeing them. I don't see how ensuring order
solves this.
