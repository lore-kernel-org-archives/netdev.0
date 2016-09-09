From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v2 1/2] e1000: add initial XDP support
Date: Fri, 09 Sep 2016 15:04:14 -0700
Message-ID: <1473458654.18970.69.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160909212915.4001.25504.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: bblanco@plumgrid.com, alexei.starovoitov@gmail.com,
        jeffrey.t.kirsher@intel.com, brouer@redhat.com,
        davem@davemloft.net, xiyou.wangcong@gmail.com,
        intel-wired-lan@lists.osuosl.org, u9012063@gmail.com,
        netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:36832 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754738AbcIIWEQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 18:04:16 -0400
Received: by mail-pa0-f66.google.com with SMTP id ez1so4337920pab.3
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2016 15:04:16 -0700 (PDT)
In-Reply-To: <20160909212915.4001.25504.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-09-09 at 14:29 -0700, John Fastabend wrote:
> From: Alexei Starovoitov <ast@fb.com>
> 


So it looks like e1000_xmit_raw_frame() can return early,
say if there is no available descriptor.

> +static void e1000_xmit_raw_frame(struct e1000_rx_buffer *rx_buffer_info,
> +				 unsigned int len,
> +				 struct net_device *netdev,
> +				 struct e1000_adapter *adapter)
> +{
> +	struct netdev_queue *txq = netdev_get_tx_queue(netdev, 0);
> +	struct e1000_hw *hw = &adapter->hw;
> +	struct e1000_tx_ring *tx_ring;
> +
> +	if (len > E1000_MAX_DATA_PER_TXD)
> +		return;
> +
> +	/* e1000 only support a single txq at the moment so the queue is being
> +	 * shared with stack. To support this requires locking to ensure the
> +	 * stack and XDP are not running at the same time. Devices with
> +	 * multiple queues should allocate a separate queue space.
> +	 */
> +	HARD_TX_LOCK(netdev, txq, smp_processor_id());
> +
> +	tx_ring = adapter->tx_ring;
> +
> +	if (E1000_DESC_UNUSED(tx_ring) < 2) {
> +		HARD_TX_UNLOCK(netdev, txq);
> +		return;
> +	}
> +
> +	e1000_tx_map_rxpage(tx_ring, rx_buffer_info, len);
> +	e1000_tx_queue(adapter, tx_ring, 0/*tx_flags*/, 1);
> +
> +	writel(tx_ring->next_to_use, hw->hw_addr + tx_ring->tdt);
> +	mmiowb();
> +
> +	HARD_TX_UNLOCK(netdev, txq);
> +}
> +
>  #define NUM_REGS 38 /* 1 based count */
>  static void e1000_regdump(struct e1000_adapter *adapter)
>  {
> @@ -4142,6 +4247,19 @@ static struct sk_buff *e1000_alloc_rx_skb(struct e1000_adapter *adapter,
>  	return skb;
>  }
> +			act = e1000_call_bpf(prog, page_address(p), length);
> +			switch (act) {
> +			case XDP_PASS:
> +				break;
> +			case XDP_TX:
> +				dma_sync_single_for_device(&pdev->dev,
> +							   dma,
> +							   length,
> +							   DMA_TO_DEVICE);
> +				e1000_xmit_raw_frame(buffer_info, length,
> +						     netdev, adapter);
> +				buffer_info->rxbuf.page = NULL;


So I am trying to understand how pages are not leaked ?
