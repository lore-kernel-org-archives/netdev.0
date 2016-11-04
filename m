From: Lance Richardson <lrichard@redhat.com>
Subject: [PATCH net] ipv4: update comment to document GSO fragmentation cases.
Date: Fri,  4 Nov 2016 12:22:38 -0400
Message-ID: <1478276558-10974-1-git-send-email-lrichard@redhat.com>
To: netdev@vger.kernel.org, shmulik.ladkani@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60278 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934743AbcKDQWk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 12:22:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a follow-up to commit eb96202f1e34 ("ipv4: allow local
fragmentation in ip_finish_output_gso()"), updating the comment
documenting cases in which fragmentation is needed for egress
GSO packets.

Suggested-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Signed-off-by: Lance Richardson <lrichard@redhat.com>
---
 net/ipv4/ip_output.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 4971401..c2dae40 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -244,12 +244,18 @@ static int ip_finish_output_gso(struct net *net, struct sock *sk,
 	if (skb_gso_validate_mtu(skb, mtu))
 		return ip_finish_output2(net, sk, skb);
 
-	/* Slowpath -  GSO segment length is exceeding the dst MTU.
+	/* Slowpath -  GSO segment length exceeds the egress MTU.
 	 *
-	 * This can happen in two cases:
-	 * 1) TCP GRO packet, DF bit not set
-	 * 2) skb arrived via virtio-net, we thus get TSO/GSO skbs directly
-	 * from host network stack.
+	 * This can happen in several cases:
+	 *  - Forwarding of a TCP GRO skb, when DF flag is not set.
+	 *  - Forwarding of an skb that arrived on a virtualization interface
+	 *    (virtio-net/vhost/tap) with TSO/GSO size set by other network
+	 *    stack.
+	 *  - Local GSO skb transmitted on an NETIF_F_TSO tunnel stacked over an
+	 *    interface with a smaller MTU.
+	 *  - Arriving GRO skb (or GSO skb in a virtualized environment) that is
+	 *    bridged to a NETIF_F_TSO tunnel stacked over an interface with an
+	 *    insufficent MTU.
 	 */
 	features = netif_skb_features(skb);
 	BUILD_BUG_ON(sizeof(*IPCB(skb)) > SKB_SGO_CB_OFFSET);
-- 
2.5.5
