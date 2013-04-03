From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Subject: [PATCH 5/5] IPoIB: add support for TIPC protocol
Date: Wed,  3 Apr 2013 14:43:30 +0200
Message-ID: <1364993010-15515-6-git-send-email-kaber@trash.net>
References: <1364993010-15515-1-git-send-email-kaber@trash.net>
Cc: allan.stephens-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jon.maloy-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1364993010-15515-1-git-send-email-kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Support TIPC in the IPoIB driver. Since IPoIB now keeps track of its own
neighbour entries and doesn't require the packet to have a dst_entry
anymore, the only necessary changes are to:

- not drop multicast TIPC packets because of the unknown ethernet type
- handle unicast TIPC packets similar to IPv4/IPv6 unicast packets

in ipoib_start_xmit().

An alternative would be to remove all ethertype limitations since they're
not necessary anymore, all TIPC needs to know about is ARP and RARP since
it wants to always perform "path find", even if a path is already known.

Signed-off-by: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
