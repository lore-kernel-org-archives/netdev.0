From: amit.salecha@qlogic.com
Subject: [PATCH NEXT 2/2] qlcnic: add external loopback support
Date: Mon, 27 Jun 2011 23:40:47 -0700
Message-ID: <1309243247-15950-3-git-send-email-amit.salecha@qlogic.com>
References: <1309243247-15950-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Amit Kumar Salecha <amit.salecha@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn.pathscale.com ([198.186.3.75]:36881 "HELO mx.mv.qlogic.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1756262Ab1F1GtG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2011 02:49:06 -0400
In-Reply-To: <1309243247-15950-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>

o Add external loopback test in self test:
  - Send set external loopback mode request to fw.
     To quiscent other storage functions.
  - Perform test
  - Send unset loopback mode request to fw.

o Rename ilb to lb.
o Update driver version 5.0.20.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h         |    5 +++--
 drivers/net/qlcnic/qlcnic_ethtool.c |   25 ++++++++++++++++---------
 drivers/net/qlcnic/qlcnic_init.c    |    3 ++-
 3 files changed, 21 insertions(+), 12 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index e545450..9899a79 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -36,8 +36,8 @@
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 0
-#define _QLCNIC_LINUX_SUBVERSION 19
-#define QLCNIC_LINUX_VERSIONID  "5.0.19"
+#define _QLCNIC_LINUX_SUBVERSION 20
+#define QLCNIC_LINUX_VERSIONID  "5.0.20"
 #define QLCNIC_DRV_IDC_VER  0x01
 #define QLCNIC_DRIVER_VERSION  ((_QLCNIC_LINUX_MAJOR << 16) |\
 		 (_QLCNIC_LINUX_MINOR << 8) | (_QLCNIC_LINUX_SUBVERSION))
@@ -782,6 +782,7 @@ struct qlcnic_mac_list_s {
 #define QLCNIC_IP_DOWN		3
 
 #define QLCNIC_ILB_MODE		0x1
+#define QLCNIC_ELB_MODE		0x2
 
 #define QLCNIC_LINKEVENT	0x1
 #define QLCNIC_LB_RESPONSE	0x2
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index 743035e..821d8a7 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -85,7 +85,8 @@ static const char qlcnic_gstrings_test[][ETH_GSTRING_LEN] = {
 	"Register_Test_on_offline",
 	"Link_Test_on_offline",
 	"Interrupt_Test_offline",
-	"Loopback_Test_offline"
+	"Internal_Loopback_offline",
+	"External_Loopback_offline"
 };
 
 #define QLCNIC_TEST_LEN	ARRAY_SIZE(qlcnic_gstrings_test)
@@ -709,7 +710,7 @@ int qlcnic_check_loopback_buff(unsigned char *data, u8 mac[])
 	return memcmp(data, buff, QLCNIC_ILB_PKT_SIZE);
 }
 
-static int qlcnic_do_ilb_test(struct qlcnic_adapter *adapter)
+static int qlcnic_do_lb_test(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 	struct qlcnic_host_sds_ring *sds_ring = &recv_ctx->sds_rings[0];
@@ -735,19 +736,19 @@ static int qlcnic_do_ilb_test(struct qlcnic_adapter *adapter)
 		dev_kfree_skb_any(skb);
 
 		if (!adapter->diag_cnt)
-			dev_warn(&adapter->pdev->dev, "ILB Test: %dth packet"
+			dev_warn(&adapter->pdev->dev, "LB Test: %dth packet"
 				" not recevied\n", i + 1);
 		else
 			cnt++;
 	}
 	if (cnt != i) {
-		dev_warn(&adapter->pdev->dev, "ILB Test failed\n");
+		dev_warn(&adapter->pdev->dev, "LB Test failed\n");
 		return -1;
 	}
 	return 0;
 }
 
-static int qlcnic_iloopback_test(struct net_device *netdev)
+static int qlcnic_loopback_test(struct net_device *netdev, u8 mode)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	int max_sds_rings = adapter->max_sds_rings;
@@ -755,7 +756,8 @@ static int qlcnic_iloopback_test(struct net_device *netdev)
 	int loop = 0;
 	int ret;
 
-	netdev_info(netdev, "%s:  in progress\n", __func__);
+	netdev_info(netdev, "%s loopback test in progress\n",
+		   mode == QLCNIC_ILB_MODE ? "internal" : "external");
 	if (adapter->op_mode == QLCNIC_NON_PRIV_FUNC) {
 		netdev_warn(netdev, "Loopback test not supported for non "
 				"privilege function\n");
@@ -772,7 +774,7 @@ static int qlcnic_iloopback_test(struct net_device *netdev)
 
 	sds_ring = &adapter->recv_ctx->sds_rings[0];
 
-	ret = qlcnic_set_lb_mode(adapter, QLCNIC_ILB_MODE);
+	ret = qlcnic_set_lb_mode(adapter, mode);
 	if (ret)
 		goto free_res;
 
@@ -790,7 +792,7 @@ static int qlcnic_iloopback_test(struct net_device *netdev)
 		goto free_res;
 	}
 
-	ret = qlcnic_do_ilb_test(adapter);
+	ret = qlcnic_do_lb_test(adapter);
 
 	qlcnic_clear_lb_mode(adapter);
 
@@ -822,10 +824,15 @@ qlcnic_diag_test(struct net_device *dev, struct ethtool_test *eth_test,
 		if (data[2])
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
-		data[3] = qlcnic_iloopback_test(dev);
+		data[3] = qlcnic_loopback_test(dev, QLCNIC_ILB_MODE);
 		if (data[3])
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
+		if (eth_test->flags & ETH_TEST_FL_EXTERNAL_LB) {
+			data[4] = qlcnic_loopback_test(dev, QLCNIC_ELB_MODE);
+			if (data[4])
+				eth_test->flags |= ETH_TEST_FL_FAILED;
+		}
 	}
 }
 
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index 9d5bee0..6ec1baa 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -1303,7 +1303,8 @@ qlcnic_handle_linkevent(struct qlcnic_adapter *adapter,
 		dev_info(&netdev->dev, "unsupported cable length %d\n",
 				cable_len);
 
-	if (!link_status && (lb_status == 1))
+	if (!link_status && (lb_status == QLCNIC_ILB_MODE ||
+	    lb_status == QLCNIC_ELB_MODE))
 		adapter->ahw->loopback_state |= QLCNIC_LINKEVENT;
 
 	qlcnic_advert_link_change(adapter, link_status);
-- 
1.7.3.3

