From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [2.6.31 07/21] wimax/i2400m: rename misleading I2400M_PL_PAD to I2400M_PL_ALIGN
Date: Thu, 11 Jun 2009 14:35:44 -0700
Message-ID: <8593a1967fb9746d318dde88a0a39a36dbfc3445.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28457 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751567AbZFKVgj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 17:36:39 -0400
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The constant is being use as an alignment factor, not as a padding
factor; made reading/reviewing the code quite confusing.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/fw.c |    2 +-
 drivers/net/wimax/i2400m/rx.c |    4 ++--
 drivers/net/wimax/i2400m/tx.c |    4 ++--
 include/linux/wimax/i2400m.h  |    2 +-
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wimax/i2400m/fw.c b/drivers/net/wimax/i2400m/fw.c
index 7ee1b99..26924f1 100644
--- a/drivers/net/wimax/i2400m/fw.c
+++ b/drivers/net/wimax/i2400m/fw.c
@@ -397,7 +397,7 @@ static int i2400m_download_chunk(struct i2400m *i2400m, const void *chunk,
 				 unsigned int direct, unsigned int do_csum)
 {
 	int ret;
-	size_t chunk_len = ALIGN(__chunk_len, I2400M_PL_PAD);
+	size_t chunk_len = ALIGN(__chunk_len, I2400M_PL_ALIGN);
 	struct device *dev = i2400m_dev(i2400m);
 	struct {
 		struct i2400m_bootrom_header cmd;
diff --git a/drivers/net/wimax/i2400m/rx.c b/drivers/net/wimax/i2400m/rx.c
index 7643850..07c32e6 100644
--- a/drivers/net/wimax/i2400m/rx.c
+++ b/drivers/net/wimax/i2400m/rx.c
@@ -1148,7 +1148,7 @@ int i2400m_rx(struct i2400m *i2400m, struct sk_buff *skb)
 	num_pls = le16_to_cpu(msg_hdr->num_pls);
 	pl_itr = sizeof(*msg_hdr) +	/* Check payload descriptor(s) */
 		num_pls * sizeof(msg_hdr->pld[0]);
-	pl_itr = ALIGN(pl_itr, I2400M_PL_PAD);
+	pl_itr = ALIGN(pl_itr, I2400M_PL_ALIGN);
 	if (pl_itr > skb->len) {	/* got all the payload descriptors? */
 		dev_err(dev, "RX: HW BUG? message too short (%u bytes) for "
 			"%u payload descriptors (%zu each, total %zu)\n",
@@ -1166,7 +1166,7 @@ int i2400m_rx(struct i2400m *i2400m, struct sk_buff *skb)
 		single_last = num_pls == 1 || i == num_pls - 1;
 		i2400m_rx_payload(i2400m, skb, single_last, &msg_hdr->pld[i],
 				  skb->data + pl_itr);
-		pl_itr += ALIGN(pl_size, I2400M_PL_PAD);
+		pl_itr += ALIGN(pl_size, I2400M_PL_ALIGN);
 		cond_resched();		/* Don't monopolize */
 	}
 	kfree_skb(skb);
diff --git a/drivers/net/wimax/i2400m/tx.c b/drivers/net/wimax/i2400m/tx.c
index 8ef724d..a635fd7 100644
--- a/drivers/net/wimax/i2400m/tx.c
+++ b/drivers/net/wimax/i2400m/tx.c
@@ -491,7 +491,7 @@ void i2400m_tx_close(struct i2400m *i2400m)
 	 */
 	hdr_size = sizeof(*tx_msg)
 		+ le16_to_cpu(tx_msg->num_pls) * sizeof(tx_msg->pld[0]);
-	hdr_size = ALIGN(hdr_size, I2400M_PL_PAD);
+	hdr_size = ALIGN(hdr_size, I2400M_PL_ALIGN);
 	tx_msg->offset = I2400M_TX_PLD_SIZE - hdr_size;
 	tx_msg_moved = (void *) tx_msg + tx_msg->offset;
 	memmove(tx_msg_moved, tx_msg, hdr_size);
@@ -574,7 +574,7 @@ int i2400m_tx(struct i2400m *i2400m, const void *buf, size_t buf_len,
 
 	d_fnstart(3, dev, "(i2400m %p skb %p [%zu bytes] pt %u)\n",
 		  i2400m, buf, buf_len, pl_type);
-	padded_len = ALIGN(buf_len, I2400M_PL_PAD);
+	padded_len = ALIGN(buf_len, I2400M_PL_ALIGN);
 	d_printf(5, dev, "padded_len %zd buf_len %zd\n", padded_len, buf_len);
 	/* If there is no current TX message, create one; if the
 	 * current one is out of payload slots or we have a singleton,
diff --git a/include/linux/wimax/i2400m.h b/include/linux/wimax/i2400m.h
index d5148a7..433693e 100644
--- a/include/linux/wimax/i2400m.h
+++ b/include/linux/wimax/i2400m.h
@@ -266,7 +266,7 @@ enum i2400m_ro_type {
 
 /* Misc constants */
 enum {
-	I2400M_PL_PAD = 16,	/* Payload data size alignment */
+	I2400M_PL_ALIGN = 16,	/* Payload data size alignment */
 	I2400M_PL_SIZE_MAX = 0x3EFF,
 	I2400M_MAX_PLS_IN_MSG = 60,
 	/* protocol barkers: sync sequences; for notifications they
-- 
1.6.2.3

