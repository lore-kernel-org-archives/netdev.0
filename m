From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH v2 1/2] net: af_packet support for direct ring access
 in user space
Date: Sat, 17 Jan 2015 09:35:44 -0800
Message-ID: <54BA9D70.50403@gmail.com>
References: <20150113043509.29985.33515.stgit@nitbit.x32> <20150114.153509.1264618607573705890.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, danny.zhou@intel.com,
	nhorman@tuxdriver.com, dborkman@redhat.com, john.ronciak@intel.com,
	hannes@stressinduktion.org, brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:43749 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751399AbbAQRgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jan 2015 12:36:00 -0500
Received: by mail-oi0-f46.google.com with SMTP id z81so207780oif.5
        for <netdev@vger.kernel.org>; Sat, 17 Jan 2015 09:36:00 -0800 (PST)
In-Reply-To: <20150114.153509.1264618607573705890.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/14/2015 12:35 PM, David Miller wrote:
> From: John Fastabend <john.fastabend@gmail.com>
> Date: Mon, 12 Jan 2015 20:35:11 -0800
>
>> +		if ((region.direction != DMA_BIDIRECTIONAL) &&
>> +		    (region.direction != DMA_TO_DEVICE) &&
>> +		    (region.direction != DMA_FROM_DEVICE))
>> +			return -EFAULT;
>   ...
>> +		if ((umem->nmap == npages) &&
>> +		    (0 != dma_map_sg(dev->dev.parent, umem->sglist,
>> +				     umem->nmap, region.direction))) {
>> +			region.iova = sg_dma_address(umem->sglist) + offset;
>
> I am having trouble seeing how this can work.
>
> dma_map_{single,sg}() mappings need synchronization after a DMA
> transfer takes place.
>
> For example if the DMA occurs to the device, then that region can
> be cached in the PCI controller's internal caches and thus future
> cpu writes into that memory region will not be seen, until a
> dma_sync_*() is invoked.
>
> That isn't going to happen when the device transmit queue is
> being completely managed in userspace.
>
> And this takes us back to the issue of protection, I don't think
> it is addressed properly yet.
>
> CAP_NET_ADMIN privileges do not mean "can crap all over memory"
> yet with this feature that can still happen.
>
> If we are dealing with a device which cannot provide strict protection
> to only the process's locked local pages, you have to do something
> to implement that protection.
>
> And you have _exactly_ one option to do that, abstracting the page
> addresses and eating a system call to trigger the sends, so that you
> can read from the user's (fake) descriptors and write into the real
> descriptors (translating the DMA addresses along the way) and
> triggering the TX doorbell.

OK, I think this brings us back to some of the original designs/ideas
we were thinking about with Daniel/Neil. We are going to take a look
at this. At least on the RX side we can have the af_packet logic give
us a set of DMA addresses'. I wonder if we can also make the busy
poll logic per queue and use it.

>
> I am not going to consider seriously an implementation that says "yeah
> sometimes the user can crap onto other people's memory", this isn't
> MS-DOS, it's a system where proper memory protections are mandatory
> rather than optional.
>

More to sort out on our side. Thanks for looking at the patches.

.John

-- 
John Fastabend         Intel Corporation
