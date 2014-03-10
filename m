From: Rob Herring <robherring2@gmail.com>
Subject: Re: [PATCH v3] sky2: allow mac to come from dt
Date: Mon, 10 Mar 2014 10:36:25 -0500
Message-ID: <CAL_JsqLEOOQ-0H3fuGHME9Q7iF_7h+Y_mrWcwJP7YjCKiZ8aNw@mail.gmail.com>
References: <1394254793-19228-1-git-send-email-tharvey@gateworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>
To: Tim Harvey <tharvey@gateworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f171.google.com ([209.85.220.171]:51477 "EHLO
	mail-vc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753157AbaCJPg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 11:36:26 -0400
In-Reply-To: <1394254793-19228-1-git-send-email-tharvey@gateworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 7, 2014 at 10:59 PM, Tim Harvey <tharvey@gateworks.com> wrote:
> The driver reads the mac address from the device registers which would
> need to have been programmed by the bootloader.  This patch adds
> the ability to pull the mac from devicetree via the pci device dt node.
>
> Signed-off-by: Tim Harvey <tharvey@gateworks.com>
> Cc: netdev@vger.kernel.org
> Cc: devicetree@vger.kernel.org
> Cc: Grant Likely <grant.likely@linaro.org>
> Cc: Rob Herring <robh+dt@kernel.org>

Acked-by: Rob Herring <robh@kernel.org>

>
> Changes since v2:
>  - eliminated use of stack tmpaddr per feedback
>
> Changes since v1:
>  - simplified based on feedback
>  - fixed formatting
> ---
>  drivers/net/ethernet/marvell/sky2.c | 15 +++++++++++++--
>  1 file changed, 13 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
> index 55a37ae..2434611 100644
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
> +       const void *iap;
>
>         if (!dev)
>                 return NULL;
> @@ -4805,8 +4808,16 @@ static struct net_device *sky2_init_netdev(struct sky2_hw *hw, unsigned port,
>
>         dev->features |= dev->hw_features;
>
> -       /* read the mac address */
> -       memcpy_fromio(dev->dev_addr, hw->regs + B2_MAC_1 + port * 8, ETH_ALEN);
> +       /* try to get mac address in the following order:
> +        * 1) from device tree data
> +        * 2) from internal registers set by bootloader
> +        */
> +       iap = of_get_mac_address(hw->pdev->dev.of_node);
> +       if (iap)
> +               memcpy(dev->dev_addr, iap, ETH_ALEN);
> +       else
> +               memcpy_fromio(dev->dev_addr, hw->regs + B2_MAC_1 + port * 8,
> +                             ETH_ALEN);
>
>         return dev;
>  }
> --
> 1.8.3.2
>
