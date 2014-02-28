From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net] tg3: Don't check undefined error bits in RXBD
Date: Fri, 28 Feb 2014 15:05:10 -0800
Message-ID: <1393628710-5476-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:10699 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751711AbaB1Vqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 16:46:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Redefine the RXD_ERR_MASK to include only relevant error bits. This fixes
a customer reported issue of randomly dropping packets on the 5719.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---

Please consider adding this to -stable.

 drivers/net/ethernet/broadcom/tg3.c |    3 +--
 drivers/net/ethernet/broadcom/tg3.h |    6 +++++-
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 3167ed6..3b6d0ba 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6843,8 +6843,7 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 
 		work_mask |= opaque_key;
 
-		if ((desc->err_vlan & RXD_ERR_MASK) != 0 &&
-		    (desc->err_vlan != RXD_ERR_ODD_NIBBLE_RCVD_MII)) {
+		if (desc->err_vlan & RXD_ERR_MASK) {
 		drop_it:
 			tg3_recycle_rx(tnapi, tpr, opaque_key,
 				       desc_idx, *post_ptr);
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index ef47238..04321e5 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -2608,7 +2608,11 @@ struct tg3_rx_buffer_desc {
 #define RXD_ERR_TOO_SMALL		0x00400000
 #define RXD_ERR_NO_RESOURCES		0x00800000
 #define RXD_ERR_HUGE_FRAME		0x01000000
-#define RXD_ERR_MASK			0xffff0000
+
+#define RXD_ERR_MASK	(RXD_ERR_BAD_CRC | RXD_ERR_COLLISION |		\
+			 RXD_ERR_LINK_LOST | RXD_ERR_PHY_DECODE |	\
+			 RXD_ERR_MAC_ABRT | RXD_ERR_TOO_SMALL |		\
+			 RXD_ERR_NO_RESOURCES | RXD_ERR_HUGE_FRAME)
 
 	u32				reserved;
 	u32				opaque;
-- 
1.7.1
