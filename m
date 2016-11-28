From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v3 net-next 1/2] net: ethernet: slicoss: add slicoss
 gigabit ethernet driver
Date: Sun, 27 Nov 2016 20:56:11 -0800
Message-ID: <a6f99dc8-60e4-7727-0764-abdfac81c713@gmail.com>
References: <1480162850-8014-1-git-send-email-LinoSanfilippo@gmx.de>
 <1480162850-8014-2-git-send-email-LinoSanfilippo@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>, davem@davemloft.net,
 charrer@alacritech.com, liodot@gmail.com, gregkh@linuxfoundation.org,
 andrew@lunn.ch
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1480162850-8014-2-git-send-email-LinoSanfilippo@gmx.de>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On 11/26/2016 04:20 AM, Lino Sanfilippo wrote:
> Add driver for Alacritech gigabit ethernet cards with SLIC (session-layer
> interface control) technology. The driver provides basic support without
> SLIC for the following devices:
> 
> - Mojave cards (single port PCI Gigabit) both copper and fiber
> - Oasis cards (single and dual port PCI-x Gigabit) copper and fiber
> - Kalahari cards (dual and quad port PCI-e Gigabit) copper and fiber

This looks great, a few nits below:


> +#define SLIC_MAX_TX_COMPLETIONS		100

You usually don't want to limit the number of TX completion, if the
entire TX ring needs to be cleaned, you would want to allow that.

[snip]

> +	while (slic_get_free_rx_descs(rxq) > SLIC_MAX_REQ_RX_DESCS) {
> +		skb = alloc_skb(maplen + ALIGN_MASK, gfp);
> +		if (!skb)
> +			break;
> +
> +		paddr = dma_map_single(&sdev->pdev->dev, skb->data, maplen,
> +				       DMA_FROM_DEVICE);
> +		if (dma_mapping_error(&sdev->pdev->dev, paddr)) {
> +			netdev_err(dev, "mapping rx packet failed\n");
> +			/* drop skb */
> +			dev_kfree_skb_any(skb);
> +			break;
> +		}
> +		/* ensure head buffer descriptors are 256 byte aligned */
> +		offset = 0;
> +		misalign = paddr & ALIGN_MASK;
> +		if (misalign) {
> +			offset = SLIC_RX_BUFF_ALIGN - misalign;
> +			skb_reserve(skb, offset);
> +		}
> +		/* the HW expects dma chunks for descriptor + frame data */
> +		desc = (struct slic_rx_desc *)skb->data;
> +		memset(desc, 0, sizeof(*desc));

Do you really need to zero-out the prepending RX descriptor? Are not you
missing a write barrier here?

[snip]

> +
> +		dma_sync_single_for_cpu(&sdev->pdev->dev,
> +					dma_unmap_addr(buff, map_addr),
> +					buff->addr_offset + sizeof(*desc),
> +					DMA_FROM_DEVICE);
> +
> +		status = le32_to_cpu(desc->status);
> +		if (!(status & SLIC_IRHDDR_SVALID))
> +			break;
> +
> +		buff->skb = NULL;
> +
> +		dma_unmap_single(&sdev->pdev->dev,
> +				 dma_unmap_addr(buff, map_addr),
> +				 dma_unmap_len(buff, map_len),
> +				 DMA_FROM_DEVICE);

This is potentially inefficient, you already did a cache invalidation
for the RX descriptor here, you could be more efficient with just
invalidating the packet length, minus the descriptor length.

> +
> +		/* skip rx descriptor that is placed before the frame data */
> +		skb_reserve(skb, SLIC_RX_BUFF_HDR_SIZE);
> +
> +		if (unlikely(status & SLIC_IRHDDR_ERR)) {
> +			slic_handle_frame_error(sdev, skb);
> +			dev_kfree_skb_any(skb);
> +		} else {
> +			struct ethhdr *eh = (struct ethhdr *)skb->data;
> +
> +			if (is_multicast_ether_addr(eh->h_dest))
> +				SLIC_INC_STATS_COUNTER(&sdev->stats, rx_mcasts);
> +
> +			len = le32_to_cpu(desc->length) & SLIC_IRHDDR_FLEN_MSK;
> +			skb_put(skb, len);
> +			skb->protocol = eth_type_trans(skb, dev);
> +			skb->ip_summed = CHECKSUM_UNNECESSARY;
> +			skb->dev = dev;

eth_type_trans() already assigns skb->dev = dev;

> +static int slic_poll(struct napi_struct *napi, int todo)
> +{
> +	struct slic_device *sdev = container_of(napi, struct slic_device, napi);
> +	struct slic_shmem *sm = &sdev->shmem;
> +	struct slic_shmem_data *sm_data = sm->shmem_data;
> +	u32 isr = le32_to_cpu(sm_data->isr);
> +	unsigned int done = 0;
> +
> +	slic_handle_irq(sdev, isr, todo, &done);
> +
> +	if (done < todo) {
> +		napi_complete(napi);

napi_complete_done() since you know how many packets you completed.

> +		/* reenable irqs */
> +		sm_data->isr = 0;
> +		/* make sure sm_data->isr is cleard before irqs are reenabled */
> +		wmb();
> +		slic_write(sdev, SLIC_REG_ISR, 0);
> +		slic_flush_write(sdev);
> +	}
> +
> +	return done;
> +}
> +
> +static irqreturn_t slic_irq(int irq, void *dev_id)
> +{
> +	struct slic_device *sdev = dev_id;
> +	struct slic_shmem *sm = &sdev->shmem;
> +	struct slic_shmem_data *sm_data = sm->shmem_data;
> +
> +	slic_write(sdev, SLIC_REG_ICR, SLIC_ICR_INT_MASK);
> +	slic_flush_write(sdev);
> +	/* make sure sm_data->isr is read after ICR_INT_MASK is set */
> +	wmb();
> +
> +	if (!sm_data->isr) {
> +		dma_rmb();
> +		/* spurious interrupt */
> +		slic_write(sdev, SLIC_REG_ISR, 0);
> +		slic_flush_write(sdev);
> +		return IRQ_NONE;
> +	}
> +
> +	napi_schedule(&sdev->napi);

Likewise napi_schedule_irqoff() can be used here.
-- 
Florian
