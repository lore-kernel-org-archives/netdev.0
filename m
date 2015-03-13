From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/6] rhashtable: Fix walker behaviour during rehash
Date: Sat, 14 Mar 2015 10:42:21 +1100
Message-ID: <20150313234221.GA9020@gondor.apana.org.au>
References: <20150313095607.GA598@gondor.apana.org.au>
 <E1YWML8-0000B6-62@gondolin.me.apana.org.au>
 <20150313155023.GG17829@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:40769 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752033AbbCMXm0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 19:42:26 -0400
Content-Disposition: inline
In-Reply-To: <20150313155023.GG17829@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 13, 2015 at 03:50:23PM +0000, Thomas Graf wrote:
>
> Is there a reason to keeping rhashtable_walk_init() and
> rhashtable_walk_start() separate? It seems like one always has
> to call init for each iteration as start does not reset the
> iterator bits. It would also safe a mutex_lock().

Yes they are needed for netlink users, e.g., netfilter.  Proc
users will always init/start while netlink users can init, and
then just use start/stop to keep their state.

> > @@ -826,17 +832,18 @@ next:
> >  		iter->skip = 0;
> >  	}
> >  
> > -	iter->p = NULL;
> > -
> > -out:
> > -	if (iter->walker->resize) {
> > -		iter->p = NULL;
> > +	iter->walker->tbl = rht_dereference_rcu(ht->future_tbl, ht);
> > +	if (iter->walker->tbl != tbl) {
> 
> I was confused at first because this would cause to always dump the
> table twice in the regular case. I see that in patch 6/6 you change
> the meaning of future_tbl and only make it non-NULL during the short
> period of the rehashing. Ordering patch 6 in front of 1 would have
> helped ;-)
> 
> Looks good in combination with patch 6.

No this patch is needed on its own and should not depend on patch 6
in any way.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
