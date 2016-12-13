From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: Designing a safe RX-zero-copy Memory Model for Networking
Date: Tue, 13 Dec 2016 11:42:22 +0200
Message-ID: <20161213094222.GF19987@rapoport-lnx>
References: <20161205153132.283fcb0e@redhat.com>
 <20161212083812.GA19987@rapoport-lnx>
 <20161212104042.0a011212@redhat.com>
 <20161212141433.GB19987@rapoport-lnx>
 <584EB8DF.8000308@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        linux-mm <linux-mm@kvack.org>,
        Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        =?iso-8859-1?Q?Bj=F6rn_T=F6pel?= <bjorn.topel@intel.com>,
        "Karlsson, Magnus" <magnus.karlsson@intel.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Mel Gorman <mgorman@techsingularity.net>,
        Tom Herbert <tom@herbertland.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Jesse Brandeburg <jesse.brandeburg@intel.com>,
        Kalman Meth <METH@il.ibm.com>,
        Vladislav Yasevich <vyasevich@gmail.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <584EB8DF.8000308@gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 12, 2016 at 06:49:03AM -0800, John Fastabend wrote:
> On 16-12-12 06:14 AM, Mike Rapoport wrote:
> >>
> > We were not considered using XDP yet, so we've decided to limit the initial
> > implementation to macvtap because we can ensure correspondence between a
> > NIC queue and virtual NIC, which is not the case with more generic tap
> > device. It could be that use of XDP will allow for a generic solution for
> > virtio case as well.
> 
> Interesting this was one of the original ideas behind the macvlan
> offload mode. iirc Vlad also was interested in this.
> 
> I'm guessing this was used because of the ability to push macvlan onto
> its own queue?

Yes, with a queue dedicated to a virtual NIC we only need to ensure that
guest memory is used for RX buffers. 
 
> >>
> >>> Have you considered using "push" model for setting the NIC's RX memory?
> >>
> >> I don't understand what you mean by a "push" model?
> > 
> > Currently, memory allocation in NIC drivers boils down to alloc_page with
> > some wrapping code. I see two possible ways to make NIC use of some
> > preallocated pages: either NIC driver will call an API (probably different
> > from alloc_page) to obtain that memory, or there will be NDO API that
> > allows to set the NIC's RX buffers. I named the later case "push".
> 
> I prefer the ndo op. This matches up well with AF_PACKET model where we
> have "slots" and offload is just a transparent "push" of these "slots"
> to the driver. Below we have a snippet of our proposed API,
> 
> (https://patchwork.ozlabs.org/patch/396714/ note the descriptor mapping
> bits will be dropped)
> 
> + * int (*ndo_direct_qpair_page_map) (struct vm_area_struct *vma,
> + *				     struct net_device *dev)
> + *	Called to map queue pair range from split_queue_pairs into
> + *	mmap region.
> +
> 
> > +
> > +static int
> > +ixgbe_ndo_qpair_page_map(struct vm_area_struct *vma, struct net_device *dev)
> > +{
> > +	struct ixgbe_adapter *adapter = netdev_priv(dev);
> > +	phys_addr_t phy_addr = pci_resource_start(adapter->pdev, 0);
> > +	unsigned long pfn_rx = (phy_addr + RX_DESC_ADDR_OFFSET) >> PAGE_SHIFT;
> > +	unsigned long pfn_tx = (phy_addr + TX_DESC_ADDR_OFFSET) >> PAGE_SHIFT;
> > +	unsigned long dummy_page_phy;
> > +	pgprot_t pre_vm_page_prot;
> > +	unsigned long start;
> > +	unsigned int i;
> > +	int err;
> > +
> > +	if (!dummy_page_buf) {
> > +		dummy_page_buf = kzalloc(PAGE_SIZE_4K, GFP_KERNEL);
> > +		if (!dummy_page_buf)
> > +			return -ENOMEM;
> > +
> > +		for (i = 0; i < PAGE_SIZE_4K / sizeof(unsigned int); i++)
> > +			dummy_page_buf[i] = 0xdeadbeef;
> > +	}
> > +
> > +	dummy_page_phy = virt_to_phys(dummy_page_buf);
> > +	pre_vm_page_prot = vma->vm_page_prot;
> > +	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
> > +
> > +	/* assume the vm_start is 4K aligned address */
> > +	for (start = vma->vm_start;
> > +	     start < vma->vm_end;
> > +	     start += PAGE_SIZE_4K) {
> > +		if (start == vma->vm_start + RX_DESC_ADDR_OFFSET) {
> > +			err = remap_pfn_range(vma, start, pfn_rx, PAGE_SIZE_4K,
> > +					      vma->vm_page_prot);
> > +			if (err)
> > +				return -EAGAIN;
> > +		} else if (start == vma->vm_start + TX_DESC_ADDR_OFFSET) {
> > +			err = remap_pfn_range(vma, start, pfn_tx, PAGE_SIZE_4K,
> > +					      vma->vm_page_prot);
> > +			if (err)
> > +				return -EAGAIN;
> > +		} else {
> > +			unsigned long addr = dummy_page_phy > PAGE_SHIFT;
> > +
> > +			err = remap_pfn_range(vma, start, addr, PAGE_SIZE_4K,
> > +					      pre_vm_page_prot);
> > +			if (err)
> > +				return -EAGAIN;
> > +		}
> > +	}
> > +	return 0;
> > +}
> > +
> 
> Any thoughts on something like the above? We could push it when net-next
> opens. One piece that fits naturally into vhost/macvtap is the kicks and
> queue splicing are already there so no need to implement this making the
> above patch much simpler.

Sorry, but I don't quite follow you here. The vhost does not use vma
mappings, it just sees a bunch of pages pointed by the vring descriptors...
 
> .John
 
--
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
