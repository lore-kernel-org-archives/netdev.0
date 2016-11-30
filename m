From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next PATCH v3 6/6] virtio_net: xdp, add slowpath case for
 non contiguous buffers
Date: Wed, 30 Nov 2016 20:49:16 +0200
Message-ID: <20161130204803-mutt-send-email-mst@kernel.org>
References: <20161129200933.26851.41883.stgit@john-Precision-Tower-5810>
 <20161129201133.26851.31803.stgit@john-Precision-Tower-5810>
 <20161130143031.2fc64ab4@jkicinski-Precision-T1700>
 <583F0361.5030804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jakub Kicinski <kubakici@wp.pl>, eric.dumazet@gmail.com,
        daniel@iogearbox.net, shm@cumulusnetworks.com, davem@davemloft.net,
        tgraf@suug.ch, alexei.starovoitov@gmail.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org,
        bblanco@plumgrid.com, brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55954 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752668AbcK3StW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 13:49:22 -0500
Content-Disposition: inline
In-Reply-To: <583F0361.5030804@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016 at 08:50:41AM -0800, John Fastabend wrote:
> On 16-11-30 06:30 AM, Jakub Kicinski wrote:
> > [add MST]
> > 
> 
> Thanks sorry MST. I did a cut'n'paste of an old list of CC's and missed
> you were not on the list.
> 
> [...]
> 
> >> +	memcpy(page_address(page) + page_off, page_address(p) + offset, *len);
> >> +	while (--num_buf) {
> >> +		unsigned int buflen;
> >> +		unsigned long ctx;
> >> +		void *buf;
> >> +		int off;
> >> +
> >> +		ctx = (unsigned long)virtqueue_get_buf(rq->vq, &buflen);
> >> +		if (unlikely(!ctx))
> >> +			goto err_buf;
> >> +
> >> +		buf = mergeable_ctx_to_buf_address(ctx);
> >> +		p = virt_to_head_page(buf);
> >> +		off = buf - page_address(p);
> >> +
> >> +		memcpy(page_address(page) + page_off,
> >> +		       page_address(p) + off, buflen);
> >> +		page_off += buflen;
> > 
> > Could malicious user potentially submit a frame bigger than MTU?
> 
> Well presumably if the MTU is greater than PAGE_SIZE the xdp program
> would not have been loaded. And the malicious user in this case would
> have to be qemu which seems like everything is already lost if qemu
> is trying to attack its VM.
> 
> But this is a good point because it looks like there is nothing in
> virtio or qemu that drops frames with MTU greater than the virtio
> configured setting. Maybe Michael can confirm this or I'll poke at it
> more. I think qemu should drop these frames in general.
> 
> So I think adding a guard here is sensible I'll go ahead and do that.
> Also the MTU guard at set_xdp time needs to account for header length.

I agree. Further, offloads are disabled dynamically and we could
get a packet that was processed with LRO.

> Thanks nice catch.
> 
> > 
> >> +	}
> >> +
> >> +	*len = page_off;
> >> +	return page;
> >> +err_buf:
> >> +	__free_pages(page, 0);
> >> +	return NULL;
> >> +}
> >> +
> >>  static struct sk_buff *receive_mergeable(struct net_device *dev,
> >>  					 struct virtnet_info *vi,
> >>  					 struct receive_queue *rq,
> >> @@ -469,21 +519,37 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
> >>  	rcu_read_lock();
> >>  	xdp_prog = rcu_dereference(rq->xdp_prog);
> >>  	if (xdp_prog) {
> >> +		struct page *xdp_page;
> >>  		u32 act;
> >>  
> >>  		if (num_buf > 1) {
> >>  			bpf_warn_invalid_xdp_buffer();
> >> -			goto err_xdp;
> >> +
> >> +			/* linearize data for XDP */
> >> +			xdp_page = xdp_linearize_page(rq, num_buf,
> >> +						      page, offset, &len);
> >> +			if (!xdp_page)
> >> +				goto err_xdp;
> >> +			offset = len;
> >> +		} else {
> >> +			xdp_page = page;
> >>  		}
> >>  
> >> -		act = do_xdp_prog(vi, xdp_prog, page, offset, len);
> >> +		act = do_xdp_prog(vi, xdp_prog, xdp_page, offset, len);
> >>  		switch (act) {
> >>  		case XDP_PASS:
> >> +			if (unlikely(xdp_page != page))
> >> +				__free_pages(xdp_page, 0);
> >>  			break;
> >>  		case XDP_TX:
> >> +			if (unlikely(xdp_page != page))
> >> +				goto err_xdp;
> >> +			rcu_read_unlock();
> > 
> > Only if there is a reason for v4 - this unlock could go to the previous
> > patch.
> > 
> 
> Sure will do this.
