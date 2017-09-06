From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next] xdp: implement xdp_redirect_map for generic
 XDP
Date: Wed, 6 Sep 2017 20:18:35 +0200
Message-ID: <20170906201835.7bc26f4f@redhat.com>
References: <150471158528.3727.12324542627400287360.stgit@firesoul>
        <59B02127.5020904@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        John Fastabend <john.fastabend@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>, brouer@redhat.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47180 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750836AbdIFSSm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 14:18:42 -0400
In-Reply-To: <59B02127.5020904@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 06 Sep 2017 18:24:07 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> On 09/06/2017 05:26 PM, Jesper Dangaard Brouer wrote:
> > Using bpf_redirect_map is allowed for generic XDP programs, but the
> > appropriate map lookup was never performed in xdp_do_generic_redirect().
> >
> > Instead the map-index is directly used as the ifindex.  For the  
> 
> Good point, but ...
> 
> [...]
> >   net/core/filter.c |   29 +++++++++++++++++++++++++++++
> >   1 file changed, 29 insertions(+)
> >
> > diff --git a/net/core/filter.c b/net/core/filter.c
> > index 5912c738a7b2..6a4745bf2c9f 100644
> > --- a/net/core/filter.c
> > +++ b/net/core/filter.c
> > @@ -2562,6 +2562,32 @@ int xdp_do_redirect(struct net_device *dev, struct xdp_buff *xdp,
> >   }
> >   EXPORT_SYMBOL_GPL(xdp_do_redirect);
> >
> > +static int xdp_do_generic_redirect_map(struct net_device *dev,
> > +				       struct sk_buff *skb,
> > +				       struct bpf_prog *xdp_prog)
> > +{
> > +	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
> > +	struct bpf_map *map = ri->map;
> > +	u32 index = ri->ifindex;
> > +	struct net_device *fwd;
> > +	int err;
> > +
> > +	ri->ifindex = 0;
> > +	ri->map = NULL;
> > +
> > +	fwd = __dev_map_lookup_elem(map, index);
> > +	if (!fwd) {
> > +		err = -EINVAL;
> > +		goto err;
> > +	}
> > +	skb->dev = fwd;
> > +	_trace_xdp_redirect_map(dev, xdp_prog, fwd, map, index);
> > +	return 0;
> > +err:
> > +	_trace_xdp_redirect_map_err(dev, xdp_prog, fwd, map, index, err);
> > +	return err;
> > +}
> > +
> >   int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb,
> >   			    struct bpf_prog *xdp_prog)
> >   {
> > @@ -2571,6 +2597,9 @@ int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb,
> >   	unsigned int len;
> >   	int err = 0;
> >
> > +	if (ri->map)
> > +		return xdp_do_generic_redirect_map(dev, skb, xdp_prog);  
> 
> This is not quite correct. Really, the only thing you want
> to do here is more or less ...
> 
> int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb,
> 			    struct bpf_prog *xdp_prog)
> {
> 	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
> 	struct bpf_map *map = ri->map;
> 	u32 index = ri->ifindex;
> 	struct net_device *fwd;
> 	unsigned int len;
> 	int err = 0;
> 
> 	ri->ifindex = 0;
> 	ri->map = NULL;
> 
> 	if (map)
> 		fwd = __dev_map_lookup_elem(map, index);
> 	else
> 		fwd = dev_get_by_index_rcu(dev_net(dev), index);
> 	if (unlikely(!fwd)) {
> 		err = -EINVAL;
> 		goto err;
> 	}
> [...]
> 
> ... such that you have a common path to also do the IFF_UP
> and MTU checks that are done here, but otherwise omitted in
> your patch.

Ah, yes. My patch miss the IFF_UP and MTU check. (I was too inspired by
xdp_do_redirect_map).


> Otherwise it looks good, but note that it also doesn't really
> resolve the issue you mention wrt stale map pointers by the
> way.  [...]

I actually discovered more cases where we can crash the kernel :-(

E.g. driver not supporting XDP_REDIRECT, are still allowed to load an
XDP bpf_prog that call bpf_redirect_map() and set the ->map pointer,
but it will never call xdp_do_redirect() (which is responsible for
clearing/consuming ->map pointer).

Another case: You can also call bpf_redirect_map() and then NOT return
XDP_REDIRECT (it is obviously strange, but the bpf-helper API allows it).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
