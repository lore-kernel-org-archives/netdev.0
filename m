From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/17] fm10k: drop transmitted messages in Tx FIFO as part of reset_work
Date: Tue, 22 Sep 2015 16:54:23 -0700
Message-ID: <1442966076-14359-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442966076-14359-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:8434 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934114AbbIVXyj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2015 19:54:39 -0400
In-Reply-To: <1442966076-14359-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch fixes a corner case issue with the PF/VF mailbox code.
Currently, fm10k_mbx_reset_work clears various state about the mailbox.
However, it does not clear the Tx FIFO head/tail pointers. We can't
simply clear these pointers as we unintentionally drop untransmitted
messages without error.

Doing nothing results in a possible phantom re-transmission of messages,
since we leave tx.head and tx.tail intact, but clear the tx_pulled and
tail_len values. This means that the PF could continuously re-send a
message which triggers a reset in the VF. Upon reset, the VF will
re-receive the same message after a reconnect.

If we reset the tx.head and tx.tail pointers completely, we end up
dropping some messages that were pending before connect. This results in
missing LPORT_MSG_READY bits, and VFs will end up reporting no link.

However, we can resolve both issues by simply incrementing head to
account for the already transmitted messages, before we reset tx_pulled.
We do this via the same logic as fm10k_mbx_head_pull.

We account for the tail_len which includes all data not yet transmitted,
once we account for the acked data which means re-reading the HEAD
variable from the message header. Then, we drop messages until we've
dropped more than the new tx_pulled value. At this point, resetting
tail_len and tx_pulled, but not tx.head and tx.tail will result in
prevention of the phantom message. It also prevents us from dropping
untransmitted messages upon attempting to Tx into a connect or
disconnect header.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.c | 19 ++++++++++++++++++-
 1 file changed, 18 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
index 1a4b526..0ff21d1 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
@@ -1046,9 +1046,26 @@ static s32 fm10k_mbx_create_reply(struct fm10k_hw *hw,
  **/
 static void fm10k_mbx_reset_work(struct fm10k_mbx_info *mbx)
 {
+	u16 len, head, ack;
+
 	/* reset our outgoing max size back to Rx limits */
 	mbx->max_size = mbx->rx.size - 1;
 
+	/* update mbx->pulled to account for tail_len and ack */
+	head = FM10K_MSG_HDR_FIELD_GET(mbx->mbx_hdr, HEAD);
+	ack = fm10k_mbx_index_len(mbx, head, mbx->tail);
+	mbx->pulled += mbx->tail_len - ack;
+
+	/* now drop any messages which have started or finished transmitting */
+	while (fm10k_fifo_head_len(&mbx->tx) && mbx->pulled) {
+		len = fm10k_fifo_head_drop(&mbx->tx);
+		mbx->tx_dropped++;
+		if (mbx->pulled >= len)
+			mbx->pulled -= len;
+		else
+			mbx->pulled = 0;
+	}
+
 	/* just do a quick resysnc to start of message */
 	mbx->pushed = 0;
 	mbx->pulled = 0;
@@ -1725,7 +1742,7 @@ static void fm10k_sm_mbx_disconnect(struct fm10k_hw *hw,
 	mbx->state = FM10K_STATE_CLOSED;
 	mbx->remote = 0;
 	fm10k_mbx_reset_work(mbx);
-	fm10k_mbx_update_max_size(mbx, 0);
+	fm10k_fifo_drop_all(&mbx->tx);
 
 	fm10k_write_reg(hw, mbx->mbmem_reg, 0);
 }
-- 
2.4.3
