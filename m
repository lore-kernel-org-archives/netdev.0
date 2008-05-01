From: "Grant Likely" <grant.likely@secretlab.ca>
Subject: Re: [PATCH] [POWERPC] mpc5200: Allow for fixed speed MII configurations
Date: Thu, 1 May 2008 08:33:24 -0600
Message-ID: <fa686aa40805010733o6bb5b522hd16669b732f1892@mail.gmail.com>
References: <20080429230620.11248.25729.stgit@trillian.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: wg@grandegger.com, linuxppc-dev@ozlabs.org, paulus@samba.org,
	netdev@vger.kernel.org, wd@denx.de,
	"Domen Puncer" <domen@coderock.org>,
	"Sylvain Munaut" <tnt@246tnt.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.224]:58815 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753639AbYEAOdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 10:33:25 -0400
Received: by wr-out-0506.google.com with SMTP id c48so647497wra.1
        for <netdev@vger.kernel.org>; Thu, 01 May 2008 07:33:24 -0700 (PDT)
In-Reply-To: <20080429230620.11248.25729.stgit@trillian.secretlab.ca>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 29, 2008 at 5:06 PM, Grant Likely <grant.likely@secretlab.ca> wrote:
> From: Grant Likely <grant.likely@secretlab.ca>
>
>  Various improvements for configuring the MPC5200 MII link from the
>  device tree:
>  * Look for 'current-speed' property for fixed speed MII links
>  * Look for 'fsl,7-wire-mode' property for boards using the 7 wire mode
>  * move definition of private data structure out of the header file
>
>  Signed-off-by: Grant Likely <grant.likely@secretlab.ca>

Any more comments on this patch?  I want to push it to Paulus, but I'd
like to have someone ack it first.

Wolfgang, you used the previous version of this patch.  Does this one
work for you?

Cheers,
g.

>  ---
>
>   .../powerpc/mpc52xx-device-tree-bindings.txt       |   11 ++
>   drivers/net/fec_mpc52xx.c                          |   96 +++++++++++++++-----
>   drivers/net/fec_mpc52xx.h                          |   19 ----
>   3 files changed, 85 insertions(+), 41 deletions(-)
>
>  diff --git a/Documentation/powerpc/mpc52xx-device-tree-bindings.txt b/Documentation/powerpc/mpc52xx-device-tree-bindings.txt
>  index cda7a7d..6f12f1c 100644
>  --- a/Documentation/powerpc/mpc52xx-device-tree-bindings.txt
>  +++ b/Documentation/powerpc/mpc52xx-device-tree-bindings.txt
>  @@ -237,6 +237,17 @@ Each GPIO controller node should have the empty property gpio-controller and
>   according to the bit numbers in the GPIO control registers. The second cell
>   is for flags which is currently unsused.
>
>  +8) FEC nodes
>  +The FEC node can specify one of the following properties to configure
>  +the MII link:
>  +"fsl,7-wire-mode" - An empty property that specifies the link uses 7-wire
>  +                    mode instead of MII
>  +"current-speed"   - Specifies that the MII should be configured for a fixed
>  +                    speed.  This property should contain two cells.  The
>  +                    first cell specifies the speed in Mbps and the second
>  +                    should be '0' for half duplex and '1' for full duplex
>  +"phy-handle"      - Contains a phandle to an Ethernet PHY.
>  +
>   IV - Extra Notes
>   ================
>
>  diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
>  index d21b7ab..eeb4433 100644
>  --- a/drivers/net/fec_mpc52xx.c
>  +++ b/drivers/net/fec_mpc52xx.c
>  @@ -43,6 +43,29 @@
>
>   #define DRIVER_NAME "mpc52xx-fec"
>
>  +#define FEC5200_PHYADDR_NONE   (-1)
>  +#define FEC5200_PHYADDR_7WIRE  (-2)
>  +
>  +/* Private driver data structure */
>  +struct mpc52xx_fec_priv {
>  +       int duplex;
>  +       int speed;
>  +       int r_irq;
>  +       int t_irq;
>  +       struct mpc52xx_fec __iomem *fec;
>  +       struct bcom_task *rx_dmatsk;
>  +       struct bcom_task *tx_dmatsk;
>  +       spinlock_t lock;
>  +       int msg_enable;
>  +
>  +       /* MDIO link details */
>  +       int phy_addr;
>  +       unsigned int phy_speed;
>  +       struct phy_device *phydev;
>  +       enum phy_state link;
>  +};
>  +
>  +
>   static irqreturn_t mpc52xx_fec_interrupt(int, void *);
>   static irqreturn_t mpc52xx_fec_rx_interrupt(int, void *);
>   static irqreturn_t mpc52xx_fec_tx_interrupt(int, void *);
>  @@ -223,7 +246,7 @@ static int mpc52xx_fec_phy_start(struct net_device *dev)
>         struct mpc52xx_fec_priv *priv = netdev_priv(dev);
>         int err;
>
>  -       if (!priv->has_phy)
>  +       if (priv->phy_addr < 0)
>                 return 0;
>
>         err = mpc52xx_fec_init_phy(dev);
>  @@ -243,7 +266,7 @@ static void mpc52xx_fec_phy_stop(struct net_device *dev)
>   {
>         struct mpc52xx_fec_priv *priv = netdev_priv(dev);
>
>  -       if (!priv->has_phy)
>  +       if (!priv->phydev)
>                 return;
>
>         phy_disconnect(priv->phydev);
>  @@ -255,7 +278,7 @@ static void mpc52xx_fec_phy_stop(struct net_device *dev)
>   static int mpc52xx_fec_phy_mii_ioctl(struct mpc52xx_fec_priv *priv,
>                 struct mii_ioctl_data *mii_data, int cmd)
>   {
>  -       if (!priv->has_phy)
>  +       if (!priv->phydev)
>                 return -ENOTSUPP;
>
>         return phy_mii_ioctl(priv->phydev, mii_data, cmd);
>  @@ -265,7 +288,7 @@ static void mpc52xx_fec_phy_hw_init(struct mpc52xx_fec_priv *priv)
>   {
>         struct mpc52xx_fec __iomem *fec = priv->fec;
>
>  -       if (!priv->has_phy)
>  +       if (priv->phydev)
>                 return;
>
>         out_be32(&fec->mii_speed, priv->phy_speed);
>  @@ -704,7 +727,7 @@ static void mpc52xx_fec_start(struct net_device *dev)
>         rcntrl = FEC_RX_BUFFER_SIZE << 16;      /* max frame length */
>         rcntrl |= FEC_RCNTRL_FCE;
>
>  -       if (priv->has_phy)
>  +       if (priv->phy_addr != FEC5200_PHYADDR_7WIRE)
>                 rcntrl |= FEC_RCNTRL_MII_MODE;
>
>         if (priv->duplex == DUPLEX_FULL)
>  @@ -864,7 +887,10 @@ mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
>         struct net_device *ndev;
>         struct mpc52xx_fec_priv *priv = NULL;
>         struct resource mem;
>  -       const phandle *ph;
>  +       struct device_node *phy_node;
>  +       const phandle *phy_handle;
>  +       const u32 *prop;
>  +       int prop_size;
>
>         phys_addr_t rx_fifo;
>         phys_addr_t tx_fifo;
>  @@ -950,24 +976,36 @@ mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
>         priv->msg_enable = netif_msg_init(debug, MPC52xx_MESSAGES_DEFAULT);
>         priv->duplex = DUPLEX_FULL;
>
>  -       /* is the phy present in device tree? */
>  -       ph = of_get_property(op->node, "phy-handle", NULL);
>  -       if (ph) {
>  -               const unsigned int *prop;
>  -               struct device_node *phy_dn;
>  -               priv->has_phy = 1;
>  -
>  -               phy_dn = of_find_node_by_phandle(*ph);
>  -               prop = of_get_property(phy_dn, "reg", NULL);
>  -               priv->phy_addr = *prop;
>  +       /*
>  +        * Link mode configuration
>  +        */
>
>  -               of_node_put(phy_dn);
>  +       /* Start with safe defaults for link connection */
>  +       priv->phy_addr = FEC5200_PHYADDR_NONE;
>  +       priv->speed = 100;
>  +       priv->duplex = 0;
>  +       priv->phy_speed = ((mpc52xx_find_ipb_freq(op->node) >> 20) / 5) << 1;
>  +
>  +       /* the 7-wire property means don't use MII mode */
>  +       if (of_find_property(op->node, "fsl,7-wire-mode", NULL))
>  +               priv->phy_addr = FEC5200_PHYADDR_7WIRE;
>  +
>  +       /* The current speed preconfigures the speed of the MII link */
>  +       prop = of_get_property(op->node, "current-speed", &prop_size);
>  +       if (prop && (prop_size >= sizeof(u32) * 2)) {
>  +               priv->speed = prop[0];
>  +               priv->duplex = prop[1] ? DUPLEX_FULL : DUPLEX_HALF;
>  +       }
>
>  -               /* Phy speed */
>  -               priv->phy_speed = ((mpc52xx_find_ipb_freq(op->node) >> 20) / 5) << 1;
>  -       } else {
>  -               dev_info(&ndev->dev, "can't find \"phy-handle\" in device"
>  -                               " tree, using 7-wire mode\n");
>  +       /* If there is a phy handle, setup link to that phy */
>  +       phy_handle = of_get_property(op->node, "phy-handle", &prop_size);
>  +       if (phy_handle && (prop_size >= sizeof(phandle))) {
>  +               phy_node = of_find_node_by_phandle(*phy_handle);
>  +               prop = of_get_property(phy_node, "reg", &prop_size);
>  +               if (prop && (prop_size >= sizeof(u32)))
>  +                       if ((*prop >= 0) && (*prop < PHY_MAX_ADDR))
>  +                               priv->phy_addr = *prop;
>  +               of_node_put(phy_node);
>         }
>
>         /* Hardware init */
>  @@ -982,6 +1020,20 @@ mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
>         if (rv < 0)
>                 goto probe_error;
>
>  +       /* Now report the link setup */
>  +       switch (priv->phy_addr) {
>  +        case FEC5200_PHYADDR_NONE:
>  +               dev_info(&ndev->dev, "Fixed speed MII link: %i%cD\n",
>  +                        priv->speed, priv->duplex ? 'F' : 'H');
>  +               break;
>  +        case FEC5200_PHYADDR_7WIRE:
>  +               dev_info(&ndev->dev, "using 7-wire PHY mode\n");
>  +               break;
>  +        default:
>  +               dev_info(&ndev->dev, "Using PHY at MDIO address %i\n",
>  +                        priv->phy_addr);
>  +       }
>  +
>         /* We're done ! */
>         dev_set_drvdata(&op->dev, ndev);
>
>  diff --git a/drivers/net/fec_mpc52xx.h b/drivers/net/fec_mpc52xx.h
>  index 8b1f753..a227a52 100644
>  --- a/drivers/net/fec_mpc52xx.h
>  +++ b/drivers/net/fec_mpc52xx.h
>  @@ -26,25 +26,6 @@
>
>   #define FEC_WATCHDOG_TIMEOUT   ((400*HZ)/1000)
>
>  -struct mpc52xx_fec_priv {
>  -       int duplex;
>  -       int r_irq;
>  -       int t_irq;
>  -       struct mpc52xx_fec __iomem *fec;
>  -       struct bcom_task *rx_dmatsk;
>  -       struct bcom_task *tx_dmatsk;
>  -       spinlock_t lock;
>  -       int msg_enable;
>  -
>  -       int has_phy;
>  -       unsigned int phy_speed;
>  -       unsigned int phy_addr;
>  -       struct phy_device *phydev;
>  -       enum phy_state link;
>  -       int speed;
>  -};
>  -
>  -
>   /* ======================================================================== */
>   /* Hardware register sets & bits                                            */
>   /* ======================================================================== */
>
>



-- 
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
