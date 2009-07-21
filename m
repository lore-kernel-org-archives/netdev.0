From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 1/10] bnx2x: Stop management traffic in loopback test
Date: Tue, 21 Jul 2009 18:47:22 +0300
Message-ID: <1248191242.18195.39.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2313 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755369AbZGUPrh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jul 2009 11:47:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since management traffic cannot go on the wire while configured to loopback,
simply stop it to avoid race condition when the MAC is set to loopback in the
middle of a packet

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   11 +++++++++++
 drivers/net/bnx2x_reg.h  |    2 ++
 2 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 6c67be6..177cb46 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -9691,8 +9691,15 @@ static void bnx2x_self_test(struct net_device *dev,
 		etest->flags &= ~ETH_TEST_FL_OFFLINE;
 
 	if (etest->flags & ETH_TEST_FL_OFFLINE) {
+		int port = BP_PORT(bp);
+		u32 val;
 		u8 link_up;
 
+		/* save current value of input enable for TX port IF */
+		val = REG_RD(bp, NIG_REG_EGRESS_UMP0_IN_EN + port*4);
+		/* disable input for TX port IF */
+		REG_WR(bp, NIG_REG_EGRESS_UMP0_IN_EN + port*4, 0);
+
 		link_up = bp->link_vars.link_up;
 		bnx2x_nic_unload(bp, UNLOAD_NORMAL);
 		bnx2x_nic_load(bp, LOAD_DIAG);
@@ -9712,6 +9719,10 @@ static void bnx2x_self_test(struct net_device *dev,
 			etest->flags |= ETH_TEST_FL_FAILED;
 
 		bnx2x_nic_unload(bp, UNLOAD_NORMAL);
+
+		/* restore input for TX port IF */
+		REG_WR(bp, NIG_REG_EGRESS_UMP0_IN_EN + port*4, val);
+
 		bnx2x_nic_load(bp, LOAD_NORMAL);
 		/* wait until link state is restored */
 		bnx2x_wait_for_link(bp, link_up);
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index b8ce6fc..6d77730 100644
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -1660,6 +1660,8 @@
 #define NIG_REG_EGRESS_PBF0_IN_EN				 0x100cc
 /* [RW 1] Input enable for TX PBF user packet port1 IF */
 #define NIG_REG_EGRESS_PBF1_IN_EN				 0x100d0
+/* [RW 1] Input enable for TX UMP management packet port0 IF */
+#define NIG_REG_EGRESS_UMP0_IN_EN				 0x100d4
 /* [RW 1] Input enable for RX_EMAC0 IF */
 #define NIG_REG_EMAC0_IN_EN					 0x100a4
 /* [RW 1] output enable for TX EMAC pause port 0 IF */
-- 
1.5.4.3




