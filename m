From: Guo-Fu Tseng <cooldavid@cooldavid.org>
Subject: [PATCH net-2.6 5/7] jme: Remove shadow register support
Date: Mon, 29 Jun 2009 04:56:25 +0800
Message-ID: <20090702183224.02EB25D2DA@cooldavid.org>
Cc: "netdev" <netdev@vger.kernel.org>,
	"Ethan Hsiao" <ethanhsiao@jmicron.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([220.133.139.86]:49287 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752802AbZGBSpy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jul 2009 14:45:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The hardware failed to update the shadow register in several cases.
It's known to be failed at 64bit box with more than 4G RAM.
In order to make the device working stable, give up using the shadow
register feature.

Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
---
 drivers/net/jme.c |   49 ++++---------------------------------------------
 drivers/net/jme.h |   14 --------------
 2 files changed, 4 insertions(+), 59 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 4a55b05..29cd5f4 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -322,20 +322,6 @@ jme_stop_irq(struct jme_adapter *jme)
 	jwrite32f(jme, JME_IENC, INTR_ENABLE);
 }
 
-static inline void
-jme_enable_shadow(struct jme_adapter *jme)
-{
-	jwrite32(jme,
-		 JME_SHBA_LO,
-		 ((u32)jme->shadow_dma & ~((u32)0x1F)) | SHBA_POSTEN);
-}
-
-static inline void
-jme_disable_shadow(struct jme_adapter *jme)
-{
-	jwrite32(jme, JME_SHBA_LO, 0x0);
-}
-
 static u32
 jme_linkstat_from_phy(struct jme_adapter *jme)
 {
@@ -1521,12 +1507,7 @@ jme_msi(int irq, void *dev_id)
 	struct jme_adapter *jme = netdev_priv(netdev);
 	u32 intrstat;
 
-	pci_dma_sync_single_for_cpu(jme->pdev,
-				    jme->shadow_dma,
-				    sizeof(u32) * SHADOW_REG_NR,
-				    PCI_DMA_FROMDEVICE);
-	intrstat = jme->shadow_regs[SHADOW_IEVE];
-	jme->shadow_regs[SHADOW_IEVE] = 0;
+	intrstat = jread32(jme, JME_IEVE);
 
 	jme_intr_msi(jme, intrstat);
 
@@ -1613,7 +1594,6 @@ jme_open(struct net_device *netdev)
 	if (rc)
 		goto err_out;
 
-	jme_enable_shadow(jme);
 	jme_start_irq(jme);
 
 	if (test_bit(JME_FLAG_SSET, &jme->flags))
@@ -1681,7 +1661,6 @@ jme_close(struct net_device *netdev)
 	netif_carrier_off(netdev);
 
 	jme_stop_irq(jme);
-	jme_disable_shadow(jme);
 	jme_free_irq(jme);
 
 	JME_NAPI_DISABLE(jme);
@@ -2764,14 +2743,6 @@ jme_init_one(struct pci_dev *pdev,
 		rc = -ENOMEM;
 		goto err_out_free_netdev;
 	}
-	jme->shadow_regs = pci_alloc_consistent(pdev,
-						sizeof(u32) * SHADOW_REG_NR,
-						&(jme->shadow_dma));
-	if (!(jme->shadow_regs)) {
-		jeprintk(pdev, "Allocating shadow register mapping error.\n");
-		rc = -ENOMEM;
-		goto err_out_unmap;
-	}
 
 	if (no_pseudohp) {
 		apmc = jread32(jme, JME_APMC) & ~JME_APMC_PSEUDO_HP_EN;
@@ -2857,7 +2828,7 @@ jme_init_one(struct pci_dev *pdev,
 		if (!jme->mii_if.phy_id) {
 			rc = -EIO;
 			jeprintk(pdev, "Can not find phy_id.\n");
-			 goto err_out_free_shadow;
+			 goto err_out_unmap;
 		}
 
 		jme->reg_ghc |= GHC_LINK_POLL;
@@ -2886,7 +2857,7 @@ jme_init_one(struct pci_dev *pdev,
 	if (rc) {
 		jeprintk(pdev,
 			"Reload eeprom for reading MAC Address error.\n");
-		goto err_out_free_shadow;
+		goto err_out_unmap;
 	}
 	jme_load_macaddr(netdev);
 
@@ -2902,7 +2873,7 @@ jme_init_one(struct pci_dev *pdev,
 	rc = register_netdev(netdev);
 	if (rc) {
 		jeprintk(pdev, "Cannot register net device.\n");
-		goto err_out_free_shadow;
+		goto err_out_unmap;
 	}
 
 	msg_probe(jme, "%s%s ver:%x rev:%x macaddr:%pM\n",
@@ -2916,11 +2887,6 @@ jme_init_one(struct pci_dev *pdev,
 
 	return 0;
 
-err_out_free_shadow:
-	pci_free_consistent(pdev,
-			    sizeof(u32) * SHADOW_REG_NR,
-			    jme->shadow_regs,
-			    jme->shadow_dma);
 err_out_unmap:
 	iounmap(jme->regs);
 err_out_free_netdev:
@@ -2941,10 +2907,6 @@ jme_remove_one(struct pci_dev *pdev)
 	struct jme_adapter *jme = netdev_priv(netdev);
 
 	unregister_netdev(netdev);
-	pci_free_consistent(pdev,
-			    sizeof(u32) * SHADOW_REG_NR,
-			    jme->shadow_regs,
-			    jme->shadow_dma);
 	iounmap(jme->regs);
 	pci_set_drvdata(pdev, NULL);
 	free_netdev(netdev);
@@ -2970,8 +2932,6 @@ jme_suspend(struct pci_dev *pdev, pm_message_t state)
 	tasklet_disable(&jme->rxclean_task);
 	tasklet_disable(&jme->rxempty_task);
 
-	jme_disable_shadow(jme);
-
 	if (netif_carrier_ok(netdev)) {
 		if (test_bit(JME_FLAG_POLL, &jme->flags))
 			jme_polling_mode(jme);
@@ -3023,7 +2983,6 @@ jme_resume(struct pci_dev *pdev)
 	else
 		jme_reset_phy_processor(jme);
 
-	jme_enable_shadow(jme);
 	jme_start_irq(jme);
 	netif_device_attach(netdev);
 
diff --git a/drivers/net/jme.h b/drivers/net/jme.h
index 9d3cedd..db912f6 100644
--- a/drivers/net/jme.h
+++ b/drivers/net/jme.h
@@ -410,13 +410,10 @@ struct jme_ring {
 /*
  * Jmac Adapter Private data
  */
-#define SHADOW_REG_NR 8
 struct jme_adapter {
 	struct pci_dev          *pdev;
 	struct net_device       *dev;
 	void __iomem            *regs;
-	dma_addr_t		shadow_dma;
-	u32			*shadow_regs;
 	struct mii_if_info	mii_if;
 	struct jme_ring		rxring[RX_RING_NR];
 	struct jme_ring		txring[TX_RING_NR];
@@ -463,10 +460,6 @@ struct jme_adapter {
 	DECLARE_NET_DEVICE_STATS
 };
 
-enum shadow_reg_val {
-	SHADOW_IEVE = 0,
-};
-
 enum jme_flags_bits {
 	JME_FLAG_MSI		= 1,
 	JME_FLAG_SSET		= 2,
@@ -1103,13 +1096,6 @@ enum jme_chipmode_shifts {
 };
 
 /*
- * Shadow base address register bits
- */
-enum jme_shadow_base_address_bits {
-	SHBA_POSTEN	= 0x1,
-};
-
-/*
  * Aggressive Power Mode Control
  */
 enum jme_apmc_bits {
-- 
1.6.0.6

