From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next 1/2] ping: some cleanup for net/ipv4/ping.c
Date: Mon,  3 Jun 2013 13:55:58 +0800
Message-ID: <1370238959-32008-1-git-send-email-amwang@redhat.com>
Cc: Lorenzo Colitti <lorenzo@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32829 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751069Ab3FCF4K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jun 2013 01:56:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

1. add some missing #if IS_ENABLED(CONFIG_IPV6)
2. make ping_supported() bool
3. fix "%pI6c" format

Cc: Lorenzo Colitti <lorenzo@google.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/ipv4/ping.c |   18 ++++++++++++++----
 1 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 71f6ad0..8c92781 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -318,7 +318,7 @@ int ping_check_bind_addr(struct sock *sk, struct inet_sock *isk,
 			return -EINVAL;
 
 		pr_debug("ping_check_bind_addr(sk=%p,addr=%pI6c,port=%d)\n",
-			 sk, addr->sin6_addr.s6_addr, ntohs(addr->sin6_port));
+			 sk, &addr->sin6_addr, ntohs(addr->sin6_port));
 
 		addr_type = ipv6_addr_type(&addr->sin6_addr);
 		scoped = __ipv6_addr_needs_scope_id(addr_type);
@@ -444,10 +444,18 @@ EXPORT_SYMBOL_GPL(ping_bind);
  * Is this a supported type of ICMP message?
  */
 
-static inline int ping_supported(int family, int type, int code)
+static inline bool ping_supported(int family, int type, int code)
 {
-	return (family == AF_INET && type == ICMP_ECHO && code == 0) ||
-	       (family == AF_INET6 && type == ICMPV6_ECHO_REQUEST && code == 0);
+	if (family == AF_INET) {
+		if (type == ICMP_ECHO && code == 0)
+			return true;
+#if IS_ENABLED(CONFIG_IPV6)
+	} else if (family == AF_INET6) {
+		if (type == ICMPV6_ECHO_REQUEST && code == 0)
+			return true;
+#endif
+	}
+	return false;
 }
 
 /*
@@ -472,11 +480,13 @@ void ping_err(struct sk_buff *skb, int offset, u32 info)
 		type = icmp_hdr(skb)->type;
 		code = icmp_hdr(skb)->code;
 		icmph = (struct icmphdr *)(skb->data + offset);
+#if IS_ENABLED(CONFIG_IPV6)
 	} else if (skb->protocol == htons(ETH_P_IPV6)) {
 		family = AF_INET6;
 		type = icmp6_hdr(skb)->icmp6_type;
 		code = icmp6_hdr(skb)->icmp6_code;
 		icmph = (struct icmphdr *) (skb->data + offset);
+#endif
 	} else {
 		BUG();
 	}
-- 
1.7.7.6
