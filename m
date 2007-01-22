From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Mon, 22 Jan 2007 13:55:08 -0500
Message-ID: <20070122185508.GA4648@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:37464 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932220AbXAVSzL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jan 2007 13:55:11 -0500
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/8139cp.c                        |    7 +-
 drivers/net/myri10ge/myri10ge.c             |   23 ++++-
 drivers/net/sis190.c                        |    2 +-
 drivers/net/ucc_geth.c                      |   12 ++-
 drivers/net/ucc_geth_phy.c                  |  134 +++++++++++++--------------
 drivers/net/wireless/bcm43xx/bcm43xx_main.c |   11 ++-
 6 files changed, 103 insertions(+), 86 deletions(-)

Brice Goglin (3):
      myri10ge: make wc_fifo usage load-time tunable
      myri10ge: check that we can get an irq
      myri10ge: update driver version to 1.2.0

Chris Lalancette (1):
      8139cp: Don't blindly enable interrupts

Francois Romieu (1):
      sis190: failure to set the MAC address from EEPROM

Larry Finger (1):
      bcm43xx: Fix failure to deliver PCI-E interrupts

Timur Tabi (2):
      Update ucc_geth.c for new workqueue structure
      Fix phy_read/write redefinition errors in ucc_geth_phy.c

diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index e2cb19b..6f93a76 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -765,17 +765,18 @@ static int cp_start_xmit (struct sk_buff *skb, struct net_device *dev)
 	struct cp_private *cp = netdev_priv(dev);
 	unsigned entry;
 	u32 eor, flags;
+	unsigned long intr_flags;
 #if CP_VLAN_TAG_USED
 	u32 vlan_tag = 0;
 #endif
 	int mss = 0;
 
-	spin_lock_irq(&cp->lock);
+	spin_lock_irqsave(&cp->lock, intr_flags);
 
 	/* This is a hard error, log it. */
 	if (TX_BUFFS_AVAIL(cp) <= (skb_shinfo(skb)->nr_frags + 1)) {
 		netif_stop_queue(dev);
-		spin_unlock_irq(&cp->lock);
+		spin_unlock_irqrestore(&cp->lock, intr_flags);
 		printk(KERN_ERR PFX "%s: BUG! Tx Ring full when queue awake!\n",
 		       dev->name);
 		return 1;
@@ -908,7 +909,7 @@ static int cp_start_xmit (struct sk_buff *skb, struct net_device *dev)
 	if (TX_BUFFS_AVAIL(cp) <= (MAX_SKB_FRAGS + 1))
 		netif_stop_queue(dev);
 
-	spin_unlock_irq(&cp->lock);
+	spin_unlock_irqrestore(&cp->lock, intr_flags);
 
 	cpw8(TxPoll, NormalTxPoll);
 	dev->trans_start = jiffies;
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 07cf574..61cbd4a 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -71,7 +71,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.1.0"
+#define MYRI10GE_VERSION_STR "1.2.0"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");
@@ -274,6 +274,10 @@ static int myri10ge_fill_thresh = 256;
 module_param(myri10ge_fill_thresh, int, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(myri10ge_fill_thresh, "Number of empty rx slots allowed\n");
 
+static int myri10ge_wcfifo = 1;
+module_param(myri10ge_wcfifo, int, S_IRUGO);
+MODULE_PARM_DESC(myri10ge_wcfifo, "Enable WC Fifo when WC is enabled\n");
+
 #define MYRI10GE_FW_OFFSET 1024*1024
 #define MYRI10GE_HIGHPART_TO_U32(X) \
 (sizeof (X) == 8) ? ((u32)((u64)(X) >> 32)) : (0)
@@ -1714,7 +1718,7 @@ static int myri10ge_open(struct net_device *dev)
 		goto abort_with_irq;
 	}
 
-	if (mgp->mtrr >= 0) {
+	if (myri10ge_wcfifo && mgp->mtrr >= 0) {
 		mgp->tx.wc_fifo = (u8 __iomem *) mgp->sram + MXGEFW_ETH_SEND_4;
 		mgp->rx_small.wc_fifo =
 		    (u8 __iomem *) mgp->sram + MXGEFW_ETH_RECV_SMALL;
@@ -2878,7 +2882,6 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netdev->hard_start_xmit = myri10ge_xmit;
 	netdev->get_stats = myri10ge_get_stats;
 	netdev->base_addr = mgp->iomem_base;
-	netdev->irq = pdev->irq;
 	netdev->change_mtu = myri10ge_change_mtu;
 	netdev->set_multicast_list = myri10ge_set_multicast_list;
 	netdev->set_mac_address = myri10ge_set_mac_address;
@@ -2888,6 +2891,15 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netdev->poll = myri10ge_poll;
 	netdev->weight = myri10ge_napi_weight;
 
+	/* make sure we can get an irq, and that MSI can be
+	 * setup (if available).  Also ensure netdev->irq
+	 * is set to correct value if MSI is enabled */
+	status = myri10ge_request_irq(mgp);
+	if (status != 0)
+		goto abort_with_firmware;
+	netdev->irq = pdev->irq;
+	myri10ge_free_irq(mgp);
+
 	/* Save configuration space to be restored if the
 	 * nic resets due to a parity error */
 	pci_save_state(pdev);
@@ -2903,8 +2915,9 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev_err(&pdev->dev, "register_netdev failed: %d\n", status);
 		goto abort_with_state;
 	}
-	dev_info(dev, "%d, tx bndry %d, fw %s, WC %s\n",
-		 pdev->irq, mgp->tx.boundary, mgp->fw_name,
+	dev_info(dev, "%s IRQ %d, tx bndry %d, fw %s, WC %s\n",
+		 (mgp->msi_enabled ? "MSI" : "xPIC"),
+		 netdev->irq, mgp->tx.boundary, mgp->fw_name,
 		 (mgp->mtrr >= 0 ? "Enabled" : "Disabled"));
 
 	return 0;
diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index b70ed79..45d91b1 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -1562,7 +1562,7 @@ static int __devinit sis190_get_mac_addr_from_eeprom(struct pci_dev *pdev,
 	for (i = 0; i < MAC_ADDR_LEN / 2; i++) {
 		__le16 w = sis190_read_eeprom(ioaddr, EEPROMMACAddr + i);
 
-		((u16 *)dev->dev_addr)[0] = le16_to_cpu(w);
+		((u16 *)dev->dev_addr)[i] = le16_to_cpu(w);
 	}
 
 	sis190_set_rgmii(tp, sis190_read_eeprom(ioaddr, EEPROMInfo));
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 8243150..7e4b23c 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -29,6 +29,7 @@
 #include <linux/fsl_devices.h>
 #include <linux/ethtool.h>
 #include <linux/mii.h>
+#include <linux/workqueue.h>
 
 #include <asm/of_platform.h>
 #include <asm/uaccess.h>
@@ -472,7 +473,7 @@ static void put_enet_addr_container(struct enet_addr_container *enet_addr_cont)
 	kfree(enet_addr_cont);
 }
 
-static int set_mac_addr(__be16 __iomem *reg, u8 *mac)
+static void set_mac_addr(__be16 __iomem *reg, u8 *mac)
 {
 	out_be16(&reg[0], ((u16)mac[5] << 8) | mac[4]);
 	out_be16(&reg[1], ((u16)mac[3] << 8) | mac[2]);
@@ -3920,10 +3921,11 @@ static irqreturn_t phy_interrupt(int irq, void *dev_id)
 }
 
 /* Scheduled by the phy_interrupt/timer to handle PHY changes */
-static void ugeth_phy_change(void *data)
+static void ugeth_phy_change(struct work_struct *work)
 {
-	struct net_device *dev = (struct net_device *)data;
-	struct ucc_geth_private *ugeth = netdev_priv(dev);
+	struct ucc_geth_private *ugeth =
+		container_of(work, struct ucc_geth_private, tq);
+	struct net_device *dev = ugeth->dev;
 	struct ucc_geth *ug_regs;
 	int result = 0;
 
@@ -4080,7 +4082,7 @@ static int ucc_geth_open(struct net_device *dev)
 #endif				/* CONFIG_UGETH_NAPI */
 
 	/* Set up the PHY change work queue */
-	INIT_WORK(&ugeth->tq, ugeth_phy_change, dev);
+	INIT_WORK(&ugeth->tq, ugeth_phy_change);
 
 	init_timer(&ugeth->phy_info_timer);
 	ugeth->phy_info_timer.function = &ugeth_phy_startup_timer;
diff --git a/drivers/net/ucc_geth_phy.c b/drivers/net/ucc_geth_phy.c
index 5360ec0..3c86592 100644
--- a/drivers/net/ucc_geth_phy.c
+++ b/drivers/net/ucc_geth_phy.c
@@ -68,8 +68,31 @@ static int gbit_config_aneg(struct ugeth_mii_info *mii_info);
 static int genmii_config_aneg(struct ugeth_mii_info *mii_info);
 static int genmii_update_link(struct ugeth_mii_info *mii_info);
 static int genmii_read_status(struct ugeth_mii_info *mii_info);
-u16 phy_read(struct ugeth_mii_info *mii_info, u16 regnum);
-void phy_write(struct ugeth_mii_info *mii_info, u16 regnum, u16 val);
+
+static u16 ucc_geth_phy_read(struct ugeth_mii_info *mii_info, u16 regnum)
+{
+	u16 retval;
+	unsigned long flags;
+
+	ugphy_vdbg("%s: IN", __FUNCTION__);
+
+	spin_lock_irqsave(&mii_info->mdio_lock, flags);
+	retval = mii_info->mdio_read(mii_info->dev, mii_info->mii_id, regnum);
+	spin_unlock_irqrestore(&mii_info->mdio_lock, flags);
+
+	return retval;
+}
+
+static void ucc_geth_phy_write(struct ugeth_mii_info *mii_info, u16 regnum, u16 val)
+{
+	unsigned long flags;
+
+	ugphy_vdbg("%s: IN", __FUNCTION__);
+
+	spin_lock_irqsave(&mii_info->mdio_lock, flags);
+	mii_info->mdio_write(mii_info->dev, mii_info->mii_id, regnum, val);
+	spin_unlock_irqrestore(&mii_info->mdio_lock, flags);
+}
 
 /* Write value to the PHY for this device to the register at regnum, */
 /* waiting until the write is done before it returns.  All PHY */
@@ -184,7 +207,7 @@ static void config_genmii_advert(struct ugeth_mii_info *mii_info)
 	advertise = mii_info->advertising;
 
 	/* Setup standard advertisement */
-	adv = phy_read(mii_info, MII_ADVERTISE);
+	adv = ucc_geth_phy_read(mii_info, MII_ADVERTISE);
 	adv &= ~(ADVERTISE_ALL | ADVERTISE_100BASE4);
 	if (advertise & ADVERTISED_10baseT_Half)
 		adv |= ADVERTISE_10HALF;
@@ -194,7 +217,7 @@ static void config_genmii_advert(struct ugeth_mii_info *mii_info)
 		adv |= ADVERTISE_100HALF;
 	if (advertise & ADVERTISED_100baseT_Full)
 		adv |= ADVERTISE_100FULL;
-	phy_write(mii_info, MII_ADVERTISE, adv);
+	ucc_geth_phy_write(mii_info, MII_ADVERTISE, adv);
 }
 
 static void genmii_setup_forced(struct ugeth_mii_info *mii_info)
@@ -204,7 +227,7 @@ static void genmii_setup_forced(struct ugeth_mii_info *mii_info)
 
 	ugphy_vdbg("%s: IN", __FUNCTION__);
 
-	ctrl = phy_read(mii_info, MII_BMCR);
+	ctrl = ucc_geth_phy_read(mii_info, MII_BMCR);
 
 	ctrl &=
 	    ~(BMCR_FULLDPLX | BMCR_SPEED100 | BMCR_SPEED1000 | BMCR_ANENABLE);
@@ -234,7 +257,7 @@ static void genmii_setup_forced(struct ugeth_mii_info *mii_info)
 		break;
 	}
 
-	phy_write(mii_info, MII_BMCR, ctrl);
+	ucc_geth_phy_write(mii_info, MII_BMCR, ctrl);
 }
 
 /* Enable and Restart Autonegotiation */
@@ -244,9 +267,9 @@ static void genmii_restart_aneg(struct ugeth_mii_info *mii_info)
 
 	ugphy_vdbg("%s: IN", __FUNCTION__);
 
-	ctl = phy_read(mii_info, MII_BMCR);
+	ctl = ucc_geth_phy_read(mii_info, MII_BMCR);
 	ctl |= (BMCR_ANENABLE | BMCR_ANRESTART);
-	phy_write(mii_info, MII_BMCR, ctl);
+	ucc_geth_phy_write(mii_info, MII_BMCR, ctl);
 }
 
 static int gbit_config_aneg(struct ugeth_mii_info *mii_info)
@@ -261,14 +284,14 @@ static int gbit_config_aneg(struct ugeth_mii_info *mii_info)
 		config_genmii_advert(mii_info);
 		advertise = mii_info->advertising;
 
-		adv = phy_read(mii_info, MII_1000BASETCONTROL);
+		adv = ucc_geth_phy_read(mii_info, MII_1000BASETCONTROL);
 		adv &= ~(MII_1000BASETCONTROL_FULLDUPLEXCAP |
 			 MII_1000BASETCONTROL_HALFDUPLEXCAP);
 		if (advertise & SUPPORTED_1000baseT_Half)
 			adv |= MII_1000BASETCONTROL_HALFDUPLEXCAP;
 		if (advertise & SUPPORTED_1000baseT_Full)
 			adv |= MII_1000BASETCONTROL_FULLDUPLEXCAP;
-		phy_write(mii_info, MII_1000BASETCONTROL, adv);
+		ucc_geth_phy_write(mii_info, MII_1000BASETCONTROL, adv);
 
 		/* Start/Restart aneg */
 		genmii_restart_aneg(mii_info);
@@ -298,10 +321,10 @@ static int genmii_update_link(struct ugeth_mii_info *mii_info)
 	ugphy_vdbg("%s: IN", __FUNCTION__);
 
 	/* Do a fake read */
-	phy_read(mii_info, MII_BMSR);
+	ucc_geth_phy_read(mii_info, MII_BMSR);
 
 	/* Read link and autonegotiation status */
-	status = phy_read(mii_info, MII_BMSR);
+	status = ucc_geth_phy_read(mii_info, MII_BMSR);
 	if ((status & BMSR_LSTATUS) == 0)
 		mii_info->link = 0;
 	else
@@ -329,7 +352,7 @@ static int genmii_read_status(struct ugeth_mii_info *mii_info)
 		return err;
 
 	if (mii_info->autoneg) {
-		status = phy_read(mii_info, MII_LPA);
+		status = ucc_geth_phy_read(mii_info, MII_LPA);
 
 		if (status & (LPA_10FULL | LPA_100FULL))
 			mii_info->duplex = DUPLEX_FULL;
@@ -352,9 +375,9 @@ static int marvell_init(struct ugeth_mii_info *mii_info)
 {
 	ugphy_vdbg("%s: IN", __FUNCTION__);
 
-	phy_write(mii_info, 0x14, 0x0cd2);
-	phy_write(mii_info, MII_BMCR,
-		  phy_read(mii_info, MII_BMCR) | BMCR_RESET);
+	ucc_geth_phy_write(mii_info, 0x14, 0x0cd2);
+	ucc_geth_phy_write(mii_info, MII_BMCR,
+		  ucc_geth_phy_read(mii_info, MII_BMCR) | BMCR_RESET);
 	msleep(4000);
 
 	return 0;
@@ -367,13 +390,13 @@ static int marvell_config_aneg(struct ugeth_mii_info *mii_info)
 	/* The Marvell PHY has an errata which requires
 	 * that certain registers get written in order
 	 * to restart autonegotiation */
-	phy_write(mii_info, MII_BMCR, BMCR_RESET);
+	ucc_geth_phy_write(mii_info, MII_BMCR, BMCR_RESET);
 
-	phy_write(mii_info, 0x1d, 0x1f);
-	phy_write(mii_info, 0x1e, 0x200c);
-	phy_write(mii_info, 0x1d, 0x5);
-	phy_write(mii_info, 0x1e, 0);
-	phy_write(mii_info, 0x1e, 0x100);
+	ucc_geth_phy_write(mii_info, 0x1d, 0x1f);
+	ucc_geth_phy_write(mii_info, 0x1e, 0x200c);
+	ucc_geth_phy_write(mii_info, 0x1d, 0x5);
+	ucc_geth_phy_write(mii_info, 0x1e, 0);
+	ucc_geth_phy_write(mii_info, 0x1e, 0x100);
 
 	gbit_config_aneg(mii_info);
 
@@ -398,7 +421,7 @@ static int marvell_read_status(struct ugeth_mii_info *mii_info)
 	 * are as set */
 	if (mii_info->autoneg && mii_info->link) {
 		int speed;
-		status = phy_read(mii_info, MII_M1011_PHY_SPEC_STATUS);
+		status = ucc_geth_phy_read(mii_info, MII_M1011_PHY_SPEC_STATUS);
 
 		/* Get the duplexity */
 		if (status & MII_M1011_PHY_SPEC_STATUS_FULLDUPLEX)
@@ -430,7 +453,7 @@ static int marvell_ack_interrupt(struct ugeth_mii_info *mii_info)
 	ugphy_vdbg("%s: IN", __FUNCTION__);
 
 	/* Clear the interrupts by reading the reg */
-	phy_read(mii_info, MII_M1011_IEVENT);
+	ucc_geth_phy_read(mii_info, MII_M1011_IEVENT);
 
 	return 0;
 }
@@ -440,9 +463,9 @@ static int marvell_config_intr(struct ugeth_mii_info *mii_info)
 	ugphy_vdbg("%s: IN", __FUNCTION__);
 
 	if (mii_info->interrupts == MII_INTERRUPT_ENABLED)
-		phy_write(mii_info, MII_M1011_IMASK, MII_M1011_IMASK_INIT);
+		ucc_geth_phy_write(mii_info, MII_M1011_IMASK, MII_M1011_IMASK_INIT);
 	else
-		phy_write(mii_info, MII_M1011_IMASK, MII_M1011_IMASK_CLEAR);
+		ucc_geth_phy_write(mii_info, MII_M1011_IMASK, MII_M1011_IMASK_CLEAR);
 
 	return 0;
 }
@@ -451,9 +474,9 @@ static int cis820x_init(struct ugeth_mii_info *mii_info)
 {
 	ugphy_vdbg("%s: IN", __FUNCTION__);
 
-	phy_write(mii_info, MII_CIS8201_AUX_CONSTAT,
+	ucc_geth_phy_write(mii_info, MII_CIS8201_AUX_CONSTAT,
 		  MII_CIS8201_AUXCONSTAT_INIT);
-	phy_write(mii_info, MII_CIS8201_EXT_CON1, MII_CIS8201_EXTCON1_INIT);
+	ucc_geth_phy_write(mii_info, MII_CIS8201_EXT_CON1, MII_CIS8201_EXTCON1_INIT);
 
 	return 0;
 }
@@ -477,7 +500,7 @@ static int cis820x_read_status(struct ugeth_mii_info *mii_info)
 	if (mii_info->autoneg && mii_info->link) {
 		int speed;
 
-		status = phy_read(mii_info, MII_CIS8201_AUX_CONSTAT);
+		status = ucc_geth_phy_read(mii_info, MII_CIS8201_AUX_CONSTAT);
 		if (status & MII_CIS8201_AUXCONSTAT_DUPLEX)
 			mii_info->duplex = DUPLEX_FULL;
 		else
@@ -505,7 +528,7 @@ static int cis820x_ack_interrupt(struct ugeth_mii_info *mii_info)
 {
 	ugphy_vdbg("%s: IN", __FUNCTION__);
 
-	phy_read(mii_info, MII_CIS8201_ISTAT);
+	ucc_geth_phy_read(mii_info, MII_CIS8201_ISTAT);
 
 	return 0;
 }
@@ -515,9 +538,9 @@ static int cis820x_config_intr(struct ugeth_mii_info *mii_info)
 	ugphy_vdbg("%s: IN", __FUNCTION__);
 
 	if (mii_info->interrupts == MII_INTERRUPT_ENABLED)
-		phy_write(mii_info, MII_CIS8201_IMASK, MII_CIS8201_IMASK_MASK);
+		ucc_geth_phy_write(mii_info, MII_CIS8201_IMASK, MII_CIS8201_IMASK_MASK);
 	else
-		phy_write(mii_info, MII_CIS8201_IMASK, 0);
+		ucc_geth_phy_write(mii_info, MII_CIS8201_IMASK, 0);
 
 	return 0;
 }
@@ -541,7 +564,7 @@ static int dm9161_read_status(struct ugeth_mii_info *mii_info)
 	/* If we aren't autonegotiating, assume speeds
 	 * are as set */
 	if (mii_info->autoneg && mii_info->link) {
-		status = phy_read(mii_info, MII_DM9161_SCSR);
+		status = ucc_geth_phy_read(mii_info, MII_DM9161_SCSR);
 		if (status & (MII_DM9161_SCSR_100F | MII_DM9161_SCSR_100H))
 			mii_info->speed = SPEED_100;
 		else
@@ -572,7 +595,7 @@ static void dm9161_timer(unsigned long data)
 {
 	struct ugeth_mii_info *mii_info = (struct ugeth_mii_info *)data;
 	struct dm9161_private *priv = mii_info->priv;
-	u16 status = phy_read(mii_info, MII_BMSR);
+	u16 status = ucc_geth_phy_read(mii_info, MII_BMSR);
 
 	ugphy_vdbg("%s: IN", __FUNCTION__);
 
@@ -599,11 +622,11 @@ static int dm9161_init(struct ugeth_mii_info *mii_info)
 	/* Reset is not done yet */
 	priv->resetdone = 0;
 
-	phy_write(mii_info, MII_BMCR,
-		  phy_read(mii_info, MII_BMCR) | BMCR_RESET);
+	ucc_geth_phy_write(mii_info, MII_BMCR,
+		  ucc_geth_phy_read(mii_info, MII_BMCR) | BMCR_RESET);
 
-	phy_write(mii_info, MII_BMCR,
-		  phy_read(mii_info, MII_BMCR) & ~BMCR_ISOLATE);
+	ucc_geth_phy_write(mii_info, MII_BMCR,
+		  ucc_geth_phy_read(mii_info, MII_BMCR) & ~BMCR_ISOLATE);
 
 	config_genmii_advert(mii_info);
 	/* Start/Restart aneg */
@@ -634,7 +657,7 @@ static int dm9161_ack_interrupt(struct ugeth_mii_info *mii_info)
 	ugphy_vdbg("%s: IN", __FUNCTION__);
 
 	/* Clear the interrupts by reading the reg */
-	phy_read(mii_info, MII_DM9161_INTR);
+	ucc_geth_phy_read(mii_info, MII_DM9161_INTR);
 
 
 	return 0;
@@ -645,9 +668,9 @@ static int dm9161_config_intr(struct ugeth_mii_info *mii_info)
 	ugphy_vdbg("%s: IN", __FUNCTION__);
 
 	if (mii_info->interrupts == MII_INTERRUPT_ENABLED)
-		phy_write(mii_info, MII_DM9161_INTR, MII_DM9161_INTR_INIT);
+		ucc_geth_phy_write(mii_info, MII_DM9161_INTR, MII_DM9161_INTR_INIT);
 	else
-		phy_write(mii_info, MII_DM9161_INTR, MII_DM9161_INTR_STOP);
+		ucc_geth_phy_write(mii_info, MII_DM9161_INTR, MII_DM9161_INTR_STOP);
 
 	return 0;
 }
@@ -718,31 +741,6 @@ static struct phy_info *phy_info[] = {
 	NULL
 };
 
-u16 phy_read(struct ugeth_mii_info *mii_info, u16 regnum)
-{
-	u16 retval;
-	unsigned long flags;
-
-	ugphy_vdbg("%s: IN", __FUNCTION__);
-
-	spin_lock_irqsave(&mii_info->mdio_lock, flags);
-	retval = mii_info->mdio_read(mii_info->dev, mii_info->mii_id, regnum);
-	spin_unlock_irqrestore(&mii_info->mdio_lock, flags);
-
-	return retval;
-}
-
-void phy_write(struct ugeth_mii_info *mii_info, u16 regnum, u16 val)
-{
-	unsigned long flags;
-
-	ugphy_vdbg("%s: IN", __FUNCTION__);
-
-	spin_lock_irqsave(&mii_info->mdio_lock, flags);
-	mii_info->mdio_write(mii_info->dev, mii_info->mii_id, regnum, val);
-	spin_unlock_irqrestore(&mii_info->mdio_lock, flags);
-}
-
 /* Use the PHY ID registers to determine what type of PHY is attached
  * to device dev.  return a struct phy_info structure describing that PHY
  */
@@ -757,11 +755,11 @@ struct phy_info *get_phy_info(struct ugeth_mii_info *mii_info)
 	ugphy_vdbg("%s: IN", __FUNCTION__);
 
 	/* Grab the bits from PHYIR1, and put them in the upper half */
-	phy_reg = phy_read(mii_info, MII_PHYSID1);
+	phy_reg = ucc_geth_phy_read(mii_info, MII_PHYSID1);
 	phy_ID = (phy_reg & 0xffff) << 16;
 
 	/* Grab the bits from PHYIR2, and put them in the lower half */
-	phy_reg = phy_read(mii_info, MII_PHYSID2);
+	phy_reg = ucc_geth_phy_read(mii_info, MII_PHYSID2);
 	phy_ID |= (phy_reg & 0xffff);
 
 	/* loop through all the known PHY types, and find one that */
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
index 2ec2e5a..91b752e 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -2701,8 +2701,8 @@ static int bcm43xx_probe_cores(struct bcm43xx_private *bcm)
 		sb_id_hi = bcm43xx_read32(bcm, BCM43xx_CIR_SB_ID_HI);
 
 		/* extract core_id, core_rev, core_vendor */
-		core_id = (sb_id_hi & 0xFFF0) >> 4;
-		core_rev = (sb_id_hi & 0xF);
+		core_id = (sb_id_hi & 0x8FF0) >> 4;
+		core_rev = ((sb_id_hi & 0xF) | ((sb_id_hi & 0x7000) >> 8));
 		core_vendor = (sb_id_hi & 0xFFFF0000) >> 16;
 
 		dprintk(KERN_INFO PFX "Core %d: ID 0x%x, rev 0x%x, vendor 0x%x\n",
@@ -2873,7 +2873,10 @@ static int bcm43xx_wireless_core_init(struct bcm43xx_private *bcm,
 		sbimconfiglow = bcm43xx_read32(bcm, BCM43xx_CIR_SBIMCONFIGLOW);
 		sbimconfiglow &= ~ BCM43xx_SBIMCONFIGLOW_REQUEST_TOUT_MASK;
 		sbimconfiglow &= ~ BCM43xx_SBIMCONFIGLOW_SERVICE_TOUT_MASK;
-		sbimconfiglow |= 0x32;
+		if (bcm->bustype == BCM43xx_BUSTYPE_PCI)
+			sbimconfiglow |= 0x32;
+		else
+			sbimconfiglow |= 0x53;
 		bcm43xx_write32(bcm, BCM43xx_CIR_SBIMCONFIGLOW, sbimconfiglow);
 	}
 
@@ -3077,7 +3080,7 @@ static int bcm43xx_setup_backplane_pci_connection(struct bcm43xx_private *bcm,
 	if (err)
 		goto out;
 
-	if (bcm->current_core->rev < 6 ||
+	if (bcm->current_core->rev < 6 &&
 		bcm->current_core->id == BCM43xx_COREID_PCI) {
 		value = bcm43xx_read32(bcm, BCM43xx_CIR_SBINTVEC);
 		value |= (1 << backplane_flag_nr);
