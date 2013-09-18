From: Jacob Keller <jacob.e.keller@intel.com>
Subject: [PATCH net RFC 2/2] ixgbe: fix sleep bug caused by napi_disable
 inside local_bh_disable()d context
Date: Wed, 18 Sep 2013 13:20:31 -0700
Message-ID: <20130918202016.8697.56423.stgit@jekeller-desk1.amr.corp.intel.com>
References: <20130918201541.8697.3548.stgit@jekeller-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@intel.com>,
	Hyong-Youb Kim <hykim@myri.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:30516 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752758Ab3IRUUd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Sep 2013 16:20:33 -0400
In-Reply-To: <20130918201541.8697.3548.stgit@jekeller-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a bug caused by calling napi_disable after local_bh_disable.
It is possible for napi_disable to sleep, (though not guarunteed) so it could
cause an atomic sleep bug during the  schedule() call in msleep. This patch
resolves the issue by moving the local_bh_disable() calls inside the for loop
in ixgbe_napi_disable_all().

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Cc: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Cc: Alexander Duyck <alexander.duyck@intel.com>
Cc: Hyong-Youb Kim <hykim@myri.com>
Cc: Amir Vadai <amirv@mellanox.com>
Cc: Dmitry Kravkov <dmitry@broadcom.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 0ade0cd..85dbf58 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3893,15 +3893,15 @@ static void ixgbe_napi_disable_all(struct ixgbe_adapter *adapter)
 {
 	int q_idx;
 
-	local_bh_disable(); /* for ixgbe_qv_lock_napi() */
 	for (q_idx = 0; q_idx < adapter->num_q_vectors; q_idx++) {
 		napi_disable(&adapter->q_vector[q_idx]->napi);
+		local_bh_disable(); /* for ixgbe_qv_lock_napi() */
 		while (!ixgbe_qv_lock_napi(adapter->q_vector[q_idx])) {
 			pr_info("QV %d locked\n", q_idx);
 			mdelay(1);
 		}
+		local_bh_enable();
 	}
-	local_bh_enable();
 }
 
 #ifdef CONFIG_IXGBE_DCB
