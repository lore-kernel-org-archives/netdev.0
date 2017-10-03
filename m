From: Dan Murphy <dmurphy@ti.com>
Subject: Re: [PATCH] net: phy: DP83822 initial driver submission
Date: Tue, 3 Oct 2017 13:03:44 -0500
Message-ID: <ccab5880-eace-503c-d325-d20867b98bd5@ti.com>
References: <20171003155316.12312-1-dmurphy@ti.com>
 <1847c902-8364-3c7c-f079-3d123ba1d3f1@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>, <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx209.ext.ti.com ([198.47.19.16]:33953 "EHLO
        fllnx209.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750871AbdJCSEa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 14:04:30 -0400
In-Reply-To: <1847c902-8364-3c7c-f079-3d123ba1d3f1@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian

Thanks for the review

On 10/03/2017 12:15 PM, Florian Fainelli wrote:
> On 10/03/2017 08:53 AM, Dan Murphy wrote:
>> Add support for the TI  DP83822 10/100Mbit ethernet phy.
>>
>> The DP83822 provides flexibility to connect to a MAC through a
>> standard MII, RMII or RGMII interface.
>>
>> Datasheet:
>> http://www.ti.com/product/DP83822I/datasheet
> 
> This looks pretty good, just a few nits below.
> 
> [snip]
> 
>> +static int dp83822_set_wol(struct phy_device *phydev,
>> +			   struct ethtool_wolinfo *wol)
>> +{
>> +	struct net_device *ndev = phydev->attached_dev;
>> +	u16 value;
>> +	const u8 *mac;
>> +
>> +	if (wol->wolopts & (WAKE_MAGIC | WAKE_MAGICSECURE)) {
>> +		mac = (const u8 *)ndev->dev_addr;
>> +
>> +		if (!is_valid_ether_addr(mac))
>> +			return -EFAULT;
> 
> -EINVAL maybe?

I referenced the at803x driver for the error code.  I can change it if you want it to be -EINVAL.
I can submit a patch to do the same for the other driver.

-EIVAL does make more sense.


> 
>> +
>> +		/* MAC addresses start with byte 5, but stored in mac[0].
>> +		 * 822 PHYs store bytes 4|5, 2|3, 0|1
>> +		 */
>> +		phy_write_mmd(phydev, DP83822_DEVADDR,
>> +			      MII_DP83822_WOL_DA1, (mac[1] << 8) | mac[0]);
>> +		phy_write_mmd(phydev, DP83822_DEVADDR,
>> +			      MII_DP83822_WOL_DA2, (mac[3] << 8) | mac[2]);
>> +		phy_write_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_DA3,
>> +			      (mac[5] << 8) | mac[4]);
>> +
>> +		value = phy_read_mmd(phydev, DP83822_DEVADDR,
>> +				     MII_DP83822_WOL_CFG);
>> +		if (wol->wolopts & WAKE_MAGIC)
>> +			value |= DP83822_WOL_MAGIC_EN;
>> +		else
>> +			value &= ~DP83822_WOL_MAGIC_EN;
>> +
>> +		if (wol->wolopts & WAKE_MAGICSECURE) {
>> +			value |= DP83822_WOL_SECURE_ON;
> 
> Just in case any of the writes below fail, you would probably want to
> set this bit last, thus indicating that the password was successfully set.

Good point

> 
>> +			phy_write_mmd(phydev, DP83822_DEVADDR,
>> +				      MII_DP83822_RXSOP1,
>> +				      (wol->sopass[1] << 8) | wol->sopass[0]);
>> +			phy_write_mmd(phydev, DP83822_DEVADDR,
>> +				      MII_DP83822_RXSOP2,
>> +				      (wol->sopass[3] << 8) | wol->sopass[2]);
>> +			phy_write_mmd(phydev, DP83822_DEVADDR,
>> +				      MII_DP83822_RXSOP3,
>> +				      (wol->sopass[5] << 8) | wol->sopass[4]);
> 
> In the else clause, you don't appear to be clearing the MagicPacket
> SecureOn password, but your get_wol function does not check for
> DP83822_WOL_SECURE_ON before returning the secure password, so either
> one of these two should be fixed. I would go with fixing the get_wol
> function see below.

OK

> 
>> +		} else {
>> +			value &= ~DP83822_WOL_SECURE_ON;
>> +		}
>> +
>> +		value |= (DP83822_WOL_EN | DP83822_WOL_CLR_INDICATION |
>> +			  DP83822_WOL_CLR_INDICATION);
> 
> The extra parenthesis should not be required here.

I did not code that in.  I had to add it after Checkpatch cribbed about it.
Let me know if you want me to remove it.

> 
>> +		phy_write_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG,
>> +			      value);
>> +	} else {
>> +		value =
>> +		    phy_read_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG);
>> +		value &= (~DP83822_WOL_EN);
> 
> Same here, parenthesis should not be needed.

There are three lines of code in the else.  This code all needs to be excuted in the else case.
I might reformat it to read better.  Lindent messed that one up.

> 
>> +		phy_write_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG,
>> +			      value);
>> +	}
>> +
>> +	return 0;
>> +}
>> +
>> +static void dp83822_get_wol(struct phy_device *phydev,
>> +			    struct ethtool_wolinfo *wol)
>> +{
>> +	int value;
>> +
>> +	wol->supported = (WAKE_MAGIC | WAKE_MAGICSECURE);
>> +	wol->wolopts = 0;
>> +
>> +	value = phy_read_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG);
>> +	if (value & DP83822_WOL_MAGIC_EN)
>> +		wol->wolopts |= WAKE_MAGIC;
>> +
>> +	if (value & DP83822_WOL_SECURE_ON)
>> +		wol->wolopts |= WAKE_MAGICSECURE;
>> +
>> +	if (~value & DP83822_WOL_CLR_INDICATION)
>> +		wol->wolopts = 0;
>> +
>> +	wol->sopass[0] = (phy_read_mmd(phydev,
>> +				       DP83822_DEVADDR,
>> +				       MII_DP83822_RXSOP1) & 0xFF);
>> +	wol->sopass[1] =
>> +	    (phy_read_mmd(phydev, DP83822_DEVADDR, MII_DP83822_RXSOP1) >> 8);
> 
> You can save about twice the amount of reads by using a temporary
> variable to hold the 16-bit register ;)

You are right I can clean that up.

> 
>> +	wol->sopass[2] =
>> +	    (phy_read_mmd(phydev, DP83822_DEVADDR, MII_DP83822_RXSOP2) & 0xFF);
>> +	wol->sopass[3] =
>> +	    (phy_read_mmd(phydev, DP83822_DEVADDR, MII_DP83822_RXSOP2) >> 8);
>> +	wol->sopass[4] =
>> +	    (phy_read_mmd(phydev, DP83822_DEVADDR, MII_DP83822_RXSOP3) & 0xFF);
>> +	wol->sopass[5] =
>> +	    (phy_read_mmd(phydev, DP83822_DEVADDR, MII_DP83822_RXSOP3) >> 8);
> 
> Unless DP83822_WOL_SECURE_ON is set, you probably should not try reading
> the password at all, because there is no guarantee it has been correctly
> set.
> 

OK

>> +}
> 
>> +static int dp83822_phy_reset(struct phy_device *phydev)
>> +{
>> +	int err;
>> +
>> +	err = phy_write(phydev, MII_DP83822_RESET_CTRL, DP83822_HW_RESET);
>> +	if (err < 0)
>> +		return err;
>> +
>> +	return 0;
>> +}
>> +
>> +static int dp83822_suspend(struct phy_device *phydev)
>> +{
>> +	int value;
>> +
>> +	mutex_lock(&phydev->lock);
>> +
>> +	value = phy_read_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG);
>> +	if (~value & DP83822_WOL_EN) {
>> +		value = phy_read(phydev, MII_BMCR);
>> +		phy_write(phydev, MII_BMCR, value | BMCR_PDOWN);
>> +	}
> 
> Can you use genphy_suspend() here along with careful locking of course?
> 

genphy_suspend does not have WoL.

>> +
>> +	mutex_unlock(&phydev->lock);
>> +
>> +	return 0;
>> +}
>> +
>> +static int dp83822_resume(struct phy_device *phydev)
>> +{
>> +	int value;
>> +
>> +	mutex_lock(&phydev->lock);
>> +
>> +	value = phy_read(phydev, MII_BMCR);
>> +	phy_write(phydev, MII_BMCR, value & ~BMCR_PDOWN);
> 
> And genphy_resume() here as well?

genphy_resume does not have WoL.

> 
>> +
>> +	value = phy_read_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG);
>> +
>> +	phy_write_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG, value |
>> +		      DP83822_WOL_CLR_INDICATION);
>> +
>> +	mutex_unlock(&phydev->lock);
>> +
>> +	return 0;
>> +}
>> +
>> +static struct phy_driver dp83822_driver[] = {
>> +	{
>> +	 .phy_id = DP83822_PHY_ID,
>> +	 .phy_id_mask = 0xfffffff0,
>> +	 .name = "TI DP83822",
>> +	 .features = PHY_BASIC_FEATURES,
>> +	 .flags = PHY_HAS_INTERRUPT,
>> +
>> +	 .config_init = genphy_config_init,
>> +	 .soft_reset = dp83822_phy_reset,
>> +
>> +	 .get_wol = dp83822_get_wol,
>> +	 .set_wol = dp83822_set_wol,
>> +
>> +	 /* IRQ related */
>> +	 .ack_interrupt = dp83822_ack_interrupt,
>> +	 .config_intr = dp83822_config_intr,
>> +
>> +	 .config_aneg = genphy_config_aneg,
>> +	 .read_status = genphy_read_status,
>> +	 .suspend = dp83822_suspend,
>> +	 .resume = dp83822_resume,
>> +	 },
> 
> I would omit newlines between definitions of callbacks, but this is
> really a personal preference. Unless you are planning on adding new IDs,
> you could also avoid using an array of 1 element and just a plain
> phy_driver structure, but that's not a big deal either.

Yes there is a plan to add another phy id in early 2018 to this driver.

> 


-- 
------------------
Dan Murphy
