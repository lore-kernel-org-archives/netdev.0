From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] fix oops from acenic ethtool
Date: Mon, 14 Jun 2004 09:40:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040614094034.7f06445c@dell_ss3.pdx.osdl.net>
References: <20040604145333.34d1600f@dell_ss3.pdx.osdl.net>
	<40C9022F.8050102@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jes Sorensen <jes@wildopensource.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <40C9022F.8050102@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here is a revised version of the acenic patch:
	* use ethtool_ops - solves OOPS on boot up
	* put firmware and driver version in correct place in ethtool info response
	* get rid of #ifdef SIOCETHTOOL

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -urN -X dontdiff linux-2.6/drivers/net/acenic.c tcp-2.6/drivers/net/acenic.c
--- linux-2.6/drivers/net/acenic.c	2004-05-28 08:33:52.000000000 -0700
+++ tcp-2.6/drivers/net/acenic.c	2004-06-14 08:29:56.237392072 -0700
@@ -71,9 +71,7 @@
 #include <linux/if_vlan.h>
 #endif
 
-#ifdef SIOCETHTOOL
 #include <linux/ethtool.h>
-#endif
 
 #include <net/sock.h>
 #include <net/ip.h>
@@ -438,11 +436,22 @@
 MODULE_PARM_DESC(max_rx_desc, "AceNIC/3C985/GA620 max number of receive descriptors to wait");
 MODULE_PARM_DESC(tx_ratio, "AceNIC/3C985/GA620 ratio of NIC memory used for TX/RX descriptors (range 0-63)");
 
+#define DRIVER_VERSION "0.92"
 
 static char version[] __initdata = 
-  "acenic.c: v0.92 08/05/2002  Jes Sorensen, linux-acenic@SunSITE.dk\n"
+  "acenic.c: v" DRIVER_VERSION "08/05/2002  Jes Sorensen, linux-acenic@SunSITE.dk\n"
   "                            http://home.cern.ch/~jes/gige/acenic.html\n";
 
+static int ace_get_settings(struct net_device *, struct ethtool_cmd *);
+static int ace_set_settings(struct net_device *, struct ethtool_cmd *);
+static void ace_get_drvinfo(struct net_device *, struct ethtool_drvinfo *);
+
+static struct ethtool_ops ace_ethtool_ops = {
+	.get_settings = ace_get_settings,
+	.set_settings = ace_set_settings,
+	.get_drvinfo = ace_get_drvinfo,
+};
+
 static int __devinit acenic_probe_one(struct pci_dev *pdev,
 		const struct pci_device_id *id)
 {
@@ -480,7 +489,7 @@
 	dev->hard_start_xmit = &ace_start_xmit;
 	dev->get_stats = &ace_get_stats;
 	dev->set_multicast_list = &ace_set_multicast_list;
-	dev->do_ioctl = &ace_ioctl;
+	SET_ETHTOOL_OPS(dev, &ace_ethtool_ops);
 	dev->set_mac_address = &ace_set_mac_addr;
 	dev->change_mtu = &ace_change_mtu;
 
@@ -2688,146 +2697,137 @@
 	return 0;
 }
 
-
-static int ace_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+static int ace_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
 	struct ace_private *ap = dev->priv;
 	struct ace_regs *regs = ap->regs;
-#ifdef SIOCETHTOOL
-	struct ethtool_cmd ecmd;
-	u32 link, speed;
+	u32 link;
 
-	if (cmd != SIOCETHTOOL)
-		return -EOPNOTSUPP;
-	if (copy_from_user(&ecmd, ifr->ifr_data, sizeof(ecmd)))
-		return -EFAULT;
-	switch (ecmd.cmd) {
-	case ETHTOOL_GSET:
-		ecmd.supported =
-			(SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full |
-			 SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full |
-			 SUPPORTED_1000baseT_Half | SUPPORTED_1000baseT_Full |
-			 SUPPORTED_Autoneg | SUPPORTED_FIBRE);
-
-		ecmd.port = PORT_FIBRE;
-		ecmd.transceiver = XCVR_INTERNAL;
-		ecmd.phy_address = 0;
-
-		link = readl(&regs->GigLnkState);
-		if (link & LNK_1000MB)
-			ecmd.speed = SPEED_1000;
-		else {
-			link = readl(&regs->FastLnkState);
-			if (link & LNK_100MB)
-				ecmd.speed = SPEED_100;
-			else if (link & LNK_100MB)
-				ecmd.speed = SPEED_10;
-			else
-				ecmd.speed = 0;
-		}
-		if (link & LNK_FULL_DUPLEX)
-			ecmd.duplex = DUPLEX_FULL;
+	memset(ecmd, 0, sizeof(struct ethtool_cmd));
+	ecmd->supported =
+		(SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full |
+		 SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full |
+		 SUPPORTED_1000baseT_Half | SUPPORTED_1000baseT_Full |
+		 SUPPORTED_Autoneg | SUPPORTED_FIBRE);
+
+	ecmd->port = PORT_FIBRE;
+	ecmd->transceiver = XCVR_INTERNAL;
+
+	link = readl(&regs->GigLnkState);
+	if (link & LNK_1000MB)
+		ecmd->speed = SPEED_1000;
+	else {
+		link = readl(&regs->FastLnkState);
+		if (link & LNK_100MB)
+			ecmd->speed = SPEED_100;
+		else if (link & LNK_100MB)
+			ecmd->speed = SPEED_10;
 		else
-			ecmd.duplex = DUPLEX_HALF;
+			ecmd->speed = 0;
+	}
+	if (link & LNK_FULL_DUPLEX)
+		ecmd->duplex = DUPLEX_FULL;
+	else
+		ecmd->duplex = DUPLEX_HALF;
 
-		if (link & LNK_NEGOTIATE)
-			ecmd.autoneg = AUTONEG_ENABLE;
-		else
-			ecmd.autoneg = AUTONEG_DISABLE;
+	if (link & LNK_NEGOTIATE)
+		ecmd->autoneg = AUTONEG_ENABLE;
+	else
+		ecmd->autoneg = AUTONEG_DISABLE;
 
 #if 0
-		/*
-		 * Current struct ethtool_cmd is insufficient
-		 */
-		ecmd.trace = readl(&regs->TuneTrace);
+	/*
+	 * Current struct ethtool_cmd is insufficient
+	 */
+	ecmd->trace = readl(&regs->TuneTrace);
 
-		ecmd.txcoal = readl(&regs->TuneTxCoalTicks);
-		ecmd.rxcoal = readl(&regs->TuneRxCoalTicks);
+	ecmd->txcoal = readl(&regs->TuneTxCoalTicks);
+	ecmd->rxcoal = readl(&regs->TuneRxCoalTicks);
 #endif
-		ecmd.maxtxpkt = readl(&regs->TuneMaxTxDesc);
-		ecmd.maxrxpkt = readl(&regs->TuneMaxRxDesc);
+	ecmd->maxtxpkt = readl(&regs->TuneMaxTxDesc);
+	ecmd->maxrxpkt = readl(&regs->TuneMaxRxDesc);
 
-		if(copy_to_user(ifr->ifr_data, &ecmd, sizeof(ecmd)))
-			return -EFAULT;
-		return 0;
-
-	case ETHTOOL_SSET:
-		link = readl(&regs->GigLnkState);
-		if (link & LNK_1000MB)
-			speed = SPEED_1000;
-		else {
-			link = readl(&regs->FastLnkState);
-			if (link & LNK_100MB)
-				speed = SPEED_100;
-			else if (link & LNK_100MB)
-				speed = SPEED_10;
-			else
-				speed = SPEED_100;
-		}
+	return 0;
+}
 
-		link = LNK_ENABLE | LNK_1000MB | LNK_100MB | LNK_10MB |
-			LNK_RX_FLOW_CTL_Y | LNK_NEG_FCTL;
-		if (!ACE_IS_TIGON_I(ap))
-			link |= LNK_TX_FLOW_CTL_Y;
-		if (ecmd.autoneg == AUTONEG_ENABLE)
-			link |= LNK_NEGOTIATE;
-		if (ecmd.speed != speed) {
-			link &= ~(LNK_1000MB | LNK_100MB | LNK_10MB);
-			switch (speed) {
-			case SPEED_1000:
-				link |= LNK_1000MB;
-				break;
-			case SPEED_100:
-				link |= LNK_100MB;
-				break;
-			case SPEED_10:
-				link |= LNK_10MB;
-				break;
-			}
+static int ace_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+{
+	struct ace_private *ap = dev->priv;
+	struct ace_regs *regs = ap->regs;
+	u32 link, speed;
+
+	link = readl(&regs->GigLnkState);
+	if (link & LNK_1000MB)
+		speed = SPEED_1000;
+	else {
+		link = readl(&regs->FastLnkState);
+		if (link & LNK_100MB)
+			speed = SPEED_100;
+		else if (link & LNK_100MB)
+			speed = SPEED_10;
+		else
+			speed = SPEED_100;
+	}
+
+	link = LNK_ENABLE | LNK_1000MB | LNK_100MB | LNK_10MB |
+		LNK_RX_FLOW_CTL_Y | LNK_NEG_FCTL;
+	if (!ACE_IS_TIGON_I(ap))
+		link |= LNK_TX_FLOW_CTL_Y;
+	if (ecmd->autoneg == AUTONEG_ENABLE)
+		link |= LNK_NEGOTIATE;
+	if (ecmd->speed != speed) {
+		link &= ~(LNK_1000MB | LNK_100MB | LNK_10MB);
+		switch (speed) {
+		case SPEED_1000:
+			link |= LNK_1000MB;
+			break;
+		case SPEED_100:
+			link |= LNK_100MB;
+			break;
+		case SPEED_10:
+			link |= LNK_10MB;
+			break;
 		}
-		if (ecmd.duplex == DUPLEX_FULL)
-			link |= LNK_FULL_DUPLEX;
+	}
 
-		if (link != ap->link) {
-			struct cmd cmd;
-			printk(KERN_INFO "%s: Renegotiating link state\n",
-			       dev->name);
+	if (ecmd->duplex == DUPLEX_FULL)
+		link |= LNK_FULL_DUPLEX;
 
-			ap->link = link;
-			writel(link, &regs->TuneLink);
-			if (!ACE_IS_TIGON_I(ap))
-				writel(link, &regs->TuneFastLink);
-			wmb();
+	if (link != ap->link) {
+		struct cmd cmd;
+		printk(KERN_INFO "%s: Renegotiating link state\n",
+		       dev->name);
 
-			cmd.evt = C_LNK_NEGOTIATION;
-			cmd.code = 0;
-			cmd.idx = 0;
-			ace_issue_cmd(regs, &cmd);
-		}
-		return 0;
+		ap->link = link;
+		writel(link, &regs->TuneLink);
+		if (!ACE_IS_TIGON_I(ap))
+			writel(link, &regs->TuneFastLink);
+		wmb();
 
-	case ETHTOOL_GDRVINFO: {
-		struct ethtool_drvinfo info = {ETHTOOL_GDRVINFO};
-		strncpy(info.driver, "acenic", sizeof(info.driver) - 1);
-		sprintf(info.fw_version, "%i.%i.%i", 
-			 tigonFwReleaseMajor, tigonFwReleaseMinor,
-			 tigonFwReleaseFix);
-		strncpy(info.version, version, sizeof(info.version) - 1);
-		if (ap && ap->pdev)
-			strcpy(info.bus_info, pci_name(ap->pdev));
-		if (copy_to_user(ifr->ifr_data, &info, sizeof(info)))
-			return -EFAULT;
-		return 0;
-	}
-	default:
-		break;
+		cmd.evt = C_LNK_NEGOTIATION;
+		cmd.code = 0;
+		cmd.idx = 0;
+		ace_issue_cmd(regs, &cmd);
 	}
-	
-#endif
-
-	return -EOPNOTSUPP;
+	return 0;
 }
 
+static void ace_get_drvinfo(struct net_device *dev, 
+			    struct ethtool_drvinfo *info)
+{
+	struct ace_private *ap = dev->priv;
+
+	strcpy(info->driver, "acenic");
+	strcpy(info->version, DRIVER_VERSION);
+	snprintf(info->fw_version, sizeof(info->fw_version), "%i.%i.%i", 
+		tigonFwReleaseMajor, tigonFwReleaseMinor,
+		tigonFwReleaseFix);
+
+	if (ap->pdev)
+		strlcpy(info->bus_info, pci_name(ap->pdev), 
+			sizeof(info->bus_info));
+
+}
 
 /*
  * Set the hardware MAC address.
diff -urN -X dontdiff linux-2.6/drivers/net/acenic.h tcp-2.6/drivers/net/acenic.h
--- linux-2.6/drivers/net/acenic.h	2004-03-31 11:03:17.000000000 -0800
+++ tcp-2.6/drivers/net/acenic.h	2004-06-04 14:19:44.000000000 -0700
@@ -790,7 +790,6 @@
 static void ace_dump_trace(struct ace_private *ap);
 static void ace_set_multicast_list(struct net_device *dev);
 static int ace_change_mtu(struct net_device *dev, int new_mtu);
-static int ace_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
 static int ace_set_mac_addr(struct net_device *dev, void *p);
 static void ace_set_rxtx_parms(struct net_device *dev, int jumbo);
 static int ace_allocate_descriptors(struct net_device *dev);
