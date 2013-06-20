From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: Re: [PATCH v5] ethernet/arc/arc_emac - Add new driver
Date: Thu, 20 Jun 2013 09:49:48 +0000
Message-ID: <4881796E12491D4BB15146FE0209CE643F5F2F56@DE02WEMBXB.internal.synopsys.com>
References: <1371629537-8076-1-git-send-email-abrodkin@synopsys.com>
 <CAHp75Vc-Aza03ZLJj3CkLP2YhvdRi94bfutxKbV34hTc1_6k4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
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
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/19/2013 04:06 PM, Andy Shevchenko wrote:
> On Wed, Jun 19, 2013 at 11:12 AM, Alexey Brodkin
> <Alexey.Brodkin@synopsys.com> wrote:
>> Driver for non-standard on-chip ethernet device ARC EMAC 10/100,
>> instantiated in some legacy ARC (Synopsys) FPGA Boards such as
>> ARCAngel4/ML50x.
>>
>> This is based off of current Linus tree.
>
> This line should go away from commit message.

Ok, will do.

>> +static int arc_emac_rx(struct net_device *ndev, int budget)
>> +{
>> +       struct arc_emac_priv *priv = netdev_priv(ndev);
>> +       unsigned int work_done;
>> +
>> +       for (work_done = 0; work_done <= budget;) {
>> +               unsigned int *last_rx_bd = &priv->last_rx_bd;
>> +               struct net_device_stats *stats = &priv->stats;
>> +               struct buffer_state *rx_buff = &priv->rx_buff[*last_rx_bd];
>> +               struct arc_emac_bd *rxbd = &priv->rxbd[*last_rx_bd];
>> +               unsigned int buflen = EMAC_BUFFER_SIZE;
>> +               unsigned int pktlen, info = __le32_to_cpu(rxbd->info);
>> +               struct sk_buff *skb;
>> +               dma_addr_t addr;
>> +
>> +               if (unlikely((info & OWN_MASK) == FOR_EMAC))
>> +                       break;
>
>> +               work_done++;
>
> Why it can't be inside for()?

Indeed it can. Earlier there was "continue" instead of "break" that's 
why increment was done at this particular place. With "break" in place 
I'm moving incrementation in "for".

>> +               if (unlikely((info & FRST_OR_LAST_MASK) != FRST_OR_LAST_MASK)) {
>> +                       /* Buffer chaining results in a significant
>> +                        * amount of additional bus overhead and thus
>> +                        * a higher CLK frequency or larger FIFOs are required.
>> +                        * Because of that fact we don't support
>> +                        * chaining of receive packets. We pre-allocate
>> +                        * buffers of MTU size so incoming packets
>> +                        * won't be chained.
>> +                        */
>
> Could that comment take less LOC?
>
>> +                       /* Return ownership to EMAC */
>> +                       rxbd->info = __cpu_to_le32(FOR_EMAC | buflen);
>
> Here and in the whole file. Parhaps cpu_to_le32()?

Indeed. Replaced both "__cpu_to_le32" and "__le32_to_cpu" with no "__" 
versions.

>> +               /* Once EMAC sees he is an owner of this BD, EMAC will start to
>> +                * use it for receiving or transmitting packets,
>> +                * depending on BD: Tx or Rx.
>> +                * That's why we need to make sure "data" has proper address
>> +                * before writing "info" word with owner flag.
>> +                */
>
> Less LOC?

Reduced.

>> +static int arc_emac_probe(struct platform_device *pdev)
>> +{
>
>> +       err = of_address_to_resource(pdev->dev.of_node, 0, &res_regs);
>
>> +       if (of_property_read_u32(pdev->dev.of_node, "clock-frequency",
>> +                                &clock_frequency)) {
>
>> +       err = of_irq_to_resource(pdev->dev.of_node, 0, &res_irq);
>
> You may save few lines if you move those checks before allocation of the netdev.

Correct, but having netdev is handy because I may have driver's private 
structure allocated as well and may set corresponding values right in 
the order I parse them from DT.
Moreover I need to have private structure pretty early in place just to 
read EMAC's ID from a register.
So I'd better leave netdev allocation on top of the probe.

>> +       err = arc_mdio_probe(pdev->dev.of_node, priv);
>> +       if (err) {
>> +               dev_err(&pdev->dev, "failed to probe MII bus\n");
>> +               goto out;
>> +       }
>> +
>> +       priv->phy_dev = of_phy_connect(ndev, phy_node, arc_emac_adjust_link, 0,
>> +                                      PHY_INTERFACE_MODE_MII);
>> +       if (!priv->phy_dev) {
>> +               netdev_err(ndev, "of_phy_connect() failed\n");
>
> Can we be consistent and use here dev_err()?

Right. Replaced.

>> +++ b/drivers/net/ethernet/arc/emac_mdio.c
>> @@ -0,0 +1,151 @@
>
>> +static int arc_mdio_complete_wait(struct arc_emac_priv *priv)
>> +{
>> +       unsigned int i;
>> +
>> +       for (i = 0; i < ARC_MDIO_COMPLETE_POLL_COUNT * 40; i++) {
>
>> +               msleep(25);
>
> So, in the worst case it takes ARC_MDIO_COMPLETE_POLL_COUNT seconds to
> wait. Quite a long time.
> Does user expect such a delay?

Well, but it shouldn't be that long. It's just a check for illegal 
situation. If this transaction never ends then it doesn't matter if we 
wait for 1 second or 2 - after this time period "libphy" will "halt" 
MDIO anyways.

In general MDIO register gets polled by "libphy" once in a couple of 
seconds, so delay of 25 milliseconds IMHO is fine.

>> +int arc_mdio_probe(struct device_node *dev_node, struct arc_emac_priv *priv)
>> +{
>
>> +       snprintf(bus->id, MII_BUS_ID_SIZE, "%.8x", (unsigned int)priv->regs);
>
> Is bus->id exposed to user-space somehow?

Well as a boot-up message from "libphy":
====
libphy: Synopsys MII Bus: probed
====

Regards,
Alexey
