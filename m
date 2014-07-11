From: Alex Williamson <alex.williamson@redhat.com>
Subject: Re: [PATCH 1/2 V3] PCI: introduce device assignment
 interface and refactory related code
Date: Fri, 11 Jul 2014 08:15:47 -0600
Message-ID: <1405088147.4098.64.camel@ul30vt.home>
References: <1405081802-419-1-git-send-email-ethan.zhao@oracle.com>
	<1405084407.4098.59.camel@ul30vt.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, linux-pci@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, vaughan.cao@oracle.com,
	jesse.brandeburg@intel.com, ethan.kernel@gmail.com,
	linux.nics@intel.com, konrad.wilk@oracle.com, gleb@kernel.org,
	bhelgaas@google.com, boris.ostrovsky@oracle.com,
	netdev@vger.kernel.org, bruce.w.allan@intel.com,
	linux-kernel@vger.kernel.org, john.ronciak@intel.com,
	david.vrabel@citrix.com, pbonzini@redhat.com
To: Ethan Zhao <ethan.zhao@oracle.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1405084407.4098.59.camel@ul30vt.home>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Fri, 2014-07-11 at 07:13 -0600, Alex Williamson wrote:
> On Fri, 2014-07-11 at 20:30 +0800, Ethan Zhao wrote:
> > This patch introduces two new device assignment functions
> > 
> > pci_iov_assign_device(),
> > pci_iov_deassign_device()
> > 
> > along with the existed one
> > 
> > pci_vfs_assigned()
> > 
> > They construct the VFs assignment management interface, used to assign/
> > deassign device to VM and query the VFs reference counter. instead of
> > direct manipulation of device flag.
> > 
> > This patch refashioned the related code and make them atomic.
> > 
> > v3: change the naming of device assignment helpers, because they work
> > for all kind of PCI device, not only SR-IOV (david.vrabel@citrix.com)
> > 
> > v2: reorder the patchset and make it bisectable and atomic, steps clear
> > between interface defination and implemenation according to the
> > suggestion from alex.williamson@redhat.com
> > 
> > Signed-off-by: Ethan Zhao <ethan.zhao@oracle.com>
> > ---
> 
> - Use a cover patch to describe the series
> 
> - Version information goes here, below the "---", not above it
> 
> - I stand by the patch breakdown I suggested originally, there are too
> many logical changes here in patch 1.  There are easily 3 separate
> patches here.
> 
> - Renaming s/sriov/iov/ doesn't address the problem David raised.  The
> name is still synonymous with SR-IOV and it's defined on
> drivers/pci/iov.c, which is only built with CONFIG_PCI_IOV.
> 
> - PCI_DEV_FLAGS_ASSIGNED should be unused after this series, why is it
> not removed?

I guess it's still used, which is even worse because now we have
separate data elements, one tracking how many VFs are assigned from a PF
and another tracking each device that's assigned.  What are we actually
gaining or fixing by doing this?

> >  drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   17 ++---------------
> >  drivers/pci/iov.c                                  |   20 ++++++++++++++++++++
> >  drivers/xen/xen-pciback/pci_stub.c                 |    4 ++--
> >  include/linux/pci.h                                |    4 ++++
> >  virt/kvm/assigned-dev.c                            |    2 +-
> >  virt/kvm/iommu.c                                   |    4 ++--
> 
> - This patch touch 4 separate logical code areas, who do you expect to
> ack and commit it?  Split it up.
> 
> >  6 files changed, 31 insertions(+), 20 deletions(-)
> > 
> > diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
> > index 02c11a7..781040e 100644
> > --- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
> > +++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
> > @@ -693,22 +693,9 @@ complete_reset:
> >  static bool i40e_vfs_are_assigned(struct i40e_pf *pf)
> >  {
> >  	struct pci_dev *pdev = pf->pdev;
> > -	struct pci_dev *vfdev;
> > -
> > -	/* loop through all the VFs to see if we own any that are assigned */
> > -	vfdev = pci_get_device(PCI_VENDOR_ID_INTEL, I40E_DEV_ID_VF , NULL);
> > -	while (vfdev) {
> > -		/* if we don't own it we don't care */
> > -		if (vfdev->is_virtfn && pci_physfn(vfdev) == pdev) {
> > -			/* if it is assigned we cannot release it */
> > -			if (vfdev->dev_flags & PCI_DEV_FLAGS_ASSIGNED)
> > -				return true;
> > -		}
> >  
> > -		vfdev = pci_get_device(PCI_VENDOR_ID_INTEL,
> > -				       I40E_DEV_ID_VF,
> > -				       vfdev);
> > -	}
> > +	if (pci_vfs_assigned(pdev))
> > +		return true;
> >  
> >  	return false;
> >  }
> > diff --git a/drivers/pci/iov.c b/drivers/pci/iov.c
> > index de7a747..090f827 100644
> > --- a/drivers/pci/iov.c
> > +++ b/drivers/pci/iov.c
> > @@ -644,6 +644,26 @@ int pci_vfs_assigned(struct pci_dev *dev)
> >  EXPORT_SYMBOL_GPL(pci_vfs_assigned);
> >  
> >  /**
> > + * pci_iov_assign_device - assign device to VM
> > + * @pdev: the device to be assigned.
> > + */
> > +void pci_iov_assign_device(struct pci_dev *pdev)
> > +{
> > +	pdev->dev_flags |= PCI_DEV_FLAGS_ASSIGNED;
> > +}
> > +EXPORT_SYMBOL_GPL(pci_iov_assign_device);
> > +
> > +/**
> > + * pci_iov_deassign_device - deasign device from VM
> > + * @pdev: the device to be deassigned.
> > + */
> > +void pci_iov_deassign_device(struct pci_dev *pdev)
> > +{
> > +	pdev->dev_flags &= ~PCI_DEV_FLAGS_ASSIGNED;
> > +}
> > +EXPORT_SYMBOL_GPL(pci_iov_deassign_device);
> > +
> > +/**
> >   * pci_sriov_set_totalvfs -- reduce the TotalVFs available
> >   * @dev: the PCI PF device
> >   * @numvfs: number that should be used for TotalVFs supported
> > diff --git a/drivers/xen/xen-pciback/pci_stub.c b/drivers/xen/xen-pciback/pci_stub.c
> > index 62fcd48..27e00d1 100644
> > --- a/drivers/xen/xen-pciback/pci_stub.c
> > +++ b/drivers/xen/xen-pciback/pci_stub.c
> > @@ -133,7 +133,7 @@ static void pcistub_device_release(struct kref *kref)
> >  	xen_pcibk_config_free_dyn_fields(dev);
> >  	xen_pcibk_config_free_dev(dev);
> >  
> > -	dev->dev_flags &= ~PCI_DEV_FLAGS_ASSIGNED;
> > +	pci_iov_deassign_device(dev);
> >  	pci_dev_put(dev);
> >  
> >  	kfree(psdev);
> > @@ -404,7 +404,7 @@ static int pcistub_init_device(struct pci_dev *dev)
> >  	dev_dbg(&dev->dev, "reset device\n");
> >  	xen_pcibk_reset_device(dev);
> >  
> > -	dev->dev_flags |= PCI_DEV_FLAGS_ASSIGNED;
> > +	pci_iov_assign_device(dev);
> >  	return 0;
> >  
> >  config_release:
> > diff --git a/include/linux/pci.h b/include/linux/pci.h
> > index aab57b4..5ece6d6 100644
> > --- a/include/linux/pci.h
> > +++ b/include/linux/pci.h
> > @@ -1603,6 +1603,8 @@ int pci_num_vf(struct pci_dev *dev);
> >  int pci_vfs_assigned(struct pci_dev *dev);
> >  int pci_sriov_set_totalvfs(struct pci_dev *dev, u16 numvfs);
> >  int pci_sriov_get_totalvfs(struct pci_dev *dev);
> > +void pci_iov_assign_device(struct pci_dev *dev);
> > +void pci_iov_deassign_device(struct pci_dev *dev);
> >  #else
> >  static inline int pci_enable_sriov(struct pci_dev *dev, int nr_virtfn)
> >  { return -ENODEV; }
> > @@ -1614,6 +1616,8 @@ static inline int pci_sriov_set_totalvfs(struct pci_dev *dev, u16 numvfs)
> >  { return 0; }
> >  static inline int pci_sriov_get_totalvfs(struct pci_dev *dev)
> >  { return 0; }
> > +static inline void pci_iov_assign_device(struct pci_dev *dev) { }
> > +static inline void pci_iov_deassign_device(struct pci_dev *dev) { }
> >  #endif
> >  
> >  #if defined(CONFIG_HOTPLUG_PCI) || defined(CONFIG_HOTPLUG_PCI_MODULE)
> > diff --git a/virt/kvm/assigned-dev.c b/virt/kvm/assigned-dev.c
> > index bf06577..7fac58d 100644
> > --- a/virt/kvm/assigned-dev.c
> > +++ b/virt/kvm/assigned-dev.c
> > @@ -302,7 +302,7 @@ static void kvm_free_assigned_device(struct kvm *kvm,
> >  	else
> >  		pci_restore_state(assigned_dev->dev);
> >  
> > -	assigned_dev->dev->dev_flags &= ~PCI_DEV_FLAGS_ASSIGNED;
> > +	pci_iov_deassign_device(assigned_dev->dev);
> >  
> >  	pci_release_regions(assigned_dev->dev);
> >  	pci_disable_device(assigned_dev->dev);
> > diff --git a/virt/kvm/iommu.c b/virt/kvm/iommu.c
> > index 0df7d4b..641ee73 100644
> > --- a/virt/kvm/iommu.c
> > +++ b/virt/kvm/iommu.c
> > @@ -194,7 +194,7 @@ int kvm_assign_device(struct kvm *kvm,
> >  			goto out_unmap;
> >  	}
> >  
> > -	pdev->dev_flags |= PCI_DEV_FLAGS_ASSIGNED;
> > +	pci_iov_assign_device(pdev);
> >  
> >  	dev_info(&pdev->dev, "kvm assign device\n");
> >  
> > @@ -220,7 +220,7 @@ int kvm_deassign_device(struct kvm *kvm,
> >  
> >  	iommu_detach_device(domain, &pdev->dev);
> >  
> > -	pdev->dev_flags &= ~PCI_DEV_FLAGS_ASSIGNED;
> > +	pci_iov_deassign_device(pdev);
> >  
> >  	dev_info(&pdev->dev, "kvm deassign device\n");
> >  
> 
> 




------------------------------------------------------------------------------
Open source business process management suite built on Java and Eclipse
Turn processes into business applications with Bonita BPM Community Edition
Quickly connect people, data, and systems into organized workflows
Winner of BOSSIE, CODIE, OW2 and Gartner awards
http://p.sf.net/sfu/Bonitasoft
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
