From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 6/6] inet: request sock should init IPv6/IPv4 addresses
Date: Wed, 18 Mar 2015 14:05:38 -0700
Message-ID: <1426712738-23395-7-git-send-email-edumazet@google.com>
References: <1426712738-23395-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:33678 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755058AbbCRVLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 17:11:48 -0400
Received: by yhoc41 with SMTP id c41so1943622yho.0
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2015 14:11:48 -0700 (PDT)
In-Reply-To: <1426712738-23395-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to be able to use sk_ehashfn() for request socks,
we need to initialize their IPv6/IPv4 addresses.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/request_sock.h | 5 +++++
 net/dccp/ipv4.c            | 4 ++--
 net/ipv4/inet_diag.c       | 4 ++--
 net/ipv4/syncookies.c      | 4 ++--
 net/ipv4/tcp_ipv4.c        | 8 ++++----
 5 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 3fa4f824900a..e7ef86340514 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -91,6 +91,11 @@ static inline struct request_sock *inet_reqsk(struct sock *sk)
 	return (struct request_sock *)sk;
 }
 
+static inline struct sock *req_to_sk(struct request_sock *req)
+{
+	return (struct sock *)req;
+}
+
 static inline void reqsk_free(struct request_sock *req)
 {
 	/* temporary debugging */
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index f3f8906f482e..e7ad291cd96b 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -638,8 +638,8 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		goto drop_and_free;
 
 	ireq = inet_rsk(req);
-	ireq->ir_loc_addr = ip_hdr(skb)->daddr;
-	ireq->ir_rmt_addr = ip_hdr(skb)->saddr;
+	sk_rcv_saddr_set(req_to_sk(req), ip_hdr(skb)->daddr);
+	sk_daddr_set(req_to_sk(req), ip_hdr(skb)->saddr);
 	ireq->ireq_family = AF_INET;
 	ireq->ir_iif = sk->sk_bound_dev_if;
 
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index e7ba59038c8d..74c39c9f3e11 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -742,14 +742,14 @@ static int inet_diag_dump_reqs(struct sk_buff *skb, struct sock *sk,
 
 			if (bc) {
 				/* Note: entry.sport and entry.userlocks are already set */
-				entry_fill_addrs(&entry, (struct sock *)req);
+				entry_fill_addrs(&entry, req_to_sk(req));
 				entry.dport = ntohs(ireq->ir_rmt_port);
 
 				if (!inet_diag_bc_run(bc, &entry))
 					continue;
 			}
 
-			err = inet_req_diag_fill((struct sock *)req, skb,
+			err = inet_req_diag_fill(req_to_sk(req), skb,
 						 NETLINK_CB(cb->skb).portid,
 						 cb->nlh->nlmsg_seq,
 						 NLM_F_MULTI, cb->nlh);
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 34e755403715..ef01d8570358 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -337,8 +337,8 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	req->mss		= mss;
 	ireq->ir_num		= ntohs(th->dest);
 	ireq->ir_rmt_port	= th->source;
-	ireq->ir_loc_addr	= ip_hdr(skb)->daddr;
-	ireq->ir_rmt_addr	= ip_hdr(skb)->saddr;
+	sk_rcv_saddr_set(req_to_sk(req), ip_hdr(skb)->daddr);
+	sk_daddr_set(req_to_sk(req), ip_hdr(skb)->saddr);
 	ireq->ir_mark		= inet_request_mark(sk, skb);
 	ireq->snd_wscale	= tcp_opt.snd_wscale;
 	ireq->sack_ok		= tcp_opt.sack_ok;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ca207df4af1c..ddd0b1f25b96 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1219,14 +1219,14 @@ static bool tcp_v4_inbound_md5_hash(struct sock *sk, const struct sk_buff *skb)
 
 #endif
 
-static void tcp_v4_init_req(struct request_sock *req, struct sock *sk,
+static void tcp_v4_init_req(struct request_sock *req, struct sock *sk_listener,
 			    struct sk_buff *skb)
 {
 	struct inet_request_sock *ireq = inet_rsk(req);
 
-	ireq->ir_loc_addr = ip_hdr(skb)->daddr;
-	ireq->ir_rmt_addr = ip_hdr(skb)->saddr;
-	ireq->no_srccheck = inet_sk(sk)->transparent;
+	sk_rcv_saddr_set(req_to_sk(req), ip_hdr(skb)->daddr);
+	sk_daddr_set(req_to_sk(req), ip_hdr(skb)->saddr);
+	ireq->no_srccheck = inet_sk(sk_listener)->transparent;
 	ireq->opt = tcp_v4_save_options(skb);
 	ireq->ireq_family = AF_INET;
 }
-- 
2.2.0.rc0.207.ga3a616c
