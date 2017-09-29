From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 3/5] bpf: cpumap xdp_buff to skb conversion and
 allocation
Date: Fri, 29 Sep 2017 15:05:36 +0200
Message-ID: <20170929150536.643019a3@redhat.com>
References: <150660339205.2808.7084136789768233829.stgit@firesoul>
        <150660343811.2808.7680200486950101509.stgit@firesoul>
        <1c37f945-0e2f-1eec-fe88-a740815026d3@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>, brouer@redhat.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55972 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751349AbdI2NFq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 29 Sep 2017 09:05:46 -0400
In-Reply-To: <1c37f945-0e2f-1eec-fe88-a740815026d3@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 Sep 2017 17:49:23 +0800
Jason Wang <jasowang@redhat.com> wrote:

> On 2017年09月28日 20:57, Jesper Dangaard Brouer wrote:
> > +};
> > +
> > +/* Convert xdp_buff to xdp_pkt */
> > +static struct xdp_pkt *convert_to_xdp_pkt(struct xdp_buff *xdp)
> > +{
> > +	struct xdp_pkt *xdp_pkt;
> > +	int headroom;
> > +
> > +	/* Assure headroom is available for storing info */
> > +	headroom = xdp->data - xdp->data_hard_start;
> > +	if (headroom < sizeof(*xdp_pkt))
> > +		return NULL;  
> 
> Hi Jesper:
> 
> Do you consider this as a trick or a long term solution? Is it better to 
> store XDP in a circular buffer? (I'm asking since I meet similar issue 
> when doing xdp_xmit for tun).

(The way you ask the question is slightly ambiguous, but I hope I understand.)

IMHO the best solution to allow queueing of XDP packets is to create a
meta-data structure, with the needed info.  For performance reasons, we
don't want to allocate a new memory area for this.  Thus, we simply use
the available headroom in the page that the packet is stored into.
Notice that DPDK also use the first cache-line of the packet data, for
its packet meta-data structure. (This is not a performance problem.
I've done several PoC benchmarks, before choosing to do this)

For now, this "trick" is local to the cpumap, and thus not exposed as
any API.  Thus we can evolve and change the contents easily.  But I
would in time, like to see this generalized. When/if more places need
to queue XDP packets, this header meta-data format should be
standardized.


Pipe-dreaming: Taking this to the extreme... if I could get away with
it, I would actually like to store the (232 bytes) SKB meta-data header
inside headroom too.  That would eliminate any real SKB memory alloc.


> > +
> > +	/* Store info in top of packet */
> > +	xdp_pkt = xdp->data_hard_start;
> > +
> > +	xdp_pkt->data = xdp->data;
> > +	xdp_pkt->len  = xdp->data_end - xdp->data;
> > +	xdp_pkt->headroom = headroom - sizeof(*xdp_pkt);
> > +  
> 
> Is wmb() needed here?

No. This xdp_pkt is queued into a into a ptr_ring, which have a
spin_lock on enqueue, and any atomic operation works as a full memory
barrirer mb().

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
