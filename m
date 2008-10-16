From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Thu, 16 Oct 2008 06:03:05 -0400
Message-ID: <20081016100305.GA31045@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:57938 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753077AbYJPKDH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Oct 2008 06:03:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please pull from 'davem-fixes' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git davem-fixes

to receive the following updates:

 drivers/net/Kconfig             |   12 ++++++++++--
 drivers/net/ixgbe/ixgbe.h       |    4 ++--
 drivers/net/ixgbe/ixgbe_main.c  |   32 ++++++++++++++++----------------
 drivers/net/myri10ge/myri10ge.c |   26 +++++++++++++-------------
 drivers/net/pcmcia/Kconfig      |    2 +-
 drivers/net/wan/lmc/lmc_main.c  |   31 ++++++++++++++++++++++++-------
 drivers/net/xen-netfront.c      |    5 ++++-
 7 files changed, 70 insertions(+), 42 deletions(-)

Alan Cox (2):
      lmc: copy_*_user under spinlock
      [netdrvr] ibmtr: PCMCIA IBMTR is ok on 64bit

Isaku Yamahata (1):
      xen-netfront: Avoid unaligned accesses to IP header

Jeff Garzik (1):
      [netdrvr] myri10ge, ixgbe: remove broken select INTEL_IOATDMA

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 1d8af33..ad301ac 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2410,7 +2410,6 @@ config IXGBE
 	tristate "Intel(R) 10GbE PCI Express adapters support"
 	depends on PCI && INET
 	select INET_LRO
-	select INTEL_IOATDMA
 	---help---
 	  This driver supports Intel(R) 10GbE PCI Express family of
 	  adapters.  For more information on how to identify your adapter, go
@@ -2426,6 +2425,11 @@ config IXGBE
 	  To compile this driver as a module, choose M here. The module
 	  will be called ixgbe.
 
+config IXGBE_DCA
+	bool
+	default y
+	depends on IXGBE && DCA && !(IXGBE=y && DCA=m)
+
 config IXGB
 	tristate "Intel(R) PRO/10GbE support"
 	depends on PCI
@@ -2462,7 +2466,6 @@ config MYRI10GE
 	select FW_LOADER
 	select CRC32
 	select INET_LRO
-	select INTEL_IOATDMA
 	---help---
 	  This driver supports Myricom Myri-10G Dual Protocol interface in
 	  Ethernet mode. If the eeprom on your board is not recent enough,
@@ -2474,6 +2477,11 @@ config MYRI10GE
 	  To compile this driver as a module, choose M here. The module
 	  will be called myri10ge.
 
+config MYRI10GE_DCA
+	bool
+	default y
+	depends on MYRI10GE && DCA && !(MYRI10GE=y && DCA=m)
+
 config NETXEN_NIC
 	tristate "NetXen Multi port (1/10) Gigabit Ethernet NIC"
 	depends on PCI
diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 2198b77..e116d34 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -36,7 +36,7 @@
 #include "ixgbe_type.h"
 #include "ixgbe_common.h"
 
-#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
+#ifdef CONFIG_IXGBE_DCA
 #include <linux/dca.h>
 #endif
 
@@ -136,7 +136,7 @@ struct ixgbe_ring {
 		      * offset associated with this ring, which is different
 		      * for DCE and RSS modes */
 
-#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
+#ifdef CONFIG_IXGBE_DCA
 	/* cpu for tx queue */
 	int cpu;
 #endif
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index ca17af4..7548fb7 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -80,7 +80,7 @@ static struct pci_device_id ixgbe_pci_tbl[] = {
 };
 MODULE_DEVICE_TABLE(pci, ixgbe_pci_tbl);
 
-#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
+#ifdef CONFIG_IXGBE_DCA
 static int ixgbe_notify_dca(struct notifier_block *, unsigned long event,
                             void *p);
 static struct notifier_block dca_notifier = {
@@ -296,7 +296,7 @@ done_cleaning:
 	return (total_packets ? true : false);
 }
 
-#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
+#ifdef CONFIG_IXGBE_DCA
 static void ixgbe_update_rx_dca(struct ixgbe_adapter *adapter,
                                 struct ixgbe_ring *rx_ring)
 {
@@ -383,7 +383,7 @@ static int __ixgbe_notify_dca(struct device *dev, void *data)
 	return 0;
 }
 
-#endif /* CONFIG_DCA or CONFIG_DCA_MODULE */
+#endif /* CONFIG_IXGBE_DCA */
 /**
  * ixgbe_receive_skb - Send a completed packet up the stack
  * @adapter: board private structure
@@ -947,7 +947,7 @@ static irqreturn_t ixgbe_msix_clean_tx(int irq, void *data)
 	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
 	for (i = 0; i < q_vector->txr_count; i++) {
 		tx_ring = &(adapter->tx_ring[r_idx]);
-#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
+#ifdef CONFIG_IXGBE_DCA
 		if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
 			ixgbe_update_tx_dca(adapter, tx_ring);
 #endif
@@ -1022,7 +1022,7 @@ static int ixgbe_clean_rxonly(struct napi_struct *napi, int budget)
 
 	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
 	rx_ring = &(adapter->rx_ring[r_idx]);
-#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
+#ifdef CONFIG_IXGBE_DCA
 	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
 		ixgbe_update_rx_dca(adapter, rx_ring);
 #endif
@@ -1066,7 +1066,7 @@ static int ixgbe_clean_rxonly_many(struct napi_struct *napi, int budget)
 	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
 	for (i = 0; i < q_vector->rxr_count; i++) {
 		rx_ring = &(adapter->rx_ring[r_idx]);
-#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
+#ifdef CONFIG_IXGBE_DCA
 		if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
 			ixgbe_update_rx_dca(adapter, rx_ring);
 #endif
@@ -2155,7 +2155,7 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 
 	netif_carrier_off(netdev);
 
-#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
+#ifdef CONFIG_IXGBE_DCA
 	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED) {
 		adapter->flags &= ~IXGBE_FLAG_DCA_ENABLED;
 		dca_remove_requester(&adapter->pdev->dev);
@@ -2167,7 +2167,7 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	ixgbe_clean_all_tx_rings(adapter);
 	ixgbe_clean_all_rx_rings(adapter);
 
-#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
+#ifdef CONFIG_IXGBE_DCA
 	/* since we reset the hardware DCA settings were cleared */
 	if (dca_add_requester(&adapter->pdev->dev) == 0) {
 		adapter->flags |= IXGBE_FLAG_DCA_ENABLED;
@@ -2193,7 +2193,7 @@ static int ixgbe_poll(struct napi_struct *napi, int budget)
 	struct ixgbe_adapter *adapter = q_vector->adapter;
 	int tx_cleaned, work_done = 0;
 
-#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
+#ifdef CONFIG_IXGBE_DCA
 	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED) {
 		ixgbe_update_tx_dca(adapter, adapter->tx_ring);
 		ixgbe_update_rx_dca(adapter, adapter->rx_ring);
@@ -3922,7 +3922,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_register;
 
-#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
+#ifdef CONFIG_IXGBE_DCA
 	if (dca_add_requester(&pdev->dev) == 0) {
 		adapter->flags |= IXGBE_FLAG_DCA_ENABLED;
 		/* always use CB2 mode, difference is masked
@@ -3972,7 +3972,7 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 
 	flush_scheduled_work();
 
-#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
+#ifdef CONFIG_IXGBE_DCA
 	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED) {
 		adapter->flags &= ~IXGBE_FLAG_DCA_ENABLED;
 		dca_remove_requester(&pdev->dev);
@@ -4105,10 +4105,10 @@ static int __init ixgbe_init_module(void)
 
 	printk(KERN_INFO "%s: %s\n", ixgbe_driver_name, ixgbe_copyright);
 
-#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
+#ifdef CONFIG_IXGBE_DCA
 	dca_register_notify(&dca_notifier);
-
 #endif
+
 	ret = pci_register_driver(&ixgbe_driver);
 	return ret;
 }
@@ -4123,13 +4123,13 @@ module_init(ixgbe_init_module);
  **/
 static void __exit ixgbe_exit_module(void)
 {
-#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
+#ifdef CONFIG_IXGBE_DCA
 	dca_unregister_notify(&dca_notifier);
 #endif
 	pci_unregister_driver(&ixgbe_driver);
 }
 
-#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
+#ifdef CONFIG_IXGBE_DCA
 static int ixgbe_notify_dca(struct notifier_block *nb, unsigned long event,
                             void *p)
 {
@@ -4140,7 +4140,7 @@ static int ixgbe_notify_dca(struct notifier_block *nb, unsigned long event,
 
 	return ret_val ? NOTIFY_BAD : NOTIFY_DONE;
 }
-#endif /* CONFIG_DCA or CONFIG_DCA_MODULE */
+#endif /* CONFIG_IXGBE_DCA */
 
 module_exit(ixgbe_exit_module);
 
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 6dce901..a9aebad 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -188,7 +188,7 @@ struct myri10ge_slice_state {
 	dma_addr_t fw_stats_bus;
 	int watchdog_tx_done;
 	int watchdog_tx_req;
-#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
+#ifdef CONFIG_MYRI10GE_DCA
 	int cached_dca_tag;
 	int cpu;
 	__be32 __iomem *dca_tag;
@@ -220,7 +220,7 @@ struct myri10ge_priv {
 	int msi_enabled;
 	int msix_enabled;
 	struct msix_entry *msix_vectors;
-#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
+#ifdef CONFIG_MYRI10GE_DCA
 	int dca_enabled;
 #endif
 	u32 link_state;
@@ -902,7 +902,7 @@ static int myri10ge_reset(struct myri10ge_priv *mgp)
 	struct myri10ge_slice_state *ss;
 	int i, status;
 	size_t bytes;
-#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
+#ifdef CONFIG_MYRI10GE_DCA
 	unsigned long dca_tag_off;
 #endif
 
@@ -1012,7 +1012,7 @@ static int myri10ge_reset(struct myri10ge_priv *mgp)
 	}
 	put_be32(htonl(mgp->intr_coal_delay), mgp->intr_coal_delay_ptr);
 
-#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
+#ifdef CONFIG_MYRI10GE_DCA
 	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_DCA_OFFSET, &cmd, 0);
 	dca_tag_off = cmd.data0;
 	for (i = 0; i < mgp->num_slices; i++) {
@@ -1051,7 +1051,7 @@ static int myri10ge_reset(struct myri10ge_priv *mgp)
 	return status;
 }
 
-#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
+#ifdef CONFIG_MYRI10GE_DCA
 static void
 myri10ge_write_dca(struct myri10ge_slice_state *ss, int cpu, int tag)
 {
@@ -1505,7 +1505,7 @@ static int myri10ge_poll(struct napi_struct *napi, int budget)
 	struct net_device *netdev = ss->mgp->dev;
 	int work_done;
 
-#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
+#ifdef CONFIG_MYRI10GE_DCA
 	if (ss->mgp->dca_enabled)
 		myri10ge_update_dca(ss);
 #endif
@@ -1736,7 +1736,7 @@ static const char myri10ge_gstrings_main_stats[][ETH_GSTRING_LEN] = {
 	"tx_boundary", "WC", "irq", "MSI", "MSIX",
 	"read_dma_bw_MBs", "write_dma_bw_MBs", "read_write_dma_bw_MBs",
 	"serial_number", "watchdog_resets",
-#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
+#ifdef CONFIG_MYRI10GE_DCA
 	"dca_capable_firmware", "dca_device_present",
 #endif
 	"link_changes", "link_up", "dropped_link_overflow",
@@ -1815,7 +1815,7 @@ myri10ge_get_ethtool_stats(struct net_device *netdev,
 	data[i++] = (unsigned int)mgp->read_write_dma;
 	data[i++] = (unsigned int)mgp->serial_number;
 	data[i++] = (unsigned int)mgp->watchdog_resets;
-#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
+#ifdef CONFIG_MYRI10GE_DCA
 	data[i++] = (unsigned int)(mgp->ss[0].dca_tag != NULL);
 	data[i++] = (unsigned int)(mgp->dca_enabled);
 #endif
@@ -3844,7 +3844,7 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev_err(&pdev->dev, "failed reset\n");
 		goto abort_with_slices;
 	}
-#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
+#ifdef CONFIG_MYRI10GE_DCA
 	myri10ge_setup_dca(mgp);
 #endif
 	pci_set_drvdata(pdev, mgp);
@@ -3948,7 +3948,7 @@ static void myri10ge_remove(struct pci_dev *pdev)
 	netdev = mgp->dev;
 	unregister_netdev(netdev);
 
-#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
+#ifdef CONFIG_MYRI10GE_DCA
 	myri10ge_teardown_dca(mgp);
 #endif
 	myri10ge_dummy_rdma(mgp, 0);
@@ -3993,7 +3993,7 @@ static struct pci_driver myri10ge_driver = {
 #endif
 };
 
-#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
+#ifdef CONFIG_MYRI10GE_DCA
 static int
 myri10ge_notify_dca(struct notifier_block *nb, unsigned long event, void *p)
 {
@@ -4024,7 +4024,7 @@ static __init int myri10ge_init_module(void)
 		       myri10ge_driver.name, myri10ge_rss_hash);
 		myri10ge_rss_hash = MXGEFW_RSS_HASH_TYPE_SRC_PORT;
 	}
-#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
+#ifdef CONFIG_MYRI10GE_DCA
 	dca_register_notify(&myri10ge_dca_notifier);
 #endif
 	if (myri10ge_max_slices > MYRI10GE_MAX_SLICES)
@@ -4037,7 +4037,7 @@ module_init(myri10ge_init_module);
 
 static __exit void myri10ge_cleanup_module(void)
 {
-#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
+#ifdef CONFIG_MYRI10GE_DCA
 	dca_unregister_notify(&myri10ge_dca_notifier);
 #endif
 	pci_unregister_driver(&myri10ge_driver);
diff --git a/drivers/net/pcmcia/Kconfig b/drivers/net/pcmcia/Kconfig
index e8f55d8..9b8f793 100644
--- a/drivers/net/pcmcia/Kconfig
+++ b/drivers/net/pcmcia/Kconfig
@@ -111,7 +111,7 @@ config ARCNET_COM20020_CS
 
 config PCMCIA_IBMTR
 	tristate "IBM PCMCIA tokenring adapter support"
-	depends on IBMTR!=y && TR && !64BIT
+	depends on IBMTR!=y && TR
 	help
 	  Say Y here if you intend to attach this type of Token Ring PCMCIA
 	  card to your computer. You then also need to say Y to "Token Ring
diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index f80640f..d7bb63e 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -122,7 +122,6 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
      * Most functions mess with the structure
      * Disable interrupts while we do the polling
      */
-    spin_lock_irqsave(&sc->lmc_lock, flags);
 
     switch (cmd) {
         /*
@@ -152,6 +151,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
 		break;
 	}
 
+	spin_lock_irqsave(&sc->lmc_lock, flags);
         sc->lmc_media->set_status (sc, &ctl);
 
         if(ctl.crc_length != sc->ictl.crc_length) {
@@ -161,6 +161,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
 	    else
 		sc->TxDescriptControlInit &= ~LMC_TDES_ADD_CRC_DISABLE;
         }
+	spin_unlock_irqrestore(&sc->lmc_lock, flags);
 
         ret = 0;
         break;
@@ -187,15 +188,18 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
 		break;				/* no change */
             }
             
+	    spin_lock_irqsave(&sc->lmc_lock, flags);
             lmc_proto_close(sc);
 
             sc->if_type = new_type;
             lmc_proto_attach(sc);
 	    ret = lmc_proto_open(sc);
+	    spin_unlock_irqrestore(&sc->lmc_lock, flags);
 	    break;
 	}
 
     case LMCIOCGETXINFO: /*fold01*/
+	spin_lock_irqsave(&sc->lmc_lock, flags);
         sc->lmc_xinfo.Magic0 = 0xBEEFCAFE;
 
         sc->lmc_xinfo.PciCardType = sc->lmc_cardtype;
@@ -208,6 +212,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
         sc->lmc_xinfo.MaxFrameSize = LMC_PKT_BUF_SZ;
         sc->lmc_xinfo.link_status = sc->lmc_media->get_link_status (sc);
         sc->lmc_xinfo.mii_reg16 = lmc_mii_readreg (sc, 0, 16);
+	spin_unlock_irqrestore(&sc->lmc_lock, flags);
 
         sc->lmc_xinfo.Magic1 = 0xDEADBEEF;
 
@@ -220,6 +225,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
         break;
 
     case LMCIOCGETLMCSTATS:
+	    spin_lock_irqsave(&sc->lmc_lock, flags);
 	    if (sc->lmc_cardtype == LMC_CARDTYPE_T1) {
 		    lmc_mii_writereg(sc, 0, 17, T1FRAMER_FERR_LSB);
 		    sc->extra_stats.framingBitErrorCount +=
@@ -243,6 +249,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
 		    sc->extra_stats.severelyErroredFrameCount +=
 			    regVal & T1FRAMER_SEF_MASK;
 	    }
+	    spin_unlock_irqrestore(&sc->lmc_lock, flags);
 	    if (copy_to_user(ifr->ifr_data, &sc->lmc_device->stats,
 			     sizeof(sc->lmc_device->stats)) ||
 		copy_to_user(ifr->ifr_data + sizeof(sc->lmc_device->stats),
@@ -258,12 +265,14 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
 		    break;
 	    }
 
+	    spin_lock_irqsave(&sc->lmc_lock, flags);
 	    memset(&sc->lmc_device->stats, 0, sizeof(sc->lmc_device->stats));
 	    memset(&sc->extra_stats, 0, sizeof(sc->extra_stats));
 	    sc->extra_stats.check = STATCHECK;
 	    sc->extra_stats.version_size = (DRIVER_VERSION << 16) +
 		    sizeof(sc->lmc_device->stats) + sizeof(sc->extra_stats);
 	    sc->extra_stats.lmc_cardtype = sc->lmc_cardtype;
+	    spin_unlock_irqrestore(&sc->lmc_lock, flags);
 	    ret = 0;
 	    break;
 
@@ -282,8 +291,10 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
 		ret = -EFAULT;
 		break;
 	}
+	spin_lock_irqsave(&sc->lmc_lock, flags);
         sc->lmc_media->set_circuit_type(sc, ctl.circuit_type);
         sc->ictl.circuit_type = ctl.circuit_type;
+	spin_unlock_irqrestore(&sc->lmc_lock, flags);
         ret = 0;
 
         break;
@@ -294,12 +305,14 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
             break;
         }
 
+	spin_lock_irqsave(&sc->lmc_lock, flags);
         /* Reset driver and bring back to current state */
         printk (" REG16 before reset +%04x\n", lmc_mii_readreg (sc, 0, 16));
         lmc_running_reset (dev);
         printk (" REG16 after reset +%04x\n", lmc_mii_readreg (sc, 0, 16));
 
         LMC_EVENT_LOG(LMC_EVENT_FORCEDRESET, LMC_CSR_READ (sc, csr_status), lmc_mii_readreg (sc, 0, 16));
+	spin_unlock_irqrestore(&sc->lmc_lock, flags);
 
         ret = 0;
         break;
@@ -338,14 +351,15 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
              */
             netif_stop_queue(dev);
 
-	if (copy_from_user(&xc, ifr->ifr_data, sizeof(struct lmc_xilinx_control))) {
+	    if (copy_from_user(&xc, ifr->ifr_data, sizeof(struct lmc_xilinx_control))) {
 		ret = -EFAULT;
 		break;
-	}
+	    }
             switch(xc.command){
             case lmc_xilinx_reset: /*fold02*/
                 {
                     u16 mii;
+		    spin_lock_irqsave(&sc->lmc_lock, flags);
                     mii = lmc_mii_readreg (sc, 0, 16);
 
                     /*
@@ -404,6 +418,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
                             lmc_led_off(sc, LMC_DS3_LED2);
                         }
                     }
+		    spin_unlock_irqrestore(&sc->lmc_lock, flags);
                     
                     
 
@@ -416,6 +431,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
                 {
                     u16 mii;
                     int timeout = 500000;
+		    spin_lock_irqsave(&sc->lmc_lock, flags);
                     mii = lmc_mii_readreg (sc, 0, 16);
 
                     /*
@@ -451,13 +467,14 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
                      */
                     while( (LMC_CSR_READ(sc, csr_gp) & LMC_GEP_INIT) == 0 &&
                            (timeout-- > 0))
-                        ;
+                        cpu_relax();
 
 
                     /*
                      * stop driving Xilinx-related signals
                      */
                     lmc_gpio_mkinput(sc, 0xff);
+		    spin_unlock_irqrestore(&sc->lmc_lock, flags);
 
                     ret = 0x0;
                     
@@ -493,6 +510,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
 
                     printk("%s: Starting load of data Len: %d at 0x%p == 0x%p\n", dev->name, xc.len, xc.data, data);
 
+		    spin_lock_irqsave(&sc->lmc_lock, flags);
                     lmc_gpio_mkinput(sc, 0xff);
 
                     /*
@@ -545,7 +563,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
                      */
                     while( (LMC_CSR_READ(sc, csr_gp) & LMC_GEP_INIT) == 0 &&
                            (timeout-- > 0))
-                        ;
+                        cpu_relax();
 
                     printk(KERN_DEBUG "%s: Waited %d for the Xilinx to clear it's memory\n", dev->name, 500000-timeout);
 
@@ -588,6 +606,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
 
                     sc->lmc_miireg16 &= ~LMC_MII16_FIFO_RESET;
                     lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
+		    spin_unlock_irqrestore(&sc->lmc_lock, flags);
 
                     kfree(data);
                     
@@ -611,8 +630,6 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
         break;
     }
 
-    spin_unlock_irqrestore(&sc->lmc_lock, flags); /*fold01*/
-
     lmc_trace(dev, "lmc_ioctl out");
 
     return ret;
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index c749bdb..9ffe743 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -239,11 +239,14 @@ static void xennet_alloc_rx_buffers(struct net_device *dev)
 	 */
 	batch_target = np->rx_target - (req_prod - np->rx.rsp_cons);
 	for (i = skb_queue_len(&np->rx_batch); i < batch_target; i++) {
-		skb = __netdev_alloc_skb(dev, RX_COPY_THRESHOLD,
+		skb = __netdev_alloc_skb(dev, RX_COPY_THRESHOLD + NET_IP_ALIGN,
 					 GFP_ATOMIC | __GFP_NOWARN);
 		if (unlikely(!skb))
 			goto no_skb;
 
+		/* Align ip header to a 16 bytes boundary */
+		skb_reserve(skb, NET_IP_ALIGN);
+
 		page = alloc_page(GFP_ATOMIC | __GFP_NOWARN);
 		if (!page) {
 			kfree_skb(skb);
