From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC] xfrm_alloc_spi always succeeds on non-trivial range
Date: Sat, 31 Jul 2004 12:00:44 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040731020044.GA13830@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Kj7319i9nmIyA2yE"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Kj7319i9nmIyA2yE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

xfrm_alloc_spi will always succeed if minspi < maxspi, even if
minspi + 1 == maxspi.  If the range is already occupied this
will obviously lead to breakage.

Of course this is very unlikely to occur in reality due to the
size of the range.  Although with IPCOMP it might actually happen
on a very large server.

The fix is obivous.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--Kj7319i9nmIyA2yE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/xfrm/xfrm_state.c 1.49 vs edited =====
--- 1.49/net/xfrm/xfrm_state.c	2004-07-30 22:12:11 +10:00
+++ edited/net/xfrm/xfrm_state.c	2004-07-31 11:56:29 +10:00
@@ -624,11 +624,12 @@
 		for (h=0; h<maxspi-minspi+1; h++) {
 			spi = minspi + net_random()%(maxspi-minspi+1);
 			x0 = xfrm_state_lookup(&x->id.daddr, htonl(spi), x->id.proto, x->props.family);
-			if (x0 == NULL)
+			if (x0 == NULL) {
+				x->id.spi = htonl(spi);
 				break;
+			}
 			xfrm_state_put(x0);
 		}
-		x->id.spi = htonl(spi);
 	}
 	if (x->id.spi) {
 		spin_lock_bh(&xfrm_state_lock);

--Kj7319i9nmIyA2yE--
