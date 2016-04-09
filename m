From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 3/6] qed/qede: Add VXLAN tunnel slowpath configuration support
Date: Sat, 9 Apr 2016 09:17:02 -0400
Message-ID: <1460207825-3622-4-git-send-email-manish.chopra@qlogic.com>
References: <1460207825-3622-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:59575 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753098AbcDIN6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 09:58:34 -0400
In-Reply-To: <1460207825-3622-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables VXLAN tunnel on the adapter and
add support for driver hooks to configure UDP ports
for VXLAN tunnel offload to be performed by the adapter.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/qlogic/Kconfig               | 11 +++
 drivers/net/ethernet/qlogic/qed/qed_main.c        |  8 ++-
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c |  3 +-
 drivers/net/ethernet/qlogic/qede/qede.h           |  5 +-
 drivers/net/ethernet/qlogic/qede/qede_main.c      | 87 +++++++++++++++++++++++
 5 files changed, 111 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/Kconfig b/drivers/net/ethernet/qlogic/Kconfig
index ddcfcab..7a65522 100644
--- a/drivers/net/ethernet/qlogic/Kconfig
+++ b/drivers/net/ethernet/qlogic/Kconfig
@@ -103,4 +103,15 @@ config QEDE
 	depends on QED
 	---help---
 	  This enables the support for ...
+
+config QEDE_VXLAN
+	bool "Virtual eXtensible Local Area Network support"
+	default n
+	depends on QEDE && VXLAN && !(QEDE=y && VXLAN=m)
+	---help---
+	  This enables hardware offload support for VXLAN protocol over
+	  qede module. Say Y here if you want to enable hardware offload
+	  support for Virtual eXtensible Local Area Network (VXLAN)
+	  in the driver.
+
 endif # NET_VENDOR_QLOGIC
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 01c0207..3b406ac 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -744,6 +744,7 @@ static void qed_update_pf_params(struct qed_dev *cdev,
 static int qed_slowpath_start(struct qed_dev *cdev,
 			      struct qed_slowpath_params *params)
 {
+	struct qed_tunn_start_params tunn_info;
 	struct qed_mcp_drv_version drv_version;
 	const u8 *data = NULL;
 	struct qed_hwfn *hwfn;
@@ -776,7 +777,12 @@ static int qed_slowpath_start(struct qed_dev *cdev,
 	/* Start the slowpath */
 	data = cdev->firmware->data;
 
-	rc = qed_hw_init(cdev, NULL, true, cdev->int_params.out.int_mode,
+	memset(&tunn_info, 0, sizeof(tunn_info));
+	tunn_info.tunn_mode |=  1 << QED_MODE_VXLAN_TUNN;
+	tunn_info.tunn_clss_vxlan = QED_TUNN_CLSS_MAC_VLAN;
+
+	rc = qed_hw_init(cdev, &tunn_info, true,
+			 cdev->int_params.out.int_mode,
 			 true, data);
 	if (rc)
 		goto err2;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
index 306da70..7ccd96e 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
@@ -353,7 +353,8 @@ int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
 	DMA_REGPAIR_LE(p_ramrod->consolid_q_pbl_addr,
 		       p_hwfn->p_consq->chain.pbl.p_phys_table);
 
-	qed_tunn_set_pf_start_params(p_hwfn, NULL, NULL);
+	qed_tunn_set_pf_start_params(p_hwfn, p_tunn,
+				     &p_ramrod->tunnel_config);
 	p_hwfn->hw_info.personality = PERSONALITY_ETH;
 
 	DP_VERBOSE(p_hwfn, QED_MSG_SPQ,
diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index d023251..0b66d4a 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -167,6 +167,7 @@ struct qede_dev {
 	bool accept_any_vlan;
 	struct delayed_work		sp_task;
 	unsigned long			sp_flags;
+	u16				vxlan_dst_port;
 };
 
 enum QEDE_STATE {
@@ -287,7 +288,9 @@ struct qede_fastpath {
 #define QEDE_CSUM_ERROR			BIT(0)
 #define QEDE_CSUM_UNNECESSARY		BIT(1)
 
-#define QEDE_SP_RX_MODE		1
+#define QEDE_SP_RX_MODE			1
+#define QEDE_SP_VXLAN_PORT_ADD		2
+#define QEDE_SP_VXLAN_PORT_DELETE	3
 
 union qede_reload_args {
 	u16 mtu;
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 518af32..9a82d42 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -1830,6 +1830,63 @@ static void qede_vlan_mark_nonconfigured(struct qede_dev *edev)
 	edev->accept_any_vlan = false;
 }
 
+#ifdef CONFIG_QEDE_VXLAN
+static void qede_add_vxlan_port(struct net_device *dev,
+				sa_family_t sa_family, __be16 port)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+	u16 t_port = ntohs(port);
+
+	if (edev->vxlan_dst_port)
+		return;
+
+	edev->vxlan_dst_port = t_port;
+
+	DP_VERBOSE(edev, QED_MSG_DEBUG, "Added vxlan port=%d", t_port);
+
+	set_bit(QEDE_SP_VXLAN_PORT_ADD, &edev->sp_flags);
+	schedule_delayed_work(&edev->sp_task, 0);
+}
+
+static void qede_del_vxlan_port(struct net_device *dev,
+				sa_family_t sa_family, __be16 port)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+	u16 t_port = ntohs(port);
+
+	if (t_port != edev->vxlan_dst_port)
+		return;
+
+	edev->vxlan_dst_port = 0;
+
+	DP_VERBOSE(edev, QED_MSG_DEBUG, "Deleted vxlan port=%d", t_port);
+
+	set_bit(QEDE_SP_VXLAN_PORT_DELETE, &edev->sp_flags);
+	schedule_delayed_work(&edev->sp_task, 0);
+}
+
+static void qede_config_def_udp_tunnel_ports(struct qede_dev *edev)
+{
+	struct qed_tunn_params tunn_params;
+
+	memset(&tunn_params, 0, sizeof(tunn_params));
+
+	if (!edev->vxlan_dst_port) {
+		tunn_params.update_vxlan_port = 1;
+		tunn_params.vxlan_port = VXLAN_DEF_UDP_PORT;
+	}
+
+	qed_ops->tunn_config(edev->cdev, &tunn_params);
+}
+#endif
+
+static netdev_features_t qede_features_check(struct sk_buff *skb,
+					     struct net_device *dev,
+					     netdev_features_t features)
+{
+	return vxlan_features_check(skb, features);
+}
+
 static const struct net_device_ops qede_netdev_ops = {
 	.ndo_open = qede_open,
 	.ndo_stop = qede_close,
@@ -1841,6 +1898,11 @@ static const struct net_device_ops qede_netdev_ops = {
 	.ndo_vlan_rx_add_vid = qede_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid = qede_vlan_rx_kill_vid,
 	.ndo_get_stats64 = qede_get_stats64,
+#ifdef CONFIG_QEDE_VXLAN
+	.ndo_add_vxlan_port = qede_add_vxlan_port,
+	.ndo_del_vxlan_port = qede_del_vxlan_port,
+#endif
+	.ndo_features_check = qede_features_check,
 };
 
 /* -------------------------------------------------------------------------
@@ -2013,6 +2075,8 @@ static void qede_sp_task(struct work_struct *work)
 {
 	struct qede_dev *edev = container_of(work, struct qede_dev,
 					     sp_task.work);
+	struct qed_dev *cdev = edev->cdev;
+
 	mutex_lock(&edev->qede_lock);
 
 	if (edev->state == QEDE_STATE_OPEN) {
@@ -2020,6 +2084,26 @@ static void qede_sp_task(struct work_struct *work)
 			qede_config_rx_mode(edev->ndev);
 	}
 
+	if (test_and_clear_bit(QEDE_SP_VXLAN_PORT_ADD, &edev->sp_flags)) {
+		struct qed_tunn_params tunn_params;
+
+		memset(&tunn_params, 0, sizeof(tunn_params));
+		tunn_params.update_vxlan_port = 1;
+		tunn_params.vxlan_port = edev->vxlan_dst_port;
+		qed_ops->tunn_config(cdev, &tunn_params);
+	}
+
+	if (test_and_clear_bit(QEDE_SP_VXLAN_PORT_DELETE, &edev->sp_flags)) {
+		struct qed_tunn_params tunn_params;
+
+		memset(&tunn_params, 0, sizeof(tunn_params));
+		tunn_params.update_vxlan_port = 1;
+
+		/* Update with default vxlan udp port */
+		tunn_params.vxlan_port = VXLAN_DEF_UDP_PORT;
+		qed_ops->tunn_config(cdev, &tunn_params);
+	}
+
 	mutex_unlock(&edev->qede_lock);
 }
 
@@ -3083,6 +3167,9 @@ static int qede_load(struct qede_dev *edev, enum qede_load_mode mode)
 	edev->ops->common->get_link(edev->cdev, &link_output);
 	qede_link_update(edev, &link_output);
 
+#ifdef CONFIG_QEDE_VXLAN
+	qede_config_def_udp_tunnel_ports(edev);
+#endif
 	DP_INFO(edev, "Ending successfully qede load\n");
 
 	return 0;
-- 
2.7.2
