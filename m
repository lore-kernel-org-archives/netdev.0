From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.35 12/25] wimax/i2400m: fix BUILD_BUG_ON() to use the maximum message size constant [v1]
Date: Fri, 14 May 2010 14:45:11 -0700
Message-ID: <718e94907d79e74bbc7cfdb3cda2266079c5e993.1273708027.git.inaky.perez-gonzalez@intel.com>
References: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Cc: "Prasanna S. Panchamukhi" <prasannax.s.panchamukhi@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:52953 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932323Ab0ENVtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 17:49:13 -0400
In-Reply-To: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prasanna S. Panchamukhi <prasannax.s.panchamukhi@intel.com>

The older method of computing the maximum PDU size relied
on a method that doesn't work when we prop the maximum
number of payloads up to the physical limit, and thus we kill
the whole computation and just verify that the constants are
congruent.

Signed-off-by: Prasanna S. Panchamukhi <prasannax.s.panchamukhi@intel.com>
---
 drivers/net/wimax/i2400m/tx.c |   20 +++++---------------
 1 files changed, 5 insertions(+), 15 deletions(-)

diff --git a/drivers/net/wimax/i2400m/tx.c b/drivers/net/wimax/i2400m/tx.c
index a5002c8..1725f2b 100644
--- a/drivers/net/wimax/i2400m/tx.c
+++ b/drivers/net/wimax/i2400m/tx.c
@@ -287,19 +287,6 @@ enum {
 	 * documents, the maximum size of each message can be up to 16KiB.
 	 */
 	I2400M_TX_MSG_SIZE = 16384,
-	/*
-	 * 16 byte aligned MAX_MTU + 4 byte payload prefix.
-	 */
-	I2400M_MAX_MTU_ALIGN = 16,
-	I2400M_TX_PDU_SIZE = I2400M_MAX_MTU % I2400M_MAX_MTU_ALIGN
-	+ I2400M_MAX_MTU + sizeof(struct i2400m_pl_data_hdr),
-	 /*
-	  * 256 byte aligned toal size of 12 PDUs including msg header,
-	  */
-	I2400M_TX_PDU_ALIGN = 256,
-	I2400M_TX_PDU_TOTAL_SIZE = ((I2400M_TX_PDU_SIZE * I2400M_TX_PLD_MAX
-	+ sizeof(struct i2400m_msg_hdr))/I2400M_TX_PDU_ALIGN + 1)
-	* I2400M_TX_PDU_ALIGN * 2,
 };
 
 #define TAIL_FULL ((void *)~(unsigned long)NULL)
@@ -915,8 +902,11 @@ int i2400m_tx_setup(struct i2400m *i2400m)
 		goto error_kmalloc;
 	}
 
-	 /* Warn if the calculated buffer size exceeds I2400M_TX_BUF_SIZE. */
-	BUILD_BUG_ON(I2400M_TX_PDU_TOTAL_SIZE > I2400M_TX_BUF_SIZE);
+	/*
+	 * Fail the build if we can't fit at least two maximum size messages
+	 * on the TX FIFO [one being delivered while one is constructed].
+	 */
+	BUILD_BUG_ON(2 * I2400M_TX_MSG_SIZE > I2400M_TX_BUF_SIZE);
 	spin_lock_irqsave(&i2400m->tx_lock, flags);
 	i2400m->tx_sequence = 0;
 	i2400m->tx_in = 0;
-- 
1.6.6.1

