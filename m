From: Byungho An <bh74.an@samsung.com>
Subject: RE: [PATCH V6 3/8] net: sxgbe: add TSO support for Samsung sxgbe
Date: Wed, 19 Mar 2014 11:29:40 -0700
Message-ID: <00aa01cf43a1$32ec0d00$98c42700$@samsung.com>
References: <006701cf4334$af6d9af0$0e48d0d0$@samsung.com>
 <CAJ3bTp6BSD5qCJEVJX36Xd=-oX6oDkmTXA2NK42g7zUj6dJgjA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'netdev' <netdev@vger.kernel.org>,
	linux-samsung-soc@vger.kernel.org, devicetree@vger.kernel.org,
	'David Miller' <davem@davemloft.net>,
	"'ks.giri'" <ks.giri@samsung.com>,
	"'siva.kallam'" <siva.kallam@samsung.com>,
	"'vipul.pandya'" <vipul.pandya@samsung.com>,
	"'ilho215.lee'" <ilho215.lee@samsung.com>
To: 'Rayagond Kokatanur' <rayagond@vayavyalabs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:21921 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753371AbaCSS3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 14:29:48 -0400
In-reply-to: <CAJ3bTp6BSD5qCJEVJX36Xd=-oX6oDkmTXA2NK42g7zUj6dJgjA@mail.gmail.com>
Content-language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rayagond Kokatanur <rayagond@vayavyalabs.com> wrote:
> On Wed, Mar 19, 2014 at 11:02 AM, Byungho An <bh74.an@samsung.com> wrote:
[snip]
> >
> >         /* save the skb address */
> >         tqueue->tx_skbuff[entry] = skb;
> >
> >         if (!is_jumbo) {
> > -               tx_desc->tdes01 = dma_map_single(priv->device, skb->data,
> > -                                                  no_pagedlen,
DMA_TO_DEVICE);
> > -               if (dma_mapping_error(priv->device, tx_desc->tdes01))
> > -                       pr_err("%s: TX dma mapping failed!!\n", __func__);
> > -
> > -               priv->hw->desc->prepare_tx_desc(tx_desc, 1, no_pagedlen,
> > -                                               no_pagedlen);
> > +               if (likely(skb_is_gso(skb))) {
> > +                       /* TSO support */
> > +                       mss = skb_shinfo(skb)->gso_size;
> > +
> > + priv->hw->desc->tx_ctxt_desc_set_mss(ctxt_desc, mss);
> 
> No need to issue context descriptor for every TSO packets. Program context
descriptor only if MSS value is value is changed compared
> to previous TSO packet MSS value. By this way we can reduce the one extra
descriptor fetch by device and improve the performance.
OK. This will be applied in the  next post.

[snip]
> > @@ -1893,7 +1943,9 @@ struct sxgbe_priv_data *sxgbe_dvr_probe(struct
> > device *device,
> >
> >         ndev->netdev_ops = &sxgbe_netdev_ops;
> >
> > -       ndev->hw_features = NETIF_F_SG | NETIF_F_RXCSUM;
> > +       ndev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM |
NETIF_F_IPV6_CSUM |
> > +               NETIF_F_RXCSUM | NETIF_F_TSO | NETIF_F_TSO6 |
> > +               NETIF_F_GRO;
> 
> Enable TSO only if HW supports, hence we have to check for HW
feature/capability registers here also.
OK. Thanks

> 
> >         ndev->features |= ndev->hw_features | NETIF_F_HIGHDMA;
> >         ndev->watchdog_timeo = msecs_to_jiffies(TX_TIMEO);
> >
> > @@ -1905,6 +1957,13 @@ struct sxgbe_priv_data *sxgbe_dvr_probe(struct
device *device,
> >         if (flow_ctrl)
> >                 priv->flow_ctrl = SXGBE_FLOW_AUTO;      /* RX/TX pause on
*/
> >
> > +       /* Enable TCP segmentation offload for all DMA channels */
> > +       if (priv->hw_cap.tcpseg_offload) {
> > +               SXGBE_FOR_EACH_QUEUE(SXGBE_TX_QUEUES, queue_num) {
> > +                       priv->hw->dma->enable_tso(priv->ioaddr,
queue_num);
> > +               }
> > +       }
> > +
> >         /* Rx Watchdog is available, enable depend on platform data */
> >         if (!priv->plat->riwt_off) {
> >                 priv->use_riwt = 1;
> > --
> > 1.7.10.4
> >
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org More majordomo info
> > at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the
body of a message to majordomo@vger.kernel.org More
> majordomo info at  http://vger.kernel.org/majordomo-info.html
