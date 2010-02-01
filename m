From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv2 NEXT 5/7] qlcnic: support LED blink for device identification
Date: Mon,  1 Feb 2010 07:24:58 -0800
Message-ID: <1265037900-20403-6-git-send-email-amit.salecha@qlogic.com>
References: <1265037900-20403-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com,
	ameen.rahman@qlogic.com,
	Sucheta Chakraborty <sucheta@dut6195.unminc.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:11624 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755243Ab0BAPZE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Feb 2010 10:25:04 -0500
In-Reply-To: <1265037900-20403-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta@dut6195.unminc.com>

Added support of device identification by blinking LED for specified time.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h         |    1 +
 drivers/net/qlcnic/qlcnic_ethtool.c |   26 ++++++++++++++++++++++++++
 drivers/net/qlcnic/qlcnic_hw.c      |   22 ++++++++++++++++++++++
 3 files changed, 49 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 9662a37..514e805 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -1015,6 +1015,7 @@ void qlcnic_pcie_sem_unlock(struct qlcnic_adapter *, int);
 
 int qlcnic_get_board_info(struct qlcnic_adapter *adapter);
 int qlcnic_wol_supported(struct qlcnic_adapter *adapter);
+int qlcnic_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate);
 
 /* Functions from qlcnic_init.c */
 int qlcnic_phantom_init(struct qlcnic_adapter *adapter);
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index 37df5f6..7212319 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -618,6 +618,7 @@ qlcnic_diag_test(struct net_device *dev, struct ethtool_test *eth_test,
 		     u64 *data)
 {
 	memset(data, 0, sizeof(u64) * QLCNIC_TEST_LEN);
+
 	data[0] = qlcnic_reg_test(dev);
 	if (data[0])
 		eth_test->flags |= ETH_TEST_FL_FAILED;
@@ -693,6 +694,30 @@ static int qlcnic_set_tso(struct net_device *dev, u32 data)
 	return 0;
 }
 
+static int qlcnic_blink_led(struct net_device *dev, u32 val)
+{
+	struct qlcnic_adapter *adapter = netdev_priv(dev);
+	int ret;
+
+	ret = qlcnic_config_led(adapter, 1, 0xf);
+	if (ret) {
+		dev_err(&adapter->pdev->dev,
+			"Failed to set LED blink state.\n");
+		return ret;
+	}
+
+	msleep_interruptible(val * 1000);
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
 static void
 qlcnic_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
@@ -867,4 +892,5 @@ const struct ethtool_ops qlcnic_ethtool_ops = {
 	.set_coalesce = qlcnic_set_intr_coalesce,
 	.get_flags = ethtool_op_get_flags,
 	.set_flags = qlcnic_set_flags,
+	.phys_id = qlcnic_blink_led,
 };
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index 91234e7..8724e56 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -1199,3 +1199,25 @@ qlcnic_wol_supported(struct qlcnic_adapter *adapter)
 
 	return 0;
 }
+
+int qlcnic_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate)
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
-- 
1.6.0.2

