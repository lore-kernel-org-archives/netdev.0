From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 5/7] qlcnic: add LED diagnostic test.
Date: Mon,  1 Feb 2010 06:30:42 -0800
Message-ID: <1265034644-19461-6-git-send-email-amit.salecha@qlogic.com>
References: <1265034644-19461-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com,
	ameen.rahman@qlogic.com,
	Sucheta Chakraborty <sucheta@dut6195.unminc.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:9787 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754709Ab0BAOaq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Feb 2010 09:30:46 -0500
In-Reply-To: <1265034644-19461-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta@dut6195.unminc.com>

LED test support in ethtool self test. Blink LED for 10 secs.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h         |    3 ++
 drivers/net/qlcnic/qlcnic_ctx.c     |    2 -
 drivers/net/qlcnic/qlcnic_ethtool.c |   10 ++++++-
 drivers/net/qlcnic/qlcnic_hw.c      |   48 +++++++++++++++++++++++++++++++++++
 4 files changed, 60 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 9662a37..2fc710f 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -560,6 +560,8 @@ struct qlcnic_recv_context {
 /*
  * Context state
  */
+#define QLCHAL_VERSION 1
+
 #define QLCNIC_HOST_CTX_STATE_ACTIVE	2
 
 /*
@@ -1015,6 +1017,7 @@ void qlcnic_pcie_sem_unlock(struct qlcnic_adapter *, int);
 
 int qlcnic_get_board_info(struct qlcnic_adapter *adapter);
 int qlcnic_wol_supported(struct qlcnic_adapter *adapter);
+int qlcnic_led_test(struct qlcnic_adapter *adapter);
 
 /* Functions from qlcnic_init.c */
 int qlcnic_phantom_init(struct qlcnic_adapter *adapter);
diff --git a/drivers/net/qlcnic/qlcnic_ctx.c b/drivers/net/qlcnic/qlcnic_ctx.c
index 71c16a1..510edc5 100644
--- a/drivers/net/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/qlcnic/qlcnic_ctx.c
@@ -24,8 +24,6 @@
 
 #include "qlcnic.h"
 
-#define QLCHAL_VERSION	1
-
 static u32
 qlcnic_poll_rsp(struct qlcnic_adapter *adapter)
 {
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index 37df5f6..5be4c8b 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -65,7 +65,8 @@ static const struct qlcnic_stats qlcnic_gstrings_stats[] = {
 
 static const char qlcnic_gstrings_test[][ETH_GSTRING_LEN] = {
 	"Register_Test_on_offline",
-	"Link_Test_on_offline"
+	"Link_Test_on_offline",
+	"LED_Test_on_offline"
 };
 
 #define QLCNIC_TEST_LEN	ARRAY_SIZE(qlcnic_gstrings_test)
@@ -617,7 +618,10 @@ static void
 qlcnic_diag_test(struct net_device *dev, struct ethtool_test *eth_test,
 		     u64 *data)
 {
+	struct qlcnic_adapter *adapter = netdev_priv(dev);
+
 	memset(data, 0, sizeof(u64) * QLCNIC_TEST_LEN);
+
 	data[0] = qlcnic_reg_test(dev);
 	if (data[0])
 		eth_test->flags |= ETH_TEST_FL_FAILED;
@@ -626,6 +630,10 @@ qlcnic_diag_test(struct net_device *dev, struct ethtool_test *eth_test,
 	data[1] = (u64) qlcnic_test_link(dev);
 	if (data[1])
 		eth_test->flags |= ETH_TEST_FL_FAILED;
+
+	data[2] = (u64) qlcnic_led_test(adapter);
+	if (data[2])
+		eth_test->flags |= ETH_TEST_FL_FAILED;
 }
 
 static void
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index 91234e7..4e60c21 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -1199,3 +1199,51 @@ qlcnic_wol_supported(struct qlcnic_adapter *adapter)
 
 	return 0;
 }
+
+static int qlcnic_config_led(struct qlcnic_adapter *adapter,
+						u32 state, u32 rate)
+{
+	struct qlcnic_nic_req   req;
+	int rv;
+	u64 word;
+
+	memset(&req, 0, sizeof(struct qlcnic_nic_req));
+	req.qhdr = cpu_to_le64(QLCNIC_HOST_REQUEST << 23);
+
+	word = QLCNIC_H2C_OPCODE_CONFIG_LED | ((u64)adapter->portnum << 16);
+	req.req_hdr = cpu_to_le64(word);
+
+	req.words[0] = cpu_to_le64((u64)rate << 32);
+	req.words[1] = cpu_to_le64(state);
+
+	rv = qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
+	if (rv)
+		dev_err(&adapter->pdev->dev, "LED configuration failed.\n");
+
+	return rv;
+}
+
+int qlcnic_led_test(struct qlcnic_adapter *adapter)
+{
+	int ret;
+
+	ret = qlcnic_config_led(adapter, 1, 0xf);
+	if (ret) {
+		dev_err(&adapter->pdev->dev,
+			"Failed to set LED blink state.\n");
+		return ret;
+	}
+
+	msleep_interruptible(10 * 1000);
+
+	ret = qlcnic_config_led(adapter, 0, 0xf);
+	if (ret) {
+		dev_err(&adapter->pdev->dev,
+			"Failed to reset LED blink state.\n");
+		return ret;
+	}
+
+	return 0;
+}
+
+
-- 
1.6.0.2

