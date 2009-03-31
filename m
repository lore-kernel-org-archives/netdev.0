From: "Leonid Grossman" <Leonid.Grossman@neterion.com>
Subject: RE: [ANNOUNCE] New driver vxge for Neterion's X3100 series 10 GbEPCIe adapter
Date: Tue, 31 Mar 2009 10:38:41 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77051BEEA1@nekter>
References: <1237018825.4966.412.camel@flash> <20090331061333.GA11240@yzhao-otc.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Netdev" <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>
To: "Yu Zhao" <yu.zhao@intel.com>,
	"Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:46522 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760762AbZCaO4w convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 10:56:52 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20090331061333.GA11240@yzhao-otc.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org
[mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Yu Zhao
> Sent: Monday, March 30, 2009 11:14 PM
> To: Ramkrishna Vepa
> Cc: Netdev; David Miller
> Subject: Re: [ANNOUNCE] New driver vxge for Neterion's X3100 series 10
> GbEPCIe adapter
> 
> On Sat, Mar 14, 2009 at 04:20:26PM +0800, Ramkrishna Vepa wrote:
> > This is a release of a new network driver, "vxge", for our latest
PCIe
> based
> > hardware - The X3100 10GbE Server/Storage Adapter. The X3100 ASIC
> supports
> > four modes of operation, configurable via firmware -
> > 	Single function mode
> > 	Multi function	mode
> > 	SRIOV mode
> > 	MRIOV mode
> >
> > The driver patches series will follow this email. This driver has
> undergone
> > significant testing for the past six months in all four modes of
> operation,
> > and is very stable. We would appreciate the community review and
> comments
> > on this driver.
> >
> > The modes, besides single function mode, are oriented towards Server
> > I/O virtualization and/or I/O sharing (see PCI SIG SR IOV and MR IOV
> > specs for reference), although they can be used on a single
> > non-virtualized server as well for instance, to run workloads that
would
> > typically benefit from using separate network cards. In these
scenarios,
> > X3100 can replace large number of GbE NICs without any system or
network
> > changes (outside of L2 driver/hardware), while each physical NIC
will be
> > able run up to 10 GbE instead of 1 GbE.
> >
> > A note on the different modes of operation -
> >
> > Single-function mode: From Linux stack perspective, the adapter is a
> > typical multi-queue 10GbE pci-e netdev interface (driven by the
> > submitted vxge driver).
> >
> > Multi-function mode: From Linux stack perspective, the adapter is a
> > multi-function pci-e device where each function is a multi-queue
pci-e
> > netdev interface. This mode has some applications in native Linux
> > environments, but it is primarily designed for use in hypervisors
that
> > do not yet support SR IOV pci-e extensions. In fact, the
functionality
> > in this mode is virtually identical to the SR IOV mode described
below,
> > except SR IOV support in Linux is not required/expected.
> 
> Xen upstream already supports the SR-IOV, and the native Linux and KVM
> will be supporting it too when 2.6.30 comes out.
> 
> Intel 82576 driver has been patched to enable the SR-IOV capability:
>   http://patchwork.kernel.org/patch/8063/
>   http://patchwork.kernel.org/patch/8064/
>   http://patchwork.kernel.org/patch/8065/
>   http://patchwork.kernel.org/patch/8066/
> Thought one of these patches uses the sysfs interface to receive the
> NumVFs
> from user space, which is deprecated, rest of them still clearly
> demonstrate
> how to convert the traditional PCI NIC driver to the `Physical
Function'
> driver by using the SR-IOV API.

Agreed - once SR-IOV support ships in Linux and Xen, using X3100
Multi-function mode becomes optional and the device can/will be used in
SR IOV mode. In other hypervisors, transition to SR IOV will take longer
time and Multi-function mode will be used for a while.

Enabling SR IOV mode should be transparent to vxge driver - the driver
has no SR IOV specific code, and we plan to use the same netdev driver
in both Linux and DomU Linux guest. Also (an optional) Xen Dom0
privileged vxge driver stays the same in Multi-function mode and SR IOV
mode.

We will look at 82576 patches to understand the changes better, but (at
least conceptually :-)) SR-IOV should not require "traditional PCI NIC
driver" to change. Some new "knobs" for VF bandwidth allocation, etc.
could be optionally added but these are applicable to multi-port or
multi-function devices and not SR IOV specific.
The main job of SR IOV support is arguably to translate (reduced) VF PCI
config space to full "traditional" PCI space, so networking (or storage
or any other subsystem) doesn't know the difference. 
What networking resources are implemented behind SR IOV VF is a
different question; in x3100 a VF has the same set of NIC resources as a
legacy pci function, so a netdev driver can stay the same.

Please let us know if this addresses the comment - alternatively, we can
start a different thread since current vxge driver submission doesn't
claim SR IOV support. Once SR IOV is supported in the kernel, we will
enable SR IOV in x3100 firmware and will test the driver in that mode. 

> 
> >
> > >From vxge driver perspective, each x3100 function is an independent
NIC.
> > The functions share 10GbE link and pci-e bus, but hardly anything
else
> > inside the ASIC. Features like independent hw reset, statistics,
> > bandwidth/priority allocation and guarantees, etc. are supported.
Also,
> > typical L2 functions like LSO, interrupt moderation, etc are
supported
> > independently on each function.
> >
> > In other words, direct hardware access with x3100 doesnctions for
Direct
> Hardware
> > 	Access to different Guests or Servers - while keeping
traditional
> > 	privileged operations (VLAN membership, etc) under privileged
domain
> > 	control.
> >
> > SR IOV mode: Once BIOS and/or OS support SR IOV pci-e extensions,
from
> > Linux stack perspective the adapter will look like the
multi-function
> > mode in #2 above. vxge driver will still think that each x3100
function
> > is an independent x3100 pci-e device.
> >
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
