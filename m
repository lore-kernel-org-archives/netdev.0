From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 3/5] cnic: Eliminate CNIC_PORT macro and
 port_mode in local struct.
Date: Mon, 2 Sep 2013 11:42:30 -0700
Message-ID: <1378147352-9076-4-git-send-email-mchan@broadcom.com>
References: <1378147352-9076-1-git-send-email-mchan@broadcom.com>
 <1378147352-9076-2-git-send-email-mchan@broadcom.com>
 <1378147352-9076-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4757 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755806Ab3IBSWU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 14:22:20 -0400
In-Reply-To: <1378147352-9076-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use BP_PORT and chip_port_mode directly from bnx2x.h to avoid duplication.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c |   13 ++++++-------
 drivers/net/ethernet/broadcom/cnic.h |    2 --
 2 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 750b9a6..435a167 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -1695,7 +1695,7 @@ static int cnic_setup_bnx2x_ctx(struct cnic_dev *dev, struct kwqe *wqes[],
 	struct iscsi_context *ictx;
 	struct regpair context_addr;
 	int i, j, n = 2, n_max;
-	u8 port = CNIC_PORT(cp);
+	u8 port = BP_PORT(bp);
 
 	ctx->ctx_flags = 0;
 	if (!req2->num_additional_wqes)
@@ -1750,7 +1750,7 @@ static int cnic_setup_bnx2x_ctx(struct cnic_dev *dev, struct kwqe *wqes[],
 	ictx->xstorm_st_context.common.ethernet.reserved_vlan_type =
 		ETH_P_8021Q;
 	if (BNX2X_CHIP_IS_E2_PLUS(bp) &&
-		cp->port_mode == CHIP_2_PORT_MODE) {
+	    bp->common.chip_port_mode == CHIP_2_PORT_MODE) {
 
 		port = 0;
 	}
@@ -3050,8 +3050,8 @@ static irqreturn_t cnic_irq(int irq, void *dev_instance)
 static inline void cnic_ack_bnx2x_int(struct cnic_dev *dev, u8 id, u8 storm,
 				      u16 index, u8 op, u8 update)
 {
-	struct cnic_local *cp = dev->cnic_priv;
-	u32 hc_addr = (HC_REG_COMMAND_REG + CNIC_PORT(cp) * 32 +
+	struct bnx2x *bp = netdev_priv(dev->netdev);
+	u32 hc_addr = (HC_REG_COMMAND_REG + BP_PORT(bp) * 32 +
 		       COMMAND_REG_INT_ACK);
 	struct igu_ack_register igu_ack;
 
@@ -4231,7 +4231,7 @@ static int cnic_cm_init_bnx2x_hw(struct cnic_dev *dev)
 	struct cnic_local *cp = dev->cnic_priv;
 	struct bnx2x *bp = netdev_priv(dev->netdev);
 	u32 pfid = cp->pfid;
-	u32 port = CNIC_PORT(cp);
+	u32 port = BP_PORT(bp);
 
 	cnic_init_bnx2x_mac(dev);
 	cnic_bnx2x_set_tcp_options(dev, 0, 1);
@@ -5090,7 +5090,6 @@ static int cnic_start_bnx2x_hw(struct cnic_dev *dev)
 	u32 pfid;
 
 	dev->stats_addr = ethdev->addr_drv_info_to_mcp;
-	cp->port_mode = bp->common.chip_port_mode;
 	cp->pfid = bp->pfid;
 	cp->func = bp->pf_num;
 
@@ -5190,7 +5189,7 @@ static void cnic_init_rings(struct cnic_dev *dev)
 		off = BAR_USTRORM_INTMEM +
 			(BNX2X_CHIP_IS_E2_PLUS(bp) ?
 			 USTORM_RX_PRODS_E2_OFFSET(cl_qzone_id) :
-			 USTORM_RX_PRODS_E1X_OFFSET(CNIC_PORT(cp), cli));
+			 USTORM_RX_PRODS_E1X_OFFSET(BP_PORT(bp), cli));
 
 		for (i = 0; i < sizeof(struct ustorm_eth_rx_producers) / 4; i++)
 			CNIC_WR(dev, off + i * 4, ((u32 *) &rx_prods)[i]);
diff --git a/drivers/net/ethernet/broadcom/cnic.h b/drivers/net/ethernet/broadcom/cnic.h
index 0408ae2..10531f6 100644
--- a/drivers/net/ethernet/broadcom/cnic.h
+++ b/drivers/net/ethernet/broadcom/cnic.h
@@ -304,7 +304,6 @@ struct cnic_local {
 	u32			chip_id;
 	int			func;
 	u32			pfid;
-	u8			port_mode;
 
 	u32			shmem_base;
 
@@ -399,7 +398,6 @@ struct bnx2x_bd_chain_next {
 #define ETH_MAX_RX_CLIENTS_E2 		ETH_MAX_RX_CLIENTS_E1H
 #endif
 
-#define CNIC_PORT(cp)			((cp)->pfid & 1)
 #define CNIC_FUNC(cp)			((cp)->func)
 
 #define BNX2X_HW_CID(bp, x)		((BP_PORT(bp) << 23) | \
-- 
1.7.1
