From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 5/6] vxlan: compute source port in network byte order
Date: Sat, 27 Apr 2013 14:31:56 -0700
Message-ID: <20130427213258.458048173@vyatta.com>
References: <20130427213151.255971631@vyatta.com>
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:52168 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753521Ab3D0Vqg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Apr 2013 17:46:36 -0400
Content-Disposition: inline; filename=vxlan-src-port-be16.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than computing source port and returning it in host order
then swapping later, go ahead and compute it in network order to
start with. Cleaner and less error prone.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/drivers/net/vxlan.c	2013-04-27 13:59:41.000000000 -0700
+++ b/drivers/net/vxlan.c	2013-04-27 14:04:28.776531047 -0700
@@ -896,7 +896,7 @@ static void vxlan_set_owner(struct net_d
  *     better and maybe available from hardware
  *   secondary choice is to use jhash on the Ethernet header
  */
-static u16 vxlan_src_port(const struct vxlan_dev *vxlan, struct sk_buff *skb)
+static __be16 vxlan_src_port(const struct vxlan_dev *vxlan, struct sk_buff *skb)
 {
 	unsigned int range = (vxlan->port_max - vxlan->port_min) + 1;
 	u32 hash;
@@ -906,7 +906,7 @@ static u16 vxlan_src_port(const struct v
 		hash = jhash(skb->data, 2 * ETH_ALEN,
 			     (__force u32) skb->protocol);
 
-	return (((u64) hash * range) >> 32) + vxlan->port_min;
+	return htons((((u64) hash * range) >> 32) + vxlan->port_min);
 }
 
 static int handle_offloads(struct sk_buff *skb)
@@ -965,8 +965,7 @@ static netdev_tx_t vxlan_xmit_one(struct
 	struct udphdr *uh;
 	struct flowi4 fl4;
 	__be32 dst;
-	__u16 src_port;
-	__be16 dst_port;
+	__be16 src_port, dst_port;
         u32 vni;
 	__be16 df = 0;
 	__u8 tos, ttl;
@@ -1053,7 +1052,7 @@ static netdev_tx_t vxlan_xmit_one(struct
 	uh = udp_hdr(skb);
 
 	uh->dest = dst_port;
-	uh->source = htons(src_port);
+	uh->source = src_port;
 
 	uh->len = htons(skb->len);
 	uh->check = 0;
