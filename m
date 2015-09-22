From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/17] fm10k: create "correct" header for the remote end on connect
Date: Tue, 22 Sep 2015 16:54:24 -0700
Message-ID: <1442966076-14359-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442966076-14359-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:63267 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934862AbbIVXyk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2015 19:54:40 -0400
In-Reply-To: <1442966076-14359-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

When we connect to the mailbox, we insert a fake disconnect header so
that the code does not see an invalid header and thus instantly error
every time we bring up the mailbox. However, we incorrectly record the
tail and head from the local perspective. Since the remote end shouldn't
have anything for us, add a "create_fake_disconnect_hdr" function which
inverts the TAIL and HEAD fields. This enables us to connect without any
errors of either TAIL or HEAD incorrectness, and prevents creating
extraneous error messages. This is necessary now since mbx_reset_work
does not actually reset the Tx FIFO head and tail pointers, thus head
and tail might not be equivalent on a reconnect.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.c | 25 ++++++++++++++++++++++++-
 1 file changed, 24 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
index 0ff21d1..5403d86 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
@@ -899,6 +899,27 @@ static void fm10k_mbx_create_disconnect_hdr(struct fm10k_mbx_info *mbx)
 }
 
 /**
+ *  fm10k_mbx_create_fake_disconnect_hdr - Generate a false disconnect mailbox header
+ *  @mbx: pointer to mailbox
+ *
+ *  This function creates a fake disconnect header for loading into remote
+ *  mailbox header. The primary purpose is to prevent errors on immediate
+ *  start up after mbx->connect.
+ **/
+static void fm10k_mbx_create_fake_disconnect_hdr(struct fm10k_mbx_info *mbx)
+{
+	u32 hdr = FM10K_MSG_HDR_FIELD_SET(FM10K_MSG_DISCONNECT, TYPE) |
+		  FM10K_MSG_HDR_FIELD_SET(mbx->head, TAIL) |
+		  FM10K_MSG_HDR_FIELD_SET(mbx->tail, HEAD);
+	u16 crc = fm10k_crc_16b(&hdr, mbx->local, 1);
+
+	mbx->mbx_lock |= FM10K_MBX_ACK;
+
+	/* load header to memory to be written */
+	mbx->mbx_hdr = hdr | FM10K_MSG_HDR_FIELD_SET(crc, CRC);
+}
+
+/**
  *  fm10k_mbx_create_error_msg - Generate a error message
  *  @mbx: pointer to mailbox
  *  @err: local error encountered
@@ -1435,8 +1456,10 @@ static s32 fm10k_mbx_connect(struct fm10k_hw *hw, struct fm10k_mbx_info *mbx)
 	/* Place mbx in ready to connect state */
 	mbx->state = FM10K_STATE_CONNECT;
 
+	fm10k_mbx_reset_work(mbx);
+
 	/* initialize header of remote mailbox */
-	fm10k_mbx_create_disconnect_hdr(mbx);
+	fm10k_mbx_create_fake_disconnect_hdr(mbx);
 	fm10k_write_reg(hw, mbx->mbmem_reg ^ mbx->mbmem_len, mbx->mbx_hdr);
 
 	/* enable interrupt and notify other party of new message */
-- 
2.4.3
