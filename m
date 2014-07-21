From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH 1/2 V3] PCI: introduce device assignment interface and
 refactory related code
Date: Mon, 21 Jul 2014 15:29:12 -0700
Message-ID: <53CD9438.6010409@intel.com>
References: <1405081802-419-1-git-send-email-ethan.zhao@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-pci@vger.kernel.org, kvm@vger.kernel.org,
	linux.nics@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ethan.kernel@gmail.com, vaughan.cao@oracle.com
To: Ethan Zhao <ethan.zhao@oracle.com>, bhelgaas@google.com,
	konrad.wilk@oracle.com, boris.ostrovsky@oracle.com,
	david.vrabel@citrix.com, gleb@kernel.org, pbonzini@redhat.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	alex.williamson@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405081802-419-1-git-send-email-ethan.zhao@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/11/2014 05:30 AM, Ethan Zhao wrote:
> This patch introduces two new device assignment functions
> 
> pci_iov_assign_device(),
> pci_iov_deassign_device()
> 
> along with the existed one
> 
> pci_vfs_assigned()
> 
> They construct the VFs assignment management interface, used to assign/
> deassign device to VM and query the VFs reference counter. instead of
> direct manipulation of device flag.
> 
> This patch refashioned the related code and make them atomic.
> 
> v3: change the naming of device assignment helpers, because they work
> for all kind of PCI device, not only SR-IOV (david.vrabel@citrix.com)
> 
> v2: reorder the patchset and make it bisectable and atomic, steps clear
> between interface defination and implemenation according to the
> suggestion from alex.williamson@redhat.com
> 
> Signed-off-by: Ethan Zhao <ethan.zhao@oracle.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   17 ++---------------
>  drivers/pci/iov.c                                  |   20 ++++++++++++++++++++
>  drivers/xen/xen-pciback/pci_stub.c                 |    4 ++--
>  include/linux/pci.h                                |    4 ++++
>  virt/kvm/assigned-dev.c                            |    2 +-
>  virt/kvm/iommu.c                                   |    4 ++--
>  6 files changed, 31 insertions(+), 20 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
> index 02c11a7..781040e 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
> @@ -693,22 +693,9 @@ complete_reset:
>  static bool i40e_vfs_are_assigned(struct i40e_pf *pf)
>  {
>  	struct pci_dev *pdev = pf->pdev;
> -	struct pci_dev *vfdev;
> -
> -	/* loop through all the VFs to see if we own any that are assigned */
> -	vfdev = pci_get_device(PCI_VENDOR_ID_INTEL, I40E_DEV_ID_VF , NULL);
> -	while (vfdev) {
> -		/* if we don't own it we don't care */
> -		if (vfdev->is_virtfn && pci_physfn(vfdev) == pdev) {
> -			/* if it is assigned we cannot release it */
> -			if (vfdev->dev_flags & PCI_DEV_FLAGS_ASSIGNED)
> -				return true;
> -		}
>  
> -		vfdev = pci_get_device(PCI_VENDOR_ID_INTEL,
> -				       I40E_DEV_ID_VF,
> -				       vfdev);
> -	}
> +	if (pci_vfs_assigned(pdev))
> +		return true;
>  
>  	return false;
>  }

This portion for i40e should be in one patch by itself.  It shouldn't be
included in the bits below.  Normally this would go through netdev.  The
rest of this below would go through linux-pci.

> diff --git a/drivers/pci/iov.c b/drivers/pci/iov.c
> index de7a747..090f827 100644
> --- a/drivers/pci/iov.c
> +++ b/drivers/pci/iov.c
> @@ -644,6 +644,26 @@ int pci_vfs_assigned(struct pci_dev *dev)
>  EXPORT_SYMBOL_GPL(pci_vfs_assigned);
>  
>  /**
> + * pci_iov_assign_device - assign device to VM
> + * @pdev: the device to be assigned.
> + */
> +void pci_iov_assign_device(struct pci_dev *pdev)
> +{
> +	pdev->dev_flags |= PCI_DEV_FLAGS_ASSIGNED;
> +}
> +EXPORT_SYMBOL_GPL(pci_iov_assign_device);
> +
> +/**
> + * pci_iov_deassign_device - deasign device from VM
> + * @pdev: the device to be deassigned.
> + */
> +void pci_iov_deassign_device(struct pci_dev *pdev)
> +{
> +	pdev->dev_flags &= ~PCI_DEV_FLAGS_ASSIGNED;
> +}
> +EXPORT_SYMBOL_GPL(pci_iov_deassign_device);
> +
> +/**
>   * pci_sriov_set_totalvfs -- reduce the TotalVFs available
>   * @dev: the PCI PF device
>   * @numvfs: number that should be used for TotalVFs supported

The two functions above don't have anything to do with IOV.  You can
direct assign a device that doesn't even support SR-IOV or MR-IOV.  You
might be better off defining this as something like
"pci_set_flag_assigned/pci_clear_flag_assigned".  I would likely also
make them inline and possibly move them to pci.h since it would likely
result in less actual code after you consider the overhead to push
everything on the stack prior to making the call.

> diff --git a/drivers/xen/xen-pciback/pci_stub.c b/drivers/xen/xen-pciback/pci_stub.c
> index 62fcd48..27e00d1 100644
> --- a/drivers/xen/xen-pciback/pci_stub.c
> +++ b/drivers/xen/xen-pciback/pci_stub.c
> @@ -133,7 +133,7 @@ static void pcistub_device_release(struct kref *kref)
>  	xen_pcibk_config_free_dyn_fields(dev);
>  	xen_pcibk_config_free_dev(dev);
>  
> -	dev->dev_flags &= ~PCI_DEV_FLAGS_ASSIGNED;
> +	pci_iov_deassign_device(dev);
>  	pci_dev_put(dev);
>  
>  	kfree(psdev);
> @@ -404,7 +404,7 @@ static int pcistub_init_device(struct pci_dev *dev)
>  	dev_dbg(&dev->dev, "reset device\n");
>  	xen_pcibk_reset_device(dev);
>  
> -	dev->dev_flags |= PCI_DEV_FLAGS_ASSIGNED;
> +	pci_iov_assign_device(dev);
>  	return 0;
>  
>  config_release:
> diff --git a/include/linux/pci.h b/include/linux/pci.h
> index aab57b4..5ece6d6 100644
> --- a/include/linux/pci.h
> +++ b/include/linux/pci.h
> @@ -1603,6 +1603,8 @@ int pci_num_vf(struct pci_dev *dev);
>  int pci_vfs_assigned(struct pci_dev *dev);
>  int pci_sriov_set_totalvfs(struct pci_dev *dev, u16 numvfs);
>  int pci_sriov_get_totalvfs(struct pci_dev *dev);
> +void pci_iov_assign_device(struct pci_dev *dev);
> +void pci_iov_deassign_device(struct pci_dev *dev);
>  #else
>  static inline int pci_enable_sriov(struct pci_dev *dev, int nr_virtfn)
>  { return -ENODEV; }
> @@ -1614,6 +1616,8 @@ static inline int pci_sriov_set_totalvfs(struct pci_dev *dev, u16 numvfs)
>  { return 0; }
>  static inline int pci_sriov_get_totalvfs(struct pci_dev *dev)
>  { return 0; }
> +static inline void pci_iov_assign_device(struct pci_dev *dev) { }
> +static inline void pci_iov_deassign_device(struct pci_dev *dev) { }
>  #endif
>  
>  #if defined(CONFIG_HOTPLUG_PCI) || defined(CONFIG_HOTPLUG_PCI_MODULE)
> diff --git a/virt/kvm/assigned-dev.c b/virt/kvm/assigned-dev.c
> index bf06577..7fac58d 100644
> --- a/virt/kvm/assigned-dev.c
> +++ b/virt/kvm/assigned-dev.c
> @@ -302,7 +302,7 @@ static void kvm_free_assigned_device(struct kvm *kvm,
>  	else
>  		pci_restore_state(assigned_dev->dev);
>  
> -	assigned_dev->dev->dev_flags &= ~PCI_DEV_FLAGS_ASSIGNED;
> +	pci_iov_deassign_device(assigned_dev->dev);
>  
>  	pci_release_regions(assigned_dev->dev);
>  	pci_disable_device(assigned_dev->dev);
> diff --git a/virt/kvm/iommu.c b/virt/kvm/iommu.c
> index 0df7d4b..641ee73 100644
> --- a/virt/kvm/iommu.c
> +++ b/virt/kvm/iommu.c
> @@ -194,7 +194,7 @@ int kvm_assign_device(struct kvm *kvm,
>  			goto out_unmap;
>  	}
>  
> -	pdev->dev_flags |= PCI_DEV_FLAGS_ASSIGNED;
> +	pci_iov_assign_device(pdev);
>  
>  	dev_info(&pdev->dev, "kvm assign device\n");
>  
> @@ -220,7 +220,7 @@ int kvm_deassign_device(struct kvm *kvm,
>  
>  	iommu_detach_device(domain, &pdev->dev);
>  
> -	pdev->dev_flags &= ~PCI_DEV_FLAGS_ASSIGNED;
> +	pci_iov_deassign_device(pdev);
>  
>  	dev_info(&pdev->dev, "kvm deassign device\n");
>  
> 
