From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 05/11] ixgbe: Add RING_F_FCOE for FCoE feature in
	82599
Date: Sun, 17 May 2009 15:33:52 -0700
Message-ID: <20090517223352.14124.2401.stgit@localhost.localdomain>
References: <20090517223213.14124.61405.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	Yi Zou <yi.zou@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:55349
	"EHLO QMTA08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755208AbZEQWeM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2009 18:34:12 -0400
In-Reply-To: <20090517223213.14124.61405.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

Add ring feature for FCoE to make use of the FCoE redirection
table in 82599. The FCoE redirection table is a receive side
scaling feature for Fiber Channel over Ethernet feature in 82599,
enabling distributing FCoE packets to different receive queues
based on the exchange id.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h      |    6 +++
 drivers/net/ixgbe/ixgbe_main.c |   96 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 102 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index db6d3ea..94b0465 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -161,6 +161,9 @@ enum ixgbe_ring_f_enum {
 	RING_F_DCB,
 	RING_F_VMDQ,
 	RING_F_RSS,
+#ifdef IXGBE_FCOE
+	RING_F_FCOE,
+#endif /* IXGBE_FCOE */
 
 	RING_F_ARRAY_SIZE      /* must be last in enum set */
 };
@@ -168,6 +171,9 @@ enum ixgbe_ring_f_enum {
 #define IXGBE_MAX_DCB_INDICES   8
 #define IXGBE_MAX_RSS_INDICES  16
 #define IXGBE_MAX_VMDQ_INDICES 16
+#ifdef IXGBE_FCOE
+#define IXGBE_MAX_FCOE_INDICES  8
+#endif /* IXGBE_FCOE */
 struct ixgbe_ring_feature {
 	int indices;
 	int mask;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index fe0ac8b..68edeab 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1756,6 +1756,17 @@ static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter, int index)
 			else
 				dev_err(&adapter->pdev->dev, "Invalid DCB "
 				        "configuration\n");
+#ifdef IXGBE_FCOE
+			if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED) {
+				struct ixgbe_ring_feature *f;
+
+				rx_ring = &adapter->rx_ring[queue0];
+				f = &adapter->ring_feature[RING_F_FCOE];
+				if ((queue0 == 0) && (index > rx_ring->reg_idx))
+					queue0 = f->mask + index -
+					         rx_ring->reg_idx - 1;
+			}
+#endif /* IXGBE_FCOE */
 		} else {
 			queue0 = index;
 		}
@@ -2842,6 +2853,47 @@ static inline bool ixgbe_set_rss_queues(struct ixgbe_adapter *adapter)
 	return ret;
 }
 
+#ifdef IXGBE_FCOE
+/**
+ * ixgbe_set_fcoe_queues: Allocate queues for Fiber Channel over Ethernet (FCoE)
+ * @adapter: board private structure to initialize
+ *
+ * FCoE RX FCRETA can use up to 8 rx queues for up to 8 different exchanges.
+ * The ring feature mask is not used as a mask for FCoE, as it can take any 8
+ * rx queues out of the max number of rx queues, instead, it is used as the
+ * index of the first rx queue used by FCoE.
+ *
+ **/
+static inline bool ixgbe_set_fcoe_queues(struct ixgbe_adapter *adapter)
+{
+	bool ret = false;
+	struct ixgbe_ring_feature *f = &adapter->ring_feature[RING_F_FCOE];
+
+	f->indices = min((int)num_online_cpus(), f->indices);
+	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED) {
+#ifdef CONFIG_IXGBE_DCB
+		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
+			DPRINTK(PROBE, INFO, "FCOE enabled with DCB \n");
+			ixgbe_set_dcb_queues(adapter);
+		}
+#endif
+		if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
+			DPRINTK(PROBE, INFO, "FCOE enabled with RSS \n");
+			ixgbe_set_rss_queues(adapter);
+		}
+		/* adding FCoE rx rings to the end */
+		f->mask = adapter->num_rx_queues;
+		adapter->num_rx_queues += f->indices;
+		if (adapter->num_tx_queues == 0)
+			adapter->num_tx_queues = f->indices;
+
+		ret = true;
+	}
+
+	return ret;
+}
+
+#endif /* IXGBE_FCOE */
 /*
  * ixgbe_set_num_queues: Allocate queues for device, feature dependant
  * @adapter: board private structure to initialize
@@ -2855,6 +2907,11 @@ static inline bool ixgbe_set_rss_queues(struct ixgbe_adapter *adapter)
  **/
 static void ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
 {
+#ifdef IXGBE_FCOE
+	if (ixgbe_set_fcoe_queues(adapter))
+		goto done;
+
+#endif /* IXGBE_FCOE */
 #ifdef CONFIG_IXGBE_DCB
 	if (ixgbe_set_dcb_queues(adapter))
 		goto done;
@@ -3030,6 +3087,39 @@ static inline bool ixgbe_cache_ring_dcb(struct ixgbe_adapter *adapter)
 }
 #endif
 
+#ifdef IXGBE_FCOE
+/**
+ * ixgbe_cache_ring_fcoe - Descriptor ring to register mapping for the FCoE
+ * @adapter: board private structure to initialize
+ *
+ * Cache the descriptor ring offsets for FCoE mode to the assigned rings.
+ *
+ */
+static inline bool ixgbe_cache_ring_fcoe(struct ixgbe_adapter *adapter)
+{
+	int i, fcoe_i = 0;
+	bool ret = false;
+	struct ixgbe_ring_feature *f = &adapter->ring_feature[RING_F_FCOE];
+
+	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED) {
+#ifdef CONFIG_IXGBE_DCB
+		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
+			ixgbe_cache_ring_dcb(adapter);
+			fcoe_i = adapter->rx_ring[0].reg_idx + 1;
+		}
+#endif /* CONFIG_IXGBE_DCB */
+		if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
+			ixgbe_cache_ring_rss(adapter);
+			fcoe_i = f->mask;
+		}
+		for (i = 0; i < f->indices; i++, fcoe_i++)
+			adapter->rx_ring[f->mask + i].reg_idx = fcoe_i;
+		ret = true;
+	}
+	return ret;
+}
+
+#endif /* IXGBE_FCOE */
 /**
  * ixgbe_cache_ring_register - Descriptor ring to register mapping
  * @adapter: board private structure to initialize
@@ -3047,6 +3137,11 @@ static void ixgbe_cache_ring_register(struct ixgbe_adapter *adapter)
 	adapter->rx_ring[0].reg_idx = 0;
 	adapter->tx_ring[0].reg_idx = 0;
 
+#ifdef IXGBE_FCOE
+	if (ixgbe_cache_ring_fcoe(adapter))
+		return;
+
+#endif /* IXGBE_FCOE */
 #ifdef CONFIG_IXGBE_DCB
 	if (ixgbe_cache_ring_dcb(adapter))
 		return;
@@ -3420,6 +3515,7 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 		adapter->flags |= IXGBE_FLAG_RSC_ENABLED;
 #ifdef IXGBE_FCOE
 		adapter->flags |= IXGBE_FLAG_FCOE_ENABLED;
+		adapter->ring_feature[RING_F_FCOE].indices = IXGBE_FCRETA_SIZE;
 #endif /* IXGBE_FCOE */
 	}
 

