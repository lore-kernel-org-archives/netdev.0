From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Clean up fib_hash datastructures
Date: 20 Sep 2004 09:33:17 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095687197.1048.310.camel@jzny.localdomain>
References: <1095640781.1047.168.camel@jzny.localdomain>
	 <E1C9Edi-00033O-00@gondolin.me.apana.org.au>
	 <20040919201735.3d9e1d6d.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-lVFenb7vPWL3xlal4mf9"
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040919201735.3d9e1d6d.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-lVFenb7vPWL3xlal4mf9
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sun, 2004-09-19 at 23:17, David S. Miller wrote:
> On Mon, 20 Sep 2004 13:14:54 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > jamal <hadi@cyberus.ca> wrote:
> > > 
> > > --- a/net/ipv4/fib_hash.c       2004/09/20 00:35:16     1.1
> > > +++ b/net/ipv4/fib_hash.c       2004/09/20 00:36:16
> > > @@ -915,7 +915,7 @@
> > >             iter->zone = iter->zone->fz_next) {
> > >                int maxslot;
> > > 
> > > -               if (!iter->zone->fz_next)
> > > +               if (!iter->zone->fz_nent)
> > >                        continue;
> > 
> > Good catch.  There seems to be another problem with the seq_file
> > conversion.  Why is this check only in fib_get_first(), but not
> > in fib_get_next()?
> > 
> > Either it's needed in fib_get_next() as well, or it can be removed here.
> 
> It's an optimization, the hash list traversal will find no entries
> even if we don't do this test.
> 
> It does belong in fib_get_next(), so I'll happily add it there.
> Thanks.

Seems like get_first just populates the fib_iter_state with the first
valid entry and fib_get_next gets the next valid one - Sorry never paid
attention when patches for these were going in. 
In which case the check for zero entries is missing from fib_get_next
making it ineeficient (but not buggy).
A more complete patch (untested, uncompiled) attached.

cheers,
jamal


--=-lVFenb7vPWL3xlal4mf9
Content-Disposition: attachment; filename=fibhash_p_2
Content-Type: text/plain; name=fibhash_p_2; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- a/net/ipv4/fib_hash.c	2004/09/20 00:35:16	1.1
+++ b/net/ipv4/fib_hash.c	2004/09/20 13:30:56
@@ -915,7 +915,7 @@
 	     iter->zone = iter->zone->fz_next) {
 		int maxslot;
 
-		if (!iter->zone->fz_next)
+		if (!iter->zone->fz_nent)
 			continue;
 
 		iter->hash = iter->zone->fz_hash;
@@ -958,10 +958,13 @@
 				goto out;
 		}
 
+get_next_zone:
 		iter->zone = iter->zone->fz_next;
 
 		if (!iter->zone)
 			goto out;
+		if (!iter->zone->fz_nent)
+			goto get_next_zone;
 		
 		iter->hash = iter->zone->fz_hash;
 		iter->bucket = 0;

--=-lVFenb7vPWL3xlal4mf9--
