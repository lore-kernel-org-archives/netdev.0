From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2] bridge netfilter: use net_ratelimit
Date: Thu, 6 May 2010 12:38:55 -0700
Message-ID: <20100506123855.735a164a@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52119 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755106Ab0EFTjI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 May 2010 15:39:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove routine br_dnat_complain which just implemented own version
of net_ratelimit() and use netdev_warn.

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
