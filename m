From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH] iwl4965: Fix a null pointer dereference in il_tx_queue_free and il_cmd_queue_free
Date: Thu,  7 Jan 2016 19:51:38 +0800
Message-ID: <1452167498-10823-1-git-send-email-baijiaju1990@163.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jia-Ju Bai <baijiaju1990@163.com>
To: sgruszka@redhat.com, kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-17.163.com ([220.181.12.17]:39162 "EHLO m12-17.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752052AbcAGLvo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jan 2016 06:51:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If "txq->cmd = kzalloc(...)" in il_tx_queue_init fails, 
"kfree(txq->cmd[i])" in il_tx_queue_free and il_cmd_queue_free 
in iwl4965_hw_txq_ctx_free will causes a null pointer dereference,
because txq->cmd is NULL at that time.

This patch fixes this problem by adding a if-check before kfree.
To avoid double free in il_tx_queue_free and il_cmd_queue_free 
caused by the fixing, txq->cmd[i], txq->meta and txq->cmd in
error handling code of il_tx_queue_init are assigned null values.
Otherwise, a double free will occur.

This patch has been tested in real device, and it actually fixes the bug.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
 drivers/net/wireless/iwlegacy/common.c |   18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/iwlegacy/common.c b/drivers/net/wireless/iwlegacy/common.c
index 8871145..2656a15 100644
--- a/drivers/net/wireless/iwlegacy/common.c
+++ b/drivers/net/wireless/iwlegacy/common.c
@@ -2794,8 +2794,10 @@ il_tx_queue_free(struct il_priv *il, int txq_id)
 	il_tx_queue_unmap(il, txq_id);
 
 	/* De-alloc array of command/tx buffers */
-	for (i = 0; i < TFD_TX_CMD_SLOTS; i++)
-		kfree(txq->cmd[i]);
+	if (txq->cmd) {
+		for (i = 0; i < TFD_TX_CMD_SLOTS; i++)
+			kfree(txq->cmd[i]);
+	}
 
 	/* De-alloc circular buffer of TFDs */
 	if (txq->q.n_bd)
@@ -2873,8 +2875,10 @@ il_cmd_queue_free(struct il_priv *il)
 	il_cmd_queue_unmap(il);
 
 	/* De-alloc array of command/tx buffers */
-	for (i = 0; i <= TFD_CMD_SLOTS; i++)
-		kfree(txq->cmd[i]);
+	if (txq->cmd) {
+		for (i = 0; i <= TFD_CMD_SLOTS; i++)
+			kfree(txq->cmd[i]);
+	}
 
 	/* De-alloc circular buffer of TFDs */
 	if (txq->q.n_bd)
@@ -3076,11 +3080,15 @@ il_tx_queue_init(struct il_priv *il, u32 txq_id)
 
 	return 0;
 err:
-	for (i = 0; i < actual_slots; i++)
+	for (i = 0; i < actual_slots; i++) {
 		kfree(txq->cmd[i]);
+		txq->cmd[i] = NULL;
+	}
 out_free_arrays:
 	kfree(txq->meta);
+	txq->meta = NULL;
 	kfree(txq->cmd);
+	txq->cmd = NULL;
 
 	return -ENOMEM;
 }
-- 
1.7.9.5
