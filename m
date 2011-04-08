From: Wei Gu <wei.gu@ericsson.com>
Subject: RE: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
Date: Fri, 8 Apr 2011 16:59:49 +0800
Message-ID: <D12839161ADD3A4B8DA63D1A134D084026E48BA58D@ESGSCCMS0001.eapac.ericsson.se>
References: <D12839161ADD3A4B8DA63D1A134D084026E48B9BEB@ESGSCCMS0001.eapac.ericsson.se>
	 <1302152327.2701.50.camel@edumazet-laptop>
	 <1302153412.2701.64.camel@edumazet-laptop>
	 <1302157012.2701.73.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48B9E82@ESGSCCMS0001.eapac.ericsson.se>
	 <1302163650.3357.8.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48B9F23@ESGSCCMS0001.eapac.ericsson.se>
	 <1302167168.3357.12.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA027@ESGSCCMS0001.eapac.ericsson.se>
	 <1302176811.3357.15.camel@edumazet-laptop>  <4D9DDF43.9080302@intel.com>
 <1302192218.3357.47.camel@edumazet-laptop> <4D9DE465.1080008@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:57755 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751745Ab1DHJAj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 05:00:39 -0400
In-Reply-To: <4D9DE465.1080008@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
On my configuration of Linux 2.6.38 we do enabled the CONFIG_DMAR
CONFIG_DMAR=3Dy
CONFIG_DMAR_DEFAULT_ON=3Dy
CONFIG_DMAR_FLOPPY_WA=3Dy
CONFIG_INTR_REMAP=3Dy

But I enabled this DMAR also by default of the RHEL6 2.6.32 kernel, whi=
ch we don't see this problem on this kernel. The only different I can s=
ee on the config is "CONFIG_DMAR_DEFAULT_ON"
CONFIG_DMAR=3Dy
# CONFIG_DMAR_DEFAULT_ON is not set
CONFIG_DMAR_FLOPPY_WA=3Dy
CONFIG_INTR_REMAP=3Dy

I could try the same configuration as 2.6.32 for the 2.6.38 kernel by u=
nset the CONFIG_DMAR_DEFAULT_ON. And run the test again, hopefully we c=
an get the test result next Monday:)

Thanks
WeiGu

-----Original Message-----
=46rom: Alexander Duyck [mailto:alexander.h.duyck@intel.com]
Sent: Friday, April 08, 2011 12:21 AM
To: Eric Dumazet
Cc: Wei Gu; netdev; Kirsher, Jeffrey T
Subject: Re: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel

On 4/7/2011 9:03 AM, Eric Dumazet wrote:
> Le jeudi 07 avril 2011 =E0 08:58 -0700, Alexander Duyck a =E9crit :
>> On 4/7/2011 4:46 AM, Eric Dumazet wrote:
>>> Le jeudi 07 avril 2011 =E0 19:15 +0800, Wei Gu a =E9crit :
>>>> Hi,
>>>> I compile the ixgbe driver into the kernel and run the test again
>>>> and also change the copy to clone in the fw hook This is the perf
>>>> report while I was forwarding 150Kpps with The attached file inclu=
de the basic info about my test system. Please let me know if I did som=
e thing wrong.
>>>>
>>>> +     71.91%          swapper  [kernel.kallsyms]            [k] po=
ll_idle
>>>> +     10.43%          swapper  [kernel.kallsyms]            [k] in=
tel_idle
>>>> -      8.00%     ksoftirqd/24  [kernel.kallsyms]            [k] _r=
aw_spin_unlock_irqrestore
>>>> \u2592   - _raw_spin_unlock_irqrestore
>>>> \u2592      - 42.25% alloc_iova
>>>> \u2592           intel_alloc_iova
>>>> \u2592           __intel_map_single
>>>> \u2592           intel_map_page
>>
>> I'm almost certain this is the issue here.  I am pretty sure the
>> intel_map_page call indicates that you are running with the Intel
>> IOMMU enabled.  As Eric suggested you can either rebuild your kernel
>> with "CONFIG_DMAR=3DN", or pass the kernel the parameter
>> "intel_iommu=3Doff" in order to disable it so that it will instead j=
ust use SWIOTLB.
>
> What's the purpose of intel_iommu ?
>
> Could this be speedup if ixgbe uses a perqueue iommu context instead
> of a per device, so that we dont hit a single spinlock ?

The intel_iommu is meant to be a security feature.  Primarily it is use=
d in virtualzation where it allows KVM or Xen to direct assign a device=
 without having to worry about the guest getting access to the hosts ph=
ysical memory by submitting invalid DMA requests.

If virtualzation isn't in use I would recommend turning it off as it ca=
n have a negative impact especially on small packet performance due to =
the extra locking overhead that is required for DMA map and unmap calls=
=2E

Thanks,

Alex

