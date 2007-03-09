From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Fri, 9 Mar 2007 12:33:42 -0500
Message-ID: <20070309173342.GA16013@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:33966 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752692AbXCIRdn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 12:33:43 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/3c59x.c                         |   28 ++++++++---------
 drivers/net/mv643xx_eth.c                   |   10 ++++--
 drivers/net/myri10ge/myri10ge.c             |   42 +++++++++++++++++++++------
 drivers/net/netxen/netxen_nic_hw.c          |    5 ++-
 drivers/net/r8169.c                         |   14 ++++----
 drivers/net/sky2.c                          |   24 +++++++++++++--
 drivers/net/tokenring/ibmtr.c               |   25 +++++++--------
 drivers/net/via-rhine.c                     |   32 +++++++++++++++++++-
 drivers/net/wan/z85230.c                    |    2 +-
 drivers/net/wireless/bcm43xx/bcm43xx_main.c |    6 ++--
 drivers/net/wireless/bcm43xx/bcm43xx_phy.c  |   10 +++++-
 drivers/net/wireless/bcm43xx/bcm43xx_wx.c   |   10 +++++-
 12 files changed, 145 insertions(+), 63 deletions(-)

Alan Cox (1):
      z85230: Fix FIFO handling

Brice Goglin (4):
      myri10ge: fix error checking and return value in myri10ge_allocate_rings
      myri10ge: use pci_map_page to prepare the dmatest buffer
      myri10ge: prevent 4k rdma on SGI TIOCE chipset
      myri10ge: add a wc_enabled flag to myri10ge_priv

Dale Farnsworth (1):
      mv643xx: Clear pending interrupts before calling request_irq

Francois Romieu (2):
      r8169: revert bogus BMCR reset
      r8169: fix a race between PCI probe and dev_open

Joerg Sommer (1):
      bcm43xx: Fix bug in frequency to channel conversion

Larry Finger (1):
      bcm43xx: Fix errors in specs to code translation in B6PHY init

Pavel Roskin (1):
      bcm43xx: Fix assertion failures in interrupt handler

Ralf Baechle (3):
      netxen: fix warnings
      3c59x: Fix several modpost warnings
      ibmtr: Drain rich supply of modpost warnings.

Roger Luethi (1):
      via-rhine: set avoid_D3 for broken BIOSes

Stephen Hemminger (1):
      sky2: turn off Rx checksum on bad hardware

diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 7299577..b406ecf 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -858,19 +858,7 @@ static struct eisa_device_id vortex_eisa_ids[] = {
 };
 MODULE_DEVICE_TABLE(eisa, vortex_eisa_ids);
 
-static int vortex_eisa_probe(struct device *device);
-static int vortex_eisa_remove(struct device *device);
-
-static struct eisa_driver vortex_eisa_driver = {
-	.id_table = vortex_eisa_ids,
-	.driver   = {
-		.name    = "3c59x",
-		.probe   = vortex_eisa_probe,
-		.remove  = vortex_eisa_remove
-	}
-};
-
-static int vortex_eisa_probe(struct device *device)
+static int __init vortex_eisa_probe(struct device *device)
 {
 	void __iomem *ioaddr;
 	struct eisa_device *edev;
@@ -893,7 +881,7 @@ static int vortex_eisa_probe(struct device *device)
 	return 0;
 }
 
-static int vortex_eisa_remove(struct device *device)
+static int __devexit vortex_eisa_remove(struct device *device)
 {
 	struct eisa_device *edev;
 	struct net_device *dev;
@@ -918,7 +906,17 @@ static int vortex_eisa_remove(struct device *device)
 	free_netdev(dev);
 	return 0;
 }
-#endif
+
+static struct eisa_driver vortex_eisa_driver = {
+	.id_table = vortex_eisa_ids,
+	.driver   = {
+		.name    = "3c59x",
+		.probe   = vortex_eisa_probe,
+		.remove  = __devexit_p(vortex_eisa_remove)
+	}
+};
+
+#endif /* CONFIG_EISA */
 
 /* returns count found (>= 0), or negative on error */
 static int __init vortex_eisa_init(void)
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 9ba21e0..1ee27c3 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -787,6 +787,12 @@ static int mv643xx_eth_open(struct net_device *dev)
 	unsigned int size;
 	int err;
 
+	/* Clear any pending ethernet port interrupts */
+	mv_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num), 0);
+	mv_write(MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
+	/* wait for previous write to complete */
+	mv_read (MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num));
+
 	err = request_irq(dev->irq, mv643xx_eth_int_handler,
 			IRQF_SHARED | IRQF_SAMPLE_RANDOM, dev->name, dev);
 	if (err) {
@@ -875,10 +881,6 @@ static int mv643xx_eth_open(struct net_device *dev)
 
 	mv643xx_eth_rx_refill_descs(dev);	/* Fill RX ring with skb's */
 
-	/* Clear any pending ethernet port interrupts */
-	mv_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num), 0);
-	mv_write(MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
-
 	eth_port_start(dev);
 
 	/* Interrupt Coalescing */
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index b05dc6e..ac02b3b 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -181,6 +181,7 @@ struct myri10ge_priv {
 	int intr_coal_delay;
 	__be32 __iomem *intr_coal_delay_ptr;
 	int mtrr;
+	int wc_enabled;
 	int wake_queue;
 	int stop_queue;
 	int down_cnt;
@@ -717,6 +718,8 @@ static int myri10ge_reset(struct myri10ge_priv *mgp)
 	int status;
 	size_t bytes;
 	u32 len;
+	struct page *dmatest_page;
+	dma_addr_t dmatest_bus;
 
 	/* try to send a reset command to the card to see if it
 	 * is alive */
@@ -726,6 +729,11 @@ static int myri10ge_reset(struct myri10ge_priv *mgp)
 		dev_err(&mgp->pdev->dev, "failed reset\n");
 		return -ENXIO;
 	}
+	dmatest_page = alloc_page(GFP_KERNEL);
+	if (!dmatest_page)
+		return -ENOMEM;
+	dmatest_bus = pci_map_page(mgp->pdev, dmatest_page, 0, PAGE_SIZE,
+				   DMA_BIDIRECTIONAL);
 
 	/* Now exchange information about interrupts  */
 
@@ -764,8 +772,8 @@ static int myri10ge_reset(struct myri10ge_priv *mgp)
 
 	len = mgp->tx.boundary;
 
-	cmd.data0 = MYRI10GE_LOWPART_TO_U32(mgp->rx_done.bus);
-	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(mgp->rx_done.bus);
+	cmd.data0 = MYRI10GE_LOWPART_TO_U32(dmatest_bus);
+	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(dmatest_bus);
 	cmd.data2 = len * 0x10000;
 	status = myri10ge_send_cmd(mgp, MXGEFW_DMA_TEST, &cmd, 0);
 	if (status == 0)
@@ -774,8 +782,8 @@ static int myri10ge_reset(struct myri10ge_priv *mgp)
 	else
 		dev_warn(&mgp->pdev->dev, "DMA read benchmark failed: %d\n",
 			 status);
-	cmd.data0 = MYRI10GE_LOWPART_TO_U32(mgp->rx_done.bus);
-	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(mgp->rx_done.bus);
+	cmd.data0 = MYRI10GE_LOWPART_TO_U32(dmatest_bus);
+	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(dmatest_bus);
 	cmd.data2 = len * 0x1;
 	status = myri10ge_send_cmd(mgp, MXGEFW_DMA_TEST, &cmd, 0);
 	if (status == 0)
@@ -785,8 +793,8 @@ static int myri10ge_reset(struct myri10ge_priv *mgp)
 		dev_warn(&mgp->pdev->dev, "DMA write benchmark failed: %d\n",
 			 status);
 
-	cmd.data0 = MYRI10GE_LOWPART_TO_U32(mgp->rx_done.bus);
-	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(mgp->rx_done.bus);
+	cmd.data0 = MYRI10GE_LOWPART_TO_U32(dmatest_bus);
+	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(dmatest_bus);
 	cmd.data2 = len * 0x10001;
 	status = myri10ge_send_cmd(mgp, MXGEFW_DMA_TEST, &cmd, 0);
 	if (status == 0)
@@ -796,6 +804,9 @@ static int myri10ge_reset(struct myri10ge_priv *mgp)
 		dev_warn(&mgp->pdev->dev,
 			 "DMA read/write benchmark failed: %d\n", status);
 
+	pci_unmap_page(mgp->pdev, dmatest_bus, PAGE_SIZE, DMA_BIDIRECTIONAL);
+	put_page(dmatest_page);
+
 	memset(mgp->rx_done.entry, 0, bytes);
 
 	/* reset mcp/driver shared state back to 0 */
@@ -1375,7 +1386,7 @@ myri10ge_get_ethtool_stats(struct net_device *netdev,
 		data[i] = ((unsigned long *)&mgp->stats)[i];
 
 	data[i++] = (unsigned int)mgp->tx.boundary;
-	data[i++] = (unsigned int)(mgp->mtrr >= 0);
+	data[i++] = (unsigned int)mgp->wc_enabled;
 	data[i++] = (unsigned int)mgp->pdev->irq;
 	data[i++] = (unsigned int)mgp->msi_enabled;
 	data[i++] = (unsigned int)mgp->read_dma;
@@ -1456,6 +1467,8 @@ static int myri10ge_allocate_rings(struct net_device *dev)
 	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_SEND_RING_SIZE, &cmd, 0);
 	tx_ring_size = cmd.data0;
 	status |= myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_RX_RING_SIZE, &cmd, 0);
+	if (status != 0)
+		return status;
 	rx_ring_size = cmd.data0;
 
 	tx_ring_entries = tx_ring_size / sizeof(struct mcp_kreq_ether_send);
@@ -1463,6 +1476,8 @@ static int myri10ge_allocate_rings(struct net_device *dev)
 	mgp->tx.mask = tx_ring_entries - 1;
 	mgp->rx_small.mask = mgp->rx_big.mask = rx_ring_entries - 1;
 
+	status = -ENOMEM;
+
 	/* allocate the host shadow rings */
 
 	bytes = 8 + (MYRI10GE_MAX_SEND_DESC_TSO + 4)
@@ -1735,7 +1750,7 @@ static int myri10ge_open(struct net_device *dev)
 		goto abort_with_irq;
 	}
 
-	if (myri10ge_wcfifo && mgp->mtrr >= 0) {
+	if (myri10ge_wcfifo && mgp->wc_enabled) {
 		mgp->tx.wc_fifo = (u8 __iomem *) mgp->sram + MXGEFW_ETH_SEND_4;
 		mgp->rx_small.wc_fifo =
 		    (u8 __iomem *) mgp->sram + MXGEFW_ETH_RECV_SMALL;
@@ -2510,6 +2525,12 @@ static void myri10ge_select_firmware(struct myri10ge_priv *mgp)
 				 bridge->vendor, bridge->device);
 			mgp->tx.boundary = 4096;
 			mgp->fw_name = myri10ge_fw_aligned;
+		} else if (bridge &&
+			   bridge->vendor == PCI_VENDOR_ID_SGI &&
+			   bridge->device == 0x4002 /* TIOCE pcie-port */ ) {
+			/* this pcie bridge does not support 4K rdma request */
+			mgp->tx.boundary = 2048;
+			mgp->fw_name = myri10ge_fw_aligned;
 		}
 	} else {
 		if (myri10ge_force_firmware == 1) {
@@ -2830,9 +2851,12 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	mgp->board_span = pci_resource_len(pdev, 0);
 	mgp->iomem_base = pci_resource_start(pdev, 0);
 	mgp->mtrr = -1;
+	mgp->wc_enabled = 0;
 #ifdef CONFIG_MTRR
 	mgp->mtrr = mtrr_add(mgp->iomem_base, mgp->board_span,
 			     MTRR_TYPE_WRCOMB, 1);
+	if (mgp->mtrr >= 0)
+		mgp->wc_enabled = 1;
 #endif
 	/* Hack.  need to get rid of these magic numbers */
 	mgp->sram_size =
@@ -2927,7 +2951,7 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev_info(dev, "%s IRQ %d, tx bndry %d, fw %s, WC %s\n",
 		 (mgp->msi_enabled ? "MSI" : "xPIC"),
 		 netdev->irq, mgp->tx.boundary, mgp->fw_name,
-		 (mgp->mtrr >= 0 ? "Enabled" : "Disabled"));
+		 (mgp->wc_enabled ? "Enabled" : "Disabled"));
 
 	return 0;
 
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index a2877f3..1be5570 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -228,7 +228,7 @@ int netxen_nic_hw_resources(struct netxen_adapter *adapter)
 			    &adapter->ctx_desc_pdev);
 
 	printk("ctx_desc_phys_addr: 0x%llx\n",
-	       (u64) adapter->ctx_desc_phys_addr);
+	       (unsigned long long) adapter->ctx_desc_phys_addr);
 	if (addr == NULL) {
 		DPRINTK(ERR, "bad return from pci_alloc_consistent\n");
 		err = -ENOMEM;
@@ -247,7 +247,8 @@ int netxen_nic_hw_resources(struct netxen_adapter *adapter)
 			    adapter->max_tx_desc_count,
 			    (dma_addr_t *) & hw->cmd_desc_phys_addr,
 			    &adapter->ahw.cmd_desc_pdev);
-	printk("cmd_desc_phys_addr: 0x%llx\n", (u64) hw->cmd_desc_phys_addr);
+	printk("cmd_desc_phys_addr: 0x%llx\n",
+	       (unsigned long long) hw->cmd_desc_phys_addr);
 
 	if (addr == NULL) {
 		DPRINTK(ERR, "bad return from pci_alloc_consistent\n");
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 15d954e..521b5f0 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -572,8 +572,8 @@ static void rtl8169_xmii_reset_enable(void __iomem *ioaddr)
 {
 	unsigned int val;
 
-	mdio_write(ioaddr, MII_BMCR, BMCR_RESET);
-	val = mdio_read(ioaddr, MII_BMCR);
+	val = mdio_read(ioaddr, MII_BMCR) | BMCR_RESET;
+	mdio_write(ioaddr, MII_BMCR, val & 0xffff);
 }
 
 static void rtl8169_check_link_status(struct net_device *dev,
@@ -1368,11 +1368,7 @@ static inline void rtl8169_request_timer(struct net_device *dev)
 	    (tp->phy_version >= RTL_GIGA_PHY_VER_H))
 		return;
 
-	init_timer(timer);
-	timer->expires = jiffies + RTL8169_PHY_TIMEOUT;
-	timer->data = (unsigned long)(dev);
-	timer->function = rtl8169_phy_timer;
-	add_timer(timer);
+	mod_timer(timer, jiffies + RTL8169_PHY_TIMEOUT);
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -1685,6 +1681,10 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp->mmio_addr = ioaddr;
 	tp->align = rtl_cfg_info[ent->driver_data].align;
 
+	init_timer(&tp->timer);
+	tp->timer.data = (unsigned long) dev;
+	tp->timer.function = rtl8169_phy_timer;
+
 	spin_lock_init(&tp->lock);
 
 	rc = register_netdev(dev);
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 5383997..ab0ab92 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -2165,9 +2165,27 @@ force_update:
 			/* fall through */
 #endif
 		case OP_RXCHKS:
-			skb = sky2->rx_ring[sky2->rx_next].skb;
-			skb->ip_summed = CHECKSUM_COMPLETE;
-			skb->csum = status & 0xffff;
+			if (!sky2->rx_csum)
+				break;
+
+			/* Both checksum counters are programmed to start at
+			 * the same offset, so unless there is a problem they
+			 * should match. This failure is an early indication that
+			 * hardware receive checksumming won't work.
+			 */
+			if (likely(status >> 16 == (status & 0xffff))) {
+				skb = sky2->rx_ring[sky2->rx_next].skb;
+				skb->ip_summed = CHECKSUM_COMPLETE;
+				skb->csum = status & 0xffff;
+			} else {
+				printk(KERN_NOTICE PFX "%s: hardware receive "
+				       "checksum problem (status = %#x)\n",
+				       dev->name, status);
+				sky2->rx_csum = 0;
+				sky2_write32(sky2->hw,
+					     Q_ADDR(rxqaddr[le->link], Q_CSR),
+					     BMU_DIS_RX_CHKSUM);
+			}
 			break;
 
 		case OP_TXINDEXLE:
diff --git a/drivers/net/tokenring/ibmtr.c b/drivers/net/tokenring/ibmtr.c
index 0d97e10..36202e9 100644
--- a/drivers/net/tokenring/ibmtr.c
+++ b/drivers/net/tokenring/ibmtr.c
@@ -186,7 +186,6 @@ static char __devinit *adapter_def(char type)
 #define TRC_INITV 0x02		/*  verbose init trace points     */
 static unsigned char ibmtr_debug_trace = 0;
 
-static int 	ibmtr_probe(struct net_device *dev);
 static int	ibmtr_probe1(struct net_device *dev, int ioaddr);
 static unsigned char get_sram_size(struct tok_info *adapt_info);
 static int 	trdev_init(struct net_device *dev);
@@ -335,17 +334,6 @@ static void ibmtr_cleanup_card(struct net_device *dev)
 #endif		
 }
 
-int ibmtr_probe_card(struct net_device *dev)
-{
-	int err = ibmtr_probe(dev);
-	if (!err) {
-		err = register_netdev(dev);
-		if (err)
-			ibmtr_cleanup_card(dev);
-	}
-	return err;
-}
-
 /****************************************************************************
  *	ibmtr_probe():  Routine specified in the network device structure
  *	to probe for an IBM Token Ring Adapter.  Routine outline:
@@ -358,7 +346,7 @@ int ibmtr_probe_card(struct net_device *dev)
  *	which references it.
  ****************************************************************************/
 
-static int ibmtr_probe(struct net_device *dev)
+static int __init ibmtr_probe(struct net_device *dev)
 {
 	int i;
 	int base_addr = dev->base_addr;
@@ -378,6 +366,17 @@ static int ibmtr_probe(struct net_device *dev)
 	return -ENODEV;
 }
 
+int __init ibmtr_probe_card(struct net_device *dev)
+{
+	int err = ibmtr_probe(dev);
+	if (!err) {
+		err = register_netdev(dev);
+		if (err)
+			ibmtr_cleanup_card(dev);
+	}
+	return err;
+}
+
 /*****************************************************************************/
 
 static int __devinit ibmtr_probe1(struct net_device *dev, int PIOaddr)
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index ebbda1d..f3a972e 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -30,8 +30,8 @@
 */
 
 #define DRV_NAME	"via-rhine"
-#define DRV_VERSION	"1.4.2"
-#define DRV_RELDATE	"Sept-11-2006"
+#define DRV_VERSION	"1.4.3"
+#define DRV_RELDATE	"2007-03-06"
 
 
 /* A few user-configurable values.
@@ -105,6 +105,7 @@ static const int multicast_filter_limit = 32;
 #include <asm/io.h>
 #include <asm/irq.h>
 #include <asm/uaccess.h>
+#include <linux/dmi.h>
 
 /* These identify the driver base version and may not be removed. */
 static char version[] __devinitdata =
@@ -1995,6 +1996,23 @@ static struct pci_driver rhine_driver = {
 	.shutdown =	rhine_shutdown,
 };
 
+static struct dmi_system_id __initdata rhine_dmi_table[] = {
+	{
+		.ident = "EPIA-M",
+		.matches = {
+			DMI_MATCH(DMI_BIOS_VENDOR, "Award Software International, Inc."),
+			DMI_MATCH(DMI_BIOS_VERSION, "6.00 PG"),
+		},
+	},
+	{
+		.ident = "KV7",
+		.matches = {
+			DMI_MATCH(DMI_BIOS_VENDOR, "Phoenix Technologies, LTD"),
+			DMI_MATCH(DMI_BIOS_VERSION, "6.00 PG"),
+		},
+	},
+	{ NULL }
+};
 
 static int __init rhine_init(void)
 {
@@ -2002,6 +2020,16 @@ static int __init rhine_init(void)
 #ifdef MODULE
 	printk(version);
 #endif
+	if (dmi_check_system(rhine_dmi_table)) {
+		/* these BIOSes fail at PXE boot if chip is in D3 */
+		avoid_D3 = 1;
+		printk(KERN_WARNING "%s: Broken BIOS detected, avoid_D3 "
+				    "enabled.\n",
+		       DRV_NAME);
+	}
+	else if (avoid_D3)
+		printk(KERN_INFO "%s: avoid_D3 set.\n", DRV_NAME);
+
 	return pci_register_driver(&rhine_driver);
 }
 
diff --git a/drivers/net/wan/z85230.c b/drivers/net/wan/z85230.c
index 8dbcf83..8b4540b 100644
--- a/drivers/net/wan/z85230.c
+++ b/drivers/net/wan/z85230.c
@@ -407,7 +407,7 @@ static void z8530_tx(struct z8530_channel *c)
 	while(c->txcount) {
 		/* FIFO full ? */
 		if(!(read_zsreg(c, R0)&4))
-			break;
+			return;
 		c->txcount--;
 		/*
 		 *	Shovel out the byte
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
index e594af4..80cb88e 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -1858,9 +1858,6 @@ static irqreturn_t bcm43xx_interrupt_handler(int irq, void *dev_id)
 
 	spin_lock(&bcm->irq_lock);
 
-	assert(bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED);
-	assert(bcm->current_core->id == BCM43xx_COREID_80211);
-
 	reason = bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON);
 	if (reason == 0xffffffff) {
 		/* irq not for us (shared irq) */
@@ -1871,6 +1868,9 @@ static irqreturn_t bcm43xx_interrupt_handler(int irq, void *dev_id)
 	if (!reason)
 		goto out;
 
+	assert(bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED);
+	assert(bcm->current_core->id == BCM43xx_COREID_80211);
+
 	bcm->dma_reason[0] = bcm43xx_read32(bcm, BCM43xx_MMIO_DMA0_REASON)
 			     & 0x0001DC00;
 	bcm->dma_reason[1] = bcm43xx_read32(bcm, BCM43xx_MMIO_DMA1_REASON)
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_phy.c b/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
index 3a5c9c2..cae8925 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
@@ -859,6 +859,11 @@ static void bcm43xx_phy_initb6(struct bcm43xx_private *bcm)
 		bcm43xx_radio_write16(bcm, 0x005D, 0x0088);
 		bcm43xx_radio_write16(bcm, 0x005E, 0x0088);
 		bcm43xx_radio_write16(bcm, 0x007D, 0x0088);
+		bcm43xx_shm_write32(bcm, BCM43xx_SHM_SHARED,
+				    BCM43xx_UCODEFLAGS_OFFSET,
+				    (bcm43xx_shm_read32(bcm, BCM43xx_SHM_SHARED,
+				    BCM43xx_UCODEFLAGS_OFFSET)
+				    | 0x00000200));
 	}
 	if (radio->revision == 8) {
 		bcm43xx_radio_write16(bcm, 0x0051, 0x0000);
@@ -941,7 +946,8 @@ static void bcm43xx_phy_initb6(struct bcm43xx_private *bcm)
 	bcm43xx_phy_write(bcm, 0x0038, 0x0668);
 	bcm43xx_radio_set_txpower_bg(bcm, 0xFFFF, 0xFFFF, 0xFFFF);
 	if (radio->revision <= 5)
-		bcm43xx_phy_write(bcm, 0x005D, bcm43xx_phy_read(bcm, 0x005D) | 0x0003);
+		bcm43xx_phy_write(bcm, 0x005D, (bcm43xx_phy_read(bcm, 0x005D)
+			          & 0xFF80) | 0x0003);
 	if (radio->revision <= 2)
 		bcm43xx_radio_write16(bcm, 0x005D, 0x000D);
 	
@@ -958,7 +964,7 @@ static void bcm43xx_phy_initb6(struct bcm43xx_private *bcm)
 		bcm43xx_phy_write(bcm, 0x0016, 0x0410);
 		bcm43xx_phy_write(bcm, 0x0017, 0x0820);
 		bcm43xx_phy_write(bcm, 0x0062, 0x0007);
-		(void) bcm43xx_radio_calibrationvalue(bcm);
+		bcm43xx_radio_init2050(bcm);
 		bcm43xx_phy_lo_g_measure(bcm);
 		if (bcm->sprom.boardflags & BCM43xx_BFL_RSSI) {
 			bcm43xx_calc_nrssi_slope(bcm);
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
index 7b665e2..d6d9413 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
@@ -105,18 +105,24 @@ static int bcm43xx_wx_set_channelfreq(struct net_device *net_dev,
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
 	unsigned long flags;
 	u8 channel;
+	s8 expon;
 	int freq;
 	int err = -EINVAL;
 
 	mutex_lock(&bcm->mutex);
 	spin_lock_irqsave(&bcm->irq_lock, flags);
 
-	if ((data->freq.m >= 0) && (data->freq.m <= 1000)) {
+	if ((data->freq.e == 0) &&
+	    (data->freq.m >= 0) && (data->freq.m <= 1000)) {
 		channel = data->freq.m;
 		freq = bcm43xx_channel_to_freq(bcm, channel);
 	} else {
-		channel = bcm43xx_freq_to_channel(bcm, data->freq.m);
 		freq = data->freq.m;
+		expon = 6 - data->freq.e;
+		while (--expon >= 0)    /* scale down the frequency to MHz */
+			freq /= 10;
+		assert(freq > 1000);
+		channel = bcm43xx_freq_to_channel(bcm, freq);
 	}
 	if (!ieee80211_is_valid_channel(bcm->ieee, channel))
 		goto out_unlock;
