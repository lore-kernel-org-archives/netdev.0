From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] rtnl: Simplify ASSERT_RTNL
Date: Tue, 2 Oct 2007 17:28:19 +0800
Message-ID: <20071002092819.GA29824@gondor.apana.org.au>
References: <E1IbTz0-0000FK-00@gondolin.me.apana.org.au>
	<46FE7019.4030705@trash.net>
	<20070930002421.GA7502@gondor.apana.org.au>
	<46FFC512.9060101@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oliver@neukum.name,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	linux-usb-devel@lists.sourceforge.net, davem@davemloft.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-usb-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <46FFC512.9060101@trash.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-usb-devel>
List-Post: <mailto:linux-usb-devel@lists.sourceforge.net>
List-Help: <mailto:linux-usb-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: linux-usb-devel-bounces@lists.sourceforge.net
Errors-To: linux-usb-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Sun, Sep 30, 2007 at 05:47:30PM +0200, Patrick McHardy wrote:
>
> In the IPv6 case we're only changing the multicast list,
> so we're never calling into __dev_set_promiscuity.
> 
> I actually even added a comment about this :)
> 
>         /* Unicast addresses changes may only happen under the rtnl,
>          * therefore calling __dev_set_promiscuity here is safe.
>          */

Good point.  I should stop mentally blocking out comments when
I read code :)

I'm a bit uncomfortable with having a function (change_flags)
that's sometimes in a sleepable context and sometimes running
with BH disabled.

So how about splitting up the unicast/multicast entry points
as follows?

[NET]: Restore multicast-only __dev_mc_upload

As it is dev_set_rx_mode needs to cope with being called with
or without the RTNL.  This is rather confusing when it comes
to understanding what locks are being held at a particular
point.

Since the only path that calls it without the RTNL is in the
multicast code, we could avoid the confusion by splitting that
out.

This patch restores the old __dev_mc_upload as a multicast-only
variant of dev_set_rx_mode.  It also gets rid of the now-unused
__dev_set_rx_mod and makes dev_set_rx_mode static since it's
only used in net/core/dev.c.

As a side-effect this fixes the warning triggered by the
RTNL_ASSERT in __dev_set_promiscuity.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 91cd3f3..e9a579e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1356,8 +1356,6 @@ extern struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 extern int		register_netdev(struct net_device *dev);
 extern void		unregister_netdev(struct net_device *dev);
 /* Functions used for secondary unicast and multicast support */
-extern void		dev_set_rx_mode(struct net_device *dev);
-extern void		__dev_set_rx_mode(struct net_device *dev);
 extern int		dev_unicast_delete(struct net_device *dev, void *addr, int alen);
 extern int		dev_unicast_add(struct net_device *dev, void *addr, int alen);
 extern int 		dev_mc_delete(struct net_device *dev, void *addr, int alen, int all);
diff --git a/net/core/dev.c b/net/core/dev.c
index 833f060..4cf985f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -967,6 +967,8 @@ void dev_load(struct net *net, const char *name)
 		request_module("%s", name);
 }
 
+static void dev_set_rx_mode(struct net_device *dev);
+
 /**
  *	dev_open	- prepare an interface for use.
  *	@dev:	device to open
@@ -2775,7 +2777,7 @@ void dev_set_allmulti(struct net_device *dev, int inc)
  *	filtering it is put in promiscous mode while unicast addresses
  *	are present.
  */
-void __dev_set_rx_mode(struct net_device *dev)
+static void dev_set_rx_mode(struct net_device *dev)
 {
 	/* dev_open will call this function so the list will stay sane. */
 	if (!(dev->flags&IFF_UP))
@@ -2784,9 +2786,11 @@ void __dev_set_rx_mode(struct net_device *dev)
 	if (!netif_device_present(dev))
 		return;
 
-	if (dev->set_rx_mode)
+	if (dev->set_rx_mode) {
+		netif_tx_lock_bh(dev);
 		dev->set_rx_mode(dev);
-	else {
+		netif_tx_unlock_bh(dev);
+	} else {
 		/* Unicast addresses changes may only happen under the rtnl,
 		 * therefore calling __dev_set_promiscuity here is safe.
 		 */
@@ -2798,18 +2802,14 @@ void __dev_set_rx_mode(struct net_device *dev)
 			dev->uc_promisc = 0;
 		}
 
-		if (dev->set_multicast_list)
+		if (dev->set_multicast_list) {
+			netif_tx_lock_bh(dev);
 			dev->set_multicast_list(dev);
+			netif_tx_unlock_bh(dev);
+		}
 	}
 }
 
-void dev_set_rx_mode(struct net_device *dev)
-{
-	netif_tx_lock_bh(dev);
-	__dev_set_rx_mode(dev);
-	netif_tx_unlock_bh(dev);
-}
-
 int __dev_addr_delete(struct dev_addr_list **list, int *count,
 		      void *addr, int alen, int glbl)
 {
@@ -2885,11 +2885,9 @@ int dev_unicast_delete(struct net_device *dev, void *addr, int alen)
 
 	ASSERT_RTNL();
 
-	netif_tx_lock_bh(dev);
 	err = __dev_addr_delete(&dev->uc_list, &dev->uc_count, addr, alen, 0);
 	if (!err)
-		__dev_set_rx_mode(dev);
-	netif_tx_unlock_bh(dev);
+		dev_set_rx_mode(dev);
 	return err;
 }
 EXPORT_SYMBOL(dev_unicast_delete);
@@ -2911,11 +2909,9 @@ int dev_unicast_add(struct net_device *dev, void *addr, int alen)
 
 	ASSERT_RTNL();
 
-	netif_tx_lock_bh(dev);
 	err = __dev_addr_add(&dev->uc_list, &dev->uc_count, addr, alen, 0);
 	if (!err)
-		__dev_set_rx_mode(dev);
-	netif_tx_unlock_bh(dev);
+		dev_set_rx_mode(dev);
 	return err;
 }
 EXPORT_SYMBOL(dev_unicast_add);
diff --git a/net/core/dev_mcast.c b/net/core/dev_mcast.c
index 896b0ca..be987d5 100644
--- a/net/core/dev_mcast.c
+++ b/net/core/dev_mcast.c
@@ -65,6 +65,30 @@
  */
 
 /*
+ *     Update the multicast list into the physical NIC controller.
+ */
+
+static void __dev_mc_upload(struct net_device *dev)
+{
+	/* Don't do anything till we up the interface
+	 * [dev_open will do this too so the list will
+	 * stay sane]
+	 */
+
+	if (!(dev->flags & IFF_UP))
+		return;
+
+	/* Devices with which have been detached don't get set. */
+	if (!netif_device_present(dev))
+		return;
+
+	if (dev->set_rx_mode)
+		dev->set_rx_mode(dev);
+	else if (dev->set_multicast_list)
+		dev->set_multicast_list(dev);
+}
+
+/*
  *	Delete a device level multicast
  */
 
@@ -81,7 +105,7 @@ int dev_mc_delete(struct net_device *dev, void *addr, int alen, int glbl)
 		 *	loaded filter is now wrong. Fix it
 		 */
 
-		__dev_set_rx_mode(dev);
+		__dev_mc_upload(dev);
 	}
 	netif_tx_unlock_bh(dev);
 	return err;
@@ -98,7 +122,7 @@ int dev_mc_add(struct net_device *dev, void *addr, int alen, int glbl)
 	netif_tx_lock_bh(dev);
 	err = __dev_addr_add(&dev->mc_list, &dev->mc_count, addr, alen, glbl);
 	if (!err)
-		__dev_set_rx_mode(dev);
+		__dev_mc_upload(dev);
 	netif_tx_unlock_bh(dev);
 	return err;
 }
@@ -140,7 +164,7 @@ int dev_mc_sync(struct net_device *to, struct net_device *from)
 		da = next;
 	}
 	if (!err)
-		__dev_set_rx_mode(to);
+		__dev_mc_upload(to);
 	netif_tx_unlock_bh(to);
 
 	return err;
@@ -177,7 +201,7 @@ void dev_mc_unsync(struct net_device *to, struct net_device *from)
 				  da->da_addr, da->da_addrlen, 0);
 		da = next;
 	}
-	__dev_set_rx_mode(to);
+	__dev_mc_upload(to);
 
 	netif_tx_unlock_bh(to);
 	netif_tx_unlock_bh(from);

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
linux-usb-devel@lists.sourceforge.net
To unsubscribe, use the last form field at:
https://lists.sourceforge.net/lists/listinfo/linux-usb-devel
