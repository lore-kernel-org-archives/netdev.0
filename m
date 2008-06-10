From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH][RFC] TSO for VLAN devices without VLAN tag insertion
Date: Tue, 10 Jun 2008 20:59:44 +0100
Message-ID: <20080610195943.GO11300@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net-drivers@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:33996 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751309AbYFJT7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 15:59:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SFC4000 controller can set IP header, TCP and UDP checksums in IPv4
packets, with or without VLAN encapsulation.  However it does not do VLAN
tag insertion.

When I try to make TSO work for VLAN devices via the new vlan_features,
dev_queue_xmit() finds skb->ip_summed == CHECKSUM_PARTIAL &&
skb->protocol == htons(ETH_P_8021Q) and calls skb_checksum_help(), which
sets skb->ip_summed = CHECKSUM_NONE.

This causes netif_needs_gso() to return true when called by
dev_hard_start_xmit(), and GSO then does its worst.

Below is a patch which worked for me, but I'm not sure whether it's the
best way to fix the problem (so I'm not submitting or signing it off yet).

Ben.

--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -119,6 +119,7 @@
 #include <linux/err.h>
 #include <linux/ctype.h>
 #include <linux/if_arp.h>
+#include <linux/if_vlan.h>
 
 #include "net-sysfs.h"
 
@@ -1638,14 +1639,24 @@ int dev_queue_xmit(struct sk_buff *skb)
 	 * checksumming for this protocol, complete checksumming here.
 	 */
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		unsigned long features = dev->features;
+		__be16 protocol = skb->protocol;
+
+		if (protocol == htons(ETH_P_8021Q)) {
+			struct vlan_ethhdr *veh =
+				(struct vlan_ethhdr *)skb->data;
+			features &= dev->vlan_features;
+			protocol = veh->h_vlan_encapsulated_proto;
+		}
+
 		skb_set_transport_header(skb, skb->csum_start -
 					      skb_headroom(skb));
 
-		if (!(dev->features & NETIF_F_GEN_CSUM) &&
-		    !((dev->features & NETIF_F_IP_CSUM) &&
-		      skb->protocol == htons(ETH_P_IP)) &&
-		    !((dev->features & NETIF_F_IPV6_CSUM) &&
-		      skb->protocol == htons(ETH_P_IPV6)))
+		if (!(features & NETIF_F_GEN_CSUM) &&
+		    !((features & NETIF_F_IP_CSUM) &&
+		      protocol == htons(ETH_P_IP)) &&
+		    !((features & NETIF_F_IPV6_CSUM) &&
+		      protocol == htons(ETH_P_IPV6)))
 			if (skb_checksum_help(skb))
 				goto out_kfree_skb;
 	}

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
