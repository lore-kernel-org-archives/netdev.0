From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 01/14] tcp/dccp: constify send_synack and send_reset socket argument
Date: Tue, 29 Sep 2015 07:42:39 -0700
Message-ID: <1443537772-15305-2-git-send-email-edumazet@google.com>
References: <1443537772-15305-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33715 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755091AbbI2OnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 10:43:12 -0400
Received: by pacex6 with SMTP id ex6so8402020pac.0
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 07:43:11 -0700 (PDT)
In-Reply-To: <1443537772-15305-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

None of these functions need to change the socket, make it
const.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/request_sock.h |  4 ++--
 net/dccp/dccp.h            |  2 +-
 net/dccp/ipv4.c            |  2 +-
 net/dccp/ipv6.c            |  2 +-
 net/dccp/minisocks.c       |  2 +-
 net/ipv4/tcp_ipv4.c        |  4 ++--
 net/ipv6/tcp_ipv6.c        | 12 ++++++------
 7 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 181f97f9fe1c..90247ec7955b 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -34,9 +34,9 @@ struct request_sock_ops {
 	char		*slab_name;
 	int		(*rtx_syn_ack)(const struct sock *sk,
 				       struct request_sock *req);
-	void		(*send_ack)(struct sock *sk, struct sk_buff *skb,
+	void		(*send_ack)(const struct sock *sk, struct sk_buff *skb,
 				    struct request_sock *req);
-	void		(*send_reset)(struct sock *sk,
+	void		(*send_reset)(const struct sock *sk,
 				      struct sk_buff *skb);
 	void		(*destructor)(struct request_sock *req);
 	void		(*syn_ack_timeout)(const struct request_sock *req);
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 31e96df500d1..8ed1df2771bd 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -229,7 +229,7 @@ void dccp_v4_send_check(struct sock *sk, struct sk_buff *skb);
 int dccp_retransmit_skb(struct sock *sk);
 
 void dccp_send_ack(struct sock *sk);
-void dccp_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
+void dccp_reqsk_send_ack(const struct sock *sk, struct sk_buff *skb,
 			 struct request_sock *rsk);
 
 void dccp_send_sync(struct sock *sk, const u64 seq,
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index a46ae9c69ccf..00a14fa4270a 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -527,7 +527,7 @@ out:
 	return err;
 }
 
-static void dccp_v4_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
+static void dccp_v4_ctl_send_reset(const struct sock *sk, struct sk_buff *rxskb)
 {
 	int err;
 	const struct iphdr *rxiph;
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 4fa199dc69a3..aa719e700961 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -234,7 +234,7 @@ static void dccp_v6_reqsk_destructor(struct request_sock *req)
 	kfree_skb(inet_rsk(req)->pktopts);
 }
 
-static void dccp_v6_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
+static void dccp_v6_ctl_send_reset(const struct sock *sk, struct sk_buff *rxskb)
 {
 	const struct ipv6hdr *rxip6h;
 	struct sk_buff *skb;
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index 838f524cf11a..9bfd0dc1e6cb 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -236,7 +236,7 @@ int dccp_child_process(struct sock *parent, struct sock *child,
 
 EXPORT_SYMBOL_GPL(dccp_child_process);
 
-void dccp_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
+void dccp_reqsk_send_ack(const struct sock *sk, struct sk_buff *skb,
 			 struct request_sock *rsk)
 {
 	DCCP_BUG("DCCP-ACK packets are never sent in LISTEN/RESPOND state");
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a23ba7daecbf..4300d0132b9f 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -576,7 +576,7 @@ EXPORT_SYMBOL(tcp_v4_send_check);
  *	Exception: precedence violation. We do not implement it in any case.
  */
 
-static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
+static void tcp_v4_send_reset(const struct sock *sk, struct sk_buff *skb)
 {
 	const struct tcphdr *th = tcp_hdr(skb);
 	struct {
@@ -795,7 +795,7 @@ static void tcp_v4_timewait_ack(struct sock *sk, struct sk_buff *skb)
 	inet_twsk_put(tw);
 }
 
-static void tcp_v4_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
+static void tcp_v4_reqsk_send_ack(const struct sock *sk, struct sk_buff *skb,
 				  struct request_sock *req)
 {
 	/* sk->sk_state == TCP_LISTEN -> for regular TCP_SYN_RECV
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 16fb299dcab8..c47e5c87a2a8 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -70,8 +70,8 @@
 #include <linux/crypto.h>
 #include <linux/scatterlist.h>
 
-static void	tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb);
-static void	tcp_v6_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
+static void	tcp_v6_send_reset(const struct sock *sk, struct sk_buff *skb);
+static void	tcp_v6_reqsk_send_ack(const struct sock *sk, struct sk_buff *skb,
 				      struct request_sock *req);
 
 static int	tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb);
@@ -724,7 +724,7 @@ static const struct tcp_request_sock_ops tcp_request_sock_ipv6_ops = {
 	.queue_hash_add =	inet6_csk_reqsk_queue_hash_add,
 };
 
-static void tcp_v6_send_response(struct sock *sk, struct sk_buff *skb, u32 seq,
+static void tcp_v6_send_response(const struct sock *sk, struct sk_buff *skb, u32 seq,
 				 u32 ack, u32 win, u32 tsval, u32 tsecr,
 				 int oif, struct tcp_md5sig_key *key, int rst,
 				 u8 tclass, u32 label)
@@ -823,7 +823,7 @@ static void tcp_v6_send_response(struct sock *sk, struct sk_buff *skb, u32 seq,
 	kfree_skb(buff);
 }
 
-static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
+static void tcp_v6_send_reset(const struct sock *sk, struct sk_buff *skb)
 {
 	const struct tcphdr *th = tcp_hdr(skb);
 	u32 seq = 0, ack_seq = 0;
@@ -894,7 +894,7 @@ release_sk1:
 #endif
 }
 
-static void tcp_v6_send_ack(struct sock *sk, struct sk_buff *skb, u32 seq,
+static void tcp_v6_send_ack(const struct sock *sk, struct sk_buff *skb, u32 seq,
 			    u32 ack, u32 win, u32 tsval, u32 tsecr, int oif,
 			    struct tcp_md5sig_key *key, u8 tclass,
 			    u32 label)
@@ -917,7 +917,7 @@ static void tcp_v6_timewait_ack(struct sock *sk, struct sk_buff *skb)
 	inet_twsk_put(tw);
 }
 
-static void tcp_v6_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
+static void tcp_v6_reqsk_send_ack(const struct sock *sk, struct sk_buff *skb,
 				  struct request_sock *req)
 {
 	/* sk->sk_state == TCP_LISTEN -> for regular TCP_SYN_RECV
-- 
2.6.0.rc2.230.g3dd15c0
