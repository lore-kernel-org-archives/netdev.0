From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net] ipv4: fix reply_dst leakage on arp reply
Date: Thu,  1 Oct 2015 16:25:43 +0200
Message-ID: <7d4263830abc45f0a1cea8aebcbc7c56debb4270.1443709468.git.jbenc@redhat.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36061 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755799AbbJAO02 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2015 10:26:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are cases when the created metadata reply is not used. Ensure the
allocated memory is freed also in such cases.

Fixes: 63d008a4e9ee ("ipv4: send arp replies to the correct tunnel")
Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 net/ipv4/arp.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index f03db8b7abee..0c9c3482e419 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -312,7 +312,7 @@ static void arp_send_dst(int type, int ptype, __be32 dest_ip,
 	if (!skb)
 		return;
 
-	skb_dst_set(skb, dst);
+	skb_dst_set(skb, dst_clone(dst));
 	arp_xmit(skb);
 }
 
@@ -384,7 +384,7 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 	}
 
 	if (skb && !(dev->priv_flags & IFF_XMIT_DST_RELEASE))
-		dst = dst_clone(skb_dst(skb));
+		dst = skb_dst(skb);
 	arp_send_dst(ARPOP_REQUEST, ETH_P_ARP, target, dev, saddr,
 		     dst_hw, dev->dev_addr, NULL, dst);
 }
@@ -811,7 +811,7 @@ static int arp_process(struct sock *sk, struct sk_buff *skb)
 				} else {
 					pneigh_enqueue(&arp_tbl,
 						       in_dev->arp_parms, skb);
-					return 0;
+					goto out_free_dst;
 				}
 				goto out;
 			}
@@ -865,6 +865,8 @@ static int arp_process(struct sock *sk, struct sk_buff *skb)
 
 out:
 	consume_skb(skb);
+out_free_dst:
+	dst_release(reply_dst);
 	return 0;
 }
 
-- 
1.8.3.1
