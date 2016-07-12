From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH RFC] mlx4: RX prefetch loop
Date: Tue, 12 Jul 2016 14:45:21 +0200
Message-ID: <20160712144521.4244e8ab@redhat.com>
References: <20160708172024.4a849b7a@redhat.com>
	<20160708160135.27507.77711.stgit@firesoul>
	<20160711130922.636ee4e6@redhat.com>
	<20160711230509.GA45195@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kafai@fb.com, daniel@iogearbox.net,
	tom@herbertland.com, bblanco@plumgrid.com,
	john.fastabend@gmail.com, gerlitz.or@gmail.com,
	hannes@stressinduktion.org, rana.shahot@gmail.com, tgraf@suug.ch,
	"David S. Miller" <davem@davemloft.net>, as754m@att.com,
	saeedm@mellanox.com, amira@mellanox.com, tzahio@mellanox.com,
	Eric Dumazet <eric.dumazet@gmail.com>, brouer@redhat.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51688 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933089AbcGLMpb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2016 08:45:31 -0400
In-Reply-To: <20160711230509.GA45195@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 11 Jul 2016 16:05:11 -0700
Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> On Mon, Jul 11, 2016 at 01:09:22PM +0200, Jesper Dangaard Brouer wrote:
> > > -	/* Process all completed CQEs */
> > > +	/* Extract and prefetch completed CQEs */
> > >  	while (XNOR(cqe->owner_sr_opcode & MLX4_CQE_OWNER_MASK,
> > >  		    cq->mcq.cons_index & cq->size)) {
> > > +		void *data;
> > >  
> > >  		frags = ring->rx_info + (index << priv->log_rx_info);
> > >  		rx_desc = ring->buf + (index << ring->log_stride);
> > > +		prefetch(rx_desc);
> > >  
> > >  		/*
> > >  		 * make sure we read the CQE after we read the ownership bit
> > >  		 */
> > >  		dma_rmb();
> > >  
> > > +		cqe_array[cqe_idx++] = cqe;
> > > +
> > > +		/* Base error handling here, free handled in next loop */
> > > +		if (unlikely((cqe->owner_sr_opcode & MLX4_CQE_OPCODE_MASK) ==
> > > +			     MLX4_CQE_OPCODE_ERROR))
> > > +			goto skip;
> > > +
> > > +		data = page_address(frags[0].page) + frags[0].page_offset;
> > > +		prefetch(data);  
> 
> that's probably not correct in all cases, since doing prefetch on the address
> that is going to be evicted soon may hurt performance.
> We need to dma_sync_single_for_cpu() before doing a prefetch or
> somehow figure out that dma_sync is a nop, so we can omit it altogether
> and do whatever prefetches we like.

Sure, DMA can be synced first (actually already played with this).

> Also unconditionally doing batch of 8 may also hurt depending on what
> is happening either with the stack, bpf afterwards or even cpu version.

See this as software DDIO, if the unlikely case that data will get
evicted, it will still exist in L2 or L3 cache (like DDIO). Notice,
only 1024 bytes are getting prefetched here.

> Doing single prefetch of Nth packet is probably ok most of the time,
> but asking cpu to prefetch 8 packets at once is unnecessary especially
> since single prefetch gives the same performance.

No, unconditionally prefetch of the Nth packet, will be wrong most of
the time, for real work loads, as Eric Dumazet already pointed out.

This patch does NOT unconditionally prefetch 8 packets.  Prefetching
_only_ happens when it is known that packets are ready in the RX ring.
We know this prefetch data will be used/touched, within the NAPI cycle.
Even if the processing of the packet flush L1 cache, then it will be in
L2 or L3 (like DDIO).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
