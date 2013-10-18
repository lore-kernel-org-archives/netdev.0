From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: gso: send_check() & segment() cleanups
Date: Fri, 18 Oct 2013 13:13:27 -0700
Message-ID: <1382127207.3284.36.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33184 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013Ab3JRUN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 16:13:28 -0400
Received: by mail-pa0-f52.google.com with SMTP id kl14so5053932pab.25
        for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 13:13:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

inet_gso_segment() and inet_gso_send_check() are called by
skb_mac_gso_segment() under rcu lock, no need to use
rcu_read_lock() / rcu_read_unlock()

Avoid calling ip_hdr() twice per function.

We can use ip_send_check() helper.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/af_inet.c |   24 +++++++++++-------------
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
