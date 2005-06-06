From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] Replace scatterlist with crypto_frag
Date: Mon, 06 Jun 2005 15:46:53 -0700 (PDT)
Message-ID: <20050606.154653.64001264.davem@davemloft.net>
References: <20050606115939.GA399@gondor.apana.org.au>
	<20050606120914.GA8317@infradead.org>
	<20050606124043.GA625@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hch@infradead.org, jmorris@redhat.com, linux-crypto@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20050606124043.GA625@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 6 Jun 2005 22:40:43 +1000

> However, for skb_frag_t at least going to the 32-bit version on i386
> means at least 72 bytes extra for every skb->data allocation.
> 
> Dave, what are your views on making skb_frag_t bigger?

Good question.

There is an ancillary issue that I'd like to address at
some point, and what you do here is tied into that.

Currently, NETIF_F_SG drivers do one DMA mapping call for
each fragment of the packet.  That totally stinks performance
wise, and the PPC64 and SPARC64 folks feel this the most.

So I wanted to create a set of interfaces ala:

   int dma_map_skb(struct sk_buff *skb, ...);
   void dma_unmap_skb(struct sk_buff *skb, ...);
   void dma_sync_skb_for_cpu(struct sk_buff *skb, ...);
   void dma_sync_skb_for_device(struct sk_buff *skb, ...);

The question is where to put the DMA mapping cookies :-)

On i386 and alike, using something like the DECLARE_PCI_UNMAP_*()
macros would allow us to NOP out the DMA addresses entirely.  Since
they are computable from the page struct and offset.

Note that the above interface, on IOMMU platforms, would allow
DMA coalescing to be performed.  This would hit heavily with
TSO, for example.  Most packets would go out with a maximum of
2 DMA descriptors, 1 for the mapping of skb->data and 1 for
all of the paged SKB data afterwards combined.

Note that, due to this coalescing, the "size" member must be
larger than a __u16.

So I guess I'm taking you a step backwards, I want to make
skb_frag_struct a little bigger :-)  Ie. put the DMA mapping
cookies into the skb_frag_struct, then a set of accessor
macros like we have for scatterlist.  Well, in fact, it would
become a scatterlist and therefore the only thing special
about dma_map_skb() is that is maps a linear buffer via
skb->data then the scatterlist in skb_shared_info(skb).
