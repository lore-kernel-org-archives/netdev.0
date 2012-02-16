From: "Ariel Elior" <ariele@broadcom.com>
Subject: [PATCH] bnx2x: tx-switching module parameter
Date: Thu, 16 Feb 2012 16:05:12 +0200
Message-ID: <1329401112-9542-1-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Ariel Elior" <ariele@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3485 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750906Ab2BPOGZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Feb 2012 09:06:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In 57712 and 578xx the tx-switching module parameter allows the user to control
whether outgoing traffic can be loopbacked into the device in case there is a
relevant client for the data using the same device for rx.
A classic example where this is necessary is for virtualization purposes, where
one vm is transmitting data to another, while both use different pci functions of
the same port of the same nic.

In case there is a promiscuous client in the rx (which wants to receive all
data) or if the traffic is broadcast, traffic may be sent on both the loopback
channel and the physical wire.

The reason tx-switching is controlled by a module parameter is twofold:
1. There is a certain performance penalty for tx-switching because:
   a. every packet must be compared against the receiver clients.
   b. duplicated traffic being loopbacked can consume a significant portion of
   the overall bandwidth, depending on the scenario.
2. Tx-switching doesn't make much sense as a per function parameter, but should
rather be controlled uniformly for the  entire device. The reason is that if one
interface wants to be able to send data on the loopback it is not enough to
enable tx-switching for that interface, as the target interface must also
register its rx classification information where the transmitting interface can
find it. One would still have to use the module parameter in each VM, though.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  |    6 +++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   13 ++++++++++++-
 3 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index d60b5f0..4d359e9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1275,6 +1275,7 @@ struct bnx2x {
 #define NO_ISCSI_FLAG			(1 << 14)
 #define NO_FCOE_FLAG			(1 << 15)
 #define BC_SUPPORTS_PFC_STATS		(1 << 17)
+#define TX_SWITCHING			(1 << 18)
 
 #define NO_ISCSI(bp)		((bp)->flags & NO_ISCSI_FLAG)
 #define NO_ISCSI_OOO(bp)	((bp)->flags & NO_ISCSI_OOO_FLAG)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index f978c6a..3e26a3f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -1241,6 +1241,10 @@ static inline u8 bnx2x_get_path_func_num(struct bnx2x *bp)
 
 static inline void bnx2x_init_bp_objs(struct bnx2x *bp)
 {
+	/* mcast rules must be added to tx if tx switching is enabled */
+	bnx2x_obj_type o_type = bp->flags & TX_SWITCHING ?
+		BNX2X_OBJ_TYPE_RX_TX : BNX2X_OBJ_TYPE_RX;
+
 	/* RX_MODE controlling object */
 	bnx2x_init_rx_mode_obj(bp, &bp->rx_mode_obj);
 
@@ -1250,7 +1254,7 @@ static inline void bnx2x_init_bp_objs(struct bnx2x *bp)
 			     bnx2x_sp(bp, mcast_rdata),
 			     bnx2x_sp_mapping(bp, mcast_rdata),
 			     BNX2X_FILTER_MCAST_PENDING, &bp->sp_state,
-			     BNX2X_OBJ_TYPE_RX);
+			     o_type);
 
 	/* Setup CAM credit pools */
 	bnx2x_init_mac_credit_pool(bp, &bp->macs_pool, BP_FUNC(bp),
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 8e809c1..1e30bbd 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -129,7 +129,9 @@ static int debug;
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, " Default debug msglevel");
 
-
+static uint tx_switching;
+module_param(tx_switching, uint, 0);
+MODULE_PARM_DESC(tx_switching, " Enable tx-switching");
 
 struct workqueue_struct *bnx2x_wq;
 
@@ -2686,6 +2688,11 @@ static inline unsigned long bnx2x_get_common_flags(struct bnx2x *bp,
 	if (zero_stats)
 		__set_bit(BNX2X_Q_FLG_ZERO_STATS, &flags);
 
+	/* tx only connections can support tx-switching, though their
+	 * COS-ness doesn't survive the loopback
+	 */
+	if (bp->flags & TX_SWITCHING)
+		__set_bit(BNX2X_Q_FLG_TX_SWITCH, &flags);
 
 	return flags;
 }
@@ -10186,6 +10193,10 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 		bp->dev->features |= NETIF_F_LRO;
 	}
 
+	/* test tx switching module parameter */
+	if (tx_switching)
+		bp->flags |= TX_SWITCHING;
+
 	if (CHIP_IS_E1(bp))
 		bp->dropless_fc = 0;
 	else
-- 
1.7.9.GIT
