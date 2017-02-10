From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: [PATCH v3 net-next 7/9] sunvnet: remove extra rcu_read_unlocks
Date: Fri, 10 Feb 2017 09:38:23 -0800
Message-ID: <1486748305-240339-8-git-send-email-shannon.nelson@oracle.com>
References: <1486748305-240339-1-git-send-email-shannon.nelson@oracle.com>
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org,
        Shannon Nelson <shannon.nelson@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:23272 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751989AbdBJRpK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 12:45:10 -0500
In-Reply-To: <1486748305-240339-1-git-send-email-shannon.nelson@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
index e54bc95..64671f0 100644
--- a/drivers/net/ethernet/sun/sunvnet_common.c
+++ b/drivers/net/ethernet/sun/sunvnet_common.c
@@ -1255,10 +1255,8 @@ int sunvnet_start_xmit_common(struct sk_buff *skb, struct net_device *dev,
 
 	rcu_read_lock();
 	port = vnet_tx_port(skb, dev);
-	if (unlikely(!port)) {
-		rcu_read_unlock();
+	if (unlikely(!port))
 		goto out_dropped;
-	}
 
 	if (skb_is_gso(skb) && skb->len > port->tsolen) {
 		err = vnet_handle_offloads(port, skb, vnet_tx_port);
@@ -1283,7 +1281,6 @@ int sunvnet_start_xmit_common(struct sk_buff *skb, struct net_device *dev,
 			fl4.saddr = ip_hdr(skb)->saddr;
 
 			rt = ip_route_output_key(dev_net(dev), &fl4);
-			rcu_read_unlock();
 			if (!IS_ERR(rt)) {
 				skb_dst_set(skb, &rt->dst);
 				icmp_send(skb, ICMP_DEST_UNREACH,
@@ -1443,8 +1440,7 @@ int sunvnet_start_xmit_common(struct sk_buff *skb, struct net_device *dev,
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
