From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v5] ethernet/arc/arc_emac - Add new driver
Date: Wed, 19 Jun 2013 15:05:54 +0300
Message-ID: <CAHp75Vc-Aza03ZLJj3CkLP2YhvdRi94bfutxKbV34hTc1_6k4g@mail.gmail.com>
References: <1371629537-8076-1-git-send-email-abrodkin@synopsys.com>
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
	Devicetree Discuss <devicetree-discuss@lists.ozlabs.org>
To: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371629537-8076-1-git-send-email-abrodkin@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 19, 2013 at 11:12 AM, Alexey Brodkin
<Alexey.Brodkin@synopsys.com> wrote:
> Driver for non-standard on-chip ethernet device ARC EMAC 10/100,
> instantiated in some legacy ARC (Synopsys) FPGA Boards such as
> ARCAngel4/ML50x.
>
> This is based off of current Linus tree.

This line should go away from commit message.

> please take a look at 5th re-spin of the patch.

Few small things I commented below.

> +++ b/drivers/net/ethernet/arc/emac_main.c
> @@ -0,0 +1,828 @@

> +static int arc_emac_rx(struct net_device *ndev, int budget)
> +{
> +       struct arc_emac_priv *priv = netdev_priv(ndev);
> +       unsigned int work_done;
> +
> +       for (work_done = 0; work_done <= budget;) {
> +               unsigned int *last_rx_bd = &priv->last_rx_bd;
> +               struct net_device_stats *stats = &priv->stats;
> +               struct buffer_state *rx_buff = &priv->rx_buff[*last_rx_bd];
> +               struct arc_emac_bd *rxbd = &priv->rxbd[*last_rx_bd];
> +               unsigned int buflen = EMAC_BUFFER_SIZE;
> +               unsigned int pktlen, info = __le32_to_cpu(rxbd->info);
> +               struct sk_buff *skb;
> +               dma_addr_t addr;
> +
> +               if (unlikely((info & OWN_MASK) == FOR_EMAC))
> +                       break;

> +               work_done++;

Why it can't be inside for()?

> +               if (unlikely((info & FRST_OR_LAST_MASK) != FRST_OR_LAST_MASK)) {
> +                       /* Buffer chaining results in a significant
> +                        * amount of additional bus overhead and thus
> +                        * a higher CLK frequency or larger FIFOs are required.
> +                        * Because of that fact we don't support
> +                        * chaining of receive packets. We pre-allocate
> +                        * buffers of MTU size so incoming packets
> +                        * won't be chained.
> +                        */

Could that comment take less LOC?

> +                       /* Return ownership to EMAC */
> +                       rxbd->info = __cpu_to_le32(FOR_EMAC | buflen);

Here and in the whole file. Parhaps cpu_to_le32()?

> +               /* Once EMAC sees he is an owner of this BD, EMAC will start to
> +                * use it for receiving or transmitting packets,
> +                * depending on BD: Tx or Rx.
> +                * That's why we need to make sure "data" has proper address
> +                * before writing "info" word with owner flag.
> +                */

Less LOC?

> +       if (status & ERR_MASK) {
> +               /* MSER/RXCR/RXFR/RXFL interrupt fires on corresponding
> +                * 8-bit error counter overrun.
> +                * Because of this fact we add 256 (0x100) items each time
> +                * overrun interrupt happens.
> +                */

Ditto.

> +static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
> +{

> +       len = max_t(unsigned int, ETH_ZLEN, skb->len);
> +
> +       /* EMAC still holds this buffer in its possession.
> +        * CPU must not modify this buffer descriptor
> +        */
> +       if (unlikely((__le32_to_cpu(*info) & OWN_MASK) == FOR_EMAC)) {

Perhaps le32_to_cpu() here and in whole file?

> +static int arc_emac_probe(struct platform_device *pdev)
> +{

> +       err = of_address_to_resource(pdev->dev.of_node, 0, &res_regs);

> +       if (of_property_read_u32(pdev->dev.of_node, "clock-frequency",
> +                                &clock_frequency)) {

> +       err = of_irq_to_resource(pdev->dev.of_node, 0, &res_irq);

You may save few lines if you move those checks before allocation of the netdev.

> +       err = arc_mdio_probe(pdev->dev.of_node, priv);
> +       if (err) {
> +               dev_err(&pdev->dev, "failed to probe MII bus\n");
> +               goto out;
> +       }
> +
> +       priv->phy_dev = of_phy_connect(ndev, phy_node, arc_emac_adjust_link, 0,
> +                                      PHY_INTERFACE_MODE_MII);
> +       if (!priv->phy_dev) {
> +               netdev_err(ndev, "of_phy_connect() failed\n");

Can we be consistent and use here dev_err()?

> +++ b/drivers/net/ethernet/arc/emac_mdio.c
> @@ -0,0 +1,151 @@

> +static int arc_mdio_complete_wait(struct arc_emac_priv *priv)
> +{
> +       unsigned int i;
> +
> +       for (i = 0; i < ARC_MDIO_COMPLETE_POLL_COUNT * 40; i++) {

> +               msleep(25);

So, in the worst case it takes ARC_MDIO_COMPLETE_POLL_COUNT seconds to
wait. Quite a long time.
Does user expect such a delay?

> +int arc_mdio_probe(struct device_node *dev_node, struct arc_emac_priv *priv)
> +{

> +       snprintf(bus->id, MII_BUS_ID_SIZE, "%.8x", (unsigned int)priv->regs);

Is bus->id exposed to user-space somehow?

--
With Best Regards,
Andy Shevchenko
