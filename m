From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.7-rc3: unregister_netdevice: waiting for tun0 to become free. Usage count = 1
Date: Thu, 17 Jun 2004 18:33:03 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617083303.GA8810@gondor.apana.org.au>
References: <20040614015013.GA11048@gondor.apana.org.au> <20040613210725.70dbd016.davem@redhat.com> <20040614042216.GA28669@gondor.apana.org.au> <20040614102858.GA12343@gondor.apana.org.au> <20040614124402.GA28519@gondor.apana.org.au> <20040616193731.GB29781@ms2.inr.ac.ru> <20040616130950.6aadde3c.davem@redhat.com> <20040616203748.GA30675@ms2.inr.ac.ru> <20040616134711.499209c9.davem@redhat.com> <20040617081722.GA8559@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="fUYQa+Pmc3FrFX/N"
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, schwab@suse.de,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040617081722.GA8559@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Jun 17, 2004 at 06:17:22PM +1000, herbert wrote:
> 
> Yes we definitely want this call.  But wouldn't it be better to do one
> call at the top level, say at the end of netdev_wait_allrefs?

Something like should be good enough.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
 
Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/core/dev.c 1.145 vs edited =====
--- 1.145/net/core/dev.c	2004-06-04 15:02:47 +10:00
+++ edited/net/core/dev.c	2004-06-17 18:31:12 +10:00
@@ -3033,6 +3033,12 @@
 
 			netdev_wait_allrefs(dev);
 
+			/* Wait for at least one quiescent state before
+			 * destroying dev.  This ensures users like
+			 * dst->dev are completely finished.
+			 */
+			synchronize_net();
+
 			/* paranoia */
 			BUG_ON(atomic_read(&dev->refcnt));
 			BUG_TRAP(!dev->ip_ptr);
===== net/core/dst.c 1.19 vs edited =====
--- 1.19/net/core/dst.c	2004-06-17 06:42:22 +10:00
+++ edited/net/core/dst.c	2004-06-17 18:31:46 +10:00
@@ -231,12 +231,6 @@
 		if (unregister) {
 			dst->dev = &loopback_dev;
 			dev_hold(&loopback_dev);
-
-			/* Wait for at least one quiescent state after
-			 * detaching the stale device from dst.
-			 */
-			synchronize_kernel();
-
 			dev_put(dev);
 			if (dst->neighbour && dst->neighbour->dev == dev) {
 				dst->neighbour->dev = &loopback_dev;

--fUYQa+Pmc3FrFX/N--
