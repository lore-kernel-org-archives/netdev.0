From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Thu, 17 May 2007 21:37:23 -0400
Message-ID: <20070518013723.GA4624@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759666AbXERBhj@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 Documentation/networking/netdevices.txt |    2 +-
 drivers/net/e1000/e1000.h               |    4 +-
 drivers/net/e1000/e1000_main.c          |   39 ++++++-----------
 drivers/net/gianfar.c                   |   11 +++++
 drivers/net/ibm_emac/ibm_emac_core.c    |    2 +-
 drivers/net/ibm_emac/ibm_emac_mal.c     |    3 +-
 drivers/net/ibm_emac/ibm_emac_mal.h     |    3 +-
 drivers/net/ibm_emac/ibm_emac_phy.c     |   60 ++++++++++++++++++++-------
 drivers/net/ibm_emac/ibm_emac_rgmii.c   |    2 +-
 drivers/net/ibm_emac/ibm_emac_rgmii.h   |    2 +-
 drivers/net/ibm_emac/ibm_emac_tah.c     |    2 +-
 drivers/net/ibm_emac/ibm_emac_tah.h     |    2 +-
 drivers/net/ibm_emac/ibm_emac_zmii.c    |    2 +-
 drivers/net/ibm_emac/ibm_emac_zmii.h    |    2 +-
 drivers/net/ixgb/ixgb.h                 |    2 -
 drivers/net/ixgb/ixgb_main.c            |   36 +++++++---------
 drivers/net/netxen/netxen_nic_init.c    |    2 +-
 drivers/net/sky2.c                      |   69 ++++++++++++-------------------
 drivers/net/spider_net.c                |    3 +-
 19 files changed, 125 insertions(+), 123 deletions(-)

Auke Kok (2):
      ixgb: don't print error if pci_enable_msi() fails, cleanup minor leak
      e1000: Fix msi enable leak on error, don't print error message, cleanup

Christoph Hellwig (2):
      small netdevices.txt fix
      spidernet: node-aware skbuff allocation

Eugene Surovegin (3):
      ibm_emac: fix section mismatch warnings
      ibm_emac: improved PHY support
      ibm_emac: fix link speed detection change

Mithlesh Thukral (1):
      NetXen: Fix NetXen driver ping on system-p

Scott Wood (1):
      gianfar: Add I/O barriers when touching buffer descriptor ownership.

Stephen Hemminger (6):
      sky2: remove Gigabyte 88e8056 restriction
      sky2: PHY register settings
      sky2: keep track of receive alloc failures
      sky2: MIB counter overflow handling
      sky2: remove dual port workaround
      sky2: memory barriers change

diff --git a/Documentation/networking/netdevices.txt b/Documentation/networking/netdevices.txt
index 847cedb..ce1361f 100644
--- a/Documentation/networking/netdevices.txt
+++ b/Documentation/networking/netdevices.txt
@@ -49,7 +49,7 @@ dev->hard_start_xmit:
 	for this and return -1 when the spin lock fails. 
 	The locking there should also properly protect against 
 	set_multicast_list
-	Context: BHs disabled
+	Context: Process with BHs disabled or BH (timer).
 	Notes: netif_queue_stopped() is guaranteed false
                Interrupts must be enabled when calling hard_start_xmit.
                 (Interrupts must also be enabled when enabling the BH handler.)
diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index a9ea67e..16a6edf 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -333,11 +333,9 @@ struct e1000_adapter {
 	struct e1000_tx_ring test_tx_ring;
 	struct e1000_rx_ring test_rx_ring;
 
-
 	int msg_enable;
-#ifdef CONFIG_PCI_MSI
 	boolean_t have_msi;
-#endif
+
 	/* to not mess up cache alignment, always add to the bottom */
 	boolean_t tso_force;
 	boolean_t smart_power_down;	/* phy smart power down */
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 637ae8f..49be393 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -158,9 +158,7 @@ static struct net_device_stats * e1000_get_stats(struct net_device *netdev);
 static int e1000_change_mtu(struct net_device *netdev, int new_mtu);
 static int e1000_set_mac(struct net_device *netdev, void *p);
 static irqreturn_t e1000_intr(int irq, void *data);
-#ifdef CONFIG_PCI_MSI
 static irqreturn_t e1000_intr_msi(int irq, void *data);
-#endif
 static boolean_t e1000_clean_tx_irq(struct e1000_adapter *adapter,
                                     struct e1000_tx_ring *tx_ring);
 #ifdef CONFIG_E1000_NAPI
@@ -300,31 +298,26 @@ module_exit(e1000_exit_module);
 static int e1000_request_irq(struct e1000_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
-	int flags, err = 0;
+	void (*handler) = &e1000_intr;
+	int irq_flags = IRQF_SHARED;
+	int err;
 
-	flags = IRQF_SHARED;
-#ifdef CONFIG_PCI_MSI
 	if (adapter->hw.mac_type >= e1000_82571) {
-		adapter->have_msi = TRUE;
-		if ((err = pci_enable_msi(adapter->pdev))) {
-			DPRINTK(PROBE, ERR,
-			 "Unable to allocate MSI interrupt Error: %d\n", err);
-			adapter->have_msi = FALSE;
+		adapter->have_msi = !pci_enable_msi(adapter->pdev);
+		if (adapter->have_msi) {
+			handler = &e1000_intr_msi;
+			irq_flags = 0;
 		}
 	}
-	if (adapter->have_msi) {
-		flags &= ~IRQF_SHARED;
-		err = request_irq(adapter->pdev->irq, &e1000_intr_msi, flags,
-		                  netdev->name, netdev);
-		if (err)
-			DPRINTK(PROBE, ERR,
-			       "Unable to allocate interrupt Error: %d\n", err);
-	} else
-#endif
-	if ((err = request_irq(adapter->pdev->irq, &e1000_intr, flags,
-	                       netdev->name, netdev)))
+
+	err = request_irq(adapter->pdev->irq, handler, irq_flags, netdev->name,
+	                  netdev);
+	if (err) {
+		if (adapter->have_msi)
+			pci_disable_msi(adapter->pdev);
 		DPRINTK(PROBE, ERR,
 		        "Unable to allocate interrupt Error: %d\n", err);
+	}
 
 	return err;
 }
@@ -335,10 +328,8 @@ static void e1000_free_irq(struct e1000_adapter *adapter)
 
 	free_irq(adapter->pdev->irq, netdev);
 
-#ifdef CONFIG_PCI_MSI
 	if (adapter->have_msi)
 		pci_disable_msi(adapter->pdev);
-#endif
 }
 
 /**
@@ -3744,7 +3735,6 @@ e1000_update_stats(struct e1000_adapter *adapter)
 
 	spin_unlock_irqrestore(&adapter->stats_lock, flags);
 }
-#ifdef CONFIG_PCI_MSI
 
 /**
  * e1000_intr_msi - Interrupt Handler
@@ -3810,7 +3800,6 @@ e1000_intr_msi(int irq, void *data)
 
 	return IRQ_HANDLED;
 }
-#endif
 
 /**
  * e1000_intr - Interrupt Handler
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index b666a0c..f5b3cba 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1025,6 +1025,15 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	dev->trans_start = jiffies;
 
+	/* The powerpc-specific eieio() is used, as wmb() has too strong
+	 * semantics (it requires synchronization between cacheable and
+	 * uncacheable mappings, which eieio doesn't provide and which we
+	 * don't need), thus requiring a more expensive sync instruction.  At
+	 * some point, the set of architecture-independent barrier functions
+	 * should be expanded to include weaker barriers.
+	 */
+
+	eieio();
 	txbdp->status = status;
 
 	/* If this was the last BD in the ring, the next one */
@@ -1301,6 +1310,7 @@ struct sk_buff * gfar_new_skb(struct net_device *dev, struct rxbd8 *bdp)
 	bdp->length = 0;
 
 	/* Mark the buffer empty */
+	eieio();
 	bdp->status |= (RXBD_EMPTY | RXBD_INTERRUPT);
 
 	return skb;
@@ -1484,6 +1494,7 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 	bdp = priv->cur_rx;
 
 	while (!((bdp->status & RXBD_EMPTY) || (--rx_work_limit < 0))) {
+		rmb();
 		skb = priv->rx_skbuff[priv->skb_currx];
 
 		if (!(bdp->status &
diff --git a/drivers/net/ibm_emac/ibm_emac_core.c b/drivers/net/ibm_emac/ibm_emac_core.c
index 50035eb..f752e5f 100644
--- a/drivers/net/ibm_emac/ibm_emac_core.c
+++ b/drivers/net/ibm_emac/ibm_emac_core.c
@@ -926,7 +926,7 @@ static int emac_link_differs(struct ocp_enet_private *dev)
 	int duplex = r & EMAC_MR1_FDE ? DUPLEX_FULL : DUPLEX_HALF;
 	int speed, pause, asym_pause;
 
-	if (r & (EMAC_MR1_MF_1000 | EMAC_MR1_MF_1000GPCS))
+	if (r & EMAC_MR1_MF_1000)
 		speed = SPEED_1000;
 	else if (r & EMAC_MR1_MF_100)
 		speed = SPEED_100;
diff --git a/drivers/net/ibm_emac/ibm_emac_mal.c b/drivers/net/ibm_emac/ibm_emac_mal.c
index 6c0f071..cabd984 100644
--- a/drivers/net/ibm_emac/ibm_emac_mal.c
+++ b/drivers/net/ibm_emac/ibm_emac_mal.c
@@ -59,8 +59,7 @@ int __init mal_register_commac(struct ibm_ocp_mal *mal,
 	return 0;
 }
 
-void __exit mal_unregister_commac(struct ibm_ocp_mal *mal,
-				  struct mal_commac *commac)
+void mal_unregister_commac(struct ibm_ocp_mal *mal, struct mal_commac *commac)
 {
 	unsigned long flags;
 	local_irq_save(flags);
diff --git a/drivers/net/ibm_emac/ibm_emac_mal.h b/drivers/net/ibm_emac/ibm_emac_mal.h
index 407d2ac..64bc338 100644
--- a/drivers/net/ibm_emac/ibm_emac_mal.h
+++ b/drivers/net/ibm_emac/ibm_emac_mal.h
@@ -223,8 +223,7 @@ void mal_exit(void) __exit;
 
 int mal_register_commac(struct ibm_ocp_mal *mal,
 			struct mal_commac *commac) __init;
-void mal_unregister_commac(struct ibm_ocp_mal *mal,
-			   struct mal_commac *commac) __exit;
+void mal_unregister_commac(struct ibm_ocp_mal *mal, struct mal_commac *commac);
 int mal_set_rcbs(struct ibm_ocp_mal *mal, int channel, unsigned long size);
 
 /* Returns BD ring offset for a particular channel
diff --git a/drivers/net/ibm_emac/ibm_emac_phy.c b/drivers/net/ibm_emac/ibm_emac_phy.c
index 9074f76..e57862b 100644
--- a/drivers/net/ibm_emac/ibm_emac_phy.c
+++ b/drivers/net/ibm_emac/ibm_emac_phy.c
@@ -22,6 +22,7 @@
 
 #include <asm/ocp.h>
 
+#include "ibm_emac_core.h"
 #include "ibm_emac_phy.h"
 
 static inline int phy_read(struct mii_phy *phy, int reg)
@@ -34,11 +35,39 @@ static inline void phy_write(struct mii_phy *phy, int reg, int val)
 	phy->mdio_write(phy->dev, phy->address, reg, val);
 }
 
-int mii_reset_phy(struct mii_phy *phy)
+/*
+ * polls MII_BMCR until BMCR_RESET bit clears or operation times out.
+ *
+ * returns:
+ *	>= 0 => success, value in BMCR returned to caller
+ *	-EBUSY => failure, RESET bit never cleared
+ *	otherwise => failure, lower level PHY read failed
+ */
+static int mii_spin_reset_complete(struct mii_phy *phy)
 {
 	int val;
 	int limit = 10000;
 
+	while (limit--) {
+		val = phy_read(phy, MII_BMCR);
+		if (val >= 0 && !(val & BMCR_RESET))
+			return val;	/* success */
+		udelay(10);
+	}
+	if (val & BMCR_RESET)
+		val = -EBUSY;
+
+	if (net_ratelimit())
+		printk(KERN_ERR "emac%d: PHY reset timeout (%d)\n", 
+		       ((struct ocp_enet_private *)phy->dev->priv)->def->index,
+		       val);
+	return val;		    
+}
+
+int mii_reset_phy(struct mii_phy *phy)
+{
+	int val;
+
 	val = phy_read(phy, MII_BMCR);
 	val &= ~BMCR_ISOLATE;
 	val |= BMCR_RESET;
@@ -46,16 +75,11 @@ int mii_reset_phy(struct mii_phy *phy)
 
 	udelay(300);
 
-	while (limit--) {
-		val = phy_read(phy, MII_BMCR);
-		if (val >= 0 && (val & BMCR_RESET) == 0)
-			break;
-		udelay(10);
-	}
-	if ((val & BMCR_ISOLATE) && limit > 0)
+	val = mii_spin_reset_complete(phy);
+	if (val >= 0 && (val & BMCR_ISOLATE))
 		phy_write(phy, MII_BMCR, val & ~BMCR_ISOLATE);
 
-	return limit <= 0;
+	return val < 0;
 }
 
 static int genmii_setup_aneg(struct mii_phy *phy, u32 advertise)
@@ -102,8 +126,14 @@ static int genmii_setup_aneg(struct mii_phy *phy, u32 advertise)
 	}
 
 	/* Start/Restart aneg */
-	ctl = phy_read(phy, MII_BMCR);
-	ctl |= (BMCR_ANENABLE | BMCR_ANRESTART);
+	/* on some PHYs (e.g. National DP83843) a write to MII_ADVERTISE
+	 * causes BMCR_RESET to be set on the next read of MII_BMCR, which
+	 * if not checked for causes the PHY to be reset below */
+	ctl = mii_spin_reset_complete(phy);
+	if (ctl < 0)
+		return ctl;
+
+	ctl |= BMCR_ANENABLE | BMCR_ANRESTART;
 	phy_write(phy, MII_BMCR, ctl);
 
 	return 0;
@@ -118,13 +148,13 @@ static int genmii_setup_forced(struct mii_phy *phy, int speed, int fd)
 	phy->duplex = fd;
 	phy->pause = phy->asym_pause = 0;
 
+	/* First reset the PHY */
+	mii_reset_phy(phy);
+
 	ctl = phy_read(phy, MII_BMCR);
 	if (ctl < 0)
 		return ctl;
-	ctl &= ~(BMCR_FULLDPLX | BMCR_SPEED100 | BMCR_ANENABLE);
-
-	/* First reset the PHY */
-	phy_write(phy, MII_BMCR, ctl | BMCR_RESET);
+	ctl &= ~(BMCR_FULLDPLX | BMCR_SPEED100 | BMCR_ANENABLE | BMCR_SPEED1000);
 
 	/* Select speed & duplex */
 	switch (speed) {
diff --git a/drivers/net/ibm_emac/ibm_emac_rgmii.c b/drivers/net/ibm_emac/ibm_emac_rgmii.c
index 53d281c..9dbb5e5 100644
--- a/drivers/net/ibm_emac/ibm_emac_rgmii.c
+++ b/drivers/net/ibm_emac/ibm_emac_rgmii.c
@@ -162,7 +162,7 @@ void rgmii_set_speed(struct ocp_device *ocpdev, int input, int speed)
 	out_be32(&dev->base->ssr, ssr);
 }
 
-void __exit __rgmii_fini(struct ocp_device *ocpdev, int input)
+void __rgmii_fini(struct ocp_device *ocpdev, int input)
 {
 	struct ibm_ocp_rgmii *dev = ocp_get_drvdata(ocpdev);
 	BUG_ON(!dev || dev->users == 0);
diff --git a/drivers/net/ibm_emac/ibm_emac_rgmii.h b/drivers/net/ibm_emac/ibm_emac_rgmii.h
index 117ea48..971e458 100644
--- a/drivers/net/ibm_emac/ibm_emac_rgmii.h
+++ b/drivers/net/ibm_emac/ibm_emac_rgmii.h
@@ -37,7 +37,7 @@ struct ibm_ocp_rgmii {
 #ifdef CONFIG_IBM_EMAC_RGMII
 int rgmii_attach(void *emac) __init;
 
-void __rgmii_fini(struct ocp_device *ocpdev, int input) __exit;
+void __rgmii_fini(struct ocp_device *ocpdev, int input);
 static inline void rgmii_fini(struct ocp_device *ocpdev, int input)
 {
 	if (ocpdev)
diff --git a/drivers/net/ibm_emac/ibm_emac_tah.c b/drivers/net/ibm_emac/ibm_emac_tah.c
index e287b45..3c2d5ba 100644
--- a/drivers/net/ibm_emac/ibm_emac_tah.c
+++ b/drivers/net/ibm_emac/ibm_emac_tah.c
@@ -63,7 +63,7 @@ int __init tah_attach(void *emac)
 	return 0;
 }
 
-void __exit __tah_fini(struct ocp_device *ocpdev)
+void __tah_fini(struct ocp_device *ocpdev)
 {
 	struct tah_regs *p = ocp_get_drvdata(ocpdev);
 	BUG_ON(!p);
diff --git a/drivers/net/ibm_emac/ibm_emac_tah.h b/drivers/net/ibm_emac/ibm_emac_tah.h
index 3815394..ccf6491 100644
--- a/drivers/net/ibm_emac/ibm_emac_tah.h
+++ b/drivers/net/ibm_emac/ibm_emac_tah.h
@@ -55,7 +55,7 @@ struct tah_regs {
 #ifdef CONFIG_IBM_EMAC_TAH
 int tah_attach(void *emac) __init;
 
-void __tah_fini(struct ocp_device *ocpdev) __exit;
+void __tah_fini(struct ocp_device *ocpdev);
 static inline void tah_fini(struct ocp_device *ocpdev)
 {
 	if (ocpdev)
diff --git a/drivers/net/ibm_emac/ibm_emac_zmii.c b/drivers/net/ibm_emac/ibm_emac_zmii.c
index 37dc8f3..2c0fdb0 100644
--- a/drivers/net/ibm_emac/ibm_emac_zmii.c
+++ b/drivers/net/ibm_emac/ibm_emac_zmii.c
@@ -215,7 +215,7 @@ void __zmii_set_speed(struct ocp_device *ocpdev, int input, int speed)
 	out_be32(&dev->base->ssr, ssr);
 }
 
-void __exit __zmii_fini(struct ocp_device *ocpdev, int input)
+void __zmii_fini(struct ocp_device *ocpdev, int input)
 {
 	struct ibm_ocp_zmii *dev = ocp_get_drvdata(ocpdev);
 	BUG_ON(!dev || dev->users == 0);
diff --git a/drivers/net/ibm_emac/ibm_emac_zmii.h b/drivers/net/ibm_emac/ibm_emac_zmii.h
index 972e3a4..fad6d8b 100644
--- a/drivers/net/ibm_emac/ibm_emac_zmii.h
+++ b/drivers/net/ibm_emac/ibm_emac_zmii.h
@@ -40,7 +40,7 @@ struct ibm_ocp_zmii {
 #ifdef CONFIG_IBM_EMAC_ZMII
 int zmii_attach(void *emac) __init;
 
-void __zmii_fini(struct ocp_device *ocpdev, int input) __exit;
+void __zmii_fini(struct ocp_device *ocpdev, int input);
 static inline void zmii_fini(struct ocp_device *ocpdev, int input)
 {
 	if (ocpdev)
diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index c8e9086..3569d5b 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -193,8 +193,6 @@ struct ixgb_adapter {
 	u16 msg_enable;
 	struct ixgb_hw_stats stats;
 	uint32_t alloc_rx_buff_failed;
-#ifdef CONFIG_PCI_MSI
 	boolean_t have_msi;
-#endif
 };
 #endif /* _IXGB_H_ */
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 6d2b059..991c883 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -227,7 +227,7 @@ int
 ixgb_up(struct ixgb_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
-	int err;
+	int err, irq_flags = IRQF_SHARED;
 	int max_frame = netdev->mtu + ENET_HEADER_SIZE + ENET_FCS_LENGTH;
 	struct ixgb_hw *hw = &adapter->hw;
 
@@ -246,26 +246,21 @@ ixgb_up(struct ixgb_adapter *adapter)
 	/* disable interrupts and get the hardware into a known state */
 	IXGB_WRITE_REG(&adapter->hw, IMC, 0xffffffff);
 
-#ifdef CONFIG_PCI_MSI
-	{
-	boolean_t pcix = (IXGB_READ_REG(&adapter->hw, STATUS) & 
-						  IXGB_STATUS_PCIX_MODE) ? TRUE : FALSE;
-	adapter->have_msi = TRUE;
-
-	if (!pcix)
-	   adapter->have_msi = FALSE;
-	else if((err = pci_enable_msi(adapter->pdev))) {
-		DPRINTK(PROBE, ERR,
-		 "Unable to allocate MSI interrupt Error: %d\n", err);
-		adapter->have_msi = FALSE;
+	/* only enable MSI if bus is in PCI-X mode */
+	if (IXGB_READ_REG(&adapter->hw, STATUS) & IXGB_STATUS_PCIX_MODE) {
+		err = pci_enable_msi(adapter->pdev);
+		if (!err) {
+			adapter->have_msi = 1;
+			irq_flags = 0;
+		}
 		/* proceed to try to request regular interrupt */
 	}
-	}
 
-#endif
-	if((err = request_irq(adapter->pdev->irq, &ixgb_intr,
-				  IRQF_SHARED | IRQF_SAMPLE_RANDOM,
-			          netdev->name, netdev))) {
+	err = request_irq(adapter->pdev->irq, &ixgb_intr, irq_flags,
+	                  netdev->name, netdev);
+	if (err) {
+		if (adapter->have_msi)
+			pci_disable_msi(adapter->pdev);
 		DPRINTK(PROBE, ERR,
 		 "Unable to allocate interrupt Error: %d\n", err);
 		return err;
@@ -307,11 +302,10 @@ ixgb_down(struct ixgb_adapter *adapter, boolean_t kill_watchdog)
 
 	ixgb_irq_disable(adapter);
 	free_irq(adapter->pdev->irq, netdev);
-#ifdef CONFIG_PCI_MSI
-	if(adapter->have_msi == TRUE)
+
+	if (adapter->have_msi)
 		pci_disable_msi(adapter->pdev);
 
-#endif
 	if(kill_watchdog)
 		del_timer_sync(&adapter->watchdog_timer);
 #ifdef CONFIG_IXGB_NAPI
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index cf0e96a..a368924 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1216,7 +1216,7 @@ u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctxid, int max)
 		/* Window = 1 */
 		writel(consumer,
 		       NETXEN_CRB_NORMALIZE(adapter,
-					    recv_crb_registers[ctxid].
+					    recv_crb_registers[adapter->portnum].
 					    crb_rcv_status_consumer));
 	}
 
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 104e204..832fd69 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -40,7 +40,6 @@
 #include <linux/if_vlan.h>
 #include <linux/prefetch.h>
 #include <linux/mii.h>
-#include <linux/dmi.h>
 
 #include <asm/irq.h>
 
@@ -151,8 +150,6 @@ static const char *yukon2_name[] = {
 	"FE",		/* 0xb7 */
 };
 
-static int dmi_blacklisted;
-
 /* Access to external PHY */
 static int gm_phy_write(struct sky2_hw *hw, unsigned port, u16 reg, u16 val)
 {
@@ -307,10 +304,13 @@ static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
 			   PHY_M_EC_MAC_S_MSK);
 		ectrl |= PHY_M_EC_MAC_S(MAC_TX_CLK_25_MHZ);
 
+		/* on PHY 88E1040 Rev.D0 (and newer) downshift control changed */
 		if (hw->chip_id == CHIP_ID_YUKON_EC)
+			/* set downshift counter to 3x and enable downshift */
 			ectrl |= PHY_M_EC_DSC_2(2) | PHY_M_EC_DOWN_S_ENA;
 		else
-			ectrl |= PHY_M_EC_M_DSC(2) | PHY_M_EC_S_DSC(3);
+			/* set master & slave downshift counter to 1x */
+			ectrl |= PHY_M_EC_M_DSC(0) | PHY_M_EC_S_DSC(1);
 
 		gm_phy_write(hw, port, PHY_MARV_EXT_CTRL, ectrl);
 	}
@@ -327,10 +327,12 @@ static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
 			/* enable automatic crossover */
 			ctrl |= PHY_M_PC_MDI_XMODE(PHY_M_PC_ENA_AUTO);
 
+			/* downshift on PHY 88E1112 and 88E1149 is changed */
 			if (sky2->autoneg == AUTONEG_ENABLE
 			    && (hw->chip_id == CHIP_ID_YUKON_XL
 				|| hw->chip_id == CHIP_ID_YUKON_EC_U
 				|| hw->chip_id == CHIP_ID_YUKON_EX)) {
+				/* set downshift counter to 3x and enable downshift */
 				ctrl &= ~PHY_M_PC_DSC_MSK;
 				ctrl |= PHY_M_PC_DSC(2) | PHY_M_PC_DOWN_S_ENA;
 			}
@@ -842,10 +844,12 @@ static inline struct tx_ring_info *tx_le_re(struct sky2_port *sky2,
 /* Update chip's next pointer */
 static inline void sky2_put_idx(struct sky2_hw *hw, unsigned q, u16 idx)
 {
-	q = Y2_QADDR(q, PREF_UNIT_PUT_IDX);
+	/* Make sure write' to descriptors are complete before we tell hardware */
 	wmb();
-	sky2_write16(hw, q, idx);
-	sky2_read16(hw, q);
+	sky2_write16(hw, Y2_QADDR(q, PREF_UNIT_PUT_IDX), idx);
+
+	/* Synchronize I/O on since next processor may write to tail */
+	mmiowb();
 }
 
 
@@ -977,6 +981,7 @@ stopped:
 
 	/* reset the Rx prefetch unit */
 	sky2_write32(hw, Y2_QADDR(rxq, PREF_UNIT_CTRL), PREF_UNIT_RST_SET);
+	mmiowb();
 }
 
 /* Clean out receive buffer area, assumes receiver hardware stopped */
@@ -1196,7 +1201,7 @@ static int sky2_rx_start(struct sky2_port *sky2)
 	}
 
 	/* Tell chip about available buffers */
-	sky2_write16(hw, Y2_QADDR(rxq, PREF_UNIT_PUT_IDX), sky2->rx_put);
+	sky2_put_idx(hw, rxq, sky2->rx_put);
 	return 0;
 nomem:
 	sky2_rx_clean(sky2);
@@ -1538,6 +1543,8 @@ static void sky2_tx_complete(struct sky2_port *sky2, u16 done)
 	}
 
 	sky2->tx_cons = idx;
+	smp_mb();
+
 	if (tx_avail(sky2) > MAX_SKB_TX_LE + 4)
 		netif_wake_queue(dev);
 }
@@ -1577,13 +1584,6 @@ static int sky2_down(struct net_device *dev)
 	imask &= ~portirq_msk[port];
 	sky2_write32(hw, B0_IMSK, imask);
 
-	/*
-	 * Both ports share the NAPI poll on port 0, so if necessary undo the
-	 * the disable that is done in dev_close.
-	 */
-	if (sky2->port == 0 && hw->ports > 1)
-		netif_poll_enable(dev);
-
 	sky2_gmac_reset(hw, port);
 
 	/* Stop transmitter */
@@ -2139,8 +2139,10 @@ static int sky2_status_intr(struct sky2_hw *hw, int to_do)
 		switch (le->opcode & ~HW_OWNER) {
 		case OP_RXSTAT:
 			skb = sky2_receive(dev, length, status);
-			if (!skb)
+			if (unlikely(!skb)) {
+				sky2->net_stats.rx_dropped++;
 				goto force_update;
+			}
 
 			skb->protocol = eth_type_trans(skb, dev);
 			sky2->net_stats.rx_packets++;
@@ -2221,6 +2223,7 @@ force_update:
 
 	/* Fully processed status ring so clear irq */
 	sky2_write32(hw, STAT_CTRL, SC_STAT_CLR_IRQ);
+	mmiowb();
 
 exit_loop:
 	if (buf_write[0]) {
@@ -2341,6 +2344,12 @@ static void sky2_mac_intr(struct sky2_hw *hw, unsigned port)
 		printk(KERN_INFO PFX "%s: mac interrupt status 0x%x\n",
 		       dev->name, status);
 
+	if (status & GM_IS_RX_CO_OV)
+		gma_read16(hw, port, GM_RX_IRQ_SRC);
+
+	if (status & GM_IS_TX_CO_OV)
+		gma_read16(hw, port, GM_TX_IRQ_SRC);
+
 	if (status & GM_IS_RX_FF_OR) {
 		++sky2->net_stats.rx_fifo_errors;
 		sky2_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_CLI_RX_FO);
@@ -2439,6 +2448,7 @@ static int sky2_poll(struct net_device *dev0, int *budget)
 	if (work_done < work_limit) {
 		netif_rx_complete(dev0);
 
+		/* end of interrupt, re-enables also acts as I/O synchronization */
 		sky2_read32(hw, B0_Y2_SP_LISR);
 		return 0;
 	} else {
@@ -2534,17 +2544,6 @@ static int __devinit sky2_init(struct sky2_hw *hw)
 		return -EOPNOTSUPP;
 	}
 
-
-	/* Some Gigabyte motherboards have 88e8056 but cause problems
-	 * There is some unresolved hardware related problem that causes
-	 * descriptor errors and receive data corruption.
-	 */
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U && dmi_blacklisted) {
-		dev_err(&hw->pdev->dev,
-			"88E8056 on this motherboard not supported\n");
-		return -EOPNOTSUPP;
-	}
-
 	hw->pmd_type = sky2_read8(hw, B2_PMD_TYP);
 	hw->ports = 1;
 	t8 = sky2_read8(hw, B2_Y2_HW_RES);
@@ -3910,24 +3909,8 @@ static struct pci_driver sky2_driver = {
 	.shutdown = sky2_shutdown,
 };
 
-static struct dmi_system_id __initdata broken_dmi_table[] = {
-	{
-		.ident = "Gigabyte 965P-S3",
-		.matches = {
-			DMI_MATCH(DMI_SYS_VENDOR, "Gigabyte Technology Co., Ltd."),
-			DMI_MATCH(DMI_PRODUCT_NAME, "965P-S3"),
-
-		},
-	},
-	{ }
-};
-
 static int __init sky2_init_module(void)
 {
-	/* Look for sick motherboards */
-	if (dmi_check_system(broken_dmi_table))
-		dmi_blacklisted = 1;
-
 	return pci_register_driver(&sky2_driver);
 }
 
diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index 108adbf..c3964c3 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -430,7 +430,8 @@ spider_net_prepare_rx_descr(struct spider_net_card *card,
 	/* and we need to have it 128 byte aligned, therefore we allocate a
 	 * bit more */
 	/* allocate an skb */
-	descr->skb = dev_alloc_skb(bufsize + SPIDER_NET_RXBUF_ALIGN - 1);
+	descr->skb = netdev_alloc_skb(card->netdev,
+				      bufsize + SPIDER_NET_RXBUF_ALIGN - 1);
 	if (!descr->skb) {
 		if (netif_msg_rx_err(card) && net_ratelimit())
 			pr_err("Not enough memory to allocate rx buffer\n");
