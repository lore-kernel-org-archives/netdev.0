From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [6/6]: jenkins hash for neigh
Date: Sat, 2 Oct 2004 17:50:51 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041002075051.GA18037@gondor.apana.org.au>
References: <20040925005623.2faf8faf.davem@davemloft.net> <E1CBtzd-0000zI-00@gondolin.me.apana.org.au> <20040927111520.4f495b17.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="PNTmBPCT7hxwcZjr"
Cc: laforge@gnumonks.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040927111520.4f495b17.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--PNTmBPCT7hxwcZjr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Sep 27, 2004 at 11:15:20AM -0700, David S. Miller wrote:
> On Mon, 27 Sep 2004 21:48:33 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > > -	if (tbl->entries > (tbl->hash_mask + 1))
> > > +	if (tbl->entries > (tbl->hash_mask + 1)) {
> > > +		write_lock_bh(&tbl->lock);
> > >  		neigh_hash_grow(tbl, (tbl->hash_mask + 1) << 1);
> > > +		write_unlock_bh(&tbl->lock);
> > > +	}
> > 
> > The locking should be outside the if block as otherwise you may grow
> > unnecessarily or grow into the same size :)
> 
> I'm not going to do that, because then we're grabbing that lock
> twice on every neigh create operation and I was trying hard
> to avoid that overhead.

Actually, why don't we just move the expansion into the locked section?

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--PNTmBPCT7hxwcZjr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/core/neighbour.c 1.51 vs edited =====
--- 1.51/net/core/neighbour.c	2004-10-02 07:58:21 +10:00
+++ edited/net/core/neighbour.c	2004-10-02 17:47:11 +10:00
@@ -406,12 +406,6 @@
 		goto out;
 	}
 
-	if (tbl->entries > (tbl->hash_mask + 1)) {
-		write_lock_bh(&tbl->lock);
-		neigh_hash_grow(tbl, (tbl->hash_mask + 1) << 1);
-		write_unlock_bh(&tbl->lock);
-	}
-
 	memcpy(n->primary_key, pkey, key_len);
 	n->dev = dev;
 	dev_hold(dev);
@@ -432,6 +426,9 @@
 	n->confirmed = jiffies - (n->parms->base_reachable_time << 1);
 
 	write_lock_bh(&tbl->lock);
+
+	if (tbl->entries > (tbl->hash_mask + 1)) {
+		neigh_hash_grow(tbl, (tbl->hash_mask + 1) << 1);
 
 	hash_val = tbl->hash(pkey, dev) & tbl->hash_mask;
 

--PNTmBPCT7hxwcZjr--
