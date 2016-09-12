From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v3 2/3] e1000: add initial XDP support
Date: Mon, 12 Sep 2016 15:46:39 -0700
Message-ID: <1473720399.18970.91.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160912220312.5610.77528.stgit@john-Precision-Tower-5810>
         <20160912221351.5610.29043.stgit@john-Precision-Tower-5810>
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
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36482 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751673AbcILWqm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 18:46:42 -0400
Received: by mail-pf0-f193.google.com with SMTP id x24so8669604pfa.3
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 15:46:42 -0700 (PDT)
In-Reply-To: <20160912221351.5610.29043.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-09-12 at 15:13 -0700, John Fastabend wrote:
> From: Alexei Starovoitov <ast@fb.com>

> +static void e1000_xmit_raw_frame(struct e1000_rx_buffer *rx_buffer_info,
> +				 u32 len,
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
> +	if (netif_xmit_frozen_or_stopped(txq))
> +		return;
> +
> +	e1000_tx_map_rxpage(tx_ring, rx_buffer_info, len);
> +	netdev_sent_queue(netdev, len);
> +	e1000_tx_queue(adapter, tx_ring, 0/*tx_flags*/, 1);
> +
> +	writel(tx_ring->next_to_use, hw->hw_addr + tx_ring->tdt);
> +	mmiowb();
> +
> +	HARD_TX_UNLOCK(netdev, txq);
> +}


e1000_tx_map() is full of workarounds.

Have a look at last_tx_tso for example.

               /* Workaround for Controller erratum --
                 * descriptor for non-tso packet in a linear SKB that follows a
                 * tso gets written back prematurely before the data is fully
                 * DMA'd to the controller
                 */
                if (!skb->data_len && tx_ring->last_tx_tso &&
                    !skb_is_gso(skb)) {
                        tx_ring->last_tx_tso = false;
                        size -= 4;
                }

Look, this XDP_TX thing is hard to properly implement and test on
various NIC revisions.

Without proper queue management, high prio packets in qdisc wont be sent
if NIC is under RX -> XDP_TX flood.

Sounds a horrible feature to me.
