From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH 6/7] PCI: Make sure VF's driver get attached after PF's
Date: Tue, 14 May 2013 09:00:48 -0700
Message-ID: <51925FB0.4080504@intel.com>
References: <1368498506-25857-1-git-send-email-yinghai@kernel.org> <1368498506-25857-7-git-send-email-yinghai@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Bjorn Helgaas <bhelgaas@google.com>,
	Gu Zheng <guz.fnst@cn.fujitsu.com>, linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Yinghai Lu <yinghai@kernel.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1368498506-25857-7-git-send-email-yinghai@kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/13/2013 07:28 PM, Yinghai Lu wrote:
> Found kernel try to load mlx4 drivers for VFs before
> PF's is really loaded when the drivers are built-in, and kernel
> command line include probe_vfs=63, num_vfs=63.
>
> It turns that it also happen for hotadd path even drivers are
> compiled as modules and if they loaded. Esp some VF share the
> same driver with PF.
>
> calling path:
> 	device driver probe
> 		==> pci_enable_sriov
> 			==> virtfn_add
> 				==> pci_dev_add
> 				==> pci_bus_device_add
> when pci_bus_device_add is called, the VF's driver will be attached.
> and at that time PF's driver does not finish yet.
>
> Need to move out pci_bus_device_add from virtfn_add and call it
> later. Fix the problem for two path,
> 1. hotadd path: use device_schedule_callback.
> 2. for booting path, use initcall to call that for all VF's.
>
> Signed-off-by: Yinghai Lu <yinghai@kernel.org>
> Cc: netdev@vger.kernel.org
>

I'm sorry, but what is the point of this patch?  With device assignment
it is always possible to have VFs loaded and the PF driver unloaded
since you cannot remove the VFs if they are assigned to a VM.

If there is a driver that has to have the PF driver fully loaded before
it instantiates the VFs then it sounds like a buggy driver to me.  The
VF driver should be able to be loaded when the PF driver is not
present.  We handle it in igb and ixgbe last I checked, and I don't see
any reason why it cannot be handled in all other VF drivers.  I'm not
saying the VF has to be able to fully functional, but it should be able
to detect the PF becoming enabled and then bring itself to a fully
functional state.  To not handle that case is a bug.

Thanks,

Alex
