From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 01/17] i40e/i40evf: Fix handling of napi budget
Date: Fri, 16 Oct 2015 05:10:09 -0700
Message-ID: <1444997425-3396-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444997425-3396-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:64539 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754082AbbJPMKj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2015 08:10:39 -0400
In-Reply-To: <1444997425-3396-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

The polling routine for i40e was rounding up the budget for Rx cleanup to
1.  This is incorrect as the netpoll poll call is expecting no Rx to be
processed as the budget passed was 0.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 5 +++++
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 5 +++++
 2 files changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 01e5ece..b560e02 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1846,6 +1846,10 @@ int i40e_napi_poll(struct napi_struct *napi, int budget)
 		ring->arm_wb = false;
 	}
 
+	/* Handle case where we are called by netpoll with a budget of 0 */
+	if (budget <= 0)
+		goto tx_only;
+
 	/* We attempt to distribute budget to each Rx queue fairly, but don't
 	 * allow the budget to go below 1 because that would exit polling early.
 	 */
@@ -1862,6 +1866,7 @@ int i40e_napi_poll(struct napi_struct *napi, int budget)
 
 	/* If work not completed, return budget and polling will return */
 	if (!clean_complete) {
+tx_only:
 		if (arm_wb)
 			i40e_force_wb(vsi, q_vector);
 		return budget;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 0e71eb4..1894cc8 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1287,6 +1287,10 @@ int i40evf_napi_poll(struct napi_struct *napi, int budget)
 		ring->arm_wb = false;
 	}
 
+	/* Handle case where we are called by netpoll with a budget of 0 */
+	if (budget <= 0)
+		goto tx_only;
+
 	/* We attempt to distribute budget to each Rx queue fairly, but don't
 	 * allow the budget to go below 1 because that would exit polling early.
 	 */
@@ -1303,6 +1307,7 @@ int i40evf_napi_poll(struct napi_struct *napi, int budget)
 
 	/* If work not completed, return budget and polling will return */
 	if (!clean_complete) {
+tx_only:
 		if (arm_wb)
 			i40evf_force_wb(vsi, q_vector);
 		return budget;
-- 
2.4.3
