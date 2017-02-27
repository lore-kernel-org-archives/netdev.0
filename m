From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [PATCH net-next 4/6] drivers: net: xgene-v2: Add base driver
Date: Sun, 26 Feb 2017 21:05:36 -0800
Message-ID: <CAKh23F=nKNOgY79ANeLMmFSOOhwP=dHKsdz=VFBUrVe_7dCtCQ@mail.gmail.com>
References: <1485889401-13909-1-git-send-email-isubramanian@apm.com>
 <1485889401-13909-5-git-send-email-isubramanian@apm.com>
 <c6ae0303-4ac9-987b-5477-fa28ddc00f83@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, patches <patches@apm.com>,
 Keyur Chudgar <kchudgar@apm.com>, David Miller <davem@davemloft.net>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <c6ae0303-4ac9-987b-5477-fa28ddc00f83@gmail.com>
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

Hi Florian,

On Tue, Jan 31, 2017 at 12:31 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 01/31/2017 11:03 AM, Iyappan Subramanian wrote:
>> This patch adds,
>>
>>      - probe, remove, shutdown
>>      - open, close and stats
>>      - create and delete ring
>>      - request and delete irq
>>
>> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
>> Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
>> ---
>
>> +static void xge_delete_desc_rings(struct net_device *ndev)
>> +{
>> +     struct xge_pdata *pdata = netdev_priv(ndev);
>> +     struct device *dev = &pdata->pdev->dev;
>> +     struct xge_desc_ring *ring;
>> +
>> +     ring = pdata->tx_ring;
>> +     if (ring) {
>> +             if (ring->skbs)
>> +                     devm_kfree(dev, ring->skbs);
>> +             if (ring->pkt_bufs)
>> +                     devm_kfree(dev, ring->pkt_bufs);
>> +             devm_kfree(dev, ring);
>> +     }
>
> The very fact that you have to do the devm_kfree suggests that the way
> you manage the lifetime of the ring is not appropriate, and in fact, if
> we look at how xge_create_desc_ring() is called, in the driver's probe
> function indicates that if the network interface is never openeded, we
> are just wasting memory sitting there and doing nothing. You should
> consider moving this to the ndo_open(), resp. ndo_close() functions to
> optimize memory consumption wrt. the network interface state.

I will move these to open and close functions and will use dma_zalloc() APIs.

>
>> +
>> +     ring = pdata->rx_ring;
>> +     if (ring) {
>> +             if (ring->skbs)
>> +                     devm_kfree(dev, ring->skbs);
>> +             devm_kfree(dev, ring);
>> +     }
>> +}
>> +
>> +static struct xge_desc_ring *xge_create_desc_ring(struct net_device *ndev)
>> +{
>> +     struct xge_pdata *pdata = netdev_priv(ndev);
>> +     struct device *dev = &pdata->pdev->dev;
>> +     struct xge_desc_ring *ring;
>> +     u16 size;
>> +
>> +     ring = devm_kzalloc(dev, sizeof(struct xge_desc_ring), GFP_KERNEL);
>> +     if (!ring)
>> +             return NULL;
>> +
>> +     ring->ndev = ndev;
>> +
>> +     size = XGENE_ENET_DESC_SIZE * XGENE_ENET_NUM_DESC;
>> +     ring->desc_addr = dmam_alloc_coherent(dev, size, &ring->dma_addr,
>> +                                           GFP_KERNEL | __GFP_ZERO);
>
> There is no dmam_zalloc_coherent()? Then again, that seems to be a
> candidate for dma_zalloc_coherent() and moving this to the ndo_open()
> function.
>
>> +     if (!ring->desc_addr) {
>> +             devm_kfree(dev, ring);
>> +             return NULL;
>> +     }
>> +
>> +     xge_setup_desc(ring);
>> +
>> +     return ring;
>> +}
>> +
>> +static int xge_refill_buffers(struct net_device *ndev, u32 nbuf)
>> +{
>> +     struct xge_pdata *pdata = netdev_priv(ndev);
>> +     struct xge_desc_ring *ring = pdata->rx_ring;
>> +     const u8 slots = XGENE_ENET_NUM_DESC - 1;
>> +     struct device *dev = &pdata->pdev->dev;
>> +     struct xge_raw_desc *raw_desc;
>> +     u64 addr_lo, addr_hi;
>> +     u8 tail = ring->tail;
>> +     struct sk_buff *skb;
>> +     dma_addr_t dma_addr;
>> +     u16 len;
>> +     int i;
>> +
>> +     for (i = 0; i < nbuf; i++) {
>> +             raw_desc = &ring->raw_desc[tail];
>> +
>> +             len = XGENE_ENET_STD_MTU;
>> +             skb = netdev_alloc_skb(ndev, len);
>> +             if (unlikely(!skb))
>> +                     return -ENOMEM;
>
> Are not you leaving holes in your RX ring if you do that?

No.  The probe will fail and clean up the unused buffers.

>
>> +
>> +             dma_addr = dma_map_single(dev, skb->data, len, DMA_FROM_DEVICE);
>> +             if (dma_mapping_error(dev, dma_addr)) {
>> +                     netdev_err(ndev, "DMA mapping error\n");
>> +                     dev_kfree_skb_any(skb);
>> +                     return -EINVAL;
>> +             }
>
>
>> +static void xge_timeout(struct net_device *ndev)
>> +{
>> +     struct xge_pdata *pdata = netdev_priv(ndev);
>> +     struct netdev_queue *txq;
>> +
>> +     xge_mac_reset(pdata);
>> +
>> +     txq = netdev_get_tx_queue(ndev, 0);
>> +     txq->trans_start = jiffies;
>> +     netif_tx_start_queue(txq);
>
> It most likely is not that simple, don't you want to walk the list of
> pending transmissed SKBs and free them all?

I'll add more exhaustive clean up and restart of Tx hardware.

>
>> +}
>> +
>> +static void xge_get_stats64(struct net_device *ndev,
>> +                         struct rtnl_link_stats64 *storage)
>> +{
>> +     struct xge_pdata *pdata = netdev_priv(ndev);
>> +     struct xge_stats *stats = &pdata->stats;
>> +
>> +     storage->tx_packets += stats->tx_packets;
>> +     storage->tx_bytes += stats->tx_bytes;
>> +
>> +     storage->rx_packets += stats->rx_packets;
>> +     storage->rx_bytes += stats->rx_bytes;
>
> Pretty sure you need some synchronization primitives here for non 64-bit
> architectures (maybe this driver is not used outside of 64-bit, but still).

Synchronization primitives are not required for this driver, yet!

>
>
>> +
>> +     ndev->hw_features = ndev->features;
>> +
>> +     ret = dma_coerce_mask_and_coherent(dev, DMA_BIT_MASK(64));
>> +     if (ret) {
>> +             netdev_err(ndev, "No usable DMA configuration\n");
>> +             goto err;
>> +     }
>> +
>> +     ret = xge_init_hw(ndev);
>> +     if (ret)
>> +             goto err;
>
> Missing netif_carrier_off() right before the register_netdev().

I'll add them.

>
>> +
>> +     ret = register_netdev(ndev);
>> +     if (ret) {
>> +             netdev_err(ndev, "Failed to register netdev\n");
>> +             goto err;
>> +     }
>
>
>
> --
> Florian
