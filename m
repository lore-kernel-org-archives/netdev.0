From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: sky2: allow mac to come from dt
Date: Wed, 05 Mar 2014 18:15:39 +0400
Message-ID: <5317318B.5020406@cogentembedded.com>
References: <1394000535-25559-1-git-send-email-tharvey@gateworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>
To: Tim Harvey <tharvey@gateworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:48742 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752755AbaCEOPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 09:15:38 -0500
Received: by mail-lb0-f175.google.com with SMTP id w7so720838lbi.20
        for <netdev@vger.kernel.org>; Wed, 05 Mar 2014 06:15:36 -0800 (PST)
In-Reply-To: <1394000535-25559-1-git-send-email-tharvey@gateworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05-03-2014 10:22, Tim Harvey wrote:

> The driver reads the mac address from the device registers which would
> need to have been programmed by the bootloader.  This patch adds
> the ability to pull the mac from devicetree via the pci device dt node.

    I highly doubt that "[local-]mac-address" prop would be added to 
(autodiscovered) PCI device node.

> Signed-off-by: Tim Harvey <tharvey@gateworks.com>
> Cc: netdev@vger.kernel.org
> Cc: devicetree@vger.kernel.org
> Cc: Grant Likely <grant.likely@linaro.org>
> Cc: Rob Herring <robh+dt@kernel.org>
> ---
>   drivers/net/ethernet/marvell/sky2.c | 24 +++++++++++++++++++++++-
>   1 file changed, 23 insertions(+), 1 deletion(-)

> diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
> index 55a37ae..bff493a 100644
> --- a/drivers/net/ethernet/marvell/sky2.c
> +++ b/drivers/net/ethernet/marvell/sky2.c
[...]
> @@ -4805,8 +4808,27 @@ static struct net_device *sky2_init_netdev(struct sky2_hw *hw, unsigned port,
>
>   	dev->features |= dev->hw_features;
>
> +	/* try to get mac address in the following order:
> +	 * 1) from device tree data
> +	 * 2) from internal registers set by bootloader
> +	 */
> +	iap = NULL;
> +	if (IS_ENABLED(CONFIG_OF)) {
> +		struct device_node *np = hw->pdev->dev.of_node;
> +		if (np)
> +			iap = (unsigned char *) of_get_mac_address(np);
> +	}
> +
> +	/* 2) mac registers set by bootloader
> +	 */
> +	if (!iap || !is_valid_ether_addr(iap)) {
> +		memcpy_fromio(&tmpaddr, hw->regs + B2_MAC_1 + port * 8,
> +			ETH_ALEN);

    This line should start right under & on the previous line.

> +		iap = &tmpaddr[0];

    Why not just 'tmpaddr'?

> +	}
> +

WBR, Sergei
