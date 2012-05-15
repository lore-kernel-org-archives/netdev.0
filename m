From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: ibmveth bug?
Date: Tue, 15 May 2012 10:01:41 -0700
Message-ID: <20120515170141.GA14272@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: anton@samba.org, benh@kernel.crashing.org, paulus@samba.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: santil@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Santiago,

Are you still working on ibmveth?

I've found a very sporadic bug with ibmveth in some testing. PAPR
requires that:

"Validate the Buffer Descriptor of the receive queue buffer (I/O
addresses for entire buffer length starting at the spec- ified I/O
address are translated by the RTCE table, length is a multiple of 16
bytes, and alignment is on a 16 byte boundary) else H_Parameter."

but from what I can tell ibmveth.c is not enforcing this last condition:

	adapter->rx_queue.queue_addr =
		kmalloc(adapter->rx_queue.queue_len, GFP_KERNEL);

	...

	adapter->rx_queue.queue_dma = dma_map_single(dev,
		adapter->rx_queue.queue_addr, adapter->rx_queue.queue_len,
		DMA_BIDIRECTIONAL);

	...

	rxq_desc.fields.address = adapter->rx_queue.queue_dma;

	...
	

	lpar_rc = ibmveth_register_logical_lan(adapter, rxq_desc,
		mac_address);
	netdev_err(netdev, "buffer TCE:0x%llx filter TCE:0x%llx rxq "
	 	"desc:0x%llx MAC:0x%llx\n", adapter->buffer_list_dma,
	 	adapter->filter_list_dma, rxq_desc.desc, mac_address);

And I got on one install attempt:

[ 39.978430] ibmveth 30000004: eth0: h_register_logical_lan failed with -4
[ 39.978449] ibmveth 30000004: eth0: buffer TCE:0x1000 filter TCE:0x10000 rxq desc:0x80006010000200a8 MAC:0x56754de8e904

rxq desc, as you can see is not 16byte aligned. kmalloc() only
guarantees 8-byte alignment (as does gcc, I think). Initially, I thought
we could just overallocate the queue_addr and ALIGN() down, but then we
would need to save the original kmalloc pointer in a new struct member
per rx_queue.

So a couple of questions:

1) Is my analysis accurate? :)

2) How gross would it be to save an extra pointer for every rx_queue?

3) Based upon 2), is it better to just go ahead and create our own
kmem_cache (which gets an alignment specified)?

For 3), I started coding this, but couldn't find a clean place to
allocate the kmem_cache itself, as the size of each object depends on
the run-time characteristics (afaict), but needs to be specified at
cache creation time. Any insight you could provide would be great!

Thanks,
Nish
 
-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center
