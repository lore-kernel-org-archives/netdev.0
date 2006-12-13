From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: latest linux git doesn't compile ucc_geth_phy.c and ucc_geth.c
Date: Wed, 13 Dec 2006 08:36:14 -0600 (CST)
Message-ID: <Pine.LNX.4.64.0612130834250.25226@gate.crashing.org>
References: <1166013887.30422.54.camel@gentoo-jocke.transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev <linuxppc-dev@ozlabs.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
In-Reply-To: <1166013887.30422.54.camel@gentoo-jocke.transmode.se>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org



On Wed, 13 Dec 2006, Joakim Tjernlund wrote:

> drivers/net/ucc_geth.c:4083:45: macro "INIT_WORK" passed 3 arguments,
> but takes just 2
> drivers/net/ucc_geth.c: In function `ucc_geth_open':
> drivers/net/ucc_geth.c:4083: error: `INIT_WORK' undeclared (first use in
> this function)
> drivers/net/ucc_geth.c:4083: error: (Each undeclared identifier is
> reported only once
> drivers/net/ucc_geth.c:4083: error: for each function it appears in.)
> drivers/net/ucc_geth.c: At top level:
> drivers/net/ucc_geth.c:3924: warning: 'ugeth_phy_change' defined but not
> used
> make[2]: *** [drivers/net/ucc_geth.o] Error 1
>

This is because of the new INIT_WORK changes.

> drivers/net/ucc_geth_phy.c:71: error: conflicting types for 'phy_read'
> include/linux/phy.h:355: error: previous declaration of 'phy_read' was
> here
> drivers/net/ucc_geth_phy.c:71: error: conflicting types for 'phy_read'
> include/linux/phy.h:355: error: previous declaration of 'phy_read' was
> here
> drivers/net/ucc_geth_phy.c:72: error: conflicting types for 'phy_write'
> include/linux/phy.h:356: error: previous declaration of 'phy_write' was
> here
> drivers/net/ucc_geth_phy.c:72: error: conflicting types for 'phy_write'
> include/linux/phy.h:356: error: previous declaration of 'phy_write' was
> here

This is because of me wanting to get PHY_POLL defined for board code with 
having to include it everywhere it was being used.

Try the following patch and let me know if it works. (Make sure to try 
something that effects the PHY, like link status change or speed).

If it works for you I'll clean it up and send it upstream.

- k

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 8243150..252088f 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3920,10 +3920,11 @@ static irqreturn_t phy_interrupt(int irq, void *dev_id)
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

@@ -4080,7 +4081,7 @@ static int ucc_geth_open(struct net_device *dev)
  #endif				/* CONFIG_UGETH_NAPI */

  	/* Set up the PHY change work queue */
-	INIT_WORK(&ugeth->tq, ugeth_phy_change, dev);
+	INIT_WORK(&ugeth->tq, ugeth_phy_change);

  	init_timer(&ugeth->phy_info_timer);
  	ugeth->phy_info_timer.function = &ugeth_phy_startup_timer;
diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h
diff --git a/drivers/net/ucc_geth_phy.c b/drivers/net/ucc_geth_phy.c
index 5360ec0..95a7674 100644
--- a/drivers/net/ucc_geth_phy.c
+++ b/drivers/net/ucc_geth_phy.c
@@ -68,8 +68,8 @@ static int gbit_config_aneg(struct ugeth_mii_info *mii_info);
  static int genmii_config_aneg(struct ugeth_mii_info *mii_info);
  static int genmii_update_link(struct ugeth_mii_info *mii_info);
  static int genmii_read_status(struct ugeth_mii_info *mii_info);
-u16 phy_read(struct ugeth_mii_info *mii_info, u16 regnum);
-void phy_write(struct ugeth_mii_info *mii_info, u16 regnum, u16 val);
+static u16 ugphy_read(struct ugeth_mii_info *mii_info, u16 regnum);
+static void ugphy_write(struct ugeth_mii_info *mii_info, u16 regnum, u16 val);

  /* Write value to the PHY for this device to the register at regnum, */
  /* waiting until the write is done before it returns.  All PHY */
@@ -184,7 +184,7 @@ static void config_genmii_advert(struct ugeth_mii_info *mii_info)
  	advertise = mii_info->advertising;

  	/* Setup standard advertisement */
-	adv = phy_read(mii_info, MII_ADVERTISE);
+	adv = ugphy_read(mii_info, MII_ADVERTISE);
  	adv &= ~(ADVERTISE_ALL | ADVERTISE_100BASE4);
  	if (advertise & ADVERTISED_10baseT_Half)
  		adv |= ADVERTISE_10HALF;
@@ -194,7 +194,7 @@ static void config_genmii_advert(struct ugeth_mii_info *mii_info)
  		adv |= ADVERTISE_100HALF;
  	if (advertise & ADVERTISED_100baseT_Full)
  		adv |= ADVERTISE_100FULL;
-	phy_write(mii_info, MII_ADVERTISE, adv);
+	ugphy_write(mii_info, MII_ADVERTISE, adv);
  }

  static void genmii_setup_forced(struct ugeth_mii_info *mii_info)
@@ -204,7 +204,7 @@ static void genmii_setup_forced(struct ugeth_mii_info *mii_info)

  	ugphy_vdbg("%s: IN", __FUNCTION__);

-	ctrl = phy_read(mii_info, MII_BMCR);
+	ctrl = ugphy_read(mii_info, MII_BMCR);

  	ctrl &=
  	    ~(BMCR_FULLDPLX | BMCR_SPEED100 | BMCR_SPEED1000 | BMCR_ANENABLE);
@@ -234,7 +234,7 @@ static void genmii_setup_forced(struct ugeth_mii_info *mii_info)
  		break;
  	}

-	phy_write(mii_info, MII_BMCR, ctrl);
+	ugphy_write(mii_info, MII_BMCR, ctrl);
  }

  /* Enable and Restart Autonegotiation */
@@ -244,9 +244,9 @@ static void genmii_restart_aneg(struct ugeth_mii_info *mii_info)

  	ugphy_vdbg("%s: IN", __FUNCTION__);

-	ctl = phy_read(mii_info, MII_BMCR);
+	ctl = ugphy_read(mii_info, MII_BMCR);
  	ctl |= (BMCR_ANENABLE | BMCR_ANRESTART);
-	phy_write(mii_info, MII_BMCR, ctl);
+	ugphy_write(mii_info, MII_BMCR, ctl);
  }

  static int gbit_config_aneg(struct ugeth_mii_info *mii_info)
@@ -261,14 +261,14 @@ static int gbit_config_aneg(struct ugeth_mii_info *mii_info)
  		config_genmii_advert(mii_info);
  		advertise = mii_info->advertising;

-		adv = phy_read(mii_info, MII_1000BASETCONTROL);
+		adv = ugphy_read(mii_info, MII_1000BASETCONTROL);
  		adv &= ~(MII_1000BASETCONTROL_FULLDUPLEXCAP |
  			 MII_1000BASETCONTROL_HALFDUPLEXCAP);
  		if (advertise & SUPPORTED_1000baseT_Half)
  			adv |= MII_1000BASETCONTROL_HALFDUPLEXCAP;
  		if (advertise & SUPPORTED_1000baseT_Full)
  			adv |= MII_1000BASETCONTROL_FULLDUPLEXCAP;
-		phy_write(mii_info, MII_1000BASETCONTROL, adv);
+		ugphy_write(mii_info, MII_1000BASETCONTROL, adv);

  		/* Start/Restart aneg */
  		genmii_restart_aneg(mii_info);
@@ -298,10 +298,10 @@ static int genmii_update_link(struct ugeth_mii_info *mii_info)
  	ugphy_vdbg("%s: IN", __FUNCTION__);

  	/* Do a fake read */
-	phy_read(mii_info, MII_BMSR);
+	ugphy_read(mii_info, MII_BMSR);

  	/* Read link and autonegotiation status */
-	status = phy_read(mii_info, MII_BMSR);
+	status = ugphy_read(mii_info, MII_BMSR);
  	if ((status & BMSR_LSTATUS) == 0)
  		mii_info->link = 0;
  	else
@@ -329,7 +329,7 @@ static int genmii_read_status(struct ugeth_mii_info *mii_info)
  		return err;

  	if (mii_info->autoneg) {
-		status = phy_read(mii_info, MII_LPA);
+		status = ugphy_read(mii_info, MII_LPA);

  		if (status & (LPA_10FULL | LPA_100FULL))
  			mii_info->duplex = DUPLEX_FULL;
@@ -352,9 +352,9 @@ static int marvell_init(struct ugeth_mii_info *mii_info)
  {
  	ugphy_vdbg("%s: IN", __FUNCTION__);

-	phy_write(mii_info, 0x14, 0x0cd2);
-	phy_write(mii_info, MII_BMCR,
-		  phy_read(mii_info, MII_BMCR) | BMCR_RESET);
+	ugphy_write(mii_info, 0x14, 0x0cd2);
+	ugphy_write(mii_info, MII_BMCR,
+		  ugphy_read(mii_info, MII_BMCR) | BMCR_RESET);
  	msleep(4000);

  	return 0;
@@ -367,13 +367,13 @@ static int marvell_config_aneg(struct ugeth_mii_info *mii_info)
  	/* The Marvell PHY has an errata which requires
  	 * that certain registers get written in order
  	 * to restart autonegotiation */
-	phy_write(mii_info, MII_BMCR, BMCR_RESET);
+	ugphy_write(mii_info, MII_BMCR, BMCR_RESET);

-	phy_write(mii_info, 0x1d, 0x1f);
-	phy_write(mii_info, 0x1e, 0x200c);
-	phy_write(mii_info, 0x1d, 0x5);
-	phy_write(mii_info, 0x1e, 0);
-	phy_write(mii_info, 0x1e, 0x100);
+	ugphy_write(mii_info, 0x1d, 0x1f);
+	ugphy_write(mii_info, 0x1e, 0x200c);
+	ugphy_write(mii_info, 0x1d, 0x5);
+	ugphy_write(mii_info, 0x1e, 0);
+	ugphy_write(mii_info, 0x1e, 0x100);

  	gbit_config_aneg(mii_info);

@@ -398,7 +398,7 @@ static int marvell_read_status(struct ugeth_mii_info *mii_info)
  	 * are as set */
  	if (mii_info->autoneg && mii_info->link) {
  		int speed;
-		status = phy_read(mii_info, MII_M1011_PHY_SPEC_STATUS);
+		status = ugphy_read(mii_info, MII_M1011_PHY_SPEC_STATUS);

  		/* Get the duplexity */
  		if (status & MII_M1011_PHY_SPEC_STATUS_FULLDUPLEX)
@@ -430,7 +430,7 @@ static int marvell_ack_interrupt(struct ugeth_mii_info *mii_info)
  	ugphy_vdbg("%s: IN", __FUNCTION__);

  	/* Clear the interrupts by reading the reg */
-	phy_read(mii_info, MII_M1011_IEVENT);
+	ugphy_read(mii_info, MII_M1011_IEVENT);

  	return 0;
  }
@@ -440,9 +440,9 @@ static int marvell_config_intr(struct ugeth_mii_info *mii_info)
  	ugphy_vdbg("%s: IN", __FUNCTION__);

  	if (mii_info->interrupts == MII_INTERRUPT_ENABLED)
-		phy_write(mii_info, MII_M1011_IMASK, MII_M1011_IMASK_INIT);
+		ugphy_write(mii_info, MII_M1011_IMASK, MII_M1011_IMASK_INIT);
  	else
-		phy_write(mii_info, MII_M1011_IMASK, MII_M1011_IMASK_CLEAR);
+		ugphy_write(mii_info, MII_M1011_IMASK, MII_M1011_IMASK_CLEAR);

  	return 0;
  }
@@ -451,9 +451,9 @@ static int cis820x_init(struct ugeth_mii_info *mii_info)
  {
  	ugphy_vdbg("%s: IN", __FUNCTION__);

-	phy_write(mii_info, MII_CIS8201_AUX_CONSTAT,
+	ugphy_write(mii_info, MII_CIS8201_AUX_CONSTAT,
  		  MII_CIS8201_AUXCONSTAT_INIT);
-	phy_write(mii_info, MII_CIS8201_EXT_CON1, MII_CIS8201_EXTCON1_INIT);
+	ugphy_write(mii_info, MII_CIS8201_EXT_CON1, MII_CIS8201_EXTCON1_INIT);

  	return 0;
  }
@@ -477,7 +477,7 @@ static int cis820x_read_status(struct ugeth_mii_info *mii_info)
  	if (mii_info->autoneg && mii_info->link) {
  		int speed;

-		status = phy_read(mii_info, MII_CIS8201_AUX_CONSTAT);
+		status = ugphy_read(mii_info, MII_CIS8201_AUX_CONSTAT);
  		if (status & MII_CIS8201_AUXCONSTAT_DUPLEX)
  			mii_info->duplex = DUPLEX_FULL;
  		else
@@ -505,7 +505,7 @@ static int cis820x_ack_interrupt(struct ugeth_mii_info *mii_info)
  {
  	ugphy_vdbg("%s: IN", __FUNCTION__);

-	phy_read(mii_info, MII_CIS8201_ISTAT);
+	ugphy_read(mii_info, MII_CIS8201_ISTAT);

  	return 0;
  }
@@ -515,9 +515,9 @@ static int cis820x_config_intr(struct ugeth_mii_info *mii_info)
  	ugphy_vdbg("%s: IN", __FUNCTION__);

  	if (mii_info->interrupts == MII_INTERRUPT_ENABLED)
-		phy_write(mii_info, MII_CIS8201_IMASK, MII_CIS8201_IMASK_MASK);
+		ugphy_write(mii_info, MII_CIS8201_IMASK, MII_CIS8201_IMASK_MASK);
  	else
-		phy_write(mii_info, MII_CIS8201_IMASK, 0);
+		ugphy_write(mii_info, MII_CIS8201_IMASK, 0);

  	return 0;
  }
@@ -541,7 +541,7 @@ static int dm9161_read_status(struct ugeth_mii_info *mii_info)
  	/* If we aren't autonegotiating, assume speeds
  	 * are as set */
  	if (mii_info->autoneg && mii_info->link) {
-		status = phy_read(mii_info, MII_DM9161_SCSR);
+		status = ugphy_read(mii_info, MII_DM9161_SCSR);
  		if (status & (MII_DM9161_SCSR_100F | MII_DM9161_SCSR_100H))
  			mii_info->speed = SPEED_100;
  		else
@@ -572,7 +572,7 @@ static void dm9161_timer(unsigned long data)
  {
  	struct ugeth_mii_info *mii_info = (struct ugeth_mii_info *)data;
  	struct dm9161_private *priv = mii_info->priv;
-	u16 status = phy_read(mii_info, MII_BMSR);
+	u16 status = ugphy_read(mii_info, MII_BMSR);

  	ugphy_vdbg("%s: IN", __FUNCTION__);

@@ -599,11 +599,11 @@ static int dm9161_init(struct ugeth_mii_info *mii_info)
  	/* Reset is not done yet */
  	priv->resetdone = 0;

-	phy_write(mii_info, MII_BMCR,
-		  phy_read(mii_info, MII_BMCR) | BMCR_RESET);
+	ugphy_write(mii_info, MII_BMCR,
+		  ugphy_read(mii_info, MII_BMCR) | BMCR_RESET);

-	phy_write(mii_info, MII_BMCR,
-		  phy_read(mii_info, MII_BMCR) & ~BMCR_ISOLATE);
+	ugphy_write(mii_info, MII_BMCR,
+		  ugphy_read(mii_info, MII_BMCR) & ~BMCR_ISOLATE);

  	config_genmii_advert(mii_info);
  	/* Start/Restart aneg */
@@ -634,7 +634,7 @@ static int dm9161_ack_interrupt(struct ugeth_mii_info *mii_info)
  	ugphy_vdbg("%s: IN", __FUNCTION__);

  	/* Clear the interrupts by reading the reg */
-	phy_read(mii_info, MII_DM9161_INTR);
+	ugphy_read(mii_info, MII_DM9161_INTR);


  	return 0;
@@ -645,9 +645,9 @@ static int dm9161_config_intr(struct ugeth_mii_info *mii_info)
  	ugphy_vdbg("%s: IN", __FUNCTION__);

  	if (mii_info->interrupts == MII_INTERRUPT_ENABLED)
-		phy_write(mii_info, MII_DM9161_INTR, MII_DM9161_INTR_INIT);
+		ugphy_write(mii_info, MII_DM9161_INTR, MII_DM9161_INTR_INIT);
  	else
-		phy_write(mii_info, MII_DM9161_INTR, MII_DM9161_INTR_STOP);
+		ugphy_write(mii_info, MII_DM9161_INTR, MII_DM9161_INTR_STOP);

  	return 0;
  }
@@ -718,7 +718,7 @@ static struct phy_info *phy_info[] = {
  	NULL
  };

-u16 phy_read(struct ugeth_mii_info *mii_info, u16 regnum)
+static u16 ugphy_read(struct ugeth_mii_info *mii_info, u16 regnum)
  {
  	u16 retval;
  	unsigned long flags;
@@ -732,7 +732,7 @@ u16 phy_read(struct ugeth_mii_info *mii_info, u16 regnum)
  	return retval;
  }

-void phy_write(struct ugeth_mii_info *mii_info, u16 regnum, u16 val)
+static void ugphy_write(struct ugeth_mii_info *mii_info, u16 regnum, u16 val)
  {
  	unsigned long flags;

@@ -757,11 +757,11 @@ struct phy_info *get_phy_info(struct ugeth_mii_info *mii_info)
  	ugphy_vdbg("%s: IN", __FUNCTION__);

  	/* Grab the bits from PHYIR1, and put them in the upper half */
-	phy_reg = phy_read(mii_info, MII_PHYSID1);
+	phy_reg = ugphy_read(mii_info, MII_PHYSID1);
  	phy_ID = (phy_reg & 0xffff) << 16;

  	/* Grab the bits from PHYIR2, and put them in the lower half */
-	phy_reg = phy_read(mii_info, MII_PHYSID2);
+	phy_reg = ugphy_read(mii_info, MII_PHYSID2);
  	phy_ID |= (phy_reg & 0xffff);

  	/* loop through all the known PHY types, and find one that */
