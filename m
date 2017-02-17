From: Jon Mason <jon.mason@broadcom.com>
Subject: Re: [PATCH] net: bgmac: store MAC address directly in netdev->dev_addr
Date: Fri, 17 Feb 2017 08:45:11 -0500
Message-ID: <CAC3K-4rb_LTcgPyDxGtFqrJE3weKG_4=Hf3qWugn4dWwz5n89g@mail.gmail.com>
References: <20170216141119.18505-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Arnd Bergmann <arnd@arndb.de>
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:36343 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933900AbdBQNpN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 08:45:13 -0500
Received: by mail-it0-f41.google.com with SMTP id h10so19562545ith.1
        for <netdev@vger.kernel.org>; Fri, 17 Feb 2017 05:45:13 -0800 (PST)
In-Reply-To: <20170216141119.18505-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 16, 2017 at 9:11 AM, Tobias Klauser <tklauser@distanz.ch> wrote:
> After commit 34a5102c3235 ("net: bgmac: allocate struct bgmac just once
> & don't copy it") the mac_addr member of struct bgmac is no longer
> necessary to pass the MAC address to bgmac_enet_probe(). Instead it can
> directly be stored in netdev->dev_addr.
>
> Also use eth_hw_addr_random() instead of eth_random_addr() in case a
> random MAC is nedded. This will make sure netdev->addr_assign_type will
> be properly set.
>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Looks sane to me

Acked-by: Jon Mason <jon.mason@broadcom.com>

> ---
>  drivers/net/ethernet/broadcom/bgmac-bcma.c     | 2 +-
>  drivers/net/ethernet/broadcom/bgmac-platform.c | 2 +-
>  drivers/net/ethernet/broadcom/bgmac.c          | 9 ++++-----
>  drivers/net/ethernet/broadcom/bgmac.h          | 1 -
>  4 files changed, 6 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/bgmac-bcma.c b/drivers/net/ethernet/broadcom/bgmac-bcma.c
> index 5ef60d4f12b4..d59cfcc4c4d5 100644
> --- a/drivers/net/ethernet/broadcom/bgmac-bcma.c
> +++ b/drivers/net/ethernet/broadcom/bgmac-bcma.c
> @@ -144,7 +144,7 @@ static int bgmac_probe(struct bcma_device *core)
>                 goto err;
>         }
>
> -       ether_addr_copy(bgmac->mac_addr, mac);
> +       ether_addr_copy(bgmac->net_dev->dev_addr, mac);
>
>         /* On BCM4706 we need common core to access PHY */
>         if (core->id.id == BCMA_CORE_4706_MAC_GBIT &&
> diff --git a/drivers/net/ethernet/broadcom/bgmac-platform.c b/drivers/net/ethernet/broadcom/bgmac-platform.c
> index 805e6ed6c390..7b1af950f312 100644
> --- a/drivers/net/ethernet/broadcom/bgmac-platform.c
> +++ b/drivers/net/ethernet/broadcom/bgmac-platform.c
> @@ -169,7 +169,7 @@ static int bgmac_probe(struct platform_device *pdev)
>
>         mac_addr = of_get_mac_address(np);
>         if (mac_addr)
> -               ether_addr_copy(bgmac->mac_addr, mac_addr);
> +               ether_addr_copy(bgmac->net_dev->dev_addr, mac_addr);
>         else
>                 dev_warn(&pdev->dev, "MAC address not present in device tree\n");
>
> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
> index 20fe2520da42..415046750bb4 100644
> --- a/drivers/net/ethernet/broadcom/bgmac.c
> +++ b/drivers/net/ethernet/broadcom/bgmac.c
> @@ -1477,14 +1477,13 @@ int bgmac_enet_probe(struct bgmac *bgmac)
>         net_dev->irq = bgmac->irq;
>         SET_NETDEV_DEV(net_dev, bgmac->dev);
>
> -       if (!is_valid_ether_addr(bgmac->mac_addr)) {
> +       if (!is_valid_ether_addr(net_dev->dev_addr)) {
>                 dev_err(bgmac->dev, "Invalid MAC addr: %pM\n",
> -                       bgmac->mac_addr);
> -               eth_random_addr(bgmac->mac_addr);
> +                       net_dev->dev_addr);
> +               eth_hw_addr_random(net_dev);
>                 dev_warn(bgmac->dev, "Using random MAC: %pM\n",
> -                        bgmac->mac_addr);
> +                        net_dev->dev_addr);
>         }
> -       ether_addr_copy(net_dev->dev_addr, bgmac->mac_addr);
>
>         /* This (reset &) enable is not preset in specs or reference driver but
>          * Broadcom does it in arch PCI code when enabling fake PCI device.
> diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethernet/broadcom/bgmac.h
> index ab2db76e4fb8..248727dc62f2 100644
> --- a/drivers/net/ethernet/broadcom/bgmac.h
> +++ b/drivers/net/ethernet/broadcom/bgmac.h
> @@ -474,7 +474,6 @@ struct bgmac {
>
>         struct device *dev;
>         struct device *dma_dev;
> -       unsigned char mac_addr[ETH_ALEN];
>         u32 feature_flags;
>
>         struct net_device *net_dev;
> --
> 2.11.0
>
>
