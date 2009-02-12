From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 31/41]bnx2x: Loopback in diag mode
Date: Thu, 12 Feb 2009 20:38:08 +0200
Message-ID: <1234463888.1863.163.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1807 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758595AbZBLSid (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:38:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 31/41]bnx2x: Loopback in diag mode
When loading in diag mode, set the device to loopback instead of normal link and
then changing it to loopback mode

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    8 +++---
 drivers/net/bnx2x_main.c |   57 ++++++++++++++++++++++++++-------------------
 2 files changed, 37 insertions(+), 28 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 891a58e..88eeee9 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -1062,10 +1062,10 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 
 #define BNX2X_NUM_TESTS			7
 
-#define BNX2X_MAC_LOOPBACK		0
-#define BNX2X_PHY_LOOPBACK		1
-#define BNX2X_MAC_LOOPBACK_FAILED	1
-#define BNX2X_PHY_LOOPBACK_FAILED	2
+#define BNX2X_PHY_LOOPBACK		0
+#define BNX2X_MAC_LOOPBACK		1
+#define BNX2X_PHY_LOOPBACK_FAILED	1
+#define BNX2X_MAC_LOOPBACK_FAILED	2
 #define BNX2X_LOOPBACK_FAILED		(BNX2X_MAC_LOOPBACK_FAILED | \
 					 BNX2X_PHY_LOOPBACK_FAILED)
 
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index a14fe75..96e23fd 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -2064,7 +2064,7 @@ static void bnx2x_link_report(struct bnx2x *bp)
 	}
 }
 
-static u8 bnx2x_initial_phy_init(struct bnx2x *bp)
+static u8 bnx2x_initial_phy_init(struct bnx2x *bp, int load_mode)
 {
 	if (!BP_NOMCP(bp)) {
 		u8 rc;
@@ -2080,14 +2080,20 @@ static u8 bnx2x_initial_phy_init(struct bnx2x *bp)
 			bp->link_params.req_fc_auto_adv = BNX2X_FLOW_CTRL_BOTH;
 
 		bnx2x_acquire_phy_lock(bp);
+
+		if (load_mode == LOAD_DIAG)
+			bp->link_params.loopback_mode = LOOPBACK_XGXS_10;
+
 		rc = bnx2x_phy_init(&bp->link_params, &bp->link_vars);
+
 		bnx2x_release_phy_lock(bp);
 
 		bnx2x_calc_fc_adv(bp);
 
-		if (bp->link_vars.link_up)
+		if (CHIP_REV_IS_SLOW(bp) && bp->link_vars.link_up) {
+			bnx2x_stats_handle(bp, STATS_EVENT_LINK_UP);
 			bnx2x_link_report(bp);
-
+		}
 
 		return rc;
 	}
@@ -6942,7 +6948,7 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		bnx2x_set_mac_addr_e1h(bp, 1);
 
 	if (bp->port.pmf)
-		bnx2x_initial_phy_init(bp);
+		bnx2x_initial_phy_init(bp, load_mode);
 
 	/* Start fast path */
 	switch (load_mode) {
@@ -9328,23 +9334,23 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode, u8 link_up)
 	u16 len;
 	int rc = -ENODEV;
 
-	if (loopback_mode == BNX2X_MAC_LOOPBACK) {
+	/* check the loopback mode */
+	switch (loopback_mode) {
+	case BNX2X_PHY_LOOPBACK:
+		if (bp->link_params.loopback_mode != LOOPBACK_XGXS_10)
+			return -EINVAL;
+		break;
+	case BNX2X_MAC_LOOPBACK:
 		bp->link_params.loopback_mode = LOOPBACK_BMAC;
 		bnx2x_phy_init(&bp->link_params, &bp->link_vars);
-
-	} else if (loopback_mode == BNX2X_PHY_LOOPBACK) {
-		u16 cnt = 1000;
-		bp->link_params.loopback_mode = LOOPBACK_XGXS_10;
-		bnx2x_phy_init(&bp->link_params, &bp->link_vars);
-		/* wait until link state is restored */
-		if (link_up)
-			while (cnt-- && bnx2x_test_link(&bp->link_params,
-							&bp->link_vars))
-				msleep(10);
-	} else
+		break;
+	default:
 		return -EINVAL;
+	}
 
-	pkt_size = 1514;
+	/* prepare the loopback packet */
+	pkt_size = (((bp->dev->mtu < ETH_MAX_PACKET_SIZE) ?
+		     bp->dev->mtu : ETH_MAX_PACKET_SIZE) + ETH_HLEN);
 	skb = netdev_alloc_skb(bp->dev, bp->rx_buf_size);
 	if (!skb) {
 		rc = -ENOMEM;
@@ -9356,6 +9362,7 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode, u8 link_up)
 	for (i = ETH_HLEN; i < pkt_size; i++)
 		packet[i] = (unsigned char) (i & 0xff);
 
+	/* send the loopback packet */
 	num_pkts = 0;
 	tx_start_idx = le16_to_cpu(*fp->tx_cons_sb);
 	rx_start_idx = le16_to_cpu(*fp->rx_cons_sb);
@@ -9440,7 +9447,7 @@ test_loopback_exit:
 
 static int bnx2x_test_loopback(struct bnx2x *bp, u8 link_up)
 {
-	int rc = 0;
+	int rc = 0, res;
 
 	if (!netif_running(bp->dev))
 		return BNX2X_LOOPBACK_FAILED;
@@ -9448,14 +9455,16 @@ static int bnx2x_test_loopback(struct bnx2x *bp, u8 link_up)
 	bnx2x_netif_stop(bp, 1);
 	bnx2x_acquire_phy_lock(bp);
 
-	if (bnx2x_run_loopback(bp, BNX2X_MAC_LOOPBACK, link_up)) {
-		DP(NETIF_MSG_PROBE, "MAC loopback failed\n");
-		rc |= BNX2X_MAC_LOOPBACK_FAILED;
+	res = bnx2x_run_loopback(bp, BNX2X_PHY_LOOPBACK, link_up);
+	if (res) {
+		DP(NETIF_MSG_PROBE, "  PHY loopback failed  (res %d)\n", res);
+		rc |= BNX2X_PHY_LOOPBACK_FAILED;
 	}
 
-	if (bnx2x_run_loopback(bp, BNX2X_PHY_LOOPBACK, link_up)) {
-		DP(NETIF_MSG_PROBE, "PHY loopback failed\n");
-		rc |= BNX2X_PHY_LOOPBACK_FAILED;
+	res = bnx2x_run_loopback(bp, BNX2X_MAC_LOOPBACK, link_up);
+	if (res) {
+		DP(NETIF_MSG_PROBE, "  MAC loopback failed  (res %d)\n", res);
+		rc |= BNX2X_MAC_LOOPBACK_FAILED;
 	}
 
 	bnx2x_release_phy_lock(bp);
-- 
1.5.4.3




