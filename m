From: Byungho An <bh74.an@samsung.com>
Subject: RE: [PATCH V11 2/7] net: sxgbe: add basic framework for Samsung 10Gb
 ethernet driver
Date: Sat, 22 Mar 2014 17:39:24 -0700
Message-ID: <008c01cf4630$591f6d00$0b5e4700$@samsung.com>
References: <007f01cf4597$50abac40$f20304c0$@samsung.com>
 <CAOwfj2PyvspY7iZjUibYRW6AgYB821BRWGdOXFwQvK7iTvivNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
	devicetree@vger.kernel.org, 'David Miller' <davem@davemloft.net>,
	'GIRISH K S' <ks.giri@samsung.com>,
	'SIVAREDDY KALLAM' <siva.kallam@samsung.com>,
	'Vipul Chandrakant' <vipul.pandya@samsung.com>,
	'Ilho Lee' <ilho215.lee@samsung.com>,
	'Jay Bhat' <j.bhat@samsung.com>
To: 'Vince Bridgers' <vbridgers2013@gmail.com>
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
In-reply-to: <CAOwfj2PyvspY7iZjUibYRW6AgYB821BRWGdOXFwQvK7iTvivNw@mail.gmail.com>
Content-language: en-us
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Vince Bridgers <vbridgers2013@gmail.com> :
> See comments inline
> 
> On Sat, Mar 22, 2014 at 1:23 AM, Byungho An <bh74.an@samsung.com> wrote:
> > From: Siva Reddy <siva.kallam@samsung.com>
> >
> > This patch adds support for Samsung 10Gb ethernet driver(sxgbe).
> >

[snip]

> > +       /* program desc registers */
> > +       writel(dma_tx >> 32,
> > +              ioaddr + SXGBE_DMA_CHA_TXDESC_HADD_REG(cha_num));
> > +       writel(dma_tx & 0xFFFFFFFF,
> > +              ioaddr + SXGBE_DMA_CHA_TXDESC_LADD_REG(cha_num));
> > +
> > +       writel(dma_rx >> 32,
> > +              ioaddr + SXGBE_DMA_CHA_RXDESC_HADD_REG(cha_num));
> > +       writel(dma_rx & 0xFFFFFFFF,
> > +              ioaddr + SXGBE_DMA_CHA_RXDESC_LADD_REG(cha_num));
> 
> use upper_32_bits and lower_32_bits for extracting the upper/lower
> 32-bit portions of a phys addrs. See
> https://www.kernel.org/doc/htmldocs/device-drivers/API-upper-32-bits.html.
OK.

[snip]

> > +       /* save the skb address */
> > +       tqueue->tx_skbuff[entry] = skb;
> > +
> > +       if (!is_jumbo) {
> > +               tx_desc->tdes01 = dma_map_single(priv->device, skb->data,
> > +                                                  no_pagedlen,
DMA_TO_DEVICE);
> > +               if (dma_mapping_error(priv->device, tx_desc->tdes01))
> > +                       pr_err("%s: TX dma mapping failed!!\n", __func__);
> > +
> > +               priv->hw->desc->prepare_tx_desc(tx_desc, 1, no_pagedlen,
> > +                                               no_pagedlen);
> 
> you're prototype is void (*prepare_tx_desc)(struct sxgbe_tx_norm_desc
> *p, u8 is_fd, int buf1_len, int pkt_len, int cksum) defined in
> sxgbe_desc.h, but you're usage is different? Am I missing something
> here? I found this when I tried to download this first patch and
> compile it independent of the application of the entire series.
OK, I'll fix it actually csum will be used after this patch....

> 
> > +       }
> > +
> > +       for (frag_num = 0; frag_num < nr_frags; frag_num++) {
> > +               const skb_frag_t *frag =
&skb_shinfo(skb)->frags[frag_num];
> > +               int len = skb_frag_size(frag);
> > +
> > +               entry = (++tqueue->cur_tx) % tx_rsize;
> > +               tx_desc = tqueue->dma_tx + entry;
> > +               tx_desc->tdes01 = skb_frag_dma_map(priv->device, frag, 0,
len,
> > +                                                  DMA_TO_DEVICE);
> > +
> > +               tqueue->tx_skbuff_dma[entry] = tx_desc->tdes01;
> > +               tqueue->tx_skbuff[entry] = NULL;
> > +
> > +               /* prepare the descriptor */
> > +               priv->hw->desc->prepare_tx_desc(tx_desc, 0, len,
> > +                                               len);
> 
> you're prototype is void (*prepare_tx_desc)(struct sxgbe_tx_norm_desc
> *p, u8 is_fd, int buf1_len, int pkt_len, int cksum) defined in
> sxgbe_desc.h, but you're usage is different? Am I missing something
> here? I found this when I tried to download this first patch and
> compile it independent of the application of the entire series.
same above

[snip]

> > +#endif /* __SXGBE_PLATFORM_H__ */
> > --
> > 1.7.10.4
> 
> Have you tried applying this series to this point and compiling? Since
> the prepare_tx_desc usage and prototype are different, I'm not so sure
> the series applied up to this patch will successfully compile.
sure with this series.. please refer above.

> 
> >
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
