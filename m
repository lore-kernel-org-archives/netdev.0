From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: ibmveth bug?
Date: Mon, 23 Jul 2012 12:03:06 -0700
Message-ID: <20120723190306.GB3444@linux.vnet.ibm.com>
References: <20120515170141.GA14272@linux.vnet.ibm.com>
 <20120720224112.GD19288@linux.vnet.ibm.com>
 <1342831966.29855.6.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: santil@linux.vnet.ibm.com, anton@samba.org, paulus@samba.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Anton Blanchard <anton@au1.ibm.com>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1342831966.29855.6.camel@pasglop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ben,

On 21.07.2012 [10:52:46 +1000], Benjamin Herrenschmidt wrote:
> On Fri, 2012-07-20 at 15:41 -0700, Nishanth Aravamudan wrote:
> > Ping on this ... we've tripped the same issue on a different system, it
> > would appear. Would appreciate if anyone can provide answers to the
> > questions below.
> 
> Well, I haven't hit it but your description makes sense. Why not use
> dma_alloc_coherent though ? Rather than kmalloc followed by map ?

Thanks for the response!

dma_alloc_coherent here makes sense. I honestly haven't though too much
about solutions yet, as the problem isn't consistent. For instance, the
one reproducer right now is hitting it only at install time, and only if
another particular PCI device is also plugged in to the machine.

> At least on power we give you page alignment for these, so the problem
> is solved magically :-) Another option is GFP + dma_map_page which is
> roughly equivalent.
> 
> If you think it's a waste of space based on the queue size, then just
> add an extra pointer, I wouldn't bother with a cache for something only
> allocated when the driver initializes.

Agreed, will try to code something up this week.

Thanks,
Nish

> 
> Cheers,
> Ben.
> 
> > Thanks,
> > Nish
> > 
> > On 15.05.2012 [10:01:41 -0700], Nishanth Aravamudan wrote:
> > > Hi Santiago,
> > > 
> > > Are you still working on ibmveth?
> > > 
> > > I've found a very sporadic bug with ibmveth in some testing. PAPR
> > > requires that:
> > > 
> > > "Validate the Buffer Descriptor of the receive queue buffer (I/O
> > > addresses for entire buffer length starting at the spec- ified I/O
> > > address are translated by the RTCE table, length is a multiple of 16
> > > bytes, and alignment is on a 16 byte boundary) else H_Parameter."
> > > 
> > > but from what I can tell ibmveth.c is not enforcing this last condition:
> > > 
> > > 	adapter->rx_queue.queue_addr =
> > > 		kmalloc(adapter->rx_queue.queue_len, GFP_KERNEL);
> > > 
> > > 	...
> > > 
> > > 	adapter->rx_queue.queue_dma = dma_map_single(dev,
> > > 		adapter->rx_queue.queue_addr, adapter->rx_queue.queue_len,
> > > 		DMA_BIDIRECTIONAL);
> > > 
> > > 	...
> > > 
> > > 	rxq_desc.fields.address = adapter->rx_queue.queue_dma;
> > > 
> > > 	...
> > > 	
> > > 
> > > 	lpar_rc = ibmveth_register_logical_lan(adapter, rxq_desc,
> > > 		mac_address);
> > > 	netdev_err(netdev, "buffer TCE:0x%llx filter TCE:0x%llx rxq "
> > > 	 	"desc:0x%llx MAC:0x%llx\n", adapter->buffer_list_dma,
> > > 	 	adapter->filter_list_dma, rxq_desc.desc, mac_address);
> > > 
> > > And I got on one install attempt:
> > > 
> > > [ 39.978430] ibmveth 30000004: eth0: h_register_logical_lan failed with -4
> > > [ 39.978449] ibmveth 30000004: eth0: buffer TCE:0x1000 filter TCE:0x10000 rxq desc:0x80006010000200a8 MAC:0x56754de8e904
> > > 
> > > rxq desc, as you can see is not 16byte aligned. kmalloc() only
> > > guarantees 8-byte alignment (as does gcc, I think). Initially, I thought
> > > we could just overallocate the queue_addr and ALIGN() down, but then we
> > > would need to save the original kmalloc pointer in a new struct member
> > > per rx_queue.
> > > 
> > > So a couple of questions:
> > > 
> > > 1) Is my analysis accurate? :)
> > > 
> > > 2) How gross would it be to save an extra pointer for every rx_queue?
> > > 
> > > 3) Based upon 2), is it better to just go ahead and create our own
> > > kmem_cache (which gets an alignment specified)?
> > > 
> > > For 3), I started coding this, but couldn't find a clean place to
> > > allocate the kmem_cache itself, as the size of each object depends on
> > > the run-time characteristics (afaict), but needs to be specified at
> > > cache creation time. Any insight you could provide would be great!
> > > 
> > > Thanks,
> > > Nish
> > >  
> > > -- 
> > > Nishanth Aravamudan <nacc@us.ibm.com>
> > > IBM Linux Technology Center
> > 
> 
> 

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center
