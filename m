From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/4] xfrm: cache bundles instead of policies for
	outgoing flows
Date: Tue, 6 Apr 2010 20:40:14 +0800
Message-ID: <20100406124014.GA24412@gondor.apana.org.au>
References: <1270450824-2928-1-git-send-email-timo.teras@iki.fi> <1270450824-2928-3-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:43603 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752199Ab0DFMkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 08:40:17 -0400
Content-Disposition: inline
In-Reply-To: <1270450824-2928-3-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 05, 2010 at 10:00:22AM +0300, Timo Teras wrote:
>
> @@ -623,33 +618,11 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
>  		schedule_work(&net->xfrm.policy_hash_work);
>  
>  	read_lock_bh(&xfrm_policy_lock);
> -	gc_list = NULL;
>  	entry = &policy->bydst;
> -	hlist_for_each_entry_continue(policy, entry, bydst) {
> -		struct dst_entry *dst;
> -
> -		write_lock(&policy->lock);
> -		dst = policy->bundles;
> -		if (dst) {
> -			struct dst_entry *tail = dst;
> -			while (tail->next)
> -				tail = tail->next;
> -			tail->next = gc_list;
> -			gc_list = dst;
> -
> -			policy->bundles = NULL;
> -		}
> -		write_unlock(&policy->lock);
> -	}
> +	hlist_for_each_entry_continue(policy, entry, bydst)
> +		atomic_inc(&policy->genid);

Do we still need this since we're invalidating the whole flow
cache?

The current code is necessary since otherwise the bundles won't
get freed.  But with your new code, this is essentially doing
nothing, no?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
