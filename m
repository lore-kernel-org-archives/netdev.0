From: Lance Richardson <lrichard@redhat.com>
Subject: [PATCH net v2] ipv4: update comment to document GSO fragmentation cases.
Date: Wed,  9 Nov 2016 15:04:39 -0500
Message-ID: <1478721879-11033-1-git-send-email-lrichard@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37626 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751277AbcKIUEk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 15:04:40 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id EE328C04B945
        for <netdev@vger.kernel.org>; Wed,  9 Nov 2016 20:04:39 +0000 (UTC)
Received: from thinkcentre.redhat.com (ovpn-116-54.rdu2.redhat.com [10.10.116.54])
        by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id uA9K4d5x002740
        for <netdev@vger.kernel.org>; Wed, 9 Nov 2016 15:04:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a follow-up to commit 9ee6c5dc816a ("ipv4: allow local
fragmentation in ip_finish_output_gso()"), updating the comment
documenting cases in which fragmentation is needed for egress
GSO packets.

Suggested-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Reviewed-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Signed-off-by: Lance Richardson <lrichard@redhat.com>
---
v2: corrected commit ID (v1 used local commit ID by mistake)

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
