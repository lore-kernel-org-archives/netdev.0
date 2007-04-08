From: Avi Kivity <avi@qumranet.com>
Subject: Re: [kvm-devel] QEMU PIC indirection patch for in-kernel APIC work
Date: Sun, 08 Apr 2007 08:36:14 +0300
Message-ID: <46187F4E.1080807@qumranet.com>
References: <4613B438.60107@codemonkey.ws> <4613B89F.8090806@qumranet.com>
 <4613BC6B.1070708@codemonkey.ws> <4613BF07.50606@qumranet.com>
 <4613C993.9020405@codemonkey.ws> <4613CC01.1090500@qumranet.com>
 <4613CDB2.4000903@codemonkey.ws> <4613D001.3040606@qumranet.com>
 <20070404200112.GA6070@elte.hu> <4614098F.2030307@us.ibm.com>
 <20070404212103.GA19026@elte.hu>
 <1175728768.12230.593.camel@localhost.localdomain>
 <4614A294.3000607@qumranet.com>
 <1175821357.12230.642.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Ingo Molnar <mingo@elte.hu>, kvm-devel@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout4.012.net.il ([84.95.2.10]:21122 "EHLO mtaout4.012.net.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751821AbXDHFgR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Apr 2007 01:36:17 -0400
Received: from firebolt.argo.co.il ([80.178.163.252])
 by i_mtaout4.012.net.il (HyperSendmail v2004.12)
 with ESMTP id <0JG500FF3ZKFTDU0@i_mtaout4.012.net.il> for
 netdev@vger.kernel.org; Sun, 08 Apr 2007 08:36:15 +0300 (IDT)
In-reply-to: <1175821357.12230.642.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rusty Russell wrote:
> On Thu, 2007-04-05 at 10:17 +0300, Avi Kivity wrote:
>   
>> Rusty Russell wrote:
>>     
>>> You didn't quote Anthony's point about "it's more about there not being
>>> good enough userspace interfaces to do network IO."
>>>
>>> It's easier to write a kernel-space network driver, but it's not
>>> obviously the right thing to do until we can show that an efficient
>>> packet-level userspace interface isn't possible.  I don't think that's
>>> been done, and it would be interesting to try.
>>>   
>>>       
>> In the case of networking, the copyful interfaces on receive are driven 
>> by the hardware not knowing how to split the header from the data.  On 
>> transmit I agree, it could be made copyless from userspace (somthing 
>> like sendfilev, only not file oriented).
>>     
>
> Hi Avi,
>
> 	I don't think you've thought about this very hard.  The receive copy is
> completely independent with whether the packet is going to the guest via
> a kernel driver or via userspace, so not relevant.
>   

A packet received in the kernel cannot be made available to userspace in 
a safe manner without a copy, as it will not be aligned with page 
boundaries, so userspace cannot examine the packet until after one copy 
has occured.  After userspace has determined what to do with the packet, 
another copy must take place to get it there.

There's a counterexample, mmapped sockets, but that works only when all 
packets arriving on a card are exposed to the same process.  This is 
useful for tcpdump or for what you outline below but is hardly generic.

> 	And if all packets from the card are going to the guest, you can
> deliver directly.  Userspace or kernel, no difference.
>   

That is not the common case.  Nor is it true when there is a mismatch 
between the card's capabilties and guest expectations and constraints.  
For example, guest memory is not physically contiguous so a NIC that 
won't do scatter/gather will require bouncing (or an iommu, but that's 
not here yet).

> 	And we have a "sendfilev not file oriented": it's called "writev" 8)
>   

writev() cannot be made copyless for networking.  One needs an async 
interface so the kernel can complete the write after the NIC acks the 
dma transfer, or a kernel driver.

> 	An in-kernel driver can avoid system call overhead and page references.
> But a better tap device helps more than just KVM.
>   

I'll believe it when I see it.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

