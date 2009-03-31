From: Yu Zhao <yu.zhao@intel.com>
Subject: Re: [ANNOUNCE] New driver vxge for Neterion's X3100 series 10 GbE
	PCIe adapter
Date: Tue, 31 Mar 2009 14:13:33 +0800
Message-ID: <20090331061333.GA11240@yzhao-otc.sh.intel.com>
References: <1237018825.4966.412.camel@flash>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Ramkrishna Vepa <ram.vepa@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:44207 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756225AbZCaGMh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Mar 2009 02:12:37 -0400
Content-Disposition: inline
In-Reply-To: <1237018825.4966.412.camel@flash>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 14, 2009 at 04:20:26PM +0800, Ramkrishna Vepa wrote:
> This is a release of a new network driver, "vxge", for our latest PCIe based
> hardware - The X3100 10GbE Server/Storage Adapter. The X3100 ASIC supports 
> four modes of operation, configurable via firmware -
> 	Single function mode
> 	Multi function	mode
> 	SRIOV mode
> 	MRIOV mode
> 	
> The driver patches series will follow this email. This driver has undergone 
> significant testing for the past six months in all four modes of operation,
> and is very stable. We would appreciate the community review and comments
> on this driver.
> 	
> The modes, besides single function mode, are oriented towards Server
> I/O virtualization and/or I/O sharing (see PCI SIG SR IOV and MR IOV
> specs for reference), although they can be used on a single
> non-virtualized server as well for instance, to run workloads that would
> typically benefit from using separate network cards. In these scenarios,
> X3100 can replace large number of GbE NICs without any system or network
> changes (outside of L2 driver/hardware), while each physical NIC will be
> able run up to 10 GbE instead of 1 GbE.
> 
> A note on the different modes of operation -
> 
> Single-function mode: From Linux stack perspective, the adapter is a
> typical multi-queue 10GbE pci-e netdev interface (driven by the
> submitted vxge driver).
>  
> Multi-function mode: From Linux stack perspective, the adapter is a
> multi-function pci-e device where each function is a multi-queue pci-e
> netdev interface. This mode has some applications in native Linux
> environments, but it is primarily designed for use in hypervisors that
> do not yet support SR IOV pci-e extensions. In fact, the functionality
> in this mode is virtually identical to the SR IOV mode described below,
> except SR IOV support in Linux is not required/expected. 

Xen upstream already supports the SR-IOV, and the native Linux and KVM
will be supporting it too when 2.6.30 comes out.

Intel 82576 driver has been patched to enable the SR-IOV capability:
  http://patchwork.kernel.org/patch/8063/
  http://patchwork.kernel.org/patch/8064/
  http://patchwork.kernel.org/patch/8065/
  http://patchwork.kernel.org/patch/8066/
Thought one of these patches uses the sysfs interface to receive the NumVFs
from user space, which is deprecated, rest of them still clearly demonstrate
how to convert the traditional PCI NIC driver to the `Physical Function'
driver by using the SR-IOV API.

> 
> >From vxge driver perspective, each x3100 function is an independent NIC.
> The functions share 10GbE link and pci-e bus, but hardly anything else
> inside the ASIC. Features like independent hw reset, statistics,
> bandwidth/priority allocation and guarantees, etc. are supported. Also,
> typical L2 functions like LSO, interrupt moderation, etc are supported
> independently on each function.
> 
> In other words, direct hardware access with x3100 doesnctions for Direct Hardware
> 	Access to different Guests or Servers - while keeping traditional
> 	privileged operations (VLAN membership, etc) under privileged domain
> 	control.
>  
> SR IOV mode: Once BIOS and/or OS support SR IOV pci-e extensions, from
> Linux stack perspective the adapter will look like the multi-function
> mode in #2 above. vxge driver will still think that each x3100 function
> is an independent x3100 pci-e device.
>  
