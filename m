From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [Lsf] [Lsf-pc] [LSF/MM TOPIC] Generic page-pool recycle
 facility?
Date: Tue, 12 Apr 2016 08:16:49 +0200
Message-ID: <20160412081649.4cb4f9db@redhat.com>
References: <1460034425.20949.7.camel@HansenPartnership.com>
	<20160407161715.52635cac@redhat.com>
	<20160407143854.GA7685@infradead.org>
	<570678B7.7010802@sandisk.com>
	<570A9F5B.5010600@grimberg.me>
	<20160411234157.3fc9c6fe@redhat.com>
	<20160411222124.GA80595@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "lsf@lists.linux-foundation.org" <lsf@lists.linux-foundation.org>,
        James
 Bottomley <James.Bottomley@HansenPartnership.com>,
        Sagi Grimberg
 <sagi@grimberg.me>, Tom Herbert <tom@herbertland.com>,
        Brenden Blanco
 <bblanco@plumgrid.com>,
        Christoph Hellwig <hch@infradead.org>, linux-mm
 <linux-mm@kvack.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Bart Van Assche <bart.vanassche@sandisk.com>,
        "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>,
        brouer@redhat.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20160411222124.GA80595@ast-mbp.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org


On Mon, 11 Apr 2016 15:21:26 -0700
Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> On Mon, Apr 11, 2016 at 11:41:57PM +0200, Jesper Dangaard Brouer wrote:
> > 
> > On Sun, 10 Apr 2016 21:45:47 +0300 Sagi Grimberg <sagi@grimberg.me> wrote:
> >   
[...]
> > > 
> > > If we go down this road how about also attaching some driver opaques
> > > to the page sets?  
> > 
> > That was the ultimate plan... to leave some opaques bytes left in the
> > page struct that drivers could use.
> > 
> > In struct page I would need a pointer back to my page_pool struct and a
> > page flag.  Then, I would need room to store the dma_unmap address.
> > (And then some of the usual fields are still needed, like the refcnt,
> > and reusing some of the list constructs).  And a zero-copy cross-domain
> > id.  
> 
> I don't think we need to add anything to struct page.
> This is supposed to be small cache of dma_mapped pages with lockless access.
> It can be implemented as an array or link list where every element
> is dma_addr and pointer to page. If it is full, dma_unmap_page+put_page to
> send it to back to page allocator.

It sounds like the Intel drivers recycle facility, where they split the
page into two parts, and keep page in RX-ring, by swapping to other
half of page, if page_count(page) is <= 2.  Thus, they use the atomic
page ref count to synchronize on.

Thus, we end-up having two atomic operations per RX packet, on the page
refcnt.  Where DPDK have zero...

By fully taking over the page as an allocator, almost like slab. I can
optimize the common case (of the packet-page getting allocated and
free'ed on the same CPU), and remove these atomic operations.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
