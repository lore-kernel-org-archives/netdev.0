From: Marcin Wojtas <mw@semihalf.com>
Subject: Re: [PATCH net-next 10/18] net: mvpp2: use the GoP interrupt for link
 status changes
Date: Tue, 25 Jul 2017 00:58:20 +0200
Message-ID: <CAPv3WKcHtAKPKcfdC7xE-duhwMSRgSRW9_2B33Ru3KNfczZzMA@mail.gmail.com>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com> <20170724134848.19330-11-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        =?UTF-8?Q?Gregory_Cl=C3=A9ment?=
        <gregory.clement@free-electrons.com>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        nadavh@marvell.com,
        Russell King - ARM Linux <linux@armlinux.org.uk>,
        Stefan Chulski <stefanc@marvell.com>, netdev@vger.kernel.org,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:32867 "EHLO
        mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752026AbdGXW6W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 18:58:22 -0400
Received: by mail-io0-f179.google.com with SMTP id j32so28311854iod.0
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 15:58:22 -0700 (PDT)
In-Reply-To: <20170724134848.19330-11-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Antoine,

This patch requires also:

diff --git a/drivers/net/ethernet/marvell/mvpp2.c
b/drivers/net/ethernet/marvell/mvpp2.c
index 4694d4f..369819f 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -6625,6 +6625,7 @@ static int mvpp2_stop(struct net_device *dev)
 {
        struct mvpp2_port *port = netdev_priv(dev);
        struct mvpp2_port_pcpu *port_pcpu;
+       struct mvpp2 *priv = port->priv;
        int cpu;

        mvpp2_stop_dev(port);
@@ -6633,6 +6634,10 @@ static int mvpp2_stop(struct net_device *dev)
        /* Mask interrupts on all CPUs */
        on_each_cpu(mvpp2_interrupts_mask, port, 1);

+       if (priv->hw_version == MVPP22 && !port->phy_node && port->link_irq) {
+               free_irq(port->link_irq, port);
+       }
+
        free_irq(port->irq, port);
        for_each_present_cpu(cpu) {
                port_pcpu = per_cpu_ptr(port->pcpu, cpu);

Otherwise a sequence: ifconfig up/down/up results in faults.

Best regards,
Marcin

2017-07-24 15:48 GMT+02:00 Antoine Tenart <antoine.tenart@free-electrons.com>:
> This patch adds the GoP link interrupt support for when a port isn't
> connected to a PHY. Because of this the phylib callback is never called
> and the link status management isn't done. This patch use the GoP link
> interrupt in such cases to still have a minimal link management. Without
> this patch ports not connected to a PHY cannot work.
>
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
> ---
>  drivers/net/ethernet/marvell/mvpp2.c | 157 ++++++++++++++++++++++++++++++++++-
>  1 file changed, 154 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
> index 77eef2cc40a1..33a7eb834855 100644
> --- a/drivers/net/ethernet/marvell/mvpp2.c
> +++ b/drivers/net/ethernet/marvell/mvpp2.c
> @@ -339,16 +339,24 @@
>  #define     MVPP2_GMAC_FLOW_CTRL_AUTONEG       BIT(11)
>  #define     MVPP2_GMAC_CONFIG_FULL_DUPLEX      BIT(12)
>  #define     MVPP2_GMAC_AN_DUPLEX_EN            BIT(13)
> +#define MVPP2_GMAC_STATUS0                     0x10
> +#define     MVPP2_GMAC_STATUS0_LINK_UP         BIT(0)
>  #define MVPP2_GMAC_PORT_FIFO_CFG_1_REG         0x1c
>  #define     MVPP2_GMAC_TX_FIFO_MIN_TH_OFFS     6
>  #define     MVPP2_GMAC_TX_FIFO_MIN_TH_ALL_MASK 0x1fc0
>  #define     MVPP2_GMAC_TX_FIFO_MIN_TH_MASK(v)  (((v) << 6) & \
>                                         MVPP2_GMAC_TX_FIFO_MIN_TH_ALL_MASK)
> +#define MVPP22_GMAC_INT_STAT                   0x20
> +#define     MVPP22_GMAC_INT_STAT_LINK          BIT(1)
> +#define MVPP22_GMAC_INT_MASK                   0x24
> +#define     MVPP22_GMAC_INT_MASK_LINK_STAT     BIT(1)
>  #define MVPP22_GMAC_CTRL_4_REG                 0x90
>  #define     MVPP22_CTRL4_EXT_PIN_GMII_SEL      BIT(0)
>  #define     MVPP22_CTRL4_DP_CLK_SEL            BIT(5)
>  #define     MVPP22_CTRL4_SYNC_BYPASS_DIS       BIT(6)
>  #define     MVPP22_CTRL4_QSGMII_BYPASS_ACTIVE  BIT(7)
> +#define MVPP22_GMAC_INT_SUM_MASK               0xa4
> +#define     MVPP22_GMAC_INT_SUM_MASK_LINK_STAT BIT(1)
>
>  /* Per-port XGMAC registers. PPv2.2 only, only for GOP port 0,
>   * relative to port->base.
> @@ -358,12 +366,19 @@
>  #define     MVPP22_XLG_CTRL0_MAC_RESET_DIS     BIT(1)
>  #define     MVPP22_XLG_CTRL0_RX_FLOW_CTRL_EN   BIT(7)
>  #define     MVPP22_XLG_CTRL0_MIB_CNT_DIS       BIT(14)
> -
> +#define MVPP22_XLG_STATUS                      0x10c
> +#define     MVPP22_XLG_STATUS_LINK_UP          BIT(0)
> +#define MVPP22_XLG_INT_STAT                    0x114
> +#define     MVPP22_XLG_INT_STAT_LINK           BIT(1)
> +#define MVPP22_XLG_INT_MASK                    0x118
> +#define     MVPP22_XLG_INT_MASK_LINK           BIT(1)
>  #define MVPP22_XLG_CTRL3_REG                   0x11c
>  #define     MVPP22_XLG_CTRL3_MACMODESELECT_MASK        (7 << 13)
>  #define     MVPP22_XLG_CTRL3_MACMODESELECT_GMAC        (0 << 13)
>  #define     MVPP22_XLG_CTRL3_MACMODESELECT_10G (1 << 13)
> -
> +#define MVPP22_XLG_EXT_INT_MASK                        0x15c
> +#define     MVPP22_XLG_EXT_INT_MASK_XLG                BIT(1)
> +#define     MVPP22_XLG_EXT_INT_MASK_GIG                BIT(2)
>  #define MVPP22_XLG_CTRL4_REG                   0x184
>  #define     MVPP22_XLG_CTRL4_FWD_FC            BIT(5)
>  #define     MVPP22_XLG_CTRL4_FWD_PFC           BIT(6)
> @@ -814,6 +829,7 @@ struct mvpp2_port {
>         int gop_id;
>
>         int irq;
> +       int link_irq;
>
>         struct mvpp2 *priv;
>
> @@ -4330,6 +4346,63 @@ static int mvpp22_gop_init(struct mvpp2_port *port)
>         return -EINVAL;
>  }
>
> +static void mvpp22_gop_unmask_irq(struct mvpp2_port *port)
> +{
> +       u32 val;
> +
> +       if (port->phy_interface == PHY_INTERFACE_MODE_RGMII ||
> +           port->phy_interface == PHY_INTERFACE_MODE_SGMII) {
> +               /* Enable the GMAC link status irq for this port */
> +               val = readl(port->base + MVPP22_GMAC_INT_SUM_MASK);
> +               val |= MVPP22_GMAC_INT_SUM_MASK_LINK_STAT;
> +               writel(val, port->base + MVPP22_GMAC_INT_SUM_MASK);
> +       }
> +
> +       /* Enable the XLG/GIG irqs for this port */
> +       val = readl(port->base + MVPP22_XLG_EXT_INT_MASK);
> +       if (port->gop_id == 0 &&
> +           port->phy_interface == PHY_INTERFACE_MODE_10GKR)
> +               val |= MVPP22_XLG_EXT_INT_MASK_XLG;
> +       else
> +               val |= MVPP22_XLG_EXT_INT_MASK_GIG;
> +       writel(val, port->base + MVPP22_XLG_EXT_INT_MASK);
> +}
> +
> +static void mvpp22_gop_mask_irq(struct mvpp2_port *port)
> +{
> +       u32 val;
> +
> +       val = readl(port->base + MVPP22_XLG_EXT_INT_MASK);
> +       val &= ~(MVPP22_XLG_EXT_INT_MASK_XLG |
> +                MVPP22_XLG_EXT_INT_MASK_GIG);
> +       writel(val, port->base + MVPP22_XLG_EXT_INT_MASK);
> +
> +       if (port->phy_interface == PHY_INTERFACE_MODE_RGMII ||
> +           port->phy_interface == PHY_INTERFACE_MODE_SGMII) {
> +               val = readl(port->base + MVPP22_GMAC_INT_SUM_MASK);
> +               val &= ~MVPP22_GMAC_INT_SUM_MASK_LINK_STAT;
> +               writel(val, port->base + MVPP22_GMAC_INT_SUM_MASK);
> +       }
> +}
> +
> +static void mvpp22_gop_setup_irq(struct mvpp2_port *port)
> +{
> +       u32 val;
> +
> +       if (port->phy_interface == PHY_INTERFACE_MODE_RGMII ||
> +           port->phy_interface == PHY_INTERFACE_MODE_SGMII) {
> +               val = readl(port->base + MVPP22_GMAC_INT_MASK);
> +               val |= MVPP22_GMAC_INT_MASK_LINK_STAT;
> +               writel(val, port->base + MVPP22_GMAC_INT_MASK);
> +       }
> +
> +       val = readl(port->base + MVPP22_XLG_INT_MASK);
> +       val |= MVPP22_XLG_INT_MASK_LINK;
> +       writel(val, port->base + MVPP22_XLG_INT_MASK);
> +
> +       mvpp22_gop_unmask_irq(port);
> +}
> +
>  static void mvpp2_port_mii_gmac_configure_mode(struct mvpp2_port *port)
>  {
>         u32 val;
> @@ -5529,6 +5602,60 @@ static irqreturn_t mvpp2_isr(int irq, void *dev_id)
>         return IRQ_HANDLED;
>  }
>
> +/* Per-port interrupt for link status changes */
> +static irqreturn_t mvpp2_link_status_isr(int irq, void *dev_id)
> +{
> +       struct mvpp2_port *port = (struct mvpp2_port *)dev_id;
> +       struct net_device *dev = port->dev;
> +       bool event = false, link = false;
> +       u32 val;
> +
> +       mvpp22_gop_mask_irq(port);
> +
> +       if (port->gop_id == 0 &&
> +           port->phy_interface == PHY_INTERFACE_MODE_10GKR) {
> +               val = readl(port->base + MVPP22_XLG_INT_STAT);
> +               if (val & MVPP22_XLG_INT_STAT_LINK) {
> +                       event = true;
> +                       val = readl(port->base + MVPP22_XLG_STATUS);
> +                       if (val & MVPP22_XLG_STATUS_LINK_UP)
> +                               link = true;
> +               }
> +       } else if (port->phy_interface == PHY_INTERFACE_MODE_RGMII ||
> +                  port->phy_interface == PHY_INTERFACE_MODE_SGMII) {
> +               val = readl(port->base + MVPP22_GMAC_INT_STAT);
> +               if (val & MVPP22_GMAC_INT_STAT_LINK) {
> +                       event = true;
> +                       val = readl(port->base + MVPP2_GMAC_STATUS0);
> +                       if (val & MVPP2_GMAC_STATUS0_LINK_UP)
> +                               link = true;
> +               }
> +       }
> +
> +       if (!netif_running(dev) || !event)
> +               goto handled;
> +
> +       if (link) {
> +               mvpp2_interrupts_enable(port);
> +
> +               mvpp2_egress_enable(port);
> +               mvpp2_ingress_enable(port);
> +               netif_carrier_on(dev);
> +               netif_tx_wake_all_queues(dev);
> +       } else {
> +               netif_tx_stop_all_queues(dev);
> +               netif_carrier_off(dev);
> +               mvpp2_ingress_disable(port);
> +               mvpp2_egress_disable(port);
> +
> +               mvpp2_interrupts_disable(port);
> +       }
> +
> +handled:
> +       mvpp22_gop_unmask_irq(port);
> +       return IRQ_HANDLED;
> +}
> +
>  /* Adjust link */
>  static void mvpp2_link_event(struct net_device *dev)
>  {
> @@ -6221,6 +6348,7 @@ static void mvpp2_phy_disconnect(struct mvpp2_port *port)
>  static int mvpp2_open(struct net_device *dev)
>  {
>         struct mvpp2_port *port = netdev_priv(dev);
> +       struct mvpp2 *priv = port->priv;
>         unsigned char mac_bcast[ETH_ALEN] = {
>                         0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
>         int err;
> @@ -6266,12 +6394,24 @@ static int mvpp2_open(struct net_device *dev)
>                 goto err_cleanup_txqs;
>         }
>
> +       if (priv->hw_version == MVPP22 && !port->phy_node && port->link_irq) {
> +               err = request_irq(port->link_irq, mvpp2_link_status_isr, 0,
> +                                 dev->name, port);
> +               if (err) {
> +                       netdev_err(port->dev, "cannot request link IRQ %d\n",
> +                                  port->link_irq);
> +                       goto err_free_irq;
> +               }
> +
> +               mvpp22_gop_setup_irq(port);
> +       }
> +
>         /* In default link is down */
>         netif_carrier_off(port->dev);
>
>         err = mvpp2_phy_connect(port);
>         if (err < 0)
> -               goto err_free_irq;
> +               goto err_free_link_irq;
>
>         /* Unmask interrupts on all CPUs */
>         on_each_cpu(mvpp2_interrupts_unmask, port, 1);
> @@ -6280,6 +6420,8 @@ static int mvpp2_open(struct net_device *dev)
>
>         return 0;
>
> +err_free_link_irq:
> +       free_irq(port->link_irq, port);
>  err_free_irq:
>         free_irq(port->irq, port);
>  err_cleanup_txqs:
> @@ -6796,6 +6938,15 @@ static int mvpp2_port_probe(struct platform_device *pdev,
>                               -EPROBE_DEFER : -EINVAL;
>                         goto err_free_netdev;
>                 }
> +
> +               port->link_irq = of_irq_get_byname(port_node, "link");
> +               if (port->link_irq == -EPROBE_DEFER) {
> +                       err = -EPROBE_DEFER;
> +                       goto err_free_irq;
> +               }
> +               if (port->link_irq <= 0)
> +                       /* the link irq is optional */
> +                       port->link_irq = 0;
>         } else {
>                 /* kept for dt compatibility */
>                 port->irq = irq_of_parse_and_map(port_node, 0);
> --
> 2.13.3
>
