From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH] [IPV6] XFRM: Fix connected socket to use transformation.
Date: Fri, 24 Aug 2007 19:08:38 +0900
Message-ID: <118795011877-git-send-email-nakam@linux-ipv6.org>
Cc: netdev@vger.kernel.org, Masahide NAKAMURA <nakam@linux-ipv6.org>,
	Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi025.linux-ipv6.org ([203.178.140.25]:44444 "EHLO
	triton.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1762442AbXHXKIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 06:08:40 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When XFRM policy and state are ready after TCP connection is started,
the traffic should be transformed immediately, however it does not
on IPv6 TCP.

It depends on a dst cache replacement policy with connected socket.
It seems that the replacement is always done for IPv4, however, on
IPv6 case it is done only when routing cookie is changed.

This patch fix that non-transformation dst can be changed to
transformation one.
This behavior is required by MIPv6 and improves IPv6 IPsec.

Signed-off-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 include/net/ip6_fib.h            |    2 ++
 net/ipv6/inet6_connection_sock.c |   34 ++++++++++++++++++++++++++++++++--
 2 files changed, 34 insertions(+), 2 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index c48ea87..85d6d9f 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -105,6 +105,8 @@ struct rt6_info
 	struct rt6key			rt6i_src;
 
 	u8				rt6i_protocol;
+
+	u32				rt6i_flow_cache_genid;
 };
 
 static inline struct inet6_dev *ip6_dst_idev(struct dst_entry *dst)
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 116f94a..f389322 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -139,6 +139,36 @@ void inet6_csk_addr2sockaddr(struct sock *sk, struct sockaddr * uaddr)
 
 EXPORT_SYMBOL_GPL(inet6_csk_addr2sockaddr);
 
+static inline
+void __inet6_csk_dst_store(struct sock *sk, struct dst_entry *dst,
+			   struct in6_addr *daddr, struct in6_addr *saddr)
+{
+	struct rt6_info *rt = (struct rt6_info *)dst;
+
+	__ip6_dst_store(sk, dst, daddr, saddr);
+	rt->rt6i_flow_cache_genid = atomic_read(&flow_cache_genid);
+}
+
+static inline
+struct dst_entry *__inet6_csk_dst_check(struct sock *sk, u32 cookie)
+{
+	struct dst_entry *dst;
+	struct rt6_info *rt;
+
+	dst = __sk_dst_check(sk, cookie);
+	if (!dst)
+		goto end;
+
+	rt = (struct rt6_info *)dst;
+	if (rt->rt6i_flow_cache_genid != atomic_read(&flow_cache_genid)) {
+		sk->sk_dst_cache = NULL;
+		dst_release(dst);
+		dst = NULL;
+	}
+ end:
+	return dst;
+}
+
 int inet6_csk_xmit(struct sk_buff *skb, int ipfragok)
 {
 	struct sock *sk = skb->sk;
@@ -166,7 +196,7 @@ int inet6_csk_xmit(struct sk_buff *skb, int ipfragok)
 		final_p = &final;
 	}
 
-	dst = __sk_dst_check(sk, np->dst_cookie);
+	dst = __inet6_csk_dst_check(sk, np->dst_cookie);
 
 	if (dst == NULL) {
 		int err = ip6_dst_lookup(sk, &dst, &fl);
@@ -186,7 +216,7 @@ int inet6_csk_xmit(struct sk_buff *skb, int ipfragok)
 			return err;
 		}
 
-		__ip6_dst_store(sk, dst, NULL, NULL);
+		__inet6_csk_dst_store(sk, dst, NULL, NULL);
 	}
 
 	skb->dst = dst_clone(dst);
-- 
1.4.4.2

