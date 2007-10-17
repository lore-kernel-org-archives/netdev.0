From: Scott Wood <scottwood@freescale.com>
Subject: [PATCH] fs_enet: Update for API changes
Date: Wed, 17 Oct 2007 12:42:43 -0500
Message-ID: <20071017174243.GA4462@loki.buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

This driver was recently broken by several changes for which this
driver was not (or was improperly) updated:

1. SET_MODULE_OWNER() was removed.
2. netif_napi_add() was only being called when building with
the old CPM binding.
3. The received/budget test was backwards.
4. to_net_dev() was wrong -- the device struct embedded in
the net_device struct is not the same as the of_platform
device in the private struct.
5. napi_disable/napi_enable was being called even when napi
was not being used.

These changes have been fixed, and napi is now on by default.

Signed-off-by: Scott Wood <scottwood@freescale.com>
---
 drivers/net/fs_enet/fs_enet-main.c |   28 ++++++++++++++++------------
 drivers/net/fs_enet/fs_enet.h      |    1 +
 2 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index 04c6fae..f2a4d39 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -88,7 +88,7 @@ static void skb_align(struct sk_buff *skb, int align)
 static int fs_enet_rx_napi(struct napi_struct *napi, int budget)
 {
 	struct fs_enet_private *fep = container_of(napi, struct fs_enet_private, napi);
-	struct net_device *dev = to_net_dev(fep->dev);
+	struct net_device *dev = fep->ndev;
 	const struct fs_platform_info *fpi = fep->fpi;
 	cbd_t __iomem *bdp;
 	struct sk_buff *skb, *skbn, *skbt;
@@ -217,7 +217,7 @@ static int fs_enet_rx_napi(struct napi_struct *napi, int budget)
 
 	fep->cur_rx = bdp;
 
-	if (received >= budget) {
+	if (received < budget) {
 		/* done */
 		netif_rx_complete(dev, napi);
 		(*fep->ops->napi_enable_rx)(dev);
@@ -807,20 +807,23 @@ static int fs_enet_open(struct net_device *dev)
 	int r;
 	int err;
 
-	napi_enable(&fep->napi);
+	if (fep->fpi->use_napi)
+		napi_enable(&fep->napi);
 
 	/* Install our interrupt handler. */
 	r = fs_request_irq(dev, fep->interrupt, "fs_enet-mac", fs_enet_interrupt);
 	if (r != 0) {
 		printk(KERN_ERR DRV_MODULE_NAME
 		       ": %s Could not allocate FS_ENET IRQ!", dev->name);
-		napi_disable(&fep->napi);
+		if (fep->fpi->use_napi)
+			napi_disable(&fep->napi);
 		return -EINVAL;
 	}
 
 	err = fs_init_phy(dev);
-	if(err) {
-		napi_disable(&fep->napi);
+	if (err) {
+		if (fep->fpi->use_napi)
+			napi_disable(&fep->napi);
 		return err;
 	}
 	phy_start(fep->phydev);
@@ -1232,7 +1235,7 @@ static int __devinit fs_enet_probe(struct of_device *ofdev,
 	fpi->rx_ring = 32;
 	fpi->tx_ring = 32;
 	fpi->rx_copybreak = 240;
-	fpi->use_napi = 0;
+	fpi->use_napi = 1;
 	fpi->napi_weight = 17;
 
 	ret = find_phy(ofdev->node, fpi);
@@ -1249,11 +1252,11 @@ static int __devinit fs_enet_probe(struct of_device *ofdev,
 		goto out_free_fpi;
 	}
 
-	SET_MODULE_OWNER(ndev);
 	dev_set_drvdata(&ofdev->dev, ndev);
 
 	fep = netdev_priv(ndev);
 	fep->dev = &ofdev->dev;
+	fep->ndev = ndev;
 	fep->fpi = fpi;
 	fep->ops = match->data;
 
@@ -1288,10 +1291,11 @@ static int __devinit fs_enet_probe(struct of_device *ofdev,
 	ndev->stop = fs_enet_close;
 	ndev->get_stats = fs_enet_get_stats;
 	ndev->set_multicast_list = fs_set_multicast_list;
-	if (fpi->use_napi) {
-		ndev->poll = fs_enet_rx_napi;
-		ndev->weight = fpi->napi_weight;
-	}
+
+	if (fpi->use_napi)
+		netif_napi_add(ndev, &fep->napi, fs_enet_rx_napi,
+		               fpi->napi_weight);
+
 	ndev->ethtool_ops = &fs_ethtool_ops;
 	ndev->do_ioctl = fs_ioctl;
 
diff --git a/drivers/net/fs_enet/fs_enet.h b/drivers/net/fs_enet/fs_enet.h
index baf6477..c675e29 100644
--- a/drivers/net/fs_enet/fs_enet.h
+++ b/drivers/net/fs_enet/fs_enet.h
@@ -75,6 +75,7 @@ struct phy_info {
 struct fs_enet_private {
 	struct napi_struct napi;
 	struct device *dev;	/* pointer back to the device (must be initialized first) */
+	struct net_device *ndev;
 	spinlock_t lock;	/* during all ops except TX pckt processing */
 	spinlock_t tx_lock;	/* during fs_start_xmit and fs_tx         */
 	struct fs_platform_info *fpi;
-- 
1.5.3.4
