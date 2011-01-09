From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH 6/6] offloading: Convert checksums to use centrally computed features.
Date: Sun,  9 Jan 2011 08:23:35 -0800
Message-ID: <1294590215-15541-6-git-send-email-jesse@nicira.com>
References: <1294590215-15541-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:37428 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752202Ab1AIQXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jan 2011 11:23:50 -0500
Received: by mail-yi0-f46.google.com with SMTP id 18so5042831yib.19
        for <netdev@vger.kernel.org>; Sun, 09 Jan 2011 08:23:50 -0800 (PST)
In-Reply-To: <1294590215-15541-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to compute the features for other offloads (primarily
scatter/gather), we need to first check the ability of the NIC to
offload the checksum for the packet.  Since we have already computed
this, we can directly use the result instead of figuring it out
again.

Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/core/dev.c |   40 ++++++++++++----------------------------
 1 files changed, 12 insertions(+), 28 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 2f838f1..3fe443b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1732,33 +1732,6 @@ void netif_device_attach(struct net_device *dev)
 }
 EXPORT_SYMBOL(netif_device_attach);
 
-static bool can_checksum_protocol(unsigned long features, __be16 protocol)
-{
-	return ((features & NETIF_F_GEN_CSUM) ||
-		((features & NETIF_F_V4_CSUM) &&
-		 protocol == htons(ETH_P_IP)) ||
-		((features & NETIF_F_V6_CSUM) &&
-		 protocol == htons(ETH_P_IPV6)) ||
-		((features & NETIF_F_FCOE_CRC) &&
-		 protocol == htons(ETH_P_FCOE)));
-}
-
-static bool dev_can_checksum(struct net_device *dev, struct sk_buff *skb)
-{
-	__be16 protocol = skb->protocol;
-	int features = dev->features;
-
-	if (vlan_tx_tag_present(skb)) {
-		features &= dev->vlan_features;
-	} else if (protocol == htons(ETH_P_8021Q)) {
-		struct vlan_ethhdr *veh = (struct vlan_ethhdr *)skb->data;
-		protocol = veh->h_vlan_encapsulated_proto;
-		features &= dev->vlan_features;
-	}
-
-	return can_checksum_protocol(features, protocol);
-}
-
 /**
  * skb_dev_set -- assign a new device to a buffer
  * @skb: buffer for the new device
@@ -2015,6 +1988,17 @@ static inline void skb_orphan_try(struct sk_buff *skb)
 	}
 }
 
+static bool can_checksum_protocol(unsigned long features, __be16 protocol)
+{
+	return ((features & NETIF_F_GEN_CSUM) ||
+		((features & NETIF_F_V4_CSUM) &&
+		 protocol == htons(ETH_P_IP)) ||
+		((features & NETIF_F_V6_CSUM) &&
+		 protocol == htons(ETH_P_IPV6)) ||
+		((features & NETIF_F_FCOE_CRC) &&
+		 protocol == htons(ETH_P_FCOE)));
+}
+
 static int harmonize_features(struct sk_buff *skb, __be16 protocol, int features)
 {
 	if (!can_checksum_protocol(protocol, features)) {
@@ -2117,7 +2101,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			if (skb->ip_summed == CHECKSUM_PARTIAL) {
 				skb_set_transport_header(skb,
 					skb_checksum_start_offset(skb));
-				if (!dev_can_checksum(dev, skb) &&
+				if (!(features & NETIF_F_ALL_CSUM) &&
 				     skb_checksum_help(skb))
 					goto out_kfree_skb;
 			}
-- 
1.7.1

