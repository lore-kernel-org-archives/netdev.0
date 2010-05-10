From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/4] bridge: netfilter use net_ratelimit
Date: Mon, 10 May 2010 12:31:10 -0700
Message-ID: <20100510193320.936126854@vyatta.com>
References: <20100510193107.722574297@vyatta.com>
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:43071 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754375Ab0EJTfc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 May 2010 15:35:32 -0400
Content-Disposition: inline; filename=bridge-netfilter-msg.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function __br_dnat_complain is basically reimplementing existing
net_ratelimit.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/bridge/br_netfilter.c	2010-05-06 12:32:23.427786161 -0700
+++ b/net/bridge/br_netfilter.c	2010-05-06 12:33:37.826565965 -0700
@@ -253,17 +253,6 @@ static int br_nf_pre_routing_finish_ipv6
 	return 0;
 }
 
-static void __br_dnat_complain(void)
-{
-	static unsigned long last_complaint;
-
-	if (jiffies - last_complaint >= 5 * HZ) {
-		printk(KERN_WARNING "Performing cross-bridge DNAT requires IP "
-		       "forwarding to be enabled\n");
-		last_complaint = jiffies;
-	}
-}
-
 /* This requires some explaining. If DNAT has taken place,
  * we will need to fix up the destination Ethernet address,
  * and this is a tricky process.
@@ -382,8 +371,12 @@ static int br_nf_pre_routing_finish(stru
 				/* we are sure that forwarding is disabled, so printing
 				 * this message is no problem. Note that the packet could
 				 * still have a martian destination address, in which case
-				 * the packet could be dropped even if forwarding were enabled */
-				__br_dnat_complain();
+				 * the packet could be dropped even if forwarding were enabled
+				 */
+				if (net_ratelimit())
+					netdev_warn(dev, "Performing cross-bridge DNAT "
+						    "requires IP forwarding to be enabled\n");
+
 				dst_release((struct dst_entry *)rt);
 			}
 free_skb:


