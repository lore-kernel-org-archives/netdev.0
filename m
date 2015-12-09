From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH net] phy: micrel: Fix finding PHY properties in MAC node.
Date: Wed, 9 Dec 2015 10:42:41 -0800
Message-ID: <56687621.9010602@caviumnetworks.com>
References: <1449686226-14834-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	<dinguyen@opensource.altera.com>, <david.daney@cavium.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0065.outbound.protection.outlook.com ([157.56.111.65]:34283
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753553AbbLITPg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Dec 2015 14:15:36 -0500
In-Reply-To: <1449686226-14834-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/09/2015 10:37 AM, Andrew Lunn wrote:
> commit 8b63ec1837fa ("phylib: Make PHYs children of their MDIO bus,
> not the bus' parent.")  changed the parenting of PHY devices, making
> them a child of the MDIO bus, instead of the MAC device. This broken
> the Micrel PHY driver which has a deprecated feature of allowing PHY
> properties to be placed into the MAC node.
>
> In order to find the MAC node, we need to walk up the tree of devices
> until we find one with an OF node attached.
>
> Reported-by: Dinh Nguyen <dinguyen@opensource.altera.com>
> Suggested-by: David Daney <david.daney@cavium.com>
> Fixes: 8b63ec1837fa ("phylib: Make PHYs children of their MDIO bus, not the bus' parent.")
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
>   drivers/net/phy/micrel.c | 14 ++++++++++++--
>   1 file changed, 12 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
> index cf6312fafea5..2493d7c035f2 100644
> --- a/drivers/net/phy/micrel.c
> +++ b/drivers/net/phy/micrel.c
> @@ -26,6 +26,7 @@
>   #include <linux/module.h>
>   #include <linux/phy.h>
>   #include <linux/micrel_phy.h>
> +#include <linux/netdevice.h>

No new types are introduced by the patch.  Why do we need an additional 
#include?

>   #include <linux/of.h>
>   #include <linux/clk.h>
>
> @@ -339,9 +340,18 @@ static int ksz9021_config_init(struct phy_device *phydev)
>   {
>   	const struct device *dev = &phydev->dev;
>   	const struct device_node *of_node = dev->of_node;
> +	const struct device *dev_walker;
>
> -	if (!of_node && dev->parent->of_node)
> -		of_node = dev->parent->of_node;
> +	/* The Micrel driver has a deprecated option to place phy OF
> +	 * properties in the MAC node. Walk up the tree of devices to
> +	 * find a device with an OF node.
> +	 */
> +	dev_walker = &phydev->dev;
> +	do {
> +		of_node = dev_walker->of_node;
> +		dev_walker = dev_walker->parent;
> +
> +	} while (!of_node && dev_walker);
>
>   	if (of_node) {
>   		ksz9021_load_values_from_of(phydev, of_node,
>
