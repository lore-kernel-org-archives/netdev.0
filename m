From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/1] i40e: Do not enable NAPI on q_vectors that have no rings
Date: Fri, 24 Mar 2017 15:01:42 -0700
Message-ID: <20170324220142.8921-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:10847 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754780AbdCXWFB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Mar 2017 18:05:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

When testing the epoll w/ busy poll code I found that I could get into a
state where the i40e driver had q_vectors w/ active NAPI that had no rings.
This was resulting in a divide by zero error.  To correct it I am updating
the driver code so that we only support NAPI on q_vectors that have 1 or
more rings allocated to them.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index e8a8351c8ea9..82a95cc2c8ee 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4438,8 +4438,12 @@ static void i40e_napi_enable_all(struct i40e_vsi *vsi)
 	if (!vsi->netdev)
 		return;
 
-	for (q_idx = 0; q_idx < vsi->num_q_vectors; q_idx++)
-		napi_enable(&vsi->q_vectors[q_idx]->napi);
+	for (q_idx = 0; q_idx < vsi->num_q_vectors; q_idx++) {
+		struct i40e_q_vector *q_vector = vsi->q_vectors[q_idx];
+
+		if (q_vector->rx.ring || q_vector->tx.ring)
+			napi_enable(&q_vector->napi);
+	}
 }
 
 /**
@@ -4453,8 +4457,12 @@ static void i40e_napi_disable_all(struct i40e_vsi *vsi)
 	if (!vsi->netdev)
 		return;
 
-	for (q_idx = 0; q_idx < vsi->num_q_vectors; q_idx++)
-		napi_disable(&vsi->q_vectors[q_idx]->napi);
+	for (q_idx = 0; q_idx < vsi->num_q_vectors; q_idx++) {
+		struct i40e_q_vector *q_vector = vsi->q_vectors[q_idx];
+
+		if (q_vector->rx.ring || q_vector->tx.ring)
+			napi_disable(&q_vector->napi);
+	}
 }
 
 /**
-- 
2.12.0
