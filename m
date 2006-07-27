From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: Re: [PATCH] Don't call request_region() for 3C90x chips
Date: Thu, 27 Jul 2006 23:22:06 +0400
Message-ID: <44C9125E.8030404@ru.mvista.com>
References: <200607102225.49253.sshtylyov@ru.mvista.com> <44BE7291.2080306@pobox.com> <44BE8324.2060103@ru.mvista.com> <44BE865A.6060307@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.155]:34723 "EHLO
	imap.sh.mvista.com") by vger.kernel.org with ESMTP id S1751868AbWG0TXU
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 15:23:20 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <44BE865A.6060307@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Jeff Garzik wrote:

>>>> It's generally not a good idea to call request_region() on an 
>>>> address returned by pci_iomap(), even less so on a MMIO address. And 
>>>> there was absolutely no point in claiming the region already claimed 
>>>> by the PCI core, especially with the same PCI generic owner's name. 
>>>> As this is the only case of the must_free_region flag being set, 
>>>> this flag may go away as well...

>>>> Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

>>> I agree you have identified a bug, but this is not a solution.

>>> The current driver bug is that it calls request_region() potentially 
>>> on an MMIO address, but the solution is _not_ to completely avoid 
>>> reserving the resource.

>>    It's not even a MMIO/PIO address anymore after pci_iomap() -- it 
>> either went thru ioremap() or ioport_map() which both change the 
>> mapping from the physical to the virtual address (or some equivalent 
>> of it for I/O ports).

> Yes.  _Obviously_ you must reserve the resource passed to 
> pci_iomap/ioremap, not the cookie returned by such.

    What somewhat puzzled me is the words "Cardbus drivers already allocate 
for us" in the current driver's vortex_probe1(). What extra drivers, and why 
should they call request_region() for us? :-/

>>> The region registered with the PCI core, but _not_ claimed by anyone. 
>>> Someone still needs to either call pci_{request,release}_regions() or 
>>> request_[mem_]region() to indicate that the resource is reserved.

>>    Sigh, it seems I've missed that difference. So, I'll recast...

> IMO it would be easiest to do pci_{request,release}_regions() in the 
> PCI-only code.  I believe this matches up well with the existing 
> EISA-specific code, which also performs request_region().

    Ugh, I've looked at vortex_remove_one() and found another buglet: they're 
trying to reset the chip there... after calling pci_disable_device(). Guess 
whether they really reset anything. I wonder whether it's accpetable for this 
fix to be put in the same patch...

>     Jeff

WBR, Sergei
