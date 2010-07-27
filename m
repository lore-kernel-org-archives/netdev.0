From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH v2] macvlan: Fix rx counters update in
 macvlan_handle_frame()
Date: Tue, 27 Jul 2010 12:10:07 -0700
Message-ID: <1280257807.27059.4.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:32828 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750858Ab0G0TKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 15:10:24 -0400
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6RJ3G1j020089
	for <netdev@vger.kernel.org>; Tue, 27 Jul 2010 13:03:16 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6RJAAKi126354
	for <netdev@vger.kernel.org>; Tue, 27 Jul 2010 13:10:11 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6RJA822025429
	for <netdev@vger.kernel.org>; Tue, 27 Jul 2010 13:10:09 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix macvlan_handle_frame() to update the rx counters based
on the return value of the vlan->receive call.

Updated the patch to not do any packet count drops when the interface
is down based on Herber'ts comments.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 87e8d4c..bcb1b36 100644
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
@@ -188,14 +189,16 @@ static struct sk_buff *macvlan_handle_frame(struct macvlan_port *port,
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
 


