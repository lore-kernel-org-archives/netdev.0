From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [PATCH net-next 2/9] be2net: query FW to check if EVB is enabled
Date: Fri, 10 Jul 2015 05:32:44 -0400
Message-ID: <1436520771-11656-3-git-send-email-sathya.perla@avagotech.com>
References: <1436520771-11656-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:56755 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753397AbbGJJ0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 05:26:32 -0400
In-Reply-To: <1436520771-11656-1-git-send-email-sathya.perla@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh Purayil <kalesh.purayil@avagotech.com>

The current code assumes that bridge functionality (EVB) in the adapter
is enabled only when SR-IOV is enabled. This is not always true.
This patch uses the GET_HSW_CONFIG FW cmd to query this from the FW.

Signed-off-by: Kalesh AP <kalesh.purayil@avagotech.com>
Signed-off-by: Sathya Perla <sathya.perla@avagotech.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.h | 1 +
 drivers/net/ethernet/emulex/benet/be_main.c | 6 +++---
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 2716e6f..f0a92b7 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1758,6 +1758,7 @@ struct be_cmd_req_set_mac_list {
 /*********************** HSW Config ***********************/
 #define PORT_FWD_TYPE_VEPA		0x3
 #define PORT_FWD_TYPE_VEB		0x2
+#define PORT_FWD_TYPE_PASSTHRU		0x1
 
 #define ENABLE_MAC_SPOOFCHK		0x2
 #define DISABLE_MAC_SPOOFCHK		0x3
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 635c62f..f21c56a 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -5073,9 +5073,6 @@ static int be_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 	int status = 0;
 	u8 hsw_mode;
 
-	if (!sriov_enabled(adapter))
-		return 0;
-
 	/* BE and Lancer chips support VEB mode only */
 	if (BEx_chip(adapter) || lancer_chip(adapter)) {
 		hsw_mode = PORT_FWD_TYPE_VEB;
@@ -5085,6 +5082,9 @@ static int be_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 					       NULL);
 		if (status)
 			return 0;
+
+		if (hsw_mode == PORT_FWD_TYPE_PASSTHRU)
+			return 0;
 	}
 
 	return ndo_dflt_bridge_getlink(skb, pid, seq, dev,
-- 
2.4.1
