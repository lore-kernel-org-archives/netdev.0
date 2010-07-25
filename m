From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv2 NEXT 1/2] qlcnic: fix loopback test
Date: Sat, 24 Jul 2010 21:32:17 -0700
Message-ID: <1280032338-7002-2-git-send-email-amit.salecha@qlogic.com>
References: <1280032338-7002-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:9239 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751065Ab0GYEcT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Jul 2010 00:32:19 -0400
In-Reply-To: <1280032338-7002-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Loopback not supported for virtual function.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h         |    2 --
 drivers/net/qlcnic/qlcnic_ethtool.c |   10 ++++++++--
 drivers/net/qlcnic/qlcnic_main.c    |   18 ------------------
 3 files changed, 8 insertions(+), 22 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index fad8e9a..9703893 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -1301,8 +1301,6 @@ struct qlcnic_nic_template {
 	int (*get_mac_addr) (struct qlcnic_adapter *, u8*);
 	int (*config_bridged_mode) (struct qlcnic_adapter *, u32);
 	int (*config_led) (struct qlcnic_adapter *, u32, u32);
-	int (*set_ilb_mode) (struct qlcnic_adapter *);
-	void (*clear_ilb_mode) (struct qlcnic_adapter *);
 	int (*start_firmware) (struct qlcnic_adapter *);
 };
 
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index 7d6558e..9328d59 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -678,6 +678,12 @@ static int qlcnic_loopback_test(struct net_device *netdev)
 	int max_sds_rings = adapter->max_sds_rings;
 	int ret;
 
+	if (adapter->op_mode == QLCNIC_NON_PRIV_FUNC) {
+		dev_warn(&adapter->pdev->dev, "Loopback test not supported"
+				"for non privilege function\n");
+		return 0;
+	}
+
 	if (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
 		return -EIO;
 
@@ -685,13 +691,13 @@ static int qlcnic_loopback_test(struct net_device *netdev)
 	if (ret)
 		goto clear_it;
 
-	ret = adapter->nic_ops->set_ilb_mode(adapter);
+	ret = qlcnic_set_ilb_mode(adapter);
 	if (ret)
 		goto done;
 
 	ret = qlcnic_do_ilb_test(adapter);
 
-	adapter->nic_ops->clear_ilb_mode(adapter);
+	qlcnic_clear_ilb_mode(adapter);
 
 done:
 	qlcnic_diag_free_res(netdev, max_sds_rings);
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index f1f7acf..f147958 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -107,8 +107,6 @@ static void qlcnic_config_indev_addr(struct net_device *dev, unsigned long);
 static int qlcnic_start_firmware(struct qlcnic_adapter *);
 
 static void qlcnic_dev_set_npar_ready(struct qlcnic_adapter *);
-static void qlcnicvf_clear_ilb_mode(struct qlcnic_adapter *);
-static int qlcnicvf_set_ilb_mode(struct qlcnic_adapter *);
 static int qlcnicvf_config_led(struct qlcnic_adapter *, u32, u32);
 static int qlcnicvf_config_bridged_mode(struct qlcnic_adapter *, u32);
 static int qlcnicvf_start_firmware(struct qlcnic_adapter *);
@@ -381,8 +379,6 @@ static struct qlcnic_nic_template qlcnic_ops = {
 	.get_mac_addr = qlcnic_get_mac_address,
 	.config_bridged_mode = qlcnic_config_bridged_mode,
 	.config_led = qlcnic_config_led,
-	.set_ilb_mode = qlcnic_set_ilb_mode,
-	.clear_ilb_mode = qlcnic_clear_ilb_mode,
 	.start_firmware = qlcnic_start_firmware
 };
 
@@ -390,8 +386,6 @@ static struct qlcnic_nic_template qlcnic_vf_ops = {
 	.get_mac_addr = qlcnic_get_mac_address,
 	.config_bridged_mode = qlcnicvf_config_bridged_mode,
 	.config_led = qlcnicvf_config_led,
-	.set_ilb_mode = qlcnicvf_set_ilb_mode,
-	.clear_ilb_mode = qlcnicvf_clear_ilb_mode,
 	.start_firmware = qlcnicvf_start_firmware
 };
 
@@ -2841,18 +2835,6 @@ qlcnicvf_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate)
 	return -EOPNOTSUPP;
 }
 
-static int
-qlcnicvf_set_ilb_mode(struct qlcnic_adapter *adapter)
-{
-	return -EOPNOTSUPP;
-}
-
-static void
-qlcnicvf_clear_ilb_mode(struct qlcnic_adapter *adapter)
-{
-	return;
-}
-
 static ssize_t
 qlcnic_store_bridged_mode(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t len)
-- 
1.6.0.2

