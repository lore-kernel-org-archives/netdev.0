From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH] 2.4.25 pcnet32.c change to use ethtool_ops
Date: Thu, 19 Feb 2004 15:34:12 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402192334.i1JNYCj05677@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This changes the driver to use ethtool_ops to be more modular.  There is a
net delta of just a one line between the two implementations, but permission
checking and copying to/from user space, etc. is all done in a consistent
manner by ethtool.c

Tested IA32

--- linux-2.4.25/drivers/net/net.pcnet32.c	Thu Feb 19 14:42:17 2004
+++ linux-2.4.25/drivers/net/pcnet32.c	Thu Feb 19 15:15:01 2004
@@ -462,6 +462,100 @@
 
 
 
+static int pcnet32_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct pcnet32_private *lp = dev->priv;
+	unsigned long flags;
+
+	spin_lock_irqsave(&lp->lock, flags);
+	mii_ethtool_gset(&lp->mii_if, cmd);
+	spin_unlock_irqrestore(&lp->lock, flags);
+	return 0;
+}
+
+static int pcnet32_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct pcnet32_private *lp = dev->priv;
+	unsigned long flags;
+	int r;
+
+	spin_lock_irqsave(&lp->lock, flags);
+	r = mii_ethtool_sset(&lp->mii_if, cmd);
+	spin_unlock_irqrestore(&lp->lock, flags);
+	return r;
+}
+
+static void pcnet32_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
+{
+	struct pcnet32_private *lp = dev->priv;
+  
+	strcpy (info->driver, DRV_NAME);
+	strcpy (info->version, DRV_VERSION);
+	if (lp->pci_dev)
+		strcpy (info->bus_info, pci_name(lp->pci_dev));
+	else
+		sprintf(info->bus_info, "VLB 0x%lx", dev->base_addr);
+}
+
+static u32 pcnet32_get_link(struct net_device *dev)
+{
+	struct pcnet32_private *lp = dev->priv;
+	unsigned long flags;
+	int r;
+
+	spin_lock_irqsave(&lp->lock, flags);
+	r = mii_link_ok(&lp->mii_if);
+	spin_unlock_irqrestore(&lp->lock, flags);
+	return r;
+}
+
+static u32 pcnet32_get_msglevel(struct net_device *dev)
+{
+	struct pcnet32_private *lp = dev->priv;
+	return lp->msg_enable;
+}
+  
+static void pcnet32_set_msglevel(struct net_device *dev, u32 value)
+{
+	struct pcnet32_private *lp = dev->priv;
+	lp->msg_enable = value;
+}
+  
+static int pcnet32_nway_reset(struct net_device *dev)
+{
+	struct pcnet32_private *lp = dev->priv;
+	unsigned long flags;
+	int r;
+
+	spin_lock_irqsave(&lp->lock, flags);
+	r = mii_nway_restart(&lp->mii_if);
+	spin_unlock_irqrestore(&lp->lock, flags);
+	return r;
+}
+
+static void pcnet32_get_ringparam(struct net_device *dev, struct ethtool_ringparam *ering)
+{
+	struct pcnet32_private *lp = dev->priv;
+
+	ering->tx_max_pending = TX_RING_SIZE - 1;
+	ering->tx_pending = lp->cur_tx - lp->dirty_tx;
+	ering->rx_max_pending = RX_RING_SIZE - 1;
+	ering->rx_pending = lp->cur_rx & RX_RING_MOD_MASK;
+}
+
+static struct ethtool_ops pcnet32_ethtool_ops = {
+	.get_settings		= pcnet32_get_settings,
+	.set_settings		= pcnet32_set_settings,
+	.get_drvinfo		= pcnet32_get_drvinfo,
+	.get_msglevel		= pcnet32_get_msglevel,
+	.set_msglevel		= pcnet32_set_msglevel,
+	.nway_reset		= pcnet32_nway_reset,
+	.get_link		= pcnet32_get_link,
+	.get_ringparam		= pcnet32_get_ringparam,
+	.get_tx_csum		= ethtool_op_get_tx_csum,
+	.get_sg			= ethtool_op_get_sg,
+};
+
 /* only probes for non-PCI devices, the rest are handled by 
  * pci_register_driver via pcnet32_probe_pci */
 
@@ -799,6 +893,7 @@
     dev->get_stats = &pcnet32_get_stats;
     dev->set_multicast_list = &pcnet32_set_multicast_list;
     dev->do_ioctl = &pcnet32_ioctl;
+    dev->ethtool_ops = &pcnet32_ethtool_ops;
     dev->tx_timeout = pcnet32_tx_timeout;
     dev->watchdog_timeo = (5*HZ);
 
@@ -1557,100 +1652,6 @@
 	lp->a.write_bcr(ioaddr, 33, phyaddr);
 }
 
-static int pcnet32_ethtool_ioctl (struct net_device *dev, void *useraddr)
-{
-	struct pcnet32_private *lp = dev->priv;
-	u32 ethcmd;
-	int phyaddr = 0;
-	int phy_id = 0;
-	unsigned long ioaddr = dev->base_addr;
-
-	if (lp->mii) {
-		phyaddr = lp->a.read_bcr (ioaddr, 33);
-		phy_id = (phyaddr >> 5) & 0x1f;
-		lp->mii_if.phy_id = phy_id;
-	}
-
-	if (copy_from_user (&ethcmd, useraddr, sizeof (ethcmd)))
-		return -EFAULT;
-
-	switch (ethcmd) {
-	case ETHTOOL_GDRVINFO: {
-		struct ethtool_drvinfo info = { ETHTOOL_GDRVINFO };
-		strcpy (info.driver, DRV_NAME);
-		strcpy (info.version, DRV_VERSION);
-		if (lp->pci_dev)
-			strcpy (info.bus_info, lp->pci_dev->slot_name);
-		else
-			sprintf(info.bus_info, "VLB 0x%lx", dev->base_addr);
-		if (copy_to_user (useraddr, &info, sizeof (info)))
-			return -EFAULT;
-		return 0;
-	}
-
-	/* get settings */
-	case ETHTOOL_GSET: {
-		struct ethtool_cmd ecmd = { ETHTOOL_GSET };
-		spin_lock_irq(&lp->lock);
-		mii_ethtool_gset(&lp->mii_if, &ecmd);
-		spin_unlock_irq(&lp->lock);
-		if (copy_to_user(useraddr, &ecmd, sizeof(ecmd)))
-			return -EFAULT;
-		return 0;
-	}
-	/* set settings */
-	case ETHTOOL_SSET: {
-		int r;
-		struct ethtool_cmd ecmd;
-		if (copy_from_user(&ecmd, useraddr, sizeof(ecmd)))
-			return -EFAULT;
-		spin_lock_irq(&lp->lock);
-		r = mii_ethtool_sset(&lp->mii_if, &ecmd);
-		spin_unlock_irq(&lp->lock);
-		return r;
-	}
-	/* restart autonegotiation */
-	case ETHTOOL_NWAY_RST: {
-		int r;
-		spin_lock_irq(&lp->lock);
-		r = mii_nway_restart(&lp->mii_if);
-		spin_unlock_irq(&lp->lock);
-		return r;
-	}
-	/* get link status */
-	case ETHTOOL_GLINK: {
-		struct ethtool_value edata = {ETHTOOL_GLINK};
-		spin_lock_irq(&lp->lock);
-		edata.data = mii_link_ok(&lp->mii_if);
-		spin_unlock_irq(&lp->lock);
-		if (copy_to_user(useraddr, &edata, sizeof(edata)))
-			return -EFAULT;
-		return 0;
-	}
-
-	/* get message-level */
-	case ETHTOOL_GMSGLVL: {
-		struct ethtool_value edata = {ETHTOOL_GMSGLVL};
-		edata.data = lp->msg_enable;
-		if (copy_to_user(useraddr, &edata, sizeof(edata)))
-			return -EFAULT;
-		return 0;
-	}
-	/* set message-level */
-	case ETHTOOL_SMSGLVL: {
-		struct ethtool_value edata;
-		if (copy_from_user(&edata, useraddr, sizeof(edata)))
-			return -EFAULT;
-		lp->msg_enable = edata.data;
-		return 0;
-	}
-	default:
-		break;
-	}
-
-	return -EOPNOTSUPP;
-}
-
 static int pcnet32_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
     struct pcnet32_private *lp = dev->priv;	 
@@ -1658,9 +1659,6 @@
     int rc;
     unsigned long flags;
 
-    if (cmd == SIOCETHTOOL)
-	return pcnet32_ethtool_ioctl(dev, (void *) rq->ifr_data);
-
     /* SIOC[GS]MIIxxx ioctls */
     if (lp->mii) {
 	spin_lock_irqsave(&lp->lock, flags);

-- 
Don Fry
brazilnut@us.ibm.com
