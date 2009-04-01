From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [ANNOUNCE] New driver vxge for Neterion's X3100 series10GbEPCIe
	adapter
Date: Tue, 31 Mar 2009 23:14:00 -0700
Message-ID: <5f2db9d90903312314r67693f38ydfd1173b517dde47@mail.gmail.com>
References: <1237018825.4966.412.camel@flash>
	 <20090331061333.GA11240@yzhao-otc.sh.intel.com>
	 <78C9135A3D2ECE4B8162EBDCE82CAD77051BEEA1@nekter>
	 <49D257D0.9050104@intel.com>
	 <78C9135A3D2ECE4B8162EBDCE82CAD77051BF027@nekter>
	 <20090401025327.GA11687@yzhao-otc.sh.intel.com>
	 <78C9135A3D2ECE4B8162EBDCE82CAD77051BF03C@nekter>
	 <20090401050940.GB11687@yzhao-otc.sh.intel.com>
	 <78C9135A3D2ECE4B8162EBDCE82CAD77051BF05A@nekter>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Yu Zhao <yu.zhao@intel.com>,
	Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Leonid Grossman <Leonid.Grossman@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:39252 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752439AbZDAGOC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 02:14:02 -0400
Received: by yx-out-2324.google.com with SMTP id 31so2808625yxl.1
        for <netdev@vger.kernel.org>; Tue, 31 Mar 2009 23:14:00 -0700 (PDT)
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD77051BF05A@nekter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 31, 2009 at 10:44 PM, Leonid Grossman
<Leonid.Grossman@neterion.com> wrote:
>
>
>> -----Original Message-----
>> From: Yu Zhao [mailto:yu.zhao@intel.com]
>> Sent: Tuesday, March 31, 2009 10:10 PM
>> To: Ramkrishna Vepa
>> Cc: Duyck, Alexander H; Leonid Grossman; Netdev; David Miller
>> Subject: Re: [ANNOUNCE] New driver vxge for Neterion's X3100
>> series10GbEPCIe adapter
>>
>> On Wed, Apr 01, 2009 at 11:36:11AM +0800, Ramkrishna Vepa wrote:
>> > > Yes, and that's what the PCI subsystem does. If the vxge VF is
>> > identical
>> > > to its PF, then vxge should be able to drive both PF and VF
> without
>> > any
>> > > modification.
>> > [Ram] Ok. In that case, is the call to pci_enable/disable_sriov
> still
>> > required for vxge?
>>
>> Yes, the vxge driver first binds the PF once it's loaded (VF doesn't
>> exist at this time) and calls the SR-IOV API. The VF appears after the
>> SR-IOV is enabled and then the same copy of the vxge driver can bind
>> the VF too if you want to use the VF in the native Linux. Though the
>> hardware is in the SR-IOV mode in this case, it would be equal to the
>> multi-function mode. Or you can assign the VF to the Xen/KVM guest and
>> let another copy of vxge driver (may be vxge for Windows, Solaris,
> BSD,
>> etc.) running in the guest bind it.
>
> Yu, could you pl. explain why this call is not optional - SR-IOV pci-e
> code should be able to find SR-IOV capable device and enable all VFs
> based upon pci-e config space alone, without any help from
> device-specific PF driver.
> Once VFs appear, vxge or any other native netdev driver should be able
> to bind a VF regardless of PF driver being loaded first (or at all) -
> there are some use cases that do not assume PF driver presence...
> Thanks, Leonid

The fact is not all drivers will want to enable all of the VFs just
because they can.  I know in the case of igb I actually prefer to have
the default as not enabling all the VFs because as soon as we do the
PF itself is no longer multiqueue capable due to the fact that the
resources are distributed between the PF and the VFs.

The actual calls themselves are fairly small in terms of enabling
things.  The pci_enable_sriov call will check before hand if the PCI
Config space for SR-IOV exists so it is safe to call in either the VFs
or on the PF.  Also from our testing internally we prefer to limit the
number of VFs allocated to just what is needed since we have seen it
can be difficult to sort out PFs and VFs because they can be allocated
in such a way that you have to go through with ethtool -i to identify
the pci bus/device/function in order to even figure out which port any
given interface belongs to.
