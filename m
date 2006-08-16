From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/1] network memory allocator.
Date: Wed, 16 Aug 2006 13:27:02 +0200
Message-ID: <200608161327.02826.arnd@arndb.de>
References: <20060814110359.GA27704@2ka.mipt.ru> <20060816084808.GA7366@infradead.org> <20060816090028.GA25476@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751036AbWHPL12@vger.kernel.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060816090028.GA25476@2ka.mipt.ru>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 16 August 2006 11:00, Evgeniy Polyakov wrote:
> There is drawback here - if data was allocated on CPU wheere NIC is
> "closer" and then processed on different CPU it will cost more than 
> in case where buffer was allocated on CPU where it will be processed.
> 
> But from other point of view, most of the adapters preallocate set of
> skbs, and with msi-x help there will be a possibility to bind irq and
> processing to the CPU where data was origianlly allocated.
> 
> So I would like to know how to determine which node should be used for
> allocation. Changes of __get_user_pages() to alloc_pages_node() are
> trivial.

There are two separate memory areas here: Your own metadata used by the
allocator and the memory used for skb data.

avl_node_array[cpu] and avl_container_array[cpu] are only designed to
be accessed only by the local cpu, so these should be done like

avl_node_array[cpu] = kmalloc_node(AVL_NODE_PAGES * sizeof(void *),
			GFP_KERNEL, cpu_to_node(cpu));

or you could make the whole array DEFINE_PER_CPU(void *, which would
waste some space in the kernel object file.

Now for the actual pages you get with __get_free_pages(), doing the
same (alloc_pages_node), will help accessing your avl_container 
members, but may not be the best solution for getting the data
next to the network adapter.

	Arnd <><
