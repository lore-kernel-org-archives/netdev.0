From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: mvneta: read MAC address from hardware when
 available
Date: Mon, 03 Jun 2013 09:52:59 -0700
Message-ID: <1370278379.2025.40.camel@joe-AO722>
References: <1370277707-2468-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jason Cooper <jason@lakedaemon.net>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	linux-arm-kernel@lists.infradead.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:59364 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759352Ab3FCQxE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jun 2013 12:53:04 -0400
In-Reply-To: <1370277707-2468-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-03 at 18:41 +0200, Thomas Petazzoni wrote:
> This patch improves the logic used by the mvneta driver to find a MAC
> address for a particular interface. Until now, it was only looking at
> the Device Tree, and if no address was found, was falling back to
> generating a random MAC address.
[]
> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
[]
> @@ -2740,6 +2748,17 @@ static int mvneta_probe(struct platform_device *pdev)
[]
> +	dt_mac_addr = of_get_mac_address(dn);
> +	if (dt_mac_addr && is_valid_ether_addr(dt_mac_addr))
> +		memcpy(dev->dev_addr, dt_mac_addr, ETH_ALEN);
> +	else {
> +		mvneta_get_mac_addr(pp, hw_mac_addr);
> +		if (is_valid_ether_addr(hw_mac_addr))
> +			memcpy(dev->dev_addr, hw_mac_addr, ETH_ALEN);
> +		else
> +			eth_hw_addr_random(dev);
> +	}

maybe there could be a dmesg line like:

	const char *mac_from;
[...]
		mac_from = "device tree"
	else
[...]
			mac_from = "hardware"
		else
			mac_from = "random"
[...]
	netdev_info(dev, "Using %s mac address %pM\n",
		    mac_from, dev->dev_addr);
