From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NET] Clear dev refs in dst->child
Date: Wed, 16 Jun 2004 21:22:11 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040616112211.GA956@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="CE+1k2dSO48ffgeK"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

This is a resend of an earlier patch to dst_dev_event.  I've changed
it slightly by moving the input/output assignment into dst_ifdown.

To recap, this patch drops lingering IPsec references to a device that
is being unregistered.  The child processing in the GC is too late
since it never runs until the reference on the dst hits zero which
could take a long time for things like TCP connections.

The reason I've left the input/output assignment outside the loop is
because they aren't really necessary for the IPsec dst's, and if
it were in the loop then we'll have to do the same child processing
in ___dst_free as well.

I've tested this with an ESP/IPCOMP tunnel and I can confirm that it
does fix the problem.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/core/dst.c 1.17 vs edited =====
--- 1.17/net/core/dst.c	2004-06-13 03:51:53 +10:00
+++ edited/net/core/dst.c	2004-06-16 21:14:18 +10:00
@@ -210,6 +210,41 @@
 	return NULL;
 }
 
+/* Dirty hack. We did it in 2.2 (in __dst_free),
+ * we have _very_ good reasons not to repeat
+ * this mistake in 2.3, but we have no choice
+ * now. _It_ _is_ _explicit_ _deliberate_
+ * _race_ _condition_.
+ *
+ * Commented and originally written by Alexey.
+ */
+static void dst_ifdown(struct dst_entry *dst, int unregister)
+{
+	struct net_device *dev = dst->dev;
+
+	if (!unregister) {
+		dst->input = dst_discard_in;
+		dst->output = dst_discard_out;
+	}
+
+	do {
+		if (unregister) {
+			dst->dev = &loopback_dev;
+			dev_hold(&loopback_dev);
+			dev_put(dev);
+			if (dst->neighbour && dst->neighbour->dev == dev) {
+				dst->neighbour->dev = &loopback_dev;
+				dev_put(dev);
+				dev_hold(&loopback_dev);
+			}
+		}
+
+		if (dst->ops->ifdown)
+			dst->ops->ifdown(dst, unregister);
+	} while ((dst = dst->child) && dst->flags & DST_NOHASH &&
+		 dst->dev == dev);
+}
+
 static int dst_dev_event(struct notifier_block *this, unsigned long event, void *ptr)
 {
 	struct net_device *dev = ptr;
@@ -220,31 +255,8 @@
 	case NETDEV_DOWN:
 		spin_lock_bh(&dst_lock);
 		for (dst = dst_garbage_list; dst; dst = dst->next) {
-			if (dst->dev == dev) {
-				/* Dirty hack. We did it in 2.2 (in __dst_free),
-				   we have _very_ good reasons not to repeat
-				   this mistake in 2.3, but we have no choice
-				   now. _It_ _is_ _explicit_ _deliberate_
-				   _race_ _condition_.
-				 */
-				if (event!=NETDEV_DOWN &&
-				    dst->output == dst_discard_out) {
-					dst->dev = &loopback_dev;
-					dev_hold(&loopback_dev);
-					dev_put(dev);
-					dst->output = dst_discard_out;
-					if (dst->neighbour && dst->neighbour->dev == dev) {
-						dst->neighbour->dev = &loopback_dev;
-						dev_put(dev);
-						dev_hold(&loopback_dev);
-					}
-				} else {
-					dst->input = dst_discard_in;
-					dst->output = dst_discard_out;
-				}
-				if (dst->ops->ifdown)
-					dst->ops->ifdown(dst, event != NETDEV_DOWN);
-			}
+			if (dst->dev == dev)
+				dst_ifdown(dst, event != NETDEV_DOWN);
 		}
 		spin_unlock_bh(&dst_lock);
 		break;

--CE+1k2dSO48ffgeK--
