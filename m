From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 04/15] bnxt: Replace ndo_add/del_vxlan_port with
 ndo_add/del_udp_enc_port
Date: Mon, 13 Jun 2016 10:48:22 -0700
Message-ID: <20160613174822.15186.55819.stgit@localhost.localdomain>
References: <20160613173750.15186.24381.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hannes@redhat.com, jesse@kernel.org, jbenc@redhat.com,
	alexander.duyck@gmail.com, saeedm@mellanox.com,
	ariel.elior@qlogic.com, tom@herbertland.com,
	Dept-GELinuxNICDev@qlogic.com, davem@davemloft.net,
	eugenia@mellanox.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34416 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423227AbcFMRs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 13:48:26 -0400
Received: by mail-pa0-f53.google.com with SMTP id bz2so47754568pad.1
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 10:48:26 -0700 (PDT)
In-Reply-To: <20160613173750.15186.24381.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change replaces the network device operations for adding or removing a
VXLAN port with operations that are more generically defined to be used for
any UDP offload port but provide a type.  As such by just adding a line to
verify that the offload type if VXLAN we can maintain the same
functionality.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c |   22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index c777cde85ce4..ab55da46cb51 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -5074,8 +5074,8 @@ static int __bnxt_open_nic(struct bnxt *bp, bool irq_re_init, bool link_re_init)
 	}
 
 	if (irq_re_init) {
-#if defined(CONFIG_VXLAN) || defined(CONFIG_VXLAN_MODULE)
-		vxlan_get_rx_port(bp->dev);
+#if IS_ENABLED(CONFIG_VXLAN)
+		udp_tunnel_get_rx_port(bp->dev);
 #endif
 		if (!bnxt_hwrm_tunnel_dst_port_alloc(
 				bp, htons(0x17c1),
@@ -6049,16 +6049,19 @@ static void bnxt_cfg_ntp_filters(struct bnxt *bp)
 #endif /* CONFIG_RFS_ACCEL */
 
 static void bnxt_add_vxlan_port(struct net_device *dev, sa_family_t sa_family,
-				__be16 port)
+				__be16 port, unsigned int type)
 {
 	struct bnxt *bp = netdev_priv(dev);
 
-	if (!netif_running(dev))
+	if (type != UDP_ENC_OFFLOAD_TYPE_VXLAN)
 		return;
 
 	if (sa_family != AF_INET6 && sa_family != AF_INET)
 		return;
 
+	if (!netif_running(dev))
+		return;
+
 	if (bp->vxlan_port_cnt && bp->vxlan_port != port)
 		return;
 
@@ -6071,16 +6074,19 @@ static void bnxt_add_vxlan_port(struct net_device *dev, sa_family_t sa_family,
 }
 
 static void bnxt_del_vxlan_port(struct net_device *dev, sa_family_t sa_family,
-				__be16 port)
+				__be16 port, unsigned int type)
 {
 	struct bnxt *bp = netdev_priv(dev);
 
-	if (!netif_running(dev))
+	if (type != UDP_ENC_OFFLOAD_TYPE_VXLAN)
 		return;
 
 	if (sa_family != AF_INET6 && sa_family != AF_INET)
 		return;
 
+	if (!netif_running(dev))
+		return;
+
 	if (bp->vxlan_port_cnt && bp->vxlan_port == port) {
 		bp->vxlan_port_cnt--;
 
@@ -6119,8 +6125,8 @@ static const struct net_device_ops bnxt_netdev_ops = {
 #ifdef CONFIG_RFS_ACCEL
 	.ndo_rx_flow_steer	= bnxt_rx_flow_steer,
 #endif
-	.ndo_add_vxlan_port	= bnxt_add_vxlan_port,
-	.ndo_del_vxlan_port	= bnxt_del_vxlan_port,
+	.ndo_add_udp_enc_port	= bnxt_add_vxlan_port,
+	.ndo_del_udp_enc_port	= bnxt_del_vxlan_port,
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	.ndo_busy_poll		= bnxt_busy_poll,
 #endif
