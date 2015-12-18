From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rhashtable: Kill harmless RCU warning in rhashtable_walk_init
Date: Fri, 18 Dec 2015 21:14:08 +0800
Message-ID: <20151218131408.GA21756@gondor.apana.org.au>
References: <874mfgedrp.fsf@yhuang-dev.intel.com>
 <20151218053416.GA19479@gondor.apana.org.au>
 <20151218062450.GA19749@gondor.apana.org.au>
 <1450443254.8474.120.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel test robot <ying.huang@linux.intel.com>, lkp@01.org,
	LKML <linux-kernel@vger.kernel.org>,
	Colin Ian King <colin.king@canonical.com>,
	0day robot <fengguang.wu@intel.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:42250 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752975AbbLRNOY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 08:14:24 -0500
Content-Disposition: inline
In-Reply-To: <1450443254.8474.120.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 18, 2015 at 04:54:14AM -0800, Eric Dumazet wrote:
>
> You can avoid the comment by using the self documented and lockdep
> enabled primitive
> 
> iter->walker->tbl = rcu_dereference_protected(ht->tbl,
> 					      lockdep_is_held(&ht->lock));

That is just gross.  I think a comment is much better in this case.

If we were to have more place where ht->lock is taken and we had
to do the RCU dereference on ht->tbl then we could add a helper
for it.  For now it's just a single place and I think a comment
is the best way to deal with it.

> But, storing the ht->tbl and then releasing the lock immediately after
> escapes RCU protection.
> 
> So why do we store ht->tbl in the first place ?
> 
> What exactly prevents it from disappearing after lock is released ?

We add ourselves to the walker list before we release the lock.
The only entity that can destroy ht->tbl will take care of all
walkers before doing so.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
