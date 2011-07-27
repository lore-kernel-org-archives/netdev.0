From: Greg Rose <gregory.v.rose@intel.com>
Subject: [RFC net-next PATCH 1/4] pci: Add flag indicating device has been
	assigned by KVM
Date: Wed, 27 Jul 2011 15:17:49 -0700
Message-ID: <20110727221749.8435.19000.stgit@gitlad.jf.intel.com>
References: <20110727221406.8435.44324.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, bhutchings@solarflare.com,
	jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:35576 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755304Ab1G0WRx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jul 2011 18:17:53 -0400
In-Reply-To: <20110727221406.8435.44324.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Device drivers that create and destroy SR-IOV virtual functions via
calls to pci_enable_sriov() and pci_disable_sriov can cause catastrophic
failures if they attempt to destroy VFs while they are assigned to
guest virtual machines.  By adding a flag for use by the KVM module
to indicate that a device is assigned a device driver can check that
flag and avoid destroying VFs while they are assigned and avoid system
failures.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
---

 include/linux/pci.h     |    2 ++
 virt/kvm/assigned-dev.c |    2 ++
 virt/kvm/iommu.c        |    4 ++++
 3 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/include/linux/pci.h b/include/linux/pci.h
index 2d29218..a297ca2 100644
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
index 6cc4b97..f401de1 100644
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
index 62a9caf..cffc530 100644
--- a/virt/kvm/iommu.c
+++ b/virt/kvm/iommu.c
@@ -181,6 +181,8 @@ int kvm_assign_device(struct kvm *kvm,
 			goto out_unmap;
 	}
 
+	pdev->dev_flags |= PCI_DEV_FLAGS_ASSIGNED;
+
 	printk(KERN_DEBUG "assign device %x:%x:%x.%x\n",
 		assigned_dev->host_segnr,
 		assigned_dev->host_busnr,
@@ -209,6 +211,8 @@ int kvm_deassign_device(struct kvm *kvm,
 
 	iommu_detach_device(domain, &pdev->dev);
 
+	pdev->dev_flags &= ~PCI_DEV_FLAGS_ASSIGNED;
+
 	printk(KERN_DEBUG "deassign device %x:%x:%x.%x\n",
 		assigned_dev->host_segnr,
 		assigned_dev->host_busnr,

