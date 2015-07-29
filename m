From: Alex Williamson <alex.williamson@redhat.com>
Subject: [PATCH v2 2/2] ixgbe: Teardown SR-IOV before unregister_netdev()
Date: Wed, 29 Jul 2015 14:38:21 -0600
Message-ID: <20150729203821.10732.51057.stgit@gimli.home>
References: <20150729203726.10732.91020.stgit@gimli.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mitch.a.williams@intel.com,
	linux-kernel@vger.kernel.org
To: intel-wired-lan@lists.osuosl.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150729203726.10732.91020.stgit@gimli.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the .remove() callback for a PF is called, SR-IOV support for the
device is disabled, which requires unbinding and removing the VFs.
The VFs may be in-use either by the host kernel or userspace, such as
assigned to a VM through vfio-pci.  In this latter case, the VFs may
be removed either by shutting down the VM or hot-unplugging the
devices from the VM.  Unfortunately in the case of a Windows 2012 R2
guest, hot-unplug is broken due to the ordering of the PF driver
teardown.  Disabling SR-IOV prior to unregister_netdev() avoids this
issue.

Signed-off-by: Alex Williamson <alex.williamson@redhat.com>
Acked-by: Mitch Williams <mitch.a.williams@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 9aa6104..faa218c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8855,9 +8855,6 @@ static void ixgbe_remove(struct pci_dev *pdev)
 	/* remove the added san mac */
 	ixgbe_del_sanmac_netdev(netdev);
 
-	if (netdev->reg_state == NETREG_REGISTERED)
-		unregister_netdev(netdev);
-
 #ifdef CONFIG_PCI_IOV
 	/*
 	 * Only disable SR-IOV on unload if the user specified the now
@@ -8866,6 +8863,9 @@ static void ixgbe_remove(struct pci_dev *pdev)
 	if (max_vfs)
 		ixgbe_disable_sriov(adapter);
 #endif
+	if (netdev->reg_state == NETREG_REGISTERED)
+		unregister_netdev(netdev);
+
 	ixgbe_clear_interrupt_scheme(adapter);
 
 	ixgbe_release_hw_control(adapter);
