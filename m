From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NET] Add barriers for dst refcnt
Date: Fri, 4 Feb 2005 18:33:11 +1100
Message-ID: <20050204073311.GA11716@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="OgqxwSJOaUobr8KG"
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--OgqxwSJOaUobr8KG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

In light of the recent discussion about sk_buff, I think we need
the following patch for dst_entry.  This adds a memory barrier
before dst_release drops the refcnt, and a read memory barrier
before dst_destroy starts destroying the entry.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--OgqxwSJOaUobr8KG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== include/net/dst.h 1.24 vs edited =====
--- 1.24/include/net/dst.h	2004-10-26 09:10:25 +10:00
+++ edited/include/net/dst.h	2005-02-04 18:24:46 +11:00
@@ -147,6 +147,7 @@
 {
 	if (dst) {
 		WARN_ON(atomic_read(&dst->__refcnt) < 1);
+		smp_mb__before_atomic_dec();
 		atomic_dec(&dst->__refcnt);
 	}
 }
===== net/core/dst.c 1.25 vs edited =====
--- 1.25/net/core/dst.c	2005-01-14 15:41:04 +11:00
+++ edited/net/core/dst.c	2005-02-04 18:26:06 +11:00
@@ -169,6 +169,8 @@
 	struct neighbour *neigh;
 	struct hh_cache *hh;
 
+	smp_rmb();
+
 again:
 	neigh = dst->neighbour;
 	hh = dst->hh;

--OgqxwSJOaUobr8KG--
