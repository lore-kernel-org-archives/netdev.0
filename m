From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next] udp: clear rps flow table for packets recv on UDP
 unconnected sockets
Date: Sat, 9 Aug 2014 09:51:23 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1408090943160.16111@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: eric.dumazet@gmail.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f201.google.com ([209.85.192.201]:38415 "EHLO
	mail-pd0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821AbaHIQvY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Aug 2014 12:51:24 -0400
Received: by mail-pd0-f201.google.com with SMTP id g10so1738870pdj.4
        for <netdev@vger.kernel.org>; Sat, 09 Aug 2014 09:51:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch addresses a problem posed by Eric Dumazet in RPS/RFS
concerning the interaction between connected sockets and traffic on
unnconnected sockets.

On a server which has both traffic using connected connected sockets
and traffic that is going through unconnected UDP sockets, it is
very possible that the connected sockets could heavily populate the
RPS flow tables. Packets received on unconnected sockets would then
be steered based on unrelated entries in the flow tables which leads
to suboptimal steering. This happens even if the connections that
populate the table are inactive with no traffic, as long as the
connected sockets simply remain open unrelated traffic can be steered
using that information. This problem would further be exacerbated
if the packets on the unconnected UDP sockets are actually part of
long lived flows (which apparently would happen with QUIC in their
current implementation).

This patch clears the RPS flow hash table for packet recieved on
unnconnected UDP sockets. The effect is that the "flows" on unconnected
socekts will be steered using RPS. We don't do this for unconnected UDP
tunnels (encap_rcv) under the assumption that the flow table entries
will be adjusted during processing of inner packets.

Tested using super_netperf UDP_RR with 200 flows. Did not see any
noticeable regression in writing to flow table for every packet.

Before fix:
  76.99% CPU utilization
  112/158/230 90/95/99% latencies
  1.62776e+06 tps

After fix:
  76.03% CPU utilization
  115/162/239 90/95/99% latencies
  1.62257e+06 tps

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/udp.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index f57c0e4..8778bec 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1444,6 +1444,8 @@ static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	if (inet_sk(sk)->inet_daddr) {
 		sock_rps_save_rxhash(sk, skb);
 		sk_mark_napi_id(sk, skb);
+	} else {
+		sock_rps_reset_flow_hash(skb->rxhash);
 	}
 
 	rc = sock_queue_rcv_skb(sk, skb);
-- 
2.0.0.526.g5318336
