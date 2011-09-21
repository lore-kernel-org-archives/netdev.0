From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/8] pci: Add flag indicating device has been assigned by KVM
Date: Wed, 21 Sep 2011 03:12:47 -0700
Message-ID: <1316599974-23205-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1316599974-23205-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:18266 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752882Ab1IUKM6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Sep 2011 06:12:58 -0400
In-Reply-To: <1316599974-23205-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Device drivers that create and destroy SR-IOV virtual functions via
calls to pci_enable_sriov() and pci_disable_sriov can cause catastrophic
failures if they attempt to destroy VFs while they are assigned to
guest virtual machines.  By adding a flag for use by the KVM module
to indicate that a device is assigned a device driver can check that
flag and avoid destroying VFs while they are assigned and avoid system
failures.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 include/linux/pci.h     |    2 ++
 virt/kvm/assigned-dev.c |    2 ++
 virt/kvm/iommu.c        |    4 ++++
 3 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/include/linux/pci.h b/include/linux/pci.h
index f27893b..4f511da 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -174,6 +174,8 @@ enum pci_dev_flags {
 	PCI_DEV_FLAGS_MSI_INTX_DISABLE_BUG = (__force pci_dev_flags_t) 1,
 	/* Device configuration is irrevocably lost if disabled into D3 */
 	PCI_DEV_FLAGS_NO_D3 = (__force pci_dev_flags_t) 2,
+	/* Provide indication device is assigned by KVM */
+	PCI_DEV_FLAGS_ASSIGNED = (__force pci_dev_flags_t) 4,
 };
 
 enum pci_irq_reroute_variant {
diff --git a/virt/kvm/assigned-dev.c b/virt/kvm/assigned-dev.c
index 4e9eaeb..eaf3a50 100644
--- a/virt/kvm/assigned-dev.c
+++ b/virt/kvm/assigned-dev.c
@@ -205,6 +205,8 @@ static void kvm_free_assigned_device(struct kvm *kvm,
 	else
 		pci_restore_state(assigned_dev->dev);
 
+	assigned_dev->dev->dev_flags &= ~PCI_DEV_FLAGS_ASSIGNED;
+
 	pci_release_regions(assigned_dev->dev);
 	pci_disable_device(assigned_dev->dev);
 	pci_dev_put(assigned_dev->dev);
diff --git a/virt/kvm/iommu.c b/virt/kvm/iommu.c
index 78c80f6..967aba1 100644
--- a/virt/kvm/iommu.c
+++ b/virt/kvm/iommu.c
@@ -187,6 +187,8 @@ int kvm_assign_device(struct kvm *kvm,
 			goto out_unmap;
 	}
 
+	pdev->dev_flags |= PCI_DEV_FLAGS_ASSIGNED;
+
 	printk(KERN_DEBUG "assign device %x:%x:%x.%x\n",
 		assigned_dev->host_segnr,
 		assigned_dev->host_busnr,
@@ -215,6 +217,8 @@ int kvm_deassign_device(struct kvm *kvm,
 
 	iommu_detach_device(domain, &pdev->dev);
 
+	pdev->dev_flags &= ~PCI_DEV_FLAGS_ASSIGNED;
+
 	printk(KERN_DEBUG "deassign device %x:%x:%x.%x\n",
 		assigned_dev->host_segnr,
 		assigned_dev->host_busnr,
-- 
1.7.6.2
