From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/4] bridge: drop PAUSE frames
Date: Wed, 25 Apr 2007 16:47:39 -0700
Message-ID: <20070425234950.699578312@linux-foundation.org>
References: <20070425234737.727790594@linux-foundation.org>
Cc: netdev@vger.kernel.org, bridge@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:47902 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S2993145AbXDYXzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 19:55:35 -0400
Content-Disposition: inline; filename=bridge-drop-pause.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pause frames should never make it out of the network device into
the stack. But if a device was misconfigured, it might happen.
So drop pause frames in bridge.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- bridge-2.6.22.orig/include/linux/if_ether.h
+++ bridge-2.6.22/include/linux/if_ether.h
@@ -61,6 +61,7 @@
 #define ETH_P_8021Q	0x8100          /* 802.1Q VLAN Extended Header  */
 #define ETH_P_IPX	0x8137		/* IPX over DIX			*/
 #define ETH_P_IPV6	0x86DD		/* IPv6 over bluebook		*/
+#define ETH_P_PAUSE	0x8808		/* IEEE Pause frames. See 802.3 31B */
 #define ETH_P_SLOW	0x8809		/* Slow Protocol. See 802.3ad 43B */
 #define ETH_P_WCCP	0x883E		/* Web-cache coordination protocol
 					 * defined in draft-wilson-wrec-wccp-v2-00.txt */
--- bridge-2.6.22.orig/net/bridge/br_input.c
+++ bridge-2.6.22/net/bridge/br_input.c
@@ -131,9 +131,14 @@ struct sk_buff *br_handle_frame(struct n
 	if (!is_valid_ether_addr(eth_hdr(skb)->h_source))
 		goto drop;
 
-	if (unlikely(is_link_local(dest)))
+	if (unlikely(is_link_local(dest))) {
+		/* Pause frames shouldn't be passed up by driver anyway */
+		if (skb->protocol == htons(ETH_P_PAUSE))
+			goto drop;
+
 		return (NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
 				NULL, br_handle_local_finish) == 0) ? skb : NULL;
+	}
 
 	switch (p->state) {
 	case BR_STATE_FORWARDING:

-- 

