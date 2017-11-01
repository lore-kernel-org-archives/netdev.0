From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH] bpf: cpumap micro-optimization in
 cpu_map_enqueue
Date: Wed, 1 Nov 2017 15:18:59 +0100
Message-ID: <20171101151859.189ae769@redhat.com>
References: <150953668583.30172.5069550217700139382.stgit@firesoul>
        <bcee429e-2f51-b75e-62cb-798e023d0ceb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38472 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754705AbdKAOTF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Nov 2017 10:19:05 -0400
In-Reply-To: <bcee429e-2f51-b75e-62cb-798e023d0ceb@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 1 Nov 2017 06:54:46 -0700
John Fastabend <john.fastabend@gmail.com> wrote:

> On 11/01/2017 04:44 AM, Jesper Dangaard Brouer wrote:
> > Discovered that the compiler laid-out asm code in suboptimal way
> > when studying perf report during benchmarking of cpumap. Help
> > the compiler by the marking unlikely code paths.
> > 
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> > ---
> >  kernel/bpf/cpumap.c |    4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/kernel/bpf/cpumap.c b/kernel/bpf/cpumap.c
> > index 86e29cbf7827..ce5b669003b2 100644
> > --- a/kernel/bpf/cpumap.c
> > +++ b/kernel/bpf/cpumap.c
> > @@ -208,7 +208,7 @@ static struct xdp_pkt *convert_to_xdp_pkt(struct xdp_buff *xdp)
> >  	headroom = xdp->data - xdp->data_hard_start;
> >  	metasize = xdp->data - xdp->data_meta;
> >  	metasize = metasize > 0 ? metasize : 0;
> > -	if ((headroom - metasize) < sizeof(*xdp_pkt))
> > +	if (unlikely((headroom - metasize) < sizeof(*xdp_pkt)))
> >  		return NULL;
> >  
> >  	/* Store info in top of packet */
> > @@ -656,7 +656,7 @@ int cpu_map_enqueue(struct bpf_cpu_map_entry *rcpu, struct xdp_buff *xdp,
> >  	struct xdp_pkt *xdp_pkt;
> >  
> >  	xdp_pkt = convert_to_xdp_pkt(xdp);
> > -	if (!xdp_pkt)
> > +	if (unlikely(!xdp_pkt))
> >  		return -EOVERFLOW;
> >  
> >  	/* Info needed when constructing SKB on remote CPU */
> >   
> 
> Seems OK to me, just curious is this noticeable at pps benchmarks?

I calculate this into an approx 2 nanosec improvement based on PPS
benchmarks.  Given my systems accuracy is around 2 nanosec (after much
tuning) then I cannot claim my measurements to be statistically
significant ;-)

> Acked-by: John Fastabend <john.fastabend@gmail.com>

Thanks

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
