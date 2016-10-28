From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next RFC WIP] Patch for XDP support for virtio_net
Date: Fri, 28 Oct 2016 21:36:34 +0100
Message-ID: <20161028213634.4a747881@jkicinski-Precision-T1700>
References: <20161028011739-mutt-send-email-mst@kernel.org>
        <20161027.213512.334468356710231957.davem@davemloft.net>
        <CAKgT0Ufe3QYtFpmtsL39-nbyy+YEt=gZKU_WUr9Wir+LTYLuEQ@mail.gmail.com>
        <20161027.221027.109834362557507518.davem@davemloft.net>
        <58137533.4030105@gmail.com>
        <20161028171812.48073f1f@jkicinski-Precision-T1700>
        <20161028182223.GA53930@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        David Miller <davem@davemloft.net>, alexander.duyck@gmail.com,
        mst@redhat.com, brouer@redhat.com, shrijeet@gmail.com,
        tom@herbertland.com, netdev@vger.kernel.org,
        shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.10]:20901 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754014AbcJ1Ugn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Oct 2016 16:36:43 -0400
In-Reply-To: <20161028182223.GA53930@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Oct 2016 11:22:25 -0700, Alexei Starovoitov wrote:
> On Fri, Oct 28, 2016 at 05:18:12PM +0100, Jakub Kicinski wrote:
> > On Fri, 28 Oct 2016 08:56:35 -0700, John Fastabend wrote:  
> > > On 16-10-27 07:10 PM, David Miller wrote:  
> > > > From: Alexander Duyck <alexander.duyck@gmail.com>
> > > > Date: Thu, 27 Oct 2016 18:43:59 -0700
> > > >     
> > > >> On Thu, Oct 27, 2016 at 6:35 PM, David Miller <davem@davemloft.net> wrote:    
> > > >>> From: "Michael S. Tsirkin" <mst@redhat.com>
> > > >>> Date: Fri, 28 Oct 2016 01:25:48 +0300
> > > >>>    
> > > >>>> On Thu, Oct 27, 2016 at 05:42:18PM -0400, David Miller wrote:    
> > > >>>>> From: "Michael S. Tsirkin" <mst@redhat.com>
> > > >>>>> Date: Fri, 28 Oct 2016 00:30:35 +0300
> > > >>>>>    
> > > >>>>>> Something I'd like to understand is how does XDP address the
> > > >>>>>> problem that 100Byte packets are consuming 4K of memory now.    
> > > >>>>>
> > > >>>>> Via page pools.  We're going to make a generic one, but right now
> > > >>>>> each and every driver implements a quick list of pages to allocate
> > > >>>>> from (and thus avoid the DMA man/unmap overhead, etc.)    
> > > >>>>
> > > >>>> So to clarify, ATM virtio doesn't attempt to avoid dma map/unmap
> > > >>>> so there should be no issue with that even when using sub/page
> > > >>>> regions, assuming DMA APIs support sub-page map/unmap correctly.    
> > > >>>
> > > >>> That's not what I said.
> > > >>>
> > > >>> The page pools are meant to address the performance degradation from
> > > >>> going to having one packet per page for the sake of XDP's
> > > >>> requirements.
> > > >>>
> > > >>> You still need to have one packet per page for correct XDP operation
> > > >>> whether you do page pools or not, and whether you have DMA mapping
> > > >>> (or it's equivalent virutalization operation) or not.    
> > > >>
> > > >> Maybe I am missing something here, but why do you need to limit things
> > > >> to one packet per page for correct XDP operation?  Most of the drivers
> > > >> out there now are usually storing something closer to at least 2
> > > >> packets per page, and with the DMA API fixes I am working on there
> > > >> should be no issue with changing the contents inside those pages since
> > > >> we won't invalidate or overwrite the data after the DMA buffer has
> > > >> been synchronized for use by the CPU.    
> > > > 
> > > > Because with SKB's you can share the page with other packets.
> > > > 
> > > > With XDP you simply cannot.
> > > > 
> > > > It's software semantics that are the issue.  SKB frag list pages
> > > > are read only, XDP packets are writable.
> > > > 
> > > > This has nothing to do with "writability" of the pages wrt. DMA
> > > > mapping or cpu mappings.
> > > >     
> > > 
> > > Sorry I'm not seeing it either. The current xdp_buff is defined
> > > by,
> > > 
> > >   struct xdp_buff {
> > > 	void *data;
> > > 	void *data_end;
> > >   };
> > > 
> > > The verifier has an xdp_is_valid_access() check to ensure we don't go
> > > past data_end. The page for now at least never leaves the driver. For
> > > the work to get xmit to other devices working I'm still not sure I see
> > > any issue.  
> > 
> > +1
> > 
> > Do we want to make the packet-per-page a requirement because it could
> > be useful in the future from architectural standpoint?  I guess there
> > is a trade-off here between having the comfort of people following this
> > requirement today and making driver support for XDP even more complex.  
>
> It looks to me that packet per page makes drivers simpler instead of complex.
> ixgbe split-page and mlx* order-3/5 tricks are definitely complex.
> The skb truesize concerns come from the host when data is delivered to user
> space and we need to have precise memory accounting for different applications
> and different users. XDP is all root and imo it's far away from the days when
> multi-user non-root issues start to pop up.
> At the same time XDP doesn't require to use 4k buffer in something like Netronome.
> If xdp bpf program can be offloaded into HW with 1800 byte buffers, great!
> For x86 cpu the 4k byte is a natural allocation chunk. Anything lower requires
> delicate dma tricks paired with even more complex slab allocator and atomic recnts.
> All of that can only drive the performance down.
> Comparing to kernel bypass xdp is using 4k pages whereas dpdk has
> to use huge pages, so xdp is saving a ton of memory already!
 
Thanks a lot for explaining!  I was not aware of the user space
delivery and precise memory accounting requirements.

My understanding was that we would be driving toward some common
implementation of the recycle tricks either as part of the frag
allocator or some new mechanism of handing out mapped pages.  Basically
moving the allocation strategy decision further up the stack.

I'm not actually worried about the offload, full disclosure, I have a
XDP implementation based on the frag allocator :) (still pending
internal review), so if packet-per-page is the way forward then I'll
have revise to flip between 4k pages and frag allocator based on !!xdp.
