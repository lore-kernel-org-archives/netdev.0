From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH net-next-2.6 1/2] qlcnic: Check FW capability for TSO
Date: Fri, 9 Jul 2010 16:14:58 -0700
Message-ID: <alpine.OSX.2.00.1007091544370.44317@macintosh-2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:24519 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754927Ab0GIXPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 19:15:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Driver checks TSO capability from FW before enabling it.

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h         |    7 ++++---
 drivers/net/qlcnic/qlcnic_ethtool.c |    3 +++
 drivers/net/qlcnic/qlcnic_main.c    |   10 +++++++---
 3 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 60ea7cb..02a50e6 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -821,9 +821,10 @@ struct qlcnic_nic_intr_coalesce {
 #define QLCNIC_LRO_REQUEST_CLEANUP	4
 
 /* Capabilites received */
-#define QLCNIC_FW_CAPABILITY_BDG		(1 << 8)
-#define QLCNIC_FW_CAPABILITY_FVLANTX		(1 << 9)
-#define QLCNIC_FW_CAPABILITY_HW_LRO		(1 << 10)
+#define QLCNIC_FW_CAPABILITY_TSO		BIT_1
+#define QLCNIC_FW_CAPABILITY_BDG		BIT_8
+#define QLCNIC_FW_CAPABILITY_FVLANTX		BIT_9
+#define QLCNIC_FW_CAPABILITY_HW_LRO		BIT_10
 
 /* module types */
 #define LINKEVENT_MODULE_NOT_PRESENT			1
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index f8e39e4..baf5a52 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -820,6 +820,9 @@ static u32 qlcnic_get_tso(struct net_device *dev)
 
 static int qlcnic_set_tso(struct net_device *dev, u32 data)
 {
+	struct qlcnic_adapter *adapter = netdev_priv(dev);
+	if (!(adapter->capabilities & QLCNIC_FW_CAPABILITY_TSO))
+		return -EOPNOTSUPP;
 	if (data)
 		dev->features |= (NETIF_F_TSO | NETIF_F_TSO6);
 	else
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 18e2b2e..c334f1a 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -1226,10 +1226,14 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter,
 	SET_ETHTOOL_OPS(netdev, &qlcnic_ethtool_ops);
 
 	netdev->features |= (NETIF_F_SG | NETIF_F_IP_CSUM |
-		NETIF_F_IPV6_CSUM | NETIF_F_GRO | NETIF_F_TSO | NETIF_F_TSO6);
-
+		NETIF_F_IPV6_CSUM | NETIF_F_GRO);
 	netdev->vlan_features |= (NETIF_F_SG | NETIF_F_IP_CSUM |
-		NETIF_F_IPV6_CSUM | NETIF_F_TSO | NETIF_F_TSO6);
+		NETIF_F_IPV6_CSUM);
+
+	if (adapter->capabilities & QLCNIC_FW_CAPABILITY_TSO) {
+		netdev->features |= (NETIF_F_TSO | NETIF_F_TSO6);
+		netdev->vlan_features |= (NETIF_F_TSO | NETIF_F_TSO6);
+	}
 
 	if (pci_using_dac) {
 		netdev->features |= NETIF_F_HIGHDMA;
-- 
1.7.1

