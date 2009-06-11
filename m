From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [2.6.31 08/21] wimax/i2400m: fix panic/warnings caused by missed check on empty TX message
Date: Thu, 11 Jun 2009 14:35:45 -0700
Message-ID: <c56affafdd29eb9764b0e35e3434cc06f6bc3781.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:17677 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751590AbZFKVgj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 17:36:39 -0400
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In some situations, when a new TX message header is started, there
might be no space for data payloads. In this case the message is left
with zero payloads and the i2400m_tx_close() function has just to mark
it as "to skip". If it tries to go ahead it will overwrite things
because there is no space to add padding as defined by the
bus-specific layer. This can cause buffer overruns and in some stress
cases, panics.

Found and diagnosed by Cindy H. Kao.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/tx.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wimax/i2400m/tx.c b/drivers/net/wimax/i2400m/tx.c
index a635fd7..7c46c05 100644
--- a/drivers/net/wimax/i2400m/tx.c
+++ b/drivers/net/wimax/i2400m/tx.c
@@ -474,10 +474,18 @@ void i2400m_tx_close(struct i2400m *i2400m)
 	struct i2400m_msg_hdr *tx_msg_moved;
 	size_t aligned_size, padding, hdr_size;
 	void *pad_buf;
+	unsigned num_pls;
 
 	if (tx_msg->size & I2400M_TX_SKIP)	/* a skipper? nothing to do */
 		goto out;
-
+	num_pls = le16_to_cpu(tx_msg->num_pls);
+	/* We can get this situation when a new message was started
+	 * and there was no space to add payloads before hitting the
+	 tail (and taking padding into consideration). */
+	if (num_pls == 0) {
+		tx_msg->size |= I2400M_TX_SKIP;
+		goto out;
+	}
 	/* Relocate the message header
 	 *
 	 * Find the current header size, align it to 16 and if we need
-- 
1.6.2.3

