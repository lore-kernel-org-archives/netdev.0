From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net v2] net: fix checksum features handling in
 netif_skb_features()
Date: Mon, 25 Aug 2014 15:16:22 +0200 (CEST)
Message-ID: <20140825131622.6233CA0BB0@unicorn.suse.cz>
References: <20140821.163320.476216950054835385.davem@davemloft.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140821.163320.476216950054835385.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is follow-up to

  da08143b8520 ("vlan: more careful checksum features handling")

which introduced more careful feature intersection in vlan code,
taking into account that HW_CSUM should be considered superset
of IP_CSUM/IPV6_CSUM. The same is needed in netif_skb_features()
in order to avoid offloading mismatch warning when vlan is
created on top of a bond consisting of slaves supporting IP/IPv6
checksumming but not vlan Tx offloading.

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 net/core/dev.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index b65a505..a964017 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2587,13 +2587,19 @@ netdev_features_t netif_skb_features(struct sk_buff *skb)
 		return harmonize_features(skb, features);
 	}
 
-	features &= (skb->dev->vlan_features | NETIF_F_HW_VLAN_CTAG_TX |
-					       NETIF_F_HW_VLAN_STAG_TX);
+	features = netdev_intersect_features(features,
+					     skb->dev->vlan_features |
+					     NETIF_F_HW_VLAN_CTAG_TX |
+					     NETIF_F_HW_VLAN_STAG_TX);
 
 	if (protocol == htons(ETH_P_8021Q) || protocol == htons(ETH_P_8021AD))
-		features &= NETIF_F_SG | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST |
-				NETIF_F_GEN_CSUM | NETIF_F_HW_VLAN_CTAG_TX |
-				NETIF_F_HW_VLAN_STAG_TX;
+		features = netdev_intersect_features(features,
+						     NETIF_F_SG |
+						     NETIF_F_HIGHDMA |
+						     NETIF_F_FRAGLIST |
+						     NETIF_F_GEN_CSUM |
+						     NETIF_F_HW_VLAN_CTAG_TX |
+						     NETIF_F_HW_VLAN_STAG_TX);
 
 	return harmonize_features(skb, features);
 }
-- 
1.8.4.5
