From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: Re: [PATCH v3] ethernet/arc/arc_emac - Add new driver
Date: Thu, 13 Jun 2013 20:25:33 +0000
Message-ID: <4881796E12491D4BB15146FE0209CE643F5DFB22@DE02WEMBXB.internal.synopsys.com>
References: <1371134239-4531-1-git-send-email-abrodkin@synopsys.com>
 <CAHp75Vf4zjtebbaQMp4L0EmUPDVyrNPfvLODo7gHBuBEsWmZeA@mail.gmail.com>
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

On 06/13/2013 10:25 PM, Andy Shevchenko wrote:
> On Thu, Jun 13, 2013 at 5:37 PM, Alexey Brodkin
> <Alexey.Brodkin@synopsys.com> wrote:
>> Driver for non-standard on-chip ethernet device ARC EMAC 10/100,
>> instantiated in some legacy ARC (Synopsys) FPGA Boards such as
>> ARCAngel4/ML50x.
>
> Much better. But still few comments below.
>
>> +++ b/drivers/net/ethernet/arc/arc_emac.h
>
> What the point to keep arc_emac prefix for files? You have separate
> folder for them. This particular one can be main.h.

A reason is to still have an ability to tell what's a source a developer 
is dealing with. But in general your idea looks good. Will simplify names.

And what about function names? Do you think it worth to shorten them too 
since most of them aren't visible outside (static).

>> +struct arc_emac_priv {
>> +       struct net_device_stats stats;
>> +       unsigned int clock_frequency;
>> +       unsigned int max_speed;
>> +
>> +       /* Pointers to BD rings - CPU side */
>> +       struct arc_emac_bd_t *rxbd;
>> +       struct arc_emac_bd_t *txbd;
>
> Usually "_t" means "type" that is used in definitions without 'struct' word.
> I don't think this is the case here.

Right, it is a legacy. Back in the day it was "typedef" I later changed 
into "struct ...".

>> +       /* Pointers to BD rings - Device side */
>> +       dma_addr_t rxbd_dma_hdl;
>> +       dma_addr_t txbd_dma_hdl;
>> +
>> +       /* The actual socket buffers */
>> +       struct buffer_state rx_buff[RX_BD_NUM];
>> +       struct buffer_state tx_buff[TX_BD_NUM];
>> +       unsigned int txbd_curr;
>> +       unsigned int txbd_dirty;
>> +
>> +       /* Remember where driver last saw a packet, so next iteration it
>> +        * starts from here and not 0
>> +        */
>> +       unsigned int last_rx_bd;
>> +
>> +       struct napi_struct napi;
>> +
>> +       /* Phy saved state */
>> +       int duplex;
>> +       int speed;
>> +
>> +       /* Devices */
>> +       struct device *dev;
>> +       struct device_node *phy_node;
>> +       struct phy_device *phy_dev;
>> +       struct net_device *ndev;
>> +       struct mii_bus *bus;
>> +
>> +       /* EMAC registers base address */
>> +       void __iomem *reg_base_addr;
>> +};
>
> It seems you missed my comments against the names of the members. Can
> you address them or comment why not?

You mean to add description in kerneldoc format for all the fields in 
structures?

Well while in general it could be "a proper way" of documenting sources 
I found it not that convenient especially in case of really long structures.

Consider an example from here 
https://www.kernel.org/doc/Documentation/kernel-doc-nano-HOWTO.txt:
=================
Example kernel-doc data structure comment.

/**
  * struct blah - the basic blah structure
  * @mem1:	describe the first member of struct blah
  * @mem2:	describe the second member of struct blah,
  *		perhaps with more lines and words.
  *
  * Longer description of this structure.
  */
=================

In my case "arc_emac_priv" structure has 21 members, so right before 
structure itself there will be another at least 21 line of comments.

Moreover: "The kernel-doc function comments describe each parameter to 
the function, in order, with the @name lines."

While I don't think that each and every member needs description. At 
least some pairs like Tx/Rx I believe may share the only comment saying 
"Pointers to BD rings - CPU side".

Also I barely can find an example of strict usage of kernel-doc format 
for data structures in drivers nearby.

For example take a look at STMMAC - drivers/net/ethernet/stmicro/stmmac/
Lots of structures defined, non with kernel-doc description.

Still you think the only way to go is to add kernel-doc description then 
I'll add it ASAP, might be it will be a good example for other developers.

>> +++ b/drivers/net/ethernet/arc/arc_emac_main.c
>
>> +static int arc_emac_get_settings(struct net_device *ndev,
>> +                                struct ethtool_cmd *cmd)
>> +{
>> +       struct arc_emac_priv *priv = netdev_priv(ndev);
>> +
>> +       if (priv->phy_dev)
>> +               return phy_ethtool_gset(priv->phy_dev, cmd);
>> +
>> +       return -EINVAL;
>
> May be
> if (!...)
>   return -EINVAL;
> return ...;

Agree, this will be better.

>> +static int arc_emac_set_settings(struct net_device *ndev,
>> +                                struct ethtool_cmd *cmd)
>> +{
>> +       struct arc_emac_priv *priv = netdev_priv(ndev);
>> +
>> +       if (!capable(CAP_NET_ADMIN))
>> +               return -EPERM;
>> +
>> +       if (priv->phy_dev)
>> +               return phy_ethtool_sset(priv->phy_dev, cmd);
>> +
>> +       return -EINVAL;
>
> Ditto.

Agree.

>> +static int arc_emac_poll(struct napi_struct *napi, int budget)
>> +{
>> +       struct net_device *ndev = napi->dev;
>> +       struct arc_emac_priv *priv = netdev_priv(ndev);
>> +       unsigned int i, loop, work_done = 0;
>> +       struct sk_buff *skb;
>
>> +       for (loop = 0; loop < RX_BD_NUM; loop++) {
>> +               struct net_device_stats *stats = &priv->stats;
>> +               struct buffer_state *rx_buff;
>> +               struct arc_emac_bd_t *rxbd;
>> +               dma_addr_t addr;
>> +               unsigned int info, pktlen;
>> +               unsigned int buflen = ndev->mtu + EMAC_BUFFER_PAD;
>> +
>> +               i = (i + 1) % RX_BD_NUM;
>
> I just realize you are using circular buffer here. What about to use
> them with linux' native framework? Documentation/circular-buffers.txt

Exactly as Francois commented already - I didn't find it to be widely 
used in network drivers so I decided to not use it at least for now.

>> +               if (unlikely((info & OWN_MASK) == FOR_EMAC)) {
>> +                       /* BD is still owned by EMAC */
>> +                       continue;
>> +               }
>
> Redundant braces.

The question is then where to put a comment?
Before "if"? But it only applicable to contents of "if", right?
If I put the comment right after "if" then "continue" will be a bit far 
from "if". And this may confuse a reader. That's why to make reading 
easier I put braces in place.

>> +               addr = dma_map_single(&ndev->dev, (void *)rx_buff->skb->data,
>> +                                     buflen, DMA_FROM_DEVICE);
>> +               if (dma_mapping_error(&ndev->dev, addr)) {
>> +                       if (net_ratelimit())
>> +                               if (net_ratelimit())
>
> Is it not a typo?

Definitely not a typo! Copy-paste! I should have found it myself...

>> +                                       netdev_err(ndev, "cannot dma map\n");
>
>> +               work_done++;
>> +               if (work_done >= budget)
>> +                       break;
>
> Those three could easily go to the for () on the top of this function.

Correct. It should be like this on top of the "arc_emac_poll":
====
		if (work_done >= budget)
			break;
		work_done++;
====

>> +static irqreturn_t arc_emac_intr(int irq, void *dev_instance)
>> +{
>
>> +       if (status & TXINT_MASK) {
>> +               unsigned int i;
>> +
>> +               for (i = 0; i < TX_BD_NUM; i++) {
>> +                       unsigned int *txbd_dirty = &priv->txbd_dirty;
>> +                       struct arc_emac_bd_t *txbd = &priv->txbd[*txbd_dirty];
>> +                       struct buffer_state *tx_buff = &priv->tx_buff[*txbd_dirty];
>> +                       struct sk_buff *skb = tx_buff->skb;
>> +                       unsigned int info = txbd->info;
>
>> +                       txbd->data = 0x0;
>> +                       txbd->info = 0x0;
>
> Plain 0?

Right, 0 might be nicer)

>> +                       *txbd_dirty = (*txbd_dirty + 1) % TX_BD_NUM;
>
> Same idea about circular buffers.
>
>> +static int arc_emac_open(struct net_device *ndev)
>> +{
>
>> +       /* Set Poll rate so that it polls every 1 ms */
>> +       arc_reg_set(priv, R_POLLRATE,
>> +                    priv->clock_frequency / 1000000);
>
> I don't understand how you end up with 1ms here. 1000000 is just a
> magic number, clock_frequency generally is an arbitrary value.

Here's an extract from documentation:
==========
The value programmed into this register is number of clocks between 
polls times 1024. A value of 1 will cause a poll every 1024 clocks, 
2=2048 clocks. 0 is not valid. A CPU clock frequency of 100Mhz would
typically want to program the POLLRATE register with a value of 100 
which will cause a poll to occur about once every millisecond (10ns * 
1024 * 100=1ms)
==========

Do you think this info should be put in comment somewhere near?
I'd say it's pretty specific and common reader doesn't need to go in 
such sort of details especially if he doesn't have access to Hw 
documentation.

Otherwise we'll need to add to many technical details in comments, right?

>> +static struct net_device_stats *arc_emac_stats(struct net_device *ndev)
>> +{
>> +       unsigned long miss, rxerr, rxfram, rxcrc, rxoflow;
>> +       struct arc_emac_priv *priv = netdev_priv(ndev);
>> +       struct net_device_stats *stats = &priv->stats;
>> +
>> +       rxerr = arc_reg_get(priv, R_RXERR);
>> +       miss = arc_reg_get(priv, R_MISS);
>> +
>> +       rxcrc = rxerr & 0xff;
>> +       rxfram = rxerr >> 8 & 0xff;
>> +       rxoflow = rxerr >> 16 & 0xff;
>
> If you declare those three as u8, you can avoid those & 0xff.

Makes sense.

>> +       ndev = alloc_etherdev(sizeof(struct arc_emac_priv));
>> +       if (!ndev) {
>> +               err = -ENOMEM;
>> +               goto out;
>> +       }
>
> Redundant goto. Just return here.

Correct.

>> +       }
>> +
>> +
>
> Extra line.

Thanks :)

> --
> With Best Regards,
> Andy Shevchenko
>

Regards,
Alexey
