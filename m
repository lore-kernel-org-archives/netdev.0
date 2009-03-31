From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [ANNOUNCE] New driver vxge for Neterion's X3100 series 10 GbEPCIe
 adapter
Date: Tue, 31 Mar 2009 10:50:08 -0700
Message-ID: <49D257D0.9050104@intel.com>
References: <1237018825.4966.412.camel@flash> <20090331061333.GA11240@yzhao-otc.sh.intel.com> <78C9135A3D2ECE4B8162EBDCE82CAD77051BEEA1@nekter>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Zhao, Yu" <yu.zhao@intel.com>,
	Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Leonid Grossman <Leonid.Grossman@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:39726 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752540AbZCaRuQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Mar 2009 13:50:16 -0400
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD77051BEEA1@nekter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Leonid Grossman wrote:
> Enabling SR IOV mode should be transparent to vxge driver - the driver
> has no SR IOV specific code, and we plan to use the same netdev driver
> in both Linux and DomU Linux guest. Also (an optional) Xen Dom0
> privileged vxge driver stays the same in Multi-function mode and SR IOV
> mode.
> 
> We will look at 82576 patches to understand the changes better, but (at
> least conceptually :-)) SR-IOV should not require "traditional PCI NIC
> driver" to change. Some new "knobs" for VF bandwidth allocation, etc.
> could be optionally added but these are applicable to multi-port or
> multi-function devices and not SR IOV specific.
> The main job of SR IOV support is arguably to translate (reduced) VF PCI
> config space to full "traditional" PCI space, so networking (or storage
> or any other subsystem) doesn't know the difference. 
> What networking resources are implemented behind SR IOV VF is a
> different question; in x3100 a VF has the same set of NIC resources as a
> legacy pci function, so a netdev driver can stay the same.
> 
> Please let us know if this addresses the comment - alternatively, we can
> start a different thread since current vxge driver submission doesn't
> claim SR IOV support. Once SR IOV is supported in the kernel, we will
> enable SR IOV in x3100 firmware and will test the driver in that mode. 

For the most part I think the bit you would be interested in is the 
"sysfs" patch, http://patchwork.kernel.org/patch/8066/, which is what I 
had used in the original implementation to enable the VFs.  I am going 
to push this to a module parameter similar to your max_config_dev.  The 
rest of the patches handle PF to VF communications and configuration 
which it sounds like is handled via firmware for your adapter.

Most of the changes you would probably need to make would be in 
vxge_probe/vxge_remove.  All you would end up needing to do is call 
pci_enable_sriov(pdev, max_config_dev - 1) on your physical function 
devices and then you would end up getting exactly as many VFs as you 
need.  The call should be safe since I am assuming your VFs don't 
implement their own SR-IOV capability structures.  The cleanup would be 
pretty strait forward as well since you would just need to call 
pci_disable_sriov in remove.

Thanks,

Alex





