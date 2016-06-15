From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v2 05/17] bnxt: Update drivers to support unified
 UDP encapsulation offload functions
Date: Wed, 15 Jun 2016 15:07:47 -0700
Message-ID: <20160615220747.15575.31433.stgit@localhost.localdomain>
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
Received: from mail-pf0-f177.google.com ([209.85.192.177]:33664 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753113AbcFOWHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 18:07:50 -0400
Received: by mail-pf0-f177.google.com with SMTP id i123so8980126pfg.0
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 15:07:49 -0700 (PDT)
In-Reply-To: <20160615220449.15575.17031.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch ends up doing several things.  First it updates the driver to
make use of the new unified UDP tunnel offload notifier functions.  In
addition I updated the code so that we can work around the bits that were
checking for if VXLAN was enabled since we are now using a notifier based
setup.  Finally I moved the hard-coded GENEVE port over to using the
notifier based setup so that we can update it if needed.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/broadcom/Kconfig     |    1 
 drivers/net/ethernet/broadcom/bnxt/bnxt.c |   68 +++++++++++++++++------------
 2 files changed, 40 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethernet/broadcom/Kconfig
index d92c37fa8036..d74a92e1c27d 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -166,7 +166,6 @@ config SYSTEMPORT
 config BNXT
 	tristate "Broadcom NetXtreme-C/E support"
 	depends on PCI
-	depends on VXLAN || VXLAN=n
 	select FW_LOADER
 	select LIBCRC32C
 	---help---
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index c777cde85ce4..bb66091b7dd6 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -37,9 +37,7 @@
 #include <net/udp.h>
 #include <net/checksum.h>
 #include <net/ip6_checksum.h>
-#if defined(CONFIG_VXLAN) || defined(CONFIG_VXLAN_MODULE)
-#include <net/vxlan.h>
-#endif
+#include <net/udp_tunnel.h>
 #ifdef CONFIG_NET_RX_BUSY_POLL
 #include <net/busy_poll.h>
 #endif
@@ -5074,9 +5072,7 @@ static int __bnxt_open_nic(struct bnxt *bp, bool irq_re_init, bool link_re_init)
 	}
 
 	if (irq_re_init) {
-#if defined(CONFIG_VXLAN) || defined(CONFIG_VXLAN_MODULE)
-		vxlan_get_rx_port(bp->dev);
-#endif
+		udp_tunnel_get_rx_info(bp->dev);
 		if (!bnxt_hwrm_tunnel_dst_port_alloc(
 				bp, htons(0x17c1),
 				TUNNEL_DST_PORT_FREE_REQ_TUNNEL_TYPE_GENEVE))
@@ -6048,47 +6044,63 @@ static void bnxt_cfg_ntp_filters(struct bnxt *bp)
 
 #endif /* CONFIG_RFS_ACCEL */
 
-static void bnxt_add_vxlan_port(struct net_device *dev, sa_family_t sa_family,
-				__be16 port)
+static void bnxt_udp_tunnel_add(struct net_device *dev,
+				struct udp_tunnel_info *ti)
 {
 	struct bnxt *bp = netdev_priv(dev);
 
-	if (!netif_running(dev))
+	if (ti->sa_family != AF_INET6 && ti->sa_family != AF_INET)
 		return;
 
-	if (sa_family != AF_INET6 && sa_family != AF_INET)
+	if (!netif_running(dev))
 		return;
 
-	if (bp->vxlan_port_cnt && bp->vxlan_port != port)
-		return;
+	switch (ti->type) {
+	case UDP_TUNNEL_TYPE_VXLAN:
+		if (bp->vxlan_port_cnt && bp->vxlan_port != ti->port)
+			return;
 
-	bp->vxlan_port_cnt++;
-	if (bp->vxlan_port_cnt == 1) {
-		bp->vxlan_port = port;
-		set_bit(BNXT_VXLAN_ADD_PORT_SP_EVENT, &bp->sp_event);
-		schedule_work(&bp->sp_task);
+		bp->vxlan_port_cnt++;
+		if (bp->vxlan_port_cnt == 1) {
+			bp->vxlan_port = ti->port;
+			set_bit(BNXT_VXLAN_ADD_PORT_SP_EVENT, &bp->sp_event);
+			schedule_work(&bp->sp_task);
+		}
+		break;
+	default:
+		return;
 	}
+
+	schedule_work(&bp->sp_task);
 }
 
-static void bnxt_del_vxlan_port(struct net_device *dev, sa_family_t sa_family,
-				__be16 port)
+static void bnxt_udp_tunnel_del(struct net_device *dev,
+				struct udp_tunnel_info *ti)
 {
 	struct bnxt *bp = netdev_priv(dev);
 
-	if (!netif_running(dev))
+	if (ti->sa_family != AF_INET6 && ti->sa_family != AF_INET)
 		return;
 
-	if (sa_family != AF_INET6 && sa_family != AF_INET)
+	if (!netif_running(dev))
 		return;
 
-	if (bp->vxlan_port_cnt && bp->vxlan_port == port) {
+	switch (ti->type) {
+	case UDP_TUNNEL_TYPE_VXLAN:
+		if (!bp->vxlan_port_cnt || bp->vxlan_port != ti->port)
+			return;
 		bp->vxlan_port_cnt--;
 
-		if (bp->vxlan_port_cnt == 0) {
-			set_bit(BNXT_VXLAN_DEL_PORT_SP_EVENT, &bp->sp_event);
-			schedule_work(&bp->sp_task);
-		}
+		if (bp->vxlan_port_cnt != 0)
+			return;
+
+		set_bit(BNXT_VXLAN_DEL_PORT_SP_EVENT, &bp->sp_event);
+		break;
+	default:
+		return;
 	}
+
+	schedule_work(&bp->sp_task);
 }
 
 static const struct net_device_ops bnxt_netdev_ops = {
@@ -6119,8 +6131,8 @@ static const struct net_device_ops bnxt_netdev_ops = {
 #ifdef CONFIG_RFS_ACCEL
 	.ndo_rx_flow_steer	= bnxt_rx_flow_steer,
 #endif
-	.ndo_add_vxlan_port	= bnxt_add_vxlan_port,
-	.ndo_del_vxlan_port	= bnxt_del_vxlan_port,
+	.ndo_udp_tunnel_add	= bnxt_udp_tunnel_add,
+	.ndo_udp_tunnel_del	= bnxt_udp_tunnel_del,
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	.ndo_busy_poll		= bnxt_busy_poll,
 #endif
