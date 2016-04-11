From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [Lsf] [Lsf-pc] [LSF/MM TOPIC] Generic page-pool recycle facility?
Date: Mon, 11 Apr 2016 15:21:26 -0700
Message-ID: <20160411222124.GA80595@ast-mbp.thefacebook.com>
References: <1460034425.20949.7.camel@HansenPartnership.com>
 <20160407161715.52635cac@redhat.com>
 <20160407143854.GA7685@infradead.org>
 <570678B7.7010802@sandisk.com>
 <570A9F5B.5010600@grimberg.me>
 <20160411234157.3fc9c6fe@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sagi Grimberg <sagi@grimberg.me>,
	Bart Van Assche <bart.vanassche@sandisk.com>,
	Christoph Hellwig <hch@infradead.org>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	Tom Herbert <tom@herbertland.com>,
	Brenden Blanco <bblanco@plumgrid.com>,
	"lsf@lists.linux-foundation.org" <lsf@lists.linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20160411234157.3fc9c6fe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 11, 2016 at 11:41:57PM +0200, Jesper Dangaard Brouer wrote:
> 
> On Sun, 10 Apr 2016 21:45:47 +0300 Sagi Grimberg <sagi@grimberg.me> wrote:
> 
> > >> This is also very interesting for storage targets, which face the same
> > >> issue.  SCST has a mode where it caches some fully constructed SGLs,
> > >> which is probably very similar to what NICs want to do.  
> > >
> > > I think a cached allocator for page sets + the scatterlists that
> > > describe these page sets would not only be useful for SCSI target
> > > implementations but also for the Linux SCSI initiator. Today the scsi-mq
> > > code reserves space in each scsi_cmnd for a scatterlist of
> > > SCSI_MAX_SG_SEGMENTS. If scatterlists would be cached together with page
> > > sets less memory would be needed per scsi_cmnd.  
> > 
> > If we go down this road how about also attaching some driver opaques
> > to the page sets?
> 
> That was the ultimate plan... to leave some opaques bytes left in the
> page struct that drivers could use.
> 
> In struct page I would need a pointer back to my page_pool struct and a
> page flag.  Then, I would need room to store the dma_unmap address.
> (And then some of the usual fields are still needed, like the refcnt,
> and reusing some of the list constructs).  And a zero-copy cross-domain
> id.

I don't think we need to add anything to struct page.
This is supposed to be small cache of dma_mapped pages with lockless access.
It can be implemented as an array or link list where every element
is dma_addr and pointer to page. If it is full, dma_unmap_page+put_page to
send it to back to page allocator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
