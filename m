From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: [PATCH net-next 7/9] sunvnet: remove extra rcu_read_unlocks
Date: Fri,  3 Feb 2017 09:42:33 -0800
Message-ID: <1486143755-192532-8-git-send-email-shannon.nelson@oracle.com>
References: <1486143755-192532-1-git-send-email-shannon.nelson@oracle.com>
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org,
        Shannon Nelson <shannon.nelson@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486143755-192532-1-git-send-email-shannon.nelson@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The RCU read lock is grabbed first thing in sunvnet_start_xmit_common()
so it always needs to be released.  This removes the conditional release
in the dropped packet error path and removes a couple of superfluous
calls in the middle of the code.

Reported-by: Bijan Mottahedeh <bijan.mottahedeh@oracle.com>
Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet_common.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet_common.c b/drivers/net/ethernet/sun/sunvnet_common.c
index 160b35a..a479a58 100644
--- a/drivers/net/ethernet/sun/sunvnet_common.c
+++ b/drivers/net/ethernet/sun/sunvnet_common.c
@@ -1279,10 +1279,8 @@ int sunvnet_start_xmit_common(struct sk_buff *skb, struct net_device *dev,
 
 	rcu_read_lock();
 	port = vnet_tx_port(skb, dev);
-	if (unlikely(!port)) {
-		rcu_read_unlock();
+	if (unlikely(!port))
 		goto out_dropped;
-	}
 
 	if (skb_is_gso(skb) && skb->len > port->tsolen) {
 		err = vnet_handle_offloads(port, skb, vnet_tx_port);
@@ -1307,7 +1305,6 @@ int sunvnet_start_xmit_common(struct sk_buff *skb, struct net_device *dev,
 			fl4.saddr = ip_hdr(skb)->saddr;
 
 			rt = ip_route_output_key(dev_net(dev), &fl4);
-			rcu_read_unlock();
 			if (!IS_ERR(rt)) {
 				skb_dst_set(skb, &rt->dst);
 				icmp_send(skb, ICMP_DEST_UNREACH,
@@ -1481,8 +1478,7 @@ out_dropped:
 				jiffies + VNET_CLEAN_TIMEOUT);
 	else if (port)
 		del_timer(&port->clean_timer);
-	if (port)
-		rcu_read_unlock();
+	rcu_read_unlock();
 	if (skb)
 		dev_kfree_skb(skb);
 	vnet_free_skbs(freeskbs);
-- 
1.7.1
