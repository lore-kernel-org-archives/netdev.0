From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: Fix misleading packet/frame count stats.
Date: Fri, 13 Jan 2017 14:46:40 +0530
Message-ID: <1484299000-7586-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, hariprasad@chelsio.com, leedom@chelsio.com,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:4481 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751241AbdAMJQx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 04:16:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not count pause frames as part of general TX/RX frame
counters.

Based on the original work of Casey Leedom <leedom@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c   | 18 ++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h | 17 +++++++++++++++++
 2 files changed, 35 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index f113015..ac712ac 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -5501,6 +5501,7 @@ void t4_get_port_stats_offset(struct adapter *adap, int idx,
 void t4_get_port_stats(struct adapter *adap, int idx, struct port_stats *p)
 {
 	u32 bgmap = t4_get_mps_bg_map(adap, idx);
+	u32 stat_ctl = t4_read_reg(adap, MPS_STAT_CTL_A);
 
 #define GET_STAT(name) \
 	t4_read_reg64(adap, \
@@ -5532,6 +5533,14 @@ void t4_get_port_stats(struct adapter *adap, int idx, struct port_stats *p)
 	p->tx_ppp6             = GET_STAT(TX_PORT_PPP6);
 	p->tx_ppp7             = GET_STAT(TX_PORT_PPP7);
 
+	if (CHELSIO_CHIP_VERSION(adap->params.chip) >= CHELSIO_T5) {
+		if (stat_ctl & COUNTPAUSESTATTX_F) {
+			p->tx_frames -= p->tx_pause;
+			p->tx_octets -= p->tx_pause * 64;
+		}
+		if (stat_ctl & COUNTPAUSEMCTX_F)
+			p->tx_mcast_frames -= p->tx_pause;
+	}
 	p->rx_octets           = GET_STAT(RX_PORT_BYTES);
 	p->rx_frames           = GET_STAT(RX_PORT_FRAMES);
 	p->rx_bcast_frames     = GET_STAT(RX_PORT_BCAST);
@@ -5560,6 +5569,15 @@ void t4_get_port_stats(struct adapter *adap, int idx, struct port_stats *p)
 	p->rx_ppp6             = GET_STAT(RX_PORT_PPP6);
 	p->rx_ppp7             = GET_STAT(RX_PORT_PPP7);
 
+	if (CHELSIO_CHIP_VERSION(adap->params.chip) >= CHELSIO_T5) {
+		if (stat_ctl & COUNTPAUSESTATRX_F) {
+			p->rx_frames -= p->rx_pause;
+			p->rx_octets -= p->rx_pause * 64;
+		}
+		if (stat_ctl & COUNTPAUSEMCRX_F)
+			p->rx_mcast_frames -= p->rx_pause;
+	}
+
 	p->rx_ovflow0 = (bgmap & 1) ? GET_STAT_COM(RX_BG_0_MAC_DROP_FRAME) : 0;
 	p->rx_ovflow1 = (bgmap & 2) ? GET_STAT_COM(RX_BG_1_MAC_DROP_FRAME) : 0;
 	p->rx_ovflow2 = (bgmap & 4) ? GET_STAT_COM(RX_BG_2_MAC_DROP_FRAME) : 0;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index e685163..f71001d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -1798,12 +1798,29 @@
 
 #define MPS_CMN_CTL_A	0x9000
 
+#define COUNTPAUSEMCRX_S    5
+#define COUNTPAUSEMCRX_V(x) ((x) << COUNTPAUSEMCRX_S)
+#define COUNTPAUSEMCRX_F    COUNTPAUSEMCRX_V(1U)
+
+#define COUNTPAUSESTATRX_S    4
+#define COUNTPAUSESTATRX_V(x) ((x) << COUNTPAUSESTATRX_S)
+#define COUNTPAUSESTATRX_F    COUNTPAUSESTATRX_V(1U)
+
+#define COUNTPAUSEMCTX_S    3
+#define COUNTPAUSEMCTX_V(x) ((x) << COUNTPAUSEMCTX_S)
+#define COUNTPAUSEMCTX_F    COUNTPAUSEMCTX_V(1U)
+
+#define COUNTPAUSESTATTX_S    2
+#define COUNTPAUSESTATTX_V(x) ((x) << COUNTPAUSESTATTX_S)
+#define COUNTPAUSESTATTX_F    COUNTPAUSESTATTX_V(1U)
+
 #define NUMPORTS_S    0
 #define NUMPORTS_M    0x3U
 #define NUMPORTS_G(x) (((x) >> NUMPORTS_S) & NUMPORTS_M)
 
 #define MPS_INT_CAUSE_A 0x9008
 #define MPS_TX_INT_CAUSE_A 0x9408
+#define MPS_STAT_CTL_A 0x9600
 
 #define FRMERR_S    15
 #define FRMERR_V(x) ((x) << FRMERR_S)
-- 
2.1.0
