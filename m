From: Marcin Wojtas <mw@semihalf.com>
Subject: Re: [PATCH net-next] net: mvpp2: phylink support
Date: Fri, 22 Sep 2017 09:56:10 +0200
Message-ID: <CAPv3WKdOvd128R+Fg2=akjj=91X3Ofd6ivOOXS6my5Nf+voXFA@mail.gmail.com>
References: <20170921134522.10993-1-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Russell King - ARM Linux <linux@armlinux.org.uk>,
        Andrew Lunn <andrew@lunn.ch>,
        =?UTF-8?Q?Gregory_Cl=C3=A9ment?=
        <gregory.clement@free-electrons.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        =?UTF-8?Q?Miqu=C3=A8l_Raynal?= <miquel.raynal@free-electrons.com>,
        nadavh@marvell.com, linux-kernel@vger.kernel.org,
        Stefan Chulski <stefanc@marvell.com>,
        netdev <netdev@vger.kernel.org>
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170921134522.10993-1-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Antoine,

You can add
Tested-by: Marcin Wojtas <mw@semihalf.com>

Best regards,
Marcin

2017-09-21 15:45 GMT+02:00 Antoine Tenart <antoine.tenart@free-electrons.com>:
> Convert the PPv2 driver to use phylink, which models the MAC to PHY
> link. The phylink support is made such a way the GoP link IRQ can still
> be used: the two modes are incompatible and the GoP link IRQ will be
> used if no PHY is described in the device tree. This is the same
> behaviour as before.
>
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
> ---
>  drivers/net/ethernet/marvell/Kconfig |   1 +
>  drivers/net/ethernet/marvell/mvpp2.c | 502 +++++++++++++++++++++--------------
>  2 files changed, 303 insertions(+), 200 deletions(-)
>
> diff --git a/drivers/net/ethernet/marvell/Kconfig b/drivers/net/ethernet/marvell/Kconfig
> index da6fb825afea..991138b8dfba 100644
> --- a/drivers/net/ethernet/marvell/Kconfig
> +++ b/drivers/net/ethernet/marvell/Kconfig
> @@ -86,6 +86,7 @@ config MVPP2
>         depends on ARCH_MVEBU || COMPILE_TEST
>         depends on HAS_DMA
>         select MVMDIO
> +       select PHYLINK
>         ---help---
>           This driver supports the network interface units in the
>           Marvell ARMADA 375, 7K and 8K SoCs.
> diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
> index 8041d692db3c..5fb7e76ee128 100644
> --- a/drivers/net/ethernet/marvell/mvpp2.c
> +++ b/drivers/net/ethernet/marvell/mvpp2.c
> @@ -28,6 +28,7 @@
>  #include <linux/of_address.h>
>  #include <linux/of_device.h>
>  #include <linux/phy.h>
> +#include <linux/phylink.h>
>  #include <linux/phy/phy.h>
>  #include <linux/clk.h>
>  #include <linux/hrtimer.h>
> @@ -341,6 +342,7 @@
>  #define     MVPP2_GMAC_FORCE_LINK_PASS         BIT(1)
>  #define     MVPP2_GMAC_IN_BAND_AUTONEG         BIT(2)
>  #define     MVPP2_GMAC_IN_BAND_AUTONEG_BYPASS  BIT(3)
> +#define     MVPP2_GMAC_IN_BAND_RESTART_AN      BIT(4)
>  #define     MVPP2_GMAC_CONFIG_MII_SPEED        BIT(5)
>  #define     MVPP2_GMAC_CONFIG_GMII_SPEED       BIT(6)
>  #define     MVPP2_GMAC_AN_SPEED_EN             BIT(7)
> @@ -350,6 +352,12 @@
>  #define     MVPP2_GMAC_AN_DUPLEX_EN            BIT(13)
>  #define MVPP2_GMAC_STATUS0                     0x10
>  #define     MVPP2_GMAC_STATUS0_LINK_UP         BIT(0)
> +#define            MVPP2_GMAC_STATUS0_GMII_SPEED       BIT(1)
> +#define            MVPP2_GMAC_STATUS0_MII_SPEED        BIT(2)
> +#define            MVPP2_GMAC_STATUS0_FULL_DUPLEX      BIT(3)
> +#define     MVPP2_GMAC_STATUS0_RX_PAUSE                BIT(6)
> +#define     MVPP2_GMAC_STATUS0_TX_PAUSE                BIT(7)
> +#define     MVPP2_GMAC_STATUS0_AN_COMPLETE     BIT(11)
>  #define MVPP2_GMAC_PORT_FIFO_CFG_1_REG         0x1c
>  #define     MVPP2_GMAC_TX_FIFO_MIN_TH_OFFS     6
>  #define     MVPP2_GMAC_TX_FIFO_MIN_TH_ALL_MASK 0x1fc0
> @@ -878,12 +886,11 @@ struct mvpp2_port {
>         u16 rx_ring_size;
>         struct mvpp2_pcpu_stats __percpu *stats;
>
> +       struct device_node *of_node;
> +
>         phy_interface_t phy_interface;
> -       struct device_node *phy_node;
> +       struct phylink *phylink;
>         struct phy *comphy;
> -       unsigned int link;
> -       unsigned int duplex;
> -       unsigned int speed;
>
>         struct mvpp2_bm_pool *pool_long;
>         struct mvpp2_bm_pool *pool_short;
> @@ -4716,13 +4723,14 @@ static void mvpp2_port_periodic_xon_disable(struct mvpp2_port *port)
>  }
>
>  /* Configure loopback port */
> -static void mvpp2_port_loopback_set(struct mvpp2_port *port)
> +static void mvpp2_port_loopback_set(struct mvpp2_port *port,
> +                                   const struct phylink_link_state *state)
>  {
>         u32 val;
>
>         val = readl(port->base + MVPP2_GMAC_CTRL_1_REG);
>
> -       if (port->speed == 1000)
> +       if (state->speed == 1000)
>                 val |= MVPP2_GMAC_GMII_LB_EN_MASK;
>         else
>                 val &= ~MVPP2_GMAC_GMII_LB_EN_MASK;
> @@ -4778,10 +4786,6 @@ static void mvpp2_defaults_set(struct mvpp2_port *port)
>         int tx_port_num, val, queue, ptxq, lrxq;
>
>         if (port->priv->hw_version == MVPP21) {
> -               /* Configure port to loopback if needed */
> -               if (port->flags & MVPP2_F_LOOPBACK)
> -                       mvpp2_port_loopback_set(port);
> -
>                 /* Update TX FIFO MIN Threshold */
>                 val = readl(port->base + MVPP2_GMAC_PORT_FIFO_CFG_1_REG);
>                 val &= ~MVPP2_GMAC_TX_FIFO_MIN_TH_ALL_MASK;
> @@ -5860,111 +5864,6 @@ static irqreturn_t mvpp2_link_status_isr(int irq, void *dev_id)
>         return IRQ_HANDLED;
>  }
>
> -static void mvpp2_gmac_set_autoneg(struct mvpp2_port *port,
> -                                  struct phy_device *phydev)
> -{
> -       u32 val;
> -
> -       if (port->phy_interface != PHY_INTERFACE_MODE_RGMII &&
> -           port->phy_interface != PHY_INTERFACE_MODE_RGMII_ID &&
> -           port->phy_interface != PHY_INTERFACE_MODE_RGMII_RXID &&
> -           port->phy_interface != PHY_INTERFACE_MODE_RGMII_TXID &&
> -           port->phy_interface != PHY_INTERFACE_MODE_SGMII)
> -               return;
> -
> -       val = readl(port->base + MVPP2_GMAC_AUTONEG_CONFIG);
> -       val &= ~(MVPP2_GMAC_CONFIG_MII_SPEED |
> -                MVPP2_GMAC_CONFIG_GMII_SPEED |
> -                MVPP2_GMAC_CONFIG_FULL_DUPLEX |
> -                MVPP2_GMAC_AN_SPEED_EN |
> -                MVPP2_GMAC_AN_DUPLEX_EN);
> -
> -       if (phydev->duplex)
> -               val |= MVPP2_GMAC_CONFIG_FULL_DUPLEX;
> -
> -       if (phydev->speed == SPEED_1000)
> -               val |= MVPP2_GMAC_CONFIG_GMII_SPEED;
> -       else if (phydev->speed == SPEED_100)
> -               val |= MVPP2_GMAC_CONFIG_MII_SPEED;
> -
> -       writel(val, port->base + MVPP2_GMAC_AUTONEG_CONFIG);
> -}
> -
> -/* Adjust link */
> -static void mvpp2_link_event(struct net_device *dev)
> -{
> -       struct mvpp2_port *port = netdev_priv(dev);
> -       struct phy_device *phydev = dev->phydev;
> -       bool link_reconfigured = false;
> -       u32 val;
> -
> -       if (phydev->link) {
> -               if (port->phy_interface != phydev->interface && port->comphy) {
> -                       /* disable current port for reconfiguration */
> -                       mvpp2_interrupts_disable(port);
> -                       netif_carrier_off(port->dev);
> -                       mvpp2_port_disable(port);
> -                       phy_power_off(port->comphy);
> -
> -                       /* comphy reconfiguration */
> -                       port->phy_interface = phydev->interface;
> -                       mvpp22_comphy_init(port);
> -
> -                       /* gop/mac reconfiguration */
> -                       mvpp22_gop_init(port);
> -                       mvpp2_port_mii_set(port);
> -
> -                       link_reconfigured = true;
> -               }
> -
> -               if ((port->speed != phydev->speed) ||
> -                   (port->duplex != phydev->duplex)) {
> -                       mvpp2_gmac_set_autoneg(port, phydev);
> -
> -                       port->duplex = phydev->duplex;
> -                       port->speed  = phydev->speed;
> -               }
> -       }
> -
> -       if (phydev->link != port->link || link_reconfigured) {
> -               port->link = phydev->link;
> -
> -               if (phydev->link) {
> -                       if (port->phy_interface == PHY_INTERFACE_MODE_RGMII ||
> -                           port->phy_interface == PHY_INTERFACE_MODE_RGMII_ID ||
> -                           port->phy_interface == PHY_INTERFACE_MODE_RGMII_RXID ||
> -                           port->phy_interface == PHY_INTERFACE_MODE_RGMII_TXID ||
> -                           port->phy_interface == PHY_INTERFACE_MODE_SGMII) {
> -                               val = readl(port->base + MVPP2_GMAC_AUTONEG_CONFIG);
> -                               val |= (MVPP2_GMAC_FORCE_LINK_PASS |
> -                                       MVPP2_GMAC_FORCE_LINK_DOWN);
> -                               writel(val, port->base + MVPP2_GMAC_AUTONEG_CONFIG);
> -                       }
> -
> -                       mvpp2_interrupts_enable(port);
> -                       mvpp2_port_enable(port);
> -
> -                       mvpp2_egress_enable(port);
> -                       mvpp2_ingress_enable(port);
> -                       netif_carrier_on(dev);
> -                       netif_tx_wake_all_queues(dev);
> -               } else {
> -                       port->duplex = -1;
> -                       port->speed = 0;
> -
> -                       netif_tx_stop_all_queues(dev);
> -                       netif_carrier_off(dev);
> -                       mvpp2_ingress_disable(port);
> -                       mvpp2_egress_disable(port);
> -
> -                       mvpp2_port_disable(port);
> -                       mvpp2_interrupts_disable(port);
> -               }
> -
> -               phy_print_status(phydev);
> -       }
> -}
> -
>  static void mvpp2_timer_set(struct mvpp2_port_pcpu *port_pcpu)
>  {
>         ktime_t interval;
> @@ -6582,7 +6481,6 @@ static int mvpp2_poll(struct napi_struct *napi, int budget)
>  /* Set hw internals when starting port */
>  static void mvpp2_start_dev(struct mvpp2_port *port)
>  {
> -       struct net_device *ndev = port->dev;
>         int i;
>
>         if (port->gop_id == 0 &&
> @@ -6607,15 +6505,14 @@ static void mvpp2_start_dev(struct mvpp2_port *port)
>
>         mvpp2_port_mii_set(port);
>         mvpp2_port_enable(port);
> -       if (ndev->phydev)
> -               phy_start(ndev->phydev);
> +       if (port->phylink)
> +               phylink_start(port->phylink);
>         netif_tx_start_all_queues(port->dev);
>  }
>
>  /* Set hw internals when stopping port */
>  static void mvpp2_stop_dev(struct mvpp2_port *port)
>  {
> -       struct net_device *ndev = port->dev;
>         int i;
>
>         /* Stop new packets from arriving to RXQs */
> @@ -6634,8 +6531,8 @@ static void mvpp2_stop_dev(struct mvpp2_port *port)
>
>         mvpp2_egress_disable(port);
>         mvpp2_port_disable(port);
> -       if (ndev->phydev)
> -               phy_stop(ndev->phydev);
> +       if (port->phylink)
> +               phylink_stop(port->phylink);
>         phy_power_off(port->comphy);
>  }
>
> @@ -6688,40 +6585,6 @@ static void mvpp21_get_mac_address(struct mvpp2_port *port, unsigned char *addr)
>         addr[5] = (mac_addr_l >> MVPP2_GMAC_SA_LOW_OFFS) & 0xFF;
>  }
>
> -static int mvpp2_phy_connect(struct mvpp2_port *port)
> -{
> -       struct phy_device *phy_dev;
> -
> -       /* No PHY is attached */
> -       if (!port->phy_node)
> -               return 0;
> -
> -       phy_dev = of_phy_connect(port->dev, port->phy_node, mvpp2_link_event, 0,
> -                                port->phy_interface);
> -       if (!phy_dev) {
> -               netdev_err(port->dev, "cannot connect to phy\n");
> -               return -ENODEV;
> -       }
> -       phy_dev->supported &= PHY_GBIT_FEATURES;
> -       phy_dev->advertising = phy_dev->supported;
> -
> -       port->link    = 0;
> -       port->duplex  = 0;
> -       port->speed   = 0;
> -
> -       return 0;
> -}
> -
> -static void mvpp2_phy_disconnect(struct mvpp2_port *port)
> -{
> -       struct net_device *ndev = port->dev;
> -
> -       if (!ndev->phydev)
> -               return;
> -
> -       phy_disconnect(ndev->phydev);
> -}
> -
>  static int mvpp2_irqs_init(struct mvpp2_port *port)
>  {
>         int err, i;
> @@ -6765,7 +6628,6 @@ static void mvpp2_irqs_deinit(struct mvpp2_port *port)
>  static int mvpp2_open(struct net_device *dev)
>  {
>         struct mvpp2_port *port = netdev_priv(dev);
> -       struct mvpp2 *priv = port->priv;
>         unsigned char mac_bcast[ETH_ALEN] = {
>                         0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
>         int err;
> @@ -6811,7 +6673,16 @@ static int mvpp2_open(struct net_device *dev)
>                 goto err_cleanup_txqs;
>         }
>
> -       if (priv->hw_version == MVPP22 && !port->phy_node && port->link_irq) {
> +       /* In default link is down */
> +       netif_carrier_off(port->dev);
> +
> +       if (port->phylink) {
> +               err = phylink_of_phy_connect(port->phylink, port->of_node);
> +               if (err) {
> +                       netdev_err(port->dev, "could not attach PHY (%d)\n", err);
> +                       goto err_free_irq;
> +               }
> +       } else if (port->link_irq) {
>                 err = request_irq(port->link_irq, mvpp2_link_status_isr, 0,
>                                   dev->name, port);
>                 if (err) {
> @@ -6821,15 +6692,11 @@ static int mvpp2_open(struct net_device *dev)
>                 }
>
>                 mvpp22_gop_setup_irq(port);
> +       } else {
> +               netdev_err(dev, "cannot use phylink or GoP link IRQ\n");
> +               goto err_free_irq;
>         }
>
> -       /* In default link is down */
> -       netif_carrier_off(port->dev);
> -
> -       err = mvpp2_phy_connect(port);
> -       if (err < 0)
> -               goto err_free_link_irq;
> -
>         /* Unmask interrupts on all CPUs */
>         on_each_cpu(mvpp2_interrupts_unmask, port, 1);
>         mvpp2_shared_interrupt_mask_unmask(port, false);
> @@ -6838,9 +6705,6 @@ static int mvpp2_open(struct net_device *dev)
>
>         return 0;
>
> -err_free_link_irq:
> -       if (priv->hw_version == MVPP22 && !port->phy_node && port->link_irq)
> -               free_irq(port->link_irq, port);
>  err_free_irq:
>         mvpp2_irqs_deinit(port);
>  err_cleanup_txqs:
> @@ -6854,17 +6718,17 @@ static int mvpp2_stop(struct net_device *dev)
>  {
>         struct mvpp2_port *port = netdev_priv(dev);
>         struct mvpp2_port_pcpu *port_pcpu;
> -       struct mvpp2 *priv = port->priv;
>         int cpu;
>
>         mvpp2_stop_dev(port);
> -       mvpp2_phy_disconnect(port);
> +       if (port->phylink)
> +               phylink_disconnect_phy(port->phylink);
>
>         /* Mask interrupts on all CPUs */
>         on_each_cpu(mvpp2_interrupts_mask, port, 1);
>         mvpp2_shared_interrupt_mask_unmask(port, true);
>
> -       if (priv->hw_version == MVPP22 && !port->phy_node && port->link_irq)
> +       if (port->link_irq)
>                 free_irq(port->link_irq, port);
>
>         mvpp2_irqs_deinit(port);
> @@ -7029,20 +6893,26 @@ mvpp2_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
>
>  static int mvpp2_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
>  {
> -       int ret;
> +       struct mvpp2_port *port = netdev_priv(dev);
>
> -       if (!dev->phydev)
> +       if (!port->phylink)
>                 return -ENOTSUPP;
>
> -       ret = phy_mii_ioctl(dev->phydev, ifr, cmd);
> -       if (!ret)
> -               mvpp2_link_event(dev);
> -
> -       return ret;
> +       return phylink_mii_ioctl(port->phylink, ifr, cmd);
>  }
>
>  /* Ethtool methods */
>
> +static int mvpp2_ethtool_nway_reset(struct net_device *dev)
> +{
> +       struct mvpp2_port *port = netdev_priv(dev);
> +
> +       if (!port->phylink)
> +               return -ENOTSUPP;
> +
> +       return phylink_ethtool_nway_reset(port->phylink);
> +}
> +
>  /* Set interrupt coalescing for ethtools */
>  static int mvpp2_ethtool_set_coalesce(struct net_device *dev,
>                                       struct ethtool_coalesce *c)
> @@ -7170,6 +7040,50 @@ static int mvpp2_ethtool_set_ringparam(struct net_device *dev,
>         return err;
>  }
>
> +static void mvpp2_ethtool_get_pause_param(struct net_device *dev,
> +                                         struct ethtool_pauseparam *pause)
> +{
> +       struct mvpp2_port *port = netdev_priv(dev);
> +
> +       if (!port->phylink)
> +               return;
> +
> +       phylink_ethtool_get_pauseparam(port->phylink, pause);
> +}
> +
> +static int mvpp2_ethtool_set_pause_param(struct net_device *dev,
> +                                        struct ethtool_pauseparam *pause)
> +{
> +       struct mvpp2_port *port = netdev_priv(dev);
> +
> +       if (!port->phylink)
> +               return -ENOTSUPP;
> +
> +       return phylink_ethtool_set_pauseparam(port->phylink, pause);
> +}
> +
> +static int mvpp2_ethtool_get_link_ksettings(struct net_device *dev,
> +                                           struct ethtool_link_ksettings *cmd)
> +{
> +       struct mvpp2_port *port = netdev_priv(dev);
> +
> +       if (!port->phylink)
> +               return -ENOTSUPP;
> +
> +       return phylink_ethtool_ksettings_get(port->phylink, cmd);
> +}
> +
> +static int mvpp2_ethtool_set_link_ksettings(struct net_device *dev,
> +                                           const struct ethtool_link_ksettings *cmd)
> +{
> +       struct mvpp2_port *port = netdev_priv(dev);
> +
> +       if (!port->phylink)
> +               return -ENOTSUPP;
> +
> +       return phylink_ethtool_ksettings_set(port->phylink, cmd);
> +}
> +
>  /* Device ops */
>
>  static const struct net_device_ops mvpp2_netdev_ops = {
> @@ -7184,15 +7098,17 @@ static const struct net_device_ops mvpp2_netdev_ops = {
>  };
>
>  static const struct ethtool_ops mvpp2_eth_tool_ops = {
> -       .nway_reset     = phy_ethtool_nway_reset,
> +       .nway_reset     = mvpp2_ethtool_nway_reset,
>         .get_link       = ethtool_op_get_link,
>         .set_coalesce   = mvpp2_ethtool_set_coalesce,
>         .get_coalesce   = mvpp2_ethtool_get_coalesce,
>         .get_drvinfo    = mvpp2_ethtool_get_drvinfo,
>         .get_ringparam  = mvpp2_ethtool_get_ringparam,
>         .set_ringparam  = mvpp2_ethtool_set_ringparam,
> -       .get_link_ksettings = phy_ethtool_get_link_ksettings,
> -       .set_link_ksettings = phy_ethtool_set_link_ksettings,
> +       .get_pauseparam = mvpp2_ethtool_get_pause_param,
> +       .set_pauseparam = mvpp2_ethtool_set_pause_param,
> +       .get_link_ksettings = mvpp2_ethtool_get_link_ksettings,
> +       .set_link_ksettings = mvpp2_ethtool_set_link_ksettings,
>  };
>
>  /* Used for PPv2.1, or PPv2.2 with the old Device Tree binding that
> @@ -7492,17 +7408,185 @@ static void mvpp2_port_copy_mac_addr(struct net_device *dev, struct mvpp2 *priv,
>         eth_hw_addr_random(dev);
>  }
>
> +static void mvpp2_phylink_validate(struct net_device *dev,
> +                                  unsigned long *supported,
> +                                  struct phylink_link_state *state)
> +{
> +       __ETHTOOL_DECLARE_LINK_MODE_MASK(mask) = { 0, };
> +
> +       phylink_set_port_modes(mask);
> +
> +       phylink_set(mask, Autoneg);
> +       phylink_set(mask, Pause);
> +       phylink_set(mask, Asym_Pause);
> +
> +       phylink_set(mask, 10baseT_Half);
> +       phylink_set(mask, 10baseT_Full);
> +       phylink_set(mask, 100baseT_Half);
> +       phylink_set(mask, 100baseT_Full);
> +       phylink_set(mask, 1000baseT_Half);
> +       phylink_set(mask, 1000baseT_Full);
> +       phylink_set(mask, 1000baseX_Full);
> +       phylink_set(mask, 10000baseKR_Full);
> +
> +       bitmap_and(supported, supported, mask, __ETHTOOL_LINK_MODE_MASK_NBITS);
> +       bitmap_and(state->advertising, state->advertising, mask,
> +                  __ETHTOOL_LINK_MODE_MASK_NBITS);
> +}
> +
> +static int mvpp2_phylink_mac_link_state(struct net_device *dev,
> +                                       struct phylink_link_state *state)
> +{
> +       struct mvpp2_port *port = netdev_priv(dev);
> +       u32 val;
> +
> +       if (!phy_interface_mode_is_rgmii(port->phy_interface) &&
> +           port->phy_interface != PHY_INTERFACE_MODE_SGMII)
> +               return 0;
> +
> +       val = readl(port->base + MVPP2_GMAC_STATUS0);
> +
> +       state->an_complete = !!(val & MVPP2_GMAC_STATUS0_AN_COMPLETE);
> +       state->link = !!(val & MVPP2_GMAC_STATUS0_LINK_UP);
> +       state->duplex = !!(val & MVPP2_GMAC_STATUS0_FULL_DUPLEX);
> +
> +       if (val & MVPP2_GMAC_STATUS0_GMII_SPEED)
> +               state->speed = SPEED_1000;
> +       else
> +               state->speed = (val & MVPP2_GMAC_STATUS0_MII_SPEED) ?
> +                              SPEED_100 : SPEED_10;
> +
> +       state->pause = 0;
> +       if (val & MVPP2_GMAC_STATUS0_RX_PAUSE)
> +               state->pause |= MLO_PAUSE_RX;
> +       if (val & MVPP2_GMAC_STATUS0_TX_PAUSE)
> +               state->pause |= MLO_PAUSE_TX;
> +
> +       return 1;
> +}
> +
> +static void mvpp2_mac_an_restart(struct net_device *dev)
> +{
> +       struct mvpp2_port *port = netdev_priv(dev);
> +       u32 val;
> +
> +       if (!phy_interface_mode_is_rgmii(port->phy_interface) &&
> +           port->phy_interface != PHY_INTERFACE_MODE_SGMII)
> +               return;
> +
> +       val = readl(port->base + MVPP2_GMAC_AUTONEG_CONFIG);
> +       val |= MVPP2_GMAC_IN_BAND_RESTART_AN;
> +       writel(val, port->base + MVPP2_GMAC_AUTONEG_CONFIG);
> +}
> +
> +static void mvpp2_mac_config(struct net_device *dev, unsigned int mode,
> +                            const struct phylink_link_state *state)
> +{
> +       struct mvpp2_port *port = netdev_priv(dev);
> +       u32 val;
> +
> +       /* disable current port for reconfiguration */
> +       mvpp2_interrupts_disable(port);
> +       netif_carrier_off(port->dev);
> +       mvpp2_port_disable(port);
> +       phy_power_off(port->comphy);
> +
> +       /* comphy reconfiguration */
> +       port->phy_interface = state->interface;
> +       mvpp22_comphy_init(port);
> +
> +       /* gop/mac reconfiguration */
> +       mvpp22_gop_init(port);
> +       mvpp2_port_mii_set(port);
> +
> +       if (!phy_interface_mode_is_rgmii(port->phy_interface) &&
> +           port->phy_interface != PHY_INTERFACE_MODE_SGMII)
> +               return;
> +
> +       val = readl(port->base + MVPP2_GMAC_AUTONEG_CONFIG);
> +       val &= ~(MVPP2_GMAC_CONFIG_MII_SPEED |
> +                MVPP2_GMAC_CONFIG_GMII_SPEED |
> +                MVPP2_GMAC_CONFIG_FULL_DUPLEX |
> +                MVPP2_GMAC_AN_SPEED_EN |
> +                MVPP2_GMAC_AN_DUPLEX_EN);
> +
> +       if (state->duplex)
> +               val |= MVPP2_GMAC_CONFIG_FULL_DUPLEX;
> +
> +       if (state->speed == SPEED_1000)
> +               val |= MVPP2_GMAC_CONFIG_GMII_SPEED;
> +       else if (state->speed == SPEED_100)
> +               val |= MVPP2_GMAC_CONFIG_MII_SPEED;
> +
> +       writel(val, port->base + MVPP2_GMAC_AUTONEG_CONFIG);
> +
> +       if (port->priv->hw_version == MVPP21 && port->flags & MVPP2_F_LOOPBACK)
> +               mvpp2_port_loopback_set(port, state);
> +}
> +
> +static void mvpp2_mac_link_down(struct net_device *dev, unsigned int mode)
> +{
> +       struct mvpp2_port *port = netdev_priv(dev);
> +       u32 val;
> +
> +       netif_tx_stop_all_queues(dev);
> +       netif_carrier_off(dev);
> +       mvpp2_ingress_disable(port);
> +       mvpp2_egress_disable(port);
> +
> +       mvpp2_port_disable(port);
> +       mvpp2_interrupts_disable(port);
> +
> +       if (!phylink_autoneg_inband(mode)) {
> +               val = readl(port->base + MVPP2_GMAC_AUTONEG_CONFIG);
> +               val &= ~MVPP2_GMAC_FORCE_LINK_PASS;
> +               val |= MVPP2_GMAC_FORCE_LINK_DOWN;
> +               writel(val, port->base + MVPP2_GMAC_AUTONEG_CONFIG);
> +       }
> +}
> +
> +static void mvpp2_mac_link_up(struct net_device *dev, unsigned int mode,
> +                             struct phy_device *phy)
> +{
> +       struct mvpp2_port *port = netdev_priv(dev);
> +       u32 val;
> +
> +       if (!phylink_autoneg_inband(mode)) {
> +               val = readl(port->base + MVPP2_GMAC_AUTONEG_CONFIG);
> +               val &= ~MVPP2_GMAC_FORCE_LINK_DOWN;
> +               val |= MVPP2_GMAC_FORCE_LINK_PASS;
> +               writel(val, port->base + MVPP2_GMAC_AUTONEG_CONFIG);
> +       }
> +
> +       mvpp2_interrupts_enable(port);
> +       mvpp2_port_enable(port);
> +
> +       mvpp2_egress_enable(port);
> +       mvpp2_ingress_enable(port);
> +       netif_carrier_on(dev);
> +       netif_tx_wake_all_queues(dev);
> +}
> +
> +static const struct phylink_mac_ops mvpp2_phylink_ops = {
> +       .validate = mvpp2_phylink_validate,
> +       .mac_link_state = mvpp2_phylink_mac_link_state,
> +       .mac_an_restart = mvpp2_mac_an_restart,
> +       .mac_config = mvpp2_mac_config,
> +       .mac_link_down = mvpp2_mac_link_down,
> +       .mac_link_up = mvpp2_mac_link_up,
> +};
> +
>  /* Ports initialization */
>  static int mvpp2_port_probe(struct platform_device *pdev,
>                             struct device_node *port_node,
>                             struct mvpp2 *priv)
>  {
> -       struct device_node *phy_node;
>         struct phy *comphy;
>         struct mvpp2_port *port;
>         struct mvpp2_port_pcpu *port_pcpu;
>         struct net_device *dev;
>         struct resource *res;
> +       struct phylink *phylink;
>         char *mac_from = "";
>         unsigned int ntxqs, nrxqs;
>         bool has_tx_irqs;
> @@ -7526,7 +7610,6 @@ static int mvpp2_port_probe(struct platform_device *pdev,
>         if (!dev)
>                 return -ENOMEM;
>
> -       phy_node = of_parse_phandle(port_node, "phy", 0);
>         phy_mode = of_get_phy_mode(port_node);
>         if (phy_mode < 0) {
>                 dev_err(&pdev->dev, "incorrect phy mode\n");
> @@ -7565,15 +7648,6 @@ static int mvpp2_port_probe(struct platform_device *pdev,
>         if (err)
>                 goto err_free_netdev;
>
> -       port->link_irq = of_irq_get_byname(port_node, "link");
> -       if (port->link_irq == -EPROBE_DEFER) {
> -               err = -EPROBE_DEFER;
> -               goto err_deinit_qvecs;
> -       }
> -       if (port->link_irq <= 0)
> -               /* the link irq is optional */
> -               port->link_irq = 0;
> -
>         if (of_property_read_bool(port_node, "marvell,loopback"))
>                 port->flags |= MVPP2_F_LOOPBACK;
>
> @@ -7583,7 +7657,7 @@ static int mvpp2_port_probe(struct platform_device *pdev,
>         else
>                 port->first_rxq = port->id * priv->max_port_rxqs;
>
> -       port->phy_node = phy_node;
> +       port->of_node = port_node;
>         port->phy_interface = phy_mode;
>         port->comphy = comphy;
>
> @@ -7592,7 +7666,7 @@ static int mvpp2_port_probe(struct platform_device *pdev,
>                 port->base = devm_ioremap_resource(&pdev->dev, res);
>                 if (IS_ERR(port->base)) {
>                         err = PTR_ERR(port->base);
> -                       goto err_free_irq;
> +                       goto err_deinit_qvecs;
>                 }
>         } else {
>                 if (of_property_read_u32(port_node, "gop-port-id",
> @@ -7609,7 +7683,7 @@ static int mvpp2_port_probe(struct platform_device *pdev,
>         port->stats = netdev_alloc_pcpu_stats(struct mvpp2_pcpu_stats);
>         if (!port->stats) {
>                 err = -ENOMEM;
> -               goto err_free_irq;
> +               goto err_deinit_qvecs;
>         }
>
>         mvpp2_port_copy_mac_addr(dev, priv, port_node, &mac_from);
> @@ -7662,16 +7736,47 @@ static int mvpp2_port_probe(struct platform_device *pdev,
>         /* 9676 == 9700 - 20 and rounding to 8 */
>         dev->max_mtu = 9676;
>
> +       /* The PHY node is optional. If not present the GoP link IRQ will be
> +        * used to handle link updates. Otherwise use phylink.
> +        */
> +       if (of_find_property(port_node, "phy", NULL)) {
> +               phylink = phylink_create(dev, port_node, phy_mode,
> +                                        &mvpp2_phylink_ops);
> +               if (IS_ERR(phylink)) {
> +                       err = PTR_ERR(phylink);
> +                       goto err_free_port_pcpu;
> +               }
> +               port->phylink = phylink;
> +               port->link_irq = 0;
> +       } else {
> +               port->phylink = NULL;
> +               if (priv->hw_version == MVPP22) {
> +                       port->link_irq = of_irq_get_byname(port_node, "link");
> +                       if (port->link_irq == -EPROBE_DEFER) {
> +                               err = -EPROBE_DEFER;
> +                               goto err_free_port_pcpu;
> +                       }
> +                       if (port->link_irq <= 0)
> +                               /* the link irq is optional */
> +                               port->link_irq = 0;
> +               }
> +       }
> +
>         err = register_netdev(dev);
>         if (err < 0) {
>                 dev_err(&pdev->dev, "failed to register netdev\n");
> -               goto err_free_port_pcpu;
> +               goto err_phylink_irq;
>         }
>         netdev_info(dev, "Using %s mac address %pM\n", mac_from, dev->dev_addr);
>
>         priv->port_list[id] = port;
>         return 0;
>
> +err_phylink_irq:
> +       if (port->phylink)
> +               phylink_destroy(port->phylink);
> +       else if (port->link_irq)
> +               irq_dispose_mapping(port->link_irq);
>  err_free_port_pcpu:
>         free_percpu(port->pcpu);
>  err_free_txq_pcpu:
> @@ -7679,13 +7784,9 @@ static int mvpp2_port_probe(struct platform_device *pdev,
>                 free_percpu(port->txqs[i]->pcpu);
>  err_free_stats:
>         free_percpu(port->stats);
> -err_free_irq:
> -       if (port->link_irq)
> -               irq_dispose_mapping(port->link_irq);
>  err_deinit_qvecs:
>         mvpp2_queue_vectors_deinit(port);
>  err_free_netdev:
> -       of_node_put(phy_node);
>         free_netdev(dev);
>         return err;
>  }
> @@ -7696,7 +7797,8 @@ static void mvpp2_port_remove(struct mvpp2_port *port)
>         int i;
>
>         unregister_netdev(port->dev);
> -       of_node_put(port->phy_node);
> +       if (port->phylink)
> +               phylink_destroy(port->phylink);
>         free_percpu(port->pcpu);
>         free_percpu(port->stats);
>         for (i = 0; i < port->ntxqs; i++)
> --
> 2.13.5
>
