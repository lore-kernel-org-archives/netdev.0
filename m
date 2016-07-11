From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH RFC] mlx4: RX prefetch loop
Date: Mon, 11 Jul 2016 16:05:11 -0700
Message-ID: <20160711230509.GA45195@ast-mbp.thefacebook.com>
References: <20160708172024.4a849b7a@redhat.com>
 <20160708160135.27507.77711.stgit@firesoul>
 <20160711130922.636ee4e6@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kafai@fb.com, daniel@iogearbox.net,
	tom@herbertland.com, bblanco@plumgrid.com,
	john.fastabend@gmail.com, gerlitz.or@gmail.com,
	hannes@stressinduktion.org, rana.shahot@gmail.com, tgraf@suug.ch,
	"David S. Miller" <davem@davemloft.net>, as754m@att.com,
	saeedm@mellanox.com, amira@mellanox.com, tzahio@mellanox.com,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34649 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751200AbcGKXFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 19:05:16 -0400
Received: by mail-pf0-f177.google.com with SMTP id h14so40300447pfe.1
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 16:05:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160711130922.636ee4e6@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 11, 2016 at 01:09:22PM +0200, Jesper Dangaard Brouer wrote:
> > -	/* Process all completed CQEs */
> > +	/* Extract and prefetch completed CQEs */
> >  	while (XNOR(cqe->owner_sr_opcode & MLX4_CQE_OWNER_MASK,
> >  		    cq->mcq.cons_index & cq->size)) {
> > +		void *data;
> >  
> >  		frags = ring->rx_info + (index << priv->log_rx_info);
> >  		rx_desc = ring->buf + (index << ring->log_stride);
> > +		prefetch(rx_desc);
> >  
> >  		/*
> >  		 * make sure we read the CQE after we read the ownership bit
> >  		 */
> >  		dma_rmb();
> >  
> > +		cqe_array[cqe_idx++] = cqe;
> > +
> > +		/* Base error handling here, free handled in next loop */
> > +		if (unlikely((cqe->owner_sr_opcode & MLX4_CQE_OPCODE_MASK) ==
> > +			     MLX4_CQE_OPCODE_ERROR))
> > +			goto skip;
> > +
> > +		data = page_address(frags[0].page) + frags[0].page_offset;
> > +		prefetch(data);

that's probably not correct in all cases, since doing prefetch on the address
that is going to be evicted soon may hurt performance.
We need to dma_sync_single_for_cpu() before doing a prefetch or
somehow figure out that dma_sync is a nop, so we can omit it altogether
and do whatever prefetches we like.
Also unconditionally doing batch of 8 may also hurt depending on what
is happening either with the stack, bpf afterwards or even cpu version.
Doing single prefetch of Nth packet is probably ok most of the time,
but asking cpu to prefetch 8 packets at once is unnecessary especially
since single prefetch gives the same performance.
