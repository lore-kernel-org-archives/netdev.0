From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 4/8] be2net: use v1 of SET_FLOW_CONTROL command
Date: Fri, 12 Sep 2014 17:39:17 +0530
Message-ID: <1410523761-1744-5-git-send-email-sathya.perla@emulex.com>
References: <1410523761-1744-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:21722 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754521AbaILMGt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 08:06:49 -0400
In-Reply-To: <1410523761-1744-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <Suresh.Reddy@emulex.com>

In some configurations the FW doesn't allow changing flow control settings
of a link. Unless a v1 version of the SET_FLOW_CONTROL cmd is used, the FW
doesn't report an error to the driver.

Signed-off-by: Suresh Reddy <Suresh.Reddy@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    5 +++++
 drivers/net/ethernet/emulex/benet/be_cmds.h |    3 ++-
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 8bb6fd9..5d8016c 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1948,6 +1948,7 @@ int be_cmd_set_flow_control(struct be_adapter *adapter, u32 tx_fc, u32 rx_fc)
 			       OPCODE_COMMON_SET_FLOW_CONTROL, sizeof(*req),
 			       wrb, NULL);
 
+	req->hdr.version = 1;
 	req->tx_flow_control = cpu_to_le16((u16)tx_fc);
 	req->rx_flow_control = cpu_to_le16((u16)rx_fc);
 
@@ -1955,6 +1956,10 @@ int be_cmd_set_flow_control(struct be_adapter *adapter, u32 tx_fc, u32 rx_fc)
 
 err:
 	spin_unlock_bh(&adapter->mcc_lock);
+
+	if (base_status(status) == MCC_STATUS_FEATURE_NOT_SUPPORTED)
+		return  -EOPNOTSUPP;
+
 	return status;
 }
 
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 0e11868..3b1606c 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -57,7 +57,8 @@ enum mcc_base_status {
 	MCC_STATUS_ILLEGAL_FIELD = 3,
 	MCC_STATUS_INSUFFICIENT_BUFFER = 4,
 	MCC_STATUS_UNAUTHORIZED_REQUEST = 5,
-	MCC_STATUS_NOT_SUPPORTED = 66
+	MCC_STATUS_NOT_SUPPORTED = 66,
+	MCC_STATUS_FEATURE_NOT_SUPPORTED = 68
 };
 
 /* Additional status */
-- 
1.7.1
