From: Christoph Lameter <christoph@lameter.com>
Subject: Re: atomic_dec_and_test for child dst needed in dst_destroy?
Date: Thu, 7 Apr 2005 09:00:51 -0700 (PDT)
Message-ID: <Pine.LNX.4.58.0504070842420.29731@graphe.net>
References: <Pine.LNX.4.58.0504051925250.21486@graphe.net>
 <E1DJ5y2-0003rF-00@gondolin.me.apana.org.au> <20050406111721.3ac67605.davem@davemloft.net>
 <20050407110724.GA8760@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        pravins@calsoftinc.com, shai@scalesx86.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050407110724.GA8760@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 7 Apr 2005, Herbert Xu wrote:

> However, for NOHASH dst entries we know that
>
> 1) They're not in a hash table.
> 2) They're not on the GC list.
>
> Therefore it is safe to look at the entry even after dropping our
> reference count.

In an earlier email you said that there was a slight chance that child
entries (typically NOHASH from what I can see in the code) could be on the
gc list.

If its not on the hash table and not on the gc list then how could the
refcnt be > 1 ? Doesnt the refcnt > 1 imply that multiple concurrent
accesses are possible?

Also if this is as you say then both types of entries better be
treated in a distinct way for clarity in the code. This also avoids
having a nohash variable:

if ((dst->flags & DST_NOHASH)) {
	/* dst not on hash and also not on gc list */
	atomic_dec(&dst->__refcnt);
	if (!atomic_read(&dst->refcnt))
		/* We were the only reference kill child */
		goto again;
	/* return child to put it on the gc list */
	return dst;
}

/* dst on the hashed list. Decrement refcnt and rely on garbage collector
 * to eventually remove it
 */
atomic_dec(&dst->__refcnt);
return NULL;
