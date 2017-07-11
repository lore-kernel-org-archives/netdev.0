From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 00/12] Implement XDP bpf_redirect vairants
Date: Tue, 11 Jul 2017 20:01:36 +0200
Message-ID: <20170711200136.46ab5687@redhat.com>
References: <20170707172115.9984.53461.stgit@john-Precision-Tower-5810>
        <595FC974.9030807@gmail.com>
        <20170708.104618.2149883426031901592.davem@davemloft.net>
        <20170708210617.249059b9@redhat.com>
        <20170711173658.6188b0a2@redhat.com>
        <59650F6D.4070202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        andy@greyhouse.net, daniel@iogearbox.net, ast@fb.com,
        alexander.duyck@gmail.com, bjorn.topel@intel.com,
        jakub.kicinski@netronome.com, ecree@solarflare.com,
        sgoutham@cavium.com, Yuval.Mintz@cavium.com, saeedm@mellanox.com,
        brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39766 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754615AbdGKSBp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Jul 2017 14:01:45 -0400
In-Reply-To: <59650F6D.4070202@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Jul 2017 10:48:29 -0700
John Fastabend <john.fastabend@gmail.com> wrote:

> On 07/11/2017 08:36 AM, Jesper Dangaard Brouer wrote:
> > On Sat, 8 Jul 2017 21:06:17 +0200
> > Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> >   
> >> My plan is to test this latest patchset again, Monday and Tuesday.
> >> I'll try to assess stability and provide some performance numbers.  
> > 
> > Performance numbers:
> > 
> >  14378479 pkt/s = XDP_DROP without touching memory
> >   9222401 pkt/s = xdp1: XDP_DROP with reading packet data
> >   6344472 pkt/s = xdp2: XDP_TX   with swap mac (writes into pkt)
> >   4595574 pkt/s = xdp_redirect:     XDP_REDIRECT with swap mac (simulate XDP_TX)
> >   5066243 pkt/s = xdp_redirect_map: XDP_REDIRECT with swap mac + devmap
> > 
> > The performance drop between xdp2 and xdp_redirect, was expected due
> > to the HW-tailptr flush per packet, which is costly.
> > 
> >  (1/6344472-1/4595574)*10^9 = -59.98 ns
> > 
> > The performance drop between xdp2 and xdp_redirect_map, is higher than
> > I expected, which is not good!  The avoidance of the tailptr flush per
> > packet was expected to give a higher boost.  The cost increased with
> > 40 ns, which is too high compared to the code added (on a 4GHz machine
> > approx 160 cycles).
> > 
> >  (1/6344472-1/5066243)*10^9 = -39.77 ns
> > 
> > This system doesn't have DDIO, thus we are stalling on cache-misses,
> > but I was actually expecting that the added code could "hide" behind
> > these cache-misses.
> > 
> > I'm somewhat surprised to see this large a performance drop.
> >   
> 
> Yep, although there is room for optimizations in the code path for sure. And
> 5mpps is not horrible my preference is to get this series in plus any
> small optimization we come up with while the merge window is closed. Then
> follow up patches can do optimizations.

IMHO 5Mpps is a very bad number for XDP.

> One easy optimization is to get rid of the atomic bitops. They are not needed
> here we have a per cpu unsigned long. Another easy one would be to move
> some of the checks out of the hotpath. For example checking for ndo_xdp_xmit
> and flush ops on the net device in the hotpath really should be done in the
> slow path.

I'm already running with a similar patch as below, but it
(surprisingly) only gave my 3 ns improvement.  I also tried a
prefetchw() on xdp.data that gave me 10 ns (which is quite good).

I'm booting up another system with a CPU E5-1650 v4 @ 3.60GHz, which
have DDIO ... I have high hopes for this, as the major bottleneck on
this CPU i7-4790K CPU @ 4.00GHz is clearly cache-misses.

Something is definitely wrong on this CPU, as perf stats shows, a very
bad utilization of the CPU pipeline with 0.89 insn per cycle.


> diff --git a/kernel/bpf/devmap.c b/kernel/bpf/devmap.c
> index 1191060..899364d 100644
> --- a/kernel/bpf/devmap.c
> +++ b/kernel/bpf/devmap.c
> @@ -213,7 +213,7 @@ void __dev_map_insert_ctx(struct bpf_map *map, u32 key)
>         struct bpf_dtab *dtab = container_of(map, struct bpf_dtab, map);
>         unsigned long *bitmap = this_cpu_ptr(dtab->flush_needed);
>  
> -       set_bit(key, bitmap);
> +       __set_bit(key, bitmap);
>  }
>  
>  struct net_device  *__dev_map_lookup_elem(struct bpf_map *map, u32 key)
> @@ -253,7 +253,7 @@ void __dev_map_flush(struct bpf_map *map)
>  
>                 netdev = dev->dev;
>  
> -               clear_bit(bit, bitmap);
> +               __clear_bit(bit, bitmap);
>                 if (unlikely(!netdev || !netdev->netdev_ops->ndo_xdp_flush))
>                         continue;
>  
> @@ -287,7 +287,7 @@ static void dev_map_flush_old(struct bpf_dtab_netdev *old_dev)
>  
>                 for_each_online_cpu(cpu) {
>                         bitmap = per_cpu_ptr(old_dev->dtab->flush_needed, cpu);
> -                       clear_bit(old_dev->key, bitmap);
> +                       __clear_bit(old_dev->key, bitmap);
>  
>                         fl->netdev_ops->ndo_xdp_flush(old_dev->dev);
>                 }
> 



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
