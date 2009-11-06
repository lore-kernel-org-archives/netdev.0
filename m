From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH 1/2] be2net: fix to set proper flow control on resume
Date: Fri, 6 Nov 2009 17:36:59 +0530
Message-ID: <20091106120445.GA19181@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:12645 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755154AbZKFMGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 07:06:54 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If be2 goes into suspend after a user changes the flow control settings,
we are not programming them back after resume. This patch takes care of it.
We now get the flow control settings before going to suspend mode and
then apply them during resume.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be.h         |    2 ++
 drivers/net/benet/be_ethtool.c |    8 +++++---
 drivers/net/benet/be_main.c    |    8 +++++++-
 3 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index a80da0e..3b79a22 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -259,6 +259,8 @@ struct be_adapter {
 	u32 port_num;
 	bool promiscuous;
 	u32 cap;
+	u32 rx_fc;		/* Rx flow control */
+	u32 tx_fc;		/* Tx flow control */
 };
 
 extern const struct ethtool_ops be_ethtool_ops;
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index cda5bf2..f0fd95b 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -323,10 +323,12 @@ be_set_pauseparam(struct net_device *netdev, struct ethtool_pauseparam *ecmd)
 
 	if (ecmd->autoneg != 0)
 		return -EINVAL;
+	adapter->tx_fc = ecmd->tx_pause;
+	adapter->rx_fc = ecmd->rx_pause;
 
-	status = be_cmd_set_flow_control(adapter, ecmd->tx_pause,
-			ecmd->rx_pause);
-	if (!status)
+	status = be_cmd_set_flow_control(adapter,
+					adapter->tx_fc, adapter->rx_fc);
+	if (status)
 		dev_warn(&adapter->pdev->dev, "Pause param set failed.\n");
 
 	return status;
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 1f941f0..4a7a452 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1652,7 +1652,8 @@ static int be_setup(struct be_adapter *adapter)
 	if (status != 0)
 		goto mccqs_destroy;
 
-	status = be_cmd_set_flow_control(adapter, true, true);
+	status = be_cmd_set_flow_control(adapter,
+					adapter->tx_fc, adapter->rx_fc);
 	if (status != 0)
 		goto mccqs_destroy;
 	return 0;
@@ -1909,6 +1910,10 @@ static void be_netdev_init(struct net_device *netdev)
 
 	adapter->rx_csum = true;
 
+	/* Default settings for Rx and Tx flow control */
+	adapter->rx_fc = true;
+	adapter->tx_fc = true;
+
 	netif_set_gso_max_size(netdev, 65535);
 
 	BE_SET_NETDEV_OPS(netdev, &be_netdev_ops);
@@ -2171,6 +2176,7 @@ static int be_suspend(struct pci_dev *pdev, pm_message_t state)
 		be_close(netdev);
 		rtnl_unlock();
 	}
+	be_cmd_get_flow_control(adapter, &adapter->tx_fc, &adapter->rx_fc);
 	be_clear(adapter);
 
 	pci_save_state(pdev);
-- 
1.6.3.3

