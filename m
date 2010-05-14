From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.35 13/25] wimax/i2400m: modify i2400m_tx_fifo_push() to check for head room space in the TX FIFO [v1]
Date: Fri, 14 May 2010 14:45:12 -0700
Message-ID: <9e6e3bd52b0f77ca5cc385892c14ff8ba5ecfa67.1273708027.git.inaky.perez-gonzalez@intel.com>
References: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Cc: "Prasanna S. Panchamukhi" <prasannax.s.panchamukhi@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:52953 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932522Ab0ENVtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 17:49:13 -0400
In-Reply-To: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prasanna S. Panchamukhi <prasannax.s.panchamukhi@intel.com>

This fixes i2400m_tx_fifo_push(); the check for having enough
space in the TX FIFO's tail was obscure and broken in certain
corner cases. The new check works in all cases and is way
clearer. Please refer the documentation in the code for details.

Signed-off-by: Prasanna S. Panchamukhi <prasannax.s.panchamukhi@intel.com>
---
 drivers/net/wimax/i2400m/tx.c |   16 ++++++++++++++--
 1 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wimax/i2400m/tx.c b/drivers/net/wimax/i2400m/tx.c
index 1725f2b..101550a 100644
--- a/drivers/net/wimax/i2400m/tx.c
+++ b/drivers/net/wimax/i2400m/tx.c
@@ -396,8 +396,20 @@ void *i2400m_tx_fifo_push(struct i2400m *i2400m, size_t size, size_t padding)
 	/* Is there space at the tail? */
 	tail_room = __i2400m_tx_tail_room(i2400m);
 	if (tail_room < needed_size) {
-		if (i2400m->tx_out % I2400M_TX_BUF_SIZE
-		    < i2400m->tx_in % I2400M_TX_BUF_SIZE) {
+		/*
+		 * If the tail room space is not enough to push the message
+		 * in the TX FIFO, then there are two possibilities:
+		 * 1. There is enough head room space to accommodate
+		 * this message in the TX FIFO.
+		 * 2. There is not enough space in the head room and
+		 * in tail room of the TX FIFO to accommodate the message.
+		 * In the case (1), return TAIL_FULL so that the caller
+		 * can figure out, if the caller wants to push the message
+		 * into the head room space.
+		 * In the case (2), return NULL, indicating that the TX FIFO
+		 * cannot accommodate the message.
+		 */
+		if (room - tail_room >= needed_size) {
 			d_printf(2, dev, "fifo push %zu/%zu: tail full\n",
 				 size, padding);
 			return TAIL_FULL;	/* There might be head space */
-- 
1.6.6.1

