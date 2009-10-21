From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 1/4] qlge: Add ethtool get/set pause parameter.
Date: Wed, 21 Oct 2009 14:07:38 -0700
Message-ID: <1256159261-29151-1-git-send-email-ron.mercer@qlogic.com>
References: <[net-next PATCH 0/4] qlge: Add some ethtool functions.>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:55641 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753970AbZJUVNh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 17:13:37 -0400
In-Reply-To: <[net-next PATCH 0/4] qlge: Add some ethtool functions.>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h         |    2 ++
 drivers/net/qlge/qlge_ethtool.c |   33 +++++++++++++++++++++++++++++++++
 drivers/net/qlge/qlge_mpi.c     |    4 ++--
 3 files changed, 37 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 9cdf8ff..b1b3375 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -1646,6 +1646,8 @@ int ql_mb_about_fw(struct ql_adapter *qdev);
 void ql_link_on(struct ql_adapter *qdev);
 void ql_link_off(struct ql_adapter *qdev);
 int ql_mb_set_mgmnt_traffic_ctl(struct ql_adapter *qdev, u32 control);
+int ql_mb_get_port_cfg(struct ql_adapter *qdev);
+int ql_mb_set_port_cfg(struct ql_adapter *qdev);
 int ql_wait_fifo_empty(struct ql_adapter *qdev);
 
 #if 1
diff --git a/drivers/net/qlge/qlge_ethtool.c b/drivers/net/qlge/qlge_ethtool.c
index aac6c6f..dfb5c80 100644
--- a/drivers/net/qlge/qlge_ethtool.c
+++ b/drivers/net/qlge/qlge_ethtool.c
@@ -424,6 +424,37 @@ static int ql_set_coalesce(struct net_device *ndev, struct ethtool_coalesce *c)
 	return ql_update_ring_coalescing(qdev);
 }
 
+static void ql_get_pauseparam(struct net_device *netdev,
+			struct ethtool_pauseparam *pause)
+{
+	struct ql_adapter *qdev = netdev_priv(netdev);
+
+	ql_mb_get_port_cfg(qdev);
+	if (qdev->link_config & CFG_PAUSE_STD) {
+		pause->rx_pause = 1;
+		pause->tx_pause = 1;
+	}
+}
+
+static int ql_set_pauseparam(struct net_device *netdev,
+			struct ethtool_pauseparam *pause)
+{
+	struct ql_adapter *qdev = netdev_priv(netdev);
+	int status = 0;
+
+	if ((pause->rx_pause) && (pause->tx_pause))
+		qdev->link_config |= CFG_PAUSE_STD;
+	else if (!pause->rx_pause && !pause->tx_pause)
+		qdev->link_config &= ~CFG_PAUSE_STD;
+	else
+		return -EINVAL;
+
+	status = ql_mb_set_port_cfg(qdev);
+	if (status)
+		return status;
+	return status;
+}
+
 static u32 ql_get_rx_csum(struct net_device *netdev)
 {
 	struct ql_adapter *qdev = netdev_priv(netdev);
@@ -468,6 +499,8 @@ const struct ethtool_ops qlge_ethtool_ops = {
 	.get_msglevel = ql_get_msglevel,
 	.set_msglevel = ql_set_msglevel,
 	.get_link = ethtool_op_get_link,
+	.get_pauseparam		 = ql_get_pauseparam,
+	.set_pauseparam		 = ql_set_pauseparam,
 	.get_rx_csum = ql_get_rx_csum,
 	.set_rx_csum = ql_set_rx_csum,
 	.get_tx_csum = ethtool_op_get_tx_csum,
diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index e497eac..81a8489 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -637,7 +637,7 @@ int ql_mb_idc_ack(struct ql_adapter *qdev)
  * for the current port.
  * Most likely will block.
  */
-static int ql_mb_set_port_cfg(struct ql_adapter *qdev)
+int ql_mb_set_port_cfg(struct ql_adapter *qdev)
 {
 	struct mbox_params mbc;
 	struct mbox_params *mbcp = &mbc;
@@ -672,7 +672,7 @@ static int ql_mb_set_port_cfg(struct ql_adapter *qdev)
  * for the current port.
  * Most likely will block.
  */
-static int ql_mb_get_port_cfg(struct ql_adapter *qdev)
+int ql_mb_get_port_cfg(struct ql_adapter *qdev)
 {
 	struct mbox_params mbc;
 	struct mbox_params *mbcp = &mbc;
-- 
1.6.0.2

