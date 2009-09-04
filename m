From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 1/3] ixgbe: Add support for multiple Tx queues for
	FCoE in 82599
Date: Thu, 03 Sep 2009 17:55:50 -0700
Message-ID: <20090904005549.14869.66878.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Yi Zou <yi.zou@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.westchester.pa.mail.comcast.net ([76.96.59.212]:53992
	"EHLO QMTA14.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753990AbZIDA4G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 20:56:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

This patch adds support for multiple transmit queues to the Fiber Channel
over Ethernet (FCoE) feature found in 82599. Currently, FCoE has multiple
Rx queues available, along with a redirection table, that helps distribute
the I/O load across multiple CPUs based on the FC exchange ID. To make
this the most effective, we need to provide the same layout of transmit
queues to match receive.

Particularly, when Data Center Bridging (DCB) is enabled, the designated
traffic class for FCoE can have dedicated queues for just FCoE traffic,
while not affecting any other type of traffic flow.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_dcb_nl.c |   37 +++++++++++++++++++++++++++------
 drivers/net/ixgbe/ixgbe_main.c   |   43 ++++++++++++++++++++++++++++++--------
 2 files changed, 65 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 47d9dde..a6bc1ef 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -36,6 +36,7 @@
 #define BIT_PFC		0x02
 #define BIT_PG_RX	0x04
 #define BIT_PG_TX	0x08
+#define BIT_APP_UPCHG	0x10
 #define BIT_RESETLINK   0x40
 #define BIT_LINKSPEED   0x80
 
@@ -348,8 +349,14 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 		while (test_and_set_bit(__IXGBE_RESETTING, &adapter->state))
 			msleep(1);
 
-		if (netif_running(netdev))
-			ixgbe_down(adapter);
+		if (adapter->dcb_set_bitmap & BIT_APP_UPCHG) {
+			if (netif_running(netdev))
+				netdev->netdev_ops->ndo_stop(netdev);
+			ixgbe_clear_interrupt_scheme(adapter);
+		} else {
+			if (netif_running(netdev))
+				ixgbe_down(adapter);
+		}
 	}
 
 	ret = ixgbe_copy_dcb_cfg(&adapter->temp_dcb_cfg, &adapter->dcb_cfg,
@@ -373,8 +380,14 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 	}
 
 	if (adapter->dcb_set_bitmap & BIT_RESETLINK) {
-		if (netif_running(netdev))
-			ixgbe_up(adapter);
+		if (adapter->dcb_set_bitmap & BIT_APP_UPCHG) {
+			ixgbe_init_interrupt_scheme(adapter);
+			if (netif_running(netdev))
+				netdev->netdev_ops->ndo_open(netdev);
+		} else {
+			if (netif_running(netdev))
+				ixgbe_up(adapter);
+		}
 		ret = DCB_HW_CHG_RST;
 	} else if (adapter->dcb_set_bitmap & BIT_PFC) {
 		if (adapter->hw.mac.type == ixgbe_mac_82598EB)
@@ -526,8 +539,20 @@ static u8 ixgbe_dcbnl_setapp(struct net_device *netdev,
 	switch (idtype) {
 	case DCB_APP_IDTYPE_ETHTYPE:
 #ifdef IXGBE_FCOE
-		if (id == ETH_P_FCOE)
-			rval = ixgbe_fcoe_setapp(netdev_priv(netdev), up);
+		if (id == ETH_P_FCOE) {
+			u8 tc;
+			struct ixgbe_adapter *adapter;
+
+			adapter = netdev_priv(netdev);
+			tc = adapter->fcoe.tc;
+			rval = ixgbe_fcoe_setapp(adapter, up);
+			if ((!rval) && (tc != adapter->fcoe.tc) &&
+			    (adapter->flags & IXGBE_FLAG_DCB_ENABLED) &&
+			    (adapter->flags & IXGBE_FLAG_FCOE_ENABLED)) {
+				adapter->dcb_set_bitmap |= BIT_APP_UPCHG;
+				adapter->dcb_set_bitmap |= BIT_RESETLINK;
+			}
+		}
 #endif
 		break;
 	case DCB_APP_IDTYPE_PORTNUM:
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 4042d87..724754a 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3113,14 +3113,16 @@ static inline bool ixgbe_set_fcoe_queues(struct ixgbe_adapter *adapter)
 
 	f->indices = min((int)num_online_cpus(), f->indices);
 	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED) {
+		adapter->num_rx_queues = 1;
+		adapter->num_tx_queues = 1;
 #ifdef CONFIG_IXGBE_DCB
 		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-			DPRINTK(PROBE, INFO, "FCOE enabled with DCB \n");
+			DPRINTK(PROBE, INFO, "FCoE enabled with DCB \n");
 			ixgbe_set_dcb_queues(adapter);
 		}
 #endif
 		if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
-			DPRINTK(PROBE, INFO, "FCOE enabled with RSS \n");
+			DPRINTK(PROBE, INFO, "FCoE enabled with RSS \n");
 			if ((adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) ||
 			    (adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE))
 				ixgbe_set_fdir_queues(adapter);
@@ -3130,8 +3132,7 @@ static inline bool ixgbe_set_fcoe_queues(struct ixgbe_adapter *adapter)
 		/* adding FCoE rx rings to the end */
 		f->mask = adapter->num_rx_queues;
 		adapter->num_rx_queues += f->indices;
-		if (adapter->num_tx_queues == 0)
-			adapter->num_tx_queues = f->indices;
+		adapter->num_tx_queues += f->indices;
 
 		ret = true;
 	}
@@ -3371,15 +3372,36 @@ static bool inline ixgbe_cache_ring_fdir(struct ixgbe_adapter *adapter)
  */
 static inline bool ixgbe_cache_ring_fcoe(struct ixgbe_adapter *adapter)
 {
-	int i, fcoe_i = 0;
+	int i, fcoe_rx_i = 0, fcoe_tx_i = 0;
 	bool ret = false;
 	struct ixgbe_ring_feature *f = &adapter->ring_feature[RING_F_FCOE];
 
 	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED) {
 #ifdef CONFIG_IXGBE_DCB
 		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
+			struct ixgbe_fcoe *fcoe = &adapter->fcoe;
+
 			ixgbe_cache_ring_dcb(adapter);
-			fcoe_i = adapter->rx_ring[0].reg_idx + 1;
+			/* find out queues in TC for FCoE */
+			fcoe_rx_i = adapter->rx_ring[fcoe->tc].reg_idx + 1;
+			fcoe_tx_i = adapter->tx_ring[fcoe->tc].reg_idx + 1;
+			/*
+			 * In 82599, the number of Tx queues for each traffic
+			 * class for both 8-TC and 4-TC modes are:
+			 * TCs  : TC0 TC1 TC2 TC3 TC4 TC5 TC6 TC7
+			 * 8 TCs:  32  32  16  16   8   8   8   8
+			 * 4 TCs:  64  64  32  32
+			 * We have max 8 queues for FCoE, where 8 the is
+			 * FCoE redirection table size. If TC for FCoE is
+			 * less than or equal to TC3, we have enough queues
+			 * to add max of 8 queues for FCoE, so we start FCoE
+			 * tx descriptor from the next one, i.e., reg_idx + 1.
+			 * If TC for FCoE is above TC3, implying 8 TC mode,
+			 * and we need 8 for FCoE, we have to take all queues
+			 * in that traffic class for FCoE.
+			 */
+			if ((f->indices == IXGBE_FCRETA_SIZE) && (fcoe->tc > 3))
+				fcoe_tx_i--;
 		}
 #endif /* CONFIG_IXGBE_DCB */
 		if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
@@ -3389,10 +3411,13 @@ static inline bool ixgbe_cache_ring_fcoe(struct ixgbe_adapter *adapter)
 			else
 				ixgbe_cache_ring_rss(adapter);
 
-			fcoe_i = f->mask;
+			fcoe_rx_i = f->mask;
+			fcoe_tx_i = f->mask;
+		}
+		for (i = 0; i < f->indices; i++, fcoe_rx_i++, fcoe_tx_i++) {
+			adapter->rx_ring[f->mask + i].reg_idx = fcoe_rx_i;
+			adapter->tx_ring[f->mask + i].reg_idx = fcoe_tx_i;
 		}
-		for (i = 0; i < f->indices; i++, fcoe_i++)
-			adapter->rx_ring[f->mask + i].reg_idx = fcoe_i;
 		ret = true;
 	}
 	return ret;

