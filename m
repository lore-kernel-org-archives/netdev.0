From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 1/7] qlge: Fix RSS hashing values.
Date: Thu,  8 Oct 2009 12:54:37 -0700
Message-ID: <1255031683-3912-2-git-send-email-ron.mercer@qlogic.com>
References: <1255031683-3912-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:40572 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932988AbZJHUBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 16:01:30 -0400
In-Reply-To: <1255031683-3912-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix RX queue table size and change from random to default hash values.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |    2 +-
 drivers/net/qlge/qlge_main.c |   22 ++++++++++++----------
 2 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 3ec6e85..567b5d6 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -1168,7 +1168,7 @@ struct ricb {
 #define RSS_RI6 0x40
 #define RSS_RT6 0x80
 	__le16 mask;
-	__le32 hash_cq_id[256];
+	u8 hash_cq_id[1024];
 	__le32 ipv6_hash_key[10];
 	__le32 ipv4_hash_key[4];
 } __attribute((packed));
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 6168071..04fc711 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3077,6 +3077,12 @@ err_irq:
 
 static int ql_start_rss(struct ql_adapter *qdev)
 {
+	u8 init_hash_seed[] = {0x6d, 0x5a, 0x56, 0xda, 0x25, 0x5b, 0x0e, 0xc2,
+				0x41, 0x67, 0x25, 0x3d, 0x43, 0xa3, 0x8f,
+				0xb0, 0xd0, 0xca, 0x2b, 0xcb, 0xae, 0x7b,
+				0x30, 0xb4, 0x77, 0xcb, 0x2d, 0xa3, 0x80,
+				0x30, 0xf2, 0x0c, 0x6a, 0x42, 0xb7, 0x3b,
+				0xbe, 0xac, 0x01, 0xfa};
 	struct ricb *ricb = &qdev->ricb;
 	int status = 0;
 	int i;
@@ -3086,21 +3092,17 @@ static int ql_start_rss(struct ql_adapter *qdev)
 
 	ricb->base_cq = RSS_L4K;
 	ricb->flags =
-	    (RSS_L6K | RSS_LI | RSS_LB | RSS_LM | RSS_RI4 | RSS_RI6 | RSS_RT4 |
-	     RSS_RT6);
-	ricb->mask = cpu_to_le16(qdev->rss_ring_count - 1);
+		(RSS_L6K | RSS_LI | RSS_LB | RSS_LM | RSS_RT4 | RSS_RT6);
+	ricb->mask = cpu_to_le16((u16)(0x3ff));
 
 	/*
 	 * Fill out the Indirection Table.
 	 */
-	for (i = 0; i < 256; i++)
-		hash_id[i] = i & (qdev->rss_ring_count - 1);
+	for (i = 0; i < 1024; i++)
+		hash_id[i] = (i & (qdev->rss_ring_count - 1));
 
-	/*
-	 * Random values for the IPv6 and IPv4 Hash Keys.
-	 */
-	get_random_bytes((void *)&ricb->ipv6_hash_key[0], 40);
-	get_random_bytes((void *)&ricb->ipv4_hash_key[0], 16);
+	memcpy((void *)&ricb->ipv6_hash_key[0], init_hash_seed, 40);
+	memcpy((void *)&ricb->ipv4_hash_key[0], init_hash_seed, 16);
 
 	QPRINTK(qdev, IFUP, DEBUG, "Initializing RSS.\n");
 
-- 
1.6.0.2

