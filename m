From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 5/7] be2net: Fix Lancer statistics
Date: Wed, 25 Apr 2012 17:16:52 +0530
Message-ID: <ecc96692-d43e-4a1c-a72d-2293d87652b0@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:29218 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758036Ab2DYLsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 07:48:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix port num sent in command to get stats. Also skip unnecessary
parsing of stats for Lancer.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    2 +-
 drivers/net/ethernet/emulex/benet/be_main.c |    5 +++++
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 3ba4aed..4e07e58 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1221,7 +1221,7 @@ int lancer_cmd_get_pport_stats(struct be_adapter *adapter,
 			OPCODE_ETH_GET_PPORT_STATS, nonemb_cmd->size, wrb,
 			nonemb_cmd);
 
-	req->cmd_params.params.pport_num = cpu_to_le16(adapter->port_num);
+	req->cmd_params.params.pport_num = cpu_to_le16(adapter->hba_port_num);
 	req->cmd_params.params.reset_stats = 0;
 
 	be_mcc_notify(adapter);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 9d42fab..8bc9e12 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -421,6 +421,9 @@ void be_parse_stats(struct be_adapter *adapter)
 		populate_be2_stats(adapter);
 	}
 
+	if (lancer_chip(adapter))
+		goto done;
+
 	/* as erx_v1 is longer than v0, ok to use v1 defn for v0 access */
 	for_all_rx_queues(adapter, rxo, i) {
 		/* below erx HW counter can actually wrap around after
@@ -429,6 +432,8 @@ void be_parse_stats(struct be_adapter *adapter)
 		accumulate_16bit_val(&rx_stats(rxo)->rx_drops_no_frags,
 				(u16)erx->rx_drops_no_fragments[rxo->q.id]);
 	}
+done:
+	return;
 }
 
 static struct rtnl_link_stats64 *be_get_stats64(struct net_device *netdev,
-- 
1.6.0.2
