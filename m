From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Don't call request_region() for 3C90x chips
Date: Wed, 19 Jul 2006 15:22:02 -0400
Message-ID: <44BE865A.6060307@pobox.com>
References: <200607102225.49253.sshtylyov@ru.mvista.com> <44BE7291.2080306@pobox.com> <44BE8324.2060103@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:29320 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1030227AbWGSTWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2006 15:22:05 -0400
To: Sergei Shtylyov <sshtylyov@ru.mvista.com>
In-Reply-To: <44BE8324.2060103@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sergei Shtylyov wrote:
> Hello.
> 
> Jeff Garzik wrote:
> 
>>> It's generally not a good idea to call request_region() on an address 
>>> returned by pci_iomap(), even less so on a MMIO address. And there 
>>> was absolutely no point in claiming the region already claimed by the 
>>> PCI core, especially with the same PCI generic owner's name. As this 
>>> is the only case of the must_free_region flag being set, this flag 
>>> may go away as well...
> 
>>> Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>
> 
>> I agree you have identified a bug, but this is not a solution.
> 
>> The current driver bug is that it calls request_region() potentially 
>> on an MMIO address, but the solution is _not_ to completely avoid 
>> reserving the resource.
> 
>    It's not even a MMIO/PIO address anymore after pci_iomap() -- it 
> either went thru ioremap() or ioport_map() which both change the mapping 
> from the physical to the virtual address (or some equivalent of it for 
> I/O ports).

Yes.  _Obviously_ you must reserve the resource passed to 
pci_iomap/ioremap, not the cookie returned by such.


>> The region registered with the PCI core, but _not_ claimed by anyone. 
>> Someone still needs to either call pci_{request,release}_regions() or 
>> request_[mem_]region() to indicate that the resource is reserved.
> 
>    Sigh, it seems I've missed that difference. So, I'll recast...

IMO it would be easiest to do pci_{request,release}_regions() in the 
PCI-only code.  I believe this matches up well with the existing 
EISA-specific code, which also performs request_region().

	Jeff


