From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH 2/2] be2net: Bug fix to send config commands to hardware
 after netdev_register
Date: Fri, 6 Nov 2009 17:37:32 +0530
Message-ID: <20091106120720.GA19198@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:12668 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755075AbZKFMH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 07:07:26 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sending config commands to be2 hardware before netdev_register is
completed, is sometimes causing the async link notification to arrive
even before the driver is ready to handle it. The commands for vlan
config and flow control settings can infact wait till be_open.
This patch takes care of that.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be_main.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 4a7a452..876b357 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1610,11 +1610,21 @@ static int be_open(struct net_device *netdev)
 
 	status = be_cmd_link_status_query(adapter, &link_up);
 	if (status)
-		return status;
+		goto ret_sts;
 	be_link_status_update(adapter, link_up);
 
+	status = be_vid_config(adapter);
+	if (status)
+		goto ret_sts;
+
+	status = be_cmd_set_flow_control(adapter,
+					adapter->tx_fc, adapter->rx_fc);
+	if (status)
+		goto ret_sts;
+
 	schedule_delayed_work(&adapter->work, msecs_to_jiffies(100));
-	return 0;
+ret_sts:
+	return status;
 }
 
 static int be_setup(struct be_adapter *adapter)
@@ -1648,18 +1658,8 @@ static int be_setup(struct be_adapter *adapter)
 	if (status != 0)
 		goto rx_qs_destroy;
 
-	status = be_vid_config(adapter);
-	if (status != 0)
-		goto mccqs_destroy;
-
-	status = be_cmd_set_flow_control(adapter,
-					adapter->tx_fc, adapter->rx_fc);
-	if (status != 0)
-		goto mccqs_destroy;
 	return 0;
 
-mccqs_destroy:
-	be_mcc_queues_destroy(adapter);
 rx_qs_destroy:
 	be_rx_queues_destroy(adapter);
 tx_qs_destroy:
-- 
1.6.3.3

