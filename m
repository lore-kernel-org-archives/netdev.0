From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 6/8] qlcnic: fix link diag test
Date: Wed, 11 Aug 2010 05:05:27 -0700
Message-ID: <1281528329-8812-7-git-send-email-amit.salecha@qlogic.com>
References: <1281528329-8812-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:23703 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751707Ab0HKMFa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Aug 2010 08:05:30 -0400
In-Reply-To: <1281528329-8812-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

o Give sufficient time for all makes of PHY modules
  to establish the link after loopback test.
o Perform online test before offline test.

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_ethtool.c |   17 ++++++++---------
 drivers/net/qlcnic/qlcnic_hw.c      |    1 +
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index 9328d59..3d4655d 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -747,6 +747,14 @@ qlcnic_diag_test(struct net_device *dev, struct ethtool_test *eth_test,
 {
 	memset(data, 0, sizeof(u64) * QLCNIC_TEST_LEN);
 
+	data[0] = qlcnic_reg_test(dev);
+	if (data[0])
+		eth_test->flags |= ETH_TEST_FL_FAILED;
+
+	data[1] = (u64) qlcnic_test_link(dev);
+	if (data[1])
+		eth_test->flags |= ETH_TEST_FL_FAILED;
+
 	if (eth_test->flags == ETH_TEST_FL_OFFLINE) {
 		data[2] = qlcnic_irq_test(dev);
 		if (data[2])
@@ -757,15 +765,6 @@ qlcnic_diag_test(struct net_device *dev, struct ethtool_test *eth_test,
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
 	}
-
-	data[0] = qlcnic_reg_test(dev);
-	if (data[0])
-		eth_test->flags |= ETH_TEST_FL_FAILED;
-
-	/* link test */
-	data[1] = (u64) qlcnic_test_link(dev);
-	if (data[1])
-		eth_test->flags |= ETH_TEST_FL_FAILED;
 }
 
 static void
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index e08c8b0..9d40ce0 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -1245,4 +1245,5 @@ void qlcnic_clear_ilb_mode(struct qlcnic_adapter *adapter)
 		mode = VPORT_MISS_MODE_ACCEPT_MULTI;
 
 	qlcnic_nic_set_promisc(adapter, mode);
+	msleep(1000);
 }
-- 
1.6.0.2

