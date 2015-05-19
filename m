From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [Intel-wired-lan] [PATCH] pci: Use a bus-global mutex to protect
 VPD operations
Date: Tue, 19 May 2015 13:58:24 -0700
Message-ID: <555BA3F0.5030001@redhat.com>
References: <20150519000037.56109.68356.stgit@mdrustad-wks.jf.intel.com> <555B78F7.60908@redhat.com> <E9012788-257F-4C44-B7F1-789B94423924@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "bhelgaas@google.com" <bhelgaas@google.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <E9012788-257F-4C44-B7F1-789B94423924@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 05/19/2015 11:28 AM, Rustad, Mark D wrote:
>> On May 19, 2015, at 10:55 AM, Alexander Duyck <alexander.h.duyck@redhat.com> wrote:
>>
>> On 05/18/2015 05:00 PM, Mark D Rustad wrote:
>>> Some devices have a problem with concurrent VPD access to different
>>> functions of the same physical device, so move the protecting mutex
>>> from the pci_vpd structure to the pci_bus structure. There are a
>>> number of reports on support sites for a variety of devices from
>>> various vendors getting the "vpd r/w failed" message. This is likely
>>> to at least fix some of them. Thanks to Shannon Nelson for helping
>>> to come up with this approach.
>>>
>>> Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
>>> Acked-by: Shannon Nelson <shannon.nelson@intel.com>
>>> Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> Instead of moving the mutex lock around you would be much better served by simply removing the duplicate VPD entries for a given device in a PCIe quirk.  Then you can save yourself the extra pain and effort of having to deal with serialized VPD accesses for a multifunction device.
>>
>> The logic for the quirk should be fairly simple.
>>   1.  Scan for any other devices with VPD that share the same bus and device number.
>>   2.  If bdf is equal to us keep searching.
>>   3.  If bdf is less than our bdf we release our VPD area and set VPD pointer to NULL.
> I could do that. If this issue only affected Intel devices, I would be more inclined to consider something like that. I am avoiding discussing other vendors directly, so please go and do a Google search on "vpd r/w failed" and see if you really want to quirk all those devices. It isn't just Intel and it isn't just networking.

I think you are assuming too much.  Have you root caused the other 
devices?  All the "vpd r/w failed" means is that a given read or write 
timed out.  There are any number of possible reasons for that including 
VPD being unimplemented in firmware, a device falling off of the bus, 
and many others.  What you have is a common symptom, it doesn't mean it 
is a common ailment for all the other parts.

> If after doing that you still feel that this isn't the best solution, I can go and cook up something much bigger (I already had two much bigger patches that I abandoned in favor of this approach). Bear in mind that the quirk code is dead weight in all the kernels.

The quirk code is there to deal with buggy hardware implementations and 
that is what it sounds like you have in this case.  I highly doubt all 
of the other vendors implemented the same mistake.  If they did then 
maybe you should implement a the quirk as a new function that can be 
used by any of the devices that implement VPD with the same limitation.

> As you said in another message, VPD is not that vital. Given that, I would think that some possible needless synchronization that resolves real problems for many devices should be acceptable. If it was synchronizing all config space or something that would be different, but this is just VPD.

The problem is it is needless synchronization, and it only resolves 
problems for some very specific devices.  The extra overhead for 
serializing what is already slow accesses can be very high so I am 
against it.  For example it will likely have unintended consequences on 
things like virtual machines where all direct assigned devices end up on 
the same bus.

We know that all Intel Ethernet parts to date only implement one VPD 
area per EEPROM, and that all functions in a multi-function Ethernet 
part share the same EEPROM, so the fix is to only present one VPD area 
so that the data is still there, without the ability of multiple 
access.  It seems like function 0 would be the obvious choice in that 
case so if somebody wants to be able to do their inventory they can go 
through and pull inventory information from function 0.  Really this is 
how this should have probably been implemented in the hardware in the 
first place if they couldn't support multiple accesses.

- Alex
