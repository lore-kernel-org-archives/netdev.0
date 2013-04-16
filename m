From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2] bond: add support to read speed and duplex via
 ethtool
Date: Tue, 16 Apr 2013 22:32:35 +0100
Message-ID: <1366147955.2645.35.camel@bwh-desktop.uk.solarflarecom.com>
References: <1362595173-11442-1-git-send-email-andy@greyhouse.net>
	 <1366146607-12343-1-git-send-email-andy@greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56583 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965337Ab3DPVcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 17:32:39 -0400
In-Reply-To: <1366146607-12343-1-git-send-email-andy@greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-16 at 17:10 -0400, Andy Gospodarek wrote:
> This patch adds support for the get_settings ethtool op to the bonding
> driver.  This was motivated by users who wanted to get the speed of the
> bond and compare that against throughput to understand utilization.
> The behavior before this patch was added was problematic when computing
> line utilization after trying to get link-speed and throughput via SNMP.
> 
> Output from ethtool looks like this for a round-robin bond:
> 
> Settings for bond0:
> 	Supported ports: [ ]
> 	Supported link modes:   Not reported
> 	Supported pause frame use: No
> 	Supports auto-negotiation: No
> 	Advertised link modes:  Not reported
> 	Advertised pause frame use: No
> 	Advertised auto-negotiation: No
> 	Speed: 11000Mb/s
> 	Duplex: Full
> 	Port: Other
> 	PHYAD: 0
> 	Transceiver: internal
> 	Auto-negotiation: off
> 	MDI-X: Unknown
> 	Link detected: yes
> 
> I tested this and verified it works as expected.  A test was also done
> on a version backported to an older kernel and it worked well there.
> 
> v2: switch to using ethtool_cmd_speed_set to set speed, added check to
> SLAVE_IS_OK for each slave in bond, dropped mode-specific calculations
> as they were not needed, and set port type to 'Other.'
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> ---
>  drivers/net/bonding/bond_main.c | 34 ++++++++++++++++++++++++++++++++++
>  1 file changed, 34 insertions(+)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 07401a3..da2dd38 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -4222,6 +4222,39 @@ void bond_set_mode_ops(struct bonding *bond, int mode)
>  	}
>  }
>  
> +static int bond_ethtool_get_settings(struct net_device *bond_dev,
> +				     struct ethtool_cmd *ecmd)
> +{
> +	struct bonding *bond = netdev_priv(bond_dev);
> +	struct slave *slave;
> +	int i;
> +	unsigned long speed = 0;
> +
> +	ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);

This is a dead write, as speed is unconditionally set again below.
Otherwise, I think the implementation is fine.

Ben.

> +	ecmd->duplex = DUPLEX_UNKNOWN;
> +	ecmd->port = PORT_OTHER;
> +
> +	/* Since SLAVE_IS_OK returns false for all inactive or down slaves, we
> +	 * do not need to check mode.  Though link speed might not represent
> +	 * the true receive or transmit bandwidth (not all modes are symmetric)
> +	 * this is an accurate maximum.
> +	 */
> +	read_lock(&bond->lock);
> +	bond_for_each_slave(bond, slave, i) {
> +		if (SLAVE_IS_OK(slave)) {
> +			if (slave->speed != SPEED_UNKNOWN) {
> +				speed += slave->speed;
> +			}
> +			if (ecmd->duplex == DUPLEX_UNKNOWN &&
> +			    slave->duplex != DUPLEX_UNKNOWN)
> +				ecmd->duplex = slave->duplex;
> +		}
> +	}
> +	ethtool_cmd_speed_set(ecmd, speed);
> +	read_unlock(&bond->lock);
> +	return 0;
> +}
> +
>  static void bond_ethtool_get_drvinfo(struct net_device *bond_dev,
>  				     struct ethtool_drvinfo *drvinfo)
>  {
> @@ -4233,6 +4266,7 @@ static void bond_ethtool_get_drvinfo(struct net_device *bond_dev,
>  
>  static const struct ethtool_ops bond_ethtool_ops = {
>  	.get_drvinfo		= bond_ethtool_get_drvinfo,
> +	.get_settings		= bond_ethtool_get_settings,
>  	.get_link		= ethtool_op_get_link,
>  };
>  

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
