From: Kumar Gala <galak@kernel.crashing.org>
Subject: [PATCH 2/9] fs-enet: remove code associated with !CONFIG_PPC_MERGE
Date: Wed, 20 Aug 2008 23:46:51 -0500
Message-ID: <1219294018-12557-3-git-send-email-galak@kernel.crashing.org>
References: <1219294018-12557-1-git-send-email-galak@kernel.crashing.org>
 <1219294018-12557-2-git-send-email-galak@kernel.crashing.org>
Cc: akpm@linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753693AbYHUEsY@vger.kernel.org>
In-Reply-To: <1219294018-12557-2-git-send-email-galak@kernel.crashing.org>
CC: netdev@vger.kernel.org
CC: jgarzik@pobox.com
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that arch/ppc is gone we don't need CONFIG_PPC_MERGE anymore remove
the dead code associated with !CONFIG_PPC_MERGE.

With this change the pre_request_irq() and post_free_irq() calls became
nops so they have been removed.  Also removed fs_request_irq() and
fs_free_irq() and just called request_irq() and free_irq().

Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
---
 drivers/net/fs_enet/fs_enet-main.c |   22 +++-------------------
 drivers/net/fs_enet/fs_enet.h      |    2 --
 drivers/net/fs_enet/mac-fcc.c      |   12 ------------
 drivers/net/fs_enet/mac-fec.c      |   30 ------------------------------
 drivers/net/fs_enet/mac-scc.c      |   26 --------------------------
 5 files changed, 3 insertions(+), 89 deletions(-)

diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index 9a51ec8..5281bdc 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -664,23 +664,6 @@ static int fs_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
-static int fs_request_irq(struct net_device *dev, int irq, const char *name,
-		irq_handler_t irqf)
-{
-	struct fs_enet_private *fep = netdev_priv(dev);
-
-	(*fep->ops->pre_request_irq)(dev, irq);
-	return request_irq(irq, irqf, IRQF_SHARED, name, dev);
-}
-
-static void fs_free_irq(struct net_device *dev, int irq)
-{
-	struct fs_enet_private *fep = netdev_priv(dev);
-
-	free_irq(irq, dev);
-	(*fep->ops->post_free_irq)(dev, irq);
-}
-
 static void fs_timeout(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
@@ -796,7 +779,8 @@ static int fs_enet_open(struct net_device *dev)
 		napi_enable(&fep->napi);
 
 	/* Install our interrupt handler. */
-	r = fs_request_irq(dev, fep->interrupt, "fs_enet-mac", fs_enet_interrupt);
+	r = request_irq(fep->interrupt, fs_enet_interrupt, IRQF_SHARED,
+			"fs_enet-mac", dev);
 	if (r != 0) {
 		printk(KERN_ERR DRV_MODULE_NAME
 		       ": %s Could not allocate FS_ENET IRQ!", dev->name);
@@ -838,7 +822,7 @@ static int fs_enet_close(struct net_device *dev)
 	/* release any irqs */
 	phy_disconnect(fep->phydev);
 	fep->phydev = NULL;
-	fs_free_irq(dev, fep->interrupt);
+	free_irq(fep->interrupt, dev);
 
 	return 0;
 }
diff --git a/drivers/net/fs_enet/fs_enet.h b/drivers/net/fs_enet/fs_enet.h
index db46d2e..85a4bab 100644
--- a/drivers/net/fs_enet/fs_enet.h
+++ b/drivers/net/fs_enet/fs_enet.h
@@ -34,8 +34,6 @@ struct fs_ops {
 	void (*adjust_link)(struct net_device *dev);
 	void (*restart)(struct net_device *dev);
 	void (*stop)(struct net_device *dev);
-	void (*pre_request_irq)(struct net_device *dev, int irq);
-	void (*post_free_irq)(struct net_device *dev, int irq);
 	void (*napi_clear_rx_event)(struct net_device *dev);
 	void (*napi_enable_rx)(struct net_device *dev);
 	void (*napi_disable_rx)(struct net_device *dev);
diff --git a/drivers/net/fs_enet/mac-fcc.c b/drivers/net/fs_enet/mac-fcc.c
index 1c7ef81..22e5a84 100644
--- a/drivers/net/fs_enet/mac-fcc.c
+++ b/drivers/net/fs_enet/mac-fcc.c
@@ -421,16 +421,6 @@ static void stop(struct net_device *dev)
 	fs_cleanup_bds(dev);
 }
 
-static void pre_request_irq(struct net_device *dev, int irq)
-{
-	/* nothing */
-}
-
-static void post_free_irq(struct net_device *dev, int irq)
-{
-	/* nothing */
-}
-
 static void napi_clear_rx_event(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
@@ -540,8 +530,6 @@ const struct fs_ops fs_fcc_ops = {
 	.set_multicast_list	= set_multicast_list,
 	.restart		= restart,
 	.stop			= stop,
-	.pre_request_irq	= pre_request_irq,
-	.post_free_irq		= post_free_irq,
 	.napi_clear_rx_event	= napi_clear_rx_event,
 	.napi_enable_rx		= napi_enable_rx,
 	.napi_disable_rx	= napi_disable_rx,
diff --git a/drivers/net/fs_enet/mac-fec.c b/drivers/net/fs_enet/mac-fec.c
index 0a7d1c5..14e5753 100644
--- a/drivers/net/fs_enet/mac-fec.c
+++ b/drivers/net/fs_enet/mac-fec.c
@@ -313,11 +313,7 @@ static void restart(struct net_device *dev)
 	 * Clear any outstanding interrupt.
 	 */
 	FW(fecp, ievent, 0xffc0);
-#ifndef CONFIG_PPC_MERGE
-	FW(fecp, ivec, (fep->interrupt / 2) << 29);
-#else
 	FW(fecp, ivec, (virq_to_hw(fep->interrupt) / 2) << 29);
-#endif
 
 	/*
 	 * adjust to speed (only for DUET & RMII)
@@ -413,30 +409,6 @@ static void stop(struct net_device *dev)
 	}
 }
 
-static void pre_request_irq(struct net_device *dev, int irq)
-{
-#ifndef CONFIG_PPC_MERGE
-	immap_t *immap = fs_enet_immap;
-	u32 siel;
-
-	/* SIU interrupt */
-	if (irq >= SIU_IRQ0 && irq < SIU_LEVEL7) {
-
-		siel = in_be32(&immap->im_siu_conf.sc_siel);
-		if ((irq & 1) == 0)
-			siel |= (0x80000000 >> irq);
-		else
-			siel &= ~(0x80000000 >> (irq & ~1));
-		out_be32(&immap->im_siu_conf.sc_siel, siel);
-	}
-#endif
-}
-
-static void post_free_irq(struct net_device *dev, int irq)
-{
-	/* nothing */
-}
-
 static void napi_clear_rx_event(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
@@ -529,8 +501,6 @@ const struct fs_ops fs_fec_ops = {
 	.set_multicast_list	= set_multicast_list,
 	.restart		= restart,
 	.stop			= stop,
-	.pre_request_irq	= pre_request_irq,
-	.post_free_irq		= post_free_irq,
 	.napi_clear_rx_event	= napi_clear_rx_event,
 	.napi_enable_rx		= napi_enable_rx,
 	.napi_disable_rx	= napi_disable_rx,
diff --git a/drivers/net/fs_enet/mac-scc.c b/drivers/net/fs_enet/mac-scc.c
index 029b3c7..397608a 100644
--- a/drivers/net/fs_enet/mac-scc.c
+++ b/drivers/net/fs_enet/mac-scc.c
@@ -371,30 +371,6 @@ static void stop(struct net_device *dev)
 	fs_cleanup_bds(dev);
 }
 
-static void pre_request_irq(struct net_device *dev, int irq)
-{
-#ifndef CONFIG_PPC_MERGE
-	immap_t *immap = fs_enet_immap;
-	u32 siel;
-
-	/* SIU interrupt */
-	if (irq >= SIU_IRQ0 && irq < SIU_LEVEL7) {
-
-		siel = in_be32(&immap->im_siu_conf.sc_siel);
-		if ((irq & 1) == 0)
-			siel |= (0x80000000 >> irq);
-		else
-			siel &= ~(0x80000000 >> (irq & ~1));
-		out_be32(&immap->im_siu_conf.sc_siel, siel);
-	}
-#endif
-}
-
-static void post_free_irq(struct net_device *dev, int irq)
-{
-	/* nothing */
-}
-
 static void napi_clear_rx_event(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
@@ -488,8 +464,6 @@ const struct fs_ops fs_scc_ops = {
 	.set_multicast_list	= set_multicast_list,
 	.restart		= restart,
 	.stop			= stop,
-	.pre_request_irq	= pre_request_irq,
-	.post_free_irq		= post_free_irq,
 	.napi_clear_rx_event	= napi_clear_rx_event,
 	.napi_enable_rx		= napi_enable_rx,
 	.napi_disable_rx	= napi_disable_rx,
-- 
1.5.5.1
