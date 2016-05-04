From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH net v2] vlan: Propagate MAC address to VLANs unless
 explicitly set
Date: Wed, 4 May 2016 11:28:02 +0200
Message-ID: <20160504092801.GC19967@unicorn.suse.cz>
References: <5728BA0B.6050807@brocade.com>
 <5728C1AC.3090708@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Mike Manning <mmanning@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33435 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751396AbcEDJ2E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2016 05:28:04 -0400
Content-Disposition: inline
In-Reply-To: <5728C1AC.3090708@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 03, 2016 at 04:20:12PM +0100, Mike Manning wrote:
> The MAC address of the physical interface is only copied to the VLAN
> when it is first created, resulting in an inconsistency after MAC
> address changes of only newly created VLANs having an up-to-date MAC.
> 
> Continuing to inherit the MAC address unless explicitly changed for
> the VLAN allows IPv6 EUI64 addresses for the VLAN to reflect the change
> and thus for DAD to behave as expected for the given MAC.
> 
> Signed-off-by: Mike Manning <mmanning@brocade.com>
> ---
>  net/8021q/vlan.c |   22 ++++++++++------------
>  1 file changed, 10 insertions(+), 12 deletions(-)
> 
> --- a/net/8021q/vlan.c
> +++ b/net/8021q/vlan.c
> @@ -286,22 +286,25 @@ static void vlan_sync_address(struct net
>  			      struct net_device *vlandev)
>  {
>  	struct vlan_dev_priv *vlan = vlan_dev_priv(vlandev);
> +	bool real_addr_in_use;
>  
>  	/* May be called without an actual change */
>  	if (ether_addr_equal(vlan->real_dev_addr, dev->dev_addr))
>  		return;
>  
> -	/* vlan address was different from the old address and is equal to
> +	real_addr_in_use =
> +		ether_addr_equal(vlandev->dev_addr, vlan->real_dev_addr);
> +
> +	/* vlan address was different from the real address and is equal to
>  	 * the new address */
> -	if (!ether_addr_equal(vlandev->dev_addr, vlan->real_dev_addr) &&
> +	if ((vlandev->flags & IFF_UP) && !real_addr_in_use &&
>  	    ether_addr_equal(vlandev->dev_addr, dev->dev_addr))
>  		dev_uc_del(dev, vlandev->dev_addr);
>  
> -	/* vlan address was equal to the old address and is different from
> +	/* vlan address was equal to the real address so now also inherit
>  	 * the new address */
> -	if (ether_addr_equal(vlandev->dev_addr, vlan->real_dev_addr) &&
> -	    !ether_addr_equal(vlandev->dev_addr, dev->dev_addr))
> -		dev_uc_add(dev, vlandev->dev_addr);
> +	if (real_addr_in_use)
> +		ether_addr_copy(vlandev->dev_addr, dev->dev_addr);
>  
>  	ether_addr_copy(vlan->real_dev_addr, dev->dev_addr);
>  }
> @@ -389,13 +392,8 @@ static int vlan_device_event(struct noti
>  
>  	case NETDEV_CHANGEADDR:
>  		/* Adjust unicast filters on underlying device */
> -		vlan_group_for_each_dev(grp, i, vlandev) {
> -			flgs = vlandev->flags;
> -			if (!(flgs & IFF_UP))
> -				continue;
> -
> +		vlan_group_for_each_dev(grp, i, vlandev)
>  			vlan_sync_address(dev, vlandev);
> -		}
>  		break;
>  
>  	case NETDEV_CHANGEMTU:

The commit message says "unless explicitly changed for the VLAN" but
what you really check is "if it is the same as real device MAC address".
This, in general, is not the same. (I believe this is what David tries
to explain from the start.)

                                                        Michal Kubecek
