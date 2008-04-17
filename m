From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][INET 1/2]: Drop the inet_inherit_port() call.
Date: Thu, 17 Apr 2008 19:59:38 +0400
Message-ID: <480773EA.2000302@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:43983 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751910AbYDQQBo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Apr 2008 12:01:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As I can see from the code, two places (tcp_v6_syn_recv_sock and
dccp_v6_request_recv_sock) that call this one already run with
BHs disabled, so it's safe to call __inet_inherit_port there.

Besides (in case I missed smth with code review) the calltrace
tcp_v6_syn_recv_sock
 `- tcp_v4_syn_recv_sock
     `- __inet_inherit_port
and the similar for DCCP are valid, but assumes BHs to be disabled.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/net/inet_hashtables.h |    7 -------
 net/dccp/ipv6.c               |    2 +-
 net/ipv6/tcp_ipv6.c           |    2 +-
 3 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 5525227..5ec91d8 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -235,13 +235,6 @@ static inline void __inet_inherit_port(struct sock *sk, struct sock *child)
 	spin_unlock(&head->lock);
 }
 
-static inline void inet_inherit_port(struct sock *sk, struct sock *child)
-{
-	local_bh_disable();
-	__inet_inherit_port(sk, child);
-	local_bh_enable();
-}
-
 extern void inet_put_port(struct sock *sk);
 
 extern void inet_listen_wlock(struct inet_hashinfo *hashinfo);
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index f8371c7..9b1129b 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -625,7 +625,7 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 	newinet->daddr = newinet->saddr = newinet->rcv_saddr = LOOPBACK4_IPV6;
 
 	__inet6_hash(newsk);
-	inet_inherit_port(sk, newsk);
+	__inet_inherit_port(sk, newsk);
 
 	return newsk;
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 231c4dd..715965f 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1534,7 +1534,7 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 #endif
 
 	__inet6_hash(newsk);
-	inet_inherit_port(sk, newsk);
+	__inet_inherit_port(sk, newsk);
 
 	return newsk;
 
-- 
1.5.3.4


