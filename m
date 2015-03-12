From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/7] inet: add ireq_state field to inet_request_sock
Date: Thu, 12 Mar 2015 14:50:11 -0700
Message-ID: <1426197016-14482-3-git-send-email-edumazet@google.com>
References: <1426197016-14482-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f202.google.com ([209.85.214.202]:34559 "EHLO
	mail-ob0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755071AbbCLVuk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 17:50:40 -0400
Received: by obcwp18 with SMTP id wp18so4916424obc.1
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 14:50:39 -0700 (PDT)
In-Reply-To: <1426197016-14482-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to identify request sock when they'll be visible in
global ehash table.

ireq_state is an alias to req.__req_common.skc_state.

Its value is set to TCP_NEW_SYN_RECV

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_sock.h | 1 +
 net/dccp/ipv4.c         | 1 +
 net/dccp/ipv6.c         | 3 +++
 net/ipv4/syncookies.c   | 1 +
 net/ipv4/tcp_input.c    | 1 +
 net/ipv6/syncookies.c   | 2 ++
 6 files changed, 9 insertions(+)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index e565afdc14ad..e6991bff91b0 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -79,6 +79,7 @@ struct inet_request_sock {
 #define ir_iif			req.__req_common.skc_bound_dev_if
 #define ir_cookie		req.__req_common.skc_cookie
 #define ireq_net		req.__req_common.skc_net
+#define ireq_state		req.__req_common.skc_state
 
 	kmemcheck_bitfield_begin(flags);
 	u16			snd_wscale : 4,
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index a78e0b999f96..af839396b714 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -642,6 +642,7 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	ireq->ir_loc_addr = ip_hdr(skb)->daddr;
 	ireq->ir_rmt_addr = ip_hdr(skb)->saddr;
 	write_pnet(&ireq->ireq_net, sock_net(sk));
+	ireq->ireq_state = TCP_NEW_SYN_RECV;
 	atomic64_set(&ireq->ir_cookie, 0);
 
 	/*
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 6bcaa33cd804..8febaeb12f6d 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -403,6 +403,9 @@ static int dccp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	ireq = inet_rsk(req);
 	ireq->ir_v6_rmt_addr = ipv6_hdr(skb)->saddr;
 	ireq->ir_v6_loc_addr = ipv6_hdr(skb)->daddr;
+	write_pnet(&ireq->ireq_net, sock_net(sk));
+	ireq->ireq_state = TCP_NEW_SYN_RECV;
+	atomic64_set(&ireq->ir_cookie, 0);
 
 	if (ipv6_opt_accepted(sk, skb, IP6CB(skb)) ||
 	    np->rxopt.bits.rxinfo || np->rxopt.bits.rxoinfo ||
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 18e5a67fda81..96330ad19744 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -347,6 +347,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	treq->snt_synack	= tcp_opt.saw_tstamp ? tcp_opt.rcv_tsecr : 0;
 	treq->listener		= NULL;
 	write_pnet(&ireq->ireq_net, sock_net(sk));
+	ireq->ireq_state = TCP_NEW_SYN_RECV;
 
 	/* We throwed the options of the initial SYN away, so we hope
 	 * the ACK carries the same options again (see RFC1122 4.2.3.8)
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 26f24995bd3d..fefbace9ec36 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5966,6 +5966,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 	tmp_opt.tstamp_ok = tmp_opt.saw_tstamp;
 	tcp_openreq_init(req, &tmp_opt, skb, sk);
 	write_pnet(&inet_rsk(req)->ireq_net, sock_net(sk));
+	inet_rsk(req)->ireq_state = TCP_NEW_SYN_RECV;
 	atomic64_set(&inet_rsk(req)->ir_cookie, 0);
 
 	af_ops->init_req(req, sk, skb);
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 7337fc7947e2..d8b4fed2a9b6 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -196,6 +196,8 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	ireq = inet_rsk(req);
 	treq = tcp_rsk(req);
 	treq->listener = NULL;
+	write_pnet(&ireq->ireq_net, sock_net(sk));
+	ireq->ireq_state = TCP_NEW_SYN_RECV;
 
 	if (security_inet_conn_request(sk, skb, req))
 		goto out_free;
-- 
2.2.0.rc0.207.ga3a616c
