From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH v4] net: ethernet: add driver for Aurora VLSI NB8800 Ethernet controller
Date: Sat, 31 Oct 2015 21:41:00 +0000
Message-ID: <yw1x8u6ibtsj.fsf@unicorn.mansr.com>
References: <1446137333-1822-1-git-send-email-mans@mansr.com>
	<CAHp75VdNY-=8Kx09CvgVeL0J3Wy=3jLE0ac5nHRt0qaqkuprhA@mail.gmail.com>
	<yw1xh9l6c23e.fsf@unicorn.mansr.com>
	<CAHp75VeeY8vqPB4U6kL18FiQTrmEt6Bmu0jzLgAG_zorkTbU7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([81.2.72.234]:37110 "EHLO unicorn.mansr.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751288AbbJaVlJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Oct 2015 17:41:09 -0400
In-Reply-To: <CAHp75VeeY8vqPB4U6kL18FiQTrmEt6Bmu0jzLgAG_zorkTbU7Q@mail.gmail.com>
	(Andy Shevchenko's message of "Sat, 31 Oct 2015 22:06:45 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Shevchenko <andy.shevchenko@gmail.com> writes:

>>>> +       nb8800_writel(priv, NB8800_MDIO_CMD, val | MDIO_CMD_GO);
>>>> +
>>>> +       if (!nb8800_mdio_wait(bus))
>>>> +               return -ETIMEDOUT;
>>>> +
>>>> +       val =3D nb8800_readl(priv, NB8800_MDIO_STS);
>>>> +       if (val & MDIO_STS_ERR)
>>>> +               return 0xffff;
>>>
>>> Can we return an error here?
>>
>> That breaks the bus scanning in phylib.
>
> You mean this is non-fatal error?

It's what you get if nothing responded to the address.

>>>> +
>>>> +               rx_buf =3D &priv->rx_bufs[next];
>>>> +               rx =3D &priv->rx_descs[next];
>>>
>>>> +               report =3D rx->report;
>>>
>>> Maybe you can use rx->report directly below.
>>
>> It's in uncached memory, so didn't want to have gcc accidentally doi=
ng
>> more reads than necessary.
>
> How it would not be possible without ACCESS_ONCE() or similar?

True, it probably doesn't make a difference.  Sometimes copying a value
to a local variable prevents re-reads due to potential pointer aliasing=
,
but I don't think that's an issue here.

>>>> +static int nb8800_xmit(struct sk_buff *skb, struct net_device *de=
v)
>>>> +{
>>>> +       struct nb8800_priv *priv =3D netdev_priv(dev);
>>>> +       struct tx_skb_data *skb_data;
>>>> +       struct tx_buf *tx_buf;
>>>> +       dma_addr_t dma_addr;
>>>> +       unsigned int dma_len;
>>>> +       int cpsz, next;
>>>> +       int frags;
>>>> +
>>>> +       if (atomic_read(&priv->tx_free) <=3D NB8800_DESC_LOW) {
>>>> +               netif_stop_queue(dev);
>>>> +               return NETDEV_TX_BUSY;
>>>> +       }
>>>> +
>>>> +       cpsz =3D (8 - (uintptr_t)skb->data) & 7;
>>>
>>> So, cast to uintptr_t looks strange in this driver, since used only
>>> twice in such expression, why not to use plain unsigned int * ?
>>
>> Because it's not the same thing.  uintptr_t is an integer type the s=
ame
>> size as a pointer.  I need to check if the data pointer is 8-byte
>> aligned as required by the DMA.
>
> Yes, I understand why you're doing this. But since you use lowest
> bits, I think result will be the same even without casting.

You can't do that kind of arithmetic on pointer values.  They have to b=
e
cast to an integer type first.

>>>> +       nb8800_writeb(priv, NB8800_RANDOM_SEED, 0x08);
>>>> +
>>>> +       /* TX single deferral params */
>>>> +       nb8800_writeb(priv, NB8800_TX_SDP, 0xc);
>>>> +
>>>> +       /* Threshold for partial full */
>>>> +       nb8800_writeb(priv, NB8800_PF_THRESHOLD, 0xff);
>>>> +
>>>> +       /* Pause Quanta */
>>>> +       nb8800_writeb(priv, NB8800_PQ1, 0xff);
>>>> +       nb8800_writeb(priv, NB8800_PQ2, 0xff);
>>>
>>> Lot of magic numbers above and below.
>>
>> Those are from the original driver.  Some of them disagree with the
>> documentation, and the "correct" values don't work.
>
> It would be nice to somehow describe them if possible.

I'll see what I can do.

--=20
M=E5ns Rullg=E5rd
mans@mansr.com
