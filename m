From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next v2 11/12] bnxt_en: Add basic XDP support.
Date: Thu, 2 Feb 2017 15:08:27 -0800
Message-ID: <20170202150813.4d94b306@cakuba.netronome.com>
References: <1486054540-366-1-git-send-email-michael.chan@broadcom.com>
        <1486054540-366-12-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Martin KaFai Lau <kafai@fb.com>
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.10]:59685 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751834AbdBBXIu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 2 Feb 2017 18:08:50 -0500
In-Reply-To: <1486054540-366-12-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  2 Feb 2017 11:55:39 -0500, Michael Chan wrote:
> +/* returns the following:
> + * true    - packet consumed by XDP and new buffer is allocated.
> + * false   - packet should be passed to the stack.
> + */
> +bool bnxt_rx_xdp(struct bnxt *bp, struct bnxt_rx_ring_info *rxr, u16 cons,
> +		 struct page *page, unsigned int len, u8 *event)
> +{
> +	struct bpf_prog *xdp_prog = READ_ONCE(rxr->xdp_prog);
> +	struct bnxt_sw_rx_bd *cons_rx_buf;
> +	struct pci_dev *pdev = bp->pdev;
> +	u32 offset = bp->rx_offset;
> +	struct xdp_buff xdp;
> +	dma_addr_t mapping;
> +	void *orig_data;
> +	u32 act;
> +
> +	if (!xdp_prog)
> +		return false;
> +
> +	cons_rx_buf = &rxr->rx_buf_ring[cons];
> +
> +	xdp.data_hard_start = cons_rx_buf->data_ptr - bp->rx_offset;
> +	xdp.data = cons_rx_buf->data_ptr;
> +	xdp.data_end = xdp.data + len;
> +	orig_data = xdp.data;
> +	mapping = cons_rx_buf->mapping - bp->rx_dma_offset;
> +
> +	dma_sync_single_for_cpu(&pdev->dev, mapping + offset, len, bp->rx_dir);
> +
> +	rcu_read_lock();
> +	act = bpf_prog_run_xdp(xdp_prog, &xdp);
> +	rcu_read_unlock();
> +
> +	if (orig_data != xdp.data) {
> +		offset = xdp.data - xdp.data_hard_start;
> +		len = xdp.data_end - xdp.data;

If BPF changed the start of the packet and returned XDP_PASS you should
make sure stack will see the modified packet.  I.e. with adjusted
offset and len.

(CC: Alexei, Martin in case I'm wrong)

> +	}
> +	switch (act) {
> +	case XDP_PASS:
> +		return false;
> +
> +	default:
> +		bpf_warn_invalid_xdp_action(act);
> +		/* Fall thru */
> +	case XDP_ABORTED:
> +		trace_xdp_exception(bp->dev, xdp_prog, act);
> +		/* Fall thru */
> +	case XDP_DROP:
> +		bnxt_reuse_rx_data(rxr, cons, page);
> +		break;
> +	}
> +	return true;
> +}
