From: William Tu <u9012063@gmail.com>
Subject: Re: [net-next PATCH] e1000: add initial XDP support
Date: Sun, 28 Aug 2016 08:56:53 -0700
Message-ID: <CALDO+SZRutKYtL3O71FZJ_=_gsz+LH0_XWdhgqA49OYSXa-K+g@mail.gmail.com>
References: <20160827071145.25345.84712.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Brenden Blanco <bblanco@plumgrid.com>,
        David Miller <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        john.r.fastabend@intel.com,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        xiyou.wangcong@gmail.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33377 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752371AbcH1P5f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2016 11:57:35 -0400
Received: by mail-it0-f68.google.com with SMTP id d65so4555300ith.0
        for <netdev@vger.kernel.org>; Sun, 28 Aug 2016 08:57:34 -0700 (PDT)
In-Reply-To: <20160827071145.25345.84712.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Reading through the patch, I found some minor typos below.

On Sat, Aug 27, 2016 at 12:11 AM, John Fastabend
<john.fastabend@gmail.com> wrote:
> From: Alexei Starovoitov <ast@fb.com>
>
> This patch adds initial support for XDP on e1000 driver. Note e1000
> driver does not support page recycling in general which could be
> added as a further improvement. However for XDP_DROP and XDP_XMIT

I think you mean XDP_PASS instead of XDP_XMIT?

> the xdp code paths will recycle pages.
>
> This patch includes the rcu_read_lock/rcu_read_unlock pair noted by
> Brenden Blanco in another pending patch.
>
>   net/mlx4_en: protect ring->xdp_prog with rcu_read_lock
>
> CC: William Tu <u9012063@gmail.com>
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  drivers/net/ethernet/intel/e1000/e1000.h      |    1
>  drivers/net/ethernet/intel/e1000/e1000_main.c |  168 ++++++++++++++++++++++++-
>  2 files changed, 165 insertions(+), 4 deletions(-)
>
> +static void e1000_xmit_raw_frame(struct e1000_rx_buffer *rx_buffer_info,
> +                                unsigned int len,
> +                                struct net_device *netdev,
> +                                struct e1000_adapter *adapter)
> +{
> +       struct netdev_queue *txq = netdev_get_tx_queue(netdev, 0);
> +       struct e1000_hw *hw = &adapter->hw;
> +       struct e1000_tx_ring *tx_ring;
> +
> +       if (len > E1000_MAX_DATA_PER_TXD)
> +               return;
> +
> +       /* e1000 only support a single txq at the moment so the queue is being
> +        * shared with stack. To support this requires locking to ensure the
> +        * stack and XPD are not running at the same time. Devices would
> +        * multiple queues should allocate a separate queue space.
> +        */

XPD --> XDP
Devices would --> with?

> +       HARD_TX_LOCK(netdev, txq, smp_processor_id());
> +
> +       tx_ring = adapter->tx_ring;
> +
> +       if (E1000_DESC_UNUSED(tx_ring) < 2)
> +               return;
> +
> +       e1000_tx_map_rxpage(tx_ring, rx_buffer_info, len);
> +
> +       e1000_tx_queue(adapter, tx_ring, 0/*tx_flags*/, 1);
> +
> +       writel(tx_ring->next_to_use, hw->hw_addr + tx_ring->tdt);
> +       mmiowb();
> +
> +       HARD_TX_UNLOCK(netdev, txq);
> +}
> +
>  #define NUM_REGS 38 /* 1 based count */
>  static void e1000_regdump(struct e1000_adapter *adapter)
>  {
> @@ -4142,6 +4240,22 @@ static struct sk_buff *e1000_alloc_rx_skb(struct e1000_adapter *adapter,
>         return skb;
>  }
>
> +static inline int e1000_call_bpf(struct bpf_prog *prog, void *data,
> +                                unsigned int length)
> +{
> +       struct xdp_buff xdp;
> +       int ret;
> +
> +       xdp.data = data;
> +       xdp.data_end = data + length;
> +
> +       rcu_read_lock();
> +       ret = BPF_PROG_RUN(prog, (void *)&xdp);
> +       rcu_read_unlock();
> +
> +       return ret;
> +}
> +
>  /**
>   * e1000_clean_jumbo_rx_irq - Send received data up the network stack; legacy
>   * @adapter: board private structure
> @@ -4160,12 +4274,15 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
>         struct pci_dev *pdev = adapter->pdev;
>         struct e1000_rx_desc *rx_desc, *next_rxd;
>         struct e1000_rx_buffer *buffer_info, *next_buffer;
> +       struct bpf_prog *prog;
>         u32 length;
>         unsigned int i;
>         int cleaned_count = 0;
>         bool cleaned = false;
>         unsigned int total_rx_bytes = 0, total_rx_packets = 0;
>
> +       rcu_read_lock(); /* rcu lock needed here to protect xdp programs */
> +       prog = READ_ONCE(adapter->prog);

If having rcu_read_lock() here, do we still need another in e1000_call_bpf()?


>         i = rx_ring->next_to_clean;
>         rx_desc = E1000_RX_DESC(*rx_ring, i);
>         buffer_info = &rx_ring->buffer_info[i];
> @@ -4188,15 +4305,57 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
>                 prefetch(next_rxd);
>
>                 next_buffer = &rx_ring->buffer_info[i];
> -
>                 cleaned = true;
>                 cleaned_count++;
> +               length = le16_to_cpu(rx_desc->length);
> +
> +               if (prog) {
> +                       struct page *p = buffer_info->rxbuf.page;
> +                       dma_addr_t dma = buffer_info->dma;
> +                       int act;
> +
> +                       if (unlikely(!(status & E1000_RXD_STAT_EOP))) {
> +                               /* attached bpf disallows larger than page
> +                                * packets, so this is hw error or corruption
> +                                */
> +                               pr_info_once("%s buggy !eop\n", netdev->name);
> +                               break;
> +                       }
> +                       if (unlikely(rx_ring->rx_skb_top)) {
> +                               pr_info_once("%s ring resizing bug\n",
> +                                            netdev->name);
> +                               break;
>
