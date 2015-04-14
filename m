From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 17/25] fm10k: comment next_vf_mbx flow
Date: Tue, 14 Apr 2015 16:51:03 -0700
Message-ID: <1429055471-401-18-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jacob Keller <jacob.e.keller@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20409 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754928AbbDNXvZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 19:51:25 -0400
In-Reply-To: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a header comment explaining why we have the somewhat crazy mailbox
flow. This flow is necessary as it prevents the PF<->SM mailbox from
being flooded by the VF messages, which normally trigger a message to
the PF. This helps prevent the case where we see a PF mailbox timeout.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Acked-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_iov.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_iov.c b/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
index 0b37e19..5b08e62 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
@@ -113,6 +113,13 @@ s32 fm10k_iov_mbx(struct fm10k_intfc *interface)
 	/* lock the mailbox for transmit and receive */
 	fm10k_mbx_lock(interface);
 
+	/* Most VF messages sent to the PF cause the PF to respond by
+	 * requesting from the SM mailbox. This means that too many VF
+	 * messages processed at once could cause a mailbox timeout on the PF.
+	 * To prevent this, store a pointer to the next VF mbx to process. Use
+	 * that as the start of the loop so that we don't starve whichever VF
+	 * got ignored on the previous run.
+	 */
 process_mbx:
 	for (i = iov_data->next_vf_mbx ? : iov_data->num_vfs; i--;) {
 		struct fm10k_vf_info *vf_info = &iov_data->vf_info[i];
@@ -137,6 +144,10 @@ process_mbx:
 		mbx->ops.process(hw, mbx);
 	}
 
+	/* if we stopped processing mailboxes early, update next_vf_mbx.
+	 * Otherwise, reset next_vf_mbx, and restart loop so that we process
+	 * the remaining mailboxes we skipped at the start.
+	 */
 	if (i >= 0) {
 		iov_data->next_vf_mbx = i + 1;
 	} else if (iov_data->next_vf_mbx) {
-- 
1.9.3
