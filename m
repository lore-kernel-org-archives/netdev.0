From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/13] fm10k: ensure we process SM mbx when processing VF mbx
Date: Mon,  2 Oct 2017 08:42:24 -0700
Message-ID: <20171002154236.84043-2-jeffrey.t.kirsher@intel.com>
References: <20171002154236.84043-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:24370 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751420AbdJBPm6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 11:42:58 -0400
In-Reply-To: <20171002154236.84043-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

When we process VF mailboxes, the driver is likely going to also queue
up messages to the switch manager. This process merely queues up the
FIFO, but doesn't actually begin the transmission process. Because we
hold the mailbox lock during this VF processing, the PF<->SM mailbox is
not getting processed at this time. Ensure that we actually process the
PF<->SM mailbox in between each PF<->VF mailbox.

This should ensure prompt transmission of the messages queued up after
each VF message is received and handled.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_iov.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_iov.c b/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
index 5f4dac0d36ef..2ec49116fe91 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
@@ -126,6 +126,9 @@ s32 fm10k_iov_mbx(struct fm10k_intfc *interface)
 		struct fm10k_mbx_info *mbx = &vf_info->mbx;
 		u16 glort = vf_info->glort;
 
+		/* process the SM mailbox first to drain outgoing messages */
+		hw->mbx.ops.process(hw, &hw->mbx);
+
 		/* verify port mapping is valid, if not reset port */
 		if (vf_info->vf_flags && !fm10k_glort_valid_pf(hw, glort))
 			hw->iov.ops.reset_lport(hw, vf_info);
-- 
2.14.2
