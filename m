From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 4/5] mlx4: add support for fast rx drop bpf program
Date: Tue, 5 Apr 2016 08:04:08 +0200
Message-ID: <20160405080408.5c9394f2@redhat.com>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
	<1459560118-5582-5-git-send-email-bblanco@plumgrid.com>
	<20160402102331.5aa3b3c2@redhat.com>
	<20160403061151.GC21980@gmail.com>
	<20160404182724.GB68392@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Brenden Blanco <bblanco@plumgrid.com>, davem@davemloft.net,
	netdev@vger.kernel.org, tom@herbertland.com, ogerlitz@mellanox.com,
	daniel@iogearbox.net, john.fastabend@gmail.com, brouer@redhat.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58989 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753651AbcDEGEP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 02:04:15 -0400
In-Reply-To: <20160404182724.GB68392@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 4 Apr 2016 11:27:27 -0700
Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> On Sat, Apr 02, 2016 at 11:11:52PM -0700, Brenden Blanco wrote:
> > On Sat, Apr 02, 2016 at 10:23:31AM +0200, Jesper Dangaard Brouer wrote:
> > [...]  
> > > 
> > > I think you need to DMA sync RX-page before you can safely access
> > > packet data in page (on all arch's).
> > >   
> > Thanks, I will give that a try in the next spin.  
> > > > +			ethh = (struct ethhdr *)(page_address(frags[0].page) +
> > > > +						 frags[0].page_offset);
> > > > +			if (mlx4_call_bpf(prog, ethh, length)) {  
> > > 
> > > AFAIK length here covers all the frags[n].page, thus potentially
> > > causing the BPF program to access memory out of bound (crash).
> > > 
> > > Having several page fragments is AFAIK an optimization for jumbo-frames
> > > on PowerPC (which is a bit annoying for you use-case ;-)).
> > >   
> > Yeah, this needs some more work. I can think of some options:
> > 1. limit pseudo skb.len to first frag's length only, and signal to
> > program that the packet is incomplete
> > 2. for nfrags>1 skip bpf processing, but this could be functionally
> > incorrect for some use cases
> > 3. run the program for each frag
> > 4. reject ndo_bpf_set when frags are possible (large mtu?)
> > 
> > My preference is to go with 1, thoughts?  
> 
> hmm and what program will do with 'incomplete' packet?
> imo option 4 is only way here. If phys_dev bpf program already
> attached to netdev then mlx4_en_change_mtu() can reject jumbo mtus.
> My understanding of mlx4_en_calc_rx_buf is that mtu < 1514
> will have num_frags==1. That's the common case and one we
> want to optimize for.

I agree, we should only optimize for the common case, where
num_frags==1.


> If later we can find a way to change mlx4 driver to support
> phys_dev bpf programs with jumbo mtus, great.

For getting the DMA-buffer/packet-page writable, some change are needed
in this code path anyhow.  Lets look at that later, when touching that
code path.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
