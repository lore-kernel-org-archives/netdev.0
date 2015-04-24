From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: rhashtable: Add cap on number of elements in hash table
Date: Fri, 24 Apr 2015 09:01:10 +0200
Message-ID: <1429858870.1852.7.camel@sipsolutions.net>
References: <1429799923-28122-1-git-send-email-johannes@sipsolutions.net>
	 <20150423.115919.1353583175267783165.davem@davemloft.net>
	 <20150424005729.GA27075@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net, tgraf@suug.ch
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:38851 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933431AbbDXHBU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Apr 2015 03:01:20 -0400
In-Reply-To: <20150424005729.GA27075@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-04-24 at 08:57 +0800, Herbert Xu wrote:

> It seems that I lost track somewhere along the line.  I meant
> to add an explicit limit on the overall number of entries since
> that was what users like netlink expected but never got around
> to doing it.  Instead it seems that we're currently relying on
> the rht_grow_above_100 to protect us.

This isn't really what I wanted though :-)

I just wanted to test hash collisions.

> We currently have no limit on the number of elements in a hash table.
> This is very bad especially considering that some rhashtable users
> had such a limit before the conversion and relied on it for defence
> against DoS attacks.
> 
> We already have a maximum hash table size limit but its enforcement
> is only by luck and results in a nasty WARN_ON.

And doesn't actually work, the insertion appears to succeed :-)

> This patch adds a new paramater insecure_max_entries which becomes

typo: parameter

> the cap on the table.  If unset it defaults to max_size.  

So at least for my (admittedly testing only) use case, I wouldn't want
it to default to max_size, since the two at least *seem* to do different
things (max # of chains vs. max # of entries), no?

Anyway - since it's for testing only I guess I could even set max_size
to 4 and insecure_max_entries to something far bigger :)

> If it is
> also zero it means that there is no cap on the number of elements
> in the table.  However, the table will grow whenever the utilisation
> hits 100% and if that growth fails, you will get ENOMEM on insertion.
> 
> As allowing >100% utilisation is potentially dangerous, the name
> contains the word insecure.

Not sure I get this. So rhashtable is trying to actually never have
collisions? How could that possibly work?

> @@ -282,7 +285,20 @@ static inline bool rht_shrink_below_30(const struct rhashtable *ht,
>  static inline bool rht_grow_above_100(const struct rhashtable *ht,
>  				      const struct bucket_table *tbl)
>  {
> -	return atomic_read(&ht->nelems) > tbl->size;
> +	return atomic_read(&ht->nelems) > tbl->size &&
> +	       (!ht->p.max_size || tbl->size < ht->p.max_size);
> +}

Since you're also doing what I did here, would it make sense to apply my
patch to net and this one only to net-next?

For my use case (which was testing/debug) I don't actually care that
much, but perhaps that'd be an easier sell towards the end of the merge
window :) It seems that my patch would mostly fix the *issue*, while
yours actually adds a new parameter that's also not actually used yet.

The netlink hash table could potentially hit max_size and thus the
warning and the case I was hitting (on a system with >>64k netlink
sockets.)

johannes
