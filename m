From: Avi Kivity <avi@qumranet.com>
Subject: Re: [kvm-devel] QEMU PIC indirection patch for in-kernel APIC work
Date: Tue, 10 Apr 2007 14:21:24 +0300
Message-ID: <461B7334.8090807@qumranet.com>
References: <1175728768.12230.593.camel@localhost.localdomain> <4614A294.3000607@qumranet.com> <1175821357.12230.642.camel@localhost.localdomain> <46187F4E.1080807@qumranet.com> <1176087018.11664.65.camel@localhost.localdomain> <4619E6DC.3010804@qumranet.com> <1176111984.11664.90.camel@localhost.localdomain> <461A41CA.9080201@qumranet.com> <20070410080729.GB16621@2ka.mipt.ru> <461B48A8.1060904@qumranet.com> <20070410085825.GA20004@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, Ingo Molnar <mingo@elte.hu>,
	kvm-devel@lists.sourceforge.net, netdev <netdev@vger.kernel.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from il.qumranet.com ([82.166.9.18]:36278 "EHLO il.qumranet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932179AbXDJLV1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2007 07:21:27 -0400
In-Reply-To: <20070410085825.GA20004@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
>>> But it looks from this discussion, that it will not prevent from
>>> changing in-kernel driver - place a hook into skb allocation path and
>>> allocate data from opposing memory - get pages from another side and put
>>> them into fragments, then copy headers into skb->data.
>>>   
>>>       
>> I don't understand this (opposing memory, another side?).  Can you
>> elaborate?
>>     
>
> You want to implement zero-copy network device between host and guest, if
> I understood this thread correctly?
> So, for sending part, device allocates pages from receiver's memory (or
> from shared memory), receiver gets an 'interrupt' and got pages from own
> memory, which are attached to new skb and transferred up to the network
> stack.
> It can be extended to use shared ring of pages.
>   

This is what Xen does.  It is actually less performant than copying, IIRC.

The problem with flipping pages around is that physical addresses are 
cached both in the kvm mmu and in the on-chip tlbs, necessitating 
expensive page table walks and tlb invalidation IPIs.

Note that for sending from the guest an external host can be done 
copylessly, and for the receive side using a dma engine (like I/OAT) can 
reduce the cost of the copy.

-- 
error compiling committee.c: too many arguments to function

