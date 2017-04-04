From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH next] bonding: fix active-backup transition
Date: Tue, 4 Apr 2017 13:32:08 -0400
Message-ID: <20170404173208.GA4730@C02RW35GFVH8.dhcp.broadcom.net>
References: <20170404013839.1728-1-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        Nikolay Aleksandrov <nikolay@redhat.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>,
        Mahesh Bandewar <maheshb@google.com>
To: Mahesh Bandewar <mahesh@bandewar.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:35678 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754201AbdDDRcQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 13:32:16 -0400
Received: by mail-qk0-f196.google.com with SMTP id k139so13261627qke.2
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 10:32:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170404013839.1728-1-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 03, 2017 at 06:38:39PM -0700, Mahesh Bandewar wrote:
> From: Mahesh Bandewar <maheshb@google.com>
> 
> Earlier patch c4adfc822bf5 ("bonding: make speed, duplex setting
> consistent with link state") made an attempt to keep slave state
> consistent with speed and duplex settings. Unfortunately link-state
> transition is used to change the active link especially when used
> in conjunction with mii-mon. The above mentioned patch broke that
> logic. Also when speed and duplex settings for a link are updated
> during a link-event, the link-status should not be changed to
> invoke correct transition logic.
> 
> This patch fixes this issue by moving the link-state update outside
> of the bond_update_speed_duplex() fn and to the places where this fn
> is called and update link-state selectively.
> 
> Fixes: c4adfc822bf5 ("bonding: make speed, duplex setting consistent
> with link state")
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

Reviewed-by: Andy Gospodarek <andy@greyhouse.net>

> ---
>  drivers/net/bonding/bond_main.c | 13 +++++--------
>  1 file changed, 5 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 27359dab78a1..535388b15cde 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -378,20 +378,15 @@ static int bond_update_speed_duplex(struct slave *slave)
>  	slave->duplex = DUPLEX_UNKNOWN;
>  
>  	res = __ethtool_get_link_ksettings(slave_dev, &ecmd);
> -	if (res < 0) {
> -		slave->link = BOND_LINK_DOWN;
> +	if (res < 0)
>  		return 1;
> -	}
> -	if (ecmd.base.speed == 0 || ecmd.base.speed == ((__u32)-1)) {
> -		slave->link = BOND_LINK_DOWN;
> +	if (ecmd.base.speed == 0 || ecmd.base.speed == ((__u32)-1))
>  		return 1;
> -	}
>  	switch (ecmd.base.duplex) {
>  	case DUPLEX_FULL:
>  	case DUPLEX_HALF:
>  		break;
>  	default:
> -		slave->link = BOND_LINK_DOWN;
>  		return 1;
>  	}
>  
> @@ -1563,7 +1558,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>  	new_slave->delay = 0;
>  	new_slave->link_failure_count = 0;
>  
> -	bond_update_speed_duplex(new_slave);
> +	if (bond_update_speed_duplex(new_slave))
> +		new_slave->link = BOND_LINK_DOWN;
>  
>  	new_slave->last_rx = jiffies -
>  		(msecs_to_jiffies(bond->params.arp_interval) + 1);
> @@ -2126,6 +2122,7 @@ static void bond_miimon_commit(struct bonding *bond)
>  
>  		case BOND_LINK_UP:
>  			if (bond_update_speed_duplex(slave)) {
> +				slave->link = BOND_LINK_DOWN;
>  				netdev_warn(bond->dev,
>  					    "failed to get link speed/duplex for %s\n",
>  					    slave->dev->name);
> -- 
> 2.12.2.715.g7642488e1d-goog
> 
