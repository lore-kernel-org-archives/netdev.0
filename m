From: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] [v7] net: emac: emac gigabit ethernet controller driver
Date: Tue, 9 Aug 2016 13:39:31 -0500
Message-ID: <CAL_Jsq+jGjxYDo2+cpmLWNB4HFTBS_iDR3PMk_vm5xSH_S6qmw@mail.gmail.com>
References: <1470255143-3979-1-git-send-email-timur@codeaurora.org>
 <9ebb6cb7-c793-cd76-5283-c9a659d0398f@gmx.de> <57AA2001.2010904@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Lino Sanfilippo <LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-msm <linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Sagar Dharia <sdharia-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Shanker Donthineni <shankerd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Vikram Sethi <vikrams-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Christopher Covington <cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Gilad Avidov <gavidov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
	Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Mark Langsdorf <mlangsdo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Andy Gross <agross-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Timur Tabi <timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <57AA2001.2010904-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 9, 2016 at 1:25 PM, Timur Tabi <timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> wrote:
> Lino Sanfilippo wrote:
>
>>> +/* Fill up transmit descriptors */
>>> +static void emac_tx_fill_tpd(struct emac_adapter *adpt,
>>> +                            struct emac_tx_queue *tx_q, struct sk_buff
>>> *skb,
>>> +                            struct emac_tpd *tpd)
>>> +{
>>> +       u16 nr_frags = skb_shinfo(skb)->nr_frags;
>>> +       unsigned int len = skb_headlen(skb);
>>> +       struct emac_buffer *tpbuf = NULL;
>>> +       unsigned int mapped_len = 0;
>>> +       unsigned int i;
>>> +       int ret;
>>> +
>>> +       /* if Large Segment Offload is (in TCP Segmentation Offload
>>> struct) */
>>> +       if (TPD_LSO(tpd)) {
>>> +               mapped_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
>>> +
>>> +               tpbuf = GET_TPD_BUFFER(tx_q, tx_q->tpd.produce_idx);
>>> +               tpbuf->length = mapped_len;
>>> +               tpbuf->dma_addr =
>>> dma_map_single(adpt->netdev->dev.parent,
>>> +                                                skb->data, mapped_len,
>>> +                                                DMA_TO_DEVICE);
>>> +               ret = dma_mapping_error(adpt->netdev->dev.parent,
>>> +                                       tpbuf->dma_addr);
>>> +               if (ret) {
>>> +                       dev_kfree_skb(skb);
>>> +                       return;
>>> +               }
>>> +
>>> +               TPD_BUFFER_ADDR_L_SET(tpd,
>>> lower_32_bits(tpbuf->dma_addr));
>>> +               TPD_BUFFER_ADDR_H_SET(tpd,
>>> upper_32_bits(tpbuf->dma_addr));
>>
>>
>> You should also take big endian systems into account. This means that if
>> the multi-byte values
>> in the descriptors require little-endian you have to convert from host
>> byte order to le and
>> vice versa. You can use cpu_to_le32() and friends for this.
>
>
> I used to work on PowerPC, so I respect making things work for both endians.
> However, even I think that this is overkill for my driver. First, there's no
> way this driver will ever be used on a big-endian system.  Second, I'm
> pretty sure there are lots of places that would need cpu_to_le32() in order
> to make this driver big-endian compatible. It would be a huge mess.

I thought that too about Calxeda systems and then someone went off and
made them run BE. I was surprised it worked, but I guess when the h/w
doesn't try to do swizzling of i/o things just work.

Rob
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
