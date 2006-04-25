From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] bridge: allow full size vlan packets (repost)
Date: Tue, 25 Apr 2006 11:08:12 -0700
Message-ID: <20060425110812.78df807f@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:44211 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932131AbWDYSIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2006 14:08:36 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Need to allow for VLAN header when bridging.

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
