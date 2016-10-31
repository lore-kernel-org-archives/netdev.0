From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 16/22] i40evf: avoid an extra msleep while
Date: Mon, 31 Oct 2016 15:29:46 -0700
Message-ID: <1477952992-125662-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1477952992-125662-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:46390 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S947509AbcJaWaC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Oct 2016 18:30:02 -0400
In-Reply-To: <1477952992-125662-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Remove the second call to msleep outside the loop, and move the msleep
within the loop as the first step. This guarantees that a single loop
will wait the minimum time first, and then after the reset finishes we
no longer need an extra msleep.

Change-ID: Ib2086f0a142402b614f67846bc091754203a0b9a
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index bcb1caf..db36744 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1746,15 +1746,17 @@ static void i40evf_reset_task(struct work_struct *work)
 
 	/* wait until the reset is complete and the PF is responding to us */
 	for (i = 0; i < I40EVF_RESET_WAIT_COUNT; i++) {
+		/* sleep first to make sure a minimum wait time is met */
+		msleep(I40EVF_RESET_WAIT_MS);
+
 		reg_val = rd32(hw, I40E_VFGEN_RSTAT) &
 			  I40E_VFGEN_RSTAT_VFR_STATE_MASK;
 		if (reg_val == I40E_VFR_VFACTIVE)
 			break;
-		msleep(I40EVF_RESET_WAIT_MS);
 	}
+
 	pci_set_master(adapter->pdev);
-	/* extra wait to make sure minimum wait is met */
-	msleep(I40EVF_RESET_WAIT_MS);
+
 	if (i == I40EVF_RESET_WAIT_COUNT) {
 		struct i40evf_mac_filter *ftmp;
 		struct i40evf_vlan_filter *fv, *fvtmp;
-- 
2.7.4
