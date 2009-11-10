From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] vlan: GRO rx statistics
Date: Tue, 10 Nov 2009 17:52:32 +0100
Message-ID: <4AF99A50.5080301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38517 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757200AbZKJQwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 11:52:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems vlan interfaces with hardware-assisted VLAN reception 
dont have rx statistics.

Following patch cures the problem for me but I have no idea
if it is correct ?

Another problem about all rx stats is about multi rx queues devices.
Several cpus can access these counters in parallel ?


diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 8d5ca2a..e13b007 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -89,6 +89,11 @@ vlan_gro_common(struct napi_struct *napi, struct vlan_group *grp,
 	if (!skb->dev)
 		goto drop;
 
+	skb->dev->stats.rx_packets++;
+	skb->dev->stats.rx_bytes += skb->len;
+	if (skb->pkt_type == PACKET_MULTICAST)
+		skb->dev->stats.multicast++;
+
 	for (p = napi->gro_list; p; p = p->next) {
 		NAPI_GRO_CB(p)->same_flow =
 			p->dev == skb->dev && !compare_ether_header(
