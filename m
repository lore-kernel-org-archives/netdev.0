From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v2 1/3] i40e/i40evf: Fix handling of napi budget
Date: Thu, 24 Sep 2015 09:04:26 -0700
Message-ID: <20150924160426.22015.37868.stgit@ahduyck-vm-fedora22>
References: <20150924160027.22015.15754.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35021 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755775AbbIXQE2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 12:04:28 -0400
Received: by pacfv12 with SMTP id fv12so78069449pac.2
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 09:04:27 -0700 (PDT)
In-Reply-To: <20150924160027.22015.15754.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The polling routine for i40e was rounding up the budget for Rx cleanup to
1.  This is incorrect as the netpoll poll call is expecting no Rx to be
processed as the budget passed was 0.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   |    5 +++++
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c |    5 +++++
 2 files changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index d51b8edebfee..66b1fd26f0fc 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1923,6 +1923,10 @@ int i40e_napi_poll(struct napi_struct *napi, int budget)
 		ring->arm_wb = false;
 	}
 
+	/* Handle case where we are called by netpoll with a budget of 0 */
+	if (budget <= 0)
+		goto tx_only;
+
 	/* We attempt to distribute budget to each Rx queue fairly, but don't
 	 * allow the budget to go below 1 because that would exit polling early.
 	 */
@@ -1939,6 +1943,7 @@ int i40e_napi_poll(struct napi_struct *napi, int budget)
 
 	/* If work not completed, return budget and polling will return */
 	if (!clean_complete) {
+tx_only:
 		if (arm_wb)
 			i40e_force_wb(vsi, q_vector);
 		return budget;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 7b20f53a414a..c60e9cf016c2 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1367,6 +1367,10 @@ int i40evf_napi_poll(struct napi_struct *napi, int budget)
 		ring->arm_wb = false;
 	}
 
+	/* Handle case where we are called by netpoll with a budget of 0 */
+	if (budget <= 0)
+		goto tx_only;
+
 	/* We attempt to distribute budget to each Rx queue fairly, but don't
 	 * allow the budget to go below 1 because that would exit polling early.
 	 */
@@ -1383,6 +1387,7 @@ int i40evf_napi_poll(struct napi_struct *napi, int budget)
 
 	/* If work not completed, return budget and polling will return */
 	if (!clean_complete) {
+tx_only:
 		if (arm_wb)
 			i40e_force_wb(vsi, q_vector);
 		return budget;
