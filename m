From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net 1/2] be2net: Poll for link status till 5s in ethtool diag
 test
Date: Fri, 2 May 2014 14:43:26 -0500
Message-ID: <20140502194326.GA20099@emulex.com>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:26294 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752136AbaEBTn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 15:43:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <suresh.reddy@emulex.com>

After the loopback test is finished,
it takes a few seconds for link to come back up.
Poll for link status every 1 second interval for 5 seconds, only in cases
when the link was UP before PHY loopback test was issued.

Signed-off-by: Suresh Reddy <suresh.reddy@emulex.com>
Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_ethtool.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 15ba96c..b4be712 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -788,9 +788,11 @@ static u64 be_loopback_test(struct be_adapter *adapter, u8 loopback_type,
 static void
 be_self_test(struct net_device *netdev, struct ethtool_test *test, u64 *data)
 {
+#define LINK_READY_TIMEOUT 5
 	struct be_adapter *adapter = netdev_priv(netdev);
 	int status;
 	u8 link_status = 0;
+	int timeout = netif_carrier_ok(netdev) ? 0 : LINK_READY_TIMEOUT;
 
 	if (adapter->function_caps & BE_FUNCTION_CAPS_SUPER_NIC) {
 		dev_err(&adapter->pdev->dev, "Self test not supported\n");
@@ -822,7 +824,18 @@ be_self_test(struct net_device *netdev, struct ethtool_test *test, u64 *data)
 		test->flags |= ETH_TEST_FL_FAILED;
 	}
 
-	status = be_cmd_link_status_query(adapter, NULL, &link_status, 0);
+	/* After the loopback test is finished,
+	 * it takes a few seconds for the link to comeback up.
+	 * Poll for 5s before reporting a failure to the link test.
+	 */
+	do {
+		status = be_cmd_link_status_query(adapter, NULL,
+						  &link_status, 0);
+		if (link_status || status || ++timeout >= LINK_READY_TIMEOUT)
+			break;
+		ssleep(1);
+	} while (true);
+
 	if (status) {
 		test->flags |= ETH_TEST_FL_FAILED;
 		data[4] = -1;
-- 
1.8.3.2
