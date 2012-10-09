From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/6] vxlan: minor output refactoring
Date: Tue, 09 Oct 2012 10:56:38 -0700
Message-ID: <20121009175714.462171246@vyatta.com>
References: <20121009175637.048993312@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:51693 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755392Ab2JISB2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2012 14:01:28 -0400
Content-Disposition: inline; filename=vxlan-dst.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move code to find destination to a small function.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/vxlan.c	2012-10-09 10:34:57.000000000 -0700
+++ b/drivers/net/vxlan.c	2012-10-09 10:48:56.546879617 -0700
@@ -621,6 +621,18 @@ static inline u8 vxlan_ecn_encap(u8 tos,
 	return INET_ECN_encapsulate(tos, inner);
 }
 
+static __be32 vxlan_find_dst(struct vxlan_dev *vxlan, struct sk_buff *skb)
+{
+	const struct ethhdr *eth = (struct ethhdr *) skb->data;
+	struct vxlan_fdb *f;
+
+	if (is_multicast_ether_addr(eth->h_dest) ||
+	    (f = vxlan_find_mac(vxlan, eth->h_dest)) == NULL)
+		return vxlan->gaddr;
+	else
+		return f->remote_ip;
+}
+
 /* Transmit local packets over Vxlan
  *
  * Outer IP header inherits ECN and DF from inner header.
@@ -632,13 +644,11 @@ static netdev_tx_t vxlan_xmit(struct sk_
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct rtable *rt;
-	const struct ethhdr *eth;
 	const struct iphdr *old_iph;
 	struct iphdr *iph;
 	struct vxlanhdr *vxh;
 	struct udphdr *uh;
 	struct flowi4 fl4;
-	struct vxlan_fdb *f;
 	unsigned int pkt_len = skb->len;
 	u32 hash;
 	__be32 dst;
@@ -646,21 +656,16 @@ static netdev_tx_t vxlan_xmit(struct sk_
 	__u8 tos, ttl;
 	int err;
 
+	dst = vxlan_find_dst(vxlan, skb);
+	if (!dst)
+		goto drop;
+
 	/* Need space for new headers (invalidates iph ptr) */
 	if (skb_cow_head(skb, VXLAN_HEADROOM))
 		goto drop;
 
-	eth = (void *)skb->data;
 	old_iph = ip_hdr(skb);
 
-	if (!is_multicast_ether_addr(eth->h_dest) &&
-	    (f = vxlan_find_mac(vxlan, eth->h_dest)))
-		dst = f->remote_ip;
-	else if (vxlan->gaddr) {
-		dst = vxlan->gaddr;
-	} else
-		goto drop;
-
 	ttl = vxlan->ttl;
 	if (!ttl && IN_MULTICAST(ntohl(dst)))
 		ttl = 1;
