From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next] team: Advertise tunneling offload features
Date: Thu, 17 Dec 2015 16:11:55 +0200
Message-ID: <1450361515-23594-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:39483 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S964793AbbLQOMe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Dec 2015 09:12:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

When the underlying device supports offloads encapulated traffic,
we need to reflect that through the hw_enc_features field of the
team net-device.

This will cause the xmit path in the core networking stack to provide
team with encapsulated GSO frames to offload into the HW etc.

Using this over Mellanox ConnectX3-pro (mlx4 driver) card that supports
VXLAN offloads we got 36.0 Gbits/sec using eight iperf streams.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
Acked-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/team/team.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 915f60f..2528331 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -985,10 +985,14 @@ static void team_port_disable(struct team *team,
 			    NETIF_F_FRAGLIST | NETIF_F_ALL_TSO | \
 			    NETIF_F_HIGHDMA | NETIF_F_LRO)
 
+#define TEAM_ENC_FEATURES	(NETIF_F_HW_CSUM | NETIF_F_SG | \
+				 NETIF_F_RXCSUM | NETIF_F_ALL_TSO)
+
 static void __team_compute_features(struct team *team)
 {
 	struct team_port *port;
 	u32 vlan_features = TEAM_VLAN_FEATURES & NETIF_F_ALL_FOR_ALL;
+	netdev_features_t enc_features  = TEAM_ENC_FEATURES;
 	unsigned short max_hard_header_len = ETH_HLEN;
 	unsigned int dst_release_flag = IFF_XMIT_DST_RELEASE |
 					IFF_XMIT_DST_RELEASE_PERM;
@@ -997,6 +1001,11 @@ static void __team_compute_features(struct team *team)
 		vlan_features = netdev_increment_features(vlan_features,
 					port->dev->vlan_features,
 					TEAM_VLAN_FEATURES);
+		enc_features =
+			netdev_increment_features(enc_features,
+						  port->dev->hw_enc_features,
+						  TEAM_ENC_FEATURES);
+
 
 		dst_release_flag &= port->dev->priv_flags;
 		if (port->dev->hard_header_len > max_hard_header_len)
@@ -1004,6 +1013,7 @@ static void __team_compute_features(struct team *team)
 	}
 
 	team->dev->vlan_features = vlan_features;
+	team->dev->hw_enc_features = enc_features | NETIF_F_GSO_ENCAP_ALL;
 	team->dev->hard_header_len = max_hard_header_len;
 
 	team->dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
@@ -2091,6 +2101,7 @@ static void team_setup(struct net_device *dev)
 			   NETIF_F_HW_VLAN_CTAG_RX |
 			   NETIF_F_HW_VLAN_CTAG_FILTER;
 
+	dev->hw_features |= NETIF_F_GSO_ENCAP_ALL;
 	dev->features |= dev->hw_features;
 }
 
-- 
2.3.7
