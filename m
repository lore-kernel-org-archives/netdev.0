From: Philippe Reynes <tremyfr@gmail.com>
Subject: Re: [PATCH 2/3] phy: add generic function to support ksetting support
Date: Sat, 16 Apr 2016 00:53:20 +0200
Message-ID: <571170E0.7080902@gmail.com>
References: <1460673301-10599-1-git-send-email-tremyfr@gmail.com> <1460673301-10599-3-git-send-email-tremyfr@gmail.com> <VI1PR0401MB18559A6D1BFF6A55CE840574FF680@VI1PR0401MB1855.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"decot@googlers.com" <decot@googlers.com>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Fugang Duan <fugang.duan@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35080 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900AbcDOWxh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 18:53:37 -0400
In-Reply-To: <VI1PR0401MB18559A6D1BFF6A55CE840574FF680@VI1PR0401MB1855.eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/04/16 04:50, Fugang Duan wrote:
> From: Philippe Reynes<tremyfr@gmail.com>  Sent: Friday, April 15, 2016 6:35 AM
>> To: davem@davemloft.net; decot@googlers.com; f.fainelli@gmail.com; Fugang
>> Duan<fugang.duan@nxp.com>
>> Cc: linux-kernel@vger.kernel.org; netdev@vger.kernel.org; Philippe Reynes
>> <tremyfr@gmail.com>
>> Subject: [PATCH 2/3] phy: add generic function to support ksetting support
>>
>> The old ethtool api (get_setting and set_setting) has generic phy functions
>> phy_ethtool_sset and phy_ethtool_gset.
>> To supprt the new ethtool api (get_link_ksettings and set_link_ksettings), we
>> add generic phy function phy_ethtool_ksettings_get and
>> phy_ethtool_ksettings_set.
>>
>> Signed-off-by: Philippe Reynes<tremyfr@gmail.com>
>> ---
>>   drivers/net/phy/phy.c |   81
>> +++++++++++++++++++++++++++++++++++++++++++++++++
>>   include/linux/phy.h   |    4 ++
>>   2 files changed, 85 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c index
>> 5590b9c..6f221c8 100644
>> --- a/drivers/net/phy/phy.c
>> +++ b/drivers/net/phy/phy.c
>> @@ -362,6 +362,60 @@ int phy_ethtool_sset(struct phy_device *phydev,
>> struct ethtool_cmd *cmd)  }  EXPORT_SYMBOL(phy_ethtool_sset);
>>
>> +int phy_ethtool_ksettings_set(struct phy_device *phydev,
>> +			      const struct ethtool_link_ksettings *cmd) {
>> +	u8 autoneg = cmd->base.autoneg;
>> +	u8 duplex = cmd->base.duplex;
>> +	u32 speed = cmd->base.speed;
>> +	u32 advertising;
>> +
>> +	if (cmd->base.phy_address != phydev->mdio.addr)
>> +		return -EINVAL;
>> +
>> +	ethtool_convert_link_mode_to_legacy_u32(&advertising,
>> +						cmd->link_modes.advertising);
>> +
>> +	/* We make sure that we don't pass unsupported values in to the PHY */
>> +	advertising&= phydev->supported;
>> +
>> +	/* Verify the settings we care about. */
>> +	if (autoneg != AUTONEG_ENABLE&&  autoneg != AUTONEG_DISABLE)
>> +		return -EINVAL;
>> +
>> +	if (autoneg == AUTONEG_ENABLE&&  advertising == 0)
>> +		return -EINVAL;
>> +
>> +	if (autoneg == AUTONEG_DISABLE&&
>> +	    ((speed != SPEED_1000&&
>> +	      speed != SPEED_100&&
>> +	      speed != SPEED_10) ||
>> +	     (duplex != DUPLEX_HALF&&
>> +	      duplex != DUPLEX_FULL)))
>> +		return -EINVAL;
>> +
>> +	phydev->autoneg = autoneg;
>> +
>> +	phydev->speed = speed;
>> +
>> +	phydev->advertising = advertising;
>> +
>> +	if (autoneg == AUTONEG_ENABLE)
>> +		phydev->advertising |= ADVERTISED_Autoneg;
>> +	else
>> +		phydev->advertising&= ~ADVERTISED_Autoneg;
>> +
>> +	phydev->duplex = duplex;
>> +
>> +	phydev->mdix = cmd->base.eth_tp_mdix_ctrl;
>> +
>> +	/* Restart the PHY */
>> +	phy_start_aneg(phydev);
>> +
>> +	return 0;
>> +}
>> +EXPORT_SYMBOL(phy_ethtool_ksettings_set);
>> +
>>   int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd)  {
>>   	cmd->supported = phydev->supported;
>> @@ -385,6 +439,33 @@ int phy_ethtool_gset(struct phy_device *phydev,
>> struct ethtool_cmd *cmd)  }  EXPORT_SYMBOL(phy_ethtool_gset);
>>
>> +int phy_ethtool_ksettings_get(struct phy_device *phydev,
>> +			      struct ethtool_link_ksettings *cmd) {
>> +	ethtool_convert_legacy_u32_to_link_mode(cmd-
>>> link_modes.supported,
>> +						phydev->supported);
>> +
>> +	ethtool_convert_legacy_u32_to_link_mode(cmd-
>>> link_modes.advertising,
>> +						phydev->advertising);
>> +
>> +	ethtool_convert_legacy_u32_to_link_mode(cmd-
>>> link_modes.lp_advertising,
>> +						phydev->lp_advertising);
>> +
>> +	cmd->base.speed = phydev->speed;
>> +	cmd->base.duplex = phydev->duplex;
>> +	if (phydev->interface == PHY_INTERFACE_MODE_MOCA)
>> +		cmd->base.port = PORT_BNC;
>> +	else
>> +		cmd->base.port = PORT_MII;
>> +
>> +	cmd->base.phy_address = phydev->mdio.addr;
>> +	cmd->base.autoneg = phydev->autoneg;
>> +	cmd->base.eth_tp_mdix_ctrl = phydev->mdix;
>> +
>> +	return 0;
>> +}
>> +EXPORT_SYMBOL(phy_ethtool_ksettings_get);
>> +
>>   /**
>>    * phy_mii_ioctl - generic PHY MII ioctl interface
>>    * @phydev: the phy_device struct
>> diff --git a/include/linux/phy.h b/include/linux/phy.h index 2abd791..be3f83b
>> 100644
>> --- a/include/linux/phy.h
>> +++ b/include/linux/phy.h
>> @@ -805,6 +805,10 @@ void phy_start_machine(struct phy_device *phydev);
>> void phy_stop_machine(struct phy_device *phydev);  int
>> phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd *cmd);  int
>> phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd);
>> +int phy_ethtool_ksettings_get(struct phy_device *phydev,
>> +			      struct ethtool_link_ksettings *cmd); int
>> +phy_ethtool_ksettings_set(struct phy_device *phydev,
>> +			      const struct ethtool_link_ksettings *cmd);
>>   int phy_mii_ioctl(struct phy_device *phydev, struct ifreq *ifr, int cmd);  int
>> phy_start_interrupts(struct phy_device *phydev);  void phy_print_status(struct
>> phy_device *phydev);
>> --
>> 1.7.4.4
>
> It seems fine. There have many drivers need to update .set_settings/. get_settings, not only fsl fec driver.

Yes, a lot a drivers needs to be updated. Right now, I've only updated the fec.
If everybody agree, I can replace them.

> And whether there still need to keep the old interface in phy.c driver ?


I think we could remove the old interface when all the drivers would have moved to the new interface.

> Regards,
> Andy

Regards,
Philippe
