From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv6: call consume_skb() in frag/reassembly
Date: Tue, 24 Apr 2012 22:17:59 +0200
Message-ID: <1335298679.5205.173.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:45065 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757174Ab2DXUSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 16:18:09 -0400
Received: by wgbds11 with SMTP id ds11so3820370wgb.1
        for <netdev@vger.kernel.org>; Tue, 24 Apr 2012 13:18:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Some kfree_skb() calls should be replaced by consume_skb() to avoid
drop_monitor/dropwatch false positives.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/ip6_output.c |    4 ++--
 net/ipv6/reassembly.c |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index b7ca461..b347062 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -210,7 +210,7 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 				kfree_skb(skb);
 				return -ENOBUFS;
 			}
-			kfree_skb(skb);
+			consume_skb(skb);
 			skb = skb2;
 			skb_set_owner_w(skb, sk);
 		}
@@ -889,7 +889,7 @@ slow_path:
 	}
 	IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
 		      IPSTATS_MIB_FRAGOKS);
-	kfree_skb(skb);
+	consume_skb(skb);
 	return err;
 
 fail:
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 36e04cf..54c5d2b 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -433,7 +433,7 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 		skb_morph(head, fq->q.fragments);
 		head->next = fq->q.fragments->next;
 
-		kfree_skb(fq->q.fragments);
+		consume_skb(fq->q.fragments);
 		fq->q.fragments = head;
 	}
 
