From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: neigh_create/inetdev_destroy race?
Date: Sat, 4 Sep 2004 09:49:41 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040903234941.GA26247@gondor.apana.org.au>
References: <20040815191450.77532d5d.davem@redhat.com> <20040816105131.GA11299@gondor.apana.org.au> <20040828234201.79556f6e.davem@davemloft.net> <20040829065031.GA786@gondor.apana.org.au> <20040830230820.7514985d.davem@davemloft.net> <20040831104139.GA2124@gondor.apana.org.au> <20040901222118.0ce4bcc6.davem@davemloft.net> <20040902130605.GA32570@gondor.apana.org.au> <20040903133623.GA23179@gondor.apana.org.au> <20040903090053.22c67bb9@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="DocE+STaALJfprDB"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040903090053.22c67bb9@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--DocE+STaALJfprDB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Sep 03, 2004 at 09:00:53AM -0700, Stephen Hemminger wrote:
>
> > You'll also notice that I've put all dereferences of dev->*_ptr under
> > the rcu_read_lock().  Without this we may get a neigh_parms that's
> > already been released.
> 
> I haven't looked at the exact code in detail, but don't you need
> use rcu_dereference() as well to make sure and get the smp_read_barrier_depends
> on Alpha.

Not really because we're not depending on *dev->neigh_parms to be set to
NULLon shutdown.  In fact *dev->neigh_parms never gets set to NULL at all.
If it did we'd have trouble cleaning up dead entries from the hash table.

So there is no data-dependent read here whose order must be preserved
when *dev is destroyed.

But hang on a second, I had forgotten about the creation path.  Indeed
that is buggy without a barrier for every path except IPv6.  Without
the barrier, we may be reading NULL pointers from parms which may
result in stale neigh entries lingering around.  Or worse we may read
complete garbage that was there before the memset on *dev was done.
Fortunately the last bit probably can only be triggered if you're
stepping through gdb :)

So here is a patch to make sure that there is a barrier between the
reading of dev->*_ptr and *dev->neigh_parms.

With these barriers in place, it's clear that *dev->neigh_parms can no
longer be NULL since once the parms are allocated, that pointer is never
reset to NULL again.  Therefore I've also removed the parms check in
these paths.

They were bogus to begin with since if they ever triggered then we'll
have dead neigh entries stuck in the hash table.

Unfortunately I couldn't arrange for this to happen with DECnet due
to the dn_db->parms.up() call that's sandwiched between the assignment
of dev->dn_ptr and dn_db->neigh_parms.  So I've kept the parms check
there but it will now fail instead of continuing.  I've also added an
smp_wmb() there so that at least we won't be reading garbage from
dn_db->neigh_parms.

DECnet is also buggy since there is no locking at all in the destruction
path.  It either needs locking or RCU like IPv4.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks a lot,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--DocE+STaALJfprDB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== drivers/s390/net/qeth_main.c 1.14 vs edited =====
--- 1.14/drivers/s390/net/qeth_main.c	2004-09-04 08:22:06 +10:00
+++ edited/drivers/s390/net/qeth_main.c	2004-09-04 09:17:17 +10:00
@@ -6718,17 +6718,15 @@
 	}
 
 	rcu_read_lock();
-	in_dev = __in_dev_get(dev);
+	in_dev = rcu_dereference(__in_dev_get(dev));
 	if (in_dev == NULL) {
 		rcu_read_unlock();
 		return -EINVAL;
 	}
 
 	parms = in_dev->arp_parms;
-	if (parms) {
-		__neigh_parms_put(neigh->parms);
-		neigh->parms = neigh_parms_clone(parms);
-	}
+	__neigh_parms_put(neigh->parms);
+	neigh->parms = neigh_parms_clone(parms);
 	rcu_read_unlock();
 
 	neigh->type = inet_addr_type(*(u32 *) neigh->primary_key);
===== net/atm/clip.c 1.37 vs edited =====
--- 1.37/net/atm/clip.c	2004-09-04 08:22:07 +10:00
+++ edited/net/atm/clip.c	2004-09-04 09:18:22 +10:00
@@ -320,17 +320,15 @@
 	if (neigh->type != RTN_UNICAST) return -EINVAL;
 
 	rcu_read_lock();
-	in_dev = __in_dev_get(dev);
+	in_dev = rcu_dereference(__in_dev_get(dev));
 	if (!in_dev) {
 		rcu_read_unlock();
 		return -EINVAL;
 	}
 
 	parms = in_dev->arp_parms;
-	if (parms) {
-		__neigh_parms_put(neigh->parms);
-		neigh->parms = neigh_parms_clone(parms);
-	}
+	__neigh_parms_put(neigh->parms);
+	neigh->parms = neigh_parms_clone(parms);
 	rcu_read_unlock();
 
 	neigh->ops = &clip_neigh_ops;
===== net/decnet/dn_dev.c 1.25 vs edited =====
--- 1.25/net/decnet/dn_dev.c	2004-09-04 08:22:07 +10:00
+++ edited/net/decnet/dn_dev.c	2004-09-04 09:36:51 +10:00
@@ -41,6 +41,7 @@
 #include <linux/sysctl.h>
 #include <linux/notifier.h>
 #include <asm/uaccess.h>
+#include <asm/system.h>
 #include <net/neighbour.h>
 #include <net/dst.h>
 #include <net/flow.h>
@@ -1108,6 +1109,7 @@
 
 	memset(dn_db, 0, sizeof(struct dn_dev));
 	memcpy(&dn_db->parms, p, sizeof(struct dn_dev_parms));
+	smp_wmb();
 	dev->dn_ptr = dn_db;
 	dn_db->dev = dev;
 	init_timer(&dn_db->timer);
===== net/decnet/dn_neigh.c 1.11 vs edited =====
--- 1.11/net/decnet/dn_neigh.c	2004-09-04 08:22:07 +10:00
+++ edited/net/decnet/dn_neigh.c	2004-09-04 09:33:12 +10:00
@@ -139,17 +139,20 @@
 	struct neigh_parms *parms;
 
 	rcu_read_lock();
-	dn_db = dev->dn_ptr;
+	dn_db = rcu_dereference(dev->dn_ptr);
 	if (dn_db == NULL) {
 		rcu_read_unlock();
 		return -EINVAL;
 	}
 
 	parms = dn_db->neigh_parms;
-	if (parms) {
-		__neigh_parms_put(neigh->parms);
-		neigh->parms = neigh_parms_clone(parms);
+	if (!parms) {
+		rcu_read_unlock();
+		return -EINVAL;
 	}
+
+	__neigh_parms_put(neigh->parms);
+	neigh->parms = neigh_parms_clone(parms);
 	rcu_read_unlock();
 
 	if (dn_db->use_long)
===== net/ipv4/arp.c 1.45 vs edited =====
--- 1.45/net/ipv4/arp.c	2004-09-04 08:22:07 +10:00
+++ edited/net/ipv4/arp.c	2004-09-04 09:17:46 +10:00
@@ -244,17 +244,15 @@
 	neigh->type = inet_addr_type(addr);
 
 	rcu_read_lock();
-	in_dev = __in_dev_get(dev);
+	in_dev = rcu_dereference(__in_dev_get(dev));
 	if (in_dev == NULL) {
 		rcu_read_unlock();
 		return -EINVAL;
 	}
 
 	parms = in_dev->arp_parms;
-	if (parms) {
-		__neigh_parms_put(neigh->parms);
-		neigh->parms = neigh_parms_clone(parms);
-	}
+	__neigh_parms_put(neigh->parms);
+	neigh->parms = neigh_parms_clone(parms);
 	rcu_read_unlock();
 
 	if (dev->hard_header == NULL) {
===== net/ipv6/ndisc.c 1.88 vs edited =====
--- 1.88/net/ipv6/ndisc.c	2004-09-04 08:22:07 +10:00
+++ edited/net/ipv6/ndisc.c	2004-09-04 09:28:12 +10:00
@@ -297,10 +297,8 @@
 	}
 
 	parms = in6_dev->nd_parms;
-	if (parms) {
-		__neigh_parms_put(neigh->parms);
-		neigh->parms = neigh_parms_clone(parms);
-	}
+	__neigh_parms_put(neigh->parms);
+	neigh->parms = neigh_parms_clone(parms);
 	rcu_read_unlock();
 
 	neigh->type = is_multicast ? RTN_MULTICAST : RTN_UNICAST;

--DocE+STaALJfprDB--
