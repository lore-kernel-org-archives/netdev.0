From: "Neftin, Sasha" <sasha.neftin@intel.com>
Subject: Re: [net-next 5/5] PCI: disable FLR for 82579 device
Date: Sun, 25 Sep 2016 10:02:43 +0300
Message-ID: <176f2366-e225-75fb-8cad-909a8f7e808c@intel.com>
References: <1474612741-75681-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1474612741-75681-6-git-send-email-jeffrey.t.kirsher@intel.com>
 <20160923140136.GC1514@localhost> <1474664726.2389.7.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, bhelgaas@google.com, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Bjorn Helgaas <helgaas@kernel.org>, linux-pci@vger.kernel.org
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1474664726.2389.7.camel@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/24/2016 12:05 AM, Jeff Kirsher wrote:
> On Fri, 2016-09-23 at 09:01 -0500, Bjorn Helgaas wrote:
>> On Thu, Sep 22, 2016 at 11:39:01PM -0700, Jeff Kirsher wrote:
>>> From: Sasha Neftin <sasha.neftin@intel.com>
>>>
>>> 82579 has a problem reattaching itself after the device is detached.
>>> The bug was reported by Redhat. The suggested fix is to disable
>>> FLR capability in PCIe configuration space.
>>>
>>> Reproduction:
>>> Attach the device to a VM, then detach and try to attach again.
>>>
>>> Fix:
>>> Disable FLR capability to prevent the 82579 from hanging.
>> Is there a bugzilla or other reference URL to include here?  Should
>> this be marked for stable?
> So the author is in Israel, meaning it is their weekend now.  I do not
> believe Sasha monitors email over the weekend, so a response to your
> questions won't happen for a few days.
>
> I tried searching my archives for more information, but had no luck finding
> any additional information.
>
>>> Signed-off-by: Sasha Neftin <sasha.neftin@intel.com>
>>> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
>>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>>> ---
>>>   drivers/pci/quirks.c | 21 +++++++++++++++++++++
>>>   1 file changed, 21 insertions(+)
>>>
>>> diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
>>> index 44e0ff3..59fba6e 100644
>>> --- a/drivers/pci/quirks.c
>>> +++ b/drivers/pci/quirks.c
>>> @@ -4431,3 +4431,24 @@ static void quirk_intel_qat_vf_cap(struct
>>> pci_dev *pdev)
>>>   	}
>>>   }
>>>   DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_INTEL, 0x443,
>>> quirk_intel_qat_vf_cap);
>>> +/*
>>> + * Workaround FLR issues for 82579
>>> + * This code disables the FLR (Function Level Reset) via PCIe, in
>>> order
>>> + * to workaround a bug found while using device passthrough, where the
>>> + * interface would become non-responsive.
>>> + * NOTE: the FLR bit is Read/Write Once (RWO) in config space, so if
>>> + * the BIOS or kernel writes this register * then this workaround will
>>> + * not work.
>> This doesn't sound like a root cause.  Is the issue a hardware
>> erratum?  Linux PCI core bug?  VFIO bug?  Device firmware bug?
>>
>> The changelog suggests that the problem only affects passthrough,
>> which suggests some sort of kernel bug related to how passthrough is
>> implemented.
>>
>>> + */
>>> +static void quirk_intel_flr_cap_dis(struct pci_dev *dev)
>>> +{
>>> +	int pos = pci_find_capability(dev, PCI_CAP_ID_AF);
>>> +	if (pos) {
>>> +		u8 cap;
>>> +		pci_read_config_byte(dev, pos + PCI_AF_CAP, &cap);
>>> +		cap = cap & (~PCI_AF_CAP_FLR);
>>> +		pci_write_config_byte(dev, pos + PCI_AF_CAP, cap);
>>> +	}
>>> +}
>>> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_INTEL, 0x1502,
>>> quirk_intel_flr_cap_dis);
>>> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_INTEL, 0x1503,
>>> quirk_intel_flr_cap_dis);
>>> -- 
>>> 2.7.4
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-pci" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Hello,

Original bugzilla thread could be found here: 
https://bugzilla.redhat.com/show_bug.cgi?format=multiple&id=966840

This is our HW bug, exist only in 82579 devices. More new devices have 
no such problem. We have found root cause and suggested this solution. 
This solution should work for a 95% of cases, so I do not think that 
this is fragile. For another cases possible solution is get up working 
system and manually disable FLR, before VM start use our adapter.

Thanks,

Sasha
