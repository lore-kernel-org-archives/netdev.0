From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes for .25
Date: Sat, 12 Apr 2008 05:30:12 -0400
Message-ID: <20080412093012.GA24827@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:35851 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754018AbYDLJaO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 05:30:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please pull from 'upstream-davem' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-davem

to receive the following updates:

 drivers/net/ehea/ehea.h            |    3 +-
 drivers/net/ehea/ehea_main.c       |   24 +++++++++++++++-
 drivers/net/forcedeth.c            |   26 ++++++++++++++++-
 drivers/net/fs_enet/fs_enet-main.c |    3 +-
 drivers/net/macb.c                 |   14 +++++----
 drivers/net/sc92031.c              |    1 +
 drivers/net/sky2.c                 |    1 +
 drivers/net/smc91x.c               |    2 +
 drivers/net/ucc_geth.c             |   53 ++++++++++++++++++++---------------
 drivers/net/wan/Kconfig            |    6 +++-
 10 files changed, 97 insertions(+), 36 deletions(-)

Atsushi Nemoto (2):
      macb: Call phy_disconnect on removing
      macb: Use semicolon instead of comma for statement

Ayaz Abdulla (1):
      forcedeth: mac address fix

Joakim Tjernlund (1):
      ucc_geth: fix non-functional fixed phy support

Krzysztof Halasa (1):
      Mark generic HDLC + PPP as broken.

Laurent Pinchart (1):
      fs_enet: Don't call NAPI functions when NAPI is not used.

Sonic Zhang (1):
      smc91x driver: fix bug: print warning only in interrupt mode

Stephen Hemminger (2):
      sky2: missing chip name for Yukon Supreme
      sc92031: sysfs link missing

Thomas Klein (1):
      ehea: Fix DLPAR memory add support

diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 93b7fb2..a8d3280 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -40,7 +40,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0089"
+#define DRV_VERSION	"EHEA_0090"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
@@ -371,6 +371,7 @@ struct ehea_port_res {
 	struct ehea_q_skb_arr rq2_skba;
 	struct ehea_q_skb_arr rq3_skba;
 	struct ehea_q_skb_arr sq_skba;
+	int sq_skba_size;
 	spinlock_t netif_queue;
 	int queue_stopped;
 	int swqe_refill_th;
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 07c742d..f460b62 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -349,7 +349,8 @@ static void ehea_refill_rq1(struct ehea_port_res *pr, int index, int nr_of_wqes)
 	pr->rq1_skba.os_skbs = 0;
 
 	if (unlikely(test_bit(__EHEA_STOP_XFER, &ehea_driver_flags))) {
-		pr->rq1_skba.index = index;
+		if (nr_of_wqes > 0)
+			pr->rq1_skba.index = index;
 		pr->rq1_skba.os_skbs = fill_wqes;
 		return;
 	}
@@ -1464,7 +1465,9 @@ static int ehea_init_port_res(struct ehea_port *port, struct ehea_port_res *pr,
 			  init_attr->act_nr_rwqes_rq2,
 			  init_attr->act_nr_rwqes_rq3);
 
-	ret = ehea_init_q_skba(&pr->sq_skba, init_attr->act_nr_send_wqes + 1);
+	pr->sq_skba_size = init_attr->act_nr_send_wqes + 1;
+
+	ret = ehea_init_q_skba(&pr->sq_skba, pr->sq_skba_size);
 	ret |= ehea_init_q_skba(&pr->rq1_skba, init_attr->act_nr_rwqes_rq1 + 1);
 	ret |= ehea_init_q_skba(&pr->rq2_skba, init_attr->act_nr_rwqes_rq2 + 1);
 	ret |= ehea_init_q_skba(&pr->rq3_skba, init_attr->act_nr_rwqes_rq3 + 1);
@@ -2621,6 +2624,22 @@ void ehea_purge_sq(struct ehea_qp *orig_qp)
 	}
 }
 
+void ehea_flush_sq(struct ehea_port *port)
+{
+	int i;
+
+	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
+		struct ehea_port_res *pr = &port->port_res[i];
+		int swqe_max = pr->sq_skba_size - 2 - pr->swqe_ll_count;
+		int k = 0;
+		while (atomic_read(&pr->swqe_avail) < swqe_max) {
+			msleep(5);
+			if (++k == 20)
+				break;
+		}
+	}
+}
+
 int ehea_stop_qps(struct net_device *dev)
 {
 	struct ehea_port *port = netdev_priv(dev);
@@ -2845,6 +2864,7 @@ static void ehea_rereg_mrs(struct work_struct *work)
 					if (dev->flags & IFF_UP) {
 						down(&port->port_lock);
 						netif_stop_queue(dev);
+						ehea_flush_sq(port);
 						ret = ehea_stop_qps(dev);
 						if (ret) {
 							up(&port->port_lock);
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 419f533..9f088a4 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -5316,8 +5316,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 
 	/* check the workaround bit for correct mac address order */
 	txreg = readl(base + NvRegTransmitPoll);
-	if ((txreg & NVREG_TRANSMITPOLL_MAC_ADDR_REV) ||
-	    (id->driver_data & DEV_HAS_CORRECT_MACADDR)) {
+	if (id->driver_data & DEV_HAS_CORRECT_MACADDR) {
 		/* mac address is already in correct order */
 		dev->dev_addr[0] = (np->orig_mac[0] >>  0) & 0xff;
 		dev->dev_addr[1] = (np->orig_mac[0] >>  8) & 0xff;
@@ -5325,6 +5324,22 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		dev->dev_addr[3] = (np->orig_mac[0] >> 24) & 0xff;
 		dev->dev_addr[4] = (np->orig_mac[1] >>  0) & 0xff;
 		dev->dev_addr[5] = (np->orig_mac[1] >>  8) & 0xff;
+	} else if (txreg & NVREG_TRANSMITPOLL_MAC_ADDR_REV) {
+		/* mac address is already in correct order */
+		dev->dev_addr[0] = (np->orig_mac[0] >>  0) & 0xff;
+		dev->dev_addr[1] = (np->orig_mac[0] >>  8) & 0xff;
+		dev->dev_addr[2] = (np->orig_mac[0] >> 16) & 0xff;
+		dev->dev_addr[3] = (np->orig_mac[0] >> 24) & 0xff;
+		dev->dev_addr[4] = (np->orig_mac[1] >>  0) & 0xff;
+		dev->dev_addr[5] = (np->orig_mac[1] >>  8) & 0xff;
+		/*
+		 * Set orig mac address back to the reversed version.
+		 * This flag will be cleared during low power transition.
+		 * Therefore, we should always put back the reversed address.
+		 */
+		np->orig_mac[0] = (dev->dev_addr[5] << 0) + (dev->dev_addr[4] << 8) +
+			(dev->dev_addr[3] << 16) + (dev->dev_addr[2] << 24);
+		np->orig_mac[1] = (dev->dev_addr[1] << 0) + (dev->dev_addr[0] << 8);
 	} else {
 		/* need to reverse mac address to correct order */
 		dev->dev_addr[0] = (np->orig_mac[1] >>  8) & 0xff;
@@ -5595,7 +5610,9 @@ out:
 static int nv_resume(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
+	u8 __iomem *base = get_hwbase(dev);
 	int rc = 0;
+	u32 txreg;
 
 	if (!netif_running(dev))
 		goto out;
@@ -5606,6 +5623,11 @@ static int nv_resume(struct pci_dev *pdev)
 	pci_restore_state(pdev);
 	pci_enable_wake(pdev, PCI_D0, 0);
 
+	/* restore mac address reverse flag */
+	txreg = readl(base + NvRegTransmitPoll);
+	txreg |= NVREG_TRANSMITPOLL_MAC_ADDR_REV;
+	writel(txreg, base + NvRegTransmitPoll);
+
 	rc = nv_open(dev);
 out:
 	return rc;
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index af869cf..940e204 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -835,7 +835,8 @@ static int fs_enet_close(struct net_device *dev)
 
 	netif_stop_queue(dev);
 	netif_carrier_off(dev);
-	napi_disable(&fep->napi);
+	if (fep->fpi->use_napi)
+		napi_disable(&fep->napi);
 	phy_stop(fep->phydev);
 
 	spin_lock_irqsave(&fep->lock, flags);
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 1d210ed..489c7c3 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -242,12 +242,12 @@ static int macb_mii_init(struct macb *bp)
 	/* Enable managment port */
 	macb_writel(bp, NCR, MACB_BIT(MPE));
 
-	bp->mii_bus.name = "MACB_mii_bus",
-	bp->mii_bus.read = &macb_mdio_read,
-	bp->mii_bus.write = &macb_mdio_write,
-	bp->mii_bus.reset = &macb_mdio_reset,
-	bp->mii_bus.id = bp->pdev->id,
-	bp->mii_bus.priv = bp,
+	bp->mii_bus.name = "MACB_mii_bus";
+	bp->mii_bus.read = &macb_mdio_read;
+	bp->mii_bus.write = &macb_mdio_write;
+	bp->mii_bus.reset = &macb_mdio_reset;
+	bp->mii_bus.id = bp->pdev->id;
+	bp->mii_bus.priv = bp;
 	bp->mii_bus.dev = &bp->dev->dev;
 	pdata = bp->pdev->dev.platform_data;
 
@@ -1257,6 +1257,8 @@ static int __exit macb_remove(struct platform_device *pdev)
 
 	if (dev) {
 		bp = netdev_priv(dev);
+		if (bp->phy_dev)
+			phy_disconnect(bp->phy_dev);
 		mdiobus_unregister(&bp->mii_bus);
 		kfree(bp->mii_bus.irq);
 		unregister_netdev(dev);
diff --git a/drivers/net/sc92031.c b/drivers/net/sc92031.c
index 37b4239..15fcee5 100644
--- a/drivers/net/sc92031.c
+++ b/drivers/net/sc92031.c
@@ -1446,6 +1446,7 @@ static int __devinit sc92031_probe(struct pci_dev *pdev,
 	}
 
 	pci_set_drvdata(pdev, dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 
 #if SC92031_USE_BAR == 0
 	dev->mem_start = pci_resource_start(pdev, SC92031_USE_BAR);
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 853bce0..f226bca 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -154,6 +154,7 @@ static const char *yukon2_name[] = {
 	"EC",		/* 0xb6 */
 	"FE",		/* 0xb7 */
 	"FE+",		/* 0xb8 */
+	"Supreme",	/* 0xb9 */
 };
 
 static void sky2_set_multicast(struct net_device *dev);
diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index 4020e9e..63a54e2 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -1326,9 +1326,11 @@ static irqreturn_t smc_interrupt(int irq, void *dev_id)
 	SMC_SET_INT_MASK(mask);
 	spin_unlock(&lp->lock);
 
+#ifndef CONFIG_NET_POLL_CONTROLLER
 	if (timeout == MAX_IRQ_LOOPS)
 		PRINTK("%s: spurious interrupt (mask = 0x%02x)\n",
 		       dev->name, mask);
+#endif
 	DBG(3, "%s: Interrupt done (%d loops)\n",
 	       dev->name, MAX_IRQ_LOOPS - timeout);
 
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 8cc3166..0ee4c16 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3833,6 +3833,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	struct device_node *phy;
 	int err, ucc_num, max_speed = 0;
 	const phandle *ph;
+	const u32 *fixed_link;
 	const unsigned int *prop;
 	const char *sprop;
 	const void *mac_addr;
@@ -3923,18 +3924,38 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 
 	ug_info->uf_info.regs = res.start;
 	ug_info->uf_info.irq = irq_of_parse_and_map(np, 0);
+	fixed_link = of_get_property(np, "fixed-link", NULL);
+	if (fixed_link) {
+		ug_info->mdio_bus = 0;
+		ug_info->phy_address = fixed_link[0];
+		phy = NULL;
+	} else {
+		ph = of_get_property(np, "phy-handle", NULL);
+		phy = of_find_node_by_phandle(*ph);
 
-	ph = of_get_property(np, "phy-handle", NULL);
-	phy = of_find_node_by_phandle(*ph);
+		if (phy == NULL)
+			return -ENODEV;
 
-	if (phy == NULL)
-		return -ENODEV;
+		/* set the PHY address */
+		prop = of_get_property(phy, "reg", NULL);
+		if (prop == NULL)
+			return -1;
+		ug_info->phy_address = *prop;
+
+		/* Set the bus id */
+		mdio = of_get_parent(phy);
+
+		if (mdio == NULL)
+			return -1;
 
-	/* set the PHY address */
-	prop = of_get_property(phy, "reg", NULL);
-	if (prop == NULL)
-		return -1;
-	ug_info->phy_address = *prop;
+		err = of_address_to_resource(mdio, 0, &res);
+		of_node_put(mdio);
+
+		if (err)
+			return -1;
+
+		ug_info->mdio_bus = res.start;
+	}
 
 	/* get the phy interface type, or default to MII */
 	prop = of_get_property(np, "phy-connection-type", NULL);
@@ -3979,20 +4000,6 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 		ug_info->numThreadsRx = UCC_GETH_NUM_OF_THREADS_4;
 	}
 
-	/* Set the bus id */
-	mdio = of_get_parent(phy);
-
-	if (mdio == NULL)
-		return -1;
-
-	err = of_address_to_resource(mdio, 0, &res);
-	of_node_put(mdio);
-
-	if (err)
-		return -1;
-
-	ug_info->mdio_bus = res.start;
-
 	if (netif_msg_probe(&debug))
 		printk(KERN_INFO "ucc_geth: UCC%1d at 0x%8x (irq = %d) \n",
 			ug_info->uf_info.ucc_num + 1, ug_info->uf_info.regs,
diff --git a/drivers/net/wan/Kconfig b/drivers/net/wan/Kconfig
index a3df09e..8005dd1 100644
--- a/drivers/net/wan/Kconfig
+++ b/drivers/net/wan/Kconfig
@@ -150,9 +150,13 @@ config HDLC_FR
 
 config HDLC_PPP
 	tristate "Synchronous Point-to-Point Protocol (PPP) support"
-	depends on HDLC
+	depends on HDLC && BROKEN
 	help
 	  Generic HDLC driver supporting PPP over WAN connections.
+	  This module is currently broken and will cause a kernel panic
+	  when a device configured in PPP mode is activated.
+
+	  It will be replaced by new PPP implementation in Linux 2.6.26.
 
 	  If unsure, say N.
 
