From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: dma_alloc_coherent() to use memory close to cpu
Date: Wed, 13 May 2015 08:49:51 -0700
Message-ID: <5553729F.3020205@redhat.com>
References: <55534659.9000606@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: achiad@mellanox.com, Or Gerlitz <ogerlitz@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57977 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933026AbbEMQpW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2015 12:45:22 -0400
In-Reply-To: <55534659.9000606@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/13/2015 05:40 AM, Amir Vadai wrote:
> Hi Alex,
>
> dma_alloc_coherent() is allocating memory close to the device -
> according to dev_to_node(dev). Sometimes it is better to use memory
> close to the CPU. e.g. when it is a buffer that NIC writes and CPU reads.

Yes, the easiest way to visualize this is do you want to have this 
operator under a push or pull model.  Either you can have the hardware 
push the data to where the interrupt will be processed, or the interrupt 
will have to pull the data to the CPU it is being processed on.  As long 
as there are enough PCIe credits to keep the PCIe link fully utilized 
you are usually better off pushing the data to the CPU the interrupt is 
on as the reads/writes are usually batched by the hardware.

> It seems that you thought that too, and added a commit to ixgbe driver
> that follows that logic [1].
> You added calls to set_dev_node() before and after the allocation.
> This seems to be prone to races in case multiple process want to alloc
> in parallel. The proper fix seems to be to extend the
> dma_alloc_coherent() to accept a NUMA node as an argument (if device's
> node is not good enough).

I'm not sure how racy it would be since you can really only have one 
driver per device and the function that does this is protected by the 
RTNL lock as I recall.

> I looked for, but couldn't find any discussion about that - is there a
> special reason not to extend dma_alloc_coherent()?

I think most of that is due to the fact that it is buried in multiple 
levels of abstraction and at the time I wrote that code I had only been 
working in the kernel drivers for a year or so.  I had to revert similar 
code from igb as it was buggy so I wasn't really in a place to be 
modifying that at that time.

If you are planning to give it a try I would say go for it.  The fact is 
there are models where you want to have the device memory spread around 
since the DMA writes usually are much less expensive to a remote node, 
than accessing a remote node from the interrupt handler.

- Alex
