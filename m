From: David Miller <davem@davemloft.net>
Subject: xfrm_state locking regression...
Date: Tue, 02 Sep 2008 19:51:48 -0700 (PDT)
Message-ID: <20080902.195148.193704236.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43902
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754682AbYICCv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 22:51:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I've been hitting a lockup on my machine, and the way to hit
it is sort of straight forward.

1) Setup IPSEC connection using openswan

2) Use something like XAUTH where openswan is not able refresh the
   IPSEC policy when it times out because it has no way to prompt the
   user for the XAUTH password again.

3) After the timeout, try to send a packet over the IPSEC connection,
   a simple DNS lookup over it works for me.

4) Shut down IPSEC daemon.

At this point with SMP we'll wedge in __xfrm_state_destroy() trying to
obtain xfrm_state_lock.

This problem seems to have been introduced by:

commit 4c563f7669c10a12354b72b518c2287ffc6ebfb3
Author: Timo Teras <timo.teras@iki.fi>
Date:   Thu Feb 28 21:31:08 2008 -0800

    [XFRM]: Speed up xfrm_policy and xfrm_state walking

(BTW, I want to point out how hesitant I was at the time to apply
 this patch.  It touches a lot of delicate areas...)

This is what added the xfrm_state_lock grabbing in __xfrm_state_destroy().

Such new locking cannot work properly, without also updating a lot of
other code in net/xfrm/xfrm_state.c

The new locking means that it is absolutely illegal to do an
xfrm_state_put() while holding xfrm_state_lock.  Yet we do this
all over the place!

Asynchronously another context can drop the count to one, and this
xfrm_state_put() call will thus call into __xfrm_state_destroy() and
try to take xfrm_state_lock (again) causing the deadlock.

I'm not exactly sure how to fix this currently.

I guess we can add a local pointer variable to the relevant functions
"struct xfrm_state *to_put", which is initialized to NULL, and we
replace the put calls with assignments to to_put.  In the "out" path,
after we drop the xfrm_state_lock, we do a put if "to_put" is
non-NULL.

Something like the patch below, but frankly this is some ugly stuff.

I double checked xfrm_policy.c, since it has the potential to have
similar issues due to the above changeset, but it appears to be
OK the best I can tell.

ipsec: Fix deadlock in xfrm_state management.

Ever since commit 4c563f7669c10a12354b72b518c2287ffc6ebfb3
("[XFRM]: Speed up xfrm_policy and xfrm_state walking") it is
illegal to call __xfrm_state_destroy (and thus xfrm_state_put())
with xfrm_state_lock held.  If we do, we'll deadlock since we
have the lock already and __xfrm_state_destroy() tries to take
it again.

Fix this by pushing the xfrm_state_put() calls after the lock
is dropped.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 4c6914e..98f20cc 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -780,11 +780,13 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 {
 	unsigned int h;
 	struct hlist_node *entry;
-	struct xfrm_state *x, *x0;
+	struct xfrm_state *x, *x0, *to_put;
 	int acquire_in_progress = 0;
 	int error = 0;
 	struct xfrm_state *best = NULL;
 
+	to_put = NULL;
+
 	spin_lock_bh(&xfrm_state_lock);
 	h = xfrm_dst_hash(daddr, saddr, tmpl->reqid, family);
 	hlist_for_each_entry(x, entry, xfrm_state_bydst+h, bydst) {
@@ -833,7 +835,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 		if (tmpl->id.spi &&
 		    (x0 = __xfrm_state_lookup(daddr, tmpl->id.spi,
 					      tmpl->id.proto, family)) != NULL) {
-			xfrm_state_put(x0);
+			to_put = x0;
 			error = -EEXIST;
 			goto out;
 		}
@@ -849,7 +851,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 		error = security_xfrm_state_alloc_acquire(x, pol->security, fl->secid);
 		if (error) {
 			x->km.state = XFRM_STATE_DEAD;
-			xfrm_state_put(x);
+			to_put = x;
 			x = NULL;
 			goto out;
 		}
@@ -870,7 +872,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 			xfrm_hash_grow_check(x->bydst.next != NULL);
 		} else {
 			x->km.state = XFRM_STATE_DEAD;
-			xfrm_state_put(x);
+			to_put = x;
 			x = NULL;
 			error = -ESRCH;
 		}
@@ -881,6 +883,8 @@ out:
 	else
 		*err = acquire_in_progress ? -EAGAIN : error;
 	spin_unlock_bh(&xfrm_state_lock);
+	if (to_put)
+		xfrm_state_put(to_put);
 	return x;
 }
 
@@ -1067,18 +1071,20 @@ static struct xfrm_state *__xfrm_find_acq_byseq(u32 seq);
 
 int xfrm_state_add(struct xfrm_state *x)
 {
-	struct xfrm_state *x1;
+	struct xfrm_state *x1, *to_put;
 	int family;
 	int err;
 	int use_spi = xfrm_id_proto_match(x->id.proto, IPSEC_PROTO_ANY);
 
 	family = x->props.family;
 
+	to_put = NULL;
+
 	spin_lock_bh(&xfrm_state_lock);
 
 	x1 = __xfrm_state_locate(x, use_spi, family);
 	if (x1) {
-		xfrm_state_put(x1);
+		to_put = x1;
 		x1 = NULL;
 		err = -EEXIST;
 		goto out;
@@ -1088,7 +1094,7 @@ int xfrm_state_add(struct xfrm_state *x)
 		x1 = __xfrm_find_acq_byseq(x->km.seq);
 		if (x1 && ((x1->id.proto != x->id.proto) ||
 		    xfrm_addr_cmp(&x1->id.daddr, &x->id.daddr, family))) {
-			xfrm_state_put(x1);
+			to_put = x1;
 			x1 = NULL;
 		}
 	}
@@ -1110,6 +1116,9 @@ out:
 		xfrm_state_put(x1);
 	}
 
+	if (to_put)
+		xfrm_state_put(to_put);
+
 	return err;
 }
 EXPORT_SYMBOL(xfrm_state_add);
@@ -1269,10 +1278,12 @@ EXPORT_SYMBOL(xfrm_state_migrate);
 
 int xfrm_state_update(struct xfrm_state *x)
 {
-	struct xfrm_state *x1;
+	struct xfrm_state *x1, *to_put;
 	int err;
 	int use_spi = xfrm_id_proto_match(x->id.proto, IPSEC_PROTO_ANY);
 
+	to_put = NULL;
+
 	spin_lock_bh(&xfrm_state_lock);
 	x1 = __xfrm_state_locate(x, use_spi, x->props.family);
 
@@ -1281,7 +1292,7 @@ int xfrm_state_update(struct xfrm_state *x)
 		goto out;
 
 	if (xfrm_state_kern(x1)) {
-		xfrm_state_put(x1);
+		to_put = x1;
 		err = -EEXIST;
 		goto out;
 	}
@@ -1295,6 +1306,9 @@ int xfrm_state_update(struct xfrm_state *x)
 out:
 	spin_unlock_bh(&xfrm_state_lock);
 
+	if (to_put)
+		xfrm_state_put(to_put);
+
 	if (err)
 		return err;
 
@@ -1483,11 +1497,13 @@ EXPORT_SYMBOL(xfrm_get_acqseq);
 int xfrm_alloc_spi(struct xfrm_state *x, u32 low, u32 high)
 {
 	unsigned int h;
-	struct xfrm_state *x0;
+	struct xfrm_state *x0, *to_put;
 	int err = -ENOENT;
 	__be32 minspi = htonl(low);
 	__be32 maxspi = htonl(high);
 
+	to_put = NULL;
+
 	spin_lock_bh(&x->lock);
 	if (x->km.state == XFRM_STATE_DEAD)
 		goto unlock;
@@ -1501,7 +1517,7 @@ int xfrm_alloc_spi(struct xfrm_state *x, u32 low, u32 high)
 	if (minspi == maxspi) {
 		x0 = xfrm_state_lookup(&x->id.daddr, minspi, x->id.proto, x->props.family);
 		if (x0) {
-			xfrm_state_put(x0);
+			to_put = x0;
 			goto unlock;
 		}
 		x->id.spi = minspi;
@@ -1514,7 +1530,7 @@ int xfrm_alloc_spi(struct xfrm_state *x, u32 low, u32 high)
 				x->id.spi = htonl(spi);
 				break;
 			}
-			xfrm_state_put(x0);
+			to_put = x0;
 		}
 	}
 	if (x->id.spi) {
@@ -1529,6 +1545,9 @@ int xfrm_alloc_spi(struct xfrm_state *x, u32 low, u32 high)
 unlock:
 	spin_unlock_bh(&x->lock);
 
+	if (to_put)
+		xfrm_state_put(to_put);
+
 	return err;
 }
 EXPORT_SYMBOL(xfrm_alloc_spi);
