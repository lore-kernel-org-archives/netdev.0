From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH net v4] vlan: Propagate MAC address to VLANs
Date: Mon, 9 May 2016 08:48:25 +0200
Message-ID: <20160509064825.GA27709@unicorn.suse.cz>
References: <572DB364.2040109@brocade.com>
 <572DBCA9.7060906@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Mike Manning <mmanning@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:42453 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750935AbcEIGs2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 02:48:28 -0400
Content-Disposition: inline
In-Reply-To: <572DBCA9.7060906@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 07, 2016 at 11:00:09AM +0100, Mike Manning wrote:
> The MAC address of the physical interface is only copied to the VLAN
> when it is first created, resulting in an inconsistency after MAC
> address changes of only newly created VLANs having an up-to-date MAC.
> 
> The VLANs should continue inheriting the MAC address of the physical
> interface until the VLAN MAC address is explicitly set to any value. 
> This allows IPv6 EUI64 addresses for the VLAN to reflect any changes
> to the MAC of the physical interface and thus for DAD to behave as
> expected.
> 
> Signed-off-by: Mike Manning <mmanning@brocade.com>
> ---
>  net/8021q/vlan.c     |    7 +++++++
>  net/8021q/vlan_dev.c |   14 ++++++++++----
>  2 files changed, 17 insertions(+), 4 deletions(-)
> 
> --- a/net/8021q/vlan.c
> +++ b/net/8021q/vlan.c
> @@ -291,6 +291,12 @@ static void vlan_sync_address(struct net
>  	if (ether_addr_equal(vlan->real_dev_addr, dev->dev_addr))
>  		return;
>  
> +	/* vlan continues to inherit address of parent interface */
> +	if (vlandev->addr_assign_type == NET_ADDR_STOLEN) {
> +		ether_addr_copy(vlandev->dev_addr, dev->dev_addr);
> +		goto out;
> +	}
> +

I might have missed something in the previous discussion but as
ether_addr_copy() is just an optimized memcpy(), how is this going to
handle the setups where the vlan device itself has an upper device? For
example,

  - if it is a bridge port, how is the bridge going to learn about its
    address change so that it can update its FDB?
  - if it is a bond slave or team port, current code preserves the vlan
    device address on real device change so everything is fine; your
    proposal would change vlan device's address without bond being even
    notified, I believe
  - there might be a macvlan on top of the vlan and you might
    accidentally match its address with the new one

>  	/* vlan address was different from the old address and is equal to
>  	 * the new address */
>  	if (!ether_addr_equal(vlandev->dev_addr, vlan->real_dev_addr) &&
> @@ -303,6 +309,7 @@ static void vlan_sync_address(struct net
>  	    !ether_addr_equal(vlandev->dev_addr, dev->dev_addr))
>  		dev_uc_add(dev, vlandev->dev_addr);
>  
> +out:
>  	ether_addr_copy(vlan->real_dev_addr, dev->dev_addr);
>  }
>  
> --- a/net/8021q/vlan_dev.c
> +++ b/net/8021q/vlan_dev.c
> @@ -255,9 +255,13 @@ static int vlan_dev_open(struct net_devi
>  		return -ENETDOWN;
>  
>  	if (!ether_addr_equal(dev->dev_addr, real_dev->dev_addr)) {
> -		err = dev_uc_add(real_dev, dev->dev_addr);
> -		if (err < 0)
> -			goto out;
> +		if (dev->addr_assign_type == NET_ADDR_STOLEN) {
> +			ether_addr_copy(dev->dev_addr, real_dev->dev_addr);

The same question here.

> +		} else {
> +			err = dev_uc_add(real_dev, dev->dev_addr);
> +			if (err < 0)
> +				goto out;
> +		}
>  	}
>  
>  	if (dev->flags & IFF_ALLMULTI) {
> @@ -558,8 +562,10 @@ static int vlan_dev_init(struct net_devi
>  	/* ipv6 shared card related stuff */
>  	dev->dev_id = real_dev->dev_id;
>  
> -	if (is_zero_ether_addr(dev->dev_addr))
> +	if (is_zero_ether_addr(dev->dev_addr)) {
>  		eth_hw_addr_inherit(dev, real_dev);
> +		dev->addr_assign_type = NET_ADDR_STOLEN;

You might want to replace eth_hw_addr_inherit() with ether_addr_copy()
here as they only differ in the former copying addr_assign_type which
you are going to rewrite anyway. (But as both are most likely inlined,
I would expect the resulting code to be the same in the end.)

                                                       Michal Kubecek

> +	}
>  	if (is_zero_ether_addr(dev->broadcast))
>  		memcpy(dev->broadcast, real_dev->broadcast, dev->addr_len);
> 
> -- 
> 1.7.10.4
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
