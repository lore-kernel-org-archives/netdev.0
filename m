From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH next 3/6] be2net: Create single TXQ on BE3-R 1G ports
Date: Tue, 1 Oct 2013 15:59:58 +0530
Message-ID: <1380623401-15630-4-git-send-email-sathya.perla@emulex.com>
References: <1380623401-15630-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:8678 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753115Ab3JAK0b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 06:26:31 -0400
In-Reply-To: <1380623401-15630-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

On BE3-R 1G ports (identified by port numbers 2 and 3) the FW cannot properly
support multiple TXQs. This also makes the number of RX and TX queues symmetric
as only a single RXQ is available on 1G ports.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   11 ++---------
 1 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 4cb2ac7..be12987 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2967,8 +2967,9 @@ static void BEx_get_resources(struct be_adapter *adapter,
 		res->max_vlans = BE_NUM_VLANS_SUPPORTED;
 	res->max_mcast_mac = BE_MAX_MC;
 
+	/* For BE3 1Gb ports, F/W does not properly support multiple TXQs */
 	if (BE2_chip(adapter) || use_sriov || be_is_mc(adapter) ||
-	    !be_physfn(adapter))
+	    !be_physfn(adapter) || (adapter->port_num > 1))
 		res->max_tx_qs = 1;
 	else
 		res->max_tx_qs = BE3_MAX_TX_QS;
@@ -3010,14 +3011,6 @@ static int be_get_resources(struct be_adapter *adapter)
 		adapter->res = res;
 	}
 
-	/* For BE3 only check if FW suggests a different max-txqs value */
-	if (BE3_chip(adapter)) {
-		status = be_cmd_get_profile_config(adapter, &res, 0);
-		if (!status && res.max_tx_qs)
-			adapter->res.max_tx_qs =
-				min(adapter->res.max_tx_qs, res.max_tx_qs);
-	}
-
 	/* For Lancer, SH etc read per-function resource limits from FW.
 	 * GET_FUNC_CONFIG returns per function guaranteed limits.
 	 * GET_PROFILE_CONFIG returns PCI-E related limits PF-pool limits
-- 
1.7.1
