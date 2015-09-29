From: Alexander Duyck <aduyck@mirantis.com>
Subject: [PATCH] ixgbevf: Limit lowest interrupt rate for adaptive interrupt
 moderation to 12K
Date: Tue, 29 Sep 2015 12:53:46 -0700
Message-ID: <20150929195346.1125.48492.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33344 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751166AbbI2Txs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 15:53:48 -0400
Received: by pacex6 with SMTP id ex6so15076119pac.0
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 12:53:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is the ixgbevf version of commit 8ac34f10a5ea4 "ixgbe: Limit
lowest interrupt rate for adaptive interrupt moderation to 12K"

The same logic applies here as well as the same results since a netperf
test will starve for memory in the time from one Tx interrupt to the next.
As a result the ixgbevf driver underperformed when compared to vhost_net.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      |    2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |    3 +--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    4 ++--
 3 files changed, 4 insertions(+), 5 deletions(-)

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
index 35da2d74e73e..4ae77953ad76 100644
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
@@ -1245,7 +1245,7 @@ static void ixgbevf_set_itr(struct ixgbevf_q_vector *q_vector)
 		break;
 	case bulk_latency:
 	default:
-		new_itr = IXGBE_8K_ITR;
+		new_itr = IXGBE_12K_ITR;
 		break;
 	}
 
