From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.7-rc3: unregister_netdevice: waiting for tun0 to become free. Usage count = 1
Date: Mon, 14 Jun 2004 22:44:02 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040614124402.GA28519@gondor.apana.org.au>
References: <20040613121514.6b3c1c8a.davem@redhat.com> <E1BZeW1-0008Ny-00@gondolin.me.apana.org.au> <20040613234142.GA32329@gondor.apana.org.au> <20040613183622.3a814506.davem@redhat.com> <20040614015013.GA11048@gondor.apana.org.au> <20040613210725.70dbd016.davem@redhat.com> <20040614042216.GA28669@gondor.apana.org.au> <20040614102858.GA12343@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="ew6BAiZeqk4r7MaW"
Cc: schwab@suse.de, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org,
        kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040614102858.GA12343@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--ew6BAiZeqk4r7MaW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jun 14, 2004 at 08:28:58PM +1000, herbert wrote:
> On Mon, Jun 14, 2004 at 02:22:16PM +1000, herbert wrote:
> > 
> > 1. The code in dst_dev_event relies on the entries with dev in it
> > getting onto the garbage list before it is called.  Unfortunately
> > for routing entries, the flushing is done asynchronusly so it is
> > entirely possible for the entries to get onto the garbage list after
> > dst_dev_event has been called twice (DOWN and then UNREGISTER).
> 
> Actually this can't happen since fib_netdev_event will do an
> immediate flush.  So it's only #2 or IPsec that's a problem.

And even there it's not too bad as it only happens if there are
more than two IPsec dst's in a row, e.g., ESP/IPCOMP.

Here is a patch to do the same loopback_dev hack for child dst's.
I've also taken the liberty to remove the bogus dst->output check.
I've tested it with ESP/IPCOMP and I can confirm that it allows
me to remove my NIC module if when I've got a TCP connection over
it.  Without it the removal hangs.

Alexey, if I've missed any subtle piece of logic there, please
scream :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--ew6BAiZeqk4r7MaW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/core/dst.c 1.17 vs edited =====
--- 1.17/net/core/dst.c	2004-06-13 03:51:53 +10:00
+++ edited/net/core/dst.c	2004-06-14 22:39:51 +10:00
@@ -210,6 +210,36 @@
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
@@ -221,29 +251,11 @@
 		spin_lock_bh(&dst_lock);
 		for (dst = dst_garbage_list; dst; dst = dst->next) {
 			if (dst->dev == dev) {
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
+				if (event == NETDEV_DOWN) {
 					dst->input = dst_discard_in;
 					dst->output = dst_discard_out;
 				}
-				if (dst->ops->ifdown)
-					dst->ops->ifdown(dst, event != NETDEV_DOWN);
+				dst_ifdown(dst, event != NETDEV_DOWN);
 			}
 		}
 		spin_unlock_bh(&dst_lock);

--ew6BAiZeqk4r7MaW--
