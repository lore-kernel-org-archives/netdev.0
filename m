From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/2] netdev: add support for Receive Side Scaling hash
 control
Date: Sun, 28 Mar 2010 15:44:48 -0700
Message-ID: <20100328154448.701c89ee@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42930 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755319Ab0C1Wyo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Mar 2010 18:54:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds ethtool and device feature flag to allow control
of Receive Side Scaling hashing supported by many modern
controllers.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
I am working on RSS for sky2 device, but the hardware isn't fully cooperating
but thought others might want to use same API.

--- a/include/linux/ethtool.h	2010-03-28 14:09:58.611267016 -0700
+++ b/include/linux/ethtool.h	2010-03-28 14:19:45.032516128 -0700
@@ -310,6 +310,7 @@ struct ethtool_perm_addr {
 enum ethtool_flags {
 	ETH_FLAG_LRO		= (1 << 15),	/* LRO is enabled */
 	ETH_FLAG_NTUPLE		= (1 << 27),	/* N-tuple filters enabled */
+	ETH_FLAG_RSS		= (1 << 28),	/* RSS is enabled */
 };
 
 /* The following structures are for supporting RX network flow
--- a/include/linux/netdevice.h	2010-03-28 14:12:13.092517615 -0700
+++ b/include/linux/netdevice.h	2010-03-28 14:13:47.232915349 -0700
@@ -785,6 +785,7 @@ struct net_device {
 #define NETIF_F_SCTP_CSUM	(1 << 25) /* SCTP checksum offload */
 #define NETIF_F_FCOE_MTU	(1 << 26) /* Supports max FCoE MTU, 2158 bytes*/
 #define NETIF_F_NTUPLE		(1 << 27) /* N-tuple filters supported */
+#define NETIF_F_RSS		(1 << 28) /* Receive Side Scaling hash */
 
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
--- a/net/core/ethtool.c	2010-03-28 14:12:25.012207457 -0700
+++ b/net/core/ethtool.c	2010-03-28 14:19:41.548521569 -0700
@@ -121,7 +121,7 @@ int ethtool_op_set_ufo(struct net_device
  * NETIF_F_xxx values in include/linux/netdevice.h
  */
 static const u32 flags_dup_features =
-	(ETH_FLAG_LRO | ETH_FLAG_NTUPLE);
+	(ETH_FLAG_LRO | ETH_FLAG_NTUPLE | ETH_FLAG_RSS);
 
 u32 ethtool_op_get_flags(struct net_device *dev)
 {
@@ -152,6 +152,11 @@ int ethtool_op_set_flags(struct net_devi
 		features &= ~NETIF_F_NTUPLE;
 	}
 
+	if (data & ETH_FLAG_RSS)
+		features |= NETIF_F_RSS;
+	else
+		features &= ~NETIF_F_RSS;
+
 	dev->features = features;
 	return 0;
 }
