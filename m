From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 8/10] cxgb3 - Unmap offload packets when they are freed.
Date: Wed, 31 Jan 2007 17:27:42 -0800
Message-ID: <45C1420E.7080701@chelsio.com>
References: <20070131034424.8651.4713.stgit@localhost.localdomain> <45C07275.9010501@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Divy Le Ray <None@chelsio.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com,
	David Miller <davem@davemloft.net>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161228AbXBAB2B@vger.kernel.org>
In-Reply-To: <45C07275.9010501@garzik.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Divy Le Ray wrote:
>> From: Divy Le Ray <divy@chelsio.com>
>>
>> Offload packets may be DMAed long after their SGE Tx descriptors are 
>> done
>> so they must remain mapped until they are freed rather than until their
>> descriptors are freed.  Unmap such packets through an skb destructor.
>>
>> Signed-off-by: Divy Le Ray <divy@chelsio.com>
>
> this is questionable and sounds like you are working around a bug.  I 
> can't think of another driver that uses skb destructors, and I could 
> have sworn that skb destructors were not for drivers to use anyway
It's not a bug work around.  The payload of RDMA packets is DMAd lazily, 
potentially well after the DMA descriptors themselves have been 
processed and released. On plaftorms w/ IOMMUs, the packets need to 
remain mapped in the IOMMU until their payload is fetched, at which time 
the Scatter/Gather Engine may or may not still have knowledge of those 
packets.  So the SGE maps them for the IOMMU, then sets up the 
destructor so they can be unmapped whenever they complete.  It's true 
that drivers don't typically set up destructors but the lazy DMA this 
device does is also uncommon.  Packets carrying these destructors are 
exchanged between the RDMA driver and the low-level driver and aren't 
visible to any parts of the stack that may have different expectations 
of destructors.  Using the destructor is the simplest, most convenient 
way to solve this problem.

Cheers,
Divy
