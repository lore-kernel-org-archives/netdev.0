From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] arp_queue: serializing unlink + kfree_skb
Date: Mon, 31 Jan 2005 22:33:26 +1100
Message-ID: <E1CvZo6-0001Bz-00@gondolin.me.apana.org.au>
References: <20050131102920.GC4170@suse.de>
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261151AbVAaLea@vger.kernel.org>
To: okir@suse.de (Olaf Kirch)
In-Reply-To: <20050131102920.GC4170@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Olaf Kirch <okir@suse.de> wrote:
> 
> The problem is that IBM testing was hitting the assertion in kfree_skb
> that checks that the skb has been removed from any list it was on
> ("kfree_skb passed an skb still on a list").

That must've be some testing to catch this :)
 
> One possible fix here would be to add an smp_wmb after the __skb_unlink
> and a smp_rmb before the assertion in __kfree_skb, as in the attached
> patch.
> 
> Does this make sense?

It makes sense.  However, I'm not sure whether we want to add a read
barrier to the common path in kfree_skb just for a debugging test.
If it was only for the skb->list test we could move the read barrier
inside the if and reread skb->list if it were non-NULL.

What you've done is expose a much bigger problem in Linux.  We're
using atomic integers to signal that we're done with an object.
The object is usually represented by a piece of memory.

The problem is that in most of the places where we do this (and that's
not just in the networking systems), there are no memory barriers between
the last reference to that object and the decrease on the atomic counter.

For example, in this particular case, a more sinister (but probably
impossible for sk_buff objects) problem would be for the list removal
itself to be delayed until after the the kfree_skb.  This could
potentially mean that we're reading/writing memory that's already
been freed.

Perhaps we should always add a barrier to such operations.  So
kfree_skb would become

	if (atomic_read(&skb->users) != 1) {
		smp_mb__before_atomic_dec();
		if (!atomic_dec_and_test(&skb->users))
			return;
	}
	__kfree_skb(skb);

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
