From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] bond: add support to read speed and duplex via
 ethtool
Date: Wed, 6 Mar 2013 20:17:17 +0000
Message-ID: <1362601037.3126.20.camel@bwh-desktop.uk.solarflarecom.com>
References: <1362595173-11442-1-git-send-email-andy@greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:42782 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752304Ab3CFURi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 15:17:38 -0500
In-Reply-To: <1362595173-11442-1-git-send-email-andy@greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-03-06 at 13:39 -0500, Andy Gospodarek wrote:
> This patch adds support for the get_settings ethtool op to the bonding
> driver.  This was motivated by users who wanted to get the speed of the
> bond and compare that against throughput to understand utilization.
> The behavior before this patch was added was problematic when computing
> line utilization after trying to get link-speed and throughput via SNMP.
> 
> The general plan for computing link-speed was as follows:
> 
> Mode                 Formula
> ----                 -------
> active-backup        speed of current active slave
> broadcast            speed of first slave with known speed
> all other modes      aggregate speed of all slaves with known speed
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
> 	Port: Twisted Pair

I think port should be PORT_OTHER.  Or perhaps you could ask the current
slave, if using active-backup.  (Tricky since you can't do that while
holding the bond rwlock.)

> 	PHYAD: 0

I don't think we have a properly defined 'not applicable' value for
phy_address, though I've used 0xff in sfc.

> 	Transceiver: internal
> 	Auto-negotiation: off
> 	MDI-X: Unknown
> 	Link detected: yes
> 
> I tested this and verified it works as expected.  A test was also done
> on a version backported to an older kernel and it worked well there.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> ---
>  drivers/net/bonding/bond_main.c | 47 +++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 47 insertions(+)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 7bd068a..6e70ff0 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -4224,6 +4224,52 @@ void bond_set_mode_ops(struct bonding *bond, int mode)
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
> +	ecmd->speed = SPEED_UNKNOWN;
[...]

You must use ethtool_cmd_speed_set() instead of assigning just
ecmd->speed.

(bonding appears to be the first driver that could report a value >
65535.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
