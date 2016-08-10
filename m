From: Hannes Reinecke <hare@suse.de>
Subject: Re: [PATCHv2 3/4] pci: Determine actual VPD size on first access
Date: Wed, 10 Aug 2016 08:23:26 +0200
Message-ID: <307b33c6-786e-f910-c456-fda94e8fdb98@suse.de>
References: <1452684335-46107-1-git-send-email-hare@suse.de>
 <1452684335-46107-4-git-send-email-hare@suse.de>
 <20160209210458.GB32530@localhost>
 <bc3c39b1-cbff-99a5-8fe7-9add14f2c6f5@ozlabs.ru>
 <CAKgT0Udm0a08v34zU11ckjk4DCq2uxjPxmhLmgiKozY676Hruw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Bjorn Helgaas <helgaas@kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Babu Moger <babu.moger@oracle.com>,
	Paul Mackerras <paulus@samba.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	santosh@chelsio.com, Netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>,
	Alexey Kardashevskiy <aik@ozlabs.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKgT0Udm0a08v34zU11ckjk4DCq2uxjPxmhLmgiKozY676Hruw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/09/2016 08:12 PM, Alexander Duyck wrote:
> On Tue, Aug 9, 2016 at 5:54 AM, Alexey Kardashevskiy <aik@ozlabs.ru> wrote:
>> On 10/02/16 08:04, Bjorn Helgaas wrote:
>>> On Wed, Jan 13, 2016 at 12:25:34PM +0100, Hannes Reinecke wrote:
>>>> PCI-2.2 VPD entries have a maximum size of 32k, but might actually
>>>> be smaller than that. To figure out the actual size one has to read
>>>> the VPD area until the 'end marker' is reached.
>>>> Trying to read VPD data beyond that marker results in 'interesting'
>>>> effects, from simple read errors to crashing the card. And to make
>>>> matters worse not every PCI card implements this properly, leaving
>>>> us with no 'end' marker or even completely invalid data.
>>>> This path tries to determine the size of the VPD data.
>>>> If no valid data can be read an I/O error will be returned when
>>>> reading the sysfs attribute.
>>
>>
>> I have a problem with this particular feature as today VFIO uses this
>> pci_vpd_xxxx API to virtualize access to VPD and the existing code assumes
>> there is just one VPD block with 0x2 start and 0xf end. However I have at
>> least one device where this is not true - "10 Gigabit Ethernet-SR PCI
>> Express Adapter" - it has 2 blocks (made a script to read/parse it as
>> /sys/bus/pci/devices/0001\:03\:00.0/vpd shows it wrong):
> 
> The PCI spec is what essentially assumes that there is only one block.
> If I am not mistaken in the case of this device the second block here
> actually contains device configuration data, not actual VPD data.  The
> issue here is that the second block is being accessed as VPD when it
> isn't.
> 
>> #0000 Large item 42 bytes; name 0x2 Identifier String
>> #002d Large item 74 bytes; name 0x10
>> #007a Small item 1 bytes; name 0xf End Tag
>> ---
>> #0c00 Large item 16 bytes; name 0x2 Identifier String
>> #0c13 Large item 234 bytes; name 0x10
>> #0d00 Large item 252 bytes; name 0x11
>> #0dff Small item 0 bytes; name 0xf End Tag
> 
> The second block here is driver proprietary setup bits.
> 
>> The cxgb3 driver is reading the second bit starting from 0xc00 but since
>> the size is wrongly detected as 0x7c, VFIO blocks access beyond it and the
>> guest driver fails to probe.
>>
>> I also cannot find a clause in the PCI 3.0 spec saying that there must be
>> just a single block, is it there?
> 
> The problem is we need to be able to parse it.  The spec defines a
> series of tags that can be used starting at offset 0.  That is how we
> are supposed to get around through the VPD data.  The problem is we
> can't have more than one end tag and what appears to be happening here
> is that we are defining a second block of data which uses the same
> formatting as VPD but is not VPD.
> 
>> What would the correct fix be? Scanning all 32k of VPD is not an option I
>> suppose as this is what this patch is trying to avoid. Thanks.
> 
> I adding the current cxgb3 maintainer and netdev list to the Cc.  This
> is something that can probably be addressed via a PCI quirk as what
> needs to happen is that we need to extend the VPD in the case of this
> part in order to include this second block.  As long as we can read
> the VPD data all the way out to 0xdff odds are we could probably just
> have the size arbitrarily increased to 0xe00 via the quirk and then
> you would be able to access all of the VPD for the device.  We already
> have code making other modifications to drivers/pci/quirks.c for
> several Broadcom devices and probably just need something similar to
> allow extended access in the case of these devices.
> 
Yes, that's what I think, too.
The Broadcom quirk should work here, too.
(Didn't we do that already?)

Cheers,

Hannes
-- 
Dr. Hannes Reinecke		   Teamlead Storage & Networking
hare@suse.de			               +49 911 74053 688
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nürnberg
GF: F. Imendörffer, J. Smithard, J. Guild, D. Upmanyu, G. Norton
HRB 21284 (AG Nürnberg)
