From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: Getting the correct asix AX88178 usb gige driver in mainline?
Date: Wed, 6 Jul 2011 22:09:05 +0200
Message-ID: <201107062209.05794.arnd@arndb.de>
References: <20110629033025.GA32153@merlins.org> <20110706172538.GI18238@merlins.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, greg@kroah.com
To: Marc MERLIN <marc@merlins.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:54406 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753770Ab1GFUKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 16:10:11 -0400
In-Reply-To: <20110706172538.GI18238@merlins.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 06 July 2011 19:25:38 Marc MERLIN wrote:
> Howdy netdev folks,
> 
> On Tue, Jul 05, 2011 at 08:35:19AM -0700, Greg KH wrote:
> > I looked at this and it seems they took a very old version of the driver
> > (from 2003) and somehow changed it to work for this device.  I can't
> > really tell what they changed unless I were to dig through the original
> > version.
> > 
> > I suggest you post your original message to the 
> > mailing list.  The network developers there should be able to help you
> > out as I can't at the moment due to real-work and travel.
> 
> Here are the details. If somehow their driver could be integrated in
> mainline by putting the relevant bits in the current driver, that would be
> fantastic :)
> (obviously it would have been better if they had done that themselves to
> start with, no idea why they didn't).
> 

Hi Marc,

I've taken a look at the driver you linked to and compared it to the
version that was closest at the time.

This is similar to the patch they must have had at some point. I would guess
that the answer is somewhere in there. It's quite different to the much
cleaner patch 933a27d39e "USB: asix - Add AX88178 support and many other
changes", which was merged later with a similar intention.

	Arnd

diff --git a/drivers/usb/net/usbnet.c b/drivers/usb/net/usbnet.c
index 4cbb408..3c1d0ee 100644
--- a/drivers/usb/net/usbnet.c
+++ b/drivers/usb/net/usbnet.c
@@ -739,11 +739,15 @@ static void ax8817x_mdio_write(struct net_device *netdev, int phy_id, int loc, i
 static int ax88172_link_reset(struct usbnet *dev)
 {
 	u16 lpa;
+	u16 adv;
+	u16 res;
 	u8 mode;
 
 	mode = AX_MEDIUM_TX_ABORT_ALLOW | AX_MEDIUM_FLOW_CONTROL_EN;
 	lpa = ax8817x_mdio_read(dev->net, dev->mii.phy_id, MII_LPA);
-	if (lpa & LPA_DUPLEX)
+	adv = ax8817x_mdio_read(dev->net, dev->mii.phy_id, MII_ADVERTISE);
+	res = mii_nway_result(lpa|adv);
+	if (res & LPA_DUPLEX)
 		mode |= AX_MEDIUM_FULL_DUPLEX;
 	ax8817x_write_cmd(dev, AX_CMD_WRITE_MEDIUM_MODE, mode, 0, 0, NULL);
 
@@ -816,7 +820,7 @@ static int ax8817x_get_eeprom(struct net_device *net,
 			eeprom->offset + i, 0, 2, &ebuf[i]) < 0)
 			return -EINVAL;
 	}
-	return 0;
+	return i * 2;
 }
 
 static void ax8817x_get_drvinfo (struct net_device *net,
@@ -960,6 +964,29 @@ static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
 		goto out2;
 
 	msleep(5);
+
+	/* Initialize MII structure */
+	dev->mii.dev = dev->net;
+	dev->mii.mdio_read = ax8817x_mdio_read;
+	dev->mii.mdio_write = ax8817x_mdio_write;
+	dev->mii.phy_id_mask = 0xff;
+	dev->mii.reg_num_mask = 0xff;
+
+	/* Get the PHY id */
+	if ((ret = ax8817x_read_cmd(dev, AX_CMD_READ_PHY_ID, 0, 0, 2, buf)) < 0) {
+		dbg("Error reading PHY ID: %02x", ret);
+		goto out2;
+	} else if (ret < 2) {
+		/* this should always return 2 bytes */
+		dbg("AX_CMD_READ_PHY_ID returned less than 2 bytes: ret=%02x",
+		    ret);
+		ret = -EIO;
+		goto out2;
+	}
+	dev->mii.phy_id = *((u8 *)buf + 1);
+
+	if (dev->mii.phy_id == 0x10)
+	{
 	if ((ret = ax8817x_write_cmd(dev, AX_CMD_SW_PHY_SELECT, 0x0001, 0, 0, buf)) < 0) {
 		dbg("Select PHY #1 failed: %d", ret);
 		goto out2;
@@ -984,6 +1011,21 @@ static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
 		dbg("Failed to set Internal/External PHY reset control: %d", ret);
 		goto out2;
 	}
+	}
+	else
+	{
+	if ((ret =
+	    ax8817x_write_cmd(dev, AX_CMD_SW_PHY_SELECT, 0x0000, 0, 0, buf)) < 0) {
+		dbg("Select PHY #1 failed: %d", ret);
+		goto out2;
+	}
+
+	if ((ret =
+	     ax8817x_write_cmd(dev, AX_CMD_SW_RESET, AX_SWRESET_IPPD | AX_SWRESET_PRL, 0, 0, buf)) < 0) {
+		dbg("Failed to power down internal PHY: %d", ret);
+		goto out2;
+	}
+	}
 
 	msleep(150);
 	if ((ret =
@@ -1006,6 +1048,8 @@ static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
 		goto out2;
 	}
 
+	if (dev->mii.phy_id == 0x10)
+	{
 	if (((ret =
 	      ax8817x_read_cmd(dev, AX_CMD_READ_MII_REG, 0x0010, 2, 2, buf)) < 0)
 	    || (*((u16 *)buf) != 0x003b)) {
@@ -1013,26 +1057,6 @@ static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
 		goto out2;
 	}
 
-	/* Initialize MII structure */
-	dev->mii.dev = dev->net;
-	dev->mii.mdio_read = ax8817x_mdio_read;
-	dev->mii.mdio_write = ax8817x_mdio_write;
-	dev->mii.phy_id_mask = 0xff;
-	dev->mii.reg_num_mask = 0xff;
-
-	/* Get the PHY id */
-	if ((ret = ax8817x_read_cmd(dev, AX_CMD_READ_PHY_ID, 0, 0, 2, buf)) < 0) {
-		dbg("Error reading PHY ID: %02x", ret);
-		goto out2;
-	} else if (ret < 2) {
-		/* this should always return 2 bytes */
-		dbg("AX_CMD_READ_PHY_ID returned less than 2 bytes: ret=%02x",
-		    ret);
-		ret = -EIO;
-		goto out2;
-	}
-	dev->mii.phy_id = *((u8 *)buf + 1);
-
 	if ((ret =
 	     ax8817x_write_cmd(dev, AX_CMD_SW_RESET, AX_SWRESET_PRL, 0, 0, buf)) < 0) {
 		dbg("Set external PHY reset pin level: %d", ret);
@@ -1045,14 +1069,14 @@ static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
 		goto out2;
 	}
 	msleep(150);
-
+	}
 
 	dev->net->set_multicast_list = ax8817x_set_multicast;
 	dev->net->ethtool_ops = &ax88772_ethtool_ops;
 
 	ax8817x_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
 	ax8817x_mdio_write(dev->net, dev->mii.phy_id, MII_ADVERTISE,
-			ADVERTISE_ALL | ADVERTISE_CSMA);
+			ADVERTISE_ALL | ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP);
 	mii_nway_restart(&dev->mii);
 
 	if ((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_MEDIUM_MODE, AX88772_MEDIUM_DEFAULT, 0, 0, buf)) < 0) {
@@ -1060,7 +1084,7 @@ static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
 		goto out2;
 	}
 
-	if ((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_IPG0, AX88772_IPG0_DEFAULT | AX88772_IPG1_DEFAULT,AX88772_IPG2_DEFAULT, 0, buf)) < 0) {
+	if ((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_IPG0, AX88772_IPG0_DEFAULT | (AX88772_IPG1_DEFAULT << 8), AX88772_IPG2_DEFAULT, 0, buf)) < 0) {
 		dbg("Write IPG,IPG1,IPG2 failed: %d", ret);
 		goto out2;
 	}
@@ -1088,6 +1112,663 @@ out1:
 	return ret;
 }
 
+static int mediacheck(struct usbnet *dev)
+{
+	int ret,fullduplex;
+	u16 phylinkstatus1, phylinkstatus2, data16, tempshort = 0;
+	struct ax8817x_data *ax17xdataptr = (struct ax8817x_data *)&dev->data;
+	struct ax88178_data *ax178dataptr = (struct ax88178_data *)ax17xdataptr->ax178dataptr;
+
+
+	if ((ret =ax8817x_read_cmd(dev,AX_CMD_READ_MII_REG,dev->mii.phy_id,
+		GMII_PHY_ANLPAR, REG_LENGTH, &data16)) < 0) {
+		dbg("error on reading MII register 5 failed: %02x", ret);
+		return ret;   //
+	}
+	phylinkstatus1 = le16_to_cpu(data16);
+
+	if ((ret =ax8817x_read_cmd(dev,AX_CMD_READ_MII_REG,dev->mii.phy_id, GMII_PHY_1000BT_STATUS,
+		REG_LENGTH, &data16)) < 0) {
+		dbg("error on reading MII register 0x0a failed: %02x", ret);
+		return ret;   //
+	}
+	phylinkstatus2 = le16_to_cpu(data16);
+
+	if(ax178dataptr->PhyMode == PHY_MODE_MARVELL){ //1st generation Marvel PHY
+		if(ax178dataptr->LedMode == 1){
+			if ((ret = ax8817x_read_cmd(dev,AX_CMD_READ_MII_REG,dev->mii.phy_id, MARVELL_MANUAL_LED,
+				REG_LENGTH, &data16)) < 0) {
+				dbg("error on reading MII register 0x19 failed: %02x", ret);
+				return ret;   //
+			}
+			tempshort = le16_to_cpu(data16);
+			tempshort &=0xfc0f;
+		}
+	}
+
+	fullduplex=1;
+	if(phylinkstatus2 & (GMII_1000_AUX_STATUS_FD_CAPABLE|GMII_1000_AUX_STATUS_HD_CAPABLE)){  /* 1000BT full duplex */
+		ax178dataptr->MediaLink =
+			MEDIUM_GIGA_MODE|MEDIUM_FULL_DUPLEX_MODE|MEDIUM_ENABLE_125MHZ|MEDIUM_ENABLE_RECEIVE;
+			if(ax178dataptr->PhyMode == PHY_MODE_MARVELL){
+				if(ax178dataptr->LedMode == 1){
+					tempshort|=0x3e0;
+				}
+			}
+	}else if(phylinkstatus1 & GMII_ANLPAR_100TXFD){  /* 100BT full duplex */
+		ax178dataptr->MediaLink=MEDIUM_FULL_DUPLEX_MODE|MEDIUM_ENABLE_RECEIVE|MEDIUM_MII_100M_MODE;
+			if(ax178dataptr->PhyMode == PHY_MODE_MARVELL){
+				if(ax178dataptr->LedMode == 1){
+					tempshort|=0x3b0;
+				}
+			}
+	}else if(phylinkstatus1 & GMII_ANLPAR_100TX){   /* 100BT half duplex */
+		ax178dataptr->MediaLink=(MEDIUM_ENABLE_RECEIVE|MEDIUM_MII_100M_MODE);
+		fullduplex=0;
+			if(ax178dataptr->PhyMode == PHY_MODE_MARVELL){
+				if(ax178dataptr->LedMode == 1){
+					tempshort|=0x3b0;
+				}
+		}
+	}else if(phylinkstatus1 & GMII_ANLPAR_10TFD){	/* 10 full duplex */
+		ax178dataptr->MediaLink = (MEDIUM_FULL_DUPLEX_MODE|MEDIUM_ENABLE_RECEIVE);
+		if(ax178dataptr->PhyMode == PHY_MODE_MARVELL){
+			if(ax178dataptr->LedMode == 1){
+				tempshort|=0x02f0;
+			}
+		}
+	}else{
+		/* 10 half duplex*/
+		ax178dataptr->MediaLink = MEDIUM_ENABLE_RECEIVE;
+		fullduplex=0;
+		if(ax178dataptr->PhyMode == PHY_MODE_MARVELL){
+			if(ax178dataptr->LedMode == 1){
+				tempshort|=0x02f0;
+			}
+		}
+	}
+
+	if(ax178dataptr->PhyMode == PHY_MODE_MARVELL){
+		if(ax178dataptr->LedMode == 1){
+			data16 = le16_to_cpu(tempshort);
+		     if ( (ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_MII_REG, (u8)dev->mii.phy_id,
+				 MARVELL_MANUAL_LED, REG_LENGTH, &data16)) < 0){
+			     dbg("error on writing MII register 0x19 failed: %02x", ret);
+			     return ret;
+		     }
+		}
+	}
+	ax178dataptr->MediaLink |= 0x0004;
+	if(ax178dataptr->UseRgmii != 0)
+		ax178dataptr->MediaLink |= 0x0008;
+	if(fullduplex){
+		ax178dataptr->MediaLink |= 0x0020;  //ebable tx flow control as default;
+		ax178dataptr->MediaLink |= 0x0010;  //ebable rx flow control as default;
+	}
+
+	return 0;
+}
+
+static int marevell_init(struct usbnet *dev)
+{
+	struct ax8817x_data *ax17xdataptr = (struct ax8817x_data *)&dev->data;
+	struct ax88178_data *ax178dataptr = (struct ax88178_data *)ax17xdataptr->ax178dataptr;
+	u16 tmp,phyreg,PhyPatch,data16;
+	int ret;
+	void *buf;
+	u8 PhyID = (u8)ax178dataptr->PhyID;
+
+	buf = kmalloc(ETH_ALEN, GFP_KERNEL);
+	if(!buf)
+		return -ENOMEM;
+
+	if(ax178dataptr->UseGpio0)
+	{
+		if ((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_GPIOS,AXGPIOS_GPO0EN |AXGPIOS_RSE,0, 0,buf)) < 0){
+			dbg("write GPIO failed: %d", ret);
+			return ret;
+		}
+		msleep(25);
+		tmp = AXGPIOS_GPO2 | AXGPIOS_GPO2EN | AXGPIOS_GPO0EN;
+		if ((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_GPIOS, tmp, 0, 0, buf)) < 0){
+			dbg("write GPIO failed: %d", ret);
+			return ret;
+		}
+		msleep(25);
+		tmp = AXGPIOS_GPO2EN | AXGPIOS_GPO0EN;
+		if ((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_GPIOS, tmp, 0, 0, buf)) < 0){
+			dbg("write GPIO failed: %d", ret);
+			return ret;
+		}
+		msleep(245);
+		tmp = AXGPIOS_GPO2 | AXGPIOS_GPO2EN | AXGPIOS_GPO0EN;
+		if ((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_GPIOS, tmp, 0, 0, buf)) < 0){
+			dbg("write GPIO failed: %d", ret);
+			return ret;
+		}	
+		
+	}
+	else /* !UseGpio0 */
+	{
+		tmp = AXGPIOS_GPO1|AXGPIOS_GPO1EN | AXGPIOS_RSE;
+		if ((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_GPIOS, tmp, 0, 0, buf)) < 0){
+			dbg("write GPIO failed: %d", ret);
+			return ret;
+		}
+		if(ax178dataptr->LedMode != 1) //our new demo board
+		{
+			msleep(25);
+			tmp = AXGPIOS_GPO1|AXGPIOS_GPO1EN | AXGPIOS_GPO2EN | AXGPIOS_GPO2;
+			if ((ret =ax8817x_write_cmd(dev,AX_CMD_WRITE_GPIOS,tmp,0,0,buf)) < 0){
+				dbg("write GPIO failed: %d", ret);
+				return ret;
+			}
+			msleep(25);
+			tmp = AXGPIOS_GPO2EN | AXGPIOS_GPO1|AXGPIOS_GPO1EN;
+			if ((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_GPIOS, tmp, 0, 0, buf)) < 0){
+				dbg("write GPIO failed: %d", ret);
+				return ret;
+			}
+			msleep(245);
+			tmp = AXGPIOS_GPO1|AXGPIOS_GPO1EN|AXGPIOS_GPO2|AXGPIOS_GPO2EN;
+			if ((ret = ax8817x_write_cmd(dev,AX_CMD_WRITE_GPIOS,tmp,0,0,buf)) < 0){
+				dbg("write GPIO failed: %d", ret);
+				return ret;
+			}
+		}
+		else if(ax178dataptr->LedMode == 1)  //bufflo old card
+		{
+			msleep(350);
+			if ((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_GPIOS, AXGPIOS_GPO1EN, 0, 0, buf)) < 0){
+				dbg("write GPIO failed: %d", ret);
+				return ret;
+			}
+			msleep(350);
+			if ((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_GPIOS, AXGPIOS_GPO1|AXGPIOS_GPO1EN, 0, 0, buf)) < 0){
+				dbg("write GPIO failed: %d", ret);
+				return ret;
+			}
+		}		
+	}
+
+
+	if((ret = ax8817x_read_cmd(dev, AX_CMD_READ_MII_REG, PhyID, PHY_MARVELL_STATUS, REG_LENGTH, &data16)) < 0){
+	       dbg("read register reg 27 failed: %d", ret);
+	       return ret;
+	}    //read phy register
+
+	phyreg = le16_to_cpu(data16);
+	if(!(phyreg & MARVELL_STATUS_HWCFG)){
+		ax178dataptr->UseRgmii=1;
+		PhyPatch = MARVELL_CTRL_RXDELAY | MARVELL_CTRL_TXDELAY;
+		data16 = cpu_to_le16(PhyPatch);
+		if((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_MII_REG, PhyID, PHY_MARVELL_CTRL, REG_LENGTH, &data16)) < 0)
+			return ret;
+		ax178dataptr->MediaLink |= MEDIUM_ENABLE_125MHZ;
+	}
+
+	if(ax178dataptr->LedMode == 1){
+		if((ret = ax8817x_read_cmd(dev,AX_CMD_READ_MII_REG, PhyID, MARVELL_LED_CTRL, REG_LENGTH, &data16))< 0)
+			return ret;
+		phyreg = le16_to_cpu(data16);
+		phyreg &= 0xf8ff;
+		phyreg |= (1+0x100);
+
+		data16 = le16_to_cpu(phyreg);
+		if((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_MII_REG, PhyID, MARVELL_LED_CTRL, REG_LENGTH,&data16))< 0)
+			return ret;
+		if((ret = ax8817x_read_cmd(dev,AX_CMD_READ_MII_REG, PhyID, MARVELL_LED_CTRL, REG_LENGTH, &data16))< 0)
+			return ret;
+		phyreg = le16_to_cpu(data16);
+		phyreg &=0xfc0f;
+	} else if(ax178dataptr->LedMode == 2){
+
+		if((ret = ax8817x_read_cmd(dev,AX_CMD_READ_MII_REG, PhyID, MARVELL_LED_CTRL, REG_LENGTH, &data16))< 0)
+			return ret;
+
+		phyreg = le16_to_cpu(data16);
+		phyreg &= 0xf886;
+		phyreg |= (1+0x10+0x300);
+		data16 = cpu_to_le16(phyreg);
+		if((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_MII_REG, PhyID, MARVELL_LED_CTRL, REG_LENGTH,&data16))< 0)
+			return ret;
+
+	}else if(ax178dataptr->LedMode == 5){
+		if((ret = ax8817x_read_cmd(dev,AX_CMD_READ_MII_REG, PhyID, MARVELL_LED_CTRL, REG_LENGTH, &data16))< 0)
+			return ret;
+		phyreg = le16_to_cpu(data16);
+		phyreg &= 0xf8be;
+		phyreg |= (1+0x40+0x300);
+		data16 = cpu_to_le16(phyreg);
+		if((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_MII_REG, PhyID, MARVELL_LED_CTRL, REG_LENGTH,&data16))< 0)
+			return ret;
+	}
+	
+	ax178dataptr->phyreg = phyreg;
+	return 0;
+}
+
+static int cicada_init(struct usbnet *dev)
+{
+
+	struct ax8817x_data *ax17xdataptr = (struct ax8817x_data *)&dev->data;
+	struct ax88178_data *ax178dataptr = (struct ax88178_data *)ax17xdataptr->ax178dataptr;
+	u16 tmp, phyreg, i, data16;
+	int ret;
+	void *buf;
+	u8 PhyID = (u8)ax178dataptr->PhyID;
+
+	buf = kmalloc(ETH_ALEN, GFP_KERNEL);
+	if(!buf)
+		return -ENOMEM;
+
+	if(ax178dataptr->UseGpio0)
+	{
+		if ((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_GPIOS,AXGPIOS_GPO0 | AXGPIOS_GPO0EN | AXGPIOS_RSE,0, 0,buf)) < 0){
+			dbg("write GPIO failed: %d", ret);
+			return ret;
+		}
+	}
+	else
+	{
+		tmp = AXGPIOS_GPO1|AXGPIOS_GPO1EN | AXGPIOS_RSE;
+		if ((ret =ax8817x_write_cmd(dev, AX_CMD_WRITE_GPIOS,tmp,0,0,buf)) < 0){
+			dbg("write GPIO failed: %d", ret);
+			return ret;
+		}
+		if(ax178dataptr->LedMode!= 1) //our new demo board
+		{
+			msleep(25);
+			tmp = AXGPIOS_GPO1|AXGPIOS_GPO1EN | AXGPIOS_GPO2EN | AXGPIOS_GPO2;
+			if ((ret =ax8817x_write_cmd(dev,AX_CMD_WRITE_GPIOS,tmp,0,0,buf)) < 0){
+				dbg("write GPIO failed: %d", ret);
+				return ret;
+			}
+			msleep(25);
+			tmp = AXGPIOS_GPO2EN | AXGPIOS_GPO1|AXGPIOS_GPO1EN;
+			if ((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_GPIOS, tmp, 0, 0, buf)) < 0){
+				dbg("write GPIO failed: %d", ret);
+				return ret;
+			}
+			msleep(245);
+			tmp = AXGPIOS_GPO1|AXGPIOS_GPO1EN|AXGPIOS_GPO2|AXGPIOS_GPO2EN;
+			if ((ret = ax8817x_write_cmd(dev,AX_CMD_WRITE_GPIOS,tmp,0,0,buf)) < 0){
+				dbg("write GPIO failed: %d", ret);
+				return ret;
+			}
+		}
+		else if(ax178dataptr->LedMode==1)  //bufflo old card
+		{
+			msleep(350);
+			if ((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_GPIOS, AXGPIOS_GPO1EN, 0, 0, buf)) < 0){
+				dbg("write GPIO failed: %d", ret);
+				return ret;
+			}
+			msleep(350);
+			if ((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_GPIOS, AXGPIOS_GPO1|AXGPIOS_GPO1EN, 0, 0, buf)) < 0){
+				dbg("write GPIO failed: %d", ret);
+				return ret;
+			}
+		}
+	}
+
+	if(ax178dataptr->PhyMode == PHY_MODE_CICADA_FAMILY){    //CICADA 1st version phy
+		ax178dataptr->UseRgmii=1;
+		ax178dataptr->MediaLink |= MEDIUM_ENABLE_125MHZ;// MEDIUM_ENABLE_125MHZ;
+
+		for (i = 0; i < sizeof(CICADA_FAMILY_HWINIT)/sizeof(CICADA_FAMILY_HWINIT[0]); i++) {
+			data16 = cpu_to_le16(CICADA_FAMILY_HWINIT[i].value);
+			ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_MII_REG, PhyID, CICADA_FAMILY_HWINIT[i].offset, REG_LENGTH, &data16);
+			if(ret < 0) return ret;
+		}
+	}
+	else if(ax178dataptr->PhyMode == PHY_MODE_CICADA_V2){
+		ax178dataptr->UseRgmii=1;
+		ax178dataptr->MediaLink |= MEDIUM_ENABLE_125MHZ;
+
+		for (i = 0; i < ( sizeof(CICADA_V2_HWINIT)/sizeof(CICADA_V2_HWINIT[0]) ); i++) {
+			data16 = cpu_to_le16(CICADA_V2_HWINIT[i].value);
+			ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_MII_REG, PhyID, CICADA_V2_HWINIT[i].offset, REG_LENGTH, &data16);
+			if(ret < 0) return ret;
+		}
+	}
+	else if(ax178dataptr->PhyMode == PHY_MODE_CICADA_V2_ASIX){
+		ax178dataptr->UseRgmii=1;
+		ax178dataptr->MediaLink |= MEDIUM_ENABLE_125MHZ;
+
+		for (i = 0; i < ( sizeof(CICADA_V2_ASIX_HWINIT)/sizeof(CICADA_V2_ASIX_HWINIT[0]) ); i++) {
+			data16 = cpu_to_le16(CICADA_V2_ASIX_HWINIT[i].value);
+			ret=ax8817x_write_cmd(dev, AX_CMD_WRITE_MII_REG, PhyID, CICADA_V2_ASIX_HWINIT[i].offset, REG_LENGTH, &data16);
+			if(ret < 0) return ret;
+		}
+	}
+
+	if(ax178dataptr->PhyMode == PHY_MODE_CICADA_FAMILY){
+		if(ax178dataptr->LedMode == 3){
+			if((ret = ax8817x_read_cmd(dev,AX_CMD_READ_MII_REG, PhyID, 27, 2, &data16))< 0)
+				return ret;
+			phyreg = le16_to_cpu(data16);
+			phyreg &= 0xfcff;
+			phyreg |= 0x0100;
+			data16 = cpu_to_le16(phyreg);
+			if((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_MII_REG, PhyID, 27,2,&data16))< 0)
+				return ret;
+		}
+	}
+	return 0;
+}
+
+static int agere_init(struct usbnet *dev)
+{
+	struct ax8817x_data *ax17xdataptr = (struct ax8817x_data *)&dev->data;
+	struct ax88178_data *ax178dataptr = (struct ax88178_data *)ax17xdataptr->ax178dataptr;
+	u16 tmp, phyreg, i;
+	int ret;
+	void *buf;
+	u8 PhyID = (u8)ax178dataptr->PhyID;
+
+	buf = kmalloc(ETH_ALEN, GFP_KERNEL);
+	if(!buf)
+		return -ENOMEM;
+
+	if ((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_GPIOS,AXGPIOS_GPO1|AXGPIOS_GPO1EN | AXGPIOS_RSE,0,0,buf)) < 0){
+		dbg("write GPIO failed: %d", ret);
+		return ret;
+	}
+	msleep(25);
+	if ((ret=ax8817x_write_cmd(dev,AX_CMD_WRITE_GPIOS,AXGPIOS_GPO1|AXGPIOS_GPO1EN
+		| AXGPIOS_GPO2EN | AXGPIOS_GPO2,0,0,buf)) < 0){
+		dbg("write GPIO failed: %d", ret);
+		return ret;
+	}
+	msleep(25);
+	if ((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_GPIOS, AXGPIOS_GPO2EN | AXGPIOS_GPO1
+		| AXGPIOS_GPO1EN, 0, 0, buf)) < 0){
+		dbg("write GPIO failed: %d", ret);
+		return ret;
+	}
+	msleep(245);
+	if ((ret=ax8817x_write_cmd(dev,AX_CMD_WRITE_GPIOS,AXGPIOS_GPO1|AXGPIOS_GPO1EN|AXGPIOS_GPO2
+		| AXGPIOS_GPO2EN,0,0,buf)) < 0){
+		dbg("write GPIO failed: %d", ret);
+		return ret;
+	}
+	
+	ax178dataptr->UseRgmii=1;
+	ax178dataptr->MediaLink |= MEDIUM_ENABLE_125MHZ;
+
+	phyreg = cpu_to_le16(BMCR_RESET);
+	if ((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_MII_REG, PhyID, MII_BMCR, REG_LENGTH, &phyreg)) < 0) {
+		dbg("Failed to write MII reg - MII_BMCR: %02x", ret);
+		return ret;
+	} //software reset
+
+	while (1)
+	{
+		phyreg = cpu_to_le16(0x1001);
+		ax8817x_write_cmd(dev, AX_CMD_WRITE_MII_REG, PhyID, 21, REG_LENGTH, &phyreg);
+		msleep(10);
+		ax8817x_read_cmd(dev, AX_CMD_READ_MII_REG, PhyID, 21, REG_LENGTH, &phyreg);
+		tmp = le16_to_cpu(phyreg);
+		if ((tmp & 0xf00f) == 0x1001)
+			break;
+		msleep(10);
+	}
+
+	if (ax178dataptr->LedMode == 4)
+	{
+		phyreg = cpu_to_le16(0x7417);
+		ax8817x_write_cmd(dev, AX_CMD_WRITE_MII_REG, PhyID, 28, 2, &phyreg);
+	}
+	else if (ax178dataptr->LedMode == 9)
+	{
+		phyreg = cpu_to_le16(0x7a10);
+		ax8817x_write_cmd(dev, AX_CMD_WRITE_MII_REG, PhyID, 28, 2, &phyreg);
+	}
+	else if (ax178dataptr->LedMode == 10)
+	{
+		phyreg = cpu_to_le16(0x7a13);
+		ax8817x_write_cmd(dev, AX_CMD_WRITE_MII_REG, PhyID, 28, 2, &phyreg);
+	}
+
+	for (i = 0; i < ( sizeof(AGERE_FAMILY_HWINIT)/sizeof(AGERE_FAMILY_HWINIT[0]) ); i++) {
+		phyreg = cpu_to_le16(AGERE_FAMILY_HWINIT[i].value);
+		ret=ax8817x_write_cmd(dev,AX_CMD_WRITE_MII_REG,PhyID,AGERE_FAMILY_HWINIT[i].offset,REG_LENGTH,&phyreg);
+		if(ret < 0) return ret;
+	}
+
+	return 0;
+}
+
+static int phy_init(struct usbnet *dev)
+{
+	struct ax8817x_data *ax17xdataptr = (struct ax8817x_data *)&dev->data;
+	struct ax88178_data *ax178dataptr = (struct ax88178_data *)ax17xdataptr->ax178dataptr;
+	int ret;
+	u16 tmp, data16, phyanar, phyauxctrl, phyctrl, phyreg = 0;
+	void *buf;
+
+	buf = kmalloc(ETH_ALEN, GFP_KERNEL);
+	if(!buf)
+		return -ENOMEM;
+
+	if(ax178dataptr->PhyMode == PHY_MODE_MARVELL) {
+		if((ret = marevell_init(dev)) < 0) return ret;
+	}else if(ax178dataptr->PhyMode == PHY_MODE_CICADA_FAMILY) {
+		if((ret = cicada_init(dev)) < 0) return ret;
+	}else if(ax178dataptr->PhyMode == PHY_MODE_CICADA_V1) {
+		if((ret = cicada_init(dev)) < 0) return ret;
+	}else if(ax178dataptr->PhyMode == PHY_MODE_CICADA_V2_ASIX) {
+		if((ret = cicada_init(dev)) < 0) return ret;
+	}else if(ax178dataptr->PhyMode == PHY_MODE_AGERE_FAMILY) {
+		if((ret = agere_init(dev)) < 0) return ret;
+	}
+
+	if(ax178dataptr->PhyMode != PHY_MODE_AGERE_FAMILY)
+	{
+		/* reset phy */
+		data16 = cpu_to_le16(BMCR_RESET);
+		if ((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_MII_REG, dev->mii.phy_id,
+			MII_BMCR, REG_LENGTH, (void *)(&data16))) < 0) {
+			dbg("Failed to write MII reg - MII_BMCR: %02x", ret);
+			return ret;
+		}
+	}
+
+	if  ((ret = ax8817x_read_cmd(dev,AX_CMD_READ_MII_REG, dev->mii.phy_id , MII_BMCR,
+		REG_LENGTH, &data16)) < 0) {
+		dbg("error on read MII reg - MII_BMCR: %02x", ret);
+		return ret;   //could be 0x0000
+	}
+
+	phyctrl = le16_to_cpu(data16);
+	tmp=phyctrl;
+	phyctrl &=~(BMCR_PDOWN|BMCR_ISOLATE);
+	if(phyctrl != tmp){
+		data16 = cpu_to_le16(phyctrl);
+		if ((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_MII_REG, dev->mii.phy_id, MII_BMCR,
+			REG_LENGTH, &data16)) < 0) {
+			dbg("Failed to write MII reg - MII_BMCR: %02x", ret);
+			return ret;
+		}
+
+	}
+
+	phyctrl&= ~BMCR_ISOLATE;
+	phyanar=1+(0x0400|ADVERTISE_100FULL|ADVERTISE_100HALF|ADVERTISE_10FULL|ADVERTISE_10HALF);
+	phyauxctrl=0x0200; //1000M and full duplex
+
+	data16 = cpu_to_le16(phyanar);
+	if((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_MII_REG,dev->mii.phy_id,
+		GMII_PHY_ANAR,REG_LENGTH,&data16))< 0) return ret;
+
+	data16 = cpu_to_le16(phyauxctrl);
+	if((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_MII_REG,dev->mii.phy_id,
+		GMII_PHY_1000BT_CONTROL,REG_LENGTH,&data16))< 0) return ret;
+
+	phyctrl |= (BMCR_ANENABLE|BMCR_ANRESTART);
+	data16 = cpu_to_le16(phyctrl);
+	if((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_MII_REG,dev->mii.phy_id,
+		GMII_PHY_CONTROL,REG_LENGTH,&data16))< 0) return ret;
+
+	if(ax178dataptr->PhyMode == PHY_MODE_MARVELL){
+		if(ax178dataptr->LedMode==1) {
+			phyreg |= 0x3f0;
+			data16 = cpu_to_le16(phyreg);
+			if((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_MII_REG,dev->mii.phy_id,
+				25,REG_LENGTH,&phyreg))< 0) return ret;
+		}
+	}
+
+	msleep(3000);
+
+	if ((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_IPG0,
+			(AX88772_IPG0_DEFAULT | (AX88772_IPG1_DEFAULT << 8)),
+			0x000e, 0, buf)) < 0) {
+		dbg("write IPG IPG1 IPG2 reg failed: %d", ret);
+		return ret;
+	}
+	if ((ret = ax8817x_write_cmd(dev, AX_CMD_SET_HW_MII, 0, 0, 0, buf)) < 0) {
+		dbg("disable PHY access failed: %d", ret);
+		return ret;
+	}
+
+	if ((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL,
+			(AX_RX_CTL_MFB | AX_RX_CTL_START | AX_RX_CTL_AB),
+		0, 0, buf)) < 0) {
+		dbg("write RX ctrl reg failed: %d", ret);
+		return ret;
+	}
+
+	return 0;	
+
+}
+
+static int ax88178_bind(struct usbnet *dev, struct usb_interface *intf)
+{
+	int ret;
+	void *buf;
+	u16 EepromData,PhyID, temp16;
+	struct ax8817x_data *ax17xdataptr = (struct ax8817x_data *)&dev->data;
+	struct ax88178_data *ax178dataptr;
+
+	get_endpoints(dev,intf);
+
+	buf = kmalloc(6, GFP_KERNEL);
+	if(!buf) {
+		dbg ("Cannot allocate memory for buffer");
+		return -ENOMEM;
+	}
+
+	/* allocate 178 data */
+	if (!(ax178dataptr = kmalloc (sizeof(struct ax88178_data), GFP_KERNEL))) {
+		dbg ("Cannot allocate memory for AX88178 data");
+		return -ENOMEM;
+	}
+	memset (ax178dataptr, 0, sizeof(struct ax88178_data));
+	ax17xdataptr->ax178dataptr = ax178dataptr;
+	/* end of allocate 178 data */
+
+	if ((ret = ax8817x_write_cmd(dev, 0x22, 0x0000, 0, 0, buf)) < 0) {
+		dbg("write S/W reset failed: %d", ret);
+		return ret;
+	}
+	msleep(150);
+
+	if ((ret = ax8817x_write_cmd(dev, 0x20, 0x0048, 0, 0, buf)) < 0) {
+		dbg("write S/W reset failed: %d", ret);
+		return ret;
+	}
+	msleep(150);
+
+	if ((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL, 0x0000, 0, 0, buf)) < 0) {
+		dbg("send AX_CMD_WRITE_RX_CTL failed: %d", ret);
+		return ret;				//stop rcv
+	}
+
+	msleep(150);
+
+	/* Get the MAC address */
+	memset(buf, 0, ETH_ALEN);
+	if ((ret = ax8817x_read_cmd(dev, AX88772_CMD_READ_NODE_ID, 0, 0, ETH_ALEN, buf)) < 0) {
+		dbg("read AX_CMD_READ_NODE_ID failed: %d", ret);
+		return ret;
+	}
+	memcpy(dev->net->dev_addr, buf, ETH_ALEN);
+	/* End of get MAC address */
+
+
+	/* Get the EEPROM data*/
+	if ((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_EEPROM_EN, 0, 0, 0, buf)) < 0) {
+		dbg("enable SROM reading failed: %d", ret);
+		return ret;   // ???
+	}
+
+	if ((ret = ax8817x_read_cmd(dev, AX_CMD_READ_EEPROM,
+			0x0017, 0, 2, (void *)(&EepromData))) < 0) {
+		dbg("read SROM address 17h failed: %d", ret);
+		return ret;
+	}
+
+	ax178dataptr->EepromData = le16_to_cpu(EepromData);
+	if ((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_EEPROM_DIS, 0, 0, 0, buf)) < 0) {
+		dbg("disable SROM reading failed: %d", ret);
+		return ret; // ???
+	}
+	/* End of get EEPROM data */
+
+	/* Get PHY id */
+
+	if ((ret = ax8817x_write_cmd(dev, AX_CMD_SET_SW_MII, 0x0000, 0, 0, buf)) < 0) {
+		dbg("enable PHY reg. access capability: %d", ret);
+		return ret;				//enable Phy register access capability
+	}
+
+	if ((ret = ax8817x_read_cmd(dev, AX_CMD_READ_PHY_ID, 0, 0, REG_LENGTH, &temp16)) < 0) {
+		dbg("error on read AX_CMD_READ_PHY_ID: %02x", ret);
+		return ret;
+	} else if (ret < 2) {
+		/* this should always return 2 bytes */
+		dbg("AX_CMD_READ_PHY_ID returned less than 2 bytes: ret=%02x", ret);
+		return -EIO;
+	}
+
+	PhyID = le16_to_cpu(temp16);
+	PhyID = (PhyID >> 8) & PHY_ID_MASK;
+	ax178dataptr->PhyID = PhyID;
+	/* End of get PHY id */
+
+	/* Initialize MII structure */
+	dev->mii.dev = dev->net;
+	dev->mii.mdio_read = ax8817x_mdio_read;
+	dev->mii.mdio_write = ax8817x_mdio_write;
+	dev->mii.phy_id_mask = 0x3f;
+	dev->mii.reg_num_mask = 0x1f;
+	dev->mii.phy_id = (u8)ax178dataptr->PhyID;
+
+	if (ax178dataptr->EepromData == 0xffff)
+	{
+		ax178dataptr->PhyMode  = PHY_MODE_MARVELL;
+		ax178dataptr->LedMode  = 0;
+		ax178dataptr->UseGpio0 = 1; //True
+	}
+	else
+	{
+		ax178dataptr->PhyMode  = (u8)(ax178dataptr->EepromData & EEPROMMASK);
+		ax178dataptr->LedMode  = (u8)(ax178dataptr->EepromData>>8);	
+		if(ax178dataptr->EepromData & 0x80) {
+			ax178dataptr->UseGpio0=0; //MARVEL se and other
+		}
+		else {
+			ax178dataptr->UseGpio0=1; //cameo
+		}
+	}
+
+	if ((ret = phy_init(dev)) < 0)	return ret;
+
+	return 0;
+}
+
 static int ax88772_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 {
 	u32 *header;
@@ -1199,6 +1880,70 @@ static int ax88772_link_reset(struct usbnet *dev)
 	return 0;
 }
 
+static int set_media(struct usbnet *dev)
+{
+	int	ret;
+	void	*buf;
+	struct ax8817x_data *ax17xdataptr = (struct ax8817x_data *)&dev->data;
+	struct ax88178_data *ax178dataptr = (struct ax88178_data *)ax17xdataptr->ax178dataptr;
+
+	buf = kmalloc(ETH_ALEN, GFP_KERNEL);
+	if(!buf)
+		return -ENOMEM;
+
+	if ((ret = ax8817x_write_cmd(dev, AX_CMD_SET_SW_MII, 0x0000, 0, 0, buf)) < 0) {
+		dbg("enable PHY reg. access capability: %d", ret);
+		return ret;				//enable Phy register access capability
+	}
+
+	mediacheck(dev);
+
+	if ((ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_MEDIUM_MODE,
+			ax178dataptr->MediaLink, 0, 0, buf)) < 0) {
+		dbg("write mode medium reg failed: %d", ret);
+		return ret;
+	}
+
+	if ((ret = ax8817x_write_cmd(dev, AX_CMD_SET_HW_MII, 0, 0, 0, buf)) < 0) {
+		dbg("disable PHY access failed: %d", ret);
+		return ret;
+	}
+
+	dev->net->set_multicast_list = ax8817x_set_multicast;
+	dev->net->ethtool_ops = &ax8817x_ethtool_ops;
+	return 0;
+}
+
+static int ax88178_link_reset(struct usbnet *dev)
+{
+	int ret;
+
+	if ((ret = set_media(dev)) < 0)	return ret;
+	return 0;
+}
+
+static const struct driver_info ax88178_info = {
+	.description = "ASIX AX88178 USB 2.0 Ethernet",
+	.bind = ax88178_bind,
+	.status = ax8817x_status,
+	.link_reset = ax88178_link_reset,
+	.flags =  FLAG_ETHER|FLAG_FRAMING_AX,
+	.rx_fixup =	ax88772_rx_fixup,
+	.tx_fixup =	ax88772_tx_fixup,
+	.data = 0x00130103,  //useless here
+};
+
+static const struct driver_info belkin178_info = {
+	.description = "Belkin Gigabit USB 2.0 Network Adapter",
+	.bind = ax88178_bind,
+	.status = ax8817x_status,
+	.link_reset = ax88178_link_reset,
+	.flags =  FLAG_ETHER|FLAG_FRAMING_AX,
+	.rx_fixup =	ax88772_rx_fixup,
+	.tx_fixup =	ax88772_tx_fixup,
+	.data = 0x00130103,  //useless here
+};
+
 static const struct driver_info ax8817x_info = {
 	.description = "ASIX AX8817x USB 2.0 Ethernet",
 	.bind = ax8817x_bind,
@@ -1251,6 +1996,18 @@ static const struct driver_info ax88772_info = {
 	.data = 0x00130103,
 };
 
+static const struct driver_info dlink_dub_e100b_info = {
+	.description = "D-Link DUB-E100 USB 2.0 Fast Ethernet Adapter",
+	.bind = ax88772_bind,
+	.status = ax8817x_status,
+	.link_reset = ax88772_link_reset,
+	.reset = ax88772_link_reset,
+	.flags = FLAG_ETHER | FLAG_FRAMING_AX,
+	.rx_fixup = ax88772_rx_fixup,
+	.tx_fixup = ax88772_tx_fixup,
+	.data = 0x00130103,
+};
+
 #endif /* CONFIG_USB_AX8817X */
 
 

