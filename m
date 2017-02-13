From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH 2/2] pcnet32: fix BNC/AUI port on AM79C970A
Date: Mon, 13 Feb 2017 23:45:47 +0100
Message-ID: <1487025947-28867-2-git-send-email-linux@rainbow-software.org>
References: <1487025947-28867-1-git-send-email-linux@rainbow-software.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: <pcnet32@frontier.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1487025947-28867-1-git-send-email-linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Even though the port autoselection is enabled by default on AM79C970A,
BNC/AUI port does not work because the link is always reported to be
down. The link state reported by the chip belongs only to the TP port
but the driver uses it regardless of the port used. The chip can't
detect BNC/AUI link state.

Disable port autoselection and use TP port by default to keep current
behavior (link detection works on TP port, BNC/AUI port does not work).

Implement ethtool autoneg, port and duplex configuration to allow
using the BNC/AUI port.

Report the TP link state only if the TP port is selected. When the
port autoselection is enabled or AUI port is selected, report the link
as always up.

Move pcnet32_suspend() and pcnet32_clr_suspend() functions to avoid
forward declarations.

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
---
 drivers/net/ethernet/amd/pcnet32.c |  177 +++++++++++++++++++++++++-----------
 1 file changed, 125 insertions(+), 52 deletions(-)

diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index ade3289..c0a9254 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -291,7 +291,10 @@ struct pcnet32_private {
 	int			options;
 	unsigned int		shared_irq:1,	/* shared irq possible */
 				dxsuflo:1,   /* disable transmit stop on uflo */
-				mii:1;		/* mii port available */
+				mii:1,		/* mii port available */
+				autoneg:1,	/* autoneg enabled */
+				port_tp:1,	/* port set to TP */
+				fdx:1;		/* full duplex enabled */
 	struct net_device	*next;
 	struct mii_if_info	mii_if;
 	struct timer_list	watchdog_timer;
@@ -677,6 +680,52 @@ static void pcnet32_poll_controller(struct net_device *dev)
 }
 #endif
 
+/*
+ * lp->lock must be held.
+ */
+static int pcnet32_suspend(struct net_device *dev, unsigned long *flags,
+			   int can_sleep)
+{
+	int csr5;
+	struct pcnet32_private *lp = netdev_priv(dev);
+	const struct pcnet32_access *a = lp->a;
+	ulong ioaddr = dev->base_addr;
+	int ticks;
+
+	/* really old chips have to be stopped. */
+	if (lp->chip_version < PCNET32_79C970A)
+		return 0;
+
+	/* set SUSPEND (SPND) - CSR5 bit 0 */
+	csr5 = a->read_csr(ioaddr, CSR5);
+	a->write_csr(ioaddr, CSR5, csr5 | CSR5_SUSPEND);
+
+	/* poll waiting for bit to be set */
+	ticks = 0;
+	while (!(a->read_csr(ioaddr, CSR5) & CSR5_SUSPEND)) {
+		spin_unlock_irqrestore(&lp->lock, *flags);
+		if (can_sleep)
+			msleep(1);
+		else
+			mdelay(1);
+		spin_lock_irqsave(&lp->lock, *flags);
+		ticks++;
+		if (ticks > 200) {
+			netif_printk(lp, hw, KERN_DEBUG, dev,
+				     "Error getting into suspend!\n");
+			return 0;
+		}
+	}
+	return 1;
+}
+
+static void pcnet32_clr_suspend(struct pcnet32_private *lp, ulong ioaddr)
+{
+	int csr5 = lp->a->read_csr(ioaddr, CSR5);
+	/* clear SUSPEND (SPND) - CSR5 bit 0 */
+	lp->a->write_csr(ioaddr, CSR5, csr5 & ~CSR5_SUSPEND);
+}
+
 static int pcnet32_get_link_ksettings(struct net_device *dev,
 				      struct ethtool_link_ksettings *cmd)
 {
@@ -684,12 +733,29 @@ static int pcnet32_get_link_ksettings(struct net_device *dev,
 	unsigned long flags;
 	int r = -EOPNOTSUPP;
 
+	spin_lock_irqsave(&lp->lock, flags);
 	if (lp->mii) {
-		spin_lock_irqsave(&lp->lock, flags);
 		mii_ethtool_get_link_ksettings(&lp->mii_if, cmd);
-		spin_unlock_irqrestore(&lp->lock, flags);
+		r = 0;
+	} else if (lp->chip_version == PCNET32_79C970A) {
+		if (lp->autoneg) {
+			cmd->base.autoneg = AUTONEG_ENABLE;
+			if (lp->a->read_bcr(dev->base_addr, 4) == 0xc0)
+				cmd->base.port = PORT_AUI;
+			else
+				cmd->base.port = PORT_TP;
+		} else {
+			cmd->base.autoneg = AUTONEG_DISABLE;
+			cmd->base.port = lp->port_tp ? PORT_TP : PORT_AUI;
+		}
+		cmd->base.duplex = lp->fdx ? DUPLEX_FULL : DUPLEX_HALF;
+		cmd->base.speed = SPEED_10;
+		ethtool_convert_legacy_u32_to_link_mode(
+						cmd->link_modes.supported,
+						SUPPORTED_TP | SUPPORTED_AUI);
 		r = 0;
 	}
+	spin_unlock_irqrestore(&lp->lock, flags);
 	return r;
 }
 
@@ -697,14 +763,46 @@ static int pcnet32_set_link_ksettings(struct net_device *dev,
 				      const struct ethtool_link_ksettings *cmd)
 {
 	struct pcnet32_private *lp = netdev_priv(dev);
+	ulong ioaddr = dev->base_addr;
 	unsigned long flags;
 	int r = -EOPNOTSUPP;
+	int suspended, bcr2, bcr9, csr15;
 
+	spin_lock_irqsave(&lp->lock, flags);
 	if (lp->mii) {
-		spin_lock_irqsave(&lp->lock, flags);
 		r = mii_ethtool_set_link_ksettings(&lp->mii_if, cmd);
-		spin_unlock_irqrestore(&lp->lock, flags);
+	} else if (lp->chip_version == PCNET32_79C970A) {
+		suspended = pcnet32_suspend(dev, &flags, 0);
+		if (!suspended)
+			lp->a->write_csr(ioaddr, CSR0, CSR0_STOP);
+
+		lp->autoneg = cmd->base.autoneg == AUTONEG_ENABLE;
+		bcr2 = lp->a->read_bcr(ioaddr, 2);
+		if (cmd->base.autoneg == AUTONEG_ENABLE) {
+			lp->a->write_bcr(ioaddr, 2, bcr2 | 0x0002);
+		} else {
+			lp->a->write_bcr(ioaddr, 2, bcr2 & ~0x0002);
+
+			lp->port_tp = cmd->base.port == PORT_TP;
+			csr15 = lp->a->read_csr(ioaddr, CSR15) & ~0x0180;
+			if (cmd->base.port == PORT_TP)
+				csr15 |= 0x0080;
+			lp->a->write_csr(ioaddr, CSR15, csr15);
+			lp->init_block->mode = cpu_to_le16(csr15);
+
+			lp->fdx = cmd->base.duplex == DUPLEX_FULL;
+			bcr9 = lp->a->read_bcr(ioaddr, 9) & ~0x0003;
+			if (cmd->base.duplex == DUPLEX_FULL)
+				bcr9 |= 0x0003;
+			lp->a->write_bcr(ioaddr, 9, bcr9);
+		}
+		if (suspended)
+			pcnet32_clr_suspend(lp, ioaddr);
+		else if (netif_running(dev))
+			pcnet32_restart(dev, CSR0_NORMAL);
+		r = 0;
 	}
+	spin_unlock_irqrestore(&lp->lock, flags);
 	return r;
 }
 
@@ -732,7 +830,14 @@ static u32 pcnet32_get_link(struct net_device *dev)
 	spin_lock_irqsave(&lp->lock, flags);
 	if (lp->mii) {
 		r = mii_link_ok(&lp->mii_if);
-	} else if (lp->chip_version >= PCNET32_79C970A) {
+	} else if (lp->chip_version == PCNET32_79C970A) {
+		ulong ioaddr = dev->base_addr;	/* card base I/O address */
+		/* only read link if port is set to TP */
+		if (!lp->autoneg && lp->port_tp)
+			r = (lp->a->read_bcr(ioaddr, 4) != 0xc0);
+		else /* link always up for AUI port or port auto select */
+			r = 1;
+	} else if (lp->chip_version > PCNET32_79C970A) {
 		ulong ioaddr = dev->base_addr;	/* card base I/O address */
 		r = (lp->a->read_bcr(ioaddr, 4) != 0xc0);
 	} else {	/* can not detect link on really old chips */
@@ -1070,52 +1175,6 @@ static int pcnet32_set_phys_id(struct net_device *dev,
 }
 
 /*
- * lp->lock must be held.
- */
-static int pcnet32_suspend(struct net_device *dev, unsigned long *flags,
-		int can_sleep)
-{
-	int csr5;
-	struct pcnet32_private *lp = netdev_priv(dev);
-	const struct pcnet32_access *a = lp->a;
-	ulong ioaddr = dev->base_addr;
-	int ticks;
-
-	/* really old chips have to be stopped. */
-	if (lp->chip_version < PCNET32_79C970A)
-		return 0;
-
-	/* set SUSPEND (SPND) - CSR5 bit 0 */
-	csr5 = a->read_csr(ioaddr, CSR5);
-	a->write_csr(ioaddr, CSR5, csr5 | CSR5_SUSPEND);
-
-	/* poll waiting for bit to be set */
-	ticks = 0;
-	while (!(a->read_csr(ioaddr, CSR5) & CSR5_SUSPEND)) {
-		spin_unlock_irqrestore(&lp->lock, *flags);
-		if (can_sleep)
-			msleep(1);
-		else
-			mdelay(1);
-		spin_lock_irqsave(&lp->lock, *flags);
-		ticks++;
-		if (ticks > 200) {
-			netif_printk(lp, hw, KERN_DEBUG, dev,
-				     "Error getting into suspend!\n");
-			return 0;
-		}
-	}
-	return 1;
-}
-
-static void pcnet32_clr_suspend(struct pcnet32_private *lp, ulong ioaddr)
-{
-	int csr5 = lp->a->read_csr(ioaddr, CSR5);
-	/* clear SUSPEND (SPND) - CSR5 bit 0 */
-	lp->a->write_csr(ioaddr, CSR5, csr5 & ~CSR5_SUSPEND);
-}
-
-/*
  * process one receive descriptor entry
  */
 
@@ -1819,6 +1878,9 @@ static void pcnet32_probe_vlbus(unsigned int *pcnet32_portlist)
 		lp->options = PCNET32_PORT_ASEL;
 	else
 		lp->options = options_mapping[options[cards_found]];
+	/* force default port to TP on 79C970A so link detection can work */
+	if (lp->chip_version == PCNET32_79C970A)
+		lp->options = PCNET32_PORT_10BT;
 	lp->mii_if.dev = dev;
 	lp->mii_if.mdio_read = mdio_read;
 	lp->mii_if.mdio_write = mdio_write;
@@ -2070,6 +2132,10 @@ static int pcnet32_open(struct net_device *dev)
 		     (u32) (lp->rx_ring_dma_addr),
 		     (u32) (lp->init_dma_addr));
 
+	lp->autoneg = !!(lp->options & PCNET32_PORT_ASEL);
+	lp->port_tp = !!(lp->options & PCNET32_PORT_10BT);
+	lp->fdx = !!(lp->options & PCNET32_PORT_FD);
+
 	/* set/reset autoselect bit */
 	val = lp->a->read_bcr(ioaddr, 2) & ~2;
 	if (lp->options & PCNET32_PORT_ASEL)
@@ -2793,6 +2859,13 @@ static void pcnet32_check_media(struct net_device *dev, int verbose)
 
 	if (lp->mii) {
 		curr_link = mii_link_ok(&lp->mii_if);
+	} else if (lp->chip_version == PCNET32_79C970A) {
+		ulong ioaddr = dev->base_addr;	/* card base I/O address */
+		/* only read link if port is set to TP */
+		if (!lp->autoneg && lp->port_tp)
+			curr_link = (lp->a->read_bcr(ioaddr, 4) != 0xc0);
+		else /* link always up for AUI port or port auto select */
+			curr_link = 1;
 	} else {
 		ulong ioaddr = dev->base_addr;	/* card base I/O address */
 		curr_link = (lp->a->read_bcr(ioaddr, 4) != 0xc0);
-- 
Ondrej Zary
