From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] [PATCH] xen: netback: remove redundant xenvif_put
Date: Tue, 19 Feb 2013 13:47:16 +0000
Message-ID: <1361281636.1051.100.camel@zakaz.uk.xensource.com>
References: <1361219360-29176-1-git-send-email-drjones@redhat.com>
	 <20130219.005356.2288460992654639558.davem@davemloft.net>
	 <51233FF502000078000BF4AE@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"drjones@redhat.com" <drjones@redhat.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jan Beulich <JBeulich@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51233FF502000078000BF4AE@nat28.tlf.novell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-02-19 at 08:03 +0000, Jan Beulich wrote:
> The core of
> it is that the put here parallels the one in netbk_tx_err(), and
> the one in xenvif_carrier_off() matches the get from
> xenvif_connect() (which normally would be done on the path
> coming through xenvif_disconnect()). 

A few people have made this mistake already, perhaps this helps make it
more obvious what is going on...

8<--------------------------------

>From 7b93077e2cda5881b594d9c7e733e617df87d7c0 Mon Sep 17 00:00:00 2001
From: Ian Campbell <ian.campbell@citrix.com>
Date: Tue, 19 Feb 2013 10:46:12 +0000
Subject: [PATCH] xen/netback: refactor xenvif_carrier_on from xenvif_connect

Several people have been confused by the vif reference count taken by
xenvif_connect() being dropped in xenvif_carrier_off(). Factor out bringing
the carrier up (and the associated reference grab) to try and make the
relationship more obvious.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
---
 drivers/net/xen-netback/interface.c |   49 +++++++++++++++++++---------------
 1 files changed, 27 insertions(+), 22 deletions(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index d984141..059d726 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -307,6 +307,32 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 	return vif;
 }
 
+static void xenvif_carrier_on(struct xenvif *vif)
+{
+	xenvif_get(vif);
+
+	rtnl_lock();
+	if (!vif->can_sg && vif->dev->mtu > ETH_DATA_LEN)
+		dev_set_mtu(vif->dev, ETH_DATA_LEN);
+	netdev_update_features(vif->dev);
+	netif_carrier_on(vif->dev);
+	if (netif_running(vif->dev))
+		xenvif_up(vif);
+	rtnl_unlock();
+}
+
+void xenvif_carrier_off(struct xenvif *vif)
+{
+	struct net_device *dev = vif->dev;
+
+	rtnl_lock();
+	netif_carrier_off(dev); /* discard queued packets */
+	if (netif_running(dev))
+		xenvif_down(vif);
+	rtnl_unlock();
+	xenvif_put(vif);
+}
+
 int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 		   unsigned long rx_ring_ref, unsigned int evtchn)
 {
@@ -328,16 +354,7 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 	vif->irq = err;
 	disable_irq(vif->irq);
 
-	xenvif_get(vif);
-
-	rtnl_lock();
-	if (!vif->can_sg && vif->dev->mtu > ETH_DATA_LEN)
-		dev_set_mtu(vif->dev, ETH_DATA_LEN);
-	netdev_update_features(vif->dev);
-	netif_carrier_on(vif->dev);
-	if (netif_running(vif->dev))
-		xenvif_up(vif);
-	rtnl_unlock();
+	xenvif_carrier_on(vif);
 
 	return 0;
 err_unmap:
@@ -346,18 +363,6 @@ err:
 	return err;
 }
 
-void xenvif_carrier_off(struct xenvif *vif)
-{
-	struct net_device *dev = vif->dev;
-
-	rtnl_lock();
-	netif_carrier_off(dev); /* discard queued packets */
-	if (netif_running(dev))
-		xenvif_down(vif);
-	rtnl_unlock();
-	xenvif_put(vif);
-}
-
 void xenvif_disconnect(struct xenvif *vif)
 {
 	if (netif_carrier_ok(vif->dev))
-- 
1.7.2.5
