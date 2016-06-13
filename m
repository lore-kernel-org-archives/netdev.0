From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 13/15] qlcnic: Replace ndo_add/del_vxlan_port with
 ndo_add/del_udp_enc_port
Date: Mon, 13 Jun 2016 10:49:49 -0700
Message-ID: <20160613174949.15186.82510.stgit@localhost.localdomain>
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
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36314 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423279AbcFMRtx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 13:49:53 -0400
Received: by mail-pa0-f42.google.com with SMTP id b5so47738289pas.3
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 10:49:53 -0700 (PDT)
In-Reply-To: <20160613173750.15186.24381.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change replaces the network device operations for adding or removing a
VXLAN port with operations that are more generically defined to be used for
any UDP offload port but provide a type.  As such by just adding a line to
verify that the offload type is VXLAN we can maintain the same
functionality.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 1c29105b6c36..e2840f55f09f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -476,11 +476,15 @@ static int qlcnic_get_phys_port_id(struct net_device *netdev,
 
 #ifdef CONFIG_QLCNIC_VXLAN
 static void qlcnic_add_vxlan_port(struct net_device *netdev,
-				  sa_family_t sa_family, __be16 port)
+				  sa_family_t sa_family, __be16 port,
+				  unsigned int type)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
+	if (type != UDP_ENC_OFFLOAD_TYPE_VXLAN)
+		return;
+
 	/* Adapter supports only one VXLAN port. Use very first port
 	 * for enabling offload
 	 */
@@ -498,11 +502,15 @@ static void qlcnic_add_vxlan_port(struct net_device *netdev,
 }
 
 static void qlcnic_del_vxlan_port(struct net_device *netdev,
-				  sa_family_t sa_family, __be16 port)
+				  sa_family_t sa_family, __be16 port,
+				  unsigned int type)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
+	if (type != UDP_ENC_OFFLOAD_TYPE_VXLAN)
+		return;
+
 	if (!qlcnic_encap_rx_offload(adapter) || !ahw->vxlan_port_count ||
 	    (ahw->vxlan_port != ntohs(port)))
 		return;
@@ -540,8 +548,8 @@ static const struct net_device_ops qlcnic_netdev_ops = {
 	.ndo_fdb_dump		= qlcnic_fdb_dump,
 	.ndo_get_phys_port_id	= qlcnic_get_phys_port_id,
 #ifdef CONFIG_QLCNIC_VXLAN
-	.ndo_add_vxlan_port	= qlcnic_add_vxlan_port,
-	.ndo_del_vxlan_port	= qlcnic_del_vxlan_port,
+	.ndo_add_udp_enc_port	= qlcnic_add_vxlan_port,
+	.ndo_del_udp_enc_port	= qlcnic_del_vxlan_port,
 	.ndo_features_check	= qlcnic_features_check,
 #endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -2017,7 +2025,7 @@ qlcnic_attach(struct qlcnic_adapter *adapter)
 
 #ifdef CONFIG_QLCNIC_VXLAN
 	if (qlcnic_encap_rx_offload(adapter))
-		vxlan_get_rx_port(netdev);
+		udp_tunnel_get_rx_port(netdev);
 #endif
 
 	adapter->is_up = QLCNIC_ADAPTER_UP_MAGIC;
