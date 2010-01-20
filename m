From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 02/11] sky2: fix DMA sync_single length error
Date: Thu, 21 Jan 2010 00:21:02 +0100
Message-ID: <20100120232102.GD3072@del.dom.local>
References: <20100120204459.820265084@vyatta.com>
 <20100120204558.901334592@vyatta.com>
 <20100120213259.GB3072@del.dom.local>
 <20100120.145218.259766536.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f220.google.com ([209.85.220.220]:65047 "EHLO
	mail-fx0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191Ab0ATXVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 18:21:07 -0500
Received: by fxm20 with SMTP id 20so740018fxm.1
        for <netdev@vger.kernel.org>; Wed, 20 Jan 2010 15:21:06 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20100120.145218.259766536.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 20, 2010 at 02:52:18PM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Wed, 20 Jan 2010 22:32:59 +0100
> 
> > On Wed, Jan 20, 2010 at 12:45:01PM -0800, Stephen Hemminger wrote:
> >> From: Jarek Poplawski <jarkao2@gmail.com>
> >> 
> >> Using pci_unmap_len(), with the same length as pci_map_single(), with
> >> pci_dma_sync_single_for_cpu()/_device() fixes this warning (2.6.32.4):
> >> 
> >> > Jan 19 10:43:50 mail kernel: WARNING: at lib/dma-debug.c:902 
> >> > check_sync+0xc1/0x43f()
> >> > Jan 19 10:43:50 mail kernel: Hardware name: System Product Name
> >> > Jan 19 10:43:50 mail kernel: sky2 0000:04:00.0: DMA-API: device driver 
> >> > tries to sync DMA memory it has not allocated [device 
> >> > address=0x0000000320a0b022] [size=60 bytes]  
> >> 
> >> Reported-by: Michael Breuer <mbreuer@majjas.com>
> >> Tested-by: Michael Breuer <mbreuer@majjas.com>
> >> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> >> Acked-by: Stephen Hemminger <shemminger@vyatta.com>
> > 
> > Thanks for acking and completing this, Stephen!
> 
> It's not a bug, lib/dma-debug.c and the DMA API documentation
> are both buggy.
> 
> I'm not applying any of this, the fix belongs in the infrastructure
> debugging and documentation not in the drivers, they are doing the
> correct and only reasonable thing.

You might be 100% right, but why do you want users to pay for this
even one day longer than necessary?

1) The warning was called "oops" by the reporter at the beginning,
   and it's meaningful; it frightens people at least.
2) Fixing this temporarily e.g. in sky2 looks safe and simple, while
   checking if it's more than a buggy warning needs time; and this:

"dma_sync_single_range(struct device *dev, dma_addr_t dma_handle,
                      unsigned long offset, size_t size,
                      enum dma_data_direction direction)

Does a partial sync, starting at offset and continuing for size.  You
must be careful to observe the cache alignment and width when doing
anything like this.  You must also be extra careful about accessing
memory you intend to sync partially." [Documentation/DMA-API.txt]

looks like even if implemented might be very tricky, especially if
untested.

Jarek P.
