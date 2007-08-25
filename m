From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Sat, 25 Aug 2007 03:51:38 -0400
Message-ID: <20070825075138.GA7145@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:52787 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932439AbXHYHvk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Aug 2007 03:51:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/dm9000.c            |   25 ++++-----------
 drivers/net/ehea/ehea_main.c    |    8 ++--
 drivers/net/ehea/ehea_qmr.c     |    6 ++++
 drivers/net/forcedeth.c         |    2 +-
 drivers/net/meth.c              |    2 +-
 drivers/net/myri10ge/myri10ge.c |   34 ++++----------------
 drivers/net/phy/phy_device.c    |    2 +-
 drivers/net/sgiseeq.c           |    4 ++-
 drivers/net/sky2.c              |   64 +++++++++++++++++++-------------------
 drivers/net/sky2.h              |    3 +-
 10 files changed, 64 insertions(+), 86 deletions(-)

Brice Goglin (2):
      myri10ge: use pcie_get/set_readrq
      myri10ge: update driver version to 1.3.2-1.269

Domen Puncer (1):
      phy layer: fix genphy_setup_forced (don't reset)

Florian Westphal (1):
      DM9000: fix interface hang under load

Jan-Bernd Themann (3):
      ehea: fix interface to DLPAR tools
      ehea: fix module parameter description
      ehea: fix queue destructor

Ralf Baechle (2):
      Don't use GFP_DMA for zone allocation.
      sgiseeq: Fix return type of sgiseeq_remove

Stephen Hemminger (3):
      sky2: clear PCI power control reg at startup
      sky2: only bring up watchdog if link is active
      sky2 1.17

Willy Tarreau (1):
      fix realtek phy id in forcedeth

diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index c3de81b..738aa59 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -700,6 +700,7 @@ dm9000_init_dm9000(struct net_device *dev)
 static int
 dm9000_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
+	unsigned long flags;
 	board_info_t *db = (board_info_t *) dev->priv;
 
 	PRINTK3("dm9000_start_xmit\n");
@@ -707,10 +708,7 @@ dm9000_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (db->tx_pkt_cnt > 1)
 		return 1;
 
-	netif_stop_queue(dev);
-
-	/* Disable all interrupts */
-	iow(db, DM9000_IMR, IMR_PAR);
+	spin_lock_irqsave(&db->lock, flags);
 
 	/* Move data to DM9000 TX RAM */
 	writeb(DM9000_MWCMD, db->io_addr);
@@ -718,12 +716,9 @@ dm9000_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	(db->outblk)(db->io_data, skb->data, skb->len);
 	db->stats.tx_bytes += skb->len;
 
+	db->tx_pkt_cnt++;
 	/* TX control: First packet immediately send, second packet queue */
-	if (db->tx_pkt_cnt == 0) {
-
-		/* First Packet */
-		db->tx_pkt_cnt++;
-
+	if (db->tx_pkt_cnt == 1) {
 		/* Set TX length to DM9000 */
 		iow(db, DM9000_TXPLL, skb->len & 0xff);
 		iow(db, DM9000_TXPLH, (skb->len >> 8) & 0xff);
@@ -732,23 +727,17 @@ dm9000_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		iow(db, DM9000_TCR, TCR_TXREQ);	/* Cleared after TX complete */
 
 		dev->trans_start = jiffies;	/* save the time stamp */
-
 	} else {
 		/* Second packet */
-		db->tx_pkt_cnt++;
 		db->queue_pkt_len = skb->len;
+		netif_stop_queue(dev);
 	}
 
+	spin_unlock_irqrestore(&db->lock, flags);
+
 	/* free this SKB */
 	dev_kfree_skb(skb);
 
-	/* Re-enable resource check */
-	if (db->tx_pkt_cnt == 1)
-		netif_wake_queue(dev);
-
-	/* Re-enable interrupt */
-	iow(db, DM9000_IMR, IMR_PAR | IMR_PTM | IMR_PRM);
-
 	return 0;
 }
 
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 9756211..db57474 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -76,7 +76,7 @@ MODULE_PARM_DESC(rq1_entries, "Number of entries for Receive Queue 1 "
 MODULE_PARM_DESC(sq_entries, " Number of entries for the Send Queue  "
 		 "[2^x - 1], x = [6..14]. Default = "
 		 __MODULE_STRING(EHEA_DEF_ENTRIES_SQ) ")");
-MODULE_PARM_DESC(use_mcs, " 0:NAPI, 1:Multiple receive queues, Default = 1 ");
+MODULE_PARM_DESC(use_mcs, " 0:NAPI, 1:Multiple receive queues, Default = 0 ");
 
 static int port_name_cnt = 0;
 static LIST_HEAD(adapter_list);
@@ -2490,7 +2490,7 @@ static ssize_t ehea_show_port_id(struct device *dev,
 				 struct device_attribute *attr, char *buf)
 {
 	struct ehea_port *port = container_of(dev, struct ehea_port, ofdev.dev);
-	return sprintf(buf, "0x%X", port->logical_port_id);
+	return sprintf(buf, "%d", port->logical_port_id);
 }
 
 static DEVICE_ATTR(log_port_id, S_IRUSR | S_IRGRP | S_IROTH, ehea_show_port_id,
@@ -2781,7 +2781,7 @@ static ssize_t ehea_probe_port(struct device *dev,
 
 	u32 logical_port_id;
 
-	sscanf(buf, "%X", &logical_port_id);
+	sscanf(buf, "%d", &logical_port_id);
 
 	port = ehea_get_port(adapter, logical_port_id);
 
@@ -2834,7 +2834,7 @@ static ssize_t ehea_remove_port(struct device *dev,
 	int i;
 	u32 logical_port_id;
 
-	sscanf(buf, "%X", &logical_port_id);
+	sscanf(buf, "%d", &logical_port_id);
 
 	port = ehea_get_port(adapter, logical_port_id);
 
diff --git a/drivers/net/ehea/ehea_qmr.c b/drivers/net/ehea/ehea_qmr.c
index a36fa6c..c82e245 100644
--- a/drivers/net/ehea/ehea_qmr.c
+++ b/drivers/net/ehea/ehea_qmr.c
@@ -235,6 +235,8 @@ int ehea_destroy_cq(struct ehea_cq *cq)
 	if (!cq)
 		return 0;
 
+	hcp_epas_dtor(&cq->epas);
+
 	if ((hret = ehea_destroy_cq_res(cq, NORMAL_FREE)) == H_R_STATE) {
 		ehea_error_data(cq->adapter, cq->fw_handle);
 		hret = ehea_destroy_cq_res(cq, FORCE_FREE);
@@ -361,6 +363,8 @@ int ehea_destroy_eq(struct ehea_eq *eq)
 	if (!eq)
 		return 0;
 
+	hcp_epas_dtor(&eq->epas);
+
 	if ((hret = ehea_destroy_eq_res(eq, NORMAL_FREE)) == H_R_STATE) {
 		ehea_error_data(eq->adapter, eq->fw_handle);
 		hret = ehea_destroy_eq_res(eq, FORCE_FREE);
@@ -541,6 +545,8 @@ int ehea_destroy_qp(struct ehea_qp *qp)
 	if (!qp)
 		return 0;
 
+	hcp_epas_dtor(&qp->epas);
+
 	if ((hret = ehea_destroy_qp_res(qp, NORMAL_FREE)) == H_R_STATE) {
 		ehea_error_data(qp->adapter, qp->fw_handle);
 		hret = ehea_destroy_qp_res(qp, FORCE_FREE);
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 10f4e3b..1938d6d 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -552,7 +552,7 @@ union ring_type {
 #define PHY_OUI_MARVELL	0x5043
 #define PHY_OUI_CICADA	0x03f1
 #define PHY_OUI_VITESSE	0x01c1
-#define PHY_OUI_REALTEK	0x01c1
+#define PHY_OUI_REALTEK	0x0732
 #define PHYID1_OUI_MASK	0x03ff
 #define PHYID1_OUI_SHFT	6
 #define PHYID2_OUI_MASK	0xfc00
diff --git a/drivers/net/meth.c b/drivers/net/meth.c
index 92b403b..32bed6b 100644
--- a/drivers/net/meth.c
+++ b/drivers/net/meth.c
@@ -405,7 +405,7 @@ static void meth_rx(struct net_device* dev, unsigned long int_status)
 				priv->stats.rx_length_errors++;
 				skb = priv->rx_skbs[priv->rx_write];
 			} else {
-				skb = alloc_skb(METH_RX_BUFF_SIZE, GFP_ATOMIC | GFP_DMA);
+				skb = alloc_skb(METH_RX_BUFF_SIZE, GFP_ATOMIC);
 				if (!skb) {
 					/* Ouch! No memory! Drop packet on the floor */
 					DPRINTK("No mem: dropping packet\n");
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index ae9bb7b..1c42266 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -72,7 +72,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.3.1-1.248"
+#define MYRI10GE_VERSION_STR "1.3.2-1.269"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");
@@ -2514,26 +2514,20 @@ static void myri10ge_firmware_probe(struct myri10ge_priv *mgp)
 {
 	struct pci_dev *pdev = mgp->pdev;
 	struct device *dev = &pdev->dev;
-	int cap, status;
-	u16 val;
+	int status;
 
 	mgp->tx.boundary = 4096;
 	/*
 	 * Verify the max read request size was set to 4KB
 	 * before trying the test with 4KB.
 	 */
-	cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
-	if (cap < 64) {
-		dev_err(dev, "Bad PCI_CAP_ID_EXP location %d\n", cap);
-		goto abort;
-	}
-	status = pci_read_config_word(pdev, cap + PCI_EXP_DEVCTL, &val);
-	if (status != 0) {
+	status = pcie_get_readrq(pdev);
+	if (status < 0) {
 		dev_err(dev, "Couldn't read max read req size: %d\n", status);
 		goto abort;
 	}
-	if ((val & (5 << 12)) != (5 << 12)) {
-		dev_warn(dev, "Max Read Request size != 4096 (0x%x)\n", val);
+	if (status != 4096) {
+		dev_warn(dev, "Max Read Request size != 4096 (%d)\n", status);
 		mgp->tx.boundary = 2048;
 	}
 	/*
@@ -2850,9 +2844,7 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	size_t bytes;
 	int i;
 	int status = -ENXIO;
-	int cap;
 	int dac_enabled;
-	u16 val;
 
 	netdev = alloc_etherdev(sizeof(*mgp));
 	if (netdev == NULL) {
@@ -2884,19 +2876,7 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	    = pci_find_capability(pdev, PCI_CAP_ID_VNDR);
 
 	/* Set our max read request to 4KB */
-	cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
-	if (cap < 64) {
-		dev_err(&pdev->dev, "Bad PCI_CAP_ID_EXP location %d\n", cap);
-		goto abort_with_netdev;
-	}
-	status = pci_read_config_word(pdev, cap + PCI_EXP_DEVCTL, &val);
-	if (status != 0) {
-		dev_err(&pdev->dev, "Error %d reading PCI_EXP_DEVCTL\n",
-			status);
-		goto abort_with_netdev;
-	}
-	val = (val & ~PCI_EXP_DEVCTL_READRQ) | (5 << 12);
-	status = pci_write_config_word(pdev, cap + PCI_EXP_DEVCTL, val);
+	status = pcie_set_readrq(pdev, 4096);
 	if (status != 0) {
 		dev_err(&pdev->dev, "Error %d writing PCI_EXP_DEVCTL\n",
 			status);
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index a8b74cd..e275df8 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -364,7 +364,7 @@ EXPORT_SYMBOL(genphy_config_advert);
  */
 int genphy_setup_forced(struct phy_device *phydev)
 {
-	int ctl = BMCR_RESET;
+	int ctl = 0;
 
 	phydev->pause = phydev->asym_pause = 0;
 
diff --git a/drivers/net/sgiseeq.c b/drivers/net/sgiseeq.c
index 384b468..0fb74cb 100644
--- a/drivers/net/sgiseeq.c
+++ b/drivers/net/sgiseeq.c
@@ -726,7 +726,7 @@ err_out:
 	return err;
 }
 
-static void __exit sgiseeq_remove(struct platform_device *pdev)
+static int __exit sgiseeq_remove(struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
 	struct sgiseeq_private *sp = netdev_priv(dev);
@@ -735,6 +735,8 @@ static void __exit sgiseeq_remove(struct platform_device *pdev)
 	free_page((unsigned long) sp->srings);
 	free_netdev(dev);
 	platform_set_drvdata(pdev, NULL);
+
+	return 0;
 }
 
 static struct platform_driver sgiseeq_driver = {
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 7575924..e6d937e 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -51,7 +51,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.16"
+#define DRV_VERSION		"1.17"
 #define PFX			DRV_NAME " "
 
 /*
@@ -99,10 +99,6 @@ static int disable_msi = 0;
 module_param(disable_msi, int, 0);
 MODULE_PARM_DESC(disable_msi, "Disable Message Signaled Interrupt (MSI)");
 
-static int idle_timeout = 100;
-module_param(idle_timeout, int, 0);
-MODULE_PARM_DESC(idle_timeout, "Watchdog timer for lost interrupts (ms)");
-
 static const struct pci_device_id sky2_id_table[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9000) }, /* SK-9Sxx */
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9E00) }, /* SK-9Exx */
@@ -219,9 +215,12 @@ static void sky2_power_on(struct sky2_hw *hw)
 	else
 		sky2_write8(hw, B2_Y2_CLK_GATE, 0);
 
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U || hw->chip_id == CHIP_ID_YUKON_EX) {
+	if (hw->chip_id == CHIP_ID_YUKON_EC_U ||
+	    hw->chip_id == CHIP_ID_YUKON_EX) {
 		u32 reg;
 
+		sky2_pci_write32(hw, PCI_DEV_REG3, 0);
+
 		reg = sky2_pci_read32(hw, PCI_DEV_REG4);
 		/* set all bits to 0 except bits 15..12 and 8 */
 		reg &= P_ASPM_CONTROL_MSK;
@@ -238,6 +237,8 @@ static void sky2_power_on(struct sky2_hw *hw)
 		reg = sky2_read32(hw, B2_GP_IO);
 		reg |= GLB_GPIO_STAT_RACE_DIS;
 		sky2_write32(hw, B2_GP_IO, reg);
+
+		sky2_read32(hw, B2_GP_IO);
 	}
 }
 
@@ -1619,6 +1620,9 @@ static int sky2_down(struct net_device *dev)
 	if (netif_msg_ifdown(sky2))
 		printk(KERN_INFO PFX "%s: disabling interface\n", dev->name);
 
+	if (netif_carrier_ok(dev) && --hw->active == 0)
+		del_timer(&hw->watchdog_timer);
+
 	/* Stop more packets from being queued */
 	netif_stop_queue(dev);
 
@@ -1739,6 +1743,10 @@ static void sky2_link_up(struct sky2_port *sky2)
 
 	netif_carrier_on(sky2->netdev);
 
+	if (hw->active++ == 0)
+		mod_timer(&hw->watchdog_timer, jiffies + 1);
+
+
 	/* Turn on link LED */
 	sky2_write8(hw, SK_REG(port, LNK_LED_REG),
 		    LINKLED_ON | LINKLED_BLINK_OFF | LINKLED_LINKSYNC_OFF);
@@ -1790,6 +1798,11 @@ static void sky2_link_down(struct sky2_port *sky2)
 
 	netif_carrier_off(sky2->netdev);
 
+	/* Stop watchdog if both ports are not active */
+	if (--hw->active == 0)
+		del_timer(&hw->watchdog_timer);
+
+
 	/* Turn on link LED */
 	sky2_write8(hw, SK_REG(port, LNK_LED_REG), LINKLED_OFF);
 
@@ -2421,25 +2434,20 @@ static void sky2_le_error(struct sky2_hw *hw, unsigned port,
 	sky2_write32(hw, Q_ADDR(q, Q_CSR), BMU_CLR_IRQ_CHK);
 }
 
-/* If idle then force a fake soft NAPI poll once a second
- * to work around cases where sharing an edge triggered interrupt.
- */
-static inline void sky2_idle_start(struct sky2_hw *hw)
-{
-	if (idle_timeout > 0)
-		mod_timer(&hw->idle_timer,
-			  jiffies + msecs_to_jiffies(idle_timeout));
-}
-
-static void sky2_idle(unsigned long arg)
+/* Check for lost IRQ once a second */
+static void sky2_watchdog(unsigned long arg)
 {
 	struct sky2_hw *hw = (struct sky2_hw *) arg;
-	struct net_device *dev = hw->dev[0];
 
-	if (__netif_rx_schedule_prep(dev))
-		__netif_rx_schedule(dev);
+	if (sky2_read32(hw, B0_ISRC)) {
+		struct net_device *dev = hw->dev[0];
+
+		if (__netif_rx_schedule_prep(dev))
+			__netif_rx_schedule(dev);
+	}
 
-	mod_timer(&hw->idle_timer, jiffies + msecs_to_jiffies(idle_timeout));
+	if (hw->active > 0)
+		mod_timer(&hw->watchdog_timer, round_jiffies(jiffies + HZ));
 }
 
 /* Hardware/software error handling */
@@ -2727,8 +2735,6 @@ static void sky2_restart(struct work_struct *work)
 	struct net_device *dev;
 	int i, err;
 
-	del_timer_sync(&hw->idle_timer);
-
 	rtnl_lock();
 	sky2_write32(hw, B0_IMSK, 0);
 	sky2_read32(hw, B0_IMSK);
@@ -2757,8 +2763,6 @@ static void sky2_restart(struct work_struct *work)
 		}
 	}
 
-	sky2_idle_start(hw);
-
 	rtnl_unlock();
 }
 
@@ -4025,11 +4029,9 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 			sky2_show_addr(dev1);
 	}
 
-	setup_timer(&hw->idle_timer, sky2_idle, (unsigned long) hw);
+	setup_timer(&hw->watchdog_timer, sky2_watchdog, (unsigned long) hw);
 	INIT_WORK(&hw->restart_work, sky2_restart);
 
-	sky2_idle_start(hw);
-
 	pci_set_drvdata(pdev, hw);
 
 	return 0;
@@ -4064,7 +4066,7 @@ static void __devexit sky2_remove(struct pci_dev *pdev)
 	if (!hw)
 		return;
 
-	del_timer_sync(&hw->idle_timer);
+	del_timer_sync(&hw->watchdog_timer);
 
 	flush_scheduled_work();
 
@@ -4108,7 +4110,6 @@ static int sky2_suspend(struct pci_dev *pdev, pm_message_t state)
 	if (!hw)
 		return 0;
 
-	del_timer_sync(&hw->idle_timer);
 	netif_poll_disable(hw->dev[0]);
 
 	for (i = 0; i < hw->ports; i++) {
@@ -4174,7 +4175,7 @@ static int sky2_resume(struct pci_dev *pdev)
 	}
 
 	netif_poll_enable(hw->dev[0]);
-	sky2_idle_start(hw);
+
 	return 0;
 out:
 	dev_err(&pdev->dev, "resume failed (%d)\n", err);
@@ -4191,7 +4192,6 @@ static void sky2_shutdown(struct pci_dev *pdev)
 	if (!hw)
 		return;
 
-	del_timer_sync(&hw->idle_timer);
 	netif_poll_disable(hw->dev[0]);
 
 	for (i = 0; i < hw->ports; i++) {
diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
index dce4d27..72e12b7 100644
--- a/drivers/net/sky2.h
+++ b/drivers/net/sky2.h
@@ -2045,12 +2045,13 @@ struct sky2_hw {
 	u8		     chip_rev;
 	u8		     pmd_type;
 	u8		     ports;
+	u8		     active;
 
 	struct sky2_status_le *st_le;
 	u32		     st_idx;
 	dma_addr_t   	     st_dma;
 
-	struct timer_list    idle_timer;
+	struct timer_list    watchdog_timer;
 	struct work_struct   restart_work;
 	int		     msi;
 	wait_queue_head_t    msi_wait;
