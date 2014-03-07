From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] sky2: allow mac to come from dt
Date: Fri, 07 Mar 2014 14:36:22 -0500 (EST)
Message-ID: <20140307.143622.1002770704528601574.davem@davemloft.net>
References: <1394059512-1691-1-git-send-email-tharvey@gateworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, grant.likely@linaro.org,
	robh+dt@kernel.org
To: tharvey@gateworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42855 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752568AbaCGTgY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 14:36:24 -0500
In-Reply-To: <1394059512-1691-1-git-send-email-tharvey@gateworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tim Harvey <tharvey@gateworks.com>
Date: Wed,  5 Mar 2014 14:45:12 -0800

> @@ -4748,6 +4750,7 @@ static struct net_device *sky2_init_netdev(struct sky2_hw *hw, unsigned port,
>  {
>  	struct sky2_port *sky2;
>  	struct net_device *dev = alloc_etherdev(sizeof(*sky2));
> +	unsigned char *iap, tmpaddr[ETH_ALEN];
>  
>  	if (!dev)
>  		return NULL;
> @@ -4805,8 +4808,17 @@ static struct net_device *sky2_init_netdev(struct sky2_hw *hw, unsigned port,
>  
>  	dev->features |= dev->hw_features;
>  
> -	/* read the mac address */
> -	memcpy_fromio(dev->dev_addr, hw->regs + B2_MAC_1 + port * 8, ETH_ALEN);
> +	/* try to get mac address in the following order:
> +	 * 1) from device tree data
> +	 * 2) from internal registers set by bootloader
> +	 */
> +	iap = of_get_mac_address(hw->pdev->dev.of_node);
> +	if (!iap) {
> +		memcpy_fromio(&tmpaddr, hw->regs + B2_MAC_1 + port * 8,
> +			      ETH_ALEN);
> +		iap = tmpaddr;
> +	}
> +	ether_addr_copy(dev->dev_addr, iap);

As Stephen Hemminger suggested do this like:

	iap = of_get_mac_address(hw->pdev->dev.of_node);
	if (iap)
		memcpy(dev->dev_addr, iap, ETH_ALEN);
	else
		memcpy_fromio(dev->dev_addr, hw->regs + B2_MAC_1 + port * 8,
			      ETH_ALEN);

That way you don't need the on-stack buffer.
