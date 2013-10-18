From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv6: gso: remove redundant locking
Date: Fri, 18 Oct 2013 14:43:55 -0700
Message-ID: <1382132635.3284.45.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:49736 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754884Ab3JRVn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 17:43:56 -0400
Received: by mail-pb0-f53.google.com with SMTP id up15so4355398pbc.40
        for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 14:43:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

ipv6_gso_send_check() and ipv6_gso_segment() are called by
skb_mac_gso_segment() under rcu lock, no need to use
rcu_read_lock() / rcu_read_unlock()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/ip6_offload.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index d82de72..b405fba 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -66,7 +66,6 @@ static int ipv6_gso_send_check(struct sk_buff *skb)
 	__skb_pull(skb, sizeof(*ipv6h));
 	err = -EPROTONOSUPPORT;
 
-	rcu_read_lock();
 	ops = rcu_dereference(inet6_offloads[
 		ipv6_gso_pull_exthdrs(skb, ipv6h->nexthdr)]);
 
@@ -74,7 +73,6 @@ static int ipv6_gso_send_check(struct sk_buff *skb)
 		skb_reset_transport_header(skb);
 		err = ops->callbacks.gso_send_check(skb);
 	}
-	rcu_read_unlock();
 
 out:
 	return err;
@@ -113,13 +111,12 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 	segs = ERR_PTR(-EPROTONOSUPPORT);
 
 	proto = ipv6_gso_pull_exthdrs(skb, ipv6h->nexthdr);
-	rcu_read_lock();
+
 	ops = rcu_dereference(inet6_offloads[proto]);
 	if (likely(ops && ops->callbacks.gso_segment)) {
 		skb_reset_transport_header(skb);
 		segs = ops->callbacks.gso_segment(skb, features);
 	}
-	rcu_read_unlock();
 
 	if (IS_ERR(segs))
 		goto out;
