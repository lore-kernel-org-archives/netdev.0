From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next] bnx2x: Spread rx buffers between allocated
 queues
Date: Sun, 12 Sep 2010 17:48:28 +0200
Message-ID: <1284306508.5534.1.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, eilong@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1614 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751980Ab0ILPsv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Sep 2010 11:48:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Default number of rx buffers will be divided equally
 between allocated queues. This will decrease amount of
 pre-allocated buffers on systems with multiple CPUs.
 User can override this behavior with ethtool -G.
 Minimum amount of rx buffers per queue set to 128.

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h         |    5 +++--
 drivers/net/bnx2x/bnx2x_cmn.c     |    6 +++++-
 drivers/net/bnx2x/bnx2x_ethtool.c |   10 +++++++++-
 drivers/net/bnx2x/bnx2x_main.c    |    1 -
 4 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index b6aaf22..64329c5 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -20,8 +20,8 @@
  * (you will need to reboot afterwards) */
 /* #define BNX2X_STOP_ON_ERROR */
 
-#define DRV_MODULE_VERSION      "1.52.53-6"
-#define DRV_MODULE_RELDATE      "2010/09/07"
+#define DRV_MODULE_VERSION      "1.52.53-7"
+#define DRV_MODULE_RELDATE      "2010/09/12"
 #define BNX2X_BC_VER            0x040200
 
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
@@ -369,6 +369,7 @@ struct bnx2x_fastpath {
 #define NUM_RX_BD			(RX_DESC_CNT * NUM_RX_RINGS)
 #define MAX_RX_BD			(NUM_RX_BD - 1)
 #define MAX_RX_AVAIL			(MAX_RX_DESC_CNT * NUM_RX_RINGS - 2)
+#define MIN_RX_AVAIL			128
 #define NEXT_RX_IDX(x)		((((x) & RX_DESC_MASK) == \
 				  (MAX_RX_DESC_CNT - 1)) ? (x) + 3 : (x) + 1)
 #define RX_BD(x)			((x) & MAX_RX_BD)
diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 7f1d291..efc7be4 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -781,6 +781,10 @@ void bnx2x_init_rx_rings(struct bnx2x *bp)
 					      ETH_MAX_AGGREGATION_QUEUES_E1H;
 	u16 ring_prod, cqe_ring_prod;
 	int i, j;
+	int rx_ring_size = bp->rx_ring_size ? bp->rx_ring_size :
+					      MAX_RX_AVAIL/bp->num_queues;
+
+	rx_ring_size = max_t(int, MIN_RX_AVAIL, rx_ring_size);
 
 	bp->rx_buf_size = bp->dev->mtu + ETH_OVREHEAD + BNX2X_RX_ALIGN;
 	DP(NETIF_MSG_IFUP,
@@ -883,7 +887,7 @@ void bnx2x_init_rx_rings(struct bnx2x *bp)
 		/* Allocate BDs and initialize BD ring */
 		fp->rx_comp_cons = 0;
 		cqe_ring_prod = ring_prod = 0;
-		for (i = 0; i < bp->rx_ring_size; i++) {
+		for (i = 0; i < rx_ring_size; i++) {
 			if (bnx2x_alloc_rx_skb(bp, fp, ring_prod) < 0) {
 				BNX2X_ERR("was only able to allocate "
 					  "%d rx skbs on queue[%d]\n", i, j);
diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
index 6f939c5..d9748e9 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -961,7 +961,14 @@ static void bnx2x_get_ringparam(struct net_device *dev,
 	ering->rx_mini_max_pending = 0;
 	ering->rx_jumbo_max_pending = 0;
 
-	ering->rx_pending = bp->rx_ring_size;
+	if (bp->rx_ring_size)
+		ering->rx_pending = bp->rx_ring_size;
+	else
+		if (bp->state == BNX2X_STATE_OPEN && bp->num_queues)
+			ering->rx_pending = MAX_RX_AVAIL/bp->num_queues;
+		else
+			ering->rx_pending = MAX_RX_AVAIL;
+
 	ering->rx_mini_pending = 0;
 	ering->rx_jumbo_pending = 0;
 
@@ -981,6 +988,7 @@ static int bnx2x_set_ringparam(struct net_device *dev,
 	}
 
 	if ((ering->rx_pending > MAX_RX_AVAIL) ||
+	    (ering->rx_pending < MIN_RX_AVAIL) ||
 	    (ering->tx_pending > MAX_TX_AVAIL) ||
 	    (ering->tx_pending <= MAX_SKB_FRAGS + 4))
 		return -EINVAL;
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 7ba3a6d..67587fe 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -6619,7 +6619,6 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 	bp->mrrs = mrrs;
 
 	bp->tx_ring_size = MAX_TX_AVAIL;
-	bp->rx_ring_size = MAX_RX_AVAIL;
 
 	bp->rx_csum = 1;
 
-- 
1.7.1




