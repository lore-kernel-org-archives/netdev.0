From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800 Ethernet controller
Date: Tue, 10 Nov 2015 22:34:53 +0000
Message-ID: <yw1xr3jxpjoy.fsf@unicorn.mansr.com>
References: <1447172063-27234-1-git-send-email-mans@mansr.com>
	<CAHp75Vch3vJEqYsCRUoctEmF0EoFx+0y7ZO+LjmdpQKAoikiOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, slash.tmp@free.fr
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHp75Vch3vJEqYsCRUoctEmF0EoFx+0y7ZO+LjmdpQKAoikiOA@mail.gmail.com>
	(Andy Shevchenko's message of "Wed, 11 Nov 2015 00:09:23 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Shevchenko <andy.shevchenko@gmail.com> writes:

>> +static inline void nb8800_maskb(struct nb8800_priv *priv, int reg,
>> +                               u32 mask, u32 val)
>> +{
>> +       u32 old =3D nb8800_readb(priv, reg);
>> +       u32 new =3D (old & ~mask) | val;
>
> Shoudn't be "=E2=80=A6 | (val & mask);" ?

No, it's meant to replace the bits in mask with the corresponding bits
from val.

> + empty line?
>
>> +       if (new !=3D old)
>> +               nb8800_writeb(priv, reg, new);
>> +}
>> +

[...]

>> +static void nb8800_receive(struct net_device *dev, int i, int len)
>
> unsigned int i ?
> len as well?

Does it matter?  The values are nowhere near overflowing signed int.


[...]

>> +               /* If a packet arrived after we last checked but
>> +                * before writing RX_ITR, the interrupt will be
>> +                * delayed, so we retrieve it now. */
>
> Block comments usually
> /*
>  * text
>  */

Documentation/CodingStyle says net/ and drivers/net/ are special, thoug=
h
currently a mix of styles can be found.  Personally, I don't
particularly care.

> Can be longer lines?

Still won't fit on two lines.

>> +               if (priv->rx_descs[next].report)
>> +                       goto again;
>> +
>> +               napi_complete_done(napi, work);
>> +       }
>> +
>> +       return work;
>> +}
>> +
>> +static void nb8800_tx_dma_start(struct net_device *dev)
>> +{
>> +       struct nb8800_priv *priv =3D netdev_priv(dev);
>> +       struct nb8800_tx_buf *txb;
>> +       u32 txc_cr;
>> +
>> +       txb =3D &priv->tx_bufs[priv->tx_queue];
>> +       if (!txb->ready)
>> +               return;
>> +
>> +       txc_cr =3D nb8800_readl(priv, NB8800_TXC_CR);
>> +       if (txc_cr & TCR_EN)
>> +               return;
>> +
>> +       nb8800_writel(priv, NB8800_TX_DESC_ADDR, txb->dma_desc);
>> +       wmb();          /* ensure desc addr is written before starti=
ng DMA */
>
> Hm=E2=80=A6 Have I missed corresponding rmb() ? If it's about MMIO, p=
erhaps mmiowb() ?

Possibly.

>> +       nb8800_writel(priv, NB8800_TXC_CR, txc_cr | TCR_EN);
>> +
>> +       priv->tx_queue =3D (priv->tx_queue + txb->chain_len) % TX_DE=
SC_COUNT;
>> +}

--=20
M=C3=A5ns Rullg=C3=A5rd
mans@mansr.com
