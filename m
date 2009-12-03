From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/5] ixgbe: use known user priority for FCoE when
	DCB is enabled
Date: Thu, 03 Dec 2009 13:32:22 -0800
Message-ID: <20091203213221.9291.34218.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Yi Zou <yi.zou@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:54811
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753444AbZLCVcg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 16:32:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

Store the user priority for FCoE and use it directly for outgoing
FCoE traffic when DCB is enabled.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_fcoe.c |   30 +++++++++++++++++-------------
 drivers/net/ixgbe/ixgbe_fcoe.h |    3 +++
 drivers/net/ixgbe/ixgbe_main.c |    8 ++++++++
 3 files changed, 28 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index edecdc8..da32a10 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -499,6 +499,10 @@ void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter)
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct ixgbe_fcoe *fcoe = &adapter->fcoe;
 	struct ixgbe_ring_feature *f = &adapter->ring_feature[RING_F_FCOE];
+#ifdef CONFIG_IXGBE_DCB
+	u8 tc;
+	u32 up2tc;
+#endif
 
 	/* create the pool for ddp if not created yet */
 	if (!fcoe->pool) {
@@ -540,6 +544,17 @@ void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter)
 			IXGBE_FCRXCTRL_FCOELLI |
 			IXGBE_FCRXCTRL_FCCRCBO |
 			(FC_FCOE_VER << IXGBE_FCRXCTRL_FCOEVER_SHIFT));
+#ifdef CONFIG_IXGBE_DCB
+	up2tc = IXGBE_READ_REG(&adapter->hw, IXGBE_RTTUP2TC);
+	for (i = 0; i < MAX_USER_PRIORITY; i++) {
+		tc = (u8)(up2tc >> (i * IXGBE_RTTUP2TC_UP_SHIFT));
+		tc &= (MAX_TRAFFIC_CLASS - 1);
+		if (fcoe->tc == tc) {
+			fcoe->up = i;
+			break;
+		}
+	}
+#endif
 }
 
 /**
@@ -671,19 +686,7 @@ out_disable:
  */
 u8 ixgbe_fcoe_getapp(struct ixgbe_adapter *adapter)
 {
-	int i;
-	u8 tc;
-	u32 up2tc;
-
-	up2tc = IXGBE_READ_REG(&adapter->hw, IXGBE_RTTUP2TC);
-	for (i = 0; i < MAX_USER_PRIORITY; i++) {
-		tc = (u8)(up2tc >> (i * IXGBE_RTTUP2TC_UP_SHIFT));
-		tc &= (MAX_TRAFFIC_CLASS - 1);
-		if (adapter->fcoe.tc == tc)
-			return 1 << i;
-	}
-
-	return 0;
+	return 1 << adapter->fcoe.up;
 }
 
 /**
@@ -710,6 +713,7 @@ u8 ixgbe_fcoe_setapp(struct ixgbe_adapter *adapter, u8 up)
 				up2tc >>= (i * IXGBE_RTTUP2TC_UP_SHIFT);
 				up2tc &= (MAX_TRAFFIC_CLASS - 1);
 				adapter->fcoe.tc = (u8)up2tc;
+				adapter->fcoe.up = i;
 				return 0;
 			}
 		}
diff --git a/drivers/net/ixgbe/ixgbe_fcoe.h b/drivers/net/ixgbe/ixgbe_fcoe.h
index b5dee7b..de8ff53 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.h
+++ b/drivers/net/ixgbe/ixgbe_fcoe.h
@@ -62,7 +62,10 @@ struct ixgbe_fcoe_ddp {
 };
 
 struct ixgbe_fcoe {
+#ifdef CONFIG_IXGBE_DCB
 	u8 tc;
+	u8 up;
+#endif
 	spinlock_t lock;
 	struct pci_pool *pool;
 	struct ixgbe_fcoe_ddp ddp[IXGBE_FCOE_DDP_MAX];
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 9ba506f..09990ed 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3958,8 +3958,10 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 		adapter->flags |= IXGBE_FLAG_FCOE_CAPABLE;
 		adapter->flags &= ~IXGBE_FLAG_FCOE_ENABLED;
 		adapter->ring_feature[RING_F_FCOE].indices = 0;
+#ifdef CONFIG_IXGBE_DCB
 		/* Default traffic class to use for FCoE */
 		adapter->fcoe.tc = IXGBE_FCOE_DEFTC;
+#endif
 #endif /* IXGBE_FCOE */
 	}
 
@@ -5332,6 +5334,12 @@ static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb,
 	    (skb->protocol == htons(ETH_P_FCOE))) {
 		tx_flags |= IXGBE_TX_FLAGS_FCOE;
 #ifdef IXGBE_FCOE
+#ifdef CONFIG_IXGBE_DCB
+		tx_flags &= ~(IXGBE_TX_FLAGS_VLAN_PRIO_MASK
+			      << IXGBE_TX_FLAGS_VLAN_SHIFT);
+		tx_flags |= ((adapter->fcoe.up << 13)
+			      << IXGBE_TX_FLAGS_VLAN_SHIFT);
+#endif
 		r_idx = smp_processor_id();
 		r_idx &= (adapter->ring_feature[RING_F_FCOE].indices - 1);
 		r_idx += adapter->ring_feature[RING_F_FCOE].mask;

