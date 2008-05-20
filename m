From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC, VLAN]: Propagate selected feature bits to VLAN devices
Date: Tue, 20 May 2008 19:05:30 +0100
Message-ID: <20080520180528.GU28241@solarflare.com>
References: <4832E223.7020206@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:35764 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1763852AbYETSFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 14:05:35 -0400
Content-Disposition: inline
In-Reply-To: <4832E223.7020206@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
[...]
> --- a/net/8021q/vlan.c
> +++ b/net/8021q/vlan.c
> @@ -382,6 +382,19 @@ static void vlan_sync_address(struct net_device *dev,
>  	memcpy(vlan->real_dev_addr, dev->dev_addr, ETH_ALEN);
>  }
>  
> +static void vlan_transfer_features(struct net_device *dev,
> +				   struct net_device *vlandev)
> +{
> +	unsigned long old_features = vlandev->features;
> +
> +	if (dev->features & NETIF_F_VLAN_TSO)
> +		vlandev->features |= dev->features &
> +				     (NETIF_F_TSO | NETIF_F_TSO6);

Shouldn't this mask the flags out of vlandev->features first?

> +	if (old_features != vlandev->features)
> +		netdev_features_change(vlandev);
> +}
> +
>  static void __vlan_device_event(struct net_device *dev, unsigned long event)
>  {
>  	switch (event) {
[...]
> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
> index c961f08..3705d5a 100644
> --- a/net/8021q/vlan_dev.c
> +++ b/net/8021q/vlan_dev.c
> @@ -662,6 +662,7 @@ static int vlan_dev_init(struct net_device *dev)
>  	dev->state  = (real_dev->state & ((1<<__LINK_STATE_NOCARRIER) |
>  					  (1<<__LINK_STATE_DORMANT))) |
>  		      (1<<__LINK_STATE_PRESENT);
> +	dev->features = real_dev->features & (NETIF_F_TSO | NETIF_F_TSO6);
>  
>  	/* ipv6 shared card related stuff */
>  	dev->dev_id = real_dev->dev_id;

This should also test the NETIF_F_VLAN_TSO flag and should copy the
NETIF_F_ALL_CSUM and NETIF_F_SG flags since TSO requires those (see
register_netdevice() feature fix-up).  Peter pointed out that TX checksum
offload for VLANs might be available even without TSO; the same goes for
scatter-gather but I don't know whether it's worth adding a flag for that.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
