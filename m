From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [BUG] overflow in net/ipv4/route.c rt_check_expire()
Date: Mon, 4 Apr 2005 20:38:14 +1000
Message-ID: <20050404103814.GA32269@gondor.apana.org.au>
References: <E1DHdsP-0003Lr-00@gondolin.me.apana.org.au> <424E641A.1020609@cosmosbay.com> <16974.41648.568927.54429@robur.slu.se> <20050402193224.GA25157@gondor.apana.org.au> <20050402115528.11f71a3c.davem@davemloft.net> <20050403074337.GA8083@gondor.apana.org.au> <16976.19092.562006.246545@robur.slu.se> <20050403214521.GB15901@gondor.apana.org.au> <16977.5791.367581.655483@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, dada1@cosmosbay.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <16977.5791.367581.655483@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Apr 04, 2005 at 12:27:43PM +0200, Robert Olsson wrote:
> 
>  The flush transient will happen also on UP... as I understand this 
>  When we have changed the rt_hash_rnd and therefore invalidated all current 
>  entries it would be best to blackhole *all* traffic until all old entries 
>  are deleted this to avoid transients.

That's nasty because if you have a large cache like Eric, then you'll
be dropping packets for quite a while :)

Actually, what's so bad about seeing transients? One cost that
I can see is that you'll be walking a chain only to conclude that
none of the entries might match.  But this is pretty cheap as long as
we keep the chain lengths short.

The other cost is that we might be creating an entry that gets flushed
straight away.  However, that's no worse than not using the cache at
all since in that case we'll be creating one entry for each packet
anyway.

Both of these can be avoided too if we really cared.  All we need
is one bit per chain that indicated whether it's been flushed.  So
when ip_route_* hits a chain that hasn't been flushed, it could

1) Skip the lookup step.
2) Create the rt entry as usual.
3) Flush the chain while we insert the entry and set the bit.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
