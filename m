From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] xdp: implement xdp_redirect_map for generic
 XDP
Date: Wed, 06 Sep 2017 18:24:07 +0200
Message-ID: <59B02127.5020904@iogearbox.net>
References: <150471158528.3727.12324542627400287360.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59644 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754774AbdIFQYJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 12:24:09 -0400
In-Reply-To: <150471158528.3727.12324542627400287360.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/06/2017 05:26 PM, Jesper Dangaard Brouer wrote:
> Using bpf_redirect_map is allowed for generic XDP programs, but the
> appropriate map lookup was never performed in xdp_do_generic_redirect().
>
> Instead the map-index is directly used as the ifindex.  For the

Good point, but ...

[...]
>   net/core/filter.c |   29 +++++++++++++++++++++++++++++
>   1 file changed, 29 insertions(+)
>
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 5912c738a7b2..6a4745bf2c9f 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -2562,6 +2562,32 @@ int xdp_do_redirect(struct net_device *dev, struct xdp_buff *xdp,
>   }
>   EXPORT_SYMBOL_GPL(xdp_do_redirect);
>
> +static int xdp_do_generic_redirect_map(struct net_device *dev,
> +				       struct sk_buff *skb,
> +				       struct bpf_prog *xdp_prog)
> +{
> +	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
> +	struct bpf_map *map = ri->map;
> +	u32 index = ri->ifindex;
> +	struct net_device *fwd;
> +	int err;
> +
> +	ri->ifindex = 0;
> +	ri->map = NULL;
> +
> +	fwd = __dev_map_lookup_elem(map, index);
> +	if (!fwd) {
> +		err = -EINVAL;
> +		goto err;
> +	}
> +	skb->dev = fwd;
> +	_trace_xdp_redirect_map(dev, xdp_prog, fwd, map, index);
> +	return 0;
> +err:
> +	_trace_xdp_redirect_map_err(dev, xdp_prog, fwd, map, index, err);
> +	return err;
> +}
> +
>   int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb,
>   			    struct bpf_prog *xdp_prog)
>   {
> @@ -2571,6 +2597,9 @@ int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb,
>   	unsigned int len;
>   	int err = 0;
>
> +	if (ri->map)
> +		return xdp_do_generic_redirect_map(dev, skb, xdp_prog);

This is not quite correct. Really, the only thing you want
to do here is more or less ...

int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb,
			    struct bpf_prog *xdp_prog)
{
	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
	struct bpf_map *map = ri->map;
	u32 index = ri->ifindex;
	struct net_device *fwd;
	unsigned int len;
	int err = 0;

	ri->ifindex = 0;
	ri->map = NULL;

	if (map)
		fwd = __dev_map_lookup_elem(map, index);
	else
		fwd = dev_get_by_index_rcu(dev_net(dev), index);
	if (unlikely(!fwd)) {
		err = -EINVAL;
		goto err;
	}
[...]

... such that you have a common path to also do the IFF_UP
and MTU checks that are done here, but otherwise omitted in
your patch.

Otherwise it looks good, but note that it also doesn't really
resolve the issue you mention wrt stale map pointers by the
way. This would need a different way to clear out the pointers
from redirect_info, I'm thinking when we have devmap dismantle
time after RCU grace period we should check whether there are
still stale pointers from this map around and clear them under
disabled preemption, but need to brainstorm a bit more on that
first.

>   	fwd = dev_get_by_index_rcu(dev_net(dev), index);
>   	ri->ifindex = 0;
>   	if (unlikely(!fwd)) {
>
