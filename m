From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC PATCH 4/5] mlx4: add support for fast rx drop bpf program
Date: Mon, 4 Apr 2016 11:27:27 -0700
Message-ID: <20160404182724.GB68392@ast-mbp.thefacebook.com>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
 <1459560118-5582-5-git-send-email-bblanco@plumgrid.com>
 <20160402102331.5aa3b3c2@redhat.com>
 <20160403061151.GC21980@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, tom@herbertland.com, ogerlitz@mellanox.com,
	daniel@iogearbox.net, john.fastabend@gmail.com
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35221 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755557AbcDDS1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 14:27:31 -0400
Received: by mail-pa0-f41.google.com with SMTP id td3so148676543pab.2
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 11:27:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160403061151.GC21980@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 02, 2016 at 11:11:52PM -0700, Brenden Blanco wrote:
> On Sat, Apr 02, 2016 at 10:23:31AM +0200, Jesper Dangaard Brouer wrote:
> [...]
> > 
> > I think you need to DMA sync RX-page before you can safely access
> > packet data in page (on all arch's).
> > 
> Thanks, I will give that a try in the next spin.
> > > +			ethh = (struct ethhdr *)(page_address(frags[0].page) +
> > > +						 frags[0].page_offset);
> > > +			if (mlx4_call_bpf(prog, ethh, length)) {
> > 
> > AFAIK length here covers all the frags[n].page, thus potentially
> > causing the BPF program to access memory out of bound (crash).
> > 
> > Having several page fragments is AFAIK an optimization for jumbo-frames
> > on PowerPC (which is a bit annoying for you use-case ;-)).
> > 
> Yeah, this needs some more work. I can think of some options:
> 1. limit pseudo skb.len to first frag's length only, and signal to
> program that the packet is incomplete
> 2. for nfrags>1 skip bpf processing, but this could be functionally
> incorrect for some use cases
> 3. run the program for each frag
> 4. reject ndo_bpf_set when frags are possible (large mtu?)
> 
> My preference is to go with 1, thoughts?

hmm and what program will do with 'incomplete' packet?
imo option 4 is only way here. If phys_dev bpf program already
attached to netdev then mlx4_en_change_mtu() can reject jumbo mtus.
My understanding of mlx4_en_calc_rx_buf is that mtu < 1514
will have num_frags==1. That's the common case and one we
want to optimize for.
If later we can find a way to change mlx4 driver to support
phys_dev bpf programs with jumbo mtus, great.
