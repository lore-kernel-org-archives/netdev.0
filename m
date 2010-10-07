From: leitao@linux.vnet.ibm.com
Subject: [PATCH] ehea: Fix a checksum issue on the receive path
Date: Thu,  7 Oct 2010 19:17:33 -0400
Message-ID: <1286493453-21784-1-git-send-email-leitao@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, Breno Leitao <leitao@linux.vnet.ibm.com>,
	Jay Vosburgh <fubar@us.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp05.br.ibm.com ([32.104.18.26]:42260 "EHLO
	e24smtp05.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754602Ab0JGXR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 19:17:58 -0400
Received: from mailhub1.br.ibm.com (mailhub1.br.ibm.com [9.18.232.109])
	by e24smtp05.br.ibm.com (8.14.4/8.13.1) with ESMTP id o97NC2I5020076
	for <netdev@vger.kernel.org>; Thu, 7 Oct 2010 20:12:02 -0300
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o97NO5Hm516240
	for <netdev@vger.kernel.org>; Thu, 7 Oct 2010 20:24:05 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o97NHfbx032358
	for <netdev@vger.kernel.org>; Thu, 7 Oct 2010 20:17:42 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we set all skbs with CHECKSUM_UNNECESSARY, even
those whose protocol we don't know. This patch just
add the CHECKSUM_COMPLETE tag for non TCP/UDP packets.

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/ehea/ehea_main.c |    9 ++++++++-
 drivers/net/ehea/ehea_qmr.h  |    1 +
 2 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 0471cae..45fd045 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -533,8 +533,15 @@ static inline void ehea_fill_skb(struct net_device *dev,
 	int length = cqe->num_bytes_transfered - 4;	/*remove CRC */
 
 	skb_put(skb, length);
-	skb->ip_summed = CHECKSUM_UNNECESSARY;
 	skb->protocol = eth_type_trans(skb, dev);
+
+	/* The packet was not an IPV4 packet so a complemented checksum was
+	   calculated. The value is found in the Internet Checksum field. */
+	if (cqe->status & EHEA_CQE_BLIND_CKSUM) {
+		skb->ip_summed = CHECKSUM_COMPLETE;
+		skb->csum = csum_unfold(~cqe->inet_checksum_value);
+	} else
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
 }
 
 static inline struct sk_buff *get_skb_by_index(struct sk_buff **skb_array,
diff --git a/drivers/net/ehea/ehea_qmr.h b/drivers/net/ehea/ehea_qmr.h
index f608a6c..3810473 100644
--- a/drivers/net/ehea/ehea_qmr.h
+++ b/drivers/net/ehea/ehea_qmr.h
@@ -150,6 +150,7 @@ struct ehea_rwqe {
 #define EHEA_CQE_TYPE_RQ           0x60
 #define EHEA_CQE_STAT_ERR_MASK     0x700F
 #define EHEA_CQE_STAT_FAT_ERR_MASK 0xF
+#define EHEA_CQE_BLIND_CKSUM       0x8000
 #define EHEA_CQE_STAT_ERR_TCP      0x4000
 #define EHEA_CQE_STAT_ERR_IP       0x2000
 #define EHEA_CQE_STAT_ERR_CRC      0x1000
-- 
1.6.5

