From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 3/5] qed*: Conditions for changing link
Date: Sun, 17 Apr 2016 22:26:33 +0300
Message-ID: <1460921195-23352-4-git-send-email-Yuval.Mintz@qlogic.com>
References: <1460921195-23352-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:64927 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751138AbcDQT0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2016 15:26:51 -0400
In-Reply-To: <1460921195-23352-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's some inconsistency in current logic determining whether the
link settings of a given interface can be changed; I.e., in all modes
other than the so-called `deault' mode the interfaces are forbidden from
changing the configuration - but even this rule is not applied to all
user APIs that may change the configuration.

Instead, let the core-module [qed] decide whether an interface can change
the configuration by supporting a new API function. We also revise the
current rule, allowing all interfaces to change their configurations while
laying the infrastructure for future modes where an interface would be
blocked from making such a configuration.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_main.c      |  6 ++++++
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 14 ++++++++++----
 include/linux/qed/qed_if.h                      | 10 ++++++++++
 3 files changed, 26 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 1e9f321..d189871 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -915,6 +915,11 @@ static u32 qed_sb_release(struct qed_dev *cdev,
 	return rc;
 }
 
+static bool qed_can_link_change(struct qed_dev *cdev)
+{
+	return true;
+}
+
 static int qed_set_link(struct qed_dev *cdev,
 			struct qed_link_params *params)
 {
@@ -1177,6 +1182,7 @@ const struct qed_common_ops qed_common_ops_pass = {
 	.sb_release = &qed_sb_release,
 	.simd_handler_config = &qed_simd_handler_config,
 	.simd_handler_clean = &qed_simd_handler_clean,
+	.can_link_change = &qed_can_link_change,
 	.set_link = &qed_set_link,
 	.get_link = &qed_get_current_link,
 	.drain = &qed_drain,
diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index 5ba6b2a..0f11685 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -243,9 +243,9 @@ static int qede_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	struct qed_link_params params;
 	u32 speed;
 
-	if (!edev->dev_info.common.is_mf_default) {
+	if (!edev->ops || !edev->ops->common->can_link_change(edev->cdev)) {
 		DP_INFO(edev,
-			"Link parameters can not be changed in non-default mode\n");
+			"Link settings are not allowed to be changed\n");
 		return -EOPNOTSUPP;
 	}
 
@@ -354,6 +354,12 @@ static int qede_nway_reset(struct net_device *dev)
 	struct qed_link_output current_link;
 	struct qed_link_params link_params;
 
+	if (!edev->ops || !edev->ops->common->can_link_change(edev->cdev)) {
+		DP_INFO(edev,
+			"Link settings are not allowed to be changed\n");
+		return -EOPNOTSUPP;
+	}
+
 	if (!netif_running(dev))
 		return 0;
 
@@ -454,9 +460,9 @@ static int qede_set_pauseparam(struct net_device *dev,
 	struct qed_link_params params;
 	struct qed_link_output current_link;
 
-	if (!edev->dev_info.common.is_mf_default) {
+	if (!edev->ops || !edev->ops->common->can_link_change(edev->cdev)) {
 		DP_INFO(edev,
-			"Pause parameters can not be updated in non-default mode\n");
+			"Pause settings are not allowed to be changed\n");
 		return -EOPNOTSUPP;
 	}
 
diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index 82a7fe0..e5de42b 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -211,6 +211,16 @@ struct qed_common_ops {
 
 	void		(*simd_handler_clean)(struct qed_dev *cdev,
 					      int index);
+
+/**
+ * @brief can_link_change - can the instance change the link or not
+ *
+ * @param cdev
+ *
+ * @return true if link-change is allowed, false otherwise.
+ */
+	bool (*can_link_change)(struct qed_dev *cdev);
+
 /**
  * @brief set_link - set links according to params
  *
-- 
1.9.3
