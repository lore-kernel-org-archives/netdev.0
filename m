From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH v2 net-next 10/11] qede: Add basic XDP support
Date: Tue, 29 Nov 2016 17:10:20 +0000
Message-ID: <20161129171020.6b8b552d@jkicinski-Precision-T1700>
References: <1480430830-17671-1-git-send-email-Yuval.Mintz@cavium.com>
        <1480430830-17671-11-git-send-email-Yuval.Mintz@cavium.com>
        <583DA362.7010702@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>, davem@davemloft.net,
        netdev@vger.kernel.org, alexei.starovoitov@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.10]:42343 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751268AbcK2RK0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Nov 2016 12:10:26 -0500
In-Reply-To: <583DA362.7010702@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Nov 2016 16:48:50 +0100, Daniel Borkmann wrote:
> On 11/29/2016 03:47 PM, Yuval Mintz wrote:
> > Add support for the ndo_xdp callback. This patch would support XDP_PASS,
> > XDP_DROP and XDP_ABORTED commands.
> >
> > This also adds a per Rx queue statistic which counts number of packets
> > which didn't reach the stack [due to XDP].
> >
> > Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>  
> [...]
> > @@ -1560,6 +1593,7 @@ static int qede_rx_process_cqe(struct qede_dev *edev,
> >   			       struct qede_fastpath *fp,
> >   			       struct qede_rx_queue *rxq)
> >   {
> > +	struct bpf_prog *xdp_prog = READ_ONCE(rxq->xdp_prog);
> >   	struct eth_fast_path_rx_reg_cqe *fp_cqe;
> >   	u16 len, pad, bd_cons_idx, parse_flag;
> >   	enum eth_rx_cqe_type cqe_type;
> > @@ -1596,6 +1630,11 @@ static int qede_rx_process_cqe(struct qede_dev *edev,
> >   	len = le16_to_cpu(fp_cqe->len_on_first_bd);
> >   	pad = fp_cqe->placement_offset;
> >
> > +	/* Run eBPF program if one is attached */
> > +	if (xdp_prog)
> > +		if (!qede_rx_xdp(edev, fp, rxq, xdp_prog, bd, fp_cqe))
> > +			return 1;
> > +  
> 
> You also need to wrap this under rcu_read_lock() (at least I haven't seen
> it in your patches) for same reasons as stated in 326fe02d1ed6 ("net/mlx4_en:
> protect ring->xdp_prog with rcu_read_lock"), as otherwise xdp_prog could
> disappear underneath you. mlx4 and nfp does it correctly, looks like mlx5
> doesn't.

My understanding was that Yuval is always doing full stop()/start() so
there should be no RX packets in flight while the XDP prog is being
changed.  But thinking about it again, perhaps is worth adding the
optimization to forego the full qede_reload() in qede_xdp_set() if there
is a program already loaded and just do the xchg()+put() (and add RCU
protection on the fast path)?
