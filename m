From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: fix ipv4 mapped request socks
Date: Tue, 24 Mar 2015 21:45:56 -0700
Message-ID: <1427258756.25985.104.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:33481 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720AbbCYEp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 00:45:59 -0400
Received: by ignm3 with SMTP id m3so64456815ign.0
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 21:45:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

ss should display ipv4 mapped request sockets like this :

tcp    SYN-RECV   0      0  ::ffff:192.168.0.1:8080   ::ffff:192.0.2.1:35261 

and not like this :

tcp    SYN-RECV   0      0  192.168.0.1:8080   192.0.2.1:35261 

We should init ireq->ireq_family based on listener sk_family,
not the actual protocol carried by SYN packet.

This means we can set ireq_family in inet_reqsk_alloc()

Signed-off-by: Eric Dumazet <edumazet@google.com>
Fixes: 3f66b083a5b7 ("inet: introduce ireq_family")
---
 net/ipv4/syncookies.c |    1 -
 net/ipv4/tcp_input.c  |    2 +-
 net/ipv4/tcp_ipv4.c   |    1 -
 net/ipv6/syncookies.c |    1 -
 net/ipv6/tcp_ipv6.c   |    1 -
 5 files changed, 1 insertion(+), 5 deletions(-)

diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 805dc444741d1042d9d8b6c2931f33c8b9a3f8b4..df849e5a10f1d7f41fb3353a26356ede81f56f72 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -347,7 +347,6 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	req->ts_recent		= tcp_opt.saw_tstamp ? tcp_opt.rcv_tsval : 0;
 	treq->snt_synack	= tcp_opt.saw_tstamp ? tcp_opt.rcv_tsecr : 0;
 	treq->tfo_listener	= false;
-	ireq->ireq_family = AF_INET;
 
 	ireq->ir_iif = sk->sk_bound_dev_if;
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 95caea707f540b6e84e51b8278f53e9f75423fc2..023196f7ec37a616346bbbef54adea72b7f3269e 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5980,7 +5980,7 @@ struct request_sock *inet_reqsk_alloc(const struct request_sock_ops *ops,
 		atomic64_set(&ireq->ir_cookie, 0);
 		ireq->ireq_state = TCP_NEW_SYN_RECV;
 		write_pnet(&ireq->ireq_net, sock_net(sk_listener));
-
+		ireq->ireq_family = sk_listener->sk_family;
 	}
 
 	return req;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index fc8995a702a6cb784b352727e27b33571e006a85..e073517b2cc727afdbde9161ce4305810a7e9bb4 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1206,7 +1206,6 @@ static void tcp_v4_init_req(struct request_sock *req, struct sock *sk_listener,
 	sk_daddr_set(req_to_sk(req), ip_hdr(skb)->saddr);
 	ireq->no_srccheck = inet_sk(sk_listener)->transparent;
 	ireq->opt = tcp_v4_save_options(skb);
-	ireq->ireq_family = AF_INET;
 }
 
 static struct dst_entry *tcp_v4_route_req(struct sock *sk, struct flowi *fl,
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 2819137fc87dae7e60cbac44037da8cf0b26a989..21bc2eb53c57bce6dd0a1073bc77766eabf9ac5f 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -197,7 +197,6 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	ireq = inet_rsk(req);
 	treq = tcp_rsk(req);
 	treq->tfo_listener = false;
-	ireq->ireq_family = AF_INET6;
 
 	if (security_inet_conn_request(sk, skb, req))
 		goto out_free;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index a9568caf4675985343e52e2dd97a32f7bd85d74a..cbdf6912d2c690a085701b789c6c30494665a049 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -688,7 +688,6 @@ static void tcp_v6_init_req(struct request_sock *req, struct sock *sk,
 		atomic_inc(&skb->users);
 		ireq->pktopts = skb;
 	}
-	ireq->ireq_family = AF_INET6;
 }
 
 static struct dst_entry *tcp_v6_route_req(struct sock *sk, struct flowi *fl,
