From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 3/6] phy: kill useless local variables
Date: Sat, 4 Jan 2014 04:17:39 +0300
Message-ID: <201401040417.39742.sergei.shtylyov@cogentembedded.com>
References: <201401040413.06853.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:62730 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754196AbaADARh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 19:17:37 -0500
Received: by mail-la0-f49.google.com with SMTP id er20so8327947lab.8
        for <netdev@vger.kernel.org>; Fri, 03 Jan 2014 16:17:36 -0800 (PST)
Received: from wasted.dev.rtsoft.ru (ppp91-76-83-104.pppoe.mtu-net.ru. [91.76.83.104])
        by mx.google.com with ESMTPSA id sd11sm48215443lab.2.2014.01.03.16.17.35
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 03 Jan 2014 16:17:35 -0800 (PST)
In-Reply-To: <201401040413.06853.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A number of functions (especially in phy.c) has local variables that were hardly
needed in the first place -- remove them.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/phy/phy.c        |   55 ++++++++++++-------------------------------
 drivers/net/phy/phy_device.c |   10 +------
 2 files changed, 18 insertions(+), 47 deletions(-)

Index: net-next/drivers/net/phy/phy.c
===================================================================
--- net-next.orig/drivers/net/phy/phy.c
+++ net-next/drivers/net/phy/phy.c
@@ -67,12 +67,10 @@ EXPORT_SYMBOL(phy_print_status);
  */
 static int phy_clear_interrupt(struct phy_device *phydev)
 {
-	int err = 0;
-
 	if (phydev->drv->ack_interrupt)
-		err = phydev->drv->ack_interrupt(phydev);
+		return phydev->drv->ack_interrupt(phydev);
 
-	return err;
+	return 0;
 }
 
 /**
@@ -84,13 +82,11 @@ static int phy_clear_interrupt(struct ph
  */
 static int phy_config_interrupt(struct phy_device *phydev, u32 interrupts)
 {
-	int err = 0;
-
 	phydev->interrupts = interrupts;
 	if (phydev->drv->config_intr)
-		err = phydev->drv->config_intr(phydev);
+		return phydev->drv->config_intr(phydev);
 
-	return err;
+	return 0;
 }
 
 
@@ -314,7 +310,6 @@ int phy_mii_ioctl(struct phy_device *phy
 {
 	struct mii_ioctl_data *mii_data = if_mii(ifr);
 	u16 val = mii_data->val_in;
-	int ret = 0;
 
 	switch (cmd) {
 	case SIOCGMIIPHY:
@@ -324,7 +319,7 @@ int phy_mii_ioctl(struct phy_device *phy
 	case SIOCGMIIREG:
 		mii_data->val_out = mdiobus_read(phydev->bus, mii_data->phy_id,
 						 mii_data->reg_num);
-		break;
+		return 0;
 
 	case SIOCSMIIREG:
 		if (mii_data->phy_id == phydev->addr) {
@@ -358,8 +353,8 @@ int phy_mii_ioctl(struct phy_device *phy
 
 		if (mii_data->reg_num == MII_BMCR &&
 		    val & BMCR_RESET)
-			ret = phy_init_hw(phydev);
-		break;
+			return phy_init_hw(phydev);
+		return 0;
 
 	case SIOCSHWTSTAMP:
 		if (phydev->drv->hwtstamp)
@@ -369,8 +364,6 @@ int phy_mii_ioctl(struct phy_device *phy
 	default:
 		return -EOPNOTSUPP;
 	}
-
-	return ret;
 }
 EXPORT_SYMBOL(phy_mii_ioctl);
 
@@ -557,8 +550,6 @@ phy_err:
  */
 int phy_start_interrupts(struct phy_device *phydev)
 {
-	int err = 0;
-
 	atomic_set(&phydev->irq_disable, 0);
 	if (request_irq(phydev->irq, phy_interrupt,
 				IRQF_SHARED,
@@ -570,9 +561,7 @@ int phy_start_interrupts(struct phy_devi
 		return 0;
 	}
 
-	err = phy_enable_interrupts(phydev);
-
-	return err;
+	return phy_enable_interrupts(phydev);
 }
 EXPORT_SYMBOL(phy_start_interrupts);
 
@@ -615,7 +604,6 @@ EXPORT_SYMBOL(phy_stop_interrupts);
  */
 void phy_change(struct work_struct *work)
 {
-	int err;
 	struct phy_device *phydev =
 		container_of(work, struct phy_device, phy_queue);
 
@@ -623,9 +611,7 @@ void phy_change(struct work_struct *work
 	    !phydev->drv->did_interrupt(phydev))
 		goto ignore;
 
-	err = phy_disable_interrupts(phydev);
-
-	if (err)
+	if (phy_disable_interrupts(phydev))
 		goto phy_err;
 
 	mutex_lock(&phydev->lock);
@@ -637,10 +623,8 @@ void phy_change(struct work_struct *work
 	enable_irq(phydev->irq);
 
 	/* Reenable interrupts */
-	if (PHY_HALTED != phydev->state)
-		err = phy_config_interrupt(phydev, PHY_INTERRUPT_ENABLED);
-
-	if (err)
+	if (PHY_HALTED != phydev->state &&
+	    phy_config_interrupt(phydev, PHY_INTERRUPT_ENABLED))
 		goto irq_enable_err;
 
 	/* reschedule state queue work to run as soon as possible */
@@ -953,14 +937,10 @@ static inline void mmd_phy_indirect(stru
 static int phy_read_mmd_indirect(struct mii_bus *bus, int prtad, int devad,
 				 int addr)
 {
-	u32 ret;
-
 	mmd_phy_indirect(bus, prtad, devad, addr);
 
 	/* Read the content of the MMD's selected register */
-	ret = bus->read(bus, addr, MII_MMD_DATA);
-
-	return ret;
+	return bus->read(bus, addr, MII_MMD_DATA);
 }
 
 /**
@@ -1000,8 +980,6 @@ static void phy_write_mmd_indirect(struc
  */
 int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
 {
-	int ret = -EPROTONOSUPPORT;
-
 	/* According to 802.3az,the EEE is supported only in full duplex-mode.
 	 * Also EEE feature is active when core is operating with MII, GMII
 	 * or RGMII.
@@ -1027,7 +1005,7 @@ int phy_init_eee(struct phy_device *phyd
 
 		cap = mmd_eee_cap_to_ethtool_sup_t(eee_cap);
 		if (!cap)
-			goto eee_exit;
+			return -EPROTONOSUPPORT;
 
 		/* Check which link settings negotiated and verify it in
 		 * the EEE advertising registers.
@@ -1046,7 +1024,7 @@ int phy_init_eee(struct phy_device *phyd
 		lp = mmd_eee_adv_to_ethtool_adv_t(eee_lp);
 		idx = phy_find_setting(phydev->speed, phydev->duplex);
 		if (!(lp & adv & settings[idx].setting))
-			goto eee_exit;
+			return -EPROTONOSUPPORT;
 
 		if (clk_stop_enable) {
 			/* Configure the PHY to stop receiving xMII
@@ -1063,11 +1041,10 @@ int phy_init_eee(struct phy_device *phyd
 					       MDIO_MMD_PCS, phydev->addr, val);
 		}
 
-		ret = 0; /* EEE supported */
+		return 0; /* EEE supported */
 	}
 
-eee_exit:
-	return ret;
+	return -EPROTONOSUPPORT;
 }
 EXPORT_SYMBOL(phy_init_eee);
 
Index: net-next/drivers/net/phy/phy_device.c
===================================================================
--- net-next.orig/drivers/net/phy/phy_device.c
+++ net-next/drivers/net/phy/phy_device.c
@@ -329,7 +329,6 @@ static int get_phy_id(struct mii_bus *bu
 struct phy_device *get_phy_device(struct mii_bus *bus, int addr, bool is_c45)
 {
 	struct phy_c45_device_ids c45_ids = {0};
-	struct phy_device *dev = NULL;
 	u32 phy_id = 0;
 	int r;
 
@@ -341,9 +340,7 @@ struct phy_device *get_phy_device(struct
 	if ((phy_id & 0x1fffffff) == 0x1fffffff)
 		return NULL;
 
-	dev = phy_device_create(bus, addr, phy_id, is_c45, &c45_ids);
-
-	return dev;
+	return phy_device_create(bus, addr, phy_id, is_c45, &c45_ids);
 }
 EXPORT_SYMBOL(get_phy_device);
 
@@ -783,7 +780,6 @@ static int genphy_config_advert(struct p
  */
 int genphy_setup_forced(struct phy_device *phydev)
 {
-	int err;
 	int ctl = 0;
 
 	phydev->pause = 0;
@@ -797,9 +793,7 @@ int genphy_setup_forced(struct phy_devic
 	if (DUPLEX_FULL == phydev->duplex)
 		ctl |= BMCR_FULLDPLX;
 
-	err = phy_write(phydev, MII_BMCR, ctl);
-
-	return err;
+	return phy_write(phydev, MII_BMCR, ctl);
 }
 EXPORT_SYMBOL(genphy_setup_forced);
 
