From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] ixgbevf: Limit lowest interrupt rate for adaptive interrupt moderation to 12K
Date: Mon, 23 Nov 2015 11:36:10 -0800
Message-ID: <1448307376-20063-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1448307376-20063-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:41412 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754832AbbKWTgY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2015 14:36:24 -0500
In-Reply-To: <1448307376-20063-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

This patch is the ixgbevf version of commit 8ac34f10a5ea4 "ixgbe: Limit
lowest interrupt rate for adaptive interrupt moderation to 12K"

The same logic applies here as well as the same results since a netperf
test will starve for memory in the time from one Tx interrupt to the next.
As a result the ixgbevf driver underperformed when compared to vhost_net.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Darin Miller <darin.j.miller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      | 2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      | 3 +--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 6 +++---
 3 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index d3e5f5b..c48aef6 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -774,7 +774,7 @@ static int ixgbevf_set_coalesce(struct net_device *netdev,
 		adapter->tx_itr_setting = ec->tx_coalesce_usecs;
 
 	if (adapter->tx_itr_setting == 1)
-		tx_itr_param = IXGBE_10K_ITR;
+		tx_itr_param = IXGBE_12K_ITR;
 	else
 		tx_itr_param = adapter->tx_itr_setting;
 
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index ec31472..68ec7daa 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -326,8 +326,7 @@ static inline bool ixgbevf_qv_disable(struct ixgbevf_q_vector *q_vector)
 #define IXGBE_MIN_RSC_ITR	24
 #define IXGBE_100K_ITR		40
 #define IXGBE_20K_ITR		200
-#define IXGBE_10K_ITR		400
-#define IXGBE_8K_ITR		500
+#define IXGBE_12K_ITR		336
 
 /* Helper macros to switch between ints/sec and what the register uses.
  * And yes, it's the same math going both ways.  The lowest value
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 2955186..e678178 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1138,7 +1138,7 @@ static void ixgbevf_configure_msix(struct ixgbevf_adapter *adapter)
 		if (q_vector->tx.ring && !q_vector->rx.ring) {
 			/* Tx only vector */
 			if (adapter->tx_itr_setting == 1)
-				q_vector->itr = IXGBE_10K_ITR;
+				q_vector->itr = IXGBE_12K_ITR;
 			else
 				q_vector->itr = adapter->tx_itr_setting;
 		} else {
@@ -1196,7 +1196,7 @@ static void ixgbevf_update_itr(struct ixgbevf_q_vector *q_vector,
 	/* simple throttle rate management
 	 *    0-20MB/s lowest (100000 ints/s)
 	 *   20-100MB/s low   (20000 ints/s)
-	 *  100-1249MB/s bulk (8000 ints/s)
+	 *  100-1249MB/s bulk (12000 ints/s)
 	 */
 	/* what was last interrupt timeslice? */
 	timepassed_us = q_vector->itr >> 2;
@@ -1247,7 +1247,7 @@ static void ixgbevf_set_itr(struct ixgbevf_q_vector *q_vector)
 		break;
 	case bulk_latency:
 	default:
-		new_itr = IXGBE_8K_ITR;
+		new_itr = IXGBE_12K_ITR;
 		break;
 	}
 
-- 
2.5.0
