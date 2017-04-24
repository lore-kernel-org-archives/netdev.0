From: Manish Chopra <manish.chopra@cavium.com>
Subject: [PATCH net-next 4/6] qede: Configure UDP ports in local context.
Date: Mon, 24 Apr 2017 10:00:47 -0700
Message-ID: <20170424170049.16027-5-manish.chopra@cavium.com>
References: <20170424170049.16027-1-manish.chopra@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0084.outbound.protection.outlook.com ([104.47.40.84]:28592
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S975264AbdDXRBx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Apr 2017 13:01:53 -0400
In-Reply-To: <20170424170049.16027-1-manish.chopra@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch configures UDP ports locally instead of
configuring them in deferred context which would be
helpful in synchronizing UDP ports configuration for VFs
which will be enabled in further patches.

Signed-off-by: Manish Chopra <manish.chopra@cavium.com>
Signed-off-by: Yuval Mintz <yuval.mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede.h        |  2 -
 drivers/net/ethernet/qlogic/qede/qede_filter.c | 67 ++++++++++++++++++++------
 drivers/net/ethernet/qlogic/qede/qede_main.c   | 19 --------
 3 files changed, 52 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index 7e18ae6..26699a7 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -442,8 +442,6 @@ struct qede_fastpath {
 #define QEDE_TUNN_CSUM_UNNECESSARY	BIT(2)
 
 #define QEDE_SP_RX_MODE			1
-#define QEDE_SP_VXLAN_PORT_CONFIG	2
-#define QEDE_SP_GENEVE_PORT_CONFIG	3
 
 #ifdef CONFIG_RFS_ACCEL
 int qede_rx_flow_steer(struct net_device *dev, const struct sk_buff *skb,
diff --git a/drivers/net/ethernet/qlogic/qede/qede_filter.c b/drivers/net/ethernet/qlogic/qede/qede_filter.c
index 23e0c16..4fa2c88 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_filter.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_filter.c
@@ -883,7 +883,11 @@ int qede_set_features(struct net_device *dev, netdev_features_t features)
 void qede_udp_tunnel_add(struct net_device *dev, struct udp_tunnel_info *ti)
 {
 	struct qede_dev *edev = netdev_priv(dev);
+	struct qed_tunn_params tunn_params;
 	u16 t_port = ntohs(ti->port);
+	int rc;
+
+	memset(&tunn_params, 0, sizeof(tunn_params));
 
 	switch (ti->type) {
 	case UDP_TUNNEL_TYPE_VXLAN:
@@ -893,12 +897,22 @@ void qede_udp_tunnel_add(struct net_device *dev, struct udp_tunnel_info *ti)
 		if (edev->vxlan_dst_port)
 			return;
 
-		edev->vxlan_dst_port = t_port;
+		tunn_params.update_vxlan_port = 1;
+		tunn_params.vxlan_port = t_port;
 
-		DP_VERBOSE(edev, QED_MSG_DEBUG, "Added vxlan port=%d\n",
-			   t_port);
+		__qede_lock(edev);
+		rc = edev->ops->tunn_config(edev->cdev, &tunn_params);
+		__qede_unlock(edev);
+
+		if (!rc) {
+			edev->vxlan_dst_port = t_port;
+			DP_VERBOSE(edev, QED_MSG_DEBUG, "Added vxlan port=%d\n",
+				   t_port);
+		} else {
+			DP_NOTICE(edev, "Failed to add vxlan UDP port=%d\n",
+				  t_port);
+		}
 
-		set_bit(QEDE_SP_VXLAN_PORT_CONFIG, &edev->sp_flags);
 		break;
 	case UDP_TUNNEL_TYPE_GENEVE:
 		if (!edev->dev_info.common.geneve_enable)
@@ -907,51 +921,74 @@ void qede_udp_tunnel_add(struct net_device *dev, struct udp_tunnel_info *ti)
 		if (edev->geneve_dst_port)
 			return;
 
-		edev->geneve_dst_port = t_port;
+		tunn_params.update_geneve_port = 1;
+		tunn_params.geneve_port = t_port;
+
+		__qede_lock(edev);
+		rc = edev->ops->tunn_config(edev->cdev, &tunn_params);
+		__qede_unlock(edev);
+
+		if (!rc) {
+			edev->geneve_dst_port = t_port;
+			DP_VERBOSE(edev, QED_MSG_DEBUG,
+				   "Added geneve port=%d\n", t_port);
+		} else {
+			DP_NOTICE(edev, "Failed to add geneve UDP port=%d\n",
+				  t_port);
+		}
 
-		DP_VERBOSE(edev, QED_MSG_DEBUG, "Added geneve port=%d\n",
-			   t_port);
-		set_bit(QEDE_SP_GENEVE_PORT_CONFIG, &edev->sp_flags);
 		break;
 	default:
 		return;
 	}
-
-	schedule_delayed_work(&edev->sp_task, 0);
 }
 
-void qede_udp_tunnel_del(struct net_device *dev, struct udp_tunnel_info *ti)
+void qede_udp_tunnel_del(struct net_device *dev,
+			 struct udp_tunnel_info *ti)
 {
 	struct qede_dev *edev = netdev_priv(dev);
+	struct qed_tunn_params tunn_params;
 	u16 t_port = ntohs(ti->port);
 
+	memset(&tunn_params, 0, sizeof(tunn_params));
+
 	switch (ti->type) {
 	case UDP_TUNNEL_TYPE_VXLAN:
 		if (t_port != edev->vxlan_dst_port)
 			return;
 
+		tunn_params.update_vxlan_port = 1;
+		tunn_params.vxlan_port = 0;
+
+		__qede_lock(edev);
+		edev->ops->tunn_config(edev->cdev, &tunn_params);
+		__qede_unlock(edev);
+
 		edev->vxlan_dst_port = 0;
 
 		DP_VERBOSE(edev, QED_MSG_DEBUG, "Deleted vxlan port=%d\n",
 			   t_port);
 
-		set_bit(QEDE_SP_VXLAN_PORT_CONFIG, &edev->sp_flags);
 		break;
 	case UDP_TUNNEL_TYPE_GENEVE:
 		if (t_port != edev->geneve_dst_port)
 			return;
 
+		tunn_params.update_geneve_port = 1;
+		tunn_params.geneve_port = 0;
+
+		__qede_lock(edev);
+		edev->ops->tunn_config(edev->cdev, &tunn_params);
+		__qede_unlock(edev);
+
 		edev->geneve_dst_port = 0;
 
 		DP_VERBOSE(edev, QED_MSG_DEBUG, "Deleted geneve port=%d\n",
 			   t_port);
-		set_bit(QEDE_SP_GENEVE_PORT_CONFIG, &edev->sp_flags);
 		break;
 	default:
 		return;
 	}
-
-	schedule_delayed_work(&edev->sp_task, 0);
 }
 
 static void qede_xdp_reload_func(struct qede_dev *edev,
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 42f043b..f57c823 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -796,7 +796,6 @@ static void qede_sp_task(struct work_struct *work)
 {
 	struct qede_dev *edev = container_of(work, struct qede_dev,
 					     sp_task.work);
-	struct qed_dev *cdev = edev->cdev;
 
 	__qede_lock(edev);
 
@@ -804,24 +803,6 @@ static void qede_sp_task(struct work_struct *work)
 		if (edev->state == QEDE_STATE_OPEN)
 			qede_config_rx_mode(edev->ndev);
 
-	if (test_and_clear_bit(QEDE_SP_VXLAN_PORT_CONFIG, &edev->sp_flags)) {
-		struct qed_tunn_params tunn_params;
-
-		memset(&tunn_params, 0, sizeof(tunn_params));
-		tunn_params.update_vxlan_port = 1;
-		tunn_params.vxlan_port = edev->vxlan_dst_port;
-		qed_ops->tunn_config(cdev, &tunn_params);
-	}
-
-	if (test_and_clear_bit(QEDE_SP_GENEVE_PORT_CONFIG, &edev->sp_flags)) {
-		struct qed_tunn_params tunn_params;
-
-		memset(&tunn_params, 0, sizeof(tunn_params));
-		tunn_params.update_geneve_port = 1;
-		tunn_params.geneve_port = edev->geneve_dst_port;
-		qed_ops->tunn_config(cdev, &tunn_params);
-	}
-
 #ifdef CONFIG_RFS_ACCEL
 	if (test_and_clear_bit(QEDE_SP_ARFS_CONFIG, &edev->sp_flags)) {
 		if (edev->state == QEDE_STATE_OPEN)
-- 
2.7.2
