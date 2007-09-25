From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Tue, 25 Sep 2007 01:08:32 -0400
Message-ID: <20070925050832.GA17626@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:40839 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755768AbXIYFId (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Sep 2007 01:08:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/pcmcia/3c589_cs.c |    2 +-
 drivers/net/r8169.c           |   14 +++++++++++++-
 drivers/net/sky2.c            |   37 ++++++++++++++++++++++++-------------
 drivers/net/sky2.h            |    2 +-
 4 files changed, 39 insertions(+), 16 deletions(-)

Edward Hsu (1):
      r8169: correct phy parameters for the 8110SC

Francois Romieu (1):
      r8169: workaround against ignored TxPoll writes (8168)

Jeff Garzik (1):
      Revert "drivers/net/pcmcia/3c589_cs: fix port configuration switcheroo"

Stephen Hemminger (2):
      sky2: FE+ Phy initialization
      sky2: be more selective about FIFO watchdog

diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index c06cae3..503f268 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -116,7 +116,7 @@ struct el3_private {
     spinlock_t		lock;
 };
 
-static const char *if_names[] = { "auto", "10base2", "10baseT", "AUI" };
+static const char *if_names[] = { "auto", "10baseT", "10base2", "AUI" };
 
 /*====================================================================*/
 
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index b85ab4a..c921ec3 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1228,7 +1228,10 @@ static void rtl8169_hw_phy_config(struct net_device *dev)
 		return;
 	}
 
-	/* phy config for RTL8169s mac_version C chip */
+	if ((tp->mac_version != RTL_GIGA_MAC_VER_02) &&
+	    (tp->mac_version != RTL_GIGA_MAC_VER_03))
+		return;
+
 	mdio_write(ioaddr, 31, 0x0001);			//w 31 2 0 1
 	mdio_write(ioaddr, 21, 0x1000);			//w 21 15 0 1000
 	mdio_write(ioaddr, 24, 0x65c7);			//w 24 15 0 65c7
@@ -2567,6 +2570,15 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
 		    (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)) {
 			netif_wake_queue(dev);
 		}
+		/*
+		 * 8168 hack: TxPoll requests are lost when the Tx packets are
+		 * too close. Let's kick an extra TxPoll request when a burst
+		 * of start_xmit activity is detected (if it is not detected,
+		 * it is slow enough). -- FR
+		 */
+		smp_rmb();
+		if (tp->cur_tx != dirty_tx)
+			RTL_W8(TxPoll, NPQ);
 	}
 }
 
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index eaffe55..0792031 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -338,6 +338,16 @@ static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
 		if (!(hw->flags & SKY2_HW_GIGABIT)) {
 			/* enable automatic crossover */
 			ctrl |= PHY_M_PC_MDI_XMODE(PHY_M_PC_ENA_AUTO) >> 1;
+
+			if (hw->chip_id == CHIP_ID_YUKON_FE_P &&
+			    hw->chip_rev == CHIP_REV_YU_FE2_A0) {
+				u16 spec;
+
+				/* Enable Class A driver for FE+ A0 */
+				spec = gm_phy_read(hw, port, PHY_MARV_FE_SPEC_2);
+				spec |= PHY_M_FESC_SEL_CL_A;
+				gm_phy_write(hw, port, PHY_MARV_FE_SPEC_2, spec);
+			}
 		} else {
 			/* disable energy detect */
 			ctrl &= ~PHY_M_PC_EN_DET_MSK;
@@ -816,7 +826,8 @@ static void sky2_mac_init(struct sky2_hw *hw, unsigned port)
 	sky2_write8(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_RST_CLR);
 	sky2_write16(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_OPER_ON);
 
-	if (!(hw->flags & SKY2_HW_RAMBUFFER)) {
+	/* On chips without ram buffer, pause is controled by MAC level */
+	if (sky2_read8(hw, B2_E_0) == 0) {
 		sky2_write8(hw, SK_REG(port, RX_GMF_LP_THR), 768/8);
 		sky2_write8(hw, SK_REG(port, RX_GMF_UP_THR), 1024/8);
 
@@ -1271,7 +1282,7 @@ static int sky2_up(struct net_device *dev)
 	struct sky2_port *sky2 = netdev_priv(dev);
 	struct sky2_hw *hw = sky2->hw;
 	unsigned port = sky2->port;
-	u32 imask;
+	u32 imask, ramsize;
 	int cap, err = -ENOMEM;
 	struct net_device *otherdev = hw->dev[sky2->port^1];
 
@@ -1326,13 +1337,12 @@ static int sky2_up(struct net_device *dev)
 
 	sky2_mac_init(hw, port);
 
-	if (hw->flags & SKY2_HW_RAMBUFFER) {
-		/* Register is number of 4K blocks on internal RAM buffer. */
-		u32 ramsize = sky2_read8(hw, B2_E_0) * 4;
+	/* Register is number of 4K blocks on internal RAM buffer. */
+	ramsize = sky2_read8(hw, B2_E_0) * 4;
+	if (ramsize > 0) {
 		u32 rxspace;
 
-		printk(KERN_DEBUG PFX "%s: ram buffer %dK\n", dev->name, ramsize);
-
+		pr_debug(PFX "%s: ram buffer %dK\n", dev->name, ramsize);
 		if (ramsize < 16)
 			rxspace = ramsize / 2;
 		else
@@ -1995,7 +2005,7 @@ static int sky2_change_mtu(struct net_device *dev, int new_mtu)
 
 	synchronize_irq(hw->pdev->irq);
 
-	if (!(hw->flags & SKY2_HW_RAMBUFFER))
+	if (sky2_read8(hw, B2_E_0) == 0)
 		sky2_set_tx_stfwd(hw, port);
 
 	ctl = gma_read16(hw, port, GM_GP_CTRL);
@@ -2526,7 +2536,7 @@ static void sky2_watchdog(unsigned long arg)
 			++active;
 
 			/* For chips with Rx FIFO, check if stuck */
-			if ((hw->flags & SKY2_HW_RAMBUFFER) &&
+			if ((hw->flags & SKY2_HW_FIFO_HANG_CHECK) &&
 			     sky2_rx_hung(dev)) {
 				pr_info(PFX "%s: receiver hang detected\n",
 					dev->name);
@@ -2684,8 +2694,10 @@ static int __devinit sky2_init(struct sky2_hw *hw)
 	switch(hw->chip_id) {
 	case CHIP_ID_YUKON_XL:
 		hw->flags = SKY2_HW_GIGABIT
-			| SKY2_HW_NEWER_PHY
-			| SKY2_HW_RAMBUFFER;
+			| SKY2_HW_NEWER_PHY;
+		if (hw->chip_rev < 3)
+			hw->flags |= SKY2_HW_FIFO_HANG_CHECK;
+
 		break;
 
 	case CHIP_ID_YUKON_EC_U:
@@ -2711,11 +2723,10 @@ static int __devinit sky2_init(struct sky2_hw *hw)
 			dev_err(&hw->pdev->dev, "unsupported revision Yukon-EC rev A1\n");
 			return -EOPNOTSUPP;
 		}
-		hw->flags = SKY2_HW_GIGABIT | SKY2_HW_RAMBUFFER;
+		hw->flags = SKY2_HW_GIGABIT | SKY2_HW_FIFO_HANG_CHECK;
 		break;
 
 	case CHIP_ID_YUKON_FE:
-		hw->flags = SKY2_HW_RAMBUFFER;
 		break;
 
 	case CHIP_ID_YUKON_FE_P:
diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
index 69cd984..8bc5c54 100644
--- a/drivers/net/sky2.h
+++ b/drivers/net/sky2.h
@@ -2063,7 +2063,7 @@ struct sky2_hw {
 #define SKY2_HW_FIBRE_PHY	0x00000002
 #define SKY2_HW_GIGABIT		0x00000004
 #define SKY2_HW_NEWER_PHY	0x00000008
-#define SKY2_HW_RAMBUFFER	0x00000010	/* chip has RAM FIFO */
+#define SKY2_HW_FIFO_HANG_CHECK	0x00000010
 #define SKY2_HW_NEW_LE		0x00000020	/* new LSOv2 format */
 #define SKY2_HW_AUTO_TX_SUM	0x00000040	/* new IP decode for Tx */
 #define SKY2_HW_ADV_POWER_CTL	0x00000080	/* additional PHY power regs */
