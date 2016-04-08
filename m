From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [RFC PATCH v2 4/5] mlx4: add support for fast rx drop bpf program
Date: Fri, 8 Apr 2016 10:04:25 -0700
Message-ID: <20160408170424.GD28353@gmail.com>
References: <1460090930-11219-1-git-send-email-bblanco@plumgrid.com>
 <1460090930-11219-4-git-send-email-bblanco@plumgrid.com>
 <20160408134158.0f153ff9@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, tom@herbertland.com,
	alexei.starovoitov@gmail.com, ogerlitz@mellanox.com,
	daniel@iogearbox.net, eric.dumazet@gmail.com, ecree@solarflare.com,
	john.fastabend@gmail.com, tgraf@suug.ch, johannes@sipsolutions.net,
	eranlinuxmellanox@gmail.com, lorenzo@google.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33837 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754046AbcDHRE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 13:04:29 -0400
Received: by mail-pf0-f170.google.com with SMTP id c20so79326647pfc.1
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 10:04:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160408134158.0f153ff9@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 08, 2016 at 01:41:58PM +0200, Jesper Dangaard Brouer wrote:
> 
> On Thu,  7 Apr 2016 21:48:49 -0700 Brenden Blanco <bblanco@plumgrid.com> wrote:
> 
> > +int mlx4_call_bpf(struct bpf_prog *prog, void *data, unsigned int length)
> > +{
> > +	struct sk_buff *skb = this_cpu_ptr(&percpu_bpf_phys_dev_md);
> > +	int ret;
> > +
> > +	build_bpf_phys_dev_md(skb, data, length);
> > +
> > +	rcu_read_lock();
> > +	ret = BPF_PROG_RUN(prog, (void *)skb);
> > +	rcu_read_unlock();
> > +
> > +	return ret;
> > +}
> [...]
> 
> > diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> > index 86bcfe5..287da02 100644
> > --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> > +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> > @@ -840,6 +843,23 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
> >  		l2_tunnel = (dev->hw_enc_features & NETIF_F_RXCSUM) &&
> >  			(cqe->vlan_my_qpn & cpu_to_be32(MLX4_CQE_L2_TUNNEL));
> >  
> > +		/* A bpf program gets first chance to drop the packet. It may
> > +		 * read bytes but not past the end of the frag.
> > +		 */
> > +		if (prog) {
> > +			struct ethhdr *ethh;
> > +			dma_addr_t dma;
> > +
> > +			dma = be64_to_cpu(rx_desc->data[0].addr);
> > +			dma_sync_single_for_cpu(priv->ddev, dma, sizeof(*ethh),
> > +						DMA_FROM_DEVICE);
> > +			ethh = page_address(frags[0].page) +
> > +							frags[0].page_offset;
> > +			if (mlx4_call_bpf(prog, ethh, frags[0].page_size) ==
> > +							BPF_PHYS_DEV_DROP)
> > +				goto next;
> > +		}
> > +
> 
> Do the program need to know if the packet-page we handover is
> considered 'read-only' at the call site?  Or do we rely on my idea
> requiring the registration to "know" this...
Seems that we're leaning towards the latter at this point. In either
case, we won't allow buggy situations, and let's see which approach
works better when we have RFC code in hand.
> 
> -- 
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer
