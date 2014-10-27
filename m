From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 2/2] udp: Reset flow table for flows over unconnected sockets
Date: Mon, 27 Oct 2014 11:01:15 -0700
Message-ID: <1414432875-23795-2-git-send-email-therbert@google.com>
References: <1414432875-23795-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:39597 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751720AbaJ0SCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2014 14:02:14 -0400
Received: by mail-pd0-f172.google.com with SMTP id r10so6141023pdi.3
        for <netdev@vger.kernel.org>; Mon, 27 Oct 2014 11:02:14 -0700 (PDT)
In-Reply-To: <1414432875-23795-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When receiving a packet on an unconnected UDP socket clear the
flow table for the corresponding hash. This is needed so flows over
unconnected UDP sockets will use RPS instead of using what is
present in the flow table. In particular, this avoids having flows
over unconnected sockets be perpetually steered by unrelated
entries in the flow table (idle TCP connections for instance).

Tested:

First filled up the RPS flow tables by creating a bunch of TCP
connections and letting them turn idle. Next, run netperf UDP_RR
with 200 flows.

Before fix:
  Client (connected UDP)
    81.15% CPU uilization
  Server (unneconnedted UDP)
    83.63% CPU uilization
  118/167/249 90/95/99% latencies
  1.59215e+06 tps

After fix:
  Client (connected UDP)
    81.13% CPU uilization
  Server (unneconnedted UDP)
    80.68% CPU uilization
  116/167/248 90/95/99% latencies
  1.61048e+06 tps

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/udp.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 9a0d346..e58d841 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1451,6 +1451,11 @@ static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	if (inet_sk(sk)->inet_daddr) {
 		sock_rps_save_rxhash(sk, skb);
 		sk_mark_napi_id(sk, skb);
+	} else {
+		/* For an unconnected socket reset flow hash so that related
+		 * flow will use RPS.
+		 */
+		sock_rps_reset_flow_hash(skb->hash);
 	}
 
 	rc = sock_queue_rcv_skb(sk, skb);
-- 
2.1.0.rc2.206.gedb03e5
