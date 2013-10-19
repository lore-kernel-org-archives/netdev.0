From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/6] ipv4: gso: send_check() & segment() cleanups
Date: Sat, 19 Oct 2013 11:42:53 -0700
Message-ID: <1382208178-22347-2-git-send-email-edumazet@google.com>
References: <1382208178-22347-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Jerry Chu <hkchu@google.com>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f201.google.com ([209.85.223.201]:44822 "EHLO
	mail-ie0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342Ab3JSSt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 14:49:56 -0400
Received: by mail-ie0-f201.google.com with SMTP id u16so970546iet.0
        for <netdev@vger.kernel.org>; Sat, 19 Oct 2013 11:49:56 -0700 (PDT)
In-Reply-To: <1382208178-22347-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inet_gso_segment() and inet_gso_send_check() are called by
skb_mac_gso_segment() under rcu lock, no need to use
rcu_read_lock() / rcu_read_unlock()

Avoid calling ip_hdr() twice per function.

We can use ip_send_check() helper.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/af_inet.c | 24 +++++++++++-------------
 1 file changed, 11 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 35913fb..4f8cd4f 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1254,20 +1254,19 @@ static int inet_gso_send_check(struct sk_buff *skb)
 	if (ihl < sizeof(*iph))
 		goto out;
 
+	proto = iph->protocol;
+
+	/* Warning: after this point, iph might be no longer valid */
 	if (unlikely(!pskb_may_pull(skb, ihl)))
 		goto out;
-
 	__skb_pull(skb, ihl);
+
 	skb_reset_transport_header(skb);
-	iph = ip_hdr(skb);
-	proto = iph->protocol;
 	err = -EPROTONOSUPPORT;
 
-	rcu_read_lock();
 	ops = rcu_dereference(inet_offloads[proto]);
 	if (likely(ops && ops->callbacks.gso_send_check))
 		err = ops->callbacks.gso_send_check(skb);
-	rcu_read_unlock();
 
 out:
 	return err;
@@ -1305,23 +1304,23 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 	if (ihl < sizeof(*iph))
 		goto out;
 
+	id = ntohs(iph->id);
+	proto = iph->protocol;
+
+	/* Warning: after this point, iph might be no longer valid */
 	if (unlikely(!pskb_may_pull(skb, ihl)))
 		goto out;
+	__skb_pull(skb, ihl);
 
 	tunnel = !!skb->encapsulation;
 
-	__skb_pull(skb, ihl);
 	skb_reset_transport_header(skb);
-	iph = ip_hdr(skb);
-	id = ntohs(iph->id);
-	proto = iph->protocol;
+
 	segs = ERR_PTR(-EPROTONOSUPPORT);
 
-	rcu_read_lock();
 	ops = rcu_dereference(inet_offloads[proto]);
 	if (likely(ops && ops->callbacks.gso_segment))
 		segs = ops->callbacks.gso_segment(skb, features);
-	rcu_read_unlock();
 
 	if (IS_ERR_OR_NULL(segs))
 		goto out;
@@ -1339,8 +1338,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 			iph->id = htons(id++);
 		}
 		iph->tot_len = htons(skb->len - skb->mac_len);
-		iph->check = 0;
-		iph->check = ip_fast_csum(skb_network_header(skb), iph->ihl);
+		ip_send_check(iph);
 	} while ((skb = skb->next));
 
 out:
-- 
1.8.4
