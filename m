From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 12/12] be2net: query max_tx_qs for BE3 super-nic profile from FW
Date: Mon, 1 Sep 2014 11:54:24 +0530
Message-ID: <1409552664-15990-13-git-send-email-sathya.perla@emulex.com>
References: <1409552664-15990-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:19158 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752233AbaIAGV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 02:21:56 -0400
In-Reply-To: <1409552664-15990-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <Suresh.Reddy@emulex.com>

In the BE3 super-nic profile, the max_tx_qs value can vary for each function.
So the driver needs to query this value from FW instead of using the
pre-defined constant BE3_MAX_TX_QS.

Signed-off-by: Suresh Reddy <Suresh.Reddy@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index f3235d1..a30156b 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3324,10 +3324,19 @@ static void BEx_get_resources(struct be_adapter *adapter,
 	 */
 	if (BE2_chip(adapter) || use_sriov ||  (adapter->port_num > 1) ||
 	    !be_physfn(adapter) || (be_is_mc(adapter) &&
-	    !(adapter->function_caps & BE_FUNCTION_CAPS_RSS)))
+	    !(adapter->function_caps & BE_FUNCTION_CAPS_RSS))) {
 		res->max_tx_qs = 1;
-	else
+	} else if (adapter->function_caps & BE_FUNCTION_CAPS_SUPER_NIC) {
+		struct be_resources super_nic_res = {0};
+		/* On a SuperNIC profile, the driver needs to use the
+		 * GET_PROFILE_CONFIG cmd to query the per-function TXQ limits
+		 */
+		be_cmd_get_profile_config(adapter, &super_nic_res, 0);
+		/* Some old versions of BE3 FW don't report max_tx_qs value */
+		res->max_tx_qs = super_nic_res.max_tx_qs ? : BE3_MAX_TX_QS;
+	} else {
 		res->max_tx_qs = BE3_MAX_TX_QS;
+	}
 
 	if ((adapter->function_caps & BE_FUNCTION_CAPS_RSS) &&
 	    !use_sriov && be_physfn(adapter))
-- 
1.7.1
