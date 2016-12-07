From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/20] i40e/i40evf: napi_poll must return the work done
Date: Tue,  6 Dec 2016 23:33:38 -0800
Message-ID: <20161207073354.88568-5-jeffrey.t.kirsher@intel.com>
References: <20161207073354.88568-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:26483 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752005AbcLGHes (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 02:34:48 -0500
In-Reply-To: <20161207073354.88568-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Currently the function i40e_napi-poll() returns 0 when it clean completely
the Rx rings, but this foul budget accounting in core code.

Fix this by returning the actual work done, capped to budget - 1, since
the core doesn't allow to return the full budget when the driver modifies
the NAPI status

This is based on a similar change that was made for the ixgbe driver by
Paolo Abeni.

Change-ID: Ic3d93ad2fa2fc8ce3164bc461e69367da0f9173b
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 2 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 5544b50..352cf7c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2027,7 +2027,7 @@ int i40e_napi_poll(struct napi_struct *napi, int budget)
 	else
 		i40e_update_enable_itr(vsi, q_vector);
 
-	return 0;
+	return min(work_done, budget - 1);
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index c4b174a..df67ef3 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1490,7 +1490,7 @@ int i40evf_napi_poll(struct napi_struct *napi, int budget)
 	else
 		i40e_update_enable_itr(vsi, q_vector);
 
-	return 0;
+	return min(work_done, budget - 1);
 }
 
 /**
-- 
2.9.3
