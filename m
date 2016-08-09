From: wenxu@ucloud.cn
Subject: [PATCH] net: ip_finish_output_gso: If skb_gso_network_seglen exceeds MTU, allow segmentation for gre tunneled skbs
Date: Tue,  9 Aug 2016 15:04:21 +0800
Message-ID: <1470726261-16371-1-git-send-email-wenxu@ucloud.cn>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	kaber@trash.net, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	shmulik.ladkani@gmail.com, wenx05124561@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50149.mail.qiye.163.com ([123.125.50.149]:61890 "EHLO
	m50149.mail.qiye.163.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752240AbcHIHX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 03:23:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: wenxu <wenxu@ucloud.cn>

commit b8247f095edd ("net: ip_finish_output_gso: If skb_gso_network_seglen
exceeds MTU, allow segmentation for local udp tunneled skbs")

Given:
     - tap0 and ovs-gre
     - ovs-gre stacked on eth0, eth0 having the small mtu

After encapsulation these skbs have skb_gso_network_seglen that exceed
eth0's ip_skb_dst_mtu. So the finnal each segment would be larger than
eth0 mtu. These packets maybe dropped.

It has the same problem if tap0 bridge with ipgre or gretap device. So
the IPSKB_FRAG_SEGS flags should also be set in gre tunneled skbs.

Signed-off-by: wenxu <wenxu@ucloud.cn>
---
 net/ipv4/ip_tunnel_core.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 9d847c3..7f36ea2 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -73,8 +73,9 @@ void iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
 	skb_dst_set(skb, &rt->dst);
 	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
 
-	if (skb_iif && proto == IPPROTO_UDP) {
-		/* Arrived from an ingress interface and got udp encapuslated.
+	if (skb_iif && (proto == IPPROTO_UDP || proto == IPPROTO_GRE)) {
+		/* Arrived from an ingress interface and got udp or gre
+		 * encapsulated.
 		 * The encapsulated network segment length may exceed dst mtu.
 		 * Allow IP Fragmentation of segments.
 		 */
-- 
1.8.3.1
