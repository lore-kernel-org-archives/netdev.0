From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH] macvlan: Fix rx counters update in macvlan_handle_frame()
Date: Thu, 22 Jul 2010 16:04:27 -0700
Message-ID: <1279839867.3274.25.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, kaber@trash.net,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:45683 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752562Ab0GVXEa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jul 2010 19:04:30 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6MN2Md2015801
	for <netdev@vger.kernel.org>; Thu, 22 Jul 2010 19:02:23 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6MN4Ti92293922
	for <netdev@vger.kernel.org>; Thu, 22 Jul 2010 19:04:29 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6MN4SXa002061
	for <netdev@vger.kernel.org>; Thu, 22 Jul 2010 19:04:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix macvlan_handle_frame() to update the rx counters based
on the return value of the vlan->receive call.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 87e8d4c..2732df1 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -152,7 +152,8 @@ static struct sk_buff *macvlan_handle_frame(struct macvlan_port *port,
 	const struct macvlan_dev *vlan;
 	const struct macvlan_dev *src;
 	struct net_device *dev;
-	unsigned int len;
+	unsigned int len = 0;
+	int ret = NET_RX_DROP;
 
 	if (is_multicast_ether_addr(eth->h_dest)) {
 		src = macvlan_hash_lookup(port, eth->h_source);
@@ -184,18 +185,20 @@ static struct sk_buff *macvlan_handle_frame(struct macvlan_port *port,
 	dev = vlan->dev;
 	if (unlikely(!(dev->flags & IFF_UP))) {
 		kfree_skb(skb);
-		return NULL;
+		goto out;
 	}
 	len = skb->len + ETH_HLEN;
 	skb = skb_share_check(skb, GFP_ATOMIC);
-	macvlan_count_rx(vlan, len, skb != NULL, 0);
 	if (!skb)
-		return NULL;
+		goto out;
 
 	skb->dev = dev;
 	skb->pkt_type = PACKET_HOST;
 
-	vlan->receive(skb);
+	ret = vlan->receive(skb);
+
+out:
+	macvlan_count_rx(vlan, len, ret == NET_RX_SUCCESS, 0);
 	return NULL;
 }
 


