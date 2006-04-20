From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] bridge: allow full size vlan tagged packets to be bridged
Date: Thu, 20 Apr 2006 14:44:19 -0700
Message-ID: <20060420144419.71f0c03d@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:31379 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751346AbWDTVoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2006 17:44:22 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Ethernet bridge code silently drops packets when forwarding a packet
that is too large for the destination interface (as per 802.1d). But it
should allow for VLAN tagged frames.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- bridge.orig/net/bridge/br_forward.c	2006-04-10 16:17:51.000000000 -0700
+++ bridge/net/bridge/br_forward.c	2006-04-19 13:50:42.000000000 -0700
@@ -16,6 +16,7 @@
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
+#include <linux/if_vlan.h>
 #include <linux/netfilter_bridge.h>
 #include "br_private.h"
 
@@ -29,10 +30,15 @@
 	return 1;
 }
 
+static inline unsigned packet_length(const struct sk_buff *skb)
+{
+	return skb->len - (skb->protocol == htons(ETH_P_8021Q) ? VLAN_HLEN : 0);
+}
+
 int br_dev_queue_push_xmit(struct sk_buff *skb)
 {
 	/* drop mtu oversized packets except tso */
-	if (skb->len > skb->dev->mtu && !skb_shinfo(skb)->tso_size)
+	if (packet_length(skb) > skb->dev->mtu && !skb_shinfo(skb)->tso_size)
 		kfree_skb(skb);
 	else {
 #ifdef CONFIG_BRIDGE_NETFILTER
