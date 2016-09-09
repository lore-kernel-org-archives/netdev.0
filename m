From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net-next PATCH v2 2/2] e1000: bundle xdp xmit routines
Date: Fri, 9 Sep 2016 16:44:47 -0700
Message-ID: <CALx6S35VCq9yPjcuhtx6jEJ78-WugkQZ6GSsqkcTr0Fa7edkVg@mail.gmail.com>
References: <20160909212915.4001.25504.stgit@john-Precision-Tower-5810> <20160909212938.4001.40540.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        u9012063@gmail.com,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:34309 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750848AbcIIXos (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 19:44:48 -0400
Received: by mail-qt0-f196.google.com with SMTP id e5so3403804qtb.1
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2016 16:44:48 -0700 (PDT)
In-Reply-To: <20160909212938.4001.40540.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 9, 2016 at 2:29 PM, John Fastabend <john.fastabend@gmail.com> wrote:
> e1000 supports a single TX queue so it is being shared with the stack
> when XDP runs XDP_TX action. This requires taking the xmit lock to
> ensure we don't corrupt the tx ring. To avoid taking and dropping the
> lock per packet this patch adds a bundling implementation to submit
> a bundle of packets to the xmit routine.
>
> I tested this patch running e1000 in a VM using KVM over a tap
> device using pktgen to generate traffic along with 'ping -f -l 100'.
>
Hi John,

How does this interact with BQL on e1000?

Tom

> Suggested-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  drivers/net/ethernet/intel/e1000/e1000.h      |   10 +++
>  drivers/net/ethernet/intel/e1000/e1000_main.c |   81 +++++++++++++++++++------
>  2 files changed, 71 insertions(+), 20 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/e1000/e1000.h b/drivers/net/ethernet/intel/e1000/e1000.h
> index 5cf8a0a..877b377 100644
> --- a/drivers/net/ethernet/intel/e1000/e1000.h
> +++ b/drivers/net/ethernet/intel/e1000/e1000.h
> @@ -133,6 +133,8 @@ struct e1000_adapter;
>  #define E1000_TX_QUEUE_WAKE    16
>  /* How many Rx Buffers do we bundle into one write to the hardware ? */
>  #define E1000_RX_BUFFER_WRITE  16 /* Must be power of 2 */
> +/* How many XDP XMIT buffers to bundle into one xmit transaction */
> +#define E1000_XDP_XMIT_BUNDLE_MAX E1000_RX_BUFFER_WRITE
>
>  #define AUTO_ALL_MODES         0
>  #define E1000_EEPROM_82544_APM 0x0004
> @@ -168,6 +170,11 @@ struct e1000_rx_buffer {
>         dma_addr_t dma;
>  };
>
> +struct e1000_rx_buffer_bundle {
> +       struct e1000_rx_buffer *buffer;
> +       u32 length;
> +};
> +
>  struct e1000_tx_ring {
>         /* pointer to the descriptor ring memory */
>         void *desc;
> @@ -206,6 +213,9 @@ struct e1000_rx_ring {
>         struct e1000_rx_buffer *buffer_info;
>         struct sk_buff *rx_skb_top;
>
> +       /* array of XDP buffer information structs */
> +       struct e1000_rx_buffer_bundle *xdp_buffer;
> +
>         /* cpu for rx queue */
>         int cpu;
>
> diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
> index 91d5c87..b985271 100644
> --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
> +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
> @@ -1738,10 +1738,18 @@ static int e1000_setup_rx_resources(struct e1000_adapter *adapter,
>         struct pci_dev *pdev = adapter->pdev;
>         int size, desc_len;
>
> +       size = sizeof(struct e1000_rx_buffer_bundle) *
> +                       E1000_XDP_XMIT_BUNDLE_MAX;
> +       rxdr->xdp_buffer = vzalloc(size);
> +       if (!rxdr->xdp_buffer)
> +               return -ENOMEM;
> +
>         size = sizeof(struct e1000_rx_buffer) * rxdr->count;
>         rxdr->buffer_info = vzalloc(size);
> -       if (!rxdr->buffer_info)
> +       if (!rxdr->buffer_info) {
> +               vfree(rxdr->xdp_buffer);
>                 return -ENOMEM;
> +       }
>
>         desc_len = sizeof(struct e1000_rx_desc);
>
> @@ -1754,6 +1762,7 @@ static int e1000_setup_rx_resources(struct e1000_adapter *adapter,
>                                         GFP_KERNEL);
>         if (!rxdr->desc) {
>  setup_rx_desc_die:
> +               vfree(rxdr->xdp_buffer);
>                 vfree(rxdr->buffer_info);
>                 return -ENOMEM;
>         }
> @@ -2087,6 +2096,9 @@ static void e1000_free_rx_resources(struct e1000_adapter *adapter,
>
>         e1000_clean_rx_ring(adapter, rx_ring);
>
> +       vfree(rx_ring->xdp_buffer);
> +       rx_ring->xdp_buffer = NULL;
> +
>         vfree(rx_ring->buffer_info);
>         rx_ring->buffer_info = NULL;
>
> @@ -3369,33 +3381,52 @@ static void e1000_tx_map_rxpage(struct e1000_tx_ring *tx_ring,
>  }
>
>  static void e1000_xmit_raw_frame(struct e1000_rx_buffer *rx_buffer_info,
> -                                unsigned int len,
> -                                struct net_device *netdev,
> -                                struct e1000_adapter *adapter)
> +                                __u32 len,
> +                                struct e1000_adapter *adapter,
> +                                struct e1000_tx_ring *tx_ring)
>  {
> -       struct netdev_queue *txq = netdev_get_tx_queue(netdev, 0);
> -       struct e1000_hw *hw = &adapter->hw;
> -       struct e1000_tx_ring *tx_ring;
> -
>         if (len > E1000_MAX_DATA_PER_TXD)
>                 return;
>
> +       if (E1000_DESC_UNUSED(tx_ring) < 2)
> +               return;
> +
> +       e1000_tx_map_rxpage(tx_ring, rx_buffer_info, len);
> +       e1000_tx_queue(adapter, tx_ring, 0/*tx_flags*/, 1);
> +}
> +
> +static void e1000_xdp_xmit_bundle(struct e1000_rx_buffer_bundle *buffer_info,
> +                                 struct net_device *netdev,
> +                                 struct e1000_adapter *adapter)
> +{
> +       struct netdev_queue *txq = netdev_get_tx_queue(netdev, 0);
> +       struct e1000_tx_ring *tx_ring = adapter->tx_ring;
> +       struct e1000_hw *hw = &adapter->hw;
> +       int i = 0;
> +
>         /* e1000 only support a single txq at the moment so the queue is being
>          * shared with stack. To support this requires locking to ensure the
>          * stack and XDP are not running at the same time. Devices with
>          * multiple queues should allocate a separate queue space.
> +        *
> +        * To amortize the locking cost e1000 bundles the xmits and sends as
> +        * many as possible until either running out of descriptors or failing.
>          */
>         HARD_TX_LOCK(netdev, txq, smp_processor_id());
>
> -       tx_ring = adapter->tx_ring;
> -
> -       if (E1000_DESC_UNUSED(tx_ring) < 2) {
> -               HARD_TX_UNLOCK(netdev, txq);
> -               return;
> +       for (; i < E1000_XDP_XMIT_BUNDLE_MAX && buffer_info[i].buffer; i++) {
> +               e1000_xmit_raw_frame(buffer_info[i].buffer,
> +                                    buffer_info[i].length,
> +                                    adapter, tx_ring);
> +               buffer_info[i].buffer->rxbuf.page = NULL;
> +               buffer_info[i].buffer = NULL;
> +               buffer_info[i].length = 0;
> +               i++;
>         }
>
> -       e1000_tx_map_rxpage(tx_ring, rx_buffer_info, len);
> -       e1000_tx_queue(adapter, tx_ring, 0/*tx_flags*/, 1);
> +       /* kick hardware to send bundle and return control back to the stack */
> +       writel(tx_ring->next_to_use, hw->hw_addr + tx_ring->tdt);
> +       mmiowb();
>
>         writel(tx_ring->next_to_use, hw->hw_addr + tx_ring->tdt);
>         mmiowb();
> @@ -4281,9 +4312,10 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
>         struct bpf_prog *prog;
>         u32 length;
>         unsigned int i;
> -       int cleaned_count = 0;
> +       int cleaned_count = 0, xdp_xmit = 0;
>         bool cleaned = false;
>         unsigned int total_rx_bytes = 0, total_rx_packets = 0;
> +       struct e1000_rx_buffer_bundle *xdp_bundle = rx_ring->xdp_buffer;
>
>         rcu_read_lock(); /* rcu lock needed here to protect xdp programs */
>         prog = READ_ONCE(adapter->prog);
> @@ -4338,13 +4370,13 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
>                         case XDP_PASS:
>                                 break;
>                         case XDP_TX:
> +                               xdp_bundle[xdp_xmit].buffer = buffer_info;
> +                               xdp_bundle[xdp_xmit].length = length;
>                                 dma_sync_single_for_device(&pdev->dev,
>                                                            dma,
>                                                            length,
>                                                            DMA_TO_DEVICE);
> -                               e1000_xmit_raw_frame(buffer_info, length,
> -                                                    netdev, adapter);
> -                               buffer_info->rxbuf.page = NULL;
> +                               xdp_xmit++;
>                         case XDP_DROP:
>                         default:
>                                 /* re-use mapped page. keep buffer_info->dma
> @@ -4486,8 +4518,14 @@ next_desc:
>
>                 /* return some buffers to hardware, one at a time is too slow */
>                 if (unlikely(cleaned_count >= E1000_RX_BUFFER_WRITE)) {
> +                       if (xdp_xmit)
> +                               e1000_xdp_xmit_bundle(xdp_bundle,
> +                                                     netdev,
> +                                                     adapter);
> +
>                         adapter->alloc_rx_buf(adapter, rx_ring, cleaned_count);
>                         cleaned_count = 0;
> +                       xdp_xmit = 0;
>                 }
>
>                 /* use prefetched values */
> @@ -4498,8 +4536,11 @@ next_desc:
>         rx_ring->next_to_clean = i;
>
>         cleaned_count = E1000_DESC_UNUSED(rx_ring);
> -       if (cleaned_count)
> +       if (cleaned_count) {
> +               if (xdp_xmit)
> +                       e1000_xdp_xmit_bundle(xdp_bundle, netdev, adapter);
>                 adapter->alloc_rx_buf(adapter, rx_ring, cleaned_count);
> +       }
>
>         adapter->total_rx_packets += total_rx_packets;
>         adapter->total_rx_bytes += total_rx_bytes;
>
