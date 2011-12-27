From: Zhao Chenhui <chenhui.zhao@freescale.com>
Subject: [PATCH v3] gianfar: add support for wake-on-packet
Date: Tue, 27 Dec 2011 19:30:55 +0800
Message-ID: <1324985455-26258-1-git-send-email-chenhui.zhao@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <devicetree-discuss@lists.ozlabs.org>,
	<leoli@freescale.com>, <afleming@freescale.com>
To: <linuxppc-dev@lists.ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe003.messaging.microsoft.com ([213.199.154.141]:27028
	"EHLO DB3EHSOBE003.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752453Ab1L0Lan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 06:30:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On certain chip like MPC8536 and P1022, system can be waked up from
sleep by user-defined packet and Magic Patcket.(The eTSEC cannot
supports both types of wake-up event simultaneously.) This patch
implements wake-up on user-defined patcket including ARP request
packet and unicast patcket to this station.

When entering suspend state, the gianfar driver sets receive queue
filer table to filter all of packets except ARP request packet and
unicast patcket to this station. The driver temporarily uses the last
receive queue to receive the user defined packet.

In suspend state, the receive part of eTSEC keeps working. When
receiving a user defined packet, it generates an interrupt to
wake up the system.

The rule of the filer table is as below.
  if (arp request to local ip address)
      accept it to the last queue
  elif (unicast packet to local mac address)
      accept it to the last queue
  else
      reject it
  endif
Note: The local ip/mac address is the ethernet primary IP/MAC address of
the station. Do not support multiple IP/MAC addresses.

Here is an example of enabling and testing wake up on user defined packet.
  ifconfig eth0 10.193.20.169
  ethtool -s eth0 wol a
  echo standby > /sys/power/state or echo mem > /sys/power/state

Ping from PC host to wake up the station:
  ping 10.193.20.169

Signed-off-by: Dave Liu <daveliu@freescale.com>
Signed-off-by: Jin Qing <b24347@freescale.com>
Signed-off-by: Li Yang <leoli@freescale.com>
Signed-off-by: Zhao Chenhui <chenhui.zhao@freescale.com>
Acked-by: Andy Fleming <afleming@freescale.com>
---
This patch depends on my previous patches related to power management.

Changes for v3:
 - Add "CONFIG_FSL_PMC"

 .../devicetree/bindings/net/fsl-tsec-phy.txt       |    3 +
 drivers/net/ethernet/freescale/gianfar.c           |  363 +++++++++++++++++---
 drivers/net/ethernet/freescale/gianfar.h           |   33 ++-
 drivers/net/ethernet/freescale/gianfar_ethtool.c   |   52 ++-
 4 files changed, 373 insertions(+), 78 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt b/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
index 2c6be03..543e36c 100644
--- a/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
+++ b/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
@@ -56,6 +56,9 @@ Properties:
     hardware.
   - fsl,magic-packet : If present, indicates that the hardware supports
     waking up via magic packet.
+  - fsl,wake-on-filer : If present, indicates that the hardware supports
+    waking up via arp request to local ip address or unicast packet to
+    local mac address.
   - bd-stash : If present, indicates that the hardware supports stashing
     buffer descriptors in the L2.
   - rx-stash-len : Denotes the number of bytes of a received buffer to stash
diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 83199fd..d0a46d8 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -85,6 +85,8 @@
 #include <linux/tcp.h>
 #include <linux/udp.h>
 #include <linux/in.h>
+#include <linux/inetdevice.h>
+#include <sysdev/fsl_soc.h>
 #include <linux/net_tstamp.h>
 
 #include <asm/io.h>
@@ -147,6 +149,17 @@ static void gfar_clear_exact_match(struct net_device *dev);
 static void gfar_set_mac_for_addr(struct net_device *dev, int num,
 				  const u8 *addr);
 static int gfar_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
+static void gfar_schedule_cleanup(struct gfar_priv_grp *gfargrp);
+
+#ifdef CONFIG_PM
+static void gfar_halt_rx(struct net_device *dev);
+static void gfar_rx_start(struct net_device *dev);
+static void gfar_enable_filer(struct net_device *dev);
+static void gfar_disable_filer(struct net_device *dev);
+static void gfar_config_filer_table(struct net_device *dev);
+static void gfar_restore_filer_table(struct net_device *dev);
+static int gfar_get_ip(struct net_device *dev);
+#endif
 
 MODULE_AUTHOR("Freescale Semiconductor, Inc");
 MODULE_DESCRIPTION("Gianfar Ethernet Driver");
@@ -751,7 +764,6 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 			FSL_GIANFAR_DEV_HAS_PADDING |
 			FSL_GIANFAR_DEV_HAS_CSUM |
 			FSL_GIANFAR_DEV_HAS_VLAN |
-			FSL_GIANFAR_DEV_HAS_MAGIC_PACKET |
 			FSL_GIANFAR_DEV_HAS_EXTENDED_HASH |
 			FSL_GIANFAR_DEV_HAS_TIMER;
 
@@ -763,9 +775,21 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 	else
 		priv->interface = PHY_INTERFACE_MODE_MII;
 
-	if (of_get_property(np, "fsl,magic-packet", NULL))
+	/* Init Wake-on-LAN */
+	priv->wol_opts = 0;
+	priv->wol_supported = 0;
+#ifdef CONFIG_FSL_PMC
+	if (of_get_property(np, "fsl,magic-packet", NULL)) {
 		priv->device_flags |= FSL_GIANFAR_DEV_HAS_MAGIC_PACKET;
+		priv->wol_supported |= GIANFAR_WOL_MAGIC;
+	}
 
+	if (of_get_property(np, "fsl,wake-on-filer", NULL)) {
+		priv->device_flags |= FSL_GIANFAR_DEV_HAS_WAKE_ON_FILER;
+		priv->wol_supported |= GIANFAR_WOL_ARP;
+		priv->wol_supported |= GIANFAR_WOL_UCAST;
+	}
+#endif
 	priv->phy_node = of_parse_phandle(np, "phy-handle", 0);
 
 	/* Find the TBI PHY.  If it's not there, we don't support SGMII */
@@ -1168,8 +1192,10 @@ static int gfar_probe(struct platform_device *ofdev)
 		goto register_fail;
 	}
 
-	device_init_wakeup(&dev->dev,
-		priv->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET);
+	if (priv->wol_supported) {
+		device_set_wakeup_capable(&ofdev->dev, true);
+		device_set_wakeup_enable(&ofdev->dev, false);
+	}
 
 	/* fill out IRQ number and name fields */
 	len_devname = strlen(dev->name);
@@ -1260,6 +1286,143 @@ static int gfar_remove(struct platform_device *ofdev)
 }
 
 #ifdef CONFIG_PM
+static void gfar_enable_filer(struct net_device *dev)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar __iomem *regs = priv->gfargrp[0].regs;
+	u32 temp;
+
+	lock_rx_qs(priv);
+
+	temp = gfar_read(&regs->rctrl);
+	temp &= ~(RCTRL_FSQEN | RCTRL_PRSDEP_MASK);
+	temp |= RCTRL_FILREN | RCTRL_PRSDEP_L2L3;
+	gfar_write(&regs->rctrl, temp);
+
+	unlock_rx_qs(priv);
+}
+
+static void gfar_disable_filer(struct net_device *dev)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar __iomem *regs = priv->gfargrp[0].regs;
+	u32 temp;
+
+	lock_rx_qs(priv);
+
+	temp = gfar_read(&regs->rctrl);
+	temp &= ~RCTRL_FILREN;
+	gfar_write(&regs->rctrl, temp);
+
+	unlock_rx_qs(priv);
+}
+
+static int gfar_get_ip(struct net_device *dev)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+	struct in_device *in_dev;
+	int ret = -ENOENT;
+
+	in_dev = in_dev_get(dev);
+	if (!in_dev)
+		return ret;
+
+	/* Get the primary IP address */
+	for_primary_ifa(in_dev) {
+		priv->ip_addr = ifa->ifa_address;
+		ret = 0;
+		break;
+	} endfor_ifa(in_dev);
+
+	in_dev_put(in_dev);
+	return ret;
+}
+
+static void gfar_restore_filer_table(struct net_device *dev)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+	u32 rqfcr, rqfpr;
+	int i;
+
+	lock_rx_qs(priv);
+
+	for (i = 0; i <= MAX_FILER_IDX; i++) {
+		rqfcr = priv->ftp_rqfcr[i];
+		rqfpr = priv->ftp_rqfpr[i];
+		gfar_write_filer(priv, i, rqfcr, rqfpr);
+	}
+
+	unlock_rx_qs(priv);
+}
+
+static void gfar_config_filer_table(struct net_device *dev)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+	u32 dest_mac_addr;
+	u32 rqfcr, rqfpr;
+	u8  rqfcr_queue = priv->num_rx_queues - 1;
+	unsigned int index;
+
+	if (gfar_get_ip(dev)) {
+		netif_err(priv, wol, dev, "WOL: get the ip address error\n");
+		return;
+	}
+
+	lock_rx_qs(priv);
+
+	/* init filer table */
+	rqfcr = RQFCR_RJE | RQFCR_CMP_MATCH;
+	rqfpr = 0x0;
+	for (index = 0; index <= MAX_FILER_IDX; index++)
+		gfar_write_filer(priv, index, rqfcr, rqfpr);
+
+	index = 0;
+	if (priv->wol_opts & GIANFAR_WOL_ARP) {
+		/* ARP request filer, filling the packet to the last queue */
+		rqfcr = (rqfcr_queue << 10) | RQFCR_AND |
+					RQFCR_CMP_EXACT | RQFCR_PID_MASK;
+		rqfpr = RQFPR_ARQ;
+		gfar_write_filer(priv, index++, rqfcr, rqfpr);
+
+		rqfcr = (rqfcr_queue << 10) | RQFCR_AND |
+					RQFCR_CMP_EXACT | RQFCR_PID_PARSE;
+		rqfpr = RQFPR_ARQ;
+		gfar_write_filer(priv, index++, rqfcr, rqfpr);
+
+		/*
+		 * DEST_IP address in ARP packet,
+		 * filling it to the last queue.
+		 */
+		rqfcr = (rqfcr_queue << 10) | RQFCR_AND |
+					RQFCR_CMP_EXACT | RQFCR_PID_MASK;
+		rqfpr = FPR_FILER_MASK;
+		gfar_write_filer(priv, index++, rqfcr, rqfpr);
+
+		rqfcr = (rqfcr_queue << 10) | RQFCR_GPI |
+					RQFCR_CMP_EXACT | RQFCR_PID_DIA;
+		rqfpr = priv->ip_addr;
+		gfar_write_filer(priv, index++, rqfcr, rqfpr);
+	}
+
+	if (priv->wol_opts & GIANFAR_WOL_UCAST) {
+		/* Unicast packet, filling it to the last queue */
+		dest_mac_addr = (dev->dev_addr[0] << 16) |
+				(dev->dev_addr[1] << 8) | dev->dev_addr[2];
+		rqfcr = (rqfcr_queue << 10) | RQFCR_AND |
+					RQFCR_CMP_EXACT | RQFCR_PID_DAH;
+		rqfpr = dest_mac_addr;
+		gfar_write_filer(priv, index++, rqfcr, rqfpr);
+
+		dest_mac_addr = (dev->dev_addr[3] << 16) |
+				(dev->dev_addr[4] << 8) | dev->dev_addr[5];
+		rqfcr = (rqfcr_queue << 10) | RQFCR_GPI |
+					RQFCR_CMP_EXACT | RQFCR_PID_DAL;
+		rqfpr = dest_mac_addr;
+		gfar_write_filer(priv, index++, rqfcr, rqfpr);
+	}
+
+	unlock_rx_qs(priv);
+}
 
 static int gfar_suspend(struct device *dev)
 {
@@ -1269,48 +1432,43 @@ static int gfar_suspend(struct device *dev)
 	unsigned long flags;
 	u32 tempval;
 
-	int magic_packet = priv->wol_en &&
-		(priv->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET);
-
 	netif_device_detach(ndev);
 
-	if (netif_running(ndev)) {
-
-		local_irq_save(flags);
-		lock_tx_qs(priv);
-		lock_rx_qs(priv);
-
-		gfar_halt_nodisable(ndev);
-
-		/* Disable Tx, and Rx if wake-on-LAN is disabled. */
-		tempval = gfar_read(&regs->maccfg1);
-
-		tempval &= ~MACCFG1_TX_EN;
+	if (!netif_running(ndev))
+		return 0;
 
-		if (!magic_packet)
-			tempval &= ~MACCFG1_RX_EN;
+	local_irq_save(flags);
+	lock_tx_qs(priv);
+	lock_rx_qs(priv);
 
-		gfar_write(&regs->maccfg1, tempval);
+	gfar_halt(ndev);
 
-		unlock_rx_qs(priv);
-		unlock_tx_qs(priv);
-		local_irq_restore(flags);
+	unlock_rx_qs(priv);
+	unlock_tx_qs(priv);
+	local_irq_restore(flags);
 
-		disable_napi(priv);
+	disable_napi(priv);
 
-		if (magic_packet) {
-			/* Enable interrupt on Magic Packet */
-			gfar_write(&regs->imask, IMASK_MAG);
+	if (!priv->wol_opts && priv->phydev) {
+		phy_stop(priv->phydev);
+		return 0;
+	}
 
-			/* Enable Magic Packet mode */
-			tempval = gfar_read(&regs->maccfg2);
-			tempval |= MACCFG2_MPEN;
-			gfar_write(&regs->maccfg2, tempval);
-		} else {
-			phy_stop(priv->phydev);
-		}
+	mpc85xx_pmc_set_wake(priv->ofdev, 1);
+	if (priv->wol_opts & GIANFAR_WOL_MAGIC) {
+		/* Enable Magic Packet mode */
+		tempval = gfar_read(&regs->maccfg2);
+		tempval |= MACCFG2_MPEN;
+		gfar_write(&regs->maccfg2, tempval);
 	}
 
+	if (priv->wol_opts & (GIANFAR_WOL_ARP | GIANFAR_WOL_UCAST)) {
+		mpc85xx_pmc_set_lossless_ethernet(1);
+		gfar_disable_filer(ndev);
+		gfar_config_filer_table(ndev);
+		gfar_enable_filer(ndev);
+	}
+	gfar_rx_start(ndev);
 	return 0;
 }
 
@@ -1320,39 +1478,49 @@ static int gfar_resume(struct device *dev)
 	struct net_device *ndev = priv->ndev;
 	struct gfar __iomem *regs = priv->gfargrp[0].regs;
 	unsigned long flags;
-	u32 tempval;
-	int magic_packet = priv->wol_en &&
-		(priv->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET);
+	u32 tempval, i;
 
 	if (!netif_running(ndev)) {
 		netif_device_attach(ndev);
 		return 0;
 	}
 
-	if (!magic_packet && priv->phydev)
+	if (!priv->wol_opts && priv->phydev) {
 		phy_start(priv->phydev);
+		goto out;
+	}
+
+	mpc85xx_pmc_set_wake(priv->ofdev, 0);
 
-	/* Disable Magic Packet mode, in case something
-	 * else woke us up.
-	 */
 	local_irq_save(flags);
-	lock_tx_qs(priv);
 	lock_rx_qs(priv);
-
-	tempval = gfar_read(&regs->maccfg2);
-	tempval &= ~MACCFG2_MPEN;
-	gfar_write(&regs->maccfg2, tempval);
-
-	gfar_start(ndev);
-
+	gfar_halt_rx(ndev);
 	unlock_rx_qs(priv);
-	unlock_tx_qs(priv);
 	local_irq_restore(flags);
 
-	netif_device_attach(ndev);
+	if (priv->wol_opts & (GIANFAR_WOL_ARP | GIANFAR_WOL_UCAST)) {
+		mpc85xx_pmc_set_lossless_ethernet(0);
+		gfar_disable_filer(ndev);
+		gfar_restore_filer_table(ndev);
+	}
+
+	if (priv->wol_opts & GIANFAR_WOL_MAGIC) {
+		/* Disable Magic Packet mode */
+		tempval = gfar_read(&regs->maccfg2);
+		tempval &= ~MACCFG2_MPEN;
+		gfar_write(&regs->maccfg2, tempval);
+	}
 
+out:
+	gfar_start(ndev);
+	netif_device_attach(ndev);
 	enable_napi(priv);
 
+	if (priv->wol_opts & (GIANFAR_WOL_ARP | GIANFAR_WOL_UCAST)) {
+		/* send requests to process the received packets */
+		for (i = 0; i < priv->num_grps; i++)
+			gfar_schedule_cleanup(&priv->gfargrp[i]);
+	}
 	return 0;
 }
 
@@ -1602,6 +1770,48 @@ static int __gfar_is_rx_idle(struct gfar_private *priv)
 	return 0;
 }
 
+#ifdef CONFIG_PM
+/* Halt the receive queues */
+static void gfar_halt_rx(struct net_device *dev)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar __iomem *regs = priv->gfargrp[0].regs;
+	u32 tempval;
+	int i = 0;
+
+	for (i = 0; i < priv->num_grps; i++) {
+		regs = priv->gfargrp[i].regs;
+		/* Mask all interrupts */
+		gfar_write(&regs->imask, IMASK_INIT_CLEAR);
+
+		/* Clear all interrupts */
+		gfar_write(&regs->ievent, IEVENT_INIT_CLEAR);
+	}
+
+	regs = priv->gfargrp[0].regs;
+	/* Stop the DMA, and wait for it to stop */
+	tempval = gfar_read(&regs->dmactrl);
+	if ((tempval & DMACTRL_GRS) != DMACTRL_GRS) {
+		int ret;
+
+		tempval |= DMACTRL_GRS;
+		gfar_write(&regs->dmactrl, tempval);
+
+		do {
+			ret = spin_event_timeout(((gfar_read(&regs->ievent) &
+				IEVENT_GRSC) == IEVENT_GRSC), 1000000, 0);
+			if (!ret && !(gfar_read(&regs->ievent) & IEVENT_GRSC))
+				ret = __gfar_is_rx_idle(priv);
+		} while (!ret);
+	}
+
+	/* Disable Rx in MACCFG1  */
+	tempval = gfar_read(&regs->maccfg1);
+	tempval &= ~MACCFG1_RX_EN;
+	gfar_write(&regs->maccfg1, tempval);
+}
+#endif
+
 /* Halt the receive and transmit queues */
 static void gfar_halt_nodisable(struct net_device *dev)
 {
@@ -1808,6 +2018,40 @@ void gfar_start(struct net_device *dev)
 	dev->trans_start = jiffies; /* prevent tx timeout */
 }
 
+#ifdef CONFIG_PM
+void gfar_rx_start(struct net_device *dev)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar __iomem *regs = priv->gfargrp[0].regs;
+	u32 tempval;
+	int i = 0;
+
+	/* Enable Rx in MACCFG1 */
+	tempval = gfar_read(&regs->maccfg1);
+	tempval |= MACCFG1_RX_EN;
+	gfar_write(&regs->maccfg1, tempval);
+
+	/* Initialize DMACTRL to have WWR and WOP */
+	tempval = gfar_read(&regs->dmactrl);
+	tempval |= DMACTRL_INIT_SETTINGS;
+	gfar_write(&regs->dmactrl, tempval);
+
+	/* Make sure we aren't stopped */
+	tempval = gfar_read(&regs->dmactrl);
+	tempval &= ~DMACTRL_GRS;
+	gfar_write(&regs->dmactrl, tempval);
+
+	for (i = 0; i < priv->num_grps; i++) {
+		regs = priv->gfargrp[i].regs;
+		/* Clear RHLT, so that the DMA starts polling now */
+		gfar_write(&regs->rstat, priv->gfargrp[i].rstat);
+
+		/* Unmask the interrupts we look for */
+		gfar_write(&regs->imask, IMASK_DEFAULT);
+	}
+}
+#endif
+
 void gfar_configure_coalescing(struct gfar_private *priv,
 	unsigned long tx_mask, unsigned long rx_mask)
 {
@@ -1970,7 +2214,7 @@ static int gfar_enet_open(struct net_device *dev)
 
 	netif_tx_start_all_queues(dev);
 
-	device_set_wakeup_enable(&dev->dev, priv->wol_en);
+	device_set_wakeup_enable(&priv->ofdev->dev, priv->wol_opts);
 
 	return err;
 }
@@ -2657,6 +2901,17 @@ static inline void count_errors(unsigned short status, struct net_device *dev)
 
 irqreturn_t gfar_receive(int irq, void *grp_id)
 {
+	struct gfar_priv_grp *gfargrp = grp_id;
+	struct gfar __iomem *regs = gfargrp->regs;
+	u32 ievent;
+
+	ievent = gfar_read(&regs->ievent);
+
+	if ((ievent & IEVENT_FGPI) == IEVENT_FGPI) {
+		gfar_write(&regs->ievent, ievent & IEVENT_RX_MASK);
+		return IRQ_HANDLED;
+	}
+
 	gfar_schedule_cleanup((struct gfar_priv_grp *)grp_id);
 	return IRQ_HANDLED;
 }
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 9aa4377..1abebc4 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -232,6 +232,13 @@ extern const char gfar_driver_version[];
 #define RQUEUE_EN7		0x00000001
 #define RQUEUE_EN_ALL		0x000000FF
 
+/* Wake-On-Lan options */
+#define GIANFAR_WOL_UCAST	0x00000001	/* Unicast wakeup */
+#define GIANFAR_WOL_MCAST	0x00000002	/* Multicast wakeup */
+#define GIANFAR_WOL_BCAST	0x00000004	/* Broadcase wakeup */
+#define GIANFAR_WOL_ARP		0x00000008	/* ARP request wakeup */
+#define GIANFAR_WOL_MAGIC	0x00000010	/* Magic packet wakeup */
+
 /* Init to do tx snooping for buffers and descriptors */
 #define DMACTRL_INIT_SETTINGS   0x000000c3
 #define DMACTRL_GRS             0x00000010
@@ -277,11 +284,15 @@ extern const char gfar_driver_version[];
 #define RCTRL_PAL_MASK		0x001f0000
 #define RCTRL_VLEX		0x00002000
 #define RCTRL_FILREN		0x00001000
+#define RCTRL_FSQEN		0x00000800
 #define RCTRL_GHTX		0x00000400
 #define RCTRL_IPCSEN		0x00000200
 #define RCTRL_TUCSEN		0x00000100
 #define RCTRL_PRSDEP_MASK	0x000000c0
 #define RCTRL_PRSDEP_INIT	0x000000c0
+#define RCTRL_PRSDEP_L2		0x00000040
+#define RCTRL_PRSDEP_L2L3	0x00000080
+#define RCTRL_PRSDEP_L2L3L4	0x000000c0
 #define RCTRL_PRSFM		0x00000020
 #define RCTRL_PROM		0x00000008
 #define RCTRL_EMEN		0x00000002
@@ -327,18 +338,20 @@ extern const char gfar_driver_version[];
 #define IEVENT_MAG		0x00000800
 #define IEVENT_GRSC		0x00000100
 #define IEVENT_RXF0		0x00000080
+#define IEVENT_FGPI		0x00000010
 #define IEVENT_FIR		0x00000008
 #define IEVENT_FIQ		0x00000004
 #define IEVENT_DPE		0x00000002
 #define IEVENT_PERR		0x00000001
-#define IEVENT_RX_MASK          (IEVENT_RXB0 | IEVENT_RXF0 | IEVENT_BSY)
+#define IEVENT_RX_MASK          (IEVENT_RXB0 | IEVENT_RXF0 | \
+					IEVENT_FGPI | IEVENT_BSY)
 #define IEVENT_TX_MASK          (IEVENT_TXB | IEVENT_TXF)
 #define IEVENT_RTX_MASK         (IEVENT_RX_MASK | IEVENT_TX_MASK)
 #define IEVENT_ERR_MASK         \
-(IEVENT_RXC | IEVENT_BSY | IEVENT_EBERR | IEVENT_MSRO | \
- IEVENT_BABT | IEVENT_TXC | IEVENT_TXE | IEVENT_LC \
- | IEVENT_CRL | IEVENT_XFUN | IEVENT_DPE | IEVENT_PERR \
- | IEVENT_MAG | IEVENT_BABR)
+	(IEVENT_RXC | IEVENT_BSY | IEVENT_EBERR | IEVENT_MSRO | \
+	 IEVENT_BABT | IEVENT_TXC | IEVENT_TXE | IEVENT_LC | \
+	 IEVENT_CRL | IEVENT_XFUN | IEVENT_FIR | IEVENT_FIQ | \
+	 IEVENT_DPE | IEVENT_PERR | IEVENT_MAG | IEVENT_BABR)
 
 #define IMASK_INIT_CLEAR	0x00000000
 #define IMASK_BABR              0x80000000
@@ -359,14 +372,15 @@ extern const char gfar_driver_version[];
 #define IMASK_MAG		0x00000800
 #define IMASK_GRSC              0x00000100
 #define IMASK_RXFEN0		0x00000080
+#define IMASK_FGPI		0x00000010
 #define IMASK_FIR		0x00000008
 #define IMASK_FIQ		0x00000004
 #define IMASK_DPE		0x00000002
 #define IMASK_PERR		0x00000001
 #define IMASK_DEFAULT  (IMASK_TXEEN | IMASK_TXFEN | IMASK_TXBEN | \
 		IMASK_RXFEN0 | IMASK_BSY | IMASK_EBERR | IMASK_BABR | \
-		IMASK_XFUN | IMASK_RXC | IMASK_BABT | IMASK_DPE \
-		| IMASK_PERR)
+		IMASK_XFUN | IMASK_RXC | IMASK_BABT | IMASK_FGPI | \
+		IMASK_FIR | IMASK_FIQ | IMASK_DPE | IMASK_PERR | IMASK_MAG)
 #define IMASK_RTX_DISABLED ((~(IMASK_RXFEN0 | IMASK_TXFEN | IMASK_BSY)) \
 			   & IMASK_DEFAULT)
 
@@ -883,6 +897,7 @@ struct gfar {
 #define FSL_GIANFAR_DEV_HAS_BD_STASHING		0x00000200
 #define FSL_GIANFAR_DEV_HAS_BUF_STASHING	0x00000400
 #define FSL_GIANFAR_DEV_HAS_TIMER		0x00000800
+#define FSL_GIANFAR_DEV_HAS_WAKE_ON_FILER	0x00001000
 
 #if (MAXGROUPS == 2)
 #define DEFAULT_MAPPING 	0xAA
@@ -1115,6 +1130,10 @@ struct gfar_private {
 
 	struct work_struct reset_task;
 
+	u32 ip_addr;
+	u32 wol_opts;
+	u32 wol_supported;
+
 	/* Network Statistics */
 	struct gfar_extra_stats extra_stats;
 
diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index 212736b..296e762 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -29,6 +29,7 @@
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
 #include <linux/mm.h>
+#include <linux/platform_device.h>
 
 #include <asm/io.h>
 #include <asm/irq.h>
@@ -577,32 +578,49 @@ static void gfar_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 
-	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET) {
-		wol->supported = WAKE_MAGIC;
-		wol->wolopts = priv->wol_en ? WAKE_MAGIC : 0;
-	} else {
-		wol->supported = wol->wolopts = 0;
-	}
+	wol->supported = 0;
+	wol->wolopts = 0;
+
+	if (!priv->wol_supported || !device_can_wakeup(&priv->ofdev->dev))
+		return;
+
+	if (priv->wol_supported & GIANFAR_WOL_MAGIC)
+		wol->supported |= WAKE_MAGIC;
+
+	if (priv->wol_supported & GIANFAR_WOL_ARP)
+		wol->supported |= WAKE_ARP;
+
+	if (priv->wol_supported & GIANFAR_WOL_UCAST)
+		wol->supported |= WAKE_UCAST;
+
+	if (priv->wol_opts & GIANFAR_WOL_MAGIC)
+		wol->wolopts |= WAKE_MAGIC;
+
+	if (priv->wol_opts & GIANFAR_WOL_ARP)
+		wol->wolopts |= WAKE_ARP;
+
+	if (priv->wol_opts & GIANFAR_WOL_UCAST)
+		wol->wolopts |= WAKE_UCAST;
 }
 
 static int gfar_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct gfar_private *priv = netdev_priv(dev);
-	unsigned long flags;
 
-	if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET) &&
-	    wol->wolopts != 0)
-		return -EINVAL;
-
-	if (wol->wolopts & ~WAKE_MAGIC)
-		return -EINVAL;
+	if (!priv->wol_supported || !device_can_wakeup(&priv->ofdev->dev) ||
+		(wol->wolopts & ~(WAKE_MAGIC | WAKE_ARP | WAKE_UCAST)))
+		return -EOPNOTSUPP;
 
-	device_set_wakeup_enable(&dev->dev, wol->wolopts & WAKE_MAGIC);
+	priv->wol_opts = 0;
 
-	spin_lock_irqsave(&priv->bflock, flags);
-	priv->wol_en =  !!device_may_wakeup(&dev->dev);
-	spin_unlock_irqrestore(&priv->bflock, flags);
+	if (wol->wolopts & WAKE_MAGIC)
+		priv->wol_opts |= GIANFAR_WOL_MAGIC;
+	if (wol->wolopts & WAKE_ARP)
+		priv->wol_opts |= GIANFAR_WOL_ARP;
+	if (wol->wolopts & WAKE_UCAST)
+		priv->wol_opts |= GIANFAR_WOL_UCAST;
 
+	device_set_wakeup_enable(&priv->ofdev->dev, (u32)priv->wol_opts);
 	return 0;
 }
 #endif
-- 
1.6.4.1
