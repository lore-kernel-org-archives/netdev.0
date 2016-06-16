From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v3 13/17] nfp: Replace ndo_add/del_vxlan_port with
 ndo_add/del_udp_enc_port
Date: Thu, 16 Jun 2016 12:22:51 -0700
Message-ID: <20160616192251.20872.62540.stgit@localhost.localdomain>
References: <20160616191851.20872.67154.stgit@localhost.localdomain>
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
Received: from mail-pf0-f176.google.com ([209.85.192.176]:35671 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754072AbcFPTWx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 15:22:53 -0400
Received: by mail-pf0-f176.google.com with SMTP id c2so22751669pfa.2
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 12:22:53 -0700 (PDT)
In-Reply-To: <20160616191851.20872.67154.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change replaces the network device operations for adding or removing a
VXLAN port with operations that are more generically defined to be used for
any UDP offload port but provide a type.  As such by just adding a line to
verify that the offload type is VXLAN we can maintain the same
functionality.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |   22 +++++++++++++-------
 1 file changed, 14 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index fa47c14c743a..2195ed3053da 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1979,7 +1979,7 @@ static int __nfp_net_set_config_and_enable(struct nfp_net *nn)
 	if (nn->ctrl & NFP_NET_CFG_CTRL_VXLAN) {
 		memset(&nn->vxlan_ports, 0, sizeof(nn->vxlan_ports));
 		memset(&nn->vxlan_usecnt, 0, sizeof(nn->vxlan_usecnt));
-		vxlan_get_rx_port(nn->netdev);
+		udp_tunnel_get_rx_info(nn->netdev);
 	}
 
 	return err;
@@ -2551,26 +2551,32 @@ static int nfp_net_find_vxlan_idx(struct nfp_net *nn, __be16 port)
 }
 
 static void nfp_net_add_vxlan_port(struct net_device *netdev,
-				   sa_family_t sa_family, __be16 port)
+				   struct udp_tunnel_info *ti)
 {
 	struct nfp_net *nn = netdev_priv(netdev);
 	int idx;
 
-	idx = nfp_net_find_vxlan_idx(nn, port);
+	if (ti->type != UDP_TUNNEL_TYPE_VXLAN)
+		return;
+
+	idx = nfp_net_find_vxlan_idx(nn, ti->port);
 	if (idx == -ENOSPC)
 		return;
 
 	if (!nn->vxlan_usecnt[idx]++)
-		nfp_net_set_vxlan_port(nn, idx, port);
+		nfp_net_set_vxlan_port(nn, idx, ti->port);
 }
 
 static void nfp_net_del_vxlan_port(struct net_device *netdev,
-				   sa_family_t sa_family, __be16 port)
+				   struct udp_tunnel_info *ti)
 {
 	struct nfp_net *nn = netdev_priv(netdev);
 	int idx;
 
-	idx = nfp_net_find_vxlan_idx(nn, port);
+	if (ti->type != UDP_TUNNEL_TYPE_VXLAN)
+		return;
+
+	idx = nfp_net_find_vxlan_idx(nn, ti->port);
 	if (!nn->vxlan_usecnt[idx] || idx == -ENOSPC)
 		return;
 
@@ -2589,8 +2595,8 @@ static const struct net_device_ops nfp_net_netdev_ops = {
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_set_features	= nfp_net_set_features,
 	.ndo_features_check	= nfp_net_features_check,
-	.ndo_add_vxlan_port     = nfp_net_add_vxlan_port,
-	.ndo_del_vxlan_port     = nfp_net_del_vxlan_port,
+	.ndo_udp_tunnel_add	= nfp_net_add_vxlan_port,
+	.ndo_udp_tunnel_del	= nfp_net_del_vxlan_port,
 };
 
 /**
