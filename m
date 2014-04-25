From: Mark Salter <msalter@redhat.com>
Subject: Re: [PATCH v3 4/4] drivers: net: Add APM X-Gene SoC ethernet driver
 support.
Date: Fri, 25 Apr 2014 09:13:43 -0400
Message-ID: <1398431623.3010.76.camel@deneb.redhat.com>
References: <1397702368-4846-1-git-send-email-isubramanian@apm.com>
 <1397702368-4846-5-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org, patches@apm.com,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 gregkh@linuxfoundation.org, Keyur Chudgar <kchudgar@apm.com>,
 davem@davemloft.net, jcm@redhat.com, Ravi Patel <rapatel@apm.com>
To: Iyappan Subramanian <isubramanian@apm.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1397702368-4846-5-git-send-email-isubramanian@apm.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-04-16 at 19:39 -0700, Iyappan Subramanian wrote:
> +static int xgene_enet_refill_bufpool(struct xgene_enet_desc_ring *buf_pool,
> +                                    u32 nbuf)
> +{
> +       struct sk_buff *skb;
> +       struct xgene_enet_desc16 *desc;
> +       struct net_device *ndev;
> +       struct device *dev;
> +       dma_addr_t dma_addr;
> +       u32 tail = buf_pool->tail;
> +       u32 slots = buf_pool->slots - 1;
> +       int i, ret = 0;
> +       u16 bufdatalen = BUF_LEN_CODE_2K | (SKB_BUFFER_SIZE & GENMASK(11, 0));
> +
> +       ndev = buf_pool->ndev;
> +       dev = ndev_to_dev(buf_pool->ndev);
> +
> +       for (i = 0; i < nbuf; i++) {
> +               desc = &buf_pool->desc16[tail];
> +
> +               skb = netdev_alloc_skb_ip_align(ndev, XGENE_ENET_MAX_MTU);
> +               if (unlikely(!skb)) {
> +                       netdev_err(ndev, "Could not allocate skb");
> +                       ret = -ENOMEM;
> +                       goto out;
> +               }
> +               buf_pool->rx_skb[tail] = skb;
> +
> +               dma_addr = dma_map_single(dev, skb->data, skb->len,
> +                                         DMA_TO_DEVICE);

Shouldn't this be:

               dma_addr = dma_map_single(dev, skb->data, XGENE_ENET_MAX_MTU,
                                         DMA_TO_DEVICE);

You just allocated the skb and nothing is in it, so ->len is zero.

> +
> +static int xgene_enet_rx_frame(struct xgene_enet_desc_ring *rx_ring,
> +                               struct xgene_enet_desc *desc)
> +{
> +       struct net_device *ndev = rx_ring->ndev;
> +       struct device *dev = ndev_to_dev(rx_ring->ndev);
> +       struct xgene_enet_desc_ring *buf_pool = rx_ring->buf_pool;
> +       u32 datalen, skb_index;
> +       struct sk_buff *skb;
> +       dma_addr_t pa;
> +       size_t len;
> +       int ret = 0;
> +
> +       skb_index = get_desc(desc, USERINFO);
> +       skb = buf_pool->rx_skb[skb_index];
> +       prefetch(skb->data - NET_IP_ALIGN);
> +
> +       /* Strip off CRC as HW isn't doing this */
> +       datalen = get_desc(desc, BUFDATALEN);
> +       datalen -= 4;
> +       skb_put(skb, datalen);
> +
> +       pa = (dma_addr_t)get_desc(desc, DATAADDR);
> +       len = get_desc(desc, BUFDATALEN);
> +       dma_unmap_single(dev, pa, len, DMA_TO_DEVICE);
> +

And here, should be:

	dma_unmap_single(dev, pa, XGENE_ENET_MAX_MTU, DMA_TO_DEVICE);

You want to unmap the whole buffer, not just the part actually used.

The underlying code works with pages, so the existing code may work by
chance, but you get err_printks is you turn on dma debug.

--Mark
