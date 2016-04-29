From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH net 2/3] udp_offload: Set encapsulation before inner completes.
Date: Fri, 29 Apr 2016 15:28:07 -0700
Message-ID: <1461968887-4993-2-git-send-email-jarno@ovn.org>
References: <1461968887-4993-1-git-send-email-jarno@ovn.org>
Cc: jesse@kernel.org, jarno@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:58436 "EHLO
	slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751679AbcD3Bei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 21:34:38 -0400
Received: from relay6-d.mail.gandi.net (relay6-d.mail.gandi.net [217.70.183.198])
	by slow1-d.mail.gandi.net (Postfix) with ESMTP id 66CE7496597
	for <netdev@vger.kernel.org>; Sat, 30 Apr 2016 00:28:55 +0200 (CEST)
In-Reply-To: <1461968887-4993-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

UDP tunnel segmentation code relies on the inner offsets being set for
an UDP tunnel GSO packet.  The inner *_complete() functions will set
the inner offsets only if the encapsulation is set before calling
them, but udp_gro_complete() set it only after the inner *_complete()
functions were done.

Also, remove the setting of the inner_mac_header in udp_gro_complete()
as it was wrongly set to the beginning of the UDP tunnel header rather
than the inner MAC header.

Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
 net/ipv4/udp_offload.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 0ed2daf..e330c0e 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -399,6 +399,11 @@ int udp_gro_complete(struct sk_buff *skb, int nhoff)
 
 	uh->len = newlen;
 
+	/* Set encapsulation before calling into inner gro_complete() functions
+	 * to make them set up the inner offsets.
+	 */
+	skb->encapsulation = 1;
+
 	rcu_read_lock();
 
 	uo_priv = rcu_dereference(udp_offload_base);
@@ -421,9 +426,6 @@ int udp_gro_complete(struct sk_buff *skb, int nhoff)
 	if (skb->remcsum_offload)
 		skb_shinfo(skb)->gso_type |= SKB_GSO_TUNNEL_REMCSUM;
 
-	skb->encapsulation = 1;
-	skb_set_inner_mac_header(skb, nhoff + sizeof(struct udphdr));
-
 	return err;
 }
 
-- 
2.7.4
