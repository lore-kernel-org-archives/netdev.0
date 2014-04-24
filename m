From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [PATCH] pci: Use designated initialization in PCI_VDEVICE
Date: Thu, 24 Apr 2014 23:15:35 +0000
Message-ID: <512BF6D5-D529-4605-B1AB-A6DB7D153E14@intel.com>
References: <1396303119-16766-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <5339E746.4030503@cogentembedded.com> <20140424212246.GG29593@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Bjorn Helgaas <bhelgaas@google.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20140424212246.GG29593@google.com>
Content-Language: en-US
Content-ID: <89A1BF9C9D1FAE4B857B7BC06D63E969@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bjorn, Sergei,

On Apr 24, 2014, at 2:22 PM, Bjorn Helgaas <bhelgaas@google.com> wrote:

> On Tue, Apr 01, 2014 at 02:08:06AM +0400, Sergei Shtylyov wrote:
>> Hello.
>> 
>> On 04/01/2014 01:58 AM, Jeff Kirsher wrote:
>> 
>>> From: Mark Rustad <mark.d.rustad@intel.com>
>> 
>>> By using designated initialization in PCI_VDEVICE, like other
>>> similar macros, many "missing initializer" warnings that appear
>>> when compiling with W=2 can be silenced.
>> 
>>> Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
>>> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
>>> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
>>> Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
>>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>>> ---
>>> include/linux/pci.h | 10 +++++-----
>>> 1 file changed, 5 insertions(+), 5 deletions(-)
>> 
>>> diff --git a/include/linux/pci.h b/include/linux/pci.h
>>> index fb57c89..49455f9 100644
>>> --- a/include/linux/pci.h
>>> +++ b/include/linux/pci.h
>> [...]
>>> @@ -689,9 +689,9 @@ struct pci_driver {
>>>  * private data.
>>>  */
>>> 
>>> -#define PCI_VDEVICE(vendor, device)		\
>>> -	PCI_VENDOR_ID_##vendor, (device),	\
>>> -	PCI_ANY_ID, PCI_ANY_ID, 0, 0
>>> +#define PCI_VDEVICE(vend, dev) \
>>> +	.vendor = PCI_VENDOR_ID_##vend, .device = (dev), \
>>> +	.subvendor = PCI_ANY_ID, .subdevice = PCI_ANY_ID, 0, 0
>> 
>>   Initializing the fields to 0 is pointless, as 0 is what should be
>> put into them anyway by the compiler. Also, it doesn't look right
>> when you mix designated and anonymous initializers.

The zeros can't be dropped because the macro needs to initialize the same number of fields as the previous macro. Callers of this macro do use undesignated initialization and will rely on how that aligns. This macro does that.

> I'm certainly willing to apply this, but I can't reproduce the benefit.  I
> tried "make W=2 drivers/net/ethernet/intel/e1000e/netdev.o" and didn't see
> any change before and after this patch (I'm using Ubuntu gcc 4.6.3 if it
> matters).

The ixgbe driver throws a lot of warnings because it does not provide the final field after the macro call, allowing it default to zero. I think I saw a few other instances around the kernel, but the largest number are in ixgbe.

> What am I missing?  And do we need the zeroes?

If you build ixgbe with W=2, I think you'll see the noise. And the zeros are needed for the reason given above. The zeros could also be moved to designated initialization, but the C standard is pretty clear on how it works, and many callers of the macro will be using undesignated initialization for the final field anyway. That is, with the new macro, many initializations will effectively have a mixed form. If that really bothers you, then I guess you should drop the patch. I was just trying to silence a bunch of noise in a simple, direct way. Adding the missing field in all of those places would also silence the message, but it seemed reasonable to have require that.

-- 
Mark Rustad, Networking Division, Intel Corporation
