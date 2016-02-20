From: Francesco Ruggeri <fruggeri@arista.com>
Subject: [PATCH 1/1] net-next: do not store needed_headroom in ip_tunnel_xmit
Date: Fri, 19 Feb 2016 20:26:14 -0800
Message-ID: <1455942374-17650-1-git-send-email-fruggeri@arista.com>
To: Francesco Ruggeri <fruggeri@arista.com>, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mx.aristanetworks.com ([162.210.130.12]:61363 "EHLO
	prod-mx.aristanetworks.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S2992772AbcBTEdD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 23:33:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Misconfigurations can result in local tunnel loops being created.
__dev_queue_xmit catches packets caught in a loop and drops them,
but the affected tunnels' needed_headroom can be corrupted in the
process as it is recursively updated.
The script below can be used to create a loop between two tunnels
and to send packets.

ip link add dummy1 type dummy
ip addr add 1.1.1.1/32 dev dummy1
ip link set dummy1 up

ip link add dummy3 type dummy
ip addr add 3.3.3.3/32 dev dummy3
ip link set dummy3 up

ip tunnel add t1 mode gre local 1.1.1.1 remote 2.2.2.2
ip link set t1 up

ip tunnel add t3 mode gre local 3.3.3.3 remote 4.4.4.4
ip link set t3 up

ip route add 2.2.2.2 dev t3
ip route add 4.4.4.4 dev t1

ping -c 5 2.2.2.2

Signed-off-by: Francesco Ruggeri <fruggeri@arista.com>
---
 net/ipv4/ip_tunnel.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 4569da7..2eddbe3 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -601,6 +601,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 	__be16 df;
 	struct rtable *rt;		/* Route to the other host */
 	unsigned int max_headroom;	/* The extra header space needed */
+	unsigned int needed_headroom;
 	__be32 dst;
 	bool connected;
 
@@ -731,10 +732,11 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 
 	max_headroom = LL_RESERVED_SPACE(rt->dst.dev) + sizeof(struct iphdr)
 			+ rt->dst.header_len + ip_encap_hlen(&tunnel->encap);
-	if (max_headroom > dev->needed_headroom)
-		dev->needed_headroom = max_headroom;
+	needed_headroom = dev->needed_headroom;
+	if (max_headroom > needed_headroom)
+		needed_headroom = max_headroom;
 
-	if (skb_cow_head(skb, dev->needed_headroom)) {
+	if (skb_cow_head(skb, needed_headroom)) {
 		ip_rt_put(rt);
 		dev->stats.tx_dropped++;
 		kfree_skb(skb);
-- 
1.8.1.4
