From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 00/12] Implement XDP bpf_redirect vairants
Date: Thu, 13 Jul 2017 10:00:15 -0700
Message-ID: <5967A71F.9010409@gmail.com>
References: <20170707172115.9984.53461.stgit@john-Precision-Tower-5810> <595FC974.9030807@gmail.com>    <20170708.104618.2149883426031901592.davem@davemloft.net>       <20170708210617.249059b9@redhat.com>    <20170710203050.54b2d8eb@redhat.com>    <596422E5.6010100@gmail.com>    <20170711162344.6fd8fb39@redhat.com>    <5965186E.8060409@gmail.com>    <20170713131430.7032b5fa@redhat.com> <20170713181644.2d421e4d@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        andy@greyhouse.net, daniel@iogearbox.net, ast@fb.com,
        alexander.duyck@gmail.com, bjorn.topel@intel.com,
        jakub.kicinski@netronome.com, ecree@solarflare.com,
        sgoutham@cavium.com, Yuval.Mintz@cavium.com, saeedm@mellanox.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34482 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751198AbdGMRAd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2017 13:00:33 -0400
Received: by mail-pg0-f65.google.com with SMTP id j186so7584683pge.1
        for <netdev@vger.kernel.org>; Thu, 13 Jul 2017 10:00:33 -0700 (PDT)
In-Reply-To: <20170713181644.2d421e4d@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/13/2017 09:16 AM, Jesper Dangaard Brouer wrote:
> On Thu, 13 Jul 2017 13:14:30 +0200
> Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> 
>> I'm still getting crashes (but much harder to provoke), but I figured
>> out why.  We sort of missed one case, where map_to_flush gets set, when
>> the ndo_xdp_xmit() call starts to fail, and the ixgbe driver then
>> forgets to call xdp_do_flush_map, if all packets in that NAPI cycle
>> failed.  We could blame the driver, but yhe clean solution is making
>> sure, that we don't set map_to_flush when the __bpf_tx_xdp() call
>> fails. It should also handle the other case I fixed .... I'll cleanup
>> my PoC-fix patch, test it and provide it here.
> 
> I changed flow in the function to be:


Great, I'll merge this, the other couple fixes, and the bitops optimization and
hopefully then we are set. I'll post a v2 and we can do some final checks.

Thanks!
John

> 
> int xdp_do_redirect_map(struct net_device *dev, struct xdp_buff *xdp,
> 			struct bpf_prog *xdp_prog)
> {
> 	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
> 	struct bpf_map *map = ri->map;
> 	u32 index = ri->ifindex;
> 	struct net_device *fwd;
> 	int err = -EINVAL;
> 
> 	ri->ifindex = 0;
> 	ri->map = NULL;
> 
> 	fwd = __dev_map_lookup_elem(map, index);
> 	if (!fwd)
> 		goto out;
> 
> 	if (ri->map_to_flush && (ri->map_to_flush != map))
> 		xdp_do_flush_map();
> 
> 	err = __bpf_tx_xdp(fwd, map, xdp, index);
> 	if (likely(!err))
> 		ri->map_to_flush = map;
> 
> out:
> 	trace_xdp_redirect(dev, fwd, xdp_prog, XDP_REDIRECT);
> 	return err;
> }
> 
> 
> The diff is:
> 
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 4ca895d6ed51..c50a7ec2cdab 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -2483,26 +2483,25 @@ int xdp_do_redirect_map(struct net_device *dev, struct xdp_buff *xdp,
>         struct bpf_map *map = ri->map;
>         u32 index = ri->ifindex;
>         struct net_device *fwd;
> +       int err = -EINVAL;
> +
> +       ri->ifindex = 0;
> +       ri->map = NULL;
>  
>         fwd = __dev_map_lookup_elem(map, index);
>         if (!fwd)
>                 goto out;
>  
> -       ri->ifindex = 0;
> -
>         if (ri->map_to_flush && (ri->map_to_flush != map))
>                 xdp_do_flush_map();
>  
> -       ri->map_to_flush = map;
> -       ri->map = NULL;
> +       err = __bpf_tx_xdp(fwd, map, xdp, index);
> +       if (likely(!err))
> +               ri->map_to_flush = map;
>  
> -       trace_xdp_redirect(dev, fwd, xdp_prog, XDP_REDIRECT);
> -
> -       return __bpf_tx_xdp(fwd, map, xdp, index);
>  out:
> -       ri->ifindex = 0;
> -       ri->map = NULL;
> -       return -EINVAL;
> +       trace_xdp_redirect(dev, fwd, xdp_prog, XDP_REDIRECT);
> +       return err;
>  }
>  
>  int xdp_do_redirect(struct net_device *dev, struct xdp_buff *xdp,
> 
