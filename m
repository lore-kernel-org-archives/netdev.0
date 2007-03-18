From: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Subject: [ofa-general] Re: dst_ifdown breaks infiniband?
Date: Sun, 18 Mar 2007 23:20:46 +0200
Message-ID: <20070318212046.GI11078@mellanox.co.il>
References: <20070318155532.GG7958@mellanox.co.il>
	<20070318191238.GA20518@ms2.inr.ac.ru>
	<20070318203345.GF11078@mellanox.co.il>
	<20070318210616.GG11078@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	general@lists.openfabrics.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <20070318210616.GG11078@mellanox.co.il>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

> Quoting Michael S. Tsirkin <mst@dev.mellanox.co.il>:
> Subject: Re: dst_ifdown breaks infiniband?
> 
> > Quoting Michael S. Tsirkin <mst@dev.mellanox.co.il>:
> > Subject: Re: dst_ifdown breaks infiniband?
> > 
> > Quoting Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>:
> > Subject: Re: dst_ifdown breaks infiniband?
> > > > Can dst->neighbour be changed to point to NULL instead, and the neighbour
> > > > released?
> > > 
> > > It should be cleared and we should be sure it will not be destroyed
> > > before quiescent state.
> > > 
> > > Seems, this is the only correct solution, but to do this we have
> > > to audit all the places where dst->neighbour is dereferenced for
> > > RCU safety.
> > > 
> > > Actually, it is very good you caught this eventually, the bug was
> > > so _disgusting_ that it was "forgotten" all the time, waiting for
> > > someone who will point out that the king is naked. :-)
> > 
> > Actually that might not be too bad:
> > $grep -rIi 'dst->neighbour' net/ | wc -l
> > 36
> > 
> > I'll try to do it.
> 
> Here's the list. Looks OK to me. What do you think?
> 

So Alexey, how does the following (lightly tested) patch look?
Is this what you had in mind?

-----------------------------

Fix dst_ifdown for infiniband.

Changing dst->neighbour->dev is unsafe because neigh->parms callbacks
are set up for specific device.
We should drop the dst->neighbour reference instead.

Signed-off-by: Michael S. Tsirkin <mst@dev.mellanox.co.il>

---

diff --git a/net/core/dst.c b/net/core/dst.c
index 764bccb..27091a5 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -15,6 +15,7 @@
 #include <linux/skbuff.h>
 #include <linux/string.h>
 #include <linux/types.h>
+#include <linux/if_arp.h>
 
 #include <net/dst.h>
 
@@ -235,6 +236,8 @@ again:
 static inline void dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 			      int unregister)
 {
+	struct neighbour *neigh;
+
 	if (dst->ops->ifdown)
 		dst->ops->ifdown(dst, dev, unregister);
 
@@ -245,13 +248,13 @@ static inline void dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 		dst->input = dst_discard_in;
 		dst->output = dst_discard_out;
 	} else {
+		neigh = dst->neighbour;
 		dst->dev = &loopback_dev;
 		dev_hold(&loopback_dev);
 		dev_put(dev);
-		if (dst->neighbour && dst->neighbour->dev == dev) {
-			dst->neighbour->dev = &loopback_dev;
-			dev_put(dev);
-			dev_hold(&loopback_dev);
+		if (neigh && neigh->dev == dev) {
+			dst->neighbour = NULL;
+			neigh_release(neigh);
 		}
 	}
 }


-- 
MST
