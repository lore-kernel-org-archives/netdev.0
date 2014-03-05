From: Rob Herring <robherring2@gmail.com>
Subject: Re: [PATCH] net: sky2: allow mac to come from dt
Date: Wed, 5 Mar 2014 00:32:36 -0600
Message-ID: <CAL_JsqLUOzGW7u2FqUKQQ8gu2m8ksBR48oHkfLZmbkUNtzxpSg@mail.gmail.com>
References: <1394000535-25559-1-git-send-email-tharvey@gateworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>
To: Tim Harvey <tharvey@gateworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f182.google.com ([209.85.220.182]:50042 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751811AbaCEGch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 01:32:37 -0500
In-Reply-To: <1394000535-25559-1-git-send-email-tharvey@gateworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 5, 2014 at 12:22 AM, Tim Harvey <tharvey@gateworks.com> wrote:
> The driver reads the mac address from the device registers which would
> need to have been programmed by the bootloader.  This patch adds
> the ability to pull the mac from devicetree via the pci device dt node.
>
> Signed-off-by: Tim Harvey <tharvey@gateworks.com>
> Cc: netdev@vger.kernel.org
> Cc: devicetree@vger.kernel.org
> Cc: Grant Likely <grant.likely@linaro.org>
> Cc: Rob Herring <robh+dt@kernel.org>
> ---
>  drivers/net/ethernet/marvell/sky2.c | 24 +++++++++++++++++++++++-
>  1 file changed, 23 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
> index 55a37ae..bff493a 100644
> --- a/drivers/net/ethernet/marvell/sky2.c
> +++ b/drivers/net/ethernet/marvell/sky2.c
> @@ -44,6 +44,8 @@
>  #include <linux/prefetch.h>
>  #include <linux/debugfs.h>
>  #include <linux/mii.h>
> +#include <linux/of_device.h>
> +#include <linux/of_net.h>
>
>  #include <asm/irq.h>
>
> @@ -4748,6 +4750,7 @@ static struct net_device *sky2_init_netdev(struct sky2_hw *hw, unsigned port,
>  {
>         struct sky2_port *sky2;
>         struct net_device *dev = alloc_etherdev(sizeof(*sky2));
> +       unsigned char *iap, tmpaddr[ETH_ALEN];
>
>         if (!dev)
>                 return NULL;
> @@ -4805,8 +4808,27 @@ static struct net_device *sky2_init_netdev(struct sky2_hw *hw, unsigned port,
>
>         dev->features |= dev->hw_features;
>
> +       /* try to get mac address in the following order:
> +        * 1) from device tree data
> +        * 2) from internal registers set by bootloader
> +        */
> +       iap = NULL;
> +       if (IS_ENABLED(CONFIG_OF)) {

This shouldn't be needed.

> +               struct device_node *np = hw->pdev->dev.of_node;
> +               if (np)
> +                       iap = (unsigned char *) of_get_mac_address(np);
> +       }

This should all just be 1 line. of_get_mac_address should just return
NULL if !CONFIG_OF or np == NULL.

> +
> +       /* 2) mac registers set by bootloader
> +        */
> +       if (!iap || !is_valid_ether_addr(iap)) {

Perhaps is_valid_ether_addr check should also be moved into of_get_mac_address.

Rob
