From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: RE: [PATCH] NET: ASSERT_RTNL in __dev_set_promiscuity makes debug warning
Date: Wed, 5 Dec 2007 14:30:10 +0900
Message-ID: <006001c836ff$f0d59a30$9c94fea9@jason>
References: <000001c8365a$e0e500c0$9c94fea9@jason> <E1IzgPL-0006HB-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"'David Miller'" <davem@davemloft.net>
To: "'Herbert Xu'" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:6403 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954AbXLEFax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 00:30:53 -0500
Received: by wa-out-1112.google.com with SMTP id v27so6808260wah
        for <netdev@vger.kernel.org>; Tue, 04 Dec 2007 21:30:52 -0800 (PST)
In-Reply-To: <E1IzgPL-0006HB-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2007/12/5, Herbert Xu <herbert@gondor.apana.org.au>:
> Joonwoo Park <joonwpark81@gmail.com> wrote:
> > Hi,
> > dev_set_rx_mode calls __dev_set_rx_mode with softirq disabled (by netif_tx_lock_bh)
> > therefore __dev_set_promiscuity can be called with softirq disabled.
> > It will cause in_interrupt() to return true and ASSERT_RTNL warning.
> > Is there a good solution to fix it besides blowing ASSERT_RTNL up?
> 
> We've talked this one before on netdev.  It's on my todo list to fix.
> The correct solution is to untangle this so that __dev_set_promiscuity
> does not get called in the first place on BH paths.
> 
> Unfortunately I've been busy so I haven't completed the patches yet.
> But as this problem is not urgent let's not just put on a bandaid.
> 

Thanks Herbert,
According to your opinion I tried a patch against davem/net-2.6.git

Thanks.
Joonwoo


[NET]: Fix to __dev_set_promiscuity does not get called with softirq is disabled

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 include/linux/netdevice.h |    3 +-
 net/core/dev.c            |   57 +++++++++++++++++++++++++++++---------------
 net/core/dev_mcast.c      |   21 +++++++++++++---
 3 files changed, 56 insertions(+), 25 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1e6af4f..6532405 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1403,7 +1403,8 @@ extern int		register_netdev(struct net_device *dev);
 extern void		unregister_netdev(struct net_device *dev);
 /* Functions used for secondary unicast and multicast support */
 extern void		dev_set_rx_mode(struct net_device *dev);
-extern void		__dev_set_rx_mode(struct net_device *dev);
+extern int		__dev_set_rx_mode(struct net_device *dev);
+extern void		__dev_set_rx_mode_fini(struct net_device *dev);
 extern int		dev_unicast_delete(struct net_device *dev, void *addr, int alen);
 extern int		dev_unicast_add(struct net_device *dev, void *addr, int alen);
 extern int 		dev_mc_delete(struct net_device *dev, void *addr, int alen, int all);
diff --git a/net/core/dev.c b/net/core/dev.c
index 86d6261..eb1a11f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2822,39 +2822,50 @@ void dev_set_allmulti(struct net_device *dev, int inc)
  *	filtering it is put in promiscous mode while unicast addresses
  *	are present.
  */
-void __dev_set_rx_mode(struct net_device *dev)
+int __dev_set_rx_mode(struct net_device *dev)
 {
 	/* dev_open will call this function so the list will stay sane. */
 	if (!(dev->flags&IFF_UP))
-		return;
+		return 0;
 
 	if (!netif_device_present(dev))
-		return;
+		return 0;
 
-	if (dev->set_rx_mode)
+	if (dev->set_rx_mode) {
 		dev->set_rx_mode(dev);
-	else {
-		/* Unicast addresses changes may only happen under the rtnl,
-		 * therefore calling __dev_set_promiscuity here is safe.
-		 */
-		if (dev->uc_count > 0 && !dev->uc_promisc) {
-			__dev_set_promiscuity(dev, 1);
-			dev->uc_promisc = 1;
-		} else if (dev->uc_count == 0 && dev->uc_promisc) {
-			__dev_set_promiscuity(dev, -1);
-			dev->uc_promisc = 0;
-		}
+		return 0;
+	}
+	return 1;
+}
 
-		if (dev->set_multicast_list)
-			dev->set_multicast_list(dev);
+void __dev_set_rx_mode_fini(struct net_device *dev)
+{
+	BUG_TRAP(dev->flags&IFF_UP);
+	BUG_TRAP(netif_device_present(dev));
+
+	/* Unicast addresses changes may only happen under the rtnl,
+	 * therefore calling __dev_set_promiscuity here is safe.
+	 */
+	if (dev->uc_count > 0 && !dev->uc_promisc) {
+		__dev_set_promiscuity(dev, 1);
+		dev->uc_promisc = 1;
+	} else if (dev->uc_count == 0 && dev->uc_promisc) {
+		__dev_set_promiscuity(dev, -1);
+		dev->uc_promisc = 0;
 	}
+
+	if (dev->set_multicast_list)
+		dev->set_multicast_list(dev);
 }
 
 void dev_set_rx_mode(struct net_device *dev)
 {
+	int pending;
 	netif_tx_lock_bh(dev);
-	__dev_set_rx_mode(dev);
+	pending = __dev_set_rx_mode(dev);
 	netif_tx_unlock_bh(dev);
+	if (pending)
+		__dev_set_rx_mode_fini(dev);
 }
 
 int __dev_addr_delete(struct dev_addr_list **list, int *count,
@@ -2929,14 +2940,17 @@ int __dev_addr_add(struct dev_addr_list **list, int *count,
 int dev_unicast_delete(struct net_device *dev, void *addr, int alen)
 {
 	int err;
+	int pending = 0;
 
 	ASSERT_RTNL();
 
 	netif_tx_lock_bh(dev);
 	err = __dev_addr_delete(&dev->uc_list, &dev->uc_count, addr, alen, 0);
 	if (!err)
-		__dev_set_rx_mode(dev);
+		pending = __dev_set_rx_mode(dev);
 	netif_tx_unlock_bh(dev);
+	if (pending)
+		__dev_set_rx_mode_fini(dev);
 	return err;
 }
 EXPORT_SYMBOL(dev_unicast_delete);
@@ -2955,14 +2969,17 @@ EXPORT_SYMBOL(dev_unicast_delete);
 int dev_unicast_add(struct net_device *dev, void *addr, int alen)
 {
 	int err;
+	int pending = 0;
 
 	ASSERT_RTNL();
 
 	netif_tx_lock_bh(dev);
 	err = __dev_addr_add(&dev->uc_list, &dev->uc_count, addr, alen, 0);
 	if (!err)
-		__dev_set_rx_mode(dev);
+		pending = __dev_set_rx_mode(dev);
 	netif_tx_unlock_bh(dev);
+	if (pending)
+		__dev_set_rx_mode_fini(dev);
 	return err;
 }
 EXPORT_SYMBOL(dev_unicast_add);
diff --git a/net/core/dev_mcast.c b/net/core/dev_mcast.c
index 69fff16..0170359 100644
--- a/net/core/dev_mcast.c
+++ b/net/core/dev_mcast.c
@@ -71,6 +71,7 @@
 int dev_mc_delete(struct net_device *dev, void *addr, int alen, int glbl)
 {
 	int err;
+	int pending = 0;
 
 	netif_tx_lock_bh(dev);
 	err = __dev_addr_delete(&dev->mc_list, &dev->mc_count,
@@ -81,9 +82,11 @@ int dev_mc_delete(struct net_device *dev, void *addr, int alen, int glbl)
 		 *	loaded filter is now wrong. Fix it
 		 */
 
-		__dev_set_rx_mode(dev);
+		pending = __dev_set_rx_mode(dev);
 	}
 	netif_tx_unlock_bh(dev);
+	if (pending)
+		__dev_set_rx_mode_fini(dev);
 	return err;
 }
 
@@ -94,12 +97,15 @@ int dev_mc_delete(struct net_device *dev, void *addr, int alen, int glbl)
 int dev_mc_add(struct net_device *dev, void *addr, int alen, int glbl)
 {
 	int err;
+	int pending = 0;
 
 	netif_tx_lock_bh(dev);
 	err = __dev_addr_add(&dev->mc_list, &dev->mc_count, addr, alen, glbl);
 	if (!err)
-		__dev_set_rx_mode(dev);
+		pending = __dev_set_rx_mode(dev);
 	netif_tx_unlock_bh(dev);
+	if (pending)
+		__dev_set_rx_mode_fini(dev);
 	return err;
 }
 
@@ -119,6 +125,7 @@ int dev_mc_sync(struct net_device *to, struct net_device *from)
 {
 	struct dev_addr_list *da, *next;
 	int err = 0;
+	int pending = 0;
 
 	netif_tx_lock_bh(to);
 	da = from->mc_list;
@@ -140,9 +147,11 @@ int dev_mc_sync(struct net_device *to, struct net_device *from)
 		da = next;
 	}
 	if (!err)
-		__dev_set_rx_mode(to);
+		pending = __dev_set_rx_mode(to);
 	netif_tx_unlock_bh(to);
 
+	if (pending)
+		__dev_set_rx_mode_fini(to);
 	return err;
 }
 EXPORT_SYMBOL(dev_mc_sync);
@@ -161,6 +170,7 @@ EXPORT_SYMBOL(dev_mc_sync);
 void dev_mc_unsync(struct net_device *to, struct net_device *from)
 {
 	struct dev_addr_list *da, *next;
+	int pending;
 
 	netif_tx_lock_bh(from);
 	netif_tx_lock_bh(to);
@@ -177,10 +187,13 @@ void dev_mc_unsync(struct net_device *to, struct net_device *from)
 		}
 		da = next;
 	}
-	__dev_set_rx_mode(to);
+	pending = __dev_set_rx_mode(to);
 
 	netif_tx_unlock_bh(to);
 	netif_tx_unlock_bh(from);
+
+	if (pending)
+		__dev_set_rx_mode_fini(to);
 }
 EXPORT_SYMBOL(dev_mc_unsync);
 
---

