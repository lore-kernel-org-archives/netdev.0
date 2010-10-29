From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH 3/3] offloading: Force software GSO for multiple vlan tags.
Date: Fri, 29 Oct 2010 15:14:55 -0700
Message-ID: <1288390495-28923-3-git-send-email-jesse@nicira.com>
References: <1288390495-28923-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:50140 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932900Ab0J2WPG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 18:15:06 -0400
Received: by mail-qw0-f46.google.com with SMTP id 7so2743176qwf.19
        for <netdev@vger.kernel.org>; Fri, 29 Oct 2010 15:15:05 -0700 (PDT)
In-Reply-To: <1288390495-28923-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently use vlan_features to check for TSO support if there is
a vlan tag.  However, it's quite likely that the NIC is not able to
do TSO when there is an arbitrary number of tags.  Therefore if there
is more than one tag (in-band or out-of-band), fall back to software
emulation.

Signed-off-by: Jesse Gross <jesse@nicira.com>
CC: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/netdevice.h |    7 +++----
 net/core/dev.c            |   16 ++++++++++++++++
 2 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 072652d..980c752 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2234,6 +2234,8 @@ unsigned long netdev_fix_features(unsigned long features, const char *name);
 void netif_stacked_transfer_operstate(const struct net_device *rootdev,
 					struct net_device *dev);
 
+int netif_get_vlan_features(struct sk_buff *skb, struct net_device *dev);
+
 static inline int net_gso_ok(int features, int gso_type)
 {
 	int feature = gso_type << NETIF_F_GSO_SHIFT;
@@ -2249,10 +2251,7 @@ static inline int skb_gso_ok(struct sk_buff *skb, int features)
 static inline int netif_needs_gso(struct net_device *dev, struct sk_buff *skb)
 {
 	if (skb_is_gso(skb)) {
-		int features = dev->features;
-
-		if (skb->protocol == htons(ETH_P_8021Q) || skb->vlan_tci)
-			features &= dev->vlan_features;
+		int features = netif_get_vlan_features(skb, dev);
 
 		return (!skb_gso_ok(skb, features) ||
 			unlikely(skb->ip_summed != CHECKSUM_PARTIAL));
diff --git a/net/core/dev.c b/net/core/dev.c
index 8bdda70..8d74988 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1969,6 +1969,22 @@ static inline void skb_orphan_try(struct sk_buff *skb)
 	}
 }
 
+int netif_get_vlan_features(struct sk_buff *skb, struct net_device *dev)
+{
+	__be16 protocol = skb->protocol;
+
+	if (protocol == htons(ETH_P_8021Q)) {
+		struct vlan_ethhdr *veh = (struct vlan_ethhdr *)skb->data;
+		protocol = veh->h_vlan_encapsulated_proto;
+	} else if (!skb->vlan_tci)
+		return dev->features;
+
+	if (protocol != htons(ETH_P_8021Q))
+		return dev->features & dev->vlan_features;
+	else
+		return 0;
+}
+
 /*
  * Returns true if either:
  *	1. skb has frag_list and the device doesn't support FRAGLIST, or
-- 
1.7.1

