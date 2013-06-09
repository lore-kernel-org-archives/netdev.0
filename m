From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v2] ethernet/arc/arc_emac - Add new driver
Date: Sun, 9 Jun 2013 21:16:35 +0300
Message-ID: <CAHp75VemPmx=1TjcAgLcat5rQO45VkBnppbeOkA_3o24c8HN-g@mail.gmail.com>
References: <1370617656-18349-1-git-send-email-abrodkin@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	Mischa Jonker <Mischa.Jonker@synopsys.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Devicetree Discuss <devicetree-discuss@lists.ozlabs.org>
To: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1370617656-18349-1-git-send-email-abrodkin@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 7, 2013 at 6:07 PM, Alexey Brodkin
<Alexey.Brodkin@synopsys.com> wrote:
> Driver for non-standard on-chip ethernet device ARC EMAC 10/100,
> instantiated in some legacy ARC (Synopsys) FPGA Boards such as
> ARCAngel4/ML50x.
>
> This is based off of current Linus tree, build tested for x86.

> +++ b/drivers/net/ethernet/arc/arc_emac_main.c
> @@ -0,0 +1,956 @@
> +/*
> + * Copyright (C) 2004, 2007-2010, 2011-2013 Synopsys, Inc. (www.synopsys.com)

2004, 2007-2013 ?

> + * Driver for the ARC EMAC 10100 (Rev 5)

If you are going to upstream this, why do you need revision?

> + * Alexey Brodkin: June 2013
> + *  -Upsteaming

It will be obvious from existence of your commit in the git tree.

> + *  -Refactoring
> + *      = Use device-tree/OF for configuration
> + *      = Use libphy for phy management
> + *      = Remove non-NAPI code sections
> + *      = Remove ARC-specific BD management implementations
> + *      = Add ethtool functionality
> + *
> + * Vineet Gupta: June 2011
> + *  -Issues when working with 64b cache line size
> + *      = BD rings point to aligned location in an internal buffer
> + *      = added support for cache coherent BD Ring memory
> + *
> + * Vineet Gupta: May 2010
> + *  -Reduced foot-print of the main ISR (handling for error cases moved out
> + *      into a separate non-inline function).
> + *  -Driver Tx path optimized for small packets (which fit into 1 BD = 2K).
> + *      Any specifics for chaining are in a separate block of code.
> + *
> + * Vineet Gupta: Nov 2009
> + *  -Unified NAPI and Non-NAPI Code.
> + *  -API changes since 2.6.26 for making NAPI independent of netdevice
> + *  -Cutting a few checks in main Rx poll routine
> + *  -Tweaked NAPI implementation:
> + *      In poll mode, Original driver would always start sweeping BD chain
> + *      from BD-0 upto poll budget (40). And if it got over-budget it would
> + *      drop reminder of packets.
> + *      Instead now we remember last BD polled and in next
> + *      cycle, we resume from next BD onwards. That way in case of over-budget
> + *      no packet needs to be dropped.
> + *
> + * Vineet Gupta: Nov 2009
> + *  -Rewrote the driver register access macros so that multiple accesses
> + *   in same function use "anchor" reg to save the base addr causing
> + *   shorter instructions
> + *
> + * Amit Bhor, Sameer Dhavale: 2004

I don't know if it's a good idea to keep changelog inside source file,
we have git commit messages for that. You may move this to the first
commit message if you want to keep history, and in future git will do
the job for you.

> + */
> +
> +#include <linux/etherdevice.h>
> +#include <linux/interrupt.h>
> +#include <linux/io.h>
> +#include <linux/module.h>
> +#include <linux/of_address.h>
> +#include <linux/of_irq.h>
> +#include <linux/of_mdio.h>
> +#include <linux/of_net.h>
> +#include <linux/of_platform.h>
> +
> +#include "arc_emac_regs.h"
> +#include "arc_emac_mdio.h"

Since you are creating driver under its own folder why to keep the
prefixes in the filenames? I think regs.h and mdio.h would be enough.

> +/* Transmission timeout */
> +#define TX_TIMEOUT (400*HZ/1000)

(400 * HZ / 1000)

> +struct arc_emac_priv {

> +       /* Pointers to BD rings - Device side */

What about documenting structure fields in the kerneldoc format on the
top of struct definition?

> +       dma_addr_t rxbd_dma_hdl;
> +       dma_addr_t txbd_dma_hdl;

Perhaps you may consider to reduce field names somethow. I don't know
why rxbd_dma and txbd_dma is not enough.

> +       struct sk_buff *rx_skbuff[RX_BD_NUM];
> +       struct sk_buff *tx_skbuff[TX_BD_NUM];

Ditto.

> +       void __iomem *reg_base_addr;

Ditto.
For example, base or regs.

> +/**
> + * arc_emac_adjust_link - Adjust the PHY link speed/duplex.
> + * @net_dev:   Pointer to the net_device structure.
> + *
> + * This function is called to change the speed and duplex setting after
> + * auto negotiation is done by the PHY.
> + */
> +static void arc_emac_adjust_link(struct net_device *net_dev)
> +{
> +       struct arc_emac_priv *priv = netdev_priv(net_dev);
> +       struct phy_device *phydev = priv->phy_dev;
> +       unsigned int reg, status_change = 0;
> +
> +       BUG_ON(!priv->phy_dev);
> +
> +       if (phydev->link && (priv->old_speed != phydev->speed)) {
> +               /* speed changed */
> +               switch (phydev->speed) {
> +               case SPEED_10:
> +               case SPEED_100:
> +                       break;
> +               default:
> +                       netdev_warn(net_dev, "Speed (%d) is not 10/100?\n",
> +                                   phydev->speed);
> +                       break;
> +               }
> +               priv->old_speed = phydev->speed;
> +               status_change = 1;
> +       }
> +
> +       if (phydev->link && (priv->old_duplex != phydev->duplex)) {
> +               /* duplex mode changed */
> +               reg = EMAC_REG_GET(priv->reg_base_addr, R_CTRL);
> +
> +               if (DUPLEX_FULL == phydev->duplex)
> +                       reg |= ENFL_MASK;
> +               else
> +                       reg &= ~ENFL_MASK;
> +
> +               EMAC_REG_SET(priv->reg_base_addr, R_CTRL, reg);
> +               priv->old_duplex = phydev->duplex;
> +               status_change = 1;
> +       }
> +
> +       if (phydev->link != priv->old_link) {
> +               /* link state changed */
> +               if (!phydev->link) {
> +                       /* link went down */
> +                       priv->old_speed = 0;
> +                       priv->old_duplex = -1;

If you move this part to the top of function you may simplify conditions

if (priv->old_link && !phydev->link) {
                       /* link went down */
                       priv->old_speed = 0;
                       priv->old_duplex = -1;
  priv->old_link = NULL;
  phy_print_status(phydev);
  return;
}

if (priv->old_speed != phydev->speed) {
...

> +               }
> +               priv->old_link = phydev->link;
> +               status_change = 1;
> +       }
> +
> +       if (status_change)
> +               phy_print_status(phydev);
> +}

> +static int arc_emac_poll(struct napi_struct *napi, int budget)
> +{

> +       for (loop = 0; loop < RX_BD_NUM; loop++) {
> +               i = (i + 1) & (RX_BD_NUM - 1);

i = (i + 1) % RX_BD_NUM;

> +static irqreturn_t arc_emac_intr(int irq, void *dev_instance)
> +{

> +       if (likely(status & (RXINT_MASK | TXINT_MASK))) {

It dublicates following checks.
Instead of using else, you may check for opposite condition.

> +               if (status & RXINT_MASK) {

> +               }
> +               if (status & TXINT_MASK) {

> +               }
> +       } else {

> +               if (status & ERR_MASK) {
> +                       /* MSER/RXCR/RXFR/RXFL interrupt fires on corresponding
> +                        * 8-bit error counter overrun.
> +                        * Because of this fact we add 256 items each time
> +                        * overrun interrupt happens.
> +                        */
> +
> +                       if (status & TXCH_MASK) {
> +                               priv->stats.tx_errors++;
> +                               priv->stats.tx_aborted_errors++;
> +                               netdev_err(priv->net_dev,
> +                                          "Tx chaining err! txbd_dirty = %u\n",
> +                                          priv->txbd_dirty);
> +                       } else if (status & MSER_MASK) {
> +                               priv->stats.rx_missed_errors += 255;
> +                               priv->stats.rx_errors += 255;
> +                       } else if (status & RXCR_MASK) {
> +                               priv->stats.rx_crc_errors += 255;
> +                               priv->stats.rx_errors += 255;
> +                       } else if (status & RXFR_MASK) {
> +                               priv->stats.rx_frame_errors += 255;
> +                               priv->stats.rx_errors += 255;

Why 255 ?

> +                       } else if (status & RXFL_MASK) {
> +                               priv->stats.rx_over_errors += 255;
> +                               priv->stats.rx_errors += 255;

> +struct net_device_stats *arc_emac_stats(struct net_device *net_dev)
> +{
> +       unsigned long miss, rxerr, rxfram, rxcrc, rxoflow;
> +       struct arc_emac_priv *priv = netdev_priv(net_dev);
> +
> +       rxerr = EMAC_REG_GET(priv->reg_base_addr, R_RXERR);
> +       miss = EMAC_REG_GET(priv->reg_base_addr, R_MISS);
> +
> +       rxcrc = (rxerr & 0xff);
> +       rxfram = (rxerr >> 8 & 0xff);
> +       rxoflow = (rxerr >> 16 & 0xff);

For what purpose you embraced those?

> +int arc_emac_tx(struct sk_buff *skb, struct net_device *net_dev)
> +{
> +       int len, bitmask;
> +       unsigned int info;
> +       char *pkt;
> +       struct arc_emac_priv *priv = netdev_priv(net_dev);
> +
> +       len = skb->len < ETH_ZLEN ? ETH_ZLEN : skb->len;

len = max_t(..., ETH_ZLEN, skb->len);

> +tx_next_chunk:
> +
> +       info = priv->txbd[priv->txbd_curr].info;
> +       if (likely((info & OWN_MASK) == FOR_CPU)) {

> +       } else {
> +               return NETDEV_TX_BUSY;

What about to do this check first and return, and do the body unconditionally?

> +       }
> +}
> +

> +static int arc_emac_probe(struct platform_device *pdev)
> +{
> +       struct net_device *net_dev;
> +       struct arc_emac_priv *priv;
> +       int err;
> +       unsigned int id, clock_frequency;
> +       struct resource res_regs, res_irq;
> +       const char *mac_addr = NULL;

It seems useless assignment.

> +       priv->reg_base_addr = devm_ioremap_resource(&pdev->dev, &res_regs);
> +       if (IS_ERR(priv->reg_base_addr)) {
> +               dev_err(&pdev->dev, "failed to ioremap MAC registers\n");

No need to print this here.


> +++ b/drivers/net/ethernet/arc/arc_emac_mdio.c
> @@ -0,0 +1,170 @@
> +/*
> + * Copyright (C) 2004, 2007-2010, 2011-2013 Synopsys, Inc. (www.synopsys.com)

2007-2013?

> +static int arc_mdio_complete_wait(struct arc_mdio_priv *priv)
> +{
> +       unsigned int status;
> +       unsigned int count = (ARC_MDIO_COMPLETE_POLL_COUNT * 40);

> +               /* Make sure we never get into infinite loop */
> +               if (count-- == 0) {
> +                       WARN_ON(1);

Is it really requires WARN_ON?

> +                       return -ETIMEDOUT;
> +               }
> +               msleep(25);

Overall delay is up to 1000 ms, correct?

> +static int arc_mdio_write(struct mii_bus *bus, int phy_addr,
> +                         int reg_num, u16 value)
> +{

> +       EMAC_REG_SET(priv->reg_base_addr, R_MDIO,
> +                    0x50020000 | (phy_addr << 23) | (reg_num << 18) |
> +                    (value & 0xffff));

Useless 0xffff for u16 value.

> +++ b/drivers/net/ethernet/arc/arc_emac_mdio.h
> @@ -0,0 +1,22 @@
> +/*
> + * Copyright (C) 2004, 2007-2010, 2011-2013 Synopsys, Inc. (www.synopsys.com)

2007-2013

> +struct arc_mdio_priv {
> +       struct mii_bus *bus;
> +       struct device *dev;
> +       void __iomem *reg_base_addr; /* MAC registers base address */

kerneldoc format?

> +++ b/drivers/net/ethernet/arc/arc_emac_regs.h
> @@ -0,0 +1,72 @@
> +/*
> + * Copyright (C) 2004, 2007-2010, 2011-2013 Synopsys, Inc. (www.synopsys.com)

2007-2013 ?

--
With Best Regards,
Andy Shevchenko
