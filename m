From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 1/8] ipv6: add missing ireq_net & ir_cookie initializations
Date: Thu, 12 Mar 2015 16:44:03 -0700
Message-ID: <1426203850-11034-2-git-send-email-edumazet@google.com>
References: <1426203850-11034-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f73.google.com ([209.85.220.73]:33602 "EHLO
	mail-pa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752991AbbCLXog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 19:44:36 -0400
Received: by pablj1 with SMTP id lj1so5783571pab.0
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 16:44:35 -0700 (PDT)
In-Reply-To: <1426203850-11034-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I forgot to update dccp_v6_conn_request() & cookie_v6_check().
They both need to set ireq->ireq_net and ireq->ir_cookie

Lets clear ireq->ir_cookie in inet_reqsk_alloc()

Signed-off-by: Eric Dumazet <edumazet@google.com>
Fixes: 33cf7c90fe2f ("net: add real socket cookies")
---
 include/net/inet_sock.h | 1 +
 net/dccp/ipv4.c         | 1 -
 net/dccp/ipv6.c         | 1 +
 net/ipv4/tcp_input.c    | 1 -
 net/ipv6/syncookies.c   | 1 +
 5 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index e565afdc14ad..30f7170abbf3 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -249,6 +249,7 @@ static inline struct request_sock *inet_reqsk_alloc(struct request_sock_ops *ops
 	if (req != NULL) {
 		kmemcheck_annotate_bitfield(ireq, flags);
 		ireq->opt = NULL;
+		atomic64_set(&ireq->ir_cookie, 0);
 	}
 
 	return req;
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index a78e0b999f96..f695874b5ade 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -642,7 +642,6 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	ireq->ir_loc_addr = ip_hdr(skb)->daddr;
 	ireq->ir_rmt_addr = ip_hdr(skb)->saddr;
 	write_pnet(&ireq->ireq_net, sock_net(sk));
-	atomic64_set(&ireq->ir_cookie, 0);
 
 	/*
 	 * Step 3: Process LISTEN state
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 6bcaa33cd804..703a21acf434 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -403,6 +403,7 @@ static int dccp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	ireq = inet_rsk(req);
 	ireq->ir_v6_rmt_addr = ipv6_hdr(skb)->saddr;
 	ireq->ir_v6_loc_addr = ipv6_hdr(skb)->daddr;
+	write_pnet(&ireq->ireq_net, sock_net(sk));
 
 	if (ipv6_opt_accepted(sk, skb, IP6CB(skb)) ||
 	    np->rxopt.bits.rxinfo || np->rxopt.bits.rxoinfo ||
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 26f24995bd3d..da61a8e75f68 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5966,7 +5966,6 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 	tmp_opt.tstamp_ok = tmp_opt.saw_tstamp;
 	tcp_openreq_init(req, &tmp_opt, skb, sk);
 	write_pnet(&inet_rsk(req)->ireq_net, sock_net(sk));
-	atomic64_set(&inet_rsk(req)->ir_cookie, 0);
 
 	af_ops->init_req(req, sk, skb);
 
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 7337fc7947e2..66bba6a84e47 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -196,6 +196,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	ireq = inet_rsk(req);
 	treq = tcp_rsk(req);
 	treq->listener = NULL;
+	write_pnet(&ireq->ireq_net, sock_net(sk));
 
 	if (security_inet_conn_request(sk, skb, req))
 		goto out_free;
-- 
2.2.0.rc0.207.ga3a616c
