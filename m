From: Kumar Gala <galak@kernel.crashing.org>
Subject: [PATCH 03/10] fs-enet: remove code associated with !CONFIG_PPC_MERGE
Date: Fri,  1 Aug 2008 11:44:13 -0500
Message-ID: <1217609060-6381-4-git-send-email-galak@kernel.crashing.org>
References: <1217609060-6381-1-git-send-email-galak@kernel.crashing.org>
 <1217609060-6381-2-git-send-email-galak@kernel.crashing.org>
 <1217609060-6381-3-git-send-email-galak@kernel.crashing.org>
Cc: linux-kernel@vger.kernel.org
To: linuxppc-dev@ozlabs.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756734AbYHAQp4@vger.kernel.org>
In-Reply-To: <1217609060-6381-3-git-send-email-galak@kernel.crashing.org>
CC: netdev@vger.kernel.org
CC: jgarzik@pobox.com
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that arch/ppc is gone we don't need CONFIG_PPC_MERGE anymore remove
the dead code associated with !CONFIG_PPC_MERGE.

With this change the pre_request_irq() and post_free_irq() calls became
nops so they have been removed.

Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
---
 drivers/net/fs_enet/fs_enet-main.c |    2 --
 drivers/net/fs_enet/fs_enet.h      |    2 --
 drivers/net/fs_enet/mac-fcc.c      |   12 ------------
 drivers/net/fs_enet/mac-fec.c      |   30 ------------------------------
 drivers/net/fs_enet/mac-scc.c      |   26 --------------------------
 5 files changed, 0 insertions(+), 72 deletions(-)

diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index 9a51ec8..e54d003 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -669,7 +669,6 @@ static int fs_request_irq(struct net_device *dev, int irq, const char *name,
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 
-	(*fep->ops->pre_request_irq)(dev, irq);
 	return request_irq(irq, irqf, IRQF_SHARED, name, dev);
 }
 
@@ -678,7 +677,6 @@ static void fs_free_irq(struct net_device *dev, int irq)
 	struct fs_enet_private *fep = netdev_priv(dev);
 
 	free_irq(irq, dev);
-	(*fep->ops->post_free_irq)(dev, irq);
 }
 
 static void fs_timeout(struct net_device *dev)
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
index 0a97fc2..b8c40d0 100644
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
