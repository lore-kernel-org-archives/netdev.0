From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-next 4/4] be2net: fix to avoid sending get_stats
 request if one is already being processed.
Date: Thu, 29 Jul 2010 21:48:58 +0530
Message-ID: <20100729161849.GA15529@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:17569 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757988Ab0G2QS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jul 2010 12:18:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GET_STATS request uses the same memory region as the response.
If a new request for get stats is fired before the response for
the previous get_stats request is received, the response will
corrupt the new request, causing the f/w to misbehave.

Signed-off-by: Somnath K <somnathk@serverengines.com>
Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be.h      |    1 +
 drivers/net/benet/be_cmds.c |    2 ++
 drivers/net/benet/be_main.c |    3 ++-
 3 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 5e6f581..99197bd 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -289,6 +289,7 @@ struct be_adapter {
 	u32 rx_fc;		/* Rx flow control */
 	u32 tx_fc;		/* Tx flow control */
 	bool ue_detected;
+	bool stats_ioctl_sent;
 	int link_speed;
 	u8 port_type;
 	u8 transceiver;
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 7fd860d..3d30549 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -75,6 +75,7 @@ static int be_mcc_compl_process(struct be_adapter *adapter,
 			be_dws_le_to_cpu(&resp->hw_stats,
 						sizeof(resp->hw_stats));
 			netdev_stats_update(adapter);
+			adapter->stats_ioctl_sent = false;
 		}
 	} else if ((compl_status != MCC_STATUS_NOT_SUPPORTED) &&
 		   (compl->tag0 != OPCODE_COMMON_NTWK_MAC_QUERY)) {
@@ -951,6 +952,7 @@ int be_cmd_get_stats(struct be_adapter *adapter, struct be_dma_mem *nonemb_cmd)
 	sge->len = cpu_to_le32(nonemb_cmd->size);
 
 	be_mcc_notify(adapter);
+	adapter->stats_ioctl_sent = true;
 
 err:
 	spin_unlock_bh(&adapter->mcc_lock);
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index e4a8ae3..74e146f 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1801,7 +1801,8 @@ static void be_worker(struct work_struct *work)
 	struct be_adapter *adapter =
 		container_of(work, struct be_adapter, work.work);
 
-	be_cmd_get_stats(adapter, &adapter->stats.cmd);
+	if (!adapter->stats_ioctl_sent)
+		be_cmd_get_stats(adapter, &adapter->stats.cmd);
 
 	/* Set EQ delay */
 	be_rx_eqd_update(adapter);
-- 
1.7.0.4

