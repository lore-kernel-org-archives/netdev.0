From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH] Fix phy_read/write redefinition errors in ucc_geth_phy.c
Date: Fri, 5 Jan 2007 08:58:45 -0600
Message-ID: <27C6D947-A741-48A5-8746-B724B9BED9C7@kernel.crashing.org>
References: <11660513361799-git-send-email-timur@freescale.com> <11660513372040-git-send-email-timur@freescale.com> <375EF617-A51E-455A-9575-AF4E561B91BC@kernel.crashing.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nommos.sslcatacombnetworking.com ([67.18.224.114]:25632 "EHLO
	nommos.sslcatacombnetworking.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161123AbXAEO6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jan 2007 09:58:08 -0500
In-Reply-To: <375EF617-A51E-455A-9575-AF4E561B91BC@kernel.crashing.org>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff,

Friendly reminder that this should go in for 2.6.20

- k

On Dec 18, 2006, at 10:24 AM, Kumar Gala wrote:

> Jeff,
>
> Can you pickup this patch for 2.6.20.  It addresses a name conflict  
> issue with the phylib and the phy handling in the ucc driver.
>
> thanks
>
> - k
>
> On Dec 13, 2006, at 5:08 PM, timur@freescale.com wrote:
>
>> From: Timur Tabi <timur@freescale.com>
>>
>> The local versions of phy_read() and phy_write() in ucc_geth_phy.c  
>> conflict
>> with the prototypes in include/linux/phy.h, so this patch renames  
>> them,
>> moves them to the top of the file (while eliminating the redundant  
>> prototype),
>> and makes them static.
>>
>> Signed-off-by: Timur Tabi <timur@freescale.com>
>> Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
>>
>> ---
>>  drivers/net/ucc_geth_phy.c |  134 +++++++++++++++++++++ 
>> +----------------------
>>  1 files changed, 66 insertions(+), 68 deletions(-)
>>
>> diff --git a/drivers/net/ucc_geth_phy.c b/drivers/net/ucc_geth_phy.c
>> index 5360ec0..3c86592 100644
>> --- a/drivers/net/ucc_geth_phy.c
>> +++ b/drivers/net/ucc_geth_phy.c
>> @@ -68,8 +68,31 @@ static int gbit_config_aneg(struct ugeth
>>  static int genmii_config_aneg(struct ugeth_mii_info *mii_info);
>>  static int genmii_update_link(struct ugeth_mii_info *mii_info);
>>  static int genmii_read_status(struct ugeth_mii_info *mii_info);
>> -u16 phy_read(struct ugeth_mii_info *mii_info, u16 regnum);
>> -void phy_write(struct ugeth_mii_info *mii_info, u16 regnum, u16  
>> val);
>> +
>> +static u16 ucc_geth_phy_read(struct ugeth_mii_info *mii_info, u16  
>> regnum)
>> +{
>> +	u16 retval;
>> +	unsigned long flags;
>> +
>> +	ugphy_vdbg("%s: IN", __FUNCTION__);
>> +
>> +	spin_lock_irqsave(&mii_info->mdio_lock, flags);
>> +	retval = mii_info->mdio_read(mii_info->dev, mii_info->mii_id,  
>> regnum);
>> +	spin_unlock_irqrestore(&mii_info->mdio_lock, flags);
>> +
>> +	return retval;
>> +}
>> +
>> +static void ucc_geth_phy_write(struct ugeth_mii_info *mii_info,  
>> u16 regnum, u16 val)
>> +{
>> +	unsigned long flags;
>> +
>> +	ugphy_vdbg("%s: IN", __FUNCTION__);
>> +
>> +	spin_lock_irqsave(&mii_info->mdio_lock, flags);
>> +	mii_info->mdio_write(mii_info->dev, mii_info->mii_id, regnum, val);
>> +	spin_unlock_irqrestore(&mii_info->mdio_lock, flags);
>> +}
>>
>>  /* Write value to the PHY for this device to the register at  
>> regnum, */
>>  /* waiting until the write is done before it returns.  All PHY */
>> @@ -184,7 +207,7 @@ static void config_genmii_advert(struct
>>  	advertise = mii_info->advertising;
>>
>>  	/* Setup standard advertisement */
>> -	adv = phy_read(mii_info, MII_ADVERTISE);
>> +	adv = ucc_geth_phy_read(mii_info, MII_ADVERTISE);
>>  	adv &= ~(ADVERTISE_ALL | ADVERTISE_100BASE4);
>>  	if (advertise & ADVERTISED_10baseT_Half)
>>  		adv |= ADVERTISE_10HALF;
>> @@ -194,7 +217,7 @@ static void config_genmii_advert(struct
>>  		adv |= ADVERTISE_100HALF;
>>  	if (advertise & ADVERTISED_100baseT_Full)
>>  		adv |= ADVERTISE_100FULL;
>> -	phy_write(mii_info, MII_ADVERTISE, adv);
>> +	ucc_geth_phy_write(mii_info, MII_ADVERTISE, adv);
>>  }
>>
>>  static void genmii_setup_forced(struct ugeth_mii_info *mii_info)
>> @@ -204,7 +227,7 @@ static void genmii_setup_forced(struct u
>>
>>  	ugphy_vdbg("%s: IN", __FUNCTION__);
>>
>> -	ctrl = phy_read(mii_info, MII_BMCR);
>> +	ctrl = ucc_geth_phy_read(mii_info, MII_BMCR);
>>
>>  	ctrl &=
>>  	    ~(BMCR_FULLDPLX | BMCR_SPEED100 | BMCR_SPEED1000 |  
>> BMCR_ANENABLE);
>> @@ -234,7 +257,7 @@ static void genmii_setup_forced(struct u
>>  		break;
>>  	}
>>
>> -	phy_write(mii_info, MII_BMCR, ctrl);
>> +	ucc_geth_phy_write(mii_info, MII_BMCR, ctrl);
>>  }
>>
>>  /* Enable and Restart Autonegotiation */
>> @@ -244,9 +267,9 @@ static void genmii_restart_aneg(struct u
>>
>>  	ugphy_vdbg("%s: IN", __FUNCTION__);
>>
>> -	ctl = phy_read(mii_info, MII_BMCR);
>> +	ctl = ucc_geth_phy_read(mii_info, MII_BMCR);
>>  	ctl |= (BMCR_ANENABLE | BMCR_ANRESTART);
>> -	phy_write(mii_info, MII_BMCR, ctl);
>> +	ucc_geth_phy_write(mii_info, MII_BMCR, ctl);
>>  }
>>
>>  static int gbit_config_aneg(struct ugeth_mii_info *mii_info)
>> @@ -261,14 +284,14 @@ static int gbit_config_aneg(struct ugeth
>>  		config_genmii_advert(mii_info);
>>  		advertise = mii_info->advertising;
>>
>> -		adv = phy_read(mii_info, MII_1000BASETCONTROL);
>> +		adv = ucc_geth_phy_read(mii_info, MII_1000BASETCONTROL);
>>  		adv &= ~(MII_1000BASETCONTROL_FULLDUPLEXCAP |
>>  			 MII_1000BASETCONTROL_HALFDUPLEXCAP);
>>  		if (advertise & SUPPORTED_1000baseT_Half)
>>  			adv |= MII_1000BASETCONTROL_HALFDUPLEXCAP;
>>  		if (advertise & SUPPORTED_1000baseT_Full)
>>  			adv |= MII_1000BASETCONTROL_FULLDUPLEXCAP;
>> -		phy_write(mii_info, MII_1000BASETCONTROL, adv);
>> +		ucc_geth_phy_write(mii_info, MII_1000BASETCONTROL, adv);
>>
>>  		/* Start/Restart aneg */
>>  		genmii_restart_aneg(mii_info);
>> @@ -298,10 +321,10 @@ static int genmii_update_link(struct uge
>>  	ugphy_vdbg("%s: IN", __FUNCTION__);
>>
>>  	/* Do a fake read */
>> -	phy_read(mii_info, MII_BMSR);
>> +	ucc_geth_phy_read(mii_info, MII_BMSR);
>>
>>  	/* Read link and autonegotiation status */
>> -	status = phy_read(mii_info, MII_BMSR);
>> +	status = ucc_geth_phy_read(mii_info, MII_BMSR);
>>  	if ((status & BMSR_LSTATUS) == 0)
>>  		mii_info->link = 0;
>>  	else
>> @@ -329,7 +352,7 @@ static int genmii_read_status(struct uge
>>  		return err;
>>
>>  	if (mii_info->autoneg) {
>> -		status = phy_read(mii_info, MII_LPA);
>> +		status = ucc_geth_phy_read(mii_info, MII_LPA);
>>
>>  		if (status & (LPA_10FULL | LPA_100FULL))
>>  			mii_info->duplex = DUPLEX_FULL;
>> @@ -352,9 +375,9 @@ static int marvell_init(struct ugeth_mii
>>  {
>>  	ugphy_vdbg("%s: IN", __FUNCTION__);
>>
>> -	phy_write(mii_info, 0x14, 0x0cd2);
>> -	phy_write(mii_info, MII_BMCR,
>> -		  phy_read(mii_info, MII_BMCR) | BMCR_RESET);
>> +	ucc_geth_phy_write(mii_info, 0x14, 0x0cd2);
>> +	ucc_geth_phy_write(mii_info, MII_BMCR,
>> +		  ucc_geth_phy_read(mii_info, MII_BMCR) | BMCR_RESET);
>>  	msleep(4000);
>>
>>  	return 0;
>> @@ -367,13 +390,13 @@ static int marvell_config_aneg(struct ug
>>  	/* The Marvell PHY has an errata which requires
>>  	 * that certain registers get written in order
>>  	 * to restart autonegotiation */
>> -	phy_write(mii_info, MII_BMCR, BMCR_RESET);
>> +	ucc_geth_phy_write(mii_info, MII_BMCR, BMCR_RESET);
>>
>> -	phy_write(mii_info, 0x1d, 0x1f);
>> -	phy_write(mii_info, 0x1e, 0x200c);
>> -	phy_write(mii_info, 0x1d, 0x5);
>> -	phy_write(mii_info, 0x1e, 0);
>> -	phy_write(mii_info, 0x1e, 0x100);
>> +	ucc_geth_phy_write(mii_info, 0x1d, 0x1f);
>> +	ucc_geth_phy_write(mii_info, 0x1e, 0x200c);
>> +	ucc_geth_phy_write(mii_info, 0x1d, 0x5);
>> +	ucc_geth_phy_write(mii_info, 0x1e, 0);
>> +	ucc_geth_phy_write(mii_info, 0x1e, 0x100);
>>
>>  	gbit_config_aneg(mii_info);
>>
>> @@ -398,7 +421,7 @@ static int marvell_read_status(struct ug
>>  	 * are as set */
>>  	if (mii_info->autoneg && mii_info->link) {
>>  		int speed;
>> -		status = phy_read(mii_info, MII_M1011_PHY_SPEC_STATUS);
>> +		status = ucc_geth_phy_read(mii_info, MII_M1011_PHY_SPEC_STATUS);
>>
>>  		/* Get the duplexity */
>>  		if (status & MII_M1011_PHY_SPEC_STATUS_FULLDUPLEX)
>> @@ -430,7 +453,7 @@ static int marvell_ack_interrupt(struct
>>  	ugphy_vdbg("%s: IN", __FUNCTION__);
>>
>>  	/* Clear the interrupts by reading the reg */
>> -	phy_read(mii_info, MII_M1011_IEVENT);
>> +	ucc_geth_phy_read(mii_info, MII_M1011_IEVENT);
>>
>>  	return 0;
>>  }
>> @@ -440,9 +463,9 @@ static int marvell_config_intr(struct ug
>>  	ugphy_vdbg("%s: IN", __FUNCTION__);
>>
>>  	if (mii_info->interrupts == MII_INTERRUPT_ENABLED)
>> -		phy_write(mii_info, MII_M1011_IMASK, MII_M1011_IMASK_INIT);
>> +		ucc_geth_phy_write(mii_info, MII_M1011_IMASK,  
>> MII_M1011_IMASK_INIT);
>>  	else
>> -		phy_write(mii_info, MII_M1011_IMASK, MII_M1011_IMASK_CLEAR);
>> +		ucc_geth_phy_write(mii_info, MII_M1011_IMASK,  
>> MII_M1011_IMASK_CLEAR);
>>
>>  	return 0;
>>  }
>> @@ -451,9 +474,9 @@ static int cis820x_init(struct ugeth_mii
>>  {
>>  	ugphy_vdbg("%s: IN", __FUNCTION__);
>>
>> -	phy_write(mii_info, MII_CIS8201_AUX_CONSTAT,
>> +	ucc_geth_phy_write(mii_info, MII_CIS8201_AUX_CONSTAT,
>>  		  MII_CIS8201_AUXCONSTAT_INIT);
>> -	phy_write(mii_info, MII_CIS8201_EXT_CON1,  
>> MII_CIS8201_EXTCON1_INIT);
>> +	ucc_geth_phy_write(mii_info, MII_CIS8201_EXT_CON1,  
>> MII_CIS8201_EXTCON1_INIT);
>>
>>  	return 0;
>>  }
>> @@ -477,7 +500,7 @@ static int cis820x_read_status(struct ug
>>  	if (mii_info->autoneg && mii_info->link) {
>>  		int speed;
>>
>> -		status = phy_read(mii_info, MII_CIS8201_AUX_CONSTAT);
>> +		status = ucc_geth_phy_read(mii_info, MII_CIS8201_AUX_CONSTAT);
>>  		if (status & MII_CIS8201_AUXCONSTAT_DUPLEX)
>>  			mii_info->duplex = DUPLEX_FULL;
>>  		else
>> @@ -505,7 +528,7 @@ static int cis820x_ack_interrupt(struct
>>  {
>>  	ugphy_vdbg("%s: IN", __FUNCTION__);
>>
>> -	phy_read(mii_info, MII_CIS8201_ISTAT);
>> +	ucc_geth_phy_read(mii_info, MII_CIS8201_ISTAT);
>>
>>  	return 0;
>>  }
>> @@ -515,9 +538,9 @@ static int cis820x_config_intr(struct ug
>>  	ugphy_vdbg("%s: IN", __FUNCTION__);
>>
>>  	if (mii_info->interrupts == MII_INTERRUPT_ENABLED)
>> -		phy_write(mii_info, MII_CIS8201_IMASK, MII_CIS8201_IMASK_MASK);
>> +		ucc_geth_phy_write(mii_info, MII_CIS8201_IMASK,  
>> MII_CIS8201_IMASK_MASK);
>>  	else
>> -		phy_write(mii_info, MII_CIS8201_IMASK, 0);
>> +		ucc_geth_phy_write(mii_info, MII_CIS8201_IMASK, 0);
>>
>>  	return 0;
>>  }
>> @@ -541,7 +564,7 @@ static int dm9161_read_status(struct uge
>>  	/* If we aren't autonegotiating, assume speeds
>>  	 * are as set */
>>  	if (mii_info->autoneg && mii_info->link) {
>> -		status = phy_read(mii_info, MII_DM9161_SCSR);
>> +		status = ucc_geth_phy_read(mii_info, MII_DM9161_SCSR);
>>  		if (status & (MII_DM9161_SCSR_100F | MII_DM9161_SCSR_100H))
>>  			mii_info->speed = SPEED_100;
>>  		else
>> @@ -572,7 +595,7 @@ static void dm9161_timer(unsigned long d
>>  {
>>  	struct ugeth_mii_info *mii_info = (struct ugeth_mii_info *)data;
>>  	struct dm9161_private *priv = mii_info->priv;
>> -	u16 status = phy_read(mii_info, MII_BMSR);
>> +	u16 status = ucc_geth_phy_read(mii_info, MII_BMSR);
>>
>>  	ugphy_vdbg("%s: IN", __FUNCTION__);
>>
>> @@ -599,11 +622,11 @@ static int dm9161_init(struct ugeth_mii_
>>  	/* Reset is not done yet */
>>  	priv->resetdone = 0;
>>
>> -	phy_write(mii_info, MII_BMCR,
>> -		  phy_read(mii_info, MII_BMCR) | BMCR_RESET);
>> +	ucc_geth_phy_write(mii_info, MII_BMCR,
>> +		  ucc_geth_phy_read(mii_info, MII_BMCR) | BMCR_RESET);
>>
>> -	phy_write(mii_info, MII_BMCR,
>> -		  phy_read(mii_info, MII_BMCR) & ~BMCR_ISOLATE);
>> +	ucc_geth_phy_write(mii_info, MII_BMCR,
>> +		  ucc_geth_phy_read(mii_info, MII_BMCR) & ~BMCR_ISOLATE);
>>
>>  	config_genmii_advert(mii_info);
>>  	/* Start/Restart aneg */
>> @@ -634,7 +657,7 @@ static int dm9161_ack_interrupt(struct u
>>  	ugphy_vdbg("%s: IN", __FUNCTION__);
>>
>>  	/* Clear the interrupts by reading the reg */
>> -	phy_read(mii_info, MII_DM9161_INTR);
>> +	ucc_geth_phy_read(mii_info, MII_DM9161_INTR);
>>
>>
>>  	return 0;
>> @@ -645,9 +668,9 @@ static int dm9161_config_intr(struct uge
>>  	ugphy_vdbg("%s: IN", __FUNCTION__);
>>
>>  	if (mii_info->interrupts == MII_INTERRUPT_ENABLED)
>> -		phy_write(mii_info, MII_DM9161_INTR, MII_DM9161_INTR_INIT);
>> +		ucc_geth_phy_write(mii_info, MII_DM9161_INTR,  
>> MII_DM9161_INTR_INIT);
>>  	else
>> -		phy_write(mii_info, MII_DM9161_INTR, MII_DM9161_INTR_STOP);
>> +		ucc_geth_phy_write(mii_info, MII_DM9161_INTR,  
>> MII_DM9161_INTR_STOP);
>>
>>  	return 0;
>>  }
>> @@ -718,31 +741,6 @@ static struct phy_info *phy_info[] = {
>>  	NULL
>>  };
>>
>> -u16 phy_read(struct ugeth_mii_info *mii_info, u16 regnum)
>> -{
>> -	u16 retval;
>> -	unsigned long flags;
>> -
>> -	ugphy_vdbg("%s: IN", __FUNCTION__);
>> -
>> -	spin_lock_irqsave(&mii_info->mdio_lock, flags);
>> -	retval = mii_info->mdio_read(mii_info->dev, mii_info->mii_id,  
>> regnum);
>> -	spin_unlock_irqrestore(&mii_info->mdio_lock, flags);
>> -
>> -	return retval;
>> -}
>> -
>> -void phy_write(struct ugeth_mii_info *mii_info, u16 regnum, u16 val)
>> -{
>> -	unsigned long flags;
>> -
>> -	ugphy_vdbg("%s: IN", __FUNCTION__);
>> -
>> -	spin_lock_irqsave(&mii_info->mdio_lock, flags);
>> -	mii_info->mdio_write(mii_info->dev, mii_info->mii_id, regnum, val);
>> -	spin_unlock_irqrestore(&mii_info->mdio_lock, flags);
>> -}
>> -
>>  /* Use the PHY ID registers to determine what type of PHY is  
>> attached
>>   * to device dev.  return a struct phy_info structure describing  
>> that PHY
>>   */
>> @@ -757,11 +755,11 @@ struct phy_info *get_phy_info(struct uge
>>  	ugphy_vdbg("%s: IN", __FUNCTION__);
>>
>>  	/* Grab the bits from PHYIR1, and put them in the upper half */
>> -	phy_reg = phy_read(mii_info, MII_PHYSID1);
>> +	phy_reg = ucc_geth_phy_read(mii_info, MII_PHYSID1);
>>  	phy_ID = (phy_reg & 0xffff) << 16;
>>
>>  	/* Grab the bits from PHYIR2, and put them in the lower half */
>> -	phy_reg = phy_read(mii_info, MII_PHYSID2);
>> +	phy_reg = ucc_geth_phy_read(mii_info, MII_PHYSID2);
>>  	phy_ID |= (phy_reg & 0xffff);
>>
>>  	/* loop through all the known PHY types, and find one that */
>> -- 
>> 1.4.4
>>
>> -
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

