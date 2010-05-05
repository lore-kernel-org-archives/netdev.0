From: Pankaj Thakkar <pthakkar@vmware.com>
Subject: Re: RFC: Network Plugin Architecture (NPA) for vmxnet3
Date: Wed, 5 May 2010 12:00:54 -0700
Message-ID: <20100505190054.GU8323@vmware.com>
References: <20100504230225.GP8323@vmware.com>
 <20100505005852.GA28034@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>
To: Chris Wright <chrisw@sous-sol.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.115.85.69]:35028 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751143Ab0EETAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 15:00:55 -0400
Content-Disposition: inline
In-Reply-To: <20100505005852.GA28034@sequoia.sous-sol.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 04, 2010 at 05:58:52PM -0700, Chris Wright wrote:
> Date: Tue, 4 May 2010 17:58:52 -0700
> From: Chris Wright <chrisw@sous-sol.org>
> To: Pankaj Thakkar <pthakkar@vmware.com>
> CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
> 	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
> 	"virtualization@lists.linux-foundation.org"
>  <virtualization@lists.linux-foundation.org>,
> 	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
> 	Shreyas Bhatewara <sbhatewara@vmware.com>,
> 	"kvm@vger.kernel.org" <kvm@vger.kernel.org>
> Subject: Re: RFC: Network Plugin Architecture (NPA) for vmxnet3
> 
> * Pankaj Thakkar (pthakkar@vmware.com) wrote:
> > We intend to upgrade the upstreamed vmxnet3 driver to implement NPA so that
> > Linux users can exploit the benefits provided by passthrough devices in a
> > seamless manner while retaining the benefits of virtualization. The document
> > below tries to answer most of the questions which we anticipated. Please let us
> > know your comments and queries.
> 
> How does the throughput, latency, and host CPU utilization for normal
> data path compare with say NetQueue?

NetQueue is really for scaling across multiple VMs. NPA allows similar scaling
and also helps in improving the CPU efficiency for a single VM since the
hypervisor is bypassed. Througput wise both emulation and passthrough (NPA) can
obtain line rates on 10gig but passthrough saves upto 40% cpu based on the
workload. We did a demo at IDF 2009 where we compared 8 VMs running on NetQueue
v/s 8 VMs running on NPA (using Niantic) and we obtained similar CPU efficiency
gains.

> 
> And does this obsolete your UPT implementation?

NPA and UPT share a lot of code in the hypervisor. UPT was adopted only by very
limited IHVs and hence NPA is our way forward to have all IHVs onboard.

> How many cards actually support this NPA interface?  What does it look
> like, i.e. where is the NPA specification?  (AFAIK, we never got the UPT
> one).

We have it working internally with Intel Niantic (10G) and Kawela (1G) SR-IOV
NIC. We are also working with upcoming Broadcom 10G card and plan to support
other IHVs. This is unlike UPT so we don't dictate the register sets or rings
like we did in UPT. Rather we have guidelines like that the card should have an
embedded switch for inter VF switching or should support programming (rx
filters, VLAN, etc) though the PF driver rather than the VF driver.

> How do you handle hardware which has a more symmetric view of the
> SR-IOV world (SR-IOV is only PCI sepcification, not a network driver
> specification)?  Or hardware which has multiple functions per physical
> port (multiqueue, hw filtering, embedded switch, etc.)?

I am not sure what do you mean by symmetric view of SR-IOV world?

NPA allows multi-queue VFs and requires an embedded switch currently. As far as
the PF driver is concerned we require IHVs to support all existing and upcoming
features like NetQueue, FCoE, etc. The PF driver is considered special and is
used to drive the traffic for the emulated/paravirtualized VMs and is also used
to program things on behalf of the VFs through the hypervisor. If the hardware
has multiple physical functions they are treated as separate adapters (with
their own set of VFs) and we require the embedded switch to maintain that
distinction as well.


> > NPA offers several benefits:
> > 1. Performance: Critical performance sensitive paths are not trapped and the
> > guest can directly drive the hardware without incurring virtualization
> > overheads.
> 
> Can you demonstrate with data?

The setup is 2.667Ghz Nehalem server running SLES11 VM talking to a 2.33Ghz
Barcelona client box running RHEL 5.1. We had netperf streams with 16k msg size
over 64k socket size running between server VM and client and they are using
Intel Niantic 10G cards. In both cases (NPA and regular) the VM was CPU
saturated (used one full core).

TX: regular vmxnet3 = 3085.5 Mbps/GHz; NPA vmxnet3 = 4397.2 Mbps/GHz
RX: regular vmxnet3 = 1379.6 Mbps/GHz; NPA vmxnet3 = 2349.7 Mbps/GHz

We have similar results for other configuration and in general we have seen NPA
is better in terms of CPU cost and can save upto 40% of CPU cost.

> 
> > 2. Hypervisor control: All control operations from the guest such as programming
> > MAC address go through the hypervisor layer and hence can be subjected to
> > hypervisor policies. The PF driver can be further used to put policy decisions
> > like which VLAN the guest should be on.
> 
> This can happen without NPA as well.  VF simply needs to request
> the change via the PF (in fact, hw does that right now).  Also, we
> already have a host side management interface via PF (see, for example,
> RTM_SETLINK IFLA_VF_MAC interface).
> 
> What is control plane interface?  Just something like a fixed register set?

All operations other than TX/RX go through the vmxnet3 shell to the vmxnet3
device emulation. So the control plane is really the vmxnet3 device emulation
as far as the guest is concerned.

> 
> > 3. Guest Management: No hardware specific drivers need to be installed in the
> > guest virtual machine and hence no overheads are incurred for guest management.
> > All software for the driver (including the PF driver and the plugin) is
> > installed in the hypervisor.
> 
> So we have a plugin per hardware VF implementation?  And the hypervisor
> injects this code into the guest?

One guest-agnostic plugin per VF implementation. Yes, the plugin is injected
into the guest by the hypervisor.

> > The plugin image is provided by the IHVs along with the PF driver and is
> > packaged in the hypervisor. The plugin image is OS agnostic and can be loaded
> > either into a Linux VM or a Windows VM. The plugin is written against the Shell
> 
> And it will need to be GPL AFAICT from what you've said thus far.  It
> does sound worrisome, although I suppose hw firmware isn't particularly
> different.

Yes it would be GPL and we are thinking of enforcing the license in the
hypervisor as well as in the shell.

> How does the shell switch back to emulated mode for live migration?

The hypervisor sends a notification to the shell to switch out of passthrough
and it quiesces the VF and tears down the mapping between VF and the guest. The
shell free's up the buffers and other resources on behalf of the plugin and
reinitializes the s/w vmxnet3 emulation plugin.

> Please make this shell API interface and the PF/VF requirments available.

We have an internal prototype working but we are not yet ready to post the
patch to LKML. We are still in the process of making changes to our windows
driver and want to ensure that we take into account all changes that could
happen.

Thanks,

-pankaj

