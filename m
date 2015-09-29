From: Alexander Duyck <aduyck@mirantis.com>
Subject: [PATCH v2] ixgbevf: Limit lowest interrupt rate for adaptive
 interrupt moderation to 12K
Date: Tue, 29 Sep 2015 13:11:15 -0700
Message-ID: <20150929201022.1388.91691.stgit@ahduyck-vm-fedora22>
References: <20150929195346.1125.48492.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34870 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751748AbbI2ULR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 16:11:17 -0400
Received: by pacfv12 with SMTP id fv12so15688360pac.2
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 13:11:17 -0700 (PDT)
In-Reply-To: <20150929195346.1125.48492.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is the ixgbevf version of commit 8ac34f10a5ea4 "ixgbe: Limit
lowest interrupt rate for adaptive interrupt moderation to 12K"

The same logic applies here as well as the same results since a netperf
test will starve for memory in the time from one Tx interrupt to the next.
As a result the ixgbevf driver underperformed when compared to vhost_net.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---

v2: Fixed comment describing lowest interrupt rate as 8000 ints/s

 drivers/net/ethernet/intel/ixgbevf/ethtool.c      |    2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |    3 +--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    6 +++---
 3 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index d3e5f5b37999..c48aef613b0a 100644
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
index 04c7ec8446e0..8b437b54cd98 100644
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
index 35da2d74e73e..1551b5dfde7e 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1136,7 +1136,7 @@ static void ixgbevf_configure_msix(struct ixgbevf_adapter *adapter)
 		if (q_vector->tx.ring && !q_vector->rx.ring) {
 			/* Tx only vector */
 			if (adapter->tx_itr_setting == 1)
-				q_vector->itr = IXGBE_10K_ITR;
+				q_vector->itr = IXGBE_12K_ITR;
 			else
 				q_vector->itr = adapter->tx_itr_setting;
 		} else {
@@ -1194,7 +1194,7 @@ static void ixgbevf_update_itr(struct ixgbevf_q_vector *q_vector,
 	/* simple throttle rate management
 	 *    0-20MB/s lowest (100000 ints/s)
 	 *   20-100MB/s low   (20000 ints/s)
-	 *  100-1249MB/s bulk (8000 ints/s)
+	 *  100-1249MB/s bulk (12000 ints/s)
 	 */
 	/* what was last interrupt timeslice? */
 	timepassed_us = q_vector->itr >> 2;
@@ -1245,7 +1245,7 @@ static void ixgbevf_set_itr(struct ixgbevf_q_vector *q_vector)
 		break;
 	case bulk_latency:
 	default:
-		new_itr = IXGBE_8K_ITR;
+		new_itr = IXGBE_12K_ITR;
 		break;
 	}
 
