From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Mon, 26 Nov 2007 11:12:54 -0500
Message-ID: <20071126161254.GA15497@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:39489 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751174AbXKZQMz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Nov 2007 11:12:55 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/Kconfig            |    2 +-
 drivers/net/amd8111e.c         |    6 ++++++
 drivers/net/bfin_mac.c         |    2 +-
 drivers/net/ehea/ehea.h        |    2 +-
 drivers/net/ehea/ehea_main.c   |   20 ++++++++++++--------
 drivers/net/ehea/ehea_qmr.h    |    4 ++--
 drivers/net/forcedeth.c        |   38 +++++++++++++++++++++++++-------------
 drivers/net/ibm_newemac/core.c |   31 ++++++++++++++++++++-----------
 drivers/net/ibm_newemac/core.h |    1 +
 drivers/net/sky2.c             |    6 +-----
 drivers/net/smc911x.c          |   19 +++++--------------
 drivers/net/smc911x.h          |    2 +-
 drivers/net/smc91x.h           |    2 +-
 drivers/net/tulip/dmfe.c       |    4 ++--
 drivers/net/usb/dm9601.c       |    2 +-
 include/linux/pci_ids.h        |    4 ++++
 16 files changed, 84 insertions(+), 61 deletions(-)

Ayaz Abdulla (2):
      forcedeth: new mcp79 pci ids
      forcedeth boot delay fix

Benjamin Herrenschmidt (1):
      ibm_newemac: Fix possible lockup on close

Jeff Garzik (1):
      dmfe: checkpatch fix (add whitespace)

Jiri Bohac (1):
      amd8111e: don't call napi_enable if configured w/o NAPI

Maxim Levitsky (1):
      NET: dmfe: don't access configuration space in D3 state

Mike Frysinger (1):
      Blackfin SMC91x Driver: punt CONFIG_BFIN -- we already have CONFIG_BLACKFIN

Peter Korsgaard (4):
      dm9601: Fix printk
      smc911x: Fix undefined CONFIG_ symbol warning
      smc911x: Fix unused variable warning.
      smc911x: Fix multicast handling

Stephen Hemminger (1):
      sky2: disable rx checksum on Yukon XL

Thomas Klein (2):
      ehea: Improve tx packets counting
      ehea: Reworked rcv queue handling to log only fatal errors

Vitja Makarov (1):
      Blackfin EMAC driver: fix bug - NAT doesn't work with bfin_mac driver

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index e8d69b0..1437b37 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -888,7 +888,7 @@ config SMC91X
 	tristate "SMC 91C9x/91C1xxx support"
 	select CRC32
 	select MII
-	depends on ARM || REDWOOD_5 || REDWOOD_6 || M32R || SUPERH || SOC_AU1X00 || BFIN
+	depends on ARM || REDWOOD_5 || REDWOOD_6 || M32R || SUPERH || SOC_AU1X00 || BLACKFIN
 	help
 	  This is a driver for SMC's 91x series of Ethernet chipsets,
 	  including the SMC91C94 and the SMC91C111. Say Y if you want it
diff --git a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
index eebf5bb..e7fdd81 100644
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -1340,7 +1340,9 @@ static int amd8111e_close(struct net_device * dev)
 	struct amd8111e_priv *lp = netdev_priv(dev);
 	netif_stop_queue(dev);
 
+#ifdef CONFIG_AMD8111E_NAPI
 	napi_disable(&lp->napi);
+#endif
 
 	spin_lock_irq(&lp->lock);
 
@@ -1372,7 +1374,9 @@ static int amd8111e_open(struct net_device * dev )
 					 dev->name, dev))
 		return -EAGAIN;
 
+#ifdef CONFIG_AMD8111E_NAPI
 	napi_enable(&lp->napi);
+#endif
 
 	spin_lock_irq(&lp->lock);
 
@@ -1380,7 +1384,9 @@ static int amd8111e_open(struct net_device * dev )
 
 	if(amd8111e_restart(dev)){
 		spin_unlock_irq(&lp->lock);
+#ifdef CONFIG_AMD8111E_NAPI
 		napi_disable(&lp->napi);
+#endif
 		if (dev->irq)
 			free_irq(dev->irq, dev);
 		return -ENOMEM;
diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 084acfd..f0f8516 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -676,7 +676,7 @@ static void bf537mac_rx(struct net_device *dev)
 	skb->protocol = eth_type_trans(skb, dev);
 #if defined(BFIN_MAC_CSUM_OFFLOAD)
 	skb->csum = current_rx_ptr->status.ip_payload_csum;
-	skb->ip_summed = CHECKSUM_PARTIAL;
+	skb->ip_summed = CHECKSUM_COMPLETE;
 #endif
 
 	netif_rx(skb);
diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index f78e5bf..5f82a46 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -40,7 +40,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0080"
+#define DRV_VERSION	"EHEA_0083"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index f0319f1..869e160 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -136,7 +136,7 @@ static struct net_device_stats *ehea_get_stats(struct net_device *dev)
 	struct ehea_port *port = netdev_priv(dev);
 	struct net_device_stats *stats = &port->stats;
 	struct hcp_ehea_port_cb2 *cb2;
-	u64 hret, rx_packets;
+	u64 hret, rx_packets, tx_packets;
 	int i;
 
 	memset(stats, 0, sizeof(*stats));
@@ -162,7 +162,11 @@ static struct net_device_stats *ehea_get_stats(struct net_device *dev)
 	for (i = 0; i < port->num_def_qps; i++)
 		rx_packets += port->port_res[i].rx_packets;
 
-	stats->tx_packets = cb2->txucp + cb2->txmcp + cb2->txbcp;
+	tx_packets = 0;
+	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++)
+		tx_packets += port->port_res[i].tx_packets;
+
+	stats->tx_packets = tx_packets;
 	stats->multicast = cb2->rxmcp;
 	stats->rx_errors = cb2->rxuerr;
 	stats->rx_bytes = cb2->rxo;
@@ -406,11 +410,6 @@ static int ehea_treat_poll_error(struct ehea_port_res *pr, int rq,
 	if (cqe->status & EHEA_CQE_STAT_ERR_CRC)
 		pr->p_stats.err_frame_crc++;
 
-	if (netif_msg_rx_err(pr->port)) {
-		ehea_error("CQE Error for QP %d", pr->qp->init_attr.qp_nr);
-		ehea_dump(cqe, sizeof(*cqe), "CQE");
-	}
-
 	if (rq == 2) {
 		*processed_rq2 += 1;
 		skb = get_skb_by_index(pr->rq2_skba.arr, pr->rq2_skba.len, cqe);
@@ -422,7 +421,11 @@ static int ehea_treat_poll_error(struct ehea_port_res *pr, int rq,
 	}
 
 	if (cqe->status & EHEA_CQE_STAT_FAT_ERR_MASK) {
-		ehea_error("Critical receive error. Resetting port.");
+		if (netif_msg_rx_err(pr->port)) {
+			ehea_error("Critical receive error for QP %d. "
+				   "Resetting port.", pr->qp->init_attr.qp_nr);
+			ehea_dump(cqe, sizeof(*cqe), "CQE");
+		}
 		schedule_work(&pr->port->reset_task);
 		return 1;
 	}
@@ -2000,6 +2003,7 @@ static int ehea_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	ehea_post_swqe(pr->qp, swqe);
+	pr->tx_packets++;
 
 	if (unlikely(atomic_read(&pr->swqe_avail) <= 1)) {
 		spin_lock_irqsave(&pr->netif_queue, flags);
diff --git a/drivers/net/ehea/ehea_qmr.h b/drivers/net/ehea/ehea_qmr.h
index 562de0e..bc62d38 100644
--- a/drivers/net/ehea/ehea_qmr.h
+++ b/drivers/net/ehea/ehea_qmr.h
@@ -145,8 +145,8 @@ struct ehea_rwqe {
 #define EHEA_CQE_VLAN_TAG_XTRACT   0x0400
 
 #define EHEA_CQE_TYPE_RQ           0x60
-#define EHEA_CQE_STAT_ERR_MASK     0x720F
-#define EHEA_CQE_STAT_FAT_ERR_MASK 0x1F
+#define EHEA_CQE_STAT_ERR_MASK     0x700F
+#define EHEA_CQE_STAT_FAT_ERR_MASK 0xF
 #define EHEA_CQE_STAT_ERR_TCP      0x4000
 #define EHEA_CQE_STAT_ERR_IP       0x2000
 #define EHEA_CQE_STAT_ERR_CRC      0x1000
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 92ce2e3..a96583c 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -5286,19 +5286,15 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		if (readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_SYNC_PHY_INIT) {
 			np->mac_in_use = readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_MGMT_ST;
 			dprintk(KERN_INFO "%s: mgmt unit is running. mac in use %x.\n", pci_name(pci_dev), np->mac_in_use);
-			for (i = 0; i < 5000; i++) {
-				msleep(1);
-				if (nv_mgmt_acquire_sema(dev)) {
-					/* management unit setup the phy already? */
-					if ((readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_SYNC_MASK) ==
-					    NVREG_XMITCTL_SYNC_PHY_INIT) {
-						/* phy is inited by mgmt unit */
-						phyinitialized = 1;
-						dprintk(KERN_INFO "%s: Phy already initialized by mgmt unit.\n", pci_name(pci_dev));
-					} else {
-						/* we need to init the phy */
-					}
-					break;
+			if (nv_mgmt_acquire_sema(dev)) {
+				/* management unit setup the phy already? */
+				if ((readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_SYNC_MASK) ==
+				    NVREG_XMITCTL_SYNC_PHY_INIT) {
+					/* phy is inited by mgmt unit */
+					phyinitialized = 1;
+					dprintk(KERN_INFO "%s: Phy already initialized by mgmt unit.\n", pci_name(pci_dev));
+				} else {
+					/* we need to init the phy */
 				}
 			}
 		}
@@ -5613,6 +5609,22 @@ static struct pci_device_id pci_tbl[] = {
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_35),
 		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
 	},
+	{	/* MCP79 Ethernet Controller */
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_36),
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+	},
+	{	/* MCP79 Ethernet Controller */
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_37),
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+	},
+	{	/* MCP79 Ethernet Controller */
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_38),
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+	},
+	{	/* MCP79 Ethernet Controller */
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_39),
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+	},
 	{0,},
 };
 
diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index 0de3aa2..eb0718b 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -642,9 +642,11 @@ static void emac_reset_work(struct work_struct *work)
 	DBG(dev, "reset_work" NL);
 
 	mutex_lock(&dev->link_lock);
-	emac_netif_stop(dev);
-	emac_full_tx_reset(dev);
-	emac_netif_start(dev);
+	if (dev->opened) {
+		emac_netif_stop(dev);
+		emac_full_tx_reset(dev);
+		emac_netif_start(dev);
+	}
 	mutex_unlock(&dev->link_lock);
 }
 
@@ -1063,10 +1065,9 @@ static int emac_open(struct net_device *ndev)
 	dev->rx_sg_skb = NULL;
 
 	mutex_lock(&dev->link_lock);
+	dev->opened = 1;
 
-	/* XXX Start PHY polling now. Shouldn't wr do like sungem instead and
-	 * always poll the PHY even when the iface is down ? That would allow
-	 * things like laptop-net to work. --BenH
+	/* Start PHY polling now.
 	 */
 	if (dev->phy.address >= 0) {
 		int link_poll_interval;
@@ -1145,9 +1146,11 @@ static void emac_link_timer(struct work_struct *work)
 	int link_poll_interval;
 
 	mutex_lock(&dev->link_lock);
-
 	DBG2(dev, "link timer" NL);
 
+	if (!dev->opened)
+		goto bail;
+
 	if (dev->phy.def->ops->poll_link(&dev->phy)) {
 		if (!netif_carrier_ok(dev->ndev)) {
 			/* Get new link parameters */
@@ -1170,13 +1173,14 @@ static void emac_link_timer(struct work_struct *work)
 		link_poll_interval = PHY_POLL_LINK_OFF;
 	}
 	schedule_delayed_work(&dev->link_work, link_poll_interval);
-
+ bail:
 	mutex_unlock(&dev->link_lock);
 }
 
 static void emac_force_link_update(struct emac_instance *dev)
 {
 	netif_carrier_off(dev->ndev);
+	smp_rmb();
 	if (dev->link_polling) {
 		cancel_rearming_delayed_work(&dev->link_work);
 		if (dev->link_polling)
@@ -1191,11 +1195,14 @@ static int emac_close(struct net_device *ndev)
 
 	DBG(dev, "close" NL);
 
-	if (dev->phy.address >= 0)
+	if (dev->phy.address >= 0) {
+		dev->link_polling = 0;
 		cancel_rearming_delayed_work(&dev->link_work);
-
+	}
+	mutex_lock(&dev->link_lock);
 	emac_netif_stop(dev);
-	flush_scheduled_work();
+	dev->opened = 0;
+	mutex_unlock(&dev->link_lock);
 
 	emac_rx_disable(dev);
 	emac_tx_disable(dev);
@@ -2756,6 +2763,8 @@ static int __devexit emac_remove(struct of_device *ofdev)
 
 	unregister_netdev(dev->ndev);
 
+	flush_scheduled_work();
+
 	if (emac_has_feature(dev, EMAC_FTR_HAS_TAH))
 		tah_detach(dev->tah_dev, dev->tah_port);
 	if (emac_has_feature(dev, EMAC_FTR_HAS_RGMII))
diff --git a/drivers/net/ibm_newemac/core.h b/drivers/net/ibm_newemac/core.h
index 4011803..a010b24 100644
--- a/drivers/net/ibm_newemac/core.h
+++ b/drivers/net/ibm_newemac/core.h
@@ -258,6 +258,7 @@ struct emac_instance {
 	int				stop_timeout;	/* in us */
 	int				no_mcast;
 	int				mcast_pending;
+	int				opened;
 	struct work_struct		reset_work;
 	spinlock_t			lock;
 };
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index a2070db..8c4c743 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1320,15 +1320,11 @@ static int sky2_up(struct net_device *dev)
 	 */
 	if (otherdev && netif_running(otherdev) &&
  	    (cap = pci_find_capability(hw->pdev, PCI_CAP_ID_PCIX))) {
- 		struct sky2_port *osky2 = netdev_priv(otherdev);
  		u16 cmd;
 
 		pci_read_config_word(hw->pdev, cap + PCI_X_CMD, &cmd);
  		cmd &= ~PCI_X_CMD_MAX_SPLIT;
 		pci_write_config_word(hw->pdev, cap + PCI_X_CMD, cmd);
-
- 		sky2->rx_csum = 0;
- 		osky2->rx_csum = 0;
  	}
 
 	if (netif_msg_ifup(sky2))
@@ -4013,7 +4009,7 @@ static __devinit struct net_device *sky2_init_netdev(struct sky2_hw *hw,
 	sky2->duplex = -1;
 	sky2->speed = -1;
 	sky2->advertising = sky2_supported_modes(hw);
-	sky2->rx_csum = 1;
+	sky2->rx_csum = (hw->chip_id != CHIP_ID_YUKON_XL);
 	sky2->wol = wol;
 
 	spin_lock_init(&sky2->phy_lock);
diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index dd18af0..1a3d80b 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -428,7 +428,6 @@ static inline void smc911x_drop_pkt(struct net_device *dev)
  */
 static inline void	 smc911x_rcv(struct net_device *dev)
 {
-	struct smc911x_local *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	unsigned int pkt_len, status;
 	struct sk_buff *skb;
@@ -473,6 +472,7 @@ static inline void	 smc911x_rcv(struct net_device *dev)
 		skb_put(skb,pkt_len-4);
 #ifdef SMC_USE_DMA
 		{
+		struct smc911x_local *lp = netdev_priv(dev);
 		unsigned int fifo;
 		/* Lower the FIFO threshold if possible */
 		fifo = SMC_GET_FIFO_INT();
@@ -1379,13 +1379,6 @@ static void smc911x_set_multicast_list(struct net_device *dev)
 	unsigned int multicast_table[2];
 	unsigned int mcr, update_multicast = 0;
 	unsigned long flags;
-	/* table for flipping the order of 5 bits */
-	static const unsigned char invert5[] =
-		{0x00, 0x10, 0x08, 0x18, 0x04, 0x14, 0x0C, 0x1C,
-		 0x02, 0x12, 0x0A, 0x1A, 0x06, 0x16, 0x0E, 0x1E,
-		 0x01, 0x11, 0x09, 0x19, 0x05, 0x15, 0x0D, 0x1D,
-		 0x03, 0x13, 0x0B, 0x1B, 0x07, 0x17, 0x0F, 0x1F};
-
 
 	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
 
@@ -1432,7 +1425,7 @@ static void smc911x_set_multicast_list(struct net_device *dev)
 
 		cur_addr = dev->mc_list;
 		for (i = 0; i < dev->mc_count; i++, cur_addr = cur_addr->next) {
-			int position;
+			u32 position;
 
 			/* do we have a pointer here? */
 			if (!cur_addr)
@@ -1442,12 +1435,10 @@ static void smc911x_set_multicast_list(struct net_device *dev)
 			if (!(*cur_addr->dmi_addr & 1))
 				 continue;
 
-			/* only use the low order bits */
-			position = crc32_le(~0, cur_addr->dmi_addr, 6) & 0x3f;
+			/* upper 6 bits are used as hash index */
+			position = ether_crc(ETH_ALEN, cur_addr->dmi_addr)>>26;
 
-			/* do some messy swapping to put the bit in the right spot */
-			multicast_table[invert5[position&0x1F]&0x1] |=
-				(1<<invert5[(position>>1)&0x1F]);
+			multicast_table[position>>5] |= 1 << (position&0x1f);
 		}
 
 		/* be sure I get rid of flags I might have set */
diff --git a/drivers/net/smc911x.h b/drivers/net/smc911x.h
index 16a0edc..d04e4fa 100644
--- a/drivers/net/smc911x.h
+++ b/drivers/net/smc911x.h
@@ -37,7 +37,7 @@
   #define SMC_USE_16BIT		0
   #define SMC_USE_32BIT		1
   #define SMC_IRQ_SENSE		IRQF_TRIGGER_FALLING
-#elif CONFIG_SH_MAGIC_PANEL_R2
+#elif defined(CONFIG_SH_MAGIC_PANEL_R2)
   #define SMC_USE_SH_DMA	0
   #define SMC_USE_16BIT		0
   #define SMC_USE_32BIT		1
diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
index db34e1e..07b7f71 100644
--- a/drivers/net/smc91x.h
+++ b/drivers/net/smc91x.h
@@ -55,7 +55,7 @@
 #define SMC_insw(a, r, p, l)	readsw((a) + (r), p, l)
 #define SMC_outsw(a, r, p, l)	writesw((a) + (r), p, l)
 
-#elif defined(CONFIG_BFIN)
+#elif defined(CONFIG_BLACKFIN)
 
 #define SMC_IRQ_FLAGS		IRQF_TRIGGER_HIGH
 #define RPC_LSA_DEFAULT		RPC_LED_100_10
diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index ca90566..b4891ca 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -2118,8 +2118,8 @@ static int dmfe_suspend(struct pci_dev *pci_dev, pm_message_t state)
 	pci_enable_wake(pci_dev, PCI_D3cold, 1);
 
 	/* Power down device*/
-	pci_set_power_state(pci_dev, pci_choose_state (pci_dev,state));
 	pci_save_state(pci_dev);
+	pci_set_power_state(pci_dev, pci_choose_state (pci_dev, state));
 
 	return 0;
 }
@@ -2129,8 +2129,8 @@ static int dmfe_resume(struct pci_dev *pci_dev)
 	struct net_device *dev = pci_get_drvdata(pci_dev);
 	u32 tmp;
 
-	pci_restore_state(pci_dev);
 	pci_set_power_state(pci_dev, PCI_D0);
+	pci_restore_state(pci_dev);
 
 	/* Re-initilize DM910X board */
 	dmfe_init_dm910x(dev);
diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 2c68573..1ffdd10 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -94,7 +94,7 @@ static void dm_write_async_callback(struct urb *urb)
 	struct usb_ctrlrequest *req = (struct usb_ctrlrequest *)urb->context;
 
 	if (urb->status < 0)
-		printk(KERN_DEBUG "dm_write_async_callback() failed with %d",
+		printk(KERN_DEBUG "dm_write_async_callback() failed with %d\n",
 		       urb->status);
 
 	kfree(req);
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index 1ee009e..111aa10 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -1237,6 +1237,10 @@
 #define PCI_DEVICE_ID_NVIDIA_NVENET_33              0x0761
 #define PCI_DEVICE_ID_NVIDIA_NVENET_34              0x0762
 #define PCI_DEVICE_ID_NVIDIA_NVENET_35              0x0763
+#define PCI_DEVICE_ID_NVIDIA_NVENET_36              0x0AB0
+#define PCI_DEVICE_ID_NVIDIA_NVENET_37              0x0AB1
+#define PCI_DEVICE_ID_NVIDIA_NVENET_38              0x0AB2
+#define PCI_DEVICE_ID_NVIDIA_NVENET_39              0x0AB3
 
 #define PCI_VENDOR_ID_IMS		0x10e0
 #define PCI_DEVICE_ID_IMS_TT128		0x9128
