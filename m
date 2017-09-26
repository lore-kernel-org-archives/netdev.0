From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 2/6] bpf: add meta pointer for direct access
Date: Tue, 26 Sep 2017 21:58:53 +0200
Message-ID: <59CAB17D.5090204@iogearbox.net>
References: <cover.1506297988.git.daniel@iogearbox.net> <458f9c13ab58abb1a15627906d03c33c42b02a7c.1506297988.git.daniel@iogearbox.net> <20170926211342.0c8e72b0@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, alexei.starovoitov@gmail.com,
        john.fastabend@gmail.com, peter.waskiewicz.jr@intel.com,
        jakub.kicinski@netronome.com, netdev@vger.kernel.org,
        Andy Gospodarek <andy@greyhouse.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37956 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965209AbdIZT7B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 15:59:01 -0400
In-Reply-To: <20170926211342.0c8e72b0@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/26/2017 09:13 PM, Jesper Dangaard Brouer wrote:
[...]
> I'm currently implementing a cpumap type, that transfers raw XDP frames
> to another CPU, and the SKB is allocated on the remote CPU.  (It
> actually works extremely well).

Meaning you let all the XDP_PASS packets get processed on a
different CPU, so you can reserve the whole CPU just for
prefiltering, right? Do you have some numbers to share at
this point, just curious when you mention it works extremely
well.

> For transferring info I need, I'm currently using xdp->data_hard_start
> (the top/start of the xdp page).  Which should be compatible with your
> approach, right?

Should be possible, yes. More below.

> The info I need:
>
>   struct xdp_pkt {
> 	void *data;
> 	u16 len;
> 	u16 headroom;
> 	struct net_device *dev_rx;
>   };
>
> When I enqueue the xdp packet I do the following:
>
>   int cpu_map_enqueue(struct bpf_cpu_map_entry *rcpu, struct xdp_buff *xdp,
> 	struct net_device *dev_rx)
>   {
> 	struct xdp_pkt *xdp_pkt;
> 	int headroom;
>
> 	/* Convert xdp_buff to xdp_pkt */
> 	headroom = xdp->data - xdp->data_hard_start;
> 	if (headroom < sizeof(*xdp_pkt))
> 		return -EOVERFLOW;
> 	xdp_pkt = xdp->data_hard_start;
> 	xdp_pkt->data = xdp->data;
> 	xdp_pkt->len  = xdp->data_end - xdp->data;
> 	xdp_pkt->headroom = headroom - sizeof(*xdp_pkt);
>
> 	/* Info needed when constructing SKB on remote CPU */
> 	xdp_pkt->dev_rx = dev_rx;
>
> 	bq_enqueue(rcpu, xdp_pkt);
> 	return 0;
>   }
>
> On the remote CPU dequeueing the packet, I'm doing the following.  As
> you can see I'm still lacking some meta-data, that would be nice to
> also transfer.  Could I use your infrastructure for that?

There could be multiple options to use it, in case you have a
helper where you look up the CPU in the map and would also store
the meta data, you could use a per-CPU scratch buffer similarly
as we do with struct redirect_info, and move that later e.g.
after program return into xdp->data_hard_start pointer. You
could also reserve that upfront potentially, so it's hidden from
the beginning from the program unless you want the program itself
to fill it out (modulo the pointers). Not all drivers currently
leave room though, I've also seen where xdp->data_hard_start
points directly to xdp->data, so there's 0 headroom available to
use; in such case it could either be treated as a hint and for
those drivers where they just pass the skb up the current CPU or
you would need some other means to move the meta data to the
remote CPU, or potentially just use tail room.

Thanks,
Daniel
