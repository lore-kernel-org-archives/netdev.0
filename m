From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/2] via-velocity: set sleep speed to 10Mbps for powersaving.
Date: Thu, 9 Dec 2010 10:26:56 +0100
Message-ID: <20101209092656.GA4064@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, DavidLv@viatech.com.cn,
	ShirleyHu@viatech.com.cn, AndersMa@viatech.com.cn
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:40153 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754183Ab0LIJ1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 04:27:04 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Lv <DavidLv@viatech.com.cn>
Acked-by: Francois Romieu <romieu@fr.zoreil.com>

---
 drivers/net/via-velocity.c |   67 ++++++++++++++++++++++++++++++++------------
 drivers/net/via-velocity.h |    3 ++
 2 files changed, 52 insertions(+), 18 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index cab96ad..95accb9 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -334,6 +334,15 @@ VELOCITY_PARAM(speed_duplex, "Setting the speed and duplex mode");
 */
 VELOCITY_PARAM(ValPktLen, "Receiving or Drop invalid 802.3 frame");
 
+/* sleep_speed_10M[] is used for setting wol speed forced 10M
+   0: Disable (default)
+   1: Enable
+*/
+#define SLEEP_SPEED_DEF         0
+#define SLEEP_SPEED_DISABLE     0
+#define SLEEP_SPEED_ENABLE      1
+VELOCITY_PARAM(sleep_speed_10M, "Sleep Speed Forced 10M");
+
 #define WOL_OPT_DEF     0
 #define WOL_OPT_MIN     0
 #define WOL_OPT_MAX     7
@@ -487,6 +496,8 @@ static void __devinit velocity_get_options(struct velocity_opt *opts, int index,
 	velocity_set_bool_opt(&opts->flags, IP_byte_align[index], IP_ALIG_DEF, VELOCITY_FLAGS_IP_ALIGN, "IP_byte_align", devname);
 	velocity_set_bool_opt(&opts->flags, ValPktLen[index], VAL_PKT_LEN_DEF, VELOCITY_FLAGS_VAL_PKT_LEN, "ValPktLen", devname);
 	velocity_set_int_opt((int *) &opts->spd_dpx, speed_duplex[index], MED_LNK_MIN, MED_LNK_MAX, MED_LNK_DEF, "Media link mode", devname);
+	velocity_set_int_opt((int *) &opts->sleep_speed_10m, sleep_speed_10M[index],
+		SLEEP_SPEED_DISABLE, SLEEP_SPEED_ENABLE, SLEEP_SPEED_DEF, "Sleep Speed Forced 10M", devname);
 	velocity_set_int_opt((int *) &opts->wol_opts, wol_opts[index], WOL_OPT_MIN, WOL_OPT_MAX, WOL_OPT_DEF, "Wake On Lan options", devname);
 	opts->numrx = (opts->numrx & ~3);
 }
@@ -2513,9 +2524,6 @@ static int velocity_close(struct net_device *dev)
 	if (dev->irq != 0)
 		free_irq(dev->irq, dev);
 
-	/* Power down the chip */
-	pci_set_power_state(vptr->pdev, PCI_D3hot);
-
 	velocity_free_rings(vptr);
 
 	vptr->flags &= (~VELOCITY_FLAGS_OPENED);
@@ -2925,6 +2933,9 @@ static int velocity_set_wol(struct velocity_info *vptr)
 	struct mac_regs __iomem *regs = vptr->mac_regs;
 	static u8 buf[256];
 	int i;
+	u8  CHIPGCR;
+	u16 ANAR;
+	u8  GCR;
 
 	static u32 mask_pattern[2][4] = {
 		{0x00203000, 0x000003C0, 0x00000000, 0x0000000}, /* ARP */
@@ -2968,23 +2979,46 @@ static int velocity_set_wol(struct velocity_info *vptr)
 
 	writew(0x0FFF, &regs->WOLSRClr);
 
-	if (vptr->mii_status & VELOCITY_AUTONEG_ENABLE) {
-		if (PHYID_GET_PHY_ID(vptr->phy_id) == PHYID_CICADA_CS8201)
-			MII_REG_BITS_ON(AUXCR_MDPPS, MII_NCONFIG, vptr->mac_regs);
+	if ((VELOCITY_SLEEP_SPEED_10M == vptr->options.sleep_speed_10m) &&
+	    !(vptr->mii_status & (VELOCITY_SPEED_10 | VELOCITY_DUPLEX_FULL))) {
+		// set force MAC mode bit */
+		BYTE_REG_BITS_ON(CHIPGCR_FCMODE, &regs->CHIPGCR);
 
-		MII_REG_BITS_OFF(ADVERTISE_1000FULL | ADVERTISE_1000HALF, MII_CTRL1000, vptr->mac_regs);
-	}
+		CHIPGCR = readb(&regs->CHIPGCR);
+		CHIPGCR &= ~CHIPGCR_FCGMII;
+		CHIPGCR |= CHIPGCR_FCFDX;
+		writeb(CHIPGCR, &regs->CHIPGCR);
+		if (vptr->rev_id < REV_ID_VT3216_A0)
+			BYTE_REG_BITS_OFF(TCR_TB2BDIS, &regs->TCR);
+
+		velocity_mii_read(vptr->mac_regs, MII_ADVERTISE, &ANAR);
+		ANAR &= ~(ADVERTISE_100HALF | ADVERTISE_100FULL | ADVERTISE_10HALF);
+		ANAR |= ADVERTISE_10FULL;
+		velocity_mii_write(vptr->mac_regs, MII_ADVERTISE, ANAR);
+
+		MII_REG_BITS_OFF(ADVERTISE_1000FULL | ADVERTISE_1000HALF,
+			MII_CTRL1000, vptr->mac_regs);
 
-	if (vptr->mii_status & VELOCITY_SPEED_1000)
 		MII_REG_BITS_ON(BMCR_ANRESTART, MII_BMCR, vptr->mac_regs);
 
-	BYTE_REG_BITS_ON(CHIPGCR_FCMODE, &regs->CHIPGCR);
+	} else {
+		if (vptr->mii_status & VELOCITY_AUTONEG_ENABLE) {
+			if (PHYID_GET_PHY_ID(vptr->phy_id) == PHYID_CICADA_CS8201)
+				MII_REG_BITS_ON(AUXCR_MDPPS, MII_NCONFIG, vptr->mac_regs);
 
-	{
-		u8 GCR;
-		GCR = readb(&regs->CHIPGCR);
-		GCR = (GCR & ~CHIPGCR_FCGMII) | CHIPGCR_FCFDX;
-		writeb(GCR, &regs->CHIPGCR);
+			MII_REG_BITS_OFF(ADVERTISE_1000FULL | ADVERTISE_1000HALF, MII_CTRL1000, vptr->mac_regs);
+		}
+
+		if (vptr->mii_status & VELOCITY_SPEED_1000)
+			MII_REG_BITS_ON(BMCR_ANRESTART, MII_BMCR, vptr->mac_regs);
+
+		BYTE_REG_BITS_ON(CHIPGCR_FCMODE, &regs->CHIPGCR);
+
+		{
+			GCR = readb(&regs->CHIPGCR);
+			GCR = (GCR & ~CHIPGCR_FCGMII) | CHIPGCR_FCFDX;
+			writeb(GCR, &regs->CHIPGCR);
+		}
 	}
 
 	BYTE_REG_BITS_OFF(ISR_PWEI, &regs->ISR);
@@ -3029,9 +3063,6 @@ static int velocity_suspend(struct pci_dev *pdev, pm_message_t state)
 	struct velocity_info *vptr = netdev_priv(dev);
 	unsigned long flags;
 
-	if (!netif_running(vptr->dev))
-		return 0;
-
 	netif_device_detach(vptr->dev);
 
 	spin_lock_irqsave(&vptr->lock, flags);
diff --git a/drivers/net/via-velocity.h b/drivers/net/via-velocity.h
index aa2e69b..b5316ff 100644
--- a/drivers/net/via-velocity.h
+++ b/drivers/net/via-velocity.h
@@ -1358,6 +1358,8 @@ enum velocity_msg_level {
 
 #define     VELOCITY_FLAGS_FLOW_CTRL       0x01000000UL
 
+#define     VELOCITY_SLEEP_SPEED_10M         1
+
 /*
  *	Flags for driver status
  */
@@ -1426,6 +1428,7 @@ struct velocity_opt {
 	int txqueue_timer;
 	int tx_intsup;
 	int rx_intsup;
+	int sleep_speed_10m;
 	u32 flags;
 };
 
-- 
1.7.3.2

