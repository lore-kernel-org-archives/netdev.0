From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH v2 net 2/2] tg3: Fix data corruption on 5725 with TSO
Date: Mon, 13 May 2013 14:04:16 -0700
Message-ID: <1368479056-11780-3-git-send-email-nsujir@broadcom.com>
References: <1368479056-11780-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	stable@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4040 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752552Ab3EMVE3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 May 2013 17:04:29 -0400
In-Reply-To: <1368479056-11780-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <mchan@broadcom.com>

The 5725 family of devices (asic rev 5762), corrupts TSO packets where
the buffer is within MSS bytes of a 4G boundary (4G, 8G etc.). Detect
this condition and trigger the workaround path.

Cc: <stable@vger.kernel.org>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 781be76..e285d76 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -7448,6 +7448,20 @@ static inline int tg3_4g_overflow_test(dma_addr_t mapping, int len)
 	return (base > 0xffffdcc0) && (base + len + 8 < base);
 }
 
+/* Test for TSO DMA buffers that cross into regions which are within MSS bytes
+ * of any 4GB boundaries: 4G, 8G, etc
+ */
+static inline int tg3_4g_tso_overflow_test(struct tg3 *tp, dma_addr_t mapping,
+					   u32 len, u32 mss)
+{
+	if (tg3_asic_rev(tp) == ASIC_REV_5762 && mss) {
+		u32 base = (u32) mapping & 0xffffffff;
+
+		return ((base + len + (mss & 0x3fff)) < base);
+	}
+	return 0;
+}
+
 /* Test for DMA addresses > 40-bit */
 static inline int tg3_40bit_overflow_test(struct tg3 *tp, dma_addr_t mapping,
 					  int len)
@@ -7484,6 +7498,9 @@ static bool tg3_tx_frag_set(struct tg3_napi *tnapi, u32 *entry, u32 *budget,
 	if (tg3_4g_overflow_test(map, len))
 		hwbug = true;
 
+	if (tg3_4g_tso_overflow_test(tp, map, len, mss))
+		hwbug = true;
+
 	if (tg3_40bit_overflow_test(tp, map, len))
 		hwbug = true;
 
-- 
1.8.1.4
