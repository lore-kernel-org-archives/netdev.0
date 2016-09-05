From: Tomer Tayar <Tomer.Tayar@qlogic.com>
Subject: [PATCH net-next 3/3] qed*: Add support for the ethtool get_regs operation
Date: Mon, 5 Sep 2016 14:35:12 +0300
Message-ID: <1473075312-19075-4-git-send-email-Tomer.Tayar@qlogic.com>
References: <1473075312-19075-1-git-send-email-Tomer.Tayar@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Yuval.Mintz@qlogic.com>, Tomer Tayar <Tomer.Tayar@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:47297 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932274AbcIELgY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2016 07:36:24 -0400
In-Reply-To: <1473075312-19075-1-git-send-email-Tomer.Tayar@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tomer Tayar <Tomer.Tayar@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_main.c      |  2 ++
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 24 ++++++++++++++++++++++++
 include/linux/qed/qed_if.h                      |  4 ++++
 3 files changed, 30 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 78cbf99..1716979 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -1421,6 +1421,8 @@ const struct qed_common_ops qed_common_ops_pass = {
 	.get_link = &qed_get_current_link,
 	.drain = &qed_drain,
 	.update_msglvl = &qed_init_dp,
+	.dbg_all_data = &qed_dbg_all_data,
+	.dbg_all_data_size = &qed_dbg_all_data_size,
 	.chain_alloc = &qed_chain_alloc,
 	.chain_free = &qed_chain_free,
 	.get_coalesce = &qed_get_coalesce,
diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index 6e17ee1..eba0128 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -689,6 +689,28 @@ static int qede_set_pauseparam(struct net_device *dev,
 	return 0;
 }
 
+static void qede_get_regs(struct net_device *ndev,
+			  struct ethtool_regs *regs, void *buffer)
+{
+	struct qede_dev *edev = netdev_priv(ndev);
+
+	regs->version = 0;
+	memset(buffer, 0, regs->len);
+
+	if (edev->ops && edev->ops->common)
+		edev->ops->common->dbg_all_data(edev->cdev, buffer);
+}
+
+static int qede_get_regs_len(struct net_device *ndev)
+{
+	struct qede_dev *edev = netdev_priv(ndev);
+
+	if (edev->ops && edev->ops->common)
+		return edev->ops->common->dbg_all_data_size(edev->cdev);
+	else
+		return -EINVAL;
+}
+
 static void qede_update_mtu(struct qede_dev *edev, union qede_reload_args *args)
 {
 	edev->ndev->mtu = args->mtu;
@@ -1340,6 +1362,8 @@ static const struct ethtool_ops qede_ethtool_ops = {
 	.get_link_ksettings = qede_get_link_ksettings,
 	.set_link_ksettings = qede_set_link_ksettings,
 	.get_drvinfo = qede_get_drvinfo,
+	.get_regs_len = qede_get_regs_len,
+	.get_regs = qede_get_regs,
 	.get_msglevel = qede_get_msglevel,
 	.set_msglevel = qede_set_msglevel,
 	.nway_reset = qede_nway_reset,
diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index 864265f..5a39a2c 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -449,6 +449,10 @@ struct qed_common_ops {
 	void		(*simd_handler_clean)(struct qed_dev *cdev,
 					      int index);
 
+	int (*dbg_all_data) (struct qed_dev *cdev, void *buffer);
+
+	int (*dbg_all_data_size) (struct qed_dev *cdev);
+
 /**
  * @brief can_link_change - can the instance change the link or not
  *
-- 
1.8.3.1
