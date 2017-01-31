From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 09/10] bnxt_en: Add basic XDP support.
Date: Mon, 30 Jan 2017 21:04:14 -0800
Message-ID: <20170130210345.5a00e190@cakuba>
References: <1485827375-20421-1-git-send-email-michael.chan@broadcom.com>
        <1485827375-20421-10-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.9]:15482 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750970AbdAaFEh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Jan 2017 00:04:37 -0500
In-Reply-To: <1485827375-20421-10-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Jan 2017 20:49:34 -0500, Michael Chan wrote:
> +#ifdef CONFIG_BNXT_XDP
> +/* returns the following:
> + * true    - packet consumed by XDP and new buffer is allocated.
> + * false   - packet should be passed to the stack.
> + */
> +bool bnxt_rx_xdp(struct bnxt_rx_ring_info *rxr, u16 cons, void *data,
> +		 u8 *data_ptr, unsigned int len, dma_addr_t dma_addr,
> +		 u8 *event)
> +{
> +	struct bpf_prog *xdp_prog = READ_ONCE(rxr->xdp_prog);
> +	struct xdp_buff xdp;
> +	u32 act;
> +
> +	if (!xdp_prog)
> +		return false;
> +
> +	xdp.data = data_ptr;
> +	xdp.data_end = xdp.data + len;
> +	rcu_read_lock();
> +	act = bpf_prog_run_xdp(xdp_prog, &xdp);
> +	rcu_read_unlock();
> +
> +	switch (act) {
> +	case XDP_PASS:
> +		return false;
> +
> +	default:
> +		bpf_warn_invalid_xdp_action(act);
> +		/* Fall thru */
> +	case XDP_DROP:
> +	case XDP_ABORTED:
> +		bnxt_reuse_rx_data(rxr, cons, data);
> +		break;
> +	}
> +	return true;
> +}

It would be cool if you could populate the appropriate paths with
tracepoints Daniel added in a67edbf4fb6d ("bpf: add initial bpf
tracepoints").

> +	if (netif_running(dev))
> +		bnxt_close_nic(bp, true, false);
> +
> +	old = xchg(&bp->xdp_prog, prog);
> +	if (old)
> +		bpf_prog_put(old);
> +
> +	if (prog) {
> +		bnxt_set_rx_skb_mode(bp, true);
> +	} else {
> +		bool sh = (bp->flags & BNXT_FLAG_SHARED_RINGS) ? true : false;
> +		int rx, tx;
> +
> +		bnxt_set_rx_skb_mode(bp, false);
> +		bnxt_get_max_rings(bp, &rx, &tx, sh);
> +		if (rx > 1) {
> +			bp->flags &= ~BNXT_FLAG_NO_AGG_RINGS;
> +			bp->dev->hw_features |= NETIF_F_LRO;
> +		}
> +	}
> +	bp->tx_nr_rings_xdp = tx_xdp;
> +	bp->tx_nr_rings = bp->tx_nr_rings_per_tc * tc + tx_xdp;
> +	bp->cp_nr_rings = max_t(int, bp->tx_nr_rings, bp->rx_nr_rings);
> +	bp->num_stat_ctxs = bp->cp_nr_rings;
> +	bnxt_set_tpa_flags(bp);
> +	bnxt_set_ring_params(bp);
> +
> +	if (netif_running(dev))
> +		return bnxt_open_nic(bp, true, false);

Mm..  I thought doing open/close like this and risking you won't be
able to come back up was frowned upon [1].  I must be misunderstanding
things...

[1] https://www.spinics.net/lists/netdev/msg365229.html

> +int bnxt_xdp(struct net_device *dev, struct netdev_xdp *xdp)
> +{
> +	struct bnxt *bp = netdev_priv(dev);
> +	int rc;
> +
> +	switch (xdp->command) {
> +	case XDP_SETUP_PROG:
> +		rc = bnxt_xdp_set(bp, xdp->prog);
> +		break;
> +	case XDP_QUERY_PROG:
> +		xdp->prog_attached = !!bp->xdp_prog;
> +		rc = 0;
> +		break;
> +	default:
> +		rc = -EINVAL;
> +		break;
> +	}
> +	return rc;
> +}

Nit: why not simply return?
