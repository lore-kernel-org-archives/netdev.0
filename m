From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 7/7] inet: introduce ireq_family
Date: Thu, 12 Mar 2015 14:50:16 -0700
Message-ID: <1426197016-14482-8-git-send-email-edumazet@google.com>
References: <1426197016-14482-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f202.google.com ([209.85.214.202]:33663 "EHLO
	mail-ob0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932180AbbCLVv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 17:51:28 -0400
Received: by obbnt9 with SMTP id nt9so4920701obb.0
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 14:51:28 -0700 (PDT)
In-Reply-To: <1426197016-14482-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before inserting request socks into general hash table,
fill their socket family.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_sock.h | 1 +
 net/dccp/ipv4.c         | 1 +
 net/dccp/ipv6.c         | 1 +
 net/ipv4/inet_diag.c    | 2 +-
 net/ipv4/syncookies.c   | 1 +
 net/ipv4/tcp_ipv4.c     | 1 +
 net/ipv6/syncookies.c   | 1 +
 net/ipv6/tcp_ipv6.c     | 1 +
 8 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index dd8a8e37fa9e..24b84a5c6ae9 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -81,6 +81,7 @@ struct inet_request_sock {
 #define ireq_net		req.__req_common.skc_net
 #define ireq_state		req.__req_common.skc_state
 #define ireq_refcnt		req.__req_common.skc_refcnt
+#define ireq_family		req.__req_common.skc_family
 
 	kmemcheck_bitfield_begin(flags);
 	u16			snd_wscale : 4,
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index af839396b714..a7f9baf12688 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -643,6 +643,7 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	ireq->ir_rmt_addr = ip_hdr(skb)->saddr;
 	write_pnet(&ireq->ireq_net, sock_net(sk));
 	ireq->ireq_state = TCP_NEW_SYN_RECV;
+	ireq->ireq_family = AF_INET;
 	atomic64_set(&ireq->ir_cookie, 0);
 
 	/*
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 8febaeb12f6d..5531e282da8f 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -405,6 +405,7 @@ static int dccp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	ireq->ir_v6_loc_addr = ipv6_hdr(skb)->daddr;
 	write_pnet(&ireq->ireq_net, sock_net(sk));
 	ireq->ireq_state = TCP_NEW_SYN_RECV;
+	ireq->ireq_family = AF_INET6;
 	atomic64_set(&ireq->ir_cookie, 0);
 
 	if (ipv6_opt_accepted(sk, skb, IP6CB(skb)) ||
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index c55a6fa3162d..43789c99031f 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -728,7 +728,7 @@ static int inet_diag_fill_req(struct sk_buff *skb, struct sock *sk,
 		return -EMSGSIZE;
 
 	r = nlmsg_data(nlh);
-	r->idiag_family = sk->sk_family;
+	r->idiag_family = ireq->ireq_family;
 	r->idiag_state = TCP_SYN_RECV;
 	r->idiag_timer = 1;
 	r->idiag_retrans = req->num_retrans;
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 96330ad19744..8717a2b23b8e 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -348,6 +348,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	treq->listener		= NULL;
 	write_pnet(&ireq->ireq_net, sock_net(sk));
 	ireq->ireq_state = TCP_NEW_SYN_RECV;
+	ireq->ireq_family = AF_INET;
 
 	/* We throwed the options of the initial SYN away, so we hope
 	 * the ACK carries the same options again (see RFC1122 4.2.3.8)
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 70b0f701bbdb..1f514a0c5e60 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1228,6 +1228,7 @@ static void tcp_v4_init_req(struct request_sock *req, struct sock *sk,
 	ireq->ir_rmt_addr = ip_hdr(skb)->saddr;
 	ireq->no_srccheck = inet_sk(sk)->transparent;
 	ireq->opt = tcp_v4_save_options(skb);
+	ireq->ireq_family = AF_INET;
 }
 
 static struct dst_entry *tcp_v4_route_req(struct sock *sk, struct flowi *fl,
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index d8b4fed2a9b6..8af02e080a7a 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -198,6 +198,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	treq->listener = NULL;
 	write_pnet(&ireq->ireq_net, sock_net(sk));
 	ireq->ireq_state = TCP_NEW_SYN_RECV;
+	ireq->ireq_family = AF_INET6;
 
 	if (security_inet_conn_request(sk, skb, req))
 		goto out_free;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 1ccfede7d55f..c5fc6a5e4adc 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -749,6 +749,7 @@ static void tcp_v6_init_req(struct request_sock *req, struct sock *sk,
 		atomic_inc(&skb->users);
 		ireq->pktopts = skb;
 	}
+	ireq->ireq_family = AF_INET6;
 }
 
 static struct dst_entry *tcp_v6_route_req(struct sock *sk, struct flowi *fl,
-- 
2.2.0.rc0.207.ga3a616c
