From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 07/15] i40e: Move all UDP port notifiers to single
 function
Date: Mon, 13 Jun 2016 10:48:49 -0700
Message-ID: <20160613174849.15186.61867.stgit@localhost.localdomain>
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
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33364 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423248AbcFMRsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 13:48:55 -0400
Received: by mail-pa0-f45.google.com with SMTP id b13so25419682pat.0
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 10:48:55 -0700 (PDT)
In-Reply-To: <20160613173750.15186.24381.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch goes through and combines the notifiers for VXLAN and GENEVE
into a single function for each action.  So there is now one combined
function for getting ports, one for adding the ports, and one for deleting
the ports.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c |  148 ++++++---------------------
 1 file changed, 35 insertions(+), 113 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 68172759bf71..8695ef467c58 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5367,14 +5367,9 @@ int i40e_open(struct net_device *netdev)
 						       TCP_FLAG_CWR) >> 16);
 	wr32(&pf->hw, I40E_GLLAN_TSOMSK_L, be32_to_cpu(TCP_FLAG_CWR) >> 16);
 
-#ifdef CONFIG_I40E_VXLAN
-	vxlan_get_rx_port(netdev);
+#if defined(CONFIG_I40E_VXLAN) || defined(CONFIG_I40E_GENEVE)
+	udp_tunnel_get_rx_port(netdev);
 #endif
-#ifdef CONFIG_I40E_GENEVE
-	if (pf->flags & I40E_FLAG_GENEVE_OFFLOAD_CAPABLE)
-		geneve_get_rx_port(netdev);
-#endif
-
 	i40e_notify_client_of_netdev_open(vsi);
 
 	return 0;
@@ -8678,17 +8673,16 @@ static u8 i40e_get_udp_port_idx(struct i40e_pf *pf, __be16 port)
 	return i;
 }
 
-#endif
-
-#if IS_ENABLED(CONFIG_VXLAN)
 /**
- * i40e_add_vxlan_port - Get notifications about VXLAN ports that come up
+ * i40e_add_udp_enc_port - Get notifications about UDP tunnel ports that come up
  * @netdev: This physical port's netdev
- * @sa_family: Socket Family that VXLAN is notifying us about
- * @port: New UDP port number that VXLAN started listening to
+ * @sa_family: Socket Family that tunnel is notifying us about
+ * @port: New UDP port number that tunnel started listening to
+ * @type: Enumerated type specifying UDP encapsulation type to be offloaded
  **/
-static void i40e_add_vxlan_port(struct net_device *netdev,
-				sa_family_t sa_family, __be16 port)
+static void i40e_add_udp_enc_port(struct net_device *netdev,
+				  sa_family_t sa_family, __be16 port,
+				  unsigned int type)
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
@@ -8700,7 +8694,7 @@ static void i40e_add_vxlan_port(struct net_device *netdev,
 
 	/* Check if port already exists */
 	if (idx < I40E_MAX_PF_UDP_OFFLOAD_PORTS) {
-		netdev_info(netdev, "vxlan port %d already offloaded\n",
+		netdev_info(netdev, "port %d already offloaded\n",
 			    ntohs(port));
 		return;
 	}
@@ -8709,112 +8703,46 @@ static void i40e_add_vxlan_port(struct net_device *netdev,
 	next_idx = i40e_get_udp_port_idx(pf, 0);
 
 	if (next_idx == I40E_MAX_PF_UDP_OFFLOAD_PORTS) {
-		netdev_info(netdev, "maximum number of vxlan UDP ports reached, not adding port %d\n",
-			    ntohs(port));
-		return;
-	}
-
-	/* New port: add it and mark its index in the bitmap */
-	pf->udp_ports[next_idx].index = port;
-	pf->udp_ports[next_idx].type = I40E_AQC_TUNNEL_TYPE_VXLAN;
-	pf->pending_udp_bitmap |= BIT_ULL(next_idx);
-	pf->flags |= I40E_FLAG_UDP_FILTER_SYNC;
-}
-
-/**
- * i40e_del_vxlan_port - Get notifications about VXLAN ports that go away
- * @netdev: This physical port's netdev
- * @sa_family: Socket Family that VXLAN is notifying us about
- * @port: UDP port number that VXLAN stopped listening to
- **/
-static void i40e_del_vxlan_port(struct net_device *netdev,
-				sa_family_t sa_family, __be16 port)
-{
-	struct i40e_netdev_priv *np = netdev_priv(netdev);
-	struct i40e_vsi *vsi = np->vsi;
-	struct i40e_pf *pf = vsi->back;
-	u8 idx;
-
-	idx = i40e_get_udp_port_idx(pf, port);
-
-	/* Check if port already exists */
-	if (idx < I40E_MAX_PF_UDP_OFFLOAD_PORTS) {
-		/* if port exists, set it to 0 (mark for deletion)
-		 * and make it pending
-		 */
-		pf->udp_ports[idx].index = 0;
-		pf->pending_udp_bitmap |= BIT_ULL(idx);
-		pf->flags |= I40E_FLAG_UDP_FILTER_SYNC;
-	} else {
-		netdev_warn(netdev, "vxlan port %d was not found, not deleting\n",
-			    ntohs(port));
-	}
-}
-#endif
-
-#if IS_ENABLED(CONFIG_GENEVE)
-/**
- * i40e_add_geneve_port - Get notifications about GENEVE ports that come up
- * @netdev: This physical port's netdev
- * @sa_family: Socket Family that GENEVE is notifying us about
- * @port: New UDP port number that GENEVE started listening to
- **/
-static void i40e_add_geneve_port(struct net_device *netdev,
-				 sa_family_t sa_family, __be16 port)
-{
-	struct i40e_netdev_priv *np = netdev_priv(netdev);
-	struct i40e_vsi *vsi = np->vsi;
-	struct i40e_pf *pf = vsi->back;
-	u8 next_idx;
-	u8 idx;
-
-	if (!(pf->flags & I40E_FLAG_GENEVE_OFFLOAD_CAPABLE))
-		return;
-
-	idx = i40e_get_udp_port_idx(pf, port);
-
-	/* Check if port already exists */
-	if (idx < I40E_MAX_PF_UDP_OFFLOAD_PORTS) {
-		netdev_info(netdev, "udp port %d already offloaded\n",
+		netdev_info(netdev, "maximum number of offloaded UDP ports reached, not adding port %d\n",
 			    ntohs(port));
 		return;
 	}
 
-	/* Now check if there is space to add the new port */
-	next_idx = i40e_get_udp_port_idx(pf, 0);
-
-	if (next_idx == I40E_MAX_PF_UDP_OFFLOAD_PORTS) {
-		netdev_info(netdev, "maximum number of UDP ports reached, not adding port %d\n",
-			    ntohs(port));
+	switch (type) {
+	case UDP_ENC_OFFLOAD_TYPE_VXLAN:
+		pf->udp_ports[next_idx].type = I40E_AQC_TUNNEL_TYPE_VXLAN;
+		break;
+	case UDP_ENC_OFFLOAD_TYPE_GENEVE:
+		if (!(pf->flags & I40E_FLAG_GENEVE_OFFLOAD_CAPABLE))
+			return;
+		pf->udp_ports[next_idx].type = I40E_AQC_TUNNEL_TYPE_NGE;
+		break;
+	default:
 		return;
 	}
 
 	/* New port: add it and mark its index in the bitmap */
 	pf->udp_ports[next_idx].index = port;
-	pf->udp_ports[next_idx].type = I40E_AQC_TUNNEL_TYPE_NGE;
 	pf->pending_udp_bitmap |= BIT_ULL(next_idx);
 	pf->flags |= I40E_FLAG_UDP_FILTER_SYNC;
-
-	dev_info(&pf->pdev->dev, "adding geneve port %d\n", ntohs(port));
 }
 
 /**
- * i40e_del_geneve_port - Get notifications about GENEVE ports that go away
+ * i40e_del_udp_enc_port - Get notifications about UDP tunnel ports that go away
  * @netdev: This physical port's netdev
- * @sa_family: Socket Family that GENEVE is notifying us about
- * @port: UDP port number that GENEVE stopped listening to
+ * @sa_family: Socket Family that tunnel is notifying us about
+ * @port: UDP port number that tunnel stopped listening to
+ * @type: Enumerated type specifying UDP encapsulation type to be offloaded
  **/
-static void i40e_del_geneve_port(struct net_device *netdev,
-				 sa_family_t sa_family, __be16 port)
+static void i40e_del_udp_enc_port(struct net_device *netdev,
+				  sa_family_t sa_family, __be16 port,
+				  unsigned int type)
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
 	u8 idx;
 
-	if (!(pf->flags & I40E_FLAG_GENEVE_OFFLOAD_CAPABLE))
-		return;
-
 	idx = i40e_get_udp_port_idx(pf, port);
 
 	/* Check if port already exists */
@@ -8825,13 +8753,11 @@ static void i40e_del_geneve_port(struct net_device *netdev,
 		pf->udp_ports[idx].index = 0;
 		pf->pending_udp_bitmap |= BIT_ULL(idx);
 		pf->flags |= I40E_FLAG_UDP_FILTER_SYNC;
-
-		dev_info(&pf->pdev->dev, "deleting geneve port %d\n",
-			 ntohs(port));
-	} else {
-		netdev_warn(netdev, "geneve port %d was not found, not deleting\n",
-			    ntohs(port));
+		return;
 	}
+
+	netdev_warn(netdev, "UDP port %d was not found, not deleting\n",
+		    ntohs(port));
 }
 #endif
 
@@ -9063,13 +8989,9 @@ static const struct net_device_ops i40e_netdev_ops = {
 	.ndo_set_vf_link_state	= i40e_ndo_set_vf_link_state,
 	.ndo_set_vf_spoofchk	= i40e_ndo_set_vf_spoofchk,
 	.ndo_set_vf_trust	= i40e_ndo_set_vf_trust,
-#if IS_ENABLED(CONFIG_VXLAN)
-	.ndo_add_vxlan_port	= i40e_add_vxlan_port,
-	.ndo_del_vxlan_port	= i40e_del_vxlan_port,
-#endif
-#if IS_ENABLED(CONFIG_GENEVE)
-	.ndo_add_geneve_port	= i40e_add_geneve_port,
-	.ndo_del_geneve_port	= i40e_del_geneve_port,
+#if IS_ENABLED(CONFIG_VXLAN) || IS_ENABLED(CONFIG_GENEVE)
+	.ndo_add_udp_enc_port	= i40e_add_udp_enc_port,
+	.ndo_del_udp_enc_port	= i40e_del_udp_enc_port,
 #endif
 	.ndo_get_phys_port_id	= i40e_get_phys_port_id,
 	.ndo_fdb_add		= i40e_ndo_fdb_add,
