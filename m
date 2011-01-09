From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH 2/6] offloading: Generalize netif_get_vlan_features().
Date: Sun,  9 Jan 2011 08:23:31 -0800
Message-ID: <1294590215-15541-2-git-send-email-jesse@nicira.com>
References: <1294590215-15541-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:37428 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751800Ab1AIQXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jan 2011 11:23:44 -0500
Received: by yib18 with SMTP id 18so5042831yib.19
        for <netdev@vger.kernel.org>; Sun, 09 Jan 2011 08:23:44 -0800 (PST)
In-Reply-To: <1294590215-15541-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netif_get_vlan_features() is currently only used by netif_needs_gso(),
so it only concerns itself with GSO features.  However, several other
places also should take into account the contents of the packet when
deciding whether to offload to hardware.  This generalizes the function
to return features about all of the various forms of offloading.  Since
offloads tend to be linked together, this avoids duplicating the logic
in each location (i.e. the scatter/gather code also needs the checksum
logic).

Suggested-by: Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 include/linux/netdevice.h |    4 ++--
 net/core/dev.c            |   35 +++++++++++++++++++++++++++--------
 2 files changed, 29 insertions(+), 10 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0f6b1c9..d4dac09 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2303,7 +2303,7 @@ unsigned long netdev_fix_features(unsigned long f=
eatures, const char *name);
 void netif_stacked_transfer_operstate(const struct net_device *rootdev=
,
 					struct net_device *dev);
=20
-int netif_get_vlan_features(struct sk_buff *skb, struct net_device *de=
v);
+int netif_skb_features(struct sk_buff *skb);
=20
 static inline int net_gso_ok(int features, int gso_type)
 {
@@ -2320,7 +2320,7 @@ static inline int skb_gso_ok(struct sk_buff *skb,=
 int features)
 static inline int netif_needs_gso(struct net_device *dev, struct sk_bu=
ff *skb)
 {
 	if (skb_is_gso(skb)) {
-		int features =3D netif_get_vlan_features(skb, dev);
+		int features =3D netif_skb_features(skb);
=20
 		return (!skb_gso_ok(skb, features) ||
 			unlikely(skb->ip_summed !=3D CHECKSUM_PARTIAL));
diff --git a/net/core/dev.c b/net/core/dev.c
index d8befd0..a51dfd7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2017,22 +2017,41 @@ static inline void skb_orphan_try(struct sk_buf=
f *skb)
 	}
 }
=20
-int netif_get_vlan_features(struct sk_buff *skb, struct net_device *de=
v)
+static int harmonize_features(struct sk_buff *skb, __be16 protocol, in=
t features)
+{
+	if (!can_checksum_protocol(protocol, features)) {
+		features &=3D ~NETIF_F_ALL_CSUM;
+		features &=3D ~NETIF_F_SG;
+	} else if (illegal_highdma(skb->dev, skb)) {
+		features &=3D ~NETIF_F_SG;
+	}
+
+	return features;
+}
+
+int netif_skb_features(struct sk_buff *skb)
 {
 	__be16 protocol =3D skb->protocol;
+	int features =3D skb->dev->features;
=20
 	if (protocol =3D=3D htons(ETH_P_8021Q)) {
 		struct vlan_ethhdr *veh =3D (struct vlan_ethhdr *)skb->data;
 		protocol =3D veh->h_vlan_encapsulated_proto;
-	} else if (!skb->vlan_tci)
-		return dev->features;
+	} else if (!vlan_tx_tag_present(skb)) {
+		return harmonize_features(skb, protocol, features);
+	}
=20
-	if (protocol !=3D htons(ETH_P_8021Q))
-		return dev->features & dev->vlan_features;
-	else
-		return 0;
+	features &=3D skb->dev->vlan_features;
+
+	if (protocol !=3D htons(ETH_P_8021Q)) {
+		return harmonize_features(skb, protocol, features);
+	} else {
+		features &=3D NETIF_F_SG | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST |
+				NETIF_F_GEN_CSUM;
+		return harmonize_features(skb, protocol, features);
+	}
 }
-EXPORT_SYMBOL(netif_get_vlan_features);
+EXPORT_SYMBOL(netif_skb_features);
=20
 /*
  * Returns true if either:
--=20
1.7.1

