From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net v2] ipv4: fix broadcast packets reception
Date: Tue, 22 Mar 2016 09:19:38 +0100
Message-ID: <c8ad97bbb6f1c9ec8c523209c1203d1982faab6f.1458634653.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50915 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757845AbcCVIVA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2016 04:21:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, ingress ipv4 broadcast datagrams are dropped since,
in udp_v4_early_demux(), ip_check_mc_rcu() is invoked even on
bcast packets.

This patch addresses the issue, invoking ip_check_mc_rcu()
only for mcast packets.

Fixes: 6e5403093261 ("ipv4/udp: Verify multicast group is ours in upd_v4_early_demux()")
Signed-off-by: Paolo Abeni <pabeni@redhat.com>

--
 v1 -> v2 droped the route related bits, the fib_validate_source()
  failures are triggered by the in_device configuration
---
 net/ipv4/udp.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 836abe5..08eed5e 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2070,10 +2070,14 @@ void udp_v4_early_demux(struct sk_buff *skb)
 		if (!in_dev)
 			return;
 
-		ours = ip_check_mc_rcu(in_dev, iph->daddr, iph->saddr,
-				       iph->protocol);
-		if (!ours)
-			return;
+		/* we are supposed to accept bcast packets */
+		if (skb->pkt_type == PACKET_MULTICAST) {
+			ours = ip_check_mc_rcu(in_dev, iph->daddr, iph->saddr,
+					       iph->protocol);
+			if (!ours)
+				return;
+		}
+
 		sk = __udp4_lib_mcast_demux_lookup(net, uh->dest, iph->daddr,
 						   uh->source, iph->saddr, dif);
 	} else if (skb->pkt_type == PACKET_HOST) {
-- 
1.8.3.1
