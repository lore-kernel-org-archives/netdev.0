From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 4/6] qed/qede: Add GENEVE tunnel slowpath configuration support
Date: Sat, 9 Apr 2016 09:17:03 -0400
Message-ID: <1460207825-3622-5-git-send-email-manish.chopra@qlogic.com>
References: <1460207825-3622-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:10935 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753112AbcDIN6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 09:58:34 -0400
In-Reply-To: <1460207825-3622-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch configures adapter for GENEVE tunnel offloads
to be performed by the adapter.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/qlogic/Kconfig          | 10 ++++++++++
 drivers/net/ethernet/qlogic/qed/qed_main.c   |  5 ++++-
 drivers/net/ethernet/qlogic/qede/qede_main.c | 12 +++++++++++-
 3 files changed, 25 insertions(+), 2 deletions(-)

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
index 3b406ac..406de14 100644
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
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 9a82d42..b2cde75 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -36,6 +36,7 @@
 #include <linux/random.h>
 #include <net/ip6_checksum.h>
 #include <linux/bitops.h>
+#include <net/geneve.h>
 
 #include "qede.h"
 
@@ -1864,17 +1865,26 @@ static void qede_del_vxlan_port(struct net_device *dev,
 	set_bit(QEDE_SP_VXLAN_PORT_DELETE, &edev->sp_flags);
 	schedule_delayed_work(&edev->sp_task, 0);
 }
+#endif
 
+#if defined(CONFIG_QEDE_VXLAN) || defined(CONFIG_QEDE_GENEVE)
 static void qede_config_def_udp_tunnel_ports(struct qede_dev *edev)
 {
 	struct qed_tunn_params tunn_params;
 
 	memset(&tunn_params, 0, sizeof(tunn_params));
 
+#ifdef CONFIG_QEDE_VXLAN
 	if (!edev->vxlan_dst_port) {
 		tunn_params.update_vxlan_port = 1;
 		tunn_params.vxlan_port = VXLAN_DEF_UDP_PORT;
 	}
+#endif
+
+#ifdef CONFIG_QEDE_GENEVE
+	tunn_params.update_geneve_port = 1;
+	tunn_params.geneve_port = GENEVE_DEF_UDP_PORT;
+#endif
 
 	qed_ops->tunn_config(edev->cdev, &tunn_params);
 }
@@ -3167,7 +3177,7 @@ static int qede_load(struct qede_dev *edev, enum qede_load_mode mode)
 	edev->ops->common->get_link(edev->cdev, &link_output);
 	qede_link_update(edev, &link_output);
 
-#ifdef CONFIG_QEDE_VXLAN
+#if defined(CONFIG_QEDE_VXLAN) || defined(CONFIG_QEDE_GENEVE)
 	qede_config_def_udp_tunnel_ports(edev);
 #endif
 	DP_INFO(edev, "Ending successfully qede load\n");
-- 
2.7.2
