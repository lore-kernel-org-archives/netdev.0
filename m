From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC] Remove redundant check in xfrm_state_add()
Date: Fri, 30 Jul 2004 22:10:56 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040730121056.GA5911@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="y0ulUmNC+osPPQO6"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

This is the patch referred to in the netlink_get_spi thread.

I was actually wrong about the reason for this patch though.  Firstly
it's the SPI check that is redundant and not the find_acq() call.
And it's redundant because of the find_acq() patch, not because
of the fact that this is in xfrm_state_add().

Now that find_acq() only returns SAs with SPIs, we don't need to
check this in xfrm_state_add() anymore.

We do still need the call though to clean up leftover larval states.

Another side-effect of the change is that we can move the existence
check above find_acq() since find_acq() will never return any SAs
matching the SPI we're trying to add (It doesn't need to because if
an SA with a matching SPI existed, it would've been returned by
state_lookup() already).

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/xfrm/xfrm_state.c 1.48 vs edited =====
--- 1.48/net/xfrm/xfrm_state.c	2004-07-30 21:16:40 +10:00
+++ edited/net/xfrm/xfrm_state.c	2004-07-30 22:07:01 +10:00
@@ -400,22 +400,16 @@
 	spin_lock_bh(&xfrm_state_lock);
 
 	x1 = afinfo->state_lookup(&x->id.daddr, x->id.spi, x->id.proto);
-	if (!x1) {
-		x1 = afinfo->find_acq(
-			x->props.mode, x->props.reqid, x->id.proto,
-			&x->id.daddr, &x->props.saddr, 0);
-		if (x1 && x1->id.spi != x->id.spi && x1->id.spi) {
-			xfrm_state_put(x1);
-			x1 = NULL;
-		}
-	}
-
-	if (x1 && x1->id.spi) {
+	if (x1) {
 		xfrm_state_put(x1);
 		x1 = NULL;
 		err = -EEXIST;
 		goto out;
 	}
+
+	x1 = afinfo->find_acq(
+		x->props.mode, x->props.reqid, x->id.proto,
+		&x->id.daddr, &x->props.saddr, 0);
 
 	__xfrm_state_insert(x);
 	err = 0;

--y0ulUmNC+osPPQO6--
