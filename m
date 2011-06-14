From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next 4/24] bnx2x: put start bd csum in separate
 function
Date: Tue, 14 Jun 2011 14:33:02 +0300
Message-ID: <201106141433.02429.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2143 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755901Ab1FNLdq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2011 07:33:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c |   34 ++++++++++++++++++++--------------
 1 files changed, 20 insertions(+), 14 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 3742514..d8e6571 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -2134,6 +2134,24 @@ static inline  u8 bnx2x_set_pbd_csum_e2(struct bnx2x *bp, struct sk_buff *skb,
 				sizeof(struct udphdr) - skb->data;
 }
 
+static inline void bnx2x_set_sbd_csum(struct bnx2x *bp, struct sk_buff *skb,
+	struct eth_tx_start_bd *tx_start_bd, u32 xmit_type)
+{
+
+	tx_start_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_L4_CSUM;
+
+	if (xmit_type & XMIT_CSUM_V4)
+		tx_start_bd->bd_flags.as_bitfield |=
+					ETH_TX_BD_FLAGS_IP_CSUM;
+	else
+		tx_start_bd->bd_flags.as_bitfield |=
+					ETH_TX_BD_FLAGS_IPV6;
+
+	if (!(xmit_type & XMIT_CSUM_TCP))
+		tx_start_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_IS_UDP;
+
+}
+
 /**
  * bnx2x_set_pbd_csum - update PBD with checksum and return header length
  *
@@ -2305,20 +2323,8 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* turn on parsing and get a BD */
 	bd_prod = TX_BD(NEXT_TX_IDX(bd_prod));
 
-	if (xmit_type & XMIT_CSUM) {
-		tx_start_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_L4_CSUM;
-
-		if (xmit_type & XMIT_CSUM_V4)
-			tx_start_bd->bd_flags.as_bitfield |=
-						ETH_TX_BD_FLAGS_IP_CSUM;
-		else
-			tx_start_bd->bd_flags.as_bitfield |=
-						ETH_TX_BD_FLAGS_IPV6;
-
-		if (!(xmit_type & XMIT_CSUM_TCP))
-			tx_start_bd->bd_flags.as_bitfield |=
-						ETH_TX_BD_FLAGS_IS_UDP;
-	}
+	if (xmit_type & XMIT_CSUM)
+		bnx2x_set_sbd_csum(bp, skb, tx_start_bd, xmit_type);
 
 	if (CHIP_IS_E2(bp)) {
 		pbd_e2 = &fp->tx_desc_ring[bd_prod].parse_bd_e2;
-- 
1.7.2.2


