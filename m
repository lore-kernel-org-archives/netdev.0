From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/5] net: MOXA ART: connect to PHY and add ethtool support
Date: Fri, 22 Nov 2013 13:14:28 -0800
Message-ID: <CAGVrzcZOKegkSTtzF9RyuEhWcz6Popm69ZFirYdTfeXLfVRdhQ@mail.gmail.com>
References: <1385132242-3204-1-git-send-email-jonas.jensen@gmail.com> <1385132242-3204-2-git-send-email-jonas.jensen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Jonas Jensen <jonas.jensen@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1385132242-3204-2-git-send-email-jonas.jensen@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Jonas,

> +       if (!priv->phy_dev)
> +               return -ENODEV;

This should not be required since you will fail probing the interface
if you cannot connect to the PHY device.

> +
> +       return phy_ethtool_gset(priv->phy_dev, cmd);
> +}
> +
> +static int moxart_set_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
> +{
> +       struct moxart_mac_priv_t *priv = netdev_priv(ndev);
> +
> +       if (!priv->phy_dev)
> +               return -ENODEV;

Same here

> +
> +       return phy_ethtool_sset(priv->phy_dev, cmd);
> +}
> +
> +static int moxart_nway_reset(struct net_device *ndev)
> +{
> +       struct moxart_mac_priv_t *priv = netdev_priv(ndev);
> +
> +       if (!priv->phy_dev)
> +               return -EINVAL;

And here

[snip]

> +       if (!priv->phy_dev)
> +               return -ENODEV;

And here

> +
> +       return phy_mii_ioctl(priv->phy_dev, ir, cmd);
> +}
> +
>  static void moxart_mac_free_memory(struct net_device *ndev)
>  {
>         struct moxart_mac_priv_t *priv = netdev_priv(ndev);
> @@ -169,6 +314,10 @@ static int moxart_mac_open(struct net_device *ndev)
>         moxart_update_mac_address(ndev);
>         moxart_mac_setup_desc_ring(ndev);
>         moxart_mac_enable(ndev);
> +
> +       if (priv->phy_dev)
> +               phy_start(priv->phy_dev);
> +
>         netif_start_queue(ndev);
>
>         netdev_dbg(ndev, "%s: IMR=0x%x, MACCR=0x%x\n",
> @@ -184,6 +333,9 @@ static int moxart_mac_stop(struct net_device *ndev)
>
>         napi_disable(&priv->napi);
>
> +       if (priv->phy_dev)
> +               phy_stop(priv->phy_dev);
> +
>         netif_stop_queue(ndev);
>
>         /* disable all interrupts */
> @@ -429,12 +581,22 @@ static struct net_device_ops moxart_netdev_ops = {
>         .ndo_set_mac_address    = moxart_set_mac_address,
>         .ndo_validate_addr      = eth_validate_addr,
>         .ndo_change_mtu         = eth_change_mtu,
> +       .ndo_do_ioctl           = moxart_do_ioctl,
>  };
>
> +static void moxart_adjust_link(struct net_device *ndev)
> +{
> +#ifdef DEBUG
> +       struct moxart_mac_priv_t *priv = netdev_priv(ndev);
> +
> +       phy_print_status(priv->phy_dev);
> +#endif

This is too simplistic, you should at least do the following:

- check for an update in the PHY duplex setting and update the
Ethernet MAC with this new setting
- check for an update in the PHY speed settings and update relevant
MAC registers (RX/TX clock speed, PHY speed etc...)

Also, it is a good practice to retain the previous link
state/duplex/speed, compare them against the phydev values and call
phy_print_status() if there is any change.

> +}
> +
>  static int moxart_mac_probe(struct platform_device *pdev)
>  {
>         struct device *p_dev = &pdev->dev;
> -       struct device_node *node = p_dev->of_node;
> +       struct device_node *node = p_dev->of_node, *phy_node;
>         struct net_device *ndev;
>         struct moxart_mac_priv_t *priv;
>         struct resource *res;
> @@ -455,6 +617,20 @@ static int moxart_mac_probe(struct platform_device *pdev)
>         priv = netdev_priv(ndev);
>         priv->ndev = ndev;
>
> +       phy_node = of_parse_phandle(node, "phy-handle", 0);
> +       if (!phy_node)
> +               dev_err(p_dev, "of_parse_phandle failed\n");
> +
> +       if (phy_node) {
> +               priv->phy_dev = of_phy_connect(priv->ndev, phy_node,
> +                                              &moxart_adjust_link,
> +                                              0, PHY_INTERFACE_MODE_MII);

Unless the hardware supports anything but MII, this is fine. A nicer
binding would include a "phy-mode" or "phy-connection-type" property
which describes how the Ethernet MAC and PHY are connected to each
other. You can then retrieve that property using of_get_phy_mode().
-- 
Florian
