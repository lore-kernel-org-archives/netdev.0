From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/13] fm10k: reschedule service event if we stall the PF<->SM mailbox
Date: Mon,  2 Oct 2017 08:42:25 -0700
Message-ID: <20171002154236.84043-3-jeffrey.t.kirsher@intel.com>
References: <20171002154236.84043-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:24370 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751199AbdJBPm6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 11:42:58 -0400
In-Reply-To: <20171002154236.84043-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

When we are handling PF<->VF mailbox messages, it is possible that the
VF will send us so many messages that the PF<->SM FIFO will fill up. In
this case, we stop the loop and wait until the service event is
rescheduled.

Normally this should happen due to an interrupt. But it is possible that
we don't get another interrupt for a while and it isn't until the
service timer actually reschedules us. Instead, simply reschedule
immediately which will cause the service event to be run again as soon
as we exit.

This ensures that we promptly handle all of the PF<->VF messages with
minimal delay, while still giving time for the SM mailbox to drain.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_iov.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_iov.c b/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
index 2ec49116fe91..d8356c494f06 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
@@ -143,6 +143,10 @@ s32 fm10k_iov_mbx(struct fm10k_intfc *interface)
 		if (!hw->mbx.ops.tx_ready(&hw->mbx, FM10K_VFMBX_MSG_MTU)) {
 			/* keep track of how many times this occurs */
 			interface->hw_sm_mbx_full++;
+
+			/* make sure we try again momentarily */
+			fm10k_service_event_schedule(interface);
+
 			break;
 		}
 
-- 
2.14.2
