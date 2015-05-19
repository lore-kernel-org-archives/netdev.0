From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [Intel-wired-lan] [PATCH] pci: Limit VPD reads for all Intel
 Ethernet devices
Date: Tue, 19 May 2015 10:50:29 -0700
Message-ID: <555B77E5.5060006@redhat.com>
References: <20150519000042.56109.69779.stgit@mdrustad-wks.jf.intel.com> <555B5CBF.1090902@redhat.com> <4AD84211-965C-4F0B-A7F4-3E6CCE6567E3@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "bhelgaas@google.com" <bhelgaas@google.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55010 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754452AbbESRuf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2015 13:50:35 -0400
In-Reply-To: <4AD84211-965C-4F0B-A7F4-3E6CCE6567E3@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 05/19/2015 09:19 AM, Rustad, Mark D wrote:
>> On May 19, 2015, at 8:54 AM, Alexander Duyck <alexander.h.duyck@redhat.com> wrote:
>>
>> On 05/18/2015 05:00 PM, Mark D Rustad wrote:
>>> To save boot time and some memory, limit VPD size to the maximum
>>> possible for all Intel Ethernet devices that have VPD, which is 1K.
>>>
>>> Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
>>> Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>>> ---
>>>   drivers/pci/quirks.c |    7 +++++--
>>>   1 file changed, 5 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
>>> index c6dc1dfd25d5..4fabbeda964a 100644
>>> --- a/drivers/pci/quirks.c
>>> +++ b/drivers/pci/quirks.c
>>> @@ -1903,12 +1903,15 @@ static void quirk_netmos(struct pci_dev *dev)
>>>   DECLARE_PCI_FIXUP_CLASS_HEADER(PCI_VENDOR_ID_NETMOS, PCI_ANY_ID,
>>>   			 PCI_CLASS_COMMUNICATION_SERIAL, 8, quirk_netmos);
>>>   -static void quirk_e100_interrupt(struct pci_dev *dev)
>>> +static void quirk_intel_enet(struct pci_dev *dev)
>>>   {
>>>   	u16 command, pmcsr;
>>>   	u8 __iomem *csr;
>>>   	u8 cmd_hi;
>>>   +	if (dev->vpd)
>>> +		dev->vpd->len = 0x400;
>>> +
>>>   	switch (dev->device) {
>>>   	/* PCI IDs taken from drivers/net/e100.c */
>>>   	case 0x1029:
>> I wasn't a fan of the first VPD patch and this clinches it.  What I would recommend doing is identifying all of the functions for a given device that share a VPD and then eliminate the VPD structure for all but the first function.  By doing that the OS should treat the other functions as though their VPD areas don't exist.
> Please, lets discuss only *this* patch in this thread. The patches are not related except that they both have to do with VPD.
>
> <snip>

These two patches are very much related.  The fact is you are 
implementing this due to "save boot time and memory" which implies that 
VPD accesses are very slow.  One good reason why VPD accesses might be 
slower is that accesses are now serialized per bus due to your earlier 
patch.  This likely means that other vendors will want to do the same 
thing which is why I would say that the first patch needs to be replaced.

>> Artificially limiting the size of the VPD does nothing but cut off possibly useful data, you would be better of providing all of the data on only the first function than providing only partial data on all functions and adding extra lock overhead.
> This limit only limits the maximum that the OS will read to what is architecturally possible in these devices. Yes, PCIe architecturally provides for the possibility of more, but these devices do not. More repeating data can be read, however slowly, but there is no possibility of useful content beyond the first 1K. If this limit were set to 0x100, which is more in line what the actual usage is, it would be an artificial limit, but at 1K it is not. Oh and it does include devices made by others that incorporate Intel Ethernet silicon, not just Intel-built devices.

As per section 3.4.4 of the X540 datasheet the upper addressable range 
for the VPD section is 0xFFF which means the upper limit for the 
hardware is 0x1000, not 0x400.

> Since this quirk function was already being run for every Intel Ethernet device, this seemed like a trivial thing to do to speed up booting a bit. It has the greatest effect with 82599 devices. Newer devices will respond to reads faster.

This is run for EVERY Intel Ethernet device.  Not just some of the 1G or 
10G server parts, everything.  This presents a very wide net and is 
highly likely to introduce some sort of regression.  This includes every 
3rd party part out there based on Intel silicon and messing with 
something like this is kind of a big issue.  That is why I say you are 
better off limiting the VPD access to 1 function instead of allowing 
only partial access from any Intel Ethernet function.

The fact is VPD is not vital.  It is simply product data for inventory 
tracking and the like.  You are much better off simply limiting this to 
one function for your parts since all of the Intel Ethernet silicon 
implements on VPD which is shared between all functions in a device.

- Alex
