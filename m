From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v6] ethernet/arc/arc_emac - Add new driver
Date: Thu, 20 Jun 2013 19:00:36 +0300
Message-ID: <CAHp75Vf8+z0B6PMjGqVNPuEJrVYiR-yMT5dvqqBAs=GA5utLrQ@mail.gmail.com>
References: <1371729196-4505-1-git-send-email-abrodkin@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Joe Perches <joe@perches.com>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	Mischa Jonker <Mischa.Jonker@synopsys.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Devicetree Discuss <devicetree-discuss@lists.ozlabs.org>,
	Florian Fainelli <florian@openwrt.org>
To: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371729196-4505-1-git-send-email-abrodkin@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 20, 2013 at 2:53 PM, Alexey Brodkin
<Alexey.Brodkin@synopsys.com> wrote:
> Driver for non-standard on-chip ethernet device ARC EMAC 10/100,
> instantiated in some legacy ARC (Synopsys) FPGA Boards such as
> ARCAngel4/ML50x.

Few nitpicks below.

> please take a look at 6th re-spin of the patch.

Usually it's better to start new thread for new version of the patchset.

> +++ b/drivers/net/ethernet/arc/emac_main.c

> +static void arc_emac_tx_clean(struct net_device *ndev)
> +{
> +       struct arc_emac_priv *priv = netdev_priv(ndev);
> +       struct net_device_stats *stats = &priv->stats;
> +       unsigned int i;
> +
> +       for (i = 0; i < TX_BD_NUM; i++) {
> +               unsigned int *txbd_dirty = &priv->txbd_dirty;
> +               struct arc_emac_bd *txbd = &priv->txbd[*txbd_dirty];
> +               struct buffer_state *tx_buff = &priv->tx_buff[*txbd_dirty];
> +               struct sk_buff *skb = tx_buff->skb;
> +               unsigned int info = le32_to_cpu(txbd->info);
> +
> +               *txbd_dirty = (*txbd_dirty + 1) % TX_BD_NUM;
> +
> +               if ((info & FOR_EMAC) || !txbd->data)

Redundant internal braces. Up to you.

> +static int arc_emac_rx(struct net_device *ndev, int budget)
> +{
> +       struct arc_emac_priv *priv = netdev_priv(ndev);
> +       unsigned int work_done;
> +
> +       for (work_done = 0; work_done <= budget; work_done++) {

> +               /* Make a note that we saw a packet at this BD.
> +                * So next time, driver starts from this + 1
> +                */
> +               *last_rx_bd = (*last_rx_bd + 1) % RX_BD_NUM;
> +
> +#define FRST_OR_LAST_MASK      (FRST_MASK | LAST_MASK)

You may re-use it in *_tx_clean() above.
Also, please use full English word FIRST. Actually is there any
conflicts with existing drivers? Should it be with [ARC_]EMAC prefix?

> +               /* Make sure pointer to data buffer is set */
> +               mb();

I'm not so familiar with memory barriers, but is this somehow differ
from smp_mb()?
Which one suits better? And what about the other places in this file?

> +       /* Allocate Tx BD's similar to Rx BD's. All Tx BD's owned by CPU */
> +       bd = priv->txbd;
> +       for (i = 0; i < TX_BD_NUM; i++) {
> +               bd->data = 0;
> +               bd->info = 0;
> +               bd++;
> +       }

Looks like
memset(priv->txbd, 0, siezeof(*priv->txbd) * TX_BD_NUM);

> +       *info = cpu_to_le32(FOR_EMAC | FRST_MASK | LAST_MASK | len);

FOR_EMAC | FRST_OR_LAST_MASK | len ?

> +       /* Increment index to point to the next BD */
> +       *txbd_curr = (*txbd_curr + 1) % TX_BD_NUM;

+ Empty line?

> +       /* Get "info" of the next BD */

> +       /* Get PHY from device tree */
> +       phy_node = of_parse_phandle(pdev->dev.of_node, "phy", 0);

> +       /* Get EMAC registers base address from device tree */
> +       err = of_address_to_resource(pdev->dev.of_node, 0, &res_regs);

> +       /* Get CPU clock frequency from device tree */
> +       if (of_property_read_u32(pdev->dev.of_node, "clock-frequency",
> +                                &clock_frequency)) {

> +       /* Get IRQ from device tree */
> +       err = of_irq_to_resource(pdev->dev.of_node, 0, &res_irq);

So, you don't like the idea to get as much as possible before
alloc_netdev(), don't you?

--
With Best Regards,
Andy Shevchenko
