From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [6/6]: jenkins hash for neigh
Date: Tue, 28 Sep 2004 07:41:34 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CC3FW-0001wo-00@gondolin.me.apana.org.au>
References: <20040927111520.4f495b17.davem@davemloft.net>
Cc: herbert@gondor.apana.org.au, laforge@gnumonks.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net (David S. Miller)
In-Reply-To: <20040927111520.4f495b17.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller <davem@davemloft.net> wrote:
> On Mon, 27 Sep 2004 21:48:33 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
>> > -   if (tbl->entries > (tbl->hash_mask + 1))
>> > +   if (tbl->entries > (tbl->hash_mask + 1)) {
>> > +           write_lock_bh(&tbl->lock);
>> >             neigh_hash_grow(tbl, (tbl->hash_mask + 1) << 1);
>> > +           write_unlock_bh(&tbl->lock);
>> > +   }
>> 
>> The locking should be outside the if block as otherwise you may grow
>> unnecessarily or grow into the same size :)
> 
> I'm not going to do that, because then we're grabbing that lock
> twice on every neigh create operation and I was trying hard
> to avoid that overhead.

Please at least do something like this:

size = tbl->hash_mask + 1;
if (tbl->entries > size) {
	write_lock_bh(&tbl->lock);
	neigh_hash_grow(tbl, size << 1);
	write_unlock_bh(&tbl->lock);
}

That'll at least kill the first race.  You can kill the race of
growing into the same size by doing the if check again inside the
locks.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
