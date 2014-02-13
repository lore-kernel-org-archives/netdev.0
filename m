From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH net-next v2 06/10] net: bcmgenet: add main driver file
Date: Thu, 13 Feb 2014 11:38:35 +0000
Message-ID: <20140213113834.GA5871@e106331-lin.cambridge.arm.com>
References: <1392269395-23513-1-git-send-email-f.fainelli@gmail.com>
 <1392269395-23513-7-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"cernekee@gmail.com" <cernekee@gmail.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([217.140.96.50]:35435 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752875AbaBMLij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 06:38:39 -0500
Content-Disposition: inline
In-Reply-To: <1392269395-23513-7-git-send-email-f.fainelli@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 13, 2014 at 05:29:51AM +0000, Florian Fainelli wrote:
> This patch adds the BCMGENET main driver file which supports the
> following:
>
> - GENET hardware from V1 to V4
> - support for reading the UniMAC MIB counters statistics
> - support for the 5 transmit queues
> - support for RX/TX checksum offload and SG
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> Changes since v1:
> - use module_platform_driver boilerplate macro
> - renamed bcmgenet_plat_drv to bcmgenet_driver
> - renamed bcmgenet_drv_{probe,remove} to bcmgenet_{probe,remove}
> - removed priv->phy_type usage and use priv->phy_interface which
>   contains the exact same value
> - removed debug module parameters, unused
> - added MODULDE_{AUTHOR,ALIAS,DESCRIPTION} macros
> - remove hardcoded queue index check in bcmgenet_xmit

[...]

> +static int bcmgenet_probe(struct platform_device *pdev)
> +{
> +       struct device_node *dn = pdev->dev.of_node;
> +       struct bcmgenet_priv *priv;
> +       struct net_device *dev;
> +       const void *macaddr;
> +       struct resource *r;
> +       int err = -EIO;
> +
> +       /* Up to GENET_MAX_MQ_CNT + 1 TX queues and a single RX queue */
> +       dev = alloc_etherdev_mqs(sizeof(*priv), GENET_MAX_MQ_CNT + 1, 1);
> +       if (!dev) {
> +               dev_err(&pdev->dev, "can't allocate net device\n");
> +               return -ENOMEM;
> +       }
> +
> +       priv = netdev_priv(dev);
> +       priv->irq0 = platform_get_irq(pdev, 0);
> +       priv->irq1 = platform_get_irq(pdev, 1);
> +       if (!priv->irq0 || !priv->irq1) {
> +               dev_err(&pdev->dev, "can't find IRQs\n");
> +               err = -EINVAL;
> +               goto err;
> +       }

The binding did not describe that there were two interrupts. What are
each of them for? Are they named in the documentation?

> +
> +       macaddr = of_get_mac_address(dn);
> +       if (!macaddr) {
> +               dev_err(&pdev->dev, "can't find MAC address\n");
> +               err = -EINVAL;
> +               goto err;
> +       }
> +
> +       r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +       priv->base = devm_request_and_ioremap(&pdev->dev, r);
> +       if (!priv->base) {
> +               dev_err(&pdev->dev, "can't ioremap\n");
> +               err = -EINVAL;
> +               goto err;
> +       }
> +
> +       dev->base_addr = (unsigned long)priv->base;

Does the net core actually need this?

I can't see anywhere else it's used in this file.

[...]

> +       if (of_device_is_compatible(dn, "brcm,genet-v4"))
> +               priv->version = GENET_V4;
> +       else if (of_device_is_compatible(dn, "brcm,genet-v3"))
> +               priv->version = GENET_V3;
> +       else if (of_device_is_compatible(dn, "brcm,genet-v2"))
> +               priv->version = GENET_V2;
> +       else if (of_device_is_compatible(dn, "brcm,genet-v1"))
> +               priv->version = GENET_V1;
> +       else {
> +               dev_err(&pdev->dev, "unknown GENET version\n");
> +               err = -EINVAL;
> +               goto err;

Surely you can't have probed if none of these are in the compatible
list?

Might it make more sense to place this value in of_device_id::data? You
can get it it with of_match_node, and you only have to place the strings
in one place, so no possible typo issues.

> +       }
> +
> +       bcmgenet_set_hw_params(priv);
> +
> +       spin_lock_init(&priv->lock);
> +       spin_lock_init(&priv->bh_lock);
> +       mutex_init(&priv->mib_mutex);
> +       /* Mii wait queue */
> +       init_waitqueue_head(&priv->wq);
> +       /* Always use RX_BUF_LENGTH (2KB) buffer for all chips */
> +       priv->rx_buf_len = RX_BUF_LENGTH;
> +       INIT_WORK(&priv->bcmgenet_irq_work, bcmgenet_irq_task);
> +
> +       priv->clk = devm_clk_get(&priv->pdev->dev, "enet");
> +       if (IS_ERR(priv->clk))
> +               dev_warn(&priv->pdev->dev, "failed to get enet clock\n");

This wasn't in the binding.

> +
> +       priv->clk_wol = devm_clk_get(&priv->pdev->dev, "enet-wol");
> +       if (IS_ERR(priv->clk_wol))
> +               dev_warn(&priv->pdev->dev, "failed to get enet-wol clock\n");

This is also missing from the binding.

> +       /* Turn off the clocks */
> +       if (!IS_ERR(priv->clk))
> +               clk_disable_unprepare(priv->clk);

Either the comment is misleading (s/clocks/clock/), or you're forgetting
about the enet-wol clock here.

Thanks,
Mark.
