From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/8] inet: remove sk_listener parameter from syn_ack_timeout()
Date: Sun, 22 Mar 2015 10:22:19 -0700
Message-ID: <1427044945-32608-3-git-send-email-edumazet@google.com>
References: <1427044945-32608-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f202.google.com ([209.85.192.202]:32817 "EHLO
	mail-pd0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751795AbbCVRWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 13:22:44 -0400
Received: by pdbfl12 with SMTP id fl12so10052836pdb.0
        for <netdev@vger.kernel.org>; Sun, 22 Mar 2015 10:22:43 -0700 (PDT)
In-Reply-To: <1427044945-32608-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is not needed, and req->sk_listener points to the listener anyway.
request_sock argument can be const.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/dccp.h            | 2 +-
 include/net/request_sock.h      | 3 +--
 include/net/tcp.h               | 2 +-
 net/dccp/ipv4.c                 | 2 +-
 net/ipv4/inet_connection_sock.c | 2 +-
 net/ipv4/tcp_timer.c            | 8 +++++---
 6 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index 439ff698000a..3dca24d3ac67 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -317,6 +317,6 @@ static inline const char *dccp_role(const struct sock *sk)
 	return NULL;
 }
 
-extern void dccp_syn_ack_timeout(struct sock *sk, struct request_sock *req);
+extern void dccp_syn_ack_timeout(const struct request_sock *req);
 
 #endif /* _LINUX_DCCP_H */
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 6a91261d9b7b..8603c350fad0 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -39,8 +39,7 @@ struct request_sock_ops {
 	void		(*send_reset)(struct sock *sk,
 				      struct sk_buff *skb);
 	void		(*destructor)(struct request_sock *req);
-	void		(*syn_ack_timeout)(struct sock *sk,
-					   struct request_sock *req);
+	void		(*syn_ack_timeout)(const struct request_sock *req);
 };
 
 int inet_rtx_syn_ack(struct sock *parent, struct request_sock *req);
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 082fd79132b7..1876262afd59 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -433,7 +433,7 @@ int compat_tcp_getsockopt(struct sock *sk, int level, int optname,
 int compat_tcp_setsockopt(struct sock *sk, int level, int optname,
 			  char __user *optval, unsigned int optlen);
 void tcp_set_keepalive(struct sock *sk, int val);
-void tcp_syn_ack_timeout(struct sock *sk, struct request_sock *req);
+void tcp_syn_ack_timeout(const struct request_sock *req);
 int tcp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int nonblock,
 		int flags, int *addr_len);
 void tcp_parse_options(const struct sk_buff *skb,
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 25a9615b3b88..1f7161e05403 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -576,7 +576,7 @@ static void dccp_v4_reqsk_destructor(struct request_sock *req)
 	kfree(inet_rsk(req)->opt);
 }
 
-void dccp_syn_ack_timeout(struct sock *sk, struct request_sock *req)
+void dccp_syn_ack_timeout(const struct request_sock *req)
 {
 }
 EXPORT_SYMBOL(dccp_syn_ack_timeout);
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 7d011e825c48..a12b973164d0 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -615,7 +615,7 @@ static void reqsk_timer_handler(unsigned long data)
 		max_retries = defer_accept;
 	syn_ack_recalc(req, thresh, max_retries, defer_accept,
 		       &expire, &resend);
-	req->rsk_ops->syn_ack_timeout(sk_listener, req);
+	req->rsk_ops->syn_ack_timeout(req);
 	if (!expire &&
 	    (!resend ||
 	     !inet_rtx_syn_ack(sk_listener, req) ||
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 3daa6b5d766d..2568fd282873 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -327,7 +327,7 @@ static void tcp_fastopen_synack_timer(struct sock *sk)
 	struct request_sock *req;
 
 	req = tcp_sk(sk)->fastopen_rsk;
-	req->rsk_ops->syn_ack_timeout(sk, req);
+	req->rsk_ops->syn_ack_timeout(req);
 
 	if (req->num_timeout >= max_retries) {
 		tcp_write_err(sk);
@@ -539,9 +539,11 @@ static void tcp_write_timer(unsigned long data)
 	sock_put(sk);
 }
 
-void tcp_syn_ack_timeout(struct sock *sk, struct request_sock *req)
+void tcp_syn_ack_timeout(const struct request_sock *req)
 {
-	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPTIMEOUTS);
+	struct net *net = read_pnet(&inet_rsk(req)->ireq_net);
+
+	NET_INC_STATS_BH(net, LINUX_MIB_TCPTIMEOUTS);
 }
 EXPORT_SYMBOL(tcp_syn_ack_timeout);
 
-- 
2.2.0.rc0.207.ga3a616c
