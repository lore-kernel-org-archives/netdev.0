From: Jason Baron <jbaron@akamai.com>
Subject: [PATCH net-next 2/2] macvlan: optimize the receive path
Date: Fri, 10 Oct 2014 03:13:31 +0000 (GMT)
Message-ID: <593466819a97154ffeae116d6789dd4ca1f2aab8.1412908929.git.jbaron@akamai.com>
References: <cover.1412908929.git.jbaron@akamai.com>
Cc: eric.dumazet@gmail.com, stephen@networkplumber.org,
	vyasevich@gmail.com, kaber@trash.net, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay02.akamai.com ([72.246.2.14]:59592 "EHLO
	prod-mail-xrelay02.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751174AbaJJDNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 23:13:32 -0400
In-Reply-To: <cover.1412908929.git.jbaron@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The netif_rx() call on the fast path of macvlan_handle_frame() appears to
be there to ensure that we properly throttle incoming packets. However, it
would appear as though the proper throttling is already in place for all
possible ingress paths, and that the call is redundant. If packets are arriving
from the physical NIC, we've already throttled them by this point. Otherwise,
if they are coming via macvlan_queue_xmit(), it calls either
'dev_forward_skb()', which ends up calling netif_rx_internal(), or else in
the broadcast case, we are throttling via macvlan_broadcast_enqueue().

The test results below are from off the box to an lxc instance running macvlan.
Once the tranactions/sec stop increasing, the cpu idle time has gone to 0.
Results are from a quad core Intel E3-1270 V2@3.50GHz box with bnx2x 10G card.

for i in {10,100,200,300,400,500};
do super_netperf $i -H $ip -t TCP_RR; done
Average of 5 runs.

trans/sec 		 trans/sec
(3.17-rc7-net-next)      (3.17-rc7-net-next + this patch)
----------               ----------
208101                   211534 (+1.6%)
839493                   850162 (+1.3%)
845071                   844053 (-.12%)
816330                   819623 (+.4%)
778700                   789938 (+1.4%)
735984                   754408 (+2.5%)

Signed-off-by: Jason Baron <jbaron@akamai.com>
---
 drivers/net/macvlan.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index c7c58af..29b3bb4 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -407,7 +407,8 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 	const struct macvlan_dev *src;
 	struct net_device *dev;
 	unsigned int len = 0;
-	int ret = NET_RX_DROP;
+	int ret;
+	rx_handler_result_t handle_res;
 
 	port = macvlan_port_get_rcu(skb->dev);
 	if (is_multicast_ether_addr(eth->h_dest)) {
@@ -423,6 +424,7 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 			vlan = src;
 			ret = macvlan_broadcast_one(skb, vlan, eth, 0) ?:
 			      netif_rx(skb);
+			handle_res = RX_HANDLER_CONSUMED;
 			goto out;
 		}
 
@@ -448,17 +450,20 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 	}
 	len = skb->len + ETH_HLEN;
 	skb = skb_share_check(skb, GFP_ATOMIC);
-	if (!skb)
+	if (!skb) {
+		ret = NET_RX_DROP;
+		handle_res = RX_HANDLER_CONSUMED;
 		goto out;
+	}
 
 	skb->dev = dev;
 	skb->pkt_type = PACKET_HOST;
 
-	ret = netif_rx(skb);
-
+	ret = NET_RX_SUCCESS;
+	handle_res = RX_HANDLER_ANOTHER;
 out:
 	macvlan_count_rx(vlan, len, ret == NET_RX_SUCCESS, false);
-	return RX_HANDLER_CONSUMED;
+	return handle_res;
 }
 
 static int macvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
-- 
1.8.2.rc2
