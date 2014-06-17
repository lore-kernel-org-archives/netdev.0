From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net] bonding: Advertize vxlan offload features when supported
Date: Tue, 17 Jun 2014 16:11:09 +0300
Message-ID: <1403010669-19731-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
	amirv@mellanox.com, Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:41344 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755274AbaFQNLQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2014 09:11:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the underlying device supports TCP offloads for VXLAN/UDP
encapulated traffic, we need to reflect that through the hw_enc_features
field of the bonding net-device. This will cause the xmit path
in the core networking stack to provide bonding with encapsulated
GSO frames to offload into the HW etc.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/bonding/bond_main.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 04f35f9..3a451b6 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1025,10 +1025,14 @@ static netdev_features_t bond_fix_features(struct net_device *dev,
 				 NETIF_F_FRAGLIST | NETIF_F_ALL_TSO | \
 				 NETIF_F_HIGHDMA | NETIF_F_LRO)
 
+#define BOND_ENC_FEATURES	(NETIF_F_ALL_CSUM | NETIF_F_SG | NETIF_F_RXCSUM |\
+				 NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL)
+
 static void bond_compute_features(struct bonding *bond)
 {
 	unsigned int flags, dst_release_flag = IFF_XMIT_DST_RELEASE;
 	netdev_features_t vlan_features = BOND_VLAN_FEATURES;
+	netdev_features_t enc_features  = BOND_ENC_FEATURES;
 	struct net_device *bond_dev = bond->dev;
 	struct list_head *iter;
 	struct slave *slave;
@@ -1044,6 +1048,9 @@ static void bond_compute_features(struct bonding *bond)
 		vlan_features = netdev_increment_features(vlan_features,
 			slave->dev->vlan_features, BOND_VLAN_FEATURES);
 
+		enc_features = netdev_increment_features(enc_features,
+							 slave->dev->hw_enc_features,
+							 BOND_ENC_FEATURES);
 		dst_release_flag &= slave->dev->priv_flags;
 		if (slave->dev->hard_header_len > max_hard_header_len)
 			max_hard_header_len = slave->dev->hard_header_len;
@@ -1054,6 +1061,7 @@ static void bond_compute_features(struct bonding *bond)
 
 done:
 	bond_dev->vlan_features = vlan_features;
+	bond_dev->hw_enc_features = enc_features;
 	bond_dev->hard_header_len = max_hard_header_len;
 	bond_dev->gso_max_segs = gso_max_segs;
 	netif_set_gso_max_size(bond_dev, gso_max_size);
@@ -3975,6 +3983,7 @@ void bond_setup(struct net_device *bond_dev)
 				NETIF_F_HW_VLAN_CTAG_FILTER;
 
 	bond_dev->hw_features &= ~(NETIF_F_ALL_CSUM & ~NETIF_F_HW_CSUM);
+	bond_dev->hw_features |= NETIF_F_GSO_UDP_TUNNEL;
 	bond_dev->features |= bond_dev->hw_features;
 }
 
-- 
1.7.1
