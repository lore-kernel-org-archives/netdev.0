From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/2] bridge: relay bridge multicast pkgs if !STP
Date: Fri, 15 May 2009 09:10:13 -0700
Message-ID: <20090515091013.44b624d7@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, bridge@linux-foundation.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56785 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754046AbZEOQMH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 May 2009 12:12:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the bridge catches all STP packets; even if STP is turned
off.  This prevents other systems (which do have STP turned on)
from being able to detect loops in the network.

With this patch, if STP is off, then any packet sent to the STP
multicast group address is forwarded to all ports.

Based on earlier patch by Joakim Tjernlund with changes
to go through forwarding (not local chain), and optimization
that only last octet needs to be checked.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Please put in for 2.6.30 because it is a bug fix.

--- a/net/bridge/br_input.c	2009-05-14 14:50:29.288882708 -0700
+++ b/net/bridge/br_input.c	2009-05-15 09:01:31.799417662 -0700
@@ -134,6 +134,10 @@ struct sk_buff *br_handle_frame(struct n
 		if (skb->protocol == htons(ETH_P_PAUSE))
 			goto drop;
 
+		/* If STP is turned off, then forward */
+		if (p->br->stp_enabled == BR_NO_STP && dest[5] == 0)
+			goto forward;
+
 		if (NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
 			    NULL, br_handle_local_finish))
 			return NULL;	/* frame consumed by filter */
@@ -141,6 +145,7 @@ struct sk_buff *br_handle_frame(struct n
 			return skb;	/* continue processing */
 	}
 
+forward:
 	switch (p->state) {
 	case BR_STATE_FORWARDING:
 		rhook = rcu_dereference(br_should_route_hook);
