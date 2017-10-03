From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: DP83822 initial driver submission
Date: Tue, 3 Oct 2017 10:15:33 -0700
Message-ID: <1847c902-8364-3c7c-f079-3d123ba1d3f1@gmail.com>
References: <20171003155316.12312-1-dmurphy@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Dan Murphy <dmurphy@ti.com>, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:43994 "EHLO
        mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751072AbdJCRPi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 13:15:38 -0400
Received: by mail-qk0-f174.google.com with SMTP id w134so8960032qkb.0
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 10:15:37 -0700 (PDT)
In-Reply-To: <20171003155316.12312-1-dmurphy@ti.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/03/2017 08:53 AM, Dan Murphy wrote:
> Add support for the TI  DP83822 10/100Mbit ethernet phy.
> 
> The DP83822 provides flexibility to connect to a MAC through a
> standard MII, RMII or RGMII interface.
> 
> Datasheet:
> http://www.ti.com/product/DP83822I/datasheet

This looks pretty good, just a few nits below.

[snip]

> +static int dp83822_set_wol(struct phy_device *phydev,
> +			   struct ethtool_wolinfo *wol)
> +{
> +	struct net_device *ndev = phydev->attached_dev;
> +	u16 value;
> +	const u8 *mac;
> +
> +	if (wol->wolopts & (WAKE_MAGIC | WAKE_MAGICSECURE)) {
> +		mac = (const u8 *)ndev->dev_addr;
> +
> +		if (!is_valid_ether_addr(mac))
> +			return -EFAULT;

-EINVAL maybe?

> +
> +		/* MAC addresses start with byte 5, but stored in mac[0].
> +		 * 822 PHYs store bytes 4|5, 2|3, 0|1
> +		 */
> +		phy_write_mmd(phydev, DP83822_DEVADDR,
> +			      MII_DP83822_WOL_DA1, (mac[1] << 8) | mac[0]);
> +		phy_write_mmd(phydev, DP83822_DEVADDR,
> +			      MII_DP83822_WOL_DA2, (mac[3] << 8) | mac[2]);
> +		phy_write_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_DA3,
> +			      (mac[5] << 8) | mac[4]);
> +
> +		value = phy_read_mmd(phydev, DP83822_DEVADDR,
> +				     MII_DP83822_WOL_CFG);
> +		if (wol->wolopts & WAKE_MAGIC)
> +			value |= DP83822_WOL_MAGIC_EN;
> +		else
> +			value &= ~DP83822_WOL_MAGIC_EN;
> +
> +		if (wol->wolopts & WAKE_MAGICSECURE) {
> +			value |= DP83822_WOL_SECURE_ON;

Just in case any of the writes below fail, you would probably want to
set this bit last, thus indicating that the password was successfully set.

> +			phy_write_mmd(phydev, DP83822_DEVADDR,
> +				      MII_DP83822_RXSOP1,
> +				      (wol->sopass[1] << 8) | wol->sopass[0]);
> +			phy_write_mmd(phydev, DP83822_DEVADDR,
> +				      MII_DP83822_RXSOP2,
> +				      (wol->sopass[3] << 8) | wol->sopass[2]);
> +			phy_write_mmd(phydev, DP83822_DEVADDR,
> +				      MII_DP83822_RXSOP3,
> +				      (wol->sopass[5] << 8) | wol->sopass[4]);

In the else clause, you don't appear to be clearing the MagicPacket
SecureOn password, but your get_wol function does not check for
DP83822_WOL_SECURE_ON before returning the secure password, so either
one of these two should be fixed. I would go with fixing the get_wol
function see below.

> +		} else {
> +			value &= ~DP83822_WOL_SECURE_ON;
> +		}
> +
> +		value |= (DP83822_WOL_EN | DP83822_WOL_CLR_INDICATION |
> +			  DP83822_WOL_CLR_INDICATION);

The extra parenthesis should not be required here.

> +		phy_write_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG,
> +			      value);
> +	} else {
> +		value =
> +		    phy_read_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG);
> +		value &= (~DP83822_WOL_EN);

Same here, parenthesis should not be needed.

> +		phy_write_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG,
> +			      value);
> +	}
> +
> +	return 0;
> +}
> +
> +static void dp83822_get_wol(struct phy_device *phydev,
> +			    struct ethtool_wolinfo *wol)
> +{
> +	int value;
> +
> +	wol->supported = (WAKE_MAGIC | WAKE_MAGICSECURE);
> +	wol->wolopts = 0;
> +
> +	value = phy_read_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG);
> +	if (value & DP83822_WOL_MAGIC_EN)
> +		wol->wolopts |= WAKE_MAGIC;
> +
> +	if (value & DP83822_WOL_SECURE_ON)
> +		wol->wolopts |= WAKE_MAGICSECURE;
> +
> +	if (~value & DP83822_WOL_CLR_INDICATION)
> +		wol->wolopts = 0;
> +
> +	wol->sopass[0] = (phy_read_mmd(phydev,
> +				       DP83822_DEVADDR,
> +				       MII_DP83822_RXSOP1) & 0xFF);
> +	wol->sopass[1] =
> +	    (phy_read_mmd(phydev, DP83822_DEVADDR, MII_DP83822_RXSOP1) >> 8);

You can save about twice the amount of reads by using a temporary
variable to hold the 16-bit register ;)

> +	wol->sopass[2] =
> +	    (phy_read_mmd(phydev, DP83822_DEVADDR, MII_DP83822_RXSOP2) & 0xFF);
> +	wol->sopass[3] =
> +	    (phy_read_mmd(phydev, DP83822_DEVADDR, MII_DP83822_RXSOP2) >> 8);
> +	wol->sopass[4] =
> +	    (phy_read_mmd(phydev, DP83822_DEVADDR, MII_DP83822_RXSOP3) & 0xFF);
> +	wol->sopass[5] =
> +	    (phy_read_mmd(phydev, DP83822_DEVADDR, MII_DP83822_RXSOP3) >> 8);

Unless DP83822_WOL_SECURE_ON is set, you probably should not try reading
the password at all, because there is no guarantee it has been correctly
set.

> +}

> +static int dp83822_phy_reset(struct phy_device *phydev)
> +{
> +	int err;
> +
> +	err = phy_write(phydev, MII_DP83822_RESET_CTRL, DP83822_HW_RESET);
> +	if (err < 0)
> +		return err;
> +
> +	return 0;
> +}
> +
> +static int dp83822_suspend(struct phy_device *phydev)
> +{
> +	int value;
> +
> +	mutex_lock(&phydev->lock);
> +
> +	value = phy_read_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG);
> +	if (~value & DP83822_WOL_EN) {
> +		value = phy_read(phydev, MII_BMCR);
> +		phy_write(phydev, MII_BMCR, value | BMCR_PDOWN);
> +	}

Can you use genphy_suspend() here along with careful locking of course?

> +
> +	mutex_unlock(&phydev->lock);
> +
> +	return 0;
> +}
> +
> +static int dp83822_resume(struct phy_device *phydev)
> +{
> +	int value;
> +
> +	mutex_lock(&phydev->lock);
> +
> +	value = phy_read(phydev, MII_BMCR);
> +	phy_write(phydev, MII_BMCR, value & ~BMCR_PDOWN);

And genphy_resume() here as well?

> +
> +	value = phy_read_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG);
> +
> +	phy_write_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG, value |
> +		      DP83822_WOL_CLR_INDICATION);
> +
> +	mutex_unlock(&phydev->lock);
> +
> +	return 0;
> +}
> +
> +static struct phy_driver dp83822_driver[] = {
> +	{
> +	 .phy_id = DP83822_PHY_ID,
> +	 .phy_id_mask = 0xfffffff0,
> +	 .name = "TI DP83822",
> +	 .features = PHY_BASIC_FEATURES,
> +	 .flags = PHY_HAS_INTERRUPT,
> +
> +	 .config_init = genphy_config_init,
> +	 .soft_reset = dp83822_phy_reset,
> +
> +	 .get_wol = dp83822_get_wol,
> +	 .set_wol = dp83822_set_wol,
> +
> +	 /* IRQ related */
> +	 .ack_interrupt = dp83822_ack_interrupt,
> +	 .config_intr = dp83822_config_intr,
> +
> +	 .config_aneg = genphy_config_aneg,
> +	 .read_status = genphy_read_status,
> +	 .suspend = dp83822_suspend,
> +	 .resume = dp83822_resume,
> +	 },

I would omit newlines between definitions of callbacks, but this is
really a personal preference. Unless you are planning on adding new IDs,
you could also avoid using an array of 1 element and just a plain
phy_driver structure, but that's not a big deal either.
-- 
Florian
