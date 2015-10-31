From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH v4] net: ethernet: add driver for Aurora VLSI NB8800 Ethernet controller
Date: Sat, 31 Oct 2015 18:41:41 +0000
Message-ID: <yw1xh9l6c23e.fsf@unicorn.mansr.com>
References: <1446137333-1822-1-git-send-email-mans@mansr.com>
	<CAHp75VdNY-=8Kx09CvgVeL0J3Wy=3jLE0ac5nHRt0qaqkuprhA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHp75VdNY-=8Kx09CvgVeL0J3Wy=3jLE0ac5nHRt0qaqkuprhA@mail.gmail.com>
	(Andy Shevchenko's message of "Sat, 31 Oct 2015 19:21:38 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Shevchenko <andy.shevchenko@gmail.com> writes:

>> +static int nb8800_mdio_read(struct mii_bus *bus, int phy_id, int re=
g)
>> +{
>> +       struct nb8800_priv *priv =3D bus->priv;
>> +       int val;
>> +
>> +       if (!nb8800_mdio_wait(bus))
>> +               return -ETIMEDOUT;
>> +
>> +       val =3D MIIAR_ADDR(phy_id) | MIIAR_REG(reg);
>> +
>> +       nb8800_writel(priv, NB8800_MDIO_CMD, val);
>> +       udelay(10);
>
> Why 10? Perhaps add a comment line.

Because it works.  The documentation doesn't mention a delay, but it
works unreliably without one.

>> +       nb8800_writel(priv, NB8800_MDIO_CMD, val | MDIO_CMD_GO);
>> +
>> +       if (!nb8800_mdio_wait(bus))
>> +               return -ETIMEDOUT;
>> +
>> +       val =3D nb8800_readl(priv, NB8800_MDIO_STS);
>> +       if (val & MDIO_STS_ERR)
>> +               return 0xffff;
>
> Can we return an error here?

That breaks the bus scanning in phylib.

>> +
>> +       return val & 0xffff;
>> +}

[...]

>> +static int nb8800_poll(struct napi_struct *napi, int budget)
>> +{
>> +       struct net_device *dev =3D napi->dev;
>> +       struct nb8800_priv *priv =3D netdev_priv(dev);
>> +       struct nb8800_dma_desc *rx;
>> +       int work =3D 0;
>> +       int last =3D priv->rx_eoc;
>> +       int next;
>> +
>> +       while (work < budget) {
>> +               struct rx_buf *rx_buf;
>> +               u32 report;
>> +               int len;
>> +
>> +               next =3D (last + 1) & (RX_DESC_COUNT - 1);
>
> Maybe (last + 1) % RX_DESC_COUNT ? It will not prevent to use
> non-power-of-two numbers.

We don't want to be doing divisions anyway, but I can certainly change
it to % if that's preferred.

>> +
>> +               rx_buf =3D &priv->rx_bufs[next];
>> +               rx =3D &priv->rx_descs[next];
>
>> +               report =3D rx->report;
>
> Maybe you can use rx->report directly below.

It's in uncached memory, so didn't want to have gcc accidentally doing
more reads than necessary.

>> +static int nb8800_xmit(struct sk_buff *skb, struct net_device *dev)
>> +{
>> +       struct nb8800_priv *priv =3D netdev_priv(dev);
>> +       struct tx_skb_data *skb_data;
>> +       struct tx_buf *tx_buf;
>> +       dma_addr_t dma_addr;
>> +       unsigned int dma_len;
>> +       int cpsz, next;
>> +       int frags;
>> +
>> +       if (atomic_read(&priv->tx_free) <=3D NB8800_DESC_LOW) {
>> +               netif_stop_queue(dev);
>> +               return NETDEV_TX_BUSY;
>> +       }
>> +
>> +       cpsz =3D (8 - (uintptr_t)skb->data) & 7;
>
> So, cast to uintptr_t looks strange in this driver, since used only
> twice in such expression, why not to use plain unsigned int * ?

Because it's not the same thing.  uintptr_t is an integer type the same
size as a pointer.  I need to check if the data pointer is 8-byte
aligned as required by the DMA.

>> +static void nb8800_set_rx_mode(struct net_device *dev)
>> +{
>> +       struct nb8800_priv *priv =3D netdev_priv(dev);
>> +       struct netdev_hw_addr *ha;
>> +       bool af_en;
>> +       int i;
>> +
>> +       if (dev->flags & (IFF_PROMISC | IFF_ALLMULTI))
>> +               af_en =3D false;
>> +       else
>> +               af_en =3D true;
>> +
>> +       nb8800_mac_af(dev, af_en);
>> +
>> +       if (!af_en)
>> +               return;
>
> Would it be
>
> if (dev->flags & (IFF_PROMISC | IFF_ALLMULTI)) {
>   nb8800_mac_af(dev, false);
>   return;
> }
>
> nb8800_mac_af(dev, true);
>
> ?

Looks equivalent.  Maybe that's clearer.

>> +static int nb8800_hw_init(struct net_device *dev)
>> +{
>> +       struct nb8800_priv *priv =3D netdev_priv(dev);
>
>> +       unsigned int val =3D 0;
>
> Useless assignment.

Indeed.  Why didn't gcc warn about that?

>> +
>> +       nb8800_writeb(priv, NB8800_RANDOM_SEED, 0x08);
>> +
>> +       /* TX single deferral params */
>> +       nb8800_writeb(priv, NB8800_TX_SDP, 0xc);
>> +
>> +       /* Threshold for partial full */
>> +       nb8800_writeb(priv, NB8800_PF_THRESHOLD, 0xff);
>> +
>> +       /* Pause Quanta */
>> +       nb8800_writeb(priv, NB8800_PQ1, 0xff);
>> +       nb8800_writeb(priv, NB8800_PQ2, 0xff);
>
> Lot of magic numbers above and below.

Those are from the original driver.  Some of them disagree with the
documentation, and the "correct" values don't work.

>> +
>> +       /* configure TX DMA Channels */
>> +       val =3D nb8800_readl(priv, NB8800_TXC_CR);
>> +       val &=3D TCR_LE;
>> +       val |=3D TCR_DM | TCR_RS | TCR_TFI(1) | TCR_BTS(2);
>> +       nb8800_writel(priv, NB8800_TXC_CR, val);
>> +
>> +       /* TX Interrupt Time Register */
>> +       nb8800_writel(priv, NB8800_TX_ITR, 1);
>> +
>> +       /* configure RX DMA Channels */
>> +       val =3D nb8800_readl(priv, NB8800_RXC_CR);
>> +       val &=3D RCR_LE;
>> +       val |=3D RCR_DM | RCR_RS | RCR_RFI(7) | RCR_BTS(2) | RCR_FL;
>> +       nb8800_writel(priv, NB8800_RXC_CR, val);
>> +
>> +       /* RX Interrupt Time Register */
>> +       nb8800_writel(priv, NB8800_RX_ITR, 1);
>> +
>> +       val =3D TX_RETRY_EN | TX_PAD_EN | TX_APPEND_FCS;
>> +       nb8800_writeb(priv, NB8800_TX_CTL1, val);
>> +
>> +       /* collision retry count */
>> +       nb8800_writeb(priv, NB8800_TX_CTL2, 5);
>> +
>> +       val =3D RX_PAD_STRIP | RX_PAUSE_EN | RX_AF_EN | RX_RUNT;
>> +       nb8800_writeb(priv, NB8800_RX_CTL, val);
>> +
>> +       nb8800_mc_init(dev, 0);
>> +
>> +       nb8800_writeb(priv, NB8800_TX_BUFSIZE, 0xff);
>> +
>> +       return 0;
>> +}
>> +
>> +static void nb8800_tangox_init(struct net_device *dev)
>> +{
>> +       struct nb8800_priv *priv =3D netdev_priv(dev);
>> +       u32 val;
>> +
>> +       val =3D nb8800_readb(priv, NB8800_TANGOX_PAD_MODE) & 0x78;
>
> Magic 0x78.

That one I can clarify.  Will do.

>> +static int nb8800_probe(struct platform_device *pdev)
>> +{
>> +       const struct of_device_id *match;
>> +       const struct nb8800_ops *ops =3D NULL;
>> +       struct nb8800_priv *priv;
>> +       struct resource *res;
>> +       struct net_device *dev;
>> +       struct mii_bus *bus;
>> +       const unsigned char *mac;
>> +       void __iomem *base;
>> +       int irq;
>> +       int ret;
>> +
>> +       match =3D of_match_device(nb8800_dt_ids, &pdev->dev);
>> +       if (match)
>> +               ops =3D match->data;
>> +
>> +       res =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
>> +       if (!res) {
>> +               dev_err(&pdev->dev, "No MMIO base\n");
>> +               return -EINVAL;
>> +       }
>
> Move platform_get_resource() just before devm_ioremap_resource() and
> remove redundant condition with the message.
>
>> +       bus =3D devm_mdiobus_alloc(&pdev->dev);
>> +       if (!bus) {
>> +               ret =3D -ENOMEM;
>> +               goto err_disable_clk;
>> +       }
>> +
>> +       bus->name =3D "nb8800-mii";
>> +       bus->read =3D nb8800_mdio_read;
>> +       bus->write =3D nb8800_mdio_write;
>> +       bus->parent =3D &pdev->dev;
>> +       snprintf(bus->id, MII_BUS_ID_SIZE, "%.*s-mii", MII_BUS_ID_SI=
ZE - 5,
>> +                pdev->name);
>
> You are not using any IDs here, why not just to strscpy(bus->id,
> bus->name, MII_BUS_ID_SIZE);  for now?

I was under the impression the ID should be unique, and there are two o=
f
these devices in the chip.

--=20
M=E5ns Rullg=E5rd
mans@mansr.com
