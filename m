From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] arp_queue: serializing unlink + kfree_skb
Date: Fri, 4 Feb 2005 12:20:53 +1100
Message-ID: <20050204012053.GA8949@gondor.apana.org.au>
References: <20050131102920.GC4170@suse.de> <E1CvZo6-0001Bz-00@gondolin.me.apana.org.au> <20050203142705.GA11318@krispykreme.ozlabs.ibm.com> <20050203203010.GA7081@gondor.apana.org.au> <20050203141901.5ce04c92.davem@davemloft.net> <20050203235044.GA8422@gondor.apana.org.au> <20050203164922.2627a112.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: anton@samba.org, okir@suse.de, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050203164922.2627a112.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Feb 03, 2005 at 04:49:22PM -0800, David S. Miller wrote:
> 
> If we see the count dropped to "1", whoever set it to "1" made
> sure that all outstanding memory operations (including things
> like __skb_unlink()) are globally visible before the
> atomic_dec_and_test() which put the thing to "1" from "2".
> (and we did use atomic_dec_and_test() since the refcount was
>  not "1")  Example, assuming skb->users is "2":
> 
> 	cpu 0			cpu 1
> 				__skb_unlink()
> 				kfree_skb()
> 	kfree_skb()
> 
> If cpu 0 sees the count at "1", it will always see the
> __skb_unlink() as well.

This is true if CPU 0 reads the count before reading skb->list.
Without a memory barrier, atomic_read and reading skb->list can
be reordered.  Put it another way, reading skb->list could return
a cached value that was read from the main memory prior to the
atomic_read.

So in order for CPU 0 to always see an up-to-date value of skb->list,
it needs to do an smp_rmb() between the atomic_read and reading
skb->list.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
