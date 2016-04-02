From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC PATCH 4/5] mlx4: add support for fast rx drop bpf program
Date: Fri, 1 Apr 2016 19:47:12 -0700
Message-ID: <20160402024710.GA59703@ast-mbp.thefacebook.com>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
 <1459560118-5582-5-git-send-email-bblanco@plumgrid.com>
 <1459562911.6473.299.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brenden Blanco <bblanco@plumgrid.com>, davem@davemloft.net,
	netdev@vger.kernel.org, tom@herbertland.com, ogerlitz@mellanox.com,
	daniel@iogearbox.net, john.fastabend@gmail.com, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:32932 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828AbcDBCrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 22:47:17 -0400
Received: by mail-pf0-f178.google.com with SMTP id 184so3752145pff.0
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 19:47:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1459562911.6473.299.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 01, 2016 at 07:08:31PM -0700, Eric Dumazet wrote:
> On Fri, 2016-04-01 at 18:21 -0700, Brenden Blanco wrote:
> > Add support for the BPF_PROG_TYPE_PHYS_DEV hook in mlx4 driver.  Since
> > bpf programs require a skb context to navigate the packet, build a
> > percpu fake skb with the minimal fields. This avoids the costly
> > allocation for packets that end up being dropped.
> > 
> 
> 
> > +		/* A bpf program gets first chance to drop the packet. It may
> > +		 * read bytes but not past the end of the frag. A non-zero
> > +		 * return indicates packet should be dropped.
> > +		 */
> > +		if (prog) {
> > +			struct ethhdr *ethh;
> > +
> > +			ethh = (struct ethhdr *)(page_address(frags[0].page) +
> > +						 frags[0].page_offset);
> > +			if (mlx4_call_bpf(prog, ethh, length)) {
> > +				priv->stats.rx_dropped++;
> > +				goto next;
> > +			}
> > +		}
> > +
> 
> 
> 1) mlx4 can use multiple fragments (priv->num_frags) to hold an Ethernet
> frame. 
> 
> Still you pass a single fragment but total 'length' here : BPF program
> can read past the end of this first fragment and panic the box.
> 
> Please take a look at mlx4_en_complete_rx_desc() and you'll see what I
> mean.

yep.
my reading of that part was that num_frags > 1 is only for large
mtu sizes, so if we limit this for num_frags==1 only for now
we should be ok and it's still applicable for most of the use cases ?

> 2) priv->stats.rx_dropped is shared by all the RX queues -> false
> sharing.

yes. good point. I bet it was copy pasted from few lines below.
Should be trivial to convert it to percpu.

>    This is probably the right time to add a rx_dropped field in struct
> mlx4_en_rx_ring since you guys want to drop 14 Mpps, and 50 Mpps on
> higher speed links.

yes, could be per ring as well.
My guess we're hitting 14.5Mpps limit for empty bpf program
and for program that actually looks into the packet because we're
hitting 10G phy limit of 40G nic. Since physically 40G nic
consists of four 10G phys. There will be the same problem
with 100G and 50G nics. Both will be hitting 25G phy limit.
We need to vary packets somehow. Hopefully Or can explain that
bit of hw design.
Jesper's experiments with mlx4 showed the same 14.5Mpps limit
when sender blasting the same packet over and over again.
Great to see the experiments converging.
