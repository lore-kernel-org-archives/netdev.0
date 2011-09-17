From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 01/11] ixgb: convert to ndo_fix_features
Date: Fri, 16 Sep 2011 19:50:28 -0700
Message-ID: <1316227829.27917.19.camel@Joe-Laptop>
References: <1316225752-1709-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1316225752-1709-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, gospo@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:37985 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753805Ab1IQCu3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Sep 2011 22:50:29 -0400
In-Reply-To: <1316225752-1709-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-09-16 at 19:15 -0700, Jeff Kirsher wrote:
> Private rx_csum flags are now duplicate of netdev->features & NETIF_F_RXCSUM.
> Removing this needs deeper surgery.
> diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
[]
> @@ -439,12 +462,14 @@ ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>  	if (err)
>  		goto err_sw_init;
>  
> -	netdev->features = NETIF_F_SG |
> -			   NETIF_F_HW_CSUM |
> +	netdev->hw_features = NETIF_F_SG |
> +			   NETIF_F_TSO |
> +			   NETIF_F_HW_CSUM;
> +	netdev->features = netdev->hw_features |
>  			   NETIF_F_HW_VLAN_TX |
>  			   NETIF_F_HW_VLAN_RX |
>  			   NETIF_F_HW_VLAN_FILTER;
> -	netdev->features |= NETIF_F_TSO;
> +	netdev->hw_features |= NETIF_F_RXCSUM;

Is there any real reason to do this?
It looks overly complicated for no benefit.

Why not just use something like:

	netdev->hw_features = foo;
	netdev->features = bar;

or maybe use #defines like:

#define FEATURES_DEFAULT (NETIF_F_NETIF_F_SG | NETIF_F_TSO | NETIF_F_HW_CSUM)
#define FEATURES_HW_VLAN (NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER)

and
	netdev->features = FEATURES_DEFAULT | FEATURES_HW_VLAN;
	netdev->hw_features = FEATURES_DEFAULT | NETIF_F_RXCSUM;
