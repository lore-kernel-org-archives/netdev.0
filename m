From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPv4] Check PAGE_SIZE in fz_hash_alloc
Date: Wed, 22 Sep 2004 13:57:10 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922035710.GA17249@gondor.apana.org.au>
References: <20040918203319.24004d6e.davem@davemloft.net> <1095645106.1048.190.camel@jzny.localdomain> <20040919195351.0b3560e6.davem@davemloft.net> <1095686672.1049.301.camel@jzny.localdomain> <20040920121123.70baf895.davem@davemloft.net> <20040921034212.GA28462@gondor.apana.org.au> <20040920231805.3f18479c.davem@davemloft.net> <20040922020729.GA14062@gondor.apana.org.au> <20040921193234.1c5b09a1.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="DocE+STaALJfprDB"
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040921193234.1c5b09a1.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--DocE+STaALJfprDB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Sep 21, 2004 at 07:32:34PM -0700, David S. Miller wrote:
> 
> I'll apply this, thanks Herbert.

Thanks.

Here is a minor optimisation to fz_hash_alloc.  The break-even point
should be based on PAGE_SIZE rather than the value of divisor.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--DocE+STaALJfprDB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/fib_hash.c 1.21 vs edited =====
--- 1.21/net/ipv4/fib_hash.c	2004-09-22 06:35:25 +10:00
+++ edited/net/ipv4/fib_hash.c	2004-09-22 13:05:41 +10:00
@@ -109,7 +109,7 @@
 {
 	unsigned long size = divisor * sizeof(struct hlist_head);
 
-	if (divisor <= 1024) {
+	if (size <= PAGE_SIZE) {
 		return kmalloc(size, GFP_KERNEL);
 	} else {
 		return (struct hlist_head *)
@@ -141,11 +141,12 @@
 
 static void fz_hash_free(struct hlist_head *hash, int divisor)
 {
-	if (divisor <= 1024)
+	unsigned long size = divisor * sizeof(struct hlist_head);
+
+	if (size <= PAGE_SIZE)
 		kfree(hash);
 	else
-		free_pages((unsigned long) hash,
-			   get_order(divisor * sizeof(struct hlist_head)));
+		free_pages((unsigned long)hash, get_order(size));
 }
 
 static void fn_rehash_zone(struct fn_zone *fz)

--DocE+STaALJfprDB--
