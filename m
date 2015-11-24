From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH V2 0/3] IXGBE/VFIO: Add live migration support for
 SRIOV NIC
Date: Tue, 24 Nov 2015 06:20:29 -0800
Message-ID: <5654722D.4010409@gmail.com>
References: <1448372298-28386-1-git-send-email-tianyu.lan@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Lan Tianyu <tianyu.lan@intel.com>,
	a.motakis@virtualopensystems.com, alex.williamson@redhat.com,
	b.reynal@virtualopensystems.com, bhelgaas@google.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	eddie.dong@intel.com, nrupal.jani@intel.com, agraf@suse.de,
	kvm@vger.kernel.org, pbonzini@redhat.com, qemu-devel@nongnu.org,
	emil.s.tantilov@intel.com, gerlitz.or@gmail.com,
	mark.d.rustad@intel.com, mst@redhat.com, eric.auger@linaro.org,
	intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	linux-api@vger.kernel.org, linux-kernel@vger.kernel.org,
	matthew.vick@intel.com, mitch.a.williams@intel.com,
	netdev@vger.kernel.org, shannon.nelson@intel.com,
	weiyang@linux.vnet.ibm.com, zajec5@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:33118 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752112AbbKXOUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 09:20:33 -0500
In-Reply-To: <1448372298-28386-1-git-send-email-tianyu.lan@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/24/2015 05:38 AM, Lan Tianyu wrote:
> This patchset is to propose a solution of adding live migration
> support for SRIOV NIC.
>
> During migration, Qemu needs to let VF driver in the VM to know
> migration start and end. Qemu adds faked PCI migration capability
> to help to sync status between two sides during migration.
>
> Qemu triggers VF's mailbox irq via sending MSIX msg when migration
> status is changed. VF driver tells Qemu its mailbox vector index
> via the new PCI capability. In some cases(NIC is suspended or closed),
> VF mailbox irq is freed and VF driver can disable irq injecting via
> new capability.
>
> VF driver will put down nic before migration and put up again on
> the target machine.
>
> Lan Tianyu (3):
>    VFIO: Add new ioctl cmd VFIO_GET_PCI_CAP_INFO
>    PCI: Add macros for faked PCI migration capability
>    Ixgbevf: Add migration support for ixgbevf driver
>
>   drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   5 ++
>   drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 102 ++++++++++++++++++++++
>   drivers/vfio/pci/vfio_pci.c                       |  21 +++++
>   drivers/vfio/pci/vfio_pci_config.c                |  38 ++++++--
>   drivers/vfio/pci/vfio_pci_private.h               |   5 ++
>   include/uapi/linux/pci_regs.h                     |  18 +++-
>   include/uapi/linux/vfio.h                         |  12 +++
>   7 files changed, 194 insertions(+), 7 deletions(-)

I'm still not a fan of this approach.  I really feel like this is 
something that should be resolved by extending the existing PCI hot-plug 
rather than trying to instrument this per driver.  Then you will get the 
goodness for multiple drivers and multiple OSes instead of just one.  An 
added advantage to dealing with this in the PCI hot-plug environment 
would be that you could then still do a hot-plug even if the guest 
didn't load a driver for the VF since you would be working with the PCI 
slot instead of the device itself.

- Alex
