From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v4] net: ethernet: add driver for Aurora VLSI NB8800
 Ethernet controller
Date: Sat, 31 Oct 2015 22:06:45 +0200
Message-ID: <CAHp75VeeY8vqPB4U6kL18FiQTrmEt6Bmu0jzLgAG_zorkTbU7Q@mail.gmail.com>
References: <1446137333-1822-1-git-send-email-mans@mansr.com>
	<CAHp75VdNY-=8Kx09CvgVeL0J3Wy=3jLE0ac5nHRt0qaqkuprhA@mail.gmail.com>
	<yw1xh9l6c23e.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: =?UTF-8?B?TcOlbnMgUnVsbGfDpXJk?= <mans@mansr.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <yw1xh9l6c23e.fsf@unicorn.mansr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 31, 2015 at 8:41 PM, M=C3=A5ns Rullg=C3=A5rd <mans@mansr.co=
m> wrote:
> Andy Shevchenko <andy.shevchenko@gmail.com> writes:
>
>>> +static int nb8800_mdio_read(struct mii_bus *bus, int phy_id, int r=
eg)
>>> +{
>>> +       struct nb8800_priv *priv =3D bus->priv;
>>> +       int val;
>>> +
>>> +       if (!nb8800_mdio_wait(bus))
>>> +               return -ETIMEDOUT;
>>> +
>>> +       val =3D MIIAR_ADDR(phy_id) | MIIAR_REG(reg);
>>> +
>>> +       nb8800_writel(priv, NB8800_MDIO_CMD, val);
>>> +       udelay(10);
>>
>> Why 10? Perhaps add a comment line.
>
> Because it works.  The documentation doesn't mention a delay, but it
> works unreliably without one.

/* Put delay here, otherwise it works unreliably */

>
>>> +       nb8800_writel(priv, NB8800_MDIO_CMD, val | MDIO_CMD_GO);
>>> +
>>> +       if (!nb8800_mdio_wait(bus))
>>> +               return -ETIMEDOUT;
>>> +
>>> +       val =3D nb8800_readl(priv, NB8800_MDIO_STS);
>>> +       if (val & MDIO_STS_ERR)
>>> +               return 0xffff;
>>
>> Can we return an error here?
>
> That breaks the bus scanning in phylib.

You mean this is non-fatal error?

>>> +static int nb8800_poll(struct napi_struct *napi, int budget)
>>> +{
>>> +       struct net_device *dev =3D napi->dev;
>>> +       struct nb8800_priv *priv =3D netdev_priv(dev);
>>> +       struct nb8800_dma_desc *rx;
>>> +       int work =3D 0;
>>> +       int last =3D priv->rx_eoc;
>>> +       int next;
>>> +
>>> +       while (work < budget) {
>>> +               struct rx_buf *rx_buf;
>>> +               u32 report;
>>> +               int len;
>>> +
>>> +               next =3D (last + 1) & (RX_DESC_COUNT - 1);
>>
>> Maybe (last + 1) % RX_DESC_COUNT ? It will not prevent to use
>> non-power-of-two numbers.
>
> We don't want to be doing divisions anyway, but I can certainly chang=
e
> it to % if that's preferred.

I'm pretty sure the result for power-of-two numbers will be the
similar (right shift).

>
>>> +
>>> +               rx_buf =3D &priv->rx_bufs[next];
>>> +               rx =3D &priv->rx_descs[next];
>>
>>> +               report =3D rx->report;
>>
>> Maybe you can use rx->report directly below.
>
> It's in uncached memory, so didn't want to have gcc accidentally doin=
g
> more reads than necessary.

How it would not be possible without ACCESS_ONCE() or similar?

>
>>> +static int nb8800_xmit(struct sk_buff *skb, struct net_device *dev=
)
>>> +{
>>> +       struct nb8800_priv *priv =3D netdev_priv(dev);
>>> +       struct tx_skb_data *skb_data;
>>> +       struct tx_buf *tx_buf;
>>> +       dma_addr_t dma_addr;
>>> +       unsigned int dma_len;
>>> +       int cpsz, next;
>>> +       int frags;
>>> +
>>> +       if (atomic_read(&priv->tx_free) <=3D NB8800_DESC_LOW) {
>>> +               netif_stop_queue(dev);
>>> +               return NETDEV_TX_BUSY;
>>> +       }
>>> +
>>> +       cpsz =3D (8 - (uintptr_t)skb->data) & 7;
>>
>> So, cast to uintptr_t looks strange in this driver, since used only
>> twice in such expression, why not to use plain unsigned int * ?
>
> Because it's not the same thing.  uintptr_t is an integer type the sa=
me
> size as a pointer.  I need to check if the data pointer is 8-byte
> aligned as required by the DMA.

Yes, I understand why you're doing this. But since you use lowest
bits, I think result will be the same even without casting.

>>> +       nb8800_writeb(priv, NB8800_RANDOM_SEED, 0x08);
>>> +
>>> +       /* TX single deferral params */
>>> +       nb8800_writeb(priv, NB8800_TX_SDP, 0xc);
>>> +
>>> +       /* Threshold for partial full */
>>> +       nb8800_writeb(priv, NB8800_PF_THRESHOLD, 0xff);
>>> +
>>> +       /* Pause Quanta */
>>> +       nb8800_writeb(priv, NB8800_PQ1, 0xff);
>>> +       nb8800_writeb(priv, NB8800_PQ2, 0xff);
>>
>> Lot of magic numbers above and below.
>
> Those are from the original driver.  Some of them disagree with the
> documentation, and the "correct" values don't work.

It would be nice to somehow describe them if possible.

>>> +static int nb8800_probe(struct platform_device *pdev)
>>> +{
>>> +       const struct of_device_id *match;
>>> +       const struct nb8800_ops *ops =3D NULL;
>>> +       struct nb8800_priv *priv;
>>> +       struct resource *res;
>>> +       struct net_device *dev;
>>> +       struct mii_bus *bus;
>>> +       const unsigned char *mac;
>>> +       void __iomem *base;
>>> +       int irq;
>>> +       int ret;
>>> +
>>> +       match =3D of_match_device(nb8800_dt_ids, &pdev->dev);
>>> +       if (match)
>>> +               ops =3D match->data;
>>> +
>>> +       res =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
>>> +       if (!res) {
>>> +               dev_err(&pdev->dev, "No MMIO base\n");
>>> +               return -EINVAL;
>>> +       }
>>
>> Move platform_get_resource() just before devm_ioremap_resource() and
>> remove redundant condition with the message.
>>
>>> +       bus =3D devm_mdiobus_alloc(&pdev->dev);
>>> +       if (!bus) {
>>> +               ret =3D -ENOMEM;
>>> +               goto err_disable_clk;
>>> +       }
>>> +
>>> +       bus->name =3D "nb8800-mii";
>>> +       bus->read =3D nb8800_mdio_read;
>>> +       bus->write =3D nb8800_mdio_write;
>>> +       bus->parent =3D &pdev->dev;
>>> +       snprintf(bus->id, MII_BUS_ID_SIZE, "%.*s-mii", MII_BUS_ID_S=
IZE - 5,
>>> +                pdev->name);
>>
>> You are not using any IDs here, why not just to strscpy(bus->id,
>> bus->name, MII_BUS_ID_SIZE);  for now?
>
> I was under the impression the ID should be unique, and there are two=
 of
> these devices in the chip.

But pdev->name is somehow different in the *first* part? Otherwise it
is error prone.
Better to provide bus id derived either from some unique number (let's
say IRQ line), or explicitly from DT.


--=20
With Best Regards,
Andy Shevchenko
