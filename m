From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM] Handle device down/unregister events
Date: Thu, 27 Nov 2003 21:59:07 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031127105907.GA13047@gondor.apana.org.au>
References: <20031126044355.GA18805@gondor.apana.org.au> <20031125222059.6730f242.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Qxx1br4bt0+wmkIi"
Cc: kuznet@ms2.inr.ac.ru, jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031125222059.6730f242.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Qxx1br4bt0+wmkIi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Nov 25, 2003 at 10:20:59PM -0800, David S. Miller wrote:
> 
> Thanks for catching this, I'll review and apply your patch soon.

Hmm, it looks like my patch has a slight race in it.  It is possible
for a device to be added to a dst, go down and unregister, and then
the dst is added to a bundle.

This isn't really a problem for net devices without destructors though
since the UNREGISTER event is rebroadcast at regular intervals.

However, it also affects xfrm_flush_bundle() and xfrm states don't
enjoy the benefit of repeated flushes.

Here is an updated patch that checks whether a dst is still valid
before adding it to a bundle.

Cheers,
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--Qxx1br4bt0+wmkIi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

Index: kernel-source-2.5/include/net/xfrm.h
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/include/net/xfrm.h,v
retrieving revision 1.17
diff -u -r1.17 xfrm.h
--- kernel-source-2.5/include/net/xfrm.h	18 Oct 2003 10:52:14 -0000	1.17
+++ kernel-source-2.5/include/net/xfrm.h	27 Nov 2003 10:32:15 -0000
@@ -860,7 +860,7 @@
 extern void xfrm_policy_kill(struct xfrm_policy *);
 extern int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol);
 extern struct xfrm_policy *xfrm_sk_policy_lookup(struct sock *sk, int dir, struct flowi *fl);
-extern int xfrm_flush_bundles(struct xfrm_state *x);
+extern int xfrm_flush_bundles(void);
 
 extern wait_queue_head_t km_waitq;
 extern void km_state_expired(struct xfrm_state *x, int hard);
Index: kernel-source-2.5/net/xfrm/xfrm_policy.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/net/xfrm/xfrm_policy.c,v
retrieving revision 1.30
diff -u -r1.30 xfrm_policy.c
--- kernel-source-2.5/net/xfrm/xfrm_policy.c	28 Oct 2003 09:58:40 -0000	1.30
+++ kernel-source-2.5/net/xfrm/xfrm_policy.c	27 Nov 2003 10:47:29 -0000
@@ -19,6 +19,8 @@
 #include <linux/list.h>
 #include <linux/spinlock.h>
 #include <linux/workqueue.h>
+#include <linux/notifier.h>
+#include <linux/netdevice.h>
 #include <net/xfrm.h>
 #include <net/ip.h>
 
@@ -695,6 +697,8 @@
 	};
 }
 
+static int stale_bundle(struct dst_entry *dst);
+
 /* Main function: finds/creates a bundle for given flow.
  *
  * At the moment we eat a raw IP route. Mostly to speed up lookups
@@ -819,10 +823,11 @@
 		}
 
 		write_lock_bh(&policy->lock);
-		if (unlikely(policy->dead)) {
+		if (unlikely(policy->dead || stale_bundle(dst))) {
 			/* Wow! While we worked on resolving, this
 			 * policy has gone. Retry. It is not paranoia,
 			 * we just cannot enlist new bundle to dead object.
+			 * We can't enlist stable bundles either.
 			 */
 			write_unlock_bh(&policy->lock);
 
@@ -990,18 +995,27 @@
 
 static struct dst_entry *xfrm_dst_check(struct dst_entry *dst, u32 cookie)
 {
+	if (!stale_bundle(dst))
+		return dst;
+
+	dst_release(dst);
+	return NULL;
+}
+
+static int stale_bundle(struct dst_entry *dst)
+{
 	struct dst_entry *child = dst;
 
 	while (child) {
 		if (child->obsolete > 0 ||
+		    (child->dev && !netif_running(child->dev)) ||
 		    (child->xfrm && child->xfrm->km.state != XFRM_STATE_VALID)) {
-			dst_release(dst);
-			return NULL;
+			return 1;
 		}
 		child = child->child;
 	}
 
-	return dst;
+	return 0;
 }
 
 static void xfrm_dst_destroy(struct dst_entry *dst)
@@ -1027,7 +1041,7 @@
 	return dst;
 }
 
-static void __xfrm_garbage_collect(void)
+static void xfrm_prune_bundles(int (*func)(struct dst_entry *))
 {
 	int i;
 	struct xfrm_policy *pol;
@@ -1039,7 +1053,7 @@
 			write_lock(&pol->lock);
 			dstp = &pol->bundles;
 			while ((dst=*dstp) != NULL) {
-				if (atomic_read(&dst->__refcnt) == 0) {
+				if (func(dst)) {
 					*dstp = dst->next;
 					dst->next = gc_list;
 					gc_list = dst;
@@ -1059,46 +1073,19 @@
 	}
 }
 
-static int bundle_depends_on(struct dst_entry *dst, struct xfrm_state *x)
+static int unused_bundle(struct dst_entry *dst)
 {
-	do {
-		if (dst->xfrm == x)
-			return 1;
-	} while ((dst = dst->child) != NULL);
-	return 0;
+	return !atomic_read(&dst->__refcnt);
 }
 
-int xfrm_flush_bundles(struct xfrm_state *x)
+static void __xfrm_garbage_collect(void)
 {
-	int i;
-	struct xfrm_policy *pol;
-	struct dst_entry *dst, **dstp, *gc_list = NULL;
-
-	read_lock_bh(&xfrm_policy_lock);
-	for (i=0; i<2*XFRM_POLICY_MAX; i++) {
-		for (pol = xfrm_policy_list[i]; pol; pol = pol->next) {
-			write_lock(&pol->lock);
-			dstp = &pol->bundles;
-			while ((dst=*dstp) != NULL) {
-				if (bundle_depends_on(dst, x)) {
-					*dstp = dst->next;
-					dst->next = gc_list;
-					gc_list = dst;
-				} else {
-					dstp = &dst->next;
-				}
-			}
-			write_unlock(&pol->lock);
-		}
-	}
-	read_unlock_bh(&xfrm_policy_lock);
-
-	while (gc_list) {
-		dst = gc_list;
-		gc_list = dst->next;
-		dst_free(dst);
-	}
+	xfrm_prune_bundles(unused_bundle);
+}
 
+int xfrm_flush_bundles(void)
+{
+	xfrm_prune_bundles(stale_bundle);
 	return 0;
 }
 
@@ -1221,6 +1208,21 @@
 	read_unlock(&afinfo->lock);
 }
 
+static int xfrm_dev_event(struct notifier_block *this, unsigned long event, void *ptr)
+{
+	switch (event) {
+	case NETDEV_DOWN:
+		xfrm_flush_bundles();
+	}
+	return NOTIFY_DONE;
+}
+
+struct notifier_block xfrm_dev_notifier = {
+	xfrm_dev_event,
+	NULL,
+	0
+};
+
 void __init xfrm_policy_init(void)
 {
 	xfrm_dst_cache = kmem_cache_create("xfrm_dst_cache",
@@ -1231,6 +1233,7 @@
 		panic("XFRM: failed to allocate xfrm_dst_cache\n");
 
 	INIT_WORK(&xfrm_policy_gc_work, xfrm_policy_gc_task, NULL);
+	register_netdevice_notifier(&xfrm_dev_notifier);
 }
 
 void __init xfrm_init(void)
Index: kernel-source-2.5/net/xfrm/xfrm_state.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/net/xfrm/xfrm_state.c,v
retrieving revision 1.11
diff -u -r1.11 xfrm_state.c
--- kernel-source-2.5/net/xfrm/xfrm_state.c	28 Oct 2003 09:58:40 -0000	1.11
+++ kernel-source-2.5/net/xfrm/xfrm_state.c	27 Nov 2003 10:32:01 -0000
@@ -219,7 +219,7 @@
 		 * there are DSTs attached to this xfrm_state.
 		 */
 		if (atomic_read(&x->refcnt) > 2)
-			xfrm_flush_bundles(x);
+			xfrm_flush_bundles();
 
 		/* All xfrm_state objects are created by one of two possible
 		 * paths:

--Qxx1br4bt0+wmkIi--
