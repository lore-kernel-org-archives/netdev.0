From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH net-next 1/4] via-rhine: commit receive buffer address
 before descriptor status update.
Date: Tue, 07 Apr 2015 14:19:03 -0700
Message-ID: <552449C7.9080804@redhat.com>
References: <cover.1428340371.git.romieu@fr.zoreil.com> <cover.1428340371.git.romieu@fr.zoreil.com> <87c90b27962c818239073d3a65341054922bd563.1428340371.git.romieu@fr.zoreil.com> <20150407.155209.47396464487922345.davem@davemloft.net> <20150407210248.GC24631@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nix@esperi.org.uk, rl@hellgate.ch,
	gurligebis@gentoo.org
To: Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33271 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751548AbbDGVTN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Apr 2015 17:19:13 -0400
In-Reply-To: <20150407210248.GC24631@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 04/07/2015 02:02 PM, Francois Romieu wrote:
> David Miller <davem@davemloft.net> :
>> From: Francois Romieu <romieu@fr.zoreil.com>
> [...]
>>> @@ -2063,6 +2063,7 @@ static int rhine_rx(struct net_device *dev, int limit)
>>>   				break;
>>>   			}
>>>   			rp->rx_ring[entry].addr = cpu_to_le32(rp->rx_skbuff_dma[entry]);
>>> +			wmb();
>> dma_wmb() perhaps?  I think this is exactly the situation that interface was
>> added for.
> I need the buffer address to be written in the receive descriptor before
> the descriptor status is. The cpu does W1, W2 and the nic mustn't see W2, W1.

That is the point of the dma_wmb().  If you are writing both W1 and W2 
to system memory then dma_wmb should be enough, if W1 is system memory 
and W2 is device memory (MMIO) then you need wmb().

You can think of dma_wmb as being something similar to smp_wmb w/o the 
SMP processor requirement.  On architectures that are strong ordered 
such as most x86 the wmb() translates to a barrier.  On other 
architectures it is something usually a little lighter than a full wmb() 
so for example on PowerPC wmb is sync() while dma_wmb() is lwsync().

- Alex
