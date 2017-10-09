From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net] udp: fix bcast packet reception
Date: Mon,  9 Oct 2017 14:52:10 +0200
Message-ID: <66294c8d1c61bdf0bff23a6339a24b4483246caa.1507394363.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47297 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754215AbdJIMw5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 08:52:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit bc044e8db796 ("udp: perform source validation for
mcast early demux") does not take into account that broadcast packets
lands in the same code path and they need different checks for the
source address - notably, zero source address are valid for bcast
and invalid for mcast.

As a result, 2nd and later broadcast packets with 0 source address
landing to the same socket are dropped. This breaks dhcp servers.

Since we don't have stringent performance requirements for ingress
broadcast traffic, fix it by disabling UDP early demux such traffic.

Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Fixes: bc044e8db796 ("udp: perform source validation for mcast early demux")
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/udp.c | 14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 5676237d2b0f..e45177ceb0ee 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2240,20 +2240,16 @@ int udp_v4_early_demux(struct sk_buff *skb)
 	iph = ip_hdr(skb);
 	uh = udp_hdr(skb);
 
-	if (skb->pkt_type == PACKET_BROADCAST ||
-	    skb->pkt_type == PACKET_MULTICAST) {
+	if (skb->pkt_type == PACKET_MULTICAST) {
 		in_dev = __in_dev_get_rcu(skb->dev);
 
 		if (!in_dev)
 			return 0;
 
-		/* we are supposed to accept bcast packets */
-		if (skb->pkt_type == PACKET_MULTICAST) {
-			ours = ip_check_mc_rcu(in_dev, iph->daddr, iph->saddr,
-					       iph->protocol);
-			if (!ours)
-				return 0;
-		}
+		ours = ip_check_mc_rcu(in_dev, iph->daddr, iph->saddr,
+				       iph->protocol);
+		if (!ours)
+			return 0;
 
 		sk = __udp4_lib_mcast_demux_lookup(net, uh->dest, iph->daddr,
 						   uh->source, iph->saddr,
-- 
2.13.6
