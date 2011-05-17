From: John <linux@8192.net>
Subject: [PATCH] IPv6 transmit hashing for bonding driver
Date: Tue, 17 May 2011 16:55:30 -0700
Message-ID: <4DD30AF2.1090707@8192.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp151.dfw.emailsrvr.com ([67.192.241.151]:60264 "EHLO
	smtp151.dfw.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932369Ab1ERAFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 20:05:10 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by smtp5.relay.dfw1a.emailsrvr.com (SMTP Server) with ESMTP id B2524585D6
	for <netdev@vger.kernel.org>; Tue, 17 May 2011 19:55:28 -0400 (EDT)
Received: by smtp5.relay.dfw1a.emailsrvr.com (Authenticated sender: john-AT-8192.net) with ESMTPSA id 6F821585C8
	for <netdev@vger.kernel.org>; Tue, 17 May 2011 19:55:28 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the "bonding" driver does not support load balancing outgoing traffic in LACP mode for IPv6 traffic. IPv4 (and 
TCP over IPv4) are currently supported; this patch adds transmit hashing for IPv6 (and TCP over IPv6), bringing IPv6 up 
to par with IPv4 support in the bonding driver.

The algorithm chosen (xor'ing the bottom three quads and then xor'ing that down into the bottom byte) was chosen after 
testing almost 400,000 unique IPv6 addresses harvested from server logs. This algorithm had the most even distribution 
for both big- and little-endian architectures while still using few instructions.

This patch also adds missing configuration information the MODULE_PARM_DESC.

Patch has been tested on various machines and performs as expected. Thanks to Stephen Hemminger and Andy Gospodarek for 
advice and guidance.

John

--- drivers/net/bonding/bond_main.c.orig	2011-04-18 17:23:09.202894000 -0700
+++ drivers/net/bonding/bond_main.c	2011-04-19 18:12:30.287929000 -0700
@@ -152,7 +152,7 @@
  MODULE_PARM_DESC(ad_select, "803.ad aggregation selection logic: stable (0, default), bandwidth (1), count (2)");
  module_param(xmit_hash_policy, charp, 0);
  MODULE_PARM_DESC(xmit_hash_policy, "XOR hashing method: 0 for layer 2 (default)"
-				   ", 1 for layer 3+4");
+				   ", 1 for layer 3+4, 2 for layer 2+3");
  module_param(arp_interval, int, 0);
  MODULE_PARM_DESC(arp_interval, "arp interval in milliseconds");
  module_param_array(arp_ip_target, charp, NULL, 0);
@@ -3720,11 +3720,20 @@
  static int bond_xmit_hash_policy_l23(struct sk_buff *skb, int count)
  {
  	struct ethhdr *data = (struct ethhdr *)skb->data;
-	struct iphdr *iph = ip_hdr(skb);

  	if (skb->protocol == htons(ETH_P_IP)) {
+		struct iphdr *iph = ip_hdr(skb);
  		return ((ntohl(iph->saddr ^ iph->daddr) & 0xffff) ^
  			(data->h_dest[5] ^ data->h_source[5])) % count;
+	} else if (skb->protocol == htons(ETH_P_IPV6)) {
+		struct ipv6hdr *ipv6h = ipv6_hdr(skb);
+		u32 v6hash = (
+			(ipv6h->saddr.s6_addr32[1] ^ ipv6h->daddr.s6_addr32[1]) ^
+			(ipv6h->saddr.s6_addr32[2] ^ ipv6h->daddr.s6_addr32[2]) ^
+			(ipv6h->saddr.s6_addr32[3] ^ ipv6h->daddr.s6_addr32[3])
+		);
+		v6hash = (v6hash >> 16) ^ (v6hash >> 8) ^ v6hash;
+		return (v6hash ^ data->h_dest[5] ^ data->h_source[5]) % count;
  	}

  	return (data->h_dest[5] ^ data->h_source[5]) % count;
@@ -3738,11 +3747,11 @@
  static int bond_xmit_hash_policy_l34(struct sk_buff *skb, int count)
  {
  	struct ethhdr *data = (struct ethhdr *)skb->data;
-	struct iphdr *iph = ip_hdr(skb);
-	__be16 *layer4hdr = (__be16 *)((u32 *)iph + iph->ihl);
-	int layer4_xor = 0;
+	u32 layer4_xor = 0;

  	if (skb->protocol == htons(ETH_P_IP)) {
+		struct iphdr *iph = ip_hdr(skb);
+		__be16 *layer4hdr = (__be16 *)((u32 *)iph + iph->ihl);
  		if (!(iph->frag_off & htons(IP_MF|IP_OFFSET)) &&
  		    (iph->protocol == IPPROTO_TCP ||
  		     iph->protocol == IPPROTO_UDP)) {
@@ -3750,7 +3759,18 @@
  		}
  		return (layer4_xor ^
  			((ntohl(iph->saddr ^ iph->daddr)) & 0xffff)) % count;
-
+	} else if (skb->protocol == htons(ETH_P_IPV6)) {
+		struct ipv6hdr *ipv6h = ipv6_hdr(skb);
+		__be16 *layer4hdrv6 = (__be16 *)((u8 *)ipv6h + sizeof(*ipv6h));
+		if (ipv6h->nexthdr == IPPROTO_TCP || ipv6h->nexthdr == IPPROTO_UDP) {
+			layer4_xor = (*layer4hdrv6 ^ *(layer4hdrv6 + 1));
+		}
+		layer4_xor ^= (
+			(ipv6h->saddr.s6_addr32[1] ^ ipv6h->daddr.s6_addr32[1]) ^
+			(ipv6h->saddr.s6_addr32[2] ^ ipv6h->daddr.s6_addr32[2]) ^
+			(ipv6h->saddr.s6_addr32[3] ^ ipv6h->daddr.s6_addr32[3])
+		);
+		return ((layer4_xor >> 16) ^ (layer4_xor >> 8) ^ layer4_xor) % count;
  	}

  	return (data->h_dest[5] ^ data->h_source[5]) % count;

