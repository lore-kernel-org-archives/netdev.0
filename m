From: Alex Williamson <alex.williamson@redhat.com>
Subject: [PATCH 1/2] igb: Teardown SR-IOV before unregister_netdev()
Date: Mon, 27 Jul 2015 17:18:34 -0600
Message-ID: <20150727231834.10121.62918.stgit@gimli.home>
References: <20150727223753.10121.78169.stgit@gimli.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150727223753.10121.78169.stgit@gimli.home>
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
---
 drivers/net/ethernet/intel/igb/igb_main.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 517746f..606a7ae 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2805,14 +2805,14 @@ static void igb_remove(struct pci_dev *pdev)
 	 */
 	igb_release_hw_control(adapter);
 
-	unregister_netdev(netdev);
-
-	igb_clear_interrupt_scheme(adapter);
-
 #ifdef CONFIG_PCI_IOV
 	igb_disable_sriov(pdev);
 #endif
 
+	unregister_netdev(netdev);
+
+	igb_clear_interrupt_scheme(adapter);
+
 	pci_iounmap(pdev, hw->hw_addr);
 	if (hw->flash_address)
 		iounmap(hw->flash_address);
