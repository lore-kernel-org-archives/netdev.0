From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.35 11/25] wimax/i2400m: limit the message size upto 16KiB [v1]
Date: Fri, 14 May 2010 14:45:10 -0700
Message-ID: <a40242f2cde38ccb04d4c35cad66aab3c047fa6a.1273708027.git.inaky.perez-gonzalez@intel.com>
References: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Cc: "Prasanna S. Panchamukhi" <prasannax.s.panchamukhi@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:52953 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932461Ab0ENVtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 17:49:12 -0400
In-Reply-To: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prasanna S. Panchamukhi <prasannax.s.panchamukhi@intel.com>

According to Intel Wimax i3200, i5x50 and i6x50 specification
documents, the maximum size of each TX message can be upto 16KiB.
This patch modifies the i2400m_tx() routine to check that the
message size does not exceed the 16KiB limit.
Please refer the documentation in the code for details.

Signed-off-by: Prasanna S. Panchamukhi <prasannax.s.panchamukhi@intel.com>
---
 drivers/net/wimax/i2400m/tx.c |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wimax/i2400m/tx.c b/drivers/net/wimax/i2400m/tx.c
index b10c3b7..a5002c8 100644
--- a/drivers/net/wimax/i2400m/tx.c
+++ b/drivers/net/wimax/i2400m/tx.c
@@ -283,6 +283,11 @@ enum {
 	+ I2400M_TX_PLD_MAX * sizeof(struct i2400m_pld),
 	I2400M_TX_SKIP = 0x80000000,
 	/*
+	 * According to Intel Wimax i3200, i5x50 and i6x50 specification
+	 * documents, the maximum size of each message can be up to 16KiB.
+	 */
+	I2400M_TX_MSG_SIZE = 16384,
+	/*
 	 * 16 byte aligned MAX_MTU + 4 byte payload prefix.
 	 */
 	I2400M_MAX_MTU_ALIGN = 16,
@@ -682,7 +687,13 @@ try_new:
 	}
 	if (i2400m->tx_msg == NULL)
 		goto error_tx_new;
-	if (i2400m->tx_msg->size + padded_len > I2400M_TX_BUF_SIZE / 2) {
+	/*
+	 * Check if this skb will fit in the TX queue's current active
+	 * TX message. The total message size must not exceed the maximum
+	 * size of each message I2400M_TX_MSG_SIZE. If it exceeds,
+	 * close the current message and push this skb into the new message.
+	 */
+	if (i2400m->tx_msg->size + padded_len > I2400M_TX_MSG_SIZE) {
 		d_printf(2, dev, "TX: message too big, going new\n");
 		i2400m_tx_close(i2400m);
 		i2400m_tx_new(i2400m);
-- 
1.6.6.1

