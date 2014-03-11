From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 5/7] be2net: Create multiple TXQs on RSS capable multi-channel BE3-R interfaces
Date: Tue, 11 Mar 2014 18:53:07 +0530
Message-ID: <1394544189-20277-6-git-send-email-sathya.perla@emulex.com>
References: <1394544189-20277-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:37774 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753617AbaCKNUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 09:20:10 -0400
In-Reply-To: <1394544189-20277-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

Currently the driver creates only a single TXQ on any BE3-R multi-channel
interface.
This patch changes this and creates multiple TXQs on RSS-capable multi-channel
BE3-R interfaces. This change helps improve the TX pps performance on the
affected interface.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index eaf0891..fc44bb3 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3209,9 +3209,13 @@ static void BEx_get_resources(struct be_adapter *adapter,
 
 	res->max_mcast_mac = BE_MAX_MC;
 
-	/* For BE3 1Gb ports, F/W does not properly support multiple TXQs */
-	if (BE2_chip(adapter) || use_sriov || be_is_mc(adapter) ||
-	    !be_physfn(adapter) || (adapter->port_num > 1))
+	/* 1) For BE3 1Gb ports, FW does not support multiple TXQs
+	 * 2) Create multiple TX rings on a BE3-R multi-channel interface
+	 *    *only* if it is RSS-capable.
+	 */
+	if (BE2_chip(adapter) || use_sriov ||  (adapter->port_num > 1) ||
+	    !be_physfn(adapter) || (be_is_mc(adapter) &&
+	    !(adapter->function_caps & BE_FUNCTION_CAPS_RSS)))
 		res->max_tx_qs = 1;
 	else
 		res->max_tx_qs = BE3_MAX_TX_QS;
-- 
1.7.1
