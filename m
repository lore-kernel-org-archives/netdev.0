From: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Subject: [PATCH net-next 4/8] be2net: SRIOV Queue distribution should factor in EQ-count of VFs
Date: Tue,  2 Feb 2016 15:50:31 +0530
Message-ID: <1454408435-11575-5-git-send-email-sriharsha.basavapatna@broadcom.com>
References: <1454408435-11575-1-git-send-email-sriharsha.basavapatna@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:63466 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754507AbcBBKj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 05:39:29 -0500
In-Reply-To: <1454408435-11575-1-git-send-email-sriharsha.basavapatna@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SRIOV resource distribution logic for RX/TX queue counts is not optimal
when a small number of VFs are enabled. It does not take into account the
VF's EQ count while computing the queue counts. Because of this, the VF
gets a large number of queues, though it doesn't have sufficient EQs,
resulting in wasted queue resources. And the PF gets a smaller share of
queues though it has more EQs. Fix this by capping the VF queue count at
its EQ count.

Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |  4 ++++
 drivers/net/ethernet/emulex/benet/be_main.c | 15 ++++++---------
 2 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index cf83783..f33d73c 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -89,6 +89,10 @@
 #define BE3_MAX_TX_QS		16
 #define BE3_MAX_EVT_QS		16
 #define BE3_SRIOV_MAX_EVT_QS	8
+#define	SH_VF_MAX_NIC_EQS	3	/* Skyhawk VFs can have a max of 4 EQs
+					 * and at least 1 is granted to either
+					 * SURF/DPDK
+					 */
 
 #define MAX_RSS_IFACES		15
 #define MAX_RX_QS		32
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 09e6f2c..62f6fbb 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3792,18 +3792,15 @@ static u16 be_calculate_vf_qs(struct be_adapter *adapter, u16 num_vfs)
 	struct be_resources res = adapter->pool_res;
 	u16 num_vf_qs = 1;
 
-	/* Distribute the queue resources equally among the PF and it's VFs
+	/* Distribute the queue resources among the PF and it's VFs
 	 * Do not distribute queue resources in multi-channel configuration.
 	 */
 	if (num_vfs && !be_is_mc(adapter)) {
-		/* If number of VFs requested is 8 less than max supported,
-		 * assign 8 queue pairs to the PF and divide the remaining
-		 * resources evenly among the VFs
-		 */
-		if (num_vfs < (be_max_vfs(adapter) - 8))
-			num_vf_qs = (res.max_rss_qs - 8) / num_vfs;
-		else
-			num_vf_qs = res.max_rss_qs / num_vfs;
+		 /* Divide the qpairs evenly among the VFs and the PF, capped
+		  * at VF-EQ-count. Any remainder qpairs belong to the PF.
+		  */
+		num_vf_qs = min(SH_VF_MAX_NIC_EQS,
+				res.max_rss_qs / (num_vfs + 1));
 
 		/* Skyhawk-R chip supports only MAX_RSS_IFACES RSS capable
 		 * interfaces per port. Provide RSS on VFs, only if number
-- 
2.3.0.rc2
