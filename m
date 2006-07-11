From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC] vlan handling of up/down
Date: Tue, 11 Jul 2006 14:47:49 -0700
Message-ID: <44B41C85.3040305@candelatech.com>
References: <200603211829.k2LITMNR029085@hera.kernel.org>	<200607091049.31628.stefan@loplof.de>	<20060710095603.0b197eec@dxpl.pdx.osdl.net>	<200607110001.14812.stefan@loplof.de> <20060711142808.1a6a47bb@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stefan Rompf <stefan@loplof.de>, Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:18821 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S932140AbWGKVsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2006 17:48:05 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060711142808.1a6a47bb@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Untested, but here is the basic idea of how I think up/down should be
> handled.  Basically, rather than changing the flags directly the VLAN code
> should call dev_open/dev_close.  The notifier end's up recursively calling
> but this is okay.
> 
> 
> --- vlan.orig/net/8021q/vlan.c
> +++ vlan/net/8021q/vlan.c
> @@ -427,7 +427,7 @@ static struct net_device *register_vlan_
>  	/* The real device must be up and operating in order to
>  	 * assosciate a VLAN device with it.
>  	 */
> -	if (!(real_dev->flags & IFF_UP))
> +	if (!netif_running(real_dev))
>  		goto out_unlock;

I can't remember why I thought this check was a good idea..but is there
any reason to keep it in?  I mean, why not allow attaching VLANs to a
'down' device?

>  	if (__find_vlan_dev(real_dev, VLAN_ID) != NULL) {
> @@ -476,10 +476,7 @@ static struct net_device *register_vlan_
>  	printk(VLAN_DBG "Allocated new name -:%s:-\n", new_dev->name);
>  #endif
>  	/* IFF_BROADCAST|IFF_MULTICAST; ??? */
> -	new_dev->flags = real_dev->flags;
> -	new_dev->flags &= ~IFF_UP;
> -
> -	new_dev->state = real_dev->state & ~(1<<__LINK_STATE_START);
> +	new_dev->flags = real_dev->flags & ~IFF_UP;
>  
>  	/* need 4 bytes for extra VLAN header info,
>  	 * hope the underlying device can handle it.
> @@ -566,6 +563,9 @@ static struct net_device *register_vlan_
>  	if (real_dev->features & NETIF_F_HW_VLAN_FILTER)
>  		real_dev->vlan_rx_add_vid(real_dev, VLAN_ID);
>  
> +	/* Real device is up so bring up the vlan */
> +	dev_open(new_dev);
> +
>  	rtnl_unlock();

Assuming we take out the 'is-up' check above, this would need
a check added here (if real-dev is up, then bring up vlan, else leave it down.)

> @@ -624,11 +624,7 @@ static int vlan_device_event(struct noti
>  			if (!vlandev)
>  				continue;
>  
> -			flgs = vlandev->flags;
> -			if (!(flgs & IFF_UP))
> -				continue;
> -
> -			dev_change_flags(vlandev, flgs & ~IFF_UP);
> +			dev_close(vlandev);
>  		}
>  		break;
>  
> @@ -638,12 +634,8 @@ static int vlan_device_event(struct noti
>  			vlandev = grp->vlan_devices[i];
>  			if (!vlandev)
>  				continue;
> -				
> -			flgs = vlandev->flags;
> -			if (flgs & IFF_UP)
> -				continue;
>  
> -			dev_change_flags(vlandev, flgs | IFF_UP);
> +			dev_open(vlandev);
>  		}
>  		break;

Although it may be too late to change this (don't want to change
user-visible behaviour), I don't really like that bouncing the
real-dev could cause the VLANs to come up, even if previously
user-space had forced them down.

Perhaps a piece of state in the vlan dev could be added to remember
the 'desired state', and then only bring back up interfaces that are
desired-up when the real-dev comes back online....

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

