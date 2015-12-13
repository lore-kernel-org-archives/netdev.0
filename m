From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/17] igb: fix NULL derefs due to skipped SR-IOV enabling
Date: Sun, 13 Dec 2015 00:31:28 -0800
Message-ID: <1449995490-17020-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449995490-17020-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jan Beulich <JBeulich@suse.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jan Beulich <jbeulich@suse.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:4841 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751336AbbLMIbi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2015 03:31:38 -0500
In-Reply-To: <1449995490-17020-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Beulich <JBeulich@suse.com>

The combined effect of commits 6423fc3416 ("igb: do not re-init SR-IOV
during probe") and ceee3450b3 ("igb: make sure SR-IOV init uses the
right number of queues") causes VFs no longer getting set up, leading
to NULL pointer dereferences due to the adapter's ->vf_data being NULL
while ->vfs_allocated_count is non-zero. The first commit not only
neglected the side effect of igb_sriov_reinit() that the second commit
tried to account for, but also that of setting IGB_FLAG_HAS_MSIX,
without which igb_enable_sriov() is effectively a no-op. Calling
igb_{,re}set_interrupt_capability() as done here seems to address this,
but I'm not sure whether this is better than sinply reverting the other
two commits.

Signed-off-by: Jan Beulich <jbeulich@suse.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 061e102..fa3b4cb 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2858,6 +2858,13 @@ static void igb_probe_vfs(struct igb_adapter *adapter)
 	if ((hw->mac.type == e1000_i210) || (hw->mac.type == e1000_i211))
 		return;
 
+	/* Of the below we really only want the effect of getting
+	 * IGB_FLAG_HAS_MSIX set (if available), without which
+	 * igb_enable_sriov() has no effect.
+	 */
+	igb_set_interrupt_capability(adapter, true);
+	igb_reset_interrupt_capability(adapter);
+
 	pci_sriov_set_totalvfs(pdev, 7);
 	igb_enable_sriov(pdev, max_vfs);
 
-- 
2.5.0
