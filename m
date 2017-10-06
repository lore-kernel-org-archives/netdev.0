From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next V4 PATCH 2/5] bpf: XDP_REDIRECT enable use of cpumap
Date: Fri, 6 Oct 2017 13:17:48 +0200
Message-ID: <20171006131748.75185f65@redhat.com>
References: <150711858281.9499.7767364427831352921.stgit@firesoul>
        <150711863012.9499.383645968070658124.stgit@firesoul>
        <59D60505.2040004@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>, pavel.odintsov@gmail.com,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>, brouer@redhat.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60638 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751917AbdJFLR7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Oct 2017 07:17:59 -0400
In-Reply-To: <59D60505.2040004@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 05 Oct 2017 12:10:13 +0200 Daniel Borkmann <daniel@iogearbox.net> wrote:

> On 10/04/2017 02:03 PM, Jesper Dangaard Brouer wrote:
> > This patch connects cpumap to the xdp_do_redirect_map infrastructure.
> >
> > Still no SKB allocation are done yet.  The XDP frames are transferred
> > to the other CPU, but they are simply refcnt decremented on the remote
> > CPU.  This served as a good benchmark for measuring the overhead of
> > remote refcnt decrement.  If driver page recycle cache is not
> > efficient then this, exposes a bottleneck in the page allocator.
> >
> > A shout-out to MST's ptr_ring, which is the secret behind is being so
> > efficient to transfer memory pointers between CPUs, without constantly
> > bouncing cache-lines between CPUs.
> >
> > V3: Handle !CONFIG_BPF_SYSCALL pointed out by kbuild test robot.
> >
> > V4: Make Generic-XDP aware of cpumap type, but don't allow redirect yet,
> >   as implementation require a separate upstream discussion.
> >
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>  
> [...]
> > diff --git a/kernel/bpf/cpumap.c b/kernel/bpf/cpumap.c
> > index ae8e29352261..4926a9971f90 100644
> > --- a/kernel/bpf/cpumap.c
> > +++ b/kernel/bpf/cpumap.c
> > @@ -493,7 +493,8 @@ static int bq_enqueue(struct bpf_cpu_map_entry *rcpu, struct xdp_pkt *xdp_pkt)
> >   	return 0;
> >   }
> >
> > -int cpu_map_enqueue(struct bpf_cpu_map_entry *rcpu, struct xdp_buff *xdp)
> > +int cpu_map_enqueue(struct bpf_cpu_map_entry *rcpu, struct xdp_buff *xdp,
> > +		    struct net_device *dev_rx)
> >   {
> >   	struct xdp_pkt *xdp_pkt;
> >   	int headroom;
> > @@ -505,7 +506,7 @@ int cpu_map_enqueue(struct bpf_cpu_map_entry *rcpu, struct xdp_buff *xdp)
> >   	xdp_pkt = xdp->data_hard_start;
> >   	xdp_pkt->data = xdp->data;
> >   	xdp_pkt->len  = xdp->data_end - xdp->data;
> > -	xdp_pkt->headroom = headroom;
> > +	xdp_pkt->headroom = headroom - sizeof(*xdp_pkt);  
> 
> (Just a note, bit confusing that first two patches add and extend
>   this, and only in the third you add the xdp->data_meta handling,
>   makes it harder to review at least.)

Sorry.  This is a left-overs from rebasing and measuring the cost of
transferring only the pointer to the page, and remote put_page().
And your xdp->data_meta, happen basically while my patches was in-flight.

I'll move this one-line back to patch 2, to spreading over too many
patches.

> [...]
> > diff --git a/net/core/filter.c b/net/core/filter.c
> > index 9b6e7e84aafd..dbf2ae071108 100644
> > --- a/net/core/filter.c
> > +++ b/net/core/filter.c
> > @@ -2521,10 +2521,36 @@ static int __bpf_tx_xdp(struct net_device *dev,
> >   	err = dev->netdev_ops->ndo_xdp_xmit(dev, xdp);
> >   	if (err)
> >   		return err;
> > -	if (map)
> > +	dev->netdev_ops->ndo_xdp_flush(dev);
> > +	return 0;
> > +}
> > +
> > +static int __bpf_tx_xdp_map(struct net_device *dev_rx, void *fwd,
> > +			    struct bpf_map *map,
> > +			    struct xdp_buff *xdp,
> > +			    u32 index)
> > +{
> > +	int err;
> > +
> > +	if (map->map_type == BPF_MAP_TYPE_DEVMAP) {
> > +		struct net_device *dev = fwd;
> > +
> > +		if (!dev->netdev_ops->ndo_xdp_xmit)
> > +			return -EOPNOTSUPP;
> > +
> > +		err = dev->netdev_ops->ndo_xdp_xmit(dev, xdp);
> > +		if (err)
> > +			return err;
> >   		__dev_map_insert_ctx(map, index);
> > -	else
> > -		dev->netdev_ops->ndo_xdp_flush(dev);
> > +
> > +	} else if (map->map_type == BPF_MAP_TYPE_CPUMAP) {
> > +		struct bpf_cpu_map_entry *rcpu = fwd;
> > +
> > +		err = cpu_map_enqueue(rcpu, xdp, dev_rx);
> > +		if (err)
> > +			return err;
> > +		__cpu_map_insert_ctx(map, index);
> > +	}
> >   	return 0;
> >   }
> >
> > @@ -2534,11 +2560,33 @@ void xdp_do_flush_map(void)
> >   	struct bpf_map *map = ri->map_to_flush;
> >
> >   	ri->map_to_flush = NULL;
> > -	if (map)
> > -		__dev_map_flush(map);
> > +	if (map) {
> > +		switch (map->map_type) {
> > +		case BPF_MAP_TYPE_DEVMAP:
> > +			__dev_map_flush(map);
> > +			break;
> > +		case BPF_MAP_TYPE_CPUMAP:
> > +			__cpu_map_flush(map);
> > +			break;
> > +		default:
> > +			break;
> > +		}
> > +	}
> >   }
> >   EXPORT_SYMBOL_GPL(xdp_do_flush_map);
> >
> > +static void *__xdp_map_lookup_elem(struct bpf_map *map, u32 index)
> > +{
> > +	switch (map->map_type) {
> > +	case BPF_MAP_TYPE_DEVMAP:
> > +		return __dev_map_lookup_elem(map, index);
> > +	case BPF_MAP_TYPE_CPUMAP:
> > +		return __cpu_map_lookup_elem(map, index);
> > +	default:
> > +		return NULL;
> > +	}  
> 
> Should we just have a callback and instead of the above use
> map->ptr_lookup_elem() (or however we name it) ... lot of it
> is pretty much the same logic as with devmap.

We could extend struct bpf_map *map with such a callback, I was just
afraid that this would be too invasive.

Performance wise, I don't thinks will hurt too much.
http://www.cipht.net/2017/10/03/are-jump-tables-always-fastest.html


> > +}
> > +
> >   static inline bool xdp_map_invalid(const struct bpf_prog *xdp_prog,
> >   				   unsigned long aux)
> >   {
> > @@ -2551,8 +2599,8 @@ static int xdp_do_redirect_map(struct net_device *dev, struct xdp_buff *xdp,
> >   	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
> >   	unsigned long map_owner = ri->map_owner;
> >   	struct bpf_map *map = ri->map;
> > -	struct net_device *fwd = NULL;
> >   	u32 index = ri->ifindex;
> > +	void *fwd = NULL;
> >   	int err;
> >
> >   	ri->ifindex = 0;  
> 



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
