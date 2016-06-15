From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v2 14/17] qede: Move all UDP port notifiers to
 single function
Date: Wed, 15 Jun 2016 15:08:45 -0700
Message-ID: <20160615220845.15575.3738.stgit@localhost.localdomain>
References: <20160615220449.15575.17031.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hannes@redhat.com, jesse@kernel.org, eugenia@mellanox.com,
	jbenc@redhat.com, alexander.duyck@gmail.com, saeedm@mellanox.com,
	ariel.elior@qlogic.com, tom@herbertland.com,
	michael.chan@broadcom.com, Dept-GELinuxNICDev@qlogic.com,
	davem@davemloft.net
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35404 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933061AbcFOWIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 18:08:47 -0400
Received: by mail-pa0-f47.google.com with SMTP id hl6so11216251pac.2
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 15:08:47 -0700 (PDT)
In-Reply-To: <20160615220449.15575.17031.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch goes through and combines the notifiers for VXLAN and GENEVE
into a single function for each action.  So there is now one combined
function for getting ports, one for adding the ports, and one for deleting
the ports.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/qlogic/Kconfig          |   20 -----
 drivers/net/ethernet/qlogic/qede/qede_main.c |  115 +++++++++++---------------
 2 files changed, 50 insertions(+), 85 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/Kconfig b/drivers/net/ethernet/qlogic/Kconfig
index 680d8c736d2b..613dd2874644 100644
--- a/drivers/net/ethernet/qlogic/Kconfig
+++ b/drivers/net/ethernet/qlogic/Kconfig
@@ -114,24 +114,4 @@ config QEDE
 	---help---
 	  This enables the support for ...
 
-config QEDE_VXLAN
-	bool "Virtual eXtensible Local Area Network support"
-	default n
-	depends on QEDE && VXLAN && !(QEDE=y && VXLAN=m)
-	---help---
-	  This enables hardware offload support for VXLAN protocol over
-	  qede module. Say Y here if you want to enable hardware offload
-	  support for Virtual eXtensible Local Area Network (VXLAN)
-	  in the driver.
-
-config QEDE_GENEVE
-	bool "Generic Network Virtualization Encapsulation (GENEVE) support"
-	depends on QEDE && GENEVE && !(QEDE=y && GENEVE=m)
-	---help---
-	  This allows one to create GENEVE virtual interfaces that provide
-	  Layer 2 Networks over Layer 3 Networks. GENEVE is often used
-	  to tunnel virtual network infrastructure in virtualized environments.
-	  Say Y here if you want to enable hardware offload support for
-	  Generic Network Virtualization Encapsulation (GENEVE) in the driver.
-
 endif # NET_VENDOR_QLOGIC
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 423168ba7c98..2972742c6adb 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -24,12 +24,7 @@
 #include <linux/netdev_features.h>
 #include <linux/udp.h>
 #include <linux/tcp.h>
-#ifdef CONFIG_QEDE_VXLAN
-#include <net/vxlan.h>
-#endif
-#ifdef CONFIG_QEDE_GENEVE
-#include <net/geneve.h>
-#endif
+#include <net/udp_tunnel.h>
 #include <linux/ip.h>
 #include <net/ipv6.h>
 #include <net/tcp.h>
@@ -2112,75 +2107,75 @@ int qede_set_features(struct net_device *dev, netdev_features_t features)
 	return 0;
 }
 
-#ifdef CONFIG_QEDE_VXLAN
-static void qede_add_vxlan_port(struct net_device *dev,
-				sa_family_t sa_family, __be16 port)
+static void qede_udp_tunnel_add(struct net_device *dev,
+				struct udp_tunnel_info *ti)
 {
 	struct qede_dev *edev = netdev_priv(dev);
-	u16 t_port = ntohs(port);
+	u16 t_port = ntohs(ti->port);
 
-	if (edev->vxlan_dst_port)
-		return;
+	switch (ti->type) {
+	case UDP_TUNNEL_TYPE_VXLAN:
+		if (edev->vxlan_dst_port)
+			return;
 
-	edev->vxlan_dst_port = t_port;
+		edev->vxlan_dst_port = t_port;
 
-	DP_VERBOSE(edev, QED_MSG_DEBUG, "Added vxlan port=%d", t_port);
+		DP_VERBOSE(edev, QED_MSG_DEBUG, "Added vxlan port=%d",
+			   t_port);
 
-	set_bit(QEDE_SP_VXLAN_PORT_CONFIG, &edev->sp_flags);
-	schedule_delayed_work(&edev->sp_task, 0);
-}
+		set_bit(QEDE_SP_VXLAN_PORT_CONFIG, &edev->sp_flags);
+		break;
+	case UDP_TUNNEL_TYPE_GENEVE:
+		if (edev->geneve_dst_port)
+			return;
 
-static void qede_del_vxlan_port(struct net_device *dev,
-				sa_family_t sa_family, __be16 port)
-{
-	struct qede_dev *edev = netdev_priv(dev);
-	u16 t_port = ntohs(port);
+		edev->geneve_dst_port = t_port;
 
-	if (t_port != edev->vxlan_dst_port)
+		DP_VERBOSE(edev, QED_MSG_DEBUG, "Added geneve port=%d",
+			   t_port);
+		set_bit(QEDE_SP_GENEVE_PORT_CONFIG, &edev->sp_flags);
+		break;
+	default:
 		return;
+	}
 
-	edev->vxlan_dst_port = 0;
-
-	DP_VERBOSE(edev, QED_MSG_DEBUG, "Deleted vxlan port=%d", t_port);
-
-	set_bit(QEDE_SP_VXLAN_PORT_CONFIG, &edev->sp_flags);
 	schedule_delayed_work(&edev->sp_task, 0);
 }
-#endif
 
-#ifdef CONFIG_QEDE_GENEVE
-static void qede_add_geneve_port(struct net_device *dev,
-				 sa_family_t sa_family, __be16 port)
+static void qede_udp_tunnel_del(struct net_device *dev,
+				struct udp_tunnel_info *ti)
 {
 	struct qede_dev *edev = netdev_priv(dev);
-	u16 t_port = ntohs(port);
+	u16 t_port = ntohs(ti->port);
 
-	if (edev->geneve_dst_port)
-		return;
+	switch (ti->type) {
+	case UDP_TUNNEL_TYPE_VXLAN:
+		if (t_port != edev->vxlan_dst_port)
+			return;
 
-	edev->geneve_dst_port = t_port;
+		edev->vxlan_dst_port = 0;
 
-	DP_VERBOSE(edev, QED_MSG_DEBUG, "Added geneve port=%d", t_port);
-	set_bit(QEDE_SP_GENEVE_PORT_CONFIG, &edev->sp_flags);
-	schedule_delayed_work(&edev->sp_task, 0);
-}
+		DP_VERBOSE(edev, QED_MSG_DEBUG, "Deleted vxlan port=%d",
+			   t_port);
 
-static void qede_del_geneve_port(struct net_device *dev,
-				 sa_family_t sa_family, __be16 port)
-{
-	struct qede_dev *edev = netdev_priv(dev);
-	u16 t_port = ntohs(port);
+		set_bit(QEDE_SP_VXLAN_PORT_CONFIG, &edev->sp_flags);
+		break;
+	case UDP_TUNNEL_TYPE_GENEVE:
+		if (t_port != edev->geneve_dst_port)
+			return;
 
-	if (t_port != edev->geneve_dst_port)
-		return;
+		edev->geneve_dst_port = 0;
 
-	edev->geneve_dst_port = 0;
+		DP_VERBOSE(edev, QED_MSG_DEBUG, "Deleted geneve port=%d",
+			   t_port);
+		set_bit(QEDE_SP_GENEVE_PORT_CONFIG, &edev->sp_flags);
+		break;
+	default:
+		return;
+	}
 
-	DP_VERBOSE(edev, QED_MSG_DEBUG, "Deleted geneve port=%d", t_port);
-	set_bit(QEDE_SP_GENEVE_PORT_CONFIG, &edev->sp_flags);
 	schedule_delayed_work(&edev->sp_task, 0);
 }
-#endif
 
 static const struct net_device_ops qede_netdev_ops = {
 	.ndo_open = qede_open,
@@ -2204,14 +2199,8 @@ static const struct net_device_ops qede_netdev_ops = {
 	.ndo_get_vf_config = qede_get_vf_config,
 	.ndo_set_vf_rate = qede_set_vf_rate,
 #endif
-#ifdef CONFIG_QEDE_VXLAN
-	.ndo_add_vxlan_port = qede_add_vxlan_port,
-	.ndo_del_vxlan_port = qede_del_vxlan_port,
-#endif
-#ifdef CONFIG_QEDE_GENEVE
-	.ndo_add_geneve_port = qede_add_geneve_port,
-	.ndo_del_geneve_port = qede_del_geneve_port,
-#endif
+	.ndo_udp_tunnel_add = qede_udp_tunnel_add,
+	.ndo_udp_tunnel_del = qede_udp_tunnel_del,
 };
 
 /* -------------------------------------------------------------------------
@@ -3579,12 +3568,8 @@ static int qede_open(struct net_device *ndev)
 	if (rc)
 		return rc;
 
-#ifdef CONFIG_QEDE_VXLAN
-	vxlan_get_rx_port(ndev);
-#endif
-#ifdef CONFIG_QEDE_GENEVE
-	geneve_get_rx_port(ndev);
-#endif
+	udp_tunnel_get_rx_info(ndev);
+
 	return 0;
 }
 
