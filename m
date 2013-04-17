From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 5/5] IPoIB: add support for TIPC protocol
Date: Wed, 17 Apr 2013 18:18:29 +0200
Message-ID: <1366215509-18500-6-git-send-email-kaber@trash.net>
References: <1366215509-18500-1-git-send-email-kaber@trash.net>
Cc: davem@davemloft.net, allan.stephens@windriver.com,
	netdev@vger.kernel.org, roland@kernel.org, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, linux-rdma@vger.kernel.org
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60755 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755612Ab3DQQTD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 12:19:03 -0400
In-Reply-To: <1366215509-18500-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support TIPC in the IPoIB driver. Since IPoIB now keeps track of its own
neighbour entries and doesn't require the packet to have a dst_entry
anymore, the only necessary changes are to:

- not drop multicast TIPC packets because of the unknown ethernet type
- handle unicast TIPC packets similar to IPv4/IPv6 unicast packets

in ipoib_start_xmit().

An alternative would be to remove all ethertype limitations since they're
not necessary anymore, all TIPC needs to know about is ARP and RARP since
it wants to always perform "path find", even if a path is already known.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 drivers/infiniband/ulp/ipoib/ipoib_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 8534afd..554b906 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -730,7 +730,8 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		if ((header->proto != htons(ETH_P_IP)) &&
 		    (header->proto != htons(ETH_P_IPV6)) &&
 		    (header->proto != htons(ETH_P_ARP)) &&
-		    (header->proto != htons(ETH_P_RARP))) {
+		    (header->proto != htons(ETH_P_RARP)) &&
+		    (header->proto != htons(ETH_P_TIPC))) {
 			/* ethertype not supported by IPoIB */
 			++dev->stats.tx_dropped;
 			dev_kfree_skb_any(skb);
@@ -751,6 +752,7 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	switch (header->proto) {
 	case htons(ETH_P_IP):
 	case htons(ETH_P_IPV6):
+	case htons(ETH_P_TIPC):
 		neigh = ipoib_neigh_get(dev, cb->hwaddr);
 		if (unlikely(!neigh)) {
 			neigh_add_path(skb, cb->hwaddr, dev);
-- 
1.8.1.4
