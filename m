From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH v2 net-next 3/5] qed/qede: Add GENEVE tunnel slowpath configuration support
Date: Thu, 14 Apr 2016 01:38:31 -0400
Message-ID: <1460612313-20323-4-git-send-email-manish.chopra@qlogic.com>
References: <1460612313-20323-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:39298 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751737AbcDNGUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 02:20:11 -0400
In-Reply-To: <1460612313-20323-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables GENEVE tunnel on the adapter and
add support for driver hooks to configure UDP ports
for GENEVE tunnel offload to be performed by the adapter.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/qlogic/Kconfig          | 10 ++++++
 drivers/net/ethernet/qlogic/qed/qed_main.c   |  5 ++-
 drivers/net/ethernet/qlogic/qede/qede.h      |  2 ++
 drivers/net/ethernet/qlogic/qede/qede_main.c | 53 ++++++++++++++++++++++++++++
 4 files changed, 69 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/Kconfig b/drivers/net/ethernet/qlogic/Kconfig
index 7a65522..c0a11b5 100644
--- a/drivers/net/ethernet/qlogic/Kconfig
+++ b/drivers/net/ethernet/qlogic/Kconfig
@@ -114,4 +114,14 @@ config QEDE_VXLAN
 	  support for Virtual eXtensible Local Area Network (VXLAN)
 	  in the driver.
 
+config QEDE_GENEVE
+	bool "Generic Network Virtualization Encapsulation (GENEVE) support"
+	depends on QEDE && GENEVE && !(QEDE=y && GENEVE=m)
+	---help---
+	  This allows one to create GENEVE virtual interfaces that provide
+	  Layer 2 Networks over Layer 3 Networks. GENEVE is often used
+	  to tunnel virtual network infrastructure in virtualized environments.
+	  Say Y here if you want to enable hardware offload support for
+	  Generic Network Virtualization Encapsulation (GENEVE) in the driver.
+
 endif # NET_VENDOR_QLOGIC
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 0bb2c57..c1533a6 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -778,7 +778,10 @@ static int qed_slowpath_start(struct qed_dev *cdev,
 	data = cdev->firmware->data;
 
 	memset(&tunn_info, 0, sizeof(tunn_info));
-	tunn_info.tunn_mode |=  1 << QED_MODE_VXLAN_TUNN;
+	tunn_info.tunn_mode |=  1 << QED_MODE_VXLAN_TUNN |
+				1 << QED_MODE_L2GENEVE_TUNN |
+				1 << QED_MODE_IPGENEVE_TUNN;
+
 	tunn_info.tunn_clss_vxlan = QED_TUNN_CLSS_MAC_VLAN;
 
 	rc = qed_hw_init(cdev, &tunn_info, true,
diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index 16a4344..8521fee 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -170,6 +170,7 @@ struct qede_dev {
 	struct delayed_work		sp_task;
 	unsigned long			sp_flags;
 	u16				vxlan_dst_port;
+	u16				geneve_dst_port;
 };
 
 enum QEDE_STATE {
@@ -292,6 +293,7 @@ struct qede_fastpath {
 
 #define QEDE_SP_RX_MODE			1
 #define QEDE_SP_VXLAN_PORT_CONFIG	2
+#define QEDE_SP_GENEVE_PORT_CONFIG	3
 
 union qede_reload_args {
 	u16 mtu;
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 895016d..6c40316 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -27,6 +27,9 @@
 #ifdef CONFIG_QEDE_VXLAN
 #include <net/vxlan.h>
 #endif
+#ifdef CONFIG_QEDE_GENEVE
+#include <net/geneve.h>
+#endif
 #include <linux/ip.h>
 #include <net/ipv6.h>
 #include <net/tcp.h>
@@ -1859,6 +1862,40 @@ static void qede_del_vxlan_port(struct net_device *dev,
 }
 #endif
 
+#ifdef CONFIG_QEDE_GENEVE
+static void qede_add_geneve_port(struct net_device *dev,
+				 sa_family_t sa_family, __be16 port)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+	u16 t_port = ntohs(port);
+
+	if (edev->geneve_dst_port)
+		return;
+
+	edev->geneve_dst_port = t_port;
+
+	DP_VERBOSE(edev, QED_MSG_DEBUG, "Added geneve port=%d", t_port);
+	set_bit(QEDE_SP_GENEVE_PORT_CONFIG, &edev->sp_flags);
+	schedule_delayed_work(&edev->sp_task, 0);
+}
+
+static void qede_del_geneve_port(struct net_device *dev,
+				 sa_family_t sa_family, __be16 port)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+	u16 t_port = ntohs(port);
+
+	if (t_port != edev->geneve_dst_port)
+		return;
+
+	edev->geneve_dst_port = 0;
+
+	DP_VERBOSE(edev, QED_MSG_DEBUG, "Deleted geneve port=%d", t_port);
+	set_bit(QEDE_SP_GENEVE_PORT_CONFIG, &edev->sp_flags);
+	schedule_delayed_work(&edev->sp_task, 0);
+}
+#endif
+
 static const struct net_device_ops qede_netdev_ops = {
 	.ndo_open = qede_open,
 	.ndo_stop = qede_close,
@@ -1874,6 +1911,10 @@ static const struct net_device_ops qede_netdev_ops = {
 	.ndo_add_vxlan_port = qede_add_vxlan_port,
 	.ndo_del_vxlan_port = qede_del_vxlan_port,
 #endif
+#ifdef CONFIG_QEDE_GENEVE
+	.ndo_add_geneve_port = qede_add_geneve_port,
+	.ndo_del_geneve_port = qede_del_geneve_port,
+#endif
 };
 
 /* -------------------------------------------------------------------------
@@ -2064,6 +2105,15 @@ static void qede_sp_task(struct work_struct *work)
 		qed_ops->tunn_config(cdev, &tunn_params);
 	}
 
+	if (test_and_clear_bit(QEDE_SP_GENEVE_PORT_CONFIG, &edev->sp_flags)) {
+		struct qed_tunn_params tunn_params;
+
+		memset(&tunn_params, 0, sizeof(tunn_params));
+		tunn_params.update_geneve_port = 1;
+		tunn_params.geneve_port = edev->geneve_dst_port;
+		qed_ops->tunn_config(cdev, &tunn_params);
+	}
+
 	mutex_unlock(&edev->qede_lock);
 }
 
@@ -3216,6 +3266,9 @@ static int qede_open(struct net_device *ndev)
 #ifdef CONFIG_QEDE_VXLAN
 	vxlan_get_rx_port(ndev);
 #endif
+#ifdef CONFIG_QEDE_GENEVE
+	geneve_get_rx_port(ndev);
+#endif
 	return 0;
 }
 
-- 
2.7.2
