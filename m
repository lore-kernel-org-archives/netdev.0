From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] net: Fix test for VLAN TX checksum offload capability
Date: Fri, 13 Jun 2008 23:38:16 +0100
Message-ID: <20080613223815.GD11300@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:39998 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754192AbYFMWi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2008 18:38:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Selected device feature bits can be propagated to VLAN devices, so we
can make use of TX checksum offload and TSO on VLAN-tagged packets.
However, if the physical device does not do VLAN tag insertion or
generic checksum offload then the test for TX checksum offload in
dev_queue_xmit() will see a protocol of htons(ETH_P_8021Q) and yield
false.

This splits the checksum offload test into two functions:

- can_checksum_protocol() tests a given protocol against a feature bitmask

- dev_can_checksum() first tests the skb protocol against the device
  features; if that fails and the protocol is htons(ETH_P_8021Q) then
  it tests the encapsulated protocol against the effective device
  features for VLANs

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 net/core/dev.c |   34 ++++++++++++++++++++++++++--------
 1 files changed, 26 insertions(+), 8 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 5829630..68d8df0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -119,6 +119,7 @@
 #include <linux/err.h>
 #include <linux/ctype.h>
 #include <linux/if_arp.h>
+#include <linux/if_vlan.h>
 
 #include "net-sysfs.h"
 
@@ -1362,6 +1363,29 @@ void netif_device_attach(struct net_device *dev)
 }
 EXPORT_SYMBOL(netif_device_attach);
 
+static bool can_checksum_protocol(unsigned long features, __be16 protocol)
+{
+	return ((features & NETIF_F_GEN_CSUM) ||
+		((features & NETIF_F_IP_CSUM) &&
+		 protocol == htons(ETH_P_IP)) ||
+		((features & NETIF_F_IPV6_CSUM) &&
+		 protocol == htons(ETH_P_IPV6)));
+}
+
+static bool dev_can_checksum(struct net_device *dev, struct sk_buff *skb)
+{
+	if (can_checksum_protocol(dev->features, skb->protocol))
+		return true;
+
+	if (skb->protocol == htons(ETH_P_8021Q)) {
+		struct vlan_ethhdr *veh = (struct vlan_ethhdr *)skb->data;
+		if (can_checksum_protocol(dev->features & dev->vlan_features,
+					  veh->h_vlan_encapsulated_proto))
+			return true;
+	}
+
+	return false;
+}
 
 /*
  * Invalidate hardware checksum when packet is to be mangled, and
@@ -1640,14 +1664,8 @@ int dev_queue_xmit(struct sk_buff *skb)
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		skb_set_transport_header(skb, skb->csum_start -
 					      skb_headroom(skb));
-
-		if (!(dev->features & NETIF_F_GEN_CSUM) &&
-		    !((dev->features & NETIF_F_IP_CSUM) &&
-		      skb->protocol == htons(ETH_P_IP)) &&
-		    !((dev->features & NETIF_F_IPV6_CSUM) &&
-		      skb->protocol == htons(ETH_P_IPV6)))
-			if (skb_checksum_help(skb))
-				goto out_kfree_skb;
+		if (!dev_can_checksum(dev, skb) && skb_checksum_help(skb))
+			goto out_kfree_skb;
 	}
 
 gso:

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
