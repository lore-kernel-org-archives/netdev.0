From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Fix fallout from tg3_readphy() value is zero on error
Date: Tue, 15 Feb 2005 09:14:01 -0800
Message-ID: <20050215091401.3d6174d8.davem@davemloft.net>
References: <16880.24671.640491.852938@berry.gelato.unsw.EDU.AU>
	<20050120233639.5e6088ee.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: peterc@gelato.unsw.edu.au, netdev@oss.sgi.com, mchan@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050120233639.5e6088ee.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I've added missing tg3_readphy() return value checks wherever I could
sanely do so.

Where possible, we throw back an error return.  Else, we at least
try to avoid writing bogus PHY register values.

In general, I just try to make sure nothing incredibly stupid happens
if tg3_readphy() fails for some reason.

===== drivers/net/tg3.c 1.241 vs edited =====
--- 1.241/drivers/net/tg3.c	2005-02-11 12:44:48 -08:00
+++ edited/drivers/net/tg3.c	2005-02-15 08:41:45 -08:00
@@ -591,9 +591,10 @@
 	if (tp->tg3_flags2 & TG3_FLG2_NO_ETH_WIRE_SPEED)
 		return;
 
-	tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x7007);
-	tg3_readphy(tp, MII_TG3_AUX_CTRL, &val);
-	tg3_writephy(tp, MII_TG3_AUX_CTRL, (val | (1 << 15) | (1 << 4)));
+	if (!tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x7007) &&
+	    !tg3_readphy(tp, MII_TG3_AUX_CTRL, &val))
+		tg3_writephy(tp, MII_TG3_AUX_CTRL,
+			     (val | (1 << 15) | (1 << 4)));
 }
 
 static int tg3_bmcr_reset(struct tg3 *tp)
@@ -634,9 +635,10 @@
 	while (limit--) {
 		u32 tmp32;
 
-		tg3_readphy(tp, 0x16, &tmp32);
-		if ((tmp32 & 0x1000) == 0)
-			break;
+		if (!tg3_readphy(tp, 0x16, &tmp32)) {
+			if ((tmp32 & 0x1000) == 0)
+				break;
+		}
 	}
 	if (limit <= 0)
 		return -EBUSY;
@@ -688,9 +690,9 @@
 		for (i = 0; i < 6; i += 2) {
 			u32 low, high;
 
-			tg3_readphy(tp, MII_TG3_DSP_RW_PORT, &low);
-			tg3_readphy(tp, MII_TG3_DSP_RW_PORT, &high);
-			if (tg3_wait_macro_done(tp)) {
+			if (tg3_readphy(tp, MII_TG3_DSP_RW_PORT, &low) ||
+			    tg3_readphy(tp, MII_TG3_DSP_RW_PORT, &high) ||
+			    tg3_wait_macro_done(tp)) {
 				*resetp = 1;
 				return -EBUSY;
 			}
@@ -746,7 +748,9 @@
 		}
 
 		/* Disable transmitter and interrupt.  */
-		tg3_readphy(tp, MII_TG3_EXT_CTRL, &reg32);
+		if (tg3_readphy(tp, MII_TG3_EXT_CTRL, &reg32))
+			continue;
+
 		reg32 |= 0x3000;
 		tg3_writephy(tp, MII_TG3_EXT_CTRL, reg32);
 
@@ -755,7 +759,9 @@
 			     BMCR_FULLDPLX | TG3_BMCR_SPEED1000);
 
 		/* Set to master mode.  */
-		tg3_readphy(tp, MII_TG3_CTRL, &phy9_orig);
+		if (tg3_readphy(tp, MII_TG3_CTRL, &phy9_orig))
+			continue;
+
 		tg3_writephy(tp, MII_TG3_CTRL,
 			     (MII_TG3_CTRL_AS_MASTER |
 			      MII_TG3_CTRL_ENABLE_AS_MASTER));
@@ -793,9 +799,11 @@
 
 	tg3_writephy(tp, MII_TG3_CTRL, phy9_orig);
 
-	tg3_readphy(tp, MII_TG3_EXT_CTRL, &reg32);
-	reg32 &= ~0x3000;
-	tg3_writephy(tp, MII_TG3_EXT_CTRL, reg32);
+	if (tg3_readphy(tp, MII_TG3_EXT_CTRL, &reg32)) {
+		reg32 &= ~0x3000;
+		tg3_writephy(tp, MII_TG3_EXT_CTRL, reg32);
+	} else if (!err)
+		err = -EBUSY;
 
 	return err;
 }
@@ -859,9 +867,9 @@
 		u32 phy_reg;
 
 		/* Set bit 14 with read-modify-write to preserve other bits */
-		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x0007);
-		tg3_readphy(tp, MII_TG3_AUX_CTRL, &phy_reg);
-		tg3_writephy(tp, MII_TG3_AUX_CTRL, phy_reg | 0x4000);
+		if (!tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x0007) &&
+		    !tg3_readphy(tp, MII_TG3_AUX_CTRL, &phy_reg))
+			tg3_writephy(tp, MII_TG3_AUX_CTRL, phy_reg | 0x4000);
 	}
 	tg3_phy_set_wirespeed(tp);
 	return 0;
@@ -1244,7 +1252,7 @@
 	};
 }
 
-static int tg3_phy_copper_begin(struct tg3 *tp)
+static void tg3_phy_copper_begin(struct tg3 *tp)
 {
 	u32 new_adv;
 	int i;
@@ -1359,15 +1367,16 @@
 		if (tp->link_config.duplex == DUPLEX_FULL)
 			bmcr |= BMCR_FULLDPLX;
 
-		tg3_readphy(tp, MII_BMCR, &orig_bmcr);
-		if (bmcr != orig_bmcr) {
+		if (!tg3_readphy(tp, MII_BMCR, &orig_bmcr) &&
+		    (bmcr != orig_bmcr)) {
 			tg3_writephy(tp, MII_BMCR, BMCR_LOOPBACK);
 			for (i = 0; i < 1500; i++) {
 				u32 tmp;
 
 				udelay(10);
-				tg3_readphy(tp, MII_BMSR, &tmp);
-				tg3_readphy(tp, MII_BMSR, &tmp);
+				if (tg3_readphy(tp, MII_BMSR, &tmp) ||
+				    tg3_readphy(tp, MII_BMSR, &tmp))
+					continue;
 				if (!(tmp & BMSR_LSTATUS)) {
 					udelay(40);
 					break;
@@ -1380,8 +1389,6 @@
 		tg3_writephy(tp, MII_BMCR,
 			     BMCR_ANENABLE | BMCR_ANRESTART);
 	}
-
-	return 0;
 }
 
 static int tg3_init_5401phy_dsp(struct tg3 *tp)
@@ -1416,7 +1423,9 @@
 {
 	u32 adv_reg, all_mask;
 
-	tg3_readphy(tp, MII_ADVERTISE, &adv_reg);
+	if (tg3_readphy(tp, MII_ADVERTISE, &adv_reg))
+		return 0;
+
 	all_mask = (ADVERTISE_10HALF | ADVERTISE_10FULL |
 		    ADVERTISE_100HALF | ADVERTISE_100FULL);
 	if ((adv_reg & all_mask) != all_mask)
@@ -1424,7 +1433,9 @@
 	if (!(tp->tg3_flags & TG3_FLAG_10_100_ONLY)) {
 		u32 tg3_ctrl;
 
-		tg3_readphy(tp, MII_TG3_CTRL, &tg3_ctrl);
+		if (tg3_readphy(tp, MII_TG3_CTRL, &tg3_ctrl))
+			return 0;
+
 		all_mask = (MII_TG3_CTRL_ADV_1000_HALF |
 			    MII_TG3_CTRL_ADV_1000_FULL);
 		if ((tg3_ctrl & all_mask) != all_mask)
@@ -1464,8 +1475,8 @@
 	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705) &&
 	    netif_carrier_ok(tp->dev)) {
 		tg3_readphy(tp, MII_BMSR, &bmsr);
-		tg3_readphy(tp, MII_BMSR, &bmsr);
-		if (!(bmsr & BMSR_LSTATUS))
+		if (!tg3_readphy(tp, MII_BMSR, &bmsr) &&
+		    !(bmsr & BMSR_LSTATUS))
 			force_reset = 1;
 	}
 	if (force_reset)
@@ -1473,9 +1484,8 @@
 
 	if ((tp->phy_id & PHY_ID_MASK) == PHY_ID_BCM5401) {
 		tg3_readphy(tp, MII_BMSR, &bmsr);
-		tg3_readphy(tp, MII_BMSR, &bmsr);
-
-		if (!(tp->tg3_flags & TG3_FLAG_INIT_COMPLETE))
+		if (tg3_readphy(tp, MII_BMSR, &bmsr) ||
+		    !(tp->tg3_flags & TG3_FLAG_INIT_COMPLETE))
 			bmsr = 0;
 
 		if (!(bmsr & BMSR_LSTATUS)) {
@@ -1486,8 +1496,8 @@
 			tg3_readphy(tp, MII_BMSR, &bmsr);
 			for (i = 0; i < 1000; i++) {
 				udelay(10);
-				tg3_readphy(tp, MII_BMSR, &bmsr);
-				if (bmsr & BMSR_LSTATUS) {
+				if (!tg3_readphy(tp, MII_BMSR, &bmsr) &&
+				    (bmsr & BMSR_LSTATUS)) {
 					udelay(40);
 					break;
 				}
@@ -1549,8 +1559,8 @@
 	bmsr = 0;
 	for (i = 0; i < 100; i++) {
 		tg3_readphy(tp, MII_BMSR, &bmsr);
-		tg3_readphy(tp, MII_BMSR, &bmsr);
-		if (bmsr & BMSR_LSTATUS)
+		if (!tg3_readphy(tp, MII_BMSR, &bmsr) &&
+		    (bmsr & BMSR_LSTATUS))
 			break;
 		udelay(40);
 	}
@@ -1561,8 +1571,8 @@
 		tg3_readphy(tp, MII_TG3_AUX_STAT, &aux_stat);
 		for (i = 0; i < 2000; i++) {
 			udelay(10);
-			tg3_readphy(tp, MII_TG3_AUX_STAT, &aux_stat);
-			if (aux_stat)
+			if (!tg3_readphy(tp, MII_TG3_AUX_STAT, &aux_stat) &&
+			    aux_stat)
 				break;
 		}
 
@@ -1573,7 +1583,8 @@
 		bmcr = 0;
 		for (i = 0; i < 200; i++) {
 			tg3_readphy(tp, MII_BMCR, &bmcr);
-			tg3_readphy(tp, MII_BMCR, &bmcr);
+			if (tg3_readphy(tp, MII_BMCR, &bmcr))
+				continue;
 			if (bmcr && bmcr != 0x7fff)
 				break;
 			udelay(10);
@@ -1610,10 +1621,13 @@
 	    (tp->link_config.autoneg == AUTONEG_ENABLE)) {
 		u32 local_adv, remote_adv;
 
-		tg3_readphy(tp, MII_ADVERTISE, &local_adv);
+		if (tg3_readphy(tp, MII_ADVERTISE, &local_adv))
+			local_adv = 0;
 		local_adv &= (ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM);
 
-		tg3_readphy(tp, MII_LPA, &remote_adv);
+		if (tg3_readphy(tp, MII_LPA, &remote_adv))
+			remote_adv = 0;
+
 		remote_adv &= (LPA_PAUSE_CAP | LPA_PAUSE_ASYM);
 
 		/* If we are not advertising full pause capability,
@@ -1632,8 +1646,8 @@
 		tg3_phy_copper_begin(tp);
 
 		tg3_readphy(tp, MII_BMSR, &tmp);
-		tg3_readphy(tp, MII_BMSR, &tmp);
-		if (tmp & BMSR_LSTATUS)
+		if (!tg3_readphy(tp, MII_BMSR, &tmp) &&
+		    (tmp & BMSR_LSTATUS))
 			current_link_up = 1;
 	}
 
@@ -5441,9 +5455,10 @@
 		u32 tmp;
 
 		/* Clear CRC stats. */
-		tg3_readphy(tp, 0x1e, &tmp);
-		tg3_writephy(tp, 0x1e, tmp | 0x8000);
-		tg3_readphy(tp, 0x14, &tmp);
+		if (!tg3_readphy(tp, 0x1e, &tmp)) {
+			tg3_writephy(tp, 0x1e, tmp | 0x8000);
+			tg3_readphy(tp, 0x14, &tmp);
+		}
 	}
 
 	__tg3_set_rx_mode(tp->dev);
@@ -6033,9 +6048,11 @@
 		u32 val;
 
 		spin_lock_irqsave(&tp->lock, flags);
-		tg3_readphy(tp, 0x1e, &val);
-		tg3_writephy(tp, 0x1e, val | 0x8000);
-		tg3_readphy(tp, 0x14, &val);
+		if (!tg3_readphy(tp, 0x1e, &val)) {
+			tg3_writephy(tp, 0x1e, val | 0x8000);
+			tg3_readphy(tp, 0x14, &val);
+		} else
+			val = 0;
 		spin_unlock_irqrestore(&tp->lock, flags);
 
 		tp->phy_crc_errors += val;
@@ -6651,10 +6668,10 @@
 	int r;
   
 	spin_lock_irq(&tp->lock);
-	tg3_readphy(tp, MII_BMCR, &bmcr);
-	tg3_readphy(tp, MII_BMCR, &bmcr);
 	r = -EINVAL;
-	if (bmcr & BMCR_ANENABLE) {
+	tg3_readphy(tp, MII_BMCR, &bmcr);
+	if (!tg3_readphy(tp, MII_BMCR, &bmcr) &&
+	    (bmcr & BMCR_ANENABLE)) {
 		tg3_writephy(tp, MII_BMCR, bmcr | BMCR_ANRESTART);
 		r = 0;
 	}
@@ -7654,9 +7671,8 @@
 		u32 bmsr, adv_reg, tg3_ctrl;
 
 		tg3_readphy(tp, MII_BMSR, &bmsr);
-		tg3_readphy(tp, MII_BMSR, &bmsr);
-
-		if (bmsr & BMSR_LSTATUS)
+		if (!tg3_readphy(tp, MII_BMSR, &bmsr) &&
+		    (bmsr & BMSR_LSTATUS))
 			goto skip_phy_reset;
 		    
 		err = tg3_phy_reset(tp);
